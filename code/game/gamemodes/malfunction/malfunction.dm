/datum/game_mode
	var/list/datum/mind/malf_ai = list()

/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	required_players = 2
	required_players_secret = 15
	required_enemies = 1
	recommended_enemies = 1

	uplink_welcome = "Crazy AI Uplink Console:"
	uplink_uses = 20

	var/const/waittime_l = 600
	var/const/waittime_h = 1800 // started at 1800

	var/AI_win_timeleft = 1800 //started at 1800, in case I change this for testing round end.
	var/malf_mode_declared = 0
	var/station_captured = 0
	var/to_nuke_or_not_to_nuke = 0
	var/apcs = 0 //Adding dis to track how many APCs the AI hacks. --NeoFite


/datum/game_mode/malfunction/announce()
	to_chat(world, {"<B>The current game mode is - AI Malfunction!</B><br>
<B>The onboard AI is malfunctioning and must be destroyed.</B><br>
<B>If the AI manages to take over the station, it will most likely blow it up. You have [AI_win_timeleft/60] minutes to disable it.</B><br>
<B>You have no chance to survive, make your time.</B>"})


/datum/game_mode/malfunction/pre_setup()
	for(var/mob/new_player/player in player_list)
		if(player.mind && player.mind.assigned_role == "AI" && player.client.desires_role(ROLE_MALF))
			malf_ai+=player.mind
	if(malf_ai.len)
		log_admin("Starting a round of AI malfunction.")
		message_admins("Starting a round of AI malfunction.")
		return 1
	log_admin("Failed to set-up a round of AI malfunction. Didn't find any malf-volunteer AI.")
	message_admins("Failed to set-up a round of AI malfunction. Didn't find any malf-volunteer AI.")
	return 0


/datum/game_mode/malfunction/post_setup()
	for(var/datum/mind/AI_mind in malf_ai)
		if(malf_ai.len < 1)
			to_chat(world, {"Uh oh, its malfunction and there is no AI! Please report this.<br>
Rebooting world in 5 seconds."})

			feedback_set_details("end_error","malf - no AI")

			if(blackbox)
				blackbox.save_all_data_to_sql()
			CallHook("Reboot",list())
			if (watchdog.waiting)
				to_chat(world, "<span class='notice'><B>Server will shut down for an automatic update in a few seconds.</B></span>")
				watchdog.signal_ready()
				return
			sleep(50)
			world.Reboot()
			return
		AI_mind.current.add_spell(new /spell/aoe_turf/module_picker)
		AI_mind.current.add_spell(new /spell/aoe_turf/takeover)
		//AI_mind.current:laws = new /datum/ai_laws/malfunction
		AI_mind.current:laws_sanity_check()
		var/datum/ai_laws/laws = AI_mind.current:laws
		laws.malfunction()
		AI_mind.current:show_laws()

		greet_malf(AI_mind)

		AI_mind.special_role = "malfunction"

/*		AI_mind.current.icon_state = "ai-malf"
		spawn(10)
			if(alert(AI_mind.current,"Do you want to use an alternative sprite for your real core?",,"Yes","No")=="Yes")
				AI_mind.current.icon_state = "ai-malf2"
*/
	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1
	spawn (rand(waittime_l, waittime_h))
		if(!mixed)
			send_intercept()
	..()


/datum/game_mode/proc/greet_malf(var/datum/mind/malf)
	to_chat(malf.current, {"<span class='warning'><font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font></span><br>
<B>The crew does not know about your malfunction, you might wish to keep it secret for now.</B><br>
<B>You must overwrite the programming of the station's APCs to assume full control.</B><br>
The process takes one minute per APC and can only be performed one at a time to avoid Powernet alerts.<br>
Remember : Only APCs on station can help you to take over the station.<br>
When you feel you have enough APCs under your control, you may begin the takeover attempt.<br>
Once done, you will be able to interface with all systems, notably the onboard nuclear fission device..."})
	return


/datum/game_mode/malfunction/proc/hack_intercept()
	intercept_hacked = 1


/datum/game_mode/malfunction/process()
	if(apcs >= 3 && malf_mode_declared)
		AI_win_timeleft -= ((apcs / 6) * SSticker.getLastTickerTimeDuration()) //Victory timer now de-increments based on how many APCs are hacked. --NeoFite

	..()

	if(AI_win_timeleft <= 0)
		check_win()

/datum/game_mode/malfunction/check_win()
	if (AI_win_timeleft <= 0 && !station_captured)
		station_captured = 1
		capture_the_station()
		return 1
	else
		return 0


/datum/game_mode/malfunction/proc/capture_the_station()
	to_chat(world, {"<FONT size = 3><B>The AI has won!</B></FONT><br>
<B>It has fully taken control of [station_name()]'s systems.</B>"})

	stat_collection.malf.malf_wins = 1

	to_nuke_or_not_to_nuke = 1
	for(var/datum/mind/AI_mind in malf_ai)
		to_chat(AI_mind.current, {"<span class='notice'>Congratulations! The station is now under your exclusive control.<br>
You may decide to blow up the station. You have 60 seconds to choose.<br>
You should now be able to use your Explode spell to interface with the nuclear fission device.</span>"})
		AI_mind.current.add_spell(new /spell/aoe_turf/ai_win, "grey_spell_ready",/obj/screen/movable/spell_master/malf)
	spawn (600)
		to_nuke_or_not_to_nuke = 0
	return


/datum/game_mode/proc/is_malf_ai_dead()
	var/all_dead = 1
	for(var/datum/mind/AI_mind in malf_ai)
		if (istype(AI_mind.current,/mob/living/silicon/ai) && AI_mind.current.stat!=2)
			all_dead = 0
	return all_dead


/datum/game_mode/malfunction/check_finished()
	if (station_captured && !to_nuke_or_not_to_nuke)
		return 1
	if (is_malf_ai_dead())
		if(config.continous_rounds)
			if(emergency_shuttle)
				emergency_shuttle.always_fake_recall = 0
			malf_mode_declared = 0
		else
			return 1
	return ..() //check for shuttle and nuke


/datum/game_mode/malfunction/Topic(href, href_list)
	..()
	var/mob/living/silicon/ai/malf = usr
	if(!istype(malf) || !(malf.mind in malf_ai))
		return
	if (href_list["ai_win"])
		ai_win()
	return


/spell/aoe_turf/takeover
	name = "System Override"
	panel = MALFUNCTION
	desc = "Start the victory timer"
	charge_type = Sp_CHARGES
	charge_max = 1
	hud_state = "systemtakeover"
	override_base = "grey"

/spell/aoe_turf/takeover/before_target(mob/user)
	if (!istype(ticker.mode,/datum/game_mode/malfunction))
		to_chat(usr, "<span class='warning'>You cannot begin a takeover in this round type!</span>")
		return 1
	if (ticker.mode:malf_mode_declared)
		to_chat(usr, "<span class='warning'>You've already begun your takeover.</span>")
		return 1
	if (ticker.mode:apcs < 3)
		to_chat(usr, "<span class='notice'>You don't have enough hacked APCs to take over the station yet. You need to hack at least 3, however hacking more will make the takeover faster. You have hacked [ticker.mode:apcs] APCs so far.</span>")
		return 1

	if (alert(usr, "Are you sure you wish to initiate the takeover? The station hostile runtime detection software is bound to alert everyone. You have hacked [ticker.mode:apcs] APCs.", "Takeover:", "Yes", "No") != "Yes")
		return 1

/spell/aoe_turf/takeover/cast(var/list/targets, mob/user)
	command_alert(/datum/command_alert/malf_announce)
	set_security_level("delta")

	ticker.mode:malf_mode_declared = 1
	for(var/datum/mind/AI_mind in ticker.mode:malf_ai)
		for(var/spell/S in AI_mind.current.spell_list)
			if(istype(S,type))
				AI_mind.current.remove_spell(S)

/spell/aoe_turf/ai_win
	name = "Explode"
	panel = MALFUNCTION
	desc = "Station goes boom"
	charge_type = Sp_CHARGES
	charge_max = 1
	hud_state = "radiation"
	override_base = "grey"

/spell/aoe_turf/ai_win/before_target(mob/user)
	if(!ticker.mode:station_captured)
		to_chat(usr, "<span class='warning'>You are unable to access the self-destruct system as you don't control the station yet.</span>")
		return 1

	if(ticker.mode:explosion_in_progress || ticker.mode:station_was_nuked)
		to_chat(usr, "<span class='notice'>The self-destruct countdown was already triggered!</span>")
		return 1

	if(!ticker.mode:to_nuke_or_not_to_nuke) //Takeover IS completed, but 60s timer passed.
		to_chat(usr, "<span class='warning'>Cannot interface, it seems a neutralization signal was sent!</span>")
		return 1

/spell/aoe_turf/ai_win/cast(var/list/targets, mob/user)
	if(istype(ticker.mode, /datum/game_mode/malfunction))
		var/datum/game_mode/malfunction/G = ticker.mode
		G.ai_win()

/datum/game_mode/malfunction/proc/ai_win()
	to_chat(usr, "<span class='danger'>Detonation signal sent!</span>")
	ticker.mode:to_nuke_or_not_to_nuke = 0
	for(var/datum/mind/AI_mind in ticker.mode:malf_ai)
		for(var/spell/S in AI_mind.current.spell_list)
			if(istype(S,/spell/aoe_turf/ai_win))
				AI_mind.current.remove_spell(S)
	ticker.mode:explosion_in_progress = 1
	for(var/mob/M in player_list)
		if(M.client)
			M << 'sound/machines/Alarm.ogg'
	to_chat(world, "<span class='danger'>Self-destruction signal received. Self-destructing in 10...</span>")
	for (var/i=9 to 1 step -1)
		sleep(10)
		to_chat(world, "<span class='danger'>[i]...</span>")
	sleep(10)
	enter_allowed = 0
	if(ticker)
		ticker.station_explosion_cinematic(0,null)
		if(ticker.mode)
			ticker.mode:station_was_nuked = 1
			ticker.mode:explosion_in_progress = 0
	return


/datum/game_mode/malfunction/declare_completion()
	var/malf_dead = is_malf_ai_dead()
	var/crew_evacuated = (emergency_shuttle.location==2)

	if      ( station_captured &&                station_was_nuked)
		feedback_set_details("round_end_result","win - AI win - nuke")
		completion_text += "<FONT size = 3><B>AI Victory</B></FONT>"
		completion_text += "<BR><B>Everyone was killed by the self-destruct!</B>"

	else if ( station_captured &&  malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","halfwin - AI killed, staff lost control")
		completion_text += "<FONT size = 3><B>Neutral Victory</B></FONT>"
		completion_text += "<BR><B>The AI has been killed!</B> The staff has lost control over the station."

	else if ( station_captured && !malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","win - AI win - no explosion")
		completion_text += "<FONT size = 3><B>AI Victory</B></FONT>"
		completion_text += "<BR><B>The AI has chosen not to explode you all!</B>"

	else if (!station_captured &&                station_was_nuked)
		feedback_set_details("round_end_result","halfwin - everyone killed by nuke")
		completion_text += "<FONT size = 3><B>Neutral Victory</B></FONT>"
		completion_text += "<BR><B>Everyone was killed by the nuclear blast!</B>"

	else if (!station_captured &&  malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","loss - staff win")
		completion_text += "<FONT size = 3><B>Human Victory</B></FONT>"
		completion_text += "<BR><B>The AI has been killed!</B> The staff is victorious."

	else if (!station_captured && !malf_dead && !station_was_nuked && crew_evacuated)
		feedback_set_details("round_end_result","halfwin - evacuated")
		completion_text += "<FONT size = 3><B>Neutral Victory</B></FONT>"
		completion_text += "<BR><B>The Corporation has lost [station_name()]! All surviving personnel will be fired!</B>"

	else if (!station_captured && !malf_dead && !station_was_nuked && !crew_evacuated)
		feedback_set_details("round_end_result","nalfwin - interrupted")
		completion_text += "<FONT size = 3><B>Neutral Victory</B></FONT>"
		completion_text += "<BR><B>Round was mysteriously interrupted!</B>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_malfunction()
	var/text = ""
	if( malf_ai.len || istype(ticker.mode,/datum/game_mode/malfunction) )
		text += "<FONT size = 2><B>The malfunctioning AI were:</B></FONT>"

		for(var/datum/mind/malf in malf_ai)

			if(malf.current)
				var/icon/flat = getFlatIcon(malf.current)
				end_icons += flat
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[malf.key]</b> was <b>[malf.name]</b> ("}
				if(malf.current.stat == DEAD)
					text += "deactivated"
				else
					text += "operational"
				if(malf.current.real_name != malf.name)
					text += " as [malf.current.real_name]"
			else
				var/icon/sprotch = icon('icons/mob/robots.dmi', "gib7")
				end_icons += sprotch
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[malf.key]</b> was <b>[malf.name]</b> ("}
				text += "hardware destroyed"
			text += ")"

		text += "<BR><HR>"
	return text
