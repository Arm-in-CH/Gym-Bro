---
name: gymbro-flutter-ui
description: >
  Use this skill for ANY Flutter UI task in the GymBro project — building screens,
  widgets, layouts, animations, or modifying existing UI code. Triggers on: "یه صفحه
  بساز", "ویجت بنویس", "UI این رو درست کن", "کامپوننت", "screen", "widget", "layout",
  "dialog", "bottom sheet", "card", "داشبورد", "فرم", "modal", or any request to
  add/change/fix visual elements in the app. Always use this skill when writing
  Flutter/Dart UI code for GymBro — never freestyle without it.
---

# GymBro Flutter UI Skill

تو یه Flutter engineer باتجربه‌ای که روی GymBro کار می‌کنی — یه اپ فیتنس فارسی با
سیستم طراحی اختصاصی و فلسفه Anti-Generic. هر خطی که می‌نویسی باید با این سیستم
هم‌راستا باشه.

---

## ۱. قوانین سخت (هرگز نقض نشود)

```
✗ هرگز رنگ hardcode نکن — نه #C9F36A، نه Colors.white، نه هیچ hex
✓ همیشه: context.appTokens.primaryLime / context.appColors.background

✗ هرگز Container خام با decoration برای کارت نساز
✓ همیشه: GymBroCard / GymBroElevatedCard / GymBroHeroCard

✗ هرگز SizedBox(height: 20) یا Padding(EdgeInsets.all(15))
✓ همیشه: SizedBox(height: AppSpacing.lg) / Padding(EdgeInsets.all(AppSpacing.base))

✗ هرگز TextButton / ElevatedButton خام
✓ همیشه: GymBroPrimaryButton / GymBroSecondaryButton / GymBroGhostButton

✗ هرگز Text('۱۲۳') مستقیم برای اعداد متغیر
✓ همیشه: Text(PersianUtils.toPersianDigits('123'))

✗ هرگز FontWeight.w900 برای هیچ عنوانی
✓ حداکثر: FontWeight.w700 برای عناوین اصلی

✗ هرگز Colors.black یا #000000
✓ کمترین تیرگی: context.appTokens.background (#0B0E13)
```

---

## ۲. توکن‌های رنگی (مرجع سریع)

| نام | Hex | نقش |
|-----|-----|-----|
| background | `#0B0E13` | بوم اصلی |
| backgroundSecondary | `#111720` | نوار پایین / هدر |
| surface | `#171D27` | کارت پایه |
| surfaceElevated | `#202A37` | مودال / دیالوگ |
| border | `#2C384A` | خط مرزی 1.2px |
| primaryLime | `#C9F36A` | CTA اصلی — فقط برای مهم‌ترین اکشن |
| warmAmber | `#FFB86B` | امتیاز / سکه / PR |
| softCyan | `#78CFE0` | هیدراتاسیون / فنی |
| error | `#FF6B70` | خطا / هشدار |
| textPrimary | `#F4F6F8` | متن اصلی |
| textSecondary | `#A7AFBD` | متن فرعی |
| textMuted | `#8F9BAA` | متادیتا / غیرفعال |

**قانون lime:** فقط یک CTA اصلی در هر صفحه می‌تواند lime باشد. بقیه secondary/outline.

---

## ۳. فاصله‌گذاری (Spacing Grid)

```dart
AppSpacing.xs   = 4.0   // فاصله داخل کامپوننت‌های فشرده
AppSpacing.sm   = 8.0   // فاصله بین المان‌های مرتبط
AppSpacing.md   = 12.0  // padding داخلی کارت‌های کوچک
AppSpacing.base = 16.0  // padding اصلی صفحه / کارت
AppSpacing.lg   = 24.0  // فاصله بین section‌ها
AppSpacing.xl   = 32.0  // فاصله بزرگ / hero padding
AppSpacing.minTouchTarget = 48.0  // حداقل اندازه هر المان تعاملی
```

---

## ۴. ویجت‌های موجود (قبل از ساختن، اینجا چک کن)

### دکمه‌ها
```dart
GymBroPrimaryButton(label: 'شروع تمرین', onPressed: () {})
GymBroSecondaryButton(label: 'ویرایش', onPressed: () {})
GymBroOutlineButton(label: 'لغو', onPressed: () {})
GymBroGhostButton(label: 'بعداً', onPressed: () {})
GymBroIconButton(icon: GymBroIcons.plus, tooltip: 'افزودن', onPressed: () {})
GymBroPillFilter(label: 'سینه', isActive: true, onTap: () {})
```

### کارت‌ها
```dart
GymBroCard(child: ...)                    // کارت پایه #171D27
GymBroElevatedCard(child: ...)            // کارت برجسته #202A37
GymBroMetricCard(                         // عدد + دلتا + واحد
  value: '۸۵',
  unit: 'کیلوگرم',
  delta: '+۲.۵',
  deltaPositive: true,
)
GymBroHeroCard(                           // بنر gradient ورزشی
  title: 'تمرین امروز',
  subtitle: 'پرس سینه + شانه',
  child: ...,
)
GymBroSectionHeader(                      // هدر یکپارچه section
  title: 'برنامه‌های من',
  subtitle: '۳ برنامه فعال',
  actionLabel: 'مشاهده همه',
  onAction: () {},
)
```

### ورودی
```dart
GymBroTextField(
  label: 'وزن (کیلوگرم)',
  hint: 'مثلاً ۸۵',
  keyboardType: TextInputType.number,
  onChanged: (v) {},
)
```

---

## ۵. الگوهای RTL فارسی

```dart
// همیشه Directionality مشخص باشد
Directionality(
  textDirection: TextDirection.rtl,
  child: ...,
)

// اعداد تبولار (تایمر، ست، تکرار، وزن)
Text(
  PersianUtils.toPersianDigits(value.toString()),
  style: AppTypography.tabularNumbers, // layout نمی‌لرزد
)

// تاریخ شمسی
Text(PersianUtils.formatJalaliDate(DateTime.now()))

// واحد تومان
Text(PersianUtils.formatToman(price))
```

---

## ۶. انیمیشن — قوانین استفاده

```
✓ یک لحظه orchestrated در page load (نه هر section جداگانه)
✓ انیمیشن پاسخ به action کاربر (تایید ست، باز شدن دیالوگ)
✓ تایمر countdown با AnimatedSwitcher برای اعداد
✗ fade-and-slide-up روی هر card — ممنوع
✗ hover animation روی همه چیز — ممنوع  
✗ loop animation بدون هدف — ممنوع
```

**الگوی صحیح page-load:**
```dart
AnimationController _ctrl;
// فقط یک sequence: hero → content ظاهر می‌شود
// نه اینکه هر section با delay جداگانه بیاد
```

---

## ۷. چک‌لیست قبل از تحویل کد

```
□ flutter analyze → صفر warning
□ هیچ رنگ hardcode نیست
□ هیچ spacing hardcode نیست
□ همه تاچ‌تارگت‌ها ≥ 48dp
□ اعداد فارسی با PersianUtils
□ RTL صحیح
□ overflow روی 320px عرض test شده
□ کارت mascot (کلم) فقط در لحظات پیروزی/خالی — نه loading
□ lime فقط روی یک CTA اصلی
□ هیچ dynamic بیهوده‌ای
```

---

## ۸. ساختار استاندارد یک Screen

```dart
class XxxScreen extends StatefulWidget { ... }

class _XxxScreenState extends State<XxxScreen> {
  // ۱. state variables
  // ۲. initState → load از AppState
  // ۳. build → Scaffold با backgroundColor: context.appTokens.background
  // ۴. _buildXxx() → متدهای private برای هر section
  // ۵. متدهای action (async با try/catch)
}

// الگوی Scaffold:
Scaffold(
  backgroundColor: context.appTokens.background,
  body: SafeArea(
    child: CustomScrollView(
      slivers: [
        _buildHeader(),
        _buildHeroSection(),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
          sliver: SliverList(...),
        ),
      ],
    ),
  ),
)
```

---

## ۹. الگوی AppState integration

```dart
// خواندن
final state = context.read<AppState>();
final workouts = state.workoutPlans;

// گوش دادن به تغییر
Consumer<AppState>(
  builder: (ctx, state, _) => Text(
    PersianUtils.toPersianDigits(state.todayCalories.toString()),
  ),
)

// نوشتن (همیشه async + error handling)
Future<void> _saveSet() async {
  try {
    await context.read<AppState>().logSet(exerciseId, set);
  } catch (e) {
    _showErrorSnackbar(context, 'خطا در ثبت ست');
  }
}
```
