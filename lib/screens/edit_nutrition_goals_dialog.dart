import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/localization/persian_utils.dart';
import '../../models/nutrition_models.dart';
import '../../state/app_state.dart';

/// دیالوگ شخصی‌سازی اهداف کالری، درشت‌مغذی‌ها و آب با پیشنهاد هوشمند Mifflin-St Jeor
class EditNutritionGoalsDialog extends StatefulWidget {
  final AppState state;

  const EditNutritionGoalsDialog({super.key, required this.state});

  static Future<bool?> show(BuildContext context, {required AppState state}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditNutritionGoalsDialog(state: state),
    );
  }

  @override
  State<EditNutritionGoalsDialog> createState() => _EditNutritionGoalsDialogState();
}

class _EditNutritionGoalsDialogState extends State<EditNutritionGoalsDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _waterController;

  @override
  void initState() {
    super.initState();
    final plan = widget.state.nutritionPlan;
    _caloriesController = TextEditingController(text: plan.dailyCalories.toString());
    _proteinController = TextEditingController(text: plan.targetProteinG.toString());
    _carbsController = TextEditingController(text: plan.targetCarbsG.toString());
    _fatController = TextEditingController(text: plan.targetFatG.toString());
    _waterController = TextEditingController(text: plan.targetWaterMl.toString());
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _calculateScientificGoals() {
    final profile = widget.state.userProfile;
    final recommended = NutritionCalculator.calculateRecommendedPlan(profile: profile);

    setState(() {
      _caloriesController.text = recommended['calories'].toString();
      _proteinController.text = recommended['protein'].toString();
      _carbsController.text = recommended['carbs'].toString();
      _fatController.text = recommended['fat'].toString();
      _waterController.text = recommended['water'].toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('اهداف بر اساس قد، وزن، فعالیت و فرمول Mifflin-St Jeor محاسبه شدند.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;

    final cals = PersianUtils.tryParseInt(_caloriesController.text) ?? 2250;
    final protein = PersianUtils.tryParseInt(_proteinController.text) ?? 160;
    final carbs = PersianUtils.tryParseInt(_carbsController.text) ?? 220;
    final fat = PersianUtils.tryParseInt(_fatController.text) ?? 55;
    final water = PersianUtils.tryParseInt(_waterController.text) ?? 3000;

    final updatedPlan = widget.state.nutritionPlan.copyWith(
      dailyCalories: cals,
      targetProteinG: protein,
      targetCarbsG: carbs,
      targetFatG: fat,
      targetWaterMl: water,
    );

    await widget.state.updateNutritionPlanGoals(updatedPlan);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: tokens.borderColor),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.cardElevated,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.tune_rounded, color: tokens.lime, size: 24),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'تنظیم اهداف تغذیه و هیدراتاسیون',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: tokens.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Smart calculation button
              InkWell(
                onTap: _calculateScientificGoals,
                borderRadius: AppRadii.baseRadius,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.lime.withOpacity(0.12),
                    borderRadius: AppRadii.baseRadius,
                    border: Border.all(color: tokens.lime.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: tokens.lime, size: 22),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'محاسبه هوشمند بر پایه مشخصات بدنی شما',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.lime,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'بر اساس قد ${PersianUtils.formatHeight(widget.state.userProfile.heightCm)}، وزن ${PersianUtils.formatWeight(widget.state.userProfile.weightKg)} و فرمول BMR/TDEE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.refresh_rounded, color: tokens.lime, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Calorie Goal Field
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'هدف کالری روزانه (کیلوکالری) *',
                  hintText: '2250',
                  prefixIcon: Icon(Icons.local_fire_department, color: tokens.lime),
                  filled: true,
                  fillColor: tokens.cardElevated,
                  border: const OutlineInputBorder(borderRadius: AppRadii.smRadius),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'الزامی';
                  if (int.tryParse(val.trim()) == null) return 'عدد نامعتبر';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Macros Row: Protein, Carbs, Fat
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'پروتئین (گرم)',
                        prefixIcon: Icon(Icons.fitness_center, size: 16, color: tokens.lime),
                        filled: true,
                        fillColor: tokens.cardElevated,
                        border: const OutlineInputBorder(borderRadius: AppRadii.smRadius),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'کربوهیدرات (گرم)',
                        prefixIcon: Icon(Icons.grain, size: 16, color: tokens.cyan),
                        filled: true,
                        fillColor: tokens.cardElevated,
                        border: const OutlineInputBorder(borderRadius: AppRadii.smRadius),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'چربی (گرم)',
                        prefixIcon: const Icon(Icons.water_drop, size: 16, color: Color(0xFFF43F5E)),
                        filled: true,
                        fillColor: tokens.cardElevated,
                        border: const OutlineInputBorder(borderRadius: AppRadii.smRadius),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Water Target Field
              TextFormField(
                controller: _waterController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'هدف مصرف آب روزانه (میلی‌لیتر) *',
                  hintText: '3000',
                  prefixIcon: Icon(Icons.water_drop_rounded, color: tokens.cyan),
                  filled: true,
                  fillColor: tokens.cardElevated,
                  border: const OutlineInputBorder(borderRadius: AppRadii.smRadius),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Clinical Disclaimer
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.smRadius,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: tokens.textMuted),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'سلب مسئولیت بالینی: این اهداف صرفاً راهنمای ورزشی و عمومی هستند و نباید به عنوان رژیم درمانی یا تجویز پزشکی تلقی شوند.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: tokens.textMuted,
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveGoals,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.lime,
                        foregroundColor: tokens.textOnLime,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadii.smRadius),
                      ),
                      child: const Text('ذخیره و اعمال اهداف', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('انصراف'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
