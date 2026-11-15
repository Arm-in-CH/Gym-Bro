import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';

/// 1RM (One-Rep Max) Calculator using Brzycki Formula
/// Inspired by the utility tool in gymbro-next-vercel, aligned with MD3.
class OneRmCalculatorDialog extends StatefulWidget {
  const OneRmCalculatorDialog({super.key});

  @override
  State<OneRmCalculatorDialog> createState() => _OneRmCalculatorDialogState();
}

class _OneRmCalculatorDialogState extends State<OneRmCalculatorDialog> {
  final _weightController = TextEditingController(text: '80');
  final _repsController = TextEditingController(text: '8');
  int _calculated1Rm = 100;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _calculate() {
    final w = PersianUtils.tryParseDouble(_weightController.text) ?? 80.0;
    final r = PersianUtils.tryParseDouble(_repsController.text) ?? 8.0;
    if (r <= 0 || r >= 37) return;

    // Brzycki Formula: 1RM = Weight / (1.0278 - (0.0278 * Reps))
    final denominator = 1.0278 - (0.0278 * r);
    if (denominator > 0) {
      setState(() {
        _calculated1Rm = (w / denominator).round();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.dialogRadius),
      child: SingleChildScrollView(
        padding: AppSpacing.dialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: AppSpacing.paddingSm,
                        decoration: BoxDecoration(
                          color: tokens.lime.withOpacity(0.18),
                          borderRadius: AppRadii.roundedMd,
                        ),
                        child: ExcludeSemantics(
                          child: Icon(Icons.calculate,
                              color: tokens.lime, size: AppSpacing.lg),
                        ),
                      ),
                      AppSpacing.wMd,
                      Expanded(
                        child: Text(
                          'محاسبه‌گر یک تکرار بیشینه (1RM)',
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: tokens.textMuted),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'بستن',
                ),
              ],
            ),
            AppSpacing.hBase,

            // Inputs Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _calculate(),
                    decoration: const InputDecoration(
                      labelText: 'وزنه (kg)',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    ),
                  ),
                ),
                AppSpacing.wMd,
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _calculate(),
                    decoration: const InputDecoration(
                      labelText: 'تعداد تکرار',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.hLg,

            // Result Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
              decoration: BoxDecoration(
                color: tokens.cardElevated,
                borderRadius: AppRadii.roundedBase,
                border: Border.all(color: tokens.lime.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    'رکورد تخمینی یک تکرار شما (1RM):',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  AppSpacing.hXs,
                  Text(
                    '${PersianUtils.toPersianDigits(_calculated1Rm)} کیلوگرم',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: tokens.lime,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hBase,

            // Percentage Breakdown Table
            Text(
              'جدول درصد شدت وزنه برای تمرین:',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: tokens.textMuted,
              ),
            ),
            AppSpacing.hSm,
            Row(
              children: [
                _buildPercentPill(
                    '95%', (_calculated1Rm * 0.95).round(), tokens),
                AppSpacing.wXs,
                _buildPercentPill(
                    '85%', (_calculated1Rm * 0.85).round(), tokens),
                AppSpacing.wXs,
                _buildPercentPill(
                    '75%', (_calculated1Rm * 0.75).round(), tokens),
                AppSpacing.wXs,
                _buildPercentPill(
                    '65%', (_calculated1Rm * 0.65).round(), tokens),
              ],
            ),
            AppSpacing.hLg,

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('متوجه شدم'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentPill(String percent, int kg, AppThemeExtension tokens) {
    return Expanded(
      child: Semantics(
        label: '$percent: ${PersianUtils.toPersianDigits(kg)} کیلوگرم',
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: tokens.cardElevated,
            borderRadius: AppRadii.roundedSm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  percent,
                  style: TextStyle(fontSize: 11, color: tokens.textMuted),
                ),
              ),
              AppSpacing.hXxs,
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${PersianUtils.toPersianDigits(kg)} kg',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: tokens.cyan,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
