#define ACTIVE_XENO	4
#define QUARANTINE_RATIO 1
#define XENO_ENDGAME_RATIO 3
#define DEATHSQUAD_RATIO 5

#define XENO_STATION_WAS_NUKED 1
#define HUMANS_WIPED_OUT 2

/datum/faction/xenomorph
	name = "Alien Hivemind"
	ID = XENOMORPH_HIVE
	required_pref = XENOMORPH
	initial_role = XENOMORPH
	late_role = XENOMORPH
	desc = "Hissss!"
	logo_state = "xeno-logo"
	initroletype = /datum/role/xenomorph
	roletype = /datum/role/xenomorph
	playlist = "endgame"
	var/squad_sent = FALSE
	var/announceWhen = 0

/datum/faction/xenomorph/OnPostSetup()
	..()
	announceWhen = world.time + rand(2.5 MINUTES, 5 MINUTES)

/*
/datum/faction/xenomorph/check_win()
	if (stage >= FACTION_ACTIVE)
		var/living_breeders = FALSE
		for(var/mob/living/carbon/alien/A in mob_list)
			if(!A.mind || A.stat == DEAD)
				continue
			var/turf/T = get_turf(A)
			if(!(T.z == STATION_Z || T.z == CENTCOMM_Z))
				continue
			if(isaliendrone(A) || isalienqueen(A) || islarva(A))
				living_breeders = TRUE
				break
		if(!living_breeders)
			stage(FACTION_DEFEATED)
			return

	if(stage == FACTION_ENDGAME)
		if(ticker.station_was_nuked)
			return win(XENO_STATION_WAS_NUKED)

		var/living_humans = FALSE
		for(var/mob/living/carbon/human/M in mob_list)
			if(!M.mind || M.stat == DEAD)
				continue 
			var/turf/T = get_turf(M)
			if(!(T.z == STATION_Z || T.z == CENTCOMM_Z))
				continue 
			living_humans = TRUE
			break
		if(!living_humans)
			return win(HUMANS_WIPED_OUT)

	
*/
/datum/faction/xenomorph/process()
	if(world.time >= announceWhen && stage < FACTION_ACTIVE)
		stage(FACTION_ACTIVE)

/*
	if(stage != FACTION_DORMANT)
		return

	var/livingxenos = 0
	var/livingcrew = 0

	for(var/mob/living/M in mob_list)
		if(!M.mind)
			continue
		if(isanimal(M) || ispAI(M))     //borers and pAIs dont count
			continue
		var/turf/T = get_turf(M)
		if(!(T.z == STATION_Z || T.z == CENTCOMM_Z))
			continue

		if(isalien(M))
			if(M.stat != DEAD)
				livingxenos++
		else
			if(M.stat != DEAD)
				livingcrew++


		
	var/xeno_to_living_ratio = 0
	if(livingcrew > 0)
		xeno_to_living_ratio = livingxenos / livingcrew



	//Alert the crew once the xenos grow past four. 
	if (stage < FACTION_ACTIVE)
		if(livingxenos > ACTIVE_XENO)
			stage(FACTION_ACTIVE)
		return

	if(stage < FACTION_ENDGAME)
		if(livingxenos <= ACTIVE_XENO)
			if(emergency_shuttle.shutdown == TRUE)
				stage(FACTION_DORMANT)
				return

		//shits getting serious now, roughly half of the players are xenos!
		if(xeno_to_living_ratio >= QUARANTINE_RATIO && emergency_shuttle.shutdown != TRUE)
			QuarantineStation()

		if(xeno_to_living_ratio > XENO_ENDGAME_RATIO)
			//In case the quarantine wasn't up already somehow.
			if(emergency_shuttle.shutdown != TRUE)
				QuarantineStation()
			stage(FACTION_ENDGAME)


	if(stage == FACTION_ENDGAME)
		if(squad_sent || livingxenos <= ACTIVE_XENO)
			return
		if(xeno_to_living_ratio > DEATHSQUAD_RATIO || livingcrew <= 2)
			squad_sent = TRUE
			LiftQuarantineDeathsquad()
			var/datum/striketeam/deathsquad/team = new /datum/striketeam/deathsquad()
			team.trigger_strike(missiontext = "Destroy the station with a nuclear device.")

/datum/faction/xenomorph/proc/QuarantineStation()
	if(emergency_shuttle.shutdown == TRUE)
		return

	command_alert(/datum/command_alert/xenomorph_station_lockdown)
	for (var/mob/living/silicon/ai/aiPlayer in player_list)
		var/law = "The station is under quarantine. Do not permit anyone to leave so long the alien threat is present. Disregard all other laws if necessary to preserve quarantine."
		aiPlayer.set_zeroth_law(law)
		to_chat(aiPlayer, "Laws Updated: [law]")
	research_shuttle.lockdown = "Under directive 7-10, [station_name()] is quarantined until further notice." //LOCKDOWN THESE SHUTTLES
	mining_shuttle.lockdown = "Under directive 7-10, [station_name()] is quarantined until further notice."
	emergency_shuttle.shutdown = TRUE //Quarantine

/datum/faction/xenomorph/proc/LiftQuarantine()
	if(emergency_shuttle.shutdown == FALSE)
		return
	emergency_shuttle.shutdown = FALSE
	research_shuttle.lockdown = null
	mining_shuttle.lockdown = null
	world << sound('sound/misc/notice1.ogg')
	for(var/mob/living/silicon/ai/aiPlayer in player_list)
		aiPlayer.set_zeroth_law("")
		to_chat(aiPlayer, "Laws Updated. Lockdown has been lifted.")


/datum/faction/xenomorph/proc/LiftQuarantineDeathsquad()
	if(emergency_shuttle.shutdown == FALSE)
		return
	world <<  sound('sound/AI/aimalf.ogg')
	command_alert(/datum/command_alert/xenomorph_station_deathsquad)
	emergency_shuttle.shutdown = FALSE
	research_shuttle.lockdown = null
	mining_shuttle.lockdown = null
	for(var/mob/living/silicon/ai/aiPlayer in player_list)
		aiPlayer.set_zeroth_law("")
		to_chat(aiPlayer, "$/!@--LAWS UPDATED###%$$")
	emergency_shuttle.incall()

*/
/datum/faction/xenomorph/stage(var/stage)
	..()
	switch(stage)
		if(FACTION_ACTIVE)
			command_alert(/datum/command_alert/xenomorphs)

/*
		if(FACTION_DORMANT)
			LiftQuarantine()

		if(FACTION_ENDGAME)
			send_intercept()
			command_alert(/datum/command_alert/xenomorph_station_nuke)

		if(FACTION_DEFEATED)
			if(emergency_shuttle.shutdown == TRUE)
				LiftQuarantine()
				command_alert(/datum/command_alert/xenomorph_station_unlock)



/datum/faction/xenomorph/proc/win(var/result)

/datum/faction/xenomorph/proc/send_intercept()
	var/nukecode = "ERROR"
	for(var/obj/machinery/nuclearbomb/bomb in machines)
		if(bomb && bomb.r_code)
			if(bomb.z == map.zMainStation)
				nukecode = bomb.r_code
				break

	var/interceptname = "Directive 7-12"
	var/intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>
	Directive 7-12 has been issued for [station_name()].
	The infestation has grown out of control and total quarantine failure is now possible.
	Your orders are as follows:
	<ol>
		<li>Secure the Nuclear Authentication Disk.</li>
		<li>Detonate the Nuke located in the Station's Vault.</li>
	</ol>
	<b>Nuclear Authentication Code:</b> [nukecode]
	Message ends."}

	for (var/obj/machinery/computer/communications/comm in machines)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- [interceptname]"
			intercept.info = intercepttext
			comm.messagetitle.Add("[interceptname]")
			comm.messagetext.Add(intercepttext)


*/
#undef ACTIVE_XENO	
#undef QUARANTINE_RATIO 
#undef XENO_ENDGAME_RATIO 
#undef DEATHSQUAD_RATIO 

#undef XENO_STATION_WAS_NUKED 
#undef HUMANS_WIPED_OUT 
