/obj/item/organ/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_ARM
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)

	var/list/items_list = list()
	// Used to store a list of all items inside, for multi-item implants.
	// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.

	var/obj/item/holder = null
	// You can use this var for item path, it would be converted into an item on New()

/obj/item/organ/cyberimp/arm/Initialize()
	. = ..()
	if(ispath(holder))
		holder = new holder(src)

	update_icon()
	SetSlotFromZone()
	items_list = contents.Copy()

/obj/item/organ/cyberimp/arm/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = ORGAN_SLOT_LEFT_ARM_AUG
		if(BODY_ZONE_R_ARM)
			slot = ORGAN_SLOT_RIGHT_ARM_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/arm/update_icon()
	if(zone == BODY_ZONE_R_ARM)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/arm/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>[src] is assembled in the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.</span>")

/obj/item/organ/cyberimp/arm/screwdriver_act(mob/living/user, obj/item/I)
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_ARM)
		zone = BODY_ZONE_L_ARM
	else
		zone = BODY_ZONE_R_ARM
	SetSlotFromZone()
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>")
	update_icon()

/obj/item/organ/cyberimp/arm/Remove(mob/living/carbon/M, special = 0)
	Retract()
	..()

/obj/item/organ/cyberimp/arm/emp_act(severity)
	if(prob(15/severity) && owner)
		to_chat(owner, "<span class='warning'>[src] is hit by EMP!</span>")
		// give the owner an idea about why his implant is glitching
		Retract()
	..()

/obj/item/organ/cyberimp/arm/proc/Retract()
	if(!holder || (holder in src))
		return

	owner.visible_message("<span class='notice'>[owner] retracts [holder] back into [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='notice'>[holder] snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='italics'>You hear a short mechanical noise.</span>")

	if(istype(holder, /obj/item/device/assembly/flash/armimplant))
		var/obj/item/device/assembly/flash/F = holder
		F.set_light(0)

	owner.transferItemToLoc(holder, src, TRUE)
	holder = null
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)

/obj/item/organ/cyberimp/arm/proc/Extend(var/obj/item/item)
	if(!(item in src))
		return

	holder = item

	holder.flags_1 |= NODROP_1
	holder.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	holder.slot_flags = null
	holder.materials = null

	if(istype(holder, /obj/item/device/assembly/flash/armimplant))
		var/obj/item/device/assembly/flash/F = holder
		F.set_light(7)

	var/obj/item/arm_item = owner.get_active_held_item()

	if(arm_item)
		if(!owner.dropItemToGround(arm_item))
			to_chat(owner, "<span class='warning'>Your [arm_item] interferes with [src]!</span>")
			return
		else
			to_chat(owner, "<span class='notice'>You drop [arm_item] to activate [src]!</span>")

	var/result = (zone == BODY_ZONE_R_ARM ? owner.put_in_r_hand(holder) : owner.put_in_l_hand(holder))
	if(!result)
		to_chat(owner, "<span class='warning'>Your [name] fails to activate!</span>")
		return

	// Activate the hand that now holds our item.
	owner.swap_hand(result)//... or the 1st hand if the index gets lost somehow

	owner.visible_message("<span class='notice'>[owner] extends [holder] from [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='notice'>You extend [holder] from your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='italics'>You hear a short mechanical noise.</span>")
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)

/obj/item/organ/cyberimp/arm/ui_action_click()
	if(crit_fail || (!holder && !contents.len))
		to_chat(owner, "<span class='warning'>The implant doesn't respond. It seems to be broken...</span>")
		return

	if(!holder || (holder in src))
		holder = null
		if(contents.len == 1)
			Extend(contents[1])
		else // TODO: make it similar to borg's storage-like module selection
			var/obj/item/choise = input("Activate which item?", "Arm Implant", null, null) as null|anything in items_list
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.internal_organs) && !holder && istype(choise) && (choise in contents))
				// This monster sanity check is a nice example of how bad input() is.
				Extend(choise)
	else
		Retract()


/obj/item/organ/cyberimp/arm/gun/emp_act(severity)
	if(prob(30/severity) && owner && !crit_fail)
		Retract()
		owner.visible_message("<span class='danger'>A loud bang comes from [owner]\'s [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm!</span>")
		playsound(get_turf(owner), 'sound/weapons/flashbang.ogg', 100, 1)
		to_chat(owner, "<span class='userdanger'>You feel an explosion erupt inside your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm as your implant breaks!</span>")
		owner.adjust_fire_stacks(20)
		owner.IgniteMob()
		owner.adjustFireLoss(25)
		crit_fail = 1
	else // The gun will still discharge anyway.
		..()


/obj/item/organ/cyberimp/arm/gun/laser
	name = "arm-mounted laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_laser"
	contents = newlist(/obj/item/gun/energy/laser/mounted)

/obj/item/organ/cyberimp/arm/gun/laser/l
	zone = BODY_ZONE_L_ARM


/obj/item/organ/cyberimp/arm/gun/taser
	name = "arm-mounted taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_taser"
	contents = newlist(/obj/item/gun/energy/e_gun/advtaser/mounted)

/obj/item/organ/cyberimp/arm/gun/taser/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of the engineering cyborg toolset, designed to be installed on subject's arm. Contains all necessary tools."
	contents = newlist(/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg, /obj/item/wirecutters/cyborg, /obj/item/device/multitool/cyborg)

/obj/item/organ/cyberimp/arm/toolset/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/toolset/emag_act()
	if(!(locate(/obj/item/kitchen/knife/combat/cyborg) in items_list))
		to_chat(usr, "<span class='notice'>You unlock [src]'s integrated knife!</span>")
		items_list += new /obj/item/kitchen/knife/combat/cyborg(src)
		return 1
	return 0

/obj/item/organ/cyberimp/arm/esword
	name = "arm-mounted energy blade"
	desc = "An illegal and highly dangerous cybernetic implant that can project a deadly blade of concentrated energy."
	contents = newlist(/obj/item/melee/transforming/energy/blade/hardlight)

/obj/item/organ/cyberimp/arm/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	contents = newlist(/obj/item/gun/medbeam)


/obj/item/organ/cyberimp/arm/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm that is able to be used as a powerful flash."
	contents = newlist(/obj/item/device/assembly/flash/armimplant)

/obj/item/organ/cyberimp/arm/flash/Initialize()
	. = ..()
	if(locate(/obj/item/device/assembly/flash/armimplant) in items_list)
		var/obj/item/device/assembly/flash/armimplant/F = locate(/obj/item/device/assembly/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/cyberimp/arm/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	contents = newlist(/obj/item/borg/stun)

/obj/item/organ/cyberimp/arm/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm."
	contents = newlist(/obj/item/melee/transforming/energy/blade/hardlight, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/device/assembly/flash/armimplant)

/obj/item/organ/cyberimp/arm/combat/Initialize()
	. = ..()
	if(locate(/obj/item/device/assembly/flash/armimplant) in items_list)
		var/obj/item/device/assembly/flash/armimplant/F = locate(/obj/item/device/assembly/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/cyberimp/arm/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/retractor/augment, /obj/item/hemostat/augment, /obj/item/cautery/augment, /obj/item/surgicaldrill/augment, /obj/item/scalpel/augment, /obj/item/circular_saw/augment, /obj/item/surgical_drapes)
