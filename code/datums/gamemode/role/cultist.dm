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
				I, the Geometer of Blood, want you to thin the veil between your reality and my realm<br>
				so I can pull this place onto my plane of existence.<br>
				You've managed to get a job here, and the time has come to put our plan into motion.<br>
				However, the veil is currently so thick that I can barely bestow any power to you.<br>
				Other cultists made their way into the crew. Talk to them. <span class='danger'>Self Other Technology</span>!<br>
				Meet up with them. Raise an altar in my name. <span class='danger'>Blood Technology Join</span>!<br>
				</span>"})
		if (GREET_ADMINTOGGLE)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
			to_chat(antag.current, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>[custom]</span>")
		if (GREET_CONVERTED)
			to_chat(antag.current, "<span class='sinister'>You feel like you've broken past the veil of reality, your mind has seen worlds from beyond this plane, you've listened to the words of the Geometer of Blood for what felt like both an instant and ages, and now share both his knowledge and his ambition.</span>")
			to_chat(antag.current, "<span class='sinister'>The Cult of Nar-Sie now counts you as its newest member. Your fellow cultists will guide you.</span>")
			to_chat(antag.current,"<b>The first thing you might want to do is to summon a tome (<span class='danger'>See Blood Hell</span>) to see the available runes and learn their uses.</b>")
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

/datum/role/cultist/proc/DropMentorship()
	if (mentor)
		to_chat(antag.current,"<span class='warning'>You have ended your mentorship under [mentor.antag.name].</span>")
		to_chat(mentor.antag.current,"<span class='warning'>[antag.name] has ended their mentorship under you.</span>")
		message_admins("[antag.key]/([antag.name]) has ended their mentorship under [mentor.antag.name]")
		log_admin("[antag.key]/([antag.name]) has ended their mentorship under [mentor.antag.name]")
	if (acolytes.len > 0)
		for (var/datum/role/cultist/acolyte in acolytes)
			to_chat(antag.current,"<span class='warning'>You have ended your mentorship of [acolyte.antag.name].</span>")
			to_chat(acolyte.antag.current,"<span class='warning'>[antag.name] has ended their mentorship.</span>")
			message_admins("[antag.key]/([antag.name]) has ended their mentorship of [acolyte.antag.name]")
			log_admin("[antag.key]/([antag.name]) has ended their mentorship of [acolyte.antag.name]")

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
	if (antag.current)
		antag.current.DisplayUI("Cultist Left Panel")
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

/datum/role/cultist/handle_reagent(var/reagent_id)
	var/mob/living/carbon/human/H = antag.current
	if (!istype(H))
		return
	if (reagent_id == INCENSE_HAREBELLS)
		H.eye_blurry = max(H.eye_blurry, 12)
		H.Dizzy(12)
		H.stuttering = max(H.stuttering, 12)
		H.Jitter(12)
		/* // TODO (UPHEAVAL PART 2) stronger effects the more cult points have been accumulated
			switch (current_act)
				if (CULT_MENDED)
					H.dust()
					return
				if (CULT_PROLOGUE)
					H.eye_blurry = max(H.eye_blurry, 3)
					H.Dizzy(3)
				if (CULT_ACT_I)
					H.eye_blurry = max(H.eye_blurry, 6)
					H.Dizzy(6)
					H.stuttering = max(H.stuttering, 6)
				if (CULT_ACT_II)
					H.eye_blurry = max(H.eye_blurry, 12)
					H.Dizzy(12)
					H.stuttering = max(H.stuttering, 12)
					H.Jitter(12)
				if (CULT_ACT_III)
					H.eye_blurry = max(H.eye_blurry, 16)
					H.Dizzy(16)
					H.stuttering = max(H.stuttering, 16)
					H.Jitter(16)
					if (prob(50))
						H.Knockdown(1)
					else if (prob(50))
						H.confused = 2
					H.adjustOxyLoss(5)
				if (CULT_ACT_IV)
					H.eye_blurry = max(H.eye_blurry, 20)
					H.Dizzy(20)
					H.stuttering = max(H.stuttering, 20)
					H.Jitter(20)
					if (prob(60))
						H.Knockdown(2)
					else if (prob(60))
						H.confused = 4
					H.adjustOxyLoss(10)
					H.adjustToxLoss(5)
				if (CULT_EPILOGUE)
					H.eye_blurry = max(H.eye_blurry, 30)
					H.Dizzy(30)
					H.stuttering = max(H.stuttering, 30)
					H.Jitter(30)
					if (prob(70))
						H.Knockdown(4)
					else if (prob(70))
						H.confused = 6
					H.adjustOxyLoss(20)
					H.adjustToxLoss(10)
					*/

/datum/role/cultist/handle_splashed_reagent(var/reagent_id)//also proc'd when holy water is drinked or ingested in any way
	var/mob/living/carbon/human/H = antag.current
	if (!istype(H))
		return
	if (reagent_id == HOLYWATER)
		if (holywarning_cooldown <= 0)
			holywarning_cooldown = 5
			to_chat(H, "<span class='danger'>The cold touch of holy water makes your head spin, you're having trouble walking straight.</span>")
				/* // TODO (UPHEAVAL PART 2) stronger effects the more cult points have been accumulated
				switch (current_act)
					if (CULT_MENDED)
						to_chat(H, "<span class='danger'>The holy water permeates your skin and consumes your cursed blood like mercury digests gold.</span>")
					if (CULT_PROLOGUE)
						to_chat(H, "<span class='warning'>You feel the cold touch of holy water, but the veil is still too thick for it to be a real threat.</span>")
					if (CULT_ACT_I)
						to_chat(H, "<span class='warning'>The touch of holy water troubles your thoughts, you won't be able to cast spells under its effects.</span>")
					if (CULT_ACT_II)
						to_chat(H, "<span class='danger'>The holy water makes your head spin, you're having trouble walking straight.</span>")
					if (CULT_ACT_III)
						to_chat(H, "<span class='danger'>The holy water freezes your muscles, you find yourself short of breath.</span>")
					if (CULT_ACT_IV)
						to_chat(H, "<span class='danger'>The holy water makes you sick to your stomach.</span>")
					if (CULT_EPILOGUE)
						to_chat(H, "<span class='danger'>Even in these times, holy water proves itself capable of hindering your progression.</span>")

				*/
	if (reagent_id == HOLYWATER || reagent_id == INCENSE_HAREBELLS)
		H.eye_blurry = max(H.eye_blurry, 12)
		H.Dizzy(12)
		H.stuttering = max(H.stuttering, 12)
		H.Jitter(12)
			/* // TODO (UPHEAVAL PART 2) stronger effects the more cult points have been accumulated
			switch (current_act)
				if (CULT_MENDED)
					H.dust()
					return
				if (CULT_PROLOGUE)
					H.eye_blurry = max(H.eye_blurry, 3)
					H.Dizzy(3)
				if (CULT_ACT_I)
					H.eye_blurry = max(H.eye_blurry, 6)
					H.Dizzy(6)
					H.stuttering = max(H.stuttering, 6)
				if (CULT_ACT_II)
					H.eye_blurry = max(H.eye_blurry, 12)
					H.Dizzy(12)
					H.stuttering = max(H.stuttering, 12)
					H.Jitter(12)
				if (CULT_ACT_III)
					H.eye_blurry = max(H.eye_blurry, 16)
					H.Dizzy(16)
					H.stuttering = max(H.stuttering, 16)
					H.Jitter(16)
					if (prob(50))
						H.Knockdown(1)
					else if (prob(50))
						H.confused = 2
					H.adjustOxyLoss(5)
				if (CULT_ACT_IV)
					H.eye_blurry = max(H.eye_blurry, 20)
					H.Dizzy(20)
					H.stuttering = max(H.stuttering, 20)
					H.Jitter(20)
					if (prob(60))
						H.Knockdown(2)
					else if (prob(60))
						H.confused = 4
					H.adjustOxyLoss(10)
					H.adjustToxLoss(5)
				if (CULT_EPILOGUE)
					H.eye_blurry = max(H.eye_blurry, 30)
					H.Dizzy(30)
					H.stuttering = max(H.stuttering, 30)
					H.Jitter(30)
					if (prob(70))
						H.Knockdown(4)
					else if (prob(70))
						H.confused = 6
					H.adjustOxyLoss(20)
					H.adjustToxLoss(10)
			*/

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
	anim(target = antag.current, a_icon = 'icons/effects/32x96.dmi', flick_anim = "tattoo_receive", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	sleep(1)
	antag.current.update_mutations()
	var/atom/movable/overlay/tattoo_markings = anim(target = antag.current, a_icon = 'icons/mob/cult_tattoos.dmi', flick_anim = "[T.icon_state]_mark", sleeptime = 30, lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	animate(tattoo_markings, alpha = 0, time = 30)


/datum/role/cultist/proc/MakeArchCultist()
	var/datum/faction/bloodcult/B = faction
	if(!B || !istype(B))
		return
	arch_cultist = TRUE
