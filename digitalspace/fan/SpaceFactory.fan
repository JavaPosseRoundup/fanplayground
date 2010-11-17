/**
 * @author freds
 * @date Nov 12, 2010
 */

mixin NodeFactory {
  abstract Node[] allNodes()
  abstract Node createNode()
  abstract Node forkNode(Node[] nodes, ConnValue[] val)
  abstract Void killNode(Node n)
}

const mixin ConnectionFactory {
  abstract Connection createConnection(Node n1, Node n2, ConnValue? val := null)
  abstract ConnValue minVal()
  abstract ConnValue maxVal()
}


