
class SpaceTest : Test {
  const static Log log := Log.get("SpaceTest")

  new make() {
    // Activate or deactivate logging
    log.level = LogLevel.warn
    Space.log.level = LogLevel.warn
    NodeMinMax.log.level = LogLevel.warn
  }

  Void testSpace12_6() {
    log.info("Starting 12-6 SpaceTime")
    s := Space()
    s.init(12,6)
    runMax(s)
  }

  Void testSpace22_15() {
    log.info("Starting 22-15 SpaceTime")
    s := Space()
    s.init(22,15)
    runMax(s)
  }

  Void testSpace200_50() {
    log.info("Starting 200-50 SpaceTime")
    s := Space()
    s.init(200,50)
    runMax(s)
  }

  ** Testing node behavior when too small
  Void testAllMin() {
    log.info("Starting SpaceTime for all small test")
    s := Space()
    s.init(NodeRules.MIN+1,1)
    nodes := s.nodeFactory.allNodes
    verifyEq(nodes.size,NodeRules.MIN+1,"Space Should have ${NodeRules.MIN+1} nodes not ${nodes.size}")
    verifyEq(s.signalingConnections.size,1,"Space should have 1 connection with a signal not ${s.signalingConnections.size}")
    log.debug(s.debugStr)
    sc := s.signalingConnections[0]
    verifyEq(sc.signals.size,1,"Signaling connection $sc should have one signal")
    node0 := sc.signals[0].from
    node1 := sc.otherSideOf(node0)
    verifyEq(node0.conn.size,NodeRules.MIN,"Node 0 ${node0.fullStr} should have ${NodeRules.MIN} connections!")
    ConnValue minVal := IntegerConnectionValue(ConnRules.MIN)
    verify(nodes.all |n| { n.conn.size == NodeRules.MIN && n.conn.all |co| { co.val == minVal } }, "All nodes should have ${NodeRules.MIN} connections of size $minVal")
    // Set signal length to one to activate immediatly
    sc.signals[0].val = 1
    activatedNodes := sc.timePass
    verifyEq(activatedNodes.size,1,"One node should be activated at the end of signal")
    verifyEq(activatedNodes[0],node1,"The second node of the signal should be activated")
    // This activated allSmall with less than 2 possible connections => 2 signals and +1 on connections
    signalConn := node1.signal([sc], s.nodeFactory)
    verifyEq(signalConn.size,2,"2 signals connections should arrive after activation of ${node1.fullStr} not $signalConn")
    minVal++
    verifyEq(signalConn[0].val,minVal,"Signals connection should have size $minVal not ${signalConn[0]}")
    verifyEq(signalConn[1].val,minVal,"Signals connection should have size $minVal not ${signalConn[1]}")
    s.signalingConnections=s.filterValidSignalConn(s.signalingConnections)
    s.signalingConnections.addAll(signalConn)
    s.checkSignalingConnections
    verifyEq(nodes.size,NodeRules.MIN+1,"Space should have ${NodeRules.MIN+1} nodes not ${nodes.size}")
    verifyEq(s.signalingConnections.size,2,"Space should have 2 connection with a signal not ${s.signalingConnections.size}")
  }

  ** Testing node behavior when too big
  Void testAllMax() {
    log.info("Starting SpaceTime for all big test")
    s := Space()
    initNbNodes := NodeRules.MIN+1
    s.init(initNbNodes,1)
    nodes := s.nodeFactory.allNodes
    verifyEq(nodes.size,NodeRules.MIN+1,"Space Should have ${NodeRules.MIN+1} nodes not ${nodes.size}")
    verifyEq(s.signalingConnections.size,1,"Space should have 1 connection with a signal not ${s.signalingConnections.size}")
    log.debug(s.debugStr)
    sc := s.signalingConnections[0]
    verifyEq(sc.signals.size,1,"Signaling connection $sc should have one signal")
    node0 := sc.signals[0].from
    node1 := sc.otherSideOf(node0)
    verifyEq(node0.conn.size,NodeRules.MIN,"Node 0 ${node0.fullStr} should have ${NodeRules.MIN} connections!")
    ConnValue maxVal := IntegerConnectionValue(ConnRules.MAX)
    nodes.each |n| { n.conn.each |co| { co.setVal(maxVal) } }
    verify(nodes.all |n| { n.conn.size == NodeRules.MIN && n.conn.all |co| { co.val == maxVal } }, "All nodes should have ${NodeRules.MIN} connections of size $maxVal")
    // Set signal length to one to activate immediatly
    sc.signals[0].val = 1
    activatedNodes := sc.timePass
    verifyEq(activatedNodes.size,1,"One node should be activated at the end of signal")
    verifyEq(activatedNodes[0],node1,"The second node of the signal should be activated")
    // This activated allBig => explode => 3 signals and +3 on connections
    signalConn := node1.signal([sc], s.nodeFactory)
    verifyEq(signalConn.size,node1.conn.size,"${node1.conn.size} signals connections should arrive after activation of ${node1.fullStr} not $signalConn")
    verify(!node1.isValid,"${node1.fullStr} should be dead")
    s.signalingConnections=s.filterValidSignalConn(s.signalingConnections)
    s.signalingConnections.addAll(signalConn)
    s.checkSignalingConnections
    nbExpectedNodes := initNbNodes+node1.conn.size-1
    verifyEq(nodes.size,nbExpectedNodes,"Space ${s.debugStr} should have ${nbExpectedNodes} nodes not ${nodes.size}")
    verifyEq(s.signalingConnections.size,3,"Space ${s.debugStr} should have 3 connection with a signal not ${s.signalingConnections.size}")
  }

  private Void runMax(Space s) {
    Int sameStateFor := 0
    Int nbSignals := s.signalingConnections.size
    ConnValue currentState := s.state
    (0..(ConnRules.MAX*15)).each {
      s.timePass
      newState := s.state
      if (newState == currentState && nbSignals == s.signalingConnections.size)
        sameStateFor++
      else
        sameStateFor = 0
      verify(sameStateFor < ConnRules.MAX, "Universe ${s.debugStr} should move... Same state for ${ConnRules.MAX} rounds!")
      nbSignals = s.signalingConnections.size
      currentState = newState
      if (log.isDebug) log.debug(s.debugStr)
      if (log.isInfo) log.info(s.infoStr)
    }
  }
}