
class CellTest : Test {

  Void testNeighbors() {
    g := GameBoard()
    verifyEq(g.cells[0].neighbors().size,8)
  }

}