import scala.collection.mutable.ListBuffer
import scala.collection.mutable.HashMap

class QuantumValue[A](val value: Option[A] = None) {
  def get: A = value.get

  def isEmpty: Boolean = value.isEmpty
}

object Universe {
  val debug = false
  val history = ListBuffer[HashMap[String, QuantumValue[Any]]]()
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

  def get[T:Manifest](fieldname: String): Option[T] = {
    if (finalRun || inOut)
      getFromTime(fieldname, position).asInstanceOf[Option[T]]
    else
      getFromTime(fieldname, position + 1).asInstanceOf[Option[T]]
  }

  def set[T:Manifest](fieldname: String, value: Option[T]) {
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

  private def checkHistory(fieldname: String) {
    if (history.size <= position) {
      // TODO: Copy the map from previous history
      history += new HashMap[String, QuantumValue[Any]]()
      history(position) += (fieldname -> new QuantumValue[Any]())
    }
  }

  private def getFromTime(fieldname: String, pos: Int): Option[Any] = {
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

  def addValue(fieldname: String, value: Option[Any]) {
    checkHistory(fieldname)
    history(position) += (fieldname -> new QuantumValue[Any](value))
    position = position + 1
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
