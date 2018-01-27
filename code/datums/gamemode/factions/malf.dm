/datum/faction/malf
	name = "Malfunctioning AI"
	desc = "ERROR"
	ID = MALF
	required_pref = ROLE_MALF
	initial_role = MALF
	late_role = MALF //There shouldn't really be any late roles for malfunction, but just in case we can corrupt an AI in the future, let's keep this
	roletype = /datum/role/malfAI
	var/apcs
	var/AI_win_timeleft = 1800
	var/malf_mode_declared //Boolean
	var/station_captured //Boolean
	var/to_nuke_or_not_to_nuke //Boolean

/datum/faction/malf/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/screen_spells.dmi', "malf_open")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Free Silicon Hivemind</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header


/datum/faction/malf/process()
	if(apcs >= 3 && malf_mode_declared && can_malf_ai_takeover())
		AI_win_timeleft -= ((apcs / 6) * SSticker.getLastTickerTimeDuration()) //Victory timer de-increments based on how many APCs are hacked.

	if(AI_win_timeleft <= 0)
		check_win()


/datum/faction/malf/proc/can_malf_ai_takeover()
	for(var/datum/role/malfAI in members) //if there happens to be more than one malfunctioning AI, there only needs to be one in the main station: the crew can just kill that one and the countdown stops while they get the rest
		var/turf/T = get_turf(malfAI.antag.current)
		if(T && (T.z == map.zMainStation))
			return TRUE
	return FALSE

/datum/faction/malf/check_win()
	if (AI_win_timeleft <= 0 && !station_captured)
		station_captured = 1
		capture_the_station()
		return 1
	else
		return 0


/datum/faction/malf/proc/capture_the_station()
	to_chat(world, {"<FONT size = 3><B>The AI has won!</B></FONT><br>
<B>It has fully taken control of [station_name()]'s systems.</B>"})

	stat_collection.malf.malf_wins = 1

	to_nuke_or_not_to_nuke = 1
	for(var/datum/role/malfAI in members)
		to_chat(malfAI.antag.current, {"<span class='notice'>Congratulations! The station is now under your exclusive control.<br>
You may decide to blow up the station. You have 60 seconds to choose.<br>
You should now be able to use your Explode spell to interface with the nuclear fission device.</span>"})
		malfAI.antag.current.add_spell(new /spell/aoe_turf/ai_win, "grey_spell_ready",/obj/abstract/screen/movable/spell_master/malf)
	spawn (600)
		to_nuke_or_not_to_nuke = 0
	return