import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FoodAnalysisResult {
  final String foodName;
  final String foodNameFa;
  final int estimatedCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double estimatedWeightG;
  final String healthTipFa;
  final bool isSimulated;
  final String? confidenceDescription;
  final bool isFromCamera;

  FoodAnalysisResult({
    required this.foodName,
    required this.foodNameFa,
    required this.estimatedCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.estimatedWeightG,
    required this.healthTipFa,
    this.isSimulated = false,
    this.confidenceDescription,
    this.isFromCamera = false,
  });
}

class FoodAnalysisException implements Exception {
  final String message;

  const FoodAnalysisException(this.message);

  @override
  String toString() => message;
}

class OpenRouterAiService {
  final http.Client _client;

  static const String defaultModel = 'openai/gpt-4o-mini';
  static const String endpoint = 'https://openrouter.ai/api/v1/chat/completions';

  OpenRouterAiService({http.Client? client}) : _client = client ?? http.Client();

  /// Bounded in-memory cache for identical meal nutrition queries (max 50 entries)
  static final Map<String, FoodAnalysisResult> _analysisCache = {};

  /// Releases HTTP connection resources cleanly
  void dispose() {
    _client.close();
  }

  /// Regex pattern to detect OpenRouter / Bearer tokens
  static final RegExp _bearerRegex = RegExp(r'Bearer\s+[A-Za-z0-9\-_\.]+', caseSensitive: false);
  static final RegExp _skRegex = RegExp(r'sk-or-[A-Za-z0-9\-_\.]+');

  /// Sanitizes any string to guarantee OpenRouter keys or credentials never leak into exceptions
  static String sanitize(String input, [String? specificKey]) {
    var sanitized = input;
    if (specificKey != null && specificKey.trim().length >= 6) {
      sanitized = sanitized.replaceAll(specificKey.trim(), '[REDACTED_API_KEY]');
    }
    sanitized = sanitized.replaceAll(_skRegex, '[REDACTED_API_KEY]');
    sanitized = sanitized.replaceAll(_bearerRegex, '[REDACTED_TOKEN]');
    return sanitized;
  }

  Future<FoodAnalysisResult> analyzeFood({
    String? description,
    String? base64Image,
    required String apiKey,
    String model = defaultModel,
  }) async {
    if (description == null && base64Image == null) {
      throw ArgumentError('Provide a food description or image.');
    }

    final cleanKey = apiKey.trim();

    // Check query cache for text meals
    final cacheKey = (description != null && base64Image == null)
        ? '${cleanKey.isEmpty ? "local" : model}:$description'.trim().toLowerCase()
        : null;

    if (cacheKey != null && _analysisCache.containsKey(cacheKey)) {
      return _analysisCache[cacheKey]!;
    }

    final FoodAnalysisResult result;
    // Provider separation: If no OpenRouter key is configured, fallback to offline Persian engine
    if (cleanKey.isEmpty) {
      result = analyzeWithLocalPersianEngine(description);
    } else {
      result = await _callOpenRouter(
        apiKey: cleanKey,
        description: description,
        base64Image: base64Image,
        model: model,
      );
    }

    if (cacheKey != null) {
      if (_analysisCache.length >= 50) {
        _analysisCache.remove(_analysisCache.keys.first);
      }
      _analysisCache[cacheKey] = result;
    }

    return result;
  }

  Future<FoodAnalysisResult> _callOpenRouter({
    required String apiKey,
    String? description,
    String? base64Image,
    String model = defaultModel,
  }) async {
    const prompt = """
You are GymBro AI Nutritionist. Analyze this meal: "%DESC%".
Output ONLY valid JSON with keys:
foodName (string), foodNameFa (string), estimatedCalories (int), proteinG (double), carbsG (double), fatG (double), estimatedWeightG (double), healthTipFa (string).
""";

    final contentList = <Map<String, dynamic>>[
      {"type": "text", "text": prompt.replaceAll('%DESC%', description ?? '')}
    ];

    if (base64Image != null) {
      contentList.add({
        "type": "image_url",
        "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
      });
    }

    final requestBody = {
      "model": model,
      "messages": [
        {
          "role": "user",
          "content": contentList,
        }
      ],
      "temperature": 0.2,
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'HTTP-Referer': 'https://gymbro.app',
      'X-Title': 'GymBro App',
    };

    try {
      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        return _parseOpenRouterResponse(response);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw const FoodAnalysisException(
          'خطای احراز هویت OpenRouter: کلید API نامعتبر است یا منقضی شده است.',
        );
      } else if (response.statusCode == 429) {
        throw const FoodAnalysisException(
          'سقف درخواست‌های سرویس OpenRouter تکمیل شده است (Rate Limit). لطفاً اندکی بعد امتحان کنید.',
        );
      } else if (response.statusCode >= 500) {
        throw FoodAnalysisException(
          'سرورهای OpenRouter موقتاً با اختلال مواجه شده‌اند (کد ${response.statusCode}).',
        );
      } else {
        throw FoodAnalysisException(
          'درخواست OpenRouter با خطای ${response.statusCode} مواجه شد.',
        );
      }
    } on SocketException {
      throw const FoodAnalysisException(
        'خطا در برقراری ارتباط شبکه با سرور OpenRouter. اتصال اینترنت را بررسی کنید.',
      );
    } on TimeoutException {
      throw const FoodAnalysisException(
        'مهلت زمان پاسخ‌دهی سرویس OpenRouter به پایان رسید (Timeout).',
      );
    } catch (e) {
      if (e is FoodAnalysisException) rethrow;
      final safeMsg = sanitize(e.toString(), apiKey);
      throw FoodAnalysisException('خطای غیرمنتظره در ارتباط با OpenRouter: $safeMsg');
    }
  }

  FoodAnalysisResult _parseOpenRouterResponse(http.Response response) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw const FoodAnalysisException('پاسخ سرور در قالب معتبر JSON دریافت نشد.');
    }

    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const FoodAnalysisException('هیچ گزینه‌ای در پاسخ سرور یافت نشد.');
    }

    final firstChoice = choices.first as Map<String, dynamic>?;
    final message = firstChoice?['message'] as Map<String, dynamic>?;
    final rawContent = message?['content'] as String?;

    if (rawContent == null || rawContent.trim().isEmpty) {
      throw const FoodAnalysisException('پاسخ دریافتی فاقد محتوای متنی است.');
    }

    var clean = rawContent
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final startIndex = clean.indexOf('{');
    final endIndex = clean.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
      clean = clean.substring(startIndex, endIndex + 1);
    }

    final Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(clean) as Map<String, dynamic>;
    } catch (_) {
      throw const FoodAnalysisException('قالب خروجی هوش مصنوعی به عنوان JSON تغذیه قابل تفسیر نبود.');
    }

    return FoodAnalysisResult(
      foodName: parsed['foodName']?.toString() ?? 'Scanned Meal',
      foodNameFa: parsed['foodNameFa']?.toString() ?? 'غذای اسکن شده',
      estimatedCalories: (parsed['estimatedCalories'] as num?)?.toInt() ?? 500,
      proteinG: (parsed['proteinG'] as num?)?.toDouble() ?? 25.0,
      carbsG: (parsed['carbsG'] as num?)?.toDouble() ?? 50.0,
      fatG: (parsed['fatG'] as num?)?.toDouble() ?? 15.0,
      estimatedWeightG: (parsed['estimatedWeightG'] as num?)?.toDouble() ?? 300.0,
      healthTipFa: parsed['healthTipFa']?.toString() ?? 'وعده مغذی و سرشار از پروتئین.',
      isSimulated: false,
    );
  }

  FoodAnalysisResult analyzeWithLocalPersianEngine(String? input) {
    final q = input?.toLowerCase().trim() ?? '';

    if (q.contains('قورمه') || q.contains('قرمه') || q.contains('ghormeh')) {
      return FoodAnalysisResult(
        foodName: 'Ghormeh Sabzi with Rice',
        foodNameFa: 'قورمه‌سبزی با برنج زعفرانی',
        estimatedCalories: 620,
        proteinG: 28.0,
        carbsG: 68.0,
        fatG: 24.0,
        estimatedWeightG: 380.0,
        healthTipFa:
            'روغن اضافی خورشت را جدا کنید و لوبیا قرمز بیشتری برای تامین فیبر و پروتئین اضافه کنید.',
        isSimulated: true,
      );
    } else if (q.contains('قیمه') || q.contains('gheimeh')) {
      return FoodAnalysisResult(
        foodName: 'Gheimeh with Rice',
        foodNameFa: 'خورشت قیمه سیب‌زمینی با برنج',
        estimatedCalories: 580,
        proteinG: 26.0,
        carbsG: 72.0,
        fatG: 20.0,
        estimatedWeightG: 360.0,
        healthTipFa:
            'لپه سرشار از پروتئین گیاهی و کربوهیدرات دیرجذب جهت حفظ انرژی در طول تمرین است.',
        isSimulated: true,
      );
    } else if (q.contains('جوجه') ||
        q.contains('joojeh') ||
        q.contains('chicken')) {
      return FoodAnalysisResult(
        foodName: 'Saffron Joojeh Kabab with Rice',
        foodNameFa: 'چلو جوجه‌کباب با گوجه کبابی',
        estimatedCalories: 650,
        proteinG: 48.0,
        carbsG: 65.0,
        fatG: 16.0,
        estimatedWeightG: 400.0,
        healthTipFa:
            'بهترین وعده بعد از تمرین با ۴۸ گرم پروتئین با کیفیت برای سنتز پروتئین عضلانی.',
        isSimulated: true,
      );
    } else if (q.contains('کوبیده') ||
        q.contains('koobideh') ||
        q.contains('کباب')) {
      return FoodAnalysisResult(
        foodName: 'Chelow Kabab Koobideh (1 Skewer)',
        foodNameFa: 'چلو کباب کوبیده با گوجه',
        estimatedCalories: 710,
        proteinG: 34.0,
        carbsG: 65.0,
        fatG: 32.0,
        estimatedWeightG: 390.0,
        healthTipFa:
            'کباب کوبیده حاوی چربی بالاتری است؛ در دوران کات مصرف آن را مدیریت کنید.',
        isSimulated: true,
      );
    } else if (q.contains('سینه مرغ') ||
        q.contains('مرغ') ||
        q.contains('grilled')) {
      return FoodAnalysisResult(
        foodName: 'Grilled Chicken Breast with Sweet Potato',
        foodNameFa: 'سینه مرغ گریل با سیب‌زمینی تنوری',
        estimatedCalories: 480,
        proteinG: 52.0,
        carbsG: 45.0,
        fatG: 8.0,
        estimatedWeightG: 350.0,
        healthTipFa:
            'طلایی‌ترین وعده بدنسازی! ۵۲ گرم پروتئین خالص با حداقل چربی برای ریکاوری فوق‌العاده.',
        isSimulated: true,
      );
    } else if (q.contains('املت') ||
        q.contains('تخم مرغ') ||
        q.contains('egg')) {
      return FoodAnalysisResult(
        foodName: 'Persian Omelette with Barbari Bread',
        foodNameFa: 'املت گوجه‌فرنگی با نان بربری',
        estimatedCalories: 460,
        proteinG: 22.0,
        carbsG: 48.0,
        fatG: 18.0,
        estimatedWeightG: 320.0,
        healthTipFa:
            'کولین موجود در زرده تخم‌مرغ به بهبود تمرکز و انقباض عصبی‌عضلانی در تمرین کمک می‌کند.',
        isSimulated: true,
      );
    } else {
      return FoodAnalysisResult(
        foodName: 'Balanced Athletic Fitness Meal',
        foodNameFa: 'وعده ورزشی پروتئین و کربوهیدرات',
        estimatedCalories: 540,
        proteinG: 36.0,
        carbsG: 58.0,
        fatG: 14.0,
        estimatedWeightG: 350.0,
        healthTipFa:
            'تعادل عالی درشت‌مغذی‌ها برای بازسازی ذخایر گلیکوژن پس از تمرینات سنگین.',
        isSimulated: true,
      );
    }
  }
}
