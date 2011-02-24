using gfx
using fwt

class Main {
  Void main(Str[] args) {
    GameBoard board := GameBoard(16)
    Int widthPx := (board.width * 26) - 2

    Window {
      size = Size(widthPx, widthPx + 24)
      GridPane {
        numCols = board.width
        hgap = 2
        vgap = 2
        g := it
        board.cells[4].state = CellState.alive
        board.cells.each |cell| {
          g.add(Box { color = (cell.state == CellState.alive) ? Color.black : Color.white})
        }
      },
    }.open
  }
}

class Box : Canvas
{
  Color color := Color.green

  override Size prefSize(Hints hints := Hints.defVal)
  {
    Size(24, 24)
  }

  override Void onPaint(Graphics g)
  {
    size := this.size
    g.brush = color
    g.fillRect(0, 0, size.w, size.h)
    g.brush = Color.black
    g.drawRect(0, 0, size.w-1, size.h-1)
  }
}