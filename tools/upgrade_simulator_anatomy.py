import base64

with open('gymbro_redmi_simulator.html', 'r', encoding='utf-8') as f:
    html = f.read()

with open('assets/images/anatomy_front.png', 'rb') as f:
    b64_f = base64.b64encode(f.read()).decode('utf-8')
with open('assets/images/anatomy_back.png', 'rb') as f:
    b64_b = base64.b64encode(f.read()).decode('utf-8')

# 1. Prepare new JS block
new_js = '''    // Interactive 3D Muscular Anatomy & Anthropometric Scan Engine (Phase 25)
    const bodyScanZones = {
      waist: { cx: 220, cy: 250, rx: 46, ry: 16, val: '۸۳.۰ cm', change: '↓ ۶cm', label: 'دور کمر و شکم', view: 'front' },
      chest: { cx: 220, cy: 168, rx: 56, ry: 18, val: '۱۰۲.۰ cm', change: '↑ ۴cm', label: 'دور سینه', view: 'front' },
      arm: { cx: 305, cy: 205, rx: 25, ry: 14, val: '۳۷.۵ cm', change: '↑ ۱.۵', label: 'دور بازو', view: 'front' },
      thigh: { cx: 250, cy: 395, rx: 30, ry: 15, val: '۵۸.۰ cm', change: '↑ ۲cm', label: 'دور ران', view: 'front' },
      hip: { cx: 220, cy: 315, rx: 48, ry: 16, val: '۹۸.۰ cm', change: '↓ ۱cm', label: 'دور باسن', view: 'both' },
      back: { cx: 220, cy: 180, rx: 58, ry: 20, val: '۱۱۰.۰ cm', change: '↑ ۳cm', label: 'زیربغل و فیله', view: 'back' },
      calf: { cx: 255, cy: 535, rx: 22, ry: 12, val: '۳۹.۰ cm', change: '↑ ۰.۸', label: 'ساق پا', view: 'both' },
      fat: { cx: 220, cy: 250, rx: 65, ry: 48, val: '۲۷.۲٪', change: '↓ ۲.۳٪', label: 'درصد چربی بدن', view: 'front' }
    };

    let activeBodyScanKey = 'waist';
    let currentAnatomyView = 'front';

    function switchAnatomyView(view) {
      try { soundClick(); } catch(e) {}
      currentAnatomyView = view;
      const frontImg = document.getElementById('anatomyImgFront');
      const backImg = document.getElementById('anatomyImgBack');
      const frontSvg = document.getElementById('anatomySvgFront');
      const backSvg = document.getElementById('anatomySvgBack');
      const btnFront = document.getElementById('btnViewFront');
      const btnBack = document.getElementById('btnViewBack');
      const viewBadge = document.getElementById('anatomyViewBadge');

      if (view === 'front') {
        if (frontImg) frontImg.classList.remove('hidden');
        if (backImg) backImg.classList.add('hidden');
        if (frontSvg) frontSvg.classList.remove('hidden');
        if (backSvg) backSvg.classList.add('hidden');
        if (btnFront) {
          btnFront.className = 'px-2.5 py-1 rounded-lg text-[10px] font-bold transition-all bg-[#CCFF00] text-black shadow-md shadow-[#CCFF00]/25';
        }
        if (btnBack) {
          btnBack.className = 'px-2.5 py-1 rounded-lg text-[10px] font-bold text-gray-400 hover:text-white transition-all';
        }
        if (viewBadge) viewBadge.textContent = 'نمای روبرو (ANTERIOR)';
      } else {
        if (frontImg) frontImg.classList.add('hidden');
        if (backImg) backImg.classList.remove('hidden');
        if (frontSvg) frontSvg.classList.add('hidden');
        if (backSvg) backSvg.classList.remove('hidden');
        if (btnBack) {
          btnBack.className = 'px-2.5 py-1 rounded-lg text-[10px] font-bold transition-all bg-[#CCFF00] text-black shadow-md shadow-[#CCFF00]/25';
        }
        if (btnFront) {
          btnFront.className = 'px-2.5 py-1 rounded-lg text-[10px] font-bold text-gray-400 hover:text-white transition-all';
        }
        if (viewBadge) viewBadge.textContent = 'نمای پشت (POSTERIOR)';
      }

      const zone = bodyScanZones[activeBodyScanKey];
      if (zone && zone.view !== 'both' && zone.view !== view) {
        selectBodyScanPart(view === 'front' ? 'chest' : 'back', false);
      } else {
        renderScanTarget();
      }
    }

    function selectBodyScanPart(partKey, autoSwitch = true) {
      try { soundClick(); } catch(e) {}
      const zone = bodyScanZones[partKey];
      if (!zone) return;
      activeBodyScanKey = partKey;

      if (autoSwitch && zone.view !== 'both' && zone.view !== currentAnatomyView) {
        switchAnatomyView(zone.view);
        return;
      }

      // Update chips UI
      Object.keys(bodyScanZones).forEach(k => {
        const chip = document.getElementById('scanChip-' + k);
        if (chip) {
          if (k === partKey) {
            chip.className = 'p-1.5 rounded-xl bg-[#CCFF00]/20 border border-[#CCFF00] flex justify-between items-center cursor-pointer transition-all shadow-md shadow-[#CCFF00]/10 scale-[1.02]';
            const labelSpan = chip.querySelector('.chip-label');
            if (labelSpan) labelSpan.className = 'chip-label text-[#CCFF00] font-black';
          } else {
            chip.className = 'p-1.5 rounded-xl bg-[#10141F] border border-zinc-800 hover:border-cyan-400/60 flex justify-between items-center cursor-pointer transition-all';
            const labelSpan = chip.querySelector('.chip-label');
            if (labelSpan) labelSpan.className = 'chip-label text-gray-300';
          }
        }
      });

      renderScanTarget();
    }

    function renderScanTarget() {
      const zone = bodyScanZones[activeBodyScanKey];
      if (!zone) return;

      const activeSvgId = currentAnatomyView === 'front' ? 'anatomySvgFront' : 'anatomySvgBack';
      const activeSvg = document.getElementById(activeSvgId);
      if (!activeSvg) return;

      const ring = activeSvg.querySelector('.scanRingOuter');
      const line = activeSvg.querySelector('.scanPointerLine');
      const dot = activeSvg.querySelector('.scanPointerDot');
      const txt = activeSvg.querySelector('.scanPointerLabel');
      const badge = document.getElementById('floatingScanBadge');

      const cx = zone.cx;
      const cy = zone.cy;
      const rx = zone.rx;
      const ry = zone.ry;

      if (ring) {
        ring.setAttribute('cx', String(cx));
        ring.setAttribute('cy', String(cy));
        ring.setAttribute('rx', String(rx));
        ring.setAttribute('ry', String(ry));
      }

      if (line) {
        const startX = cx + rx;
        line.setAttribute('x1', String(startX));
        line.setAttribute('y1', String(cy));
        line.setAttribute('x2', '410');
        line.setAttribute('y2', String(cy));
      }

      if (dot) {
        dot.setAttribute('cx', '410');
        dot.setAttribute('cy', String(cy));
      }

      if (txt) {
        txt.setAttribute('x', '280');
        txt.setAttribute('y', String(cy - 6));
        txt.textContent = zone.label + ': ' + zone.val;
      }

      if (badge) {
        badge.innerHTML = `<span class="text-[#CCFF00] font-bold">${zone.label}:</span> <span class="font-mono text-white">${zone.val}</span> <span class="text-[9px] text-lime-400">(${zone.change})</span>`;
      }
    }'''

# Replace old JS block
part1_start = html.find('// Interactive 3D Anthropometric Body Scan Part Selection')
part1_end = html.find('function selectBodyScanPart(partKey) {')
part1_end = html.find('}', part1_end) + 1

if part1_start != -1 and part1_end != -1:
    html = html[:part1_start] + new_js + html[part1_end:]
    print('JS block replaced successfully!')
else:
    print('Error: JS block markers not found!')

# 2. Build new HTML Card
new_card = f'''            <!-- 3D Segmental Anatomical Muscular Visualizer (Front & Back) (Phase 25) -->
            <div class="theme-card bg-[#141722] border border-[#252B3A] rounded-2xl p-3.5 space-y-3">
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-2">
                  <div class="w-7 h-7 rounded-full bg-[#CCFF00]/20 border border-[#CCFF00]/40 flex items-center justify-center text-[#CCFF00]">
                    <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="7" r="4"/><path d="M5.5 21v-2a7 7 0 0 1 13 0v2"/></svg>
                  </div>
                  <div>
                    <h4 class="text-xs font-bold text-white">نقشه آناتومیک و سایزهای بدن (3D Map)</h4>
                    <p class="text-[9.5px] text-gray-400">روی عضلات بدن یا مقادیر لیست تپ کنید</p>
                  </div>
                </div>

                <!-- Front / Back View Switcher (پشت و جلو) -->
                <div class="flex items-center bg-[#07090E] p-0.5 rounded-xl border border-zinc-800 shadow-inner">
                  <button id="btnViewFront" onclick="switchAnatomyView('front')" class="px-2.5 py-1 rounded-lg text-[10px] font-bold transition-all bg-[#CCFF00] text-black shadow-md shadow-[#CCFF00]/25 flex items-center gap-1">
                    <span>روبرو (جلو)</span>
                  </button>
                  <button id="btnViewBack" onclick="switchAnatomyView('back')" class="px-2.5 py-1 rounded-lg text-[10px] font-bold text-gray-400 hover:text-white transition-all flex items-center gap-1">
                    <span>پشت بدن</span>
                  </button>
                </div>
              </div>

              <!-- Interactive Visualizer Grid -->
              <div class="grid grid-cols-12 gap-2 items-center bg-[#07090E] p-2.5 rounded-2xl border border-zinc-800/80 shadow-inner">
                <!-- 3D Muscular Anatomy Stage Canvas (Front & Back) -->
                <div class="col-span-6 relative flex flex-col items-center justify-center h-64 bg-[#04060A] rounded-xl border border-zinc-800 overflow-hidden group select-none">
                  <!-- Radar Background Grid Overlay -->
                  <div class="absolute inset-0 bg-[radial-gradient(#38BDF8_1px,transparent_1px)] [background-size:12px_12px] opacity-15 pointer-events-none"></div>

                  <!-- High-Res Muscular Anatomy Images (Front & Back) -->
                  <img id="anatomyImgFront" src="data:image/png;base64,{b64_f}" alt="Anterior Muscle Anatomy" class="h-full w-auto object-contain filter drop-shadow-[0_0_18px_rgba(204,255,0,0.22)] select-none pointer-events-none transition-all duration-300" />
                  <img id="anatomyImgBack" src="data:image/png;base64,{b64_b}" alt="Posterior Muscle Anatomy" class="h-full w-auto object-contain filter drop-shadow-[0_0_18px_rgba(204,255,0,0.22)] select-none pointer-events-none transition-all duration-300 hidden" />

                  <!-- Interactive SVG Overlay FRONT (Hitboxes + Scanning HUD) -->
                  <svg id="anatomySvgFront" viewBox="0 0 440 680" class="absolute inset-0 w-full h-full select-none">
                    <defs>
                      <filter id="hudLimeGlowFront" x="-30%" y="-30%" width="160%" height="160%">
                        <feGaussianBlur stdDeviation="3" result="blur" />
                        <feComposite in="SourceGraphic" in2="blur" operator="over" />
                      </filter>
                    </defs>

                    <!-- Clickable Muscle Hitbox Polygons (Front) -->
                    <!-- Chest (Pectoralis) -->
                    <path onclick="selectBodyScanPart('chest')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" d="M 160 145 C 190 140, 250 140, 280 145 C 285 175, 275 195, 220 195 C 165 195, 155 175, 160 145 Z"><title>دور سینه (Pectoralis Major)</title></path>
                    
                    <!-- Waist & Abs (Rectus Abdominis) -->
                    <path onclick="selectBodyScanPart('waist')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" d="M 180 200 C 210 195, 230 195, 260 200 C 265 240, 255 285, 220 290 C 185 285, 175 240, 180 200 Z"><title>دور کمر و شکم (Core & Abs)</title></path>
                    
                    <!-- Biceps Left & Right -->
                    <ellipse onclick="selectBodyScanPart('arm')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="135" cy="205" rx="20" ry="35" transform="rotate(-15 135 205)"><title>دور بازو چپ</title></ellipse>
                    <ellipse onclick="selectBodyScanPart('arm')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="305" cy="205" rx="20" ry="35" transform="rotate(15 305 205)"><title>دور بازو راست</title></ellipse>
                    
                    <!-- Quads Left & Right -->
                    <path onclick="selectBodyScanPart('thigh')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" d="M 165 335 C 190 330, 210 335, 215 370 C 215 420, 205 465, 185 465 C 165 465, 155 420, 165 335 Z"><title>دور ران چپ (چهارسر)</title></path>
                    <path onclick="selectBodyScanPart('thigh')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" d="M 275 335 C 250 330, 230 335, 225 370 C 225 420, 235 465, 255 465 C 275 465, 285 420, 275 335 Z"><title>دور ران راست (چهارسر)</title></path>

                    <!-- Hips / Pelvis -->
                    <ellipse onclick="selectBodyScanPart('hip')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="220" cy="315" rx="48" ry="18"><title>دور باسن و لگن</title></ellipse>

                    <!-- Calves (Front Tibialis) -->
                    <ellipse onclick="selectBodyScanPart('calf')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="180" cy="540" rx="16" ry="38"><title>ساق پا چپ</title></ellipse>
                    <ellipse onclick="selectBodyScanPart('calf')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="260" cy="540" rx="16" ry="38"><title>ساق پا راست</title></ellipse>

                    <!-- Scanning HUD Target Highlight Group -->
                    <g class="transition-all duration-300 pointer-events-none">
                      <ellipse class="scanRingOuter" cx="220" cy="250" rx="46" ry="16" fill="rgba(204,255,0,0.18)" stroke="#CCFF00" stroke-width="2.4" filter="url(#hudLimeGlowFront)"/>
                      <line class="scanPointerLine" x1="266" y1="250" x2="410" y2="250" stroke="#CCFF00" stroke-width="1.5" stroke-dasharray="3,2"/>
                      <circle class="scanPointerDot" cx="410" cy="250" r="3.5" fill="#CCFF00"/>
                      <text class="scanPointerLabel" x="280" y="244" fill="#CCFF00" font-size="13" font-family="monospace" font-weight="900">۸۳.۰ cm</text>
                    </g>
                  </svg>

                  <!-- Interactive SVG Overlay BACK (Hitboxes + Scanning HUD) -->
                  <svg id="anatomySvgBack" viewBox="0 0 440 680" class="absolute inset-0 w-full h-full select-none hidden">
                    <defs>
                      <filter id="hudLimeGlowBack" x="-30%" y="-30%" width="160%" height="160%">
                        <feGaussianBlur stdDeviation="3" result="blur" />
                        <feComposite in="SourceGraphic" in2="blur" operator="over" />
                      </filter>
                    </defs>

                    <!-- Clickable Muscle Hitbox Polygons (Back) -->
                    <!-- Upper Back & Lats (Traps + Latissimus) -->
                    <path onclick="selectBodyScanPart('back')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" d="M 160 135 C 200 125, 240 125, 280 135 C 275 190, 240 240, 220 245 C 200 240, 165 190, 160 135 Z"><title>عضلات پشتی و زیربغل (Lats & Traps)</title></path>
                    
                    <!-- Lower Back (Erector Spinae) -->
                    <rect onclick="selectBodyScanPart('back')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" x="195" y="245" width="50" height="40" rx="8"><title>فیله کمر (Lower Back)</title></rect>
                    
                    <!-- Glutes (Gluteus Maximus) -->
                    <path onclick="selectBodyScanPart('hip')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" d="M 175 290 C 200 285, 240 285, 265 290 C 275 330, 250 355, 220 355 C 190 355, 165 330, 175 290 Z"><title>عضلات باسن و سرینی (Glutes)</title></path>
                    
                    <!-- Hamstrings Left & Right -->
                    <ellipse onclick="selectBodyScanPart('thigh')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="185" cy="405" rx="22" ry="45"><title>همسترینگ چپ (پشت ران)</title></ellipse>
                    <ellipse onclick="selectBodyScanPart('thigh')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="255" cy="405" rx="22" ry="45"><title>همسترینگ راست (پشت ران)</title></ellipse>
                    
                    <!-- Triceps Left & Right -->
                    <ellipse onclick="selectBodyScanPart('arm')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="130" cy="205" rx="18" ry="32"><title>پشت بازو چپ (Triceps)</title></ellipse>
                    <ellipse onclick="selectBodyScanPart('arm')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="310" cy="205" rx="18" ry="32"><title>پشت بازو راست (Triceps)</title></ellipse>

                    <!-- Calves Back (Gastrocnemius) -->
                    <ellipse onclick="selectBodyScanPart('calf')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="180" cy="535" rx="18" ry="40"><title>دوقلو ساق پا چپ</title></ellipse>
                    <ellipse onclick="selectBodyScanPart('calf')" class="hover:fill-[#CCFF00]/30 transition-all cursor-pointer" fill="rgba(56,189,248,0.06)" stroke="#38BDF8" stroke-width="1.4" stroke-dasharray="3,2" cx="260" cy="535" rx="18" ry="40"><title>دوقلو ساق پا راست</title></ellipse>

                    <!-- Scanning HUD Target Highlight Group Back -->
                    <g class="transition-all duration-300 pointer-events-none">
                      <ellipse class="scanRingOuter" cx="220" cy="180" rx="58" ry="20" fill="rgba(204,255,0,0.18)" stroke="#CCFF00" stroke-width="2.4" filter="url(#hudLimeGlowBack)"/>
                      <line class="scanPointerLine" x1="278" y1="180" x2="410" y2="180" stroke="#CCFF00" stroke-width="1.5" stroke-dasharray="3,2"/>
                      <circle class="scanPointerDot" cx="410" cy="180" r="3.5" fill="#CCFF00"/>
                      <text class="scanPointerLabel" x="280" y="174" fill="#CCFF00" font-size="13" font-family="monospace" font-weight="900">۱۱۰.۰ cm</text>
                    </g>
                  </svg>

                  <!-- Scanner Status Badges -->
                  <div class="absolute bottom-1.5 left-2 text-[8px] font-mono text-gray-400 bg-black/60 px-1.5 py-0.5 rounded border border-zinc-800">
                    <span id="anatomyViewBadge">نمای روبرو (ANTERIOR)</span>
                  </div>
                  <div class="absolute bottom-1.5 right-2 text-[8px] font-mono text-cyan-400 flex items-center gap-1 bg-black/60 px-1.5 py-0.5 rounded border border-zinc-800">
                    <span class="w-1.5 h-1.5 rounded-full bg-[#CCFF00] animate-ping"></span>
                    <span>3D BIO-SCAN</span>
                  </div>
                </div>

                <!-- Interactive Segment Selector Chips (Anthropometric Zones) -->
                <div class="col-span-6 space-y-1 text-[10px]">
                  <div onclick="selectBodyScanPart('waist')" id="scanChip-waist" class="p-1.5 rounded-xl bg-[#CCFF00]/20 border border-[#CCFF00] flex justify-between items-center cursor-pointer transition-all shadow-md shadow-[#CCFF00]/10 scale-[1.02]">
                    <span class="chip-label text-[#CCFF00] font-black">دور کمر:</span>
                    <span class="font-mono font-bold text-white text-[10px]">۸۳.۰ cm <span class="text-[#CCFF00] text-[8.5px]">↓ ۶cm</span></span>
                  </div>
                  <div onclick="selectBodyScanPart('chest')" id="scanChip-chest" class="p-1.5 rounded-xl bg-[#10141F] border border-zinc-800 hover:border-cyan-400/60 flex justify-between items-center cursor-pointer transition-all">
                    <span class="chip-label text-gray-300">دور سینه:</span>
                    <span class="font-mono font-bold text-cyan-300 text-[10px]">۱۰۲.۰ cm <span class="text-amber-400 text-[8.5px]">↑ ۴cm</span></span>
                  </div>
                  <div onclick="selectBodyScanPart('arm')" id="scanChip-arm" class="p-1.5 rounded-xl bg-[#10141F] border border-zinc-800 hover:border-cyan-400/60 flex justify-between items-center cursor-pointer transition-all">
                    <span class="chip-label text-gray-300">دور بازو:</span>
                    <span class="font-mono font-bold text-amber-300 text-[10px]">۳۷.۵ cm <span class="text-amber-400 text-[8.5px]">↑ ۱.۵</span></span>
                  </div>
                  <div onclick="selectBodyScanPart('thigh')" id="scanChip-thigh" class="p-1.5 rounded-xl bg-[#10141F] border border-zinc-800 hover:border-cyan-400/60 flex justify-between items-center cursor-pointer transition-all">
                    <span class="chip-label text-gray-300">دور ران:</span>
                    <span class="font-mono font-bold text-emerald-300 text-[10px]">۵۸.۰ cm <span class="text-emerald-400 text-[8.5px]">↑ ۲cm</span></span>
                  </div>
                  <div onclick="selectBodyScanPart('hip')" id="scanChip-hip" class="p-1.5 rounded-xl bg-[#10141F] border border-zinc-800 hover:border-cyan-400/60 flex justify-between items-center cursor-pointer transition-all">
                    <span class="chip-label text-gray-300">دور باسن:</span>
                    <span class="font-mono font-bold text-purple-300 text-[10px]">۹۸.۰ cm <span class="text-[#CCFF00] text-[8.5px]">↓ ۱cm</span></span>
                  </div>
                  <div onclick="selectBodyScanPart('back')" id="scanChip-back" class="p-1.5 rounded-xl bg-[#10141F] border border-zinc-800 hover:border-cyan-400/60 flex justify-between items-center cursor-pointer transition-all">
                    <span class="chip-label text-gray-300">زیربغل و پشت:</span>
                    <span class="font-mono font-bold text-sky-300 text-[10px]">۱۱۰.۰ cm <span class="text-[#CCFF00] text-[8.5px]">↑ ۳cm</span></span>
                  </div>
                  <div onclick="selectBodyScanPart('calf')" id="scanChip-calf" class="p-1.5 rounded-xl bg-[#10141F] border border-zinc-800 hover:border-cyan-400/60 flex justify-between items-center cursor-pointer transition-all">
                    <span class="chip-label text-gray-300">ساق پا:</span>
                    <span class="font-mono font-bold text-blue-300 text-[10px]">۳۹.۰ cm <span class="text-[#CCFF00] text-[8.5px]">↑ ۰.۸</span></span>
                  </div>
                  <div onclick="selectBodyScanPart('fat')" id="scanChip-fat" class="p-1.5 rounded-xl bg-[#10141F] border border-zinc-800 hover:border-cyan-400/60 flex justify-between items-center cursor-pointer transition-all">
                    <span class="chip-label text-gray-300">درصد چربی:</span>
                    <span class="font-mono font-bold text-orange-400 text-[10px]">۲۷.۲% <span class="text-[#CCFF00] text-[8.5px]">↓ ۲.۳%</span></span>
                  </div>
                </div>
              </div>

              <!-- Quick Focus HUD Pill -->
              <div id="floatingScanBadge" class="bg-[#07090E] border border-zinc-800 rounded-xl px-3 py-1.5 flex items-center justify-between text-[10.5px]">
                <span class="text-[#CCFF00] font-bold">دور کمر و شکم:</span>
                <span class="font-mono text-white font-bold">۸۳.۰ cm</span>
                <span class="text-[9.5px] text-lime-400">(کاهش ۶ سانتی‌متری)</span>
              </div>
            </div>'''

# Replace Card
card_start = html.find('<!-- 3D Segmental Anatomical Wireframe Visualizer (Phase 12) -->')
card_end = html.find('<!-- Glowing Weight Progress Interactive Line Chart (Phase 12) -->')

if card_start != -1 and card_end != -1:
    html = html[:card_start] + new_card + '\n\n            ' + html[card_end:]
    print('Card replaced successfully!')
else:
    print('Error: Card markers not found!')

with open('gymbro_redmi_simulator.html', 'w', encoding='utf-8') as f:
    f.write(html)

print('File updated successfully! Total bytes:', len(html))
