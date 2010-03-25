/**
 * Created by IntelliJ IDEA.
 * User: freds
 * Date: Mar 15, 2010
 * Time: 4:22:49 PM
 * To change this template use File | Settings | File Templates.
 */

enum TurtleColor { black, white, green, red, blue }

class TurtleMove {
    static const Int MAX := 512
    static Int check(Int v) {
        return v < 0 ? 0 : ((v > MAX) ? MAX : v)
    }

    new make(Int sx, Int sy, Int ex, Int ey, Float? angle := null, Float? dist := null) {
        x1 = check(sx)
        y1 = check(sy)
        x2 = check(ex)
        y2 = check(ey)
        aRad = angle
        distance = dist
    }

    static TurtleMove makeFromDist(Int x1, Int y1, Float angle, Float dist) {
        aRad := angle.toRadians()
        return TurtleMove(x1, y1,
           (x1.toFloat() + (dist * aRad.cos())).toInt(),
           (y1.toFloat() + (dist * aRad.sin())).toInt(),
           aRad,
           dist)
    }

    const TurtleColor color := TurtleColor.black
    Float? aRad
    Float? distance
    const Int x1
    const Int y1
    const Int x2
    const Int y2
}

/*
class TurtleMoving : TurtleMove {

}
*/