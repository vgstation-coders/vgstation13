//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = GLASSESCOVERSEYES
	slot_flags = SLOT_EYES
	strip_delay = 20
	equip_delay_other = 25
	resistance_flags = NONE
	materials = list(MAT_GLASS = 250)
	var/vision_flags = 0
	var/darkness_view = 2//Base human is 2
	var/invis_view = SEE_INVISIBLE_LIVING	//admin only for now
	var/invis_override = 0 //Override to allow glasses to set higher than normal see_invis
	var/lighting_alpha
	var/list/icon/current = list() //the current hud icons
	var/vision_correction = 0 //does wearing these glasses correct some of our vision defects?
	var/glass_colour_type //colors your vision when worn

/obj/item/clothing/glasses/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is stabbing \the [src] into their eyes! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/clothing/glasses/examine(mob/user)
	..()
	if(glass_colour_type && ishuman(user))
		to_chat(user, "<span class='notice'>Alt-click to toggle its colors.</span>")

/obj/item/clothing/glasses/visor_toggling()
	..()
	if(visor_vars_to_toggle & VISOR_VISIONFLAGS)
		vision_flags ^= initial(vision_flags)
	if(visor_vars_to_toggle & VISOR_DARKNESSVIEW)
		darkness_view ^= initial(darkness_view)
	if(visor_vars_to_toggle & VISOR_INVISVIEW)
		invis_view ^= initial(invis_view)

/obj/item/clothing/glasses/weldingvisortoggle(mob/user)
	. = ..()
	if(. && user)
		user.update_sight()

//called when thermal glasses are emped.
/obj/item/clothing/glasses/proc/thermal_overload()
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		if(!(H.has_trait(TRAIT_BLIND)))
			if(H.glasses == src)
				to_chat(H, "<span class='danger'>[src] overloads and blinds you!</span>")
				H.flash_act(visual = 1)
				H.blind_eyes(3)
				H.blur_eyes(5)
				H.adjust_eye_damage(5)

/obj/item/clothing/glasses/meson
	name = "optical meson scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting conditions."
	icon_state = "meson"
	item_state = "meson"
	darkness_view = 2
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/lightgreen

/obj/item/clothing/glasses/meson/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is putting \the [src] to their eyes and overloading the brightness! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/clothing/glasses/meson/night
	name = "night vision meson scanner"
	desc = "An optical meson scanner fitted with an amplified visible light spectrum overlay, providing greater visual clarity in darkness."
	icon_state = "nvgmeson"
	item_state = "nvgmeson"
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/green

/obj/item/clothing/glasses/meson/gar
	name = "gar mesons"
	icon_state = "garm"
	item_state = "garm"
	desc = "Do the impossible, see the invisible!"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "A pair of snazzy goggles used to protect against chemical spills. Fitted with an analyzer for scanning items and reagents."
	icon_state = "purple"
	item_state = "glasses"
	scan_reagents = 1 //You can see reagents while wearing science goggles
	actions_types = list(/datum/action/item_action/toggle_research_scanner)
	glass_colour_type = /datum/client_colour/glass_colour/purple
	resistance_flags = ACID_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)

/obj/item/clothing/glasses/science/item_action_slot_check(slot)
	if(slot == slot_glasses)
		return 1

/obj/item/clothing/glasses/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/green

/obj/item/clothing/glasses/science/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is tightening \the [src]'s straps around their neck! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol

/obj/item/clothing/glasses/material
	name = "optical material scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	item_state = "glasses"
	vision_flags = SEE_OBJS
	glass_colour_type = /datum/client_colour/glass_colour/lightblue

/obj/item/clothing/glasses/material/mining
	name = "optical material scanner"
	desc = "Used by miners to detect ores deep within the rock."
	icon_state = "material"
	item_state = "glasses"
	darkness_view = 0

/obj/item/clothing/glasses/material/mining/gar
	name = "gar material scanner"
	icon_state = "garm"
	item_state = "garm"
	desc = "Do the impossible, see the invisible!"
	force = 10
	throwforce = 20
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP
	glass_colour_type = /datum/client_colour/glass_colour/lightgreen

/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	item_state = "glasses"
	vision_correction = 1 //corrects nearsightedness

/obj/item/clothing/glasses/regular/jamjar
	name = "jamjar glasses"
	desc = "Also known as Virginity Protectors."
	icon_state = "jamjar_glasses"
	item_state = "jamjar_glasses"

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"

//Here lies green glasses, so ugly they died. RIP

/obj/item/clothing/glasses/sunglasses
	name = "sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks flashes."
	icon_state = "sun"
	item_state = "sunglasses"
	darkness_view = 1
	flash_protect = 1
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/gray
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/glasses/sunglasses/reagent
	name = "beer goggles"
	desc = "A pair of sunglasses outfitted with apparatus to scan reagents."
	scan_reagents = 1

/obj/item/clothing/glasses/sunglasses/garb
	name = "black gar glasses"
	desc = "Go beyond impossible and kick reason to the curb!"
	icon_state = "garb"
	item_state = "garb"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/clothing/glasses/sunglasses/garb/supergarb
	name = "black giga gar glasses"
	desc = "Believe in us humans."
	icon_state = "supergarb"
	item_state = "garb"
	force = 12
	throwforce = 12

/obj/item/clothing/glasses/sunglasses/gar
	name = "gar glasses"
	desc = "Just who the hell do you think I am?!"
	icon_state = "gar"
	item_state = "gar"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP
	glass_colour_type = /datum/client_colour/glass_colour/orange

/obj/item/clothing/glasses/sunglasses/gar/supergar
	name = "giga gar glasses"
	desc = "We evolve past the person we were a minute before. Little by little we advance with each turn. That's how a drill works!"
	icon_state = "supergar"
	item_state = "gar"
	force = 12
	throwforce = 12
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders; approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	materials = list(MAT_METAL = 250)
	flash_protect = 2
	tint = 2
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_cover = GLASSESCOVERSEYES
	visor_flags_inv = HIDEEYES
	glass_colour_type = /datum/client_colour/glass_colour/gray

/obj/item/clothing/glasses/welding/attack_self(mob/user)
	weldingvisortoggle(user)


/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state = "blindfold"
	flash_protect = 2
	tint = 3			// to make them blind

/obj/item/clothing/glasses/sunglasses/blindfold/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == slot_glasses)
		user.become_blind("blindfold_[REF(src)]")

/obj/item/clothing/glasses/sunglasses/blindfold/dropped(mob/living/carbon/human/user)
	..()
	user.cure_blind("blindfold_[REF(src)]")

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/thermal
	name = "optical thermal scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	item_state = "glasses"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = 0
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/thermal/emp_act(severity)
	thermal_overload()
	..()

/obj/item/clothing/glasses/thermal/syndi	//These are now a traitor item, concealed as mesons.	-Pete
	name = "chameleon thermals"
	desc = "A pair of thermal optic goggles with an onboard chameleon generator."
	flash_protect = -1

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/glasses/thermal/syndi/New()
	..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/glasses/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/glasses/thermal/syndi/emp_act(severity)
	..()
	chameleon_action.emp_randomise()

/obj/item/clothing/glasses/thermal/monocle
	name = "thermoncle"
	desc = "Never before has seeing through walls felt so gentlepersonly."
	icon_state = "thermoncle"
	flags_1 = null //doesn't protect eyes because it's a monocle, duh

/obj/item/clothing/glasses/thermal/monocle/examine(mob/user) //Different examiners see a different description!
	var/desk = desc
	if(user.gender == MALE)
		desc = replacetext(desc, "person", "man")
	else if(user.gender == FEMALE)
		desc = replacetext(desc, "person", "woman")
	..()
	desc = desk

/obj/item/clothing/glasses/thermal/eyepatch
	name = "optical thermal eyepatch"
	desc = "An eyepatch with built-in thermal optics."
	icon_state = "eyepatch"
	item_state = "eyepatch"

/obj/item/clothing/glasses/cold
	name = "cold goggles"
	desc = "A pair of goggles meant for low temperatures."
	icon_state = "cold"
	item_state = "cold"

/obj/item/clothing/glasses/heat
	name = "heat goggles"
	desc = "A pair of goggles meant for high temperatures."
	icon_state = "heat"
	item_state = "heat"

/obj/item/clothing/glasses/orange
	name = "orange glasses"
	desc = "A sweet pair of orange shades."
	icon_state = "orangeglasses"
	item_state = "orangeglasses"
	glass_colour_type = /datum/client_colour/glass_colour/lightorange

/obj/item/clothing/glasses/red
	name = "red glasses"
	desc = "Hey, you're looking good, senpai!"
	icon_state = "redglasses"
	item_state = "redglasses"
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/godeye
	name = "eye of god"
	desc = "A strange eye, said to have been torn from an omniscient creature that used to roam the wastes."
	icon_state = "godeye"
	item_state = "godeye"
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	darkness_view = 8
	scan_reagents = 1
	flags_1 = NODROP_1
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/clothing/glasses/godeye/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, src) && W != src && W.loc == user)
		if(W.icon_state == "godeye")
			W.icon_state = "doublegodeye"
			W.item_state = "doublegodeye"
			W.desc = "A pair of strange eyes, said to have been torn from an omniscient creature that used to roam the wastes. There's no real reason to have two, but that isn't stopping you."
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.update_inv_wear_mask()
		else
			to_chat(user, "<span class='notice'>The eye winks at you and vanishes into the abyss, you feel really unlucky.</span>")
		qdel(src)
	..()

/obj/item/clothing/glasses/AltClick(mob/user)
	if(glass_colour_type && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.client)
			if(H.client.prefs)
				if(src == H.glasses)
					H.client.prefs.uses_glasses_colour = !H.client.prefs.uses_glasses_colour
					if(H.client.prefs.uses_glasses_colour)
						to_chat(H, "You will now see glasses colors.")
					else
						to_chat(H, "You will no longer see glasses colors.")
					H.update_glasses_color(src, 1)
	else
		return ..()

/obj/item/clothing/glasses/proc/change_glass_color(mob/living/carbon/human/H, datum/client_colour/glass_colour/new_color_type)
	var/old_colour_type = glass_colour_type
	if(!new_color_type || ispath(new_color_type)) //the new glass colour type must be null or a path.
		glass_colour_type = new_color_type
		if(H && H.glasses == src)
			if(old_colour_type)
				H.remove_client_colour(old_colour_type)
			if(glass_colour_type)
				H.update_glasses_color(src, 1)


/mob/living/carbon/human/proc/update_glasses_color(obj/item/clothing/glasses/G, glasses_equipped)
	if(client && client.prefs.uses_glasses_colour && glasses_equipped)
		add_client_colour(G.glass_colour_type)
	else
		remove_client_colour(G.glass_colour_type)
