/obj/item/slime_heart
	name = "slime heart"
	desc = "You devil..."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "Slime-Heart"
	item_state = "Slime-Heart"
	w_class = W_CLASS_TINY

/obj/item/slime_heart/New()
	processing_objects.Add(src)
	..()

/obj/item/slime_heart/process()
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(C.is_holding_item(src))
			if(C.dna && C.dna.mutantrace == "slime")
				C.adjustToxLoss(-3)
			else
				C.adjustToxLoss(5)
			spawn(1 SECONDS)