/**
 * Created by IntelliJ IDEA.
 * User: freds
 * Date: Mar 15, 2010
 * Time: 4:56:11 PM
 * To change this template use File | Settings | File Templates.
 */

class MoveTest : Test {
    Void testMove() {
        TurtleMove? tm
        tm = TurtleMove (1,2,3,4)
        verifyEq(1, tm.x1)
        verifyEq(2, tm.y1)
        verifyEq(3, tm.x2)
        verifyEq(4, tm.y2)
    }
}