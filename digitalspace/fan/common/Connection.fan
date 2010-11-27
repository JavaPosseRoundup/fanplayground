/**
 * @author freds
 * @date Nov 16, 2010
 */

abstract class Connection {
  static Rules rules() { return RuleHolder.rules }

  Node[] nodes
  Signal[] signals := [,]
  ** 1 is na dead, 2 is nb dead, 3 is both dead
  Int dead := 0

  new make(Node node1, Node node2) {
    nodes = [node1,node2].ro
  }

  Node na() { return nodes[0] }
  Node nb() { return nodes[1] }

  override Str toStr() {
    return "<Connection $hash:$val na=${na.hash} nb=${nb.hash} dead=$dead signals=$signals>"
  }

  override Bool equals(Obj? o) {
    if (o isnot Connection) return false
    return identical(o)
  }

  override Int hash() {
    naH := na.hash
    nbH := nb.hash
    // Make sure to always use the smallest first (need same hash whatever na or nb swap)
    if (naH < nbH) return 31 * naH + nbH
    return 31 * nbH + naH
  }

  Bool identical(Connection o) {
    return isConnecting(o.na,o.nb)
  }

  Bool isConnecting(Node oa, Node ob) {
    return (na == oa && nb == ob) || (na == ob && nb == oa)
  }

  Node[] timePass(Signal[] alreadyDone := [,]) {
    Signal[] done := [,]
    Signal[] activated := [,]
    signals.each |s| {
      if (alreadyDone.contains(s)) {
        done.add(s)
      } else {
        if (s.timePass) activated.add(s)
      }
    }
    done.each |s| {
      signals.remove(s)
    }
    if (activated.isEmpty) return [,]
    Node[] result := [,]
    activated.each |s| {
      signals.remove(s)
      result.add(otherSideOf(s.from))
      alreadyDone.add(s)
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

  Connection addSignal(Node from, SigValue? sigVal := null) {
    if (sigVal == null) sigVal = rules.valToSigVal(val)
    if (signals.any |si| { si.from == from && si.val == sigVal }) {
      // Already there, just don't add
    } else {
      signals.add(Signal(from,sigVal))
    }
    return this
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

  Bool isDead(Node n) {
    switch (dead) {
      case 0:
        return false
      case 1:
        return n==na
      case 2:
        return nb==n
      case 3:
        return na==n || nb==n
    }
    return false
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
  @Operator Connection increment() { val.increment; return this }
  Bool canDecrement() { return val.canDecrement }
  @Operator Connection decrement() { val.decrement; return this }

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
      newConn := rules.createConnection(na, nb, val + o.val)
      signals.each |s| {
        newConn.addSignal(s.from, s.length + o.val.signalLength)
      }
      o.signals.each |s| {
        newConn.addSignal(s.from, s.length + val.signalLength)
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
    newConn := rules.createConnection(otherSideOf(removedNode), o.otherSideOf(removedNode), val + o.val)
    // Keep the extra dead nodes if necessary
    if (allDead) newConn.markDead(newConn.na)
    if (o.allDead) newConn.markDead(newConn.nb)
    // TODO: Create a method to manage copy of signals
    signals.each |s| {
      sl := s.length + o.val.signalLength
      if (s.from == removedNode)
        newConn.addSignal(newConn.nb, sl)
      else
        newConn.addSignal(s.from, sl)
    }
    o.signals.each |s| {
      sl := s.length + val.signalLength
      if (s.from == removedNode)
        newConn.addSignal(newConn.na, sl)
      else
        newConn.addSignal(s.from, sl)
    }
    return newConn
  }

  Connection swap(Node oldNode, Node newNode) {
    if (!nodes.contains(oldNode)) throw Err("Cannot swap old=$oldNode with new=$newNode on $this since old is not part of this")
    newConn := rules.createConnection(newNode, otherSideOf(oldNode), val)
    newConn.dead = dead
    signals.each |si| {
      if (si.from == oldNode)
        newConn.addSignal(newNode, si.length)
      else
        newConn.signals.add(si)
    }
    return newConn
  }

  Connection[] half() {
    newVal := val.half
    // Copy the dead field to the 2 connections
    Connection[] newConn := [
      rules.createConnection(na, nb, newVal[0]) { it.dead = this.dead },
      rules.createConnection(na, nb, newVal[1]) { it.dead = this.dead }
    ]
    // TODO: We multiply or split the signals? => I split
    signals.each |s| {
      d := s.length
      c := newConn.random
      if (d > c.val.signalLength) { d = d - c.val.signalLength }
      c.addSignal(s.from,d)
    }
    return newConn
  }
}

