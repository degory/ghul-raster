#!/bin/bash

# Writes the Hershey face into a ghūl source file, because the compiler emits
# no embedded resources and a stroke font is data the library cannot draw
# without. Run it when the font changes, which is approximately never.
#
#   build/embed-font.sh

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)

{
    echo "namespace Raster is"
    echo "    // The Hershey simplex face, one glyph a line, as fonts/futural.jhf"
    echo "    // holds it. Written by build/embed-font.sh; see fonts/hershey.txt"
    echo "    // for the terms it is distributed under."
    echo "    class FONT_DATA is"
    echo "        SIMPLEX: string static =>"

    sed -e 's/\\/\\\\/g' -e 's/^/            "/' -e 's/$/\\n"/' "$ROOT/fonts/futural.jhf"

    echo "    si"
    echo "si"
} > "$ROOT/src/font-data.ghul"

echo "wrote src/font-data.ghul"
