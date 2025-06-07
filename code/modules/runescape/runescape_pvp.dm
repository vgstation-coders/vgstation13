
var/list/non_standard_maint_areas = list(
	/area/construction/qmaint,
	/area/vox_trading_post/maintroom,
	/area/vox_trading_post/solars,
	/area/research_outpost/maint,
	/area/research_outpost/maintstore2
	)

/datum/runescape_skull_data
	var/holder_ref
	var/last_fight
	var/skull_timer = 20 MINUTES
	var/image/skull
	var/list/victim_refs = list()
	var/name = "skull data"

/datum/runescape_skull_data/New(var/mob/M,var/first_victim)
	if (!ticker)
		return
	if (!M)
		qdel(src)
		return
	holder_ref = "\ref[M]"
	name = M.name//for easier VV debugging
	ticker.runescape_skulls[holder_ref] = src
	skull = new/image/hud('icons/mob/hud.dmi',M,"runescape_skull")
	skull.plane = ABOVE_LIGHTING_PLANE
	skull.layer = NARSIE_GLOW
	skull.pixel_y = 20 * PIXEL_MULTIPLIER
	skull.appearance_flags = RESET_COLOR|RESET_ALPHA|TILE_BOUND|RESET_TRANSFORM
	just_fought(first_victim)

/datum/runescape_skull_data/Destroy()
	for (var/client/C in clients)//just to be sure
		C.images -= skull
	skull = null
	..()

/datum/runescape_skull_data/proc/just_fought(var/victim_ref)
	last_fight = world.time
	if (victim_ref)
		victim_refs[victim_ref] = world.time
	process()

/datum/runescape_skull_data/proc/process()
	for (var/client/C in clients)
		C.images -= skull
	var/mob/holder = locate(holder_ref)
	if (!holder || holder.gcDestroyed)
		ticker.runescape_skulls -= holder_ref
		qdel(src)
		return
	if (world.time >= last_fight + skull_timer)
		ticker.runescape_skulls -= holder_ref
	else
		for (var/client/C in clients)
			C.images += skull


/mob/proc/assaulted_by(var/mob/M,var/weak_assault=FALSE)
	//might be nice to move the LAssailant stuff here at some point

	if (M == src)
		return


	if (!ticker)
		return
	if ("\ref[src]" in ticker.runescape_skulls)
		var/datum/runescape_skull_data/the_data = ticker.runescape_skulls["\ref[src]"]
		if ("\ref[M]" in the_data.victim_refs)
			if (the_data.victim_refs["\ref[M]"] + 5 MINUTES > world.time)//if we attacked M in the last 5 minutes, do not skull M
				return
	M.just_fought(src,weak_assault)

/mob/proc/just_fought(var/mob/M,var/weak_assault=FALSE)
	if (!runescape_skull_display || weak_assault)
		return
	if (!ticker)
		return

	if ("\ref[src]" in ticker.runescape_skulls)
		var/datum/runescape_skull_data/the_data = ticker.runescape_skulls["\ref[src]"]
		the_data.just_fought("\ref[M]")
	else
		new /datum/runescape_skull_data(src,"\ref[M]")
