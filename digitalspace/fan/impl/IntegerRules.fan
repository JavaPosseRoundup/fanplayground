@Serializable { simple = true }
const class IntegerRules : Rules {
  private const ConnectionFactory connFact
  private const Int miv
  private const Int mav
  private const Int mic
  private const Int mac
  private const Bool linear

  new make(Int minV, Int maxV, Int minC, Int maxC, Bool linearSigToVal, Type connectionFactoryType) {
    if (maxV % minV != 0) throw ArgErr("Max val $maxV needs to be a multiple of min val $minV")
    miv = minV
    mav = maxV
    mic = minC
    mac = maxC
    linear = linearSigToVal
    connFact = connectionFactoryType.make()
  }

  override ConnValue minVal() { return IntegerConnectionValue(miv) }
  override ConnValue maxVal() { return IntegerConnectionValue(mav) }
  override ConnValue randomVal() {
    return IntegerConnectionValue(Int.random((miv)..(mav)))
  }
  override Int minConn() { return mic }
  override Int maxConn() { return mac }
  override SigValue valToSigVal(ConnValue val) {
    Int iVal := ((IntegerConnectionValue)val).d
    if (linear)
      return IntegerSignalValue(iVal)
    else
      return IntegerSignalValue(1+mav-iVal)
  }

  override ConnValue valForSignals(Int nbSignals) {
    return minVal() * nbSignals
  }

  override Int nbSignalsForVal(ConnValue val) {
    Int iVal := ((IntegerConnectionValue)val).d
    if (iVal % miv != 0) {
      throw ArgErr("Cannot convert $val to signal since it not a multiple of $minVal")
    }
    return iVal/miv
  }

  override Connection createConnection(Node n1, Node n2, ConnValue? val := null) {
    return connFact.createConnection(n1, n2, val)
  }
}

