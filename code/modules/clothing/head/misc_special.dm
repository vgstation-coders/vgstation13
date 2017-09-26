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
	icon_state = "ushankadown"
	item_state = "ushankadown"
	body_parts_covered = EARS|HEAD

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		body_parts_covered = HEAD
		to_chat(user, "You raise the ear flaps on the ushanka.")
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		to_chat(user, "You lower the ear flaps on the ushanka.")
		body_parts_covered = EARS|HEAD

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
	var/icon/mob
	var/icon/mob2
	siemens_coefficient = 1.5

	update_icon(var/mob/living/carbon/human/user)
		if(!istype(user))
			return
		mob = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty")
		mob2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty2")
		mob.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)
		mob2.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)

		var/icon/earbit = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner")
		var/icon/earbit2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner2")
		mob.Blend(earbit, ICON_OVERLAY)
		mob2.Blend(earbit2, ICON_OVERLAY)

/obj/item/clothing/head/kitty/cursed
	canremove = 0

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
	if(wearer.head == src)
		if(prob(5))
			wearer.say(pick("Ah, you're here at last","Twice now you've made me taste bitter defeat", " I hate to disappoint the Cobras but you're mine now.", "Ocelots are proud creatures. They prefer to hunt alone.","This time, I've got twelve shots.","This is the greatest handgun ever made. The Colt Single Action Army.","Six bullets, more than enough to kill anything that moves."))



/obj/item/clothing/head/welding/white
	name = "white welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. This one is painted white with a red mark on it."
	icon_state = "yuki_matsuda_1"
	item_state = "yuki_matsuda_1"

/obj/item/clothing/head/welding/red
	name = "red welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. This one is pained red with a blue stripe on it."
	icon_state = "paintedwelding"
	item_state = "paintedwelding"

/obj/item/clothing/head/welding/blue
	name = "blue welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. This one has a low quality blue paint job."
	icon_state = "norah_briggs_1"
	item_state = "norah_briggs_1"

/obj/item/clothing/head/welding/fire
	name = "fiery welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. This one has a fiery paint design on it."
	icon_state = "alice_mccrea_1"
	item_state = "alice_mccrea_1"

/obj/item/clothing/head/welding/demon
	name = "demonic welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. This one looks like a demons face."
	icon_state = "demonwelding"
	item_state = "demonwelding"

/obj/item/clothing/head/welding/knight
	name = "knightly welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. This one looks chivalrous."
	icon_state = "knightwelding"
	item_state = "knightwelding"

/obj/item/clothing/head/welding/fancy
	name = "fancy welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. This one looks fancy."
	icon_state = "fancywelding"
	item_state = "fancywelding"

/obj/item/clothing/head/welding/engie
	name = "engineering welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. This one is painted in the engineering colours."
	icon_state = "engiewelding"
	item_state = "engiewelding"

/obj/item/clothing/head/welding/carp
	name = "carp welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. This one looks like a carp face."
	icon_state = "carpwelding"
	item_state = "carpwelding"


/*/obj/item/device/paintkit
	name = "welding helmet stencil kit"
	desc = "A kit for automatically painting welding helmets with preset designs"
	icon_state = "modkit"
	var/obj/item/device/paintkit/active_paint = /obj/item/clothing/head/welding/engie

	var/paints = list("hotrod" = /obj/item/clothing/head/welding/engie,
	"penis" = /obj/item/clothing/head/welding/carp)

/obj/item/device/paintkit/attack_self(mob/user)
	if(paints)
		var/selection = paints[input("Select the material you'd like to synthesize", "Change Material Type") as null|anything in paints]
		if(selection)
			active_paint = selection
			to_chat(user, "<span class='notice'>You switch \the [src] to synthesize [initial(active_paint.name)]</span>")
	else
		active_paint = null
		return

*/