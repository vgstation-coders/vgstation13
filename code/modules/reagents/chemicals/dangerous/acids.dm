
/datum/reagent/sacid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	reagent_state = LIQUID
	color = "#DB5008" // rgb: 219, 80, 8

/datum/reagent/sacid/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom

	if(ishuman(M))
		var/mob/living/carbon/human/H=M
		if(H.species.name=="Grey")
			..()
			return // Greys lurve dem some sacid

	M.adjustToxLoss(1*REM)
	M.take_organ_damage(0, 1*REM)
	..()
	return

/datum/reagent/sacid/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				if(!H.wear_mask.unacidable)
					del (H.wear_mask)
					H.update_inv_wear_mask()
					H << "\red Your mask melts away but protects you from the acid!"
				else
					H << "\red Your mask protects you from the acid!"
				return

			if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
				if(prob(15) && !H.head.unacidable)
					del(H.head)
					H.update_inv_head()
					H << "\red Your helmet melts away but protects you from the acid"
				else
					H << "\red Your helmet protects you from the acid!"
				return

		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M
			if(MK.wear_mask)
				if(!MK.wear_mask.unacidable)
					del (MK.wear_mask)
					MK.update_inv_wear_mask()
					MK << "\red Your mask melts away but protects you from the acid!"
				else
					MK << "\red Your mask protects you from the acid!"
				return

		if(!M.unacidable)
			if(prob(15) && istype(M, /mob/living/carbon/human) && volume >= 30)
				var/mob/living/carbon/human/H = M
				if(H.species.name=="Grey")
					..()
					return // Greys lurve dem some sacid
				var/datum/organ/external/affecting = H.get_organ("head")
				if(affecting)
					if(affecting.take_damage(25, 0))
						H.UpdateDamageIcon(1)
					H.status_flags |= DISFIGURED
					H.emote("scream",,, 1)
			else
				M.take_organ_damage(min(15, volume * 2)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
	else
		if(!M.unacidable)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.species.name=="Grey")
					..()
					return // Greys lurve dem some sacid
			M.take_organ_damage(min(15, volume * 2))

/datum/reagent/sacid/reaction_obj(var/obj/O, var/volume)
	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(10))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			for(var/mob/M in viewers(5, O))
				M << "\red \the [O] melts."
			del(O)

/datum/reagent/pacid
	name = "Polytrinic acid"
	id = "pacid"
	description = "Polytrinic acid is a an extremely corrosive chemical substance."
	reagent_state = LIQUID
	color = "#8E18A9" // rgb: 142, 24, 169

/datum/reagent/pacid/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	..()
	return

/datum/reagent/pacid/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return //wooo more runtime fixin
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				if(!H.wear_mask.unacidable)
					del (H.wear_mask)
					H.update_inv_wear_mask()
					H << "\red Your mask melts away but protects you from the acid!"
				else
					H << "\red Your mask protects you from the acid!"
				return

			if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
				if(prob(15) && !H.head.unacidable)
					del(H.head)
					H.update_inv_head()
					H << "\red Your helmet melts away but protects you from the acid"
				else
					H << "\red Your helmet protects you from the acid!"
				return

			if(!H.unacidable)
				var/datum/organ/external/affecting = H.get_organ("head")
				if(affecting.take_damage(15, 0))
					H.UpdateDamageIcon(1)
				H.emote("scream",,, 1)
		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M

			if(MK.wear_mask)
				if(!MK.wear_mask.unacidable)
					del (MK.wear_mask)
					MK.update_inv_wear_mask()
					MK << "\red Your mask melts away but protects you from the acid!"
				else
					MK << "\red Your mask protects you from the acid!"
				return

			if(!MK.unacidable)
				MK.take_organ_damage(min(15, volume * 4)) // same deal as sulphuric acid
	else
		if(!M.unacidable)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/affecting = H.get_organ("head")
				if(affecting.take_damage(15, 0))
					H.UpdateDamageIcon(1)
				H.emote("scream",,, 1)
				H.status_flags |= DISFIGURED
			else
				M.take_organ_damage(min(15, volume * 4))

/datum/reagent/pacid/reaction_obj(var/obj/O, var/volume)
	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			for(var/mob/M in viewers(5, O))
				M << "\red \the [O] melts."
			del(O)