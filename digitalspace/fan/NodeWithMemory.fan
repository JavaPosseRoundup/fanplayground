enum class NodeState {
  AB, AC, BC, BA, CA, CB;
}

class NodeWithMemory : Node {
  NodeState? s

  new make() {
  }

  override Connection[] signal(Connection[] from) {
    switch (s) {
      case NodeState.AB:
       --conn[0]
       ++conn[1]
      case NodeState.AC:
       --conn[0]
       ++conn[2]
      case NodeState.BC:
       --conn[1]
       ++conn[2]
      case NodeState.BA:
       ++conn[0]
       --conn[1]
      case NodeState.CA:
       ++conn[0]
       --conn[2]
      case NodeState.CB:
       ++conn[1]
       --conn[2]
    }
    return [,]
  }
}


