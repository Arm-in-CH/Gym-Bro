import 'package:flutter/material.dart';
import '../core/localization/persian_utils.dart';
import '../core/storage/id_generator.dart';
import '../models/workout_plan.dart';
import '../models/exercise.dart';
import '../state/app_state.dart';
import 'common/gymbro_design_system.dart';

class WorkoutPlanEditorDialog extends StatefulWidget {
  final AppState state;
  final WorkoutPlan? initialPlan;

  const WorkoutPlanEditorDialog({
    super.key,
    required this.state,
    this.initialPlan,
  });

  @override
  State<WorkoutPlanEditorDialog> createState() =>
      _WorkoutPlanEditorDialogState();
}

class _WorkoutPlanEditorDialogState extends State<WorkoutPlanEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _splitType;
  late int _daysPerWeek;
  late String _difficulty;
  late List<WorkoutPlanExercise> _exercises;
  bool _isSaving = false;
  String? _errorMessage;

  final List<String> _splitOptions = [
    'Push Pull Legs',
    'Upper / Lower',
    'Full Body',
    'Bro Split',
    'تخصصی شخصی',
  ];

  final List<String> _difficultyOptions = [
    'مبتدی',
    'متوسط',
    'پیشرفته',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initialPlan;
    _titleController = TextEditingController(text: p?.titleFa ?? '');
    _descController = TextEditingController(text: p?.descriptionFa ?? '');
    _splitType = p?.splitType ?? 'Push Pull Legs';
    _daysPerWeek = p?.daysPerWeek ?? 3;
    _difficulty = p?.difficulty ?? 'متوسط';
    _exercises = p != null
        ? List<WorkoutPlanExercise>.from(p.exercises)
        : <WorkoutPlanExercise>[];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addExerciseDialog() async {
    final available = widget.state.exercises;
    if (available.isEmpty) return;

    Exercise selectedEx = available.first;
    int dayOfWeek = 1;
    int sets = 3;
    int reps = 10;
    double weight = 20.0;
    int rest = 60;

    final added = await showDialog<WorkoutPlanExercise>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: context.appTokens.cardBackground,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedLg),
              title: Text(
                'افزودن حرکت به برنامه',
                style: AppTypography.sectionTitle(context).copyWith(
                  color: context.appTokens.lime,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Exercise>(
                      value: selectedEx,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'انتخاب حرکت از بانک'),
                      items: available.map((ex) {
                        return DropdownMenuItem<Exercise>(
                          value: ex,
                          child: Text('${ex.nameFa} (${ex.muscleGroupFa})',
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedEx = val);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<int>(
                      value: dayOfWeek,
                      decoration:
                          const InputDecoration(labelText: 'روز تمرینی'),
                      items: List.generate(_daysPerWeek, (i) => i + 1).map((d) {
                        return DropdownMenuItem<int>(
                          value: d,
                          child: Text('برنامه روز $d'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => dayOfWeek = val);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: sets.toString(),
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'تعداد ست'),
                            onChanged: (v) => sets = int.tryParse(v) ?? sets,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextFormField(
                            initialValue: reps.toString(),
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'تکرار'),
                            onChanged: (v) => reps = int.tryParse(v) ?? reps,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: weight.toString(),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration:
                                const InputDecoration(labelText: 'وزنه هدف (kg)'),
                            onChanged: (v) =>
                                weight = double.tryParse(v) ?? weight,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextFormField(
                            initialValue: rest.toString(),
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'استراحت (s)'),
                            onChanged: (v) => rest = int.tryParse(v) ?? rest,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('انصراف'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appTokens.lime,
                    foregroundColor: context.appTokens.textOnLime,
                  ),
                  onPressed: () {
                    final nextOrder = _exercises
                            .where((e) => e.dayOfWeek == dayOfWeek)
                            .length +
                        1;
                    final pe = WorkoutPlanExercise(
                      id: IdGenerator.planExercise(),
                      planId: widget.initialPlan?.id ?? 'temp_plan',
                      exerciseId: selectedEx.id,
                      dayOfWeek: dayOfWeek,
                      dayNameFa: 'برنامه روز $dayOfWeek',
                      orderInDay: nextOrder,
                      targetSets: sets < 1 ? 1 : sets,
                      targetReps: reps < 1 ? 1 : reps,
                      targetWeightKg: weight < 0 ? 0.0 : weight,
                      restSeconds: rest < 10 ? 10 : rest,
                    );
                    Navigator.pop(ctx, pe);
                  },
                  child: const Text('افزودن'),
                ),
              ],
            );
          },
        );
      },
    );

    if (added != null) {
      setState(() {
        _exercises.add(added);
      });
    }
  }

  void _savePlan() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'لطفاً نام برنامه را وارد فرمایید.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (widget.initialPlan != null) {
        // Update
        final updated = widget.initialPlan!.copyWith(
          titleFa: title,
          descriptionFa: _descController.text.trim(),
          splitType: _splitType,
          daysPerWeek: _daysPerWeek,
          difficulty: _difficulty,
          exercises: _exercises,
        );
        await widget.state.updateWorkoutPlan(updated);
      } else {
        // Create new
        await widget.state.createWorkoutPlan(
          titleFa: title,
          descriptionFa: _descController.text.trim(),
          splitType: _splitType,
          daysPerWeek: _daysPerWeek,
          difficulty: _difficulty,
          exercises: _exercises,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialPlan != null
                ? 'برنامه تمرینی با موفقیت به‌روزرسانی شد.'
                : 'برنامه تمرینی جدید با موفقیت ذخیره گردید.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'خطا در ذخیره‌سازی: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final isEditing = widget.initialPlan != null;

    return Dialog(
      backgroundColor: tokens.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.dialogRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: AppSpacing.dialogPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing
                        ? 'ویرایش برنامه تمرینی'
                        : 'ایجاد برنامه تمرینی جدید',
                    style: AppTypography.pageTitle(context).copyWith(
                      color: tokens.lime,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: AppRadii.roundedSm,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: 12),
                  ),
                ),

              // Form Body
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'نام برنامه (فارسی)',
                        hintText: 'مثال: برنامه تفکیکی پیشرفته عضلات',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'توضیحات و اهداف برنامه',
                        hintText: 'اهداف، شیوه اجرا، شدت و استراحت...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _splitType,
                            decoration:
                                const InputDecoration(labelText: 'نوع اسپلیت'),
                            items: _splitOptions
                                .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s,
                                        style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _splitType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _daysPerWeek,
                            decoration: const InputDecoration(
                                labelText: 'روزها در هفته'),
                            items: [1, 2, 3, 4, 5, 6, 7]
                                .map((d) => DropdownMenuItem(
                                    value: d, child: Text('$d روز')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _daysPerWeek = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _difficulty,
                      decoration: const InputDecoration(labelText: 'سطح سختی'),
                      items: _difficultyOptions
                          .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _difficulty = val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Exercises Header & Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'حرکات برنامه (${PersianUtils.toPersianDigits(_exercises.length)} حرکت)',
                          style: AppTypography.bodySmall(context)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addExerciseDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('افزودن حرکت',
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tokens.lime,
                            foregroundColor: tokens.textOnLime,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (_exercises.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: tokens.cardElevated,
                          borderRadius: AppRadii.roundedMd,
                          border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          'هنوز حرکتی اضافه نشده است. برای افزودن از دکمه بالا استفاده نمایید.',
                          style:
                              TextStyle(color: tokens.textMuted, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...List.generate(_exercises.length, (index) {
                        final pe = _exercises[index];
                        final ex = widget.state.exercises.firstWhere(
                          (e) => e.id == pe.exerciseId,
                          orElse: () => widget.state.exercises.first,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: tokens.cardElevated,
                            borderRadius: AppRadii.roundedSm,
                            border: Border.all(color: tokens.borderColor.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'روز ${PersianUtils.toPersianDigits(pe.dayOfWeek)}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: tokens.cyan,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ex.nameFa,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      '${pe.targetSets} ست × ${pe.targetReps} تکرار • ${pe.targetWeightKg}kg • استراحت: ${pe.restSeconds}s',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: tokens.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              // Move Up
                              if (index > 0)
                                IconButton(
                                  icon:
                                      const Icon(Icons.arrow_upward, size: 16),
                                  onPressed: () {
                                    setState(() {
                                      final item = _exercises.removeAt(index);
                                      _exercises.insert(index - 1, item);
                                    });
                                  },
                                  tooltip: 'انتقال به بالا',
                                ),
                              // Move Down
                              if (index < _exercises.length - 1)
                                IconButton(
                                  icon: const Icon(Icons.arrow_downward,
                                      size: 16),
                                  onPressed: () {
                                    setState(() {
                                      final item = _exercises.removeAt(index);
                                      _exercises.insert(index + 1, item);
                                    });
                                  },
                                  tooltip: 'انتقال به پایین',
                                ),
                              // Delete
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    size: 16, color: theme.colorScheme.error),
                                onPressed: () {
                                  setState(() {
                                    _exercises.removeAt(index);
                                  });
                                },
                                tooltip: 'حذف حرکت',
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('انصراف'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _savePlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.lime,
                      foregroundColor: tokens.textOnLime,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(isEditing ? 'ذخیره تغییرات' : 'ایجاد برنامه'),
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
