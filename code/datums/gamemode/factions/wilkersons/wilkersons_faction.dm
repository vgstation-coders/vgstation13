/datum/faction/wilkersons
	name = WILKERSON
	ID = WILKERSON
	default_admin_voice = "Stevie"
	admin_voice_style = ""
	logo_state = "malcolm-logo"
	hud_icons = list("malcolm-logo")
	stat_datum = /datum/stat/faction/wilkerson
	var/list/halBeacons = list()
	var/turf/theMiddle = null
	var/list/loisBeacons = list()
	var/list/halDirs = list(SOUTHWEST, WEST, NORTHWEST)
	var/mob/living/carbon/monkey/malcolm/malcolm = null
	var/list/loisDirs = list(SOUTHEAST, EAST, NORTHEAST)

/datum/faction/wilkersons/OnPostSetup()
	..()
	manifestMiddle()
	for(var/datum/role/wilkerson/malcolm/M in members)
		if(istype(M.host, /mob/living/carbon/monkey/malcolm))
			malcolm = M.host

/datum/faction/wilkersons/proc/manifestMiddle()
	theMiddle = get_turf(locate(map.center_x, map.center_y, 1))
	malcolm.theMiddle = theMiddle
	for(var/turf/M in orange(2, theMiddle))
		if(M.Adjacent(theMiddle))
			continue
		new /obj/effect/theMiddle(M)
	handleWilkersonColours()

/datum/faction/wilkersons/proc/handleWilkersonColours()
	var/middleX = theMiddle.x
	var/middleY = theMiddle.y
	for(var/ix = 5, ix <= 100, ix += 5)	//Turns a 100x100 tile radius to the left and right of the middle into coloured zones by placing lit markers on every 5 tiles. Also ambient.
		var/halX = middleX - ix
		var/loisX = middleX + ix
		var/turf/halT = locate(halX, middleX, 1)
		var/turf/loisT = locate(loisX, middleX, 1)
		if(!istype(halT, /turf/space))
			halBeacons.Add(new /obj/effect/theMiddle/hal(halT))
		if(!istype(loisT, /turf/space))
			loisBeacons.Add(new /obj/effect/theMiddle/lois(loisT))
		for(var/iy = 5, iy <= 100, iy += 5)
			halT = locate(halX, middleY - iy, 1)
			if(!istype(halT, /turf/space))
				halBeacons.Add(new /obj/effect/theMiddle/hal(halT))
			halT = locate(halX, middleY + iy, 1)
			if(!istype(halT, /turf/space))
				halBeacons.Add(new /obj/effect/theMiddle/hal(halT))
			loisT = locate(loisX, middleY - iy, 1)
			if(!istype(loisT, /turf/space))
				loisBeacons.Add(new /obj/effect/theMiddle/lois(loisT))
			loisT =	locate(loisX, middleY + iy, 1)
			if(!istype(loisT, /turf/space))
				loisBeacons.Add(new /obj/effect/theMiddle/lois(loisT))
			CHECK_TICK	//I can only assume this proc is disgustingly laggy

/datum/faction/wilkersons/proc/inTheMiddle()
	stat_datum.malcolmPoints++

/datum/faction/wilkersons/proc/notInTheMiddle()
	var/malcDir = get_dir(theMiddle, malcolm)	//No one gets points is Malcolm is north or south. It is in the middle but not IN the middle
	if(malcDir in halDirs)
		stat_datum.halPoints++
	else if(malcDir in loisDirs)
		stat_datum.loisPoints++
