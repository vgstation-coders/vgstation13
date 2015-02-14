/obj/item/poop
	name = "poop"
	desc = "A pleasant lump of faeces."
	icon = 'icons/obj/poop.dmi'
	icon_state = "poop"
	force = 1
	throwforce = 1
	siemens_coefficient = 1

/obj/item/poop/New(var/loc, var/ue_in, var/dna_in)
	..()
	icon_state = "poop[rand(1,2)]"
	if(ue_in && dna_in)
		if(!islist(blood_DNA))
			blood_DNA = list()
		src.blood_DNA |= list("[ue_in]" = "[dna_in]")
	generate_poop()

/obj/item/poop/throw_impact(target, throw_speed, mob/user)
	if(istype(target, /mob/living) && prob(25))
		var/mob/living/M = target
		M.eye_blind += 3
		M.eye_blurry += 3
	generate_poop()

/obj/item/poop/proc/generate_poop()
	var/obj/effect/decal/cleanable/blood/poop/poop_decal = getFromPool(/obj/effect/decal/cleanable/blood/poop, get_turf(src))
	poop_decal.blood_DNA |= src.blood_DNA