import re

def update_simulator():
    with open('gymbro_redmi_simulator.html', 'r', encoding='utf-8') as f:
        html = f.read()

    # 1. Update Workout Page
    workout_pattern = re.compile(
        r'(<section id="pageWorkout" class="p-4 space-y-4 pb-36 hidden">)(.*?)(</section>\s*<!-- ================= TAB 3: NUTRITION)',
        re.DOTALL
    )

    new_workout_html = r'''\1
            <!-- Header with Title & Active Program Details -->
            <div class="flex justify-between items-start">
              <div>
                <div class="flex items-center gap-2">
                  <span class="w-2 h-2 rounded-full bg-[#CCFF00] animate-pulse"></span>
                  <span class="text-[10px] font-black uppercase tracking-wider text-[#CCFF00]">برنامه فعال هفتگی</span>
                </div>
                <h2 class="theme-text-primary text-lg font-black text-white mt-0.5">برنامه تمرینی اختصاصی آرمین</h2>
                <p class="theme-text-muted text-xs text-gray-400">اسپلیت ۳ روزه هایپرتروفی • پروتکل مفاصل، گرم‌کردن و سردکردن</p>
              </div>
              <button onclick="openAiCoachModal()" class="px-3 py-1.5 rounded-xl bg-[#CCFF00]/15 text-[#CCFF00] border border-[#CCFF00]/30 hover:bg-[#CCFF00]/25 transition text-xs font-bold flex items-center gap-1.5 active:scale-95">
                <svg class="w-3.5 h-3.5 text-[#CCFF00]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/></svg>
                <span>مشاوره مربی</span>
              </button>
            </div>

            <!-- Private Coach Attribution Card (فیلد اختصاصی مربی خصوصی) -->
            <div class="theme-card bg-gradient-to-r from-[#141722] via-[#181D2C] to-[#141722] border border-[#2B354C] rounded-2xl p-3.5 flex items-center justify-between shadow-lg">
              <div class="flex items-center gap-3">
                <div class="relative">
                  <div class="w-11 h-11 rounded-full bg-gradient-to-tr from-[#CCFF00] to-[#00F0FF] p-0.5 flex items-center justify-center">
                    <div class="w-full h-full rounded-full bg-[#0E121B] flex items-center justify-center text-white font-black text-xs">
                      راد
                    </div>
                  </div>
                  <span class="absolute -bottom-1 -right-1 w-4 h-4 rounded-full bg-[#FFB800] text-black text-[9px] font-black flex items-center justify-center border border-black" title="مربی تایید شده IFBB Pro">✓</span>
                </div>
                <div>
                  <div class="flex items-center gap-1.5">
                    <span class="text-xs font-black text-white">استاد علیرضا راد</span>
                    <span class="text-[9px] font-bold bg-[#FFB800]/20 text-[#FFB800] px-1.5 py-0.5 rounded border border-[#FFB800]/40">مربی خصوصی شما</span>
                  </div>
                  <p class="text-[10px] text-gray-400 mt-0.5">مربی رسمی فدراسیون IFBB • برنامه اختصاصی هایپرتروفی و کات</p>
                </div>
              </div>
              <button onclick="toggleCoachPrivateNotes()" class="px-2.5 py-1.5 rounded-lg bg-[#252B3A] hover:bg-[#323A4E] text-gray-300 hover:text-white text-[11px] font-bold transition flex items-center gap-1">
                <svg class="w-3.5 h-3.5 text-[#CCFF00]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                <span>توصیه‌ها</span>
              </button>
            </div>

            <!-- Coach Private Notes Dropdown (Collapsible) -->
            <div id="coachPrivateNotesPanel" class="hidden theme-card bg-[#0E131E] border border-[#252B3A] rounded-2xl p-3.5 space-y-2 text-xs">
              <div class="flex items-center gap-1.5 text-[#CCFF00] font-bold text-[11px]">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <span>دستورالعمل‌های خصوصی مربی برای آرمین:</span>
              </div>
              <ul class="text-[11px] text-gray-300 space-y-1.5 pr-4 list-disc marker:text-[#CCFF00] leading-relaxed">
                <li>کنترل فاز منفی (Eccentric) به مدت ۲ ثانیه در حرکات اسکوات و پرس سینه.</li>
                <li>استراحت بین ست‌های سنگین ۹۰ الی ۱۲۰ ثانیه و بین سوپرست‌ها ۶۰ ثانیه.</li>
                <li>مصرف حداقل ۷۵۰ میلی‌لیتر آب الکترولیت‌دار حین هر جلسه تمرینی.</li>
                <li>۵ دقیقه گرم‌کردن پویا قبل از بارگذاری و کشش ایستا پس از پایان تمرین.</li>
              </ul>
            </div>

            <!-- Workout Day 1 -->
            <div class="theme-card bg-[#141722] border border-[#252B3A] hover:border-[#38435C] rounded-2xl p-4 space-y-3.5 transition-all shadow-md">
              <div class="flex justify-between items-start">
                <div>
                  <div class="flex items-center gap-2">
                    <span class="text-xs font-black text-white">برنامه شماره ۱: پا و شکم (Legs & Core)</span>
                    <span class="theme-card-sub text-[10px] bg-zinc-800 text-gray-300 px-2 py-0.5 rounded-md font-bold">شنبه</span>
                  </div>
                  <div class="flex items-center gap-2 mt-1 text-[11px] text-gray-400">
                    <span class="flex items-center gap-1">⏱️ ۵۰ دقیقه</span>
                    <span>•</span>
                    <span class="flex items-center gap-1 text-[#00F0FF]">🔥 ۴۵۰ کالری</span>
                    <span>•</span>
                    <span class="text-gray-300">۶ حرکت تخصصی</span>
                  </div>
                </div>
                <span class="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">تکمیل شده</span>
              </div>

              <!-- Structured Exercise Pills List -->
              <div class="space-y-1.5 pt-1">
                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۱</span>
                    <span class="font-bold text-gray-200">اسکوات هالتر استاندارد</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۲</span>
                    <span class="font-bold text-gray-200">پرس پا دستگاه شیبدار</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۳</span>
                    <span class="font-bold text-gray-200">ددلیفت رومانیایی دمبل</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۸</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-purple-500/20 text-purple-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست جلوپا + پشت‌پا دستگاه</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-purple-300 bg-purple-500/10 px-2 py-0.5 rounded border border-purple-500/20">۳ × ۱۵</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۵</span>
                    <span class="font-bold text-gray-200">ساق پا هاگ دستگاه</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۲۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-cyan-500/20 text-cyan-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست پلنک و شکم شیب</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-cyan-300 bg-cyan-500/10 px-2 py-0.5 rounded border border-cyan-500/20">۳ × ۶۰s</span>
                </div>
              </div>

              <!-- Warmup & Cooldown Pill -->
              <div class="flex items-center gap-2 text-[10px] text-gray-400 bg-[#0A0D14] p-2 rounded-xl border border-zinc-800/80">
                <span class="text-[#CCFF00]">🏃‍♂️ گرم‌کردن:</span>
                <span>۵ دقیقه تردمیل شیبدار + چرخش فعال مفاصل زانو و مچ پا</span>
              </div>

              <button onclick="openWorkoutSessionModal(1)" class="w-full py-2.5 rounded-xl bg-[#1D2230] hover:bg-[#CCFF00] hover:text-black text-gray-200 font-black text-xs transition active:scale-95 flex items-center justify-center gap-2 border border-[#2B354C]">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M6 5v14M18 5v14M2 9h4M18 9h4M2 15h4M18 15h4M6 12h12"/></svg>
                <span>مرور و شروع مجدد تمرین پا و شکم</span>
              </button>
            </div>

            <!-- Workout Day 2 (Active Today Highlight) -->
            <div class="theme-card bg-gradient-to-b from-[#161B28] to-[#121622] border-2 border-[#CCFF00] rounded-2xl p-4 space-y-3.5 shadow-xl shadow-[#CCFF00]/10 relative overflow-hidden">
              <div class="absolute top-0 left-0 w-24 h-24 bg-[#CCFF00]/10 rounded-full blur-2xl pointer-events-none"></div>
              
              <div class="flex justify-between items-start relative z-10">
                <div>
                  <div class="flex items-center gap-2">
                    <span class="text-sm font-black text-white">برنامه شماره ۲: سینه، بازو و فیله کمر</span>
                  </div>
                  <div class="flex items-center gap-2 mt-1 text-[11px] text-gray-300">
                    <span class="flex items-center gap-1 font-bold text-white">⏱️ ۴۵ دقیقه</span>
                    <span>•</span>
                    <span class="flex items-center gap-1 text-[#00F0FF] font-bold">🔥 ۵۲۰ کالری</span>
                    <span>•</span>
                    <span class="text-gray-300">۶ حرکت هایپرتروفی</span>
                  </div>
                </div>
                <span class="text-[11px] bg-[#CCFF00] text-black font-black px-2.5 py-1 rounded-lg flex items-center gap-1 shadow-md shadow-[#CCFF00]/30 animate-pulse">
                  <span>جلسه امروز</span>
                  <span>🔥</span>
                </span>
              </div>

              <!-- Structured Exercise Pills List -->
              <div class="space-y-1.5 pt-1 relative z-10">
                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0D1018] border border-[#252B3A] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#CCFF00] text-black flex items-center justify-center text-[10px] font-black">۱</span>
                    <div>
                      <span class="font-black text-white">پرس سینه هالتر هرمی</span>
                      <span class="text-[10px] text-gray-400 block sm:inline sm:mr-1">افزایش وزنه در هر ست</span>
                    </div>
                  </div>
                  <span class="text-[11px] font-mono font-black text-[#CCFF00] bg-[#CCFF00]/15 px-2 py-0.5 rounded border border-[#CCFF00]/30">۴ × ۱۲-۱۰-۸-۶</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0D1018] border border-[#252B3A] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۲</span>
                    <span class="font-bold text-gray-200">قفسه بالاسینه کراس‌اور</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0D1018] border border-[#252B3A] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-purple-500/20 text-purple-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <div>
                      <span class="font-bold text-gray-200">سوپرست بالاسینه دمبل + شنا سوئدی</span>
                      <span class="text-[10px] text-purple-300 block">پمپ خون و استرس متابولیک</span>
                    </div>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-purple-300 bg-purple-500/10 px-2 py-0.5 rounded border border-purple-500/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0D1018] border border-[#252B3A] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۴</span>
                    <span class="font-bold text-gray-200">پرس سینه دستگاه ماتریکس</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0D1018] border border-[#252B3A] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-cyan-500/20 text-cyan-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست‌های بازو (جلو بازو + دیپ)</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-cyan-300 bg-cyan-500/10 px-2 py-0.5 rounded border border-cyan-500/20">۳ × ۱۲</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0D1018] border border-[#252B3A] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۶</span>
                    <span class="font-bold text-gray-200">فیله کمر با وزنه (Hyperextensions)</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۵</span>
                </div>
              </div>

              <!-- Warmup & Cooldown Pill -->
              <div class="flex items-center gap-2 text-[10px] text-gray-300 bg-[#0A0D14] p-2 rounded-xl border border-zinc-800/80 relative z-10">
                <span class="text-[#CCFF00] font-bold">🎯 دستورالعمل:</span>
                <span>گرم‌کردن کامل روتاتور کاف شانه با کش پیلاتس + کشش سینه در پایان</span>
              </div>

              <!-- High-Impact Primary CTA Button -->
              <button onclick="openWorkoutSessionModal(2)" class="w-full py-3 rounded-xl bg-[#CCFF00] hover:bg-[#b8e600] text-black font-black text-xs transition active:scale-95 flex items-center justify-center gap-2 shadow-lg shadow-[#CCFF00]/25 relative z-10">
                <svg class="w-4 h-4 text-black" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 5v14M18 5v14M2 9h4M18 9h4M2 15h4M18 15h4M6 12h12"/></svg>
                <span>ورود به تمرین زنده سینه و بازو (جلسه امروز) 🚀</span>
              </button>
            </div>

            <!-- Workout Day 3 -->
            <div class="theme-card bg-[#141722] border border-[#252B3A] hover:border-[#38435C] rounded-2xl p-4 space-y-3.5 transition-all shadow-md">
              <div class="flex justify-between items-start">
                <div>
                  <div class="flex items-center gap-2">
                    <span class="text-xs font-black text-white">برنامه شماره ۳: زیربغل، سرشانه، کول و شکم</span>
                    <span class="theme-card-sub text-[10px] bg-zinc-800 text-gray-300 px-2 py-0.5 rounded-md font-bold">چهارشنبه</span>
                  </div>
                  <div class="flex items-center gap-2 mt-1 text-[11px] text-gray-400">
                    <span class="flex items-center gap-1">⏱️ ۵۵ دقیقه</span>
                    <span>•</span>
                    <span class="flex items-center gap-1 text-[#00F0FF]">🔥 ۴۸۰ کالری</span>
                    <span>•</span>
                    <span class="text-gray-300">۶ حرکت تخصصی</span>
                  </div>
                </div>
                <span class="text-[10px] font-bold px-2 py-0.5 rounded bg-amber-500/15 text-amber-300 border border-amber-500/30">جلسه بعدی</span>
              </div>

              <!-- Structured Exercise Pills List -->
              <div class="space-y-1.5 pt-1">
                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۱</span>
                    <span class="font-bold text-gray-200">بارفیکس مچ برعکس (Chin-ups)</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۸</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۲</span>
                    <span class="font-bold text-gray-200">زیربغل قایقی میله V</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-purple-500/20 text-purple-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست سیم‌کش جلو + تی‌بار</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-purple-300 bg-purple-500/10 px-2 py-0.5 rounded border border-purple-500/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۴</span>
                    <span class="font-bold text-gray-200">پرس سرشانه هالتر نظامی</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۰</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-cyan-500/20 text-cyan-300 flex items-center justify-center text-[10px] font-black">⚡</span>
                    <span class="font-bold text-gray-200">سوپرست پرس دمبل آرنولدی + نشر جانب</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-cyan-300 bg-cyan-500/10 px-2 py-0.5 rounded border border-cyan-500/20">۳ × ۱۲</span>
                </div>

                <div class="flex items-center justify-between p-2 rounded-xl bg-[#0F121C] border border-[#1E2433] text-xs">
                  <div class="flex items-center gap-2">
                    <span class="w-5 h-5 rounded-md bg-[#252B3A] text-gray-300 flex items-center justify-center text-[10px] font-black">۶</span>
                    <span class="font-bold text-gray-200">فلای معکوس دمبل + شراگز هالتر سنگین</span>
                  </div>
                  <span class="text-[11px] font-mono font-bold text-[#CCFF00] bg-[#CCFF00]/10 px-2 py-0.5 rounded border border-[#CCFF00]/20">۳ × ۱۵</span>
                </div>
              </div>

              <button onclick="openWorkoutSessionModal(3)" class="w-full py-2.5 rounded-xl bg-[#1D2230] hover:bg-[#CCFF00] hover:text-black text-gray-200 font-black text-xs transition active:scale-95 flex items-center justify-center gap-2 border border-[#2B354C]">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M6 5v14M18 5v14M2 9h4M18 9h4M2 15h4M18 15h4M6 12h12"/></svg>
                <span>شروع تمرین پشت و سرشانه</span>
              </button>
            </div>

            <!-- Home Fallback Plan -->
            <div class="theme-card bg-gradient-to-r from-[#1A1822] to-[#141722] border border-orange-500/30 rounded-2xl p-4 space-y-3">
              <div class="flex justify-between items-center">
                <div>
                  <h3 class="text-sm font-bold text-orange-400">برنامه بدون وزنه در خانه</h3>
                  <p class="text-[10px] text-gray-400 mt-0.5">جایگزین فوری در صورت عدم امکان مراجعه به باشگاه</p>
                </div>
                <span class="text-[10px] bg-orange-500/15 text-orange-400 border border-orange-500/30 px-2 py-0.5 rounded font-bold">خانگی</span>
              </div>
              <div class="flex flex-wrap gap-1 text-[11px]">
                <span class="bg-[#0F121C] text-gray-300 px-2 py-0.5 rounded border border-zinc-800">شنا سوئدی</span>
                <span class="bg-[#0F121C] text-gray-300 px-2 py-0.5 rounded border border-zinc-800">اسکوات تک‌پا</span>
                <span class="bg-[#0F121C] text-gray-300 px-2 py-0.5 rounded border border-zinc-800">دیپ لبه صندلی</span>
                <span class="bg-[#0F121C] text-gray-300 px-2 py-0.5 rounded border border-zinc-800">پلنک شکم</span>
              </div>
              <button onclick="openWorkoutSessionModal(4)" class="w-full py-2 rounded-xl bg-orange-500 hover:bg-orange-600 text-black font-black text-xs transition active:scale-95">
                شروع تمرین خانگی
              </button>
            </div>
          </section>
\3'''

    html, count1 = workout_pattern.subn(new_workout_html, html)
    print(f'Workout section replaced: {count1} occurrence(s)')

    # 2. Update Marketplace Page (Gyms & Trainers separated)
    market_pattern = re.compile(
        r'(<section id="pageMarketplace" class="p-4 space-y-4 pb-36 hidden">)(.*?)(<!-- SubTab Content: Bookings)',
        re.DOTALL
    )

    new_market_html = r'''\1
            <div>
              <div class="flex items-center gap-2">
                <span class="w-2 h-2 rounded-full bg-[#00F0FF] animate-pulse"></span>
                <span class="text-[10px] font-black uppercase tracking-wider text-[#00F0FF]">باشگاه‌ها و مربیان رسمی</span>
              </div>
              <h2 class="theme-text-primary text-lg font-black text-white mt-0.5">مجموعه‌های ورزشی و مربیان خصوصی</h2>
              <p class="theme-text-muted text-xs text-gray-400">سانس‌های VIP باشگاه‌ها و رزرو جلسات خصوصی ۱-به-۱ با مربیان IFBB</p>
            </div>

            <!-- 3 Modern Segmented Sub-Tabs Pill -->
            <div class="theme-card-sub flex bg-[#10141F] border border-[#252B3A] p-1 rounded-xl text-xs font-bold shadow-inner">
              <button onclick="switchMarketSubTab('gyms')" id="subTabGyms" class="flex-1 py-2 rounded-lg bg-[#CCFF00] text-black transition font-black flex items-center justify-center gap-1.5 shadow-sm">
                <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 21h18M3 7v14M21 7v14M6 11v6M10 11v6M14 11v6M18 11v6M9 3l3-2 3 2v4H9V3z"/></svg>
                <span>باشگاه‌های VIP</span>
              </button>
              <button onclick="switchMarketSubTab('trainers')" id="subTabTrainers" class="flex-1 py-2 rounded-lg text-gray-400 hover:text-white transition font-bold flex items-center justify-center gap-1.5">
                <svg class="w-3.5 h-3.5 text-[#FFB800]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                <span>مربیان خصوصی (۱-به-۱)</span>
              </button>
              <button onclick="switchMarketSubTab('bookings')" id="subTabBookings" class="flex-1 py-2 rounded-lg text-gray-400 hover:text-white transition font-bold flex items-center justify-center gap-1.5">
                <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                <span>رزروهای من</span>
              </button>
            </div>

            <!-- SubTab Content: Gyms -->
            <div id="subTabContentGyms" class="space-y-4">
              <!-- Search & District Filter -->
              <div class="flex gap-2">
                <div class="relative flex-1">
                  <input type="text" placeholder="جستجوی باشگاه، منطقه (سعادت‌آباد، زعفرانیه...)" class="w-full bg-[#141722] border border-[#252B3A] rounded-xl px-3 py-2 pr-8 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#CCFF00]">
                  <svg class="w-4 h-4 text-gray-400 absolute right-2.5 top-2.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                </div>
                <button class="px-3 py-2 bg-[#1C2232] border border-[#2B354C] rounded-xl text-gray-300 text-xs font-bold flex items-center gap-1 hover:text-white">
                  <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
                  <span>فیلتر</span>
                </button>
              </div>

              <!-- Gym 1: Oxin VIP -->
              <div class="theme-card bg-[#141722] border border-[#252B3A] hover:border-[#CCFF00]/40 rounded-2xl overflow-hidden shadow-lg transition-all">
                <!-- Gym Architectural Banner -->
                <div class="h-28 w-full bg-gradient-to-r from-emerald-950 via-zinc-900 to-[#121622] relative p-3 flex flex-col justify-between border-b border-zinc-800">
                  <div class="flex justify-between items-center">
                    <span class="text-[10px] font-black bg-black/60 backdrop-blur-md text-[#CCFF00] border border-[#CCFF00]/30 px-2 py-0.5 rounded-full flex items-center gap-1">
                      <span>★</span>
                      <span>مجموعه VIP برتر منطقه ۲</span>
                    </span>
                    <span class="text-[10px] font-bold bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full border border-emerald-500/30">
                      ⚡ سانس آقایان: ۶ الی ۲۴
                    </span>
                  </div>
                  <div class="flex items-center gap-2">
                    <div class="w-9 h-9 rounded-xl bg-[#0A0D14] border border-[#252B3A] flex items-center justify-center font-black text-xs text-[#CCFF00] shadow-md">
                      OXIN
                    </div>
                    <div>
                      <h3 class="theme-text-primary text-sm font-black text-white drop-shadow">مجموعه ورزشی اکسین سعادت‌آباد (Oxin VIP)</h3>
                      <p class="text-[10px] text-gray-300 drop-shadow">تهران، سعادت‌آباد، میدان کاج، بلوار سرو غربی</p>
                    </div>
                  </div>
                </div>

                <!-- Card Body -->
                <div class="p-3.5 space-y-3">
                  <!-- Rating & District Info -->
                  <div class="flex justify-between items-center text-xs">
                    <div class="flex items-center gap-1">
                      <div class="flex text-[#FFB800]">★★★★★</div>
                      <span class="font-black text-white mr-1">۴.۹</span>
                      <span class="text-gray-400 text-[10px]">(۱۲۸ نظر تایید شده)</span>
                    </div>
                    <span class="text-[10px] text-gray-400 bg-zinc-800/80 px-2 py-0.5 rounded">منطقه ۲ تهران</span>
                  </div>

                  <!-- Amenities Chips -->
                  <div class="flex flex-wrap gap-1.5">
                    <span class="text-[10px] font-medium bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg flex items-center gap-1">
                      <span>🏊‍♂️</span> استخر آب‌گرم و سونا
                    </span>
                    <span class="text-[10px] font-medium bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg flex items-center gap-1">
                      <span>🏋️</span> تجهیزات ماتریکس ۲۰۲۵
                    </span>
                    <span class="text-[10px] font-medium bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg flex items-center gap-1">
                      <span>🚗</span> پارکینگ اختصاصی
                    </span>
                    <span class="text-[10px] font-medium bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg flex items-center gap-1">
                      <span>🥗</span> بار پروتئینی
                    </span>
                    <span class="text-[10px] font-medium bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg flex items-center gap-1">
                      <span>🩺</span> آنالیز بدنی InBody
                    </span>
                  </div>

                  <!-- Fee & GymBro VIP Discount -->
                  <div class="p-2.5 rounded-xl bg-[#0E121B] border border-[#1E2433] flex justify-between items-center">
                    <div>
                      <span class="text-[10px] text-gray-400 block">شهریه ماهانه:</span>
                      <div class="flex items-baseline gap-1.5">
                        <span class="text-sm font-black text-[#CCFF00]">۳,۲۰۰,۰۰۰</span>
                        <span class="text-[10px] text-gray-400">تومان</span>
                      </div>
                    </div>
                    <div class="text-left">
                      <span class="text-[9px] font-bold text-amber-400 bg-amber-400/10 border border-amber-400/20 px-2 py-0.5 rounded-full block mb-0.5">۵٪ تخفیف اعضای GymBro</span>
                      <span class="text-[10px] text-gray-400">شامل دسترسی به استخر و بدنسازی</span>
                    </div>
                  </div>

                  <!-- CTAs -->
                  <div class="flex gap-2">
                    <button onclick="bookGymSession('مجموعه ورزشی اکسین سعادت‌آباد', '۳,۲۰۰,۰۰۰ تومان')" class="flex-1 py-2.5 rounded-xl bg-[#CCFF00] hover:bg-[#b8e600] text-black font-black text-xs transition active:scale-95 flex items-center justify-center gap-1.5 shadow-md shadow-[#CCFF00]/20">
                      <svg class="w-4 h-4 text-black" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                      <span>رزرو سانس و عضویت آنلاین</span>
                    </button>
                    <button onclick="alert('امکانات اکسین: ۱۲۰۰ متر سالن بدنسازی مجهز به برند Matrix، استخر آبدرمانی، جکوزی، بوفه سلامت و مربیان رسمی فدراسیون.')" class="px-3 py-2.5 rounded-xl bg-[#1C2232] hover:bg-[#252B3A] text-gray-300 hover:text-white text-xs font-bold transition flex items-center justify-center">
                      امکانات
                    </button>
                  </div>
                </div>
              </div>

              <!-- Gym 2: Palladium Luxury -->
              <div class="theme-card bg-[#141722] border border-[#252B3A] hover:border-[#CCFF00]/40 rounded-2xl overflow-hidden shadow-lg transition-all">
                <!-- Gym Architectural Banner -->
                <div class="h-28 w-full bg-gradient-to-r from-amber-950/60 via-zinc-900 to-[#121622] relative p-3 flex flex-col justify-between border-b border-zinc-800">
                  <div class="flex justify-between items-center">
                    <span class="text-[10px] font-black bg-black/60 backdrop-blur-md text-[#FFB800] border border-[#FFB800]/30 px-2 py-0.5 rounded-full flex items-center gap-1">
                      <span>★</span>
                      <span>پرچمدار لاکچری شمال تهران</span>
                    </span>
                    <span class="text-[10px] font-bold bg-cyan-500/20 text-cyan-300 px-2 py-0.5 rounded-full border border-cyan-500/30">
                      ⚡ پذیرش همه‌روزه
                    </span>
                  </div>
                  <div class="flex items-center gap-2">
                    <div class="w-9 h-9 rounded-xl bg-[#0A0D14] border border-[#252B3A] flex items-center justify-center font-black text-xs text-[#FFB800] shadow-md">
                      PLD
                    </div>
                    <div>
                      <h3 class="theme-text-primary text-sm font-black text-white drop-shadow">باشگاه ورزشی پالادیوم زعفرانیه (Palladium)</h3>
                      <p class="text-[10px] text-gray-300 drop-shadow">تهران، زعفرانیه، مرکز خرید پالادیوم، طبقه ۶</p>
                    </div>
                  </div>
                </div>

                <!-- Card Body -->
                <div class="p-3.5 space-y-3">
                  <!-- Rating & District Info -->
                  <div class="flex justify-between items-center text-xs">
                    <div class="flex items-center gap-1">
                      <div class="flex text-[#FFB800]">★★★★★</div>
                      <span class="font-black text-white mr-1">۴.۹۵</span>
                      <span class="text-gray-400 text-[10px]">(۲۱۴ نظر تایید شده)</span>
                    </div>
                    <span class="text-[10px] text-gray-400 bg-zinc-800/80 px-2 py-0.5 rounded">زعفرانیه (منطقه ۱)</span>
                  </div>

                  <!-- Amenities Chips -->
                  <div class="flex flex-wrap gap-1.5">
                    <span class="text-[10px] font-medium bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg flex items-center gap-1">
                      <span>🏙️</span> سالن پانوراما دید شمال شهر
                    </span>
                    <span class="text-[10px] font-medium bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg flex items-center gap-1">
                      <span>🧖‍♀️</span> اسپا و ماساژ ریکاوری
                    </span>
                    <span class="text-[10px] font-medium bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg flex items-center gap-1">
                      <span>🅿️</span> ۵ طبقه پارکینگ اختصاصی
                    </span>
                    <span class="text-[10px] font-medium bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg flex items-center gap-1">
                      <span>🥗</span> کافه ارگانیک پالادیوم
                    </span>
                  </div>

                  <!-- Fee & Discount -->
                  <div class="p-2.5 rounded-xl bg-[#0E121B] border border-[#1E2433] flex justify-between items-center">
                    <div>
                      <span class="text-[10px] text-gray-400 block">شهریه ماهانه:</span>
                      <div class="flex items-baseline gap-1.5">
                        <span class="text-sm font-black text-[#CCFF00]">۴,۸۰۰,۰۰۰</span>
                        <span class="text-[10px] text-gray-400">تومان</span>
                      </div>
                    </div>
                    <div class="text-left">
                      <span class="text-[9px] font-bold text-cyan-400 bg-cyan-400/10 border border-cyan-400/20 px-2 py-0.5 rounded-full block mb-0.5">شامل حوله و کمد اختصاصی</span>
                      <span class="text-[10px] text-gray-400">محیطی کاملاً اختصاصی و آرام</span>
                    </div>
                  </div>

                  <!-- CTAs -->
                  <div class="flex gap-2">
                    <button onclick="bookGymSession('باشگاه ورزشی پالادیوم زعفرانیه', '۴,۸۰۰,۰۰۰ تومان')" class="flex-1 py-2.5 rounded-xl bg-[#CCFF00] hover:bg-[#b8e600] text-black font-black text-xs transition active:scale-95 flex items-center justify-center gap-1.5 shadow-md shadow-[#CCFF00]/20">
                      <svg class="w-4 h-4 text-black" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                      <span>رزرو سانس و عضویت آنلاین</span>
                    </button>
                    <button onclick="alert('امکانات پالادیوم: تجهیزات بدنسازی Technogym ایتالیا، استخر سرپوشیده با سقف شیشه‌ای، بخش ماساژ حرفه‌ای، بار نوشیدنی‌های ورزشی.')" class="px-3 py-2.5 rounded-xl bg-[#1C2232] hover:bg-[#252B3A] text-gray-300 hover:text-white text-xs font-bold transition flex items-center justify-center">
                      امکانات
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- SubTab Content: Trainers (فیلد اختصاصی مربیان خصوصی) -->
            <div id="subTabContentTrainers" class="space-y-4 hidden">
              <!-- Private Coaching Mission Banner -->
              <div class="theme-card bg-gradient-to-r from-[#171D2C] via-[#1A2234] to-[#121622] border border-[#2E3A54] rounded-2xl p-4 space-y-2 shadow-lg">
                <div class="flex items-center gap-2">
                  <div class="w-7 h-7 rounded-lg bg-[#FFB800]/20 text-[#FFB800] border border-[#FFB800]/30 flex items-center justify-center">
                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                  </div>
                  <div>
                    <h3 class="text-xs font-black text-white">خدمات کوچینگ و مربیگری خصوصی ۱-به-۱ (VIP)</h3>
                    <p class="text-[10px] text-gray-400">تمرین اختصاصی همراه با مربی، اصلاح بیومکانیک حرکات و رژیم هدفمند</p>
                  </div>
                </div>
                <div class="flex flex-wrap gap-2 pt-1 text-[10px]">
                  <span class="bg-black/40 text-gray-300 px-2 py-0.5 rounded-md border border-zinc-800">✅ نظارت مستقیم بر اجرای فرم حرکات</span>
                  <span class="bg-black/40 text-gray-300 px-2 py-0.5 rounded-md border border-zinc-800">✅ طراحی برنامه ماهانه اختصاصی</span>
                  <span class="bg-black/40 text-gray-300 px-2 py-0.5 rounded-md border border-zinc-800">✅ پشتیبانی تلفنی و واتساپ</span>
                </div>
              </div>

              <!-- Private Trainer 1: Alireza Rad -->
              <div class="theme-card bg-[#141722] border-2 border-[#FFB800]/40 hover:border-[#FFB800] rounded-2xl p-4 space-y-3 shadow-lg transition-all relative overflow-hidden">
                <div class="flex justify-between items-start">
                  <div class="flex items-center gap-3">
                    <div class="relative">
                      <div class="w-13 h-13 rounded-2xl bg-gradient-to-tr from-[#FFB800] to-[#CCFF00] p-0.5 shadow-md">
                        <div class="w-12 h-12 rounded-2xl bg-[#0E131E] flex items-center justify-center font-black text-white text-base">
                          راد
                        </div>
                      </div>
                      <span class="absolute -bottom-1 -right-1 bg-[#FFB800] text-black text-[9px] font-black px-1.5 py-0.2 rounded-full border border-black shadow">PRO</span>
                    </div>
                    <div>
                      <div class="flex items-center gap-1.5">
                        <h3 class="theme-text-primary text-sm font-black text-white">استاد علیرضا راد</h3>
                        <span class="text-[9px] font-black bg-[#CCFF00] text-black px-1.5 py-0.5 rounded">مربی خصوصی آرمین</span>
                      </div>
                      <p class="text-[10px] text-gray-400 mt-0.5">مربی رسمی فدراسیون IFBB • ۱۰ سال سابقه تخصصی هایپرتروفی</p>
                      <div class="flex items-center gap-2 mt-1 text-[10px]">
                        <span class="text-[#FFB800] font-bold">★★★★★ ۴.۹۸</span>
                        <span class="text-gray-400">•</span>
                        <span class="text-gray-300">۸۹ شاگرد فعال</span>
                        <span class="text-gray-400">•</span>
                        <span class="text-emerald-400 font-bold">باشگاه اکسین و آنلاین</span>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Specializations -->
                <div class="flex flex-wrap gap-1.5">
                  <span class="text-[10px] bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg font-medium">🎯 هایپرتروفی و حجم عضلانی</span>
                  <span class="text-[10px] bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg font-medium">🥗 رژیم کات و مسابقات فیزیک</span>
                  <span class="text-[10px] bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg font-medium">🩹 اصلاح الگوهای حرکتی و زانو/شانه</span>
                </div>

                <!-- Rates / Packages Box -->
                <div class="p-2.5 rounded-xl bg-[#0E121B] border border-[#1E2433] space-y-1.5">
                  <div class="flex justify-between items-center text-xs">
                    <span class="text-gray-400">جلسه خصوصی ۱-به-۱ (حضوری):</span>
                    <span class="font-black text-[#CCFF00]">۶۵۰,۰۰۰ تومان</span>
                  </div>
                  <div class="flex justify-between items-center text-xs pt-1 border-t border-zinc-800">
                    <span class="text-gray-400">پکیج ۱۲ جلسه‌ای ماهانه (با برنامه کامل):</span>
                    <span class="font-black text-[#FFB800]">۶,۹۰۰,۰۰۰ تومان</span>
                  </div>
                </div>

                <!-- Actions -->
                <div class="flex gap-2">
                  <button onclick="bookTrainerSession('استاد علیرضا راد', '۶۵۰,۰۰۰ تومان')" class="flex-1 py-2.5 rounded-xl bg-[#CCFF00] hover:bg-[#b8e600] text-black font-black text-xs transition active:scale-95 flex items-center justify-center gap-1.5 shadow-md shadow-[#CCFF00]/20">
                    <svg class="w-4 h-4 text-black" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    <span>رزرو جلسه خصوصی حضوری</span>
                  </button>
                  <button onclick="openCoachChatModal('استاد علیرضا راد')" class="px-3 py-2.5 rounded-xl bg-[#1C2232] hover:bg-[#252B3A] text-gray-300 hover:text-white text-xs font-bold transition flex items-center justify-center gap-1">
                    <svg class="w-3.5 h-3.5 text-[#00F0FF]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    <span>چت خصوصی</span>
                  </button>
                </div>
              </div>

              <!-- Private Trainer 2: Sohrab Sarabi -->
              <div class="theme-card bg-[#141722] border border-[#252B3A] hover:border-[#FFB800]/50 rounded-2xl p-4 space-y-3 shadow-lg transition-all">
                <div class="flex justify-between items-start">
                  <div class="flex items-center gap-3">
                    <div class="relative">
                      <div class="w-13 h-13 rounded-2xl bg-gradient-to-tr from-[#00F0FF] to-blue-600 p-0.5 shadow-md">
                        <div class="w-12 h-12 rounded-2xl bg-[#0E131E] flex items-center justify-center font-black text-white text-base">
                          سرابی
                        </div>
                      </div>
                      <span class="absolute -bottom-1 -right-1 bg-cyan-400 text-black text-[9px] font-black px-1.5 py-0.2 rounded-full border border-black shadow">قهرمان</span>
                    </div>
                    <div>
                      <div class="flex items-center gap-1.5">
                        <h3 class="theme-text-primary text-sm font-black text-white">سهراب سرابی</h3>
                        <span class="text-[9px] font-bold bg-[#FFB800]/20 text-[#FFB800] px-1.5 py-0.5 rounded border border-[#FFB800]/30">قهرمان اسبق آسیا</span>
                      </div>
                      <p class="text-[10px] text-gray-400 mt-0.5">مدرس ارشد پرورش اندام • متخصص فازهای حجم عضلانی سنگین</p>
                      <div class="flex items-center gap-2 mt-1 text-[10px]">
                        <span class="text-[#FFB800] font-bold">★★★★★ ۴.۹۲</span>
                        <span class="text-gray-400">•</span>
                        <span class="text-gray-300">۱۴۰ شاگرد موفق</span>
                        <span class="text-gray-400">•</span>
                        <span class="text-emerald-400 font-bold">پالادیوم و غرب تهران</span>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Specializations -->
                <div class="flex flex-wrap gap-1.5">
                  <span class="text-[10px] bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg font-medium">🏆 بدنسازی قهرمانی و پاورلیفتینگ</span>
                  <span class="text-[10px] bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg font-medium">⚡ افزایش رکورد 1RM اسکوات و ددلیفت</span>
                  <span class="text-[10px] bg-[#1D2230] text-gray-300 border border-[#252B3A] px-2 py-0.5 rounded-lg font-medium">🥩 رژیم‌های پرکالری حجم پاک</span>
                </div>

                <!-- Rates / Packages Box -->
                <div class="p-2.5 rounded-xl bg-[#0E121B] border border-[#1E2433] space-y-1.5">
                  <div class="flex justify-between items-center text-xs">
                    <span class="text-gray-400">جلسه خصوصی ۱-به-۱ (حضوری):</span>
                    <span class="font-black text-[#CCFF00]">۵۰۰,۰۰۰ تومان</span>
                  </div>
                  <div class="flex justify-between items-center text-xs pt-1 border-t border-zinc-800">
                    <span class="text-gray-400">پکیج ۱۰ جلسه‌ای با تنظیم مکمل‌ها:</span>
                    <span class="font-black text-[#FFB800]">۴,۵۰۰,۰۰۰ تومان</span>
                  </div>
                </div>

                <!-- Actions -->
                <div class="flex gap-2">
                  <button onclick="bookTrainerSession('سهراب سرابی', '۵۰۰,۰۰۰ تومان')" class="flex-1 py-2.5 rounded-xl bg-[#CCFF00] hover:bg-[#b8e600] text-black font-black text-xs transition active:scale-95 flex items-center justify-center gap-1.5 shadow-md shadow-[#CCFF00]/20">
                    <svg class="w-4 h-4 text-black" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    <span>رزرو جلسه خصوصی حضوری</span>
                  </button>
                  <button onclick="openCoachChatModal('سهراب سرابی')" class="px-3 py-2.5 rounded-xl bg-[#1C2232] hover:bg-[#252B3A] text-gray-300 hover:text-white text-xs font-bold transition flex items-center justify-center gap-1">
                    <svg class="w-3.5 h-3.5 text-[#00F0FF]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    <span>چت خصوصی</span>
                  </button>
                </div>
              </div>
            </div>
\3'''

    html, count2 = market_pattern.subn(new_market_html, html)
    print(f'Marketplace section replaced: {count2} occurrence(s)')

    # 3. Add JS helper functions if not present
    js_helpers = '''
    // ==========================================
    // PRIVATE COACH & GYM BOOKING HELPERS
    // ==========================================
    function toggleCoachPrivateNotes() {
      soundClick();
      const panel = document.getElementById('coachPrivateNotesPanel');
      if (panel) {
        panel.classList.toggle('hidden');
      }
    }

    function bookGymSession(gymName, fee) {
      soundClick();
      const emptyView = document.getElementById('emptyBookingsView');
      const activeList = document.getElementById('activeBookingsList');
      if (emptyView) emptyView.classList.add('hidden');
      if (activeList) activeList.classList.remove('hidden');

      const bookingItem = document.createElement('div');
      bookingItem.id = `gym_booking_${Date.now()}`;
      bookingItem.className = "theme-card bg-[#141722] border border-[#252B3A] rounded-2xl p-4 space-y-2 shadow-md";
      bookingItem.innerHTML = `
        <div class="flex justify-between items-start">
          <div>
            <h4 class="theme-text-primary text-sm font-bold text-white">عضویت سانس VIP در ${gymName}</h4>
            <p class="theme-text-muted text-[10px] text-gray-400">تاریخ شروع: از فردا • دسترسی نامحدود به بدنسازی و استخر</p>
          </div>
          <span class="text-[10px] bg-emerald-500/20 text-emerald-300 font-bold px-2 py-0.5 rounded border border-emerald-500/30 flex items-center gap-1">
            <svg class="w-3 h-3 text-emerald-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            <span>فعال شد</span>
          </span>
        </div>
        <div class="flex justify-between items-center text-xs">
          <span class="theme-text-muted text-gray-400">مبلغ عضویت: ${fee} (تخفیف ۵٪ لحاظ شد)</span>
          <button onclick="cancelBooking('${bookingItem.id}')" class="text-red-400 hover:text-red-300 text-[11px] font-bold">لغو اشتراک</button>
        </div>
      `;
      if (activeList) activeList.prepend(bookingItem);
      switchMarketSubTab('bookings');
      alert(`درخواست عضویت در ${gymName} با موفقیت ثبت شد.`);
    }

    function openCoachChatModal(coachName) {
      soundClick();
      alert(`اتصال به چت اختصاصی و امن با ${coachName}...\\nمربی در ساعات کاری (۱۰ الی ۲۲) در دسترس است.`);
    }
'''

    if 'function toggleCoachPrivateNotes' not in html:
      html = html.replace('function cancelBooking(elementId) {', js_helpers + '\n    function cancelBooking(elementId) {')
      print('Added JS helpers for private coach & gym booking')

    with open('gymbro_redmi_simulator.html', 'w', encoding='utf-8') as f:
        f.write(html)
    print('gymbro_redmi_simulator.html successfully updated!')

if __name__ == '__main__':
    update_simulator()
