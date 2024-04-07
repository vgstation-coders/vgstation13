/datum/role/cultist
	id = CULTIST
	name = "Cultist"
	required_pref = CULTIST
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chief Engineer",
						"Chief Medical Officer", "Research Director", "Chaplain", "Head of Personnel",
						"Internal Affairs Agent", "Merchant")
	logo_state = "cult-logo"
	greets = list(GREET_DEFAULT,GREET_CUSTOM,GREET_ROUNDSTART,GREET_ADMINTOGGLE)
	default_admin_voice = "<span class='danger'>Nar-Sie</span>" // Nar-Sie's name always appear in red in the chat, makes it stand out.
	admin_voice_style = "sinister"
	admin_voice_say = "murmurs..."
	var/list/tattoos = list()
	var/holywarning_cooldown = 0
	var/list/conversion = list()
	var/second_chance = 1
	var/datum/deconversion_ritual/deconversion = null

	//writing runes
	var/rune_blood_cost = 1	// How much blood spent per rune word written
	var/verbose = FALSE	// Used by the rune writing UI to avoid message spam

	var/cultist_role = CULTIST_ROLE_NONE // Because the role might change on the fly and we don't want to set everything again each time, better not start dealing with subtypes
	var/arch_cultist = FALSE	// same as above

	var/time_role_changed_last = 0

	var/datum/role/cultist/mentor = null
	var/list/acolytes = list()

	var/devotion = 0
	var/rank = DEVOTION_TIER_0
	/*
		rank 1: 100
		rank 2: 500
		rank 3: 1000
		rank 4: 2000
	*/

	var/blood_pool = FALSE

/datum/role/cultist/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id)
	..()
	wikiroute = role_wiki[CULTIST]

/datum/role/cultist/OnPostSetup(var/laterole = FALSE)
	. = ..()
	if(!.)
		return

	update_cult_hud()
	antag.current.add_language(LANGUAGE_CULT)

/datum/role/cultist/RemoveFromRole(var/datum/mind/M)
	antag.current.remove_language(LANGUAGE_CULT)
	remove_cult_hud()
	for(var/spell/cult/spell_to_remove in antag.current.spell_list)
		antag.current.remove_spell(spell_to_remove)
	if (src in blood_communion)
		blood_communion.Remove(src)
	DropMentorship()
	if (conversion.len > 0)
		var/conv = pick(conversion)
		switch (conv)
			if ("converted")
				to_chat(antag.current, "<span class='sinister'>Your memories of the cult gradually fade away. You remember getting converted by [conversion[conv]], but nothing else.</span>")
			if ("resurrected")
				to_chat(antag.current, "<span class='sinister'>Your memories of the cult gradually fade away. You remember getting resurrected by [conversion[conv]], but nothing else.</span>")
			if ("soulstone")
				to_chat(antag.current, "<span class='sinister'>Your memories of the cult gradually fade away. You remember having your soul captured by [conversion[conv]], but nothing else.</span>")
			if ("altar")
				to_chat(antag.current, "<span class='sinister'>Your memories of the cult gradually fade away. You do not remember anything, not even who you were prior.</span>")
			if ("sacrifice")
				to_chat(antag.current, "<span class='sinister'>Your memories of the cult gradually fade away. You do not remember anything other than having had your body sacrificed at some point.</span>")
			else
				to_chat(antag.current, "<span class='sinister'>Your memories of the cult gradually fade away. You do not remember anything.</span>")
	else
		to_chat(antag.current, "<span class='sinister'>Your memories of the cult gradually fade away. You do not remember anything.</span>")
	..()
	if (faction)
		faction.members -= src
	update_faction_icons()

/datum/role/cultist/PostMindTransfer(var/mob/living/new_character)
	. = ..()
	if (issilicon(new_character))
		to_chat(new_character, "<span class='userdanger'>As the silicon directives override your free will, your connection to the cult is shattered. You are to follow your new master's commands and help them in their goal.</span>")
		Drop()
		return
	update_cult_hud()
	antag.current.add_language(LANGUAGE_CULT)

/datum/role/cultist/loggedOutHow()
	for (var/mob/living/simple_animal/astral_projection/AP in astral_projections)
		if (AP.key == antag.key)
			return {"<a href='?_src_=holder;adminplayeropts=\ref[AP]'>astral projecting</a>"}
	return "logged out"

/datum/role/cultist/process()
	..()
	if (holywarning_cooldown > 0)
		holywarning_cooldown--
	if ((cultist_role == CULTIST_ROLE_ACOLYTE) && !mentor)
		FindMentor()

	if (faction)
		var/datum/faction/bloodcult/cult = faction
		switch(cult.stage)
			if (BLOODCULT_STAGE_READY)
				antag.current.add_particles("Cult Smoke")
				antag.current.add_particles("Cult Smoke2")
				if (cult.tear_ritual && cult.tear_ritual.dance_count)
					var/count = clamp(cult.tear_ritual.dance_count / 400, 0.01, 0.6)
					antag.current.adjust_particles("spawning",count,"Cult Smoke")
					antag.current.adjust_particles("spawning",count,"Cult Smoke2")
				else
					if (prob(1))
						antag.current.adjust_particles("spawning",0.05,"Cult Smoke")
						antag.current.adjust_particles("spawning",0.05,"Cult Smoke2")
					else
						antag.current.adjust_particles("spawning",0,"Cult Smoke")
						antag.current.adjust_particles("spawning",0,"Cult Smoke2")
			if (BLOODCULT_STAGE_MISSED)
				antag.current.remove_particles("Cult Smoke")
				antag.current.remove_particles("Cult Smoke2")
			if (BLOODCULT_STAGE_ECLIPSE)
				antag.current.add_particles("Cult Smoke")
				antag.current.add_particles("Cult Smoke2")
				antag.current.adjust_particles("spawning",0.6,"Cult Smoke")
				antag.current.adjust_particles("spawning",0.6,"Cult Smoke2")
				antag.current.add_particles("Cult Halo")
				antag.current.adjust_particles("icon_state","cult_halo[get_devotion_rank()]","Cult Halo")
			if (BLOODCULT_STAGE_DEFEATED)
				antag.current.add_particles("Cult Smoke")
				antag.current.add_particles("Cult Smoke2")
				antag.current.adjust_particles("spawning",0.19,"Cult Smoke")
				antag.current.adjust_particles("spawning",0.21,"Cult Smoke2")
				antag.current.add_particles("Cult Halo")
				antag.current.adjust_particles("color","#00000066","Cult Halo")
				antag.current.adjust_particles("icon_state","cult_halo[get_devotion_rank()]","Cult Halo")
			if (BLOODCULT_STAGE_NARSIE)
				antag.current.add_particles("Cult Smoke")
				antag.current.add_particles("Cult Smoke2")
				antag.current.adjust_particles("spawning",0.6,"Cult Smoke")
				antag.current.adjust_particles("spawning",0.6,"Cult Smoke2")
				antag.current.add_particles("Cult Halo")
				antag.current.adjust_particles("icon_state","cult_halo[get_devotion_rank()]","Cult Halo")


// 2022 - Commenting out some part of the greeting message and spacing it out a bit.
//  Getting converted floods the chat with a lot of unncessary information

/datum/role/cultist/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	to_chat(antag.current, "<br>")
	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'><font size=3>You are a cultist of <span class='danger'><font size=3>Nar-Sie</font></span>!</font><br>
				I, the Geometer of Blood, want you to drag this station into the blood realm.<br>
				You've managed to get a job here, and the time has come to put our plan into motion.<br>
				An Eclipse will soon arrive which will weaken this station's ties to reality, giving us a window of time to perform the Tear Reality ritual.<br>
				Performing occult activities will hasten its arrival. Consult the Cult panel to track how much time is left, as well as the state of the Cult.<br>
				Until the Eclipse arrives, work with your peers to disrupt the crew and increase your dominion over the station!<br>
				But first of all, use the Cult panel to choose a role that fits you. You may change it later.<br>
				</span>"})
		if (GREET_ADMINTOGGLE)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
			to_chat(antag.current, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>[custom]</span>")
		if (GREET_CONVERTED)
			to_chat(antag.current, "<span class='sinister'>You feel like you've broken past the veil of reality, your mind has seen worlds from beyond this plane, you've listened to the words of the Geometer of Blood for what felt like both an instant and ages, and now share both his knowledge and his ambition.</span>")
			to_chat(antag.current, "<span class='sinister'>The Cult of Nar-Sie now counts you as its newest member. Your fellow cultists will guide you.</span>")
			to_chat(antag.current,"<b>The first thing you might want to do is set your role from the panel to the left, then summon a tome (<span class='danger'>See Blood Hell</span>) to see the available runes and learn their uses.</b>")
		if (GREET_PAMPHLET)
			to_chat(antag.current, "<span class='sinister'>Wow, that pamphlet was very convincing, in fact you're like totally a cultist now, hail Nar-Sie!</span>")//remember, debug item
		if (GREET_SOULSTONE)
			to_chat(antag.current, "<span class='sinister'>Dark energies corrupt your soul, as the blood stone grants you a window to peer through the veil, you have become a cultist!</span>")
		if (GREET_SOULBLADE)
			to_chat(antag.current, "<span class='sinister'>Your soul has made its way into the blade's soul gem! The dark energies of the altar forge your mind into an instrument of the cult of Nar-Sie, be of assistance to your fellow cultists.</span>")
		if (GREET_RESURRECT)
			to_chat(antag.current, "<span class='sinister'>You were resurrected from beyond the veil by the followers of Nar-Sie, and are already familiar with their rituals! You have now joined their ranks as a cultist.</span>")
		if (GREET_SACRIFICE)
			to_chat(antag.current, "<span class='sinister'>The cult has spared your soul following the sacrifice of your body. You are now living as a shade inside the Soul Blade that nailed your body to the altar. You are to help the cult in their endeavours to repay their graciousness.</span>")
		else
			if (faction && faction.ID == BLOODCULT)
				to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You are cultist, from the cult of Nar-Sie, the Geometer of Blood.</span>")
			else
				to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You are a lone cultist. You've spent years studying the language of Nar-Sie, but haven't associated with his followers.</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
	//to_chat(antag.current, "<span class='sinister'>You find yourself to be well-versed in the runic alphabet of the cult.</span>")
	to_chat(antag.current, "<br>")
	spawn(1)
		if (faction)
			/*
			var/datum/objective_holder/OH = faction.objective_holder
			if (OH.objectives.len > 0)
				var/datum/objective/O = OH.objectives[OH.objectives.len] //Gets the latest objective.
				to_chat(antag.current,"<span class='danger'>[O.name]</span><b>: [O.explanation_text]</b>")
				to_chat(antag.current,"<b>First of all though, choose a role that fits you best using the button on the left.</b>")
			*/
			if (greeting != GREET_ROUNDSTART)
				var/datum/faction/bloodcult/cult = faction
				to_chat(antag.current, "<span class='sinister'>The station population is currently large enough for <span class='userdanger'>[cult.cultist_cap]</span> cultists.</span>")

/datum/role/cultist/update_antag_hud()
	update_cult_hud()

/datum/role/cultist/proc/update_cult_hud()
	var/mob/M = antag?.current
	if(M)
		M.DisplayUI("Cultist")
		if (M.client && M.hud_used)
			if (isshade(M))
				if (istype(M.loc,/obj/item/weapon/melee/soulblade))
					M.DisplayUI("Soulblade")
					M.client.screen |= list(M.healths2)
				else
					M.client.screen -= list(M.healths2)

/datum/role/cultist/proc/remove_cult_hud()
	var/mob/M = antag?.current
	if(M)
		M.HideUI("Cultist")
		M.HideUI("Bloodcult Runes")

/datum/role/cultist/extraPanelButtons()
	var/dat = ""
	if (mentor)
		dat = "<br>Currently under the mentorship of <b>[mentor.antag.name]/([mentor.antag.key])</b><br>"
	if (acolytes.len)
		dat += "<br>Currently mentoring "
		for (var/datum/role/cultist/acolyte in acolytes)
			dat += "<b>[acolyte.antag.name]/([acolyte.antag.key])</b>, "
		dat += "<br>"
	return dat

/datum/role/cultist/ExtraScoreboard()
	switch(devotion)
		if (2000 to INFINITY)
			return " <font color='#FF0000'>[devotion]</font>"
		if (1000 to 2000)
			return " <font color='#FF8800'>[devotion]</font>"
		if (500 to 1000)
			return " <font color='#FFFF00'>[devotion]</font>"
		if (100 to 500)
			return " <font color='#88FF00'>[devotion]</font>"
		else
			return " <font color='#00FF00'>[devotion]</font>"

/datum/role/cultist/Drop()
	DropMentorship()
	antag.current.remove_particles("Cult Smoke")
	antag.current.remove_particles("Cult Smoke2")
	antag.current.remove_particles("Cult Halo")
	if (faction)
		var/datum/faction/bloodcult/C = faction
		C.deconverted[antag.name] = devotion
	..()

/datum/role/cultist/proc/DropMentorship()
	if (mentor)
		to_chat(antag.current,"<span class='warning'>You have ended your mentorship under [mentor.antag.name].</span>")
		to_chat(mentor.antag.current,"<span class='warning'>[antag.name] has ended their mentorship under you.</span>")
		message_admins("[antag.key]/([antag.name]) has ended their mentorship under [mentor.antag.name]")
		log_admin("[antag.key]/([antag.name]) has ended their mentorship under [mentor.antag.name]")
		mentor.acolytes -= src
		mentor = null
	if (acolytes.len > 0)
		for (var/datum/role/cultist/acolyte in acolytes)
			to_chat(antag.current,"<span class='warning'>You have ended your mentorship of [acolyte.antag.name].</span>")
			to_chat(acolyte.antag.current,"<span class='warning'>[antag.name] has ended their mentorship.</span>")
			message_admins("[antag.key]/([antag.name]) has ended their mentorship of [acolyte.antag.name]")
			log_admin("[antag.key]/([antag.name]) has ended their mentorship of [acolyte.antag.name]")
			acolyte.mentor = null
		acolytes = list()

/datum/role/cultist/proc/ChangeCultistRole(var/new_role)
	if (!new_role)
		return
	var/datum/faction/bloodcult/cult = faction
	if ((cultist_role == CULTIST_ROLE_MENTOR) && cult)
		cult.mentor_count--

	cultist_role = new_role

	DropMentorship()

	switch(cultist_role)
		if (CULTIST_ROLE_ACOLYTE)
			message_admins("BLOODCULT: [antag.key]/([antag.name]) has become a cultist acolyte.")
			log_admin("BLOODCULT: [antag.key]/([antag.name]) has become a cultist acolyte.")
			logo_state = "cult-apprentice-logo"
			FindMentor()
			if (!mentor)
				message_admins("BLOODCULT: [antag.key]/([antag.name]) couldn't find a mentor.")
				log_admin("BLOODCULT: [antag.key]/([antag.name]) couldn't find a mentor.")
		if (CULTIST_ROLE_HERALD)
			message_admins("BLOODCULT: [antag.key]/([antag.name]) has become a cultist herald.")
			log_admin("BLOODCULT: [antag.key]/([antag.name]) has become a cultist herald.")
			logo_state = "cult-logo"
		if (CULTIST_ROLE_MENTOR)
			message_admins("BLOODCULT: [antag.key]/([antag.name]) has become a cultist mentor.")
			log_admin("BLOODCULT: [antag.key]/([antag.name]) has become a cultist mentor.")
			logo_state = "cult-master-logo"
			if (cult)
				cult.mentor_count++
		else
			logo_state = "cult-logo"
			cultist_role = CULTIST_ROLE_NONE
	if (cult)
		cult.update_hud_icons()
	if (antag.current)//refreshing the UI so the current role icon appears on the cult panel button and role change button.
		antag.current.DisplayUI("Cultist Left Panel")
		antag.current.DisplayUI("Cult Panel")
	time_role_changed_last = world.time

/datum/role/cultist/proc/FindMentor()
	var/datum/faction/bloodcult/cult = faction
	if (!cult || !cult.mentor_count)
		return
	var/datum/role/cultist/potential_mentor
	var/min_acolytes = ARBITRARILY_LARGE_NUMBER
	for (var/datum/role/cultist/C in cult.members)
		if (!C.antag.current || C.antag.current.isDead())
			continue
		if (C.cultist_role == CULTIST_ROLE_MENTOR)
			if (C.acolytes.len < min_acolytes || (C.acolytes.len == min_acolytes && prob(50)))
				min_acolytes = C.acolytes.len
				potential_mentor = C

	if (potential_mentor)
		mentor = potential_mentor
		potential_mentor.acolytes |= src
		to_chat(antag.current, "<span class='sinister'>You are now in a mentorship under <span class='danger'>[mentor.antag.name], the [mentor.antag.assigned_role=="MODE" ? (mentor.antag.special_role) : (mentor.antag.assigned_role)]</span>. Seek their help to learn the ways of our cult.</span>")
		to_chat(mentor.antag.current, "<span class='sinister'>You are now mentoring <span class='danger'>[antag.name], the [antag.assigned_role=="MODE" ? (antag.special_role) : (antag.assigned_role)]</span>. </span>")
		message_admins("[mentor.antag.key]/([mentor.antag.name]) is now mentoring [antag.name]")
		log_admin("[mentor.antag.key]/([mentor.antag.name]) is now mentoring [antag.name]")

/datum/role/cultist/proc/get_devotion_rank()
	switch(devotion)
		if (2000 to INFINITY)
			return DEVOTION_TIER_4
		if (1000 to 2000)
			return DEVOTION_TIER_3
		if (500 to 1000)
			return DEVOTION_TIER_2
		if (100 to 500)
			return DEVOTION_TIER_1
		if (0 to 100)
			return DEVOTION_TIER_0

/datum/role/cultist/proc/get_devotion(var/acquired_devotion = 0, var/tier = DEVOTION_TIER_0)
	if (faction)
		switch(faction.stage)
			if (BLOODCULT_STAGE_DEFEATED)//no more devotion gains if the bloodstone has been destroyed
				return
			if (BLOODCULT_STAGE_NARSIE)//or narsie has risen
				return

	//The more devotion the cultist has acquired, the less devotion they obtain from lesser rituals
	switch (get_devotion_rank() - tier)
		if (3 to INFINITY)
			return//until they just don't get any devotion anymore
		if (2)
			acquired_devotion /= 10
		if (1)
			acquired_devotion /= 2
	devotion += acquired_devotion
	check_rank_upgrade()

	if (faction)
		var/datum/faction/bloodcult/cult = faction
		cult.total_devotion += acquired_devotion

/datum/role/cultist/proc/check_rank_upgrade()
	var/new_rank = get_devotion_rank()
	if (new_rank > rank)
		rank = new_rank
		if (iscarbon(antag.current))//constructs and shades cannot make use of those powers so no point informing them.
			to_chat(antag.current, "<span class='sinisterbig'>As your devotion to the cult increases, a new power awakens inside you.</span>")
			switch(rank)
				if (DEVOTION_TIER_1)
					to_chat(antag.current, "<span class='danger'>Blood Pooling</span>")
					to_chat(antag.current, "<b>Any blood cost required by a cult rune or ritual will now be reduced and split with other cult members that have attained this power. You can toggle blood pooling as needed.</b>")
					GiveTattoo(/datum/cult_tattoo/bloodpool)
				if (DEVOTION_TIER_2)
					to_chat(antag.current, "<span class='danger'>Blood Dagger</span>")
					to_chat(antag.current, "<b>You can now form a dagger using your own blood (or pooled blood, any blood that you can get your hands on). Hitting someone will let the dagger steal some of their blood, while sheathing the dagger will let you recover all the stolen blood. Throwing the dagger deals damage based on how much blood it carries, and nails the victim down, forcing them to pull the dagger out to move away.</b>")
					GiveTattoo(/datum/cult_tattoo/dagger)
				if (DEVOTION_TIER_3)
					to_chat(antag.current, "<span class='danger'>Runic Skin</span>")
					to_chat(antag.current, "<b>You can now fuse a talisman that has a rune imbued or attuned to it with your skin, granting you the ability to cast this talisman hands free, as long as you are conscious and not under the effects of Holy Water.</b>")
					GiveTattoo(/datum/cult_tattoo/rune_store)
				if (DEVOTION_TIER_4)
					to_chat(antag.current, "<span class='danger'>Shortcut Sigil</span>")
					to_chat(antag.current, "<b>Apply your palms on a wall to draw a sigil on it that lets you and any ally pass through it.</b>")
					GiveTattoo(/datum/cult_tattoo/shortcut)
	antag.current.DisplayUI("Cultist Right Panel")

/datum/role/cultist/proc/get_eclipse_increment()
	switch(get_devotion_rank())
		if (DEVOTION_TIER_0)
			return 0.10
		if (DEVOTION_TIER_1)
			return 0.10 + (devotion-100)*0.000375
		if (DEVOTION_TIER_2)
			return 0.25 + (devotion-500)*0.0003
		if (DEVOTION_TIER_3)
			return 0.40 + (devotion-1000)*0.0001
		if (DEVOTION_TIER_4)
			return 0.50 + (devotion-2000)*0.00005

/datum/role/cultist/handle_reagent(var/reagent_id)
	var/mob/living/carbon/human/H = antag.current
	if (!istype(H))
		return
	if (reagent_id == INCENSE_HAREBELLS)
		H.eye_blurry = max(H.eye_blurry, 12)
		H.Dizzy(12)
		H.stuttering = max(H.stuttering, 12)
		H.Jitter(12)

/datum/role/cultist/handle_splashed_reagent(var/reagent_id)//also proc'd when holy water is drinked or ingested in any way
	var/mob/living/carbon/human/H = antag.current
	if (!istype(H))
		return
	if (reagent_id == HOLYWATER)
		if (holywarning_cooldown <= 0)
			holywarning_cooldown = 5
			to_chat(H, "<span class='danger'>The cold touch of holy water makes your head spin, you're having trouble walking straight.</span>")

	if (reagent_id == HOLYWATER || reagent_id == INCENSE_HAREBELLS)
		H.eye_blurry = max(H.eye_blurry, 12)
		H.Dizzy(12)
		H.stuttering = max(H.stuttering, 12)
		H.Jitter(12)

/datum/role/cultist/proc/write_rune(var/word_to_draw)
	var/mob/living/user = antag.current

	if (user.incapacitated())
		return

	var/muted = user.occult_muted()
	if (muted)
		to_chat(user,"<span class='danger'>You find yourself unable to focus your mind on the words of Nar-Sie.</span>")
		return

	if(!istype(user.loc, /turf))
		to_chat(user, "<span class='warning'>You do not have enough space to write a proper rune.</span>")
		return

	var/turf/T = get_turf(user)
	var/obj/effect/rune/rune = locate() in T

	if(rune)
		if (rune.invisibility == INVISIBILITY_OBSERVER)
			to_chat(user, "<span class='warning'>You can feel the presence of a concealed rune here. You have to reveal it before you can add more words to it.</span>")
			return
		else if (rune.word1 && rune.word2 && rune.word3)
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return

	var/datum/rune_word/word = rune_words[word_to_draw]
	var/list/rune_blood_data = use_available_blood(user, rune_blood_cost, feedback = verbose)
	if (rune_blood_data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		return

	if (verbose)
		if(rune)
			user.visible_message("<span class='warning'>\The [user] chants and paints more symbols on the floor.</span>",\
					"<span class='warning'>You add another word to the rune.</span>",\
					"<span class='warning'>You hear chanting.</span>")
		else
			user.visible_message("<span class='warning'>\The [user] begins to chant and paint symbols on the floor.</span>",\
					"<span class='warning'>You begin drawing a rune on the floor.</span>",\
					"<span class='warning'>You hear some chanting.</span>")

	if(!user.checkTattoo(TATTOO_SILENT))
		user.whisper("...[word.rune]...")

	if(rune)
		if(rune.word1 && rune.word2 && rune.word3)
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return
	get_devotion(10, DEVOTION_TIER_0)
	write_rune_word(get_turf(user), word, rune_blood_data["blood"], caster = user)
	verbose = FALSE


/datum/role/cultist/proc/erase_rune()
	var/mob/living/user = antag.current
	if (!istype(user))
		return

	if (user.incapacitated())
		return

	var/turf/T = get_turf(user)
	var/obj/effect/rune/rune = locate() in T

	if (rune && rune.invisibility == INVISIBILITY_OBSERVER)
		to_chat(user, "<span class='warning'>You can feel the presence of a concealed rune here, you have to reveal it before you can erase words from it.</span>")
		return

	var/removed_word = erase_rune_word(get_turf(user))
	if (removed_word)
		to_chat(user, "<span class='notice'>You retrace your steps, carefully undoing the lines of the [removed_word] rune.</span>")
	else
		to_chat(user, "<span class='warning'>There aren't any rune words left to erase.</span>")

/datum/role/cultist/proc/GiveTattoo(var/type)
	if(locate(type) in tattoos)
		return
	var/datum/cult_tattoo/T = new type
	tattoos[T.name] = T
	update_cult_hud()
	T.getTattoo(antag.current)
	//anim(target = antag.current, a_icon = 'icons/effects/32x96.dmi', flick_anim = "tattoo_receive", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	sleep(1)
	antag.current.update_mutations()
	var/atom/movable/overlay/tattoo_markings = anim(target = antag.current, a_icon = 'icons/mob/cult_tattoos.dmi', flick_anim = "[T.icon_state]_mark", sleeptime = 30, lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	animate(tattoo_markings, alpha = 0, time = 30)


/datum/role/cultist/proc/MakeArchCultist()
	var/datum/faction/bloodcult/B = faction
	if(!B || !istype(B))
		return
	arch_cultist = TRUE
