/**
 * @author freds
 * @date Nov 12, 2010
 */

const class Rules {
  static const Int MIN := 4
  static const Int MAX := 10
}

class IntegerConnection : Connection {
  IntegerConnectionValue connVal := IntegerConnectionValue()

  new make(Node node1, Node node2, ConnValue v) : super(node1,node2) {
   if (v isnot IntegerConnectionValue) throw Err("IntegerConnection takes only IntegerConnectionValue not ${v.typeof}")
   connVal = (IntegerConnectionValue)v
  }

  override ConnValue val() { return connVal }
  override Void setVal(ConnValue v) {
   if (v isnot IntegerConnectionValue) throw Err("IntegerConnection takes only IntegerConnectionValue not ${v.typeof}")
   connVal = (IntegerConnectionValue)v
  }
}

class IntegerConnectionValue : ConnValue {
  Int d { set {
    if (it < Rules.MIN) throw Err("Value $it is below MIN ${Rules.MIN}")
    if (it > Rules.MAX) throw Err("Value $it is above MAX ${Rules.MAX}")
    &d = it
  } }

  new make(Int val := Rules.MIN) {
    d = val
  }

  override Int compare(Obj o) {
    if (o isnot IntegerConnectionValue) throw Err("Cannot compare an IntegerConnectionValue to ${o.typeof()}")
    return this.d <=> ((IntegerConnectionValue)o).d
  }

  override Bool canIncrement() {
    return d < Rules.MAX
  }

  @Operator override ConnValue increment() {
    d++
    return this
  }

  override Bool canDecrement() {
    return d > Rules.MIN
  }

  @Operator override ConnValue decrement() {
    d--
    return this
  }

  @Operator override ConnValue plus(ConnValue o) {
    if (o isnot IntegerConnectionValue) throw Err("Cannot plus an IntegerConnectionValue to ${o.typeof()}")
    d = d + ((IntegerConnectionValue)o).d
    return this
  }

  @Operator override ConnValue minus(ConnValue o) {
    if (o isnot IntegerConnectionValue) throw Err("Cannot minus an IntegerConnectionValue to ${o.typeof()}")
    d = d - ((IntegerConnectionValue)o).d
    return this
  }

  override ConnValue[] half() {
    Int firstHalf := d / 2
    return [IntegerConnectionValue(firstHalf), IntegerConnectionValue(d-firstHalf)]
  }

  override Int signalLength() { return d }
}


