/obj/item/device/onetankbomb
	name = "bomb"
	icon = 'icons/obj/tank.dmi'
	item_state = "assembly"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 4
	flags_1 = CONDUCT_1
	var/status = FALSE   //0 - not readied //1 - bomb finished with welder
	var/obj/item/device/assembly_holder/bombassembly = null   //The first part of the bomb is an assembly holder, holding an igniter+some device
	var/obj/item/tank/bombtank = null //the second part of the bomb is a plasma tank


/obj/item/device/onetankbomb/examine(mob/user)
	bombtank.examine(user)

/obj/item/device/onetankbomb/update_icon()
	if(bombtank)
		icon = bombtank.icon
		icon_state = bombtank.icon_state
	if(bombassembly)
		add_overlay(bombassembly.icon_state)
		copy_overlays(bombassembly)
		add_overlay("bomb_assembly")

/obj/item/device/onetankbomb/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/analyzer))
		bombtank.attackby(W, user)
		return
	if(istype(W, /obj/item/wrench) && !status)	//This is basically bomb assembly code inverted. apparently it works.

		to_chat(user, "<span class='notice'>You disassemble [src].</span>")

		bombassembly.forceMove(drop_location())
		bombassembly.master = null
		bombassembly = null

		bombtank.forceMove(drop_location())
		bombtank.master = null
		bombtank = null

		qdel(src)
		return
	var/obj/item/weldingtool/WT = W
	if((istype(WT) && WT.welding))
		if(!status)
			status = TRUE
			GLOB.bombers += "[key_name(user)] welded a single tank bomb. Temp: [bombtank.air_contents.temperature-T0C]"
			message_admins("[key_name_admin(user)] welded a single tank bomb. Temp: [bombtank.air_contents.temperature-T0C]")
			to_chat(user, "<span class='notice'>A pressure hole has been bored to [bombtank] valve. \The [bombtank] can now be ignited.</span>")
	add_fingerprint(user)
	..()

/obj/item/device/onetankbomb/attack_self(mob/user) //pressing the bomb accesses its assembly
	bombassembly.attack_self(user, TRUE)
	add_fingerprint(user)
	return

/obj/item/device/onetankbomb/receive_signal()	//This is mainly called by the sensor through sense() to the holder, and from the holder to here.
	visible_message("[icon2html(src, viewers(src))] *beep* *beep*", "*beep* *beep*")
	sleep(10)
	if(!src)
		return
	if(status)
		bombtank.ignite()	//if its not a dud, boom (or not boom if you made shitty mix) the ignite proc is below, in this file
	else
		bombtank.release()

/obj/item/device/onetankbomb/Crossed(atom/movable/AM as mob|obj) //for mousetraps
	if(bombassembly)
		bombassembly.Crossed(AM)

/obj/item/device/onetankbomb/on_found(mob/finder) //for mousetraps
	if(bombassembly)
		bombassembly.on_found(finder)


// ---------- Procs below are for tanks that are used exclusively in 1-tank bombs ----------

//Bomb assembly proc. This turns assembly+tank into a bomb
/obj/item/tank/proc/bomb_assemble(obj/item/device/assembly_holder/assembly, mob/living/user)
	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
	if(isigniter(assembly.a_left) == isigniter(assembly.a_right))
		return

	if((src in user.get_equipped_items()) && !user.canUnEquip(src))
		to_chat(user, "<span class='warning'>[src] is stuck to you!</span>")
		return

	if(!user.canUnEquip(assembly))
		to_chat(user, "<span class='warning'>[assembly] is stuck to your hand!</span>")
		return

	var/obj/item/device/onetankbomb/bomb = new
	user.transferItemToLoc(src, bomb)
	user.transferItemToLoc(assembly, bomb)

	bomb.bombassembly = assembly	//Tell the bomb about its assembly part
	assembly.master = bomb			//Tell the assembly about its new owner

	bomb.bombtank = src	//Same for tank
	master = bomb

	forceMove(bomb)
	bomb.update_icon()

	user.put_in_hands(bomb)		//Equips the bomb if possible, or puts it on the floor.
	to_chat(user, "<span class='notice'>You attach [assembly] to [src].</span>")
	return

/obj/item/tank/proc/ignite()	//This happens when a bomb is told to explode
	air_contents.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)
	var/fuel_moles = air_contents.gases[/datum/gas/plasma][MOLES] + air_contents.gases[/datum/gas/oxygen][MOLES]/6
	air_contents.garbage_collect()
	var/datum/gas_mixture/bomb_mixture = air_contents.copy()
	var/strength = 1

	var/turf/ground_zero = get_turf(loc)

	if(master)
		qdel(master)
	qdel(src)

	if(bomb_mixture.temperature > (T0C + 400))
		strength = (fuel_moles/15)

		if(strength >=1)
			explosion(ground_zero, round(strength,1), round(strength*2,1), round(strength*3,1), round(strength*4,1))
		else if(strength >=0.5)
			explosion(ground_zero, 0, 1, 2, 4)
		else if(strength >=0.2)
			explosion(ground_zero, -1, 0, 1, 2)
		else
			ground_zero.assume_air(bomb_mixture)
			ground_zero.hotspot_expose(1000, 125)

	else if(bomb_mixture.temperature > (T0C + 250))
		strength = (fuel_moles/20)

		if(strength >=1)
			explosion(ground_zero, 0, round(strength,1), round(strength*2,1), round(strength*3,1))
		else if (strength >=0.5)
			explosion(ground_zero, -1, 0, 1, 2)
		else
			ground_zero.assume_air(bomb_mixture)
			ground_zero.hotspot_expose(1000, 125)

	else if(bomb_mixture.temperature > (T0C + 100))
		strength = (fuel_moles/25)

		if (strength >=1)
			explosion(ground_zero, -1, 0, round(strength,1), round(strength*3,1))
		else
			ground_zero.assume_air(bomb_mixture)
			ground_zero.hotspot_expose(1000, 125)

	else
		ground_zero.assume_air(bomb_mixture)
		ground_zero.hotspot_expose(1000, 125)

	ground_zero.air_update_turf()

/obj/item/tank/proc/release()	//This happens when the bomb is not welded. Tank contents are just spat out.
	var/datum/gas_mixture/removed = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	if(!T)
		return
	T.assume_air(removed)
	air_update_turf()
