var/list/landmarks_list = list() //list of all landmarks
var/list/landmarks_by_type = list() //list of landmark types associated with object lists

//Returns a list of all landmark turfs or an empty list
/proc/get_landmarks(input_type)
	var/list/L = landmarks_by_type[input_type]
	return L ? L : list()

/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	w_type=NOT_RECYCLABLE

	var/destroy_on_creation = TRUE

/obj/effect/landmark/New()
	. = ..()
	tag = text("landmark*[]", name)
	invisibility = 101

	if(!islist(landmarks_by_type[src.type]))
		landmarks_by_type[src.type] = list()

	var/list/L = landmarks_by_type[src.type]
	L.Add(loc)

	switch(name)			//some of these are probably obsolete
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
		//not prisoners
		if("prisonsecuritywarp")
			prisonsecuritywarp += loc
			qdel(src)

		if("blobstart")
			blobstart += loc
			qdel(src)

		if("xeno_spawn")
			xeno_spawn += loc
			qdel(src)

	landmarks_list += src
	return 1

/obj/effect/landmark/Destroy()
	landmarks_list -= src
	..()

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1

/obj/effect/landmark/start/New()
	..()
	tag = "start*[name]"
	invisibility = 101

	return 1

/obj/effect/landmark/bluespacerift
	name = "bluespace rift"
	desc = "In the event of a supermatter cascade, the portal to safety spawns here."

/obj/effect/landmark/endgame_exit
	name = "endgame exit"
	desc = "In the event of a supermatter cascade, the portal to safety teleports you here."

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
