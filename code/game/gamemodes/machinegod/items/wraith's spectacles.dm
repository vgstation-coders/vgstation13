/obj/item/clothing/glasses/wraithspecs
	name = "antique spectacles"
	desc = "Bizarre spectacles with yellow lenses. They radiate a discomforting energy."
	icon_state = "wraith_specs"
	item_state = "wraith_specs"
	vision_flags = SEE_MOBS | SEE_TURFS | SEE_OBJS
	invisa_view = 2
	darkness_view = 3

/obj/item/clothing/glasses/wraithspecs/OnMobLife(var/mob/living/carbon/human/wearer)
	var/datum/organ/internal/eyes/E = wearer.internal_organs_by_name["eyes"]
	if(E && wearer.glasses == src)
		E.damage += 0.75
		if(E.damage >= E.min_broken_damage && !(wearer.sdisabilities & BLIND))
			wearer << "<span class='danger'>You go blind!</span>"
			wearer.sdisabilities |= BLIND
		else if (E.damage >= E.min_bruised_damage && !(wearer.disabilities & NEARSIGHTED))
			wearer << "<span class='danger'>You're going blind!</span>"
			wearer.eye_blurry = 5
			wearer.disabilities |= NEARSIGHTED
		if(prob(15))
			wearer << "<span class='danger'>Your eyes burn as you look through the spectacles.</span>"

/obj/item/clothing/glasses/wraithspecs/equipped(var/mob/M, glasses)
	var/mob/living/carbon/human/H = M
	if(!H) return
	if(H.glasses == src)
		var/datum/organ/internal/eyes/E =  H.internal_organs_by_name["eyes"]
		if(!istype(E))
			return

		if(!(H.sdisabilities & BLIND))
			if(iscultist(H))
				H << "<span class='clockwork'>\"Looks like Nar'sie's dogs really don't value their eyes.\"</span>"
				E.damage += E.min_broken_damage
				H << "<span class='danger'>You go blind!</span>"
				H.sdisabilities |= BLIND
				return

			H << "<span class='clockwork'>Your vision expands, but your eyes begin to burn.</span>"
			E.damage += 4

			if(E.damage >= E.min_broken_damage && !(H.sdisabilities & BLIND))
				H << "<span class='danger'>You go blind!</span>"
				H.sdisabilities |= BLIND
			else if (E.damage >= E.min_bruised_damage && !(H.disabilities & NEARSIGHTED))
				H << "<span class='danger'>You're going blind!</span>"
				H.eye_blurry = 5
				H.disabilities |= NEARSIGHTED
		else
			H << "<span class='clockwork'>\"You're already blind, fool. Stop embarassing yourself.\"</span>"
			return
