/**
 * @author freds
 * @date Nov 16, 2010
 */

class Signal {
  Node from
  SigValue val

  new make(Node fromNode, SigValue d) {
    from = fromNode
    val = d
  }

  Bool timePass() {
    if (val.isDone) throw Err("Signal from $from is done")
    val--
    return val.isDone
  }

  Void add(SigValue d) {
    if (val.isDone) throw Err("Signal from $from is done")
    val += d
    if (val.isDone) throw Err("Signal from $from was deleted by length reduction")
  }

  override Str toStr() {
    return "<Signal $hash length=$val from=${from.hash} >"
  }
}

