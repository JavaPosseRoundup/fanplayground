/**
 * @author freds
 * @date Oct 5, 2009
 */

class Space {
  const static Log log := Log.get("Space")

  static Rules rules() { return RuleHolder.rules }
  NodeFactory nodeFactory := NodeMinMaxFactory()

  Connection[] signalingConnections := [,]
  Int step := 0
  Int sameStateFor := 0
  Int nbSignals := signalingConnections.size
  ConnValue currentState := rules.minVal

  Void init(Int size := rules.minConn+1, Int nbSignals := 2, ConnValue? defVal := null) {
    log.info("Initializing space with $size nodes and $nbSignals signals")
    if (size < NodeRules.MIN+1) throw Err("Cannot create space with less than ${NodeRules.MIN+1} nodes")
    Node[] nodes := [,]
    (0..(size-1)).each { nodes.add(nodeFactory.createNode()) }
    nodeFactory.connectNodes(nodes, defVal)
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
    st := rules.minVal
    nodeFactory.allNodes.each |n| {
      n.conn.each |co| {
        st = st + co.val
      }
    }
    st = (st-rules.minVal) / 2
    return st
  }

  Bool isValid() {
    return nodeFactory.allNodes.all |Node n->Bool| { n.isValid } && !signalingConnections.isEmpty
  }

  Connection[] filterValidSignalConn(Connection[] sc) {
    // get only unique and remove connections with no signals or dead nodes
    return sc.unique.findAll |co| { co.hasSignal && !co.hasDeadNodes }
  }

  Void checkSignalingConnections() {
    signalingConnections = filterValidSignalConn(signalingConnections)
    if (!isValid) {
      throw Err("Initial Universe $debugStr is invalid!")
    }
    newState := state
    if (newState == currentState && nbSignals == signalingConnections.size)
      sameStateFor++
    else
      sameStateFor = 0
    nbSignals = signalingConnections.size
    currentState = newState
  }

  Void timePass() {
    log.debug("Time pass activated for step $step")
    // Activate time pass on all signaling connections and collect activated nodes
    Int:Connection[] signaled := [:]
    Signal[] doned := [,]
    signalingConnections.each |co| {
      co.timePass(doned).each |n| {signaled.getOrAdd(n.hash, |k->Connection[]| {[,]}).add(co)}
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
    if (log.isInfo) log.info(infoStr)
  }

  Str infoStr() {
    return "$step: n=${nodeFactory.allNodes.size}, st=$currentState, s=${signalingConnections.size}, sameFor=$sameStateFor"
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