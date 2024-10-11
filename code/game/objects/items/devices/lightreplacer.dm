#define LIGHTREPLACER_BASIC 0
#define LIGHTREPLACER_BORG 1
#define LIGHTREPLACER_ADVANCED 2

/obj/item/device/lightreplacer

	name = "light replacer"
	desc = "A device to automatically replace lights. Holds two boxes for supply and waste. Slotted to only accept light boxes."

	icon = 'icons/obj/janitor.dmi'
	icon_state = "lightreplacer0"
	item_state = "electronic"

	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	origin_tech = Tc_MAGNETS + "=3;" + Tc_MATERIALS + "=2"
	w_type = RECYK_ELECTRONIC
	flammable = TRUE
	var/upgraded
	var/device_mode = LIGHTREPLACER_BASIC

	//Internal storage boxes. Boxes can hold 21 light bulb/tubes by default.
	var/obj/item/weapon/storage/box/lights/supply = null
	var/obj/item/weapon/storage/box/lights/waste = null

	//Internal resources
	var/glass = 0
	var/glass_max = 5 * CC_PER_SHEET_GLASS
	var/cardboard = 0
	var/cardboard_max = 5

	var/current_type = "Standard"
	var/current_shape = "Tube"
	var/light_types = list(
		"Bulb" 				= "/bulb",
		"Tube" 				= "/tube",
		"Standard" 			= "",
		"High Efficiency" 	= "/he",
		"Smart" 			= "/smart"
	)

	//Quality = switchcount for created bulbs. Higher switchcount = higher chance to burn out on switch.
	//Efficiency = multiplied by autolathe base glass for lights
	var/prod_quality = 30
	var/prod_eff = 1.5

	//Options for advanced replacer, put in the base type for sanity purposes
	var/current_frequency = 1500
	var/current_color = "#FFFFFF"
	var/current_brightness = 6

/obj/item/device/lightreplacer/emag_act(mob/user)
	emagged = !emagged
	playsound(src, "sparks", 100, 1)
	if(emagged)
		to_chat(user, "<span class = 'warning'>As you emag \the [src], you unlock its true potential as the greatest hand-portable source of plasma imaginable. A shame the only use for this is injecting the plasma into the lights it deploys.</span>")
		name = "Short-circuited [initial(name)]"
	else
		name = initial(name)
	update_icon()

/obj/item/device/lightreplacer/update_icon()
	icon_state = "lightreplacer[emagged]"

/obj/item/device/lightreplacer/attack_self(mob/user)
	ui_interact(user)

/*
preattack() handles two things here (aside from its normal function of allowing an attack to go through on 0, blocking it on 1):
- Handle replacing the light fixture on the tile that's clicked. Will return with 1 if successful. This is intentional so it does one thing per click! (either replace light or pick up broken lights)
- Handle picking up broken lights on the clicked tile. As with replacing lights, this also returns 1 if successful.
This used to be handled by attackby() on the light fixtures and bulbs themselves (lol), but that has been removed with this implementation.
*/

/obj/item/device/lightreplacer/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return 0
	var/turf/gather_loc = isturf(target) ? target : target.loc
	if(!gather_loc || !isturf(gather_loc))
		return 0
	var/obj/machinery/light/lightfixture = locate() in gather_loc.contents
	var/obj/item/weapon/light/best_light = get_best_light(lightfixture)
	if(lightfixture && lightfixture.current_bulb && is_light_better(best_light, lightfixture.current_bulb))
		. = ReplaceLight(lightfixture, usr)
		return .
	else if(lightfixture && !lightfixture.current_bulb)
		. = ReplaceLight(lightfixture, usr)
		if(.)
			return .
	else
		for(var/obj/O in gather_loc.contents)
			. = insert_if_possible(O)
		return .

/obj/item/device/lightreplacer/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/sheet/glass/glass))
		if(!add_glass(CC_PER_SHEET_GLASS, force_fill = 1))
			to_chat(user, "<span class='warning'>\The [src] can't hold any more glass!</span>")
			return
		var/obj/item/stack/sheet/glass/glass/G = W
		G.use(1)
		to_chat(user, "<span class='notice'>You insert \the [G] into \the [src].</span>")
		return

	if(istype(W, /obj/item/stack/sheet/cardboard))
		if(!add_cardboard(1, force_fill = 1))
			to_chat(user, "<span class='warning'>\The [src] can't hold any more glass!</span>")
			return
		var/obj/item/stack/sheet/cardboard/G = W
		G.use(1)
		to_chat(user, "<span class='notice'>You insert \the [G] into \the [src].</span>")
		return

	if(istype(W, /obj/item/weapon/light))
		var/obj/item/weapon/light/L = W
		insert_if_possible(L)
		return

	if(istype(W, /obj/item/weapon/storage/box/lights))
		if(!supply)
			if(user.drop_item(W, src))
				user.visible_message("[user] inserts \a [W] into \the [src]", "You insert \the [W] into \the [src] to be used as the supply container.")
				supply = W
				return
		else if(!waste)
			if(user.drop_item(W, src))
				user.visible_message("[user] inserts \a [W] into \the [src]", "You insert \the [W] into \the [src] to be used as the waste container.")
				waste = W
				return
		else
			var/obj/item/weapon/storage/box/lights/lsource = W
			if(!lsource.contents.len)
				to_chat(user, "<span class='notice'>\The [src] has both a supply box and a waste box and this box is empty. Remove one first if you want to insert a new one or use a light box with lights in it to insert them.</span>")
				return
			var/hasinserted = 0
			for(var/obj/item/weapon/light/L in lsource)
				if(insert_if_possible(L))
					hasinserted = 1
			if(hasinserted)
				to_chat(user, "<span class='notice'>\The [src] accepts the lights in \the [lsource].</span>")
			else
				to_chat(user, "<span class='warning'>\The [src] cannot accept any of the lights in \the [lsource]!</span>")
			return

/obj/item/device/lightreplacer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/list/data = list()

	data["supply"] = list(
		"exists" = (supply ? null : "disabled"),
		"notexists" = (supply ? "disabled" : null),
		"amount" = 0
	)

	data["waste"] = list(
		"exists" = (waste ? null : "disabled"),
		"notexists" = (waste ? "disabled" : null),
		"amount" = 0
	)

	for(var/obj/item/weapon/light/L in supply)
		data["supply"]["amount"]++

	for(var/obj/item/weapon/light/L in waste)
		data["waste"]["amount"]++

	data["resources"] = list(
		"glass" = glass,
		"glass_max" = glass_max,
		"cardboard" = cardboard,
		"cardboard_max" = cardboard_max)

	data["settings"] = list(
		"advanced" = (device_mode & LIGHTREPLACER_ADVANCED),
		"borg" = (device_mode & LIGHTREPLACER_BORG),
		"shape" = current_shape,
		"type" = current_type,
		"color" = current_color,
		"brightness" = current_brightness,
		"frequency" = current_frequency
	)


	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "lightreplacer.tmpl", name, 430, 280)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/item/device/lightreplacer/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["eject"])
		switch(href_list["eject"])
			if("supply")
				if(usr)
					usr.put_in_hands(supply)
					usr.visible_message("[usr] removes \the [supply] from \the [src].", "You remove \the [src]'s supply container, \the [supply].")
				else
					supply.forceMove(get_turf(src))
				supply = null
				return 1

			if("waste")
				if(usr)
					usr.put_in_hands(waste)
					usr.visible_message("[usr] removes \the [waste] from \the [src].", "You remove \the [src]'s waste container, \the [waste].")
				else
					waste.forceMove(get_turf(src))
				waste = null
				return 1

	if(href_list["build"])
		switch(href_list["build"])
			if("single")
				build_light()
				return 1
			if("multi")
				return 1

	if(href_list["fold"])
		if(cardboard <= 0)
			if(usr)
				to_chat(usr, "<span class='warning'>\The [src] is out of cardboard!</span>")
			return 1
		switch(href_list["fold"])
			if("supply")
				if(!supply) //Topic is technically asynchronous, I believe, so this sanity is a good idea
					supply = new /obj/item/weapon/storage/box/lights/empty(src)
					cardboard--
					if(usr)
						to_chat(usr, "<span class='notice'>\The [src] constructs a new supply container.</span>")
						attack_self(usr)
					return 1
			if("waste")
				if(!waste) //Topic is technically asynchronous, I believe, so this sanity is a good idea
					waste = new /obj/item/weapon/storage/box/lights/empty(src)
					cardboard--
					if(usr)
						to_chat(usr, "<span class='notice'>\The [src] constructs a new waste container.</span>")
						attack_self(usr)
					return 1

	if(href_list["recycle"])
		recycle_waste()
		return 1

	if(href_list["settings"])
		switch(href_list["settings"])
			if("shape")
				select_shape()
				return 1
			if("type")
				select_type()
				return 1
			if("color")
				current_color = input(usr, "Select a new light color", "Light color") as color
				return 1
			if("brightness")
				current_brightness = input(usr, "Select brightness level from 1 to 10.", "Brightness") as num
				current_brightness = clamp(current_brightness, 1, 10)
				return 1
			if("frequency")
				current_frequency = input(usr, "Enter a frequency from 3000 to 4000.", "Frequency") as num
				current_frequency = clamp(current_frequency, 3000, 4000)
				return 1

	if(href_list["recharge"])
		if(!istype(src, /obj/item/device/lightreplacer/borg))
			return 1
		recharge(usr)
		return 1

	if(href_list["dump"])
		if(!istype(src, /obj/item/device/lightreplacer/borg))
			return 1
		dump_supply(usr)
		return 1

	updateUsrDialog()
	return

//Adds amt glass to the glass storage if possible.
//If force_fill is 0, fails if there is not enough room for all of amt.
//If force_fill is 1, fails only if amt is totally full.
//If force_fill is 2, never fails.
//Returns 1 on success and 0 on fail.
/obj/item/device/lightreplacer/proc/add_glass(var/amt, var/force_fill = 0)
	if(!force_fill)
		if(glass + amt > glass_max)
			return 0
	else if(force_fill == 1)
		if(glass >= glass_max)
			return 0
	glass = min(glass_max, glass + amt)
	return 1

/obj/item/device/lightreplacer/proc/add_cardboard(var/amt, var/force_fill = 0)
	if(!force_fill)
		if(cardboard + amt > cardboard_max)
			return 0
	else if(force_fill == 1)
		if(cardboard >= cardboard_max)
			return 0
	cardboard = min(cardboard_max, cardboard + amt)
	return 1

//Attempts to insert a light into the light replacer's storage.
//If the light works, attempts to place it in the supply box. Otherwise, attempts to place it in the waste box.
//Fails if the light cannot be placed into the correct box for any reason.
//Returns 1 if the light is successfully inserted into the correct box, 0 if the insertion fails, and null if the item to be inserted is not a light or something very strange happens.
/obj/item/device/lightreplacer/proc/insert_if_possible(var/obj/item/weapon/light/L)
	if(!istype(L))
		return
	if(L.status == LIGHT_OK)
		if(supply && supply.can_be_inserted(L, TRUE))
			if(istype(L.loc, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/lsource = L.loc
				lsource.remove_from_storage(L, supply)
			else
				supply.handle_item_insertion(L, TRUE)
				usr.visible_message("\proper[usr] picks up the broken [L] using \the [src].", \
		"\proper You pick up \the [L] using \the [src].")
			return 1
		else
			to_chat(usr, "<span class='warning'>\The [src] has no supply container!</span>")
			return 0
	else if(L.status == LIGHT_BROKEN || L.status == LIGHT_BURNED)
		if(waste && waste.can_be_inserted(L, TRUE))
			if(istype(L.loc, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/lsource = L.loc
				lsource.remove_from_storage(L, waste)
			else
				waste.handle_item_insertion(L, TRUE)
				usr.visible_message("\proper[usr] picks up the broken [L] using \the [src].", \
		"\proper You pick up the broken [L.name] using \the [src].")
			return 1
		else
			to_chat(usr, "<span class='warning'>\The [src] has no waste container!</span>")
			return 0

/obj/item/device/lightreplacer/proc/build_light()
	var/obj/item/weapon/light/L
	var/light_path = text2path("/obj/item/weapon/light" + light_types[current_shape] + light_types[current_type])
	L = new light_path
	if(glass < L.starting_materials[MAT_GLASS] * prod_eff)
		if(usr)
			to_chat(usr, "<span class='warning'>\The [src] doesn't have enough glass to make that!</span>")
		if(L)
			QDEL_NULL(L)
		return 1
	glass -= (L.starting_materials[MAT_GLASS] * prod_eff)
	L.switchcount = prod_quality
	if(istype(L, /obj/item/weapon/light/tube/smart) || istype(L, /obj/item/weapon/light/bulb/smart))
		L.brightness_range = current_brightness
		L.brightness_color = current_color
		L.frequency = current_frequency
	if(!insert_if_possible(L))
		L.forceMove(get_turf(src))
		if(usr)
			to_chat(usr, "<span class='notice'>\The [src] successfully fabricates \a [L], but it drops it on the floor.</span>")
	else if(usr)
		to_chat(usr, "<span class='notice'>\The [src] successfully fabricates \a [L].</span>")
	return 1

/obj/item/device/lightreplacer/proc/recycle_waste()
	if(waste)
		var/recycledglass = 0 //How much glass is successfully recycled
		for(var/obj/item/weapon/light/L in waste)
			if(istype(L))
				switch(L.status)
					if(LIGHT_OK)
						recycledglass += (L.materials.storage[MAT_GLASS] * 0.75)
					if(LIGHT_BROKEN)
						recycledglass += (L.materials.storage[MAT_GLASS] * 0.25)
					if(LIGHT_BURNED)
						recycledglass += (L.materials.storage[MAT_GLASS] * 0.50)
				QDEL_NULL(L)
		if(recycledglass)
			to_chat(usr, "<span class='notice'>\The [src] recycles its waste box, producing [recycledglass] units of glass.</span>")
			add_glass(recycledglass, force_fill = 2)

/obj/item/device/lightreplacer/proc/select_shape()
	if(current_shape == "Tube")
		current_shape = "Bulb"
		return
	else
		current_shape = "Tube"

/obj/item/device/lightreplacer/proc/select_type()
	switch(current_type)
		if("Standard")
			current_type = "High Efficiency"
		if("High Efficiency")
			if(device_mode & LIGHTREPLACER_ADVANCED)
				current_type = "Smart"
			else
				current_type = "Standard"
		if("Smart")
			current_type = "Standard"
	return

/obj/item/device/lightreplacer/proc/ReplaceLight(var/obj/machinery/light/target, var/mob/living/user)
	var/obj/item/weapon/light/best_light = get_best_light(target)
	if(best_light == 0)
		to_chat(user, "<span class='warning'>\The [src] has no supply container!</span>")
		return 0
	else if(!best_light)
		to_chat(user, "<span class='warning'>\The [src] has no compatible light!</span>")
		return 0
	if(target.current_bulb && !is_light_better(best_light, target.current_bulb))
		to_chat(user, "<span class='notice'>\The [src] has no light better than the one already in \the [target].</span>")
		return 0

	to_chat(user, "<span class='notice'>You replace the [target.fitting] with \the [src].</span>")
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	supply.remove_from_storage(best_light)
	. = 1

	if(target.current_bulb)
		var/obj/item/weapon/light/L1 = target.current_bulb
		L1.forceMove(target.loc)
		L1.update()
		target.current_bulb = null
		target.update()
		if(!insert_if_possible(L1))
			if(istype(waste))
				to_chat(user, "<span class='warning'>\The [src]'s waste container is full and it drops the removed light on the floor!</span>")
			else
				to_chat(user, "<span class='warning'>\The [src] has no waste container and it drops the removed light on the floor!</span>")
	if(emagged && !best_light.rigged)
		to_chat(user, "<span class='warning'>\The [src] injects a small amount of plasma into \the [best_light].</span>")
		best_light.rigged = TRUE
		log_admin("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode.")
		message_admins("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode. [formatJumpTo(get_turf(target))]")
	best_light.forceMove(target)
	target.current_bulb = best_light
	best_light = null
	target.on = target.has_power()
	target.update()
	if(target.on && target.current_bulb.rigged)
		target.explode()

/obj/item/device/lightreplacer/proc/get_best_light(var/obj/machinery/light/target)
	if(!istype(supply) || !istype(target))
		return 0
	var/best_light
	if(!target.fitting) //no idea how this happens
		target.fitting = initial(target.fitting)
	switch(target.fitting)
		if("bulb")
			best_light = ((locate(/obj/item/weapon/light/bulb/smart) in supply) || (locate(/obj/item/weapon/light/bulb/he) in supply) || (locate(/obj/item/weapon/light/bulb) in supply))
		if("tube")
			best_light = ((locate(/obj/item/weapon/light/bulb/smart) in supply) || (locate(/obj/item/weapon/light/tube/he) in supply) || (locate(/obj/item/weapon/light/tube) in supply))
		if("large tube")
			best_light = locate(/obj/item/weapon/light/tube/large) in supply
	return best_light

/obj/item/device/lightreplacer/proc/is_light_better(var/obj/item/weapon/light/tested, var/obj/item/weapon/light/comparison)
	if(tested.status >= LIGHT_BROKEN) //Is tested broken or burnt out? If so, it cannot win.
		return 0
	if(tested.status < comparison.status) //Is tested closer to functional than comparison? If so, it wins.
		return 1
	if(tested.status) //Is tested empty? If so, either it must be a tie or comparison wins, so tested cannot win.
		return 0

	//Now we know both work, so all that is left is to test if tested wins by being HE.
	if(findtextEx(tested.base_state, "he", 1, 3) && !findtextEx(comparison.base_state, "he", 1, 3))
		return 1
	else
		return 0

/obj/item/device/lightreplacer/proc/recharge(mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R && R.cell && R.cell.charge && (glass < glass_max))
			var/added_glass = 0
			added_glass = clamp(added_glass, 7500, (glass_max - glass))
			if(R.cell.use(added_glass * 0.1))
				add_glass(added_glass, 2)
				to_chat(usr, "<span class='notice'>\The [src] synthesizes[added_glass] units of glass.</span>")
				return 1
		to_chat(usr, "<span class='warning'>You don't have enough charge to synthesize more glass!</span>")
	return 0

/obj/item/device/lightreplacer/proc/dump_supply(mob/user)
	if(supply && get_turf(user))
		for(var/obj/item/weapon/light/L in supply)
			L.forceMove(get_turf(user))
	return 1

/obj/item/device/lightreplacer/advanced
	name = "advanced light replacer"
	device_mode = LIGHTREPLACER_ADVANCED
	glass_max = 15 * CC_PER_SHEET_GLASS
	cardboard_max = 10

/obj/item/device/lightreplacer/borg
	name = "cyborg light replacer"
	device_mode = LIGHTREPLACER_BORG

/obj/item/device/lightreplacer/borg/New()
	..()
	supply = new /obj/item/weapon/storage/box/lights(src)
	waste = new /obj/item/weapon/storage/box/lights/empty(src)
	add_glass(5 * CC_PER_SHEET_GLASS, 2)

/obj/item/device/lightreplacer/loaded/New()
	..()
	supply = new /obj/item/weapon/storage/box/lights/tubes(src)
	waste = new /obj/item/weapon/storage/box/lights/empty(src)

/obj/item/device/lightreplacer/loaded/he/New()
	..()
	supply = new /obj/item/weapon/storage/box/lights/he(src)
	waste = new /obj/item/weapon/storage/box/lights/empty(src)

/obj/item/device/lightreplacer/loaded/mixed/New()
	..()
	supply = new /obj/item/weapon/storage/box/lights/mixed(src)
	waste = new /obj/item/weapon/storage/box/lights/empty(src)
