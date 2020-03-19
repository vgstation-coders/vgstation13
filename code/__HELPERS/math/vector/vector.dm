// Basic geometry things.
/vector/
	var/x = 0
	var/y = 0

/vector/New(var/x, var/y)
	src.x = x
	src.y = y

/vector/proc/duplicate()
	return new /vector(x, y)

/vector/proc/euclidian_norm()
	return sqrt(x*x + y*y)

/vector/proc/squared_norm()
	return x*x + y*y

/vector/proc/normalize()
	var/norm = euclidian_norm()
	x = x/norm
	y = y/norm
	return src

/vector/proc/chebyshev_norm()
	return max(abs(x), abs(y))

/vector/proc/chebyshev_normalize()
	var/norm = chebyshev_norm()
	x = x/norm
	y = y/norm
	return src

/vector/proc/is_integer()
	return IS_INT(x) && IS_INT(y)
