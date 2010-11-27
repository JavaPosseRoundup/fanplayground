/**
 * @author freds
 * @date Nov 12, 2010
 */

class NodeMinMax : Node {
  const static Log log := Log.get("NodeMinMax")

  override Bool isValid() {
    return conn.size >= rules.minConn && conn.size <= rules.maxConn && conn.all |co| { !co.hasDeadNodes }
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
    return mySize < rules.maxConn && endSize < rules.maxConn && super.canConnect(endNode, notCounting, considering)
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

  private Connection[] standardMove(Connection small, Connection big, Bool signalOnBig := true) {
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
    // I need to be valid to explode :)
    if (!isValid()) throw Err("Node ${fullStr} is invalid and so cannot explode!")
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
    nodeFactory.connectNodes(newNodes, rules.minVal).eachWhile |newConn->Bool?| {
      if (nbSignals > 0) {
        signaled.add(newConn.addSignal(newConn.na))
        nbSignals--
      }
      if (nbSignals == 0) return true
      return null
    }
    return signaled
  }

  private Connection[] allSmall(NodeFactory nodeFactory, Connection[] nonSignalConns) {
    return explodeMe(nodeFactory, conn.size)
  }

  private Connection[] allBig(NodeFactory nodeFactory, Connection[] nonSignalConns) {
    // The node disapear, the adjacent nodes are reput in stable state (with node creation if necessary)
    // Then all the existing connections and signals of this node are redistributed to the adjacents connections

    // Kill the node and distribute the connections to possible adjacent
    // Cut the node and distribute the tot value
    log.info("Node $hash disapear and adj connections created and signaled")
    ConnValue initVal := rules.minVal
    ConnValue tot := rules.minVal
    Int leftSignals := conn.size - nonSignalConns.size
    adj := adjNodes
    adj.each |n| {
      dc := n.cut(this)
      tot += dc.val
      leftSignals += dc.signals.size
    }
    nodeFactory.killNode(this)
    newConns := nodeFactory.connectNodes(adj,rules.minVal)
    // Distribute tot to all possible => first remove the val of new connections
    tot = tot - (initVal * (newConns.size+1))
    adj.each |na| { adj.each |nb| {
        co := na.findConnection(nb)
        if (co != null) newConns.add(co)
    } }
    newConns = newConns.unique
    Connection[] results := [,]
    if (newConns.size == 0) {
      log.warn("Node $this loose it all!")
    } else {
      ConnValue? leftOvers := tot
      i := 0
      while (leftOvers != null && i < newConns.size) {
        i++
        newLeftOvers := distribute(newConns,leftOvers)
        if (newLeftOvers != null && leftOvers == newLeftOvers) {
          log.info("Distribution lost $leftOvers values")
          break;
        }
        leftOvers = newLeftOvers
      }
      newConns.each |co| {
        if (leftSignals > 0) {
          results.add(co.addSignal(co.na))
          leftSignals--
        }
      }
      if (leftOvers != null || leftSignals != 0) {
        log.info("Node $this lost $leftSignals signals and $leftOvers conn val")
      }
     }
    return results
  }

  ** Distributing tot to all connections
  ConnValue? distribute(Connection[] conns, ConnValue tot) {
    maxVal := Space.connFactory.maxVal
    minVal := Space.connFactory.minVal
    // the flat v to distribute
    ConnValue v := tot / conns.size
    if ((v + minVal) > maxVal) {
      log.info("Cannot distribute more than max-min per connections => Means loosing val")
      v = maxVal - minVal
    }
    conns.each |co| {
      if (!tot.isZero) {
        newVal := co.val + v
        if (!newVal.valid) {
          newVal = maxVal
        }
        tot -= newVal - co.val
        co.setVal(newVal)
      }
    }
    if (tot.isZero) return null
    return tot
  }
}

class NodeMinMaxFactory : NodeFactory {
  static Rules rules() { return RuleHolder.rules }

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

  private Connection createConn(Node na, Node nb, ConnValue? defVal) {
    if (defVal == null) {
      // Using random
      defVal = rules.randomVal
    }
    return na.connect(nb,rules.createConnection(na, nb, defVal))
  }

  override Connection[] connectNodes(Node[] nodes, ConnValue? defVal := null) {
    Connection[] results := [,]
    i := 0
    nodes.each |na| {
      // Use randomization only at the beginning for big nodes collection
      if (nodes.size > rules.minConn*2) {
        while (!na.isValid && i < rules.minConn*2) {
          i++
          nb := nodes.random
          if (!nb.isValid && na.canConnect(nb)) results.add(createConn(na,nb,defVal))
        }
        // If randomization worked continue to use it
        if (na.isValid) i = 0
      }
      if (!na.isValid) {
        // Sweep systematically finding other invalid nodes
        Bool? valid := nodes.eachrWhile |Node nb->Bool?| {
          if (!nb.isValid && na.canConnect(nb)) results.add(createConn(na,nb,defVal))
          if (na.isValid) return true
          return null
        }
        if (valid == null) {
          // Need to allow more than min number of connections (local loops or wrong numbering)
          // Use randomization for big nodes collection
          if (nodes.size > rules.minConn*2) {
            j := 0
            while (!na.isValid && j < rules.minConn*2) {
              j++
              nb := nodes.random
              if (na.canConnect(nb)) results.add(createConn(na,nb,defVal))
            }
          }
          if (!na.isValid) {
            // Sweep systematically and ignore nb validity
            valid = nodes.eachrWhile |Node nb->Bool?| {
              if (na.canConnect(nb)) results.add(createConn(na,nb,defVal))
              if (na.isValid) return true
              return null
            }
          }
          if (!na.isValid) throw Err("Cannot provide connections to ${na.fullStr} from collection $nodes")
        }
      }
    }
    return results
  }
}