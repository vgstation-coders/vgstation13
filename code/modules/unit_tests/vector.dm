/datum/unit_test/vector_duplicate/start()
	var/_vector/V
	var/_vector/D
	for(var/i in range(100))
		V = new /_vector(i, i*2)
		D = V.duplicate()
		if(D == V)
			fail("Reference copied")

		if(D.x != V.x || D.y != V.y)
			fail("Value mismatch")

/datum/unit_test/vector_isnull/start()
	var/_vector/V = new /_vector(0,0.0)
	if(!V.is_null())
		fail("Vector not null")

/datum/unit_test/vector_isint/start()
	var/_vector/V = new /_vector(5416,115)
	if(!V.is_integer())
		fail("Vector not int, should be int")

	V = new /_vector(5416.044,115)
	if(V.is_integer())
		fail("Vector int, should not be int")

/datum/unit_test/vector_toangle/start()
	var/_vector/V = new /_vector(1,1)
	var/angle = V.toAngle()
	if(angle != 45)
		fail("Angle #1 ("+num2text(angle)+") incorrect")

	V = new /_vector(-1,1)
	angle = V.toAngle()
	if(angle != 315)
		fail("Angle #2 ("+num2text(angle)+") incorrect")

/datum/unit_test/vector_mirror/start()
	var/_vector/V = new /_vector(1,-1)
	var/_vector/N = new /_vector(0,1)
	var/_vector/M = new /_vector(1,1)
	var/_vector/R = V.mirrorWithNormal(N)
	if(!R.equals(M))
		fail("Mirror #2 incorrect "+R.toString())

/datum/unit_test/vector_dot/start()
	var/_vector/V1 = new /_vector(4,-1)
	var/_vector/V2 = new /_vector(1,1)
	var/d = V1.dot(V2)
	if(d != 3)
		fail("Dot product #1 ("+num2text(d)+") incorrect")

	V1 = new /_vector(0,2)
	V2 = new /_vector(1,1)
	d = V1.dot(V2)
	if(d != 2)
		fail("Dot product #2 ("+num2text(d)+") incorrect")
