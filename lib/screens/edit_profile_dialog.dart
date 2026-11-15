import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../models/body_analytics_models.dart';
import '../state/app_state.dart';

/// Professional Profile Editing Dialog with form validation, metric units,
/// goal selectors, and proper save behavior.
class EditProfileDialog extends StatefulWidget {
  final AppState state;

  const EditProfileDialog({super.key, required this.state});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;

  late Gender _selectedGender;
  late FitnessGoal _selectedGoal;
  late String _selectedFitnessLevel;
  late ActivityLevel _selectedActivity;
  late int _selectedTrainingDays;

  bool _isSaving = false;

  final List<String> _fitnessLevelOptions = [
    'مبتدی (Beginner)',
    'متوسط (Intermediate)',
    'پیشرفته (Advanced)',
    'ورزشکار حرفه‌ای (Athlete)',
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.state.userProfile;

    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _ageController = TextEditingController(text: profile.age.toString());
    _heightController = TextEditingController(text: profile.heightCm.toInt().toString());
    _weightController = TextEditingController(text: profile.weightKg.toStringAsFixed(1));
    _targetWeightController = TextEditingController(text: profile.targetWeightKg.toStringAsFixed(1));

    _selectedGender = profile.gender;
    _selectedGoal = profile.parsedFitnessGoal;
    _selectedFitnessLevel = profile.fitnessLevel;
    _selectedActivity = profile.activityLevel;
    _selectedTrainingDays = profile.preferredTrainingDays;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final double weight = PersianUtils.tryParseDouble(_weightController.text) ?? widget.state.userProfile.weightKg;
      final double targetWeight = PersianUtils.tryParseDouble(_targetWeightController.text) ?? widget.state.userProfile.targetWeightKg;
      final double height = PersianUtils.tryParseDouble(_heightController.text) ?? widget.state.userProfile.heightCm;
      final int age = PersianUtils.tryParseInt(_ageController.text) ?? widget.state.userProfile.age;

      final updatedProfile = widget.state.userProfile.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        age: age,
        heightCm: height,
        weightKg: weight,
        targetWeightKg: targetWeight,
        gender: _selectedGender,
        fitnessGoal: _selectedGoal.displayNameFa,
        fitnessLevel: _selectedFitnessLevel,
        activityLevel: _selectedActivity,
        preferredTrainingDays: _selectedTrainingDays,
      );

      await widget.state.updateFullProfile(updatedProfile);

      // If weight was updated directly, log it in weight history if different
      if ((widget.state.latestWeightRecord?.weightKg ?? 0) != weight) {
        await widget.state.addWeightRecord(
          weightKg: weight,
          note: 'ویرایش مشخصات پرونده کاربری',
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('پروفایل کاربری و اهداف ورزشی با موفقیت ذخیره شد.'),
            backgroundColor: context.appTokens.lime,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: tokens.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.lgRadius,
        side: BorderSide(color: tokens.borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.manage_accounts, color: tokens.lime, size: 24),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'ویرایش مشخصات فیزیکی',
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
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1E273A)),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Fields
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'نام',
                              controller: _firstNameController,
                              tokens: tokens,
                              validator: (v) => v == null || v.trim().isEmpty ? 'نام الزامی است' : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _buildTextField(
                              label: 'نام خانوادگی',
                              controller: _lastNameController,
                              tokens: tokens,
                              validator: (v) => v == null || v.trim().isEmpty ? 'نام خانوادگی الزامی است' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Metrics: Age, Height, Weight, Target Weight
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'سن (سال)',
                              controller: _ageController,
                              tokens: tokens,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 10 || n > 110) return 'سن نامعتبر';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _buildTextField(
                              label: 'قد (سانتی‌متر)',
                              controller: _heightController,
                              tokens: tokens,
                              keyboardType: TextInputType.number,
                              suffix: 'cm',
                              validator: (v) {
                                final n = double.tryParse((v ?? '').replaceAll('٫', '.'));
                                if (n == null || n < 100 || n > 250) {
                                  return 'قد باید بین ۱۰۰ تا ۲۵۰ سانتی‌متر باشد.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'وزن فعلی (کیلوگرم)',
                              controller: _weightController,
                              tokens: tokens,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              suffix: 'kg',
                              validator: (v) {
                                final n = double.tryParse((v ?? '').replaceAll('٫', '.'));
                                if (n == null || n < 30 || n > 300) {
                                  return 'وزن باید بین ۳۰ تا ۳۰۰ کیلوگرم باشد.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _buildTextField(
                              label: 'وزن هدف (kg)',
                              controller: _targetWeightController,
                              tokens: tokens,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              suffix: 'kg',
                              validator: (v) {
                                final n = double.tryParse((v ?? '').replaceAll('٫', '.'));
                                if (n == null || n < 30 || n > 300) {
                                  return 'وزن هدف نامعتبر';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Gender Selector
                      Text('جنسیت (اختیاری):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tokens.textMuted)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: Gender.values.map((g) {
                          final isSelected = _selectedGender == g;
                          return ChoiceChip(
                            label: Text(g.displayNameFa),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedGender = g),
                            selectedColor: tokens.lime,
                            backgroundColor: tokens.cardElevated,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : tokens.textMuted,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11.5,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Main Fitness Goal
                      Text('هدف اصلی ورزشی:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tokens.textMuted)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: tokens.cardElevated,
                          borderRadius: AppRadii.smRadius,
                          border: Border.all(color: tokens.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<FitnessGoal>(
                            value: _selectedGoal,
                            isExpanded: true,
                            dropdownColor: tokens.cardBackground,
                            items: FitnessGoal.values.map((goal) {
                              return DropdownMenuItem(
                                value: goal,
                                child: Text(goal.displayNameFa, style: const TextStyle(fontSize: 12.5, color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGoal = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Fitness Experience Level
                      Text('سطح تجربه در بدنسازی:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tokens.textMuted)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: tokens.cardElevated,
                          borderRadius: AppRadii.smRadius,
                          border: Border.all(color: tokens.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _fitnessLevelOptions.contains(_selectedFitnessLevel)
                                ? _selectedFitnessLevel
                                : _fitnessLevelOptions[1],
                            isExpanded: true,
                            dropdownColor: tokens.cardBackground,
                            items: _fitnessLevelOptions.map((lvl) {
                              return DropdownMenuItem(
                                value: lvl,
                                child: Text(lvl, style: const TextStyle(fontSize: 12.5, color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedFitnessLevel = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Activity Level
                      Text('میزان فعالیت روزمره:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tokens.textMuted)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: tokens.cardElevated,
                          borderRadius: AppRadii.smRadius,
                          border: Border.all(color: tokens.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ActivityLevel>(
                            value: _selectedActivity,
                            isExpanded: true,
                            dropdownColor: tokens.cardBackground,
                            items: ActivityLevel.values.map((act) {
                              return DropdownMenuItem(
                                value: act,
                                child: Text(act.displayNameFa, style: const TextStyle(fontSize: 12, color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedActivity = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Preferred Training Days
                      Text(
                        'روزهای تمرین در هفته: ${PersianUtils.toPersianDigits(_selectedTrainingDays)} روز',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tokens.textMuted),
                      ),
                      Slider(
                        value: _selectedTrainingDays.toDouble(),
                        min: 2,
                        max: 6,
                        divisions: 4,
                        activeColor: tokens.lime,
                        inactiveColor: tokens.cardElevated,
                        label: '$_selectedTrainingDays روز',
                        onChanged: (v) => setState(() => _selectedTrainingDays = v.round()),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Contact Fields (Readonly / Informative)
                      _buildTextField(
                        label: 'ایمیل کاربری',
                        controller: _emailController,
                        tokens: tokens,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: tokens.borderColor),
                        foregroundColor: tokens.textMuted,
                      ),
                      child: const Text('انصراف'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.lime,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('ذخیره تغییرات'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required AppThemeExtension tokens,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.5, color: tokens.textMuted)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            suffixText: suffix,
            suffixStyle: TextStyle(color: tokens.lime, fontSize: 11, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: tokens.cardElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.lime, width: 1.5)),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
