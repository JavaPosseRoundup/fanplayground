/**
 * @author freds
 * @date Oct 5, 2009
 */

class Space {
  static const ConnectionFactory connFactory := IntegerConnectionFactory()
  NodeFactory nodeFactory := Node34Factory()
  Connection[] signalingConnections := [,]

  Void init(Int size := 4, Int nbSignals := 1) {
    if (size < 4) throw Err("Cannot create space less than 4")
    Node[] nodes := [,]
    (0..(size-1)).each { nodes.add(nodeFactory.createNode()) }
    nodes[0..(size-2)].each |na,idx| {
      end := idx+3
      if (end > size-1) end = size-1
      nodes[(idx+1)..end].each |nb| {
        if (na.conn.size < 3 && nb.conn.size < 3)
         na.connect(connFactory.createConnection(na,nb), nb)
      }
    }
    (0..(nbSignals-1)).each |idx| {
      n0 := nodes[idx]
      c0 := n0.conn[0]
      if (c0.hasSignal) c0 = n0.conn[1]
      if (c0.hasSignal) c0 = n0.conn[2]
      c0.addSignal(n0)
      signalingConnections.add(c0)
    }
    checkSignalingConnections
  }

  private Void checkSignalingConnections() {
    // get only unique and remove connections with no signals or dead nodes
    signalingConnections = signalingConnections.unique.findAll |co| { co.hasSignal && !co.hasDeadNodes }
  }

  Void timePass() {
    // Activate time pass on all signaling connections and collect activated nodes
    Node:Connection[] signaled := [:]
    signalingConnections.each |co| {
      co.timePass.each |n| {signaled.get(n,[,]).add(co)}
    }
    // Activate signal on all activated node and collect new signaled connections
    signaled.each |conns,n| {
      signalingConnections.addAll(n.signal(conns))
    }
    checkSignalingConnections
  }

  Void main() {
    echo("Starting SpaceTime")
    s := Space()
    s.init()
    echo("Space has ${s.nodeFactory.all.size} nodes and ${s.signalingConnections.size} signals")
  }
}