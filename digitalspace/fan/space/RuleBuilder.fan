/**
 * @author freds
 * @date Nov 17, 2010
 */

using util

enum class ConnectionValueType {
  Integer, Complex
}

enum class SignalRuleType {
  IntegerLinear, IntegerInverse, Complex
}

enum class NodeRuleType {
  MinMax, Memory
}

class RuleBuilder : AbstractMain {
  @Arg{ help = "Output JSON file for the rule implementation"; aliases=["f"] }
  File? fileOut

  @Opt{ help = "Minimum number of connections" }
  Int minConn := 3

  @Opt{ help = "Maximum number of connections" }
  Int maxConn := 6

  @Opt{ help = "Minimum size of a connection" }
  Int minVal := 2

  @Opt{ help = "Maximum size of a connection" }
  Int maxVal := 8

  @Opt{ help = "Connection value type: ${ConnectionValueType.vals}"; aliases=["c"] }
  ConnectionValueType connValType := ConnectionValueType.Integer

  @Opt{ help = "Signal rule type: ${SignalRuleType.vals}"; aliases=["s"] }
  SignalRuleType sigRuleType := SignalRuleType.IntegerLinear

  @Opt{ help = "Node rule type: ${NodeRuleType.vals}"; aliases=["n"] }
  NodeRuleType nodeRuleType := NodeRuleType.MinMax

  override Int run() {
    if (out == null) {
      echo("Output file name is mandatory")
      return 1
    }
    Rules? rules
    switch (connValType) {
      case ConnectionValueType.Integer:
        rules = IntegerRules(minVal,maxVal,minConn,maxConn,sigRuleType==SignalRuleType.IntegerLinear,IntegerConnectionFactory.typeof)
      case ConnectionValueType.Complex:
        throw UnsupportedErr("Complex value type not implemented yet")
    }
    JsonOutStream(fileOut.out).writeJson(rules)
    return 0
  }
}