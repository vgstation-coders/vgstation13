//________________________________________________

/datum/faction/revolution
	name = "Revolutionaries"
	ID = REVOLUTION
	required_pref = REV
	initial_role = HEADREV
	late_role = REV
	desc = "Viva!"
	logo_state = "rev-logo"
	hud_icons = list("rev-logo", "rev_head-logo")
	initroletype = /datum/role/revolutionary/leader
	roletype = /datum/role/revolutionary
	playlist = "nukesquad"

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
	var/datum/role/revolutionary/rev = M.GetRole(REV)
	var/datum/gamemode/dynamic/D = ticker.mode
	if(locate(/datum/dynamic_ruleset/roundstart/delayed/revs) in D.executed_rules)
		rev.Greet(GREET_CONVERTED)
	else if(locate(/datum/dynamic_ruleset/midround/from_ghosts/faction_based/revsquad) in D.executed_rules)
		rev.Greet(GREET_REVSQUAD_CONVERTED)
	else if(locate(/datum/dynamic_ruleset/latejoin/provocateur) in D.executed_rules)
		rev.Greet(GREET_PROVOC_CONVERTED)
	else
		rev.Greet(GREET_DEFAULT)
	update_faction_icons()

/datum/faction/revolution/forgeObjectives()
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/target/assassinate/orexile/A = new(auto_target = FALSE)
		if(A.set_target(head_mind))
			AppendObjective(A, TRUE) // We will have more than one kill objective

/datum/faction/revolution/OnPostSetup()
	..()
	/*var/datum/gamemode/dynamic/D = ticker.mode
	if(locate(/datum/dynamic_ruleset/midround/from_ghosts/faction_based/revsquad) in D.executed_rules)
		//Move the revheads! In the future this could be used to make the revsquad arrive via shuttle.
		var/list/turf/revsq_spawn = list()

		for(var/obj/effect/landmark/A in landmarks_list)
			if(A.name == "RevSq-Spawn")
				revsq_spawn += get_turf(A)
				qdel(A)
				A = null
				continue

		var/spawnpos = 1

		for(var/datum/role/revolutionary/leader/L in members)
			if(spawnpos > revsq_spawn.len)
				spawnpos = 1
			if(revsq_spawn[spawnpos])
				RS.forceMove(revsq_spawn[spawnpos])
			spawnpos++*/

	update_faction_icons()
	if(!objective_holder.objectives.len)
		forgeObjectives()
		AnnounceObjectives()

/datum/faction/revs/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<br><h2>Heads of Staff</h2><BR><BR>"
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/mob/M = head_mind.current
		if (M)
			dat += {"[name] <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]/[M.key]</a>[M.client ? "" : " <i> - (logged out)</i>"][M.stat == DEAD ? " <b><font color=red> - (DEAD)</font></b>" : ""]
				 - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(priv msg)</a>
				 - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>"}
		else
			dat += {"[name] [head_mind.name]/[M.key]<b><font color=red> - (DESTROYED)</font></b>
				 - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(priv msg)</a>
				 - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>"}
	return dat

#define ALL_HEADS_DEAD 1
#define ALL_REVS_DEAD 2

/datum/faction/revolution/check_win()
	var/gameactivetime = world.time - ticker.gamestart_time*10 //gamestart_time is expressed in seconds, not deciseconds
	if(gameactivetime < 5 MINUTES)
		if(!(gameactivetime % 60))
			message_admins("The revolution faction exists. [round(((5 MINUTES) - gameactivetime)/60)] minutes until win conditions begin checking.")
		return //Don't bother checking for win before 5min
	if(stage <= FACTION_DEFEATED)
		return

	// -- 2. Are all the heads dead ?
	var/remaining_targets = objective_holder.objectives.len
	for(var/datum/objective/objective in objective_holder.GetObjectives())
		if(objective.IsFulfilled())
			remaining_targets--

	if(stage < FACTION_ENDGAME)
		var/living_revs = 0
		var/total_valid_living = 0
		for (var/mob/living/L in player_list)
			if (issilicon(L)||isborer(L))
				continue
			if (L.stat == DEAD)
				continue
			if (isrev(L))
				living_revs++
			total_valid_living++
		var/threshold = 50 //the percentage of living revs at which point the announcement is triggered
		if(living_revs > 0 && total_valid_living > 0)
			var/revs_percentage = round((living_revs * 100)/total_valid_living)
			if(revs_percentage >= threshold)
				stage(FACTION_ENDGAME)
				command_alert(/datum/command_alert/revolution)

	switch(remaining_targets)
		if(0)
			if(stage < FACTION_VICTORY)
				stage(FACTION_VICTORY)
				return end(ALL_HEADS_DEAD)
		if(1)
			if(stage < FACTION_ENDGAME)
				stage(FACTION_ENDGAME)
				command_alert(/datum/command_alert/revolution)

/datum/faction/revolution/process()
	..()
	if(stage >= FACTION_ENDGAME)
		var/anyone = FALSE
		for(var/datum/role/R in members)
			if(!R.antag.current.stat)
				anyone = TRUE //If one rev is still not incapacitated
		if(!anyone)
			stage(FACTION_DEFEATED)
			command_alert(/datum/command_alert/revolutiontoppled)

// Called on arrivals and emergency shuttle departure.
/hook_handler/revs

/hook_handler/revs/proc/OnArrival(var/list/args)
	var/datum/faction/revolution/R = find_active_faction_by_type(/datum/faction/revolution)
	if (!istype(R))
		return FALSE
	ASSERT(args["character"])
	ASSERT(args["rank"])
	var/mob/living/L = args["character"]
	if (args["rank"] in command_positions)
		var/datum/objective/target/assassinate/orexile/A = new(auto_target = FALSE)
		if(A.set_target(L.mind))
			R.AppendObjective(A, TRUE) // We will have more than one kill objective


/datum/faction/revolution/proc/end(var/result)
	. = TRUE
	switch (result)
		if (ALL_HEADS_DEAD)
			to_chat(world, "<font size = 3><b>The revolution has won!</b></font><br/><font size = 2>All heads are either dead or have fled the station!</font>")
		if (ALL_REVS_DEAD)
			to_chat(world, "<font size = 3><b>The crew has won!</b></h1><br/><font size = 2>All revolutionaries are either dead or have fled the station!</font>")