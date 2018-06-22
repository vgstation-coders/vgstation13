#define PUFF_COOLDOWN_TIME 8

/obj/item/device/inhaler
	name = "inhaler"
	desc = "Breathe deep!"
	icon = 'icons/obj/inhaler.dmi'
	icon_state = "inhaler"
	w_class = W_CLASS_TINY
	flags = FPRINT
	slot_flags = SLOT_BELT
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0
	var/last_puff = 0

/obj/item/device/inhaler/proc/puff_ready()
	return last_puff < world.time - PUFF_COOLDOWN_TIME

/obj/item/device/inhaler/attack_self(mob/user)
	puff(user, user)

/obj/item/device/inhaler/attack(mob/living/target, mob/user)
	if(user.a_intent != I_HELP)
		return ..()
	puff(target, user)

/obj/item/device/inhaler/proc/puff(mob/living/carbon/human/target, var/mob/living/user)
	if(!ishuman(target))
		return
	if(!puff_ready())
		return
	var/used_on_self = target == user
	if(!target.hasmouth)
		if(used_on_self)
			to_chat(user, "<span class='warning'>There's nowhere to put \the [src] as you lack a mouth!</span>")
		else
			to_chat(user, "<span class='warning'>There's nowhere to put \the [src] as [target] lacks a mouth!</span>")
		return
	var/obj/item/mouth_protection = target.get_body_part_coverage(MOUTH)
	if(mouth_protection)
		to_chat(user, "<span class='warning'>Remove [used_on_self ? "your" : "their"] [mouth_protection.name] first!</span>")
		return
	if(used_on_self)
		user.visible_message("<span class='notice'>[user] takes a puff from \the [src].</span>", "<span class='notice'>You take a puff from \the [src].</span>")
	else
		user.visible_message("<span class='notice'>[user] helps [target] take a puff from \the [src].</span>", "<span class='notice'>You help [target] take a puff from \the [src].</span>")
	playsound(target, 'sound/effects/spray2.ogg', 20, 1)
	target.reagents.add_reagent(ALBUTEROL, 5)
	last_puff = world.time

#undef PUFF_COOLDOWN_TIME
