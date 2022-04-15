////////////////////////////////////////////////////////////////////////////
// Electric Metroid
//
// Stuns mobs
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// Baby
////////////////////////////////////////////////////////////////////////////
/mob/living/carbon/metroid/electric
	subtype="electric"
	icon_state = "electric baby metroid"
	primarytype = /mob/living/carbon/metroid/electric
	adulttype = /mob/living/carbon/metroid/adult/electric
	coretype = /obj/item/metroid_core/electric

/mob/living/carbon/metroid/electric/pre_attach(var/mob/living/carbon/M)
	shock(M,75)
	return 1

/mob/living/carbon/metroid/proc/shock(mob/user, prb, var/siemens_coeff = 1.0)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, null, src, siemens_coeff))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return 1
	else
		return 0

////////////////////////////////////////////////////////////////////////////
// Adult
////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/metroid/adult/electric
	subtype="electric"
	icon_state = "electric adult metroid"
	primarytype = /mob/living/carbon/metroid/electric
	coretype= /obj/item/metroid_core/electric
	mutationtypes = list(
		/mob/living/carbon/metroid/electric,
		// Copied from Yellow.
		/mob/living/carbon/metroid/metal,
		/mob/living/carbon/metroid/bluespace,
		/mob/living/carbon/metroid/orange
	)

/mob/living/carbon/metroid/adult/electric/pre_attach(var/mob/living/carbon/M)
	shock(M,60)
	return 1

////////////////////////////////////////////////////////////////////////////
// Core
////////////////////////////////////////////////////////////////////////////

/obj/item/metroid_core/electric
	name="electric metroid core"
	desc="How shocking!"
	icon_state="electric metroid core"