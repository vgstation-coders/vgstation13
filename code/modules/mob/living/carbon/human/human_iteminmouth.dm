/datum/action/item_action/itemInMouth
	name = "Spit Out"

/datum/action/item_action/itemInMouth/proc/adjustForItem()
	if(!target)
		return FALSE
	name = "Spit Out [target]"
	desc = "Spits out \the [target] you have in your mouth"

/datum/action/item_action/itemInMouth/Trigger()
	to_chat(world, "Trigger start")
	if(ishuman(owner))
		to_chat(world, "Trigger human")
		var/mob/living/carbon/human/H = owner
		H.spitItem()


/mob/living/carbon/human/verb/spitItem()
	set name = "Spit Out"
	set category = "IC"

	if(!hasMouthFull)
		return FALSE
	if(a_intent == I_HURT)
		var/turf/T = get_turf(get_step(src, dir))
		spitOutItem(TRUE, FALSE, T)
	else
		spitOutItem(TRUE, TRUE)



//Mob procs/////////

/mob/proc/biteCheck(var/atom/A)
	return FALSE

/mob/living/carbon/human/biteCheck(var/atom/A)
	to_chat(world, "Start bite check")
	if(attack_type == ATTACK_BITE)
		to_chat(world, "ATTACK BITE")
		if(hasMouthFull)
			to_chat(world, "has mouth full")
			spitOutItem(TRUE, FALSE, get_turf(A))
			to_chat(world, "After spit out")
			return TRUE
		if(can_bite(A))
			to_chat(world, "Can bite")
			if(a_intent == "hurt")	//So we can still do things like bite pills without change
				to_chat(world, "hurt")
				A.bite_act(src)
			else if(istype(A, /obj/item))
				to_chat(world, "Biting [A]")
				var/obj/item/toBite = A
				putItemInMouth(toBite)
				to_chat(world, "put in mouth")
				return TRUE
	return FALSE

/mob/living/carbon/human/proc/putItemInMouth(var/obj/item/mItem)
	if(hasMouthFull)
		to_chat(src, "<span class='warning'>You already have something in your mouth.</span>")
	else if(mItem.w_class == W_CLASS_TINY)
		to_chat(world, "It's tiny")
		if(equip_to_slot_if_possible(mItem, slot_mouth))
			to_chat(world, "after equip to slot")
			mItem.mouth_act(src)	//I don't want to hear any giggling in the back of the class
			visible_message("<span class='warning'>[src] puts \the [mItem] in their mouth!.</span>")
		else
			to_chat(src, "<span class='warning'>You couldn't get \the [src] into your mouth!.</span>")

/mob/living/carbon/human/proc/enableSpitting(var/obj/item/mItem)
	to_chat(world, "begin enable spitting")
	var/datum/action/A = new /datum/action/item_action/itemInMouth(mItem)
	to_chat(world, "Action added")
	A.Grant(src)
	to_chat(world, "After grant")

/mob/living/carbon/human/proc/spitOutItem(var/message = TRUE, var/spitInHands = FALSE, var/turf/spitAt = null, var/spitStr = 0)
	to_chat(world, "Begin spit out")
	var/obj/item/inMouth = get_item_by_slot(slot_mouth)
	to_chat(world, "in mouth is [inMouth]")
	if(!inMouth)
		to_chat(world, "No in mouth")
		return FALSE
	if(inMouth.gcDestroyed || inMouth.loc != src)
		to_chat(world, "in mouth destroyed or not in there")
		emptyMouth()
		to_chat(world, "After empty mouth")
		return TRUE	//Just in case
	if(inMouth.current_glue_state)
		to_chat(world, "Glued")
		return FALSE
	emptyMouth()
	to_chat(world, "After second empty mouth")
	inMouth.forceMove(get_turf(src))
	to_chat(world, "inmouth was force moved")
	if(message)
		visible_message("<span class='warning'>\[src] spits out what was in their mouth!</span>")
	if(spitInHands)
		to_chat(world, "spit in hands")
		put_in_hands(inMouth)
	if(spitAt)
		to_chat(world, "spit at turf")
		spitStr += get_strength(src)	//Will usually be 1
		inMouth.throw_at(spitAt, spitStr, spitStr)
	return TRUE

/mob/living/carbon/human/proc/emptyMouth()
	to_chat(world, "Empty start")
	var/obj/item/inMouth = get_item_by_slot(slot_mouth)
	to_chat(world, "in mouth is [inMouth]")
	u_equip(inMouth, slot_mouth)
	to_chat(world, "After u_equip")
	hasMouthFull = FALSE


//Item procs/////////////

/obj/item/bite_act(mob/user)
	to_chat(world, "begin bite act")
	if(ishuman(user))	//Monkeys aren't smart enough or something. Mostly this is too prone to break things so I'm human restricting it
		to_chat(world, "after ishuman")
		var/mob/living/carbon/human/H = user
		H.putItemInMouth(src)

/obj/item/proc/mouth_act(mob/user)	//If something does something while held in your mouth, like a wad of paper
	to_chat(world, "mouth act")
	return
