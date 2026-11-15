import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/chat_message.dart';

class GeminiService {
  static const String defaultModel = 'gemini-1.5-flash';

  static const List<String> availableModels = [
    'gemini-1.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-pro',
  ];

  final http.Client _client;

  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  /// Closes internal HTTP client and releases resources
  void dispose() {
    _client.close();
  }

  /// Regex pattern to detect Google API keys (starts with AIza and has 35 chars)
  static final RegExp _apiKeyRegex = RegExp(r'AIza[0-9A-Za-z\-_]{35}');
  static final RegExp _bearerRegex = RegExp(r'Bearer\s+[A-Za-z0-9\-_\.]+', caseSensitive: false);

  /// Sanitizes any string to guarantee API keys or credentials never leak into exceptions or logs
  static String sanitize(String input, [String? specificKey]) {
    var sanitized = input;
    if (specificKey != null && specificKey.trim().length >= 8) {
      sanitized = sanitized.replaceAll(specificKey.trim(), '[REDACTED_API_KEY]');
    }
    sanitized = sanitized.replaceAll(_apiKeyRegex, '[REDACTED_API_KEY]');
    sanitized = sanitized.replaceAll(_bearerRegex, '[REDACTED_TOKEN]');
    return sanitized;
  }

  /// Sends a conversation message list to Google Gemini API
  Future<String> generateContent({
    required String apiKey,
    required String systemInstruction,
    required List<ChatMessage> history,
    required String userMessage,
    String model = defaultModel,
  }) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      throw const GeminiException(
        'کلید API جمینای تنظیم نشده است. لطفاً از بخش تنظیمات هوش مصنوعی کلید خود را وارد کنید.',
      );
    }

    final selectedModel = availableModels.contains(model) ? model : defaultModel;
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$selectedModel:generateContent',
    );

    // Build contents array for multi-turn contextual conversation
    final contents = <Map<String, dynamic>>[];

    // Include previous turns (limit to last 10 messages for token budget)
    final recentHistory = history.length > 10 ? history.sublist(history.length - 10) : history;
    for (var msg in recentHistory) {
      if (msg.isError) continue;
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ],
      });
    }

    // Add current user message
    contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ],
    });

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1500,
      },
    };

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-goog-api-key': cleanKey,
    };

    return _executeWithRetry(
      cleanKey: cleanKey,
      action: () async {
        final response = await _client
            .post(
              uri,
              headers: headers,
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 30));

        return _parseContentResponse(response, cleanKey);
      },
    );
  }

  /// Tests connectivity with a simple ping request
  /// API key is sent STRICTLY via headers and NEVER via URL query parameters
  Future<bool> testConnection({
    required String apiKey,
    String model = defaultModel,
  }) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) return false;

    final selectedModel = availableModels.contains(model) ? model : defaultModel;
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$selectedModel:generateContent',
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'x-goog-api-key': cleanKey,
            },
            body: jsonEncode({
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': 'Ping test. Respond with OK.'}
                  ]
                }
              ]
            }),
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Analyzes a meal image using Gemini Vision API
  Future<Map<String, dynamic>> analyzeFoodImage({
    required String apiKey,
    required List<int> imageBytes,
    String mimeType = 'image/jpeg',
    String model = defaultModel,
  }) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      throw const GeminiException(
        'کلید API جمینای تنظیم نشده است. لطفاً از بخش تنظیمات کلید خود را وارد کنید.',
      );
    }

    final selectedModel = availableModels.contains(model) ? model : defaultModel;
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$selectedModel:generateContent',
    );

    final base64Image = base64Encode(imageBytes);

    final requestBody = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
            {
              'text': 'این تصویر یک وعده غذایی است. به عنوان متخصص تغذیه ورزشی، غذا را شناسایی کن و ارزش غذایی آن را تخمین بزن. پاسخ را دقیقاً و صرفاً به صورت یک آبجکت JSON معتبر به این فرمت برگردان:\n'
                  '{\n'
                  '  "food_name": "نام دقیق غذا به فارسی",\n'
                  '  "calories": 650,\n'
                  '  "protein_g": 42.0,\n'
                  '  "carbs_g": 65.0,\n'
                  '  "fat_g": 18.0,\n'
                  '  "portion_g": 350.0,\n'
                  '  "description": "توضیح کوتاه در مورد سازگاری با رژیم و میزان کیفیت پروتئین"\n'
                  '}'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 800,
      },
    };

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-goog-api-key': cleanKey,
    };

    return _executeWithRetry(
      cleanKey: cleanKey,
      action: () async {
        final response = await _client
            .post(
              uri,
              headers: headers,
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 35));

        return _parseVisionResponse(response, cleanKey);
      },
    );
  }

  /// Executes request with retry policy for transient server errors (500, 502, 503, 504)
  Future<T> _executeWithRetry<T>({
    required String cleanKey,
    required Future<T> Function() action,
  }) async {
    try {
      return await action();
    } on SocketException {
      // Retry once for transient socket disconnect
      try {
        await Future.delayed(const Duration(milliseconds: 600));
        return await action();
      } on SocketException {
        throw const GeminiException(
          'خطا در برقراری ارتباط شبکه با سرورهای گوگل. لطفاً اتصال اینترنت یا پروکسی خود را بررسی کنید.',
        );
      }
    } on TimeoutException {
      throw const GeminiException(
        'مهلت زمان پاسخ‌دهی هوش مصنوعی به پایان رسید (Timeout). لطفاً دوباره امتحان کنید.',
      );
    } catch (e) {
      if (e is GeminiException) rethrow;
      final safeMessage = sanitize(e.toString(), cleanKey);
      throw GeminiException('خطای غیرمنتظره در ارتباط با هوش مصنوعی: $safeMessage');
    }
  }

  /// Parses text generation response with complete candidate and safety inspection
  String _parseContentResponse(http.Response response, String cleanKey) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } catch (_) {
        throw const GeminiException('پاسخ سرور گوگل در قالب JSON معتبر دریافت نشد.');
      }

      // Check prompt feedback block
      final promptFeedback = data['promptFeedback'] as Map<String, dynamic>?;
      if (promptFeedback != null && promptFeedback['blockReason'] != null) {
        final reason = promptFeedback['blockReason'];
        throw GeminiException('درخواست شما به دلیل خط‌مشی ایمنی هوش مصنوعی مسدود شد ($reason).');
      }

      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw const GeminiException('متاسفانه پاسخی از مدل دریافت نشد (نامزد خالی).');
      }

      final firstCandidate = candidates.first as Map<String, dynamic>?;
      if (firstCandidate == null) {
        throw const GeminiException('ساختار نامزد پاسخ معتبر نیست.');
      }

      final finishReason = firstCandidate['finishReason'] as String?;
      if (finishReason == 'SAFETY') {
        throw const GeminiException('پاسخ هوش مصنوعی به دلیل سیاست‌های فیلتر ایمنی محتوا متوقف شد.');
      } else if (finishReason == 'RECITATION') {
        throw const GeminiException('پاسخ هوش مصنوعی به دلیل محدودیت نقل‌قول متوقف شد.');
      }

      final content = firstCandidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts != null && parts.isNotEmpty) {
        final textParts = parts
            .whereType<Map<String, dynamic>>()
            .map((p) => (p['text'] ?? '').toString())
            .where((t) => t.trim().isNotEmpty)
            .toList();

        if (textParts.isNotEmpty) {
          return textParts.join('\n').trim();
        }
      }
      return 'متاسفانه محتوای متنی از مدل دریافت نشد.';
    } else if (response.statusCode == 429) {
      throw const GeminiException(
        'سقف درخواست‌های مجاز جمینای تکمیل شده است (Rate Limit). لطفاً چند لحظه دیگر مجدداً سوال فرمایید.',
      );
    } else if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      final errorMsg = _extractErrorMessage(response.body, cleanKey);
      throw GeminiException(
        'خطای احراز هویت یا دسترسی Google AI Studio: $errorMsg (کلید API یا فیلترشکن را بررسی کنید).',
      );
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw GeminiException(
        'سرورهای گوگل موقتاً با اختلال مواجه شده‌اند (کد ${response.statusCode}). لطفاً اندکی بعد تلاش کنید.',
      );
    } else {
      throw GeminiException(
        'خطای سرور گوگل (کد ${response.statusCode}). لطفاً مجدداً تلاش کنید.',
      );
    }
  }

  /// Parses vision analysis response with resilient JSON extraction
  Map<String, dynamic> _parseVisionResponse(http.Response response, String cleanKey) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } catch (_) {
        throw const GeminiException('پاسخ سرور گوگل در قالب JSON معتبر دریافت نشد.');
      }

      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final candidate = candidates.first as Map<String, dynamic>?;
        final parts = candidate?['content']?['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          String rawText = parts
              .whereType<Map<String, dynamic>>()
              .map((p) => p['text'] ?? '')
              .join()
              .trim();

          // Strip markdown fences
          if (rawText.startsWith('```json')) {
            rawText = rawText.substring(7);
          } else if (rawText.startsWith('```')) {
            rawText = rawText.substring(3);
          }
          if (rawText.endsWith('```')) {
            rawText = rawText.substring(0, rawText.length - 3);
          }
          rawText = rawText.trim();

          // Locate JSON block if surrounding prose exists
          final startIndex = rawText.indexOf('{');
          final endIndex = rawText.lastIndexOf('}');
          if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
            rawText = rawText.substring(startIndex, endIndex + 1);
          }

          try {
            final parsedJson = jsonDecode(rawText);
            if (parsedJson is Map<String, dynamic>) {
              return parsedJson;
            }
          } catch (_) {
            throw const GeminiException('قالب JSON اطلاعات تغذیه غذا معتبر نیست.');
          }
        }
      }
      throw const GeminiException('پاسخ مدل به ساختار داده معتبر تبدیل نشد.');
    } else if (response.statusCode == 429) {
      throw const GeminiException(
        'سقف درخواست‌های مجاز اسکن تصویر تکمیل شده است. لطفاً کمی بعد تلاش کنید.',
      );
    } else {
      final errorMsg = _extractErrorMessage(response.body, cleanKey);
      throw GeminiException('خطا در آنالیز تصویر غذا: $errorMsg');
    }
  }

  static String _extractErrorMessage(String responseBody, [String? cleanKey]) {
    try {
      final data = jsonDecode(responseBody);
      if (data['error'] != null && data['error']['message'] != null) {
        final rawMsg = data['error']['message'].toString();
        return sanitize(rawMsg, cleanKey);
      }
    } catch (_) {}
    return 'کلید نامعتبر است یا موقعیت مکانی تحریم شده است.';
  }
}

class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);

  @override
  String toString() => message;
}
