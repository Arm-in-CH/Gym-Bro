import 'package:flutter/material.dart';
import '../core/localization/persian_utils.dart';
import '../core/storage/database_seeder.dart';
import '../models/exercise.dart';
import '../state/app_state.dart';
import '../widgets/common/gymbro_design_system.dart';
import '../widgets/exercise_detail_sheet.dart';

/// Screen representing the full Exercise Bank with bilingual search,
/// muscle group filtering, equipment isolation, and vector equipment illustrations.
class ExerciseBankScreen extends StatefulWidget {
  final AppState state;
  final String? initialMuscleGroup;

  const ExerciseBankScreen({
    super.key,
    required this.state,
    this.initialMuscleGroup,
  });

  @override
  State<ExerciseBankScreen> createState() => _ExerciseBankScreenState();
}

class _ExerciseBankScreenState extends State<ExerciseBankScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedMuscleGroup;
  String? _selectedEquipment;
  bool _showBodyMap = false;

  final List<String> _muscleFilters = const [
    'همه عضلات',
    'سینه',
    'پشت و زیربغل',
    'پا و باسن',
    'سرشانه',
    'جلو و پشت بازو',
    'عضلات مرکزی و شکم',
  ];

  final List<String> _equipmentFilters = const [
    'همه تجهیزات',
    'هالتر',
    'دمبل',
    'دستگاه',
    'سیم‌کش',
    'وزن بدن',
    'کش تمرینی',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMuscleGroup = widget.initialMuscleGroup ?? 'همه عضلات';
    _selectedEquipment = 'همه تجهیزات';
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  List<Exercise> _getFilteredExercises() {
    List<Exercise> list = widget.state.exercises;
    if (list.isEmpty) {
      list = DatabaseSeeder.defaultExercises;
    }

    // 1. Search filter (Bilingual via DatabaseSeeder)
    if (_searchQuery.isNotEmpty) {
      list = DatabaseSeeder.searchExercises(exercises: list, query: _searchQuery);
    }

    // 2. Muscle Group filter
    if (_selectedMuscleGroup != null && _selectedMuscleGroup != 'همه عضلات') {
      list = list.where((ex) {
        final groupFa = ex.muscleGroupFa.toLowerCase();
        final groupEn = ex.muscleGroup.toLowerCase();
        final target = (ex.targetMuscle ?? '').toLowerCase();

        switch (_selectedMuscleGroup) {
          case 'سینه':
            return groupFa.contains('سینه') || groupEn.contains('chest');
          case 'پشت و زیربغل':
            return groupFa.contains('پشت') ||
                groupFa.contains('زیربغل') ||
                groupEn.contains('back') ||
                groupEn.contains('lat');
          case 'پا و باسن':
            return groupFa.contains('پا') ||
                groupFa.contains('ران') ||
                groupFa.contains('ساق') ||
                groupFa.contains('باسن') ||
                groupEn.contains('leg') ||
                groupEn.contains('quad') ||
                groupEn.contains('calf');
          case 'سرشانه':
            return groupFa.contains('سرشانه') || groupEn.contains('shoulder') || target.contains('delt');
          case 'جلو و پشت بازو':
            return groupFa.contains('بازو') ||
                groupEn.contains('arm') ||
                groupEn.contains('bicep') ||
                groupEn.contains('tricep');
          case 'عضلات مرکزی و شکم':
            return groupFa.contains('شکم') || groupFa.contains('مرکزی') || groupEn.contains('core');
          default:
            return true;
        }
      }).toList();
    }

    // 3. Equipment filter
    if (_selectedEquipment != null && _selectedEquipment != 'همه تجهیزات') {
      list = list.where((ex) {
        final eqFa = ex.equipmentFa.toLowerCase();
        final eqEn = ex.equipment.toLowerCase();

        switch (_selectedEquipment) {
          case 'هالتر':
            return eqFa.contains('هالتر') || eqEn.contains('barbell');
          case 'دمبل':
            return eqFa.contains('دمبل') || eqEn.contains('dumbbell');
          case 'دستگاه':
            return eqFa.contains('دستگاه') || eqEn.contains('machine') || eqEn.contains('smith');
          case 'سیم‌کش':
            return eqFa.contains('سیم‌کش') || eqEn.contains('cable');
          case 'وزن بدن':
            return ex.isBodyweight || eqFa.contains('وزن بدن') || eqEn.contains('bodyweight');
          case 'کش تمرینی':
            return eqFa.contains('کش') || eqEn.contains('band');
          default:
            return true;
        }
      }).toList();
    }

    return list;
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedMuscleGroup = 'همه عضلات';
      _selectedEquipment = 'همه تجهیزات';
      _showBodyMap = false;
    });
  }

  void _openExerciseDetails(Exercise exercise) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExerciseDetailSheet(exercise: exercise),
    );
  }

  String _getSuggestedSetsAndReps(Exercise exercise) {
    final eq = exercise.equipment.toLowerCase();
    final name = exercise.nameEn.toLowerCase();

    if (name.contains('squat') || name.contains('deadlift') || name.contains('press')) {
      return '۴ ست × ۶ تا ۸ تکرار (قدرتی)';
    } else if (exercise.isBodyweight || name.contains('crunch') || name.contains('plank')) {
      return '۳ تا ۴ ست × ۱۵ تا ۲۰ تکرار';
    } else if (eq.contains('cable') || eq.contains('dumbbell')) {
      return '۳ ست × ۱۰ تا ۱۲ تکرار (هایپرتروفی)';
    }
    return '۳ ست × ۸ تا ۱۰ تکرار استاندارد';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final exercises = _getFilteredExercises();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: tokens.cardBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'بانک جامع حرکات ورزشی',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _showBodyMap ? Icons.view_headline_rounded : Icons.accessibility_new_rounded,
                color: _showBodyMap ? tokens.lime : tokens.textMuted,
              ),
              tooltip: _showBodyMap ? 'بستن نقشه بدن' : 'فیلتر با نقشه آناتومی',
              onPressed: () => setState(() => _showBodyMap = !_showBodyMap),
            ),
          ],
        ),
        body: Column(
          children: [
            // 1. Search Bar (Bilingual)
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.xs),
              color: tokens.cardBackground,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadii.lgRadius,
                  border: Border.all(color: tokens.borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'جستجوی حرکت (مثال: پرس سینه، Squat، هالتر)...',
                    hintStyle: TextStyle(fontSize: 12, color: tokens.textMuted),
                    prefixIcon: Icon(Icons.search, size: 20, color: tokens.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close, size: 18, color: tokens.textMuted),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ),

            // 2. Interactive Body Map (Collapsible)
            if (_showBodyMap)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                color: tokens.cardBackground,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadii.lgRadius,
                    border: Border.all(color: tokens.lime.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'انتخاب ناحیه آناتومیک هدف:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tokens.lime,
                            ),
                          ),
                          Text(
                            'نقشه آناتومی GymBro',
                            style: TextStyle(fontSize: 10, color: tokens.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildAnatomyChip('سینه', 'chest'),
                          _buildAnatomyChip('پشت و زیربغل', 'back'),
                          _buildAnatomyChip('چهارسر ران', 'quads'),
                          _buildAnatomyChip('همسترینگ', 'hamstrings'),
                          _buildAnatomyChip('سرشانه', 'shoulders'),
                          _buildAnatomyChip('جلوبازو', 'biceps'),
                          _buildAnatomyChip('پشت‌بازو', 'triceps'),
                          _buildAnatomyChip('شکم و مرکز', 'core'),
                          _buildAnatomyChip('ساق پا', 'calves'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // 3. Filter Chips: Muscle Group Row
            Container(
              color: tokens.cardBackground,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.xs, AppSpacing.base, AppSpacing.xs),
                child: Row(
                  children: _muscleFilters.map((muscle) {
                    final isSelected = _selectedMuscleGroup == muscle;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: FilterChip(
                        label: Text(
                          muscle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? tokens.textOnLime : tokens.textMuted,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedMuscleGroup = val ? muscle : 'همه عضلات';
                          });
                        },
                        backgroundColor: AppColors.background,
                        selectedColor: tokens.lime,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.pillRadius,
                          side: BorderSide(
                            color: isSelected ? tokens.lime : tokens.borderColor,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 4. Filter Chips: Equipment Row
            Container(
              color: tokens.cardBackground,
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Row(
                  children: _equipmentFilters.map((equip) {
                    final isSelected = _selectedEquipment == equip;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(
                          equip,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? tokens.cyan : tokens.textMuted,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedEquipment = val ? equip : 'همه تجهیزات';
                          });
                        },
                        backgroundColor: AppColors.background,
                        selectedColor: tokens.cyan.withOpacity(0.18),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.pillRadius,
                          side: BorderSide(
                            color: isSelected ? tokens.cyan : tokens.borderColor.withOpacity(0.6),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Count summary bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 6),
              color: AppColors.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تعداد حرکات یافت‌شده: ${PersianUtils.toPersianDigits(exercises.length)} حرکت',
                    style: TextStyle(fontSize: 11, color: tokens.textMuted),
                  ),
                  if (_searchQuery.isNotEmpty ||
                      _selectedMuscleGroup != 'همه عضلات' ||
                      _selectedEquipment != 'همه تجهیزات')
                    GestureDetector(
                      onTap: _resetFilters,
                      child: Text(
                        'پاکسازی همه فیلترها',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tokens.cyan),
                      ),
                    ),
                ],
              ),
            ),

            // 5. Exercise Cards List
            Expanded(
              child: exercises.isEmpty
                  ? _buildEmptyState(tokens)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.base, 4, AppSpacing.base, AppSpacing.lg),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        return _buildExerciseCard(exercise, tokens);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnatomyChip(String label, String keyword) {
    final tokens = context.appTokens;
    final isSelected = _selectedMuscleGroup?.contains(label) == true;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMuscleGroup = label;
          _showBodyMap = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? tokens.lime : tokens.cardElevated,
          borderRadius: AppRadii.pillRadius,
          border: Border.all(color: isSelected ? tokens.lime : tokens.borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? tokens.textOnLime : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, AppThemeExtension tokens) {
    final suggestedSets = _getSuggestedSetsAndReps(exercise);
    final eqType = GymBroEquipmentTypeX.fromString(exercise.equipment);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor.withOpacity(0.8)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadii.lgRadius,
          onTap: () => _openExerciseDetails(exercise),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Vector Equipment Illustration Placeholder (No GIF)
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadii.mdRadius,
                    border: Border.all(color: tokens.borderColor),
                  ),
                  child: Center(
                    child: GymBroEquipmentIllustration(
                      type: eqType,
                      size: 38,
                      accentColor: tokens.lime,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 2. Exercise Details (Name, Muscle, Suggested Sets)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.nameFa,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exercise.nameEn,
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Badges: Target Muscle + Equipment + Suggested Sets
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Target Muscle Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: tokens.lime.withOpacity(0.14),
                              borderRadius: AppRadii.xsRadius,
                              border: Border.all(color: tokens.lime.withOpacity(0.3)),
                            ),
                            child: Text(
                              exercise.muscleGroupFa,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: tokens.lime,
                              ),
                            ),
                          ),

                          // Equipment Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: tokens.cardElevated,
                              borderRadius: AppRadii.xsRadius,
                              border: Border.all(color: tokens.borderColor),
                            ),
                            child: Text(
                              exercise.equipmentFa,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: tokens.textMuted,
                              ),
                            ),
                          ),

                          // Suggested Sets Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: tokens.cyan.withOpacity(0.12),
                              borderRadius: AppRadii.xsRadius,
                              border: Border.all(color: tokens.cyan.withOpacity(0.3)),
                            ),
                            child: Text(
                              suggestedSets,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: tokens.cyan,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing Info Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: tokens.textMuted.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeExtension tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 56,
              color: tokens.textMuted.withOpacity(0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'هیچ حرکتی با فیلترهای انتخابی یافت نشد.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'کلمات کلیدی جستجو یا فیلترهای عضلات و تجهیزات را بازنشانی فرمایید.',
              style: TextStyle(fontSize: 12, color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.lime,
                foregroundColor: tokens.textOnLime,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('پاکسازی همه فیلترها'),
            ),
          ],
        ),
      ),
    );
  }
}
