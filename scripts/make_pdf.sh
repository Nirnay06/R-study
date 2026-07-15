#!/bin/bash
# make_pdf.sh <input.html> <output.pdf>
# Converts an HTML file to PDF using headless Chrome.
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <input.html> <output.pdf>" >&2
  exit 1
fi

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
INPUT="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
OUTPUT="$2"

mkdir -p "$(dirname "$OUTPUT")"

"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$OUTPUT" "file://$INPUT" 2>/dev/null

echo "PDF created: $OUTPUT"
