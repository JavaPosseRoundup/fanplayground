
class CellTest : Test {

  Void testNeighbors() {
    g := GameBoard()
    verifyNeighbors(g.cells[0])
    verifyNeighbors(g.cells[7])
    verifyNeighbors(g.cells[4])
    verifyNeighbors(g.cells[12])
    verifyNeighbors(g.cells[56])
    verifyNeighbors(g.cells[63])
  }

  private Void verifyNeighbors(Cell c) {
    n := c.neighbors
    verifyEq(n.size,8)
    prev := c.index - 1
    if (prev < 0) prev += c.board.width
    verify(n.any {it.index == prev})
  }

}