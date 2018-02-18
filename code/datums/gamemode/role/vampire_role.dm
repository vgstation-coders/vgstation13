
/*
 -- Vampires --
 */

/datum/role/vampire
	id = VAMPIRE
	name = "Vampire"
	special_role = "vampire"
	disallow_job = FALSE
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain")
	logo_state = "vampire-logo"


	// -- Vampire mechanics --
	var/list/datum/role/thrall/thralls = list()

	var/list/powers = list()
	var/ismenacing = FALSE
	var/iscloaking = FALSE

	var/nullified = 0
	var/smitecounter = 0

	var/draining = FALSE
	var/blood_usable = 0
	var/blood_total = 0

	var/static/list/spell/roundstart_spells = list(/spell/targeted/hypnotise, /spell/rejuvenate)

/datum/role/vampire/Greet(var/you_are = TRUE)
	var/dat
	if (you_are)
		dat = "<span class='danger'>You are a Vampire!</br></span>"
	dat += {"To drink blood from somebody, just bite their head (switch to harm intent, enable biting and attack the victim in the head with an empty hand). Drink blood to gain new powers and use coffins to regenerate your body if injured.
	You are weak to holy things and starlight. Don't go into space and avoid the Chaplain, the chapel, and especially Holy Water."}
	to_chat(antag.current, dat)
	to_chat(antag.current, "<B>You must complete the following tasks:</B>")
	antag.current << sound('sound/effects/vampire_intro.ogg')

/datum/role/vampire/OnPostSetup()
	. = ..()
	update_vamp_hud(antag.current)

	for(var/type_S in roundstart_spells)
		var/spell/S = new type_S
		antag.current.add_spell(S)

/datum/role/vampire/RemoveFromRole(var/datum/mind/M)
	for(var/spell/spell in antag.current.spell_list)
		if (is_type_in_list(spell,roundstart_spells))//TODO: HAVE A LIST WITH EVERY VAMPIRE SPELLS
			antag.current.remove_spell(spell)
	if(antag.current.client && antag.current.hud_used)
		if(antag.current.hud_used.vampire_blood_display)
			antag.current.client.screen -= list(antag.current.hud_used.vampire_blood_display)
	..()

/* we're gonna have procedural faction generation to handle thralls and apprentices
/datum/role/vampire/AdminPanelEntry()
	. = ..()
	if (thralls.len)
		. += "<b>Thralls slaved to [antag.current]:</b> <br/>"
		. += "<ul>"
		for (var/datum/role/thrall/T in thralls)
			. += T.AdminPanelEntry()
		. += "</ul>"
*/

// -- Not sure if this is meant to work like that.
// I just put what I expect to see in the "The vampires were..."
/datum/role/vampire/GetScoreboard()
	. = ..() // Who he was, his objectives...
	. += "Total blood collected: <b>[blood_total]</b>"
	for (var/datum/role/thrall/T in thralls)
		. += T.GetScoreboard()

/datum/role/vampire/ForgeObjectives()
	// -- Vampires objectives : acquire blood, assassinate.
	objectives.AddObjective(new /datum/objective/acquire_blood, src.antag)
	objectives.AddObjective(new /datum/objective/target/assassinate, src.antag)

// -- Vampire mechanics --

/datum/role/vampire/proc/can_suck(var/mob/living/carbon/human/H)
	var/mob/M = antag.current
	if(M.lying || M.incapacitated())
		to_chat(M, "<span class='warning'> You cannot do this while on the ground!</span>")
		return FALSE

	if(H.check_body_part_coverage(MOUTH))
		to_chat(M, "<span class='warning'>Remove their mask!</span>")
		return FALSE

	if(ishuman(M))
		var/mob/living/carbon/human/vamp_H = M
		if(H.check_body_part_coverage(MOUTH))
			if(vamp_H.species.breath_type == "oxygen")
				to_chat(H, "<span class='warning'>Remove your mask!</span>")
				return FALSE
			else
				to_chat(H, "<span class='notice'>With practiced ease, you shift aside your mask for each gulp of blood.</span>")
	return TRUE

/datum/role/vampire/proc/handle_bloodsucking(var/mob/living/carbon/human/target)
	draining = target

	var/mob/assailant = antag.current

	var/blood = 0
	var/blood_total_before = blood_total
	var/blood_usable_before = blood_usable
	assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Bit [key_name(target)] in the neck and draining their blood.</font>")
	target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been bit in the neck by [key_name(assailant)].</font>")
	log_attack("[key_name(assailant)] bit [key_name(target)] in the neck")

	to_chat(antag.current, "<span class='danger'>You latch on firmly to \the [target]'s neck.</span>")
	to_chat(target, "<span class='userdanger'>\The [assailant] latches on to your neck!</span>")

	if(!iscarbon(assailant))
		target.LAssailant = null
	else
		target.LAssailant = assailant
	while(do_mob(assailant, target, 5 SECONDS))
		if(!isvampire(assailant))
			to_chat(assailant, "<span class='warning'>Your fangs have disappeared!</span>")
			draining = null
			return FALSE
		if(target.species.anatomy_flags & NO_BLOOD)
			to_chat(assailant, "<span class='warning'>Not a drop of blood here.</span>")
			draining = null
			return FALSE
		if(!target.mind)
			to_chat(assailant, "<span class='warning'>This blood is lifeless and has no power.</span>")
			draining = null
			return 0
		if(!target.vessel.get_reagent_amount(BLOOD))
			to_chat(assailant, "<span class='warning'>They've got no blood left to give.</span>")
			break
		if(target.stat < DEAD) //alive
			blood = min(10, target.vessel.get_reagent_amount(BLOOD)) // if they have less than 10 blood, give them the remnant else they get 10 blood
			blood_total += blood
			blood_usable += blood
			update_vamp_hud(assailant)
			target.adjustCloneLoss(10) // beep boop 10 damage
		else
			blood = min(5, target.vessel.get_reagent_amount(BLOOD)) // The dead only give 5 bloods
			blood_total += blood
		if(blood_total_before != blood_total)
			to_chat(assailant, "<span class='notice'>You have accumulated [blood_total] [blood_total > 1 ? "units" : "unit"] of blood[blood_usable_before != blood_usable ?", and have [blood_usable] left to use." : "."]</span>")
		check_vampire_upgrade()
		target.vessel.remove_reagent(BLOOD,25)

	draining = null
	to_chat(assailant, "<span class='notice'>You stop draining \the [target] of blood.</span>")
	return TRUE

/datum/role/vampire/proc/check_vampire_upgrade()
	var/list/old_powers = powers.Copy()

	switch (blood_total)

		// TIER 1
		if (100 to 150)
			powers |= VAMP_VISION
			powers |= VAMP_SHAPE

		// TIER 2
		if(150 to 200)
			powers |= VAMP_CLOAK
			powers |= VAMP_DISEASE

		// TIER 3
		if (200 to 250)
			powers |= VAMP_BATS
			powers |= VAMP_SCREAM
			powers |= VAMP_HEAL

		// TIER 3.5 (/vg/)
		if(250 to 300)
			powers |= VAMP_BLINK

		// TIER 4
		if(300 to 400)
			powers |= VAMP_JAUNT
			powers |= VAMP_SLAVE

		// TIER 5 (/vg/)
		if(400 to 450)
			powers |= VAMP_MATURE

		// TIER 6 (/vg/)
		if(450 to 500)
			powers |= VAMP_SHADOW

		// TIER 66 (/vg/)
		if(500 to 666)
			powers |= VAMP_CHARISMA

		// TIER 666 (/vg/)
		if(666 to ARBITRARILY_LARGE_NUMBER)
			powers |= VAMP_UNDYING

	announce_new_powers(old_powers, powers)

/datum/role/vampire/proc/announce_new_powers(var/old_powers, var/new_powers)
	var/msg = ""
	var/mob/M = antag.current
	for(var/n in new_powers)
		if(!(n in old_powers))
			switch(n)
				if(VAMP_SHAPE)
					msg = "<span class='notice'>You have gained the shapeshifting ability, at the cost of stored blood you can change your form permanently.</span>"
					to_chat(M, "[msg]")
					// -- TODO : add the spell
				if(VAMP_VISION)
					msg = "<span class='notice'>Your vampiric vision has improved.</span>"
					to_chat(M, "[msg]")
					antag.store_memory("<font size = 1>[msg]</font>")
					//no verb
				if(VAMP_DISEASE)
					msg = "<span class='notice'>You have gained the Diseased Touch ability which causes those you touch to die shortly after unless treated medically.</span>"
					to_chat(M, "[msg]")
					// -- TODO : add the spell
				if(VAMP_CLOAK)
					msg = "<span class='notice'>You have gained the Cloak of Darkness ability which when toggled makes you near invisible in the shroud of darkness.</span>"
					to_chat(M, "[msg]")
					// -- TODO : add the spell
				if(VAMP_BATS)
					msg = "<span class='notice'>You have gained the Summon Bats ability which allows you to summon a trio of angry space bats.</span>"
					to_chat(M, "[msg]")
					// -- TODO : add the spell
				if(VAMP_SCREAM)
					msg = "<span class='notice'>You have gained the Chiroptean Screech ability which stuns anything with ears in a large radius and shatters glass in the process.</span>"
					to_chat(M, "[msg]")
					// -- TODO : add the spell
				if(VAMP_HEAL)
					msg = "<span class=notice'>Your rejuvination abilities have improved and will now heal you over time when used.</span>"
					to_chat(M, "[msg]")
					antag.store_memory("<font size = 1>[msg]</font>")
					//no verb
				if(VAMP_JAUNT)
					msg = "<span class='notice'>You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path.</span>"
					to_chat(M, "[msg]")
					// -- TODO : add the spell
				if(VAMP_SLAVE)
					msg = "<span class='notice'>You have gained the Enthrall ability which at a heavy blood cost allows you to enslave a human that is not loyal to any other for a random period of time.</span>"
					to_chat(M, "[msg]")
					// -- TODO : add the spell
				if(VAMP_BLINK)
					msg = "<span class='notice'>You have gained the ability to shadowstep, which makes you disappear into nearby shadows at the cost of blood.</span>"
					to_chat(M, "[msg]")
					// -- TODO : add the spell
				if(VAMP_MATURE)
					msg = "<span class='sinister'>You have reached physical maturity. You are more resistant to holy things, and your vision has been improved greatly.</span>"
					to_chat(M, "[msg]")
					antag.store_memory("<font size = 1>[msg]</font>")
					//no verb
				if(VAMP_SHADOW)
					msg = "<span class='notice'>You have gained mastery over the shadows. In the dark, you can mask your identity, instantly terrify non-vampires who approach you, and enter the chapel for a longer period of time.</span>"
					to_chat(M, "[msg]")
					// -- TODO : add the spell
				if(VAMP_CHARISMA)
					msg = "<span class='sinister'>You develop an uncanny charismatic aura that makes you difficult to disobey. Hypnotise and Enthrall take less time to perform, and Enthrall works on implanted targets.</span>"
					to_chat(M, "[msg]")
					antag.store_memory("<font size = 1>[msg]</font>")
					//no verb
				if(VAMP_UNDYING)
					msg = "<span class='sinister'>You have reached the absolute peak of your power. Your abilities cannot be nullified very easily, and you may return from the grave so long as your body is not burned, destroyed or sanctified. You can also spawn a rather nice cape.</span>"
					to_chat(M, "[msg]")
					antag.store_memory("<font size = 1>[msg]</font>")
					// -- TODO : add the spells
/*
-- Life() related procs --
*/

/datum/role/vampire/process()
	var/mob/living/carbon/human/H = antag.current
	if (!istype(H))
		return FALSE // The life() procs only work on humans.
	handle_cloak(H)
	handle_menace(H)
	handle_smite(H)
	if(istype(H.loc, /turf/space))
		H.check_sun()
	if(istype(H.loc, /obj/structure/closet/coffin))
		H.adjustBruteLoss(-4)
		H.adjustFireLoss(-4)
		H.adjustToxLoss(-4)
		H.adjustOxyLoss(-4)
		smitecounter = 0
		nullified -= 5
		for(var/datum/organ/internal/I in H.internal_organs)
			if(I && I.damage > 0)
				I.damage = max(0, I.damage - 4)
			if(I)
				I.status &= ~ORGAN_BROKEN
				I.status &= ~ORGAN_SPLINTED
				I.status &= ~ORGAN_BLEEDING
	nullified = max(0, nullified - 1)

/datum/role/vampire/proc/handle_cloak(var/mob/living/carbon/human/H)
	var/turf/T = get_turf(H)

	if(!iscloaking)
		H.alphas["vampire_cloak"] = 255
		H.color = "#FFFFFF"
		return FALSE

	if((T.get_lumcount() * 10) <= 2)
		H.alphas["vampire_cloak"] = round((255 * 0.15))
		if(VAMP_SHADOW in powers)
			H.color = "#000000"
		return TRUE
	else
		if(VAMP_SHADOW in powers)
			H.alphas["vampire_cloak"] = round((255 * 0.15))
		else
			H.alphas["vampire_cloak"] = round((255 * 0.80))

/datum/role/vampire/proc/handle_menace(var/mob/living/carbon/human/H)
	if(!ismenacing)
		ismenacing = 0 // ? Probably not necessary
		return FALSE

	var/turf/T = get_turf(H)

	if(T.get_lumcount() > 2)
		ismenacing = 0
		return FALSE

	for(var/mob/living/carbon/C in oview(6))
		if(prob(35))
			continue //to prevent fearspam
		if(!C.vampire_affected(antag))
			continue
		C.stuttering += 20
		C.Jitter(20)
		C.Dizzy(20)
		to_chat(C, "<span class='sinister'>Your heart is filled with dread, and you shake uncontrollably.</span>")

/datum/role/vampire/proc/handle_smite(var/mob/living/carbon/human/H)
	var/smitetemp = 0
	var/vampcoat = istype(H.wear_suit, /obj/item/clothing/suit/storage/draculacoat) //coat reduces smiting
	if(check_holy(H)) //if you're on a holy tile get ready for pain
		smitetemp += (vampcoat ? 1 : 5)
		if(prob(35))
			to_chat(H, "<span class='danger'>This ground is blessed. Get away, or splatter it with blood to make it safe for you.</span>")

	if(!(VAMP_MATURE in powers) && get_area(H) == /area/chapel) //stay out of the chapel unless you want to turn into a pile of ashes
		nullified = max(5, nullified + 2)
		if(prob(35))
			to_chat(H, "<span class='sinister'>You feel yourself growing weaker.</span>")
		/*smitetemp += (vampcoat ? 5 : 15)
		if(prob(35))
			to_chat(src, "<span class='sinister'>Burn, wretch.</span>")
		*/

	if(!nullified) //Checks to see if you can benefit from your vamp powers here
		if(VAMP_MATURE in powers)
			smitetemp -= 1
		if(VAMP_SHADOW in powers)
			var/turf/T = get_turf(H)
			if((T.get_lumcount() * 10) < 2)
				smitetemp -= 1

		if(VAMP_UNDYING in powers)
			smitetemp -= 1

	if(smitetemp <= 0) //if you weren't smote by the tile you're on, remove a little holy
		smitetemp = -1

	smitecounter = max(0, (smitecounter + smitetemp))

	switch(smitecounter)
		if(1 to 30) //just dizziness
			H.dizziness = max(5, H.dizziness)
			if(prob(35))
				to_chat(H, "<span class='warning'>You feel sick.</span>")
		if(30 to 60) //more dizziness, and occasional disorientation
			H.dizziness = max(5, H.dizziness + 1)
			remove_blood(1)
			if(prob(35))
				H.confused = max(5, H.confused)
				to_chat(H, "<span class='warning'>You feel very sick.</span>")
		if(60 to 90) //this is where you start barfing and losing your powers
			H.dizziness = max(10, H.dizziness + 3)
			nullified = max(20, nullified)
			remove_blood(2)
			if(prob(8))
				H.vomit()
			if(prob(35))
				H.confused = max(5, H.confused)
				to_chat(H, "<span class='warning'>You feel extremely sick. Get to a coffin as soon as you can.</span>")
		if(90 to 100) //previous effects, and skin starts to smoulder
			H.dizziness = max(10, H.dizziness + 6)
			nullified = max(20, nullified + 1)
			remove_blood(5)
			H.confused = max(10, H.confused)
			H.adjustFireLoss(1)
			if(prob(35))
				H.visible_message("<span class='danger'>[H]'s skin sizzles!</span>", "<span class='danger'>Your skin sizzles!</span>")
		if(100 to (INFINITY)) //BONFIRE
			H.dizziness = max(50, H.dizziness + 8)
			nullified = max(50, nullified + 10)
			remove_blood(10)
			H.confused = max(10, H.confused)
			if(!H.on_fire)
				to_chat(H, "<span class='danger'>Your skin catches fire!</span>")
			else if(prob(35))
				to_chat(H, "<span class='danger'>The holy flames continue to burn your flesh!</span>")
			H.fire_stacks += 5
			H.IgniteMob()

/datum/role/vampire/proc/remove_blood(var/amount)
	blood_usable = max(0, blood_usable - amount)
	update_vamp_hud(antag.current)

/*
-- Helpers --
*/

/datum/role/vampire/proc/update_vamp_hud(var/mob/M)
	if(M.hud_used)
		if(!M.hud_used.vampire_blood_display)
			M.hud_used.vampire_hud()
			//hud_used.human_hud(hud_used.ui_style)
		M.hud_used.vampire_blood_display.maptext_width = WORLD_ICON_SIZE*2
		M.hud_used.vampire_blood_display.maptext_height = WORLD_ICON_SIZE
		M.hud_used.vampire_blood_display.maptext = "<div align='left' valign='top' style='position:relative; top:0px; left:6px'>U:<font color='#33FF33'>[blood_usable]</font><br> T:<font color='#FFFF00'>[blood_total]</font></div>"

/mob/living/carbon/human/proc/check_sun()
	var/ax = x
	var/ay = y

	for(var/i = 1 to 20)
		ax += sun.dx
		ay += sun.dy

		var/turf/T = locate( round(ax,0.5),round(ay,0.5),z)

		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)
			break

		if(T.density)
			return

	if(prob(45))
		switch(health)
			if(80 to 100)
				to_chat(src, "<span class='warning'>Your skin flakes away...</span>")
				adjustFireLoss(1)
			if(60 to 80)
				to_chat(src, "<span class='warning'>Your skin sizzles!</span>")
				adjustFireLoss(1)
			if((-INFINITY) to 60)
				if(!on_fire)
					to_chat(src, "<span class='danger'>Your skin catches fire!</span>")
				else
					to_chat(src, "<span class='danger'>You continue to burn!</span>")
				fire_stacks += 5
				IgniteMob()
		emote("scream",,, 1)
	else
		switch(health)
			if((-INFINITY) to 60)
				fire_stacks++
				IgniteMob()
	adjustFireLoss(3)

/*
 -- Thralls --
 */

#define THRALL "thrall" // Should be moved somewhere else

/datum/role/thrall
	id = THRALL
	name = "thrall"
	special_role = "thrall"
	logo_state = "thrall-logo"
	var/datum/role/vampire/master

/datum/role/thrall/Greet(var/you_are = TRUE)
	var/dat
	if (you_are)
		dat = "<span class='danger'>You are a Thrall!</br> You are slaved to <b>[master.antag.current]</b>!</span>"
	dat += {""}
	to_chat(antag.current, dat)
	to_chat(antag.current, "<B>You must complete the following tasks:</B>")
	antag.current << sound('sound/effects/vampire_intro.ogg')

/datum/role/thrall/ForgeObjectives()
	objectives.AddObjective(new /datum/objective/protect_master(master), src.antag)