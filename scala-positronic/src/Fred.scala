import collection.mutable
import scala.collection.mutable.ListBuffer

object Recorder {
  val history = ListBuffer[mutable.ListMap[String, Int]]()
  var position = 0
  var numRun = 0

  def get(fieldname: String) = {
    if (history.size <= position) {
      // TODO: Copy the map from previous history
      history += new mutable.ListMap[String, Int]()
    }
    history(position).get(fieldname)
  }

  def set(fieldname: String, value: Int) {
    if (numRun > 0) {
      history(position)(fieldname) = value; position = position + 1

    }
    else {
      get(fieldname) match {
      
        case None =>  history(position)(fieldname) = value; position = position + 1
        case _ => position = position + 1; set(fieldname, value)
      }

    }
  }

  def live(func: => Unit) {
    
    while (numRun < 20 && !isDone) {
      position = 0
      println("in the loop " + numRun)
      func
      
      numRun = numRun+1
    }
    if (isDone) {
      position = 0
      func      
    }
  }



  def isDone: Boolean = {
    numRun != 0 &&
    !history.isEmpty &&
    !(history.exists(_.isEmpty ))

  

  }
}

object Fred extends App {
  val temperature = 32
  def blah = Recorder.get("blah")
  def blah_=(x: Int) {
    Recorder.set("blah", x)
  }

  def out(temp: Any) {
     if (Recorder.isDone) println(temp)
  }
  /*def runUniverse(x: Unit { 
    out(blah)
    blah = temperature/4 - 2
    out(blah)
    blah = temperature*4
  }
  */

  Recorder.live {
    out(blah)
    blah = temperature/4 - 2
    out(blah)
    blah = temperature*4
    }
  
}





