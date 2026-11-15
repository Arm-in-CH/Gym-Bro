import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../models/body_analytics_models.dart';
import '../state/app_state.dart';

/// Modal dialog allowing the user to record a new weight or full body measurement.
class AddMeasurementDialog extends StatefulWidget {
  final AppState state;
  final bool initialIsFullBody;

  const AddMeasurementDialog({
    super.key,
    required this.state,
    this.initialIsFullBody = false,
  });

  @override
  State<AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends State<AddMeasurementDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Weight Form
  final _weightFormKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _weightNoteController;
  DateTime _weightDate = DateTime.now();

  // Full Body Circumferences Form
  final _bodyFormKey = GlobalKey<FormState>();
  late TextEditingController _chestController;
  late TextEditingController _waistController;
  late TextEditingController _hipController;
  late TextEditingController _armController;
  late TextEditingController _thighController;
  late TextEditingController _calfController;
  late TextEditingController _bodyFatController;
  late TextEditingController _bodyNoteController;
  DateTime _bodyDate = DateTime.now();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIsFullBody ? 1 : 0,
    );

    final currentWeight = widget.state.currentWeightKg;
    _weightController = TextEditingController(text: currentWeight.toStringAsFixed(1));
    _weightNoteController = TextEditingController();

    final latest = widget.state.latestBodyMeasurement;
    _chestController = TextEditingController(text: latest?.chestCm?.toStringAsFixed(1) ?? '');
    _waistController = TextEditingController(text: latest?.waistCm?.toStringAsFixed(1) ?? '');
    _hipController = TextEditingController(text: latest?.hipCm?.toStringAsFixed(1) ?? '');
    _armController = TextEditingController(text: (latest?.rightArmCm ?? latest?.leftArmCm)?.toStringAsFixed(1) ?? '');
    _thighController = TextEditingController(text: latest?.thighCm?.toStringAsFixed(1) ?? '');
    _calfController = TextEditingController(text: latest?.calfCm?.toStringAsFixed(1) ?? '');
    _bodyFatController = TextEditingController(
      text: widget.state.userProfile.bodyFatPercentage.toStringAsFixed(1),
    );
    _bodyNoteController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightController.dispose();
    _weightNoteController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _armController.dispose();
    _thighController.dispose();
    _calfController.dispose();
    _bodyFatController.dispose();
    _bodyNoteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isWeight) async {
    final initial = isWeight ? _weightDate : _bodyDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('fa', 'IR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.appTokens.lime,
              onPrimary: Colors.black,
              surface: context.appTokens.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isWeight) {
          _weightDate = picked;
        } else {
          _bodyDate = picked;
        }
      });
    }
  }

  Future<void> _saveWeight() async {
    if (!_weightFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final val = PersianUtils.tryParseDouble(_weightController.text);
      if (val == null || val <= 0) {
        setState(() => _isSaving = false);
        return;
      }
      await widget.state.addWeightRecord(
        weightKg: val,
        date: _weightDate,
        note: _weightNoteController.text.trim().isNotEmpty ? _weightNoteController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('وزن ${PersianUtils.toPersianDigits(val.toStringAsFixed(1))} کیلوگرم با موفقیت ثبت شد.'),
            backgroundColor: context.appTokens.lime,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveBodyMeasurements() async {
    if (!_bodyFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    double? parseField(TextEditingController ctrl) {
      return PersianUtils.tryParseDouble(ctrl.text);
    }

    try {
      final record = BodyMeasurementRecord(
        id: 'bm_${DateTime.now().millisecondsSinceEpoch}',
        date: _bodyDate,
        chestCm: parseField(_chestController),
        waistCm: parseField(_waistController),
        hipCm: parseField(_hipController),
        leftArmCm: parseField(_armController),
        rightArmCm: parseField(_armController),
        thighCm: parseField(_thighController),
        calfCm: parseField(_calfController),
        bodyFatPercentage: parseField(_bodyFatController),
        note: _bodyNoteController.text.trim().isNotEmpty ? _bodyNoteController.text.trim() : null,
      );

      await widget.state.addBodyMeasurement(record);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('اندازه‌گیری‌های دور عضلات با موفقیت در پرونده ثبت شد.'),
            backgroundColor: context.appTokens.cyan,
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
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.edit_note, color: tokens.lime, size: 24),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'ثبت آمار و اندازه‌گیری جدید',
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

            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: tokens.lime,
              labelColor: tokens.lime,
              unselectedLabelColor: tokens.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'ثبت وزن (kg)'),
                Tab(text: 'سایزگیری بدن (cm)'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWeightTab(tokens, theme),
                  _buildBodyTab(tokens, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTab(AppThemeExtension tokens, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Form(
        key: _weightFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Card
            _buildDatePickerTile(
              date: _weightDate,
              onTap: () => _selectDate(true),
              tokens: tokens,
            ),
            const SizedBox(height: AppSpacing.md),

            // Weight Field
            Text('وزن ناشتا (کیلوگرم):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tokens.textMuted)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'وزن ناشتا (کیلوگرم)',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                hintText: 'مثال: 72.5',
                suffixText: 'kg',
                suffixStyle: TextStyle(color: tokens.lime, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: tokens.cardElevated,
                border: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.lime, width: 1.5)),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'لطفاً وزن را وارد کنید';
                final n = double.tryParse(val.replaceAll('٫', '.'));
                if (n == null || n < 30 || n > 300) return 'وزن نامعتبر است (بین ۳۰ تا ۳۰۰ کیلوگرم)';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Note
            Text('یادداشت اختیاری (وضعیت تغذیه یا تمرین):', style: TextStyle(fontSize: 12, color: tokens.textMuted)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _weightNoteController,
              maxLines: 2,
              style: const TextStyle(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'مثال: بعد از تمرین سینه و مصرف آب فراوان...',
                hintStyle: TextStyle(color: tokens.textMuted.withOpacity(0.5), fontSize: 12),
                filled: true,
                fillColor: tokens.cardElevated,
                border: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.lime,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.smRadius),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('ثبت و ذخیره وزن'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyTab(AppThemeExtension tokens, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Form(
        key: _bodyFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDatePickerTile(
              date: _bodyDate,
              onTap: () => _selectDate(false),
              tokens: tokens,
            ),
            const SizedBox(height: AppSpacing.md),

            // Circumference Inputs in 2 Columns
            Row(
              children: [
                Expanded(
                  child: _buildMeasureInput(
                    label: 'دور سینه (Chest)',
                    controller: _chestController,
                    unit: 'cm',
                    tokens: tokens,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildMeasureInput(
                    label: 'دور کمر (Waist)',
                    controller: _waistController,
                    unit: 'cm',
                    tokens: tokens,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _buildMeasureInput(
                    label: 'دور باسن (Hips)',
                    controller: _hipController,
                    unit: 'cm',
                    tokens: tokens,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildMeasureInput(
                    label: 'دور بازو (Arm)',
                    controller: _armController,
                    unit: 'cm',
                    tokens: tokens,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _buildMeasureInput(
                    label: 'دور ران (Thigh)',
                    controller: _thighController,
                    unit: 'cm',
                    tokens: tokens,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildMeasureInput(
                    label: 'ساق پا (Calf)',
                    controller: _calfController,
                    unit: 'cm',
                    tokens: tokens,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            _buildMeasureInput(
              label: 'درصد چربی بدن (اختیاری)',
              controller: _bodyFatController,
              unit: '%',
              tokens: tokens,
            ),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _bodyNoteController,
              maxLines: 1,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'یادداشت این سایزگیری...',
                hintStyle: TextStyle(color: tokens.textMuted.withOpacity(0.5), fontSize: 11),
                filled: true,
                fillColor: tokens.cardElevated,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveBodyMeasurements,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.cyan,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.smRadius),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('ثبت سایزهای بدن'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerTile({
    required DateTime date,
    required VoidCallback onTap,
    required AppThemeExtension tokens,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.smRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: tokens.cardElevated,
          borderRadius: AppRadii.smRadius,
          border: Border.all(color: tokens.borderColor),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month, size: 18, color: tokens.lime),
                const SizedBox(width: 8),
                Text('تاریخ اندازه‌گیری:', style: TextStyle(fontSize: 12, color: tokens.textMuted)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  PersianUtils.formatPersianDate(date),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: tokens.lime, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasureInput({
    required String label,
    required TextEditingController controller,
    required String unit,
    required AppThemeExtension tokens,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: tokens.textMuted)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          decoration: InputDecoration(
            suffixText: unit,
            suffixStyle: TextStyle(fontSize: 11, color: tokens.cyan, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: tokens.cardElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: tokens.cyan, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
