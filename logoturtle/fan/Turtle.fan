/**
 * Created by IntelliJ IDEA.
 * User: freds
 * Date: Nov 20, 2009
 * Time: 11:02:50 PM
 * To change this template use File | Settings | File Templates.
 */
using gfx
using fwt

class TurtleWindow {
  TurtleGarden garden
  Window win

  Void main()
  {
    TurtleWindow().win.open
  }

  new make()
  {
    garden = TurtleGarden()
    garden.doc.text = "AV 100"
    win = Window
    {
      EdgePane {
        size = Size(900,520)
        left = GridPane {
          numCols = 1
          size = Size(380,520)
          ScrollPane {
//            size = Size(380,420)
            content = RichText {
              size  = Size(370,420)
              model = garden.doc
              font  = garden.doc.defFont
              //hbar.onModify.add(&onScroll("hbar"))
              //vbar.onModify.add(&onScroll("vbar"))
              //onVerify.add |Event e| { echo("verify: $e.data") }
              //onVerifyKey.add |Event e| { echo("verify: $e") }
              //onSelect.add |Event e| { echo(e) }
            }
          },
          Button { text = "Clean";    onAction.add {garden.clean} },
          Button { text = "Execute";  onAction.add {garden.execute} },
          Button { text = "Redraw";   onAction.add {garden.refresh} },
        }
        right = InsetPane {
            size = Size(520,520)
            makeGarden,
        }
      },
    }
  }

  **
  ** Build a pane showing how to use Graphics
  **
  Widget makeGarden()
  {
    return ScrollPane {
      size = Size(520,520)
      content=garden
    }
  }
}



**************************************************************************
** GraphicsDemo
**************************************************************************

class TurtleCommands {
  TurtleCommand? forward // := TurtleCommand() {}
  TurtleCommand? backward
  TurtleCommand? turn_left
  TurtleCommand? turn_right
  TurtleCommand? pen_up
  TurtleCommand? pen_down
  TurtleCommand? function
  TurtleCommand? repeat
}

class EnglishTurtleCommands {

}

class FrenchTurtleCommands {

}

abstract class TurtleCommand {
  TurtleGarden? garden
  Str[]? token
  abstract Void execute()
}

class ForwardTurtleCommand : TurtleCommand {
  new make(TurtleGarden? garden := null) {
    this.garden = garden
  }

  override Void execute() {
    if (garden == null) return;
    //garden.turtle.move
  }
}

class Turtle {
  ** TODO: Support changing size of garden
  readonly Int width := TurtleMove.MAX
  readonly Int height := TurtleMove.MAX

  Int x := (width.toFloat / 2f).toInt()
  Int y := (height.toFloat / 2f).toInt()
  Float a := 0f
  Bool penDown := true
  Color color := Color.black

  TurtleMove move(Float distance) {
    tm := TurtleMove.makeFromDist(x, y, a, distance)
    x = tm.x2
    y = tm.y2
    return tm
  }
}

class TurtleGarden : Canvas
{
  Turtle turtle := Turtle()
  Bool dirty := true
  Doc doc := Doc()

  ** All color fields of the garden
  TurtleMove[] moves := [,]
  const Image turtleImage := Image(`fan:/sys/pod/logoturtle/img/turtle.gif`)

  Int width() { return turtle.width }
  Int height() { return turtle.height }

  Void clean() {
    moves = [,]
    turtle = Turtle()
    dirty = true
    repaint
  }

  Void execute() {
    moves.add(turtle.move(150f))
    turtle.a += 90f
    moves.add(turtle.move(150f))
    turtle.a += 90f
    moves.add(turtle.move(150f))
    turtle.a += 90f
    moves.add(turtle.move(150f))
    turtle.a -= 260f
    refresh()
    /*
    doc.text.split(' ',false).each |Str token| {
      switch (token) {
        case "AV": case "AVANCE":
      }
    }
    */
  }

  Void refresh() {
    dirty = true
    repaint
  }

  override Size prefSize(Hints hints := Hints.defVal) { return Size.make(width, height) }

  override Void onPaint(Graphics g)
  {
    if (dirty) 
      dirty = false
    else
      return

    g.antialias = false
    g.brush = Color.green
    g.fillRect(0,0,width(),height())
    moves.each |TurtleMove tm| {
        switch (tm.color) {
          case TurtleColor.black: g.brush = Color.black
        }
        if (tm.aRad != null) {
            Int cix := tm.x1
            Int ciy := tm.y1
            Float cx := tm.x1.toFloat()
            Float cy := tm.y1.toFloat()
            Float dx := 5f * tm.aRad.cos()
            Float dy := 5f * tm.aRad.sin()
            Float cd := 0f
            while (cd < tm.distance) {
                cx += dx
                cy += dy
                g.drawLine(cix, ciy, cx.toInt(), cy.toInt())
                cix = cx.toInt()
                ciy = cy.toInt()
                g.drawImage(turtleImage, cix, ciy)
                //Actor.sleep(10ms)
                cd += 5f
            }
        } else {
            g.drawLine(tm.x1, tm.y1, tm.x2, tm.y2)
        }
    }
    g.drawImage(turtleImage, turtle.x, turtle.y)
  }
}

**
** This class provides a grossly inefficient implementation
** for managing a document.  But should be easy to understand.
**
class Doc : RichTextModel
{
  override Str text

  const Log log := Log.get("Doc")

  override Int charCount()
  {
    r := text.size
    log.debug("charCount => $r")
    return r
  }

  override Int lineCount()
  {
    r := text.splitLines.size
    log.debug("lineCount => $r")
    return r
  }

  override Str line(Int lineIndex)
  {
    r := text.splitLines[lineIndex]
    log.debug("line($lineIndex) => $r")
    return r
  }

  override Int lineAtOffset(Int offset)
  {
    line := 0
    for (i:=0; i<offset; ++i) if (text[i] == '\n') line++
    log.debug("lineAtOffset($offset) => $line")
    return line
  }

  override Int offsetAtLine(Int lineIndex)
  {
    Int r := text.splitLines[0..<lineIndex]
      .reduce(0) |Obj o, Str line->Int| { return line.size+o+1 }
    log.debug("offsetAtLine($lineIndex) => $r")
    return r
  }

  override Str textRange(Int start, Int len)
  {
    r := text[start..<start+len]
    log.debug("textRange($start, $len) => $r.toCode")
    return r
  }

  override Void modify(Int start, Int len, Str newText)
  {
    log.debug("modify($start, $len, $newText)")

    // update model
    oldText := textRange(start, len)
    text = text[0..<start] + newText + text[start+len..-1]

    // must fire modify event
    tc := TextChange
    {
      it.startOffset    = start
      it.startLine      = lineAtOffset(start)
      it.oldText        = oldText
      it.newText        = newText
      it.oldNumNewlines = oldText.numNewlines
      it.newNumNewlines = newText.numNewlines
    }
    onModify.fire(Event { id = EventId.modified; data = tc })
  }

  override Obj[]? lineStyling(Int lineIndex)
  {
    // style { or } using brace color,
    // and // or ** as end of line comments
    line := line(lineIndex)
    styles := Obj[,]
    inComment := false
    last := 0
    line.each |Int ch, Int i|
    {
      if (inComment) return
      if (ch == '{' || ch == '}')
        { styles.add(i).add(brace).add(i+1).add(normal) }
      else if (ch == '/' && last == '/')
        { styles.add(i-1).add(comment); inComment = true }
      else if (ch == '*' && last == '*')
        { styles.add(i-1).add(comment); inComment = true }
      last = ch

    }
    if (styles.first != 0) styles.insert(0, 0).insert(1, normal)
    return styles
  }

  Font defFont := Font { name="Courier New"; size=12 }
  RichTextStyle normal  := RichTextStyle { font=defFont }
  RichTextStyle brace   := RichTextStyle { font=defFont; fg=Color.red }
  RichTextStyle comment := RichTextStyle { font=defFont; fg=Color.make(0x00_7f_00) }
}
