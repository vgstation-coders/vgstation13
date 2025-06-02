// Basic geometry things.
/_vector
	var/x = 0
	var/y = 0

/_vector/New(var/x, var/y)
	src.x = x
	src.y = y

/_vector/proc/duplicate()
	return new /_vector(x, y)

/_vector/proc/euclidian_norm()
	return sqrt(x*x + y*y)

/_vector/proc/squared_norm()
	return x*x + y*y

/_vector/proc/normalized()
	var/norm = euclidian_norm()
	return new /_vector(x/norm, y/norm)

/_vector/proc/floored()
	return new /_vector(Floor(x), Floor(y))

//use this one
/_vector/proc/chebyshev_norm()
	return max(abs(x), abs(y))

//use this one
/_vector/proc/chebyshev_normalized()
	var/norm = chebyshev_norm()
	return new /_vector(x/norm, y/norm)

/_vector/proc/is_integer()
	return IS_INT(x) && IS_INT(y)

/_vector/proc/is_null()
	return chebyshev_norm() == 0

/_vector/proc/toString()
	return "\[Vector\]([x],[y])"

//returns angle from 0 to 360
//-1 if vector is (0,0)
//angle calculated on north
/_vector/proc/toAngle()
	if(x == 0)
		if(y == 0)
			return -1
		else if(y > 0)
			return 0
		else if(y < 0)
			return 180
	else if(y == 0)
		if(x > 0)
			return 90
		else if(x < 0)
			return 270

	var/_vector/src_norm = src.chebyshev_normalized()
	var/angle = arctan(src_norm.y,src_norm.x) - 360 * -1 //this is broken
	return (angle >= 360) ? angle - 360 : angle

/_vector/proc/dot(var/_vector/B)
	return src.x * B.x + src.y * B.y

/_vector/proc/mirrorWithNormal(var/_vector/N)
	var/_vector/n_norm = N.normalized()
	return src - n_norm * ( 2 * ( src * n_norm ))

//operator overloading
/_vector/proc/operator+(var/_vector/B)
	return new /_vector(x + B.x, y + B.y)

/_vector/proc/operator-(var/_vector/B)
	return new /_vector(x - B.x, y - B.y)

/_vector/proc/operator*(var/mult)
	if(istype(mult, /_vector))
		return dot(mult)
	return new /_vector(x * mult, y * mult)

/_vector/proc/equals(var/_vector/vectorB)
	return (x == vectorB.x && y == vectorB.y)


