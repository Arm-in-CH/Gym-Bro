import 'package:flutter/material.dart';
import '../core/localization/persian_utils.dart';
import '../core/theme/app_tokens.dart';
import '../models/body_analytics_models.dart';
import '../models/exercise.dart';
import 'body_3d_wireframe_visualizer.dart';

enum BodyMapView { front, back }

enum BodyMuscleRegion {
  chest('سینه', BodyMapView.front, BodyPartFocus.chest,
      ['chest', 'pectoral', 'سینه']),
  shoulders('سرشانه', BodyMapView.front, BodyPartFocus.arm,
      ['shoulder', 'deltoid', 'سرشانه']),
  biceps('جلوبازو', BodyMapView.front, BodyPartFocus.arm,
      ['bicep', 'arm', 'جلو بازو', 'جلوبازو']),
  forearms('ساعد', BodyMapView.front, BodyPartFocus.arm,
      ['forearm', 'arm', 'ساعد']),
  abs('شکم', BodyMapView.front, BodyPartFocus.waist,
      ['core', 'abdominal', 'شکم']),
  quadriceps('چهارسر ران', BodyMapView.front, BodyPartFocus.thigh,
      ['quadricep', 'leg', 'ران', 'پا']),
  frontCalves('ساق پا', BodyMapView.front, BodyPartFocus.calf,
      ['calf', 'ساق']),
    rearShoulders('سرشانه پشتی', BodyMapView.back, BodyPartFocus.arm,
      ['shoulder', 'deltoid', 'سرشانه']),
    rearForearms('ساعد', BodyMapView.back, BodyPartFocus.arm,
      ['forearm', 'arm', 'ساعد']),
  triceps('پشت‌بازو', BodyMapView.back, BodyPartFocus.arm,
      ['tricep', 'arm', 'پشت بازو', 'پشت‌بازو']),
  upperBack('پشت میانی', BodyMapView.back, null,
      ['back', 'lat', 'پشت', 'زیربغل']),
  lats('زیربغل', BodyMapView.back, null,
      ['back', 'lat', 'زیربغل', 'پشت']),
  lowerBack('فیله کمر', BodyMapView.back, BodyPartFocus.waist,
      ['back', 'lower', 'کمر', 'فیله']),
  glutes('باسن', BodyMapView.back, BodyPartFocus.hip,
      ['glute', 'hip', 'باسن']),
  hamstrings('همسترینگ', BodyMapView.back, BodyPartFocus.thigh,
      ['hamstring', 'leg', 'پشت پا', 'همسترینگ']),
  backCalves('ساق پا', BodyMapView.back, BodyPartFocus.calf,
      ['calf', 'ساق']);

  const BodyMuscleRegion(
    this.labelFa,
    this.view,
    this.measurementFocus,
    this.exerciseKeywords,
  );

  final String labelFa;
  final BodyMapView view;
  final BodyPartFocus? measurementFocus;
  final List<String> exerciseKeywords;
}

class BodyMuscleMap extends StatefulWidget {
  final BodyMeasurementRecord? latestMeasurement;
  final BodyMeasurementRecord? previousMeasurement;
  final List<Exercise> exercises;
  final ValueChanged<BodyPartFocus>? onPartSelected;
  final VoidCallback? onAddMeasurement;

  const BodyMuscleMap({
    super.key,
    this.latestMeasurement,
    this.previousMeasurement,
    this.exercises = const [],
    this.onPartSelected,
    this.onAddMeasurement,
  });

  @override
  State<BodyMuscleMap> createState() => _BodyMuscleMapState();
}

class _BodyMuscleMapState extends State<BodyMuscleMap> {
  static const double _figureWidth = 240;
  static const double _figureHeight = 370;

  BodyMapView _view = BodyMapView.front;
  BodyMuscleRegion _selectedRegion = BodyMuscleRegion.chest;

  List<BodyMuscleRegion> get _visibleRegions =>
      BodyMuscleRegion.values.where((region) => region.view == _view).toList();

  void _selectRegion(BodyMuscleRegion region) {
    setState(() => _selectedRegion = region);
    final focus = region.measurementFocus;
    if (focus != null) widget.onPartSelected?.call(focus);
  }

  void _selectView(BodyMapView view) {
    setState(() {
      _view = view;
      _selectedRegion = view == BodyMapView.front
          ? BodyMuscleRegion.chest
          : BodyMuscleRegion.upperBack;
    });
    final focus = _selectedRegion.measurementFocus;
    if (focus != null) widget.onPartSelected?.call(focus);
  }

  double? get _currentValue =>
      _selectedRegion.measurementFocus?.getValue(widget.latestMeasurement);

  double? get _measurementChange {
    final focus = _selectedRegion.measurementFocus;
    if (focus == null) return null;
    final current = focus.getValue(widget.latestMeasurement);
    final previous = focus.getValue(widget.previousMeasurement);
    if (current == null || previous == null) return null;
    return current - previous;
  }

  List<Exercise> get _relatedExercises {
    final keywords = _selectedRegion.exerciseKeywords;
    return widget.exercises.where((exercise) {
      final searchable = [
        exercise.nameFa,
        exercise.nameEn,
        exercise.muscleGroup,
        exercise.muscleGroupFa,
        exercise.targetMuscle ?? '',
        ...?exercise.secondaryMuscles,
      ].join(' ').toLowerCase();
      return keywords.any((keyword) => searchable.contains(keyword));
    }).take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final currentValue = _currentValue;
    final change = _measurementChange;

    return Container(
      key: const ValueKey('body-muscle-map'),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tokens.lime.withOpacity(0.14),
                  borderRadius: AppRadii.smRadius,
                ),
                child: Icon(Icons.accessibility_new, color: tokens.lime),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نقشه عضلات بدن',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'نما را عوض کن و یک عضله را انتخاب کن',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: SegmentedButton<BodyMapView>(
              key: const ValueKey('body-view-switch'),
              segments: const [
                ButtonSegment(
                  value: BodyMapView.front,
                  label: Text('نمای جلو'),
                  icon: Icon(Icons.person_outline),
                ),
                ButtonSegment(
                  value: BodyMapView.back,
                  label: Text('نمای پشت'),
                  icon: Icon(Icons.accessibility),
                ),
              ],
              selected: {_view},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => _selectView(selection.first),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: _figureWidth,
              height: _figureHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF080B0E),
                borderRadius: AppRadii.mdRadius,
                border: Border.all(color: tokens.borderColor.withOpacity(0.7)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _view == BodyMapView.front
                        ? 'assets/images/anatomy_front.png'
                        : 'assets/images/anatomy_back.png',
                    fit: BoxFit.fill,
                    semanticLabel: _view == BodyMapView.front
                        ? 'نمای جلویی آناتومی عضلات بدن'
                        : 'نمای پشتی آناتومی عضلات بدن',
                  ),
                  ..._hotspotsFor(_view).map(_buildHotspot),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _visibleRegions.map((region) {
              final selected = _selectedRegion == region;
              return FilterChip(
                key: ValueKey('body-region-${region.name}'),
                label: Text(region.labelFa),
                selected: selected,
                showCheckmark: selected,
                selectedColor: tokens.lime.withOpacity(0.18),
                side: BorderSide(
                  color: selected ? tokens.lime : tokens.borderColor,
                ),
                labelStyle: TextStyle(
                  color: selected ? tokens.lime : theme.colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => _selectRegion(region),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSelectedDetails(
            theme: theme,
            tokens: tokens,
            currentValue: currentValue,
            change: change,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('add-body-measurement'),
              onPressed: widget.onAddMeasurement,
              icon: const Icon(Icons.add_chart_outlined),
              label: const Text('ثبت اندازه‌گیری بدن'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotspot(_BodyHotspot hotspot) {
    final selected = hotspot.region == _selectedRegion;
    return Positioned(
      left: hotspot.left * _figureWidth,
      top: hotspot.top * _figureHeight,
      width: hotspot.width * _figureWidth,
      height: hotspot.height * _figureHeight,
      child: Semantics(
        button: true,
        selected: selected,
        label: hotspot.region.labelFa,
        child: Tooltip(
          message: hotspot.region.labelFa,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey(
                'body-hotspot-${hotspot.region.name}-${hotspot.side}',
              ),
              customBorder: const StadiumBorder(),
              onTap: () => _selectRegion(hotspot.region),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFCCFF00).withOpacity(0.34)
                      : Colors.white.withOpacity(0.035),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFCCFF00)
                        : Colors.white.withOpacity(0.16),
                    width: selected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDetails({
    required ThemeData theme,
    required AppThemeExtension tokens,
    required double? currentValue,
    required double? change,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardElevated,
        borderRadius: AppRadii.mdRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedRegion.labelFa,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: tokens.lime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (currentValue != null)
                Text(
                  '${PersianUtils.toPersianDigits(currentValue.toStringAsFixed(1))} cm',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: tokens.lime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            currentValue == null
                ? 'برای این ناحیه هنوز اندازه‌ای ثبت نشده است.'
                : change == null
                    ? 'آخرین اندازه ثبت‌شده'
                    : 'تغییر نسبت به ثبت قبلی: ${change > 0 ? '+' : ''}${PersianUtils.toPersianDigits(change.toStringAsFixed(1))} cm',
            style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'حرکت‌های مرتبط',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (_relatedExercises.isEmpty)
            Text(
              'حرکتی برای این عضله در برنامه‌ها پیدا نشد.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.textMuted,
              ),
            )
          else
            ..._relatedExercises.map(
              (exercise) => Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(Icons.fitness_center, size: 15, color: tokens.cyan),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        exercise.nameFa,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      exercise.equipmentFa,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<_BodyHotspot> _hotspotsFor(BodyMapView view) {
    if (view == BodyMapView.front) {
      return const [
        _BodyHotspot(BodyMuscleRegion.shoulders, 0.25, 0.20, 0.15, 0.10, 'left'),
        _BodyHotspot(BodyMuscleRegion.shoulders, 0.60, 0.20, 0.15, 0.10, 'right'),
        _BodyHotspot(BodyMuscleRegion.chest, 0.35, 0.25, 0.30, 0.11, 'center'),
        _BodyHotspot(BodyMuscleRegion.biceps, 0.15, 0.30, 0.13, 0.12, 'left'),
        _BodyHotspot(BodyMuscleRegion.biceps, 0.72, 0.30, 0.13, 0.12, 'right'),
        _BodyHotspot(BodyMuscleRegion.forearms, 0.02, 0.41, 0.14, 0.13, 'left'),
        _BodyHotspot(BodyMuscleRegion.forearms, 0.84, 0.41, 0.14, 0.13, 'right'),
        _BodyHotspot(BodyMuscleRegion.abs, 0.37, 0.37, 0.26, 0.16, 'center'),
        _BodyHotspot(BodyMuscleRegion.quadriceps, 0.29, 0.55, 0.18, 0.17, 'left'),
        _BodyHotspot(BodyMuscleRegion.quadriceps, 0.53, 0.55, 0.18, 0.17, 'right'),
        _BodyHotspot(BodyMuscleRegion.frontCalves, 0.29, 0.75, 0.17, 0.14, 'left'),
        _BodyHotspot(BodyMuscleRegion.frontCalves, 0.54, 0.75, 0.17, 0.14, 'right'),
      ];
    }
    return const [
      _BodyHotspot(BodyMuscleRegion.rearShoulders, 0.23, 0.19, 0.16, 0.11, 'left'),
      _BodyHotspot(BodyMuscleRegion.rearShoulders, 0.61, 0.19, 0.16, 0.11, 'right'),
      _BodyHotspot(BodyMuscleRegion.upperBack, 0.35, 0.22, 0.30, 0.16, 'center'),
      _BodyHotspot(BodyMuscleRegion.triceps, 0.14, 0.31, 0.13, 0.13, 'left'),
      _BodyHotspot(BodyMuscleRegion.triceps, 0.73, 0.31, 0.13, 0.13, 'right'),
      _BodyHotspot(BodyMuscleRegion.rearForearms, 0.01, 0.42, 0.14, 0.14, 'left'),
      _BodyHotspot(BodyMuscleRegion.rearForearms, 0.85, 0.42, 0.14, 0.14, 'right'),
      _BodyHotspot(BodyMuscleRegion.lats, 0.27, 0.34, 0.17, 0.15, 'left'),
      _BodyHotspot(BodyMuscleRegion.lats, 0.56, 0.34, 0.17, 0.15, 'right'),
      _BodyHotspot(BodyMuscleRegion.lowerBack, 0.39, 0.42, 0.22, 0.12, 'center'),
      _BodyHotspot(BodyMuscleRegion.glutes, 0.36, 0.54, 0.28, 0.11, 'center'),
      _BodyHotspot(BodyMuscleRegion.hamstrings, 0.28, 0.64, 0.18, 0.14, 'left'),
      _BodyHotspot(BodyMuscleRegion.hamstrings, 0.54, 0.64, 0.18, 0.14, 'right'),
      _BodyHotspot(BodyMuscleRegion.backCalves, 0.29, 0.78, 0.17, 0.13, 'left'),
      _BodyHotspot(BodyMuscleRegion.backCalves, 0.54, 0.78, 0.17, 0.13, 'right'),
    ];
  }
}

class _BodyHotspot {
  final BodyMuscleRegion region;
  final double left;
  final double top;
  final double width;
  final double height;
  final String side;

  const _BodyHotspot(
    this.region,
    this.left,
    this.top,
    this.width,
    this.height,
    this.side,
  );
}