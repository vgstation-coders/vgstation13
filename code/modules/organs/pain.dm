/mob/proc/flash_pain()
	flick("pain",pain)

/mob/var/list/pain_stored = list()
/mob/var/last_pain_message = ""
/mob/var/next_pain_time = 0

// partname is the name of a body part
// amount is a num from 1 to 100
/mob/living/carbon/proc/pain(var/partname, var/amount, var/force, var/burning = 0)
	if(stat >= 2 || sleeping)
		return
	if(!feels_pain() || has_painkillers())
		return
	if(world.time < next_pain_time && !force)
		return
	if(amount > 50 && prob(amount / 5) && get_active_hand())
		to_chat(src, "<span class='danger'>The pain in your [partname] causes you to wince and drop [get_active_hand()]!</span>")
		src.drop_item()
	var/msg
	if(burning)
		switch(amount)
			if(1 to 10)
				msg = "<span class='danger'>Your [partname] burns.</span>"
			if(11 to 90)
				flash_weak_pain()
				msg = "<span class='danger'><font size=2>Your [partname] burns badly!</font></span>"
			if(91 to 10000)
				flash_pain()
				msg = "<span class='danger'><font size=3>OH GOD! Your [partname] is on fire!</font></span>"
	else
		switch(amount)
			if(1 to 10)
				msg = "<b>Your [partname] hurts.</b>"
			if(11 to 90)
				flash_weak_pain()
				msg = "<b><font size=2>Your [partname] hurts badly.</font></b>"
			if(91 to 10000)
				flash_pain()
				msg = "<b><font size=3>OH GOD! Your [partname] is hurting terribly!</font></b>"
	if(msg && (msg != last_pain_message || prob(10)))
		last_pain_message = msg
		to_chat(src, msg)
	next_pain_time = world.time + (100 - amount)


// message is the custom message to be displayed
// flash_strength is 0 for weak pain flash, 1 for strong pain flash
/mob/living/carbon/human/proc/custom_pain(var/message, var/flash_strength, var/scream = FALSE)
	if(stat >= 1)
		return

	if(!feels_pain() || has_painkillers())
		return

	var/msg = "<span class='danger'>[message]</span>"
	if(flash_strength >= 1)
		msg = "<span class='danger'><font size=3>[message]</font></span>"

	// Anti message spam checks
	if(msg && ((msg != last_pain_message) || (world.time >= next_pain_time)))
		last_pain_message = msg
		if(scream)
			audible_scream()
		to_chat(src, msg)
	next_pain_time = world.time + 100

/mob/living/carbon/human/proc/handle_pain()
	if(sleeping || stat == DEAD)
		return
	if(!feels_pain() || has_painkillers())
		return

	var/maxdam = 0
	var/datum/organ/external/damaged_organ = null
	for(var/datum/organ/external/E in organs)
		//dead limbs don't cause or feel pain
		if(E.status & ORGAN_DEAD)
			continue
		//peg limbs and metal limbs don't cause pain
		if(!E.is_organic())
			continue
		// CLEANLY amputated limbs don't cause pain
		else if(E.amputated)
			continue
		// your shredded nub of a fuckin' arm DOES, though
		else if (!E.is_existing())
			if(prob(2))
				custom_pain("The mangled stump of your [E.display_name] hurts badly!", 1)
			continue

		var/dam = E.get_damage()
		// make the choice of the organ depend on damage,
		// but also sometimes use one of the less damaged ones
		if(dam > maxdam && (maxdam == 0 || prob(70)) )
			damaged_organ = E
			maxdam = dam
	if(damaged_organ)
		pain(damaged_organ.display_name, maxdam, 0)

	// Damage to internal organs hurts a lot.
	for(var/datum/organ/internal/I in internal_organs)
		if(I.damage > 2)
			if(prob(2))
				var/datum/organ/external/parent = get_organ(I.parent_organ)
				custom_pain("You feel a sharp pain in your [parent.display_name]", 1)

	var/toxDamageMessage = null
	var/toxMessageProb = 1
	switch(getToxLoss())
		if(1 to 5)
			toxMessageProb = 1
			toxDamageMessage = "Your body stings slightly."
		if(6 to 10)
			toxMessageProb = 2
			toxDamageMessage = "Your whole body hurts a little."
		if(11 to 15)
			toxMessageProb = 2
			toxDamageMessage = "Your whole body hurts."
		if(15 to 25)
			toxMessageProb = 3
			toxDamageMessage = "Your whole body hurts badly."
		if(26 to INFINITY)
			toxMessageProb = 5
			toxDamageMessage = "Your body aches all over, it's driving you mad."

	if(toxDamageMessage && prob(toxMessageProb))
		src.custom_pain(toxDamageMessage, getToxLoss() >= 15)
