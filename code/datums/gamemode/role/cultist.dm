/datum/role/cultist
	id = CULTIST
	name = "Cultist"
	required_pref = CULTIST
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent", "Merchant")
	logo_state = "cult-logo"
	greets = list(GREET_DEFAULT,GREET_CUSTOM,GREET_ROUNDSTART,GREET_ADMINTOGGLE)
	var/list/tattoos = list()
	var/holywarning_cooldown = 0
	var/list/conversion = list()
	var/second_chance = 1

/datum/role/cultist/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id)
	..()
	wikiroute = role_wiki[CULTIST]

/datum/role/cultist/OnPostSetup()
	. = ..()
	if(!.)
		return

	update_cult_hud()
	antag.current.add_language(LANGUAGE_CULT)

	if((ishuman(antag.current) || ismonkey(antag.current)) && !(locate(/spell/cult) in antag.current.spell_list))
		antag.current.add_spell(new /spell/cult/trace_rune/blood_cult, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
		antag.current.add_spell(new /spell/cult/erase_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)

	antag.store_memory("A couple of runes appear clearly in your mind:")
	antag.store_memory("<B>Raise Structure:</B> BLOOD, TECHNOLOGY, JOIN.")
	antag.store_memory("<B>Communication:</B> SELF, OTHER, TECHNOLOGY.")
	antag.store_memory("<B>Summon Tome:</B> SEE, BLOOD, HELL.")
	antag.store_memory("<hr>")

/datum/role/cultist/RemoveFromRole(var/datum/mind/M)
	antag.current.remove_language(LANGUAGE_CULT)
	for(var/spell/cult/spell_to_remove in antag.current.spell_list)
		antag.current.remove_spell(spell_to_remove)
	if (src in blood_communion)
		blood_communion.Remove(src)
	..()

/datum/role/cultist/PostMindTransfer(var/mob/living/new_character)
	. = ..()
	if (issilicon(new_character))
		antag.decult()
	update_cult_hud()
	antag.current.add_language(LANGUAGE_CULT)
	if((ishuman(antag.current) || ismonkey(antag.current)) && !(locate(/spell/cult) in antag.current.spell_list))
		antag.current.add_spell(new /spell/cult/trace_rune/blood_cult, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
		antag.current.add_spell(new /spell/cult/erase_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)

/datum/mind/proc/decult()
	antag_roles -= CULTIST
	current.remove_language(LANGUAGE_CULT)
	for(var/spell/cult/spell_to_remove in current.spell_list)
		current.remove_spell(spell_to_remove)
	var/datum/role/cultist/C = GetRole(CULTIST)
	if (C in blood_communion)
		blood_communion.Remove(C)
	update_faction_icons()

/datum/role/cultist/process()
	..()
	if (holywarning_cooldown > 0)
		holywarning_cooldown--

	if (veil_thickness == CULT_MENDED && antag.current)
		if (ishuman(antag.current))
			var/mob/living/carbon/human/H = antag.current
			if(H.get_heart() && prob(10))
				H.visible_message("<span class='danger'>\The [H]'s heart bursts out of \his chest!</span>","<span class='danger'>Your heart bursts out of your chest!</span>")
				var/obj/item/organ/internal/blown_heart = H.remove_internal_organ(H,H.get_heart(),H.get_organ(LIMB_CHEST))
				var/list/spawn_turfs = list()
				for(var/turf/T in orange(1, H))
					if(!T.density)
						spawn_turfs.Add(T)
				if(!spawn_turfs.len)
					spawn_turfs.Add(get_turf(H))
				var/mob/living/simple_animal/hostile/heart_attack = new(pick(spawn_turfs))
				heart_attack.appearance = blown_heart.appearance
				heart_attack.icon_dead = "heart-off"
				heart_attack.environment_smash_flags = 0
				heart_attack.melee_damage_lower = 15
				heart_attack.melee_damage_upper = 15
				heart_attack.health = 50
				heart_attack.maxHealth = 50
				heart_attack.stat_attack = 1
				qdel(blown_heart)
			else
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
		else
			antag.current.adjustBruteLoss(rand(20,50))

/datum/role/cultist/Greet(var/greeting,var/custom)
	if(!greeting)
		return

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
	to_chat(antag.current, "<span class='sinister'>You find yourself to be well-versed in the runic alphabet of the cult.</span>")
	to_chat(antag.current, "<span class='sinister'>A couple of runes linger vividly in your mind.</span><span class='info'> (check your notes).</span>")


	spawn(1)
		if (faction)
			var/datum/objective_holder/OH = faction.objective_holder
			var/datum/objective/O = OH.objectives[OH.objectives.len] //Gets the latest objective.
			to_chat(antag.current,"<span class='danger'>[O.name]</span><b>: [O.explanation_text]</b>")
/datum/role/cultist/update_antag_hud()
	update_cult_hud()

/datum/role/cultist/proc/update_cult_hud()
	var/mob/M = antag.current
	if(M && M.client && M.hud_used)
		if(!M.hud_used.cult_Act_display)
			M.hud_used.cult_hud()
		if (!(M.hud_used.cult_Act_display in M.client.screen))
			M.client.screen += list(M.hud_used.cult_Act_display,M.hud_used.cult_tattoo_display)
		M.hud_used.cult_Act_display.overlays.len = 0
		M.hud_used.cult_tattoo_display.overlays.len = 0
		var/current_act = max(-1,min(5,veil_thickness))
		var/image/I_act = image('icons/mob/screen1_cult.dmi',"act")
		I_act.appearance_flags |= RESET_COLOR
		M.hud_used.cult_Act_display.overlays += I_act
		var/image/I_tattoos = image('icons/mob/screen1_cult.dmi',"tattoos")
		I_tattoos.appearance_flags |= RESET_COLOR
		M.hud_used.cult_tattoo_display.overlays += I_tattoos

		var/image/I_act_indicator = image('icons/mob/screen1_cult.dmi',"[current_act]")
		if (current_act == CULT_MENDED)
			I_act_indicator.appearance_flags |= RESET_COLOR
		M.hud_used.cult_Act_display.overlays += I_act_indicator

		var/image/I_arrow = image('icons/mob/screen1_cult.dmi',"[current_act]a")
		I_arrow.appearance_flags |= RESET_COLOR
		M.hud_used.cult_Act_display.overlays += I_arrow
		switch (current_act)
			if (CULT_MENDED)
				M.hud_used.cult_Act_display.name = "..."
			if (CULT_PROLOGUE)
				M.hud_used.cult_Act_display.name = "Prologue: The Reunion"
			if (CULT_ACT_I)
				M.hud_used.cult_Act_display.name = "Act I: The Followers"
			if (CULT_ACT_II)
				M.hud_used.cult_Act_display.name = "Act II: The Sacrifice"
			if (CULT_ACT_III)
				M.hud_used.cult_Act_display.name = "Act III: The Blood Bath"
			if (CULT_ACT_IV)
				M.hud_used.cult_Act_display.name = "Act IV: The Tear in Reality"
			if (CULT_EPILOGUE)
				M.hud_used.cult_Act_display.name = "Epilogue: The Feast"
		var/tattoos_names = ""
		var/i = 0
		for (var/T in tattoos)
			var/datum/cult_tattoo/tattoo = tattoos[T]
			if (tattoo)
				M.hud_used.cult_tattoo_display.overlays += image('icons/mob/screen1_cult.dmi',"t_[tattoo.icon_state]")
				tattoos_names += "[i ? ", " : ""][tattoo.name]"
				i++
		if (!tattoos_names)
			tattoos_names = "none"
		M.hud_used.cult_tattoo_display.name = "Arcane Tattoos: [tattoos_names]"

		if (isshade(M) && M.gui_icons && istype(M.loc,/obj/item/weapon/melee/soulblade))
			M.client.screen += list(
				M.gui_icons.soulblade_bgLEFT,
				M.gui_icons.soulblade_coverLEFT,
				M.gui_icons.soulblade_bloodbar,
				M.fire,
				)

/mob/living/carbon/proc/muted()
	if (checkTattoo(TATTOO_HOLY))
		return 0
	return (iscultist(src) && reagents && reagents.has_reagent(HOLYWATER))

/datum/role/cultist/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
	var/dat = ..()
	dat += " - <a href='?src=\ref[src]&mind=\ref[antag]&cult_privatespeak=\ref[antag.current]'>(Nar-Sie whispers)</a>"
	return dat

/datum/role/cultist/handle_reagent(var/reagent_id)
	var/mob/living/carbon/human/H = antag.current
	if (!istype(H))
		return
	var/unholy = H.checkTattoo(TATTOO_HOLY)
	var/current_act = Clamp(veil_thickness,CULT_MENDED,CULT_EPILOGUE)
	if (reagent_id == INCENSE_HAREBELLS)
		if (unholy)
			H.eye_blurry = max(H.eye_blurry, 3)
			return
		else
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

/datum/role/cultist/handle_splashed_reagent(var/reagent_id)//also proc'd when holy water is drinked or ingested in any way
	var/mob/living/carbon/human/H = antag.current
	if (!istype(H))
		return
	var/unholy = H.checkTattoo(TATTOO_HOLY)
	var/current_act = max(-1,min(5,veil_thickness))
	if (reagent_id == HOLYWATER)
		if (holywarning_cooldown <= 0)
			holywarning_cooldown = 5
			if (unholy)
				to_chat(H, "<span class='warning'>You feel the unpleasant touch of holy water, but the mark on your back negates its most debilitating effects.</span>")
			else
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

	if (reagent_id == HOLYWATER || reagent_id == INCENSE_HAREBELLS)
		if (unholy)
			H.eye_blurry = max(H.eye_blurry, 3)
			return
		else
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

/datum/role/cultist/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	if (href_list["cult_privatespeak"])
		var/message = input("What message shall we send?",
                    "Voice of Nar-Sie",
                    "")
		var/mob/mob = M.current
		if (mob)
			to_chat(mob, "<span class='danger'>Nar-Sie</span> murmurs to you... <span class='sinister'>[message]</span>")

			for(var/mob/dead/observer/O in player_list)
				to_chat(O, "<span class='game say'><span class='danger'>Nar-Sie</span> whispers to [mob.real_name], <span class='sinister'>[message]</span></span>")

			message_admins("Admin [key_name_admin(usr)] has talked with the Voice of Nar-Sie.")
			log_narspeak("[key_name(usr)] Voice of Nar-Sie (privately to [mob.real_name]): [message]")
