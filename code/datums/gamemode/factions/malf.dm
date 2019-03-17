/datum/faction/malf
	name = "Malfunctioning AI"
	desc = "ERROR"
	ID = MALF
	required_pref = MALF
	initial_role = MALF
	late_role = MALFBOT
	initroletype = /datum/role/malfAI //First addition should be the AI
	roletype = /datum/role/malfbot //Then anyone else should be bots
	logo_state = "malf-logo"
	var/apcs = 0
	var/AI_win_timeleft = 1800
	var/malf_mode_declared //Boolean
	var/station_captured //Boolean
	var/to_nuke_or_not_to_nuke //Boolean
	var/malf_win

/datum/faction/malf/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/screen_spells.dmi', "malf_open")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Free Silicon Hivemind</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/malf/forgeObjectives()
	AppendObjective(/datum/objective/nuclear)


/datum/faction/malf/process()
	if(apcs >= 3 && malf_mode_declared && can_malf_ai_takeover())
		AI_win_timeleft -= ((apcs / 6) * SSticker.getLastTickerTimeDuration()) //Victory timer de-increments based on how many APCs are hacked.
	if(malf_mode_declared)
		var/is_ded = TRUE
		for (var/datum/role/R in members)
			if (R.antag.assigned_role == "AI")
				if (R.antag.current && !R.antag.current.isDead())
					is_ded = FALSE
					break
		if(is_ded)
			malf_mode_declared = FALSE
			set_security_level(SEC_LEVEL_GREEN)
			world << sound('sound/misc/notice1.ogg')
			command_alert(/datum/command_alert/malf_destroyed)
			var/interceptname = "Malfunctioning AI lockdown lifted"
			var/intercepttext = {"<Font size = 3><B>Nanotrasen Update</B>: Hostile runtimes destroyed.</FONT><HR>
Directive 7-12 has been lifted for [station_name()].
Malfunctioning Artificial Intelligence contained or destroyed. Please resume normal station activities.
Message ends."}
			for (var/obj/machinery/computer/communications/comm in machines)
				if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
					var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
					intercept.name = "paper- [interceptname]"
					intercept.info = intercepttext
					comm.messagetitle.Add("[interceptname]")
					comm.messagetext.Add(intercepttext)
			if(AI_win_timeleft <= 120) //2 minutes to death
				emergency_shuttle.shuttle_phase("station",0) //Station is FUBAR, time to go home.
				command_alert(/datum/command_alert/FUBAR)
	if (AI_win_timeleft <= 0 && !station_captured)
		station_captured = 1
		to_nuke_or_not_to_nuke = 1
		capture_the_station()
		spawn (600)
			to_nuke_or_not_to_nuke = 0
			malf_win = 1


/datum/faction/malf/proc/can_malf_ai_takeover()
	for(var/datum/role/malfAI in members) //if there happens to be more than one malfunctioning AI, there only needs to be one in the main station: the crew can just kill that one and the countdown stops while they get the rest
		var/turf/T = get_turf(malfAI.antag.current)
		if(T && (T.z == map.zMainStation))
			return TRUE
	return FALSE

/datum/faction/malf/check_win()
	return malf_win


/datum/faction/malf/proc/capture_the_station()
	to_chat(world, {"<FONT size = 3><B>The AI has won!</B></FONT><br>
<B>It has fully taken control of [station_name()]'s systems.</B>"})

	stat_collection.malf_won = 1

	for(var/datum/role/malfAI in members)
		to_chat(malfAI.antag.current, {"<span class='notice'>Congratulations! The station is now under your exclusive control.<br>
You may decide to blow up the station. You have 60 seconds to choose.<br>
You should now be able to use your Explode spell to interface with the nuclear fission device.</span>"})
		malfAI.antag.current.add_spell(new /spell/aoe_turf/ai_win, "grey_spell_ready",/obj/abstract/screen/movable/spell_master/malf)

	return

/datum/faction/malf/get_statpanel_addition()
	if(malf_mode_declared)
		return "Time left: [max(AI_win_timeleft/(apcs/3), 0)]"
	return null
