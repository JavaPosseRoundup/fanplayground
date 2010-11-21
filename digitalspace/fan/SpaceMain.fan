/**
 * @author freds
 * @date Nov 17, 2010
 */

using util

class SpaceMain : AbstractMain {
  @Opt{ help = "Initial number of nodes" }
  Int nbNodes := 4

  @Opt{ help = "Initial number of signals" }
  Int nbSignals := 4

  @Arg{ help = "Number of steps to run" }
  Int? nbSteps

  @Opt{ help = "Minimum number of connections" }
  Int minConn := 3

  @Opt{ help = "Maximum number of connections" }
  Int maxConn := 6

  @Opt{ help = "Minimum size of a connection" }
  Int minVal := 2

  @Opt{ help = "Maximum size of a connection" }
  Int maxVal := 8

  @Opt{ help = "Signal on decrement or increment" }
  Bool sigOnDec := true

  override Int run() {
    Space.log.level = LogLevel.info
    NodeMinMax.log.level = LogLevel.warn
    s := Space()
    s.init(nbNodes,nbSignals)
    (0..nbSteps).each {
      s.timePass
    }
    return 0
  }
}