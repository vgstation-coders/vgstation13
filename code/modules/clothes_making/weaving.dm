/*

/obj/structure/spinning_wheel
/obj/machinery/electric_loom

*/

#define CLOTH_PER_FLAX	2

////////////////////MANUAL LOOM//////////////////////////////////////////////////////////////////////////////////////////
//TODO: support wool as well, and maybe other plants such as coton
//I chose linen to start with because of too much time playing Pharaoh
/obj/structure/spinning_wheel
	name = "spinning wheel"
	desc = "Allows you to manually weave grown flax into linen cloth."
	icon = 'icons/obj/clothes_making.dmi'
	icon_state = "wooden_loom"
	density = 1
	anchored = 0
	pass_flags_self = PASSMACHINE

	var/remaining_cloth_to_spin = 0
	var/mob/spinner = null

/obj/structure/spinning_wheel/Destroy()
	if (spinner)
		spinner = null
		processing_objects.Remove(src)
	..()

/obj/structure/spinning_wheel/examine(mob/user)
	..()
	if(remaining_cloth_to_spin > 0)
		to_chat(user, "<span class='info'>There is enough flax in it to produce [remaining_cloth_to_spin] more length[remaining_cloth_to_spin > 1 ? "s" : ""] of cloth.</span>")
	else
		to_chat(user, "<span class='info'>Grow flax and insert it to spin cloth.</span>")

/obj/structure/spinning_wheel/attack_hand(var/mob/user)
	if (spinner)
		if (user == spinner)
			to_chat(user, "<span class='notice'>You interrupt your weaving.</span>")
			spinner = null
			processing_objects.Remove(src)
			update_icon()
		else
			to_chat(user, "<span class='warning'>\The [spinner] is currently weaving at this [src] already.</span>")
	else if (remaining_cloth_to_spin > 0)
		spinner = user
		to_chat(user, "<span class='notice'>You start weaving the flax into cloth.</span>")
		processing_objects.Add(src)
		playsound(src, 'sound/machines/loom_wooden_start.ogg', 10, 0)
		update_icon()
	else
		to_chat(user, "<span class='warning'>Can't use the wheel before some flax to weave has been added to it.</span>")

/obj/structure/spinning_wheel/attackby(var/obj/item/W, var/mob/user)
	if(W.is_wrench(user))
		W.playtoolsound(src, 100)
		user.visible_message("<span class='notice'>[user] starts disassembling \the [src].</span>", \
		"<span class='notice'>You start disassembling \the [src].</span>")
		if(do_after(user, src, 2 SECONDS))
			user.visible_message("<span class='warning'>[user] dissasembles \the [src].</span>", \
			"<span class='notice'>You dissasemble \the [src].</span>")
			var/turf/T = get_turf(src)
			new /obj/item/stack/sheet/wood(T, 10)
			for (var/i = 1 to round(remaining_cloth_to_spin/CLOTH_PER_FLAX))
				new /obj/item/weapon/reagent_containers/food/snacks/grown/flax(T)
			qdel(src)
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/flax))
		if(user.drop_item(W, loc))
			remaining_cloth_to_spin += CLOTH_PER_FLAX
			qdel(W)
			to_chat(user, "<span class='notice'>You mount the flax upon the loom..</span>")
			playsound(src, 'sound/items/bonegel.ogg', 50, 0)
			update_icon()
	else if (istype(W, /obj/item/weapon/storage/bag/plants))
		var/inserted = FALSE
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/flax/F in W.contents)
			remaining_cloth_to_spin += CLOTH_PER_FLAX
			inserted = TRUE
			qdel(F)
		if (inserted)
			playsound(src, 'sound/items/bonegel.ogg', 50, 0)
			playsound(src, 'sound/effects/rustle3.ogg', 50, 0)
			to_chat(user, "<span class='notice'>You remove the flax from the bag and mount it upon the loom..</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>There is no flax in the bag.</span>")
	else
		..()

/obj/structure/spinning_wheel/process()
	set waitfor = FALSE

	if (!spinner || !Adjacent(spinner) || spinner.incapacitated() || spinner.lying || (remaining_cloth_to_spin <= 0))
		spinner = null
		update_icon()
		processing_objects.Remove(src)
		return
	if (remaining_cloth_to_spin > 0)
		playsound(src, 'sound/machines/loom_wooden.ogg', 20, 0)
		if (spawn_cloth(spinner))
			spawn(10)//process is called every 2 seconds, this lets us spawn 1 cloth per second
				spawn_cloth(spinner)


/obj/structure/spinning_wheel/proc/spawn_cloth(var/mob/_spinner)
	remaining_cloth_to_spin--
	drop_stack(/obj/item/stack/sheet/cloth, loc, 1)
	if (remaining_cloth_to_spin <= 0)
		to_chat(_spinner, "<span class='warning'>There [src] is out of flax.</span>")
		spinner = null
		update_icon()
		processing_objects.Remove(src)
		return 0
	return 1

/obj/structure/spinning_wheel/update_icon()
	if (spinner)
		icon_state = "wooden_loom_spin"
	else if (remaining_cloth_to_spin > 0)
		icon_state = "wooden_loom_ready"
	else
		icon_state = "wooden_loom"


///////////////////ELECTRIC LOOM//////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/electric_loom
	name = "electric loom"
	desc = "Automatically turns flax into cloth while powered. You can set input and output directions with a multitool."
	icon = 'icons/obj/clothes_making.dmi'
	icon_state = "electric_loom"
	density = 1
	anchored = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL | MULTIOUTPUT
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 5
	active_power_usage = 500
	pass_flags_self = PASSMACHINE

	var/remaining_cloth_to_spin = 0
	var/current_production = 0
	var/stored_cloth = 0

	var/manipulator_rating = 0
	var/matterbin_rating = 0

/obj/machinery/electric_loom/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/electric_loom,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
	)

	RefreshParts()
	update_icon()

/obj/machinery/electric_loom/examine(mob/user)
	..()
	if(remaining_cloth_to_spin + current_production > 0)
		to_chat(user, "<span class='info'>There is enough flax in it to produce [remaining_cloth_to_spin*matterbin_rating + current_production] more cloth sheets.</span>")
	else
		to_chat(user, "<span class='info'>Grow flax and insert it to spin cloth. Flax can be loaded automatically by conveyor belt.</span>")

	if(stored_cloth > 0)
		to_chat(user, "<span class='info'>There [stored_cloth > 1 ? "are [stored_cloth] lengths" : "is 1 length"] of cloth on the roll being spun. The machine will eject when it is full, or you can eject the roll now.</span>")
	if(output_dir)
		to_chat(user, "<span class='info'>Ejected cloth will be dropped on the [dir2text(output_dir)]ern tile.</span>")
	else
		to_chat(user, "<span class='info'>You can use a multi-tool to set a direction cloth should automatically be ejected to. Otherwise it will be placed on top of the loom.</span>")

/obj/machinery/electric_loom/spillContents(var/destroy_chance = 0)
	..()
	for (var/i = 1 to round(remaining_cloth_to_spin/CLOTH_PER_FLAX))
		new /obj/item/weapon/reagent_containers/food/snacks/grown/flax(loc)
	remaining_cloth_to_spin = 0
	if (stored_cloth > 0)
		drop_stack(/obj/item/stack/sheet/cloth, loc, stored_cloth)
		stored_cloth = 0
		update_icon()

/obj/machinery/electric_loom/attack_hand(var/mob/user, var/ignore_brain_damage = 0)
	if(..())
		return TRUE

	if (stat & (BROKEN))
		to_chat(user, "You have to fix the machine first.")
		return TRUE
	if (stored_cloth > 0)
		user.put_in_hands(drop_stack(/obj/item/stack/sheet/cloth, src, stored_cloth))
		stored_cloth = 0
		update_icon()
		playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You pick up the roll of cloth woven by the machine.</span>")
	else
		to_chat(user, "<span class='warning'>There is no cloth stored in it. Add some flax to the loom first.</span>")

/obj/machinery/electric_loom/RefreshParts()
	//Better Manipulators = Faster production
	//Better Matter Bins = More cloth per flax
	manipulator_rating = 0
	matterbin_rating = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipulator_rating += SP.rating
		if(istype(SP, /obj/item/weapon/stock_parts/matter_bin))
			matterbin_rating += SP.rating
	manipulator_rating = round(manipulator_rating/3)+1
	matterbin_rating = round(matterbin_rating/2)

/obj/machinery/electric_loom/attackby(var/obj/item/W, var/mob/user)
	if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/flax))
		if (stat & (BROKEN))
			to_chat(user, "You have to fix the machine first.")
			return
		if(user.drop_item(W, loc))
			remaining_cloth_to_spin += CLOTH_PER_FLAX
			qdel(W)
			to_chat(user, "<span class='notice'>You prepare the flax to be woven by the loom.</span>")
			playsound(src, 'sound/items/bonegel.ogg', 50, 0)
			update_icon()
		return
	else if (istype(W, /obj/item/weapon/storage/bag/plants))
		if (stat & (BROKEN))
			to_chat(user, "You have to fix the machine first.")
			return
		var/inserted = FALSE
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/flax/F in W.contents)
			remaining_cloth_to_spin += CLOTH_PER_FLAX
			inserted = TRUE
			qdel(F)
		if (inserted)
			playsound(src, 'sound/items/bonegel.ogg', 50, 0)
			playsound(src, 'sound/effects/rustle3.ogg', 50, 0)
			to_chat(user, "<span class='notice'>You remove the flax from the bag and prepare it be woven by the loom.</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>There is no flax in the bag.</span>")
		return
	..()

/obj/machinery/electric_loom/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if (stat & (BROKEN))
		return FALSE
	if(istype(AM, /obj/item/weapon/storage/bag/plants))
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/flax/F in AM.contents)
			remaining_cloth_to_spin += CLOTH_PER_FLAX
			qdel(F)
	else if(istype(AM, /obj/item/weapon/reagent_containers/food/snacks/grown/flax))
		remaining_cloth_to_spin += CLOTH_PER_FLAX
		qdel(AM)
	else
		return FALSE
	update_icon()
	return TRUE

/obj/machinery/electric_loom/process()
	if (stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return
	if (!powered())
		return

	if ((remaining_cloth_to_spin > 0) || (current_production > 0))
		use_power = MACHINE_POWER_USE_ACTIVE
		playsound(src, 'sound/machines/electric_loom.ogg', 15, 0, -3)
		spawn()
			for (var/i = 1 to (manipulator_rating))
				if (!process_cloth())
					break
				sleep(round(SS_WAIT_MACHINERY/manipulator_rating))//manipulator_rating starts at 2, so by default we produce 1 cloth per second
	else
		use_power = MACHINE_POWER_USE_IDLE

/obj/machinery/electric_loom/proc/process_cloth(var/mob/_spinner)
	if (current_production <= 0)
		remaining_cloth_to_spin--
		current_production += matterbin_rating

	current_production--
	stored_cloth++

	if (stored_cloth >= MAX_SHEET_STACK_AMOUNT)
		stored_cloth = 0
		drop_stack(/obj/item/stack/sheet/cloth, get_output(), MAX_SHEET_STACK_AMOUNT)
		update_icon()

	if (remaining_cloth_to_spin + current_production <= 0)
		update_icon()
		return 0
	return 1

/obj/machinery/electric_loom/update_icon()
	overlays.len = 0
	luminosity = 0
	if (stat & (BROKEN))
		icon_state = "electric_loom-broken"
		return
	if (remaining_cloth_to_spin + current_production <= 0)
		icon_state = "electric_loom"
		if (!(stat & (NOPOWER|FORCEDISABLE)) && powered())
			luminosity = 2
			var/image/led = image(icon,src,"electric_loom-lightempty")
			led.plane = ABOVE_LIGHTING_PLANE
			led.layer = ABOVE_LIGHTING_LAYER
			overlays += led
		if (stored_cloth > 0)
			overlays += "electric_loom-cloth"
	else if ((stat & (NOPOWER|FORCEDISABLE)) || !powered())
		icon_state = "electric_loom_ready"
	else
		if (icon_state != "electric_loom_spin")
			playsound(src, 'sound/machines/electric_loom_start.ogg', 10, 0, -3)
		icon_state = "electric_loom_spin"
		luminosity = 2
		var/image/led = image(icon,src,"electric_loom-lightready")
		led.plane = ABOVE_LIGHTING_PLANE
		led.layer = ABOVE_LIGHTING_LAYER
		overlays += led

/obj/machinery/electric_loom/power_change()
	..()
	update_icon()

/obj/machinery/electric_loom/proc/breakdown()
	stat |= BROKEN
	for (var/i = 1 to round(remaining_cloth_to_spin/CLOTH_PER_FLAX))
		new /obj/item/weapon/reagent_containers/food/snacks/grown/flax(loc)
	remaining_cloth_to_spin = 0
	if (stored_cloth > 0)
		drop_stack(/obj/item/stack/sheet/cloth, loc, stored_cloth)
		stored_cloth = 0
		update_icon()
	update_icon()

/obj/machinery/electric_loom/ex_act(var/severity)
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

/obj/machinery/electric_loom/attack_construct(var/mob/user)
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

/obj/machinery/electric_loom/kick_act(var/mob/living/carbon/human/user)
	..()
	if(stat & (BROKEN))
		return
	if (prob(5))
		breakdown()

/obj/machinery/electric_loom/attack_paw(var/mob/user)
	if(istype(user,/mob/living/carbon/alien/humanoid))
		if(stat & (BROKEN))
			return
		breakdown()
		user.do_attack_animation(src, user)
		visible_message("<span class='warning'>\The [user] slashes at \the [src]!</span>")
		playsound(src, 'sound/weapons/slash.ogg', 100, 1)
		add_hiddenprint(user)
	else if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
	else
		attack_hand(user)
