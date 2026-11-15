import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/graphics/gymbro_equipment_illustration.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/screens/exercise_bank_screen.dart';
import 'package:gymbro/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late AppState appState;

  final sampleExercises = [
    Exercise(
      id: 'ex_bench_press',
      nameFa: 'پرس سینه با هالتر',
      nameEn: 'Barbell Bench Press',
      muscleGroup: 'chest',
      muscleGroupFa: 'سینه',
      equipment: 'barbell',
      equipmentFa: 'هالتر',
      instructionsFa: 'روی نیمکت دراز بکشید و میله را به آرامی پایین بیاورید.',
      secondaryMuscles: ['پشت بازو', 'سرشانه جلویی'],
    ),
    Exercise(
      id: 'ex_squat',
      nameFa: 'اسکوات با هالتر',
      nameEn: 'Barbell Back Squat',
      muscleGroup: 'legs',
      muscleGroupFa: 'پا',
      equipment: 'barbell',
      equipmentFa: 'هالتر',
      instructionsFa: 'پاها به اندازه عرض شانه، به آرامی بنشینید.',
      secondaryMuscles: ['سرینی', 'همسترینگ'],
    ),
    Exercise(
      id: 'ex_db_curl',
      nameFa: 'جلو بازو با دمبل',
      nameEn: 'Dumbbell Bicep Curl',
      muscleGroup: 'arms',
      muscleGroupFa: 'بازو',
      equipment: 'dumbbell',
      equipmentFa: 'دمبل',
      instructionsFa: 'دمبل‌ها را بالا بیاورید و به آرامی برگردانید.',
      secondaryMuscles: ['ساعد'],
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
    appState = AppState(storage: storage);

    // Replace exercises with deterministic samples
    appState.exercises.clear();
    appState.exercises.addAll(sampleExercises);
  });

  tearDown(() async {
    appState.dispose();
  });

  Widget buildTestWidget({String? initialMuscle}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: ExerciseBankScreen(
        state: appState,
        initialMuscleGroup: initialMuscle,
      ),
    );
  }

  testWidgets('ExerciseBankScreen renders header and search input', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('بانک جامع حرکات ورزشی'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('پرس سینه با هالتر'), findsOneWidget);
    expect(find.text('اسکوات با هالتر'), findsOneWidget);
    expect(find.text('جلو بازو با دمبل'), findsOneWidget);
  });

  testWidgets('Bilingual search filters by Persian query', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'پرس');
    await tester.pumpAndSettle();

    expect(find.text('پرس سینه با هالتر'), findsOneWidget);
    expect(find.text('اسکوات با هالتر'), findsNothing);
    expect(find.text('جلو بازو با دمبل'), findsNothing);
  });

  testWidgets('Bilingual search filters by English query', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Squat');
    await tester.pumpAndSettle();

    expect(find.text('اسکوات با هالتر'), findsOneWidget);
    expect(find.text('پرس سینه با هالتر'), findsNothing);
    expect(find.text('جلو بازو با دمبل'), findsNothing);
  });

  testWidgets('Filters by muscle group chip', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final chestChip = find.text('سینه');
    expect(chestChip, findsWidgets);
    await tester.tap(chestChip.first);
    await tester.pumpAndSettle();

    expect(find.text('پرس سینه با هالتر'), findsOneWidget);
    expect(find.text('اسکوات با هالتر'), findsNothing);
    expect(find.text('جلو بازو با دمبل'), findsNothing);
  });

  testWidgets('Filters by equipment chip', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final dbChip = find.text('دمبل');
    expect(dbChip, findsWidgets);
    await tester.tap(dbChip.first);
    await tester.pumpAndSettle();

    expect(find.text('جلو بازو با دمبل'), findsOneWidget);
    expect(find.text('پرس سینه با هالتر'), findsNothing);
    expect(find.text('اسکوات با هالتر'), findsNothing);
  });

  testWidgets('Uses GymBroEquipmentIllustration vector placeholder and displays sets/reps', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(GymBroEquipmentIllustration), findsWidgets);
    expect(find.textContaining('ست'), findsWidgets);
  });

  testWidgets('Tapping exercise card opens detail modal', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final benchCard = find.text('پرس سینه با هالتر');
    await tester.tap(benchCard);
    await tester.pumpAndSettle();

    expect(find.textContaining('عضله هدف اصلی'), findsOneWidget);
  });
}
