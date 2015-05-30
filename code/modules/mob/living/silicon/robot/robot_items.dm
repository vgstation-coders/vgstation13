// A special tray for the service droid. Allow droid to pick up and drop items as if they were using the tray normally
// Click on table to unload, click on item to load. Otherwise works identically to a tray.
// Unlike the base item "tray", robotrays ONLY pick up food, drinks and condiments.

/obj/item/weapon/storage/tray/robotray
	name = "RoboTray"
	desc = "An autoloading tray specialized for carrying refreshments."

	use_to_pickup = 1

/obj/item/weapon/storage/tray/robotray/afterattack(atom/target, mob/user as mob, proximity_flag)
	if(!target)
		return

	if(!proximity_flag)
		return

	if(..())
		return 1

	//Unloads the tray, copied from base item's proc dropped() and altered
	//See code\game\objects\items\weapons\kitchen.dm line 263
	if(isturf(target) || istype(target,/obj/structure/table))
		var/foundtable = istype(target,/obj/structure/table) || (locate(/obj/structure/table) in target)

		var/turf/dropspot
		if(!foundtable) //Don't unload things onto walls or other silly places.
			dropspot = get_turf(src)
		else //They clicked on a turf with a table in it
			dropspot = get_turf(target)

		if(contents.len)
			drop_all(foundtable, dropspot)
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
		user << "Changed printing mode to 'Rename Paper'"
		return
	if (mode == 2)
		mode = 1
		user << "Changed printing mode to 'Write Paper'"

// Copied over from paper's rename verb
// see code\modules\paperwork\paper.dm line 62

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