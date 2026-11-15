import re
import sys
from pathlib import Path
from xml.etree import ElementTree

html_path = Path(__file__).resolve().parents[1] / "gymbro_redmi_simulator.html"
html = html_path.read_text(encoding="utf-8")
svg_fragments = re.findall(r"<svg\b[^>]*>[\s\S]*?</svg\s*>", html, re.IGNORECASE)

if not svg_fragments:
    print(f"FAIL: no inline SVGs found in {html_path.name}")
    sys.exit(1)

errors = []
for index, fragment in enumerate(svg_fragments, start=1):
    try:
        ElementTree.fromstring(fragment)
    except ElementTree.ParseError as error:
        errors.append(f"SVG {index}: {error}")

if errors:
    print("FAIL: invalid inline SVG markup")
    print("\n".join(errors))
    sys.exit(1)

print(f"PASS: validated {len(svg_fragments)} inline SVG fragments in {html_path.name}.")
