/**
 * Created by IntelliJ IDEA.
 * User: freds
 * Date: Mar 17, 2010
 * Time: 8:24:50 PM
 * To change this template use File | Settings | File Templates.
 */

class PositronicModulo : PositronicFwt {
    // Positronic variable
    Int? antival {
        get { return getter(#antival) }
        set { setter(#antival, val) }
    }

    Void mod() {
        antival = -1
        print("The antival is $antival")
        Int? val := (antival + 1) % 3
        print("The val is $val")
        antival = val
    }

    Void main() {
        run(#mod)
    }
}