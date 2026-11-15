import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../core/theme/app_tokens.dart';
import '../core/ai/openrouter_ai_service.dart';
import '../core/services/camera_service.dart';
import '../core/storage/id_generator.dart';
import '../models/calorie_scan_log.dart';
import '../state/app_state.dart';
import '../widgets/cabbage_mascot_loader.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/empty_state_widget.dart';
import '../core/graphics/graphics.dart';

class MealScannerScreen extends StatefulWidget {
  final AppState state;
  final ICameraService? cameraService;

  const MealScannerScreen({
    super.key,
    required this.state,
    this.cameraService,
  });

  @override
  State<MealScannerScreen> createState() => _MealScannerScreenState();
}

class _MealScannerScreenState extends State<MealScannerScreen> {
  late final ICameraService _cameraService;
  CameraController? _cameraController;
  bool _isCameraInitializing = false;
  CameraPermissionStatus _permissionStatus = CameraPermissionStatus.granted;

  CapturedImage? _capturedImage;
  int _activeTabIndex = 0; // 0: دوربین و تصویر, 1: برآورد متنی دستی

  String _selectedMealType = 'ناهار';
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _portionController = TextEditingController();

  bool _isAnalyzing = false;
  bool _isSaving = false;
  String? _errorMessage;
  FoodAnalysisResult? _result;

  final List<String> _mealTypes = ['صبحانه', 'ناهار', 'شام', 'میان‌وعده'];

  final List<String> _quickMeals = [
    '۲ تست پروتئینی + ۱ تخم‌مرغ + کره بادام‌زمینی',
    '۱۰ قاشق برنج + ۱۵۰ گرم فیله مرغ گریل',
    '۱۰ قاشق برنج + ۱۵۰ گرم ماهی گریل',
    '۱ اسکوپ Whey + ۵ گرم کراتین (بعد تمرین)',
    '۲ تست پروتئینی + ۲۰۰ گرم فیله مرغ + ۵ زیتون',
    '۱ سیب‌زمینی پخته + ۲۰۰ گرم استیک گوشت',
    '۱ اسکوپ MPC پروتئین شیر (قبل خواب)',
    'چلو کباب کوبیده با گوجه',
  ];

  @override
  void initState() {
    super.initState();
    _cameraService = widget.cameraService ?? DeviceCameraService();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    setState(() {
      _isCameraInitializing = true;
      _errorMessage = null;
    });

    try {
      final isAvail = await _cameraService.isCameraAvailable();
      if (!isAvail) {
        if (mounted) {
          setState(() {
            _permissionStatus = CameraPermissionStatus.unavailable;
            _isCameraInitializing = false;
          });
        }
        return;
      }

      var status = await _cameraService.checkPermission();
      if (status == CameraPermissionStatus.denied) {
        status = await _cameraService.requestPermission();
      }

      _permissionStatus = status;

      if (_permissionStatus == CameraPermissionStatus.granted) {
        _cameraController = await _cameraService.createController();
      }
    } catch (e) {
      _permissionStatus = CameraPermissionStatus.unavailable;
    } finally {
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }

  Future<void> _capturePhoto() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final image = await _cameraService.takePhoto(_cameraController);
      if (!mounted) return;
      if (image == null) {
        setState(() {
          _errorMessage = 'عکس‌برداری لغو شد یا تصویری دریافت نشد.';
        });
        return;
      }

      if (!image.isValid) {
        setState(() {
          _errorMessage = 'تصویر گرفته‌شده نامعتبر یا بیش از حد حجیم است.';
        });
        return;
      }

      final optimized = image.optimizeForUpload();
      setState(() {
        _capturedImage = optimized;
        _result = null;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطا در ثبت عکس با دوربین: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final image = await _cameraService.pickImageFromGallery();
      if (!mounted) return;
      if (image == null) {
        return; // User cancelled
      }

      if (!image.isValid) {
        setState(() {
          _errorMessage = 'تصویر انتخابی نامعتبر یا بیش از حد حجیم است.';
        });
        return;
      }

      final optimized = image.optimizeForUpload();
      setState(() {
        _capturedImage = optimized;
        _result = null;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطا در بارگذاری تصویر از گالری: $e';
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _result = null;
      _errorMessage = null;
    });
  }

  Future<void> _confirmAndAnalyzeImage() async {
    if (_capturedImage == null || !_capturedImage!.isValid) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final geminiKey = widget.state.geminiApiKey.trim();

      if (geminiKey.isNotEmpty) {
        final visionData = await widget.state.scanFoodWithGeminiVision(
          _capturedImage!.bytes,
          mimeType: _capturedImage!.mimeType,
        );

        final foodName = visionData['food_name']?.toString() ?? 'غذای اسکن‌شده';
        final calories = (visionData['calories'] as num?)?.toInt() ?? 450;
        final protein = (visionData['protein_g'] as num?)?.toDouble() ?? 25.0;
        final carbs = (visionData['carbs_g'] as num?)?.toDouble() ?? 40.0;
        final fat = (visionData['fat_g'] as num?)?.toDouble() ?? 12.0;
        final portion = (visionData['portion_g'] as num?)?.toDouble() ?? 250.0;
        final desc = visionData['description']?.toString() ??
            'برآورد ارزش غذایی با بینایی هوش مصنوعی بر مبنای تصویر';

        final result = FoodAnalysisResult(
          foodName: foodName,
          foodNameFa: foodName,
          estimatedCalories: calories,
          proteinG: protein,
          carbsG: carbs,
          fatG: fat,
          estimatedWeightG: portion,
          healthTipFa: desc,
          isSimulated: false,
          isFromCamera: true,
          confidenceDescription: 'تحلیل چندوجهی بینایی ماشین (Google Gemini Vision)',
        );

        _applyAnalysisResult(result);
      } else {
        // Safe fallback simulation if Gemini API key is not configured in settings
        final result = FoodAnalysisResult(
          foodName: 'وعده پروتئینی اسکن‌شده',
          foodNameFa: 'وعده پروتئینی اسکن‌شده',
          estimatedCalories: 480,
          proteinG: 34.0,
          carbsG: 45.0,
          fatG: 14.0,
          estimatedWeightG: 300.0,
          healthTipFa:
              'کلید API جمینای در تنظیمات وارد نشده است. مقادیر به عنوان برآورد تخمینی بارگذاری شده‌اند؛ لطفاً پیش از ثبت بازبینی فرمایید.',
          isSimulated: true,
          isFromCamera: true,
          confidenceDescription: 'برآورد تخمینی اولیه (کلید جمینای تنظیم نشده)',
        );

        _applyAnalysisResult(result);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'خطا در تحلیل تصویر با هوش مصنوعی: $e';
      });
    }
  }

  void _applyAnalysisResult(FoodAnalysisResult result) {
    if (!mounted) return;
    setState(() {
      _result = result;
      _isAnalyzing = false;
      _foodNameController.text = result.foodNameFa;
      _caloriesController.text = result.estimatedCalories.toString();
      _proteinController.text = result.proteinG.toInt().toString();
      _carbsController.text = result.carbsG.toInt().toString();
      _fatController.text = result.fatG.toInt().toString();
      _portionController.text = result.estimatedWeightG.toInt().toString();
    });
  }

  void _analyzeFood(String text) async {
    if (text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'ابتدا نام یا ترکیبات غذا را وارد کنید.';
        _result = null;
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final res = await widget.state.aiService.analyzeFood(
        description: text.trim(),
        apiKey: widget.state.openRouterApiKey,
      );

      if (!mounted) return;
      _applyAnalysisResult(res);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage =
            'خطا در تحلیل هوشمند غذا. لطفاً اتصال اینترنت خود را بررسی کرده و مجدداً تلاش کنید.';
      });
    }
  }

  void _confirmAndSave() async {
    if (_result == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final name = _foodNameController.text.trim().isNotEmpty
        ? _foodNameController.text.trim()
        : _result!.foodNameFa;
    final calories = int.tryParse(_caloriesController.text.trim()) ??
        _result!.estimatedCalories;
    final protein = double.tryParse(_proteinController.text.trim()) ??
        _result!.proteinG;
    final carbs =
        double.tryParse(_carbsController.text.trim()) ?? _result!.carbsG;
    final fat = double.tryParse(_fatController.text.trim()) ?? _result!.fatG;
    final portion = double.tryParse(_portionController.text.trim()) ??
        _result!.estimatedWeightG;

    try {
      final entry = CalorieScanLog(
        id: IdGenerator.generate('scan'),
        foodName: name,
        mealType: _selectedMealType,
        calories: calories,
        proteinG: protein,
        carbsG: carbs,
        fatG: fat,
        portionG: portion,
        dateString: widget.state.selectedNutritionDateString,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        note: _result!.healthTipFa,
      );

      await widget.state.addFoodEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'وعده غذایی با موفقیت در دفترچه کالری ثبت شد.',
              style: TextStyle(fontFamily: 'Vazirmatn'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ثبت وعده غذایی: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraService.disposeController(_cameraController);
    _descController.dispose();
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _portionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اسکنر هوشمند غذا'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: AdaptiveContainer(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title for Screen
                Text(
                  'برآورد غذا',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.hXs,
                Text(
                  'اسکن تصویری با دوربین یا برآورد متنی ترکیبات بشقاب غذا',
                  style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
                AppSpacing.hSm,

                // Scanner Mode Selector
                _buildModeSelector(tokens, theme),
                AppSpacing.hMd,

                // Meal Type Selector
                Text(
                  'وعده غذایی:',
                  style: theme.textTheme.titleSmall,
                ),
                AppSpacing.hSm,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: _mealTypes.map((type) {
                    final isSelected = _selectedMealType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: tokens.lime,
                      backgroundColor: theme.colorScheme.surfaceContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? tokens.textOnLime
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedMealType = type;
                        });
                      },
                    );
                  }).toList(),
                ),
                AppSpacing.hBase,

                if (_activeTabIndex == 0)
                  _buildCameraWorkflow(tokens, theme)
                else
                  _buildManualTextWorkflow(tokens, theme),

                // Analyzing Loader
                if (_isAnalyzing) ...[
                  AppSpacing.hLg,
                  CabbageMascotLoader(
                    text: _capturedImage != null
                        ? 'در حال تحلیل تصویر با هوش مصنوعی و تفکیک ماکروها...'
                        : 'کلم ورزشی در حال هضم متن و محاسبه ماکروها...',
                    subtext: 'محاسبه فوری کالری، پروتئین، کربوهیدرات و چربی...',
                  ),
                ],

                // Error State with Retry
                if (_errorMessage != null && !_isAnalyzing) ...[
                  AppSpacing.hLg,
                  EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'خطا در تحلیل هوشمند غذا',
                    subtitle: _errorMessage!,
                    isError: true,
                    actionLabel: 'تلاش مجدد',
                    onAction: () {
                      if (_capturedImage != null) {
                        _confirmAndAnalyzeImage();
                      } else {
                        _analyzeFood(_descController.text);
                      }
                    },
                  ),
                ],

                // Result Review Card
                if (_result != null && !_isAnalyzing) ...[
                  AppSpacing.hLg,
                  _buildResultReviewCard(theme, tokens),
                ],
                AppSpacing.hXl,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(AppThemeExtension tokens, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.cardElevated,
        borderRadius: AppRadii.roundedMd,
        border: Border.all(color: tokens.borderColor),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeTabIndex = 0;
                  _errorMessage = null;
                });
              },
              borderRadius: AppRadii.roundedSm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _activeTabIndex == 0
                      ? tokens.lime
                      : Colors.transparent,
                  borderRadius: AppRadii.roundedSm,
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: _activeTabIndex == 0
                            ? tokens.textOnLime
                            : tokens.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'دوربین و تصویر',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _activeTabIndex == 0
                              ? tokens.textOnLime
                              : tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeTabIndex = 1;
                  _errorMessage = null;
                });
              },
              borderRadius: AppRadii.roundedSm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _activeTabIndex == 1
                      ? tokens.lime
                      : Colors.transparent,
                  borderRadius: AppRadii.roundedSm,
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 20,
                        color: _activeTabIndex == 1
                            ? tokens.textOnLime
                            : tokens.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'برآورد متنی دستی',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _activeTabIndex == 1
                              ? tokens.textOnLime
                              : tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraWorkflow(AppThemeExtension tokens, ThemeData theme) {
    if (_capturedImage != null) {
      // Step 4: Preview captured image & Step 5/7: Retake or Confirm
      return Container(
        decoration: BoxDecoration(
          color: tokens.cardElevated,
          borderRadius: AppRadii.roundedLg,
          border: Border.all(color: tokens.lime.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline, color: tokens.lime, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'تصویر آماده تحلیل است',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tokens.lime,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(_capturedImage!.sizeBytes / 1024).toStringAsFixed(0)} KB',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
            AppSpacing.hMd,
            ClipRRect(
              borderRadius: AppRadii.roundedMd,
              child: Container(
                height: 220,
                width: double.infinity,
                color: Colors.black26,
                child: Image.memory(
                  _capturedImage!.bytes,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
            AppSpacing.hMd,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : _retakePhoto,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('عکاسی مجدد'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _confirmAndAnalyzeImage,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('تأیید و تحلیل تصویر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.lime,
                      foregroundColor: tokens.textOnLime,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_isCameraInitializing) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.cardElevated,
          borderRadius: AppRadii.roundedLg,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2.5),
            SizedBox(height: AppSpacing.md),
            Text('در حال آماده‌سازی دوربین...', style: TextStyle(fontFamily: 'Vazirmatn')),
          ],
        ),
      );
    }

    if (_permissionStatus == CameraPermissionStatus.denied) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: tokens.cardElevated,
          borderRadius: AppRadii.roundedLg,
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.no_photography_outlined, size: 48, color: Colors.orange),
            AppSpacing.hSm,
            Text(
              'دسترسی دوربین رد شده است',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.hXs,
            Text(
              'برای اسکن مستقیم بشقاب غذا، دسترسی دوربین الزامی است. همچنین می‌توانید عکس را از گالری انتخاب فرمایید.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            AppSpacing.hMd,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('انتخاب از گالری'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _initCamera,
                    icon: const Icon(Icons.settings),
                    label: const Text('درخواست دسترسی'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_permissionStatus == CameraPermissionStatus.unavailable ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: tokens.cardElevated,
          borderRadius: AppRadii.roundedLg,
          border: Border.all(color: tokens.borderColor),
        ),
        child: Column(
          children: [
            Icon(Icons.camera_alt_outlined, size: 48, color: tokens.cyan),
            AppSpacing.hSm,
            Text(
              'دوربین زنده در این محیط در دسترس نیست',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.hXs,
            Text(
              'می‌توانید تصویر غذا را از گالری انتخاب کنید یا عکس نمونه را بررسی نمایید.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            AppSpacing.hMd,
            ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('انتخاب عکس غذا از گالری'),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.cyan,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    // Step 1: Live Viewfinder Preview & Step 3: Capture Photo
    return ClipRRect(
      borderRadius: AppRadii.roundedLg,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: AppRadii.roundedLg,
          border: Border.all(color: tokens.borderColor),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CameraPreview(_cameraController!),

            // Reticle Target Frame Overlay
            Container(
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: tokens.lime.withOpacity(0.8), width: 2),
                borderRadius: AppRadii.roundedLg,
              ),
            ),

            Positioned(
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: AppRadii.smRadius,
                ),
                child: const Text(
                  'ظرف غذا را در کادر تنظیم کنید',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

            // Shutter & Gallery Controls
            Positioned(
              bottom: 14,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
                    tooltip: 'انتخاب از گالری',
                    onPressed: _pickFromGallery,
                  ),
                  InkWell(
                    onTap: _capturePhoto,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: tokens.lime,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tokens.lime.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt, color: Colors.black, size: 28),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                    tooltip: 'تغییر دوربین',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualTextWorkflow(AppThemeExtension tokens, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _descController,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'نام و ترکیبات غذا',
            hintText: 'مثلاً: قورمه سبزی با کته، فیله مرغ با برنج...',
            prefixIcon: ExcludeSemantics(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: GymBroNutritionIllustration(
                  type: GymBroNutritionType.foodScanner,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        AppSpacing.hMd,

        Text(
          'غذاهای متداول ورزشی و سنتی (انتخاب سریع):',
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        AppSpacing.hXs,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _quickMeals.map((meal) {
            return InkWell(
              onTap: () {
                _descController.text = meal;
                _analyzeFood(meal);
              },
              borderRadius: AppRadii.roundedSm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.roundedSm,
                  border: Border.all(color: tokens.borderColor),
                ),
                child: Text(
                  meal,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurface),
                ),
              ),
            );
          }).toList(),
        ),
        AppSpacing.hLg,

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing
                ? null
                : () => _analyzeFood(_descController.text),
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              _isAnalyzing
                  ? 'هوش مصنوعی در حال تحلیل...'
                  : 'تحلیل متن غذا با هوش مصنوعی',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultReviewCard(ThemeData theme, AppThemeExtension tokens) {
    return Container(
      padding: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: tokens.lime.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نتیجه تحلیل هوشمند غذا',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.lime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_result!.confidenceDescription != null)
                      Text(
                        _result!.confidenceDescription!,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: tokens.textMuted),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: tokens.textMuted),
                onPressed: () => setState(() {
                  _result = null;
                  _capturedImage = null;
                }),
                tooltip: 'انصراف',
              ),
            ],
          ),
          AppSpacing.hBase,

          // Requirement 4: Mandatory Uncertainty Notice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: AppRadii.smRadius,
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'توجه: مقادیر ارائه‌شده برآورد هوش مصنوعی هستند و نه اندازه‌گیری آزمایشگاهی. لطفاً پیش از ثبت نهایی، مقادیر را بررسی و در صورت نیاز اصلاح فرمایید.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.amber.shade200,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hBase,

          // Editable Food Name
          TextFormField(
            controller: _foodNameController,
            decoration: const InputDecoration(
              labelText: 'نام غذا (قابل ویرایش)',
              prefixIcon: Icon(Icons.restaurant_menu),
            ),
          ),
          AppSpacing.hBase,

          // Editable Nutrients Row
          Row(
            children: [
              _buildEditableNutrientBox('کالری', _caloriesController, 'کیلوکالری',
                  tokens.lime, tokens, theme),
              AppSpacing.wSm,
              _buildEditableNutrientBox('پروتئین', _proteinController, 'گرم',
                  tokens.cyan, tokens, theme),
              AppSpacing.wSm,
              _buildEditableNutrientBox('کربوهیدرات', _carbsController, 'گرم',
                  tokens.gold, tokens, theme),
              AppSpacing.wSm,
              _buildEditableNutrientBox('چربی', _fatController, 'گرم',
                  tokens.orange, tokens, theme),
            ],
          ),
          AppSpacing.hMd,

          // Health Tip / Dietary Note
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: tokens.cardElevated,
              borderRadius: AppRadii.roundedMd,
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: tokens.gold, size: 18),
                AppSpacing.wSm,
                Expanded(
                  child: Text(
                    _result!.healthTipFa,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hBase,

          // Action Buttons: Discard / Retake vs Save
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _retakePhoto,
                  child: const Text('انصراف / لغو'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _confirmAndSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _isSaving
                        ? 'در حال ثبت...'
                        : 'تایید و ثبت در برنامه تغذیه',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.lime,
                    foregroundColor: tokens.textOnLime,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableNutrientBox(
    String title,
    TextEditingController controller,
    String unit,
    Color color,
    AppThemeExtension tokens,
    ThemeData theme,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: tokens.cardElevated,
          borderRadius: AppRadii.roundedMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                border: InputBorder.none,
              ),
            ),
            Text(
              unit,
              style: TextStyle(fontSize: 10, color: tokens.textMuted),
            ),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
