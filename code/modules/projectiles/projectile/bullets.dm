/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	phase_type = PROJREACT_WINDOWS
	penetration = 5 //bullets can now by default move through up to 5 windows, or 2 reinforced windows, or 1 plasma window. (reinforced plasma windows still have enough dampening to completely block them)
	flag = "bullet"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	var/embed = 1
	var/embed_message = TRUE

/obj/item/projectile/bullet/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/L = target
		shake_camera(L, 3, 2)
		return 1
	return 0

/obj/item/projectile/bullet/dart
	name = "shotgun dart"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/bullet/shrapnel

	name = "shrapnel"
	damage = 45
	damage_type = BRUTE
	weaken = 1
	stun = 3

/obj/item/projectile/bullet/shrapnel/New()
	..()
	kill_count = rand(6,10)



/obj/item/projectile/bullet/shrapnel/small

	name = "small shrapnel"
	damage = 25

/obj/item/projectile/bullet/shrapnel/small/plasma

	name = "small plasma shrapnel"
	damage_type = TOX
	color = "#BF5FFF"
	damage = 35


/obj/item/projectile/bullet/weakbullet
	name = "weak bullet"
	icon_state = "bbshell"
	damage = 10
	stun = 5
	weaken = 5
	embed = 0
/obj/item/projectile/bullet/weakbullet/booze
	name = "booze bullet"
	on_hit(var/atom/target, var/blocked = 0)
		if(..(target, blocked))
			var/mob/living/M = target
			M.dizziness += 20
			M:slurring += 20
			M.confused += 20
			M.eye_blurry += 20
			M.drowsyness += 20
			if(M.dizziness <= 150)
				M.Dizzy(150)
				M.dizziness = 150
			for(var/datum/reagent/ethanol/A in M.reagents.reagent_list)
				M.paralysis += 2
				M.dizziness += 10
				M:slurring += 10
				M.confused += 10
				M.eye_blurry += 10
				M.drowsyness += 10
				A.volume += 5 //Because we can
				M.dizziness += 10
			return 1
		return 0

/obj/item/projectile/bullet/midbullet
	damage = 20
	stun = 5
	weaken = 5
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'

/obj/item/projectile/bullet/midbullet/lawgiver
	damage = 10
	stun = 0
	weaken = 0
	superspeed = 1

/obj/item/projectile/bullet/midbullet/assault
	damage = 20
	stun = 0
	weaken = 0

/obj/item/projectile/bullet/midbullet2
	damage = 25
	stun = 0
	weaken = 0

/obj/item/projectile/bullet/midbullet/bouncebullet
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS
	bounces = -1

/obj/item/projectile/bullet/midbullet/bouncebullet/lawgiver
	damage = 30
	stun = 0
	weaken = 0

/obj/item/projectile/bullet/fourtyfive
	damage = 35 //buffed up for antag usage
	drowsy = 2
	agony = 2
	penetration = 3

/obj/item/projectile/bullet/fourtyfive/practice
	damage = 3
	drowsy = 1
	agony = 1
	embed = 0
	penetration = 0

/obj/item/projectile/bullet/fourtyfive/rubber
	damage = 10
	stun = 5
	weaken = 5
	penetration = 1

/obj/item/projectile/bullet/auto380 //new sec pistol ammo, reverse name because lol compiler
	damage = 15 
	drowsy = 1
	agony = 1
	penetration = 2

/obj/item/projectile/bullet/auto380/practice
	damage = 2
	drowsy = 0
	agony = 0
	embed = 0
	penetration = 0

/obj/item/projectile/bullet/auto380/rubber
	damage = 8
	stun = 5
	weaken = 5
	embed = 0
	penetration = 0
	
/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "CO2 bullet"
	damage = 20
	damage_type = OXY


/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 40
	damage_type = TOX


/obj/item/projectile/bullet/burstbullet//I think this one needs something for the on hit
	name = "exploding bullet"
	damage = 20


/obj/item/projectile/bullet/stunshot
	name = "stunshot"
	icon_state = "sshell"
	damage = 5
	stun = 10
	weaken = 10
	stutter = 10

/obj/item/projectile/bullet/a762
	damage = 25

#define SPUR_FULL_POWER 4
#define SPUR_HIGH_POWER 3
#define SPUR_MEDIUM_POWER 2
#define SPUR_LOW_POWER 1
#define SPUR_NO_POWER 0

/obj/item/projectile/spur
	name = "spur bullet"
	damage_type = BRUTE
	flag = "bullet"
	kill_count = 100
	layer = PROJECTILE_LAYER
	damage = 40
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "spur_high"
	animate_movement = 2
	custom_impact = 1
	linear_movement = 0
	fire_sound = 'sound/weapons/spur_high.ogg'

/obj/item/projectile/spur/OnFired()
	..()
	var/obj/item/weapon/gun/energy/polarstar/spur/quote = shot_from
	if(!quote || !istype(quote))
		return
	switch(quote.firelevel)
		if(SPUR_FULL_POWER,SPUR_HIGH_POWER)
			icon_state = "spur_high"
			damage = 40
			kill_count = 20
		if(SPUR_MEDIUM_POWER)
			icon_state = "spur_medium"
			damage = 30
			kill_count = 13
		if(SPUR_LOW_POWER,SPUR_NO_POWER)
			icon_state = "spur_low"
			damage = 20
			kill_count = 7

/obj/item/projectile/spur/polarstar
	name = "polar star bullet"
	damage = 20

/obj/item/projectile/spur/polarstar/OnFired()
	..()
	var/obj/item/weapon/gun/energy/polarstar/quote = shot_from
	if(!quote || !istype(quote))
		return
	switch(quote.firelevel)
		if(SPUR_FULL_POWER,SPUR_HIGH_POWER)
			icon_state = "spur_high"
			damage = 20
			kill_count = 20
		if(SPUR_MEDIUM_POWER)
			icon_state = "spur_medium"
			damage = 15
			kill_count = 13
		if(SPUR_LOW_POWER,SPUR_NO_POWER)
			icon_state = "spur_low"
			damage = 10
			kill_count = 7

/obj/item/projectile/spur/to_bump(atom/A as mob|obj|turf|area)

	if(loc)
		var/turf/T = loc
		var/impact_icon = null
		var/impact_sound = null
		var/PixelX = 0
		var/PixelY = 0

		switch(get_dir(src,A))
			if(NORTH)
				PixelY = 16
			if(SOUTH)
				PixelY = -16
			if(EAST)
				PixelX = 16
			if(WEST)
				PixelX = -16
		if(ismob(A))
			impact_icon = "spur_3"
			impact_sound = 'sound/weapons/spur_hitmob.ogg'
		else
			impact_icon = "spur_1"
			impact_sound = 'sound/weapons/spur_hitwall.ogg'

		var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,impact_icon)
		impact.pixel_x = PixelX
		impact.pixel_y = PixelY
		impact.layer = PROJECTILE_LAYER
		T.overlays += impact
		spawn(3)
			T.overlays -= impact
		playsound(loc, impact_sound, 30, 1)


	if(istype(A, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = A
		M.GetDrilled()
	if(istype(A, /obj/structure/boulder))
		returnToPool(A)

	return ..()

/obj/item/projectile/spur/process_step()
	if(kill_count <= 0)
		if(loc)
			var/turf/T = loc
			var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,"spur_2")
			impact.layer = PROJECTILE_LAYER
			T.overlays += impact
			spawn(3)
				T.overlays -= impact
	..()

#undef SPUR_FULL_POWER
#undef SPUR_HIGH_POWER
#undef SPUR_MEDIUM_POWER
#undef SPUR_LOW_POWER
#undef SPUR_NO_POWER


/obj/item/projectile/bullet/gatling
	name = "gatling bullet"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "minigun"
	damage = 30
	fire_sound = 'sound/weapons/gatling_fire.ogg'

/obj/item/projectile/bullet/osipr
	name = "\improper OSIPR bullet"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "osipr"
	damage = 50
	stun = 2
	weaken = 2
	destroy = 1
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS
	bounces = 1
	fire_sound = 'sound/weapons/osipr_fire.ogg'

/obj/item/projectile/bullet/hecate
	name = "high penetration bullet"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "hecate"
	damage = 101//you're going to crit, lad
	kill_count = 255//oh boy, we're crossing through the entire Z level!
	stun = 5
	weaken = 5
	stutter = 5
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration = 20//can hit 3 mobs at once, or go through a wall and hit 2 more mobs, or go through an rwall/blast door and hit 1 mob
	superspeed = 1
	fire_sound = 'sound/weapons/hecate_fire.ogg'

/obj/item/projectile/bullet/hecate/OnFired()
	..()
	for (var/mob/M in player_list)
		if(M && M.client)
			var/turf/M_turf = get_turf(M)
			if(M_turf && (M_turf.z == starting.z))
				M.playsound_local(starting, 'sound/weapons/hecate_fire_far.ogg', 25, 1)
	for (var/mob/living/carbon/human/H in range(src,1))
		if(!H.earprot())
			H.Knockdown(2)
			H.Stun(2)
			H.ear_damage += rand(3, 5)
			H.ear_deaf = max(H.ear_deaf,15)
			to_chat(H, "<span class='warning'>Your ears ring!</span>")

/obj/item/projectile/bullet/a762x55
	name = "a762x55 round"
	damage = 65
	stun = 5
	weaken = 5
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS
	penetration = 10

/obj/item/projectile/bullet/beegun
	name = "bee"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "beegun"
	damage = 5
	damage_type = TOX
	flag = "bio"

/obj/item/projectile/bullet/beegun/OnFired()
	..()
	playsound(starting, 'sound/effects/bees.ogg', 75, 1)

/obj/item/projectile/bullet/beegun/to_bump(atom/A as mob|obj|turf|area)
	if (!A)
		return 0
	if((A == firer) && !reflected)
		loc = A.loc
		return 0
	if(bumped)
		return 0
	bumped = 1

	var/turf/T = get_turf(src)
	var/mob/living/simple_animal/bee/BEE = new(T)
	BEE.strength = 1
	BEE.toxic = 5
	BEE.mut = 2
	BEE.feral = 25
	BEE.icon_state = "bees1-feral"

	if(istype(A,/mob/living))
		var/mob/living/M = A
		visible_message("<span class='warning'>\the [M.name] is hit by \the [src.name] in the [parse_zone(def_zone)]!</span>")
		M.bullet_act(src, def_zone)
		admin_warn(M)
		BEE.forceMove(M.loc)
		BEE.target = M
	else
		BEE.newTarget()
	bullet_die()

/obj/item/projectile/bullet/APS //Armor-piercing sabot round. Metal rods become this when fired from a railgun.
	name = "armor-piercing sabot round"
	icon_state = "APS"
	damage = 10 //Default damage, actual damage is determined per-shot in railgun.dm
	kill_count = 20 //This will be increased when the round is fired, based on the strength of the shot
	stun = 0
	weaken = 0
	stutter = 0
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration = 0 //By default. Higher-power shots will have penetration.

/obj/item/projectile/bullet/APS/on_hit(var/atom/atarget, var/blocked = 0)
	if(istype(atarget, /mob/living) && damage == 200)
		var/mob/living/M = atarget
		M.gib()
	else
		..()

/obj/item/projectile/bullet/APS/OnFired()
	..()
	if(damage >= 100)
		superspeed = 1
		super_speed = 1
		for (var/mob/M in player_list)
			if(M && M.client)
				var/turf/M_turf = get_turf(M)
				if(M_turf && (M_turf.z == starting.z))
					M.playsound_local(starting, 'sound/weapons/hecate_fire_far.ogg', 25, 1)

/obj/item/projectile/bullet/APS/OnDeath()
	var/turf/T = get_turf(src)
	new /obj/item/stack/rods(T)

/obj/item/projectile/bullet/stinger
	name = "alien stinger"
	damage = 5
	damage_type = TOX
	flag = "bio"
	fire_sound = 'sound/weapons/hivehand.ogg'

/obj/item/projectile/bullet/stinger/OnFired()
	var/choice = rand(1,4)
	switch(choice)
		if(1)
			stutter = 2
		if(2)
			eyeblur = 2
		if(3)
			agony = 2
		if(4)
			jittery = 2
	..()

/obj/item/projectile/bullet/vial
	name = "vial"
	icon_state = "vial"
	damage = 0
	penetration = 0
	embed = 0
	var/vial = null
	var/user = null
	var/hit_mob = 0

/obj/item/projectile/bullet/vial/Destroy()
	if(vial)
		qdel(vial)
		vial = null
	if(user)
		user = null
	..()

/obj/item/projectile/bullet/vial/to_bump(atom/A as mob|obj|turf|area) //to allow vials to splash onto walls
	if(!A)
		return
	if(vial)
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/V = vial
		if(!V.is_open_container())
			V.flags |= OPENCONTAINER
		if(istype(A, /turf/simulated/wall))
			splash_sub(V.reagents, A, V.reagents.total_volume)
			bullet_die()
			return 1
	..()

/obj/item/projectile/bullet/vial/on_hit(var/atom/atarget, var/blocked = 0)
	..()
	if(vial)
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/V = vial
		if(!V.is_open_container())
			V.flags |= OPENCONTAINER
		if(!V.is_empty())
			hit_mob = 1
			atarget.visible_message("<span class='warning'>\The [V] shatters, dousing [atarget] in its contents!</span>",
								"<span class='warning'>\The [V] shatters, dousing you in its contents!</span>")

		splash_sub(V.reagents, atarget, V.reagents.total_volume)

		qdel(V)
		vial = null
		user = null

/obj/item/projectile/bullet/vial/OnDeath()
	if(!hit_mob)
		src.visible_message("<span class='warning'>The vial shatters!</span>")
	playsound(get_turf(src), "shatter", 20, 1)

/obj/item/projectile/bullet/blastwave
	name = "blast wave"
	icon_state = null
	damage = 0
	penetration = -1
	embed = 0
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration_message = 0
	var/heavy_damage_range = 0
	var/medium_damage_range = 0
	var/light_damage_range = 0
	fire_sound = 'sound/effects/Explosion1.ogg'

/obj/item/projectile/bullet/blastwave/New()
	..()
	var/sound = rand(1,6)
	switch(sound)
		if(1)
			fire_sound = 'sound/effects/Explosion1.ogg'
		if(2)
			fire_sound = 'sound/effects/Explosion2.ogg'
		if(3)
			fire_sound = 'sound/effects/Explosion3.ogg'
		if(4)
			fire_sound = 'sound/effects/Explosion4.ogg'
		if(5)
			fire_sound = 'sound/effects/Explosion5.ogg'
		if(6)
			fire_sound = 'sound/effects/Explosion6.ogg'

/obj/item/projectile/bullet/blastwave/OnFired()
	..()
	if(!heavy_damage_range || !medium_damage_range || !light_damage_range)
		bullet_die()
		return

/obj/item/projectile/bullet/blastwave/process_step()
	..()
	var/turf/T = get_turf(src)
	if(light_damage_range)
		if(medium_damage_range)
			if(heavy_damage_range)
				for(var/atom/movable/A in T.contents)
					if(!istype(A, /obj/item/weapon/organ/head))
						A.ex_act(1)
				T.ex_act(1)
				heavy_damage_range -= 1
			else
				for(var/atom/movable/A in T.contents)
					A.ex_act(2)
				T.ex_act(2)
				medium_damage_range -= 1
		else
			for(var/atom/movable/A in T.contents)
				A.ex_act(3)
			T.ex_act(3)
			light_damage_range -= 1
	else
		bullet_die()

/obj/item/projectile/bullet/blastwave/ex_act()
	return

/obj/item/projectile/bullet/fire_plume
	name = "fire plume"
	icon_state = null
	damage = 0
	penetration = -1
	embed = 0
	phase_type = PROJREACT_MOBS|PROJREACT_BLOB|PROJREACT_OBJS
	bounce_sound = null
	custom_impact = 1
	penetration_message = 0
	var/has_O2_in_mix = 0
	var/datum/gas_mixture/gas_jet = null
	var/max_range = 10
	var/stepped_range = 0
	var/burn_strength = 0
	var/has_reacted = 0
	var/burn_damage = 0
	var/jet_pressure = 0
	var/original_total_moles = 0

/obj/item/projectile/bullet/fire_plume/OnFired()
	..()
	if(!gas_jet)
		bullet_die()
	else
		original_total_moles = gas_jet.total_moles()

/obj/item/projectile/bullet/fire_plume/proc/create_puff()
	if(gas_jet)
		if(gas_jet.total_moles())
			var/total_moles = gas_jet.total_moles()
			var/o2_concentration = gas_jet.oxygen/total_moles
			var/n2_concentration = gas_jet.nitrogen/total_moles
			var/co2_concentration = gas_jet.carbon_dioxide/total_moles
			var/plasma_concentration = gas_jet.toxins/total_moles
			var/n2o_concentration = null

			var/datum/gas_mixture/gas_dispersal = gas_jet.remove(original_total_moles/10)

			if(gas_jet.trace_gases.len)
				for(var/datum/gas/G in gas_jet.trace_gases)
					if(istype(G, /datum/gas/sleeping_agent))
						n2o_concentration = G.moles/total_moles

			var/gas_type = null

			if(o2_concentration > 0.5)
				gas_type = "oxygen"
			if(n2_concentration > 0.5)
				gas_type = "nitrogen"
			if(co2_concentration > 0.5)
				gas_type = "CO2"
			if(plasma_concentration > 0.5)
				gas_type = "plasma"
			if(n2o_concentration && n2o_concentration > 0.5)
				gas_type = "N2O"

			new /obj/effect/gas_puff(get_turf(src.loc), gas_dispersal, gas_type)

/obj/item/projectile/bullet/fire_plume/proc/calculate_burn_strength(var/turf/T = null)
	if(!gas_jet)
		return

	if(gas_jet.total_moles())
		var/jet_total_moles = gas_jet.total_moles()
		var/toxin_concentration = gas_jet.toxins/jet_total_moles
		if(!(toxin_concentration > 0.01))
			create_puff()
			return
	else
		return

	if(!has_O2_in_mix && T)
		var/turf/location = get_turf(src)
		var/datum/gas_mixture/turf_gases = location.return_air()
		var/turf_total_moles = turf_gases.total_moles()
		if(turf_total_moles)
			var/o2_concentration = turf_gases.oxygen/turf_total_moles
			if(!(o2_concentration > 0.01))
				create_puff()
				return
		else
			create_puff()
			return
		var/datum/gas_mixture/temp_gas_jet = new()
		temp_gas_jet.copy_from(gas_jet)
		temp_gas_jet.merge(turf_gases)
		if(temp_gas_jet.temperature < 373.15)
			temp_gas_jet.temperature = 383.15
			temp_gas_jet.update_values()
		for(var/i = 1; i <= 20; i++)
			temp_gas_jet.react()
		burn_strength = temp_gas_jet.temperature

	else
		if(!has_reacted)
			if(gas_jet.temperature < 373.15)
				gas_jet.temperature = 383.15
				gas_jet.update_values()
			for(var/i = 1; i <= 20; i++)
				gas_jet.react()
			has_reacted = 1
		burn_strength = gas_jet.temperature

	var/initial_burn_damage = burn_strength/100
	burn_damage = ((((-(10 * (0.9**((initial_burn_damage/10) * 5))) + 10) * 0.4) * 20)/5) //Exponential decay function 20*(y=(-(10*(0.9^(x/10)))+10)*0.4)
	//assuming the target stays in the fire for its duration, the total burn damage will be roughly 5 * burn_damage
	new /obj/effect/fire_blast(get_turf(src.loc), burn_damage, stepped_range, 1, jet_pressure, burn_strength)

/obj/item/projectile/bullet/fire_plume/process_step()
	..()
	if(stepped_range <= max_range)
		stepped_range++
	else
		bullet_die()
		return
	var/turf/T = get_turf(src)
	for(var/obj/effect/E in T)
		if(istype(E, /obj/effect/blob))
			stepped_range += 3
			if(istype(E, /obj/effect/blob/shield)) //The fire can't penetrate through dense blob shields
				calculate_burn_strength(get_turf(src))
				bullet_die()
				return
	calculate_burn_strength(get_turf(src))

/obj/item/projectile/bullet/fire_plume/ex_act()
	return

/obj/item/projectile/bullet/mahoganut
	name = "mahogany nut"
	icon_state = "nut"
	damage = 30
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS
	bounces = 1
	fire_sound = 'sound/weapons/gunshot_1.ogg'
	bounce_sound = null
	projectile_slowdown = 0.5
	kill_count = 100
	embed = 0
	rotate = 0

/obj/item/projectile/bullet/leaf
	name = "leaf"
	icon_state = "leaf"
	damage = 10
	fire_sound = null
	penetration = 0
	embed = 0
	rotate = 0

/obj/item/projectile/bullet/liquid_blob
	name = "blob of liquid"
	icon_state = "liquid_blob"
	damage = 0
	penetration = 0
	embed = 0
	flags = FPRINT | NOREACT
	custom_impact = 1
	rotate = 0
	var/hard = 0

/obj/item/projectile/bullet/liquid_blob/New(atom/T, var/hardness = null)
	..(T)
	hard = hardness
	if(hard)
		damage = 30
		create_reagents(10)
	else
		create_reagents(50)

/obj/item/projectile/bullet/liquid_blob/OnFired()
	src.icon += mix_color_from_reagents(reagents.reagent_list)
	src.alpha = mix_alpha_from_reagents(reagents.reagent_list)
	..()

/obj/item/projectile/bullet/liquid_blob/to_bump(atom/A as mob|obj|turf|area)
	if(!A)
		return
	..()
	if(reagents.total_volume)
		for(var/datum/reagent/R in reagents.reagent_list)
			reagents.add_reagent(R.id, reagents.get_reagent_amount(R.id))
		if(istype(A, /mob))
			if(hard)
				var/splash_verb = pick("dousing","completely soaking","drenching","splashing")
				A.visible_message("<span class='warning'>\The [src] smashes into [A], [splash_verb] \him!</span>",
										"<span class='warning'>\The [src] smashes into you, [splash_verb] you!</span>")
			else
				var/splash_verb = pick("douses","completely soaks","drenches","splashes")
				A.visible_message("<span class='warning'>\The [src] [splash_verb] [A]!</span>",
										"<span class='warning'>\The [src] [splash_verb] you!</span>")
			splash_sub(reagents, get_turf(A), reagents.total_volume/2)
		else
			splash_sub(reagents, get_turf(src), reagents.total_volume/2)
		splash_sub(reagents, A, reagents.total_volume)
		return 1

/obj/item/projectile/bullet/liquid_blob/OnDeath()
	if(get_turf(src))
		playsound(get_turf(src), 'sound/effects/slosh.ogg', 20, 1)

/obj/item/projectile/bullet/buckshot
	name = "buckshot pellet"
	icon_state = "buckshot"
	damage = 10
	penetration = 0
	rotate = 0
	var/total_amount_to_fire = 9
	var/type_to_fire = /obj/item/projectile/bullet/buckshot
	var/is_child = 0

/obj/item/projectile/bullet/buckshot/New(atom/T, var/C = 0)
	..(T)
	is_child = C

/obj/item/projectile/bullet/buckshot/proc/get_radius_turfs(turf/T)
	return orange(T,1)

/obj/item/projectile/bullet/buckshot/OnFired()
	if(!is_child)
		var/list/turf/possible_turfs = list()
		for(var/turf/T in get_radius_turfs(original))
			possible_turfs += T
		for(var/I = 1; I <=total_amount_to_fire-1; I++)
			var/obj/item/projectile/bullet/buckshot/B = new type_to_fire(src.loc, 1)
			var/turf/targloc = pick(possible_turfs)
			B.forceMove(get_turf(src))
			B.launch_at(targloc,from = shot_from)
	..()

/obj/item/projectile/bullet/invisible
	name = "invisible bullet"
	icon_state = null
	damage = 25
	fire_sound = null

/obj/item/projectile/bullet/invisible/on_hit(var/atom/target, var/blocked = 0) //silence the target for a few seconds on hit
	if (..(target, blocked))
		var/mob/living/L = target
		if(!L.silent || (L.silent && L.silent < 5))
			L.silent = 5
		return 1
	return 0

/obj/item/projectile/bullet/sabonana
	name = "armor-piercing discarding sabonana"
	icon_state = "sabonana_peel"
	damage = 30
	penetration = 10
	var/peel_drop_chance = 4
	var/peel_dropped = FALSE
	fire_sound = 'sound/misc/slip.ogg'

/obj/item/projectile/bullet/sabonana/process_step()
	..()
	if(!peel_dropped)
		if(prob(peel_drop_chance))
			return drop_peel()
		peel_drop_chance *= 2

/obj/item/projectile/bullet/sabonana/proc/drop_peel()
	new /obj/item/weapon/bananapeel(get_turf(src))
	icon_state = "sabonana"
	damage *= 2
	peel_dropped = TRUE

/obj/item/projectile/bullet/buckshot/bullet_storm
	name = "tiny pellet"
	total_amount_to_fire = 100
	type_to_fire = /obj/item/projectile/bullet/buckshot/bullet_storm
	custom_impact = 1
	embed_message = FALSE

/obj/item/projectile/bullet/buckshot/bullet_storm/get_radius_turfs(turf/T)
	return circlerangeturfs(original,5)
