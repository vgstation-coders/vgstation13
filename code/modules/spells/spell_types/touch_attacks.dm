/obj/effect/proc_holder/spell/targeted/touch
	var/hand_path = "/obj/item/melee/touch_attack"
	var/obj/item/melee/touch_attack/attached_hand = null
	invocation_type = "none" //you scream on connecting, not summoning
	include_user = 1
	range = -1

/obj/effect/proc_holder/spell/targeted/touch/Click(mob/user = usr)
	if(attached_hand)
		qdel(attached_hand)
		charge_counter = charge_max
		attached_hand = null
		to_chat(user, "<span class='notice'>You draw the power out of your hand.</span>")
		return FALSE
	..()

/obj/effect/proc_holder/spell/targeted/touch/cast(list/targets,mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		if(!attached_hand)
			if(!ChargeHand(C))
				return FALSE
	while(attached_hand)
		charge_counter = 0
		stoplag(1)

/obj/effect/proc_holder/spell/targeted/touch/can_cast(mob/user = usr)
	return ..() && attached_hand

/obj/effect/proc_holder/spell/targeted/touch/proc/ChargeHand(mob/living/carbon/user)
	attached_hand = new hand_path(src)
	if(!user.put_in_hands(attached_hand))
		qdel(attached_hand)
		charge_counter = charge_max
		attached_hand = null
		to_chat(user, "<span class='warning'>Your hands are full!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You channel the power of the spell to your hand.</span>")
	return TRUE


/obj/effect/proc_holder/spell/targeted/touch/disintegrate
	name = "Disintegrate"
	desc = "This spell charges your hand with vile energy that can be used to violently explode victims."
	hand_path = "/obj/item/melee/touch_attack/disintegrate"

	school = "evocation"
	charge_max = 600
	clothes_req = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "gib"

/obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone
	name = "Flesh to Stone"
	desc = "This spell charges your hand with the power to turn victims into inert statues for a long period of time."
	hand_path = "/obj/item/melee/touch_attack/fleshtostone"

	school = "transmutation"
	charge_max = 600
	clothes_req = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "statue"
	sound = 'sound/magic/fleshtostone.ogg'
