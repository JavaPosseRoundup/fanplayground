/**
 * Created by IntelliJ IDEA.
 * User: freds
 * Date: Mar 17, 2010
 * Time: 7:37:59 PM
 * To change this template use File | Settings | File Templates.
 */
class Universe {
}

abstract class PositronicFwt {
    Int currentHistory := 0
    Int nbRun := 0
    Field:QuantumState variables := [:]

    private Void bigBang() {
		currentHistory = 0
		nbRun = 0
		variables = [:]
    }

    Void run(Method flow) {
    	bigBang
        intRun(flow)
        while (nbRun < 20 && !done()) {
            intRun(flow)
        }
        if (nbRun >= 20) {
            echo("Your Universe is unstable!")
        } else if (!variables.isEmpty) {
            intRun(flow)
        }
    }

    private Void intRun(Method flow) {
        currentHistory = 0
        flow.callOn(this, null)
        nbRun++
    }

    Bool done() {
        Bool res := true
        variables.each |QuantumState qs| {
            if (!qs.done()) res = false
        }
        return res
    }

    Void print(Str msg) {
        if (nbRun != 0 && done()) {
            echo(msg)
        }
    }

    Obj? getter(Field f) {
        qs := getState(f)
        Obj? res := qs.values[currentHistory]
        if (res == null && currentHistory > 0) {
            return qs.values[currentHistory-1]
        }
        return res
    }

    Void setter(Field f, Obj? value) {
        getState(f).values[currentHistory] = value
        currentHistory++
    }

    QuantumState getState(Field f) {
        if (!variables.containsKey(f)) {
            qs := QuantumState()
            variables[f] = qs
            return qs
        }
        return variables[f]
    }
}

class QuantumState {
    [Int:Obj?] values := [:]

    Bool done() {
        Bool res := true
        values.each |Obj? val| {
            if (val == null) res = false
        }
        return res
    }
}