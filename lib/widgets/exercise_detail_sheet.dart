import 'package:flutter/material.dart';
import '../models/exercise.dart';
import 'common/gymbro_design_system.dart';
import 'one_rm_calculator_dialog.dart';

class ExerciseDetailSheet extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailSheet({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final secondaryMuscles = exercise.resolvedSecondaryMusclesFa;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.90,
      ),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.sheetRadius,
        border: Border.all(color: tokens.borderColor.withOpacity(0.6), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.borderColor.withOpacity(0.8),
                borderRadius: AppRadii.pillRadius,
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.xs,
                AppSpacing.base,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header: Exercise Name, English Subtitle & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.nameFa,
                              style: AppTypography.pageTitle(context).copyWith(
                                color: tokens.lime,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              exercise.nameEn,
                              style: AppTypography.caption(context).copyWith(
                                color: tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: tokens.cardElevated,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,
                              size: 18, color: tokens.textMuted),
                        ),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'بستن',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Anatomical Muscle Activation Hero Card (Reference Image 1, 2, 3)
                  GymBroCard(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    borderColor: tokens.lime.withOpacity(0.35),
                    gradient: LinearGradient(
                      colors: [
                        theme.brightness == Brightness.dark
                            ? const Color(0xFF141A24)
                            : tokens.lime.withOpacity(0.1),
                        tokens.cardBackground,
                      ],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Left: High-detail Vector Muscle Anatomy
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: tokens.cardElevated,
                                borderRadius: AppRadii.roundedLg,
                                border: Border.all(
                                    color: tokens.lime.withOpacity(0.4),
                                    width: 1.2),
                                boxShadow: AppShadows.card,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  GymBroMuscleIllustration(
                                    muscle: GymBroMuscleGroupX.fromString(
                                        exercise.muscleGroup),
                                    activation: GymBroMuscleActivation.primary,
                                    size: 64,
                                    isAnimated: false,
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.85),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: tokens.cyan.withOpacity(0.6),
                                            width: 1),
                                      ),
                                      child: GymBroEquipmentIllustration(
                                        type: GymBroEquipmentTypeX.fromString(
                                            exercise.equipment),
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Right: Anatomical Muscle Targets List
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Primary Target
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: tokens.lime,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'عضله هدف اصلی (Primary):',
                                              style: AppTypography.caption(context)
                                                  .copyWith(
                                                color: tokens.textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              exercise.primaryMuscleFa,
                                              style: AppTypography.bodySmall(context)
                                                  .copyWith(
                                                color: tokens.lime,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Secondary Target
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: tokens.cyan,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'عضلات درگیر کمکی (Assisting):',
                                              style: AppTypography.caption(context)
                                                  .copyWith(
                                                color: tokens.textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              secondaryMuscles.join(' • '),
                                              style: AppTypography.caption(context)
                                                  .copyWith(
                                                color: theme
                                                    .colorScheme.onSurface,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Tags row: Equipment, Difficulty, Bodyweight status
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _DetailPill(
                              label: 'وسیله: ${exercise.equipmentFa}',
                              color: tokens.cyan,
                            ),
                            _DetailPill(
                              label: 'سطح: ${exercise.difficultyFa}',
                              color: tokens.gold,
                            ),
                            if (exercise.isBodyweight)
                              _DetailPill(
                                label: 'وزن بدن (بدون وسیله)',
                                color: tokens.lime,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Recommended Prescription Stat Cards (3 Cards)
                  Row(
                    children: [
                      Expanded(
                        child: _StatPrescriptionCard(
                          title: 'ست‌های هدف',
                          value: '۳ تا ۴ ست',
                          icon: Icons.fitness_center_rounded,
                          accentColor: tokens.lime,
                          tokens: tokens,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatPrescriptionCard(
                          title: 'دامنه تکرار',
                          value: '۸ - ۱۲ تکرار',
                          icon: Icons.repeat_rounded,
                          accentColor: tokens.cyan,
                          tokens: tokens,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatPrescriptionCard(
                          title: 'استراحت ست',
                          value: '۶۰ - ۹۰ ثانیه',
                          icon: Icons.timer_outlined,
                          accentColor: tokens.gold,
                          tokens: tokens,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Biomechanics & Form Cues Section
                  const GymBroSectionHeader(
                    title: 'راهنمای بیومکانیک و اجرای صحیح',
                    subtitle: 'تکنیک استاندارد جهت بیشترین هایپرتروفی و ایمنی مفصل',
                  ),
                  const SizedBox(height: 10),

                  GymBroCard(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    borderColor: tokens.borderColor.withOpacity(0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InstructionStepRow(
                          stepNumber: '۱',
                          stepTitle: 'آماده‌سازی و استقرار اولیه',
                          stepDesc:
                              'بدن را در وضعیت پایدار قرار دهید. مفاصل در راستای طبیعی و بدون قوس غیرعادی ستون فقرات باشند.',
                          tokens: tokens,
                        ),
                        const Divider(height: 20),
                        _InstructionStepRow(
                          stepNumber: '۲',
                          stepTitle: 'فاز مثبت و انقباض اوج (Concentric)',
                          stepDesc:
                              'وزنه را با تمرکز مستقیم روی ${exercise.primaryMuscleFa} حرکت دهید. در اوج دامنه، ۱ ثانیه مکث و انقباض کامل اعمال کنید.',
                          tokens: tokens,
                        ),
                        const Divider(height: 20),
                        _InstructionStepRow(
                          stepNumber: '۳',
                          stepTitle: 'فاز منفی کنترل‌شده (Eccentric)',
                          stepDesc:
                              'وزنه را در مدت ۲ تا ۳ ثانیه به آرامی و با حفظ کشش پیوسته به نقطه شروع بازگردانید. از رها کردن وزنه پرهیز شود.',
                          tokens: tokens,
                        ),
                        const Divider(height: 20),
                        _InstructionStepRow(
                          stepNumber: '۴',
                          stepTitle: 'نکات تنفس و نکات مربی',
                          stepDesc: exercise.instructionsFa,
                          tokens: tokens,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 5. Action Buttons (1RM Calculator & Close)
                  Row(
                    children: [
                      Expanded(
                        child: GymBroOutlineButton(
                          text: 'محاسبه‌گر 1RM رکورد',
                          icon: const Icon(Icons.calculate_outlined, size: 18),
                          textColor: tokens.cyan,
                          borderColor: tokens.cyan.withOpacity(0.5),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const OneRmCalculatorDialog(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GymBroPrimaryButton(
                          text: 'متوجه شدم (تایید)',
                          prefixIcon: const Icon(Icons.check_rounded, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final String label;
  final Color color;

  const _DetailPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: AppRadii.roundedXs,
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.caption(context).copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _StatPrescriptionCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final AppThemeExtension tokens;

  const _StatPrescriptionCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.cardElevated.withOpacity(0.7),
        borderRadius: AppRadii.roundedMd,
        border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: AppTypography.caption(context).copyWith(
                color: tokens.textMuted,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.bodySmall(context).copyWith(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionStepRow extends StatelessWidget {
  final String stepNumber;
  final String stepTitle;
  final String stepDesc;
  final AppThemeExtension tokens;
  final bool isLast;

  const _InstructionStepRow({
    required this.stepNumber,
    required this.stepTitle,
    required this.stepDesc,
    required this.tokens,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tokens.lime.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: tokens.lime.withOpacity(0.4)),
          ),
          child: Text(
            stepNumber,
            style: TextStyle(
              color: tokens.lime,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stepTitle,
                style: AppTypography.bodySmall(context).copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                stepDesc,
                style: AppTypography.caption(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
