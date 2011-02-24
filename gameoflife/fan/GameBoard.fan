class GameBoard {
  const Int width
  Cell[] cells := [,]

  new make(Int w := 8) {
    width = w
    (0..(width * width - 1)).each |idx| {
      cells.add(Cell(this, idx))
    }
  }
}