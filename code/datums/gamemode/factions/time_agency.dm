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
	var/datum/role/time_agent/primary_agent = null // first added is primary, any others added are doppelgangers.
	var/list/eviltwins = list()

/datum/faction/time_agent/New()
	..()
	load_dungeon(/datum/map_element/dungeon/timevoid)

/datum/faction/time_agent/proc/addPrimary(/datum/role/time_agent/T)
	primary_agent = T

/datum/faction/time_agent/proc/addEvilTwin(/datum/role/time_agent/T)
	eviltwins += T

/datum/faction/time_agent/forgeObjectives()
	return

/datum/faction/time_agent/stage(var/stage)
	..()
	switch(stage)
		if(FACTION_ACTIVE)
		// spawn in the time anomaly, adjust agents' jecties
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

/obj/structure/button/timeagent/activate(mob/user)
	var/mob/living/carbon/human/H = user
	var/datum/role/time_agent/R = H.mind.GetRole(TIMEAGENT)
	if(R)
		R.time_elapsed = -1 // increments every tick or so, teleport to station at 0.
