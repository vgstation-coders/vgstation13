/obj/item/slime_heart
	name = "slime heart"
	desc = "You devil..."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "Slime-Heart"
	item_state = "Slime-Heart"
	w_class = W_CLASS_TINY

/obj/item/slime_heart/OnMobLife(var/mob)
	if(iscarbon(mob))
		var/mob/living/carbon/C = mob
		if(C.is_holding_item(src))
			if(C.dna && C.dna.mutantrace == "slime")
				C.adjustToxLoss(-3)
			else
				C.adjustToxLoss(5)