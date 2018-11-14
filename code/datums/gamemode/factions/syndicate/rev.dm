//________________________________________________

/datum/faction/revolution
	name = "Revolutionaries"
	ID = REVOLUTION
	required_pref = ROLE_REV
	initial_role = HEADREV
	late_role = REV
	desc = "Viva!"
	logo_state = "rev-logo"
	initroletype = /datum/role/revolutionary/leader
	roletype = /datum/role/revolutionary
	var/win_shuttle = FALSE

/datum/faction/revolution/HandleRecruitedMind(var/datum/mind/M)
	if(M.assigned_role in command_positions)
		return ADD_REVOLUTIONARY_FAIL_IS_COMMAND

	var/mob/living/carbon/human/H = M.current

	if(jobban_isbanned(H, "revolutionary"))
		return ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED

	for(var/obj/item/weapon/implant/loyalty/L in H) // check loyalty implant in the contents
		if(L.imp_in == H) // a check if it's actually implanted
			return ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED

	if(isrev(H)) //HOW DO YOU FUCK UP THIS BADLY.
		return ADD_REVOLUTIONARY_FAIL_IS_REV

	return ..()

/datum/faction/revolution/forgeObjectives()
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/target/assassinate/A = new(auto_target = FALSE)
		if(A.set_target(head_mind))
			AppendObjective(A)

#define ALL_HEADS_DEAD 1
#define ALL_REVS_DEAD 2
#define SHUTTLE_LEFT 3

/datum/faction/revolution/check_win()
	// -- 1. Did the shuttle left ?
	if (win_shuttle)
		return end(SHUTTLE_LEFT)

	// -- 2. Are all the heads dead ?
	var/total_heads = 0
	var/incapacitated_heads = 0

	for (var/mob/living/carbon/human/H in player_list)
		var/datum/mind/M = H.mind
		if (!M)
			continue
		if (M.assigned_role in command_positions)
			total_heads++
			if (H.isDead() || H.z != map.zMainStation)
				incapacitated_heads++

	if (incapacitated_heads >= total_heads)
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
	R.win_shuttle = TRUE
	return TRUE

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
			R.AppendObjective(A)

/datum/faction/revolution/proc/end(var/result)
	. = TRUE
	switch (result)
		if (ALL_HEADS_DEAD)
			to_chat(world, "<b>The revolution has won!</b><br/>All heads are either dead or have fled the station!")
		if (ALL_REVS_DEAD)
			to_chat(world, "<b>The crew has won!</b><br/>All revolutionaries are either dead or have fled the station!")
		if (SHUTTLE_LEFT)
			to_chat(world, "<b>Revolution minor victory!</b><br/>The heads called the shuttle to leave the station!")