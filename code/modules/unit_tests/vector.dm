/datum/unit_test/vector_duplicate/start()
	var/vector/V
	var/vector/D
	for(var/i in range(100))
		V = vector(i, i*2)
		D = copyVector(V)
		if(D == V)
			fail("Reference copied")

		if(D.x != V.x || D.y != V.y)
			fail("Value mismatch")

/datum/unit_test/vector_isnull/start()
	var/vector/V = vector(0,0.0)
	if(!V.isNullVector())
		fail("Vector not null")

/datum/unit_test/vector_isint/start()
	var/vector/V = vector(5416,115)
	if(!V.isIntegerVector())
		fail("Vector not int, should be int")

	V = vector(5416.044,115)
	if(V.isIntegerVector())
		fail("Vector int, should not be int")

/datum/unit_test/vector_toangle/start()
	var/vector/V = vector(1,1)
	var/angle = vectorToAngle(V)
	if(angle != 45)
		fail("Angle #1 ("+num2text(angle)+") incorrect")

	V = vector(-1,1)
	angle = vectorToAngle(V)
	if(angle != 315)
		fail("Angle #2 ("+num2text(angle)+") incorrect")

/datum/unit_test/vector_mirror/start()
	var/vector/V = vector(1,-1)
	var/vector/N = vector(0,1)
	var/vector/M = vector(1,1)
	var/vector/R = mirrorWithNormal(V,N)
	if(!vector_equals(R,M))
		fail("Mirror #2 incorrect "+R.toString())

/datum/unit_test/vector_dot/start()
	var/vector/V1 = vector(4,-1)
	var/vector/V2 = vector(1,1)
	var/d = V1.Dot(V2)
	if(d != 3)
		fail("Dot product #1 ("+num2text(d)+") incorrect")

	V1 = vector(0,2)
	V2 = vector(1,1)
	d = V1.Dot(V2)
	if(d != 2)
		fail("Dot product #2 ("+num2text(d)+") incorrect")
