import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../models/body_analytics_models.dart';

/// Clinical BMI Indicator Card with continuous 5-segment spectrum bar and educational context.
class BmiIndicatorCard extends StatelessWidget {
  final double bmi;
  final double heightCm;
  final double weightKg;

  const BmiIndicatorCard({
    super.key,
    required this.bmi,
    required this.heightCm,
    required this.weightKg,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final category = BmiCategory.fromBmi(bmi);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with BMI number and Category Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: category.color.withOpacity(0.18),
                        border: Border.all(color: category.color.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Icon(Icons.speed, color: category.color, size: 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'شاخص توده بدنی (BMI)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'بر پایه قد ${PersianUtils.toPersianDigits(heightCm.toInt())} سانتی‌متر و وزن ${PersianUtils.toPersianDigits(weightKg)} کیلوگرم',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PersianUtils.toPersianDigits(bmi.toStringAsFixed(1)),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: category.color,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.15),
                      borderRadius: AppRadii.xsRadius,
                      border: Border.all(color: category.color.withOpacity(0.4)),
                    ),
                    child: Text(
                      category.displayNameFa.split(' ')[0], // First word (کمبود, طبیعی, اضافه, چاقی)
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: category.color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),

          // 5-Segment Visual Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              // Normalize BMI range from 15.0 to 40.0 for indicator needle position
              final normalizedPos = ((bmi - 15.0) / 25.0).clamp(0.02, 0.98);
              final needleX = normalizedPos * totalWidth;

              return Column(
                children: [
                  // Indicator Needle Arrow
                  SizedBox(
                    height: 12,
                    child: Stack(
                      children: [
                        Positioned(
                          right: needleX - 6, // In RTL, right is start
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: category.color,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Colored Segmented Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          // Underweight (< 18.5) -> (18.5-15)/25 = 14%
                          Expanded(
                            flex: 14,
                            child: Container(color: const Color(0xFF38BDF8)),
                          ),
                          const SizedBox(width: 2),
                          // Normal (18.5 - 24.9) -> (25-18.5)/25 = 26%
                          Expanded(
                            flex: 26,
                            child: Container(color: const Color(0xFFCCFF00)),
                          ),
                          const SizedBox(width: 2),
                          // Overweight (25.0 - 29.9) -> (30-25)/25 = 20%
                          Expanded(
                            flex: 20,
                            child: Container(color: const Color(0xFFFBBF24)),
                          ),
                          const SizedBox(width: 2),
                          // Obese Class 1 (30.0 - 34.9) -> 20%
                          Expanded(
                            flex: 20,
                            child: Container(color: const Color(0xFFF97316)),
                          ),
                          const SizedBox(width: 2),
                          // Obese Class 2+ (>= 35.0) -> 20%
                          Expanded(
                            flex: 20,
                            child: Container(color: const Color(0xFFEF4444)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Scale Range Labels
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('۱۵', style: TextStyle(fontSize: 9.5, color: tokens.textMuted)),
                        const SizedBox(width: 16),
                        Text('۱۸.۵ (طبیعی)', style: TextStyle(fontSize: 9.5, color: tokens.lime)),
                        const SizedBox(width: 16),
                        Text('۲۵ (اضافه)', style: TextStyle(fontSize: 9.5, color: tokens.gold)),
                        const SizedBox(width: 16),
                        Text('۳۰ (چاقی)', style: TextStyle(fontSize: 9.5, color: tokens.orange)),
                        const SizedBox(width: 16),
                        Text('+۳۵', style: TextStyle(fontSize: 9.5, color: tokens.textMuted)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Clinical Note Alert Box
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: tokens.cardElevated.withOpacity(0.7),
              borderRadius: AppRadii.smRadius,
              border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: tokens.cyan),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '${category.clinicalNoteFa}\nتوجه علمی: BMI یک شاخص غربالگری آماری است و درصد دقیق چربی یا بافت خالص عضلانی را تفکیک نمی‌کند.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: tokens.textMuted,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
