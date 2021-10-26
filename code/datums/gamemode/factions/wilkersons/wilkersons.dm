/datum/faction/wilkersons
	name = WILKERSON
	ID = WILKERSON
	default_admin_voice = "Stevie"
	admin_voice_style = ""
	logo_state = "malcolm-logo"
	hud_icons = list("malcolm-logo")
	stat_datum = /datum/stat/faction/wilkerson
	var/turf/theMiddle = null
	var/mob/living/malcolm = null
	var/list/halDirs = list(SOUTHWEST, WEST, NORTHWEST)
	var/list/loisDirs = list(SOUTHEAST, EAST, NORTHEAST)

/datum/faction/wilkersons/OnPostSetup()
	..()
	manifestMiddle()
	for(var/datum/role/wilkerson/malcolm/M in members)
		malcolm = M

/datum/faction/wilkersons/proc/manifestMiddle()
	theMiddle = get_turf(locate(map.center_x, map.center_y, 1))
	malcolm.theMiddle = theMiddle
	for(var/turf/M in orange(2, theMiddle)
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
		new /obj/effect/theMiddle/hal(locate(halX, middleX, 1))
		new /obj/effect/theMiddle/lois(locate(loisX, middleX, 1))
		for(var/iy = 5, iy <= 100, iy += 5)
			new /obj/effect/theMiddle/hal(locate(halX, middleY - iy, 1))
			new /obj/effect/theMiddle/hal(locate(halX, middleY + iy, 1))
			new /obj/effect/theMiddle/lois(locate(loisX, middleY - iy, 1))
			new /obj/effect/theMiddle/lois(locate(loisX, middleY + iy, 1))
			CHECK_TICK	//I can only assume this proc is disgustingly laggy

/obj/effect/theMiddle
	name = "The Middle"
	icon_state = "theMiddle"
	anchored = TRUE
	var/lightType = "#8C489F"

/obj/effect/theMiddle/New()
	..()
	set_light(5, 3, lightType)

/obj/effect/theMiddle/hal
	name = "Hal Fragment"
	icon_state = "halFrag"
	lightType = "#990033"

/obj/effect/theMiddle/lois
	name = "Lois Fragment"
	icon_state = "loisFrag"
	lightType = "#003366"


/datum/faction/wilkersons/proc/inTheMiddle()
	stat_datum.malcolmPoints++

/datum/faction/wilkersons/proc/notInTheMiddle()
	var/malcDir = get_dir(theMiddle, malcolm)	//No one gets points is Malcolm is north or south. It is in the middle but not IN the middle
	if(malcDir in halDirs)
		stat_datum.halPoints++
	else if(malcDir in loisDirs)
		stat_datum.loisPoints++
