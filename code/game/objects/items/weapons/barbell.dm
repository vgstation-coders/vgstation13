/obj/item/weapon/barbell
	name = "barbell"
	desc = "A large barbell."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "barbell"
	item_state = "barbell"
	w_class = 8
	force = 8


/obj/item/weapon/barbell/attack_self(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		user.delayNextAttack(5)
		user.visible_message("<span class='rose'>You see [user] pumping out reps with \the [src]</span>", \
		"<span class='rose'>You start pumping out reps with \the [src].</span>")
		if(do_after(user, H, 50))
			user.visible_message("<span class='rose'>[user] looks stronger!</span>", \
			"<span class='rose'>You feel stronger.</span>")
			H.species.muscle_mass += 15



