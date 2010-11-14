/**
 * @author freds
 * @date Oct 5, 2009
 */

class Space {
  const Node[] nodes
  static const SpaceFactory factory := Node34Factory()

  new make(Int size) {
    nodes = List.make(Node#, size*2)
    a := 0
    b := 0

  }
}