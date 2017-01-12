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
		return 1
	if(A.type in allowed_types)
		var/obj/item/inflatable/I = A
		if(I.inflating)
			return 0
		if(istype(I, /obj/item/inflatable/wall))
			if(stored_walls.len >= max_walls)
				to_chat(user, "\The [src] can't hold more walls.")
				return 0
			stored_walls += I
		else if(istype(I, /obj/item/inflatable/door))
			if(stored_doors.len >= max_doors)
				to_chat(usr, "\The [src] can't hold more doors.")
				return 0
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
				return 0
		user.delayNextAttack(8)
		visible_message("\The [user] picks up \the [A] with \the [src]!")
		A.forceMove(src)
		return 1

#undef MODE_WALL
#undef MODE_DOOR