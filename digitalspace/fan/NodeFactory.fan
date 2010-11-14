/**
 * @author freds
 * @date Nov 12, 2010
 */

mixin SpaceFactory {
  abstract Node createNode()
  abstract Node forkNode(Node[] nodes, ConnValue[] val)
  abstract Connection createConnection(Node n1, Node n2, ConnValue val)
}


