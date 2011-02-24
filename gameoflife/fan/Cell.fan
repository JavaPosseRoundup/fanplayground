
enum class CellState {
  dead, alive
}

class Cell {
  GameBoard board
  Int index
  CellState state := CellState.dead

  new make(GameBoard b, Int i) { board = b; index = i; }

  Cell[] neighbors() {
    Cell[] res := [,]
    (-1..1).each |line| {
      lineIdx := index + (line * board.width)
      if (lineIdx < 0) lineIdx = board.cells.size + lineIdx
      if (lineIdx >= board.cells.size) lineIdx = lineIdx - board.cells.size
      (-1..1).each |col| {
        cellIdx := lineIdx + col
        if (cellIdx < 0) cellIdx = board.width + cellIdx
        if (cellIdx >= board.cells.size) cellIdx = cellIdx - board.width
        if (col != 0 || line != 0) res.add(board.cells[cellIdx])
      }
    }
    return res
  }
}