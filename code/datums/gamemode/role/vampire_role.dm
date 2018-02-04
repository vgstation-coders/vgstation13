
/*
 -- Vampires --
 */

#define VAMP_MAX_BLOOD_USUABLE 666

/datum/role/vampire
	id = VAMPIRE
	name = "vampire"
	special_role = "vampire"
	disallow_job = FALSE
	protected_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain")


	// -- Vampire mechanics --
	var/list/datum/role/thrall/thralls = list()

	var/list/powers = list()

	var/draining = FALSE
	var/nullified = FALSE

	var/blood_usable = 0
	var/blood_total = 0

	var/static/list/spell/roundstart_spells = list(/spell/targeted/hypnotise)

/datum/role/vampire/Greet(var/you_are = TRUE)
	var/dat
	if (you_are)
		dat = "<span class='danger'>You are a Vampire!</br></span>"
	dat += {"To drink blood from somebody, just bite their head (switch to harm intent, enable biting and attack the victim in the head with an empty hand). Drink blood to gain new powers and use coffins to regenerate your body if injured.
	You are weak to holy things and starlight. Don't go into space and avoid the Chaplain, the chapel, and especially Holy Water."}
	to_chat(antag.current, dat)
	to_chat(antag.current, "<B>You must complete the following tasks:</B>")
	antag.current << sound('sound/effects/vampire_intro.ogg')
	var/i = 1;

	// Not exactly sure if this is meant to be here.
	for (var/datum/objective/O in objectives.GetObjectives())
		to_chat(antag.current, "Objective #[i]: [O.explanation_text]")
		i++
	for(var/type_S in roundstart_spells)
		var/spell/S = new type_S
		antag.current.add_spell(S)

/datum/role/vampire/AdminPanelEntry()
	. = ..()
	if (thralls.len)
		. += "<b>Thralls slaved to [antag.current]:</b> <br/>"
		. += "<ul>"
		for (var/datum/role/thrall/T in thralls)
			. += T.AdminPanelEntry()
		. += "</ul>"

/datum/role/vampire/GetScoreboard()
	// -- To complete

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
 -- Thralls --
 */

/datum/role/thrall
	id = "thrall"
	name = "thrall"
	special_role = "thrall"
	var/datum/role/vampire/master

/datum/role/thrall/AdminPanelEntry()
	var/mob/M = antag.current
	return {"<li>
[name] <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]/[M.key]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]
<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>
<a href='?_src_=holder;traitor=\ref[M]'>TP</a></li>"}

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