/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	layer = PROJECTILE_LAYER
	flag = "energy"
	fire_sound = 'sound/weapons/ion.ogg'

/obj/item/projectile/ion/to_bump(atom/A as mob|obj|turf|area)
	if(!bumped && ((A != firer) || reflected))
		empulse(get_turf(A), 1, 1)
		qdel(src)
		return
	..()

/obj/item/projectile/ion/small/to_bump(atom/A as mob|obj|turf|area)
	if(!bumped && ((A != firer) || reflected))
		empulse(get_turf(A), 0, 1)
		qdel(src)
		return
	..()

/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"

/obj/item/projectile/bullet/gyro/to_bump(var/atom/target) //The bullets lose their ability to penetrate (which was pitiful for these ones) but now explode when hitting anything instead of only some things.
	explosion(target, -1, 0, 2)
	qdel(src)

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "temp_4"
	damage = 0
	damage_type = BURN
	nodamage = 1
	layer = PROJECTILE_LAYER
	flag = "energy"
	var/temperature = 300
	fire_sound = 'sound/weapons/pulse3.ogg'

/obj/item/projectile/temp/OnFired()
	..()

	var/obj/item/weapon/gun/energy/temperature/T = shot_from
	if(istype(T))
		temperature = T.temperature
	else
		temperature = rand(100,600) //give it a random temp value if it's not fired from a temp gun

	switch(temperature)
		if(501 to INFINITY)
			name = "searing beam"	//if emagged
			icon_state = "temp_8"
		if(400 to 500)
			name = "burning beam"	//temp at which mobs start taking HEAT_DAMAGE_LEVEL_2
			icon_state = "temp_7"
		if(360 to 400)
			name = "hot beam"		//temp at which mobs start taking HEAT_DAMAGE_LEVEL_1
			icon_state = "temp_6"
		if(335 to 360)
			name = "warm beam"		//temp at which players get notified of their high body temp
			icon_state = "temp_5"
		if(295 to 335)
			name = "ambient beam"
			icon_state = "temp_4"
		if(260 to 295)
			name = "cool beam"		//temp at which players get notified of their low body temp
			icon_state = "temp_3"
		if(200 to 260)
			name = "cold beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_1
			icon_state = "temp_2"
		if(120 to 260)
			name = "ice beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_2
			icon_state = "temp_1"
		if(-INFINITY to 120)
			name = "freeze beam"	//temp at which mobs start taking COLD_DAMAGE_LEVEL_3
			icon_state = "temp_0"
		else
			name = "temperature beam"//failsafe
			icon_state = "temp_4"

/obj/item/projectile/temp/to_bump(var/atom/A)
	if (!ismob(A) && A.reagents && A.reagents.total_volume)
		A.reagents.chem_temp = temperature
		if(!(A.reagents.skip_flags & SKIP_RXN_CHECK_ON_HEATING))
			A.reagents.handle_reactions()
	..()

/obj/item/projectile/temp/on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(M.flags & INVULNERABLE)
			return 0
		if(istype(M,/mob/living/carbon/human))
			M.bodytemperature -= 2*((temperature-T0C)/(-T0C))
		else
			M.bodytemperature = temperature
		if(temperature > 500)//emagged
			M.adjust_fire_stacks(0.5)
			M.on_fire = 1
			M.update_icon = 1
			playsound(M.loc, 'sound/effects/bamf.ogg', 50, 0)
	return 1

//Simple fireball
/obj/item/projectile/simple_fireball
	name = "fireball"
	icon_state = "fireball"
	animate_movement = 2
	damage = 0
	nodamage = 1
	flag = "bullet"

/obj/item/projectile/simple_fireball/to_bump(atom/A)
	explosion(get_turf(src), -1, -1, 2, 2)
	return qdel(src)

/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(var/atom/target, var/blocked = 0)
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustBrainLoss(20)
		M.hallucination += 20

/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = "energy"
	damage = 15
	damage_type = BRUTE
	flag = "energy"
	fire_sound = 'sound/weapons/Taser.ogg'
	color = "#a7ff96"
	var/low_pressure_bonus = 15 //bonus in pressures below 50kpa
	var/monster_bonus = 0 //bonus against simple_animals (roid mobs) and xenos

/obj/item/projectile/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
		damage += low_pressure_bonus
		color = "#ccffff"// "#ff4444"
	..()

/* wat - N3X
/obj/item/projectile/kinetic/Range()
	range--
	if(range <= 0)
		new /obj/item/effect/kinetic_blast(src.loc)
		qdel(src)
*/

/obj/item/projectile/kinetic/on_hit(var/atom/target, var/blocked = 0)
	if(!loc)
		return
	var/turf/target_turf = get_turf(target)
	//testing("Hit [target.type], on [target_turf.type].")
	if(istype(target_turf, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = target_turf
		if(M.mining_difficulty < MINE_DIFFICULTY_TOUGH)
			M.GetDrilled()
	new /obj/item/effect/kinetic_blast(target_turf)
	..(target,blocked)

/obj/item/projectile/kinetic/to_bump(atom/A as mob|obj|turf|area)
	if(istype(A, /mob/living/simple_animal) || istype(A, /mob/living/carbon/alien))
		damage += monster_bonus
	if(!loc)
		return
	if(A == firer)
		loc = A.loc
		return

	if(src)//Do not add to this if() statement, otherwise the meteor won't delete them

		if(A)
			var/turf/target_turf = get_turf(A)
			//testing("Bumped [A.type], on [target_turf.type].")
			if(istype(target_turf, /turf/unsimulated/mineral))
				var/turf/unsimulated/mineral/M = target_turf
				if(M.mining_difficulty < MINE_DIFFICULTY_TOUGH)
					M.GetDrilled()
				new /obj/item/effect/kinetic_blast(target_turf)
			// Now we bump as a bullet, if the atom is a non-turf.
			if(!isturf(A))
				..(A)
			//qdel(src) // Comment this out if you want to shoot through the asteroid, ERASER-style.
			qdel(src)
			return 1
	else
		//qdel(src)
		qdel(src)
		return 0

/obj/item/projectile/kinetic/shotgun
	low_pressure_bonus = 25

/obj/item/projectile/kinetic/cutter
	monster_bonus = 15

/obj/item/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	plane = ABOVE_HUMAN_PLANE

/obj/item/effect/kinetic_blast/New()
	..()
	spawn(4)
		qdel(src)

/obj/item/projectile/stickybomb
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "stickybomb"
	damage = 0
	var/obj/item/stickybomb/sticky = null


/obj/item/projectile/stickybomb/to_bump(atom/A as mob|obj|turf|area)
	if(bumped)
		return 0
	bumped = 1

	if(A)
		setDensity(FALSE)
		invisibility = 101
		kill_count = 0
		if(isliving(A))
			sticky.stick_to(A)
		else if(loc)
			var/turf/T = get_turf(src)
			sticky.stick_to(T,get_dir(src,A))
		bullet_die()

/obj/item/projectile/stickybomb/bump_original_check()//so players can aim at floors
	if(!bumped)
		if(loc == get_turf(original))
			if(!(original in permutated))
				to_bump(original)

/obj/item/projectile/portalgun
	name = "portal gun shot"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "portalgun"
	damage = 0
	nodamage = 1
	kill_count = 500//enough to cross a ZLevel...twice!
	var/setting = 0

/obj/item/projectile/portalgun/bump_original_check()//so players can aim at floors
	if(!bumped)
		if(loc == get_turf(original))
			if(!(original in permutated))
				to_bump(original)

/obj/item/projectile/portalgun/to_bump(atom/A as mob|obj|turf|area)
	if(bumped)
		return
	bumped = 1

	if(!istype(shot_from,/obj/item/weapon/gun/portalgun))
		bullet_die()
		return

	var/obj/item/weapon/gun/portalgun/P = shot_from

	if(isliving(A))
		forceMove(get_step(loc,dir))

	if(!(locate(/obj/effect/portal) in loc))
		P.open_portal(setting,loc,A,firer)
	bullet_die()


//Fire breath
//Fairly simple projectile that doesn't use any atmos calculations. Intended to be used by simple mobs
/obj/item/projectile/fire_breath
	name = "fiery breath"
	icon_state = null
	damage = 0
	penetration = -1
	phase_type = PROJREACT_MOBS|PROJREACT_BLOB|PROJREACT_OBJS
	bounce_sound = null
	custom_impact = 1
	penetration_message = 0
	grillepasschance = 100

	var/fire_blast_type = /obj/effect/fire_blast

	var/stepped_range = 0
	var/max_range = 9

	var/fire_damage = 10
	var/pressure = ONE_ATMOSPHERE * 4.5
	var/temperature = T0C + 175
	var/fire_duration

/obj/item/projectile/fire_breath/straight
	fire_blast_type = /obj/effect/fire_blast/no_spread

/obj/item/projectile/fire_breath/New(turf/T, var/direction, var/F_Dam, var/P, var/Temp, var/F_Dur)
	..(T,direction)
	if(F_Dam)
		fire_damage = F_Dam
	if(P)
		pressure = P
	if(Temp)
		temperature = Temp
	if(F_Dur)
		fire_duration = F_Dur

/obj/item/projectile/fire_breath/process_step()
	..()

	if(stepped_range <= max_range)
		stepped_range++
	else
		bullet_die()
		return

	var/turf/T = get_turf(src)
	if(!T)
		return

	new fire_blast_type(T, fire_damage, stepped_range, 1, pressure, temperature, fire_duration)

/obj/item/projectile/fire_breath/shuttle_exhaust //don't stand behind rockets
	fire_blast_type = /obj/effect/fire_blast/blue

	temperature = PLASMA_UPPER_TEMPERATURE
	max_range = 9
	fire_damage = 20
	fire_duration = 6 //shorter but hotter

/obj/item/projectile/fire_breath/shuttle_exhaust/horizon
	fire_blast_type = /obj/effect/fire_blast/blue/horizon

/obj/item/projectile/cold
	name = "bolt of cold"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	layer = PROJECTILE_LAYER
	flag = "energy"
	fire_sound = 'sound/weapons/radgun.ogg'

/obj/item/projectile/cold/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob))
		var/mob/M = target
		if(M.flags & INVULNERABLE)
			return 0
		M.bodytemperature = max(M.bodytemperature-5 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
		playsound(M, 'sound/effects/freeze.ogg', 100, 1)
	return 1

/obj/item/projectile/napalm_bomb
	name = "napalm bomb"
	icon_state = "fireball"
	damage = 0
	damage_type = BURN
	nodamage = 1
	layer = PROJECTILE_LAYER
	flag = "bio"
	fire_sound = 'sound/weapons/rocket.ogg'

	projectile_speed = 1.33

	var/fire_damage = 5
	var/pressure = ONE_ATMOSPHERE * 4.5
	var/temperature = T0C + 175
	var/fire_duration = 10

/obj/item/projectile/napalm_bomb/on_hit(var/atom/target, var/blocked = 0)
	new /obj/effect/fire_blast/blue(get_turf(target), fire_damage, 0, 1, pressure, temperature, fire_duration)


/obj/item/projectile/swap
	name = "bolt of swapping"
	icon_state = "sparkblue"
	damage = 0
	nodamage = 1
	fire_sound = 'sound/weapons/osipr_altfire.ogg'

/obj/item/projectile/swap/on_hit(var/atom/target, var/blocked = 0)
	var/turf/T = get_turf(target)
	do_teleport(target, firer.loc)
	do_teleport(firer, T)

/obj/item/projectile/swap/advanced
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSRAILING

/obj/item/projectile/energy/microwaveray
	name = "microwave ray"
	icon_state = "microwaveray"
	damage = 15
	damage_type = BURN
	flag = "energy"
	fire_sound = 'sound/weapons/ray2.ogg'

/obj/item/projectile/energy/microwaveray/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/carbon/human/H = target
		to_chat(H, "<span class='warning'>You are heated by the microwave ray's energy!</span>")
		H.eye_blurry = max(H.eye_blurry, 5)
		H.bodytemperature += 120
	return 0

/obj/item/projectile/energy/scramblerray
	name = "scrambler ray"
	icon_state = "scramblerray"
	flag = "energy"
	nodamage = 1
	fire_sound = 'sound/weapons/ray2.ogg'

/obj/item/projectile/energy/scramblerray/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/carbon/human/H = target
		to_chat(H, "<span class='warning'>The scrambler ray's energy makes you feel lightheaded and sick!</span>")
		H.eye_blurry = max(H.eye_blurry, 5)
		H.adjustBrainLoss(2)
		H.drop_item()
		H.vomit(0,1)
	return 0

/obj/item/projectile/puke
	icon_state = "projectile_puke"

/obj/item/projectile/puke/New()
	..()
	create_reagents(500)
	make_reagents()

/obj/item/projectile/puke/proc/make_reagents()
	var/room_remaining = 500
	var/poly_to_add = rand(100,200)
	reagents.add_reagent(PACID, poly_to_add)
	room_remaining -= poly_to_add
	var/sulph_to_add = rand(100,200)
	reagents.add_reagent(SACID, sulph_to_add)
	room_remaining -= sulph_to_add
	reagents.add_reagent(VOMIT, room_remaining)

/obj/item/projectile/puke/clear/make_reagents()
	return

/obj/item/projectile/puke/on_hit(var/atom/atarget, var/blocked = 0)
	..()
	splash_sub(reagents, atarget, -1)

/obj/item/projectile/puke/process_step()
	..()
	var/turf/simulated/T = get_turf(src)
	if(T) //The first time it runs, it won't work, it'll runtime
		playsound(T, 'sound/effects/splat.ogg', 50, 1)
		T.add_vomit_floor(src, 1, 1, 1)
	sleep(1) //Slow the fuck down, hyperspeed vomit
