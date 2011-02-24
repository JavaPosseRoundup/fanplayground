
enum class CellState {
  dead, alive
}

class Cell {
  Int index
  CellState state := CellState.dead

  new make() {}
}