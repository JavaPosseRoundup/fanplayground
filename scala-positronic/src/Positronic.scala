import scala.collection.mutable.ListBuffer
import scala.collection.mutable.HashMap

class QuantumValue[A](val value: Option[A] = None) {
  def get: A = value.get

  def isEmpty: Boolean = value.isEmpty
}

object Universe {
  val debug = false
  val history = ListBuffer[HashMap[String, QuantumValue[Int]]]()
  var position = 0
  var numRun = 0
  var finalRun = false
  var inOut = false

  def out(temp: Any) {
    if (Universe.finalRun) {
      inOut = true
      println(temp)
      inOut = false
    }
  }

  private def checkHistory(fieldname: String) {
    if (history.size <= position) {
      // TODO: Copy the map from previous history
      history += new HashMap[String, QuantumValue[Int]]()
      history(position) += (fieldname -> new QuantumValue[Int]())
    }
  }

  def get(fieldname: String): Option[Int] = {
    if (finalRun || inOut)
      getFromTime(fieldname, position)
    else
      getFromTime(fieldname, position + 1)
  }

  def getFromTime(fieldname: String, pos: Int): Option[Int] = {
    checkHistory(fieldname)
    if (history.size > pos) {
      history(pos).get(fieldname) match {
        case None => None
        case Some(quVal) => quVal.value
      }
    } else {
      None
    }
  }

  def addValue(fieldname: String, value: Option[Int]) {
    checkHistory(fieldname)
    history(position) += (fieldname -> new QuantumValue[Int](value))
    position = position + 1
  }

  def set(fieldname: String, value: Option[Int]) {
    addValue(fieldname, value)
  }

  def live(func: => Unit) {
    while (numRun < 5 && !isDone) {
      position = 0
      func
      if (debug) {
        println("in the loop " + numRun + " position=" + position)
      }
      numRun = numRun + 1
    }
    if (isDone) {
      finalRun = true
      position = 0
      func
    }
  }

  def isDone: Boolean = {
    if (debug) {
      println("Debug from is done")
      for {
        h <- history
        p <- h
      } yield println(s"${h.hashCode()} ${p._1} : ${p._2.value}")
    }
    numRun != 0 &&
      !history.isEmpty &&
      !history.exists(_.isEmpty) &&
      !history.exists(_.values.exists(_.isEmpty))
  }
}
