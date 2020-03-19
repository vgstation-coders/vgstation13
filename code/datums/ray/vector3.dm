/vector3
	var/x = 0
	var/y = 0
	var/z = 0

/vector3/New(var/x, var/y, var/z)
	src.x = x
	src.y = y
	src.z = z

/vector3/proc/duplicate()
	return new /vector3(x, y, z)

/vector3/proc/euclidian_norm()
	return sqrt(x*x + y*y + z*z)

/vector3/proc/normalized()
	var/norm = euclidian_norm()
	return new /vector3(x/norm, y/norm, z/norm)

/vector3/proc/floored()
	return new /vector3(Floor(x), Floor(y), Floor(z))

/vector3/proc/plus(var/vector3/vectorB)
	return new /vector3(x + vectorB.x, y + vectorB.y, z + vectorB.z)

/vector3/proc/minus(var/vector3/vectorB)
	return new /vector3(x - vectorB.x, y - vectorB.y, z - vectorB.z)

/vector3/proc/times(var/mult)
	return new /vector3(x * mult, y * mult, z * mult)

/vector3/proc/equals(var/vector3/vectorB)
	return (x == vectorB.x && y == vectorB.y && z == vectorB.z)

/vector3/proc/toString()
	return "\[Vector3\]([x],[y],[z])"

/proc/atom2vector3(var/atom/A)
	return new /vector3(A.x, A.y, A.z)

/proc/atoms2vector3(var/atom/A, var/atom/B)
	return new /vector3((B.x - A.x), (B.y - A.y), (B.z - A.z)) // Vector from A -> B
