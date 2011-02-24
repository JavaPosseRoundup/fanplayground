
class CellTest : Test {

  Void testNeighbors() {
    g := GameBoard()
    verifyEq(g.cells[0].neighbors().size,8)
    verifyEq(g.cells[7].neighbors().size,8)
    verifyEq(g.cells[4].neighbors().size,8)
    verifyEq(g.cells[12].neighbors().size,8)
    verifyEq(g.cells[56].neighbors().size,8)
    verifyEq(g.cells[63].neighbors().size,8)
  }

}