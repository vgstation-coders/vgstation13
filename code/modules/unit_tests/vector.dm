/datum/unit_test/vector_duplicate/start()
	var/vector/V
	var/vector/D
	for(var/i in range(100))
		V = new /vector(i, i*2)
		D = V.duplicate()
		if(D == V)
			fail("Reference copied")

		if(D.x != V.x || D.y != V.y)
			fail("Value mismatch")

/datum/unit_test/vector_isnull/start()
	var/vector/V = new /vector(0,0.0)
	if(!V.is_null())
		fail("Vector not null")

/datum/unit_test/vector_isint/start()
	var/vector/V = new /vector(5416,115)
	if(!V.is_integer())
		fail("Vector not int, should be int")

	V = new /vector(5416.044,115)
	if(V.is_integer())
		fail("Vector int, should not be int")

/datum/unit_test/vector_toangle/start()
	var/vector/V = new /vector(1,1)
	var/angle = V.toAngle()
	if(angle != 45)
		fail("Angle #1 ("+num2text(angle)+") incorrect")

	V = new /vector(-1,1)
	angle = V.toAngle()
	if(angle != 315)
		fail("Angle #2 ("+num2text(angle)+") incorrect")

/datum/unit_test/vector_mirror/start()
	var/vector/V = new /vector(1,-1)
	var/vector/N = new /vector(0,1)
	var/vector/M = new /vector(1,1)
	var/vector/R = V.mirrorWithNormal(N)
	if(!R.equals(M))
		fail("Mirror #2 incorrect "+R.toString())

/datum/unit_test/vector_dot/start()
	var/vector/V1 = new /vector(4,-1)
	var/vector/V2 = new /vector(1,1)
	var/d = V1.dot(V2)
	if(d != 3)
		fail("Dot product #1 ("+num2text(d)+") incorrect")

	V1 = new /vector(0,2)
	V2 = new /vector(1,1)
	d = V1.dot(V2)
	if(d != 2)
		fail("Dot product #2 ("+num2text(d)+") incorrect")
