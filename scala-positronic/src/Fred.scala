import collection.mutable
import scala.collection.mutable.ListBuffer

class QuantumValue[A](val value: Option[A] = None) {
  def get: A = value.get
  def isEmpty: Boolean = value.isEmpty
}

object Universe {
  val history = ListBuffer[mutable.ListMap[String, QuantumValue[Int]]]()
  var position = 0
  var numRun = 0

  def get(fieldname: String): Option[Int] = {
    if (history.size <= position) {
      // TODO: Copy the map from previous history
      history += new mutable.ListMap[String, QuantumValue[Int]]()
    }
    history(position).get(fieldname) match {
      case None => None
      case Some(quVal) => quVal.value
    }
  }

  def addValue(fieldname: String, value: Option[Int]) {
    history(position) += (fieldname -> new QuantumValue[Int](value))
    position = position + 1
  }

  def set(fieldname: String, value: Option[Int]) {
    addValue(fieldname, value)
  }

  def live(func: => Unit) {
    while (numRun < 20 && !isDone) {
      position = 0
      println("in the loop " + numRun)
      func
      numRun = numRun + 1
    }
    if (isDone) {
      position = 0
      func
    }
  }

  def isDone: Boolean = {
    numRun != 0 &&
      !history.isEmpty &&
      !history.exists(_.isEmpty) &&
      !history.exists(_.values.exists(_.isEmpty))
  }
}

object Fred extends App {

  val theList = List("now", "is", "the", "time")
  val toFind = "the"
  val temperature = 32

  def blah = Universe.get("blah")

  def blah_=(x: Int) {
    Universe.set("blah", Some(x))
  }

  def blah_=(x: Option[Int]) {
    Universe.set("blah", x)
  }

  def out(temp: Any) {
    if (Universe.isDone) println(temp)
  }

  Universe.live {
    out(blah)
    blah = temperature / 4 - 2
    out(blah)
    blah = blah.collect {
      case x: Int => x * -1
    }
    out(blah)
    blah = theList.indexOf(toFind)
  }
}





