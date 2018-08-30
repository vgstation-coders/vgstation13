/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *		Butt
 *		Tinfoil Hat
 *		Celtic Crown
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags = FPRINT
	item_state = "welding"
	starting_materials = list(MAT_IRON = 3000, MAT_GLASS = 1000)
	w_type = RECYK_MISC
	var/up = 0
	eyeprot = 3
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	body_parts_covered = FACE
	actions_types = list(/datum/action/item_action/toggle_helmet)
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/welding/attack_self()
	toggle()


/obj/item/clothing/head/welding/proc/toggle()
	if(!usr)
		return //PANIC
	if(!usr.incapacitated())
		if(src.up)
			src.up = !src.up
			src.body_parts_covered = FACE
			eyeprot = 3
			icon_state = initial(icon_state)
			to_chat(usr, "You flip the [src] down to protect your eyes.")
		else
			src.up = !src.up
			src.body_parts_covered = HEAD
			icon_state = "[initial(icon_state)]up"
			eyeprot = 0
			to_chat(usr, "You push the [src] up out of your face.")
		usr.update_inv_head()	//so our mob-overlays update
		usr.update_inv_wear_mask()
		usr.update_inv_glasses()
		usr.update_hair()
		usr.update_inv_ears()


/*
 * Cakehat
 */
/obj/item/clothing/head/cakehat
	name = "cake-hat"
	desc = "It's tasty looking!"
	icon_state = "cake0"
	flags = FPRINT
	body_parts_covered = HEAD|EYES
	light_power = 0.5
	var/onfire = 0.0
	var/status = 0
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage
	var/processing = 0 //I dont think this is used anywhere.

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_objects.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(istype(M))
			if(M.head == src || M.is_holding_item(src))
				location = M.loc
		else
			return

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)
		return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"
		processing_objects.Add(src)
		set_light(2)
	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
		set_light(0)
	return


/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushanka"
	item_state = "ushanka"
	body_parts_covered = EARS|HEAD
	heat_conductivity = SNOWGEAR_HEAT_CONDUCTIVITY

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	var/initial_icon_state = initial(icon_state)
	if(icon_state == initial_icon_state)
		icon_state = "[initial_icon_state]up"
		item_state = "[initial_icon_state]up"
		body_parts_covered = HEAD
		to_chat(user, "You raise the ear flaps on \the [src].")
	else
		icon_state = initial_icon_state
		item_state = initial_icon_state
		to_chat(user, "You lower the ear flaps on \the [src].")
		body_parts_covered = EARS|HEAD

/obj/item/clothing/head/ushanka/security
	name = "security ushanka"
	desc = "Davai, tovarish. Let us catch the capitalist greyshirt, and show him why it is that we proudly wear red!"
	icon_state = "ushankared"
	item_state = "ushankared"
/*
 * Pumpkin head
 */
/obj/item/clothing/head/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"//Could stand to be renamed
	item_state = "hardhat0_pumpkin"
	_color = "pumpkin"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	var/brightness_on = 2 //luminosity when on
	var/on = 0

	attack_self(mob/user)
		if(!isturf(user.loc))
			to_chat(user, "You cannot turn the light on while in this [user.loc]")//To prevent some lighting anomalities.

			return
		on = !on
		icon_state = "hardhat[on]_[_color]"
		item_state = "hardhat[on]_[_color]"

		if(on)
			set_light(brightness_on)
		else
			set_light(0)

/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	flags = FPRINT
	var/haircolored = 1
	siemens_coefficient = 1.5

/obj/item/clothing/head/kitty/cursed
	canremove = 0

/obj/item/clothing/head/kitty/collectable
	desc = "A pair of black kitty ears. Meow!"
	haircolored = 0

/obj/item/clothing/head/kitty/update_icon(var/mob/living/carbon/human/user)
	if(!istype(user) || !haircolored)
		return
	wear_override = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty")
	wear_override.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)

	var/icon/earbit = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner")
	wear_override.Blend(earbit, ICON_OVERLAY)

/obj/item/clothing/head/butt
	name = "butt"
	desc = "So many butts, so little time."
	icon_state = "butt"
	item_state = "butt"
	flags = 0
	force = 4.0
	w_class = W_CLASS_TINY
	throwforce = 2
	throw_speed = 3
	throw_range = 5

	wizard_garb = 1

	var/s_tone = 0.0
	var/created_name = "Buttbot"

/obj/item/clothing/head/butt/proc/transfer_buttdentity(var/mob/living/carbon/H)
	name = "[H.real_name]'s butt"
	return

/obj/item/clothing/head/tinfoil
	name = "tinfoil hat"
	desc = "There's no evidence that the security staff is NOT out to get you."
	icon_state = "foilhat"
	item_state = "paper"
	siemens_coefficient = 2

/obj/item/clothing/head/celtic
	name = "\improper Celtic crown"
	desc = "According to legend, Celtic kings would use crowns like this one to shield their subjects from harsh winters back on Earth."
	icon_state = "celtic_crown"
	wizard_garb = 1

/obj/item/clothing/head/celtic/equipped(mob/living/carbon/human/H, head)
	if(istype(H) && H.get_item_by_slot(head) == src)
		H.species.cold_level_1 = -1
		H.species.cold_level_2 = -1
		H.species.cold_level_3 = -1
		H.species.flags |= HYPOTHERMIA_IMMUNE
		H.faction = "frost"

/obj/item/clothing/head/celtic/unequipped(mob/living/carbon/human/user, var/from_slot = null)
	if(from_slot == slot_head && istype(user))
		user.species.cold_level_1 = initial(user.species.cold_level_1)
		user.species.cold_level_2 = initial(user.species.cold_level_2)
		user.species.cold_level_3 = initial(user.species.cold_level_3)
		if(~initial(user.species.flags) & HYPOTHERMIA_IMMUNE)
			user.species.flags &= ~HYPOTHERMIA_IMMUNE
		user.faction = initial(user.faction)

/obj/item/clothing/head/beret/sec/ocelot
	name = "Ocelot's beret"
	desc = "Ocelot's signature red beret"

/obj/item/clothing/head/beret/sec/ocelot/OnMobLife(var/mob/living/carbon/human/wearer)
	if(wearer.get_item_by_slot(slot_head) == src)
		if(prob(5))
			wearer.say(pick("Ah, you're here at last","Twice now you've made me taste bitter defeat", " I hate to disappoint the Cobras but you're mine now.", "Ocelots are proud creatures. They prefer to hunt alone.","This time, I've got twelve shots.","This is the greatest handgun ever made. The Colt Single Action Army.","Six bullets, more than enough to kill anything that moves."))
