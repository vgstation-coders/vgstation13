/obj/structure/closet/secure_closet/freezer

	var/icon_exploded = "fridge_exploded"
	var/exploded = 0

/obj/structure/closet/secure_closet/freezer/New()
	..()
	processing_objects.Add(src)

/obj/structure/closet/secure_closet/freezer/process()
	if(exploded)
		processing_objects.Remove(src)
		return

	for(var/obj/item/weapon/reagent_containers/R in contents)
		if(R.reagents)
			R.reagents.heating(rand(-200,-800), T0C)

/obj/structure/closet/secure_closet/freezer/open()
	if(..())
		processing_objects.Remove(src)

/obj/structure/closet/secure_closet/freezer/close()
	if(..())
		processing_objects.Add(src)

/obj/structure/closet/secure_closet/freezer/update_icon()
	overlays.len = 0
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
			if(welded)
				overlays += image(icon = icon, icon_state = "welded")
		else
			if(exploded)
				icon_state = icon_exploded
				return
			icon_state = icon_opened

//Fridges cannot be destroyed by explosions (a reference to Indiana Jones if you don't know)
//However, the door will be blown off its hinges, permanently breaking the fridge
//And of course, if the bomb is IN the fridge, you're fucked
/obj/structure/closet/secure_closet/freezer/ex_act(var/severity)

	//Bomb in here? (using same search as space transits searching for nuke disk)
	var/list/bombs = search_contents_for(/obj/item/device/transfer_valve)
	if(!isemptylist(bombs)) // You're fucked.
		..(severity)

	if(severity == 1)
		//If it's not open, we need to override the normal open proc and set everything ourselves
		//Otherwise, you can cheese this by simply welding it shut, or if the lock is engaged
		if(!opened)
			opened = 1
			setDensity(FALSE)
			dump_contents()

		//Now, set our special variables
		exploded = 1
		update_icon()

	return

/obj/structure/closet/secure_closet/freezer/can_close()
	if(exploded) //Door blew off, can't close it anymore
		return 0
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src && !closet.wall_mounted)
			return 0
	return 1

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "Kitchen Cabinet"
	req_access = list(access_kitchen)

	New()
		..()
		sleep(2)
		for(var/i = 0, i < 3, i++)
			new /obj/item/weapon/reagent_containers/food/drinks/flour(src)
		new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)
		return


/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()



/obj/structure/closet/secure_closet/freezer/meat
	name = "Meat Fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"


	New()
		..()
		sleep(2)
		for(var/i = 0, i < 4, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/meat/animal/monkey(src)
		return



/obj/structure/closet/secure_closet/freezer/fridge
	name = "Refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"


	New()
		..()
		sleep(2)
		for(var/i = 0, i < 5, i++)
			new /obj/item/weapon/reagent_containers/food/drinks/milk(src)
		for(var/i = 0, i < 5, i++)
			new /obj/item/weapon/reagent_containers/food/drinks/soymilk(src)
		for(var/i = 0, i < 2, i++)
			new /obj/item/weapon/storage/fancy/egg_box(src)
		return



/obj/structure/closet/secure_closet/freezer/money
	name = "Freezer"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"
	req_access = list(access_heads_vault)


	New()
		..()
		sleep(2)
		dispense_cash(6700,src)
		return








