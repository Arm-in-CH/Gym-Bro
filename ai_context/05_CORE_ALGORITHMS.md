# 05 — CORE MATHEMATICAL ALGORITHMS (PURE DART)

این سند جزییات محاسبات ریاضی، بیومکانیک و تغذیه‌ای پیاده‌سازی‌شده در فایل کاملاً خالص دارت بدون وابستگی به فلاتر را تشریح می‌کند:
**مسیر فایل:** [`lib/core/algorithms/fitness_calculator.dart`](file:///c:/Users/Armin/Desktop/GymBro/lib/core/algorithms/fitness_calculator.dart)

---

## ۱. موتور متابولیک (`MetabolicEngine`)

### الف. فرمول میزان متابولیسم پایه (Mifflin-St Jeor BMR)
این فرمول استاندارد طلایی آکادمی تغذیه و رژیم غذایی برای تخمین کالری سوزی پایه در حالت استراحت است:

$$\text{Base} = (10 \times \text{Weight}_{\text{kg}}) + (6.25 \times \text{Height}_{\text{cm}}) - (5 \times \text{Age}_{\text{years}})$$

- **برای آقایان:** $\text{BMR} = \text{Base} + 5$
- **برای بانوان:** $\text{BMR} = \text{Base} - 161$

### ب. محاسبه کل انرژی مصرفی روزانه (TDEE)
$$\text{TDEE} = \text{BMR} \times \text{Activity Multiplier}$$
ضرایب فعالیت ورزشی بر اساس enum `ActivityLevel`:
- `sedentary` (کم‌تحرک / کارمندی): **۱.۲**
- `lightlyActive` (۱ تا ۳ روز تمرین سبک): **۱.۳۷۵**
- `moderatelyActive` (۳ تا ۵ روز تمرین باشگاهی): **۱.۵۵**
- `veryActive` (۶ تا ۷ روز تمرین سنگین): **۱.۷۲۵**
- `extraActive` (ورزشکار حرفه‌ای دو جلسه در روز): **۱.۹**

### ج. تفکیک به درشت‌مغذی‌ها (`partitionMacros`)
اهداف بدنسازی به صورت علمی با تنظیم کالری و ماکروها محاسبه می‌شوند:
1. **کاهش چربی (Fat Loss):**
   - ۲۰٪ کسر کالری: $\text{Calories} = \text{TDEE} \times 0.80$
   - پروتئین بالا برای حفظ بافت عضلانی: ۲.۲ گرم به ازای هر کیلوگرم وزن بدن ($4\text{ kcal/g}$)
   - چربی کنترل‌شده برای سلامت هورمونی: ۰.۸ گرم به ازای هر کیلوگرم ($9\text{ kcal/g}$)
   - کربوهیدرات: پرکننده کالری باقیمانده ($4\text{ kcal/g}$)
2. **تثبیت وزن (Maintenance):**
   - بدون تغییر کالری: $\text{Calories} = \text{TDEE} \times 1.00$
   - پروتئین: ۲.۰ گرم بر کیلوگرم | چربی: ۰.۹ گرم بر کیلوگرم
3. **افزایش حجم عضلانی تمیز (Muscle Gain / Lean Bulk):**
   - ۱۰٪ مازاد کالری: $\text{Calories} = \text{TDEE} \times 1.10$
   - پروتئین: ۲.۲ گرم بر کیلوگرم | چربی: ۱.۰ گرم بر کیلوگرم

---

## ۲. موتور تخمین قدرت و رکورد (`StrengthEngine`)

### الف. فرمول مت برزیکی (Matt Brzycki 1RM)
استاندارد معتبر برای تخمین حداکثر یک تکرار بیشینه ($1\text{RM}$) بدون ریسک مصدومیت:

$$1\text{RM} = \frac{\text{Weight}}{1.0278 - (0.0278 \times \text{Reps})}$$

- اگر $\text{Reps} = 1$ باشد، $1\text{RM} = \text{Weight}$.
- **مدیریت استثناها:** اگر تعداد تکرارها منفی، صفر یا $\ge 37$ باشد، خطا پرتاب می‌شود (چون در تکرار ۳۷ مخرج کسر به سمت صفر میل کرده و نامعتبر می‌شود).

### ب. محاسبه درصدهای تمرینی (`calculateTrainingPercentages`)
خروجی یک مپ ساختاریافته از وزنه‌های تجویزی برای برنامه‌ریزی جلسات قدرتی:
- **۶۵٪:** گرم‌کردن و تمرینات سرعتی/تکنیک
- **۷۵٪:** هایپرتروفی و حجم‌سازی عضلانی
- **۸۵٪:** افزایش قدرت پایه
- **۹۵٪:** فاز پیک‌گیری و سنجش توان

---

## ۳. تضمین کیفیت ریاضی
تمام متدهای این فایل در تست واحد [`test/fitness_calculator_test.dart`](file:///c:/Users/Armin/Desktop/GymBro/test/fitness_calculator_test.dart) به طور کامل آزموده شده و دقت اعشاری و مدیریت `ArgumentError` آن تایید شده است.
