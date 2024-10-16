/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	w_type=NOT_RECYCLABLE

/obj/effect/landmark/New()
	. = ..()
	tag = text("landmark*[]", name)
	invisibility = 101
	landmarks_list += src

	switch(name)			//some of these are probably obsolete
		if("shuttle")
			shuttle_z = z
			qdel(src)

		if("airtunnel_stop")
			airtunnel_stop = x

		if("airtunnel_start")
			airtunnel_start = x

		if("airtunnel_bottom")
			airtunnel_bottom = y

		if("monkey")
			monkeystart += loc
			qdel(src)
		if("start")
			newplayer_start += loc
			qdel(src)

		if("wizard")
			wizardstart += loc
			qdel(src)

		if("JoinLate")
			latejoin += loc
			qdel(src)
		if("AssetJoinLate")
			assistant_latejoin += loc
			qdel(src)

		//prisoners
		if("prisonwarp")
			prisonwarp += loc
			qdel(src)
	//	if("mazewarp")
	//		mazewarp += loc
		if("Holding Facility")
			holdingfacility += loc
		if("tdome1")
			tdome1	+= loc
		if("tdome2")
			tdome2 += loc
		if("tdomeadmin")
			tdomeadmin	+= loc
		if("tdomeobserve")
			tdomeobserve += loc
		if("tdomepacks")
			tdomepacks += loc
		//not prisoners
		if("prisonsecuritywarp")
			prisonsecuritywarp += loc
			qdel(src)

		//the ACTUAL prisoners
		if("Prisoner")
			var/turf/T = get_turf(src)
			var/obj/structure/bed/chair/chair = locate(/obj/structure/bed/chair) in T.contents
			prisonerstart += chair	//the prisoners start buckled in chairs that are on shuttles, add those to the list
			qdel(src)

		if("blobstart")
			blobstart += loc
			qdel(src)

		if("xeno_spawn")
			xeno_spawn += loc
			qdel(src)

		if("endgame_exit")
			endgame_safespawns += loc
			qdel(src)
		if("bluespacerift")
			endgame_exits += loc
			qdel(src)

		if("grinchstart")
			grinchstart += loc

		if("hobostart")
			hobostart += loc

		if("voxstart")
			voxstart += loc

		if("voxlocker")
			voxlocker += loc

		if("ninjastart")
			ninjastart += loc

		if("timeagentstart")
			timeagentstart += loc
	return 1

/obj/effect/landmark/Destroy()
	landmarks_list -= src
	..()

/obj/effect/landmark/start
	name = "start"
	icon_state = "x"

/obj/effect/narration
	name = "narrator"
	icon_state = "megaphone"

	var/msg
	var/play_sound
	var/list/saw_ckeys = list() //List of ckeys which have seen the message

/obj/effect/narration/New()
	..()

	invisibility = 101

/obj/effect/narration/Crossed(mob/living/O)
	if(istype(O))
		if(!saw_ckeys.Find(O.ckey))
			saw_ckeys.Add(O.ckey)

			display(O)

	return ..()

/obj/effect/narration/proc/display(mob/living/L)
	if(msg)
		to_chat(L, msg)

	if(play_sound)
		L << play_sound

/obj/effect/landmark/grinchstart
	name = "grinchstart"

/obj/effect/landmark/xtra_cleanergrenades
	name = "xtra_cleanergrenades"

/obj/effect/landmark/vox_locker
	name = "vox_locker"

/obj/effect/landmark/hobostart
	name = "hobostart"

var/list/map_landmarks = list()

/obj/effect/landmark/map_element
	name = "map_element"
	icon_state = "x3"
	var/maptype = /datum/map_element
	var/rotatable = TRUE

/obj/effect/landmark/map_element/New()
	. = ..()
	map_landmarks += src

/obj/effect/landmark/map_element/Destroy()
	map_landmarks -= src
	. = ..()
	
/obj/effect/landmark/map_element/proc/mapload()
	if(maptype)
		var/datum/map_element/ME = new maptype
		if(istype(ME))
			ME.load(src.x-1,src.y-1,src.z,(rotatable && map.nameShort == "xoq" ? 180 : 0), override_can_rotate = (rotatable && map.nameShort == "xoq"))
	qdel(src)
			
/obj/effect/landmark/map_element/whiteship
	maptype = /datum/map_element/fixedvault/whiteship
    
/obj/effect/landmark/map_element/abandonted_aitele
	maptype = /datum/map_element/fixedvault/abandoned_aitele
    
/obj/effect/landmark/map_element/salvage_shuttle
	maptype = /datum/map_element/fixedvault/salvage_shuttle
	rotatable = FALSE
	
/obj/effect/landmark/map_element/salvage_shuttle_spiders
	maptype = /datum/map_element/fixedvault/salvage_shuttle_spiders
	rotatable = FALSE
	
/obj/effect/landmark/map_element/salvage_shuttle_bears
	maptype = /datum/map_element/fixedvault/salvage_shuttle_bears
	rotatable = FALSE
	
/obj/effect/landmark/map_element/salvage_shuttle_cockroaches
	maptype = /datum/map_element/fixedvault/salvage_shuttle_cockroaches
	rotatable = FALSE
	
/obj/effect/landmark/map_element/salvage_shuttle_skrites
	maptype = /datum/map_element/fixedvault/salvage_shuttle_skrites
	rotatable = FALSE
	
/obj/effect/landmark/map_element/salvage_shuttle_pets
	maptype = /datum/map_element/fixedvault/salvage_shuttle_pets
	rotatable = FALSE
    
/obj/effect/landmark/map_element/deepspaceruin
	maptype = /datum/map_element/fixedvault/deepspaceruin

/obj/effect/landmark/map_element/deepspaceruin_doom
	maptype = /datum/map_element/fixedvault/deepspaceruin_doom

/obj/effect/landmark/map_element/oldstation
	maptype = /datum/map_element/fixedvault/oldstation

/obj/effect/landmark/map_element/misc_derelict_west
	maptype = /datum/map_element/fixedvault/misc_derelict_west

/obj/effect/landmark/map_element/misc_derelict_east
	maptype = /datum/map_element/fixedvault/misc_derelict_east

/obj/effect/landmark/map_element/djsat
	maptype = /datum/map_element/fixedvault/djsat
	rotatable = FALSE
	
/obj/effect/landmark/map_element/djsat_notail
	maptype = /datum/map_element/fixedvault/djsat_notail
	rotatable = FALSE

/obj/effect/landmark/map_element/derelict_tele
	maptype = /datum/map_element/fixedvault/derelict_tele
	
/obj/effect/landmark/map_element/spacegym
	maptype = /datum/map_element/fixedvault/spacegym
	
/obj/effect/landmark/map_element/medship
	maptype = /datum/map_element/fixedvault/medship
	rotatable = FALSE

/obj/effect/landmark/map_element/spacetomb
	maptype = /datum/map_element/fixedvault/spacetomb

/obj/effect/landmark/map_element/clownroid
	maptype = /datum/map_element/fixedvault/clownroid

/obj/effect/landmark/map_element/deepspaceroid
	maptype = /datum/map_element/fixedvault/deepspaceroid