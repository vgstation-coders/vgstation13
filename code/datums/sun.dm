var/global/datum/sun/sun

/datum/sun
	var/name
	var/angle
	var/dx
	var/dy
	var/list/solars // For debugging purposes, references solars_list at the constructor.

	// Replacement for var/counter to force the sun to move every X IC minutes.
	// To prevent excess server load the server only updates the sun's sight lines by minute(s).
	// 300 is 30 seconds.
	var/updatePer = 600

	var/nextTime
	var/lastAngle = 0
	var/rotationRate = 1 //A pretty average way of setting up station rotation direction AND absolute speed
	var/heat //Temperature you are exposed to when in space. Not technically correct, but current temperature model doesn't use energy exposure, only temperature exposure.
	var/severity //How nasty the star is (Possibility out of 100 you'll be exposed to radiation, how severe the radiation exposure will be)

/datum/sun/New()

	solars = solars_list
	nextTime = updatePer

	rotationRate = rand(850, 1150) / 1000 //Slight deviation, no more than 15 %, budget orbital stabilization system
	if(prob(50))
		rotationRate = -rotationRate

	heat = rand(250, 3000)
	severity = rand(1,100)
	name = pick(star_names)
/*
 * Calculate the sun's position given the time of day.
 */
/datum/sun/proc/calc_position()
	var/time = world.time
	angle = ((rotationRate * time / 100) % 360 + 360) % 360

	if(angle != lastAngle)
		var/obj/machinery/power/solar/panel/tracker/T
		for(T in solars_list)
			if(!T.powernet)
				solars_list.Remove(T)
				continue

			T.set_angle(angle)
		lastAngle = angle

	if(world.time < nextTime)
		return

	nextTime += updatePer

	// Now calculate and cache the (dx,dy) increments for line drawing.
	var/si = sin(angle)
	var/co = cos(angle)

	if(!co)
		dx = 0
		dy = si
	else if (abs(si) < abs(co))
		dx = si / abs(co)
		dy = co / abs(co)
	else
		dx = si / abs(si)
		dy = co / abs(si)

	var/obj/machinery/power/solar/panel/S

	for(S in solars_list)
		if(!S.powernet)
			solars_list.Remove(S)

		if(S.control)
			occlusion(S)

//For a solar panel, trace towards sun to see if we're in shadow.

/datum/sun/proc/occlusion(const/obj/machinery/power/solar/panel/S)
	S.obscured = is_in_sun(get_turf(S), 256) //If hit the edge or stepped 256 times, not obscured.
	S.update_solar_exposure()


/proc/is_in_sun(var/turf/init_turf, var/max_check = 20)
	var/ax = init_turf.x
	var/ay = init_turf.y

	for(var/i = 1 to max_check)
		ax += sun.dx
		ay += sun.dy

		var/turf/T = locate( round(ax,0.5),round(ay,0.5),init_turf.z)

		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)
			break

		if(T.density)
			return 0

	return 1