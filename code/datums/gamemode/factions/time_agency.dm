/datum/faction/time_agent
	name = "Time Agency"
	desc = "To maintain the timelines' integrity."
	ID = TIMEAGENCY
	required_pref = TIMEAGENT
	initial_role = TIMEAGENT
	late_role = TIMEAGENT
	roletype = /datum/role/time_agent
	initroletype = /datum/role/time_agent
	logo_state = "time-logo"
	hud_icons = list("time-logo")
	default_admin_voice = "The Agency"
	admin_voice_style = "notice"
	var/datum/role/time_agent/primary_agent = null // first added is primary, any others added are doppelgangers.
	var/list/eviltwins = list()

/datum/faction/time_agent/New()
	..()
	load_dungeon(/datum/map_element/dungeon/timevoid)

/datum/faction/time_agent/forgeObjectives()
	return

/datum/faction/time_agent/process()
	for(var/datum/role/time_agent/T in members)
		T.process()
	if(stage < FACTION_ACTIVE)
		for(var/datum/role/time_agent/T in members)
			var/list/datum/objective/jecties = T.objectives.GetObjectives()
			if(!jecties.len || locate(/datum/objective/time_agent_extract) in jecties)
				return //not set up yet
			var/finished = TRUE
			for(var/datum/objective/O in T.objectives.GetObjectives())
				if(!(O.IsFulfilled()))
					finished = FALSE
					break
			if(finished)
				stage(FACTION_ACTIVE)


/datum/faction/time_agent/stage(var/stage)
	..()
	switch(stage)
		if(FACTION_ACTIVE)
			for(var/datum/role/time_agent/T in members)
				to_chat(T.antag.current, "<span class = 'notice'>Objectives complete. Triangulating anomaly location.</span>")
				for(var/datum/objective/O in T.objectives.GetObjectives())
					O.force_success = TRUE
			AppendObjective(/datum/objective/time_agent_extract)
			AnnounceObjectives()
			return
		if(FACTION_ENDGAME)
			return

/datum/map_element/dungeon/timevoid //small room for the ninja to get oriented
	file_path = "maps/misc/timevoid.dmm"
	unique = TRUE

/obj/structure/button/time_agent
	activate_id = "0"
	global_search = 0
	reset_name = 0
	name = "teleporter button"
	desc = "Pressing this button will conclude your time in the void and send you into station maintenance."

/obj/structure/button/time_agent/attack_hand(mob/user)

	visible_message("<span class='info'>[user] presses \the [src].</span>")
	activate(user)

/obj/structure/button/time_agent/activate(mob/user)
	var/mob/living/carbon/human/H = user
	var/datum/role/time_agent/R = H.mind.GetRole(TIMEAGENT) || H.mind.GetRole(TIMEAGENTTWIN)
	if(R)
		R.time_elapsed = 59 // increments every tick or so, teleport to station at 60.

/obj/effect/decal/timeagentporter
	name = "time agent teleporter"
	desc = "Teleports you at the press of a button!"
	icon = 'icons/mecha/mecha_equipment.dmi' //placeholder until someone sprites something better
	icon_state = "mecha_teleport"
