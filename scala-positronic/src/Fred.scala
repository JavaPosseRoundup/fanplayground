object Recorder extends App {
	val history = List[Map[String, Int]]()
    var position = 0

    def get(fieldname: String) = {
      	if (history.size <= position) {
      		// TODO: Copy the map from previous history
      		history += new Map[String, Int]
      	}
      	history(position).get(fieldname)
    }

    def set(fieldname: String, value: Int) = {
      	if (history.size <= position) {
      		// TODO: Copy the map from previous history
      		history += new Map[String, Int]
      	}
      	history(position)(fieldname) = value
    }
}

class Fred {
	def blah = Recorder.get("blah")
	def blah_=(x : Int) = { Recorder.set("blah", x) }
}

val fred = new Fred()
fred.blah = 12
println(fred.blah)
	
