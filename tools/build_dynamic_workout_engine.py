import re

def update_dynamic_workout():
    with open('gymbro_redmi_simulator.html', 'r', encoding='utf-8') as f:
        html = f.read()

    # 1. Replace the inner contents of workoutPlayerModal
    modal_body_pattern = re.compile(
        r'(<!-- Warmup Protocol -->\s*<div class="theme-card-sub bg-\[#0E1118\].*?<!-- CHRONOGRAPH REST TIMER DISPLAY -->)',
        re.DOTALL
    )

    new_modal_body = '''<!-- Warmup Protocol (Dynamic) -->
            <div id="activeWorkoutWarmupBox" class="theme-card-sub bg-[#0E1118] border border-zinc-800 rounded-xl p-3 space-y-2">
              <div class="text-xs font-bold text-gray-300 flex items-center justify-between">
                <div class="flex items-center gap-1.5">
                  <svg class="w-4 h-4 text-[#CCFF00]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8h1a4 4 0 0 1 0 8h-1M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/></svg>
                  <span>پروتکل گرم‌کردن اختصاصی آرمین:</span>
                </div>
                <span id="activeWorkoutWarmupTag" class="text-[9px] bg-emerald-500/15 text-emerald-400 px-2 py-0.5 rounded font-bold">زانو و مچ پا</span>
              </div>
              <div id="activeWorkoutWarmupList" class="space-y-1 text-xs text-gray-400">
                <label class="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" checked class="accent-[#CCFF00]">
                  <span>۱۰ دقیقه تردمیل برای افزایش ضربان قلب</span>
                </label>
                <label class="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" checked class="accent-[#CCFF00]">
                  <span>۵ دقیقه گرم کردن و چرخش مفاصل</span>
                </label>
              </div>
            </div>

            <!-- Horizontal Exercise Selector Navigation Strip -->
            <div>
              <div class="flex justify-between items-center mb-1.5 text-xs">
                <span class="text-gray-400 text-[11px] font-bold">فهرست حرکات جلسه:</span>
                <span id="exerciseProgressBadge" class="text-[10px] text-[#CCFF00] font-black bg-[#CCFF00]/15 px-2 py-0.5 rounded">حرکت ۱ از ۶</span>
              </div>
              <div id="exerciseTabsStrip" class="flex gap-1.5 overflow-x-auto pb-1 scrollbar-none">
                <!-- Dynamically Populated Exercise Chips -->
              </div>
            </div>

            <!-- Current Active Exercise Card (Dynamic Container) -->
            <div id="activeExerciseCard" class="theme-card bg-[#141722] border-2 border-[#252B3A] rounded-2xl p-4 space-y-3 transition-all shadow-lg">
              <!-- Dynamically Populated by renderActiveExercise() -->
            </div>

            <!-- Exercise Navigation: Prev / Next Buttons -->
            <div class="flex justify-between items-center gap-2">
              <button onclick="prevWorkoutExercise()" id="btnPrevExercise" class="flex-1 py-2 rounded-xl bg-[#1D2230] hover:bg-[#252B3A] text-gray-300 hover:text-white text-xs font-bold transition flex items-center justify-center gap-1.5 border border-[#2B354C] active:scale-95">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
                <span>حرکت قبلی</span>
              </button>
              <button onclick="nextWorkoutExercise()" id="btnNextExercise" class="flex-1 py-2 rounded-xl bg-[#1D2230] hover:bg-[#CCFF00] hover:text-black text-gray-300 font-black text-xs transition flex items-center justify-center gap-1.5 border border-[#2B354C] active:scale-95">
                <span>حرکت بعدی</span>
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
              </button>
            </div>

            <!-- CHRONOGRAPH REST TIMER DISPLAY -->'''

    html, count1 = modal_body_pattern.subn(new_modal_body, html)
    print(f'Modal body replaced: {count1} occurrence(s)')

    # 2. Add complete workout plans dataset & controller functions to JS
    js_workout_engine = '''
    // ============================================================================
    // COMPLETE DYNAMIC WORKOUT ENGINE (PLANS 1, 2, 3 & 4)
    // ============================================================================
    const WORKOUT_PLANS = {
      1: {
        title: "برنامه شماره ۱: پا و شکم (Legs & Core)",
        warmupTag: "پا، زانو و کور",
        warmupItems: [
          "۱۰ دقیقه تردمیل شیبدار برای جریان خون پاها",
          "۵ دقیقه چرخش فعال مفاصل مچ پا و زانوها",
          "۲ ست اسکوات وزن بدن برای روانکاری مفاصل"
        ],
        exercises: [
          {
            id: "d1_e1",
            name: "اسکوات هالتر استاندارد (Barbell Squat)",
            muscle: "چهارسر ران و گلوت",
            equipment: "هالتر المپیکی",
            restSec: 120,
            sets: [
              { num: 1, text: "۷۰kg × ۱۰ تکرار", weight: 70, reps: 10, done: true },
              { num: 2, text: "۸۰kg × ۱۰ تکرار", weight: 80, reps: 10, done: false },
              { num: 3, text: "۹۰kg × ۱۰ تکرار", weight: 90, reps: 10, done: false }
            ]
          },
          {
            id: "d1_e2",
            name: "پرس پا دستگاه شیبدار (Leg Press)",
            muscle: "چهارسر و باسن",
            equipment: "دستگاه پرس پا",
            restSec: 90,
            sets: [
              { num: 1, text: "۱۲۰kg × ۱۰ تکرار", weight: 120, reps: 10, done: false },
              { num: 2, text: "۱۴۰kg × ۱۰ تکرار", weight: 140, reps: 10, done: false },
              { num: 3, text: "۱۶۰kg × ۱۰ تکرار", weight: 160, reps: 10, done: false }
            ]
          },
          {
            id: "d1_e3",
            name: "ددلیفت رومانیایی دمبل (Romanian Deadlift)",
            muscle: "همسترینگ و فیله کمر",
            equipment: "دمبل سنگین",
            restSec: 90,
            sets: [
              { num: 1, text: "۲۵kg × ۸ تکرار", weight: 25, reps: 8, done: false },
              { num: 2, text: "۳۰kg × ۸ تکرار", weight: 30, reps: 8, done: false },
              { num: 3, text: "۳۰kg × ۸ تکرار", weight: 30, reps: 8, done: false }
            ]
          },
          {
            id: "d1_e4",
            name: "سوپرست جلوپا + پشت‌پا دستگاه",
            muscle: "تفکیک کامل عضلات ران",
            equipment: "دستگاه سیم‌کش",
            restSec: 60,
            sets: [
              { num: 1, text: "۴۵kg × ۱۵ تکرار (سوپر)", weight: 45, reps: 15, done: false },
              { num: 2, text: "۵۰kg × ۱۵ تکرار (سوپر)", weight: 50, reps: 15, done: false },
              { num: 3, text: "۵۵kg × ۱۵ تکرار (سوپر)", weight: 55, reps: 15, done: false }
            ]
          },
          {
            id: "d1_e5",
            name: "ساق پا هاگ دستگاه (Calf Raise)",
            muscle: "دوقلو و نعلی ساق",
            equipment: "دستگاه هاگ",
            restSec: 60,
            sets: [
              { num: 1, text: "۴۰kg × ۲۰ تکرار", weight: 40, reps: 20, done: false },
              { num: 2, text: "۵۰kg × ۲۰ تکرار", weight: 50, reps: 20, done: false },
              { num: 3, text: "۵۰kg × ۲۰ تکرار", weight: 50, reps: 20, done: false }
            ]
          },
          {
            id: "d1_e6",
            name: "سوپرست پلنک و شکم شیب (Core Blast)",
            muscle: "راست و مورب شکمی",
            equipment: "وزن بدن و میز شیبدار",
            restSec: 45,
            sets: [
              { num: 1, text: "۶۰ ثانیه پلنک + ۲۰ تکرار شکم", weight: 0, reps: 20, done: false },
              { num: 2, text: "۶۰ ثانیه پلنک + ۲۰ تکرار شکم", weight: 0, reps: 20, done: false },
              { num: 3, text: "۶۰ ثانیه پلنک + ۲۰ تکرار شکم", weight: 0, reps: 20, done: false }
            ]
          }
        ]
      },

      2: {
        title: "برنامه شماره ۲: سینه، بازو و فیله کمر (Chest & Arms)",
        warmupTag: "سینه و روتاتور کاف",
        warmupItems: [
          "۵ دقیقه چرخش کش پیلاتس برای روتاتور کاف شانه",
          "۵ دقیقه شیب ملایم تردمیل برای گردش خون",
          "۲ ست شنا سوئدی سبک با کنترل فاز منفی"
        ],
        exercises: [
          {
            id: "d2_e1",
            name: "پرس سینه هالتر هرمی (Bench Press)",
            muscle: "سینه میانی و قدامی",
            equipment: "هالتر تخت",
            restSec: 120,
            sets: [
              { num: 1, text: "۷۰kg × ۱۲ تکرار", weight: 70, reps: 12, done: true },
              { num: 2, text: "۸۰kg × ۱۰ تکرار", weight: 80, reps: 10, done: false },
              { num: 3, text: "۸۵kg × ۸ تکرار", weight: 85, reps: 8, done: false },
              { num: 4, text: "۹۰kg × ۶ تکرار (سنگین‌ترین)", weight: 90, reps: 6, done: false }
            ]
          },
          {
            id: "d2_e2",
            name: "قفسه بالاسینه کراس‌اور (Cable Fly)",
            muscle: "بالاسینه و تفکیک خط وسط",
            equipment: "سیم‌کش دوبل",
            restSec: 75,
            sets: [
              { num: 1, text: "۱۵kg × ۱۰ تکرار", weight: 15, reps: 10, done: false },
              { num: 2, text: "۱۷.۵kg × ۱۰ تکرار", weight: 17.5, reps: 10, done: false },
              { num: 3, text: "۲۰kg × ۱۰ تکرار", weight: 20, reps: 10, done: false }
            ]
          },
          {
            id: "d2_e3",
            name: "سوپرست بالاسینه دمبل + شنا سوئدی",
            muscle: "پمپ خون و استرس متابولیک سینه",
            equipment: "دمبل و وزن بدن",
            restSec: 90,
            sets: [
              { num: 1, text: "۲۲kg × ۱۰ + ۱۲ شنا", weight: 22, reps: 10, done: false },
              { num: 2, text: "۲۴kg × ۱۰ + ۱۰ شنا", weight: 24, reps: 10, done: false },
              { num: 3, text: "۲۶kg × ۱۰ + ۱۰ شنا", weight: 26, reps: 10, done: false }
            ]
          },
          {
            id: "d2_e4",
            name: "پرس سینه دستگاه ماتریکس (Chest Press)",
            muscle: "تمرکز انقباض ایزوله سینه",
            equipment: "دستگاه ماتریکس",
            restSec: 60,
            sets: [
              { num: 1, text: "۵۰kg × ۱۰ تکرار", weight: 50, reps: 10, done: false },
              { num: 2, text: "۶۰kg × ۱۰ تکرار", weight: 60, reps: 10, done: false },
              { num: 3, text: "۶۵kg × ۱۰ تکرار", weight: 65, reps: 10, done: false }
            ]
          },
          {
            id: "d2_e5",
            name: "سوپرست بازو (جلو بازو دمبل + دیپ پارالل)",
            muscle: "دوسر و سه‌سر بازو",
            equipment: "دمبل و پارالل",
            restSec: 60,
            sets: [
              { num: 1, text: "۱۴kg × ۱۲ + ۱۲ دیپ", weight: 14, reps: 12, done: false },
              { num: 2, text: "۱۶kg × ۱۲ + ۱۲ دیپ", weight: 16, reps: 12, done: false },
              { num: 3, text: "۱۶kg × ۱۲ + ۱۰ دیپ", weight: 16, reps: 12, done: false }
            ]
          },
          {
            id: "d2_e6",
            name: "فیله کمر با صفحه وزنه (Hyperextensions)",
            muscle: "راست‌کننده ستون فقرات و سرینی",
            equipment: "میز فیله + وزنه",
            restSec: 60,
            sets: [
              { num: 1, text: "۱۰kg × ۱۵ تکرار", weight: 10, reps: 15, done: false },
              { num: 2, text: "۱۰kg × ۱۵ تکرار", weight: 10, reps: 15, done: false },
              { num: 3, text: "۱۵kg × ۱۵ تکرار", weight: 15, reps: 15, done: false }
            ]
          }
        ]
      },

      3: {
        title: "برنامه شماره ۳: پشت، زیربغل، سرشانه و کول (Back & Shoulders)",
        warmupTag: "کتف، شانه و لت",
        warmupItems: [
          "۵ دقیقه آویزان شدن پویا از بارفیکس و چرخش اسکاپولا",
          "۵ دقیقه کش پیلاتس نشر جانب و فیس پول سبک",
          "۲ ست لت سیم‌کش خیلی سبک برای درگیری عصب و عضله"
        ],
        exercises: [
          {
            id: "d3_e1",
            name: "بارفیکس مچ برعکس (Chin-ups)",
            muscle: "زیربغل، پهنای لت و جلوبازو",
            equipment: "میله بارفیکس",
            restSec: 90,
            sets: [
              { num: 1, text: "وزن بدن (۷۳kg) × ۸ تکرار", weight: 73, reps: 8, done: true },
              { num: 2, text: "وزن بدن (۷۳kg) × ۸ تکرار", weight: 73, reps: 8, done: false },
              { num: 3, text: "وزن بدن (۷۳kg) × ۸ تکرار", weight: 73, reps: 8, done: false }
            ]
          },
          {
            id: "d3_e2",
            name: "زیربغل قایقی میله V (Seated Cable Row)",
            muscle: "ضخامت لت و زیربغل میانی",
            equipment: "سیم‌کش قایقی",
            restSec: 75,
            sets: [
              { num: 1, text: "۵۰kg × ۱۰ تکرار", weight: 50, reps: 10, done: false },
              { num: 2, text: "۶۰kg × ۱۰ تکرار", weight: 60, reps: 10, done: false },
              { num: 3, text: "۶۵kg × ۱۰ تکرار", weight: 65, reps: 10, done: false }
            ]
          },
          {
            id: "d3_e3",
            name: "سوپرست سیم‌کش جلو + تی‌بار سنگین",
            muscle: "پهنا و ضخامت کامل عضلات پشت",
            equipment: "دستگاه لت و هالتر T",
            restSec: 90,
            sets: [
              { num: 1, text: "۵۵kg × ۱۰ + ۴۰kg × ۱۰", weight: 55, reps: 10, done: false },
              { num: 2, text: "۶۰kg × ۱۰ + ۴۵kg × ۱۰", weight: 60, reps: 10, done: false },
              { num: 3, text: "۶۵kg × ۱۰ + ۵۰kg × ۱۰", weight: 65, reps: 10, done: false }
            ]
          },
          {
            id: "d3_e4",
            name: "پرس سرشانه هالتر نظامی (Military Press)",
            muscle: "دلتوئید قدامی و میانی",
            equipment: "هالتر ایستاده",
            restSec: 90,
            sets: [
              { num: 1, text: "۴۰kg × ۱۰ تکرار", weight: 40, reps: 10, done: false },
              { num: 2, text: "۴۵kg × ۱۰ تکرار", weight: 45, reps: 10, done: false },
              { num: 3, text: "۵۰kg × ۱۰ تکرار", weight: 50, reps: 10, done: false }
            ]
          },
          {
            id: "d3_e5",
            name: "سوپرست پرس دمبل آرنولدی + نشر جانب",
            muscle: "تفکیک کامل عضلات سرشانه",
            equipment: "دمبل",
            restSec: 60,
            sets: [
              { num: 1, text: "۱۶kg × ۱۲ + ۸kg × ۱۲", weight: 16, reps: 12, done: false },
              { num: 2, text: "۱۸kg × ۱۲ + ۹kg × ۱۲", weight: 18, reps: 12, done: false },
              { num: 3, text: "۱۸kg × ۱۲ + ۱۰kg × ۱۲", weight: 18, reps: 12, done: false }
            ]
          },
          {
            id: "d3_e6",
            name: "فلای معکوس دمبل + شراگز هالتر سنگین",
            muscle: "سرشانه خلفی و کول (تراپزیوس)",
            equipment: "دمبل و هالتر",
            restSec: 60,
            sets: [
              { num: 1, text: "۱۰kg × ۱۵ + ۷۰kg × ۱۵", weight: 70, reps: 15, done: false },
              { num: 2, text: "۱۲kg × ۱۵ + ۸۰kg × ۱۵", weight: 80, reps: 15, done: false },
              { num: 3, text: "۱۲kg × ۱۵ + ۹۰kg × ۱۵", weight: 90, reps: 15, done: false }
            ]
          }
        ]
      },

      4: {
        title: "برنامه تمرین خانگی بدون وزنه (Home Workout)",
        warmupTag: "پروانه و کشش پویا",
        warmupItems: [
          "۵ دقیقه پروانه سبک برای گرم‌کردن عمومی",
          "۵ دقیقه کشش دست، پا و مفاصل مچ",
          "۲ ست پلانک سبک ۲۰ ثانیه‌ای"
        ],
        exercises: [
          {
            id: "d4_e1",
            name: "شنا سوئدی استاندارد (Push-ups)",
            muscle: "سینه و پشت‌بازو",
            equipment: "وزن بدن",
            restSec: 60,
            sets: [
              { num: 1, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: true },
              { num: 2, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false },
              { num: 3, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false }
            ]
          },
          {
            id: "d4_e2",
            name: "شنا پاهای بالا روی صندلی (Decline Push-ups)",
            muscle: "بالاسینه",
            equipment: "وزن بدن + صندلی",
            restSec: 60,
            sets: [
              { num: 1, text: "وزن بدن × ۱۲ تکرار", weight: 0, reps: 12, done: false },
              { num: 2, text: "وزن بدن × ۱۲ تکرار", weight: 0, reps: 12, done: false },
              { num: 3, text: "وزن بدن × ۱۲ تکرار", weight: 0, reps: 12, done: false }
            ]
          },
          {
            id: "d4_e3",
            name: "اسکوات بلغاری تک‌پا (Bulgarian Split Squat)",
            muscle: "چهارسر ران و گلوت",
            equipment: "وزن بدن",
            restSec: 60,
            sets: [
              { num: 1, text: "وزن بدن × ۱۵ تکرار هر پا", weight: 0, reps: 15, done: false },
              { num: 2, text: "وزن بدن × ۱۵ تکرار هر پا", weight: 0, reps: 15, done: false },
              { num: 3, text: "وزن بدن × ۱۵ تکرار هر پا", weight: 0, reps: 15, done: false }
            ]
          },
          {
            id: "d4_e4",
            name: "دیپ لبه صندلی (Chair Dips)",
            muscle: "پشت‌بازو",
            equipment: "صندلی یا لبه تخت",
            restSec: 60,
            sets: [
              { num: 1, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false },
              { num: 2, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false },
              { num: 3, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false }
            ]
          },
          {
            id: "d4_e5",
            name: "سوپرمن با حوله کشیده (Superman Extension)",
            muscle: "فیله کمر و عضلات پشت",
            equipment: "حوله ورزشی",
            restSec: 45,
            sets: [
              { num: 1, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false },
              { num: 2, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false },
              { num: 3, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false }
            ]
          },
          {
            id: "d4_e6",
            name: "پلنک ایستا (Plank)",
            muscle: "عضلات کور و شکم",
            equipment: "وزن بدن",
            restSec: 45,
            sets: [
              { num: 1, text: "۶۰ ثانیه نگهداری", weight: 0, reps: 60, done: false },
              { num: 2, text: "۶۰ ثانیه نگهداری", weight: 0, reps: 60, done: false },
              { num: 3, text: "۶۰ ثانیه نگهداری", weight: 0, reps: 60, done: false }
            ]
          }
        ]
      }
    };

    let activePlanId = 2;
    let activeExerciseIndex = 0;
    let sessionSecondsElapsed = 765;
    let sessionTimerInterval = null;

    function openWorkoutSessionModal(dayNumber) {
      soundClick();
      activePlanId = dayNumber || 2;
      activeExerciseIndex = 0;

      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];

      // Update Title
      const titleEl = document.getElementById('activeWorkoutTitle');
      if (titleEl) titleEl.textContent = plan.title;

      // Update Warmup Protocol
      const tagEl = document.getElementById('activeWorkoutWarmupTag');
      if (tagEl) tagEl.textContent = plan.warmupTag;

      const warmupListEl = document.getElementById('activeWorkoutWarmupList');
      if (warmupListEl) {
        warmupListEl.innerHTML = plan.warmupItems.map(item => `
          <label class="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" checked class="accent-[#CCFF00]">
            <span>${item}</span>
          </label>
        `).join('');
      }

      // Render Exercise Strip & Active Card
      renderExerciseTabs();
      renderActiveExercise();
      recalcSessionTonnage();

      // Start live elapsed timer
      if (!sessionTimerInterval) {
        sessionTimerInterval = setInterval(() => {
          sessionSecondsElapsed++;
          const m = String(Math.floor(sessionSecondsElapsed / 60)).padStart(2, '0');
          const s = String(sessionSecondsElapsed % 60).padStart(2, '0');
          const disp = document.getElementById('sessionTimerDisplay');
          if (disp) disp.textContent = `۰۰:${m}:${s}`;
        }, 1000);
      }

      document.getElementById('workoutPlayerModal').classList.remove('hidden');
      updateIslandState('<span class="text-[#CCFF00]">جلسه فعال</span>', true);
    }

    function closeWorkoutPlayer() {
      pauseTimerManual();
      if (sessionTimerInterval) {
        clearInterval(sessionTimerInterval);
        sessionTimerInterval = null;
      }
      document.getElementById('workoutPlayerModal').classList.add('hidden');
      updateIslandState('<span>GymBro</span>', false);
    }

    function renderExerciseTabs() {
      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      const strip = document.getElementById('exerciseTabsStrip');
      if (!strip) return;

      strip.innerHTML = plan.exercises.map((ex, idx) => {
        const isActive = idx === activeExerciseIndex;
        const allDone = ex.sets.every(s => s.done);
        return `
          <button onclick="selectWorkoutExercise(${idx})" class="whitespace-nowrap px-3 py-1.5 rounded-xl text-xs font-bold transition flex items-center gap-1.5 border ${
            isActive
              ? 'bg-[#CCFF00] text-black border-[#CCFF00] shadow-md'
              : allDone
                ? 'bg-emerald-500/20 text-emerald-300 border-emerald-500/40'
                : 'bg-[#141722] text-gray-300 border-[#252B3A] hover:border-gray-500'
          }">
            <span>${idx + 1}. ${ex.name.split(' (')[0]}</span>
            ${allDone ? '<span class="text-[10px]">✓</span>' : ''}
          </button>
        `;
      }).join('');

      const badge = document.getElementById('exerciseProgressBadge');
      if (badge) {
        badge.textContent = `حرکت ${activeExerciseIndex + 1} از ${plan.exercises.length}`;
      }
    }

    function selectWorkoutExercise(index) {
      soundClick();
      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      if (index < 0 || index >= plan.exercises.length) return;
      activeExerciseIndex = index;
      renderExerciseTabs();
      renderActiveExercise();
    }

    function nextWorkoutExercise() {
      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      if (activeExerciseIndex < plan.exercises.length - 1) {
        selectWorkoutExercise(activeExerciseIndex + 1);
      }
    }

    function prevWorkoutExercise() {
      if (activeExerciseIndex > 0) {
        selectWorkoutExercise(activeExerciseIndex - 1);
      }
    }

    function renderActiveExercise() {
      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      const ex = plan.exercises[activeExerciseIndex];
      const container = document.getElementById('activeExerciseCard');
      if (!container || !ex) return;

      container.innerHTML = `
        <div class="flex justify-between items-start">
          <div>
            <div class="flex items-center gap-2">
              <span class="w-6 h-6 rounded-lg bg-[#CCFF00] text-black font-black text-xs flex items-center justify-center">${activeExerciseIndex + 1}</span>
              <h4 class="theme-text-primary text-sm font-black text-white">${ex.name}</h4>
            </div>
            <div class="flex items-center gap-2 mt-1.5 text-[10px] text-gray-400">
              <span class="text-gray-300 font-bold">${ex.muscle}</span>
              <span>•</span>
              <span>${ex.equipment}</span>
              <span>•</span>
              <span class="bg-[#CCFF00]/15 text-[#CCFF00] px-1.5 py-0.5 rounded font-bold">هدف استراحت: ${ex.restSec} ثانیه</span>
            </div>
          </div>
        </div>

        <!-- Sets Table -->
        <div class="space-y-2 text-xs pt-1">
          ${ex.sets.map((set, setIdx) => `
            <div onclick="toggleSetCheck(${activeExerciseIndex}, ${setIdx})" class="theme-card-sub flex justify-between items-center bg-[#0E1118] hover:bg-[#161B26] p-2.5 rounded-xl border border-zinc-800 transition cursor-pointer select-none">
              <div class="text-gray-300 flex items-center gap-2">
                <span class="font-bold text-white">ست ${set.num}:</span>
                <span class="${set.done ? 'line-through text-gray-500' : 'text-gray-200'}">${set.text}</span>
              </div>
              <input type="checkbox" ${set.done ? 'checked' : ''} onclick="event.stopPropagation(); toggleSetCheck(${activeExerciseIndex}, ${setIdx})" class="w-5 h-5 accent-[#CCFF00] cursor-pointer">
            </div>
          `).join('')}
        </div>
      `;

      // Set Chronograph rest timer to this exercise's restSec
      timerTargetSeconds = ex.restSec || 90;
      resetTimerManual();

      // Update Prev / Next Buttons State
      const prevBtn = document.getElementById('btnPrevExercise');
      const nextBtn = document.getElementById('btnNextExercise');
      if (prevBtn) {
        prevBtn.disabled = activeExerciseIndex === 0;
        prevBtn.style.opacity = activeExerciseIndex === 0 ? "0.4" : "1";
      }
      if (nextBtn) {
        nextBtn.disabled = activeExerciseIndex === plan.exercises.length - 1;
        nextBtn.style.opacity = activeExerciseIndex === plan.exercises.length - 1 ? "0.4" : "1";
      }
    }

    function toggleSetCheck(exIdx, setIdx) {
      soundClick();
      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      const set = plan.exercises[exIdx].sets[setIdx];
      set.done = !set.done;

      if (set.done) {
        soundSuccess();
        // Prompt to start rest timer
        startTimerManual();
      }

      renderExerciseTabs();
      renderActiveExercise();
      recalcSessionTonnage();
    }

    function recalcSessionTonnage() {
      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      let totalKg = 0;
      let totalSetsDone = 0;

      plan.exercises.forEach(ex => {
        ex.sets.forEach(set => {
          if (set.done) {
            totalSetsDone++;
            totalKg += (set.weight || 0) * (set.reps || 1);
          }
        });
      });

      const tonnageDisp = document.getElementById('sessionTonnageDisplay');
      if (tonnageDisp) {
        tonnageDisp.textContent = `${totalKg.toLocaleString('fa-IR')} kg`;
      }
      return { totalKg, totalSetsDone };
    }

    function finishWorkoutSession() {
      const { totalKg, totalSetsDone } = recalcSessionTonnage();

      if (totalSetsDone === 0) {
        const confirmExit = confirm("هیچ ستی به عنوان انجام شده تیک نخورده است. آیا مایلید جلسه را بدون ثبت تناژ پایان دهید؟");
        if (!confirmExit) return;
        closeWorkoutPlayer();
        return;
      }

      closeWorkoutPlayer();
      soundSuccess();

      // Show Celebration Modal with accurate stats
      document.getElementById('celebrationTonnageText').textContent = `${totalKg.toLocaleString('fa-IR')} کیلوگرم`;
      document.getElementById('celebrationSetsText').textContent = `${totalSetsDone} ست`;
      document.getElementById('workoutCelebrationModal').classList.remove('hidden');

      const coinsDisplay = document.getElementById('dashboardCoinsText');
      if (coinsDisplay) coinsDisplay.textContent = '۱۵۰ سکه';
    }
'''

    # Replace the existing openWorkoutSessionModal and finishWorkoutSession functions
    old_functions_pattern = re.compile(
        r'// Active Workout Session Modal\s*function openWorkoutSessionModal\(dayNumber\) {.*?function finishWorkoutSession\(\) {.*?}\s*}',
        re.DOTALL
    )

    if old_functions_pattern.search(html):
        html = old_functions_pattern.sub(js_workout_engine.strip(), html)
        print('Replaced old workout functions with complete dynamic engine!')
    else:
        print('Could not find old workout functions pattern, searching alternate anchor...')
        # Alternative replacement around finishWorkoutSession
        idx = html.find('// Active Workout Session Modal')
        end_idx = html.find('// Visual Food Scanner Modal Controls')
        if idx != -1 and end_idx != -1:
            html = html[:idx] + js_workout_engine.strip() + '\n\n    ' + html[end_idx:]
            print('Replaced workout engine via index slice!')

    with open('gymbro_redmi_simulator.html', 'w', encoding='utf-8') as f:
        f.write(html)
    print('gymbro_redmi_simulator.html updated with dynamic exercises for all workouts!')

if __name__ == '__main__':
    update_dynamic_workout()
