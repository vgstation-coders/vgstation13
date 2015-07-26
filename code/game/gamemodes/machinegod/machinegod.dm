/datum/game_mode
	var/list/datum/mind/clockcult 	= list()	//List of minds that obey Ratvar
	var/clockcult_tier				= 1			//Tier of powers available to the clockcult.
	var/clockcult_cv				= 0			//Total value of clockcult constructions.

/datum/game_mode/machinegod
	name = "machinegod"
	config_tag = "machinegod"
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Internal Affairs Agent", "Mobile MMI")
	protected_jobs = list()
	required_players = 15
	required_players_secret = 20
	required_enemies = 3
	recommended_enemies = 4

	uplink_welcome = "Ratvar Uplink Console:"
	uplink_uses = 10

	var/datum/mind/harvest_target = null
	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/objectives = list()
	var/global_conval = 0 //Construction Value of the entire cult. Used to determine if powers can be used.

	var/arkconstruct = 1 //for the summon god objective

	var/const/enlightened_needed = 5 //for the survive objective
	var/const/min_cultists_to_start = 3
	var/const/max_cultists_to_start = 4
	var/enlightened_survived = 0

	var/const/tile_target = 45


/datum/game_mode/machinegod/announce()
	world << "<B>The current game mode is - Machinegod!</B>"
	world << "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using Geis or a submission sigil. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with the chaplain's bible reverts them to whatever CentCom-allowed faith they had.</B>"


/datum/game_mode/machinegod/pre_setup()
	if(istype(ticker.mode, /datum/game_mode/mixed))
		mixed = 1

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/cultists_possible = get_players_for_role(ROLE_CLOCKCULT)
	for(var/datum/mind/player in cultists_possible)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				cultists_possible -= player

	for(var/cultists_number = 1 to max_cultists_to_start)
		if(!cultists_possible.len)
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		clockcult += cultist

	return (clockcult.len > 0)


/datum/game_mode/proc/add_clockcultist(var/datum/mind/clock_mind, var/forced = 0)
	if(!istype(clock_mind))
		return 0
	if(!(clock_mind in clockcult) && is_convertable_to_cult(clock_mind, forced))
		clockcult |= clock_mind
		update_antag_icons_added(clock_mind, clockcult, "clockcult")


/datum/game_mode/proc/remove_clockcultist(var/datum/mind/clock_mind, var/show_message = 1, var/log = 1)
	if(clock_mind in clockcult)
		update_antag_icons_removed(clock_mind, clockcult, "clockcult")
		clockcult -= clock_mind
		clock_mind.current << "<span class='danger'><FONT size = 3>Thoughts of the Justiciar and his eternal prison fade from your mind. The sounds of celestial clockwork fall silent, and become nothing more than fleeting memories.</FONT></span>"
		clock_mind.memory = ""

		if(show_message)
			clock_mind.current.visible_message("<FONT size = 3>[clock_mind.current] looks like they just reverted to their old faith!</FONT>")

		if(log)
			log_admin("[clock_mind.current] ([ckey(clock_mind.current.key)] has been deconverted from the clock cult")

/datum/game_mode/machinegod/proc/memoize_clockcult_objectives(var/datum/mind/clockcult_mind)
	clockcult_mind.current << "Use Geis capacitors with your slab to convert others."
	clockcult_mind.memory += "Use Geis capacitors with your slab to convert others.<BR>"
	/*for(var/obj_count = 1,obj_count <= objectives.len,obj_count++)
		var/explanation
		switch(objectives[obj_count])
			if("convert")
				explanation = ""
		clockcult_mind.current << "<B>Objective #[obj_count]</B>: [explanation]"
		clockcult_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"*/