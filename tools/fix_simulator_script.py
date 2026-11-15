with open('gymbro_redmi_simulator.html', 'r', encoding='utf-8') as f:
    html = f.read()

# 1. Fix line 7: close tailwind script and open fresh script
old_tw = '<script src="https://www.gstatic.com/antigravity/web/dev/tailwindcss.min.js">'
new_tw = '<script src="https://www.gstatic.com/antigravity/web/dev/tailwindcss.min.js"></script>\n  <script>'

if old_tw in html:
    html = html.replace(old_tw, new_tw, 1)
    print('Tailwind script tag separated successfully!')
else:
    print('Tailwind script tag pattern not found directly!')

# 2. Clean up leftover fragment
leftover_start = html.find("    } else {\n            chip.className = 'p-1.5 rounded-xl bg-[#10141F]")
leftover_end = html.find("  </script>\n  <style>", leftover_start)

if leftover_start != -1 and leftover_end != -1:
    html = html[:leftover_start] + "    }\n\n" + html[leftover_end:]
    print('Leftover function fragment cleaned up successfully!')
else:
    print('Leftover markers:', leftover_start, leftover_end)

with open('gymbro_redmi_simulator.html', 'w', encoding='utf-8') as f:
    f.write(html)

print('Updated gymbro_redmi_simulator.html successfully!')
