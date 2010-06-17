/**
 * Created by IntelliJ IDEA.
 * User: freds
 * Date: Mar 17, 2010
 * Time: 2:36:52 PM
 * To change this template use File | Settings | File Templates.
 */

class PositronicSearch : PositronicFwt {

    Str[] animals := ["bull", "cow", "mouse", "camel", "dog", "cat"]

    // Positronic variable
    Int? position {
        get { return getter(#position) }
        set { setter(#position, val) }
    }

    Str animal := "dog"

    Void search() {
        print("Looking for $animal in $animals")

        print("Found $animal at pos $position")

        Int pos := -1
        animals.each |Str a, Int i| {
            if (a == animal) {
                pos = i
            }
        }
        position = pos
    }

    Void main() {
        run(#search)
    }
}
