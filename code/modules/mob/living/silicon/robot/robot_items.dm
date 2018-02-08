// A special tray for the service droid. Allow droid to pick up and drop items as if they were using the tray normally
// Click on table to unload, click on item to load. Otherwise works identically to a tray.
// Unlike the base item "tray", robotrays ONLY pick up food, drinks and condiments.

/obj/item/weapon/tray/robotray
	name = "RoboTray"
	desc = "An autoloading tray specialized for carrying refreshments."

/obj/item/weapon/tray/robotray/afterattack(atom/target, mob/user as mob, proximity_flag)
	if(!target)
		return

	if(!proximity_flag)
		return

	//Pick up items, mostly copied from base tray pickup proc
	//See code\game\objects\items\weapons\kitchen.dm line 241
	if(istype(target,/obj/item))
		if(!isturf(target.loc)) // Don't load up stuff if it's inside a container or mob!
			return

		var/turf/pickup = target.loc
		var/addedSomething = 0

		for(var/obj/item/weapon/reagent_containers/food/I in pickup)
			if(I != src && !I.anchored && !istype(I, /obj/item/clothing/under) && !istype(I, /obj/item/clothing/suit) && !istype(I, /obj/item/projectile))
				var/add = 0
				if(I.w_class > W_CLASS_TINY)
					add = 1
				else if(I.w_class == W_CLASS_SMALL)
					add = 3
				else
					add = 5
				if(calc_carry() + add >= max_carry)
					break

				I.forceMove(src)
				carrying.Add(I)
				overlays += image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer)
				addedSomething = 1
		if (addedSomething)
			user.visible_message("<span class='notice'>[user] load some items onto their service tray.</span>")

		return

	//Unloads the tray, copied from base item's proc dropped() and altered
	//See code\game\objects\items\weapons\kitchen.dm line 263
	if(isturf(target) || istype(target,/obj/structure/table))
		var foundtable = istype(target,/obj/structure/table/)
		if(!foundtable) //It must be a turf!
			for(var/obj/structure/table/T in target)
				foundtable = 1
				break

		var/turf/dropspot
		if(!foundtable) //Don't unload things onto walls or other silly places.
			dropspot = user.loc
		else if(isturf(target)) //They clicked on a turf with a table in it
			dropspot = target
		else					//They clicked on a table
			dropspot = target.loc

		overlays = null

		var droppedSomething = 0

		for(var/obj/item/I in carrying)
			I.forceMove(dropspot)
			carrying.Remove(I)
			droppedSomething = 1
			if(!foundtable && isturf(dropspot))
				//If no table, presume that the person just shittily dropped the tray on the ground and made a mess everywhere!
				spawn()
					for(var/i = 1, i <= rand(1,2), i++)
						if(I)
							step(I, pick(NORTH,SOUTH,EAST,WEST))
							sleep(rand(2,4))
		if(droppedSomething)
			if(foundtable)
				user.visible_message("<span class='notice'>[user] unloads their service tray.</span>")
			else
				user.visible_message("<span class='notice'>[user] drops all the items on their tray.</span>")

	return ..()

//A special pen for service droids. Can be toggled to switch between normal writting mode, and paper rename mode
//Allows service droids to rename paper items.
/obj/item/weapon/pen/robopen
	desc = "A black ink printing attachment with a paper naming mode."
	name = "Printing Pen"
	var/mode = 1

/obj/item/weapon/pen/robopen/attack_self(mob/user as mob)
	playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
	if (mode == 1)
		mode = 2
		to_chat(user, "Changed printing mode to 'Rename Paper'")
		return
	if (mode == 2)
		mode = 1
		to_chat(user, "Changed printing mode to 'Write Paper'")

// Copied over from paper's rename verb
// see code\\modules\\\paperwork\\\paper.dm line 62

/obj/item/weapon/pen/robopen/proc/RenamePaper(mob/user as mob,obj/paper as obj)
	if ( !user || !paper )
		return
	var/n_name = input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text
	if ( !user || !paper )
		return

	n_name = copytext(n_name, 1, 32)
	if (Adjacent(user) && !user.stat)
		paper.name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(user)
	return

//Personal shielding for the combat module.
/obj/item/borg/combat/shield
	name = "personal shielding"
	desc = "A powerful experimental module that turns aside or absorbs incoming attacks at the cost of charge."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
	var/shield_level = 0.5 //Percentage of damage absorbed by the shield.

/obj/item/borg/combat/shield/verb/set_shield_level()
	set name = "Set shield level"
	set category = "Object"
	set src in range(0)

	var/N = input("How much damage should the shield absorb?") in list("5","10","25","50","75","100")
	if (N)
		shield_level = text2num(N)/100

/obj/item/borg/combat/mobility
	name = "mobility module"
	desc = "By retracting limbs and tucking in its head, a combat android can roll at high speeds."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

#define MODE_WALL 0
#define MODE_DOOR 1

/obj/item/weapon/inflatable_dispenser
	name = "inflatables dispenser"
	desc = "A hand-held device which allows rapid deployment and removal of inflatable structures."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "inf_deployer"
	w_class = W_CLASS_MEDIUM

	var/list/stored_walls = list()
	var/list/stored_doors = list()
	var/max_walls = 4
	var/max_doors = 3
	var/list/allowed_types = list(/obj/item/inflatable/wall, /obj/item/inflatable/door)
	var/mode = MODE_WALL

/obj/item/weapon/inflatable_dispenser/New()
	..()
	for(var/i = 0 to max(max_walls,max_doors))
		if(stored_walls.len < max_walls)
			stored_walls += new /obj/item/inflatable/wall(src)
		if(stored_doors.len < max_doors)
			stored_doors += new /obj/item/inflatable/door(src)

/obj/item/weapon/inflatable_dispenser/Destroy()
	stored_walls = null
	stored_doors = null
	..()

/obj/item/weapon/inflatable_dispenser/robot
	w_class = W_CLASS_HUGE
	max_walls = 10
	max_doors = 5

/obj/item/weapon/inflatable_dispenser/examine(mob/user)
	..()
	to_chat(user, "It has [stored_walls.len] wall segment\s and [stored_doors.len] door segment\s stored, and is set to deploy [mode ? "doors" : "walls"].")

/obj/item/weapon/inflatable_dispenser/attack_self()
	mode = !mode
	to_chat(usr, "You set \the [src] to deploy [mode ? "doors" : "walls"].")

/obj/item/weapon/inflatable_dispenser/attackby(var/obj/item/O, var/mob/user)
	if(O.type in allowed_types)
		pick_up(O, user)
		return
	..()

/obj/item/weapon/inflatable_dispenser/afterattack(var/atom/A, var/mob/user)
	..(A, user)
	if(!user)
		return
	if(!user.Adjacent(A))
		return
	if(istype(A, /turf))
		try_deploy(A, user)
	if(istype(A, /obj/item/inflatable) || istype(A, /obj/structure/inflatable))
		pick_up(A, user)

/obj/item/weapon/inflatable_dispenser/proc/try_deploy(var/turf/T, var/mob/living/user)
	if(!istype(T))
		return
	if(T.density)
		return

	var/obj/item/inflatable/I
	if(mode == MODE_WALL)
		if(!stored_walls.len)
			to_chat(user, "\The [src] is out of walls!")
			return

		I = stored_walls[1]
		if(!I.can_inflate(T))
			return
		stored_walls -= I

	if(mode == MODE_DOOR)
		if(!stored_doors.len)
			to_chat(user, "\The [src] is out of doors!")
			return

		I = stored_doors[1]
		if(!I.can_inflate(T))
			return
		stored_doors -= I

	I.forceMove(T)
	I.inflate()
	user.visible_message("<span class='danger'>[user] deploy an inflatable [mode ? "door" : "wall"].</span>", \
	"<span class='notice'>You deploy an inflatable [mode ? "door" : "wall"].</span>")

/obj/item/weapon/inflatable_dispenser/proc/pick_up(var/obj/A, var/mob/living/user)
	if(istype(A, /obj/structure/inflatable))
		var/obj/structure/inflatable/I = A
		I.deflate(0,5)
		return TRUE
	if(A.type in allowed_types)
		var/obj/item/inflatable/I = A
		if(I.inflating)
			return FALSE
		if(istype(I, /obj/item/inflatable/wall))
			if(stored_walls.len >= max_walls)
				to_chat(user, "\The [src] can't hold more walls.")
				return FALSE
			stored_walls += I
		else if(istype(I, /obj/item/inflatable/door))
			if(stored_doors.len >= max_doors)
				to_chat(usr, "\The [src] can't hold more doors.")
				return FALSE
			stored_doors += I
		if(istype(I.loc, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = I.loc
			S.remove_from_storage(I,src)
		else if(istype(I.loc, /mob))
			var/mob/M = I.loc
			if(!M.drop_item(I,src))
				to_chat(user, "<span class='notice'>You can't let go of \the [I]!</span>")
				stored_doors -= I
				stored_walls -= I
				return FALSE
		user.delayNextAttack(8)
		visible_message("\The [user] picks up \the [A] with \the [src]!")
		A.forceMove(src)
		return TRUE

#undef MODE_WALL
#undef MODE_DOOR

//Cyborg Beer
/obj/item/weapon/reagent_containers/glass/replenishing/cyborg
	name = "brobot's space beer"
	icon = 'icons/obj/drinks.dmi'
	icon_state = "beer"
	reagent_list = BEER
	artifact = FALSE
	can_be_placed_into = null
	var/synth_cost = 10 //Around 1666 cell charge for 50u beer

/obj/item/weapon/reagent_containers/glass/replenishing/cyborg/fits_in_iv_drip()
	return FALSE

/obj/item/weapon/reagent_containers/glass/replenishing/cyborg/process()
	if(isrobot(loc))
		var/mob/living/silicon/robot/robot = loc
		if(robot && robot.cell)
			if(reagents.total_volume < reagents.maximum_volume) // don't recharge reagents and drain power if the storage is full
				robot.cell.use(synth_cost)
				..()

/obj/item/weapon/reagent_containers/glass/replenishing/cyborg/hacked
	name = "mickey finn's special brew"
	reagent_list = BEER2
	synth_cost = 25 //4165 cell charge for 50u !NotShitterJuice.

//Grippers: Simple cyborg manipulator. Limited use... SLIPPERY SLOPE POWERCREEP
/obj/item/weapon/gripper
	icon = 'icons/obj/device.dmi'
	actions_types = list(/datum/action/item_action/magrip_drop)
	var/obj/item/wrapped = null // Item currently being held.
	var/list/can_hold = list() //Has a list of items that it can hold.
	var/list/blacklist = list() //This is a list of items that can't be held even if their parent is whitelisted.
	var/force_holder = null

/datum/action/item_action/magrip_drop
	name = "Drop Item"

/datum/action/item_action/magrip_drop/Trigger()
	var/obj/item/weapon/gripper/G = target
	if(!istype(G))
		return
	G.drop_item(force_drop = 1)

/obj/item/weapon/gripper/proc/grip_item(obj/item/I as obj, mob/user, var/feedback = TRUE)
	//This function returns TRUE if we successfully took the item, or FALSE if it was invalid. This information is useful to the caller
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(I.loc == (R || R.module))// Don't remove your own modules
			to_chat(R, "<span class='danger'>ERROR. Safety protocols prevent self-disassembling.</span>")
			return FALSE
	if (!wrapped)
		if(is_type_in_list(I, can_hold) && !is_type_in_list(I, blacklist))
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
		drop_item(force_drop = 1)
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
	if(usr)
		usr.update_action_buttons()
	..()

/obj/item/weapon/gripper/examine(mob/user)
	. = ..()
	if(wrapped)
		to_chat(user, "It is holding \a [bicon(wrapped)] [wrapped].")

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
		if(!isturf(target.loc))//That the item is not in a container.
			return
		grip_item(I, user, 1)//And finally.

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
	desc = "A simple grasping tool used to perform tasks in the service sector, such as handling food, drinks, and seeds."

	can_hold = list(
		/obj/item/weapon/reagent_containers/food/drinks,
		/obj/item/clothing/head/fedora,
		/obj/item/trash
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

/obj/item/weapon/gripper/no_use/magnetic //No use because they don't need to open held tanks.
	name = "magnetic gripper"
	desc = "A simple grasping tool specialized in construction and engineering work."
	icon_state = "gripper"

	can_hold = list(
		/obj/item/weapon/cell,
		/obj/item/weapon/stock_parts,
		/obj/item/weapon/tank,
		/obj/item/weapon/circuitboard,
		/obj/item/weapon/am_containment,
		/obj/item/device/am_shielding_container
		)

	blacklist = list(
		/obj/item/weapon/tank/jetpack,
		/obj/item/weapon/cell/infinite,
		/obj/item/weapon/circuitboard/communications,
		/obj/item/weapon/circuitboard/card,
		/obj/item/weapon/circuitboard/aiupload,
		/obj/item/weapon/circuitboard/borgupload
		)
