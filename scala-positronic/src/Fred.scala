import collection.mutable
import scala.collection.mutable.ListBuffer

object Recorder {
  val history = ListBuffer[mutable.ListMap[String, Int]]()
  var position = 0

  def get(fieldname: String) = {
    if (history.size <= position) {
      // TODO: Copy the map from previous history
      history += new mutable.ListMap[String, Int]()
    }
    history(position).get(fieldname)
  }

  def set(fieldname: String, value: Int) {
    if (history.size <= position) {
      // TODO: Copy the map from previous history
      history += new mutable.ListMap[String, Int]()
    }
    history(position)(fieldname) = value
  }
}

object Fred extends App {
  def blah = Recorder.get("blah")
  def blah_=(x: Int) {
    Recorder.set("blah", x)
  }

   
    blah = 12
    println(blah)
    blah = 14
    println(blah)
  
}





