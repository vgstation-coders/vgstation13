
/*
	/vg/station's version of the Cult of Nar-Sie
	Mostly developped and maintained by Deity Link since 2014
	with extra contributions by:
		* Gurfan
		* Shifty
		* R0b0
		* Damian
		* Barry
		* and others!

	Rune sprites inspired by the designs originally drawn by Urist McDorf

	Nar-Sie sprite based on Ausops' original re-sprite, higher-res version by Deity Link

	Based on TGstation's cult mode originally developped in 2010 by Uporotiy
*/

/datum/faction/bloodcult
	name = "Cult of Nar-Sie"
	ID = BLOODCULT
	initial_role = CULTIST
	late_role = CULTIST
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to grow their ranks and cause chaos.\
	Nar-Sie's goal is to toy with the crew, before tearing open a breach through reality so he can pull the station into his realm and feast on the crew's blood."
	initroletype = /datum/role/cultist
	roletype = /datum/role/cultist
	logo_state = "cult-logo"
	hud_icons = list("cult-apprentice-logo", "cult-logo", "cult-master-logo", "shade-blade")
	default_admin_voice = "<span class='danger'>Nar-Sie</span>" // Nar-Sie's name always appear in red in the chat, makes it stand out.
	admin_voice_style = "sinister"
	admin_voice_say = "murmurs..."
	stage = BLOODCULT_STAGE_NORMAL
	var/list/bloody_floors = list()
	var/cult_win = FALSE

	var/list/cult_reminders = list()

	var/list/bindings = list()

	var/cultist_cap = 1	//clamped between 5 and 9 depending on crew size. once the cap goes up it cannot go down.
	var/min_cultist_cap = 5
	var/max_cultist_cap = 9

	var/mentor_count = 0 	//so we don't loop through the member list if we already know there are no mentors in there

	var/list/arch_cultists = list()
	var/list/departments_left = list("Security", "Medical", "Engineering", "Science", "Cargo")

	var/mob/living/sacrifice_target = null
	var/datum/mind/sacrifice_mind = null
	var/target_sacrificed = FALSE

	var/cult_founding_time = 0
	var/last_process_time = 0
	var/delta = 1

	var/eclipse_progress = 0
	var/eclipse_target = 1800
	var/eclipse_window = 10 MINUTES
	var/eclipse_increments = 0
	var/eclipse_contributors = list()//associative list: /mind = score
	var/eclipse_countermeasures = 0//mostly chaplain's efforts to indirectly impede the cult with his own conversions and rituals

	var/soon_announcement = FALSE
	var/overtime_announcement = FALSE

	var/bloodstone_rising_time = 0
	var/bloodstone_duration = 430 SECONDS
	var/bloodstone_target_time = 0

	var/datum/rune_spell/tearreality/tear_ritual = null
	var/obj/structure/cult/bloodstone/bloodstone = null		//we track the one spawned by the Tear Reality rune
	var/obj/machinery/singularity/narsie/large/narsie = null

	//we track the mind of anyone that has been converted or made prisoner at least once.
	var/previously_made_prisoner = list()
	var/previously_converted = list()

	var/total_devotion = 0

/datum/faction/bloodcult/stage(var/value)
	stage = value
	switch(stage)
		if (BLOODCULT_STAGE_READY)
			eclipse_trigger_cult()
		if (BLOODCULT_STAGE_MISSED)
			for (var/datum/role/cultist in members)
				var/mob/M = cultist.antag.current
				to_chat(M, "<span class='sinister'>The Eclipse has passed. You won't be able to tear reality aboard this station anymore. Escape the station alive with your fellow cultists so you may try again another day.</span>")
		if (BLOODCULT_STAGE_ECLIPSE)
			update_all_parallax()
			spawn()
				for (var/mob/dead/observer/O in player_list)
					O.cultify()
					sleep(rand(1,5))
			bloodstone_rising_time = world.time
			bloodstone_target_time = world.time + bloodstone_duration
			spawn (3 SECONDS)//leaving just a moment for the blood stone to rise.
				last_security_level_change = SEC_LEVEL_RED
				var/sec_change = TRUE
				for(var/datum/faction/F in ticker.mode.factions)
					if (F.last_security_level_change == SEC_LEVEL_DELTA)
						sec_change = FALSE
				command_alert(/datum/command_alert/eclipse_bloodstone)
				if (sec_change)
					ticker.StartThematic("endgame")
					sleep(2 SECONDS)
					set_security_level("red")
		if (BLOODCULT_STAGE_DEFEATED)
			..()
			command_alert(/datum/command_alert/eclipse_bloodstone_broken)
			if (sun.eclipse == ECLIPSE_ONGOING)//destruction of the blood stone instantly ends the Eclipse
				sun.eclipse_manager.eclipse_end()
			spawn()
				for (var/mob/dead/observer/O in player_list)
					O.decultify()
					sleep(rand(1,5))
		if (BLOODCULT_STAGE_NARSIE)
			ticker.StartThematic("endgame")
			call_shuttle_proc(null, "")
			if (bloodstone)
				narsie = new(bloodstone.loc)

/datum/faction/bloodcult/IsSuccessful()
	return cult_win

/datum/faction/bloodcult/GetScoreboard()
	. = ..()
	//TODO

/datum/faction/bloodcult/proc/calculate_eclipse_rate()
	eclipse_increments = 0
	for (var/datum/role/cultist/R in members)
		var/mob/M = R.antag.current
		if (isliving(M) && !M.isDead())
			eclipse_increments += R.get_eclipse_increment()

/datum/faction/bloodcult/process()
	..()
	if (cultist_cap > 1) //The first call occurs in OnPostSetup()
		UpdateCap()

	switch(stage)
		if (BLOODCULT_STAGE_NORMAL)
			//if there is at least one cultist alive, the eclipse comes forward
			for (var/datum/role/R in members)
				var/mob/M = R.antag.current
				calculate_eclipse_rate()
				if (isliving(M) && !M.isDead())
					//TODO: chaplain's countersmeasures can slow down it down, but not completely halt it.
					//we calculate the progress relative to the time since the last process so the overall time is independant from server lag and shit
					delta = 1
					if (last_process_time && (last_process_time < world.time))//carefully dealing with midnight rollover
						delta = (world.time - last_process_time)
						if(SSticker.initialized)
							delta /= SSticker.wait
					last_process_time = world.time

					eclipse_progress += max(0.1, eclipse_increments - eclipse_countermeasures) * delta
					if (eclipse_progress >= eclipse_target)
						stage(BLOODCULT_STAGE_READY)
					break
		if (BLOODCULT_STAGE_READY)
			if (sun.eclipse == ECLIPSE_OVER)
				stage(BLOODCULT_STAGE_MISSED)
		if (BLOODCULT_STAGE_ECLIPSE)
			bloodstone.update_icon()
			if (world.time >= bloodstone_target_time)
				stage(BLOODCULT_STAGE_NARSIE)
		if (BLOODCULT_STAGE_DEFEATED)
			..()
		if (BLOODCULT_STAGE_NARSIE)
			call_shuttle_proc(null, "")


#define HUDICON_BLINKDURATION 10
/datum/faction/bloodcult/update_hud_icons(var/offset = 0,var/factions_with_icons = 0)
	..()
	for(var/mob/living/simple_animal/astral_projection/AP in astral_projections)
		for(var/datum/role/R_target in members)
			if(R_target.antag && R_target.antag.current)
				var/imageloc = R_target.antag.current
				if(istype(R_target.antag.current.loc,/obj/mecha))
					imageloc = R_target.antag.current.loc
				var/hud_icon = R_target.logo_state//the icon is based on the member's role
				if (!(R_target.logo_state in hud_icons))
					hud_icon = hud_icons[1]//if the faction doesn't recognize the role, it'll just give it a default one.
				var/image/I = image('icons/role_HUD_icons.dmi', loc = imageloc, icon_state = hud_icon)
				I.pixel_x = 20 * PIXEL_MULTIPLIER
				I.pixel_y = 20 * PIXEL_MULTIPLIER
				I.plane = ANTAG_HUD_PLANE
				I.appearance_flags |= RESET_COLOR|RESET_ALPHA
				if (factions_with_icons > 1)
					animate(I, layer = 1, time = 0.1 + offset * HUDICON_BLINKDURATION, loop = -1)
					animate(layer = 0, time = 0.1)
					animate(layer = 0, time = HUDICON_BLINKDURATION)
					animate(layer = 1, time = 0.1)
					animate(layer = 1, time = 0.1 + HUDICON_BLINKDURATION*(factions_with_icons - 1 - offset))
				if (AP.client)
					AP.client.images += I
				if (R_target.antag.current.client)
					R_target.antag.current.client.images += AP.hudicon
		for(var/mob/living/simple_animal/astral_projection/PA in astral_projections)
			if (AP.client)
				AP.client.images += PA.hudicon
			if ((AP != PA) && PA.client)
				PA.client.images += AP.hudicon

#undef HUDICON_BLINKDURATION


/datum/faction/bloodcult/proc/UpdateCap()
	var/living_players = 0
	var/new_cap = 0
	for (var/mob/M in player_list)
		if (!M.client)
			continue
		if (istype(M,/mob/new_player))
			continue
		if (M.stat != DEAD)
			living_players++
	new_cap =  clamp(round(living_players / 3),min_cultist_cap,max_cultist_cap)
	if (new_cap > cultist_cap)
		cultist_cap = new_cap
		for (var/datum/role/R in members)
			var/mob/M = R.antag.current
			to_chat(M, "<span class='sinister'>The station population is now large enough for <span class='userdanger'>[cultist_cap]</span> cultists, plus one of each construct types.</span>")

/datum/faction/bloodcult/proc/CanConvert()
	var/list/free_construct_slots = list()
	var/cultist_count = 0
	for (var/datum/role/R in members)
		var/mob/M = R.antag.current
		//The first construct of each type doesn't take up a slot.
		if (istype(M, /mob/living/simple_animal/construct))
			var/mob/living/simple_animal/construct/C = M
			if (!(C.construct_type in free_construct_slots))
				free_construct_slots += C.construct_type
				continue
		//Living Humans, Shades and extra Constructs all count.
		if (isliving(M))
			if (!M.isDead())
				cultist_count += 1

	return (cultist_count < cultist_cap)

/datum/faction/bloodcult/HandleRecruitedRole(var/datum/role/R)
	. = ..()
	if (cult_reminders.len)
		to_chat(R.antag.current, "<span class='notice'>Other cultists have shared some of their knowledge. It will be stored in your memory (check your Notes under the IC tab).</span>")
	for (var/reminder in cult_reminders)
		R.antag.store_memory("Shared Cultist Knowledge: [reminder].")
	previously_converted |= R.antag

/datum/faction/bloodcult/AdminPanelEntry(var/datum/admins/A)
	var/list/dat = ..()

	dat += "<br>"
	dat += "<a href='?src=\ref[src];unlockRitual=1'>\[Unlock Ritual\]</A><br>"
	dat += "<br>"

	return dat

/datum/faction/bloodcult/Topic(href, href_list)
	..()

	if(!usr.check_rights(R_ADMIN))
		message_admins("[usr] tried to access bloodcult faction Topic() without permissions.")
		return
	//TODO: let admins change and lock cultist cap


/datum/faction/bloodcult/HandleNewMind(var/datum/mind/M)
	. = ..()
	M.special_role = "Cultist"

/datum/faction/bloodcult/OnPostSetup()
	cult_founding_time = world.time
	initialize_rune_words()
	AppendObjective(/datum/objective/bloodcult)
	for (var/datum/role/cultist/R in members)
		var/mob/M = R.antag.current
		to_chat(M, "<span class='sinister'>Our communion must remain small and secretive until we are confident enough.</span>")
		previously_converted |= R.antag
	UpdateCap()
	if (cultist_cap < 9)
		for (var/datum/role/R in members)
			var/mob/M = R.antag.current
			to_chat(M, "<span class='sinister'>This number might rise up to 9 as more people arrive aboard the station. The first Artificer, Wraith, and Juggernaut each do not take up a slot. Check your panel to the left to set your role and get more information.</span>")
	AnnounceObjectives()
	..()


/datum/faction/bloodcult/proc/add_bloody_floor(var/turf/T)
	if (!istype(T))
		return
	if(T && (T.z == map.zMainStation))//F I V E   T I L E S
		if(!(locate("\ref[T]") in bloody_floors))
			bloody_floors[T] = T


/datum/faction/bloodcult/proc/remove_bloody_floor(var/turf/T)
	if (!istype(T))
		return
	bloody_floors -= T


/datum/faction/bloodcult/proc/FindSacrificeTarget()
	var/list/possible_targets = list()
	var/list/backup_targets = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(iscultist(player))
			continue
		//They may be dead, but we only need their flesh
		var/turf/player_turf = get_turf(player)
		if(player_turf.z != map.zMainStation)//We only look for people currently aboard the station
			continue
		var/is_implanted = player.is_loyalty_implanted()
		if(is_implanted || isReligiousLeader(player))
			possible_targets += player
		else
			backup_targets += player

	if(possible_targets.len <= 0) // If there are only non-implanted players left on the station, we'll have to sacrifice one of them
		if (backup_targets.len <= 0)
			message_admins("Blood Cult: Could not find a suitable sacrifice target.")
			log_admin("Blood Cult: Could not find a suitable sacrifice target.")
			return null
		else
			sacrifice_target = pick(backup_targets)
	else
		sacrifice_target = pick(possible_targets)
	return sacrifice_target

/proc/eclipse_bonus(var/mob/user, var/bonus = 0, var/method = "unknown")
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!istype(cult))
		return
	if (cult.stage != BLOODCULT_STAGE_NORMAL)
		return//we only track bonus points if they're added when it matters

	cult.eclipse_increments += bonus

	if (user.mind)//minds are unique and never deleted unlike roles or mobs, so they're great for tracking.
		if (user.mind in cult.eclipse_contributors)
			cult.eclipse_contributors[user.mind] += bonus
		else
			cult.eclipse_contributors[user.mind] = bonus
