#!/bin/sh
# Regenerate the README screenshot from docs/showcase/demo.bend.
# Needs: bend 2.0.38 (BEND), ImageMagick `magick` with a monospace font (FONT).
# usage: sh docs/showcase/make-screenshots.sh        (run from the repository root)
set -eu
bend=${BEND:-bend}
font=${FONT:-/System/Library/Fonts/Menlo.ttc}
here=$(cd "$(dirname "$0")" && pwd -P)
out="$here/encode-sample.png"
txt=$(mktemp)
trap 'rm -f "$txt"' EXIT

"$bend" "$here/demo.bend" 2> /dev/null | grep -v '^bend [0-9.]* is available' > "$txt"

magick -background '#1e1e2e' -fill '#cdd6f4' -font "$font" -pointsize 22 \
  -bordercolor '#1e1e2e' label:@"$txt" -border 28x24 \
  -strip -colors 16 PNG8:"$out"
echo "$out"
