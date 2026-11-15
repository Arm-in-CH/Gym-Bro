import 'package:flutter/foundation.dart';
import '../core/ai/gemini_service.dart';
import '../core/ai/openrouter_ai_service.dart';
import '../core/repository/settings_repository.dart';
import '../models/chat_message.dart';

class AiState extends ChangeNotifier {
  final ISettingsRepository settingsRepository;
  final GeminiService geminiService;
  final OpenRouterAiService aiService;
  final String Function()? systemPromptBuilder;

  List<ChatMessage> chatMessages = [];
  bool isAiLoading = false;
  bool isScanningFood = false;

  String geminiApiKey = '';
  String geminiModel = 'gemini-1.5-flash';
  String openRouterApiKey = '';

  AiState({
    required this.settingsRepository,
    GeminiService? geminiService,
    OpenRouterAiService? aiService,
    this.systemPromptBuilder,
    String? initialGeminiApiKey,
    String? initialGeminiModel,
    String? initialOpenRouterApiKey,
  })  : geminiService = geminiService ?? GeminiService(),
        aiService = aiService ?? OpenRouterAiService() {
    if (initialGeminiApiKey != null) geminiApiKey = initialGeminiApiKey;
    if (initialGeminiModel != null) geminiModel = initialGeminiModel;
    if (initialOpenRouterApiKey != null) openRouterApiKey = initialOpenRouterApiKey;

    _ensureWelcomeMessage();
  }

  void _ensureWelcomeMessage() {
    if (chatMessages.isEmpty) {
      chatMessages.add(ChatMessage(
        id: 'welcome_msg',
        text:
            'درود آرمین جان! من جیم‌برو (GymBro AI Coach)، مربی هوشمند و دستیار اختصاصی تو هستم.\nتمام اطلاعات بدنی، رکوردهای تمرینی PPL و آمار تغذیه‌ات را در اختیار دارم. چطور می‌تونم امروز کمکت کنم؟',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> loadFromRepository() async {
    geminiApiKey = await settingsRepository.getGeminiApiKey();
    geminiModel = await settingsRepository.getGeminiModel();
    openRouterApiKey = await settingsRepository.getOpenRouterApiKey();
    notifyListeners();
  }

  Future<void> saveGeminiConfig({
    required String apiKey,
    required String model,
  }) async {
    geminiApiKey = apiKey.trim();
    geminiModel = model.trim();
    await settingsRepository.saveGeminiApiKey(geminiApiKey);
    await settingsRepository.saveGeminiModel(geminiModel);
    notifyListeners();
  }

  Future<void> updateApiKey(String key) async {
    openRouterApiKey = key.trim();
    await settingsRepository.saveOpenRouterApiKey(openRouterApiKey);
    notifyListeners();
  }

  Future<bool> testGeminiConnection({
    required String apiKey,
    required String model,
  }) async {
    return await geminiService.testConnection(
      apiKey: apiKey.trim(),
      model: model.trim(),
    );
  }

  Future<Map<String, dynamic>> scanFoodWithGeminiVision(
    List<int> imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    isScanningFood = true;
    notifyListeners();
    try {
      if (geminiApiKey.trim().isEmpty) {
        throw const GeminiException(
          'کلید API جمینای تنظیم نشده است. لطفاً از بخش تنظیمات کلید خود را وارد کنید.',
        );
      }
      final result = await geminiService.analyzeFoodImage(
        apiKey: geminiApiKey.trim(),
        imageBytes: imageBytes,
        mimeType: mimeType,
        model: geminiModel,
      );
      isScanningFood = false;
      notifyListeners();
      return result;
    } catch (e) {
      isScanningFood = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearChatMessages() {
    chatMessages.clear();
    chatMessages.add(ChatMessage(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      text:
          'تاریخچه پیام‌ها پاکسازی شد. تمام داده‌های بدنی، ورزشی و تغذیه‌ای تو همچنان برای پاسخ‌گویی در دسترسم هستند.',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> sendAiMessage(
    String userText, {
    String? systemPrompt,
  }) async {
    final text = userText.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    chatMessages.add(userMsg);
    isAiLoading = true;
    notifyListeners();

    try {
      final prompt = systemPrompt ?? systemPromptBuilder?.call() ?? '';

      final responseText = await geminiService.generateContent(
        apiKey: geminiApiKey,
        model: geminiModel,
        systemInstruction: prompt,
        history: chatMessages
            .where((m) => m.id != 'welcome_msg' && !m.isError)
            .toList(),
        userMessage: text,
      );

      chatMessages.add(ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } on GeminiException catch (e) {
      chatMessages.add(ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        text: 'خطا: ${e.message}',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } catch (e) {
      final safeError = GeminiService.sanitize(e.toString(), geminiApiKey);
      chatMessages.add(ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        text: 'خطا: خطایی در ارتباط با هوش مصنوعی رخ داد: $safeError',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      isAiLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    geminiService.dispose();
    aiService.dispose();
    super.dispose();
  }
}
