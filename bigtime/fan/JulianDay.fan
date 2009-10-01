//
// Copyright (c) 2009, Frederic Simon
// Licensed under the Academic Free License version 3.0
//
// History:
//    4 Sep 09  Fred Simon  Creation
//

 ** The JulianDay supports turning Gregorian and Julian (Caesar) dates
 ** to/from Julius Scaliger's clever Julian Day Numbers.  In 1583,
 ** Julius had a great idea, and started to count the number of days
 ** starting on -4712-01-01 at noon (Z).  This is a wonderful
 ** "intermediate form" is still used for calendar calculations today!
 **
 ** @author Kleanthes Koniaris (C version)
 **
 ** @author Fred Simon (Fan version)
 ** @date Sep 4, 2009
const class JulianDay {
	static const Date JULIAN_ORIGIN := Date(-4712,Month.jan,1)
	static const Date LAST_JULIAN_DAY := Date(1582,Month.oct,4)
	static const Date FIRST_GREGORIAN_DAY := Date(1582,Month.oct,15)
	static const Time NOON := Time.fromIso("12:00:00")
	static const DateTime DATE_2000 := DateTime.fromIso("2000-01-01T12:00:00Z")
	static const Float JD_2000 := 2451545.0f
	static const Float MILLIS_IN_DAY := 86400000.0f
	static const Int BIG_BANG_IN_SECS := 432_330_242_400_000_000
	static const Int JD_2000_SECS := 211_813_488_000
	static const Int ONE_SEC := 1_000_000_000_000_000_000

    // With 2 Int values one for seconds around 1.1.2000 (-229 billion years to +229 billion years)
    // and the other for the smallest measurable time ever = 1 attoseconds = 1e-18s
    // - The Planck time ( tp = 5.391255e-44 ) is way too small here -
    // Nb secs since big bang 4.323302424E17 and nb secs in maxInt * PlanckTime 4.972555061055349E-25
    //Int seconds
    //Int attoseconds

	const Float value

	new make(Float jd) {
		value = jd
	}

	** This is valid for all Fan valid date time between 1901 and 2099
	static JulianDay fromDateTime(DateTime dt) {
		return JulianDay(JD_2000 + (dt.minus(DATE_2000).toMillis().toFloat() / MILLIS_IN_DAY))
	}

	** This is not using the Proleptic Gregorian Calendar http://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar
	** Or Proleptic Julian Calendar http://en.wikipedia.org/wiki/Julian_proleptic_calendar
	** But using the date of the gregorian reform http://en.wikipedia.org/wiki/Gregorian_Calendar where
	** "Council of Nicaea was corrected by a deletion of ten days":
	** The last day of the Julian calendar was Thursday, 4 October 1582 and this was followed by
	** the first day of the Gregorian calendar, Friday, 15 October 1582 (the cycle of weekdays was not affected)
	static JulianDay fromIsoDateTime(Date date, Time time := NOON, TimeZone tz := TimeZone.utc) {
	 	// If year between 1901 and 2099, use DateTime
	 	// If not remove or add 4centuries + centuries until we reach it
	 	if (date <= LAST_JULIAN_DAY) {
	 		return fromJulianDateTime(date, time, tz)
	 	} else if (date >= FIRST_GREGORIAN_DAY) {
	 		return fromGregorianDateTime(date, time, tz)
	 	}
	 	throw DateErr("Date $date does not exists due to Gregorian Calendar reform!")
	}

	** This is using the Proleptic Gregorian Calendar http://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar
	** and so ignore the Julian calendar switch
	static JulianDay fromGregorianDateTime(Date date, Time time := NOON, TimeZone tz := TimeZone.utc) {
	 	// If year between 1901 and 2099, use DateTime
	 	// If not remove or add quadro centuries (146,097 days) then centuries inside (36,524 days) until we reach it
	 	Int year := date.year
	 	Int nbQuadroCenturies := 0
		while (year < 1800) {
			year += 400
			nbQuadroCenturies--
		}
		while (year > 2200) {
			year -= 400
			nbQuadroCenturies++
		}
	 	Int nbCenturies := 0
		while (year < 1901) {
			year += 100
			nbCenturies--
		}
		while (year > 2099) {
			year -= 100
			nbCenturies++
		}
		return JulianDay(JulianDay.fromDateTime(
					DateTime(year, date.month, date.day,
		 					time.hour, time.min, time.sec, time.nanoSec, tz)).value +
			(nbQuadroCenturies.toFloat() * 146097.0f) + (nbCenturies.toFloat() * 36524.0f))
	}

	** This is using the Proleptic Julian Calendar http://en.wikipedia.org/wiki/Julian_proleptic_calendar
	** and so ignore the Gregorian calendar switch
	static JulianDay fromJulianDateTime(Date date, Time time := NOON, TimeZone tz := TimeZone.utc) {
	 	// If year between 1901 and 2099, use DateTime
	 	// If not remove or add centuries 36,525 days until we reach a good year
	 	Int year := date.year
	 	Int nbCenturies := 0
		while (year < 1901) {
			year += 100
			nbCenturies++
		}
		while (year > 2099) {
			year -= 100
			nbCenturies--
		}
		return JulianDay(JulianDay.fromDateTime(
					DateTime(year, date.month, date.day,
		 					time.hour, time.min, time.sec, time.nanoSec, tz)).value +
			(nbCenturies.toFloat() * 36525.0f))
	}

	JulianDay minusDuration(Duration duration) {
		return JulianDay(this.value + (duration.toMillis().toFloat() / MILLIS_IN_DAY))
	}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Negative of this.  Shortcut is -a.
  **
  JulianDay negate() { return JulianDay(-this.value) }

  **
  ** Multiply this with b.  Shortcut is a*b.
  **
  JulianDay mult(JulianDay b) { return JulianDay(this.value*b.value) }

  **
  ** Divide this by b.  Shortcut is a/b.
  **
  JulianDay div(JulianDay b) { return JulianDay(this.value/b.value) }

  **
  ** Return remainder of this divided by b.  Shortcut is a%b.
  **
  JulianDay mod(JulianDay b)  { return JulianDay(this.value%b.value) }

  **
  ** Add this with b.  Shortcut is a+b.
  **
  JulianDay plus(JulianDay b)  { return JulianDay(this.value+b.value) }

  **
  ** Subtract b from this.  Shortcut is a-b.
  **
  JulianDay minus(JulianDay b) { return JulianDay(this.value-b.value) }

  **
  ** Increment by one.  Shortcut is ++a or a++.
  **
  JulianDay increment()  { return JulianDay(this.value+1f) }

  **
  ** Decrement by one.  Shortcut is --a or a--.
  **
  JulianDay decrement() { return JulianDay(this.value-1f) }
}