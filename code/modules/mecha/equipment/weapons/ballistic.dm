//Exosuit ballistic weapons: autocannons, shotguns, missile racks, grenade launchers and mortars.
//To switch a gun between real ammo and power-made projectiles, or change what it spawns loaded with,
//edit uses_ammo and ammo_type on its type below.

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "\improper General Ballistic Weapon"
	var/max_projectiles
	var/projectiles
	var/projectile_energy_cost

	//-------- AMMO SETTINGS --------
	var/uses_ammo = FALSE //TRUE: fed real ammo_casings that have to be loaded. FALSE: makes projectiles out of power like it used to
	var/starts_loaded = FALSE //TRUE: spawns full. FALSE: spawns empty, and has to be loaded (uses_ammo) or rearmed (power) first
	var/ammo_type = null //Casing type the magazines are filled with when starts_loaded is on. Only used with uses_ammo
	//-------------------------------
	var/list/calibers = null //Calibers it accepts when uses_ammo is on, same format as guns: list(CALIBER = 1)
	var/mag_count = 3 //Number of fixed internal magazines
	var/mag_capacity = 0 //Rounds per magazine
	var/list/magazines = null //List of lists of ammo_casings
	var/current_mag = 1
	var/loading = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/New()
	..()
	projectiles = starts_loaded ? max_projectiles : 0
	if(uses_ammo && (!calibers || mag_capacity <= 0)) //Nothing it could be loaded with, fall back to power
		uses_ammo = FALSE
	if(uses_ammo)
		magazines = new /list(mag_count)
		for(var/i = 1 to mag_count)
			var/list/mag = list()
			if(starts_loaded && ammo_type)
				for(var/j = 1 to mag_capacity)
					mag += new ammo_type(src)
			magazines[i] = mag

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Destroy()
	if(magazines)
		for(var/list/mag in magazines)
			for(var/obj/item/ammo_casing/AC in mag)
				qdel(AC)
			mag.Cut()
		magazines = null
	..()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/rounds_left()
	if(!uses_ammo)
		return projectiles
	. = 0
	for(var/list/mag in magazines)
		. += mag.len

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/can_take_round(var/obj/item/ammo_casing/AC)
	return istype(AC) && AC.BB && calibers[AC.caliber]

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/free_space()
	. = 0
	for(var/list/mag in magazines)
		. += mag_capacity - mag.len

//Puts a casing into the first magazine with room, starting with the selected one
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/insert_round(var/obj/item/ammo_casing/AC)
	for(var/i = 0 to mag_count - 1)
		var/list/mag = magazines[((current_mag - 1 + i) % mag_count) + 1]
		if(mag.len < mag_capacity)
			mag += AC
			AC.forceMove(src)
			return TRUE
	return FALSE

//Whether this weapon would accept anything from W right now
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/accepts_ammo(var/obj/item/W)
	if(!uses_ammo || !free_space())
		return FALSE
	if(istype(W, /obj/item/ammo_casing))
		return can_take_round(W)
	if(istype(W, /obj/item/ammo_storage))
		var/obj/item/ammo_storage/AS = W
		for(var/obj/item/ammo_casing/AC in AS.stored_ammo)
			if(can_take_round(AC))
				return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/load_ammo(var/obj/item/W, var/mob/user)
	if(!accepts_ammo(W))
		return 0
	var/atom/holder = chassis ? chassis : src
	if(istype(W, /obj/item/ammo_casing))
		if(!user.drop_item(W, src, failmsg = TRUE))
			return 0
		if(!insert_round(W)) //Should not happen, accepts_ammo checked for space
			W.forceMove(get_turf(holder))
			return 0
		playsound(holder, 'sound/weapons/magazine_load_click.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You load \the [W] into \the [src].</span>")
		update_equip_info()
		return 1
	var/obj/item/ammo_storage/AS = W
	if(loading || AS.reloading)
		return 0
	loading = TRUE
	AS.reloading = TRUE
	user.visible_message("<span class='notice'>[user] starts feeding rounds from \the [AS] into \the [holder]'s [src.name].</span>", \
		"<span class='notice'>You start feeding rounds from \the [AS] into \the [src].</span>")
	var/loaded = 0
	if(do_after(user, holder, 2 SECONDS))
		for(var/obj/item/ammo_casing/AC in AS.stored_ammo.Copy())
			if(!free_space())
				break
			if(!can_take_round(AC))
				continue
			AS.stored_ammo -= AC
			insert_round(AC)
			loaded++
	AS.reloading = FALSE
	loading = FALSE
	if(loaded)
		AS.update_icon()
		playsound(holder, AS.reload_sound, 50, 1)
		to_chat(user, "<span class='notice'>You load [loaded] round\s from \the [AS] into \the [src].</span>")
		update_equip_info()
	return loaded

//Takes the next round, switching to the next non-empty magazine if the current one is dry
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/pop_round()
	var/list/mag = magazines[current_mag]
	if(!mag.len)
		for(var/i = 1 to mag_count - 1)
			var/next = ((current_mag - 1 + i) % mag_count) + 1
			var/list/other = magazines[next]
			if(other.len)
				current_mag = next
				mag = other
				occupant_message("Magazine empty, switching to magazine [current_mag].", TRUE)
				break
	if(!mag.len)
		return null
	var/obj/item/ammo_casing/AC = mag[mag.len]
	mag.len--
	return AC

//Fires one round at target. With uses_ammo it fires the next loaded casing and ejects it spent,
//otherwise it makes a projectile out of the stored charge. Returns FALSE if out of ammo.
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/fire_round(atom/target, turf/curloc, turf/targloc)
	var/obj/item/projectile/A
	if(uses_ammo)
		var/obj/item/ammo_casing/AC = pop_round()
		if(!AC)
			return FALSE
		A = AC.BB
		AC.BB = null
		AC.forceMove(curloc)
		AC.update_icon()
		if(!A)
			return TRUE
		A.forceMove(curloc)
	else
		if(projectiles <= 0 || !projectile)
			return FALSE
		projectiles--
		A = new projectile(curloc)
	A.firer = chassis.occupant
	A.shot_from = src
	A.original = target
	A.current = curloc
	A.starting = curloc
	A.yo = targloc.y - curloc.y
	A.xo = targloc.x - curloc.x
	A.OnFired()
	A.process()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/cycle_magazine()
	current_mag = (current_mag % mag_count) + 1
	var/list/mag = magazines[current_mag]
	occupant_message("Switched to magazine [current_mag] ([mag.len]/[mag_capacity]).")
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/eject_magazine()
	var/list/mag = magazines[current_mag]
	if(!mag.len)
		occupant_message("Magazine [current_mag] is already empty.")
		return
	var/turf/T = get_turf(src)
	for(var/obj/item/ammo_casing/AC in mag)
		AC.forceMove(T)
		AC.update_icon()
	occupant_message("Dumped [mag.len] round\s from magazine [current_mag].")
	log_message("Unloaded magazine [current_mag].")
	mag.Cut()
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/attackby(obj/item/W, mob/user)
	if(load_ammo(W, user))
		return
	..()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/examine(mob/user)
	..()
	if(uses_ammo)
		for(var/i = 1 to mag_count)
			var/list/mag = magazines[i]
			to_chat(user, "<span class='info'>Magazine [i]: [mag.len]/[mag_capacity] rounds.</span>")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/alt_action()
	if(uses_ammo)
		cycle_magazine()
	else
		rearm()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(atom/target)
	if(..())
		if(rounds_left() > 0)
			return 1
		if(uses_ammo && chassis)
			playsound(chassis, 'sound/weapons/empty.ogg', 50, 1)
			occupant_message("<span class='warning'>\The [src] is out of ammunition!</span>", TRUE)
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_equip_info()
	if(uses_ammo)
		var/list/mag = magazines[current_mag]
		return "[..()]\[Mag [current_mag]/[mag_count]: [mag.len]/[mag_capacity] | [rounds_left()] total\] - <a href='?src=\ref[src];cycle_mag=1'>Next mag</a> - <a href='?src=\ref[src];eject_mag=1'>Unload</a>"
	return "[..()]\[[src.projectiles]\][(src.projectiles < src.max_projectiles)?" - <a href='?src=\ref[src];rearm=1'>Rearm</a>":null]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/rearm()
	if(uses_ammo)
		return
	if(projectiles < max_projectiles)
		var/projectiles_to_add = max_projectiles - projectiles
		while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
			projectiles++
			projectiles_to_add--
			chassis.use_power(projectile_energy_cost)
	send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	log_message("Rearmed [src.name].")
	to_chat(chassis.occupant, "<span class='notice'>Rearmed [src.name].</span>")
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Topic(href, href_list)
	if(..())
		return TRUE
	if (href_list["rearm"])
		src.rearm()
	if(uses_ammo)
		if(href_list["cycle_mag"])
			cycle_magazine()
		if(href_list["eject_mag"])
			eject_magazine()
	return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "\improper LBX AC 10 \"Scattershot\""
	icon_state = "mecha_scatter"
	equip_cooldown = 20
	fire_sound = 'sound/weapons/shotgun.ogg'
	energy_drain = 5
	uses_ammo = TRUE
	starts_loaded = FALSE
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	calibers = list(GAUGE12 = 1, GAUGEFLARE = 1)
	mag_capacity = 7
	//Only used when uses_ammo = FALSE
	projectile = /obj/item/projectile/bullet/buckshot
	max_projectiles = 20
	projectile_energy_cost = 25
	var/projectiles_per_shot = 1
	var/deviation = 0.7  //the shots were perfectly accurate no matter what this was set to

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/loaded
	starts_loaded = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/action(atom/target)
	if(!action_checks(target))
		return
	var/originaltarget = target
	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if(!curloc || !targloc || targloc == curloc)
		return
	set_ready_state(0)
	chassis.use_power(energy_drain)
	for(var/i=1 to projectiles_per_shot)
		if(!fire_round(target, curloc, targloc))
			break
		playsound(chassis, fire_sound, 80, 1)
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return



/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "\improper Ultra AC 2"
	icon_state = "mecha_uac2"
	equip_cooldown = 10
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	energy_drain = 5
	uses_ammo = TRUE
	starts_loaded = FALSE
	ammo_type = /obj/item/ammo_casing/c380auto
	calibers = list(POINT380 = 1)
	mag_capacity = 100
	//Only used when uses_ammo = FALSE
	projectile = /obj/item/projectile/bullet/weakbullet/mech
	max_projectiles = 300
	projectile_energy_cost = 20
	var/projectiles_per_shot = 3
//	var/deviation = 0.3

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/loaded
	starts_loaded = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/action(atom/target)
	if(!action_checks(target))
		return
	var/originaltarget = target
	var/turf/targloc = get_turf(target)
	chassis.use_power(energy_drain)
	spawn	for(var/i=1 to projectiles_per_shot)
		if(!chassis)
			break
		var/turf/curloc = get_turf(chassis)
		if (!targloc || !curloc)
			continue
		if (targloc == curloc)
			continue
		if(!fire_round(target, curloc, targloc))
			break
		playsound(chassis, fire_sound, 50, 1)
		sleep(2)
	set_ready_state(0)
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	name = "\improper SRM-8 Missile Rack"
	icon_state = "mecha_missilerack"
	projectile = /obj/item/missile
	fire_sound = 'sound/weapons/rocket.ogg'
	max_projectiles = 8
	starts_loaded = FALSE
	projectile_energy_cost = 1000
	equip_cooldown = 60
	var/missile_speed = 2
	var/missile_range = 30

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/missile/M = new projectile(chassis.loc)
	M.primed = 1
	playsound(chassis, fire_sound, 50, 1)
	var/originaltarget = target
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return


/obj/item/missile
	icon = 'icons/obj/grenade.dmi'
	icon_state = "missile"
	var/primed = null
	throwforce = 15

/obj/item/missile/throw_impact(atom/hit_atom)
	if(primed)
		explosion(hit_atom, 0, 1, 2)
		qdel(src)
	else
		..()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/loaded
	starts_loaded = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	name = "\improper SGL-6 Grenade Launcher"
	icon_state = "mecha_grenadelnchr"
	projectile = /obj/item/weapon/grenade/flashbang
	fire_sound = 'sound/weapons/grenadelauncher.ogg'
	max_projectiles = 6
	starts_loaded = FALSE
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 60
	var/det_time = 20
	var/obj/item/weapon/grenade/grenade
	var/can_pre_detonate = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/action(target)
	if(can_pre_detonate && grenade)
		grenade.prime(chassis.occupant)
		grenade = null
		return
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/weapon/grenade/G = new projectile(chassis.loc)
	grenade = G
	playsound(chassis, fire_sound, 50, 1)
	var/originaltarget = target
	G.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	spawn(det_time)
		if(grenade)
			grenade = null
			G.prime(chassis.occupant)
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang//Because I am a heartless bastard -Sieve
	name = "\improper SOP-6 Grenade Launcher"
	projectile = /obj/item/weapon/grenade/flashbang/clusterbang

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/loaded
	starts_loaded = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited
	starts_loaded = TRUE //Can't rearm, so it comes with its one load

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/get_equip_info()//Limited version of the clusterbang launcher that can't reload
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[chassis.selected==src?"<b>":"<a href='?src=\ref[chassis];select_equip=\ref[src]'>"][src.name][chassis.selected==src?"</b>":"</a>"]\[[src.projectiles]\]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/rearm()
	return//Extra bit of security

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/metalfoam
	starts_loaded = TRUE //Not gunpowder, comes stocked
	name = "\improper Metal Foam Grenade Launcher"
	desc = "An exosuit-mounted Metal Foam Grenade Launcher. (Can be attached to: Engineering exosuits)"
	projectile = /obj/item/weapon/grenade/chem_grenade/metalfoam
	origin_tech = Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=2;" + Tc_ENGINEERING + "=3"
	can_pre_detonate = TRUE
	equip_cooldown = 30
	range = RANGED | MELEE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/metalfoam/can_attach(var/obj/mecha/working/clarke/M)
	if(istype(M))
		return ..(M,TRUE)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/inflatable
	starts_loaded = TRUE //Not gunpowder, comes stocked
	name = "\improper Inflatable Barrier Launcher"
	desc = "An exosuit-mounted Inflatable Barrier Launcher. (Can be attached to: Engineering exosuits)"
	projectile = /obj/item/weapon/grenade/inflatable
	origin_tech = Tc_MATERIALS + "=2;" + Tc_MAGNETS + "=1;" + Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2"
	can_pre_detonate = TRUE
	equip_cooldown = 10
	range = RANGED | MELEE
	var/mode = 0
	var/inflatable_type = 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/inflatable/Topic(href,href_list)
	if(..())
		return TRUE
	if(href_list["inflatable_type"])
		inflatable_type = !inflatable_type
		if(inflatable_type)
			projectile = /obj/item/weapon/grenade/inflatable/door
			occupant_message("Now set to launch inflatable doors.")
		else
			projectile = /obj/item/weapon/grenade/inflatable
			occupant_message("Now set to launch inflatable walls.")
	if(href_list["mode"])
		mode = !mode
		if(mode)
			occupant_message("Now set to deflate inflatable barriers.")
		else
			occupant_message("Now set to deploy inflatable barriers.")
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/inflatable/get_equip_info()
	return "[..()] \n[mode ? "" : "Current projectile: inflatable [inflatable_type ? "door" : "wall"]\[<a href='?src=\ref[src];inflatable_type=0'>change</a>\]"]\[<a href='?src=\ref[src];mode=0'>switch to [mode ? "deploy" : "deflate"] mode</a>\]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/inflatable/action(target)
	if(mode)
		if(istype(target, /obj/structure/inflatable))
			if(!chassis.Adjacent(target))
				occupant_message("You must be next to \the [target] in order to deflate it.")
				return
			var/obj/structure/inflatable/I = target
			I.deflate()
		return
	else if(chassis.Adjacent(target))
		if(istype(target, /obj/structure/inflatable/door))
			var/obj/structure/inflatable/door/D = target
			D.toggle(chassis.occupant)
		if(isturf(target))
			..()
		return
	..()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/inflatable/can_attach(var/obj/mecha/working/clarke/M)
	if(istype(M))
		return ..(M,TRUE)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	starts_loaded = TRUE //Not gunpowder, comes stocked
	name = "\improper Banana Mortar"
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/weapon/bananapeel
	fire_sound = 'sound/items/bikehorn.ogg'
	max_projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/weapon/bananapeel/B = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 60, 1)
	B.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Bananed from [src.name], targeting [target]. HONK!")
	message_admins("[key_name_and_info(chassis.occupant)] banana'd \a [src] towards [target] ([formatJumpTo(chassis)])",0,1)
	log_game("[key_name(chassis.occupant)] banana'd \a [src] towards [target] ([formatLocation(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	starts_loaded = TRUE //Not gunpowder, comes stocked
	name = "\improper Mousetrap Mortar"
	icon_state = "mecha_mousetrapmrtr"
	projectile = /obj/item/device/assembly/mousetrap
	fire_sound = 'sound/items/bikehorn.ogg'
	max_projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 10

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/device/assembly/mousetrap/M = new projectile(chassis.loc)
	M.secured = 1
	playsound(chassis, fire_sound, 60, 1)
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Launched a mouse-trap from [src.name], targeting [target]. HONK!")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [target] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [target] ([formatLocation(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/creampie_mortar //why waste perfectly good food synthetizing technology in solving world hunger when you can have clowntide instead?
	starts_loaded = TRUE //Not gunpowder, comes stocked
	name = "\improper Rapid-Fire Cream Pie Mortar"
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/weapon/reagent_containers/food/snacks/pie/empty //because some chucklefuck will try to catch the pie somehow for free nutriment
	fire_sound = 'sound/items/bikehorn.ogg'
	max_projectiles = 15
	missile_speed = 0.75 //for maximum pie-traveling
	projectile_energy_cost = 100
	equip_cooldown = 5
	range = MELEE|RANGED

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/creampie_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/creampie_mortar/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/weapon/reagent_containers/food/snacks/pie/P = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 60, 1)
	P.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Cream-pied from [src.name], targeting [target]. HONK!")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [target] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [target] ([formatLocation(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas
	starts_loaded = TRUE //Not gunpowder, comes stocked
	name = "\improper PCMK-6 Bolas Launcher"
	icon_state = "mecha_bolas"
	projectile = /obj/item/weapon/legcuffs/bolas/mech
	fire_sound = 'sound/weapons/whip.ogg'
	max_projectiles = 10
	missile_speed = 1
	missile_range = 30
	projectile_energy_cost = 50
	equip_cooldown = 10


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/weapon/legcuffs/bolas/mech/M = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	var/originaltarget = target
	M.throw_at(target, missile_range, missile_speed)
	playsound(src,'sound/weapons/whip.ogg', 20, 1) //because mechs play the sound anyways
	projectiles--
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas/restrainment
	name = "\improper PCMK-7 Restrainment Module"
	desc = "This upgraded version of the PCMK-6 is capable of applying handcuffs as well as launching bolas."
	range = MELEE | RANGED

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas/restrainment/action(target)
	if(!action_checks(target))
		return
	if(loc.Adjacent(target) && istype(target, /mob/living/carbon))
		var/obj/mecha/M = loc
		if(!istype(M))
			return ..()
		var/mob/living/carbon/human/user = M.occupant
		if(!istype(user))
			return ..()

		var/mob/living/carbon/C = target
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if (!H.has_organ_for_slot(slot_handcuffed))
				to_chat(user, "<span class='danger'>\The [C] needs at least two wrists before you can cuff them together!</span>")
				return

		playsound(src, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
		user.visible_message("<span class='danger'>\The [M] is trying to handcuff \the [C]!</span>",
							 "<span class='danger'>You try to handcuff \the [C]!</span>")

		if(do_after(user, C, 3 SECONDS, 10, FALSE, TRUE))
			var/obj/item/weapon/handcuffs/cuffs = new(src)
			feedback_add_details("handcuffs", "H")

			user.visible_message("<span class='danger'>\The [M] has put \the [cuffs] on \the [C]!</span>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has put \the [cuffs] on [C.name] ([C.ckey])</font>")
			C.attack_log += text("\[[time_stamp()]\] <font color='red'>Handcuffed with \the [cuffs] by [user.name] ([user.ckey])</font>")
			log_attack("[user.name] ([user.ckey]) has cuffed [C.name] ([C.ckey]) with \the [cuffs] while piloting \the [M]")

			C.equip_to_slot(cuffs, slot_handcuffed)
			projectiles--
	else
		..()
