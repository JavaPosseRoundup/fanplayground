/**
 * @author freds
 * @date Nov 16, 2010
 */

class Signal {
  Node from
  Int val

  new make(Node fromNode, Int d) {
    from = fromNode
    val = d
  }

  Bool timePass() {
    if (val <= 0) throw Err("Signal from $from is done")
    val--
    return val == 0
  }

  Int length() { return val }

  Void add(Int d) {
    if (val <= 0) throw Err("Signal from $from is done")
    val += d
    if (val <= 0) throw Err("Signal from $from was deleted by length reduction")
  }

  override Str toStr() {
    return "<Signal $hash length=$val from=${from.hash} >"
  }
}

