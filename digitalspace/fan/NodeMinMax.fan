/**
 * @author freds
 * @date Nov 12, 2010
 */

const class ConnRules {
  static const Int MIN := 2
  static const Int MAX := 8
}

const class NodeRules {
  static const Int MIN := 3
  static const Int MAX := 6
  static const Bool signalOnDecrement := true
}

class NodeMinMax : Node {
  const static Log log := Log.get("NodeMinMax")

  override Bool isValid() {
    return conn.size >= NodeRules.MIN && conn.size <= NodeRules.MAX && conn.all |co| { !co.hasDeadNodes }
  }

  override Bool canConnect(Node endNode, Node? notCounting := null, Connection[] considering := [,]) {
    mySize := conn.size
    endSize := endNode.conn.size
    // notCounting not null means that this node does not count
    if (notCounting != null) {
      if (isConnected(notCounting)) mySize--
      if (endNode.isConnected(notCounting)) endSize--
    }
    if (!considering.isEmpty) {
      considering.each |co| {
        myO := co.findOtherSideOf(this)
        endO := co.findOtherSideOf(endNode)
        if (myO != null && myO != notCounting) mySize++
        if (endO != null && endO != notCounting) endSize++
      }
    }
    return mySize < NodeRules.MAX && endSize < NodeRules.MAX && super.canConnect(endNode, notCounting, considering)
  }

  Connection connectAndSignal(Node n, Connection conn, Node endNode) {
    co := n.connect(endNode,conn)
    co.addSignal(n)
    return co
  }

  override Connection[] signal(Connection[] from, NodeFactory nodeFactory) {
    if (!isValid()) throw Err("Node ${fullStr} is invalid")
    // No actual signal
    if (from.isEmpty) return [,]

    Connection[] nonSignalConns := conn.exclude { from.contains(it) }
    // How many other side connection will be influenced by the signals
    switch (nonSignalConns.size) {
      case 0:
        // WOW! This node received a signal from all its connections simultaneously
        log.info("Node $hash received signal from all connections => explode")
        return explodeMe(nodeFactory, from.size)
      case 1:
        // Only one connection receives all the energy of the signals
        // Decrement or increment for each signal until feasible
        log.info("Node $hash received signal except one connection => transform signal to val")
        co := nonSignalConns[0]
        dec := co.canDecrement
        from.eachWhile |f->Bool?| {
          if (dec) {
            if (co.canDecrement)
              co--
            else
              return true
          } else {
            if (co.canIncrement)
              co++
            else
              return false
          }
          return null
        }
        co.addSignal(this)
        return nonSignalConns
      default:
        // At least 2 non signal connections, can play big->small game
        log.info("Node $hash received signal => Play small big game")
        Connection[] newSignals := [,]
        playGround := nonSignalConns.dup
        Bool? res := from.eachWhile |f->Bool?| {
          if (playGround.size < 2) return false
          Connection[] smallBig := findSmallAndBig(playGround)
          small := smallBig[0]
          big := smallBig[1]
          if (small.otherSideOf(this) == big.otherSideOf(this)) {
            throw Err("Found big equal to small")
          }
          if (small.canIncrement() && big.canDecrement()) {
            // Standard movement of connections values
            newSignals.addAll(standardMove(small,big))
            playGround.remove(newSignals.last)
          } else if (!small.canIncrement) {
            log.info("All connections left to play for $hash are too big => explode")
            newSignals.addAll(allBig(nodeFactory, nonSignalConns))
            // Futher signals are ignored
            return true
          } else if (!big.canDecrement) {
            // All connections other than signal are too small
            log.info("All connections left to play for $hash are too small => node disappear or create value")
            newSignals.addAll(allSmall(nodeFactory, nonSignalConns))
            // Futher signals are ignored
            return true
          } else {
            throw Err("Don't know how to code boolean logic!!??")
          }
          return null
        }
        if (res != null && !res) {
          log.debug("Lost some signal on activation of node $this")
          if (playGround.size != 1) {
            throw Err("Playground cannot be empty after removing 1 from 2?")
          }
          // So now basically playGround is only 1 connection
          signalsToDo := from.size - (nonSignalConns.size - playGround.size)
          if (signalsToDo <= 0) {
            throw Err("The loop of distribution should have returned null?!?")
          }
          left := playGround[0]
          // Pick the pair of left over and do a standard move
          leftVal := left.val
          // Pick a from that has a val different from leftVal
          sf := from.find |f| { f.val != leftVal }
          if (sf == null && !(leftVal.canIncrement && leftVal.canDecrement)) {
            // All signaling and left have same values that cannot inc AND dec
            // Break conservation?
            if (leftVal.canIncrement) {
              newSignals.add(left.increment.addSignal(this))
            } else {
              newSignals.add(left.decrement.addSignal(this))
            }
          } else {
            // Sinc the val can inc AND dec any from will do
            sf = from.random
          }
          if (left.val < sf.val) {
            newSignals.addAll(standardMove(left, sf, false))
          } else {
            newSignals.addAll(standardMove(sf, left, true))
          }
          signalsToDo--
          if (signalsToDo > 0) {
            // Sending back signalsToDo signals to sf and other from
            newSignals.add(sf.addSignal(this))
            signalsToDo--
            i := 0
            while (i < from.size && signalsToDo > 0) {
              if (from[i] != sf) {
                newSignals.add(from[i].addSignal(this))
                signalsToDo--
              }
              i++
            }
            if (signalsToDo > 0)
              log.err("Did not manage to redistribute the signals after possible distribution!")
          }
        }
        return newSignals
    }
  }

  private Connection[] findSmallAndBig(Connection[] conns) {
    Connection? small
    Connection? big
    conns.each |co| {
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
    return [small,big]
  }

  private Connection[] standardMove(Connection small, Connection big, Bool signalOnBig := NodeRules.signalOnDecrement) {
    small.increment()
    big.decrement()
    toSignal := (signalOnBig ? big : small)
    toSignal.addSignal(this)
    return [toSignal,]
  }

  **
  ** Create a new node for each connections and connect them until they reach validity
  ** Then send signals back to all adj nodes if sendSignals is true
  **
  private Connection[] explodeMe(NodeFactory nodeFactory, Int nbSignals) {
    Connection[] signaled := [,]
    Node[] newNodes := adjNodes.map |adj| {
      newNode := nodeFactory.createNode()
      newCo := adj.cut(this).swap(this,newNode)
      finalConn := adj.connect(newNode, newCo)
      if (nbSignals > 0) {
        signaled.add(finalConn.addSignal(newNode))
        nbSignals--
      }
      return newNode
    }
    nodeFactory.killNode(this)
    // Each new nodes has already one connection they need MIN-1 new ones to be valid
    newNodes.each |nn| {
      newNodes.eachrWhile |on| {
        if (!on.isValid() && !nn.isValid() && on.canConnect(nn)) {
          newConn := on.connect(nn)
          if (nbSignals > 0) {
            signaled.add(newConn.addSignal(nn))
            nbSignals--
          }
        }
        if (nn.isValid()) return nn
        return null
      }
    }
    return signaled
  }

  private Connection[] allBig(NodeFactory nodeFactory, Connection[] nonSignalConns) {
    return explodeMe(nodeFactory, conn.size)
  }

  private Connection[] allSmall(NodeFactory nodeFactory, Connection[] nonSignalConns) {
    // 2 cases:
    // 1) All connections are redistributed to adjancent connections
    // 2) All connections (except signaled) are increment and signaled
    Node[] adj := adjNodes
    // Create all possible connections between adj nodes
    Connection[] possible := [,]
    adj.each |na| { adj.each |nb| { if (na.canConnect(nb,this,possible)) possible.add(Space.connFactory.createConnection(na,nb)) } }
    possible = possible.unique
    if (possible.size < 2) {
      // This node cannot create enough new connections with adjacent nodes ???!!!?
      // Break conservation and increment and signals everyone
      log.info("Not enough possible adj connections on $hash to disapear => create val and signals")
      return nonSignalConns.findAll |co| {
        co++
        co.addSignal(this)
        return true
      }
    }
    // Kill the node and distribute the connections to possible adjacent
    // Cut the node and distribute the tot value
    log.info("Node $hash disapear and adj connections created and signaled")
    ConnValue initVal := IntegerConnectionValue()
    ConnValue tot := adj.reduce(initVal) |v,n->ConnValue| { n.cut(this).val + v }
    nodeFactory.killNode(this)
    // Distribute tot to all possible => first remove the val of all possible
    tot = tot - (initVal * possible.size)
    // v to distribute
    ConnValue v := tot / possible.size
    if (!(v + initVal).valid()) {
      throw Err("All connection were small and I cannot distribute the value to adjacent new connections?!?")
    }
    return possible.map |co| {
      co.na.connect(co.nb,co + v).addSignal(co.na)
    }
  }
}

class NodeMinMaxFactory : NodeFactory {
  Node[] nodes := [,]

  override Node[] allNodes() { return nodes }

  override Void killNode(Node n) {
    if (n.conn.any |co->Bool| { !co.isDead(n) }) throw Err("Killing node ${n.fullStr} which is still connected!")
    nodes.remove(n)
  }

  override Node createNode() {
    res := NodeMinMax()
    nodes.add(res)
    return res
  }

  override Node forkNode(Node[] nodes, ConnValue[] val) {
    res := NodeMinMax() {
      me := it
      nodes.each |no,idx| {
        me.conn.add(Space.connFactory.createConnection(me, no, val[idx]))
      }
    }
    nodes.add(res)
    return res
  }
}