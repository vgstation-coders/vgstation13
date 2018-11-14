/*
 * Glass shards
 */

/obj/item/weapon/shard
	name = "shard"
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	sharpness = 0.8
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = W_CLASS_TINY
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 5.0
	throwforce = 15.0

	item_state = "shard-glassnew"
	starting_materials = list(MAT_GLASS = 3750)
	w_type = RECYK_GLASS
	melt_temperature = MELTPOINT_GLASS
	siemens_coefficient = 0 //no conduct
	attack_verb = list("stabs", "slashes", "slices", "cuts")
	var/glass = /obj/item/stack/sheet/glass/glass
	shrapnel_amount = 3
	shrapnel_type = "/obj/item/projectile/bullet/shrapnel/small"
	shrapnel_size = 2

/obj/item/weapon/shard/New()

	src.icon_state = pick("large", "medium", "small")
	switch(src.icon_state)
		if("small")
			src.pixel_x = rand(-12, 12) * PIXEL_MULTIPLIER
			src.pixel_y = rand(-12, 12) * PIXEL_MULTIPLIER
		if("medium")
			src.pixel_x = rand(-8, 8) * PIXEL_MULTIPLIER
			src.pixel_y = rand(-8, 8) * PIXEL_MULTIPLIER
		if("large")
			src.pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
			src.pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER
		else
	..()
	return

/obj/item/weapon/shard/plasma
	name = "plasma shard"
	desc = "A shard of plasma glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 8.0
	throwforce = 15.0
	icon_state = "plasmalarge"
	item_state = "shard-plasglass"
	glass = /obj/item/stack/sheet/glass/plasmaglass
	shrapnel_type = "/obj/item/projectile/bullet/shrapnel/small/plasma"

/obj/item/weapon/shard/plasma/New()
	..()
	src.icon_state = pick("plasmalarge", "plasmamedium", "plasmasmall")
	return

/obj/item/weapon/shard/shrapnel
	name = "shrapnel"
	icon = 'icons/obj/shards.dmi'
	icon_state = "shrapnellarge"
	desc = "A bunch of tiny bits of shattered metal."
	starting_materials = list(MAT_IRON = 5)
	w_type=RECYK_METAL
	melt_temperature=MELTPOINT_STEEL
	glass = /obj/item/stack/sheet/metal

/obj/item/weapon/shard/shrapnel/New()
	..()
	src.icon_state = pick("shrapnellarge", "shrapnelmedium", "shrapnelsmall")
	return

/obj/item/weapon/shard/suicide_act(mob/user)
		to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his wrists with the shard of glass! It looks like \he's trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting \his throat with the shard of glass! It looks like \he's trying to commit suicide.</span>"))
		return (SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/shard/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/shard/resetVariables()
	..("icon_state", "pixel_y", "pixel_x")

/obj/item/weapon/shard/to_bump()

	spawn( 0 )
		if (prob(20))
			src.force = initial(src.force) + rand(3,8)
		else
			src.force = max(1, initial(src.force) - rand(1,4))
		..()
		return
	return

/obj/item/weapon/shard/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/glass/new_item = new glass()
			new_item.forceMove(user.loc) //This is because new() doesn't call forceMove, so we're forcemoving the new sheet to make it stack with other sheets on the ground.
			returnToPool(src)
			return
	return ..()

/obj/item/weapon/shard/Crossed(mob/living/AM)
	if(istype(AM))
		if(AM.locked_to) //Mob is locked to something, so it's not actually stepping on the glass
			playsound(src, 'sound/effects/glass_step.ogg', 50, 1) //Make noise
			return //Stop here
		if(AM.flying) //We don't check for lying yet because it's intended to hurt
			return
		else //Stepping on the glass
			playsound(src, 'sound/effects/glass_step.ogg', 50, 1)
			if(ishuman(AM))
				var/mob/living/carbon/human/H = AM
				var/danger = FALSE

				var/datum/organ/external/foot = H.pick_usable_organ(LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT)
				if(!H.organ_has_mutation(foot, M_STONE_SKIN) && !H.check_body_part_coverage(FEET))
					if(foot.is_organic())
						danger = TRUE

						if(!H.lying && H.feels_pain())
							H.Knockdown(3)
						if(foot.take_damage(5, 0))
							H.UpdateDamageIcon()
						H.updatehealth()

				to_chat(AM, "<span class='[danger ? "danger" : "notice"]'>You step in the broken glass!</span>")
	..()
