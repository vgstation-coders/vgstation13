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
