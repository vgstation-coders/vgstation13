
// Light Replacer (LR)
//
// ABOUT THE DEVICE
//
// This is a device supposedly to be used by Janitors and Janitor Cyborgs which will
// allow them to easily replace lights. This was mostly designed for Janitor Cyborgs since
// they don't have hands or a way to replace lightbulbs.
//
// HOW IT WORKS
//
// You attack a light fixture with it. If the light fixture is broken, it will replace the
// light fixture with a working light. The broken light is then placed into the device's waste box.
// If the fixture is empty then it will just place a light in the fixture.
//
// HOW TO REFILL THE DEVICE
//
// The supply box can be removed and replaced to refill the whole thing at once or lights can be inserted into the device.
// Additionally, it can process glass into any type of light, though it uses much more than other methods of making lights
// and lights made this way start out with a high switchcount.
//
// EMAGGED FEATURES
//
// NOTICE: The Cyborg cannot use the emagged Light Replacer and the light's explosion was nerfed. It cannot create holes in the station anymore.
//
// I'm not sure everyone will react the emag's features so please say what your opinions are of it.
//
// When emagged it will rig every light it replaces, which will explode when the light is on.
// This is VERY noticable, even the device's name changes when you emag it so if anyone
// examines you when you're holding it in your hand, you will be discovered.
// It will also be very obvious who is setting all these lights off, since only Janitor Borgs and Janitors have easy
// access to them, and only one of them can emag their device.
//
// The explosion cannot insta-kill anyone with 30% or more health.

#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3


/obj/item/device/lightreplacer

	name = "light replacer"
	desc = "A device to automatically replace lights. Takes lights from a supply box and puts the spent ones in a waste box."

	icon = 'icons/obj/janitor.dmi'
	icon_state = "lightreplacer0"
	item_state = "electronic"

	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	origin_tech = "magnets=3;materials=2"

	var/obj/item/weapon/storage/box/lights/supply = null //Takes bulbs from here to replace
	var/obj/item/weapon/storage/box/lights/waste = null //Places replaced bulbs here
	var/glass_stor = 0 //How much glass it contains for producing lights
	var/glass_stor_max = 5 * CC_PER_SHEET_GLASS //Max glass it can hold
	var/prod_quality = 30 //Starting switchcount for lights this builds out of glass
	var/prod_eff = 10 //How many times more glass it uses to build lights than would an autolathe
	var/emagged = 0
	var/charge = 1

/obj/item/device/lightreplacer/borg //Since it will mainly be loaded by processing glass, it is MUCH better at it than the standard version.
	glass_stor = 10 * CC_PER_SHEET_GLASS //Twice the capacity of the standard version
	glass_stor_max = 10 * CC_PER_SHEET_GLASS //Starts full
	prod_quality = 0 //Just as good as lights from a box/autolathe
	prod_eff = 5 //Half the glass per light as the standard version

/obj/item/device/lightreplacer/loaded/New() //Contains only a waste box. Exists mainly just as a parent of the other loaded ones, but I guess you can use it.
	..()
	waste = new(src)

/obj/item/device/lightreplacer/loaded/mixed/New() //Contains a box of normal mixed lights plus a waste box.
	..()
	supply = new /obj/item/weapon/storage/box/lights/mixed(src)

/obj/item/device/lightreplacer/loaded/he/New() //Contains a box of high-efficiency mixed lights plus a waste box.
	..()
	supply = new /obj/item/weapon/storage/box/lights/he(src)

/obj/item/device/lightreplacer/borg/New() //Contains a box of mixed lights and a waste box.
	..()
	supply = new /obj/item/weapon/storage/box/lights/mixed(src)
	waste = new /obj/item/weapon/storage/box/lights(src)

/obj/item/device/lightreplacer/examine(mob/user)
	..()
	if(supply)
		if(supply.contents.len)
			user << "<span class='info'>It has [supply.contents.len] light[supply.contents.len == 1 ? "" : "s"] remaining. Check its interface to see what type[supply.contents.len == 1 ? "" : "s"].</span>"
		else
			user << "<span class='info'>Its supply container is empty.</span>"
	else
		user << "<span class='info'>It has no supply container.</span>"

	if(waste)
		user << "<span class='info'>Its waste container has [waste.contents.len] slot[waste.contents.len == 1 ? "" : "s"] full.</span>"
	else
		user << "<span class='info'>It has no waste container.</span>"

	user << "<span class='info'>Its glass storage contains [glass_stor] unit[waste.contents.len == 1 ? "" : "s"].</span>"


/obj/item/device/lightreplacer/attackby(obj/item/W, mob/user)
	if(istype(W,  /obj/item/weapon/card/emag) && emagged == 0)
		Emag()
		return

	if(istype(W, /obj/item/stack/sheet/glass/glass))
		if(!add_glass(CC_PER_SHEET_GLASS))
			user << "<span class='warning'>\The [src] can't hold any more glass!</span>"
			return
		var/obj/item/stack/sheet/glass/glass/G = W
		G.use(1)
		user << "<span class='notice'>You insert \the [G] into \the [src].</span>"
		return

	if(istype(W, /obj/item/weapon/light))
		var/obj/item/weapon/light/L = W
		switch(insert_if_possible(L))
			if(0)
				if(L.status ? istype(waste) : istype(supply)) //The expression returns true if the correct box for the light is valid, which implies that it is full because the insertion failed.
					user << "<span class='warning'>\The [src]'s [L.status ? "waste" : "supply"] container is full!</span>"
				else
					user << "<span class='warning'>\The [src] has no [L.status ? "waste" : "supply"] container!</span>"
			if(1)
				user.visible_message("[user] inserts \a [L] into \the [src]", "You insert \the [L] into \the [src]'s [L.status ? "waste" : "supply"] container.")
			else
				user << "<span class='bnotice'>Something very strange has happened. Please adminhelp and ask someone to view the variables of that light, especially status.</span>"
		return

	if(istype(W, /obj/item/weapon/storage/box/lights))
		if(!supply)
			user.drop_item(W, src)
			user.visible_message("[user] inserts \a [W] into \the [src]", "You insert \the [W] into \the [src] to be used as the supply container.")
			supply = W
			return
		else if(!waste)
			user.drop_item(W, src)
			user.visible_message("[user] inserts \a [W] into \the [src]", "You insert \the [W] into \the [src] to be used as the waste container.")
			waste = W
			return
		else
			user << "<span class='notice'>\The [src] has both a supply box and a waste box. Remove one first if you want to insert a new one.</span>"
			return
		

/obj/item/device/lightreplacer/attack_self(mob/user)
	/* // This would probably be a bit OP. If you want it though, uncomment the code.
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.emagged)
			src.Emag()
			usr << "You shortcircuit the [src]."
			return
	*/

	var/dat = {"<TITLE>Light Replacer Interface</TITLE>

	Glass storage: [glass_stor]/[glass_stor_max]<br>"}

	if(supply)
		dat += {"<a href='?src=\ref[src];build=tube'>Fabricate Tube</a>
		<a href='?src=\ref[src];build=bulb'>Fabricate Bulb</a>

		<h3>Supply Container:</h3>"} //It's not clear here, but the argument to build is the part of the typepath after /obj/item/weapon/light/
		var/list/light_types = new()
		for(var/obj/item/weapon/light/L in supply)
			if(!light_types[L.name])
				light_types[L.name] = 0
			light_types[L.name]++
	
		for(var/T in light_types)
			dat += "<br><b>[T]: </b>[light_types[T]]"

		dat += "<br><b><a href='?src=\ref[src];eject=supply'>Eject Supply Container</a></b>"

	else
		dat += "<h3>No supply container inserted</h3>"

	if(waste)
		dat += {"<br><br><br><h3>Waste Container:</h3>
	
		<b>Filled: </b>[waste.contents.len]/[waste.storage_slots]<br>
		<b><a href='?src=\ref[src];eject=waste'>Eject Waste Container</a></b>
		"}
	else
		dat += "<br><br><br><h3>No waste container inserted</h3>"

	user << browse(dat, "window=lightreplacer")

/obj/item/device/lightreplacer/update_icon()
	icon_state = "lightreplacer[emagged]"


/obj/item/device/lightreplacer/proc/Charge(var/mob/user)
	charge += 1
	if(charge > 7)
		charge = 1

/obj/item/device/lightreplacer/proc/ReplaceLight(var/obj/machinery/light/target, var/mob/living/user)
	var/obj/item/weapon/light/best_light = get_best_light(target)
	if(best_light == 0)
		user << "<span class='warning'>\The [src] has no supply container!</span>"
		return
	else if(!best_light)
		user << "<span class='warning'>\The [src] has no compatible light!</span>"
		return
	if(!is_light_better(best_light, target))
		user << "<span class='notice'>\The [src] has no light better than the one already in \the [target].</span>"
		return

	user << "<span class='notice'>You replace the [target.fitting] with \the [src].</span>"
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)

	supply.remove_from_storage(best_light)

	if(target.status != LIGHT_EMPTY)
		var/obj/item/weapon/light/L1 = new target.light_type(target.loc)
		L1.status = target.status
		L1.rigged = target.rigged
		L1.brightness_range = target.brightness_range
		L1.brightness_power = target.brightness_power
		L1.brightness_color = target.brightness_color
		L1.cost = target.cost
		L1.base_state = target.base_state
		L1.switchcount = target.switchcount
		target.switchcount = 0
		L1.update()
		target.status = LIGHT_EMPTY
		target.update()
		if(!insert_if_possible(L1))
			if(istype(waste))
				user << "<span class='warning'>\The [src]'s waste container is full and it drops the removed light on the floor!</span>"
			else
				user << "<span class='warning'>\The [src] has no waste container and it drops the removed light on the floor!</span>"

	target.status = best_light.status
	target.switchcount = best_light.switchcount
	target.rigged = emagged || best_light.rigged
	target.brightness_range = best_light.brightness_range
	target.brightness_power = best_light.brightness_power
	target.brightness_color = best_light.brightness_color
	target.cost = best_light.cost
	target.base_state = best_light.base_state
	target.light_type = best_light.type
	target.on = target.has_power()
	target.update()
	del(best_light)
	if(target.on && target.rigged)
		target.explode()


/obj/item/device/lightreplacer/proc/Emag()
	emagged = !emagged
	playsound(get_turf(src), "sparks", 100, 1)
	if(emagged)
		name = "Shortcircuited [initial(name)]"
	else
		name = initial(name)
	update_icon()


//Attempts to insert a light into the light replacer's storage.
//If the light works, attempts to place it in the supply box. Otherwise, attempts to place it in the waste box.
//Fails if the light cannot be placed into the correct box for any reason.
//Returns 1 if the light is successfully inserted into the correct box, 0 if the insertion fails, and null if the item to be inserted is not a light or something very strange happens.
/obj/item/device/lightreplacer/proc/insert_if_possible(var/obj/item/weapon/light/L) 
	if(!istype(L))
		return
	if(L.status == LIGHT_OK)
		if(supply && supply.can_be_inserted(L, TRUE))
			supply.handle_item_insertion(L, TRUE)
			return 1
		else
			return 0
	else if(L.status == LIGHT_BROKEN || L.status == LIGHT_BURNED)
		if(waste && waste.can_be_inserted(L, TRUE))
			waste.handle_item_insertion(L, TRUE)
			return 1
		else
			return 0

//Returns the best light currently in the supply container that is compatible with target.
//For the standard light replacer, it just prioritizes HE lights over standard lights. I may add an advanced replacer with better light selection later.
//Returns null if no compatible bulb is found and 0 if the light replacer has no (valid) supply box.
/obj/item/device/lightreplacer/proc/get_best_light(var/obj/machinery/light/target)
	if(!istype(supply))
		return 0
	var/best_light
	switch(target.fitting)
		if("bulb")
			best_light = (locate(/obj/item/weapon/light/bulb/he) in supply) || (locate(/obj/item/weapon/light/bulb) in supply)
		if("tube")
			best_light = (locate(/obj/item/weapon/light/tube/he) in supply) || (locate(/obj/item/weapon/light/tube) in supply)
		if("large tube")
			best_light = locate(/obj/item/weapon/light/tube/large) in supply
	return best_light

//Returns 1 if the first argument is considered better, 0 if the second is better or they are equal, and null if either argument is invalid.
//To be valid, each argument must be an instance of either /obj/item/weapon/light or /obj/machinery/light.
//Again, standard replacer just checks as follows:
//HE light < standard light < no light < broken light = burned-out light
//In normal operation, tested should never be no light and very rarely be a broken light.
/obj/item/device/lightreplacer/proc/is_light_better(var/obj/tested, var/obj/comparison)
	if(!(istype(tested, /obj/item/weapon/light) || istype(tested, /obj/machinery/light)) || !(istype(comparison, /obj/item/weapon/light) || istype(comparison, /obj/machinery/light)))
		return
	if(tested:status >= LIGHT_BROKEN) //Is tested broken or burnt out? If so, it cannot win.
		return 0
	if(tested:status < comparison:status) //Is tested closer to functional than comparison? If so, it wins.
		return 1
	if(tested:status) //Is tested empty? If so, either it must be a tie or comparison wins, so tested cannot win.
		return 0

	//Now we know both work, so all that is left is to test if tested wins by being HE.
	if(findtextEx(tested:base_state, "he", 1, 3) && !findtextEx(comparison:base_state, "he", 1, 3))
		return 1
	else
		return 0

//Can you use it?
//This used to actually check if it wasn't empty, but that's handled in ReplaceLight() now.

/obj/item/device/lightreplacer/proc/CanUse(var/mob/living/user)
	src.add_fingerprint(user)
	//Not sure what else to check for. Maybe if clumsy?
	return 1

//Adds amt glass to the glass storage if possible.
//If force_fill is 0, fails if there is not enough room for all of amt.
//If force_fill is 1, fails only if amt is totally full.
//If force_fill is 2, never fails.
//Returns 1 on success and 0 on fail.
/obj/item/device/lightreplacer/proc/add_glass(var/amt, var/force_fill = 0)
	if(!force_fill)
		if(glass_stor + amt > glass_stor_max)
			return 0
	else if(force_fill == 1)
		if(glass_stor >= glass_stor_max)
			return 0
	glass_stor = min(glass_stor_max, glass_stor + amt)
	return 1

//Attempts to use amt glass from storage. Returns 1 on success and 0 on failure.
/obj/item/device/lightreplacer/proc/use_glass(var/amt)
	if(amt > glass_stor)
		return 0
	glass_stor -= amt
	return 1

/obj/item/device/lightreplacer/Topic(href, href_list)
	if(..()) return 1

	if(href_list["eject"])
		switch(href_list["eject"])

			if("supply")
				if(usr)
					usr.put_in_hands(supply)
					usr.visible_message("[usr] removes \the [supply] from \the [src].", "You remove \the [src]'s supply container, \the [supply].")
				else
					supply.loc = get_turf(src)
				supply = null
				if(usr) attack_self(usr)
				return 1

			if("waste")
				if(usr)
					usr.put_in_hands(waste)
					usr.visible_message("[usr] removes \the [waste] from \the [src].", "You remove \the [src]'s waste container, \the [waste].")
				else
					waste.loc = get_turf(src)
				waste = null
				if(usr) attack_self(usr)
				return 1

	if(href_list["build"])
		var/lightpath = text2path("/obj/item/weapon/light/[href_list["build"]]")
		if(lightpath)
			var/obj/item/weapon/light/L = new lightpath()
			if(!use_glass(L.g_amt * prod_eff))
				del(L)
				if(usr) usr << "<span class='warning'>\The [src] doesn't have enough glass to make that!</span>"
				return 1
			L.switchcount = prod_quality
			if(!insert_if_possible(L))
				L.loc = get_turf(src)
				if(usr) usr << "<span class='notice'>\The [src] successfully fabricates \a [L], but it drops it on the floor.</span>"
			else if(usr) usr << "<span class='notice'>\The [src] successfully fabricates \a [L].</span>"
			if(usr) attack_self(usr)
			return 1


#undef LIGHT_OK
#undef LIGHT_EMPTY
#undef LIGHT_BROKEN
#undef LIGHT_BURNED