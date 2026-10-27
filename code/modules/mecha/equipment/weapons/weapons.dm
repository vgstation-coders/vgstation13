/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = RANGED
	origin_tech = Tc_MATERIALS + "=3;" + Tc_COMBAT + "=3"
	var/projectile
	var/fire_sound


/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(var/obj/mecha/combat/M as obj, var/override = FALSE)
	if(..())
		if(istype(M) || override)
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "\improper General Energy Weapon"

/obj/item/mecha_parts/mecha_equipment/weapon/energy/action(atom/target)
	if(!action_checks(target))
		return
	var/originaltarget = target
	var/turf/curloc = chassis.loc
	var/atom/targloc = get_turf(target)
	if (!targloc || !istype(targloc, /turf) || !curloc)
		return
	if (targloc == curloc)
		return
	set_ready_state(0)
	playsound(chassis, fire_sound, 50, 1)
	var/obj/item/projectile/A = new projectile(curloc)
	A.firer = chassis.occupant
	A.original = target
	A.current = curloc
	A.starting = curloc
	A.yo = targloc.y - curloc.y
	A.xo = targloc.x - curloc.x
	chassis.use_power(energy_drain)
	A.OnFired()
	A.process()
	chassis.log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return


/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	equip_cooldown = 8
	name = "\improper CH-PS \"Immolator\" Laser"
	icon_state = "mecha_laser"
	energy_drain = 30
	projectile = /obj/item/projectile/beam
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	equip_cooldown = 15
	name = "\improper CH-LC \"Solaris\" Laser Cannon"
	icon_state = "mecha_laser"
	energy_drain = 60
	projectile = /obj/item/projectile/beam/heavylaser
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	equip_cooldown = 40
	name = "mkIV Ion Heavy Cannon"
	icon_state = "mecha_ion"
	energy_drain = 120
	projectile = /obj/item/projectile/ion
	fire_sound = 'sound/weapons/ion.ogg'


/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	equip_cooldown = 30
	name = "eZ-13 MK2 heavy pulse rifle"
	icon_state = "mecha_pulse"
	energy_drain = 120
	origin_tech = Tc_MATERIALS + "=3;" + Tc_COMBAT + "=6;" + Tc_POWERSTORAGE + "=4"
	projectile = /obj/item/projectile/beam/pulse/heavy
	fire_sound = 'sound/weapons/marauder.ogg'


/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "u_laser"
	damage = 60

/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	name = "\improper PBT \"Pacifier\" mounted taser"
	icon_state = "mecha_taser"
	energy_drain = 20
	equip_cooldown = 8
	projectile = /obj/item/projectile/energy/electrode
	fire_sound = 'sound/weapons/Taser.ogg'


/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "\improper HoNkER BlAsT 5000"
	icon_state = "mecha_honker"
	energy_drain = 200
	equip_cooldown = 150
	range = MELEE|RANGED

/obj/item/mecha_parts/mecha_equipment/weapon/honker/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/honker/action(target)
	if(!chassis)
		return 0
	if(energy_drain && chassis.get_charge() < energy_drain)
		return 0
	if(!equip_ready)
		return 0

	playsound(chassis, 'sound/items/AirHorn.ogg', 100, 1)
	chassis.occupant_message("<font color='red' size='5'>HONK</font>")
	for(var/mob/living/carbon/M in ohearers(6, chassis))
		if(M.is_deaf())
			continue
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.earprot())
				continue
		to_chat(M, "<font color='red' size='7'>HONK</font>")
		M.sleeping = 0
		M.stuttering += 20
		M.ear_deaf += 30
		M.Knockdown(3)
		if(prob(30))
			M.Stun(10)
			M.Paralyse(4)
		else
			M.Jitter(500)
		/* //else the mousetraps are useless
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(isobj(H.shoes))
				var/thingy = H.shoes
				H.drop_from_inventory(H.shoes)
				walk_away(thingy,chassis,15,2)
				spawn(20)
					if(thingy)
						walk(thingy,0)
		*/
	chassis.use_power(energy_drain)
	log_message("Honked from [src.name]. HONK!")
	message_admins("[key_name_and_info(chassis.occupant)] used a Mecha Honker in ([formatJumpTo(chassis)])",0,1)
	log_game("[key_name(chassis.occupant)] used a Mecha Honker in ([formatJumpTo(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/random_weapon
	var/list/blacklisted = list(
		/obj/item/mecha_parts/mecha_equipment/weapon,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/loaded,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/loaded,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/metalfoam,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/inflatable,
		//leaving the banana mortar in because its funny
		/obj/item/mecha_parts/mecha_equipment/weapon/honker,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/creampie_mortar,
		///obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse,
		///obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		)

/obj/item/mecha_parts/mecha_equipment/weapon/random_weapon/New()
	..()
	var/weapontype = pick(existing_typesof(/obj/item/mecha_parts/mecha_equipment/weapon) - blacklisted)
	new weapontype (loc)
	qdel(src)
