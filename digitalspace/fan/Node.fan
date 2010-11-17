/**
 * @author freds
 * @date Oct 5, 2009
 */

abstract class Node {
  Connection[] conn := [,]

  ** Activate the node from a list of connection that sent the signal
  ** and returns the list of connections (may be from forked nodes)
  ** that have a new signal
  abstract Connection[] signal(Connection[] from, NodeFactory nodeFactory)

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

  abstract Bool isValid()
  Node[] adjNodes() { conn.map { it.otherSideOf(this) } }
  Bool isConnected(Node endNode) { (this != endNode) && conn.any { it.na == endNode || it.nb == endNode } }

  **
  ** Cannot connect to myself or have double connections
  ** Connection to notCounting node should be ignore in the test
  ** and connection to consider should be included in the test
  **
  virtual Bool canConnect(Node endNode, Node? notCounting := null, Connection[] considering := [,]) {
    return (this != endNode) && !isConnected(endNode) && !endNode.isConnected(this) &&
     considering.all |co| { !co.isConnecting(this,endNode) }
  }

  Connection connect(Node endNode, Connection? newConn := null) {
    if (!canConnect(endNode)) throw Err("Node $this already connected to $endNode")
    Connection? finalConn
    if (newConn == null) {
      finalConn = Space.connFactory.createConnection(this, endNode)
    } else {
      os := newConn.findOtherSideOf(endNode)
      if (!newConn.hasDeadNodes && os == null) throw Err("Cannot use non dead node connection ${newConn} or connection without the endNode ${os}")
      // If connection valid (not dead and good nodes) use it as is
      if (!newConn.hasDeadNodes && os == this) {
        finalConn = newConn
      } else {
        finalConn = Space.connFactory.createConnection(this, endNode, newConn.val)
        newConn.signals.each |s| {
          if (s.from == endNode)
            finalConn.addSignal(s.from, s.length)
          else
            finalConn.addSignal(this, s.length)
        }
      }
    }
    conn.add(finalConn)
    endNode.conn.add(finalConn)
    return finalConn
  }

  override Str toStr() {
    connStr := conn.join(",") |co| { co.hash.toStr }
    return "<Node $hash connections: $connStr >"
  }

  Str fullStr() {
    connStr := conn.join(",\n") |co| { co.toStr }
    return "<Node $hash valid=$isValid connections:\n$connStr >"
  }
}


