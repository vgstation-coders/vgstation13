// Enhanced mecha gun with projectile storage // THE SLOPPA
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "\improper General Ballistic Weapon"
//	step_delay = 20 // It can't be THAT heavy!
	var/max_projectiles = 0
	var/projectiles = 0
	var/projectile_energy_cost = 0
	var/starts_full = FALSE
	var/projectiles_cache = 0
	var/projectiles_cache_max = 100
	var/disabledreload = FALSE
	var/list/ammo_types = list(/obj/item/ammo_casing/c9mm)
	var/caliber = MM9
	var/no_caliber = FALSE
	var/list/loaded_projectiles = list()
	var/projectile_type
	var/burst_delay = 0 // Delay that seperates each projectile when burst-firing

	var/projectiles_per_shot = 1
	var/deviation = 0.7  //the shots were perfectly accurate no matter what this was set to

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action(atom/target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/originaltarget = target
	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)

	if(!curloc || !targloc)
		do_after_cooldown()
		return
	var/start_loc = curloc
	spawn
		for(var/i=1 to min(projectiles, projectiles_per_shot))
			if(!chassis)
				break
			var/turf/fire_from = start_loc
			var/atom/current_target = originaltarget
			var/turf/current_targloc = targloc
			if(defective)
				current_target = get_inaccuracy(originaltarget, 2, chassis)
				current_targloc = get_turf(current_target)
			if(!current_targloc || current_targloc == fire_from)
				break
			playsound(chassis, fire_sound, 80, 1)
			var/obj/item/projectile/A = new projectile(fire_from)
			src.projectiles--
			A.firer = chassis.occupant
			A.original = current_target
			A.current = fire_from
			A.starting = fire_from
			A.yo = current_targloc.y - fire_from.y
			A.xo = current_targloc.x - fire_from.x
			A.OnFired()
			spawn(0)
				A.process()
			if(i < min(projectiles, projectiles_per_shot))
				sleep(burst_delay)

		log_message("Fired from [src.name], targeting [originaltarget].")
		message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
		log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")

	do_after_cooldown()
	return

/obj/mecha/proc/resupply_single(var/obj/item/ammo_casing/CS, mob/user)
	if(!CS.BB)
		to_chat(user, "<span class='warning'>This box of ammo is empty!</span>")
		return
	var/found_gun = FALSE
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in equipment)
		if(gun.no_caliber || gun.caliber != CS.caliber)
			continue
		found_gun = TRUE
		if(gun.projectiles_cache < gun.projectiles_cache_max)
			playsound(src, 'sound/weapons/magazine_load_click.ogg', 50, 1)
			gun.projectiles_cache++
			CS.BB = null
			to_chat(user, "<span class='notice'>You load the [CS.name] into the [gun.name].</span>")
			qdel(CS) // don't know how to make casings, maybe later
			return

	to_chat(user, found_gun ? "<span class='notice'>You can't fit any more ammo of this type!</span>" : "<span class='notice'>None of the equipment on this exosuit can use this ammo!</span>")

/obj/mecha/proc/resupply_box(var/obj/item/box, mob/user)
	var/obj/item/ammo_casing/sample_ammo
	var/is_storage = istype(box, /obj/item/weapon/storage/box)
	var/is_ammo_storage = istype(box, /obj/item/ammo_storage/box)

	if(!is_storage && !is_ammo_storage)
		return

	if(is_ammo_storage)
		var/obj/item/ammo_storage/box/A = box
		if(!A.stored_ammo || !A.stored_ammo.len)
			to_chat(user, "<span class='warning'>This box of ammo is empty!</span>")
			return
		sample_ammo = A.stored_ammo[1]
	else
		var/obj/item/weapon/storage/box/B = box
		if(!B.contents.len)
			to_chat(user, "<span class='warning'>This box is empty!</span>")
			return
		for(var/obj/item/ammo_casing/AC in B.contents)
			sample_ammo = AC
			break
		if(!sample_ammo)
			to_chat(user, "<span class='warning'>This box doesn't contain any ammunition!</span>")
			return

	var/found_gun = FALSE
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in equipment)
		if(gun.no_caliber)
			continue
		if(!gun.ammo_types || !gun.ammo_types.len)
			continue
		var/ammo_compatible = FALSE
		for(var/ammo_path in gun.ammo_types)
			if(sample_ammo.type == ammo_path)
				ammo_compatible = TRUE
				break
		if(!ammo_compatible)
			continue

		found_gun = TRUE
		var/ammo_needed = gun.projectiles_cache_max - gun.projectiles_cache
		if(ammo_needed > 0)
			var/ammo_loaded = 0

			if(is_ammo_storage)
				var/obj/item/ammo_storage/box/A = box
				var/ammo_to_transfer = min(ammo_needed, A.stored_ammo.len)
				for(var/i = 1 to ammo_to_transfer)
					var/obj/item/ammo_casing/casing = A.get_round()
					if(casing && casing.BB)
						playsound(src, 'sound/weapons/magazine_load_click.ogg', 50, 1)
						gun.projectiles_cache++
						ammo_loaded++
						qdel(casing)
					else
						break
			else
				var/obj/item/weapon/storage/box/B = box
				var/list/ammo_to_remove = list()
				for(var/obj/item/ammo_casing/casing in B.contents)
					// FIX: Check if casing.type is in the ammo_types list
					if(!casing.BB)
						continue
					var/casing_compatible = FALSE
					for(var/ammo_path in gun.ammo_types)
						if(casing.type == ammo_path)
							casing_compatible = TRUE
							break
					if(!casing_compatible)
						continue
					if(ammo_loaded >= ammo_needed)
						break
					ammo_to_remove += casing
					ammo_loaded++
				for(var/obj/item/ammo_casing/casing in ammo_to_remove)
					B.remove_from_storage(casing, null, 1, 0)
					gun.projectiles_cache++
					qdel(casing)
				B.refresh_all()

			to_chat(user, "<span class='notice'>You add [ammo_loaded] round[ammo_loaded > 1 ? "s" : ""] to the [gun.name].</span>")
			return

	to_chat(user, found_gun ? "<span class='notice'>You can't fit any more ammo of this type!</span>" : "<span class='notice'>None of the equipment on this exosuit can use this ammo!</span>")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/rearm()
	if(projectiles >= max_projectiles)
		return FALSE

	var/projectiles_to_add = max_projectiles - projectiles
	if(projectile_energy_cost)
		while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
			projectiles++
			projectiles_to_add--
			chassis.use_power(projectile_energy_cost)
	else
		if(!projectiles_cache)
			return FALSE
		var/ammo_used = min(projectiles_to_add, projectiles_cache)
		projectiles += ammo_used
		projectiles_cache -= ammo_used

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/New()
	..()
	if(starts_full)
		projectiles_cache = projectiles_cache_max
		projectiles = max_projectiles

/////////////
// Misc Mecha Gun Procs
/////////////

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/alt_action()
	rearm()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/become_defective()
	if(!defective)
		..()
		equip_cooldown = rand(equip_cooldown*2, equip_cooldown*3)
		projectile_energy_cost = rand(projectile_energy_cost*1.5, projectile_energy_cost*3)
		max_projectiles = rand(max_projectiles/4, max_projectiles*0.75)
		if(max_projectiles < projectiles)
			projectiles = max_projectiles

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(atom/target)
	if(..())
		if(projectiles > 0)
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Topic(href, href_list)
	if(..())
		return TRUE
	if (href_list["rearm"])
		src.rearm()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_equip_info()
	return "[..()]\[[src.projectiles][projectiles_cache_max &&!projectile_energy_cost?"/[projectiles_cache]":""]\][!disabledreload &&(src.projectiles < src.max_projectiles)?" - <a href='?src=\ref[src];rearm=1'>Rearm</a>":null]"

/obj/mecha/proc/max_ammo() //Max the ammo stored for Nuke Ops mechs, or anyone else that calls this
	for(var/obj/item/I in equipment)
		if(istype(I, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/))
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = I
			gun.projectiles_cache = gun.projectiles_cache_max
			gun.projectiles = gun.max_projectiles
