with open('gymbro_redmi_simulator.html', 'r', encoding='utf-8') as f:
    html = f.read()

dup_marker1 = '<script>    // ================= FOLDABLE MODE & CABBAGE ALIGNMENT ENGINE ================='
dup_marker2 = '      // ================= FOLDABLE MODE & CABBAGE ALIGNMENT ENGINE ================='

pos1 = html.find(dup_marker1)
pos2 = html.find(dup_marker2)

if pos1 != -1 and pos2 != -1 and pos1 < pos2:
    html = html[:pos1] + '<script>\n' + html[pos2:]
    print('Duplicate foldable engine removed successfully!')
else:
    print('Markers not found or order invalid:', pos1, pos2)

with open('gymbro_redmi_simulator.html', 'w', encoding='utf-8') as f:
    f.write(html)
print('File updated!')
