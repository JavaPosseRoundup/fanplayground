 ** Data from http://www.nr.com/julian.html and http://www.quadibloc.com/science/cal04.htm
 ** ISO 8601 used in Fan DateTime is a Gregorian date format (so don't use julian only dates)
 ** @author freds
 ** @date Sep 4, 2009
class JulianDayTest : Test {
	Void testJ2000()
	{
		JulianDay jd2000 := JulianDay.fromDateTime(DateTime.fromIso("2000-01-01T12:00:00Z"))
		this.verifyEq(jd2000.value, 2451545.0f);
	}

	Void testSimpleDate()
	{
		[Str:Float] testValues := [
		"2009-09-04T12:00:00Z":2455079.0f,
		"1901-01-01T00:00:00Z":2415385.5f,
		"2099-01-01T12:00:00Z":2487705.0f,
		"2099-12-31T12:00:00Z":2488069.0f,
		]
		testValues.each |Float jdValue, Str isoDate|
		{
			this.verifyEq(JulianDay.fromDateTime(DateTime.fromIso(isoDate)).value, jdValue);
		}
	}

	Void testDateTime()
	{
		[Str:Float] testValues := [
		"2009-09-04T10:10:10Z":2455078.423726852f,
		"2009-09-04T11:59:59.999Z":2455078.9999999884f,
		"2009-09-04T10:10:10Z":2455078.923726852f,
		"1901-01-01T00:00:00.001Z":2415385.5000000116f,
		"2099-12-31T23:59:59.999Z":2488069.4999999884f,
		]
		testValues.each |Float jdValue, Str isoDate|
		{
			this.verifyEq(JulianDay.fromDateTime(DateTime.fromIso(isoDate)).value, jdValue);
		}
	}

	Void testGregorianDate()
	{
		[Str:Float] testValues := [
		"1582-10-15":2299161.0f,
		"1858-11-16":2400000.0f,
		"2132-08-31":2500000.0f,
		"2406-06-16":2600000.0f,
		]
		testValues.each |Float jdValue, Str gregorianDate|
		{
			this.verifyEq(JulianDay.fromGregorianDateTime(Date(gregorianDate)).value, jdValue);
			this.verifyEq(JulianDay.fromIsoDateTime(Date(gregorianDate)).value, jdValue);
		}
	}

	Void testMathOperator()
	{
		jd1 := JulianDay.fromDateTime(DateTime.fromIso("1901-01-01T00:00:00Z"))
		jd2 := JulianDay.fromDateTime(DateTime.fromIso("1901-01-20T00:00:00Z")) - jd1
		verifyEq(jd2.value, 19.0f)
	}
}