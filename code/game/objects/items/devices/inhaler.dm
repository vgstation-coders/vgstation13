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
	var/cooldown = 0

/obj/item/device/inhaler/attack_self(mob/user)
	if(cooldown < world.time - 8  && ishuman(user))
		var/mob/living/carbon/human/H = user
		playsound(user, 'sound/effects/spray2.ogg', 20, 1)
		H.reagents.add_reagent(ALBUTEROL, 5)
		cooldown = world.time

/obj/item/device/inhaler/attack(mob/living/M, mob/user)
	if(!ishuman(M) || user.zone_sel.selecting != "mouth" || user.a_intent != I_HELP)
		return ..()
	if(cooldown < world.time - 8)
		var/mob/living/carbon/human/H = M
		var/obj/item/mouth_protection = H.get_body_part_coverage(MOUTH)
		if(mouth_protection)
			to_chat(user, "<span class='warning'>Remove their [mouth_protection] first!</span>")
			return 1
		if(!H.hasmouth)
			to_chat(user, "<span class='warning'>There's nowhere to put \the [src] as [H] lacks a mouth!</span>")
			return 1
		playsound(H, 'sound/effects/spray2.ogg', 20, 1)
		H.reagents.add_reagent(ALBUTEROL, 5)
		cooldown = world.time
