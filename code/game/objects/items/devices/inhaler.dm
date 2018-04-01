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
