
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

	var/cult_founding_time = 0
	var/last_process_time = 0
	var/delta = 1

	var/eclipse_progress = 0
	var/eclipse_target = 1800
	var/eclipse_window = 10 MINUTES
	var/eclipse_increments = 0
	var/eclipse_contributors = list()//associative list: /mind = score

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

	var/twister = FALSE

	var/list/deconverted = list()//tracking for scoreboard purposes

	var/datum/bloodcult_ritual/bloodspill_ritual = null

	var/list/possible_rituals = list()
	var/list/rituals = list(RITUAL_FACTION_1,RITUAL_FACTION_2,RITUAL_FACTION_3)

	var/countdown_to_first_rituals = 5

/datum/faction/bloodcult/stage(var/value)
	stage = value
	switch(stage)
		if (BLOODCULT_STAGE_READY)
			eclipse_trigger_cult()
			for(var/obj/structure/cult/spire/S in cult_spires)
				S.upgrade(3)
		if (BLOODCULT_STAGE_MISSED)
			for (var/datum/role/cultist in members)
				var/mob/M = cultist.antag.current
				if (M)
					to_chat(M, "<span class='sinister'>The Eclipse has passed. You won't be able to tear reality aboard this station anymore. Escape the station alive with your fellow cultists so you may try again another day.</span>")
			for(var/obj/structure/cult/spire/S in cult_spires)
				S.upgrade(1)
		if (BLOODCULT_STAGE_ECLIPSE)
			update_all_parallax()
			var/datum/zLevel/ZL = map.zLevels[map.zMainStation]
			ZL.transitionLoops = TRUE
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
			var/datum/zLevel/ZL = map.zLevels[map.zMainStation]
			ZL.transitionLoops = FALSE
			command_alert(/datum/command_alert/eclipse_bloodstone_broken)
			if (sun.eclipse == ECLIPSE_ONGOING)//destruction of the blood stone instantly ends the Eclipse
				sun.eclipse_manager.eclipse_end()
			for (var/obj/effect/rune/R in runes)
				qdel(R)//new runes can be written, but any pre-existing one gets nuked.
			cultist_cap = 0
			spawn()
				for(var/mob/living/simple_animal/M in mob_list)
					if(!M.client && (M.faction == "cult"))
						M.death()
					CHECK_TICK
			spawn()
				for (var/mob/dead/observer/O in player_list)
					O.decultify()
					sleep(rand(1,5))
			for(var/obj/structure/cult/spire/S in cult_spires)
				S.upgrade(1)
			spawn(5 SECONDS)
				for (var/datum/role/cultist in members)
					var/mob/M = cultist.antag.current
					to_chat(M, "<span class='sinister'>With the blood stone destroyed, the tear through the veil has been mended, and a great deal of occult energies have been purged from the Station.</span>")
					sleep(3 SECONDS)
					to_chat(M, "<span class='sinister'>Your connection to the Geometer of Blood has grown weaker and you can no longer recall the runes as easily as you did before. Maybe an Arcane Tome can alleviate the problem.</span>")
					sleep(3 SECONDS)
					to_chat(M, "<span class='sinister'>Lastly it seems that the toll of the ritual on your body hasn't gone away. Going unnoticed will be a lot harder.</span>")
		if (BLOODCULT_STAGE_NARSIE)
			if (bloodstone)
				ticker.StopThematic()//music stops, then resumes from Nar-Sie.
				for (var/mob/M in player_list)
					M.playsound_local(get_turf(M), 'sound/effects/tear_reality.ogg', 100, 0)
				anim(target = bloodstone.loc, a_icon = 'icons/obj/narsie.dmi', flick_anim = "narsie_spawn_anim_start", offX = -236 * PIXEL_MULTIPLIER, offY = -256 * PIXEL_MULTIPLIER, plane = NARSIE_PLANE)
				sleep(5)
				narsie = new(bloodstone.loc)
	for (var/datum/role/cultist in members)
		var/datum/mind/M = cultist.antag
		if ("Cult Panel" in M.activeUIs)
			var/datum/mind_ui/m_ui = M.activeUIs["Cult Panel"]
			if (m_ui.active)
				m_ui.Display()
		if ("Cultist Panel" in M.activeUIs)
			var/datum/mind_ui/m_ui = M.activeUIs["Cultist Panel"]
			if (m_ui.active)
				m_ui.Display()

/datum/faction/bloodcult/IsSuccessful()
	return cult_win

/datum/faction/bloodcult/GetScoreboard()
	var/dat = ""
	var/cult_won = FALSE
	var/end_message = "The cult couldn't thrive"

	if (stage == BLOODCULT_STAGE_NARSIE)
		cult_won = TRUE
		end_message = "The cult has thrived!"
	else if (stage == BLOODCULT_STAGE_DEFEATED)
		end_message = "The cult has been broken by the crew!"
	else if (stage == BLOODCULT_STAGE_ECLIPSE)
		cult_won = TRUE
		end_message = "The cult shall inherit the station!"
	else if (twister)
		end_message = "The cult unfortunately sucks at twister!"
	else if(emergency_shuttle.location == map.zCentcomm)
		var/escaped_on_shuttle = 0
		var/escaped_on_pods = 0
		var/arrested_cultists = 0

		for (var/datum/role/cultist/C in members)
			var/datum/mind/_M = C.antag
			var/mob/M = _M.current

			if (!M || M.isDead())
				continue
			if(issilicon(M))
				arrested_cultists++
				continue
			if(isbrain(M))
				continue
			var/turf/location = get_turf(M.loc)
			if(!location)
				continue

			var/datum/shuttle/S = is_on_shuttle(M)
			if(emergency_shuttle.shuttle == S)
				if(istype(location, /turf/simulated/floor/shuttle/brig))
					if(istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = M
						if(H.restrained())
							arrested_cultists++
						else
							escaped_on_shuttle++
					else if(istype(M, /mob/living/carbon))
						var/mob/living/carbon/O = M
						if (O.handcuffed)
							arrested_cultists++
						else
							escaped_on_shuttle++
					continue
				escaped_on_shuttle++
			else if(emergency_shuttle.escape_pods.Find(S))
				escaped_on_pods++

		if (escaped_on_shuttle)
			cult_won = TRUE
			end_message = "[escaped_on_shuttle] cultist[(escaped_on_shuttle > 1) ? "s":""] escaped alongside the crew to spread the cult's influence further!"
		else if (escaped_on_pods)
			end_message = "Some cultists cowardly escaped on pods to hide for another century!"
		else if (arrested_cultists)
			end_message = "The cult has been overpowered by the crew! [arrested_cultists] of them [(arrested_cultists > 1) ? "were":"was"] arrested and delivered to Nanotrasen for containment."


	dat += "<br>Accumulated devotion: [total_devotion]"

	if (cult_won)
		dat += "<br><font color='green'><B>[end_message]</B></font>"
		feedback_add_details("[ID]_success","SUCCESS")
	else
		dat += "<br><font color='red'><B>[end_message]</B></font>"
		feedback_add_details("[ID]_success","FAIL")

	dat += "<br><FONT size = 2><B>Nar-Sie's most devoted:</B></FONT><br>"

	var/list/sorted_members = list()
	for (var/datum/role/cultist/C in members)
		var/pos = sorted_members.len
		while(pos > 0)
			var/datum/role/cultist/U = sorted_members[pos]
			if (C.devotion > U.devotion)
				break
			else
				pos--
		sorted_members.Insert(pos+1, C)

	var/i = 1
	var/members_dat = ""
	for(var/datum/role/R in sorted_members)
		var/results = R.GetScoreboard()
		if(results)
			members_dat = "[results]<br>[members_dat]"
		i++

	dat += members_dat

	if (deconverted.len > 0)
		dat += "<br><FONT size = 2><B>those who turned back:</B></FONT><br>"
		i = 1
		for (var/D in deconverted)
			dat += "<br><font color='#888888'>[D] ([deconverted[D]])</font>"
			if (i < deconverted.len)
				dat += "<br>"
			i++

	stat_collection.add_faction(src)

	return dat

/datum/faction/bloodcult/proc/calculate_eclipse_rate()
	eclipse_increments = 0
	for (var/datum/role/cultist/R in members)
		var/mob/M = R.antag.current
		if (isliving(M) && !M.isDead())
			if (M.occult_muted())
				eclipse_increments -= R.get_eclipse_increment()
			else
				eclipse_increments += R.get_eclipse_increment()

/datum/faction/bloodcult/proc/assign_rituals()
	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions())
			valid_rituals += R

	if (valid_rituals.len < 3)
		return

	for (var/ritual_slot in rituals)
		var/datum/bloodcult_ritual/BR = pick(valid_rituals)
		rituals[ritual_slot] = BR
		possible_rituals -= BR
		valid_rituals -= BR
		BR.init_ritual()

	for (var/datum/role/cultist in members)
		var/datum/mind/M = cultist.antag
		if ("Cult Panel" in M.activeUIs)
			var/datum/mind_ui/m_ui = M.activeUIs["Cult Panel"]
			if (m_ui.active)
				m_ui.Display()

/datum/faction/bloodcult/proc/replace_rituals(var/slot)
	if (gcDestroyed)
		return
	if (!slot)
		return

	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions(src))
			valid_rituals += R

	if (valid_rituals.len < 1)
		return

	var/datum/bloodcult_ritual/BR = pick(valid_rituals)
	rituals[slot] = BR
	possible_rituals -= BR
	BR.init_ritual()

	for (var/datum/role/cultist in members)
		var/mob/O = cultist.antag.current
		if (O)
			to_chat(O, "<span class='sinister'>A new ritual is available...</span>")
		var/datum/mind/M = cultist.antag
		if ("Cult Panel" in M.activeUIs)
			var/datum/mind_ui/m_ui = M.activeUIs["Cult Panel"]
			if (m_ui.active)
				m_ui.Display()

/datum/faction/bloodcult/process()
	..()
	if (cultist_cap > 1) //The first call occurs in OnPostSetup()
		UpdateCap()

	switch(stage)
		if (BLOODCULT_STAGE_NORMAL)
			if (bloodspill_ritual)
				check_ritual("bloodspill", bloody_floors.len)
			//if there is at least one cultist alive, the eclipse comes forward
			for (var/datum/role/R in members)
				var/mob/M = R.antag.current
				calculate_eclipse_rate()
				if (isliving(M) && !M.isDead())
					//we calculate the progress relative to the time since the last process so the overall time is independant from server lag and shit
					delta = 1
					if (last_process_time && (last_process_time < world.time))//carefully dealing with midnight rollover
						delta = (world.time - last_process_time)
						if(SSticker.initialized)
							delta /= SSticker.wait
					last_process_time = world.time

					eclipse_progress += max(0.1, eclipse_increments) * delta
					if (eclipse_progress >= eclipse_target)
						stage(BLOODCULT_STAGE_READY)
					break
			if (countdown_to_first_rituals)
				countdown_to_first_rituals--
				if (countdown_to_first_rituals <= 0)
					assign_rituals()
					for (var/datum/role/cultist/C in members)
						C.assign_rituals()
						var/mob/M = C.antag.current
						if (M)
							to_chat(M, "<span class='sinister'>Although you can generate devotion by performing most cult activities, a couple rituals for you to perform are now available. Check the cult panel.</span>")


		if (BLOODCULT_STAGE_MISSED)
			if (bloodspill_ritual)
				check_ritual("bloodspill", bloody_floors.len)
		if (BLOODCULT_STAGE_READY)
			if (sun.eclipse == ECLIPSE_OVER)
				stage(BLOODCULT_STAGE_MISSED)
		if (BLOODCULT_STAGE_ECLIPSE)
			bloodstone.update_icon()
			if (world.time >= bloodstone_target_time)
				stage(BLOODCULT_STAGE_NARSIE)


/datum/faction/bloodcult/proc/check_ritual(var/key, var/extra)
	switch(stage)
		if (BLOODCULT_STAGE_DEFEATED)//no more devotion gains if the bloodstone has been destroyed
			return
		if (BLOODCULT_STAGE_NARSIE)//or narsie has risen
			return

	if (key && (stage != BLOODCULT_STAGE_ECLIPSE))
		for (var/ritual_slot in rituals)
			if (rituals[ritual_slot])
				var/datum/bloodcult_ritual/faction_ritual = rituals[ritual_slot]
				if (key in faction_ritual.keys)
					if (faction_ritual.key_found(extra))
						faction_ritual.complete()
						if (!faction_ritual.only_once)
							possible_rituals += faction_ritual
						rituals[ritual_slot] = null
						for (var/datum/role/cultist in members)
							var/mob/M = cultist.antag.current
							if (M)
								to_chat(M, "<span class='sinister'>Someone has completed a ritual, rewarding the entire cult...soon another ritual will take its place.</span>")
						spawn(10 MINUTES)
							replace_rituals(ritual_slot)

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
	if (stage == BLOODCULT_STAGE_DEFEATED)
		cultist_cap = 0
		return
	if (stage == BLOODCULT_STAGE_NARSIE)
		cultist_cap = 666
		return
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
	if (R.antag.name in deconverted)
		deconverted -= R.antag.name

/datum/faction/bloodcult/HandleNewMind(var/datum/mind/M)
	. = ..()
	M.special_role = "Cultist"

/datum/faction/bloodcult/OnPostSetup()
	for (var/ritual_type in bloodcult_faction_rituals)
		possible_rituals += new ritual_type()
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

//we don't really have a use for that right now but there are plans for it.
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
