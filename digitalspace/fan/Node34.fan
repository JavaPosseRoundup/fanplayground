/**
 * @author freds
 * @date Nov 12, 2010
 */

class Node34 : Node {

  Bool has3() {
    return conn.size == 3
  }

  Bool has4() {
    return conn.size == 4
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
        Node34 bigNode := (Node34)big.otherSideOf(this)
        Node34 smallNode := (Node34)small.otherSideOf(this)
        if (bigNode == smallNode) {
          throw Err("Found big equal to small")
        }
        Connection[] results := [,]
        if (small.canIncrement() && big.canDecrement()) {
          small.increment()
          big.decrement()
        } else if (!small.canIncrement) {
          // A new node is forked

        } else if (!big.canDecrement) {
          // All connections other than signal are too small => This node disappear...
          Node34 signalFrom := signalConn.otherSideOf(this)
          if (has3()) {
            // signalFrom will connect to big and small instead of me if it can suppport one more connection
            if (signalFrom.has3()) {
              Connection[] halfConnectionsFrom := signalFrom.cut(this).half
              Connection newBigConn := halfConnectionsFrom[0] + bigNode.cut(this)
              Connection newSmallConn := halfConnectionsFrom[1] + smallNode.cut(this)
              signalFrom.connect(newBigConn, bigNode)
              signalFrom.connect(newSmallConn, smallNode)
            } else if (signalFrom.has4()) {
              // Cannot had new connection to original signaler just cut the connection and connect big and small directly
              // NOTE: We are loosing all signals on this connection
              ConnValue leftOver := signalFrom.cut(this).val
              Connection newConn := bigNode.cut(this) + smallNode.cut(this) + leftOver
              bigNode.connect(newConn, smallNode)
            } else {
              throw Err("Node $signalFrom has neither 3 or 4 connections")
            }
          } else {
            // Removing a 4 connection nodes (a, b, c, d), means connect a<->c, b<->d
            // We need to pick which node will play the role of c? For the moment we take big
            Connection newBigConn := signalFrom.cut(this) + bigNode.cut(this)
            Node[] left := conn.exclude |co| {
              other := co.otherSideOf(this)
              return other == signalFrom || other == bigNode
            }.map |co -> Node| { co.otherSideOf(this) }
            // After excluding the 2 above this should have only 2 connections left
            if (left.size != 2) throw Err("After filtering big and signal on has4() did not get 2 on $this")
            Connection newLeftConn := left[0].cut(this) + left[1].cut(this)
            signalFrom.connect(newBigConn, bigNode)
            left[0].connect(newLeftConn, left[1])
          }
        } else {
          throw Err("Don't know how to code boolean logic!!??")
        }
        return results
      default:
        throw Err("How to manage 2 calls!!")
    }
  }
}

const class Node34Factory : SpaceFactory {
  override Node createNode() {
    return Node34()
  }

  override Node forkNode(Node[] nodes, ConnValue[] val) {
    return Node34() {
      conn.add(createConnection(it, nodes[0], val[0]))
      conn.add(createConnection(it, nodes[1], val[1]))
      conn.add(createConnection(it, nodes[2], val[2]))
      if (nodes.size == 4) {
        conn.add(createConnection(it, nodes[3], val[3]))
      }
    }
  }

  override Connection createConnection(Node n1, Node n2, ConnValue val) {
    return IntegerConnection(n1,n2,val)
  }
}