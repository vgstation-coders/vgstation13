/obj/item/dicetower
	name = "dice tower"
	desc = "A tower you can place or throw dice into to ensure a fair roll."
	icon = 'icons/obj/library.dmi'
	icon_state = "dicetower"
	w_class = W_CLASS_MEDIUM
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 10
	layer = MACHINERY_LAYER

/obj/item/dicetower/attack_hand(mob/user)
	if(locate(/obj/item/weapon/dice) in contents)
		tower(user)
	else
		..()

/obj/item/dicetower/attackby(obj/item/O, mob/user)
	if(istype(O,/obj/item/weapon/dice))
		user.drop_item(O,src)
		tower(user)
	else
		..()

/obj/item/dicetower/Crossed(atom/movable/mover)
	if(istype(mover,/obj/item/weapon/dice) && mover.throwing) //Dice should always impact
		mover.forceMove(src)
		tower(usr)

/obj/item/dicetower/proc/tower(mob/user)
	playsound(src, 'sound/weapons/dicetower.ogg', 50, 1)
	shake(1,2)
	sleep(4)
	for(var/obj/item/weapon/dice/D in contents)
		D.result = rand(D.minsides, D.sides)
		D.update_icon()
		if(istype(D,/obj/item/weapon/dice/fudge))
			var/obj/item/weapon/dice/fudge/FD = D
			visible_message("<span class='notice'>[user] rolled a [FD.result_names[D.result]] in \the [src]!</span>")
		else
			visible_message("<span class='notice'>[user] rolled a [D.result] in \the [src]!</span>")
		D.forceMove(get_turf(loc))

/obj/item/toy/gamepiece
	icon = 'icons/obj/toy.dmi'
	w_class = W_CLASS_TINY

/obj/item/toy/gamepiece/miner
	name = "Red Core player gamepiece"
	desc = "Use it to change the class."
	icon_state = "miner_gamepiece"

/obj/item/toy/gamepiece/miner/attack_self(mob/user)
	var/list/choices = list("Shaft Miner", "Paramedic", "Anomalist", "Engineer")
	var/choice = input("Which class?") in choices
	switch(choice)
		if("Shaft Miner")
			icon_state = "miner_gamepiece"
		if("Paramedic")
			icon_state = "para_gamepiece"
		if("Anomalist")
			icon_state = "anom_gamepiece"
		if("Engineer")
			icon_state = "eng_gamepiece"

/obj/item/toy/gamepiece/hivelord
	name = "hivelord gamepiece"
	desc = "A beating heart manifest."
	icon_state = "hivelord_gamepiece"

/obj/item/toy/gamepiece/brood
	name = "brood gamepiece"
	desc = "The endless horde."
	icon_state = "brood_gamepiece"

/obj/item/weapon/storage/box/redcore
	name = "gamepiece box"
	desc = "A box containing game pieces for a tabletop game called Red Core."
	fits_max_w_class = W_CLASS_TINY
	storage_slots = 21
	max_combined_w_class = 23
	items_to_spawn = list(
		/obj/item/toy/gamepiece/miner,
		/obj/item/toy/gamepiece/miner,
		/obj/item/toy/gamepiece/miner,
		/obj/item/toy/gamepiece/miner,
		/obj/item/toy/gamepiece/hivelord,
		/obj/item/toy/gamepiece/hivelord,
		/obj/item/toy/gamepiece/hivelord,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/weapon/book/manual/redcore1,
		/obj/item/weapon/paper/redcore/miner,
		/obj/item/weapon/paper/redcore/para,
		/obj/item/weapon/paper/redcore/anom,
		/obj/item/weapon/paper/redcore/eng)

/obj/item/battlemat
	name = "battle mat"
	desc = "A big grid ideal for placing figurines. Place it on a large table to unroll."
	icon = 'icons/obj/posters.dmi'
	icon_state = "rolled_poster"
	w_class = W_CLASS_MEDIUM
	layer = BELOW_OBJ_LAYER
	var/unfurl_icon = "gamemat"

/obj/item/battlemat/battlemat_exception(atom/neighbor)
	return

/obj/item/battlemat/attackby(obj/item/W, mob/user, params)
	if(user.drop_item(W, src.loc))
		if(bound_width > WORLD_ICON_SIZE && W.loc == loc && params)
			W.setPixelOffsetsFromParams(params, user, pixel_x, pixel_y, FALSE)
			update_icon()
			return 1
	else
		..()

/obj/item/battlemat/update_icon()
	if(table_shift())
		return
	icon = 'icons/obj/posters.dmi'
	icon_state = "rolled_poster"
	bound_width = WORLD_ICON_SIZE
	bound_height = WORLD_ICON_SIZE

/obj/item/battlemat/pickup(mob/user)
	..()
	update_icon()

/obj/item/battlemat/dropped(mob/user)
	..()
	update_icon()

/obj/item/battlemat/setPixelOffsetsFromParams(params, user, pixel_x, pixel_y)
	if(!table_shift())
		..()

/obj/item/battlemat/proc/table_shift()
	var/obj/structure/table/O = locate(/obj/structure/table) in loc
	var/list/acceptable_angles = list(3,4,6) //Ensure we're on a large table
	if(O && (O.tableform in acceptable_angles))
		icon = 'icons/obj/objects_64x64.dmi'
		icon_state = unfurl_icon
		bound_width = 2*WORLD_ICON_SIZE
		bound_height = 2*WORLD_ICON_SIZE
		switch(O.dir)
			if(NORTHEAST, NORTH, EAST)
				//No action, this statement for clarity only
			if(SOUTHEAST, SOUTH)
				forceMove(get_step(loc,SOUTH))
			if(SOUTHWEST)
				forceMove(get_step(loc,SOUTHWEST))
			if(NORTHWEST, WEST)
				forceMove(get_step(loc,WEST))
		pixel_x = 0
		pixel_y = 0
		return TRUE
	return FALSE