/datum/game_mode
	var/list/datum/mind/devils = list()
	var/devil_ascended = 0 // Number of arch devils on station

/datum/game_mode/proc/add_devil_objectives(datum/mind/devil_mind, quantity)
	var/list/validtypes = list(/datum/objective/devil/soulquantity, /datum/objective/devil/soulquality, /datum/objective/devil/sintouch, /datum/objective/devil/buy_target)
	for(var/i = 1 to quantity)
		var/type = pick(validtypes)
		var/datum/objective/devil/objective = new type(null)
		objective.owner = devil_mind
		devil_mind.objectives += objective
		if(!istype(objective, /datum/objective/devil/buy_target))
			validtypes -= type //prevent duplicate objectives, EXCEPT for buy_target.
		else
			objective.find_target()

/datum/game_mode/proc/update_devil_icons_added(datum/mind/devil_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_DEVIL]
	hud.join_hud(devil_mind.current)
	set_antag_hud(devil_mind.current, "devil")

/datum/game_mode/proc/update_devil_icons_removed(datum/mind/devil_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_DEVIL]
	hud.leave_hud(devil_mind.current)
	set_antag_hud(devil_mind.current, null)

/datum/game_mode/proc/update_soulless_icons_added(datum/mind/soulless_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_SOULLESS]
	hud.join_hud(soulless_mind.current)
	set_antag_hud(soulless_mind.current, "soulless")

/datum/game_mode/proc/update_soulless_icons_removed(datum/mind/soulless_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_SOULLESS]
	hud.leave_hud(soulless_mind.current)
	set_antag_hud(soulless_mind.current, null)
