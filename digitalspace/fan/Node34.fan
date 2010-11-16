/**
 * @author freds
 * @date Nov 12, 2010
 */

class Node34 : Node {
  static const Bool signalOnDecrement := true

  Bool has3() {
    return conn.size == 3
  }

  Bool has4() {
    return conn.size == 4
  }

  override Bool canConnect(Node endNode, Node? notCounting := null) {
    // notCounting not null means that this node does not count
    if (notCounting == null) {
      return conn.size < 4 && endNode.conn.size < 4 && super.canConnect(endNode, notCounting)
    } else {
      mySize := conn.size
      endSize := endNode.conn.size
      if (isConnected(notCounting)) mySize--
      if (endNode.isConnected(notCounting)) endSize--
      return conn.size < 4 && endNode.conn.size < 4 && super.canConnect(endNode, notCounting)
    }
  }

  Connection connectAndSignal(Node n, Connection conn, Node endNode) {
    co := n.connect(conn,endNode)
    co.addSignal(n)
    return co
  }

  override Connection[] signal(Connection[] from) {
    switch (from.size) {
      case 0:
        return [,]
      case 1:
        if (!has3() && !has4()) throw Err("Node34 has neither 3 or 4 connections??!!")
        Connection signalConn := from[0]
        Connection? small
        Connection? big
        conn.each |co| {
          if (co != signalConn) {
            if (small == null) {
              small = co
            } else if (co < small) {
              small = co
            }
            if (big == null) {
              big = co
            } else if (co >= big) {
              // Using greater or equal to enforce big != small
              big = co
            }
          }
        }
        if (big.otherSideOf(this) == small.otherSideOf(this)) {
          throw Err("Found big equal to small")
        }
        Connection[] results := [,]
        if (small.canIncrement() && big.canDecrement()) {
          // Standard movement of connections values
          return standardMove(small,big)
        } else if (!small.canIncrement) {
          // All connections other than signal are too big
          return allBig(signalConn)
        } else if (!big.canDecrement) {
          // All connections other than signal are too small
          return allSmall(signalConn)
        } else {
          throw Err("Don't know how to code boolean logic!!??")
        }
      default:
        throw Err("How to manage 2 calls!!")
    }
  }

  private Connection[] standardMove(Connection small, Connection big) {
    small.increment()
    big.decrement()
    toSignal := (signalOnDecrement ? big : small)
    toSignal.addSignal(this)
    return [toSignal,]
  }

  private Connection[] allBig(Connection signal) {
    // A new node is forked
    return [,]
  }

  private Connection[] allSmall(Connection signal) {
    // 2 cases:
    // 1) All connections are redistributed to adjancent connections
    // 2) All connections (except signaled) are increment and signaled
    Node[] adj := adjNodes
    // Create all possible connections between adj nodes
    Connection[] possible := [,]
    adj.each |na| { adj.each |nb| { if (na.canConnect(nb,this)) possible.add(Space.connFactory.createConnection(na,nb)) } }
    possible = possible.unique
    if (possible.size < 2) {
      // This node cannot create enough new connections with adjacent
      return conn.findAll |co| {
        if (co != signal) {
          co++
          co.addSignal(this)
          return true
        }
        return false
      }
    }
    // Kill the node and distribute the connections to possible adjacent
    // Cut the node and distribute the tot value
    IntegerConnectionValue tot := adj.reduce(IntegerConnectionValue()) |v,n->IntegerConnectionValue| { n.cut(this).val + v }
    ConnValue v := tot / possible.size
    return possible.map |co| {
      co.na.connect(co + v,co.nb).addSignal(co.na)
    }
  }
}

class Node34Factory : NodeFactory {
  Node[] nodes := [,]

  override Node[] all() { return nodes }

  override Void killNode(Node n) {
    // TODO: Verify all connection are dead
    nodes.remove(n)
  }

  override Node createNode() {
    res := Node34()
    nodes.add(res)
    return res
  }

  override Node forkNode(Node[] nodes, ConnValue[] val) {
    res := Node34() {
      conn.add(Space.connFactory.createConnection(it, nodes[0], val[0]))
      conn.add(Space.connFactory.createConnection(it, nodes[1], val[1]))
      conn.add(Space.connFactory.createConnection(it, nodes[2], val[2]))
      if (nodes.size == 4) {
        conn.add(Space.connFactory.createConnection(it, nodes[3], val[3]))
      }
    }
    nodes.add(res)
    return res
  }
}