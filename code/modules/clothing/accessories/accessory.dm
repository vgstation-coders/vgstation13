/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands by default
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing_accessories.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing_accessories.dmi')
	_color = null
	flags = FPRINT
	slot_flags = 0
	w_class = W_CLASS_SMALL
	quick_equip_priority = list(slot_w_uniform)
	species_fit = list(VOX_SHAPED)
	var/accessory_exclusion = DECORATION
	var/obj/item/clothing/attached_to = null
	var/image/inv_overlay
	var/ignoreinteract = FALSE //for accessories that should not come off when attached to object is touched

/obj/item/clothing/accessory/New()
	..()
	update_icon()

/obj/item/clothing/accessory/update_icon()
	if(attached_to)
		attached_to.overlays -= inv_overlay
	inv_overlay = image("icon" = 'icons/obj/clothing/accessory_overlays.dmi', "icon_state" = "[_color || icon_state]")
	if(color)
		inv_overlay.color = color

	overlays.len = 0
	inv_overlay.overlays.len = 0
	for (var/part in dyed_parts)
		var/list/dye_data = dyed_parts[part]
		var/dye_color = dye_data[1]
		var/dye_alpha = dye_data[2]

		var/_state = dye_base_iconstate_override
		if (!_state)
			_state = icon_state
		var/image/object_overlay = image(icon, src, "[_state]-[part]")
		object_overlay.appearance_flags = RESET_COLOR
		object_overlay.color = dye_color
		object_overlay.alpha = dye_alpha
		overlays += object_overlay

		var/image/worn_overlay = image(cloth_icon, src, "[_state]-[part]")
		worn_overlay.appearance_flags = RESET_COLOR
		worn_overlay.color = dye_color
		worn_overlay.alpha = dye_alpha
		inv_overlay.overlays += worn_overlay

	if(attached_to)
		attached_to.overlays += inv_overlay
		if(iscarbon(attached_to.loc))
			var/mob/living/carbon/carbon_attached_to = attached_to.loc
			carbon_attached_to.update_inv_by_slot(attached_to.slot_flags)

/obj/item/clothing/accessory/proc/can_attach_to(obj/item/clothing/C)
	return istype(C, /obj/item/clothing/under) //By default, accessories can only be attached to jumpsuits

/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/C)
	if(!istype(C))
		return
	attached_to = C
	attached_to.overlays += inv_overlay

/obj/item/clothing/accessory/proc/on_removed(mob/user as mob)
	if(!attached_to)
		return
	to_chat(user, "<span class='notice'>You remove [src] from [attached_to].</span>")
	attached_to.overlays -= inv_overlay
	attached_to = null
	forceMove(get_turf(src))
	if(user)
		user.put_in_hands(src)
		add_fingerprint(user)

/obj/item/clothing/accessory/proc/on_accessory_interact(mob/user, delayed = 0)
	if(!attached_to)
		return
	if(delayed)
		attached_to.remove_accessory(user, src)
		attack_hand(user)
		return 1
	return -1

/obj/item/clothing/accessory/Destroy()
	on_removed(null)
	inv_overlay = null
	return ..()

//Defining this at item level to prevent CASTING HELL
/obj/item/proc/generate_accessory_overlays()
	return

/obj/item/clothing/generate_accessory_overlays(mutable_appearance/accessory_overlay_final, datum/species/species)
	if(!accessories.len)
		return
	if(!species && ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		species = wearer.species
	for(var/obj/item/clothing/accessory/accessory in accessories)
		var/mutable_appearance/accessory_overlay = mutable_appearance('icons/mob/clothing_accessories.dmi', "[accessory._color || accessory.icon_state]")
		if(species && (species.name in accessory.species_fit) && icon_exists(species.accessory_icons, accessory_overlay.icon_state))
			accessory_overlay.icon = species.accessory_icons
		accessory_overlay.color = accessory.color
		for(var/part in accessory.dyed_parts)
			var/list/dye_data = accessory.dyed_parts[part]
			var/dye_color = dye_data[1]
			var/dye_alpha = dye_data[2]
			var/_state = accessory.dye_base_iconstate_override || accessory.icon_state
			var/mutable_appearance/worn_overlay = mutable_appearance('icons/mob/clothing_accessories.dmi', "[_state]-[part]", alpha = dye_alpha, appearance_flags = RESET_COLOR)
			worn_overlay.color = dye_color
			accessory_overlay.overlays += worn_overlay
		accessory_overlay_final.overlays += accessory_overlay

//Defining this at item level to prevent CASTING HELL
/obj/item/proc/description_accessories()
	return

/obj/item/proc/description_hats()
	return

/obj/item/clothing/description_accessories()
	if(accessories.len)
		return " It has [counted_english_list(accessories)]."

/obj/item/clothing/accessory/pinksquare
	name = "pink square"
	desc = "It's a pink square."
	icon_state = "pinksquare"
	_color = "pinksquare"
/obj/item/clothing/accessory/pinksquare/can_attach_to(obj/item/clothing/C)
	return 1

/obj/item/clothing/accessory/tie
	restraint_resist_time = 30 SECONDS
	toolsounds = list("rustle")

/obj/item/clothing/accessory/tie/can_attach_to(obj/item/clothing/C)
	if(istype(C))
		return (C.body_parts_covered & UPPER_TORSO) //Sure why not

/obj/item/clothing/accessory/tie/blue
	name = "blue tie"
	icon_state = "bluetie"
	_color = "bluetie"
	accessory_exclusion = TIE

/obj/item/clothing/accessory/tie/red
	name = "red tie"
	icon_state = "redtie"
	_color = "redtie"
	accessory_exclusion = TIE

/obj/item/clothing/accessory/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	_color = "horribletie"
	accessory_exclusion = TIE

/obj/item/clothing/accessory/tie/bolo
	name = "bolo tie"
	desc = "Feels more like a millstone."
	icon_state = "bolotie"
	_color = "bolotie"
	accessory_exclusion = TIE

/obj/item/clothing/accessory/tie/linen
	name = "tie"
	desc = "A woven tie."
	icon_state = "tie"
	accessory_exclusion = TIE

	color = COLOR_LINEN
	clothing_flags = COLORS_OVERLAY
	dyeable_parts = list("pattern","tip")

/obj/item/clothing/accessory/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	_color = "stethoscope"
	origin_tech = Tc_BIOTECH + "=1"
	restraint_resist_time = 30 SECONDS
	toolsounds = list("rustle")

/obj/item/clothing/accessory/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user.a_intent == I_HELP)
			var/body_part = parse_zone(user.zone_sel.selecting)
			if(body_part)
				var/their = "their"
				switch(M.gender)
					if(MALE)
						their = "his"
					if(FEMALE)
						their = "her"

				var/sound = "pulse"
				var/sound_strength

				if(M.isDead())
					sound_strength = "cannot hear"
					sound = "anything"
				else
					sound_strength = "hear a weak"
					switch(body_part)
						if(LIMB_CHEST)
							if(M.oxyloss < 50)
								sound_strength = "hear a healthy"
							sound = "pulse and respiration"
						if("eyes","mouth")
							sound_strength = "cannot hear"
							sound = "anything"
						else
							sound_strength = "hear a weak"

				user.visible_message("[user] places [src] against [M]'s [body_part] and listens attentively.", "You place [src] against [their] [body_part]. You [sound_strength] [sound].")
				return
	return ..(M,user)


//Medals
/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	_color = "bronze"

/obj/item/clothing/accessory/medal/can_attach_to(obj/item/clothing/C)
	if(istype(C))
		return (C.body_parts_covered & UPPER_TORSO) //Sure why not

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/accessory/medal/participation
	name = "super participation medal"
	desc = "On closer inspection, this one is dated 2551..."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/nobel_science
	name = "nobel sciences award"
	desc = "A bronze medal which represents significant contributions to the field of science or engineering."

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	_color = "silver"

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	_color = "gold"

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentComm. To receive such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/obj/item/clothing/accessory/medal/byond
	name = "\improper BYOND support pin"
	icon_state = "byond"
	_color = "byond"
	desc = "A cheap, but surprisingly rare, plastic pin. Sent to supporters by the BYOND corporation."

/obj/item/clothing/accessory/medal/byond/on_attached(obj/item/clothing/C)
	..()
	if(ismob(C.loc))
		var/mob/living/carbon/human/supporter = C.loc
		if((supporter.getBrainLoss()) < 5)
			supporter.adjustBrainLoss(1)

/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/holobadge

	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	_color = "holobadge"
	slot_flags = SLOT_BELT

	var/stored_name = null

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"
	_color = "holobadge-cord"
	slot_flags = SLOT_MASK

/obj/item/clothing/accessory/holobadge/attack_self(mob/user as mob)
	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return
	if(isliving(user))
		user.visible_message("<span class='warning'>[user] displays their Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>","<span class='warning'>You display your Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>")

/obj/item/clothing/accessory/holobadge/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))

		var/obj/item/weapon/card/id/id_card = null

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if ((access_security in id_card.access) || emagged)
			to_chat(user, "You imprint your ID details onto the badge.")
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW."
		else
			to_chat(user, "[src] rejects your insufficient access rights.")
		return
	..()

/obj/item/clothing/accessory/holobadge/emag_act(mob/user)
	if (emagged)
		to_chat(user, "<span class='warning'>[src] is already cracked.</span>")
	else
		emagged = 1
		to_chat(user, "<span class='warning'>You swipe the cryptographic sequencer and crack the holobadge security checks.</span>")

/obj/item/clothing/accessory/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message("<span class='warning'>[user] invades [M]'s personal space, thrusting [src] into their face insistently.</span>","<span class='warning'>You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law.</span>")

/obj/item/clothing/accessory/assistantcard
	name = "assistant card"
	desc = "This nanopaper slip marks the holder as HELPFUL."
	icon_state = "assistantcard"
	_color = "assistantcard"
	slot_flags = SLOT_BELT
	var/stored_name = null
	starting_materials = list(MAT_PLASTIC = 50)
	w_type = RECYK_PLASTIC

/obj/item/clothing/accessory/assistantcard/attack_self(mob/user as mob)
	if(!stored_name)
		user.visible_message("<span class='notice'>[user] displays their official assistant card.\nIt reads: Here To Help.</span>","<span class='notice'>You display your official assistant card.\nIt reads: Here To Help.</span>")
		return
	if(isliving(user))
		user.visible_message("<span class='notice'>[user] displays their official assistant card.\nIt reads: [stored_name], Here To Help.</span>","<span class='notice'>You display your official assistant card.\nIt reads: [stored_name], Here To Help.</span>")

/obj/item/clothing/accessory/assistantcard/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))

		var/obj/item/weapon/card/id/id_card = null

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		to_chat(user, "You imprint your ID details onto the card.")
		stored_name = id_card.registered_name
		name = "assistant card ([stored_name])"
		desc = "This nanopaper slip marks [stored_name] as HELPFUL."
		return
	..()

/obj/item/clothing/accessory/assistantcard/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message("<span class='notice'>[user] invades [M]'s personal space, thrusting [src] into their face insistently.</span>","<span class='notice'>You invade [M]'s personal space, thrusting [src] into their face insistently. You're here to help.</span>")

/obj/item/clothing/accessory/lasertag
	name = "laser tag vest"
	desc = "A vest for player laser tag."
	icon = null
	icon_state = null
	accessory_exclusion = LASERTAG
	inv_overlay
	var/obj/item/clothing/suit/tag/source_vest

/obj/item/clothing/accessory/lasertag/can_attach_to(obj/item/clothing/C)
	return ..() || istype(C, /obj/item/clothing/monkeyclothes)

/obj/item/clothing/accessory/lasertag/update_icon()
	if(source_vest)
		appearance = source_vest.appearance
		if(attached_to)
			var/image/vestoverlay = image('icons/mob/suit.dmi', src, icon_state)
			attached_to.dynamic_overlay["[UNIFORM_LAYER]"] = vestoverlay
			if(ismob(attached_to.loc))
				var/mob/M = attached_to.loc
				M.regenerate_icons()
	..()

/obj/item/clothing/accessory/lasertag/on_removed(mob/user)
	if(!attached_to)
		return
	attached_to.dynamic_overlay["[UNIFORM_LAYER]"] = null
	attached_to.overlays -= inv_overlay
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.regenerate_icons()
	attached_to = null
	if(source_vest)
		source_vest.forceMove(get_turf(src))
		if(user)
			user.put_in_hands(source_vest)
		add_fingerprint(user)
		transfer_fingerprints(src,source_vest)
		source_vest = null
	qdel(src)


/obj/item/clothing/accessory/jinglebells
	name = "jingle bells"
	desc = "A festive jingley bell, can be attached to shoes!"
	icon_state = "jinglebells"
	item_state = "jinglebells"
	_color =  "jinglebells"

/obj/item/clothing/accessory/jinglebells/pickup(mob/user)
	user.register_event(/event/face, src, /obj/item/clothing/accessory/jinglebells/proc/jingle)
	jingle()

/obj/item/clothing/accessory/jinglebells/dropped(mob/user)
	user.unregister_event(/event/face, src, /obj/item/clothing/accessory/jinglebells/proc/jingle)

/obj/item/clothing/accessory/jinglebells/proc/jingle()
	var/turf/T = get_turf(src)
	playsound(T, "jinglebell", 50, 1)

/obj/item/clothing/accessory/jinglebells/can_attach_to(obj/item/clothing/C)
	return istype(C, /obj/item/clothing/shoes)

/obj/item/clothing/accessory/jinglebells/on_attached(obj/item/clothing/shoes/jingleshoe)
	..()
	attached_to = jingleshoe
	jingleshoe.step_sound = "jinglebell"

/obj/item/clothing/accessory/jinglebells/on_removed(mob/user)
	var/obj/item/clothing/shoes/shoes_attached_to = attached_to
	shoes_attached_to.step_sound = null
	..()

/obj/item/clothing/accessory/rad_patch
	name = "radiation detection patch"
	desc = "A paper patch that you can attach to your clothing. Changes color to black when it absorbs over a certain amount of radiation."
	icon_state = "patch_0"
	var/rad_absorbed = 0
	var/rad_threshold = 45
	var/triggered = FALSE
	var/event_key

	w_class = W_CLASS_TINY
	w_type = RECYK_WOOD
	flammable = TRUE

/obj/item/clothing/accessory/rad_patch/proc/check_rads(mob/living/carbon/human/user, rads)
	if(triggered)
		return
	rad_absorbed += rads

	if(rad_absorbed > rad_threshold)
		triggered = TRUE
		update_icon()
		to_chat(user, "<span class = 'warning'>You hear \the [src] tick!</span>")

		user.unregister_event(/event/irradiate, src, nameof(src::check_rads()))

/obj/item/clothing/accessory/rad_patch/on_attached(obj/item/clothing/C)
	..()
	if(ismob(C.loc) && !triggered)
		var/mob/user = C.loc
		user.register_event(/event/irradiate, src, nameof(src::check_rads()))

/obj/item/clothing/accessory/rad_patch/on_removed(mob/user)
	..()
	user?.unregister_event(/event/irradiate, src, nameof(src::check_rads()))

/obj/item/clothing/accessory/rad_patch/examine(mob/user)
	..(user)
	if(triggered)
		to_chat(user, "<span class = 'warning'>It is a deep dark color!</span>")

/obj/item/clothing/accessory/rad_patch/update_icon()
	if(triggered)
		icon_state = "patch_1"
	else
		icon_state = "patch_0"
	..()

/obj/item/clothing/accessory/rabbit_foot
	name = "rabbit's foot"
	desc = "The hind left foot from a rabbit. It makes you feel lucky."
	icon_state = "rabbit_foot"
	_color = "rabbit_foot"
	var/wired = FALSE
	luckiness = 50
	luckiness_validity = LUCKINESS_WHEN_GENERAL_RECURSIVE

/obj/item/clothing/accessory/rabbit_foot/attackby(obj/item/I, mob/user)
	..()
	if(iscablecoil(I))
		var/obj/item/stack/cable_coil/C = I
		if(wired)
			to_chat(user, "<span class='info'>\The [src] already has a loop on it.</span>")
			//break
		else if(C.use(5))
			wired = TRUE
			overlays += image("icon" = 'icons/obj/clothing/accessories.dmi', "icon_state" = "rabbit_foot_loop")
			to_chat(user, "<span class='info'>You add a loop to \the [src].</span>")
		else
			to_chat(user, "<span class='info'>You need at least 5 lengths of cable to add a loop to this.</span>")

/obj/item/clothing/accessory/rabbit_foot/can_attach_to(obj/item/clothing/C)
	if(wired)
		return istype(C, /obj/item/clothing/under)
	else
		return FALSE

// -- Voter pin

/obj/item/clothing/accessory/voter_pin
	name = "voter pin"
	desc = "This little pin proves the holder takes their civic duty very seriously."
	icon_state = "voting_pin"
	_color = "voting_pin"


/obj/item/clothing/accessory/ribbon_medal
	name = "bronze medal"
	desc = "Even though you were late to the party, you were still the life of it."
	icon_state = "bronze_medal"
	_color = "bronze_medal"

/obj/item/clothing/accessory/ribbon_medal/silver
	name = "silver medal"
	desc = "Of all the losers, you're the number one loser. No one lost ahead of you."
	icon_state = "silver_medal"
	_color = "silver_medal"

/obj/item/clothing/accessory/ribbon_medal/gold
	name = "gold medal"
	desc = "You won! Congratulations! You've put in a lot of effort and it paid off. Good job."
	icon_state = "gold_medal"
	_color = "gold_medal"

