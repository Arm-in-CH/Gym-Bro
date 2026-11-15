import re

with open('gymbro_redmi_simulator.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace "رفتن به تمرین" button
old_workout_btn = '''<button onclick="openWorkoutSessionModal(2)" class="w-full mt-3.5 py-3 rounded-xl bg-[#CCFF00] hover:bg-[#b8e600] text-black font-black text-sm shadow-lg shadow-[#CCFF00]/30 transition-all flex items-center justify-center gap-2 active:scale-95">
                <svg class="w-5 h-5 text-black" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                  <path d="M6 5v14M18 5v14M2 9h4M18 9h4M2 15h4M18 15h4M6 12h12"/>
                </svg>
                <span>رفتن به تمرین (ورود به جلسه زنده)</span>
              </button>'''

new_workout_btn = '''<button onclick="openWorkoutSessionModal(2)" class="w-full mt-3.5 py-3 rounded-xl bg-[#CCFF00] hover:bg-[#b8e600] text-black font-black text-sm shadow-lg shadow-[#CCFF00]/30 transition-all flex items-center justify-center gap-2 active:scale-95 group">
                <svg class="w-5 h-5 text-black shrink-0 transition-transform group-hover:scale-110" viewBox="0 0 100 100" fill="none">
                  <line x1="25" y1="75" x2="75" y2="25" stroke="#000" stroke-width="10" stroke-linecap="round" />
                  <line x1="16" y1="64" x2="34" y2="82" stroke="#000" stroke-width="10" stroke-linecap="round" />
                  <line x1="66" y1="18" x2="84" y2="36" stroke="#000" stroke-width="10" stroke-linecap="round" />
                  <circle cx="50" cy="50" r="7" fill="#000" />
                </svg>
                <span>رفتن به تمرین (ورود به جلسه زنده)</span>
                <span class="text-xs px-1.5 py-0.5 rounded bg-black/15 font-black">⚡ Live</span>
              </button>'''

# 2. Replace flame icon in Calorie Budget card
old_flame = '''<svg class="w-4 h-4 text-[#CCFF00]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/>
                    </svg>'''

new_flame = '''<svg class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none">
                      <path d="M12 2C8 7 4 10.5 4 15a8 8 0 1 0 16 0c0-4.5-4-8-8-13z" fill="#F59E0B" opacity="0.95"/>
                      <path d="M12 11c-2 2.5-3 4-3 5.5a3 3 0 1 0 6 0c0-1.5-1-3-3-5.5z" fill="#CCFF00"/>
                    </svg>'''

# 3. Replace the 4 macro boxes
old_macros = '''<!-- Macros Grid -->
              <div class="grid grid-cols-4 gap-2 pt-1 text-center">
                <div class="theme-card-sub bg-[#0E1118] p-2 rounded-xl border border-zinc-800/80">
                  <div class="theme-text-muted text-[10px] text-gray-400">پروتئین</div>
                  <div id="macroProteinText" class="theme-text-primary text-xs font-bold text-white mt-0.5">۳۸ / ۱۶۰g</div>
                </div>
                <div class="theme-card-sub bg-[#0E1118] p-2 rounded-xl border border-zinc-800/80">
                  <div class="theme-text-muted text-[10px] text-gray-400">کربوهیدرات</div>
                  <div id="macroCarbsText" class="theme-text-primary text-xs font-bold text-white mt-0.5">۶۵ / ۲۲۰g</div>
                </div>
                <div class="theme-card-sub bg-[#0E1118] p-2 rounded-xl border border-zinc-800/80">
                  <div class="theme-text-muted text-[10px] text-gray-400">چربی</div>
                  <div id="macroFatText" class="theme-text-primary text-xs font-bold text-white mt-0.5">۱۸ / ۵۵g</div>
                </div>
                <div class="theme-card-sub bg-[#0E1118] p-2 rounded-xl border border-cyan-900/30">
                  <div class="text-[10px] text-cyan-400">آب هدف</div>
                  <div class="text-xs font-bold text-cyan-300 mt-0.5">۸ لیوان</div>
                </div>
              </div>'''

new_macros = '''<!-- Macros Grid -->
              <div class="grid grid-cols-4 gap-2 pt-1 text-center">
                <div class="theme-card-sub bg-[#0E1118] p-2 rounded-xl border border-zinc-800/80">
                  <div class="theme-text-muted text-[10px] text-emerald-400 font-bold flex items-center justify-center gap-1">
                    <span>🥩</span> پروتئین
                  </div>
                  <div id="macroProteinText" class="theme-text-primary text-xs font-bold text-white mt-0.5">۳۸ / ۱۶۰g</div>
                </div>
                <div class="theme-card-sub bg-[#0E1118] p-2 rounded-xl border border-zinc-800/80">
                  <div class="theme-text-muted text-[10px] text-amber-400 font-bold flex items-center justify-center gap-1">
                    <span>🌾</span> کربوهیدرات
                  </div>
                  <div id="macroCarbsText" class="theme-text-primary text-xs font-bold text-white mt-0.5">۶۵ / ۲۲۰g</div>
                </div>
                <div class="theme-card-sub bg-[#0E1118] p-2 rounded-xl border border-zinc-800/80">
                  <div class="theme-text-muted text-[10px] text-teal-400 font-bold flex items-center justify-center gap-1">
                    <span>🥑</span> چربی
                  </div>
                  <div id="macroFatText" class="theme-text-primary text-xs font-bold text-white mt-0.5">۱۸ / ۵۵g</div>
                </div>
                <div class="theme-card-sub bg-[#0E1118] p-2 rounded-xl border border-cyan-900/40">
                  <div class="text-[10px] text-cyan-400 font-bold flex items-center justify-center gap-1">
                    <span>💧</span> آب هدف
                  </div>
                  <div class="text-xs font-bold text-cyan-300 mt-0.5">۸ لیوان</div>
                </div>
              </div>'''

# 4. Replace Floating Action Button (AI Coach)
old_fab = '''<!-- ================= FLOATING ACTION BUTTON (AI COACH) ================= -->
        <button onclick="openAiCoachModal()" class="absolute bottom-20 left-4 z-40 w-12 h-12 rounded-2xl bg-[#CCFF00] hover:bg-[#b8e600] text-black flex items-center justify-center shadow-lg shadow-[#CCFF00]/30 transition active:scale-90" title="مربی هوشمند بدنسازی">
          <svg class="w-6 h-6 text-black" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 4.44-2.04zM14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-4.44-2.04z"/>
          </svg>
        </button>'''

new_fab = '''<!-- ================= FLOATING ACTION BUTTON (AI COACH SYNAPSE) ================= -->
        <button onclick="openAiCoachModal()" class="absolute bottom-[72px] left-3 z-40 w-12 h-12 rounded-2xl bg-[#CCFF00] hover:bg-[#b8e600] text-black flex items-center justify-center shadow-[0_6px_24px_rgba(204,255,0,0.45)] border-2 border-black/25 transition-all hover:scale-105 active:scale-95 group" title="مربی هوشمند بدنسازی (Gemini Vision)">
          <svg class="w-7 h-7 text-black transition-transform group-hover:rotate-45" viewBox="0 0 100 100" fill="none">
            <path d="M50 14 Q50 50 86 50 Q50 50 50 86 Q50 50 14 50 Q50 50 50 14 Z" fill="#000000" />
            <circle cx="50" cy="50" r="9" fill="#CCFF00" />
          </svg>
        </button>'''

# 5. Replace bottom navigation bar icons (Dashboard, Workouts, Nutrition, Marketplace, Profile)
old_nav = '''<!-- ================= BOTTOM NAVIGATION BAR ================= -->
        <nav class="theme-bottom-nav absolute bottom-0 left-0 right-0 h-16 bg-[#0E1118] border-t border-zinc-800/80 flex items-center justify-around px-2 z-40">
          <!-- Nav 1: Dashboard -->
          <button onclick="switchTab('dashboard')" id="navDashboard" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-[#CCFF00]/18 text-[#CCFF00] shadow-[0_0_12px_rgba(204,255,0,0.25)]">
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
              </svg>
            </div>
            <span class="nav-label text-[10px] font-black text-[#CCFF00] mt-1 tracking-tight transition-colors">داشبورد</span>
          </button>

          <!-- Nav 2: Workouts -->
          <button onclick="switchTab('workout')" id="navWorkout" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-transparent text-gray-400 group-hover:text-gray-200">
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M2 9h2v6H2zm3-2h3v10H5zm4 4h6v2H9zm7-4h3v10h-3zm4 2h2v6h-2z"/>
              </svg>
            </div>
            <span class="nav-label text-[10px] font-medium text-gray-400 mt-1 tracking-tight transition-colors">تمرینات</span>
          </button>

          <!-- Nav 3: Nutrition -->
          <button onclick="switchTab('nutrition')" id="navNutrition" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-transparent text-gray-400 group-hover:text-gray-200">
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M11 9H9V2H7v7H5V2H3v7c0 2.12 1.66 3.84 3.75 3.97V22h2.5v-9.03C11.34 12.84 13 11.12 13 9V2h-2v7zm5-3v8h2.5v8H21V2c-2.76 0-5 2.24-5 4z"/>
              </svg>
            </div>
            <span class="nav-label text-[10px] font-medium text-gray-400 mt-1 tracking-tight transition-colors">تغذیه</span>
          </button>

          <!-- Nav 4: Marketplace -->
          <button onclick="switchTab('marketplace')" id="navMarketplace" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-transparent text-gray-400 group-hover:text-gray-200">
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2L2 7v2h20V7L12 2zm-8 9v8h3v-8H4zm6 0v8h3v-8h-3zm6 0v8h3v-8h-3zM2 21h20v2H2v-2z"/>
              </svg>
            </div>
            <span class="nav-label text-[10px] font-medium text-gray-400 mt-1 tracking-tight transition-colors">باشگاه</span>
          </button>

          <!-- Nav 5: Profile -->
          <button onclick="switchTab('profile')" id="navProfile" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-transparent text-gray-400 group-hover:text-gray-200">
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/>
              </svg>
            </div>
            <span class="nav-label text-[10px] font-medium text-gray-400 mt-1 tracking-tight transition-colors">پروفایل</span>
          </button>
        </nav>'''

new_nav = '''<!-- ================= BOTTOM NAVIGATION BAR (PHASE 11 COHESIVE ICONS) ================= -->
        <nav class="theme-bottom-nav absolute bottom-0 left-0 right-0 h-16 bg-[#0E1118]/95 backdrop-blur-md border-t border-zinc-800/80 flex items-center justify-around px-2 z-40">
          <!-- Nav 1: Dashboard -->
          <button onclick="switchTab('dashboard')" id="navDashboard" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-[#CCFF00]/18 text-[#CCFF00] shadow-[0_0_14px_rgba(204,255,0,0.3)]">
              <!-- Athletic Home Base -->
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M3 10.5L12 3l9 7.5v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-9z"/>
                <path d="M9 21v-6a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v6" stroke="#CCFF00" stroke-width="2.2"/>
              </svg>
            </div>
            <span class="nav-label text-[10px] font-black text-[#CCFF00] mt-1 tracking-tight transition-colors">داشبورد</span>
          </button>

          <!-- Nav 2: Workouts -->
          <button onclick="switchTab('workout')" id="navWorkout" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-transparent text-gray-400 group-hover:text-gray-200">
              <!-- 3D Athletic Dumbbell -->
              <svg class="w-5 h-5" viewBox="0 0 100 100" fill="none">
                <line x1="25" y1="75" x2="75" y2="25" stroke="currentColor" stroke-width="10" stroke-linecap="round" />
                <line x1="16" y1="64" x2="34" y2="82" stroke="currentColor" stroke-width="9" stroke-linecap="round" />
                <line x1="66" y1="18" x2="84" y2="36" stroke="currentColor" stroke-width="9" stroke-linecap="round" />
                <circle cx="50" cy="50" r="7" fill="#CCFF00" />
              </svg>
            </div>
            <span class="nav-label text-[10px] font-medium text-gray-400 mt-1 tracking-tight transition-colors">تمرینات</span>
          </button>

          <!-- Nav 3: Nutrition -->
          <button onclick="switchTab('nutrition')" id="navNutrition" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-transparent text-gray-400 group-hover:text-gray-200">
              <!-- Emoji Nutrition Apple -->
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 7c-2.5-2-6-1.5-7 1.5-1.5 4.5.5 10 7 12 6.5-2 8.5-7.5 7-12-1-3-4.5-3.5-7-1.5z"/>
                <path d="M12 7V4c1.5-1 3-1 4 0" stroke="#CCFF00" stroke-width="2.2"/>
              </svg>
            </div>
            <span class="nav-label text-[10px] font-medium text-gray-400 mt-1 tracking-tight transition-colors">تغذیه</span>
          </button>

          <!-- Nav 4: Marketplace -->
          <button onclick="switchTab('marketplace')" id="navMarketplace" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-transparent text-gray-400 group-hover:text-gray-200">
              <!-- Gym Duffel Bag -->
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="8" width="18" height="12" rx="4"/>
                <path d="M8 8V6a4 4 0 0 1 8 0v2" stroke="#CCFF00" stroke-width="2"/>
                <line x1="12" y1="12" x2="12" y2="15" stroke="#CCFF00" stroke-width="2"/>
              </svg>
            </div>
            <span class="nav-label text-[10px] font-medium text-gray-400 mt-1 tracking-tight transition-colors">باشگاه</span>
          </button>

          <!-- Nav 5: Profile -->
          <button onclick="switchTab('profile')" id="navProfile" class="nav-item group flex flex-col items-center justify-center flex-1 py-1 focus:outline-none select-none transition-all">
            <div class="nav-pill w-14 h-7 rounded-full flex items-center justify-center transition-all duration-200 bg-transparent text-gray-400 group-hover:text-gray-200">
              <!-- Athletic User Avatar -->
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
                <circle cx="12" cy="7" r="1.5" fill="#CCFF00"/>
              </svg>
            </div>
            <span class="nav-label text-[10px] font-medium text-gray-400 mt-1 tracking-tight transition-colors">پروفایل</span>
          </button>
        </nav>'''

# Apply replacements (normalizing CRLF)
def rep(src, old, new):
    old_crlf = old.replace('\n', '\r\n')
    new_crlf = new.replace('\n', '\r\n')
    if old in src:
        return src.replace(old, new)
    elif old_crlf in src:
        return src.replace(old_crlf, new_crlf)
    else:
        print("COULD NOT FIND:", repr(old[:40]))
        return src

content = rep(content, old_workout_btn, new_workout_btn)
content = rep(content, old_flame, new_flame)
content = rep(content, old_macros, new_macros)
content = rep(content, old_fab, new_fab)
content = rep(content, old_nav, new_nav)

# Also ensure pageDashboard has bottom padding so no content is ever masked:
content = content.replace('section id="pageDashboard" class="p-4 space-y-4 pb-20"', 'section id="pageDashboard" class="p-4 space-y-4 pb-28"')

with open('gymbro_redmi_simulator.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("gymbro_redmi_simulator.html updated successfully!")
