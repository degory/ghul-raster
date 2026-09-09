# ghul-raster

Drawing into a PNG, from ghūl, with no dependency on a graphics stack.

`System.Drawing.Common` is GDI+ and throws on Linux; SkiaSharp needs a native
library; neither runs under WebAssembly. This library allocates a buffer,
draws strokes into it, and writes a PNG, all in managed code, so it runs
wherever ghūl does.

```ghul
use Raster.IMAGE

let image = IMAGE(640, 400)

image.view(-0.5D, -1.4D, 6.8D, 1.4D)

image.colour(20ub, 60ub, 200ub)
image.stroke(2.0D)

image.line(x0, System.Math.sin(x0), x1, System.Math.sin(x1))

image.text(0.1D, 1.15D, 18.0D, "sin x")

image.write("plot.png")
```

## Coordinates

`view` maps a rectangle of your own coordinates onto the whole image, with y
increasing upwards as it does in mathematics rather than downwards as it does
in an image. A program then works in the space its problem is stated in - the
complex plane, a unit square, the range its data covers - and says nothing
about pixels.

The rectangle is mapped exactly, so it stretches where its proportions differ
from the image's: a circle drawn in a square rectangle on a 640 by 320 image
comes out an ellipse. Choose proportions that match, or accept the stretch.

Without a `view`, positions are already pixels.

Sizes are always in pixels, whatever the view. A label is as tall as it is
asked to be and a stroke as wide, because a label that stretched with the
axes would be unreadable on any plot whose axes differ in scale.

## Strokes

Everything is drawn as a stroke, and coverage is computed from the distance to
the line segment. Ends and joins are round, and the edges are antialiased.
`stroke` sets the width in pixels; `colour` sets what is laid down.

## Pixels

`set_pixel` writes a pixel outright and `pixel` reads one back. `blend` lays
part of the current colour over what is already there, which is what a program
drawing its own shapes needs to antialias them. A position outside the image is
ignored by both writers.

## A turtle

`TURTLE` is a pen on an image, at a position and a heading, told how far to go
rather than where to go: `forward`, `turn`, `face`, `move_to`, `pen_up` and
`pen_down`. A curve stated as a sequence of turns and steps is written that way
directly.

Angles are in degrees and follow the image's coordinates, so with a `view` set
a positive turn is counter-clockwise and without one it is the other way about.

## Text

`text` draws with its baseline at the position given and the height in pixels
from baseline to the top of a capital. `text_width` says how wide that text
will be, for placing it. The weight follows the height unless it is given.

The face is a Hershey stroke font, so text is drawn with the same strokes as
everything else, and scales without a rasteriser.

## Saying where an image belongs

A program that draws has two outputs, and nothing in its text says where the
pictures go.

```ghul
image.write("plot.png")
image.show("plot.png")
```

`show` writes a line naming the image:

```
<<image plot.png>>
```

That is a contract with whatever displays the output, not an instruction to
anything in particular. A publisher can turn it into a reference its
destination understands and put the file where that reference points; a
console that can display images can display it in place; a terminal shows the
line, which names a file the reader was told about anyway.

Nothing here knows where the output is going, and nothing that reads the
marker needs to know how the image was drawn.


## The font

The Hershey Fonts were originally created by Dr. A. V. Hershey while working
at the U. S. National Bureau of Standards. The format of the font data was
originally created by James Hurt, Cognition, Inc.

`fonts/futural.jhf` is the face and `fonts/hershey.txt` is the notice its
distribution terms require to accompany it. `build/embed-font.sh` writes the
face into `src/font-data.ghul`, which is what the library reads: the compiler
emits no embedded resources (degory/ghul#2477), and a source string works
under WebAssembly and single-file publish, where a file beside the assembly
does not.

## Tests

```sh
dotnet test unit-tests
dotnet ghul-test --use-dotnet-build integration-tests
```

The unit tests cover the font and the geometry. The integration test draws a
plot and compares it against `plot.png.expected`, which is the assertion that
matters: it is the whole picture, and it notices a stroke a fifth of a pixel
too thin.
