//Grippers: Simple cyborg manipulator. Limited use... SLIPPERY SLOPE POWERCREEP
/obj/item/weapon/gripper
	icon = 'icons/obj/device.dmi'
	var/obj/item/wrapped = null // Item currently being held.
	var/list/can_hold = list() //Has a list of items that it can hold.
	var/list/blacklist = list() //This is a list of items that can't be held even if their parent is whitelisted.
	var/list/valid_containers = list()
	var/force_holder = null

/obj/item/weapon/gripper/proc/grip_item(obj/item/I as obj, mob/user, var/feedback = TRUE)
	//This function returns TRUE if we successfully took the item, or FALSE if it was invalid. This information is useful to the caller
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(I.loc == (R || R.module))// Don't remove your own modules
			to_chat(R, "<span class='danger'>ERROR. Safety protocols prevent self-disassembling.</span>")
			return FALSE
	if (!wrapped)
		var/grab = FALSE
		for(var/typepath in can_hold)
			if(istype(I,typepath))
				grab = TRUE
				break
		if(grab && !is_type_in_list(I, blacklist))
			if(feedback)
				to_chat(user, "<span class='notice'>You collect \the [I].</span>")
			I.loc = src
			I.add_fingerprint(user)
			wrapped = I
			update_icon()
			return TRUE
		if(feedback)
			to_chat(user, "<span class='danger'>ERROR. Your [name] wasn't designed to handle \the [I].</span>")
		return FALSE
	if(feedback)
		to_chat(user, "<span class='danger'>ERROR. Your [name] is already holding \the [wrapped].</span>")
	return FALSE


/obj/item/weapon/gripper/proc/drop_item(var/obj/item/to_drop, var/atom/target, force_drop = 0,var/dontsay = null) //Do we care about to_drop at all?
	if(!gripper_sanity_check(src))
		return FALSE
	if(to_drop && !istype(wrapped, to_drop))// What the fuck?
		drop_item(force_drop = 1)
		return FALSE
	if(!target) //Just drop it, baka.
		target = loc
	var/mob/holder = get_holder_of_type(src, /mob)
	if(holder)
		if(!dontsay)
			to_chat(usr, "<span class='warning'>You drop \the [wrapped].</span>")
		wrapped.dropped(usr)
	if(force_drop)
		wrapped.loc = get_turf(target)
	else
		wrapped.forceMove(target)
	wrapped = null
	update_icon()
	return TRUE

/obj/item/weapon/gripper/proc/gripper_safety_check(var/mob/user, var/target)
	if(issilicon(user))
		var/mob/living/silicon/robot/A = user
		if(!A.emagged)
			to_chat(user, "<span class='danger'>ERROR. Safety protocols prevent your [name] from [ismob(target) ? "completing this action." : "holding \the [target]."]</span>")
			return TRUE

/proc/gripper_sanity_check(var/obj/item/weapon/gripper/G)
	if(!G.wrapped)//The object must have been lost
		G.update_icon()
		return FALSE
	if(G.wrapped.loc != G)//The object left the gripper but it still exists. Maybe placed on a table
		//Reset the force and then remove our reference to it
		G.wrapped.force = G.force_holder
		G.wrapped = null
		G.force_holder = null
		G.update_icon()
		return FALSE
	return TRUE

/obj/item/weapon/gripper/Destroy()
	if(gripper_sanity_check(src))
		drop_item(force_drop = 1, dontsay = TRUE)
	..()

/obj/item/weapon/gripper/update_icon()
	overlays.Cut()
	if(wrapped && wrapped.icon)
		var/image/olay = image("icon" = wrapped.icon, "icon_state" = wrapped.icon_state, "layer" = 30 + wrapped.layer, "pixel_x" = null, "pixel_y" = null)
		olay.overlays = wrapped.overlays
		olay.appearance_flags = RESET_ALPHA
		alpha = SEMI_TRANSPARENT
		overlays += olay
	else
		alpha = initial(alpha)
	..()

/obj/item/weapon/gripper/examine(mob/user)
	if(wrapped)
		return wrapped.examine(user)
	else
		return ..()

/obj/item/weapon/gripper/attackby(obj/item/thing, mob/living/user)
	if(gripper_sanity_check(src))
		var/resolved = wrapped.attackby(thing,user)
		if(!resolved && wrapped && thing) // Double check that shit
			thing.afterattack(wrapped,user,1)//We pass along things targeting the gripper, to objects inside the gripper. So that we can draw chemicals from held beakers for instance
		update_icon()
		return
	return ..()

/obj/item/weapon/gripper/AltClick()
	if(gripper_sanity_check(src))
		.=wrapped.AltClick()
		update_icon()
		return
	return ..()

/obj/item/weapon/gripper/CtrlClick()
	if(gripper_sanity_check(src))
		.=wrapped.CtrlClick()
		update_icon()
		return
	return ..()

/obj/item/weapon/gripper/attack_self(var/mob/living/user)
	if(gripper_sanity_check(src))
		.=wrapped.attack_self(user)
		update_icon()
		return
	return ..()

/obj/item/weapon/gripper/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(gripper_sanity_check(src))//Somehow things happened.
		force_holder = wrapped.force
		wrapped.force = 0
		wrapped.attack(M,user)
		gripper_sanity_check(src)
		return TRUE
	else //mob interactions
		switch(user.a_intent)
			if(I_HELP)
				user.visible_message("[user] [pick("boops", "squeezes", "pokes", "prods", "strokes", "bonks")] [M] with \the [src].")
			if(I_HURT)
				if(!gripper_safety_check())
					user.visible_message("<span class='danger'>[user] [pick("bludgeons", "whacks", "impales")] [M] with \the [src]!</spam>")
					playsound(user, 'sound/weapons/smash.ogg', 40, 1)
					M.adjustBruteLoss(rand(2,7))//about as much as a punch
					user.delayNextAttack(15)
	return FALSE

//obj/item/weapon/gripper/attack(mob/living/carbon/M, mob/living/carbon/user)
//	return FALSE// Don't fall through and smack people with gripper

/obj/item/weapon/gripper/preattack(var/atom/target, var/mob/living/user, proximity, params)
	if(!proximity)
		return // This will prevent them using guns at range but adminbuse can add them directly to modules, so eh.

	if(!wrapped)//There's some weirdness with items being lost inside the arm. Trying to fix all cases. ~Z
		for(var/obj/item/thing in contents)
			wrapped = thing
			break

	if(wrapped)
		return

	else if(isitem(target))//Check that we're not pocketing a mob.
		var/obj/item/I = target
		if(isturf(target.loc))
			grip_item(I, user, 1)
		else if(is_type_in_list(target.loc,valid_containers))
			var/obj/O = target.loc
			grip_item(I, user, 1)
			O.update_icon()//updating fancy containers

	else if(isrobot(target))//Robots repairing themselves? What can go wrong.
		var/mob/living/silicon/robot/A = target
		if(A.opened && A.cell)
			if(!gripper_safety_check(user, A.cell))//Only allowed if the user pass the safety check.
				if(grip_item(A.cell, user, FALSE))
					A.cell.update_icon()
					A.updateicon()
					A.cell = null
					user.visible_message("<span class='danger'>[user] removes the power cell from [A]!</span>", "You remove the power cell.")

/obj/item/weapon/gripper/chemistry //Used to handle glass containers and pills.
	name = "chemistry gripper"
	icon_state = "gripper-sci"
	desc = "A simple grasping tool for chemical work."

	can_hold = list(
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/weapon/reagent_containers/blood,
		)

	valid_containers = list(
		/obj/item/weapon/storage/fancy/vials,
		/obj/item/weapon/storage/lockbox/vials,
		)

/obj/item/weapon/gripper/organ //Used to handle organs.
	name = "organ gripper"
	icon_state = "gripper-medical"
	desc = "A simple grasping tool for holding and manipulating organic and mechanical organs, both internal and external."

	can_hold = list(
	/obj/item/organ/,
	/obj/item/robot_parts,
	/obj/item/weapon/reagent_containers/food/snacks/meat
	)

/obj/item/weapon/gripper/service //Used to handle food, drinks and seeds.
	name = "service gripper"
	icon_state = "gripper-old"
	desc = "A simple grasping tool used to perform tasks in the service sector, such as handling drinks and... fedoras!"

	can_hold = list(
		/obj/item/weapon/reagent_containers/food/drinks,
		/obj/item/clothing/head/fedora,
		/obj/item/weapon/broken_bottle,
		/obj/item/trash
		)

/obj/item/weapon/gripper/service/noir
	name = "worn-out gripper"
	icon_state = "gripper-noir"
	desc = "A repurposed and heavily worn-out service gripper. A simple grasping tool used to handle both forensic tasks and mugs, especially mugs."

	can_hold = list(
		/obj/item/weapon/reagent_containers/food/drinks,
		/obj/item/device/detective_scanner,
		/obj/item/weapon/f_card
		)

/obj/item/weapon/gripper/no_use //Used when you want to hold and put things in other things, but not able to 'use' the item

/obj/item/weapon/gripper/no_use/attack_self(mob/user as mob)
	return

/obj/item/weapon/gripper/no_use/attackby(var/atom/thing, var/mob/living/user)
	return

/obj/item/weapon/gripper/no_use/AltClick()
	return

/obj/item/weapon/gripper/no_use/CtrlClick()
	return

/obj/item/weapon/gripper/no_use/inserter //This is used to disallow building sheets.
	name = "sheet inserter"
	desc = "A specialized loading device, designed to pick up and insert sheets of materials inside machines."
	icon_state = "gripper-sheet"

	can_hold = list(
		/obj/item/stack/sheet
		)

/obj/item/weapon/gripper/magnetic
	name = "magnetic gripper"
	desc = "A simple grasping tool specialized in construction and engineering work."
	icon_state = "gripper"

	can_hold = list(
		/obj/item/weapon/cell,
		/obj/item/weapon/stock_parts,
		/obj/item/weapon/tank,
		/obj/item/weapon/circuitboard,
		/obj/item/weapon/am_containment,
		/obj/item/device/am_shielding_container,
		/obj/item/weapon/table_parts,
		/obj/item/weapon/rack_parts,
		/obj/item/mounted/frame,
		/obj/item/weapon/intercom_electronics
		)

	blacklist = list(
		/obj/item/weapon/tank/jetpack,
		/obj/item/weapon/cell/infinite,
		/obj/item/weapon/circuitboard/communications,
		/obj/item/weapon/circuitboard/card,
		/obj/item/weapon/circuitboard/aiupload,
		/obj/item/weapon/circuitboard/borgupload
		)
