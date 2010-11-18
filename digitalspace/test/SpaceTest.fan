
class SpaceTest : Test {
  const static Log log := Log.get("SpaceTest")

  new make() {
    // Activate or deactivate logging
    log.level = LogLevel.warn
    Space.log.level = LogLevel.warn
    NodeMinMax.log.level = LogLevel.warn
  }

  Void testSpace4_4() {
    log.info("Starting 4-4 Exploding SpaceTime")
    s := Space()
    s.init(4,4,Space.connFactory.minVal)
    runMax(s,5)
  }

  Void testSpace22_15() {
    log.info("Starting 22-15 SpaceTime")
    s := Space()
    s.init(22,15)
    runMax(s,8)
  }

  Void testSpace30_30() {
    log.info("Starting 30-30 SpaceTime")
    s := Space()
    s.init(30,30)
    runMax(s,8)
  }

  ** Testing node behavior when too big
  Void testAllMax() {
    log.info("Starting SpaceTime for all big test")
    s := Space()
    ConnValue maxVal := Space.connFactory.maxVal
    initNbNodes := NodeRules.MIN*2
    s.init(initNbNodes,1,maxVal)
    nodes := s.nodeFactory.allNodes
    verifyEq(nodes.size,initNbNodes,"Space Should have ${NodeRules.MIN+1} nodes not ${nodes.size}")
    verifyEq(s.signalingConnections.size,1,"Space should have 1 connection with a signal not ${s.signalingConnections.size}")
    log.debug(s.debugStr)
    sc := s.signalingConnections[0]
    verifyEq(sc.signals.size,1,"Signaling connection $sc should have one signal")
    node0 := sc.signals[0].from
    node1 := sc.otherSideOf(node0)
    verify(node0.conn.size < NodeRules.MIN+2 , "Node 0 ${node0.fullStr} should have less than ${NodeRules.MIN+2} connections!")
    verify(nodes.all |n| { n.conn.size < NodeRules.MIN+2 && n.conn.all |co| { co.val == maxVal } }, "All nodes of ${s.debugStr} should have less than ${NodeRules.MIN+2} connections of size $maxVal")
    // Set signal length to one to activate immediatly
    sc.signals[0].val = 1
    activatedNodes := sc.timePass
    verifyEq(activatedNodes.size,1,"One node should be activated at the end of signal")
    verifyEq(activatedNodes[0],node1,"The second node of the signal should be activated")
    // This activated allBig with less than 2 possible connections => 2 signals and +1 on connections
    signalConn := node1.signal([sc], s.nodeFactory)
    verifyEq(signalConn.size,1,"1 signals connections should arrive after activation of ${node1.fullStr} not $signalConn")
    verify(!node1.isValid,"${node1.fullStr} should be dead")
    s.signalingConnections=s.filterValidSignalConn(s.signalingConnections)
    s.signalingConnections.addAll(signalConn)
    s.checkSignalingConnections
    verifyEq(nodes.size,initNbNodes-1,"Space should have ${initNbNodes-1} nodes not ${nodes.size}")
    verifyEq(s.signalingConnections.size,1,"Space should have 1 connection with a signal not ${s.signalingConnections.size}")
  }

  ** Testing node behavior when too small
  Void testAllMin() {
    log.info("Starting SpaceTime for all min test")
    s := Space()
    ConnValue minVal := Space.connFactory.minVal
    initNbNodes := NodeRules.MIN+1
    s.init(initNbNodes,1,minVal)
    nodes := s.nodeFactory.allNodes
    verifyEq(nodes.size,NodeRules.MIN+1,"Space Should have ${NodeRules.MIN+1} nodes not ${nodes.size}")
    verifyEq(s.signalingConnections.size,1,"Space should have 1 connection with a signal not ${s.signalingConnections.size}")
    log.debug(s.debugStr)
    sc := s.signalingConnections[0]
    verifyEq(sc.signals.size,1,"Signaling connection $sc should have one signal")
    node0 := sc.signals[0].from
    node1 := sc.otherSideOf(node0)
    verifyEq(node0.conn.size,NodeRules.MIN,"Node 0 ${node0.fullStr} should have ${NodeRules.MIN} connections!")
    verify(nodes.all |n| { n.conn.size == NodeRules.MIN && n.conn.all |co| { co.val == minVal } }, "All nodes should have ${NodeRules.MIN} connections of size $minVal")
    verifyEq(s.state, minVal*6, "The total state of ${s.infoStr}\n${s.debugStr} should be ${minVal*6}")
    // Set signal length to one to activate immediatly
    sc.signals[0].val = 1
    activatedNodes := sc.timePass
    verifyEq(activatedNodes.size,1,"One node should be activated at the end of signal")
    verifyEq(activatedNodes[0],node1,"The second node of the signal should be activated")
    // This activated allSmall => explode => 3 signals and +3 on connections
    signalConn := node1.signal([sc], s.nodeFactory)
    verifyEq(signalConn.size,node1.conn.size,"${node1.conn.size} signals connections should arrive after activation of ${node1.fullStr} not $signalConn")
    verify(!node1.isValid,"${node1.fullStr} should be dead")
    s.signalingConnections=s.filterValidSignalConn(s.signalingConnections)
    s.signalingConnections.addAll(signalConn)
    s.checkSignalingConnections
    nbExpectedNodes := initNbNodes+node1.conn.size-1
    verifyEq(nodes.size,nbExpectedNodes,"Space ${s.debugStr} should have ${nbExpectedNodes} nodes not ${nodes.size}")
    verifyEq(s.signalingConnections.size,3,"Space ${s.debugStr} should have 3 connection with a signal not ${s.signalingConnections.size}")
    verifyEq(s.currentState, minVal*(6 + 3), "The total state of ${s.infoStr}\n${s.debugStr} should be ${minVal*(6+3)}")
  }

  private Void runMax(Space s, Int steps := ConnRules.MAX*5) {
    (0..steps).each {
      s.timePass
      verify(s.sameStateFor < ConnRules.MAX, "Universe ${s.debugStr} should move... Same state for ${ConnRules.MAX} rounds!")
      if (log.isDebug) log.debug(s.debugStr)
      if (log.isInfo) log.info(s.infoStr)
    }
  }
}