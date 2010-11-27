/**
 * @author freds
 * @date Nov 12, 2010
 */


const class IntegerConnectionFactory : ConnectionFactory {
  override Connection createConnection(Node n1, Node n2, ConnValue? val := null) {
    return IntegerConnection(n1,n2,val)
  }
}

class IntegerSignalValue : SigValue {
  Int d { private set }

  new make(Int val) {
    d = val
  }

  override Str toStr() { "$d" }

  override Bool isDone() {
    return (d <= 0)
  }

  override Bool equals(Obj? o) {
    if (o isnot IntegerSignalValue) return false
    return this.d == ((IntegerSignalValue)o).d
  }

  override Int hash() {
    return d.hash
  }

  override Int compare(Obj o) {
    if (o isnot IntegerSignalValue) throw Err("Cannot compare an IntegerSignalValue to ${o.typeof()}")
    return this.d <=> ((IntegerSignalValue)o).d
  }

  @Operator override SigValue decrement() {
    d--
    return this
  }

  @Operator override SigValue plus(SigValue o) {
    if (o isnot IntegerSignalValue) throw Err("Cannot plus an IntegerSignalValue to ${o.typeof()}")
    return IntegerSignalValue(d + ((IntegerSignalValue)o).d)
  }

  @Operator override SigValue minus(SigValue o) {
    if (o isnot IntegerSignalValue) throw Err("Cannot minus an IntegerSignalValue to ${o.typeof()}")
    return IntegerSignalValue(d - ((IntegerSignalValue)o).d)
  }
}

class IntegerConnection : Connection {
  IntegerConnectionValue connVal

  new make(Node node1, Node node2, ConnValue? v := null) : super(node1,node2) {
    if (v == null) {
      connVal = IntegerConnectionValue()
    } else {
      connVal = checkVal(v)
    }
  }

  private IntegerConnectionValue checkVal(ConnValue v) {
    if (v isnot IntegerConnectionValue) throw Err("IntegerConnection takes only IntegerConnectionValue not ${v.typeof}")
    if (!v.valid()) {
      throw Err(v.invalidReason)
    }
    return v
  }

  override ConnValue val() { return connVal }
  override Void setVal(ConnValue v) {
    connVal = checkVal(v)
  }
}

class IntegerConnectionValue : ConnValue {
  static IntegerRules rules() { return RuleHolder.rules }

  Int d { private set }

  new make(Int val) {
    d = val
  }

  override Str toStr() { "$d" }

  override Bool valid() {
    return (d >= rules.miv) && (d <= rules.mav)
  }

  override Str? invalidReason() {
    if (d < rules.miv) return "Value $d is below MIN ${rules.miv}"
    if (d > rules.mav) return "Value $d is above MAX ${rules.mav}"
    return null
  }

  override Bool equals(Obj? o) {
    if (o isnot IntegerConnectionValue) return false
    return this.d == ((IntegerConnectionValue)o).d
  }

  override Int hash() {
    return d.hash
  }

  override Bool isZero() {
    return d <= 0
  }

  override Int compare(Obj o) {
    if (o isnot IntegerConnectionValue) throw Err("Cannot compare an IntegerConnectionValue to ${o.typeof()}")
    return this.d <=> ((IntegerConnectionValue)o).d
  }

  override Bool canIncrement() {
    return d < rules.mav
  }

  @Operator override ConnValue increment() {
    d++
    return this
  }

  override Bool canDecrement() {
    return d > rules.miv
  }

  @Operator override ConnValue decrement() {
    d--
    return this
  }

  @Operator override ConnValue plus(ConnValue o) {
    if (o isnot IntegerConnectionValue) throw Err("Cannot plus an IntegerConnectionValue to ${o.typeof()}")
    return IntegerConnectionValue(d + ((IntegerConnectionValue)o).d)
  }

  @Operator override ConnValue minus(ConnValue o) {
    if (o isnot IntegerConnectionValue) throw Err("Cannot minus an IntegerConnectionValue to ${o.typeof()}")
    return IntegerConnectionValue(d - ((IntegerConnectionValue)o).d)
  }

  @Operator override ConnValue mult(Int per) {
    return IntegerConnectionValue(d * per)
  }

  @Operator override ConnValue div(Int per) {
    v := d / per
    // Can never be 0 => at least 1
    if (v == 0) v = 1
    return IntegerConnectionValue(v)
  }

  override ConnValue[] half() {
    Int[] half := [rules.miv,rules.miv]
    if (d <= rules.miv*2) {
      // Not enough connection length to cut in 2
      // Generate 2 identical half of min length
    } else {
      half[0] = d / 2
      half[1] = d - half[0]
    }
    return [IntegerConnectionValue(half[0]), IntegerConnectionValue(half[1])]
  }
}


