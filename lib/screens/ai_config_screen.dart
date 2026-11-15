import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_tokens.dart';
import '../core/ai/gemini_service.dart';
import '../state/app_state.dart';
import '../widgets/adaptive_container.dart';

class AiConfigScreen extends StatefulWidget {
  final AppState state;

  const AiConfigScreen({super.key, required this.state});

  @override
  State<AiConfigScreen> createState() => _AiConfigScreenState();
}

class _AiConfigScreenState extends State<AiConfigScreen> {
  late TextEditingController _apiKeyController;
  late String _selectedModel;
  bool _obscureKey = true;
  bool _isTesting = false;
  bool? _testSuccess;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.state.geminiApiKey);
    _selectedModel = widget.state.geminiModel;
    if (!GeminiService.availableModels.contains(_selectedModel)) {
      _selectedModel = GeminiService.defaultModel;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testSuccess = false;
        _testMessage = 'لطفاً ابتدا کلید API را وارد کنید.';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testSuccess = null;
      _testMessage = null;
    });

    try {
      final success = await widget.state.testGeminiConnection(
        apiKey: key,
        model: _selectedModel,
      );

      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testSuccess = success;
        _testMessage = success
            ? 'اتصال به Google AI Studio با موفقیت برقرار شد!'
            : 'خطا در برقراری ارتباط با گوگل. کلید API یا اینترنت/پروکسی را بررسی فرمایید.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testSuccess = false;
        _testMessage = 'خطا در تست: ${e.toString()}';
      });
    }
  }

  Future<void> _saveConfig() async {
    final tokens = context.appTokens;
    final key = _apiKeyController.text.trim();
    await widget.state.saveGeminiConfig(
      apiKey: key,
      model: _selectedModel,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تنظیمات هوش مصنوعی جمینای با موفقیت ذخیره شد.'),
          backgroundColor: tokens.limeDark,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data != null && data.text != null) {
      setState(() {
        _apiKeyController.text = data.text!.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات هوش مصنوعی Gemini'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: AdaptiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: tokens.cardBackground,
                    borderRadius: AppRadii.baseRadius,
                    border: Border.all(
                      color: widget.state.geminiApiKey.isNotEmpty
                          ? tokens.lime.withOpacity(0.4)
                          : tokens.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.state.geminiApiKey.isNotEmpty
                              ? tokens.lime.withOpacity(0.15)
                              : tokens.cardElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.state.geminiApiKey.isNotEmpty
                              ? Icons.smart_toy
                              : Icons.smart_toy_outlined,
                          color: widget.state.geminiApiKey.isNotEmpty
                              ? tokens.lime
                              : tokens.textMuted,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.state.geminiApiKey.isNotEmpty
                                  ? 'سرویس هوش مصنوعی آماده است'
                                  : 'کلید API هنوز تنظیم نشده است',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'مدل فعال: $_selectedModel',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        label: 'وضعیت کلید هوش مصنوعی',
                        value: widget.state.geminiApiKey.isNotEmpty
                            ? 'کلید ذخیره شده و فعال است'
                            : 'کلیدی ثبت نشده است',
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.state.geminiApiKey.isNotEmpty
                                ? tokens.lime
                                : tokens.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // API Key Section
                Text(
                  'کلید اختصاصی Google AI Studio',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'کلید به صورت امن در حافظه محلی دستگاه ذخیره می‌شود و به هیچ سرور واسطه‌ای ارسال نمی‌گردد.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureKey,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'کلید اختصاصی Google Gemini API',
                    hintText: 'AIzaSy... یا AQ.Ab...',
                    prefixIcon: ExcludeSemantics(
                      child: Icon(Icons.key, color: tokens.lime),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscureKey
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: tokens.textMuted,
                          ),
                          onPressed: () {
                            setState(() => _obscureKey = !_obscureKey);
                          },
                          tooltip: 'نمایش / مخفی کردن',
                        ),
                        IconButton(
                          icon: Icon(Icons.paste, color: tokens.lime),
                          onPressed: _pasteFromClipboard,
                          tooltip: 'چسباندن از کلیپ‌بورد',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Model Selection
                Text(
                  'انتخاب مدل هوش مصنوعی',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                ...GeminiService.availableModels.map((m) {
                  final isSelected = _selectedModel == m;
                  String desc = '';
                  if (m == 'gemini-1.5-flash') {
                    desc =
                        'بسیار سریع، سبک، مناسب برای مربی‌گری و پاسخ‌های فوری ورزشی (پیشنهادی)';
                  } else if (m == 'gemini-2.0-flash') {
                    desc =
                        'جدیدترین مدل نسل دوم با درک عمیق‌تر و سرعت فوق‌العاده بالا';
                  } else if (m == 'gemini-1.5-pro') {
                    desc =
                        'مدل با استدلال تحلیلی قوی‌تر برای محاسبات پیچیده بیومکانیک و رژیم';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tokens.lime.withOpacity(0.08)
                          : tokens.cardBackground,
                      borderRadius: AppRadii.baseRadius,
                      border: Border.all(
                        color: isSelected ? tokens.lime : tokens.borderColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: RadioListTile<String>(
                      value: m,
                      groupValue: _selectedModel,
                      activeColor: tokens.lime,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedModel = val);
                        }
                      },
                      title: Text(
                        m,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? tokens.lime
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        desc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.md),

                // Test Connection Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: tokens.cyan),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.baseRadius,
                      ),
                    ),
                    icon: _isTesting
                        ? Semantics(
                            label: 'در حال تست اتصال به سرور هوش مصنوعی',
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: tokens.cyan),
                            ),
                          )
                        : Icon(Icons.network_check, color: tokens.cyan),
                    label: Text(
                      _isTesting
                          ? 'در حال برقراری ارتباط آزمایشی...'
                          : 'تست اتصال به هوش مصنوعی',
                      style: TextStyle(
                        color: tokens.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                if (_testMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _testSuccess == true
                          ? tokens.lime.withOpacity(0.12)
                          : tokens.red.withOpacity(0.12),
                      borderRadius: AppRadii.mdRadius,
                      border: Border.all(
                        color: _testSuccess == true ? tokens.lime : tokens.red,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _testSuccess == true
                              ? Icons.check_circle
                              : Icons.error_outline,
                          color:
                              _testSuccess == true ? tokens.lime : tokens.red,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _testMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _testSuccess == true
                                  ? tokens.lime
                                  : tokens.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.base),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveConfig,
                    icon: const Icon(Icons.save),
                    label: const Text('ذخیره پیکربندی هوش مصنوعی'),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Help & Guide Note
                Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadii.baseRadius,
                    border: Border.all(color: tokens.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: tokens.gold, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'راهنمای دریافت کلید Google AI Studio',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '۱. به سایت aistudio.google.com مراجعه کنید.\n'
                        '۲. بر روی "Get API key" کلیک کرده و یک کلید رایگان ایجاد کنید.\n'
                        '۳. کلید را در فیلد بالا قرار داده و تست اتصال را بزنید.\n'
                        'نکته: در صورتی که در برقراری ارتباط خطای تحریم یا مکان جغرافیایی مشاهده کردید، از ابزارهای تغییر IP مناسب استفاده فرمایید.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
