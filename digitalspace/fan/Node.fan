/**
 * @author freds
 * @date Oct 5, 2009
 */

class Node {
	static Int counter := 0
	const Int id
	Connection? a
	Connection? b
	Connection? c
	NodeState? s

	new make() {
		id := counter++
	}

	Void move() {

		switch (s) {
			case NodeState.AB:
			 a = a--
			 b = b++
			 c = c.same()
			case NodeState.AC:
			 a = a--
			 b = b.same()
			 c = c++
			case NodeState.BC:
			 a = Connection.next(a, |Int d -> Int| {return d} )
			 b = Connection.next(b, &Int.decrement )
			 c = Connection.next(c, &Int.increment )
			case NodeState.BA:
			 a = Connection.next(a, &Int.increment )
			 b = Connection.next(b, &Int.decrement )
			 c = Connection.next(c, |Int d -> Int| {return d} )
			case NodeState.CA:
			 a = Connection.next(a, &Int.increment )
			 b = Connection.next(b, |Int d -> Int| {return d} )
			 c = Connection.next(c, &Int.decrement )
			case NodeState.CB:
			 a = Connection.next(a, |Int d -> Int| {return d} )
			 b = Connection.next(b, &Int.increment )
			 c = Connection.next(c, &Int.decrement )
		}
	}
}

const class Connection {
	const Int step
	const Int d
	const Node n1
	const Node n2

	new make(Node node1, Node node2, Int distance, Int initStep := 0) {
		step := initStep
		d := distance
		n1 := node1
		n2 := node2
	}

	Connection same() {
		return Connection(n1, n2, d, step++)
	}

	Connection increment() {
		return Connection(n1, n2, d++, step++)
	}

	Connection decrement() {
		return Connection(n1, n2, d--, step++)
	}
}

enum NodeState {
	AB, AC, BC, BA, CA, CB;
}