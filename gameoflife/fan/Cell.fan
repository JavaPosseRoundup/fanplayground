
enum class CellState {
  dead, alive
}

class Cell {
  GameBoard board
  Int index
  CellState state := CellState.dead

  new make(GameBoard b, Int i) { board = b; index = i; }

  Cell[] neighbors() {
    return [,]
  }
}