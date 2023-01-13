var/global/list/invoked_emotions = list()

/spell/targeted/invoke_emotion
	name = "Invoke Emotion"
	desc = "Summon a cursed document that forces itself to, eventually, be read by your target. Once your message is complete, simply throw the document and it will find its way."
	abbreviation = "IE"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	hud_state = "invoke_emotion"
	invocation = "YU'V GO'T MA'LE"
	invocation_type = SpI_WHISPER
	spell_flags = WAIT_FOR_CLICK | SELECTABLE | INCLUDEUSER
	price = 0.25 * Sp_BASE_PRICE
	range = 9
	charge_max = 150
	cooldown_min = 10
	compatible_mobs = list(/mob/living/carbon)
	spell_levels = list(Sp_SPEED = 0, Sp_POWER = 0, Sp_MOVE = 0)
	level_max = list(Sp_TOTAL = 7, Sp_SPEED = 1, Sp_POWER = 5, Sp_MOVE = 1)

	var/obj/item/weapon/paper/emotion_invoker/thePaper = null
	var/obj/item/weapon/pen/invoked_quill/theQuill = null

/spell/targeted/invoke_emotion/cast(var/list/targets, mob/user)
	..()
	for(var/mob/living/carbon/target in targets)
		var/obj/item/weapon/paper/emotion_invoker/thePaper = new /obj/item/weapon/paper/emotion_invoker(user.loc)
		thePaper.curseTarget = target
		thePaper.cursePower = spell_levels[Sp_POWER]
		thePaper.forcesHand = spell_levels[Sp_MOVE]
		user.put_in_hands(thePaper)
		if(!theQuill)
			theQuill = new /obj/item/weapon/pen/invoked_quill(user.loc)
			theQuill.quillSpell = src
			user.put_in_hands(theQuill)
		else if(theQuill.loc != user)
			theQuill.forceMove(user.loc)
			user.put_in_hands(theQuill)


/spell/targeted/invoke_emotion/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return quicken_spell()
		if(Sp_POWER)
			spell_levels[Sp_POWER]++
			return "Your invoked emotions now cut slightly deeper."
		if(Sp_MOVE)
			spell_levels[Sp_MOVE]++
			return "Your invoked emotions are now harder to ignore."

/spell/targeted/invoke_emotion/get_upgrade_price(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return 20
		if(Sp_POWER)
			return 1
		if(Sp_MOVE)
			return 5

/spell/targeted/invoke_emotion/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return "Nearly removes the cooldown of the spell."
		if(Sp_POWER)
			return "Invoked paper is more likely to cut, or otherwise curse, the target."
		if(Sp_MOVE)
			return "Invoked emotions have a chance to place themselves in their target's hand."

/obj/item/weapon/pen/invoked_quill
	name = "invoked quill"
	desc = "A magical quill that requires no inkwell. So it's a pen."
	var/spell/targeted/invoke_emotion/quillSpell = null	//Just for preventing hard deletes

/obj/item/weapon/pen/invoked_quill/Destroy()
	quillSpell.theQuill = null
	quillSpell = null
	..()

/obj/item/weapon/paper/emotion_invoker
	name = "emotion invoker"
	desc = "A cursed sheet of paper designed to transfer or create powerful emotions. Seeks out its target after being thrown."
	fire_fuel = 0	//Covering my bases on potential infinite fire bugs
	throw_range = 6
	var/mob/living/curseTarget = null
	var/isActive = FALSE
	var/emotionInvoked = FALSE
	var/forcesHand = 0
	var/cursePower = 0

/obj/item/weapon/paper/emotion_invoker/New()
	..()
	invoked_emotions += src

/obj/item/weapon/paper/emotion_invoker/canfold(mob/user)
	return FALSE

/obj/item/weapon/paper/emotion_invoker/dissolvable()
	return FALSE

/obj/item/weapon/paper/emotion_invoker/ashify_item(mob/user)
	if(isActive)
		return FALSE	//Not that easy
	..()

/obj/item/weapon/paper/emotion_invoker/pickup(mob/living/carbon/user)
	if(isActive && curseTarget)
		if(user != curseTarget)
			var/datum/organ/external/affecting = user.get_active_hand_organ()
			if(affecting.take_damage(1 * cursePower))
				user.UpdateDamageIcon()
				to_chat(user, "<span class='warning'>Ouch, paper cut!</span>")
			user.drop_item(src)

/obj/item/weapon/paper/emotion_invoker/Destroy()
	processing_objects.Remove(src)
	invoked_emotions -= src
	..()

/obj/item/weapon/paper/emotion_invoker/process()
	if(curseTarget)
		if(curseTarget.gcDestroyed)
			isActive = FALSE
			ashify()
		if(loc != curseTarget)
			if(emotionInvoked)
				destroyEmotion()
			else
				goToTarget()

/obj/item/weapon/paper/emotion_invoker/proc/destroyEmotion()
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/weapon/paper/emotion_invoker/throw_impact(atom/hit_atom)
	if(..())
		return
	if(isActive)
		if(hit_atom == curseTarget)
			inflictCurse()
	else
		activateInvoker()

/obj/item/weapon/paper/emotion_invoker/on_enter_storage(obj/item/weapon/storage/S)
	if(isActive)
		spawn(5)
			do_teleport(src, curseTarget, 2)

/obj/item/weapon/paper/emotion_invoker/proc/activateInvoker()
	isActive = TRUE
	processing_objects.Add(src)

/obj/item/weapon/paper/emotion_invoker/proc/goToTarget()
	if(curseTarget in viewers(src))
		throw_at(curseTarget, 10, 2)
	else
		do_teleport(src, curseTarget, 2)

/obj/item/weapon/paper/emotion_invoker/proc/inflictCurse()
	if(prob(10 * cursePower))
		curseTarget.adjustBruteLoss(1)
		to_chat(curseTarget, "<span class='warning'>You receive a paper cut!</span>")
	if(prob(cursePower))
		curseTarget.Knockdown(1)
	if(forcesHand && prob(20))
		curseTarget.put_in_hands(src)

/obj/item/weapon/paper/emotion_invoker/show_text(var/mob/user, var/links = FALSE, var/starred = FALSE)
	..()
	if(isActive && curseTarget)
		if(user == curseTarget && !starred)
			emotionInvoked = TRUE
	else if(info)
		message_admins("[key_name(user)] has written on an invoke emotion paper [formatJumpTo(get_turf(src))]!")
		log_admin("[key_name(user)] wrote on an invoked emotion: [info]")
