
object Fred extends App {

  val theList = List("now", "is", "the", "time", "to", "find", "in", "a", "list")
  val toFind = "in"
  val temperature = 240

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

  def blah = Universe.get("blah")

  def blah_=(x: Int) {
    blah = Some(x)
  }

  def blah_=(x: Option[Int]) {
    Universe.set("blah", x)
  }

  def out(temp: Any) {
    if (Universe.finalRun) println(temp)
  }
}





