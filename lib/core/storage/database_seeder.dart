import '../../models/user_level.dart';
import '../../models/user_profile.dart';
import '../../models/exercise.dart';
import '../../models/workout_plan.dart';
import '../../models/nutrition_plan.dart';
import '../../models/marketplace_models.dart';
import '../../models/body_analytics_models.dart';
import '../../models/calorie_scan_log.dart';
import '../../models/nutrition_models.dart';
import '../localization/persian_utils.dart';
import '../../models/open_gym_exercise_model.dart';

class DatabaseSeeder {
  static UserProfile get defaultUserProfile => UserProfile(
        id: 'user_armin_1',
        firstName: 'آرمین',
        lastName: 'چینی‌پرداز',
        phone: '+989120000000',
        email: 'armin@gymbro.ir',
        weightKg: 72.6,
        heightCm: 165.0,
        age: 20,
        bodyFatPercentage: 27.2,
        muscleMassKg: 29.9,
        fitnessGoal: 'بهبود فرم بدنی و عضله‌سازی (Body Recomposition)',
        fitnessLevel: 'متوسط (Intermediate)',
        level: UserLevel.athlete,
        coins: 60,
        dailyFreeScans: 5,
        streakDays: 14,
        totalWorkoutsCompleted: 42,
        activeSinceMonths: 4,
      );

  static NutritionPlan get defaultNutritionPlan => NutritionPlan(
        id: 'plan_armin_rejim_533',
        dailyCalories: 2250,
        targetProteinG: 160,
        targetCarbsG: 220,
        targetFatG: 55,
        targetWaterMl: 3000,
      );

  static List<Exercise> get defaultExercises => [
        // DAY 1: LEGS & CORE (پا و شکم)
        Exercise(
          id: 'ex_squat',
          nameEn: 'Barbell Back Squat',
          nameFa: 'اسکوات هالتر',
          muscleGroup: 'Legs',
          muscleGroupFa: 'چهارسر ران و سرینی',
          equipment: 'Barbell',
          equipmentFa: 'هالتر',
          instructionsFa:
              'هالتر روی کول، سینه بالا، کنترل شده تا زاویه ۹۰ درجه پایین بروید و مفاصل زانو را قفل نکنید.',
          isBodyweight: false,
          homeEquivalentId: 'ex_jump_squats',
        ),
        Exercise(
          id: 'ex_leg_press',
          nameEn: 'Leg Press Machine',
          nameFa: 'پرس پا دستگاه',
          muscleGroup: 'Legs',
          muscleGroupFa: 'چهارسر ران و باسن',
          equipment: 'Machine',
          equipmentFa: 'دستگاه پرس پا',
          instructionsFa:
              'پاها به عرض شانه روی صفحه، زانوها در مسیر انگشتان پا باز و کنترل شده پایین بیاید.',
          isBodyweight: false,
          homeEquivalentId: 'ex_bulgarian_split_squat',
        ),
        Exercise(
          id: 'ex_rdl_db',
          nameEn: 'Romanian Deadlift (Dumbbell)',
          nameFa: 'ددلیفت رومانیایی دمبل',
          muscleGroup: 'Legs',
          muscleGroupFa: 'همسترینگ و باسن',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa:
              'باسن را به عقب هدایت کرده، زانوها خم جزئی، دمبل‌ها چسبیده به ران و کشش عمیق همسترینگ.',
          isBodyweight: false,
          homeEquivalentId: 'ex_towel_superman',
        ),
        Exercise(
          id: 'ex_leg_extension',
          nameEn: 'Leg Extension Machine',
          nameFa: 'جلو پا دستگاه',
          muscleGroup: 'Legs',
          muscleGroupFa: 'چهارسر ران',
          equipment: 'Machine',
          equipmentFa: 'دستگاه جلو پا',
          instructionsFa:
              'بالا آوردن وزنه با انقباض ۱ ثانیه‌ای راس حرکت در سوپرست با پشت پا.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_lying_leg_curl',
          nameEn: 'Lying Leg Curl',
          nameFa: 'پشت پا دستگاه خوابیده',
          muscleGroup: 'Legs',
          muscleGroupFa: 'همسترینگ',
          equipment: 'Machine',
          equipmentFa: 'دستگاه پشت پا',
          instructionsFa:
              'پاشنه‌ها به سمت باسن بدون جدا شدن لگن از روی تشک، سوپرست با جلو پا.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_hack_calf_raise',
          nameEn: 'Hack Squat Calf Raise',
          nameFa: 'ساق پا با دستگاه هاگ',
          muscleGroup: 'Calves',
          muscleGroupFa: 'ساق پا',
          equipment: 'Machine',
          equipmentFa: 'دستگاه هاگ',
          instructionsFa:
              'کشش کامل در پایین و ایست کامل روی پنجه پا به مدت ۱ ثانیه در اوج حرکت.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_plank',
          nameEn: 'Core Plank',
          nameFa: 'پلنک شکم',
          muscleGroup: 'Core',
          muscleGroupFa: 'عضلات مرکزی و شکم',
          equipment: 'Bodyweight',
          equipmentFa: 'وزن بدن',
          instructionsFa:
              'انقباض مداوم شکم و فیله کمر به مدت ۱ دقیقه بدون افتادگی باسن.',
          isBodyweight: true,
        ),
        Exercise(
          id: 'ex_incline_weighted_crunch',
          nameEn: 'Incline Bench Weighted Crunch',
          nameFa: 'شکم شیب با وزنه',
          muscleGroup: 'Core',
          muscleGroupFa: 'راست شکمی',
          equipment: 'Free Weight',
          equipmentFa: 'صفحه یا دمبل',
          instructionsFa:
              'روی میز شیب‌دار، صفحه وزنه روی سینه و انقباض بالاتنه بدون فشار به گردن.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_incline_leg_raise',
          nameEn: 'Incline Bench Leg Raise',
          nameFa: 'زیر شکم روی میز شیب‌دار',
          muscleGroup: 'Core',
          muscleGroupFa: 'زیر شکم',
          equipment: 'Bench',
          equipmentFa: 'میز شیب‌دار',
          instructionsFa:
              'لبه میز را گرفته، پاها با انقباض زیر شکم بالا برود و کنترل شده پایین بیاید.',
          isBodyweight: true,
        ),

        // DAY 2: CHEST, ARMS & LOWER BACK (سینه، بازو و فیله کمر)
        Exercise(
          id: 'ex_bench_press_pyramid',
          nameEn: 'Barbell Bench Press (Pyramid)',
          nameFa: 'پرس سینه هالتر (هرمی)',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Barbell',
          equipmentFa: 'هالتر',
          instructionsFa:
              'اجرای هرمی با افزایش وزنه: ۱۲-۱۰-۸-۶ تکرار با ریتم متوسط و تمرکز بر فیبرهای میانی سینه.',
          isBodyweight: false,
          homeEquivalentId: 'ex_pushups',
        ),
        Exercise(
          id: 'ex_cable_crossover',
          nameEn: 'Cable Crossover Fly',
          nameFa: 'قفسه سینه کراس اور',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Cable',
          equipmentFa: 'دستگاه کراس‌اور',
          instructionsFa:
              'کشش کامل سینه در باز شدن و فشردن قوی دست‌ها روبروی سینه.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_incline_db_press',
          nameEn: 'Incline Dumbbell Press',
          nameFa: 'پرس بالا سینه دمبل',
          muscleGroup: 'Chest',
          muscleGroupFa: 'بالا سینه',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa:
              '۱۰ تکرار سنگین سوپرست فوری با شنا سوئدی تا نهایت توان.',
          isBodyweight: false,
          homeEquivalentId: 'ex_decline_pushups',
        ),
        Exercise(
          id: 'ex_pushups',
          nameEn: 'Standard Push-Ups (To Failure)',
          nameFa: 'شنا سوئدی (تا ناتوانی)',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Bodyweight',
          equipmentFa: 'وزن بدن',
          instructionsFa:
              'بلافاصله بعد از پرس بالاسینه دمبل تا سر حد ناتوانی عضلانی (Max).',
          isBodyweight: true,
        ),
        Exercise(
          id: 'ex_machine_chest_press',
          nameEn: 'Machine Chest Press',
          nameFa: 'پرس سینه دستگاه',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Machine',
          equipmentFa: 'دستگاه پرس سینه',
          instructionsFa:
              '۲۰ تکرار پرفشار با ریتم متوسط برای پمپاژ خون عضلانی.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_cable_rope_biceps',
          nameEn: 'Cable Rope Biceps Curl',
          nameFa: 'جلو بازو سیم‌کش طناب',
          muscleGroup: 'Arms',
          muscleGroupFa: 'جلو بازو',
          equipment: 'Cable',
          equipmentFa: 'سیم‌کش با طناب',
          instructionsFa: '۱۰ تکرار سوپرست با پشت بازو سیم‌کش طناب.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_cable_rope_triceps',
          nameEn: 'Cable Rope Triceps Pushdown',
          nameFa: 'پشت بازو سیم‌کش طناب',
          muscleGroup: 'Arms',
          muscleGroupFa: 'پشت بازو',
          equipment: 'Cable',
          equipmentFa: 'سیم‌کش با طناب',
          instructionsFa:
              '۱۰ تکرار سوپرست با جلو بازو طناب، انقباض کامل آرنج‌ها.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_ez_bar_curl',
          nameEn: 'EZ Bar Biceps Curl',
          nameFa: 'جلو بازو هالتر EZ',
          muscleGroup: 'Arms',
          muscleGroupFa: 'جلو بازو',
          equipment: 'Barbell',
          equipmentFa: 'هالتر EZ',
          instructionsFa: '۱۰ تکرار سوپرست با پشت‌بازو سیم‌کش طناب از پشت سر.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_overhead_cable_triceps',
          nameEn: 'Overhead Cable Rope Triceps Extension',
          nameFa: 'پشت بازو سیم‌کش طناب از پشت سر',
          muscleGroup: 'Arms',
          muscleGroupFa: 'پشت بازو',
          equipment: 'Cable',
          equipmentFa: 'سیم‌کش طناب',
          instructionsFa: 'کشش عمیق سر بلند پشت بازو بالای سر.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_alt_db_curl',
          nameEn: 'Standing Alternating Dumbbell Curl',
          nameFa: 'جلو بازو دمبل تناوبی ایستاده',
          muscleGroup: 'Arms',
          muscleGroupFa: 'جلو بازو',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa:
              '۱۰ تکرار با چرخش مچ در اوج حرکت سوپرست با پشت بازو دمبل جفت.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_two_arm_db_triceps',
          nameEn: 'Overhead Two-Arm Dumbbell Triceps Extension',
          nameFa: 'پشت بازو دمبل جفت از پشت سر',
          muscleGroup: 'Arms',
          muscleGroupFa: 'پشت بازو',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa: 'دمبل دو دستی پشت سر با آرنج‌های بسته به سمت داخل.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_hyperextension',
          nameEn: 'Back Extension / Hyperextension',
          nameFa: 'فیله کمر',
          muscleGroup: 'Back',
          muscleGroupFa: 'فیله و پایین کمر',
          equipment: 'Bench',
          equipmentFa: 'میز فیله کمر',
          instructionsFa:
              'کنترل کامل ستون فقرات بدون پرتاب ناگهانی کمر در انتهای حرکت.',
          isBodyweight: true,
        ),

        // DAY 3: BACK, SHOULDERS, TRAPS & CORE (زیربغل، سرشانه و کول، شکم)
        Exercise(
          id: 'ex_chin_ups',
          nameEn: 'Underhand Chin-Ups',
          nameFa: 'زیر بغل بارفیکس دست معکوس',
          muscleGroup: 'Back',
          muscleGroupFa: 'زیربغل و پشت',
          equipment: 'Bodyweight',
          equipmentFa: 'میله بارفیکس',
          instructionsFa:
              'دست‌ها مچ رو به صورت، بالا کشیدن تا رسیدن چانه به بالای میله.',
          isBodyweight: true,
          homeEquivalentId: 'ex_doorframe_row',
        ),
        Exercise(
          id: 'ex_vbar_cable_row',
          nameEn: 'Seated Cable Row (V-Bar)',
          nameFa: 'زیر بغل قایقی میله V',
          muscleGroup: 'Back',
          muscleGroupFa: 'پشت و زیربغل',
          equipment: 'Cable',
          equipmentFa: 'دستگاه قایقی سیم‌کش',
          instructionsFa:
              'کشش بالاتنه به جلو و فشردن دستگیره V به ناف با انقباض تیغه‌های شانه.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_lat_pulldown_front',
          nameEn: 'Front Lat Pulldown',
          nameFa: 'زیر بغل سیم‌کش از جلو',
          muscleGroup: 'Back',
          muscleGroupFa: 'عضلات پشتی بزرگ',
          equipment: 'Cable',
          equipmentFa: 'دستگاه سیم‌کش عمودی',
          instructionsFa: '۱۰ تکرار سوپرست با زیربغل T-Bar دست باز.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_tbar_row_wide',
          nameEn: 'T-Bar Row (Wide Grip)',
          nameFa: 'زیر بغل T بار دست باز',
          muscleGroup: 'Back',
          muscleGroupFa: 'پشت و ذوزنقه‌ای',
          equipment: 'Machine',
          equipmentFa: 'دستگاه تی‌بار',
          instructionsFa:
              'دستگیره عریض، کشش آرنج‌ها به طرفین برای تمرکز روی پهنای پشت.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_wide_cable_row',
          nameEn: 'Wide Grip Seated Row',
          nameFa: 'زیربغل قایقی دست باز',
          muscleGroup: 'Back',
          muscleGroupFa: 'پشت میانی',
          equipment: 'Cable',
          equipmentFa: 'سیم‌کش قایقی',
          instructionsFa: '۲۰ تکرار برای پمپاژ با میله صاف و دستگیره عریض.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_standing_overhead_press',
          nameEn: 'Standing Barbell Overhead Press',
          nameFa: 'پرس سرشانه هالتر ایستاده از جلو',
          muscleGroup: 'Shoulders',
          muscleGroupFa: 'سرشانه جلویی و میانی',
          equipment: 'Barbell',
          equipmentFa: 'هالتر',
          instructionsFa:
              'شکم سفت، هالتر از زیر گلو تا بالای سر بدون قوس غیرطبیعی کمر.',
          isBodyweight: false,
          homeEquivalentId: 'ex_pike_pushups',
        ),
        Exercise(
          id: 'ex_seated_db_press',
          nameEn: 'Seated Dumbbell Shoulder Press',
          nameFa: 'پرس سرشانه دمبل نشسته',
          muscleGroup: 'Shoulders',
          muscleGroupFa: 'سرشانه',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa: '۱۰ تکرار سوپرست با نشر از جانب دمبل ایستاده.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_lateral_raise_db',
          nameEn: 'Standing Dumbbell Lateral Raise',
          nameFa: 'نشر از بغل دمبل ایستاده',
          muscleGroup: 'Shoulders',
          muscleGroupFa: 'سرشانه میانی',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa:
              'آرنج‌ها کمی خمیده، بالا آوردن دمبل‌ها تا خط شانه در سوپرست با پرس دمبل.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_reverse_pec_deck',
          nameEn: 'Reverse Pec Deck Fly',
          nameFa: 'فلای عکس دستگاه',
          muscleGroup: 'Shoulders',
          muscleGroupFa: 'سرشانه پشتی (دلتا عقب)',
          equipment: 'Machine',
          equipmentFa: 'دستگاه فلای معکوس',
          instructionsFa: 'تمرکز خالص روی عضلات دلتوئید خلفی بدون دخالت کول.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_barbell_shrugs',
          nameEn: 'Standing Barbell Shrugs',
          nameFa: 'شراگز هالتر از جلو',
          muscleGroup: 'Traps',
          muscleGroupFa: 'کول و ذوزنقه‌ای',
          equipment: 'Barbell',
          equipmentFa: 'هالتر',
          instructionsFa:
              'بالا کشیدن مستقیم شانه‌ها به سمت گوش‌ها با ۱ ثانیه مکث در بالا.',
          isBodyweight: false,
        ),
        Exercise(
          id: 'ex_captains_chair_leg_raise',
          nameEn: 'Captains Chair Hanging Knee Raise',
          nameFa: 'زیرشکم خلبانی',
          muscleGroup: 'Core',
          muscleGroupFa: 'زیر شکم',
          equipment: 'Station',
          equipmentFa: 'دستگاه خلبانی',
          instructionsFa:
              'سوپرست با شکم شیب با وزنه، بالا آوردن زانوها به سینه بدون تکانه.',
          isBodyweight: true,
        ),

        // HOME FALLBACK EXERCISES
        Exercise(
          id: 'ex_decline_pushups',
          nameEn: 'Feet-Elevated Push-Ups',
          nameFa: 'شنا پاهای بالا (بالا سینه خانگی)',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Bodyweight',
          equipmentFa: 'وزن بدن / صندلی',
          instructionsFa:
              'پاها روی مبل یا صندلی برای انتقال فشار به بالای سینه.',
          isBodyweight: true,
        ),
        Exercise(
          id: 'ex_doorframe_row',
          nameEn: 'Doorframe Inverted Row',
          nameFa: 'پارویی لنگه در / حوله خانگی',
          muscleGroup: 'Back',
          muscleGroupFa: 'پشت',
          equipment: 'Bodyweight',
          equipmentFa: 'چهارچوب درب',
          instructionsFa:
              'گرفتن لبه محکم چهارچوب با بدن شیب‌دار و کشیدن به جلو.',
          isBodyweight: true,
        ),
        Exercise(
          id: 'ex_bulgarian_split_squat',
          nameEn: 'Bulgarian Split Squats',
          nameFa: 'اسکوات بلغاری تک‌پا روی صندلی',
          muscleGroup: 'Legs',
          muscleGroupFa: 'پا و باسن',
          equipment: 'Bodyweight',
          equipmentFa: 'وزن بدن / صندلی',
          instructionsFa: 'پای عقب روی صندلی و اسکوات عمیق با پای جلو.',
          isBodyweight: true,
        ),
        Exercise(
          id: 'ex_jump_squats',
          nameEn: 'Explosive Jump Squats',
          nameFa: 'اسکوات پرشی انفجاری',
          muscleGroup: 'Legs',
          muscleGroupFa: 'پا',
          equipment: 'Bodyweight',
          equipmentFa: 'وزن بدن',
          instructionsFa: 'اسکوات سریع با جهش انفجاری به بالا.',
          isBodyweight: true,
        ),
        Exercise(
          id: 'ex_pike_pushups',
          nameEn: 'Pike Push-Ups',
          nameFa: 'شنا پایک سرشانه',
          muscleGroup: 'Shoulders',
          muscleGroupFa: 'سرشانه',
          equipment: 'Bodyweight',
          equipmentFa: 'وزن بدن',
          instructionsFa: 'باسن بالا به حالت هرم و پرس به سمت زمین.',
          isBodyweight: true,
        ),
        Exercise(
          id: 'ex_chair_dips',
          nameEn: 'Chair / Bench Dips',
          nameFa: 'دیپ لبه صندلی خانگی',
          muscleGroup: 'Arms',
          muscleGroupFa: 'پشت بازو',
          equipment: 'Bodyweight',
          equipmentFa: 'صندلی',
          instructionsFa: 'دیپ پشت بازو با استفاده از صندلی یا لبه تخت.',
          isBodyweight: true,
        ),
        Exercise(
          id: 'ex_towel_superman',
          nameEn: 'Prone Superman with Towel',
          nameFa: 'سوپرمن روی زمین با حوله کششی',
          muscleGroup: 'Back',
          muscleGroupFa: 'فیله و پشت',
          equipment: 'Bodyweight',
          equipmentFa: 'حوله',
          instructionsFa:
              'خوابیده روی شکم، کشیدن حوله به طرفین و انقباض فیله کمر.',
          isBodyweight: true,
        ),
      ];

  static List<WorkoutPlan> get defaultWorkoutPlans => [
        WorkoutPlan(
          id: 'plan_armin_3day',
          titleFa: 'برنامه ۳ روزه بدنسازی آرمین (برنامه اصلی)',
          titleEn: 'Armin Chinipardaz Hypertrophy Plan',
          descriptionFa:
              'برنامه تمرینی رسمی آرمین چینی‌پرداز بر اساس پروتکل گرم کردن مفاصل و تردمیل، ۳ جلسه هفتگی، و سرد کردن نهایی.',
          splitType: '3-Day Bodybuilding Split',
          isHomeWorkout: false,
          daysPerWeek: 3,
          difficulty: 'متوسط تخصصی',
          exercises: [
            // DAY 1: پا و شکم (شنبه)
            WorkoutPlanExercise(
                id: 'd1_1',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_squat',
                dayOfWeek: 1,
                dayNameFa: 'برنامه ۱: پا و شکم (Legs & Core)',
                orderInDay: 1,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 80,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd1_2',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_leg_press',
                dayOfWeek: 1,
                dayNameFa: 'برنامه ۱: پا و شکم (Legs & Core)',
                orderInDay: 2,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 140,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd1_3',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_rdl_db',
                dayOfWeek: 1,
                dayNameFa: 'برنامه ۱: پا و شکم (Legs & Core)',
                orderInDay: 3,
                targetSets: 3,
                targetReps: 8,
                targetWeightKg: 22,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd1_4',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_leg_extension',
                dayOfWeek: 1,
                dayNameFa: 'برنامه ۱: پا و شکم (Legs & Core)',
                orderInDay: 4,
                targetSets: 3,
                targetReps: 15,
                targetWeightKg: 45,
                restSeconds: 120),
            WorkoutPlanExercise(
                id: 'd1_5',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_lying_leg_curl',
                dayOfWeek: 1,
                dayNameFa: 'برنامه ۱: پا و شکم (Legs & Core)',
                orderInDay: 5,
                targetSets: 3,
                targetReps: 15,
                targetWeightKg: 35,
                restSeconds: 120),
            WorkoutPlanExercise(
                id: 'd1_6',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_hack_calf_raise',
                dayOfWeek: 1,
                dayNameFa: 'برنامه ۱: پا و شکم (Legs & Core)',
                orderInDay: 6,
                targetSets: 3,
                targetReps: 20,
                targetWeightKg: 60,
                restSeconds: 60),
            WorkoutPlanExercise(
                id: 'd1_7',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_plank',
                dayOfWeek: 1,
                dayNameFa: 'برنامه ۱: پا و شکم (Legs & Core)',
                orderInDay: 7,
                targetSets: 3,
                targetReps: 60,
                targetWeightKg: 0,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd1_8',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_incline_weighted_crunch',
                dayOfWeek: 1,
                dayNameFa: 'برنامه ۱: پا و شکم (Legs & Core)',
                orderInDay: 8,
                targetSets: 3,
                targetReps: 20,
                targetWeightKg: 10,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd1_9',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_incline_leg_raise',
                dayOfWeek: 1,
                dayNameFa: 'برنامه ۱: پا و شکم (Legs & Core)',
                orderInDay: 9,
                targetSets: 3,
                targetReps: 15,
                targetWeightKg: 0,
                restSeconds: 90),

            // DAY 2: سینه، بازو و فیله کمر (دوشنبه)
            WorkoutPlanExercise(
                id: 'd2_1',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_bench_press_pyramid',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 1,
                targetSets: 4,
                targetReps: 10,
                targetWeightKg: 80,
                restSeconds: 120),
            WorkoutPlanExercise(
                id: 'd2_2',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_cable_crossover',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 2,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 20,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd2_3',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_incline_db_press',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 3,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 24,
                restSeconds: 120),
            WorkoutPlanExercise(
                id: 'd2_4',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_pushups',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 4,
                targetSets: 3,
                targetReps: 15,
                targetWeightKg: 0,
                restSeconds: 120),
            WorkoutPlanExercise(
                id: 'd2_5',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_machine_chest_press',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 5,
                targetSets: 3,
                targetReps: 20,
                targetWeightKg: 50,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd2_6',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_cable_rope_biceps',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 6,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 22.5,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd2_7',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_cable_rope_triceps',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 7,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 25,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd2_8',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_ez_bar_curl',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 8,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 30,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd2_9',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_overhead_cable_triceps',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 9,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 20,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd2_10',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_alt_db_curl',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 10,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 14,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd2_11',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_two_arm_db_triceps',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 11,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 20,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd2_12',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_hyperextension',
                dayOfWeek: 2,
                dayNameFa: 'برنامه ۲: سینه، بازو و فیله کمر (Chest & Arms)',
                orderInDay: 12,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 0,
                restSeconds: 90),

            // DAY 3: زیربغل، سرشانه و کول، شکم (چهارشنبه)
            WorkoutPlanExercise(
                id: 'd3_1',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_chin_ups',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 1,
                targetSets: 3,
                targetReps: 8,
                targetWeightKg: 0,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd3_2',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_vbar_cable_row',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 2,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 50,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd3_3',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_lat_pulldown_front',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 3,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 55,
                restSeconds: 120),
            WorkoutPlanExercise(
                id: 'd3_4',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_tbar_row_wide',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 4,
                targetSets: 3,
                targetReps: 12,
                targetWeightKg: 40,
                restSeconds: 120),
            WorkoutPlanExercise(
                id: 'd3_5',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_wide_cable_row',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 5,
                targetSets: 3,
                targetReps: 20,
                targetWeightKg: 40,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd3_6',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_standing_overhead_press',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 6,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 40,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd3_7',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_seated_db_press',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 7,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 18,
                restSeconds: 120),
            WorkoutPlanExercise(
                id: 'd3_8',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_lateral_raise_db',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 8,
                targetSets: 3,
                targetReps: 10,
                targetWeightKg: 10,
                restSeconds: 120),
            WorkoutPlanExercise(
                id: 'd3_9',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_reverse_pec_deck',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 9,
                targetSets: 3,
                targetReps: 15,
                targetWeightKg: 35,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd3_10',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_barbell_shrugs',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 10,
                targetSets: 3,
                targetReps: 12,
                targetWeightKg: 60,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd3_11',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_incline_weighted_crunch',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 11,
                targetSets: 3,
                targetReps: 20,
                targetWeightKg: 10,
                restSeconds: 90),
            WorkoutPlanExercise(
                id: 'd3_12',
                planId: 'plan_armin_3day',
                exerciseId: 'ex_captains_chair_leg_raise',
                dayOfWeek: 3,
                dayNameFa: 'برنامه ۳: زیربغل، سرشانه و شکم (Back & Shoulders)',
                orderInDay: 12,
                targetSets: 3,
                targetReps: 15,
                targetWeightKg: 0,
                restSeconds: 90),
          ],
        ),
        WorkoutPlan(
          id: 'plan_home_bodyweight',
          titleFa: 'ورزش در خانه بدون وسیله (جایگزین فوری)',
          titleEn: 'Home Workout Beast Mode',
          descriptionFa:
              'برنامه پرفشار ۱۰۰٪ وزن بدن بدون نیاز به دمبل و دستگاه، مناسب روزهایی که به باشگاه نمی‌رسید.',
          splitType: 'Full Body Bodyweight',
          isHomeWorkout: true,
          daysPerWeek: 3,
          difficulty: 'همه سطوح',
          exercises: [
            WorkoutPlanExercise(
                id: 'h1',
                planId: 'plan_home_bodyweight',
                exerciseId: 'ex_pushups',
                dayOfWeek: 1,
                dayNameFa: 'تمرین فول‌بادی خانگی',
                orderInDay: 1,
                targetSets: 4,
                targetReps: 20,
                targetWeightKg: 0,
                restSeconds: 45),
            WorkoutPlanExercise(
                id: 'h2',
                planId: 'plan_home_bodyweight',
                exerciseId: 'ex_decline_pushups',
                dayOfWeek: 1,
                dayNameFa: 'تمرین فول‌بادی خانگی',
                orderInDay: 2,
                targetSets: 3,
                targetReps: 15,
                targetWeightKg: 0,
                restSeconds: 45),
            WorkoutPlanExercise(
                id: 'h3',
                planId: 'plan_home_bodyweight',
                exerciseId: 'ex_doorframe_row',
                dayOfWeek: 1,
                dayNameFa: 'تمرین فول‌بادی خانگی',
                orderInDay: 3,
                targetSets: 4,
                targetReps: 15,
                targetWeightKg: 0,
                restSeconds: 45),
            WorkoutPlanExercise(
                id: 'h4',
                planId: 'plan_home_bodyweight',
                exerciseId: 'ex_bulgarian_split_squat',
                dayOfWeek: 1,
                dayNameFa: 'تمرین فول‌بادی خانگی',
                orderInDay: 4,
                targetSets: 3,
                targetReps: 15,
                targetWeightKg: 0,
                restSeconds: 60),
            WorkoutPlanExercise(
                id: 'h5',
                planId: 'plan_home_bodyweight',
                exerciseId: 'ex_chair_dips',
                dayOfWeek: 1,
                dayNameFa: 'تمرین فول‌بادی خانگی',
                orderInDay: 5,
                targetSets: 3,
                targetReps: 18,
                targetWeightKg: 0,
                restSeconds: 45),
            WorkoutPlanExercise(
                id: 'h6',
                planId: 'plan_home_bodyweight',
                exerciseId: 'ex_jump_squats',
                dayOfWeek: 1,
                dayNameFa: 'تمرین فول‌بادی خانگی',
                orderInDay: 6,
                targetSets: 3,
                targetReps: 20,
                targetWeightKg: 0,
                restSeconds: 60),
          ],
        ),
      ];

  static List<Gym> get defaultGyms => [
        Gym(
          id: 'gym_oxin',
          name: 'مجموعه ورزشی اکسین سعادت‌آباد (Oxin VIP)',
          address: 'تهران، سعادت‌آباد، میدان کاج، بلوار سرو غربی',
          district: 'سعادت‌آباد (منطقه ۲)',
          latitude: 35.7820,
          longitude: 51.3750,
          monthlyFeeToman: 3200000,
          rating: 4.9,
          reviewCount: 142,
          amenities: [
            'کافه و شیک‌بار رژیمی',
            'استخر و سونای خشک',
            'باکس کراس‌فیت',
            'پارکینگ اختصاصی',
            'مربیگری حضوری'
          ],
        ),
        Gym(
          id: 'gym_palladium',
          name: 'باشگاه ورزشی پالادیوم زعفرانیه (Palladium)',
          address: 'تهران، زعفرانیه، خیابان مقدس اردبیلی، مرکز خرید پالادیوم',
          district: 'زعفرانیه (منطقه ۱)',
          latitude: 35.8050,
          longitude: 51.4180,
          monthlyFeeToman: 4800000,
          rating: 4.95,
          reviewCount: 210,
          amenities: [
            'ویو پانوراما تهران',
            'لاونج ریکاوری و ماساژ',
            'دستگاه‌های پیشرفته Technogym',
            'اسکن سه‌بعدی بدن',
            'رختکن VIP'
          ],
        ),
        Gym(
          id: 'gym_samfit',
          name: 'باشگاه تخصصی سام‌فیت شهرک غرب (Sam Fit)',
          address: 'تهران، شهرک غرب، بلوار دادمان، خیابان هرمزان',
          district: 'شهرک غرب (منطقه ۲)',
          latitude: 35.7650,
          longitude: 51.3620,
          monthlyFeeToman: 3600000,
          rating: 4.85,
          reviewCount: 98,
          amenities: [
            'مجهز به دمبل‌های کالیبره Eleiko',
            'سکوی وزنه‌برداری',
            'تردمیل‌های شیب‌دار اسکی',
            'شاور و لاکر اختصاصی'
          ],
        ),
      ];

  static List<Trainer> get defaultTrainers => [
        Trainer(
          id: 'trainer_arash',
          name: 'آرش رحمانی',
          title: 'مربی رسمی فدراسیون IFBB',
          specialty: 'متخصص بیومکانیک هایپرتروفی و افزایش حجم خالص',
          bio:
              'قهرمان اسبق فیزیک کشور با ۱۲ سال تجربه مربیگری اختصاصی و طراحی سیستم‌های پیشرفته تمرین و بازتوانی عضلانی.',
          hourlyRateToman: 450000,
          sessionType: 'Both',
          rating: 4.98,
          reviewCount: 85,
        ),
        Trainer(
          id: 'trainer_sara',
          name: 'سارا محمدی',
          title: 'کارشناس ارشد تغذیه ورزشی',
          specialty: 'رژیم‌های کاهش چربی و تناسب اندام',
          bio:
              'کارشناس ارشد تغذیه ورزشی از دانشگاه تهران، طراح برنامه‌های غذایی سفارشی کتوژنیک و کرب سایکلینگ.',
          hourlyRateToman: 380000,
          sessionType: 'Online',
          rating: 4.92,
          reviewCount: 110,
        ),
      ];

  static List<WeightRecord> get defaultWeightRecords {
    final now = DateTime.now();
    return [
      WeightRecord(
        id: 'w_init_1',
        date: now.subtract(const Duration(days: 110)),
        weightKg: 76.5,
        note: 'شروع دوره تمرینی و رژیم بازآرایی بدنی با جیم‌برو',
      ),
      WeightRecord(
        id: 'w_init_2',
        date: now.subtract(const Duration(days: 80)),
        weightKg: 75.2,
        note: 'پایان ماه اول، احساس سبکی و افزایش انرژی',
      ),
      WeightRecord(
        id: 'w_init_3',
        date: now.subtract(const Duration(days: 50)),
        weightKg: 74.0,
        note: 'کاهش سایز دور شکم و افزایش رکوردهای پرس',
      ),
      WeightRecord(
        id: 'w_init_4',
        date: now.subtract(const Duration(days: 28)),
        weightKg: 73.2,
        note: 'ثبت رکورد جدید در اسکوات',
      ),
      WeightRecord(
        id: 'w_init_5',
        date: now.subtract(const Duration(days: 14)),
        weightKg: 72.9,
        note: 'تثبیت در محدوده ۷۳ کیلوگرم',
      ),
      WeightRecord(
        id: 'w_init_6',
        date: now.subtract(const Duration(days: 1)),
        weightKg: 72.6,
        note: 'وزن‌کشی ناشتا بعد از تمرین سینه',
      ),
    ];
  }

  static List<BodyMeasurementRecord> get defaultBodyMeasurements {
    final now = DateTime.now();
    return [
      BodyMeasurementRecord(
        id: 'bm_init_1',
        date: now.subtract(const Duration(days: 110)),
        chestCm: 98.0,
        waistCm: 89.0,
        hipCm: 99.5,
        leftArmCm: 32.5,
        rightArmCm: 33.0,
        thighCm: 57.0,
        calfCm: 36.5,
        bodyFatPercentage: 29.5,
        note: 'سایزگیری اولیه قبل از شروع برنامه ۷۶۱',
      ),
      BodyMeasurementRecord(
        id: 'bm_init_2',
        date: now.subtract(const Duration(days: 50)),
        chestCm: 100.0,
        waistCm: 85.5,
        hipCm: 98.0,
        leftArmCm: 34.0,
        rightArmCm: 34.5,
        thighCm: 56.5,
        calfCm: 37.0,
        bodyFatPercentage: 28.1,
        note: 'اندازه‌گیری میان‌دوره (پیشرفت عالی در بازو و دور سینه)',
      ),
      BodyMeasurementRecord(
        id: 'bm_init_3',
        date: now.subtract(const Duration(days: 7)),
        chestCm: 102.0,
        waistCm: 83.0,
        hipCm: 97.0,
        leftArmCm: 35.0,
        rightArmCm: 35.5,
        thighCm: 56.0,
        calfCm: 37.0,
        bodyFatPercentage: 27.2,
        note: 'کاهش ۶ سانتی‌متری دور کمر و افزایش ۳ سانتی دور سینه!',
      ),
    ];
  }

  static List<QuickFoodTemplate> get defaultFavoriteFoods => [
        QuickFoodTemplate(
          id: 'food_fav_1',
          name: 'سینه مرغ گریل‌شده',
          defaultMealType: 'ناهار',
          calories: 165,
          proteinG: 31.0,
          carbsG: 0.0,
          fatG: 3.6,
          portionG: 100.0,
          category: 'پروتئین',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_2',
          name: 'تخم‌مرغ آب‌پز کامل (۲ عدد)',
          defaultMealType: 'صبحانه',
          calories: 155,
          proteinG: 13.0,
          carbsG: 1.1,
          fatG: 11.0,
          portionG: 100.0,
          category: 'پروتئین',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_3',
          name: 'برنج کته کم‌روغن',
          defaultMealType: 'ناهار',
          calories: 195,
          proteinG: 4.0,
          carbsG: 42.0,
          fatG: 1.0,
          portionG: 150.0,
          category: 'کربوهیدرات',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_4',
          name: 'اوتمیل جو دوسر با شیر کم‌چرب',
          defaultMealType: 'صبحانه',
          calories: 260,
          proteinG: 12.0,
          carbsG: 44.0,
          fatG: 5.0,
          portionG: 200.0,
          category: 'کربوهیدرات',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_5',
          name: 'پروتئین وی ایزوله (۱ اسکوپ)',
          defaultMealType: 'میان‌وعده',
          calories: 120,
          proteinG: 25.0,
          carbsG: 2.0,
          fatG: 1.0,
          portionG: 30.0,
          category: 'مکمل',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_6',
          name: 'فیله ماهی قزل‌آلا گریل',
          defaultMealType: 'شام',
          calories: 280,
          proteinG: 30.0,
          carbsG: 0.0,
          fatG: 16.0,
          portionG: 150.0,
          category: 'پروتئین',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_7',
          name: 'نان جو سبوس‌دار سنتی',
          defaultMealType: 'صبحانه',
          calories: 150,
          proteinG: 5.0,
          carbsG: 28.0,
          fatG: 2.0,
          portionG: 60.0,
          category: 'کربوهیدرات',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_8',
          name: 'ماست یونانی پرپروتئین',
          defaultMealType: 'میان‌وعده',
          calories: 110,
          proteinG: 15.0,
          carbsG: 6.0,
          fatG: 2.0,
          portionG: 150.0,
          category: 'لبنیات',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_9',
          name: 'بادام درختی خام',
          defaultMealType: 'میان‌وعده',
          calories: 175,
          proteinG: 6.0,
          carbsG: 6.0,
          fatG: 15.0,
          portionG: 30.0,
          category: 'چربی‌های سالم',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_10',
          name: 'سیب درختی و کره بادام‌زمینی',
          defaultMealType: 'میان‌وعده',
          calories: 190,
          proteinG: 4.5,
          carbsG: 25.0,
          fatG: 8.5,
          portionG: 160.0,
          category: 'سبزیجات و میوه',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_11',
          name: 'سالاد فصل با روغن زیتون فرابکر',
          defaultMealType: 'شام',
          calories: 85,
          proteinG: 2.0,
          carbsG: 7.0,
          fatG: 5.5,
          portionG: 180.0,
          category: 'سبزیجات و میوه',
          isFavorite: true,
        ),
        QuickFoodTemplate(
          id: 'food_fav_12',
          name: 'عدسی کم‌روغن با آبلیمو',
          defaultMealType: 'صبحانه',
          calories: 230,
          proteinG: 16.0,
          carbsG: 38.0,
          fatG: 2.0,
          portionG: 250.0,
          category: 'پروتئین',
          isFavorite: true,
        ),
      ];

  static List<CalorieScanLog> get defaultCalorieLogs {
    final now = DateTime.now();
    final todayStr = PersianUtils.toDateString(now);
    final y1Str = PersianUtils.toDateString(now.subtract(const Duration(days: 1)));
    final y2Str = PersianUtils.toDateString(now.subtract(const Duration(days: 2)));
    final y3Str = PersianUtils.toDateString(now.subtract(const Duration(days: 3)));
    final y4Str = PersianUtils.toDateString(now.subtract(const Duration(days: 4)));
    final y5Str = PersianUtils.toDateString(now.subtract(const Duration(days: 5)));
    final y6Str = PersianUtils.toDateString(now.subtract(const Duration(days: 6)));

    return [
      // TODAY
      CalorieScanLog(
        id: 'seed_cal_t1',
        foodName: 'املت ۳ سفیده و ۱ تخم‌مرغ کامل با نان جو',
        mealType: 'صبحانه',
        calories: 320,
        proteinG: 26.0,
        carbsG: 28.0,
        fatG: 9.0,
        portionG: 220.0,
        isAiScanned: true,
        dateString: todayStr,
        timestamp: now.subtract(const Duration(hours: 7)).millisecondsSinceEpoch,
        note: 'صبحانه قبل تمرین',
      ),
      CalorieScanLog(
        id: 'seed_cal_t2',
        foodName: 'سینه مرغ گریل با کته زعفرانی و سبزیجات بخارپز',
        mealType: 'ناهار',
        calories: 580,
        proteinG: 52.0,
        carbsG: 62.0,
        fatG: 11.0,
        portionG: 380.0,
        isAiScanned: false,
        dateString: todayStr,
        timestamp: now.subtract(const Duration(hours: 3)).millisecondsSinceEpoch,
        note: 'ناهار رژیمی با روغن زیتون محدود',
      ),
      CalorieScanLog(
        id: 'seed_cal_t3',
        foodName: 'پروتئین وی + سیب و ۱۰ عدد بادام درختی',
        mealType: 'میان‌وعده',
        calories: 290,
        proteinG: 28.0,
        carbsG: 26.0,
        fatG: 7.0,
        portionG: 190.0,
        isAiScanned: false,
        dateString: todayStr,
        timestamp: now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      ),

      // YESTERDAY (y1)
      CalorieScanLog(
        id: 'seed_cal_y1_1',
        foodName: 'اوتمیل جو دوسر، شیر و کره بادام‌زمینی',
        mealType: 'صبحانه',
        calories: 420,
        proteinG: 20.0,
        carbsG: 54.0,
        fatG: 13.0,
        portionG: 250.0,
        isAiScanned: true,
        dateString: y1Str,
        timestamp: now.subtract(const Duration(days: 1, hours: 8)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y1_2',
        foodName: 'خوراک لوبیا چیتی با فیله گوشت راسته گوساله',
        mealType: 'ناهار',
        calories: 640,
        proteinG: 54.0,
        carbsG: 68.0,
        fatG: 14.0,
        portionG: 400.0,
        isAiScanned: false,
        dateString: y1Str,
        timestamp: now.subtract(const Duration(days: 1, hours: 4)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y1_3',
        foodName: 'شیک پروتئین وی و موز',
        mealType: 'میان‌وعده',
        calories: 230,
        proteinG: 27.0,
        carbsG: 28.0,
        fatG: 2.0,
        portionG: 300.0,
        isAiScanned: false,
        dateString: y1Str,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y1_4',
        foodName: 'فیله سالمون تنوری با سالاد کلم بروکلی',
        mealType: 'شام',
        calories: 520,
        proteinG: 44.0,
        carbsG: 14.0,
        fatG: 28.0,
        portionG: 320.0,
        isAiScanned: false,
        dateString: y1Str,
        timestamp: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      ),

      // DAY 2 AGO
      CalorieScanLog(
        id: 'seed_cal_y2_1',
        foodName: 'تخم‌مرغ آب‌پز + پنیر کم‌چرب و نان سنگک',
        mealType: 'صبحانه',
        calories: 450,
        proteinG: 28.0,
        carbsG: 45.0,
        fatG: 16.0,
        portionG: 240.0,
        isAiScanned: false,
        dateString: y2Str,
        timestamp: now.subtract(const Duration(days: 2, hours: 8)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y2_2',
        foodName: 'چلو جوجه‌کباب سینه بدون کره با سالاد شیرازی',
        mealType: 'ناهار',
        calories: 710,
        proteinG: 58.0,
        carbsG: 72.0,
        fatG: 18.0,
        portionG: 420.0,
        isAiScanned: true,
        dateString: y2Str,
        timestamp: now.subtract(const Duration(days: 2, hours: 4)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y2_3',
        foodName: 'ماست ایسلندی و گردو',
        mealType: 'میان‌وعده',
        calories: 220,
        proteinG: 20.0,
        carbsG: 8.0,
        fatG: 12.0,
        portionG: 200.0,
        isAiScanned: false,
        dateString: y2Str,
        timestamp: now.subtract(const Duration(days: 2, hours: 2)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y2_4',
        foodName: 'سینه بوقلمون تفت داده با قارچ و فلفل دلمه‌ای',
        mealType: 'شام',
        calories: 460,
        proteinG: 48.0,
        carbsG: 12.0,
        fatG: 16.0,
        portionG: 300.0,
        isAiScanned: false,
        dateString: y2Str,
        timestamp: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      ),

      // DAY 3 AGO
      CalorieScanLog(
        id: 'seed_cal_y3_1',
        foodName: 'اوتمیل پروتئینی توت‌فرنگی',
        mealType: 'صبحانه',
        calories: 390,
        proteinG: 26.0,
        carbsG: 50.0,
        fatG: 8.0,
        portionG: 250.0,
        isAiScanned: false,
        dateString: y3Str,
        timestamp: now.subtract(const Duration(days: 3, hours: 8)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y3_2',
        foodName: 'تن ماهی فلفلی آب‌پز با سیب‌زمینی تنوری',
        mealType: 'ناهار',
        calories: 620,
        proteinG: 50.0,
        carbsG: 64.0,
        fatG: 12.0,
        portionG: 360.0,
        isAiScanned: false,
        dateString: y3Str,
        timestamp: now.subtract(const Duration(days: 3, hours: 4)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y3_3',
        foodName: 'سینه مرغ گریل و هویج پخته',
        mealType: 'شام',
        calories: 480,
        proteinG: 46.0,
        carbsG: 22.0,
        fatG: 14.0,
        portionG: 320.0,
        isAiScanned: false,
        dateString: y3Str,
        timestamp: now.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
      ),

      // DAY 4 AGO
      CalorieScanLog(
        id: 'seed_cal_y4_1',
        foodName: 'املت قارچ و گوجه با نان بربری سبوس‌دار',
        mealType: 'صبحانه',
        calories: 410,
        proteinG: 22.0,
        carbsG: 48.0,
        fatG: 12.0,
        portionG: 260.0,
        isAiScanned: false,
        dateString: y4Str,
        timestamp: now.subtract(const Duration(days: 4, hours: 8)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y4_2',
        foodName: 'ماکارونی سبوس‌دار با گوشت چرخ‌کرده کم‌چرب',
        mealType: 'ناهار',
        calories: 690,
        proteinG: 48.0,
        carbsG: 82.0,
        fatG: 16.0,
        portionG: 400.0,
        isAiScanned: true,
        dateString: y4Str,
        timestamp: now.subtract(const Duration(days: 4, hours: 4)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y4_3',
        foodName: 'سالاد سزار رژیمی بدون سس مایونز',
        mealType: 'شام',
        calories: 430,
        proteinG: 40.0,
        carbsG: 16.0,
        fatG: 18.0,
        portionG: 340.0,
        isAiScanned: false,
        dateString: y4Str,
        timestamp: now.subtract(const Duration(days: 4)).millisecondsSinceEpoch,
      ),

      // DAY 5 AGO
      CalorieScanLog(
        id: 'seed_cal_y5_1',
        foodName: 'عدسی سنتی با لیمو ترش و نان جو',
        mealType: 'صبحانه',
        calories: 380,
        proteinG: 24.0,
        carbsG: 52.0,
        fatG: 6.0,
        portionG: 300.0,
        isAiScanned: false,
        dateString: y5Str,
        timestamp: now.subtract(const Duration(days: 5, hours: 8)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y5_2',
        foodName: 'فیله مرغ و برنج قهوه‌ای و زیتون پرورده رژیمی',
        mealType: 'ناهار',
        calories: 630,
        proteinG: 55.0,
        carbsG: 65.0,
        fatG: 14.0,
        portionG: 380.0,
        isAiScanned: false,
        dateString: y5Str,
        timestamp: now.subtract(const Duration(days: 5, hours: 4)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y5_3',
        foodName: 'سفیده تخم‌مرغ با سیب‌زمینی آب‌پز',
        mealType: 'شام',
        calories: 390,
        proteinG: 36.0,
        carbsG: 42.0,
        fatG: 5.0,
        portionG: 280.0,
        isAiScanned: false,
        dateString: y5Str,
        timestamp: now.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
      ),

      // DAY 6 AGO
      CalorieScanLog(
        id: 'seed_cal_y6_1',
        foodName: 'پنکیک پروتئینی خانگی با عسل طبیعی',
        mealType: 'صبحانه',
        calories: 440,
        proteinG: 30.0,
        carbsG: 56.0,
        fatG: 9.0,
        portionG: 240.0,
        isAiScanned: false,
        dateString: y6Str,
        timestamp: now.subtract(const Duration(days: 6, hours: 8)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y6_2',
        foodName: 'کباب تابه‌ای راسته گوسفندی کم‌چرب با کته',
        mealType: 'ناهار',
        calories: 680,
        proteinG: 52.0,
        carbsG: 60.0,
        fatG: 22.0,
        portionG: 390.0,
        isAiScanned: true,
        dateString: y6Str,
        timestamp: now.subtract(const Duration(days: 6, hours: 4)).millisecondsSinceEpoch,
      ),
      CalorieScanLog(
        id: 'seed_cal_y6_3',
        foodName: 'خوراک سبزیجات و لوبیا سبز با فیله بوقلمون',
        mealType: 'شام',
        calories: 470,
        proteinG: 45.0,
        carbsG: 26.0,
        fatG: 13.0,
        portionG: 320.0,
        isAiScanned: false,
        dateString: y6Str,
        timestamp: now.subtract(const Duration(days: 6)).millisecondsSinceEpoch,
      ),
    ];
  }

  static List<WaterLog> get defaultWaterLogs {
    final now = DateTime.now();
    return [
      // Today
      WaterLog(
        id: 'water_today_1',
        dateString: PersianUtils.toDateString(now),
        amountMl: 500,
        timestamp: now.subtract(const Duration(hours: 6)).millisecondsSinceEpoch,
      ),
      WaterLog(
        id: 'water_today_2',
        dateString: PersianUtils.toDateString(now),
        amountMl: 750,
        timestamp: now.subtract(const Duration(hours: 4)).millisecondsSinceEpoch,
      ),
      WaterLog(
        id: 'water_today_3',
        dateString: PersianUtils.toDateString(now),
        amountMl: 500,
        timestamp: now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      ),
      // Past days
      WaterLog(
        id: 'water_y1',
        dateString: PersianUtils.toDateString(now.subtract(const Duration(days: 1))),
        amountMl: 3000,
        timestamp: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      ),
      WaterLog(
        id: 'water_y2',
        dateString: PersianUtils.toDateString(now.subtract(const Duration(days: 2))),
        amountMl: 2750,
        timestamp: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      ),
      WaterLog(
        id: 'water_y3',
        dateString: PersianUtils.toDateString(now.subtract(const Duration(days: 3))),
        amountMl: 3250,
        timestamp: now.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
      ),
      WaterLog(
        id: 'water_y4',
        dateString: PersianUtils.toDateString(now.subtract(const Duration(days: 4))),
        amountMl: 2500,
        timestamp: now.subtract(const Duration(days: 4)).millisecondsSinceEpoch,
      ),
      WaterLog(
        id: 'water_y5',
        dateString: PersianUtils.toDateString(now.subtract(const Duration(days: 5))),
        amountMl: 2800,
        timestamp: now.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
      ),
      WaterLog(
        id: 'water_y6',
        dateString: PersianUtils.toDateString(now.subtract(const Duration(days: 6))),
        amountMl: 3100,
        timestamp: now.subtract(const Duration(days: 6)).millisecondsSinceEpoch,
      ),
    ];
  }

  // ================= OPEN GYM CATALOGUE IMPORT PIPELINE =================

  /// Maps openGym body parts to standard Persian terminology.
  static const Map<String, String> openGymBodyPartTranslations = {
    'back': 'پشت و زیربغل',
    'cardio': 'قلبی و عروقی',
    'chest': 'سینه',
    'lower arms': 'ساعد و مچ دست',
    'lower legs': 'ساق پا',
    'neck': 'گردن',
    'shoulders': 'سرشانه و دلتوئید',
    'upper arms': 'بازو (جلو و پشت بازو)',
    'upper legs': 'ران و سرینی',
    'waist': 'شکم، پهلو و فیله کمر',
    'full body': 'تمام بدن',
  };

  /// Maps openGym target muscles to Persian names.
  static const Map<String, String> openGymTargetMuscleTranslations = {
    'abs': 'راست شکمی',
    'pectorals': 'سینه',
    'biceps': 'جلو بازو',
    'glutes': 'سرینی و باسن',
    'front delts': 'بخش جلویی سرشانه',
    'side delts': 'بخش میانی سرشانه',
    'rear delts': 'بخش پشتی سرشانه',
    'delts': 'سرشانه',
    'triceps': 'پشت بازو',
    'upper back': 'بخش بالایی پشت',
    'lats': 'زیربغل (پشتی بزرگ)',
    'calves': 'ساق پا',
    'quads': 'چهارسر ران',
    'forearms': 'ساعد',
    'cardiovascular system': 'سیستم قلبی عروقی',
    'hamstrings': 'همسترینگ (پشت پا)',
    'spine': 'ستون فقرات و فیله کمر',
    'traps': 'کول و ذوزنقه‌ای',
    'adductors': 'نزدیک‌کننده ران (داخل پا)',
    'serratus anterior': 'دندانه‌ای قدامی',
    'abductors': 'دورکننده ران (خارج پا)',
    'levator scapulae': 'بالابرنده کتف',
    'obliques': 'مورب شکمی (پهلو)',
    'hip flexors': 'خم‌کننده لگن',
    'shins': 'درشت‌نی و جلوی ساق',
  };

  /// Maps openGym equipment to standard GymBro equipment and Persian labels.
  static const Map<String, Map<String, String>> openGymEquipmentMappings = {
    'body weight': {'gymbro': 'Bodyweight', 'fa': 'وزن بدن'},
    'dumbbell': {'gymbro': 'Dumbbell', 'fa': 'دمبل'},
    'barbell': {'gymbro': 'Barbell', 'fa': 'هالتر'},
    'cable': {'gymbro': 'Cable', 'fa': 'سیم‌کش'},
    'leverage machine': {'gymbro': 'Machine', 'fa': 'دستگاه اهرمی'},
    'smith machine': {'gymbro': 'Machine', 'fa': 'دستگاه اسمیت'},
    'sled machine': {'gymbro': 'Machine', 'fa': 'دستگاه سورتمه'},
    'band': {'gymbro': 'Bands', 'fa': 'کش تمرینی'},
    'resistance band': {'gymbro': 'Bands', 'fa': 'کش مقاومتی'},
    'kettlebell': {'gymbro': 'Kettlebell', 'fa': 'کتل‌بل'},
    'weighted': {'gymbro': 'Free Weight', 'fa': 'وزنه آزاد'},
    'ez barbell': {'gymbro': 'Barbell', 'fa': 'هالتر EZ'},
    'olympic barbell': {'gymbro': 'Barbell', 'fa': 'هالتر المپیک'},
    'weight plate': {'gymbro': 'Free Weight', 'fa': 'صفحه وزنه'},
    'wheel roller': {'gymbro': 'Roller', 'fa': 'رولر شکم'},
    'stability ball': {'gymbro': 'Ball', 'fa': 'توپ تعادل'},
    'medicine ball': {'gymbro': 'Ball', 'fa': 'مدیسن بال'},
    'bench': {'gymbro': 'Bench', 'fa': 'نیمکت'},
    'pull-up bar': {'gymbro': 'Bar', 'fa': 'میله بارفیکس'},
  };

  /// Normalizes an exercise name for duplicate detection.
  static String normalizeExerciseName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }

  /// Converts an openGym ExerciseModel to GymBro's internal Exercise entity.
  static Exercise convertOpenGymExercise(
    ExerciseModel openGym, {
    String? nameFa,
    String? instructionsFa,
  }) {
    final eqMapping = openGymEquipmentMappings[openGym.equipment.toLowerCase().trim()];
    final standardEquipment = eqMapping?['gymbro'] ?? (openGym.equipment.isNotEmpty ? openGym.equipment : 'Other');
    final standardEquipmentFa = eqMapping?['fa'] ?? standardEquipment;

    final muscleFa = openGymTargetMuscleTranslations[openGym.target.toLowerCase().trim()] ??
        openGymBodyPartTranslations[openGym.bodyPart.toLowerCase().trim()] ??
        openGym.bodyPart;

    final resolvedInstructionsFa = instructionsFa != null && instructionsFa.trim().isNotEmpty
        ? instructionsFa.trim()
        : (openGym.instructions.isNotEmpty
            ? openGym.instructions.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')
            : openGym.description);

    final isBodyweight = openGym.equipment.toLowerCase().contains('body weight') ||
        openGym.category == 'calisthenics';

    return Exercise(
      id: 'opengym_${openGym.id}',
      nameEn: openGym.name,
      nameFa: nameFa != null && nameFa.trim().isNotEmpty ? nameFa.trim() : openGym.name,
      muscleGroup: openGym.bodyPart,
      muscleGroupFa: muscleFa,
      equipment: standardEquipment,
      equipmentFa: standardEquipmentFa,
      instructionsFa: resolvedInstructionsFa,
      isBodyweight: isBodyweight,
      secondaryMuscles: openGym.secondaryMuscles.isNotEmpty ? openGym.secondaryMuscles : null,
      targetMuscle: openGym.target.isNotEmpty ? openGym.target : null,
    );
  }

  /// Merges a catalogue of openGym exercises into existing GymBro exercises
  /// without producing duplicate movements.
  static List<Exercise> mergeOpenGymCatalogue({
    required List<Exercise> existingExercises,
    required List<ExerciseModel> openGymCatalogue,
    Map<String, Map<String, Object?>>? faTranslations,
  }) {
    final merged = List<Exercise>.from(existingExercises);
    final existingNormalizedNames = existingExercises.map((e) => normalizeExerciseName(e.nameEn)).toSet();
    final existingIds = existingExercises.map((e) => e.id).toSet();

    for (final openGymEx in openGymCatalogue) {
      final normalized = normalizeExerciseName(openGymEx.name);

      // Check for duplicate by normalized name or ID
      if (existingNormalizedNames.contains(normalized)) {
        continue;
      }
      final newId = 'opengym_${openGymEx.id}';
      if (existingIds.contains(newId)) {
        continue;
      }

      // Check if Persian translation is available
      final trans = faTranslations?[openGymEx.id];
      final nameFa = trans?['name'] as String?;
      final instructionsList = trans?['instructions'] as List<Object?>?;
      final instructionsFa = instructionsList?.map((e) => e.toString()).join('\n');

      final converted = convertOpenGymExercise(
        openGymEx,
        nameFa: nameFa,
        instructionsFa: instructionsFa,
      );

      merged.add(converted);
      existingNormalizedNames.add(normalized);
      existingIds.add(newId);
    }

    return merged;
  }

  /// Filters exercises based on the user's available equipment set.
  static List<Exercise> filterByAvailableEquipment({
    required List<Exercise> exercises,
    required Set<String> availableEquipment,
  }) {
    if (availableEquipment.isEmpty) return exercises;

    final normalizedSet = availableEquipment.map((e) => e.trim().toLowerCase()).toSet();

    return exercises.where((ex) {
      if (ex.isBodyweight) return true;

      final eq = ex.equipment.toLowerCase().trim();
      final eqFa = ex.equipmentFa.toLowerCase().trim();

      return normalizedSet.any((avail) =>
          avail == eq ||
          avail == eqFa ||
          eq.contains(avail) ||
          avail.contains(eq));
    }).toList();
  }

  /// Performs bilingual parallel search on exercises (matching Persian or English).
  static List<Exercise> searchExercises({
    required List<Exercise> exercises,
    required String query,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return exercises;

    return exercises.where((ex) {
      final nameFa = ex.nameFa.toLowerCase();
      final nameEn = ex.nameEn.toLowerCase();
      final muscleFa = ex.muscleGroupFa.toLowerCase();
      final muscleEn = ex.muscleGroup.toLowerCase();
      final equipFa = ex.equipmentFa.toLowerCase();
      final equipEn = ex.equipment.toLowerCase();
      final target = (ex.targetMuscle ?? '').toLowerCase();

      return nameFa.contains(cleanQuery) ||
          nameEn.contains(cleanQuery) ||
          muscleFa.contains(cleanQuery) ||
          muscleEn.contains(cleanQuery) ||
          equipFa.contains(cleanQuery) ||
          equipEn.contains(cleanQuery) ||
          target.contains(cleanQuery);
    }).toList();
  }
}
