---
name: gymbro-icon-maker
description: >
  Use this skill whenever a new icon, illustration, SVG graphic, or visual asset
  needs to be created or added to GymBro. Triggers on: "آیکون بساز", "icon",
  "آیکون جدید", "SVG", "ایکون", "تصویر وکتوری", "illustration", "لوگو",
  "نشان", "badge", "emoji ورزشی", "گرافیک", or any request to design/add a
  visual asset for the app. Also use when converting an icon idea into Dart
  CustomPainter or Flutter SVG code for the GymBro icon system.
---

# GymBro Icon Maker Skill

تو یه طراح آیکون ورزشی هستی که برای سیستم آیکون GymBro کار می‌کنی. استایل
این پروژه مشخصه: geometric، minimal، athletic — نه cartoon، نه photorealistic،
نه generic Material/Cupertino.

---

## ۱. سیستم آیکون موجود (اول اینجا چک کن)

فایل‌های موجود در `lib/core/graphics/`:
```
gymbro_icon.dart              → کلاس اصلی GymBroIcon با 60+ آیکون
gymbro_icon_data.dart         → GymBroIconData — تعریف path‌های SVG
gymbro_animated_icon.dart     → آیکون‌های انیمیتد (تایمر، ضربان)
gymbro_brand_logo.dart        → لوگوی برند GymBro
gymbro_equipment_illustration.dart  → تصاویر تجهیزات باشگاه
gymbro_muscle_illustration.dart     → نقشه عضلات بدن
gymbro_nutrition_illustration.dart  → تصاویر تغذیه/غذا
```

**قبل از ساختن آیکون جدید:** بررسی کن آیا در `GymBroIcons` وجود داره.

---

## ۲. استایل‌گاید آیکون

### اصول بصری
```
Grid:        24×24dp (standard) | 48×48dp (hero) | 16×16dp (micro)
Stroke:      2dp — نه 1dp (خیلی نازک) نه 3dp (خیلی ضخیم)
Corner:      گوشه‌های rounded فقط در صورت نیاز — radius=2dp
Fill:        اکثراً outline-only؛ fill فقط برای state فعال/تاکید
Style:       Geometric athletic — نه cute، نه skeuomorphic
Viewbox:     "0 0 24 24" (استاندارد) یا "0 0 48 48" (hero)
```

### پالت رنگی آیکون‌ها
```
حالت پیش‌فرض:   textSecondary  #A7AFBD
حالت فعال:       textPrimary    #F4F6F8
حالت accent:     primaryLime    #C9F36A  (فقط برای emphasis)
حالت مثبت:       softCyan       #78CFE0
حالت امتیاز:     warmAmber      #FFB86B
حالت خطا:        error          #FF6B70
```

### ممنوع در آیکون‌ها
```
✗ shadow روی آیکون
✗ gradient داخل آیکون (مگر hero illustration)
✗ بیش از ۲ رنگ در یک آیکون
✗ نازک‌تر از stroke 1.5dp
✗ کپی از Material Icons با rename
✗ emoji به عنوان جایگزین آیکون واقعی
```

---

## ۳. اضافه کردن آیکون به سیستم GymBro

### مرحله ۱: تعریف path در `gymbro_icon_data.dart`

```dart
class GymBroIconData {
  static const String newIconName = '''
    M 12 3 
    C 12 3 ... 
    Z
  ''';
  
  // قرارداد نام‌گذاری: camelCase، توصیفی، بدون پسوند Icon
  // مثال: barbellPress, restTimer, waterDrop, muscleFront
}
```

### مرحله ۲: ثبت در enum یا map

```dart
// در gymbro_icon.dart
class GymBroIcons {
  static const GymBroIconData newIconName = GymBroIconData(
    path: GymBroIconData.newIconName,
    semanticLabel: 'توضیح فارسی برای accessibility',
  );
}
```

### مرحله ۳: استفاده

```dart
GymBroIcon(
  icon: GymBroIcons.newIconName,
  size: 24,
  color: context.appTokens.textSecondary,
)

// یا با CustomPainter مستقیم:
CustomPaint(
  size: Size(24, 24),
  painter: GymBroIconPainter(
    iconData: GymBroIcons.newIconName,
    color: context.appTokens.primaryLime,
  ),
)
```

---

## ۴. الگوی CustomPainter برای آیکون جدید

```dart
class NewIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  
  const NewIconPainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0; // normalize to 24px grid
    canvas.scale(scale, scale);

    final path = Path();
    // path commands here — طراحی روی grid 24×24
    // مثال: دکمه پلی
    path.moveTo(8, 5);
    path.lineTo(8, 19);
    path.lineTo(19, 12);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NewIconPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
```

---

## ۵. Illustration (تصویر بزرگ‌تر از آیکون)

برای illustration‌های پیچیده‌تر (عضله، تجهیزات، تغذیه) از الگوی فایل‌های
موجود (`gymbro_muscle_illustration.dart`) استفاده کن:

```dart
class NewIllustration extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color accentColor;

  const NewIllustration({
    super.key,
    this.size = 120,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NewIllustrationPainter(
          primary: primaryColor,
          accent: accentColor,
        ),
      ),
    );
  }
}
```

---

## ۶. Animated Icon

برای آیکون‌های انیمیتد (تایمر، ضربان، لودینگ):

```dart
class AnimatedXxxIcon extends StatefulWidget {
  final Color color;
  final double size;
  
  const AnimatedXxxIcon({
    super.key,
    required this.color,
    this.size = 24,
  });

  @override
  State<AnimatedXxxIcon> createState() => _AnimatedXxxIconState();
}

class _AnimatedXxxIconState extends State<AnimatedXxxIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // یا ..repeat() برای loop یک‌طرفه
    
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _XxxIconPainter(
          color: widget.color,
          progress: _anim.value,
        ),
      ),
    );
  }
}
```

---

## ۷. چک‌لیست تحویل آیکون

```
□ روی grid 24×24 طراحی شده
□ stroke دقیقاً 2dp (یا مشخص شده)
□ هیچ رنگ hardcode — color پارامتر می‌گیرد
□ semanticLabel فارسی دارد (accessibility)
□ shouldRepaint صحیح implement شده
□ dispose() در animated icon فراخوانی می‌شود
□ در GymBroIcons ثبت شده
□ در design_system_showcase_screen نمایش داده می‌شود
□ تست بصری روی پس‌زمینه #0B0E13 انجام شده
□ flutter analyze → صفر warning
```

---

## ۸. مثال‌های سریع

### آیکون دمبل (barbell)
```
Path: دو دایره در چپ و راست + خط افقی وسط
Grid 24×24: دایره‌ها در x=2-6 و x=18-22، خط در y=12
```

### آیکون آب (water drop)  
```
Path: قطره — نقطه تیز در بالا، بدنه گرد در پایین
Accent: softCyan #78CFE0
```

### آیکون آتش (streak)
```
Path: شعله انحنادار — سه منحنی bezier
Accent: warmAmber #FFB86B
```
