import collection.mutable
import scala.collection.mutable.ListBuffer

object Universe {
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

  def set(fieldname: String, value: Option[Int]) {
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
    /*&&
    !history.exists(_.values.exists(_ None)) */


  

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
    blah = temperature/4 - 2
    out(blah)
    blah = blah.collect {case x:Int => x * -1}
    out(blah)
    blah = theList.indexOf(toFind)

    }
  

}





