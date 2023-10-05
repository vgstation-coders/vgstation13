/spell/area_teleport
	name = "Teleport"
	desc = "This spell teleports you to a type of area of your selection."
	abbreviation = "TP"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY

	school = "abjuration"
	spell_flags = NEEDSCLOTHES
	autocast_flags = AUTOCAST_NOTARGET
	invocation = "SCYAR NILA"
	invocation_type = SpI_SHOUT

	charge_max = 45 SECONDS
	cooldown_min = 5 SECONDS
	cooldown_reduc = 10 SECONDS

	smoke_spread = 1
	smoke_amt = 5

	var/randomise_selection = 0 //if it lets the usr choose the teleport loc or picks it from the list
	var/invocation_area = 1 //if the invocation appends the selected area

	cast_sound = 'sound/effects/teleport.ogg'

	hud_state = "wiz_tele"

/spell/area_teleport/before_cast(list/targets, user, bypass_range = 0)
	return targets

/spell/area_teleport/choose_targets()
	var/A = null

	if(!randomise_selection)
		A = input("Area to teleport to", "Teleport", A) as null|anything in teleportlocs
	else
		A = pick(teleportlocs)

	var/area/thearea = teleportlocs[A]
	if(!thearea) //Wizard didn't pick an area
		to_chat(holder, "<span class='warning'>You cancel the teleportation.</span>")
		return

	return list(thearea)

/spell/area_teleport/cast(area/thearea, mob/user)
	if(!istype(thearea))
		if(istype(thearea, /list))
			thearea = thearea[1]
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L.len)
		to_chat(user, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
		return

	user.unlock_from()

	var/attempt = null
	var/success = 0
	while(L.len)
		attempt = pick(L)
		success = user.Move(attempt)
		if(!success)
			L.Remove(attempt)
		else
			break

	if(!success)
		user.forceMove(pick(L))

	log_game("[key_name(user)] teleported to [thearea.name] using the teleportation spell.")

/spell/area_teleport/after_cast()
	return

/spell/area_teleport/invocation(mob/user, area/chosenarea)
	if(!istype(chosenarea))
		return //can't have that, can we
	if(!invocation_area || !chosenarea)
		..()
	else
		invocation += "[uppertext(chosenarea.name)]"
		..()
	return
