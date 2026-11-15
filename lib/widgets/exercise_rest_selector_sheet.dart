import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';

class ExerciseRestSelectorSheet extends StatefulWidget {
  final String exerciseName;
  final int currentRestSeconds;

  const ExerciseRestSelectorSheet({
    super.key,
    required this.exerciseName,
    required this.currentRestSeconds,
  });

  static const List<int> presetDurations = [30, 45, 60, 90, 120, 180];

  static Future<int?> show(
    BuildContext context, {
    required String exerciseName,
    required int currentRestSeconds,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExerciseRestSelectorSheet(
        exerciseName: exerciseName,
        currentRestSeconds: currentRestSeconds,
      ),
    );
  }

  @override
  State<ExerciseRestSelectorSheet> createState() =>
      _ExerciseRestSelectorSheetState();
}

class _ExerciseRestSelectorSheetState extends State<ExerciseRestSelectorSheet> {
  late int _selectedSeconds;
  bool _isCustomMode = false;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSeconds = widget.currentRestSeconds;
    if (!ExerciseRestSelectorSheet.presetDurations.contains(_selectedSeconds)) {
      _isCustomMode = true;
      _customController.text = _selectedSeconds.toString();
    } else {
      _customController.text = '75';
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _applySelection(int seconds) {
    Navigator.pop(context, seconds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: tokens.borderColor),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.lime.withOpacity(0.18),
                  ),
                  child:
                      Icon(Icons.timer_outlined, color: tokens.lime, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'زمان استراحت حرکت',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.exerciseName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'بستن',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            Text(
              'مدت زمان استراحت بین ست‌های این حرکت را تعیین کنید:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Presets Grid
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ...ExerciseRestSelectorSheet.presetDurations.map((seconds) {
                  final isSelected =
                      !_isCustomMode && _selectedSeconds == seconds;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label:
                        'استراحت ${PersianUtils.toPersianDigits(seconds)} ثانیه',
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isCustomMode = false;
                          _selectedSeconds = seconds;
                        });
                        _applySelection(seconds);
                      },
                      borderRadius: AppRadii.roundedMd,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 95,
                          minHeight: AppSpacing.minTouchTarget,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? tokens.lime : tokens.cardElevated,
                          borderRadius: AppRadii.roundedMd,
                          border: Border.all(
                            color:
                                isSelected ? tokens.lime : tokens.borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected) ...[
                              Icon(
                                Icons.check,
                                size: 16,
                                color: tokens.textOnLime,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            Text(
                              '${PersianUtils.toPersianDigits(seconds)} ثانیه',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? tokens.textOnLime
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Custom Duration Button
                Semantics(
                  button: true,
                  selected: _isCustomMode,
                  label: 'تنظیم زمان استراحت سفارشی',
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isCustomMode = true;
                      });
                    },
                    borderRadius: AppRadii.roundedMd,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 120,
                        minHeight: AppSpacing.minTouchTarget,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: _isCustomMode
                            ? tokens.cyan.withOpacity(0.18)
                            : tokens.cardElevated,
                        borderRadius: AppRadii.roundedMd,
                        border: Border.all(
                          color:
                              _isCustomMode ? tokens.cyan : tokens.borderColor,
                          width: _isCustomMode ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color:
                                _isCustomMode ? tokens.cyan : tokens.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'مدت سفارشی...',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isCustomMode
                                  ? tokens.cyan
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_isCustomMode) ...[
              const SizedBox(height: AppSpacing.base),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(color: tokens.cyan),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مدت زمان دلخواه به ثانیه (۵ تا ۶۰۰):',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _customController,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: 'مثال: ۷۵',
                              suffixText: 'ثانیه',
                              filled: true,
                              fillColor: theme.scaffoldBackgroundColor,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () {
                            final parsed = int.tryParse(_customController.text);
                            if (parsed != null &&
                                parsed >= 5 &&
                                parsed <= 600) {
                              _applySelection(parsed);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'لطفاً عددی بین ۵ تا ۶۰۰ ثانیه وارد نمایید.'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tokens.cyan,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('ثبت'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
