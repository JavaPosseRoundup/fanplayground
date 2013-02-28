
object Fred extends App {

  val theList = List("now", "is", "the", "time", "to", "find", "in", "a", "list")
  val toFind = "in"
  val temperature = 20

  Universe.live {
    Universe.out(blah)
    blah = blah.collect {
      case x: Int => temperature / 4 - x
    }
    Universe.out(blah)
    blah = blah.collect {
      case x: Int => x * -1
    }
    Universe.out(blah)
    blah = theList.indexOf(toFind)
  }









  def blah = Universe.get("blah")

  def blah_=(x: Int) {
    blah = Some(x)
  }

  def blah_=(x: Option[Int]) {
    Universe.set("blah", x)
  }
}





