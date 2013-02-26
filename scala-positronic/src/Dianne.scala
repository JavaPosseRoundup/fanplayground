import scala.collection.mutable.MutableList
import scala.collection.mutable.Map

object Recorder extends App {
	val history = MutableList[Map[String, Int]]()
    var position = 0

    def get(fieldname: String) = {
      	if (history.size <= position) {

      		// TODO: Copy the map from previous history
      		val m = Map[String, Int]()
      		m += fieldname -> position
      		history +=  m

      	}
      	history(position).get(fieldname)
    }

    def set(fieldname: String, value: Int) = {
      	if (history.size <= position) {
      		// TODO: Copy the map from previous history
      		history += Map(fieldname->value)
      	}
      	history(position)(fieldname)->value
    }
}

class Dianne {
	def blah = Recorder.get("blah")
	def blah_=(x : Int) = { Recorder.set("blah", x) }
}

/*
val dianne = new Dianne()
dianne.blah = 12
println(dianne.blah)
*/

