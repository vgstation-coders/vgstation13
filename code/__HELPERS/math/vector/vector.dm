var/list/vector/cardinal_vectors = list(
	NORTH = new /vector(0,1), //NORTH
	SOUTH = new /vector(0,-1), //SOUTH
	EAST = new /vector(1,0), //EAST
	WEST = new /vector(-1,0) //WEST
)
var/list/vector/diagonal_vectors = list(
	NORTHEAST = new /vector(1,1), //NORTHEAST
	NORTHWEST = new /vector(-1,1), //NORTHWEST
	SOUTHEAST = new /vector(1,-1), //SOUTHEAST
	SOUTHWEST = new /vector(-1,-1) //SOUTHWEST
)
var/list/vector/all_vectors = list(
	NORTH = new /vector(0,1), //NORTH
	SOUTH = new /vector(0,-1), //SOUTH
	EAST = new /vector(1,0), //EAST
	WEST = new /vector(-1,0), //WEST
	NORTHEAST = new /vector(1,1), //NORTHEAST
	NORTHWEST = new /vector(-1,1), //NORTHWEST
	SOUTHEAST = new /vector(1,-1), //SOUTHEAST
	SOUTHWEST = new /vector(-1,-1) //SOUTHWEST
)

// Basic geometry things.
/vector
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

/vector/proc/normalized()
	var/norm = euclidian_norm()
	return new /vector(x/norm, y/norm)

/vector/proc/floored()
	return new /vector(Floor(x), Floor(y))

//use this one
/vector/proc/chebyshev_norm()
	return max(abs(x), abs(y))

//use this one
/vector/proc/chebyshev_normalized()
	var/norm = chebyshev_norm()
	return new /vector(x/norm, y/norm)

/vector/proc/is_integer()
	return IS_INT(x) && IS_INT(y)

/vector/proc/is_null()
	return chebyshev_norm() == 0

/vector/proc/toString()
	return "\[Vector\]([x],[y])"

//returns angle from 0 to 360
//-1 if vector is (0,0)
//angle calculated on north
/vector/proc/toAngle()
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

	var/vector/src_norm = src.chebyshev_normalized()
	var/angle = arctan(src_norm.y,src_norm.x) - 360 * -1 //this is broken
	return (angle >= 360) ? angle - 360 : angle

/vector/proc/dot(var/vector/B)
	return src.x * B.x + src.y * B.y

/vector/proc/angleBetween(var/vector/B)
	if(src.is_null() || B.is_null())
		return 0
	var/vector/src_norm = src.chebyshev_normalized()
	var/vector/b_norm = B.chebyshev_normalized()
	if(src_norm.equals(b_norm))
		return 0
	return arccos((src_norm * b_norm)/(src_norm.chebyshev_norm()*b_norm.chebyshev_norm()))

/vector/proc/mirrorWithNormal(var/vector/N)
	var/vector/n_norm = N.normalized()
	return src - n_norm * ( 2 * ( src * n_norm ))

//operator overloading
/vector/proc/operator+(var/vector/B)
	if(isnum(B))
		return new /vector(x + B, y + B)
	return new /vector(x + B.x, y + B.y)

/*/vector/proc/operator+=(var/vector/B)
	if(isnum(B))
		x += B
		y += B
	x += B.x
	y += B.y*/

/vector/proc/operator-(var/vector/B)
	if(isnum(B))
		return new /vector(x - B, y - B)
	return new /vector(x - B.x, y - B.y)

/*/vector/proc/operator-=(var/vector/B)
	if(isnum(B))
		x -= B
		y -= B
	x -= B.x
	y -= B.y*/

/vector/proc/operator*(var/mult)
	if(istype(mult, /vector))
		return dot(mult)
	return new /vector(x * mult, y * mult)

/*/vector/proc/operator*=(var/mult)
	x *= mult
	y *= mult*/

/vector/proc/equals(var/vector/vectorB)
	return (x == vectorB.x && y == vectorB.y)


