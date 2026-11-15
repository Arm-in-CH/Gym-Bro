import re

def update_hero_and_verify():
    with open('gymbro_redmi_simulator.html', 'r', encoding='utf-8') as f:
        html = f.read()

    # Upgrade the Dashboard Hero Action Card
    old_hero = re.compile(
        r'(<!-- HERO ACTION CARD: TODAY\'S WORKOUT -->\s*<div class="theme-card bg-gradient-to-br from-\[#161B26\] to-\[#0E121B\].*?)(<h3 class="theme-text-primary text-base font-black text-white">برنامه شماره ۲: سینه، بازو و فیله کمر</h3>\s*<p class="theme-text-muted text-\[11px\] text-gray-400 mt-1 leading-relaxed">پرس سینه هالتر هرمی • قفسه کراس‌اور • بالاسینه دمبل سوپر با شنا • سوپرست‌های بازو</p>)',
        re.DOTALL
    )

    new_hero_replacement = r'''\1<div class="flex items-center gap-1.5 mb-1.5">
                <span class="text-[9px] font-bold bg-[#FFB800]/20 text-[#FFB800] px-2 py-0.5 rounded border border-[#FFB800]/30 flex items-center gap-1">
                  <span>🎖️</span>
                  <span>مربی خصوصی: استاد علیرضا راد (IFBB Pro)</span>
                </span>
                <span class="text-[9px] text-gray-400 bg-zinc-800/80 px-1.5 py-0.5 rounded">RPE 8.5</span>
              </div>
              <h3 class="theme-text-primary text-base font-black text-white">برنامه شماره ۲: سینه، بازو و فیله کمر</h3>
              <div class="flex items-center gap-2 my-2 text-[10px] text-gray-300">
                <span class="flex items-center gap-1 font-bold text-white">⏱️ ۴۵ دقیقه</span>
                <span>•</span>
                <span class="text-[#00F0FF] font-bold">🔥 ۵۲۰ کالری</span>
                <span>•</span>
                <span class="text-[#CCFF00] font-bold">۶ حرکت هایپرتروفی</span>
              </div>
              <!-- Structured Movement Pills -->
              <div class="grid grid-cols-2 gap-1.5 my-2.5 text-[11px]">
                <div class="flex items-center justify-between p-1.5 rounded-lg bg-[#0E121B] border border-zinc-800">
                  <span class="font-bold text-gray-200">پرس سینه هرمی</span>
                  <span class="text-[10px] font-mono text-[#CCFF00]">۴×۱۲-۶</span>
                </div>
                <div class="flex items-center justify-between p-1.5 rounded-lg bg-[#0E121B] border border-zinc-800">
                  <span class="font-bold text-gray-200">قفسه کراس‌اور</span>
                  <span class="text-[10px] font-mono text-[#CCFF00]">۳×۱۰</span>
                </div>
                <div class="flex items-center justify-between p-1.5 rounded-lg bg-[#0E121B] border border-zinc-800">
                  <span class="font-bold text-purple-300">سوپر بالاسینه+شنا</span>
                  <span class="text-[10px] font-mono text-purple-300">۳×۱۰</span>
                </div>
                <div class="flex items-center justify-between p-1.5 rounded-lg bg-[#0E121B] border border-zinc-800">
                  <span class="font-bold text-cyan-300">سوپرست‌های بازو</span>
                  <span class="text-[10px] font-mono text-cyan-300">۳×۱۲</span>
                </div>
              </div>'''

    html, count = old_hero.subn(new_hero_replacement, html)
    print(f'Dashboard Hero card upgraded: {count} occurrence(s)')

    with open('gymbro_redmi_simulator.html', 'w', encoding='utf-8') as f:
        f.write(html)
    print('Verified gymbro_redmi_simulator.html successfully!')

if __name__ == '__main__':
    update_hero_and_verify()
