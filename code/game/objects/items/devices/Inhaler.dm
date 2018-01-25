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
	
/obj/item/device/inhaler/attack_self(mob/user as mob)
	if(cooldown < world.time - 8  && ishuman(user))
		var/mob/living/carbon/human/H = user
		playsound(user, 'sound/effects/spray2.ogg', 20, 1)
		H.reagents.add_reagent(ALBUTEROL, 5)
		visible_message("<span class='danger'>\The [src] puts the inhaler up to their mouth and takes a deep breath!</span>", \
									"<span class='warning'>You place the inhaler up to your mouth and take a deep breath!</span>")
		cooldown = world.time

/obj/item/device/inhaler/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8 && ishuman(user))
			var/mob/living/carbon/human/H = user
			playsound(user, 'sound/effects/spray2.ogg', 20, 1)
			H.reagents.add_reagent(ALBUTEROL, 5)
			visible_message("<span class='danger'>\The [src] puts the inhaler up to their mouth and takes a deep breath!</span>", \
										"<span class='warning'>You place the inhaler up to your mouth and take a deep breath!</span>")
			cooldown = world.time
			return
