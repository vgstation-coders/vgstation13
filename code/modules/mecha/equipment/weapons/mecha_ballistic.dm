// Enhanced mecha gun with projectile storage // THE SLOPPA
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "\improper General Ballistic Weapon"
	step_delay = 20 // It can't be THAT heavy!
	var/max_projectiles = 0
	var/projectiles = 0
	var/projectile_energy_cost = 0
	var/starts_full = FALSE
	var/projectiles_cache = 0
	var/projectiles_cache_max = 100
	var/disabledreload = FALSE
	var/ammo_type = "/obj/item/ammo_casing/c9mm"
	var/caliber = MM9
	var/no_caliber = FALSE
	var/list/loaded_projectiles = list()
	var/projectile_type

	var/projectiles_per_shot = 1
	var/deviation = 0.7  //the shots were perfectly accurate no matter what this was set to

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action(atom/target)
	if(!action_checks(target))
		return

	var/originaltarget = target
	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)

	if(!curloc || !targloc)
		return

	for(var/i=1 to min(projectiles, projectiles_per_shot))
		if(defective)
			target = get_inaccuracy(originaltarget, 2, chassis)
			targloc = get_turf(target)
		if(!targloc || targloc == curloc)
			break
		playsound(chassis, fire_sound, 80, 1)
		var/obj/item/projectile/A = new projectile(curloc)//new projectile(curloc)
		src.projectiles--
		A.firer = chassis.occupant
		A.original = target
		A.current = curloc
		A.starting = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		set_ready_state(0)
		A.OnFired()
		A.process()
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
			gun.projectiles_cache++
			CS.BB = null
			to_chat(user, "<span class='notice'>You load the [CS.name] into the [gun.name].</span>")
			qdel(CS) // don't know how to make casings, maybe later
			return

	to_chat(user, found_gun ? "<span class='notice'>You can't fit any more ammo of this type!</span>" : "<span class='notice'>None of the equipment on this exosuit can use this ammo!</span>")

/obj/mecha/proc/resupply_box(var/obj/item/ammo_storage/box/A, mob/user)
	if(!A.stored_ammo)
		to_chat(user, "<span class='warning'>This box of ammo is empty!</span>")
		return

	var/found_gun = FALSE
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in equipment)
		if(gun.no_caliber || gun.ammo_type != A.ammo_type)
			continue
		found_gun = TRUE
		var/ammo_needed = gun.projectiles_cache_max - gun.projectiles_cache
		if(ammo_needed > 0)
			var/ammo_to_transfer = min(ammo_needed, A.stored_ammo.len)
			var/obj/item/ammo_casing/dropped = A.stored_ammo[ammo_to_transfer]
			for(var/i = 1 to ammo_to_transfer)
				var/obj/item/ammo_casing/casing = A.get_round()
				if(casing && casing.BB)
					gun.projectiles_cache++
					A.stored_ammo -= dropped
				else
					break
			to_chat(user, "<span class='notice'>You add [ammo_to_transfer] round[ammo_to_transfer > 1 ? "s" : ""] to the [gun.name].</span>")
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

///

/mob/living/simple_animal/hostile/mechahitler/mech380
	name = "Mecha Hitler"

	ranged = 1
	rapid = 1

	projectiletype = /obj/item/projectile/bullet/auto380


/mob/living/simple_animal/hostile/mechahitler/ion
	name = "Mecha Hitler"

	ranged = 1
	rapid = 0

	projectiletype = /obj/item/projectile/ion


/mob/living/simple_animal/hostile/mechahitler/mech9mm
	name = "Mecha Hitler"

	ranged = 1
	rapid = 0

	projectiletype = /obj/item/projectile/bullet/midbullet2


/mob/living/simple_animal/hostile/mechahitler/mosin
	name = "Mecha Hitler"

	ranged = 1
	rapid = 0

	projectiletype = /obj/item/projectile/bullet/a762x55
