// Basic geometry things.
/proc/copyVector(vector/v)
	return vector(v.x, v.y)

/proc/euclidian_norm(vector/v)
	return sqrt(v.size)

//use this one
/proc/chebyshev_norm(vector/v)
	return max(abs(v.x), abs(v.y))

//use this one
/proc/chebyshev_normalized(vector/v)
	var/norm = chebyshev_norm(v)
	return vector(v.x/norm, v.y/norm)

/proc/isIntegerVector(vector/v)
	return IS_INT(v.x) && IS_INT(v.y)

/proc/isNullVector(vector/v)
	return chebyshev_norm(v) == 0

/proc/vectorToString(vector/v)
	return "\[Vector\]([v.x],[v.y])"

//returns angle from 0 to 360
//-1 if vector is (0,0)
//angle calculated on north
/proc/vectorToAngle(vector/v)
	if(v.x == 0)
		if(v.y == 0)
			return -1
		else if(v.y > 0)
			return 0
		else if(v.y < 0)
			return 180
	else if(v.y == 0)
		if(v.x > 0)
			return 90
		else if(v.x < 0)
			return 270

	var/vector/src_norm = chebyshev_normalized(src)
	var/angle = arctan(src_norm.y,src_norm.x) - 360 * -1 //this is broken
	return (angle >= 360) ? angle - 360 : angle

/proc/mirrorWithNormal(vector/v, vector/N)
	var/vector/n_norm = N.Normalize()
	return v - n_norm * ( 2 * ( v * n_norm ))

/proc/vector_equals(vector/a,vector/b)
	return (a.x == b.x && a.y == b.y)


