var/list/vector/cardinal_vectors = list(
	new /vector(0,1), //NORTH
	new /vector(0,-1), //SOUTH
	new /vector(1,0), //EAST
	new /vector(-1,0) //WEST
)
var/list/vector/diagonal_vectors = list(
	new /vector(1,1), //NORTHEAST
	new /vector(-1,1), //NORTHWEST
	new /vector(1,-1), //SOUTHEAST
	new /vector(-1,-1) //SOUTHWEST
)
var/list/vector/all_vectors = list(
	new /vector(0,1), //NORTH
	new /vector(0,-1), //SOUTH
	new /vector(1,0), //EAST
	new /vector(-1,0), //WEST
	new /vector(1,1), //NORTHEAST
	new /vector(-1,1), //NORTHWEST
	new /vector(1,-1), //SOUTHEAST
	new /vector(-1,-1) //SOUTHWEST
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
	return chebyshev_norm() != 0

/vector/proc/toString()
	return "\[Vector\]([x],[y])"

//returns angle from 0 to 360
//-1 if vector is (0,0)
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

	return arctan(y/x)

/vector/proc/dot(var/vector/B)
	return src.x * B.x + src.y * B.y

/vector/proc/angleBetween(var/vector/B)
	if(src.is_null() || B.is_null()) return FALSE
	return arccos((src.dot(B))/(src.chebyshev_norm()*B.chebyshev_norm()))

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
	return new /vector(x * mult, y * mult)

/*/vector/proc/operator*=(var/mult)
	x *= mult
	y *= mult*/

/vector/proc/equals(var/vector/vectorB)
	return (x == vectorB.x && y == vectorB.y)


