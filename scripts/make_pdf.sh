#!/bin/bash
# make_pdf.sh <input.html> <output.pdf>
# Converts an HTML file to PDF. Works on macOS (Chrome) and Linux cloud
# containers (chromium if present, else pure-Python fpdf2 fallback).
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <input.html> <output.pdf>" >&2
  exit 1
fi

INPUT="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
OUTPUT="$2"
mkdir -p "$(dirname "$OUTPUT")"

CHROME="${CHROME_BIN:-}"
if [ -z "$CHROME" ]; then
  for c in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    google-chrome google-chrome-stable chromium chromium-browser chrome headless-shell; do
    if [ -x "$c" ] || command -v "$c" >/dev/null 2>&1; then CHROME="$c"; break; fi
  done
fi

if [ -n "$CHROME" ]; then
  "$CHROME" --headless --disable-gpu --no-sandbox --no-pdf-header-footer \
    --print-to-pdf="$OUTPUT" "file://$INPUT" 2>/dev/null
else
  # No browser available (e.g. cloud sandbox): render with fpdf2.
  # Supports a basic HTML subset (h1-h6, p, b/i, ul/ol/li, table) — keep HTML simple.
  python3 - "$INPUT" "$OUTPUT" <<'PY'
import subprocess, sys
try:
    import fpdf  # noqa: F401
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "fpdf2"])
from fpdf import FPDF

html = open(sys.argv[1], encoding="utf-8").read()
pdf = FPDF()
pdf.add_page()
pdf.write_html(html)
pdf.output(sys.argv[2])
PY
fi

[ -s "$OUTPUT" ] || { echo "PDF not created: $OUTPUT" >&2; exit 1; }
echo "PDF created: $OUTPUT"
