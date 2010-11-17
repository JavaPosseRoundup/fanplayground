/**
 * @author freds
 * @date Oct 5, 2009
 */

class Space {
  const static Log log := Log.get("Space")

  const static ConnectionFactory connFactory := IntegerConnectionFactory()
  NodeFactory nodeFactory := NodeMinMaxFactory()

  Connection[] signalingConnections := [,]
  Int step := 0

  Void init(Int size := NodeRules.MIN+1, Int nbSignals := 2) {
    log.info("Initializing space with $size nodes and $nbSignals signals")
    if (size < NodeRules.MIN+1) throw Err("Cannot create space with less than ${NodeRules.MIN+1} nodes")
    Node[] nodes := [,]
    (0..(size-1)).each { nodes.add(nodeFactory.createNode()) }
    i := 0
    nodes.each |na| {
      // Randomization done only at the beginning
      while (!na.isValid && i < NodeRules.MIN*2) {
        i++
        nb := nodes.random
        if (!nb.isValid && na.canConnect(nb)) na.connect(nb)
      }
      if (!na.isValid) {
        // Sweep systematically
        Bool? valid := nodes.eachrWhile |Node nb->Bool?| {
          if (!nb.isValid && na.canConnect(nb)) na.connect(nb)
          if (na.isValid) return true
          return null
        }
        if (valid == null && !na.isValid) {
          // Need to allow more than min number of connections (local loops or wrong numbering)
          j := 0
          while (!na.isValid && j < NodeRules.MIN*2) {
            j++
            nb := nodes.random
            if (na.canConnect(nb)) na.connect(nb)
          }
          if (!na.isValid) throw Err("Universe $debugStr cannot provide connections to $na")
        }
      }
    }
    (0..(nbSignals-1)).each |idx| {
      n0 := nodes.random
      c0 := n0.conn.random
      if (c0.hasSignal) c0 = n0.conn.random
      if (c0.hasSignal) c0 = n0.conn.random
      c0.addSignal(n0)
      signalingConnections.add(c0)
    }
    checkSignalingConnections
    log.debug("Space initialized and has ${nodeFactory.allNodes.size} nodes and ${signalingConnections.size} signaling connections")
  }

  ConnValue state() {
    st := connFactory.minVal
    nodeFactory.allNodes.each |n| {
      n.conn.each |co| {
        st = st + co.val
      }
    }
    st = st / 2
    return st
  }

  Bool isValid() {
    return nodeFactory.allNodes.all |Node n->Bool| { n.isValid } && !signalingConnections.isEmpty
  }

  Connection[] filterValidSignalConn(Connection[] sc) {
    return sc.unique.findAll |co| { co.hasSignal && !co.hasDeadNodes }
  }

  Void checkSignalingConnections() {
    // get only unique and remove connections with no signals or dead nodes
    log.debug("Signaling connections size is ${signalingConnections.size} before cleanup")
    signalingConnections = filterValidSignalConn(signalingConnections)
    log.debug("Signaling connections size is ${signalingConnections.size} after cleanup")
    if (!isValid) throw Err("Initial Universe $debugStr is invalid!")
  }

  Void timePass() {
    log.debug("Time pass activated for step $step")
    // Activate time pass on all signaling connections and collect activated nodes
    Int:Connection[] signaled := [:]
    signalingConnections.each |co| {
      co.timePass.each |n| {signaled.getOrAdd(n.hash, |k->Connection[]| {[,]}).add(co)}
    }
    if (log.isDebug) {
      debugActif := signaled.join("\n") |conns->Str| { conns.join("") |co->Str| { co.toStr } }
      log.debug("Step $step going to activate ${signaled.size} nodes:\n$debugActif")
    }
    // Activate signal on all activated node and collect new signaled connections
    Connection[] newSignalConn := [,]
    signaled.each |conns,nId| {
      Node n := (conns[0].na.hash == nId) ? conns[0].na : conns[0].nb
      newSc := n.signal(conns, nodeFactory)
      log.debug("Node $n created ${newSc.size} new signals")
      newSignalConn.addAll(newSc)
    }
    log.debug("Step $step received ${newSignalConn.size} new signaling connections")
    // After node activation a lot of old connections are dead. Cleaning them up before adding the new ones
    signalingConnections = filterValidSignalConn(signalingConnections)
    signalingConnections.addAll(newSignalConn)
    checkSignalingConnections
    step++
    if (!isValid) throw Err("Universe $debugStr colapsed")
    log.info(infoStr)
  }

  Str infoStr() {
    return "$step: n=${nodeFactory.allNodes.size}, st=$state, s=${signalingConnections.size}"
  }

  Str debugStr() {
      nodes := nodeFactory.allNodes
      scs := signalingConnections
      i := 0
      nodesStr := nodes.join("\n----------------") |n->Str| {"${i++}:\n${n.fullStr}"}
      i = 0
      signalsStr := scs.join("") |sc| { sc.signals.join("\n") |si| { "signal ${i++} = $si" } }
      return "##################################################################
              Space step $step has ${nodes.size} nodes and ${scs.size} signals
              -----------  NODES --------------------------
              $nodesStr
              -----------  SIGNALS ------------------------
              $signalsStr
              ##################################################################"
  }
}