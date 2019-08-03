/proc/Get_Angle(atom/movable/start,atom/movable/end)//For beams.
	if(!start || !end)
		return 0
	var/dy
	var/dx
	dy=(WORLD_ICON_SIZE*end.y+end.pixel_y)-(WORLD_ICON_SIZE*start.y+start.pixel_y)
	dx=(WORLD_ICON_SIZE*end.x+end.pixel_x)-(WORLD_ICON_SIZE*start.x+start.pixel_x)
	if(!dy)
		return (dx>=0)?90:270
	.=arctan(dx/dy)
	if(dy<0)
		.+=180
	else if(dx<0)
		.+=360


/proc/get_angle(atom/a, atom/b)
	return Atan2(b.y - a.y, b.x - a.x)


/proc/adjustAngle(angle)
	angle = round(angle) + 45
	if(angle > 180)
		angle -= 180
	else
		angle += 180
	if(!angle)
		angle = 1
	/*if(angle < 0)
		//angle = (round(abs(get_angle(A, user))) + 45) - 90
		angle = round(angle) + 45 + 180
	else
		angle = round(angle) + 45*/
	return angle


proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)


/proc/get_dir_cardinal(var/atom/T1,var/atom/T2)
	if(!T1 || !T2)
		return null

	var/direc = get_dir(T1,T2)

	if(direc in cardinal)
		return direc

	switch(direc)
		if(NORTHEAST)
			if((T2.x - T1.x) > (T2.y - T1.y))
				return EAST
			else
				return NORTH
		if(SOUTHEAST)
			if((T2.x - T1.x) > ((T2.y - T1.y)*-1))
				return EAST
			else
				return SOUTH
		if(NORTHWEST)
			if(((T2.x - T1.x)*-1) > (T2.y - T1.y))
				return WEST
			else
				return NORTH
		if(SOUTHWEST)
			if((T2.x - T1.x) > (T2.y - T1.y))
				return WEST
			else
				return SOUTH
		else
			return null


/proc/reverse_direction(var/dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(NORTHEAST)
			return SOUTHWEST
		if(EAST)
			return WEST
		if(SOUTHEAST)
			return NORTHWEST
		if(SOUTH)
			return NORTH
		if(SOUTHWEST)
			return NORTHEAST
		if(WEST)
			return EAST
		if(NORTHWEST)
			return SOUTHEAST


/proc/counter_clockwise_perpendicular_direction(var/dir)
	switch(dir)
		if(NORTH)
			return EAST
		if(SOUTH)
			return WEST
		if(EAST)
			return SOUTH
		if(WEST)
			return NORTH
		if(NORTHEAST)
			return NORTHWEST
		if(SOUTHEAST)
			return NORTHEAST
		if(SOUTHWEST)
			return SOUTHEAST
		if(NORTHWEST)
			return SOUTHWEST

/proc/widen_dir(var/dir, var/angle = 45)
	var/list/dirs = list()
	dirs += dir

	angle = round(angle, 45)

	if(angle <= 0)
		return dirs
	if(angle >= 180)
		return alldirs

	var/steps = angle/45
	while(steps)
		dirs += turn(dir,  45*steps)
		dirs += turn(dir, -45*steps)
		steps--
	return dirs

// smoothing dirs - now you can tell the difference between a tile being surrounded by north and west and a tile being surrounded by northwest.
// used for 3x3/diagonal smoothers - not suitable for cardinal smoothing.
// because for some reason it seems that north and south and east and west byond variables are actually capped to 15 when adding other flags, we need to redefine those too.

#define SMOOTHING_NORTH 	1
#define SMOOTHING_SOUTH		2
#define SMOOTHING_EAST		4
#define SMOOTHING_WEST		8
#define SMOOTHING_NORTHWEST 16
#define SMOOTHING_NORTHEAST 32
#define SMOOTHING_SOUTHEAST 64
#define SMOOTHING_SOUTHWEST 128


#define SMOOTHING_ALLNORTH SMOOTHING_NORTHWEST|SMOOTHING_NORTH|SMOOTHING_NORTHEAST // 16 + 1 + 32 = 49
#define SMOOTHING_ALLEAST SMOOTHING_SOUTHEAST|SMOOTHING_EAST|SMOOTHING_NORTHEAST // 64 + 4 + 32 = 100
#define SMOOTHING_ALLWEST SMOOTHING_SOUTHWEST|SMOOTHING_WEST|SMOOTHING_NORTHWEST // 128 + 8 + 16 = 152
#define SMOOTHING_ALLSOUTH SMOOTHING_SOUTHWEST|SMOOTHING_SOUTH|SMOOTHING_SOUTHEAST // 128 + 2 + 64 = 194
#define SMOOTHING_ALLDIRS 255


// L curves - x is our object, # is smoothable, . is not
/*

###
#X.  northwest - SMOOTHING_ALLNORTH|SMOOTHING_ALLWEST
#..


###
.X#  northeast - SMOOTHING_ALLNORTH|SMOOTHING_ALLEAST
..#


#..
#X.  southwest - SMOOTHING_ALLSOUTH|SMOOTHING_ALLWEST
###

..#
.X#  southeast SMOOTHING_ALLSOUTH|SMOOTHING_ALLEAST
###

*/

#define SMOOTHING_L_CURVE_NORTHWEST SMOOTHING_ALLNORTH|SMOOTHING_ALLWEST
#define SMOOTHING_L_CURVE_NORTHEAST SMOOTHING_ALLNORTH|SMOOTHING_ALLEAST
#define SMOOTHING_L_CURVE_SOUTHWEST SMOOTHING_ALLSOUTH|SMOOTHING_ALLWEST
#define SMOOTHING_L_CURVE_SOUTHEAST SMOOTHING_ALLSOUTH|SMOOTHING_ALLEAST
#define SMOOTHING_L_CURVES SMOOTHING_L_CURVE_NORTHWEST,SMOOTHING_L_CURVE_NORTHEAST,SMOOTHING_L_CURVE_SOUTHWEST,SMOOTHING_L_CURVE_SOUTHEAST

/proc/dir_to_smoothingdir(var/dir)
	switch(dir)
		if(NORTHEAST)
			return SMOOTHING_NORTHEAST
		if(SOUTHEAST)
			return SMOOTHING_SOUTHEAST
		if(SOUTHWEST)
			return SMOOTHING_SOUTHWEST
		if(NORTHWEST)
			return SMOOTHING_NORTHWEST
	return dir


/proc/smoothingdir_to_dir(var/dir)
	switch(dir)
		if(SMOOTHING_NORTHEAST,SMOOTHING_L_CURVE_NORTHEAST)
			return NORTHEAST
		if(SMOOTHING_SOUTHEAST,SMOOTHING_L_CURVE_SOUTHEAST)
			return SOUTHEAST
		if(SMOOTHING_SOUTHWEST,SMOOTHING_L_CURVE_SOUTHWEST)
			return SOUTHWEST
		if(SMOOTHING_NORTHWEST,SMOOTHING_L_CURVE_NORTHWEST)
			return NORTHWEST
		if(SMOOTHING_NORTH)
			return NORTH
		if(SMOOTHING_SOUTH)
			return SOUTH
		if(SMOOTHING_EAST)
			return EAST
		if(SMOOTHING_WEST)
			return WEST
	return dir

/proc/dir2arrow(var/dir) // ↑ ↓ → ← ↖ ↘ ↙ ↗
	switch(dir)
		if(NORTH)
			return "&uarr;"
		if(SOUTH)
			return "&darr;"
		if(EAST)
			return "&rarr;"
		if(WEST)
			return "&larr;"
		if(NORTHEAST)
			return "&#8599;"
		if(SOUTHEAST)
			return "&#8600;"
		if(SOUTHWEST)
			return "&#8601;"
		if(NORTHWEST)
			return "&#8598;"
