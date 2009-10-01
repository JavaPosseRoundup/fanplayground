/**
 * @author freds
 * @date Sep 12, 2009
 */

class DatePrecisionTest {
	const static Float ageOfTheUniverse := 13.7e9f // In years
	const static Float planckTime := 5.391255e-44f // In seconds

	static Void main(Str[] args) {
	    Float secondsSinceBigBang := ageOfTheUniverse * 86400f * 365.2425f
	    Float secondsIntInPlanckTime := planckTime * Int.maxVal.toFloat()
	    echo("Nb secs since big bang $secondsSinceBigBang and nb secs in int planck time $secondsIntInPlanckTime")
		intIsSec
		intIsMilliSec
		intIsNano
	}

	static Void intIsNano() {
		// If Int is nano seconds
		Float nanoSecs := Int.maxVal.toFloat()
		Float secs := nanoSecs * 1e-9f
		Float days := secs / 86400f
		Float years := days / 365.2425f
		Float percentAge := 100f * years / ageOfTheUniverse
		echo("Size of ${nanoSecs} ns is ${secs} secs or ${days} days or ${years} years or ${percentAge} percent age of universe")
	}

	static Void intIsMilliSec() {
		// If Int is seconds
		Float secs := Int.maxVal.toFloat() / 1000f
		Float days := secs / 86400f
		Float years := days / 365.2425f
		Float percentAge := 100f * years / ageOfTheUniverse
		echo(" Size of ${secs} secs or ${days} days or ${years} years or ${percentAge} percent age of universe")
	}

	static Void intIsSec() {
		// If Int is seconds
		Float secs := Int.maxVal.toFloat()
		Float days := secs / 86400f
		Float years := days / 365.2425f
		Float percentAge := 100f * years / ageOfTheUniverse
		echo(" Size of ${secs} secs or ${days} days or ${years} years or ${percentAge} percent age of universe")
	}
}