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
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/effect/landmark/start/New()
	..()
	invisibility = 101

	return 1

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
