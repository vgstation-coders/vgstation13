/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	unacidable = 1
	w_type=NOT_RECYCLABLE

/obj/effect/landmark/New()
	. = ..()
	tag = text("landmark*[]", name)
	invisibility = 101

	switch(name)			//some of these are probably obsolete
		if("shuttle")
			shuttle_z = z
			return qdel(src)

		if("airtunnel_stop")
			airtunnel_stop = x

		if("airtunnel_start")
			airtunnel_start = x

		if("airtunnel_bottom")
			airtunnel_bottom = y

		if("monkey")
			monkeystart += loc
			return qdel(src)
		if("start")
			newplayer_start += loc
			return qdel(src)

		if("wizard")
			wizardstart += loc
			return qdel(src)

		if("JoinLate")
			latejoin += loc
			return qdel(src)
		if("AssetJoinLate")
			assistant_latejoin += loc
			return qdel(src)

		//prisoners
		if("prisonwarp")
			prisonwarp += loc
			return qdel(src)
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
			return qdel(src)

		if("blobstart")
			blobstart += loc
			return qdel(src)

		if("xeno_spawn")
			xeno_spawn += loc
			return qdel(src)

		if("endgame_exit")
			endgame_safespawns += loc
			return qdel(src)
		if("bluespacerift")
			endgame_exits += loc
			return qdel(src)
		if("centcom_mail")
			centcom_mail += loc
			return qdel(src)

	landmarks_list += src
	return 1

/obj/effect/landmark/Destroy()
	landmarks_list -= src
	..()

/obj/effect/landmark/centcom_mail
	name = "centcom_mail"

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/effect/landmark/start/New()
	..()
	tag = "start*[name]"
	invisibility = 101

	return 1
