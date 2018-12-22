//________________________________________________

/datum/faction/revolution
	name = "Revolutionaries"
	ID = REVOLUTION
	required_pref = ROLE_REV
	initial_role = HEADREV
	late_role = REV
	desc = "Viva!"
	logo_state = "rev-logo"
	hud_icons = list("rev-logo", "rev_head-logo")
	initroletype = /datum/role/revolutionary/leader
	roletype = /datum/role/revolutionary
	var/win_shuttle = FALSE

/datum/faction/revolution/HandleRecruitedMind(var/datum/mind/M)
	if(M.assigned_role in command_positions)
		return ADD_REVOLUTIONARY_FAIL_IS_COMMAND

	var/mob/living/carbon/human/H = M.current

	if(jobban_isbanned(H, "revolutionary") || isantagbanned(H))
		return ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED

	for(var/obj/item/weapon/implant/loyalty/L in H) // check loyalty implant in the contents
		if(L.imp_in == H) // a check if it's actually implanted
			return ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED

	if(isrev(H)) //HOW DO YOU FUCK UP THIS BADLY.
		return ADD_REVOLUTIONARY_FAIL_IS_REV

	. = ..()
	update_faction_icons()

/datum/faction/revolution/forgeObjectives()
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/target/assassinate/A = new(auto_target = FALSE)
		if(A.set_target(head_mind))
			AppendObjective(A, TRUE) // We will have more than one kill objective

#define ALL_HEADS_DEAD 1
#define ALL_REVS_DEAD 2
#define SHUTTLE_LEFT 3

/datum/faction/revolution/check_win()
	// -- 1. Did the shuttle leave ?
	if (win_shuttle)
		return end(SHUTTLE_LEFT)

	// -- 2. Are all the heads dead ?
	var/list/total_heads = get_living_heads()
	var/incapacitated_heads = 0

	for (var/datum/mind/M in total_heads)
		if (M.current.isDead() || M.current.z != map.zMainStation)
			incapacitated_heads++

	if (incapacitated_heads >= total_heads.len)
		return end(ALL_HEADS_DEAD)

	// -- 3. Are all the revs deads ?
	for (var/datum/role/R in members)
		if (R.antag && R.antag.current && !(R.antag.current.isDead() || R.antag.current.z != map.zMainStation))
			return FALSE

	return end(ALL_REVS_DEAD)

// Called on arrivals and emergency shuttle departure.
/hook_handler/revs

/hook_handler/revs/proc/OnEmergencyShuttleDeparture(var/list/args)
	var/datum/faction/revolution/R = find_active_faction_by_type(/datum/faction/revolution)
	if (!istype(R))
		return FALSE
	for(var/datum/mind/M in get_living_heads())
		var/mob/living/L = M.current
		var/turf/T = get_turf(L)
		if(istype(T.loc, /area/shuttle/escape/centcom))
			R.win_shuttle = TRUE
			return TRUE
		else if(istype(T.loc, /area/shuttle/escape_pod1/centcom) || istype(T.loc, /area/shuttle/escape_pod2/centcom) || istype(T.loc, /area/shuttle/escape_pod3/centcom) || istype(T.loc, /area/shuttle/escape_pod5/centcom))
			R.win_shuttle = TRUE
			return TRUE
	return FALSE

/hook_handler/revs/proc/OnArrival(var/list/args)
	var/datum/faction/revolution/R = find_active_faction_by_type(/datum/faction/revolution)
	if (!istype(R))
		return FALSE
	ASSERT(args["character"])
	ASSERT(args["rank"])
	var/mob/living/L = args["character"]
	if (args["rank"] in command_positions)
		var/datum/objective/target/assassinate/A = new(auto_target = FALSE)
		if(A.set_target(L.mind))
			R.AppendObjective(A, TRUE) // We will have more than one kill objective

/datum/faction/revolution/proc/end(var/result)
	. = TRUE
	switch (result)
		if (ALL_HEADS_DEAD)
			to_chat(world, "<font size = 3><b>The revolution has won!</b></font><br/><font size = 2>All heads are either dead or have fled the station!</font>")
		if (ALL_REVS_DEAD)
			to_chat(world, "<font size = 3><b>The crew has won!</b></h1><br/><font size = 2>All revolutionaries are either dead or have fled the station!</font>")
		if (SHUTTLE_LEFT)
			to_chat(world, "<font size = 3><b>Revolution minor victory!</b></font><br/><font size = 2>The heads called the shuttle to leave the station!</font>")