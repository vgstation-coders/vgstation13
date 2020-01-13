//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = W_CLASS_SMALL
	body_parts_covered = EYES
	slot_flags = SLOT_EYES
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/invisa_view = 0
	var/cover_hair = 0
	var/see_invisible = 0
	var/see_in_dark = 0
	var/prescription = 0
	min_harm_label = 12
	harm_label_examine = list("<span class='info'>A label is covering one lens, but doesn't reach the other.</span>","<span class='warning'>A label covers the lenses!</span>")
	species_restricted = list("exclude","Muton")
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/
/obj/item/clothing/glasses/harm_label_update()
	if(harm_labeled >= min_harm_label)
		vision_flags |= BLIND
	else
		vision_flags &= ~BLIND

/obj/item/clothing/glasses/equipped(mob/M, var/slot)
	..()
	if(slot == slot_glasses)
		M.handle_regular_hud_updates()

/obj/item/clothing/glasses/unequipped(mob/M, var/from_slot = null)
	..()
	if(from_slot == slot_glasses)
		M.handle_regular_hud_updates()

/obj/item/clothing/glasses/scanner/meson/prescription
	name = "prescription mesons"
	desc = "Optical Meson Scanner with prescription lenses."
	prescription = 1
	eyeprot = -1
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/hud/health/prescription
	name = "prescription health scanner HUD"
	desc = "A Health Scanner HUD with prescription lenses."
	prescription = 1
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/sunglasses/sechud/prescription
	name = "prescription security HUD"
	desc = "A Security HUD with prescription lenses."
	prescription = 1
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

////////////////////////////////////////////////PATHOGEN HUD///////////////////////////////////////////////////
var/list/science_goggles_wearers = list()

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "almost nothing."
	icon_state = "purple"
	item_state = "glasses"
	origin_tech = Tc_MATERIALS + "=1"
	species_fit = list(GREY_SHAPED)
	actions_types = list(/datum/action/item_action/toggle_goggles)
	var/on = FALSE

/obj/item/clothing/glasses/science/prescription
	name = "prescription science goggles"
	prescription = 1
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/glasses/science/attack_self(var/mob/user)
	toggle(user)

/obj/item/clothing/glasses/science/proc/toggle(var/mob/user)
	if (user.incapacitated())
		return
	if (on)
		on = FALSE
		to_chat(user, "You turn the pathogen scanner off.")
		disable(user)
	else
		on = TRUE
		to_chat(user, "You turn the pathogen scanner on.")
		enable(user)
	user.handle_regular_hud_updates()

/obj/item/clothing/glasses/science/equipped(var/mob/M, var/slot)
	..()
	if (!M.client)
		return
	if(slot == slot_glasses)
		if (on)
			enable(M)

/obj/item/clothing/glasses/science/unequipped(var/mob/M, var/from_slot)
	..()
	if (!M.client)
		return
	if(from_slot == slot_glasses)
		disable(M)

/obj/item/clothing/glasses/science/proc/enable(var/mob/M)
	var/toggle = 0
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.glasses == src)
			toggle = 1
	if (ismonkey(M))
		var/mob/living/carbon/monkey/H = M
		if (H.glasses == src)
			toggle = 1
	if (toggle)
		playsound(M,'sound/misc/click.ogg',30,0,-5)
		science_goggles_wearers.Add(M)
		for (var/obj/item/I in infected_items)
			if (I.pathogen)
				M.client.images |= I.pathogen
		for (var/mob/living/L in infected_contact_mobs)
			if (L.pathogen)
				M.client.images |= L.pathogen
		for (var/obj/effect/effect/pathogen_cloud/C in pathogen_clouds)
			if (C.pathogen)
				M.client.images |= C.pathogen
		for (var/obj/effect/decal/cleanable/C in infected_cleanables)
			if (C.pathogen)
				M.client.images |= C.pathogen

/obj/item/clothing/glasses/science/proc/disable(var/mob/M)
	playsound(M,'sound/misc/click.ogg',30,0,-5)
	science_goggles_wearers.Remove(M)
	for (var/obj/item/I in infected_items)
		M.client.images -= I.pathogen
	for (var/mob/living/L in infected_contact_mobs)
		M.client.images -= L.pathogen
	for (var/obj/effect/effect/pathogen_cloud/C in pathogen_clouds)
		M.client.images -= C.pathogen
	for (var/obj/effect/decal/cleanable/C in infected_cleanables)
		M.client.images -= C.pathogen
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch0"
	species_fit = list(GREY_SHAPED)
	item_state = "eyepatch0"
	min_harm_label = 0
	var/flipped = FALSE

/obj/item/clothing/glasses/eyepatch/attack_self(mob/user)
	flipped = !flipped
	icon_state = "eyepatch[flipped]"
	species_fit = list(GREY_SHAPED)
	item_state = "eyepatch[flipped]"
	to_chat(user, "You flip \the [src] to your [flipped ? "left" : "right"] eye.")

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")
/obj/item/clothing/glasses/monocle/harm_label_update()
	return //Can't exactly blind someone by covering one eye.

/obj/item/clothing/glasses/regular
	name = "Prescription Glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	item_state = "glasses"
	prescription = 1
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/glasses/regular/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] stomps on \the [src], crushing them!</span>", "<span class='danger'>You crush \the [src] under your foot.</span>")
	playsound(src, "shatter", 50, 1)

	var/obj/item/weapon/shard/S = new(get_turf(src))
	S.Crossed()

	qdel(src)
	return SPECIAL_ATTACK_FAILED

/obj/item/clothing/glasses/regular/hipster
	name = "Prescription Glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/glasses/gglasses
	name = "Green Glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/glasses/sunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	origin_tech = Tc_COMBAT + "=2"
	darkness_view = -1
	eyeprot = 1
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/sunglasses/virus

/obj/item/clothing/glasses/sunglasses/virus/dropped(mob/user as mob)
	canremove = 1
	..()

/obj/item/clothing/glasses/sunglasses/virus/equipped(var/mob/user, var/slot)
	if (slot == slot_glasses)
		canremove = 0
	..()

/obj/item/clothing/glasses/sunglasses/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] stomps on \the [src], crushing them!</span>", "<span class='danger'>You crush \the [src] under your foot.</span>")
	playsound(src, "shatter", 50, 1)

	var/obj/item/weapon/shard/S = new(get_turf(src))
	S.Crossed()

	qdel(src)
	return SPECIAL_ATTACK_FAILED

/obj/item/clothing/glasses/sunglasses/holo/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] stomps on \the [src], crushing them and making them fade away!</span>", "<span class='danger'>You crush \the [src] under your foot, which takes less effort than you realized as they fade from existence.</span>")
	playsound(src, "shatter", 50, 1)

	qdel(src)
	return SPECIAL_ATTACK_FAILED

/obj/item/clothing/glasses/sunglasses/purple
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes, and the colored lenses let you see the world in purple."
	name = "purple sunglasses"
	icon_state = "sun_purple"
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/glasses/sunglasses/star
	name = "star-shaped sunglasses"
	desc = "Novelty sunglasses, both lenses are in the shape of a star."
	icon_state = "sun_star"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/sunglasses/rockstar
	name = "red star-shaped sunglasses"
	desc = "Novelty sunglasses with a fancy silver frame and two red-tinted star-shaped lenses. You should probably stomp on them and get a pair of normal ones."
	icon_state = "sun_star_silver"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/sunglasses/red
	name = "red sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes, and the colored lenses let you see the world in red."
	icon_state = "sunred"
	item_state = "sunred"
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/glasses/sunglasses/security
	name = "security sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes. Often worn by budget security officers."
	icon_state = "sunhud"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/virussunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	origin_tech = Tc_COMBAT + "=2"
	darkness_view = -1
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	origin_tech = Tc_ENGINEERING + "=1;" + Tc_MATERIALS + "=2"
	actions_types = list(/datum/action/item_action/toggle_goggles)
	var/up = 0
	eyeprot = 3
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/welding/attack_self()
	toggle()


/obj/item/clothing/glasses/welding/proc/toggle()
	var/mob/C = usr
	if(!usr)
		if(!ismob(loc))
			return
		C = loc
	if(!C.incapacitated())
		if(src.up)
			src.up = !src.up
			eyeprot = 3
			body_parts_covered |= EYES
			icon_state = initial(icon_state)
			to_chat(C, "You flip the [src] down to protect your eyes.")
		else
			src.up = !src.up
			eyeprot = 0
			body_parts_covered &= ~EYES
			icon_state = "[initial(icon_state)]up"
			to_chat(C, "You push the [src] up out of your face.")

		C.update_inv_glasses()

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes. Allows for better vision than normal goggles.."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_MATERIALS + "=3"

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state = "blindfold"
	see_invisible = SEE_INVISIBLE_LIVING
	vision_flags = BLIND
	eyeprot = 4 //What you can't see can't burn your eyes out
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	min_harm_label = 0

/obj/item/clothing/glasses/sunglasses/prescription
	name = "prescription sunglasses"
	prescription = 1
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	min_harm_label = 15

/obj/item/clothing/glasses/sunglasses/sechud
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	var/obj/item/clothing/glasses/hud/security/hud = null
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/sunglasses/sechud/New()
	..()
	src.hud = new/obj/item/clothing/glasses/hud/security(src)
	return

/obj/item/clothing/glasses/sunglasses/sechud/become_defective()
	if(!defective)
		..()
		if(prob(15))
			new /obj/item/weapon/shard(loc)
			playsound(src, "shatter", 50, 1)
			qdel(src)
			return
		if(prob(15))
			new/obj/item/clothing/glasses/sunglasses(get_turf(src))
			playsound(src, 'sound/effects/glass_step.ogg', 50, 1)
			qdel(src)
			return
		if(prob(55))
			eyeprot = 0
		if(prob(55))
			hud = null
			qdel(hud)

/obj/item/clothing/glasses/sunglasses/sechud/syndishades
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	darkness_view = 0 //Subtly better than normal shades
	origin_tech = Tc_SYNDICATE + "=3"
	actions_types = list(/datum/action/item_action/change_appearance_shades)
	var/static/list/clothing_choices = null
	var/full_access = FALSE

/obj/item/clothing/glasses/sunglasses/sechud/syndishades/New()
	..()
	if(!clothing_choices)
		clothing_choices = list()
		for(var/Type in existing_typesof(/obj/item/clothing/glasses) - /obj/item/clothing/glasses - typesof(/obj/item/clothing/glasses/sunglasses/sechud/syndishades))
			var/obj/glass = Type
			clothing_choices[initial(glass.name)] = glass

/obj/item/clothing/glasses/sunglasses/sechud/syndishades/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/clothing/glasses/sunglasses/sechud) || istype(I, /obj/item/clothing/glasses/hud/security))
		var/obj/item/clothing/glasses/sunglasses/sechud/syndishades/S = I
		if(istype(S) && !S.full_access)
			return
		if(full_access)
			to_chat(user, "<span class='warning'>\The [src] already has those access codes.</span>")
			return
		else
			to_chat(user, "<span class='notice'>You transfer the security access codes from \the [I] to \the [src].</span>")
			full_access = TRUE

/datum/action/item_action/change_appearance_shades
	name = "Change Shades Appearance"

/datum/action/item_action/change_appearance_shades/Trigger()
	var/obj/item/clothing/glasses/sunglasses/sechud/syndishades/T = target
	if(!istype(T))
		return
	T.change()

/obj/item/clothing/glasses/sunglasses/sechud/syndishades/proc/change()
	var/choice = input("Select style to change it to", "Style Selector") as null|anything in clothing_choices
	if(src.gcDestroyed || !choice || usr.incapacitated() || !Adjacent(usr))
		return
	var/obj/item/clothing/glasses/glass_type = clothing_choices[choice]
	desc = initial(glass_type.desc)
	name = initial(glass_type.name)
	icon_state = initial(glass_type.icon_state)
	item_state = initial(glass_type.item_state)
	_color = initial(glass_type._color)
	usr.update_inv_glasses()

/obj/item/clothing/glasses/thermal
	name = "Optical Thermal Scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	item_state = "glasses"
	species_fit = list(GREY_SHAPED)
	origin_tech = Tc_MAGNETS + "=3"
	vision_flags = SEE_MOBS
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisa_view = 2
	eyeprot = -2 //prepare for your eyes to get shit on

/obj/item/clothing/glasses/thermal/emp_act(severity)
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		to_chat(M, "<span class='warning'>\The [src] overloads and blinds you!</span>")
		if(M.glasses == src)
			M.eye_blind = 3
			M.eye_blurry = 5
			M.disabilities |= NEARSIGHTED
			spawn(100)
				M.disabilities &= ~NEARSIGHTED
	..()

/obj/item/clothing/glasses/thermal/syndi	//These are now a traitor item, concealed as mesons.	-Pete
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/thermal/monocle
	name = "Thermonocle"
	desc = "A monocle thermal."
	icon_state = "thermoncle"
	species_fit = list(GREY_SHAPED)
	flags = 0 //doesn't protect eyes because it's a monocle, duh
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")
/obj/item/clothing/glasses/thermal/monocle/harm_label_update()
	if(harm_labeled < min_harm_label)
		vision_flags |= SEE_MOBS
		see_invisible |= SEE_INVISIBLE_MINIMUM
		invisa_view = 2
	else
		vision_flags &= ~SEE_MOBS
		see_invisible &= ~SEE_INVISIBLE_MINIMUM
		invisa_view = 0

/obj/item/clothing/glasses/thermal/eyepatch
	name = "Optical Thermal Eyepatch"
	desc = "An eyepatch with built-in thermal optics."
	icon_state = "eyepatch"
	item_state = "eyepatch"
	species_fit = list(GREY_SHAPED)
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")
/obj/item/clothing/glasses/thermal/eyepatch/harm_label_update()
	if(harm_labeled < min_harm_label)
		vision_flags |= SEE_MOBS
		see_invisible |= SEE_INVISIBLE_MINIMUM
		invisa_view = 2
	else
		vision_flags &= ~SEE_MOBS
		see_invisible &= ~SEE_INVISIBLE_MINIMUM
		invisa_view = 0

/obj/item/clothing/glasses/thermal/jensen
	name = "Optical Thermal Implants"
	desc = "A set of implantable lenses designed to augment your vision."
	icon_state = "thermalimplants"
	item_state = "syringe_kit"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/simonglasses
	name = "Simon's Glasses"
	desc = "Just who the hell do you think I am?"
	icon_state = "simonglasses"
	item_state = "simonglasses"
	species_fit = list(GREY_SHAPED)
	cover_hair = 1

/obj/item/clothing/glasses/kaminaglasses
	name = "Kamina's Glasses"
	desc = "I'm going to tell you something important now, so you better dig the wax out of those huge ears of yours and listen! The reputation of Team Gurren echoes far and wide. When they talk about its badass leader - the man of indomitable spirit and masculinity - they're talking about me! The mighty Kamina!"
	icon_state = "kaminaglasses"
	item_state = "kaminaglasses"
	species_fit = list(GREY_SHAPED)
	cover_hair = 1

/obj/item/clothing/glasses/contacts
	name = "contact lenses"
	desc = "Only nerds wear glasses."
	icon = 'icons/obj/items.dmi'
	icon_state = "contact"
	prescription = 1
	body_parts_covered = null

/obj/item/clothing/glasses/contacts/polarized
	name = "polarized contact lenses"
	desc = "Protects your eyes from bright flashes of light."
	icon_state = "polarized_contact"
	darkness_view = -1
	prescription = 1
	eyeprot = 1
