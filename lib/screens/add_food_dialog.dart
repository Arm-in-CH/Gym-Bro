import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/localization/persian_utils.dart';
import '../../models/calorie_scan_log.dart';
import '../../models/nutrition_models.dart';
import '../../state/app_state.dart';
import '../../core/storage/id_generator.dart';

/// دیالوگ افزودن و ویرایش دستی وعده غذایی به همراه انتخاب سریع از غذاهای پرتکرار
class AddFoodDialog extends StatefulWidget {
  final AppState state;
  final String initialMealType;
  final CalorieScanLog? existingMeal;
  final String? initialDateString;

  const AddFoodDialog({
    super.key,
    required this.state,
    this.initialMealType = 'ناهار',
    this.existingMeal,
    this.initialDateString,
  });

  static Future<bool?> show(
    BuildContext context, {
    required AppState state,
    String initialMealType = 'ناهار',
    CalorieScanLog? existingMeal,
    String? initialDateString,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddFoodDialog(
        state: state,
        initialMealType: initialMealType,
        existingMeal: existingMeal,
        initialDateString: initialDateString,
      ),
    );
  }

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedMealType;
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _portionController;
  late TextEditingController _noteController;

  bool _isQuickPickOpen = false;

  final List<String> _mealTypes = const [
    'صبحانه',
    'ناهار',
    'شام',
    'میان‌وعده',
  ];

  @override
  void initState() {
    super.initState();
    final meal = widget.existingMeal;
    _selectedMealType = meal?.mealType ?? widget.initialMealType;

    _nameController = TextEditingController(text: meal?.foodName ?? '');
    _caloriesController =
        TextEditingController(text: meal != null ? meal.calories.toString() : '');
    _proteinController =
        TextEditingController(text: meal != null ? meal.proteinG.toStringAsFixed(1) : '');
    _carbsController =
        TextEditingController(text: meal != null ? meal.carbsG.toStringAsFixed(1) : '');
    _fatController =
        TextEditingController(text: meal != null ? meal.fatG.toStringAsFixed(1) : '');
    _portionController =
        TextEditingController(text: meal != null ? meal.portionG.toStringAsFixed(0) : '100');
    _noteController = TextEditingController(text: meal?.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _portionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _applyTemplate(QuickFoodTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _caloriesController.text = template.calories.toString();
      _proteinController.text = template.proteinG.toStringAsFixed(1);
      _carbsController.text = template.carbsG.toStringAsFixed(1);
      _fatController.text = template.fatG.toStringAsFixed(1);
      _portionController.text = template.portionG.toStringAsFixed(0);
      _isQuickPickOpen = false;
    });
  }

  void _autoCalculateCalories() {
    final protein = PersianUtils.tryParseDouble(_proteinController.text) ?? 0.0;
    final carbs = PersianUtils.tryParseDouble(_carbsController.text) ?? 0.0;
    final fat = PersianUtils.tryParseDouble(_fatController.text) ?? 0.0;
    final calculated = (protein * 4.0 + carbs * 4.0 + fat * 9.0).round();
    if (calculated > 0) {
      setState(() {
        _caloriesController.text = calculated.toString();
      });
    }
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    int cals = PersianUtils.tryParseInt(_caloriesController.text) ?? 0;
    final protein = PersianUtils.tryParseDouble(_proteinController.text) ?? 0.0;
    final carbs = PersianUtils.tryParseDouble(_carbsController.text) ?? 0.0;
    final fat = PersianUtils.tryParseDouble(_fatController.text) ?? 0.0;
    final portion = PersianUtils.tryParseDouble(_portionController.text) ?? 100.0;
    final note = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null;

    if (cals == 0 && (protein > 0 || carbs > 0 || fat > 0)) {
      cals = (protein * 4.0 + carbs * 4.0 + fat * 9.0).round();
    }

    final dateStr = widget.initialDateString ?? widget.state.selectedNutritionDateString;

    if (widget.existingMeal != null) {
      final updated = widget.existingMeal!.copyWith(
        foodName: name,
        mealType: _selectedMealType,
        calories: cals,
        proteinG: protein,
        carbsG: carbs,
        fatG: fat,
        portionG: portion,
        note: note,
      );
      await widget.state.updateFoodEntry(updated);
    } else {
      final newMeal = CalorieScanLog(
        id: IdGenerator.generate('food'),
        foodName: name,
        mealType: _selectedMealType,
        calories: cals,
        proteinG: protein,
        carbsG: carbs,
        fatG: fat,
        portionG: portion,
        isAiScanned: false,
        dateString: dateStr,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        note: note,
      );
      await widget.state.addFoodEntry(newMeal);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final isEditing = widget.existingMeal != null;
    final favorites = widget.state.favoriteFoods;

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
              // Sheet Drag Handle
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
                        Icon(
                          isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                          color: tokens.lime,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            isEditing ? 'ویرایش وعده غذایی' : 'ثبت وعده غذایی جدید',
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
              const SizedBox(height: AppSpacing.sm),

              // Meal Category Selector Pills
              Text(
                'وعده غذایی:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tokens.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: _mealTypes.map((type) {
                  final isSelected = type == _selectedMealType;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => setState(() => _selectedMealType = type),
                        borderRadius: AppRadii.smRadius,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? tokens.lime : tokens.cardElevated,
                            borderRadius: AppRadii.smRadius,
                            border: Border.all(
                              color: isSelected ? tokens.lime : tokens.borderColor,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            type,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected ? tokens.textOnLime : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Quick Pick Drawer Toggle
              if (!isEditing && favorites.isNotEmpty) ...[
                InkWell(
                  onTap: () => setState(() => _isQuickPickOpen = !_isQuickPickOpen),
                  borderRadius: AppRadii.smRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: tokens.cardElevated,
                      borderRadius: AppRadii.smRadius,
                      border: Border.all(color: tokens.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.bolt_rounded, color: tokens.lime, size: 18),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  'انتخاب سریع از غذاهای پرتکرار ورزشی (${PersianUtils.toPersianDigits(favorites.length)})',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: tokens.lime,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isQuickPickOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: tokens.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isQuickPickOpen) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      color: tokens.cardElevated.withOpacity(0.5),
                      borderRadius: AppRadii.smRadius,
                      border: Border.all(color: tokens.borderColor),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: tokens.borderColor),
                      itemBuilder: (ctx, idx) {
                        final fav = favorites[idx];
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            fav.name,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${PersianUtils.formatCalories(fav.calories)} • پرو: ${PersianUtils.toPersianDigits(fav.proteinG.toInt())} گرم • کرب: ${PersianUtils.toPersianDigits(fav.carbsG.toInt())} گرم',
                            style: theme.textTheme.labelSmall?.copyWith(color: tokens.textMuted),
                          ),
                          trailing: Icon(Icons.chevron_left_rounded, size: 16, color: tokens.cyan),
                          onTap: () => _applyTemplate(fav),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
              ],

              // Food Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'نام غذا یا ماده مصرفی *',
                  hintText: 'مثلاً: سینه مرغ گریل با برنج کته',
                  prefixIcon: Icon(Icons.restaurant_menu_rounded, color: tokens.lime),
                  filled: true,
                  fillColor: tokens.cardElevated,
                  border: const OutlineInputBorder(borderRadius: AppRadii.smRadius),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'لطفاً نام غذا را وارد نمایید.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Calories and Serving Size Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'انرژی (کالری) *',
                        hintText: 'kcal',
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
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _portionController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'مقدار (گرم)',
                        hintText: '100',
                        filled: true,
                        fillColor: tokens.cardElevated,
                        border: const OutlineInputBorder(borderRadius: AppRadii.smRadius),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Macros Row: Protein, Carbs, Fat
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'پروتئین (g)',
                        hintText: '0',
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'کربوهیدرات (g)',
                        hintText: '0',
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'چربی (g)',
                        hintText: '0',
                        filled: true,
                        fillColor: tokens.cardElevated,
                        border: const OutlineInputBorder(borderRadius: AppRadii.smRadius),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _autoCalculateCalories,
                  icon: Icon(Icons.calculate_outlined, size: 16, color: tokens.lime),
                  label: Text(
                    'محاسبه هوشمند کالری از ماکروها (P×4 + C×4 + F×9)',
                    style: TextStyle(fontSize: 11, color: tokens.lime, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Optional Note
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'توضیحات اختیاری',
                  hintText: 'مثلاً: قبل از تمرین پا مصرف شد',
                  prefixIcon: Icon(Icons.notes_rounded, color: tokens.textMuted),
                  filled: true,
                  fillColor: tokens.cardElevated,
                  border: const OutlineInputBorder(borderRadius: AppRadii.smRadius),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Estimated Values Disclaimer
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: tokens.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'مقادیر تغذیه‌ای به صورت تخمین تقریبی برای اهداف ورزشی ثبت می‌شوند.',
                      style: theme.textTheme.labelSmall?.copyWith(color: tokens.textMuted, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.lime,
                        foregroundColor: tokens.textOnLime,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadii.smRadius),
                      ),
                      child: Text(
                        isEditing ? 'ذخیره تغییرات' : 'افزودن به دفترچه غذایی',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
