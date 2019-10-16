/obj/item/clothing
	name = "clothing"
	sterility = 5
	var/list/species_restricted = null //Only these species can wear this kit.
	var/wizard_garb = 0 // Wearing this empowers a wizard.
	var/eyeprot = 0 //for head and eyewear

	//temperatures in Kelvin. These default values won't affect protections in any way.
	var/cold_breath_protection = 300 //that cloth protects its wearer's breath from cold air down to that temperature
	var/hot_breath_protection = 300 //that cloth protects its wearer's breath from hot air up to that temperature

	var/cold_speed_protection = 300 //that cloth allows its wearer to keep walking at normal speed at lower temperatures

	var/list/obj/item/clothing/accessory/accessories = list()
	var/hidecount = 0
	var/extinguishingProb = 15

/obj/item/clothing/Destroy()
	for(var/obj/item/clothing/accessory/A in accessories)
		accessories.Remove(A)
		qdel(A)
	..()
	
/obj/item/clothing/CtrlClick(var/mob/user)
	if(isturf(loc))
		return ..()
	if(isliving(user) && !user.incapacitated() && user.Adjacent(src) && accessories.len)
		removeaccessory()
	
/obj/item/clothing/examine(mob/user)
	..()
	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "<span class='info'>\A [A] is clipped to it.</span>")

/obj/item/clothing/emp_act(severity)
	for(var/obj/item/clothing/accessory/accessory in accessories)
		accessory.emp_act(severity)
	..()

/obj/item/clothing/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A = I
		if(check_accessory_overlap(A))
			to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to [src].</span>")
			return
		if(!A.can_attach_to(src))
			to_chat(user, "<span class='notice'>\The [A] cannot be attached to [src].</span>")
			return
		if(user.drop_item(I, src))
			to_chat(user, "<span class='notice'>You attach [A] to [src].</span>")
			attach_accessory(A)
			A.add_fingerprint(user)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_by_slot(slot_flags)
		return 1
	if(I.is_screwdriver(user))
		for(var/obj/item/clothing/accessory/accessory in priority_accessories())
			if(accessory.attackby(I, user))
				return 1
	for(var/obj/item/clothing/accessory/accessory in priority_accessories())
		if(accessory.attackby(I, user))
			return 1

	..()

/obj/item/clothing/attack_hand(mob/user)
	if(accessories.len && src.loc == user)
		var/list/delayed = list()
		for(var/obj/item/clothing/accessory/A in priority_accessories())
			switch(A.on_accessory_interact(user, 0))
				if(1)
					return 1
				if(-1)
					delayed.Add(A)
				else
					continue
		var/ignorecounter = 0
		for(var/obj/item/clothing/accessory/A in delayed)
			//if(A.ignoreinteract)
				//ignorecounter += 1
			ignorecounter += A.ignoreinteract
			if(!(A.ignoreinteract) && A.on_accessory_interact(user, 1))
				return 1
		if(ignorecounter == accessories.len)
			return ..()
		return
	return ..()

/obj/item/clothing/proc/attach_accessory(obj/item/clothing/accessory/accessory, mob/user)
	accessories += accessory
	accessory.forceMove(src)
	accessory.on_attached(src)
	update_verbs()

/obj/item/clothing/proc/priority_accessories()
	if(!accessories.len)
		return list()
	var/list/unorg = accessories
	var/list/prioritized = list()
	for(var/obj/item/clothing/accessory/holster/H in accessories)
		prioritized.Add(H)
	for(var/obj/item/clothing/accessory/storage/S in accessories)
		prioritized.Add(S)
	for(var/obj/item/clothing/accessory/armband/A in accessories)
		prioritized.Add(A)
	prioritized |= unorg
	return prioritized

/obj/item/clothing/proc/check_accessory_overlap(var/obj/item/clothing/accessory/accessory)
	if(!accessory)
		return

	for(var/obj/item/clothing/accessory/A in accessories)
		if(A.accessory_exclusion & accessory.accessory_exclusion)
			return 1

/obj/item/clothing/proc/remove_accessory(mob/user, var/obj/item/clothing/accessory/accessory)
	if(!accessory || !(accessory in accessories))
		return

	accessory.on_removed(user)
	accessories.Remove(accessory)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_by_slot(slot_flags)
	update_verbs()

/obj/item/clothing/proc/get_accessory_by_exclusion(var/exclusion)
	for(var/obj/item/clothing/accessory/A in accessories)
		if(A.accessory_exclusion == exclusion)
			return A

/obj/item/clothing/verb/removeaccessory()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return

	if(!accessories.len)
		return
	var/obj/item/clothing/accessory/A
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as anything in accessories
	else
		A = accessories[1]
	src.remove_accessory(usr,A)

/obj/item/clothing/proc/update_verbs()
	if(accessories.len)
		verbs |= /obj/item/clothing/verb/removeaccessory
	else
		verbs -= /obj/item/clothing/verb/removeaccessory

/obj/item/clothing/proc/is_worn_by(mob/user)
	if(user.is_wearing_item(src))
		return TRUE
	return FALSE

/obj/item/clothing/New() //so sorry
	..()
	update_verbs()

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	. = ..() //Default return value. If 1, item can be equipped. If 0, it can't be.
	if(!.)
		return //Default return value is 0 - don't check for species

	switch(role_check(M))
		if(FALSE)
			return CANNOT_EQUIP
		if(ALWAYSTRUE)
			return CAN_EQUIP

	if(species_restricted && istype(M,/mob/living/carbon/human) && (slot != slot_l_store && slot != slot_r_store))

		var/wearable = null
		var/exclusive = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		var/datum/species/base_species = H.species
		if(!base_species)
			return

		var/base_species_can_wear = 1 //If the body's main species can wear this

		if(exclusive)
			if(!species_restricted.Find(base_species.name))
				wearable = 1
			else
				base_species_can_wear = 0
		else
			if(species_restricted.Find(base_species.name))
				wearable = 1
			else
				base_species_can_wear = 0

		//Check ALL organs covered by the slot. If any of the organ's species can't wear this, return 0

		for(var/datum/organ/external/OE in get_organs_by_slot(slot, H)) //Go through all organs covered by the item
			if(!OE.species) //Species same as of the body
				if(!base_species_can_wear) //And the body's species can't wear
					wearable = 0
					break
				continue

			if(exclusive)
				if(!species_restricted.Find(OE.species.name))
					wearable = 1
				else
					to_chat(M, "<span class='warning'>Your misshapen [OE.display_name] prevents you from wearing \the [src].</span>")
					return CANNOT_EQUIP
			else
				if(species_restricted.Find(OE.species.name))
					wearable = 1
				else
					to_chat(M, "<span class='warning'>Your misshapen [OE.display_name] prevents you from wearing \the [src].</span>")
					return CANNOT_EQUIP

		if(!wearable) //But we are a species that CAN'T wear it (sidenote: slots 15 and 16 are pockets)
			to_chat(M, "<span class='warning'>Your species cannot wear [src].</span>")//Let us know
			return CANNOT_EQUIP

	//return ..()

/obj/item/clothing/proc/role_check(mob/user)
	if(!user || !user.mind || !user.mind.antag_roles.len)
		return TRUE //No roles to check
	for(var/datum/role/R in get_list_of_elements(user.mind.antag_roles))
		switch(R.can_wear(src))
			if(ALWAYSTRUE)
				return ALWAYSTRUE
			if(FALSE)
				return FALSE
			if(TRUE)
				continue
	return TRUE //All roles true? Return true.

/obj/item/clothing/before_stripped(mob/wearer as mob, mob/stripper as mob, slot)
	..()
	if(slot == slot_w_uniform) //this will cause us to drop our belt, ID, and pockets!
		for(var/slotID in list(slot_wear_id, slot_belt, slot_l_store, slot_r_store))
			var/obj/item/I = wearer.get_item_by_slot(slotID)
			if(I)
				I.stripped(wearer, stripper)

/obj/item/clothing/become_defective()
	if(!defective)
		..()
		for(var/A in armor)
			armor[A] -= rand(armor[A]/3, armor[A])

/obj/item/clothing/attack(var/mob/living/M, var/mob/living/user, def_zone, var/originator = null)
	if (!(iscarbon(user) && user.a_intent == I_HELP && (clothing_flags & CANEXTINGUISH) && ishuman(M) && M.on_fire))
		..()
	else
		var/mob/living/carbon/human/target = M
		if(isplasmaman(target)) // Cannot put out plasmamen, else they could just go around with a jumpsuit and not need a space suit.
			visible_message("<span class='warning'>\The [user] attempts to put out the fire on \the [target], but plasmafires are too hot. It is no use.</span>")
		else
			visible_message("<span class='warning'>\The [user] attempts to put out the fire on \the [target] with \the [src].</span>")
			if(prob(extinguishingProb))
				M.ExtinguishMob()
				visible_message("<span class='notice'>\The [user] puts out the fire on \the [target].</span>")
		return

/obj/item/clothing/proc/get_armor(var/type)
	return armor[type]

/obj/item/clothing/proc/get_armor_absorb(var/type)
	return armor_absorb[type]

//Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = W_CLASS_TINY
	throwforce = 2
	slot_flags = SLOT_EARS

/obj/item/clothing/ears/attack_hand(mob/user as mob)
	if (!user)
		return

	if (src.loc != user || !istype(user,/mob/living/carbon/human))
		..()
		return

	var/mob/living/carbon/human/H = user
	if(H.ears != src)
		..()
		return

	if(!canremove)
		return

	var/obj/item/clothing/ears/O = src

	user.u_equip(src,0)

	if (O)
		user.put_in_hands(O)
		O.add_fingerprint(user)

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from both loud and quiet noises."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	slot_flags = SLOT_EARS

//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = W_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/gloves.dmi', "right_hand" = 'icons/mob/in-hand/right/gloves.dmi')
	siemens_coefficient = 0.50
	sterility = 50
	var/wired = 0
	var/obj/item/weapon/cell/cell = 0
	var/clipped = 0
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenges")
	species_restricted = list("exclude","Unathi","Tajaran","Muton")
	var/pickpocket = 0 //Master pickpocket?

	var/bonus_knockout = 0 //Knockout chance is multiplied by (1 + bonus_knockout) and is capped at 1/2. 0 = 1/12 chance, 1 = 1/6 chance, 2 = 1/4 chance, 3 = 1/3 chance, etc.
	var/damage_added = 0 //Added to unarmed damage, doesn't affect knockout chance
	var/sharpness_added = 0 //Works like weapon sharpness for unarmed attacks, affects bleeding and limb severing.
	var/hitsound_added = "punch"	//The sound that plays for an unarmed attack while wearing these gloves.

	var/attack_verb_override = "punches"

/obj/item/clothing/gloves/get_cell()
	return cell

/obj/item/clothing/gloves/emp_act(severity)
	if(cell)
		cell.charge -= 1000 / severity
		if (cell.charge < 0)
			cell.charge = 0
		if(cell.reliability != 100 && prob(50/severity))
			cell.reliability -= 10 / severity
	..()

/obj/item/clothing/gloves/proc/dexterity_check(mob/user) //Set wearer's dexterity to the value returned by this proc. Doesn't override death or brain damage, and should always return 1 (unless intended otherwise)
	return 1 //Setting this to 0 will make user NOT dexterious when wearing these gloves

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(var/atom/A, mob/user, proximity)
	return 0 // return 1 to cancel attack_hand()

/obj/item/clothing/gloves/proc/get_damage_added()
	return damage_added

/obj/item/clothing/gloves/proc/get_sharpness_added()
	return sharpness_added

/obj/item/clothing/gloves/proc/get_hitsound_added()
	return hitsound_added

/obj/item/clothing/gloves/proc/on_punch(mob/user, mob/victim)
	return

/obj/item/clothing/gloves/proc/on_wearer_threw_item(mob/user, atom/target, atom/movable/thrown)	//Called when the mob wearing the gloves successfully throws either something or nothing.
	return

//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	species_restricted = list("exclude","Muton")

/obj/item/proc/islightshielded() // So as to avoid unneeded casts.
	return FALSE

//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = MOUTH
	slot_flags = SLOT_MASK
	species_restricted = list("exclude","Muton")
	var/can_flip = null
	var/is_flipped = 1
	var/ignore_flip = 0
	actions_types = list(/datum/action/item_action/toggle_mask)
	heat_conductivity = MASK_HEAT_CONDUCTIVITY

/datum/action/item_action/toggle_mask
	name = "Toggle Mask"

/datum/action/item_action/toggle_mask/Trigger()
	var/obj/item/clothing/mask/T = target
	if(!istype(T))
		return
	T.togglemask()

/obj/item/clothing/mask/proc/togglemask()
	if(ignore_flip)
		return
	else
		if(usr.incapacitated())
			return
		if(!can_flip)
			to_chat(usr, "You try pushing \the [src] out of the way, but it is very uncomfortable and you look like a fool. You push it back into place.")
			return
		if(src.is_flipped == 2)
			src.icon_state = initial(icon_state)
			gas_transfer_coefficient = initial(gas_transfer_coefficient)
			permeability_coefficient = initial(permeability_coefficient)
			flags = initial(flags)
			body_parts_covered = initial(body_parts_covered)
			to_chat(usr, "You push \the [src] back into place.")
			src.is_flipped = 1
		else
			src.icon_state = "[initial(icon_state)]_up"
			to_chat(usr, "You push \the [src] out of the way.")
			gas_transfer_coefficient = null
			permeability_coefficient = null
			flags = 0
			src.is_flipped = 2
			body_parts_covered &= ~(MOUTH|HEAD|BEARD|FACE)
		usr.update_inv_wear_mask()
		usr.update_hair()
		usr.update_inv_glasses()

/obj/item/clothing/mask/New()
	if(!can_flip /*&& !istype(/obj/item/clothing/mask/gas/voice)*/) //the voice changer has can_flip = 1 anyways but it's worth noting that it exists if anybody changes this in the future
		actions_types = null
	..()

/obj/item/clothing/mask/attack_self()
	togglemask()

//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing

	var/chained = 0
	var/chaintype = null // Type of chain.
	var/bonus_kick_damage = 0
	var/footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints //The type of footprint left by someone wearing these
	var/mag_slow = MAGBOOTS_SLOWDOWN_HIGH //how slow are they when the magpulse is on?

	siemens_coefficient = 0.9
	body_parts_covered = FEET
	slot_flags = SLOT_FEET
	heat_conductivity = SHOE_HEAT_CONDUCTIVITY
	permeability_coefficient = 0.50
	sterility = 50

	species_restricted = list("exclude","Unathi","Tajaran","Muton")
	var/step_sound = ""
	var/stepstaken = 1

/obj/item/clothing/shoes/proc/step_action()
	stepstaken++
	if(step_sound != "" && ishuman(loc))
		var/mob/living/carbon/human/H = loc
		switch(H.m_intent)
			if("run")
				if(stepstaken % 2 == 1)
					playsound(H, step_sound, 50, 1) // this will NEVER GET ANNOYING!
			if("walk")
				playsound(H, step_sound, 20, 1)

/obj/item/clothing/shoes/proc/on_kick(mob/living/user, mob/living/victim)
	return

/obj/item/clothing/shoes/clean_blood()
	. = ..()
	track_blood = 0

/obj/item/clothing/shoes/proc/togglemagpulse(var/mob/user = usr, var/override = FALSE)
	if(!override)
		if(user.isUnconscious())
			return
	if((clothing_flags & MAGPULSE))
		clothing_flags &= ~(NOSLIP | MAGPULSE)
		slowdown = NO_SLOWDOWN
		return 0
	else
		clothing_flags |= (NOSLIP | MAGPULSE)
		slowdown = mag_slow
		return 1

//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	flags = FPRINT
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_OCLOTHING
	heat_conductivity = ARMOUR_HEAT_CONDUCTIVITY
	body_parts_covered = ARMS|LEGS|FULL_TORSO
	var/blood_overlay_type = "suit"
	species_restricted = list("exclude","Muton")
	siemens_coefficient = 0.9
	clothing_flags = CANEXTINGUISH
	sterility = 30

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corresponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	flags = FPRINT|HIDEHAIRCOMPLETELY
	pressure_resistance = 5 * ONE_ATMOSPHERE
	item_state = "space"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/spacesuits.dmi', "right_hand" = 'icons/mob/in-hand/right/spacesuits.dmi')
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	body_parts_covered = FULL_HEAD|BEARD
	siemens_coefficient = 0.9
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	species_restricted = list("exclude","Diona","Muton")
	eyeprot = 1
	cold_breath_protection = 230
	sterility = 100

/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments. Has a big \"13\" on the back."
	icon_state = "space"
	item_state = "s_suit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/spacesuits.dmi', "right_hand" = 'icons/mob/in-hand/right/spacesuits.dmi')
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = FPRINT
	pressure_resistance = 5 * ONE_ATMOSPHERE
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/)
	slowdown = HARDSUIT_SLOWDOWN_BULKY
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	siemens_coefficient = 0.9
	species_restricted = list("exclude","Diona","Muton")
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	clothing_flags = CANEXTINGUISH
	sterility = 100

//Under clothing
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = ARMS|LEGS|FULL_TORSO
	permeability_coefficient = 0.90
	flags = FPRINT
	slot_flags = SLOT_ICLOTHING
	heat_conductivity = JUMPSUIT_HEAT_CONDUCTIVITY
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	species_restricted = list("exclude","Muton")
	var/has_sensor = 1 //For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1
	clothing_flags = CANEXTINGUISH

/obj/item/clothing/under/examine(mob/user)
	..()
	var/mode
	switch(src.sensor_mode)
		if(0)
			mode = "Its sensors appear to be disabled."
		if(1)
			mode = "Its binary life sensors appear to be enabled."
		if(2)
			mode = "Its vital tracker appears to be enabled."
		if(3)
			mode = "Its vital tracker and tracking beacon appear to be enabled."
	to_chat(user, "<span class='info'>" + mode + "</span>")

/obj/item/clothing/under/emp_act(severity)
	..()
	sensor_mode = pick(0,1,2,3)

/obj/item/clothing/under/proc/set_sensors(mob/user as mob)
	if(user.incapacitated())
		return
	if(has_sensor >= 2)
		to_chat(user, "<span class='warning'>The controls are locked.</span>")
		return 0
	if(has_sensor <= 0)
		to_chat(user, "<span class='warning'>This suit does not have any sensors.</span>")
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(user.incapacitated())
		return
	if(get_dist(user, src) > 1)
		to_chat(user, "<span class='warning'>You have moved too far away.</span>")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if(is_holder_of(user, src))
		switch(sensor_mode) //i'm sure there's a more compact way to write this but c'mon
			if(0)
				to_chat(user, "<span class='notice'>You disable your suit's remote sensing equipment.</span>")
			if(1)
				to_chat(user, "<span class='notice'>Your suit will now report whether you are live or dead.</span>")
			if(2)
				to_chat(user, "<span class='notice'>Your suit will now report your vital lifesigns.</span>")
			if(3)
				to_chat(user, "<span class='notice'>Your suit will now report your vital lifesigns as well as your coordinate position.</span>")
	else
		switch(sensor_mode)
			if(0)
				to_chat(user, "<span class='notice'>You disable the suit's remote sensing equipment.</span>")
			if(1)
				to_chat(user, "<span class='notice'>The suit sensors will now report whether the wearer is live or dead.</span>")
			if(2)
				to_chat(user, "<span class='notice'>The suit sensors will now report the wearer's vital lifesigns.</span>")
			if(3)
				to_chat(user, "<span class='notice'>The suit sensors will now report the wearer's vital lifesigns as well as their coordinate position.</span>")
	return switchMode

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/AltClick()
	if(is_holder_of(usr, src))
		set_sensors(usr)
	else
		return ..()

/datum/action/item_action/toggle_minimap
	name = "Toggle Minimap"

/datum/action/item_action/toggle_minimap/Trigger()
	var/obj/item/clothing/under/T = target
	if(!istype(T))
		return
	for(var/obj/item/clothing/accessory/holomap_chip/HC in T.accessories)
		HC.togglemap()

/obj/item/clothing/under/rank/New()
	. = ..()
	sensor_mode = pick(0, 1, 2, 3)


//Capes?
/obj/item/clothing/back
	name = "cape"
	w_class = W_CLASS_SMALL
	throwforce = 2
	slot_flags = SLOT_BACK
