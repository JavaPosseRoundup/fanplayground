/**
 * @author freds
 * @date Nov 12, 2010
 */

mixin ConnValue {
  abstract Bool valid()
  abstract Str? invalidReason()
  abstract Bool isZero()
  abstract Bool canIncrement()
  @Operator abstract ConnValue increment()
  abstract Bool canDecrement()
  @Operator abstract ConnValue decrement()
  @Operator abstract ConnValue plus(ConnValue o)
  @Operator abstract ConnValue minus(ConnValue o)
  @Operator abstract ConnValue mult(Int per)
  @Operator abstract ConnValue div(Int per)
  abstract ConnValue[] half()
}

mixin SigValue {
  abstract Bool isDone()
  @Operator abstract SigValue decrement()
  @Operator abstract SigValue plus(SigValue o)
  @Operator abstract SigValue minus(SigValue o)
}

const mixin Rules : ConnectionFactory {
  abstract ConnValue minVal()
  abstract ConnValue maxVal()
  abstract ConnValue randomVal()
  abstract Int minConn()
  abstract Int maxConn()
  abstract SigValue valToSigVal(ConnValue val)

  abstract ConnValue valForSignals(Int nbSignals)
  abstract Int nbSignalsForVal(ConnValue val)
}


