/obj/item/slime_heart
	name = "Slime Heart"
	desc = "You devil..."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "Slime-Heart"
	item_state = "Slime-Heart"
	w_class = W_CLASS_TINY
	var/cd = 0

/obj/item/slime_heart/New()
	processing_objects.Add(src)
	..()

/obj/item/slime_heart/process()
	if(iscarbon(loc) && !cd)
		var/mob/living/carbon/C = loc
		if(C.is_holding_item(src))
			if(C.dna && C.dna.mutantrace == "slime")
				C.adjustToxLoss(-3)
			else
				C.adjustToxLoss(5)
			cd = 1
			spawn(1 SECONDS)
				cd = 0

/obj/item/slime_heart/Destroy()
	processing_objects.Remove(src)
	..()