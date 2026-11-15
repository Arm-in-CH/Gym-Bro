import re

with open('gymbro_redmi_simulator.html', 'r', encoding='utf-8') as f:
    html = f.read()

# ==============================================================================
# 1. UPGRADE WORKOUT PLANS SECTION IN pageWorkout
# ==============================================================================

# Find the entire list of 4 plans in pageWorkout
# It starts around: <!-- Plan 1: Legs & Core --> and ends before </section> of pageWorkout
idx1 = html.find('برنامه شماره ۱: پا و شکم')
card1_start = html.rfind('<div class="theme-card', 0, idx1)
idx4 = html.find('برنامه بدون وزنه در خانه')
idx_pw_end = html.find('</section>', idx4)

assert card1_start != -1 and idx_pw_end != -1, "Failed to locate bounds!"

NEW_WORKOUT_PLANS_HTML = '''<!-- Plan 1: Legs & Core (با آیکون و تصویر عضلات پا و شکم) -->
            <div class="theme-card bg-[#141722] border border-[#252B3A] rounded-2xl p-4 space-y-3.5 transition hover:border-[#CCFF00]/40">
              <!-- Header with Muscle Anatomy Icon -->
              <div class="flex justify-between items-start gap-3 border-b border-[#1E2433] pb-3">
                <div class="flex items-center gap-3">
                  <!-- Leg Anatomy Vector Badge -->
                  <div class="w-12 h-12 rounded-xl bg-[#CCFF00]/10 border border-[#CCFF00]/30 flex items-center justify-center shrink-0">
                    <svg viewBox="0 0 100 100" class="w-8 h-8 drop-shadow-[0_0_8px_rgba(204,255,0,0.4)]" fill="none" stroke="#CCFF00" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M30 18 L38 48 L35 75 L30 92 M40 92 L36 76" />
                      <path d="M70 18 L62 48 L65 75 L70 92 M60 92 L64 76" />
                      <path d="M32 30 Q50 36 68 30" stroke-dasharray="2 2" opacity="0.7" />
                      <circle cx="37" cy="52" r="5" fill="#CCFF00" fill-opacity="0.3" />
                      <circle cx="63" cy="52" r="5" fill="#CCFF00" fill-opacity="0.3" />
                      <rect x="25" y="12" width="50" height="7" rx="3.5" fill="#CCFF00" fill-opacity="0.2" />
                    </svg>
                  </div>
                  <div>
                    <div class="flex items-center gap-2">
                      <span class="text-[10px] bg-[#252B3A] text-gray-300 px-2 py-0.5 rounded font-bold">شنبه</span>
                      <span class="text-[10px] bg-emerald-500/15 text-emerald-400 border border-emerald-500/30 px-2 py-0.5 rounded font-bold">تکمیل‌شده (✓)</span>
                    </div>
                    <h3 class="text-sm font-black text-white mt-1">برنامه شماره ۱: پا و شکم (Legs & Core)</h3>
                    <p class="text-[11px] text-[#CCFF00] font-bold mt-0.5">🦵 عضلات هدف: چهارسر ران، همسترینگ، باسن، ساق و کور</p>
                  </div>
                </div>
              </div>

              <!-- Exercise List with Muscle Tags -->
              <div class="space-y-2">
                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۱</span>
                    <span class="font-bold text-gray-200">اسکوات هالتر آزاد</span>
                    <span class="text-[9px] bg-[#CCFF00]/10 text-[#CCFF00] px-1.5 py-0.5 rounded border border-[#CCFF00]/20">🦵 چهارسر + باسن</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۲</span>
                    <span class="font-bold text-gray-200">پرس پا زاویه ۴۵ درجه</span>
                    <span class="text-[9px] bg-[#CCFF00]/10 text-[#CCFF00] px-1.5 py-0.5 rounded border border-[#CCFF00]/20">🦵 چهارسر ران</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-purple-500/20 text-purple-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست جلوپا + پشت‌پا دستگاه</span>
                    <span class="text-[9px] bg-purple-500/10 text-purple-300 px-1.5 py-0.5 rounded border border-purple-500/20">🦵 قدام + خلف ران</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-purple-300 bg-purple-500/10 px-2 py-0.5 rounded border border-purple-500/20">۳ × ۱۵</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۴</span>
                    <span class="font-bold text-gray-200">ددلیفت رومانیایی دمبل</span>
                    <span class="text-[9px] bg-[#CCFF00]/10 text-[#CCFF00] px-1.5 py-0.5 rounded border border-[#CCFF00]/20">🦵 همسترینگ + گلوت</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۸</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۵</span>
                    <span class="font-bold text-gray-200">ساق پا هاگ ایستاده</span>
                    <span class="text-[9px] bg-[#CCFF00]/10 text-[#CCFF00] px-1.5 py-0.5 rounded border border-[#CCFF00]/20">🦵 دوقلو و نعلی</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۲۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-cyan-500/20 text-cyan-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست پلانک + شکم شیب</span>
                    <span class="text-[9px] bg-cyan-500/10 text-cyan-300 px-1.5 py-0.5 rounded border border-cyan-500/20">⚡ شکم و هسته بدن</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-cyan-300 bg-cyan-500/10 px-2 py-0.5 rounded border border-cyan-500/20">۳ × ۲۰</span>
                </div>
              </div>

              <!-- Start Button -->
              <button onclick="openWorkoutSessionModal(1)" class="w-full py-2.5 rounded-xl bg-[#1D2230] hover:bg-[#CCFF00] hover:text-black text-gray-200 font-black text-xs transition active:scale-95 flex items-center justify-center gap-2 border border-[#2B354C]">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M6 5v14M18 5v14M2 9h4M18 9h4M2 15h4M18 15h4M6 12h12"/></svg>
                <span>شروع تمرین پا و شکم (روز ۱)</span>
              </button>
            </div>

            <!-- Plan 2: Chest & Arms (با آیکون و تصویر عضلات سینه و بازو) -->
            <div class="theme-card bg-[#141722] border-2 border-[#CCFF00]/60 rounded-2xl p-4 space-y-3.5 shadow-xl shadow-[#CCFF00]/10 relative overflow-hidden">
              <div class="absolute -right-12 -top-12 w-28 h-28 bg-[#CCFF00]/10 rounded-full blur-2xl pointer-events-none"></div>
              
              <!-- Header with Muscle Anatomy Icon -->
              <div class="flex justify-between items-start gap-3 border-b border-[#1E2433] pb-3 relative z-10">
                <div class="flex items-center gap-3">
                  <!-- Arm & Chest Anatomy Vector Badge -->
                  <div class="w-12 h-12 rounded-xl bg-[#00F0FF]/15 border border-[#00F0FF]/40 flex items-center justify-center shrink-0">
                    <svg viewBox="0 0 100 100" class="w-8 h-8 drop-shadow-[0_0_8px_rgba(0,240,255,0.4)]" fill="none" stroke="#00F0FF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M20 70 L38 52 C45 38 60 38 68 45 L85 30 L90 42 L72 62 C65 72 45 78 30 78 Z" fill="#00F0FF" fill-opacity="0.2" />
                      <path d="M42 45 Q52 28 64 42" stroke-width="3.5" />
                      <circle cx="52" cy="38" r="6" fill="#00F0FF" fill-opacity="0.4" />
                      <circle cx="82" cy="36" r="3.5" fill="#00F0FF" />
                    </svg>
                  </div>
                  <div>
                    <div class="flex items-center gap-2">
                      <span class="text-[10px] bg-[#CCFF00] text-black font-black px-2 py-0.5 rounded shadow-sm">دوشنبه (جلسه امروز) 🔥</span>
                      <span class="text-[10px] bg-[#252B3A] text-gray-300 px-2 py-0.5 rounded font-bold">⏱️ ۴۵-۵۰ دقیقه</span>
                    </div>
                    <h3 class="text-sm font-black text-white mt-1">برنامه شماره ۲: سینه، بازو و فیله کمر</h3>
                    <p class="text-[11px] text-[#00F0FF] font-bold mt-0.5">💪 عضلات هدف: پکتورال سینه، جلوبازو، پشت‌بازو و راست‌کننده ستون فقرات</p>
                  </div>
                </div>
              </div>

              <!-- Exercise List with Muscle Tags -->
              <div class="space-y-2 relative z-10">
                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#CCFF00] text-black flex items-center justify-center text-[10px] font-black">۱</span>
                    <span class="font-bold text-gray-100">پرس سینه هالتر (هرمی)</span>
                    <span class="text-[9px] bg-[#FF9900]/15 text-[#FF9900] px-1.5 py-0.5 rounded border border-[#FF9900]/30">🎯 سینه میانی و کلی</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۴ × ۱۲-۱۰-۸-۶</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۲</span>
                    <span class="font-bold text-gray-200">قفسه بالاسینه دمبل موازی</span>
                    <span class="text-[9px] bg-[#FF9900]/15 text-[#FF9900] px-1.5 py-0.5 rounded border border-[#FF9900]/30">🎯 بالاسینه ترقوه‌ای</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-purple-500/20 text-purple-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست بالاسینه دمبل + شنا سوئدی</span>
                    <span class="text-[9px] bg-[#FF9900]/15 text-[#FF9900] px-1.5 py-0.5 rounded border border-[#FF9900]/30">🎯 حجم و خط سینه</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-purple-300 bg-purple-500/10 px-2 py-0.5 rounded border border-purple-500/20">۳ × ۱۲</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۴</span>
                    <span class="font-bold text-gray-200">پارالل سینه وزن بدن</span>
                    <span class="text-[9px] bg-[#FF9900]/15 text-[#FF9900] px-1.5 py-0.5 rounded border border-[#FF9900]/30">🎯 زیرسینه و پشت‌بازو</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-cyan-500/20 text-cyan-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست جلوبازو هالتر EZ + پشت‌بازو طناب</span>
                    <span class="text-[9px] bg-[#00F0FF]/15 text-[#00F0FF] px-1.5 py-0.5 rounded border border-[#00F0FF]/30">💪 دوسر و سه‌سر بازو</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-cyan-300 bg-cyan-500/10 px-2 py-0.5 rounded border border-cyan-500/20">۳ × ۱۲</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۶</span>
                    <span class="font-bold text-gray-200">هایپراکستنشن فیله کمر</span>
                    <span class="text-[9px] bg-emerald-500/15 text-emerald-400 px-1.5 py-0.5 rounded border border-emerald-500/30">🛡️ فیله و ستون فقرات</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۵</span>
                </div>
              </div>

              <!-- Start Button -->
              <button onclick="openWorkoutSessionModal(2)" class="w-full py-3 rounded-xl bg-[#CCFF00] hover:bg-[#b8e600] text-black font-black text-xs transition active:scale-95 flex items-center justify-center gap-2 shadow-lg shadow-[#CCFF00]/25 relative z-10">
                <svg class="w-4 h-4 text-black" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 5v14M18 5v14M2 9h4M18 9h4M2 15h4M18 15h4M6 12h12"/></svg>
                <span>ورود به تمرین زنده سینه و بازو (جلسه امروز) 🚀</span>
              </button>
            </div>

            <!-- Plan 3: Back & Shoulders (با آیکون و تصویر عضلات پشت و سرشانه) -->
            <div class="theme-card bg-[#141722] border border-[#252B3A] rounded-2xl p-4 space-y-3.5 transition hover:border-purple-500/50">
              <!-- Header with Muscle Anatomy Icon -->
              <div class="flex justify-between items-start gap-3 border-b border-[#1E2433] pb-3">
                <div class="flex items-center gap-3">
                  <!-- Back & Shoulders Anatomy Vector Badge -->
                  <div class="w-12 h-12 rounded-xl bg-purple-500/15 border border-purple-500/40 flex items-center justify-center shrink-0">
                    <svg viewBox="0 0 100 100" class="w-8 h-8 drop-shadow-[0_0_8px_rgba(168,85,247,0.4)]" fill="none" stroke="#A855F7" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M25 25 Q50 18 75 25 L88 38 C80 58 65 75 50 90 C35 75 20 58 12 38 Z" fill="#A855F7" fill-opacity="0.2" />
                      <path d="M22 36 Q38 48 50 38 Q62 48 78 36" stroke-width="2.5" />
                      <line x1="50" y1="20" x2="50" y2="88" stroke-width="3" />
                    </svg>
                  </div>
                  <div>
                    <div class="flex items-center gap-2">
                      <span class="text-[10px] bg-[#252B3A] text-gray-300 px-2 py-0.5 rounded font-bold">چهارشنبه</span>
                      <span class="text-[10px] bg-purple-500/15 text-purple-400 border border-purple-500/30 px-2 py-0.5 rounded font-bold">جلسه بعدی</span>
                    </div>
                    <h3 class="text-sm font-black text-white mt-1">برنامه شماره ۳: زیربغل، سرشانه، کول و شکم</h3>
                    <p class="text-[11px] text-purple-400 font-bold mt-0.5">🦅 عضلات هدف: پهنا و ضخامت لت (V-Taper)، سرشانه 3D و تراپز</p>
                  </div>
                </div>
              </div>

              <!-- Exercise List with Muscle Tags -->
              <div class="space-y-2">
                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۱</span>
                    <span class="font-bold text-gray-200">بارفیکس مچ برعکس (Chin-ups)</span>
                    <span class="text-[9px] bg-purple-500/15 text-purple-300 px-1.5 py-0.5 rounded border border-purple-500/30">🦅 پهنای زیربغل و لت</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۸</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۲</span>
                    <span class="font-bold text-gray-200">زیربغل قایقی میله V</span>
                    <span class="text-[9px] bg-purple-500/15 text-purple-300 px-1.5 py-0.5 rounded border border-purple-500/30">🦅 ضخامت لت میانی</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-purple-500/20 text-purple-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست سیم‌کش جلو + تی‌بار</span>
                    <span class="text-[9px] bg-purple-500/15 text-purple-300 px-1.5 py-0.5 rounded border border-purple-500/30">🦅 تفکیک کامل پشت</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-purple-300 bg-purple-500/10 px-2 py-0.5 rounded border border-purple-500/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۴</span>
                    <span class="font-bold text-gray-200">پرس سرشانه هالتر نظامی</span>
                    <span class="text-[9px] bg-[#00F0FF]/15 text-[#00F0FF] px-1.5 py-0.5 rounded border border-[#00F0FF]/30">🎯 دلتوئید قدامی و میانی</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-cyan-500/20 text-cyan-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست پرس دمبل آرنولدی + نشر جانب</span>
                    <span class="text-[9px] bg-[#00F0FF]/15 text-[#00F0FF] px-1.5 py-0.5 rounded border border-[#00F0FF]/30">🎯 گردی سرشانه 3D</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-cyan-300 bg-cyan-500/10 px-2 py-0.5 rounded border border-cyan-500/20">۳ × ۱۲</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۶</span>
                    <span class="font-bold text-gray-200">فلای معکوس دمبل + شراگز هالتر سنگین</span>
                    <span class="text-[9px] bg-amber-500/15 text-amber-300 px-1.5 py-0.5 rounded border border-amber-500/30">🎯 دلت خلفی و کول</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۵</span>
                </div>
              </div>

              <!-- Start Button -->
              <button onclick="openWorkoutSessionModal(3)" class="w-full py-2.5 rounded-xl bg-[#1D2230] hover:bg-[#CCFF00] hover:text-black text-gray-200 font-black text-xs transition active:scale-95 flex items-center justify-center gap-2 border border-[#2B354C]">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M6 5v14M18 5v14M2 9h4M18 9h4M2 15h4M18 15h4M6 12h12"/></svg>
                <span>شروع تمرین پشت و سرشانه (روز ۳)</span>
              </button>
            </div>

            <!-- Home Fallback Plan (با آیکون و تصویر کالیستنیکس خانگی) -->
            <div class="theme-card bg-gradient-to-r from-[#1A1822] to-[#141722] border border-orange-500/40 rounded-2xl p-4 space-y-3.5 shadow-lg shadow-orange-500/5">
              <div class="flex justify-between items-start gap-3 border-b border-[#252B3A] pb-3">
                <div class="flex items-center gap-3">
                  <!-- Home Workout Vector Badge -->
                  <div class="w-12 h-12 rounded-xl bg-orange-500/15 border border-orange-500/40 flex items-center justify-center shrink-0">
                    <svg viewBox="0 0 100 100" class="w-8 h-8 drop-shadow-[0_0_8px_rgba(249,115,22,0.4)]" fill="none" stroke="#F97316" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M20 70 L35 70 L45 50 L75 50 M75 50 L85 65" />
                      <circle cx="78" cy="38" r="6" fill="#F97316" fill-opacity="0.3" />
                      <line x1="20" y1="80" x2="80" y2="80" stroke-width="4" />
                    </svg>
                  </div>
                  <div>
                    <div class="flex items-center gap-2">
                      <span class="text-[10px] bg-orange-500/15 text-orange-400 border border-orange-500/30 px-2 py-0.5 rounded font-bold">تمرین خانگی</span>
                      <span class="text-[10px] bg-[#252B3A] text-gray-300 px-2 py-0.5 rounded font-bold">بدون نیاز به وزنه</span>
                    </div>
                    <h3 class="text-sm font-black text-orange-400 mt-1">برنامه بدون وزنه در خانه (Full-Body)</h3>
                    <p class="text-[11px] text-gray-400 mt-0.5">🏠 عضلات هدف: سینه، پشت‌بازو، پا و میان‌تنه با وزن بدن</p>
                  </div>
                </div>
              </div>

              <div class="flex flex-wrap gap-1.5 text-[11px]">
                <span class="bg-[#0F121C] text-gray-300 px-2.5 py-1 rounded-lg border border-zinc-800">🎯 شنا سوئدی</span>
                <span class="bg-[#0F121C] text-gray-300 px-2.5 py-1 rounded-lg border border-zinc-800">🎯 شنا پاهای بالا</span>
                <span class="bg-[#0F121C] text-gray-300 px-2.5 py-1 rounded-lg border border-zinc-800">🦵 اسکوات تک‌پا</span>
                <span class="bg-[#0F121C] text-gray-300 px-2.5 py-1 rounded-lg border border-zinc-800">💪 دیپ لبه صندلی</span>
                <span class="bg-[#0F121C] text-gray-300 px-2.5 py-1 rounded-lg border border-zinc-800">⚡ پلانک شکم</span>
              </div>

              <!-- Start Button -->
              <button onclick="openWorkoutSessionModal(4)" class="w-full py-2.5 rounded-xl bg-orange-500 hover:bg-orange-600 text-black font-black text-xs transition active:scale-95 shadow-lg shadow-orange-500/20">
                شروع تمرین خانگی (روز ۴)
              </button>
            </div>
          </section>
'''

html = html[:card1_start] + NEW_WORKOUT_PLANS_HTML + html[idx_pw_end:]
print("Workout plans cards updated successfully with muscle anatomy icons!")

# ==============================================================================
# 2. UPGRADE WORKOUT PLAYER MODAL CONTAINER TO fixed/absolute z-[100] & overflow-y-auto
# ==============================================================================
modal_div_pattern = re.compile(
    r'<div id="workoutPlayerModal" class="[^"]*">'
)

html = modal_div_pattern.sub(
    '<div id="workoutPlayerModal" class="theme-surface fixed inset-0 md:absolute md:inset-0 bg-[#08090C] z-[100] flex flex-col overflow-y-auto p-4 hidden">',
    html,
    count=1
)
print("workoutPlayerModal container updated with z-[100] and overflow-y-auto!")

# ==============================================================================
# 3. WRITE THE COMPLETE RELIABLE JAVASCRIPT CONTROLLER (TIMER + ENGINE + MUSCLES)
# ==============================================================================
# Find existing WORKOUT_PLANS in <script> and replace down to finishWorkoutSession
engine_start = html.find('const WORKOUT_PLANS = {')
engine_end = html.find('function closeFoodScannerModal()')
assert engine_start != -1 and engine_end != -1, "Engine markers not found in HTML!"

NEW_JS_ENGINE = '''const WORKOUT_PLANS = {
      1: {
        title: "برنامه شماره ۱: پا و شکم (Legs & Core)",
        warmupTag: "پا، زانو و کور",
        warmupItems: [
          "۱۰ دقیقه تردمیل شیبدار برای جریان خون پاها",
          "۵ دقیقه چرخش فعال مفاصل مچ پا و زانوها",
          "۲ ست اسکوات وزن بدن برای کشش کپسول مفصلی"
        ],
        exercises: [
          {
            id: "d1_e1",
            name: "اسکوات هالتر آزاد (Barbell Squat)",
            muscleGroup: "leg",
            muscle: "چهارسر ران، باسن (Glutes) و عضلات کور",
            secondary: "همسترینگ، دوقلو ساق و فیله کمر",
            equipment: "هالتر المپیکی + رک اسکوات",
            restSec: 120,
            sets: [
              { num: 1, text: "۷۰kg × ۱۰ تکرار", weight: 70, reps: 10, done: false },
              { num: 2, text: "۸۰kg × ۱۰ تکرار", weight: 80, reps: 10, done: false },
              { num: 3, text: "۹۰kg × ۱۰ تکرار", weight: 90, reps: 10, done: false }
            ]
          },
          {
            id: "d1_e2",
            name: "پرس پا زاویه ۴۵ درجه (Leg Press)",
            muscleGroup: "leg",
            muscle: "چهارسر ران و همسترینگ",
            secondary: "گلوتئوس ماکسیموس",
            equipment: "دستگاه پرس پا زاویه‌دار",
            restSec: 90,
            sets: [
              { num: 1, text: "۱۴۰kg × ۱۰ تکرار", weight: 140, reps: 10, done: false },
              { num: 2, text: "۱۶۰kg × ۱۰ تکرار", weight: 160, reps: 10, done: false },
              { num: 3, text: "۱۸۰kg × ۱۰ تکرار", weight: 180, reps: 10, done: false }
            ]
          },
          {
            id: "d1_e3",
            name: "سوپرست جلوپا + پشت‌پا دستگاه",
            muscleGroup: "leg",
            muscle: "چهارسر ران و عضله دوسر رانی (همسترینگ)",
            secondary: "ساق پا و باسن",
            equipment: "دستگاه اکستنشن و لگ کرال",
            restSec: 90,
            sets: [
              { num: 1, text: "۴۵kg × ۱۵ + ۴۰kg × ۱۵", weight: 85, reps: 15, done: false },
              { num: 2, text: "۵۰kg × ۱۵ + ۴۵kg × ۱۵", weight: 95, reps: 15, done: false },
              { num: 3, text: "۵۵kg × ۱۵ + ۵۰kg × ۱۵", weight: 105, reps: 15, done: false }
            ]
          },
          {
            id: "d1_e4",
            name: "ددلیفت رومانیایی دمبل (Romanian Deadlift)",
            muscleGroup: "leg",
            muscle: "همسترینگ و باسن (Gluteus)",
            secondary: "فیله کمر و مچ دست",
            equipment: "جفت دمبل سنگین",
            restSec: 90,
            sets: [
              { num: 1, text: "۲۴kg × ۸ تکرار هر دمبل", weight: 48, reps: 8, done: false },
              { num: 2, text: "۲۸kg × ۸ تکرار هر دمبل", weight: 56, reps: 8, done: false },
              { num: 3, text: "۳۲kg × ۸ تکرار هر دمبل", weight: 64, reps: 8, done: false }
            ]
          },
          {
            id: "d1_e5",
            name: "ساق پا هاگ ایستاده (Standing Calf Raise)",
            muscleGroup: "leg",
            muscle: "عضله دوقلو ساق و عضله نعلی (Calves)",
            secondary: "مچ پا و تاندون آشیل",
            equipment: "دستگاه هاگ یا ساق ایستاده",
            restSec: 60,
            sets: [
              { num: 1, text: "۶۰kg × ۲۰ تکرار", weight: 60, reps: 20, done: false },
              { num: 2, text: "۷۰kg × ۲۰ تکرار", weight: 70, reps: 20, done: false },
              { num: 3, text: "۸۰kg × ۲۰ تکرار", weight: 80, reps: 20, done: false }
            ]
          },
          {
            id: "d1_e6",
            name: "سوپرست پلانک شکم + کرانچ شیب",
            muscleGroup: "core",
            muscle: "راست شکمی، مایل شکمی و هسته مرکزی",
            secondary: "فیله کمر و لگن",
            equipment: "مت یوگا + میز شیبدار",
            restSec: 60,
            sets: [
              { num: 1, text: "۶۰ ثانیه پلانک + ۲۰ کرانچ", weight: 0, reps: 20, done: false },
              { num: 2, text: "۶۰ ثانیه پلانک + ۲۰ کرانچ", weight: 0, reps: 20, done: false },
              { num: 3, text: "۶۰ ثانیه پلانک + ۲۰ کرانچ", weight: 0, reps: 20, done: false }
            ]
          }
        ]
      },

      2: {
        title: "برنامه شماره ۲: سینه، بازو و فیله کمر (Chest & Arms)",
        warmupTag: "سینه، روتاتور کاف و آرنج",
        warmupItems: [
          "۵ دقیقه چرخش دست و چرخش روتاتور کاف با کش",
          "۲ ست شنا سوئدی کنترل‌شده برای گرم‌کردن سینه",
          "۱ ست سبک پرس سینه با میله خالی هالتر (۲۰ تکرار)"
        ],
        exercises: [
          {
            id: "d2_e1",
            name: "پرس سینه هالتر هرمی (Barbell Bench Press)",
            muscleGroup: "chest",
            muscle: "پکتورالیس ماژور (سینه میانی و کلی)",
            secondary: "دلتوئید قدامی و پشت‌بازو (Triceps)",
            equipment: "هالتر المپیکی + نیمکت پرس سینه",
            restSec: 120,
            sets: [
              { num: 1, text: "۷۰kg × ۱۲ تکرار (گرم‌کردن)", weight: 70, reps: 12, done: true },
              { num: 2, text: "۸۰kg × ۱۰ تکرار (ست اصلی)", weight: 80, reps: 10, done: false },
              { num: 3, text: "۸۵kg × ۸ تکرار (فشار اوج)", weight: 85, reps: 8, done: false },
              { num: 4, text: "۹۰kg × ۶ تکرار (سنگین‌ترین)", weight: 90, reps: 6, done: false }
            ]
          },
          {
            id: "d2_e2",
            name: "قفسه بالاسینه دمبل موازی (Incline DB Flye)",
            muscleGroup: "chest",
            muscle: "بالاسینه و اتصال ترقوه‌ای (Upper Pectorals)",
            secondary: "دلتوئید قدامی و خط وسط سینه",
            equipment: "جفت دمبل + میز بالاسینه ۳۰ درجه",
            restSec: 90,
            sets: [
              { num: 1, text: "۱۸kg × ۱۰ تکرار", weight: 36, reps: 10, done: false },
              { num: 2, text: "۲۰kg × ۱۰ تکرار", weight: 40, reps: 10, done: false },
              { num: 3, text: "۲۲kg × ۱۰ تکرار", weight: 44, reps: 10, done: false }
            ]
          },
          {
            id: "d2_e3",
            name: "سوپرست بالاسینه دمبل + شنا سوئدی",
            muscleGroup: "chest",
            muscle: "حجم بالاسینه و تفکیک خط سینه",
            secondary: "پشت‌بازو و سرشانه",
            equipment: "دمبل + زمین تمرین",
            restSec: 90,
            sets: [
              { num: 1, text: "۲۴kg × ۱۲ + ۱۲ شنا سوئدی", weight: 48, reps: 12, done: false },
              { num: 2, text: "۲۶kg × ۱۲ + ۱۰ شنا سوئدی", weight: 52, reps: 12, done: false },
              { num: 3, text: "۲۸kg × ۱۲ + ۱۰ شنا سوئدی", weight: 56, reps: 12, done: false }
            ]
          },
          {
            id: "d2_e4",
            name: "پارالل سینه وزن بدن (Chest Dips)",
            muscleGroup: "chest",
            muscle: "زیرسینه و خط زیرین پکتورال",
            secondary: "پشت‌بازو و سرشانه قدامی",
            equipment: "میله پارالل بدنسازی",
            restSec: 90,
            sets: [
              { num: 1, text: "وزن بدن (۷۳kg) × ۱۰ تکرار", weight: 73, reps: 10, done: false },
              { num: 2, text: "وزن بدن (۷۳kg) × ۱۰ تکرار", weight: 73, reps: 10, done: false },
              { num: 3, text: "وزن بدن (۷۳kg) × ۱۰ تکرار", weight: 73, reps: 10, done: false }
            ]
          },
          {
            id: "d2_e5",
            name: "سوپرست جلوبازو هالتر EZ + پشت‌بازو طناب",
            muscleGroup: "arm",
            muscle: "دوسر بازویی (Biceps) و سه‌سر بازویی (Triceps)",
            secondary: "ساعد و مچ دست",
            equipment: "هالتر EZ و قرقره سیم‌کش",
            restSec: 75,
            sets: [
              { num: 1, text: "۳۰kg × ۱۲ + ۴۰kg × ۱۲", weight: 70, reps: 12, done: false },
              { num: 2, text: "۳۵kg × ۱۲ + ۴۵kg × ۱۲", weight: 80, reps: 12, done: false },
              { num: 3, text: "۳۵kg × ۱۲ + ۵۰kg × ۱۲", weight: 85, reps: 12, done: false }
            ]
          },
          {
            id: "d2_e6",
            name: "هایپراکستنشن فیله کمر (Hyperextensions)",
            muscleGroup: "core",
            muscle: "راست‌کننده ستون فقرات و فیله کمر (Erectors)",
            secondary: "عضلات باسن و همسترینگ",
            equipment: "نیمکت فیله کمر ۴۵ درجه",
            restSec: 60,
            sets: [
              { num: 1, text: "۱۰kg صفحه × ۱۵ تکرار", weight: 10, reps: 15, done: false },
              { num: 2, text: "۱۵kg صفحه × ۱۵ تکرار", weight: 15, reps: 15, done: false },
              { num: 3, text: "۱۵kg صفحه × ۱۵ تکرار", weight: 15, reps: 15, done: false }
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
            muscleGroup: "back",
            muscle: "زیربغل، پهنای لت و جلوبازو",
            secondary: "گرد بزرگ و دلتوئید خلفی",
            equipment: "میله بارفیکس استاندارد",
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
            muscleGroup: "back",
            muscle: "ضخامت لت و زیربغل میانی (Mid-Back)",
            secondary: "متوازی‌الاضلاع (Rhomboids) و جلوبازو",
            equipment: "دستگاه سیم‌کش قایقی",
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
            muscleGroup: "back",
            muscle: "پهنا و ضخامت کامل عضلات پشتی (V-Taper)",
            secondary: "تراپز میانی و گرد بزرگ",
            equipment: "دستگاه لت و هالتر T-Bar",
            restSec: 90,
            sets: [
              { num: 1, text: "۵۵kg × ۱۰ + ۴۰kg × ۱۰", weight: 95, reps: 10, done: false },
              { num: 2, text: "۶۰kg × ۱۰ + ۴۵kg × ۱۰", weight: 105, reps: 10, done: false },
              { num: 3, text: "۶۵kg × ۱۰ + ۵۰kg × ۱۰", weight: 115, reps: 10, done: false }
            ]
          },
          {
            id: "d3_e4",
            name: "پرس سرشانه هالتر نظامی (Military Press)",
            muscleGroup: "shoulder",
            muscle: "دلتوئید قدامی و میانی سرشانه",
            secondary: "پشت‌بازو و بخش فوقانی سینه",
            equipment: "هالتر صاف + رک سرشانه",
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
            muscleGroup: "shoulder",
            muscle: "گردی و حجم سرشانه 3D (Lateral Delts)",
            secondary: "دلتوئید قدامی و خلفی",
            equipment: "جفت دمبل متغیر",
            restSec: 75,
            sets: [
              { num: 1, text: "۱۶kg × ۱۲ + ۸kg × ۱۲", weight: 48, reps: 12, done: false },
              { num: 2, text: "۱۸kg × ۱۲ + ۹kg × ۱۲", weight: 54, reps: 12, done: false },
              { num: 3, text: "۲۰kg × ۱۲ + ۱۰kg × ۱۲", weight: 60, reps: 12, done: false }
            ]
          },
          {
            id: "d3_e6",
            name: "فلای معکوس دمبل + شراگز هالتر سنگین",
            muscleGroup: "back",
            muscle: "دلتوئید خلفی و عضلات کول و تراپز (Trapezius)",
            secondary: "متوازی‌الاضلاع و گرد کوچک",
            equipment: "دمبل شیبدار + هالتر المپیکی",
            restSec: 75,
            sets: [
              { num: 1, text: "۱۰kg × ۱۵ + ۸۰kg × ۱۵", weight: 100, reps: 15, done: false },
              { num: 2, text: "۱۲kg × ۱۵ + ۹۰kg × ۱۵", weight: 114, reps: 15, done: false },
              { num: 3, text: "۱۴kg × ۱۵ + ۱۰۰kg × ۱۵", weight: 128, reps: 15, done: false }
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
            muscleGroup: "chest",
            muscle: "سینه و پشت‌بازو",
            secondary: "دلتوئید قدامی و شکم",
            equipment: "وزن بدن (بدون تجهیزات)",
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
            muscleGroup: "chest",
            muscle: "بالاسینه و سرشانه",
            secondary: "پشت‌بازو و کور",
            equipment: "صندلی یا لبه تخت",
            restSec: 60,
            sets: [
              { num: 1, text: "وزن بدن × ۱۲ تکرار", weight: 0, reps: 12, done: false },
              { num: 2, text: "وزن بدن × ۱۲ تکرار", weight: 0, reps: 12, done: false },
              { num: 3, text: "وزن بدن × ۱۲ تکرار", weight: 0, reps: 12, done: false }
            ]
          },
          {
            id: "d4_e3",
            name: "اسکوات تک‌پا / اسکوات بلغاری لبه مبل",
            muscleGroup: "leg",
            muscle: "چهارسر ران و باسن",
            secondary: "همسترینگ و تعادل",
            equipment: "لبه مبل یا صندلی",
            restSec: 60,
            sets: [
              { num: 1, text: "وزن بدن × ۱۰ تکرار هر پا", weight: 0, reps: 10, done: false },
              { num: 2, text: "وزن بدن × ۱۰ تکرار هر پا", weight: 0, reps: 10, done: false },
              { num: 3, text: "وزن بدن × ۱۰ تکرار هر پا", weight: 0, reps: 10, done: false }
            ]
          },
          {
            id: "d4_e4",
            name: "دیپ لبه تخت یا صندلی (Chair Dips)",
            muscleGroup: "arm",
            muscle: "پشت‌بازو (Triceps)",
            secondary: "زیرسینه و سرشانه قدامی",
            equipment: "لبه صندلی یا تخت",
            restSec: 60,
            sets: [
              { num: 1, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false },
              { num: 2, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false },
              { num: 3, text: "وزن بدن × ۱۵ تکرار", weight: 0, reps: 15, done: false }
            ]
          },
          {
            id: "d4_e5",
            name: "سوپرست پلانک کلاسیک + حرکت کوهنورد",
            muscleGroup: "core",
            muscle: "شکم و استقامت کل بدن",
            secondary: "شانه و ران",
            equipment: "زمین تمرین",
            restSec: 60,
            sets: [
              { num: 1, text: "۴۵ ثانیه پلانک + ۲۰ کوهنورد", weight: 0, reps: 20, done: false },
              { num: 2, text: "۴۵ ثانیه پلانک + ۲۰ کوهنورد", weight: 0, reps: 20, done: false },
              { num: 3, text: "۴۵ ثانیه پلانک + ۲۰ کوهنورد", weight: 0, reps: 20, done: false }
            ]
          }
        ]
      }
    };

    let activePlanId = 2;
    let activeExerciseIndex = 0;
    let sessionSecondsElapsed = 765;
    let sessionTimerInterval = null;

    // CHRONOMETER / REST TIMER STATE & FUNCTIONS
    let timerTargetSeconds = 90;
    let timerRemainingSeconds = 90;
    let restTimerInterval = null;

    function formatTimerSeconds(sec) {
      const m = String(Math.floor(sec / 60)).padStart(2, '0');
      const s = String(sec % 60).padStart(2, '0');
      return `${m}:${s}`.replace(/0/g, '۰').replace(/1/g, '۱').replace(/2/g, '۲').replace(/3/g, '۳').replace(/4/g, '۴').replace(/5/g, '۵').replace(/6/g, '۶').replace(/7/g, '۷').replace(/8/g, '۸').replace(/9/g, '۹');
    }

    function updateTimerDisplay() {
      const el = document.getElementById('stopwatchDisplay');
      if (el) {
        el.textContent = formatTimerSeconds(timerRemainingSeconds);
      }
    }

    function startTimerManual() {
      try { soundClick(); } catch(e) {}
      if (restTimerInterval) return;
      restTimerInterval = setInterval(() => {
        if (timerRemainingSeconds > 0) {
          timerRemainingSeconds--;
          updateTimerDisplay();
          if (timerRemainingSeconds === 0) {
            clearInterval(restTimerInterval);
            restTimerInterval = null;
            try { soundSuccess(); } catch(e) {}
          }
        } else {
          clearInterval(restTimerInterval);
          restTimerInterval = null;
        }
      }, 1000);
    }

    function pauseTimerManual() {
      try { soundClick(); } catch(e) {}
      if (restTimerInterval) {
        clearInterval(restTimerInterval);
        restTimerInterval = null;
      }
    }

    function resetTimerManual() {
      pauseTimerManual();
      timerRemainingSeconds = timerTargetSeconds;
      updateTimerDisplay();
    }

    function setTimerDuration(seconds) {
      try { soundClick(); } catch(e) {}
      timerTargetSeconds = seconds;
      resetTimerManual();
    }

    // ==============================================================================
    // WORKOUT PLAYER MODAL CONTROLLERS
    // ==============================================================================

    function openWorkoutSessionModal(dayNumber) {
      try { soundClick(); } catch(e) {}
      activePlanId = parseInt(dayNumber) || 2;
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

      // Force display modal safely
      const modal = document.getElementById('workoutPlayerModal');
      if (modal) {
        modal.classList.remove('hidden');
        modal.style.display = 'flex';
        modal.scrollTop = 0;
      }
      try { updateIslandState('<span class="text-[#CCFF00]">جلسه فعال</span>', true); } catch(e) {}
    }

    function closeWorkoutPlayer() {
      try { pauseTimerManual(); } catch(e) {}
      if (sessionTimerInterval) {
        clearInterval(sessionTimerInterval);
        sessionTimerInterval = null;
      }
      const modal = document.getElementById('workoutPlayerModal');
      if (modal) {
        modal.classList.add('hidden');
        modal.style.display = 'none';
      }
      try { updateIslandState('<span>GymBro</span>', false); } catch(e) {}
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
      try { soundClick(); } catch(e) {}
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

    function getMuscleSvg(muscleGroup) {
      if (muscleGroup === 'leg') {
        return `<svg viewBox="0 0 100 100" class="w-10 h-10 drop-shadow-[0_0_8px_rgba(204,255,0,0.5)] shrink-0" fill="none" stroke="#CCFF00" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <path d="M30 18 L38 48 L35 75 L30 92 M40 92 L36 76" />
          <path d="M70 18 L62 48 L65 75 L70 92 M60 92 L64 76" />
          <circle cx="37" cy="52" r="5" fill="#CCFF00" fill-opacity="0.3" />
          <circle cx="63" cy="52" r="5" fill="#CCFF00" fill-opacity="0.3" />
        </svg>`;
      } else if (muscleGroup === 'arm') {
        return `<svg viewBox="0 0 100 100" class="w-10 h-10 drop-shadow-[0_0_8px_rgba(0,240,255,0.5)] shrink-0" fill="none" stroke="#00F0FF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <path d="M20 70 L38 52 C45 38 60 38 68 45 L85 30 L90 42 L72 62 C65 72 45 78 30 78 Z" fill="#00F0FF" fill-opacity="0.2" />
          <path d="M42 45 Q52 28 64 42" stroke-width="3.5" />
          <circle cx="52" cy="38" r="6" fill="#00F0FF" fill-opacity="0.4" />
        </svg>`;
      } else if (muscleGroup === 'chest') {
        return `<svg viewBox="0 0 100 100" class="w-10 h-10 drop-shadow-[0_0_8px_rgba(255,153,0,0.5)] shrink-0" fill="none" stroke="#FF9900" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <path d="M20 38 C32 40 46 50 48 68 C35 72 20 62 18 45 Z" fill="#FF9900" fill-opacity="0.25" />
          <path d="M80 38 C68 40 54 50 52 68 C65 72 80 62 82 45 Z" fill="#FF9900" fill-opacity="0.25" />
          <line x1="50" y1="36" x2="50" y2="72" stroke-width="3" />
        </svg>`;
      } else if (muscleGroup === 'shoulder') {
        return `<svg viewBox="0 0 100 100" class="w-10 h-10 drop-shadow-[0_0_8px_rgba(0,240,255,0.5)] shrink-0" fill="none" stroke="#00F0FF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <path d="M20 50 Q50 25 80 50 L70 70 Q50 60 30 70 Z" fill="#00F0FF" fill-opacity="0.2" />
          <circle cx="28" cy="50" r="5" fill="#00F0FF" fill-opacity="0.4" />
          <circle cx="72" cy="50" r="5" fill="#00F0FF" fill-opacity="0.4" />
        </svg>`;
      } else {
        // Back / Core
        return `<svg viewBox="0 0 100 100" class="w-10 h-10 drop-shadow-[0_0_8px_rgba(168,85,247,0.5)] shrink-0" fill="none" stroke="#A855F7" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <path d="M25 25 Q50 18 75 25 L88 38 C80 58 65 75 50 90 C35 75 20 58 12 38 Z" fill="#A855F7" fill-opacity="0.2" />
          <path d="M22 36 Q38 48 50 38 Q62 48 78 36" stroke-width="2.5" />
          <line x1="50" y1="20" x2="50" y2="88" stroke-width="3" />
        </svg>`;
      }
    }

    function renderActiveExercise() {
      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      const ex = plan.exercises[activeExerciseIndex];
      const container = document.getElementById('activeExerciseCard');
      if (!container || !ex) return;

      const muscleSvg = getMuscleSvg(ex.muscleGroup);

      container.innerHTML = `
        <!-- Muscle Anatomy Visual Card Header -->
        <div class="flex justify-between items-start gap-3 bg-[#0C0F17] p-3 rounded-xl border border-zinc-800">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-xl bg-[#141722] border border-[#252B3A] flex items-center justify-center shrink-0">
              ${muscleSvg}
            </div>
            <div>
              <div class="flex items-center gap-2">
                <span class="w-5 h-5 rounded bg-[#CCFF00] text-black font-black text-xs flex items-center justify-center">${activeExerciseIndex + 1}</span>
                <h4 class="theme-text-primary text-sm font-black text-white">${ex.name}</h4>
              </div>
              <div class="text-[10px] text-gray-300 font-bold mt-1">
                عضله هدف اصلی: <span class="text-[#CCFF00]">${ex.muscle}</span>
              </div>
              <div class="text-[9px] text-gray-400 mt-0.5">
                عضلات کمکی: <span>${ex.secondary || 'هسته بدن'}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="flex items-center justify-between text-[10px] text-gray-400 px-1 pt-1">
          <span class="bg-[#141722] px-2 py-0.5 rounded border border-[#252B3A] text-gray-300 font-bold">🛠️ ${ex.equipment}</span>
          <span class="bg-[#CCFF00]/15 text-[#CCFF00] px-2 py-0.5 rounded border border-[#CCFF00]/30 font-bold">⏱️ استراحت استاندارد: ${ex.restSec} ثانیه</span>
        </div>

        <!-- Sets Table -->
        <div class="space-y-2 text-xs pt-1">
          ${ex.sets.map((set, setIdx) => `
            <div onclick="toggleSetCheck(${activeExerciseIndex}, ${setIdx})" class="theme-card-sub flex justify-between items-center bg-[#0E1118] hover:bg-[#161B26] p-2.5 rounded-xl border ${set.done ? 'border-emerald-500/50 bg-emerald-500/5' : 'border-zinc-800'} transition cursor-pointer select-none">
              <div class="text-gray-300 flex items-center gap-2">
                <span class="w-5 h-5 rounded-md ${set.done ? 'bg-emerald-500 text-black' : 'bg-[#252B3A] text-gray-300'} font-black text-[10px] flex items-center justify-center">${set.num}</span>
                <span class="${set.done ? 'line-through text-gray-500 font-normal' : 'text-gray-100 font-bold'}">${set.text}</span>
              </div>
              <input type="checkbox" ${set.done ? 'checked' : ''} onclick="event.stopPropagation(); toggleSetCheck(${activeExerciseIndex}, ${setIdx})" class="w-5 h-5 accent-[#CCFF00] cursor-pointer">
            </div>
          `).join('')}
        </div>
      `;

      // Set Chronograph rest timer to this exercise's restSec safely
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
      try { soundClick(); } catch(e) {}
      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      const set = plan.exercises[exIdx].sets[setIdx];
      set.done = !set.done;

      if (set.done) {
        try { soundSuccess(); } catch(e) {}
        // Auto-start rest timer
        resetTimerManual();
        startTimerManual();
      }

      renderExerciseTabs();
      renderActiveExercise();
      recalcSessionTonnage();
    }

    function recalcSessionTonnage() {
      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      let totalKg = 0;
      let totalCompletedSets = 0;

      plan.exercises.forEach(ex => {
        ex.sets.forEach(s => {
          if (s.done) {
            totalCompletedSets++;
            totalKg += (s.weight * s.reps);
          }
        });
      });

      const tonnageDisp = document.getElementById('sessionTonnageDisplay');
      if (tonnageDisp) {
        tonnageDisp.textContent = `${totalKg.toLocaleString('fa-IR')} kg`;
      }
    }

    function closeCelebrationModal() {
      const modal = document.getElementById('workoutCelebrationModal');
      if (modal) {
        modal.classList.add('hidden');
        modal.style.display = 'none';
      }
    }

    function finishWorkoutSession() {
      try { soundSuccess(); } catch(e) {}
      closeWorkoutPlayer();

      const plan = WORKOUT_PLANS[activePlanId] || WORKOUT_PLANS[2];
      let totalKg = 0;
      let totalCompletedSets = 0;
      plan.exercises.forEach(ex => {
        ex.sets.forEach(s => {
          if (s.done) {
            totalCompletedSets++;
            totalKg += (s.weight * s.reps);
          }
        });
      });

      const tonEl = document.getElementById('celebrationTonnageText');
      if (tonEl) tonEl.textContent = `${totalKg.toLocaleString('fa-IR')} کیلوگرم`;

      const setEl = document.getElementById('celebrationSetsText');
      if (setEl) setEl.textContent = `${totalCompletedSets.toLocaleString('fa-IR')} ست`;

      const modal = document.getElementById('workoutCelebrationModal');
      if (modal) {
        modal.classList.remove('hidden');
        modal.style.display = 'flex';
      }
    }

    '''

html = html[:engine_start] + NEW_JS_ENGINE + html[engine_end:]
print("JavaScript engine replaced with full timer, muscle icons, and safe execution!")

with open('gymbro_redmi_simulator.html', 'w', encoding='utf-8') as f:
    f.write(html)

print("gymbro_redmi_simulator.html saved successfully!")
