/*

/obj/item/knitting_needles
/obj/machinery/sewing_machine

*/

////////////////////KNITTING NEEDLES//////////////////////////////////////////////////////////////////////////////////////////

/obj/item/knitting_needles
	name = "knitting needles"
	desc = "Needles that allow the dexterous to process cloth into more intricate clothing than is possible with bare hands."
	gender = PLURAL
	icon = 'icons/obj/clothes_making.dmi'
	icon_state = "knitting_needles"
	item_state = "knitting_needles"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	sharpness = 1
	siemens_coefficient = 0
	sharpness_flags = SHARP_TIP
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_WOOD = 75)
	w_type = RECYK_WOOD
	autoignition_temperature = AUTOIGNITION_WOOD
	attack_verb = list("stabs")

	var/obj/item/stack/sheet/cloth/stored_cloth = null

	var/knitting = 0

/obj/item/knitting_needles/alien
	name = "sewing needles"
	desc = "They're quite big, but could probably be used as knitting needles still."
	icon_state = "sewing_needles"
	item_state = "sewing_needles"
	starting_materials = list(MAT_IRON = 75)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	siemens_coefficient = 1
	autoignition_temperature = 0
	force = 10
	throwforce = 15
	throw_range = 7

/obj/item/knitting_needles/Destroy()
	QDEL_NULL(stored_cloth)
	..()

/obj/item/knitting_needles/examine(mob/user)
	..()
	if(stored_cloth)
		to_chat(user, "<span class='info'>There are [stored_cloth.amount] lengths of cloth left.</span>")
	else
		to_chat(user, "<span class='warning'>Now you just need some cloth.</span>")

/obj/item/knitting_needles/attack_self(var/mob/user)
	if(stored_cloth)
		stored_cloth.attack_self(user)
	else
		to_chat(user, "<span class='warning'>You need some cloth first before you can knit anything.</span>")

/obj/item/knitting_needles/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return
	if(istype(target, /obj/item/stack/sheet/cloth))
		if (stored_cloth)
			var/obj/item/stack/sheet/cloth/C = target
			if (C.color == stored_cloth.color)
				to_chat(user, "You add some more cloth.")
				C.merge(stored_cloth)
			else
				user.drop_item(target)//in case it's in our bag or another hand
				stored_cloth.forceMove(target.loc)
				stored_cloth = target
				stored_cloth.forceMove(src)
				playsound(user.loc, 'sound/items/bonegel.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You swap the cloth rolls.</span>")
		else
			to_chat(user, "<span class='notice'>You equip \the [src] with cloth.</span>")
			user.drop_item(target)//in case it's in our bag or another hand
			stored_cloth = target
			stored_cloth.forceMove(src)
			playsound(user.loc, 'sound/items/bonegel.ogg', 50, 1)
		update_icon()


/obj/item/knitting_needles/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/sheet/cloth))
		if(user.drop_item(W, src))
			if (stored_cloth)
				if (W.color == stored_cloth.color)
					to_chat(user, "You add some more cloth.")
					var/obj/item/stack/sheet/cloth/C = W
					C.forceMove(get_turf(src))//moves the new roll out so its on_empty() won't empty the needles
					C.merge(stored_cloth)
					if (C.amount > 0)
						user.put_in_hands(C)
				else
					user.put_in_hands(stored_cloth)
					stored_cloth = W
					stored_cloth.forceMove(src)
					playsound(user.loc, 'sound/items/bonegel.ogg', 50, 1)
					to_chat(user, "You swap the cloth rolls.")
			else
				to_chat(user, "You equip \the [src] with cloth.")
				stored_cloth = W
				stored_cloth.forceMove(src)
				playsound(user.loc, 'sound/items/bonegel.ogg', 50, 1)
			update_icon()
			return
	..()

/obj/item/knitting_needles/AltClick(var/mob/user)
	if (user.incapacitated() || !Adjacent(user))
		return
	remove_cloth(user)

/obj/item/knitting_needles/verb/remove_cloth_verb()
	set name = "Remove cloth"
	set category = "Object"
	set src in range(1)
	if(usr.incapacitated())
		return
	remove_cloth(usr)

/obj/item/knitting_needles/proc/remove_cloth(var/mob/user)
	if(!stored_cloth && user)
		to_chat(user, "<span class='warning'>There is no cloth to remove.</span>")
		return
	stored_cloth.forceMove(get_turf(src))
	if (user)
		user.put_in_hands(stored_cloth)
	stored_cloth = null
	update_icon()

/obj/item/knitting_needles/update_icon()
	..()
	overlays.len = 0
	if (stored_cloth)
		var/image/cloth = image(icon, src, "knitting_needles-cloth")
		cloth.color = stored_cloth.color
		overlays += cloth
		item_state = "[initial(icon_state)][knitting ? "-knitting" : ""]"
		//dynamic in-hand overlay
		var/image/clothleft = image(inhand_states["left_hand"], src, "knitting_needles-cloth[knitting ? "-knitting" : ""]")
		var/image/clothright = image(inhand_states["right_hand"], src, "knitting_needles-cloth[knitting ? "-knitting" : ""]")
		clothleft.color = stored_cloth.color
		clothright.color = stored_cloth.color
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = clothleft
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = clothright
	else
		dynamic_overlay = list()
	update_blood_overlay()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

////////////////////SEWING MACHINE//////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/sewing_machine
	name = "sewing machine"
	desc = "Allows processing of cloth into clothing at a much faster rate than by doing it with knitting needles."
	icon = 'icons/obj/clothes_making.dmi'
	icon_state = "sewing_machine"
	density = 1
	anchored = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL | MULTIOUTPUT
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 5
	active_power_usage = 500
	pass_flags_self = PASSMACHINE

	var/obj/item/stack/sheet/cloth/stored_cloth = null
	var/max_amount = MAX_SHEET_STACK_AMOUNT

	var/manipulator_rating = 0
	var/matterbin_rating = 0

	var/operating = 0

/obj/machinery/sewing_machine/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/sewing_machine,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
	)

	RefreshParts()
	update_icon()

	if(ticker)
		initialize()

/obj/machinery/sewing_machine/examine(mob/user)
	..()
	if(stored_cloth)
		to_chat(user, "<span class='info'>There are [stored_cloth.amount] lengths of cloth left.</span>")
	else
		to_chat(user, "<span class='warning'>Now you just need some cloth.</span>")

	if(output_dir)
		to_chat(user, "<span class='info'>Finished items will be dropped on the [dir2text(output_dir)]ern tile.</span>")
	else
		to_chat(user, "<span class='info'>You can use a multi-tool to set a direction finished items should automatically be ejected to. Otherwise they will be placed on top of the machine.</span>")

/obj/machinery/sewing_machine/RefreshParts()
	//Better Manipulators = Faster production
	//Better Matter Bins = Larger Cloth Storage
	manipulator_rating = 0
	matterbin_rating = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipulator_rating += SP.rating
		if(istype(SP, /obj/item/weapon/stock_parts/matter_bin))
			matterbin_rating += SP.rating
	manipulator_rating = round(manipulator_rating/2)-1
	max_amount = MAX_SHEET_STACK_AMOUNT * matterbin_rating
	if (stored_cloth)
		stored_cloth.max_amount = max_amount
		while(stored_cloth.amount > stored_cloth.max_amount)
			var/diff = stored_cloth.amount % MAX_SHEET_STACK_AMOUNT
			if(diff)
				stored_cloth.use(diff)
				new /obj/item/stack/sheet/cloth(loc, diff, stored_cloth.color)
			else
				stored_cloth.use(MAX_SHEET_STACK_AMOUNT)
				new /obj/item/stack/sheet/cloth(loc, MAX_SHEET_STACK_AMOUNT, stored_cloth.color)

/obj/machinery/sewing_machine/spillContents(var/destroy_chance = 0)
	..()
	remove_cloth()

/obj/machinery/sewing_machine/attack_hand(var/mob/user)
	if(..())
		return TRUE

	if (stat & (BROKEN))
		to_chat(user, "You have to fix the machine first.")
		return
	if(stored_cloth)
		stored_cloth.attack_self(user)
	else
		to_chat(user, "<span class='warning'>You need some cloth first before you can sew anything.</span>")

/obj/machinery/sewing_machine/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/sheet/cloth))
		if (stat & (BROKEN))
			to_chat(user, "You have to fix the machine first.")
			return
		if(user.drop_item(W, src))
			if (stored_cloth)
				if (W.color == stored_cloth.color)
					to_chat(user, "You add some more cloth.")
					var/obj/item/stack/sheet/cloth/C = W
					C.forceMove(loc)//moves the new roll out so its on_empty() won't empty the machine
					C.merge(stored_cloth)
					if (C.amount > 0)
						user.put_in_hands(C)
				else
					user.put_in_hands(stored_cloth)
					stored_cloth.max_amount = initial(stored_cloth.max_amount)
					while(stored_cloth.amount > stored_cloth.max_amount)
						var/diff = stored_cloth.amount % MAX_SHEET_STACK_AMOUNT
						if(diff)
							stored_cloth.use(diff)
							new /obj/item/stack/sheet/cloth(user.loc, diff, stored_cloth.color)
						else
							stored_cloth.use(MAX_SHEET_STACK_AMOUNT)
							new /obj/item/stack/sheet/cloth(user.loc, MAX_SHEET_STACK_AMOUNT, stored_cloth.color)
					stored_cloth = W
					stored_cloth.forceMove(src)
					stored_cloth.max_amount = max_amount
					playsound(user.loc, 'sound/items/bonegel.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You swap the cloth rolls.</span>")
			else
				to_chat(user, "<span class='notice'>You equip the sewing machine with cloth.</span>")
				stored_cloth = W
				stored_cloth.forceMove(src)
				stored_cloth.max_amount = max_amount
				playsound(user.loc, 'sound/items/bonegel.ogg', 50, 1)
			update_icon()
			return
	else if (istype(W, /obj/item/weapon/bedsheet))
		if (stat & (BROKEN))
			to_chat(user, "You have to fix the machine first.")
			return
		var/obj/item/weapon/bedsheet/B = W
		to_chat(user, "You begin altering the patterns of the bedsheet.")
		playsound(get_turf(src), 'sound/machines/sewing_machine.ogg', 50, 1)
		if (do_after(user, get_turf(src), 3 SECONDS) && B)
			var/result = B.plaid_convert()
			switch (result)
				if (PLAIDPATTERN_INCOMPATIBLE)
					to_chat(user, "<span class='warning'>Try as you might, this bedsheet cannot be altered into having a plaid pattern.</span>")
				if (PLAIDPATTERN_TO_PLAID)
					to_chat(user, "<span class='notice'>You add a plaid pattern to the bedsheet.</span>")
				if (PLAIDPATTERN_TO_NOT_PLAID)
					to_chat(user, "<span class='notice'>You remove the bedsheet's plaid pattern.</span>")
		return
	..()

/obj/machinery/sewing_machine/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if (stat & (BROKEN))
		return FALSE
	if(istype(AM, /obj/item/stack/sheet/cloth))
		if (stored_cloth)
			if (AM.color == stored_cloth.color)
				var/obj/item/stack/sheet/cloth/C = AM
				C.merge(stored_cloth)
			else
				return FALSE
		else
			stored_cloth = AM
			stored_cloth.forceMove(src)
			stored_cloth.max_amount = max_amount
			playsound(loc, 'sound/items/bonegel.ogg', 50, 1)
	else
		return FALSE
	update_icon()
	return TRUE

/obj/machinery/sewing_machine/proc/remove_cloth(var/mob/user)
	if(!stored_cloth && user)
		to_chat(user, "<span class='warning'>There is no cloth to remove.</span>")
		return
	if (stored_cloth)
		while(stored_cloth.amount>MAX_SHEET_STACK_AMOUNT)
			var/diff = stored_cloth.amount % MAX_SHEET_STACK_AMOUNT
			if(diff)
				stored_cloth.use(diff)
				new /obj/item/stack/sheet/cloth(user.loc, diff, stored_cloth.color)
			else
				stored_cloth.use(MAX_SHEET_STACK_AMOUNT)
				new /obj/item/stack/sheet/cloth(user.loc, MAX_SHEET_STACK_AMOUNT, stored_cloth.color)
		stored_cloth.max_amount = initial(stored_cloth.max_amount)
		stored_cloth.forceMove(loc)
		if (user)
			user.put_in_hands(stored_cloth)
		stored_cloth = null
	update_icon()

/obj/machinery/sewing_machine/AltClick(var/mob/user)
	if (user.incapacitated() || !Adjacent(user))
		return
	remove_cloth(user)

/obj/machinery/sewing_machine/verb/remove_cloth_verb()
	set name = "Remove clothing"
	set category = "Object"
	set src in range(1)
	if(usr.incapacitated())
		return
	remove_cloth(usr)

/obj/machinery/sewing_machine/update_icon()
	..()
	overlays.len = 0

	if (stat & (BROKEN))
		icon_state = "sewing_machine-broken"
		return

	if (operating)
		use_power = MACHINE_POWER_USE_ACTIVE
	else
		use_power = MACHINE_POWER_USE_IDLE

	if (operating && stored_cloth)
		icon_state = "sewing_machine-operating"
		var/image/cloth = image(icon, src, "sewing_machine-clothoperating")
		cloth.color = stored_cloth.color
		overlays += cloth
	else
		icon_state = "sewing_machine"
		if (stored_cloth)
			var/image/cloth = image(icon, src, "sewing_machine-cloth")
			cloth.color = stored_cloth.color
			overlays += cloth

/obj/machinery/sewing_machine/power_change()
	..()
	update_icon()

/obj/machinery/sewing_machine/proc/breakdown()
	stat |= BROKEN
	remove_cloth()
	update_icon()

/obj/machinery/sewing_machine/ex_act(var/severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(20))
				qdel(src)
			else
				breakdown()
		if(3)
			if(prob(50))
				breakdown()

/obj/machinery/sewing_machine/attack_construct(var/mob/user)
	if(stat & (BROKEN))
		return
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		shake(1, 3)
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		add_hiddenprint(user)
		breakdown()
		return 1
	return 0

/obj/machinery/sewing_machine/kick_act(var/mob/living/carbon/human/user)
	..()
	if(stat & (BROKEN))
		return
	if (prob(5))
		breakdown()

/obj/machinery/sewing_machine/attack_paw(var/mob/user)
	if(istype(user,/mob/living/carbon/alien/humanoid))
		if(stat & (BROKEN))
			return
		breakdown()
		user.do_attack_animation(src, user)
		visible_message("<span class='warning'>\The [user] slashes at \the [src]!</span>")
		playsound(src, 'sound/weapons/slash.ogg', 100, 1)
		add_hiddenprint(user)
	else if (!usr.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
	else
		attack_hand(user)

/obj/machinery/sewing_machine/table_shift()
	pixel_y = 4

/obj/machinery/sewing_machine/table_unshift()
	pixel_y = 0
