# 01 — PROJECT OVERVIEW & ARCHITECTURE BLUEPRINT

## ۱. هویت و ماموریت GymBro (Product Vision)
- **نام برنامه:** جیم‌برو (GymBro)
- **نوع محصول:** اپلیکیشن مدرن، بومی و حرفه‌ای فیتنس و مدیریت تمرینات ورزشی (Personal Workout & Nutrition Companion).
- **فلسفه طراحی:** «Human-crafted Athletic Technology»
  - رد قاطع طراحی‌های پیش‌پاافتاده و شابلونی هوش مصنوعی (Anti-Generic Flutter Template).
  - تمرکز بر سهولت استفاده با یک دست در حین تمرین واقعی زیر وزنه.
  - تعادل میان هویت جسورانه ورزشی و طراحی مینیمال و خوانا.
- **کاراکتر برند (Brand Mascot):** «کلم جیم‌برو» (Cabbage Mascot) به عنوان المان بامزه، باهویت و مشوق در لحظات پیروزی، شکستن رکورد، و صفحات خالی (نه به عنوان انیمیشن مداوم و خسته‌کننده لودینگ).
- **محیط و جهت:** ۱۰۰٪ سازگار با راست‌چین (RTL)، زبان فارسی، فونت **وزیرمتن (Vazirmatn)** و ارقام فارسی/تبولار.

---

## ۲. مشخصات فنی (Tech Stack & Environment)
- **فریم‌ورک اصلی:** Flutter (اندروید، iOS، وب و دسکتاپ).
- **زبان:** Dart 3+ با رعایت کامل Type-Safety و حذف `dynamic`های بیهوده.
- **معماری وضعیت (State Management):** معماری تمیز تک‌منبعی `AppState` با استفاده از `ChangeNotifier` (برنامه نیاز به شلوغ‌کاری و وابستگی‌های اضافی مثل Riverpod یا Bloc ندارد).
- **پایداری محلی (Persistence):** `LocalStorageService` بر بستر `SharedPreferences` با همگام‌سازی بلادرنگ و قابلیت Seeding آفلاین اولیه (`DatabaseSeeder`).
- **کیفیت کد (Code Quality):**
  - **Dart Analyzer:** صفر خطا و هشدار (`flutter analyze` کاملاً Clean).
  - **آزمون‌های خودکار:** **۲۲۷ از ۲۲۷ تست با موفقیت ۱۰۰٪ پاس شده‌اند**.
  - **سازگاری اندازه‌ها:** تضمین عدم Overflow روی کوچک‌ترین صفحه (320x640)، تبلت و مقیاس فونت بزرگ ۲.۰x.
  - **استاندارد دسترسی‌پذیری:** تطابق کامل با WCAG 2.2 AA (کنتراست $\ge 4.5:1$ و تاچ‌تارگت $\ge 48\text{dp}$).

---

## ۳. نقشه درختی پوشه‌ها (Folder Structure)

```text
c:\Users\Armin\Desktop\GymBro\
├── ai_context/                        # بسته کامل شناختی برای هوش مصنوعی (این پوشه)
│   ├── README.md
│   ├── 01_PROJECT_OVERVIEW.md
│   ├── 02_DESIGN_SYSTEM_&_RULES.md
│   ├── 03_DATA_MODELS_&_STATE.md
│   ├── 04_SCREENS_&_USER_JOURNEYS.md
│   ├── 05_CORE_ALGORITHMS.md
│   └── 06_QA_&_TESTING_STANDARDS.md
├── lib/
│   ├── core/
│   │   ├── algorithms/                # محاسبات خالص دارت بدون وابستگی به فلاتر (BMR, 1RM, Macros)
│   │   │   └── fitness_calculator.dart
│   │   ├── graphics/                  # لوگوها و نگاره‌های وکتوری سفارشی
│   │   ├── localization/              # فرمت‌بندی اعداد فارسی، تاریخ شمسی، تومان و کالری
│   │   │   └── persian_utils.dart
│   │   ├── storage/                   # لایه ذخیره‌سازی محلی و دیتای پیش‌فرض
│   │   │   ├── database_seeder.dart
│   │   │   └── local_storage_service.dart
│   │   └── theme/                     # پالت رنگی، فواصل فضایی ۴/۸، ردیوس‌ها و تایپوگرافی
│   │       ├── app_colors.dart
│   │       ├── app_theme.dart
│   │       ├── app_tokens.dart
│   │       └── app_typography.dart
│   ├── models/                        # مدل‌های داده ناب (WorkoutPlan, Exercise, CalorieLog, ...)
│   ├── screens/                       # ۵ صفحه اصلی + صفحات دیالوگ و تنظیمات
│   │   ├── dashboard_screen.dart
│   │   ├── workout_screen.dart
│   │   ├── active_workout_screen.dart
│   │   ├── nutrition_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── marketplace_screen.dart
│   │   └── ...
│   ├── state/
│   │   └── app_state.dart             # هاب مرکزی کنترل داده‌های برنامه
│   └── widgets/                       # کامپوننت‌های سیستم طراحی (دکمه‌ها، کارت‌ها، اینپوت‌ها)
│       └── common/
│           ├── gymbro_buttons.dart
│           ├── gymbro_cards.dart
│           ├── gymbro_design_system.dart
│           ├── gymbro_inputs.dart
│           └── gymbro_section_header.dart
└── test/                              # ۲۲۷ تست جامع واحد، ویجت، ریسپانسیو و دسترسی‌پذیری
```

---

## ۴. تعاریف و مرزهای عملیاتی (Boundaries & Real vs Demo)
1. **عملیات واقعی در اپلیکیشن:**
   - ثبت ست‌های تمرینی، وزنه و تکرار.
   - تایمر هوشمند استراحت با کنترل پس‌زمینه/پیش‌زمینه.
   - ثبت غذا، کالری و آب در یک منبع حقیقت مشترک.
   - ذخیره سوابق وزنی و رسم نمودارهای واقعی.
2. **سرویس‌های دمو و مرزبندی‌شده (Mocked Services):**
   - اسکن با دوربین غذا (تشخیص هوش مصنوعی) به عنوان شبیه‌سازی مشخص شده است.
   - درگاه پرداخت مربیان در مارکت‌پلیس جنبه نمایشی و شبیه‌سازی دارد و تراکنش مالی واقعی انجام نمی‌دهد.
   - چت هوش مصنوعی مربی ورزشی به کلید API واقعی نیازمند است و در صورت عدم وجود، پاسخ‌های ساختارمند کمکی ارائه می‌دهد.
