import org.omg.PortableInterceptor.USER_EXCEPTION
import Universe._

object Fred extends App {

  val theList = List("now", "is", "the", "time", "to", "find", "in", "a", "list")
  val toFind = "in"
  val temperature = 20
  val blah = new PositronicVar[Int]("b")

  live {
    out(blah.v)
    blah.v = blah.calc { x => temperature / 4 - x }
    out(blah.v)
    blah.v = blah.calc { x => x * -1 }
    out(blah.v)
    blah.v = theList.indexOf(toFind)
  }
}

class PositronicVar[T:Manifest] (name:String) {
  val tt = manifest[T].runtimeClass
  def v : Option[T] = get[T](name)
  def v_=(x: T) { set(name, Some(x)) }
  def v_=(x: Option[T]) { set(name, x) }
  def calc(f: T => T) : Option[T] = {
    Universe.get(name) map { v => f(v) }
  }
}



