/**
 * @author freds
 * @date Oct 5, 2009
 */

abstract class Node {
  Connection[] conn := [,]

  ** Activate the node from a list of connection that sent the signal
  ** and returns the list of connections (may be from forked nodes)
  ** that have a new signal
  abstract Connection[] signal(Connection[] from)

  ** Cut a dead node (passed as param) from the connections of this node
  ** return the disconnected connection with the node passed marked dead
  Connection cut(Node n) {
    Connection[] found := conn.findAll |co->Bool| { co.otherSideOf(this) == n }
    if (found.isEmpty) throw Err("Could not find node $n connection to $this")
    if (found.size > 1) throw Err("Node $n has double connection to $this")
    toCut := found[0]
    conn.remove(toCut)
    toCut.markDead(n)
    return toCut
  }

}

mixin ConnValue {
  abstract Bool canIncrement()
  @Operator abstract ConnValue increment()
  abstract Bool canDecrement()
  @Operator abstract ConnValue decrement()
  @Operator abstract ConnValue plus(ConnValue o)
  @Operator abstract ConnValue minus(ConnValue o)
  abstract ConnValue[] half()
  abstract Int signalLength()
}

class Signal {
  Node from
  Int val

  new make(Node fromNode, Int d) {
    from = fromNode
    val = d
  }

  Bool timePass() {
    if (val <= 0) throw Err("Signal from $from is done")
    val--
    return val == 0
  }

  Void add(Int d) {
    if (val <= 0) throw Err("Signal from $from is done")
    val += d
    if (val <= 0) throw Err("Signal from $from was deleted by length reduction")
  }
}

abstract class Connection {
  const Signal[] signals := [,]
  const Node[] nodes
  ** 1 is na dead, 2 is nb dead, 3 is both dead
  Int dead := 0

  new make(Node node1, Node node2) {
    nodes = [node1,node2]
  }

  Node na() { return nodes[0] }
  Node nb() { return nodes[1] }

  Bool identical(Connection o) {
    return (na == o.na && nb == o.nb) || (na == o.nb && nb == o.na)
  }

  Node[] timePass() {
    Signal[] done := [,]
    signals.each |s| {
      if (s.timePass) done.add(s)
    }
    if (done.isEmpty) return [,]
    Node[] result := [,]
    done.each |s| {
      signals.remove(s)
      result.add(otherSideOf(s.from))
    }
    return result
  }

  Bool hasSignal() { return !signals.isEmpty }

  Node otherSideOf(Node n) {
    if (na == n) return nb
    if (nb == n) return na
    throw Err("Node $n is not part of connection $this")
  }

  Node? findOtherSideOf(Node n) {
    if (na == n) return nb
    if (nb == n) return na
    return null
  }

  Void addSignal(Node from) {
    signals.add(Signal(from,val().signalLength))
  }

  Void markDead(Node cut) {
    if (na == cut) dead = dead.or(1)
    if (nb == cut) dead = dead.or(2)
    if (dead == 0) throw Err("Node $cut is not connected to $this")
  }

  Bool hasDeadNodes() {
    return dead != 0
  }

  Bool allDead() {
    return dead == 3
  }

  Node[] deadNodes() {
    Node[] res := [,]
    switch (dead) {
      case 1:
        res.add(na)
      case 2:
        res.add(nb)
      case 3:
        res.add(na)
        res.add(nb)
    }
    return res
  }

  abstract ConnValue val()
  abstract Void setVal(ConnValue connVal)

  Bool canIncrement() { return val.canIncrement }
  @Operator Connection increment() { val.increment }
  Bool canDecrement() { return val.canDecrement }
  @Operator Connection decrement() { val.decrement }

  override Int compare(Obj o) {
    if (o isnot Connection) throw Err("Cannot compare an Connection to ${o.typeof()}")
    return this.val <=> ((Connection)o).val
  }

  @Operator Connection plusConnVal(ConnValue connVal) {
    setVal(val() + connVal)
    toAdd := connVal.signalLength
    if (toAdd != 0) signals.each |s| {
      s.add(toAdd)
    }
    return this
  }

  @Operator Connection plusConnection(Connection o) {
    if (identical(o)) {
      // Same connection nodes, just add the connection value and signals
      newConn := Space.factory.createConnection(na, nb, val() + o.val())
      signals.each |s| {
        newConn.addSignal(s.from)
      }
      o.signals.each |s| {
        newConn.addSignal(s.from)
      }
      return newConn
    }
    // Each connection should have at least one dead node
    if (!hasDeadNodes() || !o.hasDeadNodes()) {
      throw Err("Adding non identical connections with no dead nodes is forbidden: $this plus $o")
    }
    commonDeadNodes := deadNodes().intersection(o.deadNodes())
    if (commonDeadNodes.isEmpty) {
      throw Err("No common dead nodes between $this and $o")
    }
    // Common dead nodes cannot be more than it means connection are identical
    removedNode := commonDeadNodes[0]
    newConn := Space.factory.createConnection(otherSideOf(removedNode), o.otherSideOf(removedNode), val() + o.val())
    // Keep the extra dead nodes if necessary
    if (allDead) newConn.markDead(newConn.na)
    if (o.allDead) newConn.markDead(newConn.nb)
    signals.each |s| {
      if (s.from == removedNode)
        newConn.addSignal(newConn.nb)
      else
        newConn.addSignal(s.from)
    }
    o.signals.each |s| {
      if (s.from == removedNode)
        newConn.addSignal(newConn.na)
      else
        newConn.addSignal(s.from)
    }
    return newConn
  }

  Connection[] half() {
    newVal := val.half
    Connection[] newConn := [
      Space.factory.createConnection(na, nb, newVal[0]),
      Space.factory.createConnection(na, nb, newVal[1])
    ]
    // We multiply the signals?
    newConn.each |nc| {
      nc.dead = dead
      signals.each |s| {
        nc.addSignal(s.from)
      }
    }
    return newConn
  }
}


