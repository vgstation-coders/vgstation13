/*
CONTAINS:
SAFES
FLOOR SAFES
*/

//SAFES
/obj/structure/safe
	name = "safe"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms - 2 tumbler safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	anchored = 1
	density = 1
	layer = MACHINERY_LAYER
	var/open = 0		//is the safe open?
	var/tumbler_1_pos	//the tumbler position- from 0 to 72
	var/tumbler_1_open	//the tumbler position to open at- 0 to 72
	var/tumbler_2_pos
	var/tumbler_2_open
	var/dial = 0		//where is the dial pointing?
	var/storage_capacity = 30

	var/feedback = ""

	var/choices = list(
		list("Rotate Clockwise", "radial_increment"),
		list("Rotate Counter-Clockwise", "radial_decrement"),
		)

/obj/structure/safe/New()
	..()
	initialize()

/obj/structure/safe/initialize()
	randomize_tumblers()
	store()

/obj/structure/safe/proc/randomize_tumblers()//avoiding values too close to 0 or 72 to prevent uncrackable safes
	tumbler_1_open = rand(0, 71)
	tumbler_2_open = rand(0, 71)
	while ((tumbler_2_open == (tumbler_1_open + 36)) || (tumbler_2_open == (tumbler_1_open - 36)))
		tumbler_2_open = rand(0, 71)

/obj/structure/safe/proc/store()
	dial = 0
	tumbler_1_pos = rand(0, 71)
	tumbler_2_pos = rand(0, 71)
	var/i = 0
	for(var/obj/item/I in loc)
		I.forceMove(src)
		i++
		if (i >= storage_capacity)
			break

/obj/structure/safe/proc/check_unlocked(var/mob/user, canhear)
	if(tumbler_1_pos == tumbler_1_open && tumbler_2_pos == tumbler_2_open)
		if(user)
			feedback += " <span class='danger'>*[pick("Spring", "Sprang", "Sproing", "Clunk", "Krunk")]*</span>"
		var/turf/T = get_turf(src)
		if(arcanetampered)
			playsound(T, 'sound/items/Deconstruct.ogg', 50, 1)
			playsound(T, 'sound/machines/dial_reset.ogg', 50, 1)
			return 0
		open = TRUE
		playsound(T, 'sound/items/Deconstruct.ogg', 50, 1)
		for (var/atom/movable/AM in contents)
			AM.forceMove(T)
		icon_state = "[initial(icon_state)]-open"
		return 1
	return 0

/obj/structure/safe/proc/decrement(num)
	num -= 1
	if(num < 0)
		num = 71
	return num

/obj/structure/safe/proc/increment(num)
	num += 1
	if(num > 71)
		num = 0
	return num

/obj/structure/safe/proc/radial_check(mob/living/user)
	if(!istype(user))
		return FALSE
	if(!user.client)
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/structure/safe/update_icon()
	if(open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)

/obj/structure/safe/attack_hand(var/mob/user,params,proximity)
	if (open)
		if(alert("Close the safe and reset the dial and tumblers?","Close Safe","Do it","Cancel") == "Do it")
			if (radial_check(user))
				store()
				var/turf/T = get_turf(src)
				playsound(T, 'sound/items/Deconstruct.ogg', 50, 1)
				playsound(T, 'sound/machines/dial_reset.ogg', 50, 1)
				icon_state = initial(icon_state)
				open = FALSE
		return

	recursive_dial(user, show_radial_menu(user,src,choices,'icons/obj/safe_radial.dmi',"radial-safe", custom_check = new /callback(src, nameof(src::radial_check()), user), recursive = TRUE))


/obj/structure/safe/proc/recursive_dial(var/mob/user, var/datum/radial_menu/radial)
	if (!radial)
		return

	var/task = radial.selected_choice

	if (!task || !Adjacent(user))
		radial.finish()
		return

	turn_dial(user, task)

	if (!open && Adjacent(user))
		radial.do_it_again()
		recursive_dial(user, radial)
	else
		radial.finish()

/obj/structure/safe/proc/turn_dial(var/mob/living/user, var/task)
	var/canhear = 0
	if(user.find_held_item_by_type(/obj/item/clothing/accessory/stethoscope))
		if (!(user.sdisabilities & DEAF) && !user.ear_deaf && !user.earprot())
			canhear = 1

	switch (task)
		if ("Rotate Clockwise")
			user.playsound_local(loc, 'sound/machines/dial_tick.ogg', 25, 1)
			dial = increment(dial)
			feedback = "<span class='notice'>You turn the dial up to [dial * 5].</span>"
			if(dial == tumbler_1_pos)
				tumbler_1_pos = increment(tumbler_1_pos)
				if(canhear)
					if(tumbler_1_pos == tumbler_1_open)
						feedback += " <span class='bold'>*[pick("tonk", "krunk", "plunk")]*</span>"
						user.playsound_local(src, 'sound/machines/dial_tick_alt.ogg', 35, 1)
					else
						feedback += " <span class='italics'>*[pick("clack", "scrape", "clank")]*</span>"
				if(tumbler_1_pos == tumbler_2_pos - 36 || tumbler_1_pos == tumbler_2_pos + 36)
					tumbler_2_pos = increment(tumbler_2_pos)
					if(canhear)
						if(tumbler_2_pos == tumbler_2_open)
							feedback += " <span class='bold'>*[pick("tink", "krink", "plink")]*</span>"
							user.playsound_local(src, 'sound/machines/dial_tick_alt.ogg', 35, 1)
						else
							feedback += " <span class='italics'>*[pick("click", "chink", "clink")]*</span>"
				check_unlocked(user, canhear)
			to_chat(user, feedback)

		if ("Rotate Counter-Clockwise")
			user.playsound_local(loc, 'sound/machines/dial_tick.ogg', 25, 1)
			dial = decrement(dial)
			feedback = "<span class='notice'>You turn the dial down to [dial * 5].</span>"
			if(dial == tumbler_1_pos)
				tumbler_1_pos = decrement(tumbler_1_pos)
				if(canhear)
					if(tumbler_1_pos == tumbler_1_open)
						feedback += " <span class='bold'>*[pick("tonk", "krunk", "plunk")]*</span>"
					else
						feedback += " <span class='italics'>*[pick("clack", "scrape", "clank")]*</span>"
				if(tumbler_1_pos == tumbler_2_pos + 36 || tumbler_1_pos == tumbler_2_pos - 36)
					tumbler_2_pos = decrement(tumbler_2_pos)
					if(canhear)
						if(tumbler_2_pos == tumbler_2_open)
							feedback += " <span class='bold'>*[pick("tink", "krink", "plink")]*</span>"
						else
							feedback += " <span class='italics'>*[pick("click", "chink", "clink")]*</span>"
				check_unlocked(user, canhear)
			to_chat(user, feedback)

//Byond randomly breaks radial menus after some time it seems. This workaround will replace the menu without interrupting the player's actions.
/obj/structure/safe/proc/unclog(var/mob/user, var/datum/radial_menu/radial)
	if (radial.selected_choice)
		turn_dial(user, radial.selected_choice)
		radial.finish()
		recursive_dial(user, show_radial_menu(user,src,choices,'icons/obj/safe_radial.dmi',"radial-safe",recursive = TRUE))
	else
		radial.finish()

/obj/structure/safe/attackby(var/obj/item/I, var/mob/user)
	if(open)
		if (I.is_screwdriver(user))
			if(alert("Randomize the tumblers' unlocked positions?","Randomize Tumblers","Do it","Cancel") == "Do it")
				randomize_tumblers()
				playsound(get_turf(src), "sound/items/screwdriver.ogg", 10, 1)
				return
		var/turf/T = get_turf(src)
		user.drop_item(I, T)
	else
		if(istype(I, /obj/item/clothing/accessory/stethoscope))
			recursive_dial(user, show_radial_menu(user,src,choices,'icons/obj/safe_radial.dmi',"radial-safe", custom_check = new /callback(src, nameof(src::radial_check()), user), recursive = TRUE))

/obj/structure/safe/blob_act()
	return

/obj/structure/safe/ex_act(severity)
	return

//FLOOR SAFES
/obj/structure/safe/floor
	name = "floor safe"
	icon_state = "floorsafe"
	density = 0
	level = 1	//underfloor
	layer = BELOW_OBJ_LAYER


/obj/structure/safe/floor/initialize()
	..()
	var/turf/T = loc
	hide(T.intact)


/obj/structure/safe/floor/hide(var/intact)
	invisibility = intact ? 101 : 0

/obj/structure/safe/floor/wizard	//Given that these are so difficult to open, and only spawn in wizard dens, they should have some good loot.
	var/list/loot_list = list(
		/obj/item/weapon/spellbook/oneuse/fireball,
		/obj/item/weapon/spellbook/oneuse/smoke,
		/obj/item/weapon/spellbook/oneuse/blind,
		/obj/item/weapon/spellbook/oneuse/disorient,
		/obj/item/weapon/spellbook/oneuse/mindswap,
		/obj/item/weapon/spellbook/oneuse/forcewall,
		/obj/item/weapon/spellbook/oneuse/teleport/blink,
		/obj/item/weapon/spellbook/oneuse/knock,
		/obj/item/weapon/spellbook/oneuse/horsemask,
		/obj/item/weapon/spellbook/oneuse/clown,
		/obj/item/weapon/spellbook/oneuse/mime,
		/obj/item/weapon/spellbook/oneuse/shoesnatch,
		/obj/item/weapon/spellbook/oneuse/bound_object,
		/obj/item/weapon/gun/energy/staff/change,
		/obj/item/weapon/gun/energy/staff/animate,
		/obj/item/weapon/gun/energy/staff/focus,
		/obj/item/weapon/storage/box/smartbox/clothing_box/gemsuit,
		)

/obj/structure/safe/floor/wizard/New()
	..()
	var/I = pick(loot_list)
	new I(src)
