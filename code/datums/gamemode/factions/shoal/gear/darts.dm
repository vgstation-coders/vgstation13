///////////////////////////////////////////////
//
//				DARTS
//
///////////////////////////////////////////////


/obj/item/ammo_casing/dart
	name = "dart"
	desc = "A dart."
	icon = 'icons/obj/shoal.dmi'
	item_state = "syringe_0"
	icon_state = "dart_0"
	hitsound = 'sound/weapons/toolhit.ogg'
	sharpness = 1
	force = 3
	sharpness_flags = SHARP_TIP
	flags = FPRINT | NOREACT
	starting_materials = list(MAT_GLASS = 1000, MAT_IRON = 1000)
	attack_verb = list("stabs", "sticks", "pokes")
	caliber = DART
	projectile_type = /obj/item/projectile/dart
	w_type = RECYK_METAL

/obj/item/ammo_casing/dart/New()
	..()
	create_reagents(10)			// 10 unit volume.

// Raiders can label their darts, for fun.
/obj/item/ammo_casing/dart/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/device/flashlight/pen))
		set_tiny_label(user)


/obj/item/ammo_casing/dart/suicide_act(var/mob/living/user)
	user.visible_message("<span class='danger'>[user] starts stabbing himself in the neck with [src]! It looks like \he's trying to commit suicide!</span>")
	user.audible_scream()
	for(var/i=1, i<=rand(2,4), i++)
		user.spray_blood(pick(cardinal),rand(1,5))
		playsound(user, 'sound/weapons/toolhit.ogg', 30, 1)
		playsound(user, get_sfx("gib"),40,1)
		user.apply_damage(25, BRUTE, LIMB_HEAD)
		sleep(5)
	var/target_zone = check_zone(user.zone_sel.selecting)
	inject(user, target_zone)
	user.death()
	user.Life()
	return SUICIDE_ACT_CUSTOM

/obj/item/ammo_casing/dart/on_reagent_change()
	..()
	update_icon()

/obj/item/ammo_casing/dart/attack(mob/M, mob/user, def_zone)
	..()

/obj/item/ammo_casing/dart/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(user.a_intent == I_HURT)
		var/target_zone = check_zone(user.zone_sel.selecting)
		if(clumsy_check(user) && prob(50))
			to_chat(user, "<span class='warning'>Your footing slips and you stab yourself in the knee!</span>")
			inject(user, target_zone)
			return
		inject(target, target_zone)

/obj/item/ammo_casing/dart/update_icon()
	if(reagents)
		var/rounded_vol = round(reagents.total_volume,5)
		if(0 < reagents.total_volume && reagents.total_volume < 5)
			rounded_vol = 5
		overlays.len = 0

		icon_state = "dart_[rounded_vol]"
		item_state = "syringe_[rounded_vol]"

		if(reagents.total_volume)
			var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")
			filling.icon_state = "syringe[rounded_vol]"
			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling
	else
		icon_state = "dart_0"
		item_state = "syringe_0"


//////////// TODO
//////////// Instead of simply adding the dart as an implant, consider improving the code for embedded objects (currently only mob cubes use it)
//////////// There's a lot of leftover code for embedded stuff, including a HUD icon.
//////////// Maybe these darts can literally be removed by (alt clicking) on a person/yourself, with some pain if not using a hemostat
//////////// It would be funny to see darts sticking out of people like a pincushion too.

/obj/item/ammo_casing/dart/proc/inject(var/mob/living/target, var/embed_limb)
	reagents.trans_to(target, reagents.total_volume)		// Juice them up!
	var/datum/organ/external/organ = target.get_organ(embed_limb ? embed_limb : LIMB_CHEST)		// If no limb was specified, use the torso.
	if(organ)
		target.visible_message("<span class='warning'>[src] embeds itself in [target]'s [organ.display_name]!</span>", \
			self_message = "<span class='danger'>[src] embeds itself in your [organ.display_name]!</span>", \
			drugged_message = "<span class='good'>[target] gets pumped full of love!</span>")
		if(istype(loc, /mob))
			var/mob/M = loc
			M.drop_item(src, null, TRUE)
		forceMove(target)
		organ.implants += src
		add_blood(target)
	else	// If there's no limb to target, we just give up and die.
		target.visible_message("<span class='warning'>[target] is hit by [src]!</span>", \
			self_message = "<span class='danger'>You're hit by [src]!</span>", \
			drugged_message = "<span class='good'>[target] gets pumped full of love!</span>")
		qdel(src)


///////////////////////////////////////////////
//
//				DART PROJECTILES
//
///////////////////////////////////////////////


// Not to be confused with /obj/item/projectile/bullet/dart AKA shotgun darts.

/obj/item/projectile/dart
	name = "dart"
	icon_state = "syringe"
	phase_type = null
	penetration = 0
	damage = 5
	//nodamage = TRUE
	fire_sound = 'sound/items/syringeproj.ogg'
	travel_range = 6
	projectile_speed = 0.5
	custom_impact = TRUE
	decay_type = null 		// Set to an instance of /obj/item/ammo_casing/dart on fire.

	var/obj/item/ammo_casing/dart/source_dart

/obj/item/projectile/dart/New(atom/A)
	..()
	if(istype(loc, /obj/item/ammo_casing/dart))		// Are we inside a casing right now?
		source_dart = loc
		name = source_dart.name
	else														// This should not happen under normal circumstances, but might occur from guns like a roulette revolver.
		source_dart = new /obj/item/ammo_casing/dart(src)		// In that case, we just conjure up an empty dart out of thin air and shove it inside us.

	decay_type = source_dart 									// Our decay type should be the source dart, so it's dropped if we reach our maximum range.


// This feels jank. It might be better to just have a SHOOTCASINGS gun_flag for projectile weapons. But projectile code is already such as mess.
/obj/item/projectile/dart/OnFired(proj_target)
	if(source_dart.loc != src)											// If our source dart isn't already inside us, move it to us.
		source_dart.forceMove(src)
	source_dart.BB = new source_dart.projectile_type(source_dart)		// Reload the dart with a new projectile, so that it can be fired again when it was retrieved.
	..()


/obj/item/projectile/dart/on_hit(atom/A as mob|obj|turf|area)
	if(!A)
		return
	if(!..())
		return FALSE
	if(ismob(A))
		var/mob/M = A

		// Skeletons, liches, and golemns don't care about darts since they can't be injected. God help you if it's halloween season.
		// Maybe make them pass through sketons and liches instead, since they're... basically just bones?
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && (H.species.chem_flags & NO_INJECT))
				H.visible_message("<span class='warning'>\The [src] bounces harmlessly off of \the [H].</span>", "<span class='notice'>\The [src] bounces off you harmlessly and breaks as it hits the ground.</span>")
				return

		//Reagent logging, same as the syringe gun does it.
		if(source_dart)
			if(source_dart.reagents?.total_volume)
				var/R
				for(var/datum/reagent/E in source_dart.reagents.reagent_list)
					R += E.id + " ("
					R += num2text(E.volume) + "),"
				M.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with \a <b>[src]</b> ([R])"
				firer.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with \a <b>[src]</b> ([R])"
				msg_admin_attack("[firer] ([firer.ckey]) shot [M] ([M.ckey]) with \a [src] ([R]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)")


			source_dart.inject(M, def_zone)		// In we go!




///////////////////////////////////////////////
//
//				DARTGUNS
//
///////////////////////////////////////////////


/obj/item/weapon/gun/projectile/dartgun
	name = "dart gun"
	desc = "A small gas-powered dartgun, capable of delivering chemical cocktails swiftly across short distances. Dials allow you to specify how much of the loaded chemicals to fire at once."
	icon_state = "dartgun-empty"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/dartgun.ogg'

	ammo_type ="/obj/item/ammo_casing/dart"
	mag_type = "/obj/item/ammo_storage/magazine/dart_cartridge"
	caliber = list(DART = 1)

	load_method = 2		// 2 = Magazine loaded. Not sure why the define won't work here.
	force = 10
	recoil = FALSE
	ejectshell = FALSE		// I'm pretty sure this variable does nothing and that this behavior is handled by the (lack of the) EMPTYCASINGS flag
	gun_flags = AUTOMAGDROP

/obj/item/weapon/gun/projectile/dartgun/isHandgun()
	return TRUE

/obj/item/weapon/gun/projectile/dartgun/update_icon()
	if(!stored_magazine)
		icon_state = "dartgun-empty"
		return 1

	if(!stored_magazine.stored_ammo.len)
		icon_state = "dartgun-0"
	else if(stored_magazine.stored_ammo.len > 5)
		icon_state = "dartgun-5"
	else
		icon_state = "dartgun-[stored_magazine.stored_ammo.len]"
	return 1

/obj/item/weapon/gun/projectile/dartgun/New()
	..()
	update_icon()

///////////////////////////////////////////////
//
//			CARTRIDGES AND BOXES
//
///////////////////////////////////////////////

/obj/item/ammo_storage/magazine/dart_cartridge
	name = "dart cartridge"
	desc = "A rack of darts."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "darts"
	item_state = "rcdammo"
	origin_tech = Tc_SYNDICATE + "=2;" + Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	w_class = W_CLASS_SMALL

	caliber = DART
	max_ammo = 5
	starting_ammo = 0
	multiple_sprites = TRUE
	exact = TRUE
	ammo_type = "/obj/item/ammo_casing/dart"

/obj/item/ammo_storage/box/darts
	name = "dart box"
	desc = "A box of empty darts. Holds 15 darts."
	icon_state = "9mmred"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/dart"
	caliber = DART
	max_ammo = 15


///////////////////////////////////////////////
//
//				DART PRESS
//
///////////////////////////////////////////////

/obj/machinery/dart_press
	name = "\improper dart press"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer"
	use_power = MACHINE_POWER_USE_NONE

	machine_flags = WRENCHMOVE | FIXED2WORK

	var/obj/item/weapon/reagent_containers/container_1
	var/obj/item/weapon/reagent_containers/container_2

	var/obj/item/ammo_casing/dart/active_dart
	var/obj/item/ammo_storage/output_box
	var/list/processing_darts = list()

	var/dart_label = ""

/obj/machinery/dart_press/proc/can_insert_output_box(var/obj/C)
	return istype(C, /obj/item/ammo_storage/box/darts) || istype(C,/obj/item/ammo_storage/magazine/dart_cartridge)

/obj/machinery/dart_press/proc/can_insert_container(var/obj/C)
	return istype(C, /obj/item/weapon/reagent_containers/glass) || istype(C, /obj/item/weapon/reagent_containers/food/drinks)

/obj/machinery/dart_press/proc/press_dart()
	var/mix_amount = 5
	if(container_1)
		container_1.reagents.trans_to(active_dart,mix_amount)
	if(container_2)
		container_2.reagents.trans_to(active_dart,mix_amount)
	playsound(src, 'sound/weapons/casing_drop.ogg', 70, 1)
	cycle_dart()

/obj/machinery/dart_press/proc/load_dart(var/obj/item/ammo_casing/dart/D)
	if(istype(D, /obj/item/ammo_casing/dart))
		processing_darts += D
		D.forceMove(src)
	if(!active_dart)
		cycle_dart()

/obj/machinery/dart_press/proc/cycle_dart()
	if(output_box && active_dart)
		active_dart.forceMove(output_box)
		output_box.stored_ammo += active_dart
		active_dart = shift(processing_darts)

/obj/machinery/dart_press/proc/insert_output(var/mob/living/carbon/human/user)
	if(output_box)
		to_chat(user, "<span class='warning'>There's already an output box loaded.</span>")
		return
	var/obj/item/C = user.get_active_hand()
	if(can_insert_output_box(C))
		if(!user.drop_item(C, src, failmsg = TRUE))
			return
		output_box = C
		to_chat(user, "<span class='notice'>You insert [C] into [src].</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
	else
		to_chat(user, "<span class='warning'>You can't insert that.</span>")

/obj/machinery/dart_press/proc/eject_output(var/mob/living/carbon/human/user)
	user.put_in_hands(output_box)
	output_box = null

/obj/machinery/dart_press/proc/remove_active_dart(var/mob/living/carbon/human/user)
	user.put_in_hands(active_dart)
	active_dart = null

/obj/machinery/dart_press/proc/eject_container(var/slot, var/mob/living/carbon/human/user)
	switch(slot)
		if(1)
			if(container_1)
				user.put_in_hands(container_1)
				container_1 = null
		if(2)
			if(container_2)
				user.put_in_hands(container_2)
				container_2 = null

/obj/machinery/dart_press/proc/insert_container(var/slot, var/mob/living/carbon/human/user)
	var/obj/item/C = user.get_active_hand()
	switch(slot)
		if(1)
			if(container_1)
				to_chat(user, "<span class='warning'>There's already a container loaded.</span>")
				return
		if(2)
			if(container_2)
				to_chat(user, "<span class='warning'>There's already a container loaded.</span>")
				return
	if(can_insert_container(C))
		if(!user.drop_item(C, src, failmsg = TRUE))
			return
		switch(slot)
			if(1)
				container_1 = C
			if(2)
				container_2 = C
		to_chat(user, "<span class='notice'>You insert [C] into [src].</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)

	else
		to_chat(user, "<span class='warning'>You can't insert that.</span>")


/obj/machinery/dart_press/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/ammo_storage/box/darts))
		var/obj/item/ammo_storage/S = O
		if(S.stored_ammo.len)
			if(do_after(user, src, 2 SECONDS))
				for(var/obj/item/ammo_casing/dart/A in S.stored_ammo)
					load_dart(A)
					S.stored_ammo -= A
				playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
				to_chat(user, "<span class='notice'>You empty the [O] into [src].")
	if(istype(O, /obj/item/ammo_casing/dart))
		if(!user.drop_item(O, src, failmsg = TRUE))
			return
		load_dart(O)
	..()


/*
/obj/machinery/dart_press/Topic(var/href, var/href_list)
	if(..())
		return 1
	if(href_list["eject"])
		eject_container(href_list["eject"], usr)
	if(href_list["insert"])
		insert_container(href_list["insert"], usr)
	if(href_list["insertoutput"])
		insert_output(usr)
	if(href_list["ejectoutput"])
		eject_output(usr)
	if(href_list["press"])
		press_dart()
	if(href_list["cycle"])
		cycle_dart()
	if(href_list["removeactive"])
		remove_active_dart(usr)
	updateUsrDialog()
*/

/*
/obj/machinery/dart_press/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(isAdminGhost(user) || (ishuman(user) && !user.stat && get_dist(src,user) <= 1))
		user.set_machine(src)
		var/dat = "<b>[src]:</b><br><br>"

		if (container_1)
			dat += "[container_1] contains: "
			if(container_1.reagents && container_1.reagents.reagent_list.len)
				for(var/datum/reagent/R in container_1.reagents.reagent_list)
					dat += "<br>    [R.volume] units of [R.name], "
			else
				dat += "nothing."
			dat += " \[<A href='?src=\ref[src];eject=1'>Eject</A>\]<br>"
		else
			dat += "There are no beakers inserted! \[<A href='?src=\ref[src];insert=1'>Insert</A>\]<br><br><br>"


		if (container_2)
			dat += "[container_2] contains: "
			if(container_2.reagents && container_2.reagents.reagent_list.len)
				for(var/datum/reagent/R in container_2.reagents.reagent_list)
					dat += "<br>    [R.volume] units of [R.name], "
			else
				dat += "nothing."
			dat += " \[<A href='?src=\ref[src];eject=2'>Eject</A>\]<br>"
		else
			dat += "There are no beakers inserted! \[<A href='?src=\ref[src];insert=2'>Insert</A>\]<br><br><br>"


		if (active_dart)
			dat += "The active dart contains "
			if(active_dart.reagents && active_dart.reagents.reagent_list.len)
				for(var/datum/reagent/R in active_dart.reagents.reagent_list)
					dat += "<br>    [R.volume] units of [R.name], "
			else
				dat += "nothing."
			dat += " \[<A href='?src=\ref[src];removeactive=1'>Remove</A>\]<br>"
		else
			dat += "There is no active dart. <br><br><br>"


		if (output_box)
			dat += "The output box [output_box] contains: "
			if(output_box.stored_ammo.len)
				dat += "[output_box.stored_ammo.len] darts. "
			else
				dat += "nothing."
			dat += " \[<A href='?src=\ref[src];ejectoutput=1'>Eject</A>\]<br>"
		else
			dat += "There is no output box! \[<A href='?src=\ref[src];insertoutput=1'>Insert</A>\]<br><br><br>"



		user << browse(HTML_SKELETON(dat), "window=dartpress")
		onclose(user, "dartpress", src)
*/

/obj/machinery/dart_press/attack_hand(mob/user as mob)
	if(..())
		return
	tgui_interact(user)

/obj/machinery/dart_press/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DartPress")
		ui.open()

/obj/machinery/dart_press/ui_data(mob/user)
	var/list/data = list()

	data["container_1"] = null
	data["container_2"] = null
	data["active_dart"] = null
	data["loaded_darts"] = processing_darts.len
	data["dart_label"] = dart_label
	if(!output_box)
		data["output_darts"] = -1
		data["output_max"] = -1
	else
		data["output_darts"] = output_box.stored_ammo.len
		data["output_max"] = output_box.max_ammo


	if(container_1)
		var/list/container_data = list(
			"name" = container_1.name,
			"containericon" = icon2base64(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(container_1)))),
			"reagents" = list()
		)
		if(container_1.reagents && container_1.reagents.reagent_list.len)
			for(var/datum/reagent/R in container_1.reagents.reagent_list)
				var/list/reagent_data = list(
					"name" = R.name,
					"volume" = R.volume
				)
				container_data["reagents"] += list(reagent_data)
		data["container_1"] = container_data
	if(container_2)
		var/list/container_data = list(
			"name" = container_2.name,
			"containericon" = icon2base64(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(container_2)))),
			"reagents" = list()
		)
		if(container_2.reagents && container_2.reagents.reagent_list.len)
			for(var/datum/reagent/R in container_2.reagents.reagent_list)
				var/list/reagent_data = list(
					"name" = R.name,
					"volume" = R.volume
				)
				container_data["reagents"] += list(reagent_data)
		data["container_2"] = container_data
	if(active_dart)
		var/list/container_data = list(
			"name" = active_dart.name,
			"containericon" = icon2base64(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(active_dart)))),
			"reagents" = list()
		)
		if(active_dart.reagents && active_dart.reagents.reagent_list.len)
			for(var/datum/reagent/R in active_dart.reagents.reagent_list)
				var/list/reagent_data = list(
					"name" = R.name,
					"volume" = R.volume
				)
				container_data["reagents"] += list(reagent_data)
		data["active_dart"] = container_data

	return data


/obj/machinery/dart_press/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			switch(params["choice"])
				if(1 to 2)
					eject_container(params["choice"], usr)
				if(3) // 3 == active dart
					remove_active_dart(usr)
				if(4)
					eject_output(usr)
		if("insert")
			switch(params["choice"])
				if(1 to 2)
					insert_container(params["choice"], usr)
				if(3) // 3 == active dart
					var/obj/item/I = usr.get_active_hand()
					if(istype(I, /obj/item/ammo_casing/dart))
						if(usr.drop_item(I, src, failmsg = TRUE))
							load_dart(I)
				if(4)
					insert_output(usr)
		if("press")
			press_dart()
		if("cycle")
			cycle_dart()
	SStgui.try_update_ui(ui.user, src, ui)
	return TRUE
