
//malfunctioning combat drones
/mob/living/simple_animal/hostile/retaliate/malf_drone
	name = "Combat Drone"
	desc = "An automated combat drone armed with state of the art weaponry and shielding."
	icon_state = "NT_drone"
	icon_living = "NT_drone"
	icon_dead = "NT_drone"
	ranged = 1
	rapid = 1
	speak_chance = 5
	turns_per_move = 3
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	melee_damage_lower = 10
	melee_damage_upper = 12
	attacktext = "fires point-blank on"
	melee_damage_type = BURN
	speak = list("ALERT.","Hostile-ile-ile entities dee-twhoooo-wected.","Threat parameterszzzz- szzet.","Bring sub-sub-sub-systems uuuup to combat alert alpha-a-a.")
	emote_see = list("beeps menacingly","whirrs threateningly","scans its immediate vicinity")
	a_intent = I_HURT
	stop_automated_movement_when_pulled = 0
	health = 300
	maxHealth = 300
	speed = 9
	projectiletype = /obj/item/projectile/beam/drone
	projectilesound = 'sound/weapons/laser3.ogg'
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS
	minimum_distance = 3
	retreat_distance = 2
	can_butcher = 0
	meat_type = null

	flying = 1
	mob_property_flags = MOB_ROBOTIC

	var/datum/effect/effect/system/trail/ion_trail
	var/hostile_time = 0

	//the drone randomly switches between hostile/retaliation only states because it's malfunctioning
	//hostile
	//0 - retaliate, only attack enemies that attack it
	//1 - hostile, attack everything that comes near

	var/turf/patrol_target
	var/explode_chance = 1
	var/disabled = 0
	var/exploding = 0

	//Drones aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	var/has_loot = 1
	faction = "malf_drone"

	var/datum/event/rogue_drone/from_event = null
	var/image/shield_overlay
	var/image/light_overlay

/mob/living/simple_animal/hostile/retaliate/malf_drone/New()
	..()
	if(prob(5))
		projectiletype = /obj/item/projectile/beam/pulse/drone
		projectilesound = 'sound/weapons/pulse2.ogg'
	ion_trail = new
	ion_trail.set_up(src)
	ion_trail.start()

/mob/living/simple_animal/hostile/retaliate/malf_drone/examine(mob/user)
	..()
	if(disabled)
		to_chat(user, "<span class = 'notice'>It seems inactive.</span>")
	if(exploding)
		to_chat(user, "<span class = 'warning'>It is sparking and is beginning to glow under its plating.</span>")

/mob/living/simple_animal/hostile/retaliate/malf_drone/update_icon()
	overlays.Cut()
	if(disabled > 0)
		icon_state = icon_dead
		shield_overlay = null
		light_overlay = null
	else
		icon_state = icon_living
		switch(health/maxHealth)
			if(0.9 to INFINITY)
				shield_overlay = image('icons/mob/mob.dmi', src, "energy_shield_full", ABOVE_LIGHTING_LAYER)
				light_overlay = image('icons/mob/mob.dmi', src, "[icon_living]_light", ABOVE_LIGHTING_LAYER)
			if(0.7 to 0.9)
				shield_overlay = image('icons/mob/mob.dmi', src, "energy_shield_half", ABOVE_LIGHTING_LAYER)
				light_overlay = image('icons/mob/mob.dmi', src, "[icon_living]_light", ABOVE_LIGHTING_LAYER)
			if(0.5 to 0.7)
				shield_overlay = image('icons/mob/mob.dmi', src, "energy_shield_partial", ABOVE_LIGHTING_LAYER)
				light_overlay = image('icons/mob/mob.dmi', src, "[icon_living]_light", ABOVE_LIGHTING_LAYER)
			if(0.3 to 0.5)
				shield_overlay = null
				light_overlay = image('icons/mob/mob.dmi', src, "[icon_living]_light", ABOVE_LIGHTING_LAYER)
			else
				icon_state = icon_dead
				shield_overlay = null
				light_overlay = null
	if(shield_overlay)
		shield_overlay.plane = LIGHTING_PLANE
		overlays.Add(shield_overlay)
	if(light_overlay)
		light_overlay.plane = LIGHTING_PLANE
		overlays.Add(light_overlay)

/mob/living/simple_animal/hostile/retaliate/malf_drone/Process_Spacemove(var/check_drift = 0)
	return 1

//self repair systems have a chance to bring the drone back to life
/mob/living/simple_animal/hostile/retaliate/malf_drone/Life()
	if(timestopped)
		return 0 //under effects of time magick

	//emps and lots of damage can temporarily shut us down
	if(disabled > 0)
		stat = UNCONSCIOUS
		update_icon()
		disabled--
		wander = 0
		speak_chance = 0
		LoseTarget()
	else
		update_icon()
		stat = CONSCIOUS
		wander = 1
		speak_chance = 5

	//repair a bit of damage
	if(health != maxHealth && prob(3))
		src.visible_message("<span class='warning'>  [bicon(src)] [src] shudders and shakes as some of it's damaged systems come back online.</span>")
		spark(src)
		health += rand(25,100)

	//spark for no reason
	if(prob(5))
		spark(src)

	//sometimes our targetting sensors malfunction, and we attack anyone nearby
	if(prob(disabled ? 0 : 1) && hostile == 0)
		src.visible_message("<span class='warning'> [bicon(src)] [src] suddenly lights up, and additional targeting vanes slide into place.</span>")
		hostile = 1
		hostile_time = rand(20,35)
	else if(hostile == 1)
		hostile_time--
		if(hostile_time == 0)
			hostile = 0
			src.visible_message("<span class='notice'> [bicon(src)] [src] retracts several targeting vanes, and dulls it's running lights.</span>")
			LoseTarget()

	if(health / maxHealth > 0.9)
		explode_chance = 0
	else if(health / maxHealth > 0.7)
		explode_chance = 0
	else if(health / maxHealth > 0.5)
		explode_chance = 0.5
	else if(health / maxHealth > 0.3)
		explode_chance = 5
	else if(health > 0)
		exploding = 0
		if(!disabled && prob(30))
			if(prob(50))
				src.visible_message("<span class='notice'> [bicon(src)] [src] suddenly shuts down!</span>")
			else
				src.visible_message("<span class='warning'> [bicon(src)] [src] suddenly lies still and quiet.")
			disabled = rand(20, 40)
			walk(src,0)

	if(exploding && prob(20))
		if(prob(50))
			src.visible_message("<span class='warning'> [bicon(src)] [src] begins to spark and shake violenty!</span>")
		else
			src.visible_message("<span class='warning'> [bicon(src)] [src] sparks and shakes like it's about to explode!</span>")
		spark(src)

	if(!exploding && !disabled && prob(explode_chance))
		exploding = 1
		stat = UNCONSCIOUS
		wander = 1
		walk(src,0)
		spawn(rand(50,80))
			if(!disabled && exploding)
				explosion(get_turf(src), 0, 1, 4, 7)
				//proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1)
	return ..()

//ion rifle!
/mob/living/simple_animal/hostile/retaliate/malf_drone/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	health -= rand(3,15) * (severity + 1)
	disabled = rand(5, 20)
	hostile = 0
	hostile_time = 0
	walk(src,0)

/mob/living/simple_animal/hostile/retaliate/malf_drone/death(var/gibbed = FALSE)
	src.visible_message("<span class='notice'> [bicon(src)] [src] suddenly breaks apart.</span>")
	..(TRUE)
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/malf_drone/Destroy()
	//some random debris left behind
	if(from_event)
		from_event.drones_list -= src
		from_event = null
	if(has_loot)
		spark(src)
		var/obj/O

		//shards
		O = getFromPool(/obj/item/weapon/shard, loc)
		step_to(O, get_turf(pick(view(7, src))))
		if(prob(75))
			O = getFromPool(/obj/item/weapon/shard, loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(50))
			O = getFromPool(/obj/item/weapon/shard, loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(25))
			O = getFromPool(/obj/item/weapon/shard, loc)
			step_to(O, get_turf(pick(view(7, src))))

		//rods
		O = new /obj/item/stack/rods(src.loc)
		step_to(O, get_turf(pick(view(7, src))))
		if(prob(75))
			O = new /obj/item/stack/rods(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(50))
			O = new /obj/item/stack/rods(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(25))
			O = new /obj/item/stack/rods(src.loc)
			step_to(O, get_turf(pick(view(7, src))))

		//plasteel
		O = new /obj/item/stack/sheet/plasteel(src.loc)
		step_to(O, get_turf(pick(view(7, src))))
		if(prob(75))
			O = new /obj/item/stack/sheet/plasteel(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(50))
			O = new /obj/item/stack/sheet/plasteel(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(25))
			O = new /obj/item/stack/sheet/plasteel(src.loc)
			step_to(O, get_turf(pick(view(7, src))))

		//also drop dummy circuit boards deconstructable for research (loot)
		var/obj/item/weapon/circuitboard/C

		//spawn 1-4 boards of a random type
		var/spawnees = 0
		var/num_boards = rand(1,4)
		var/list/options = list(1,2,4,8,16,32,64,128,256, 512)
		for(var/i=0, i<num_boards, i++)
			var/chosen = pick(options)
			options.Remove(options.Find(chosen))
			spawnees |= chosen

		if(spawnees & 1)
			C = new(src.loc)
			C.name = "Drone CPU motherboard"
			C.origin_tech = "programming=[rand(3,6)]"

		if(spawnees & 2)
			C = new(src.loc)
			C.name = "Drone neural interface"
			C.origin_tech = "biotech=[rand(3,6)]"

		if(spawnees & 4)
			C = new(src.loc)
			C.name = "Drone suspension processor"
			C.origin_tech = "magnets=[rand(3,6)]"

		if(spawnees & 8)
			C = new(src.loc)
			C.name = "Drone shielding controller"
			C.origin_tech = "bluespace=[rand(3,6)]"

		if(spawnees & 16)
			C = new(src.loc)
			C.name = "Drone power capacitor"
			C.origin_tech = "powerstorage=[rand(3,6)]"

		if(spawnees & 32)
			C = new(src.loc)
			C.name = "Drone hull reinforcer"
			C.origin_tech = "materials=[rand(3,6)]"

		if(spawnees & 64)
			C = new(src.loc)
			C.name = "Drone auto-repair system"
			C.origin_tech = "engineering=[rand(3,6)]"

		if(spawnees & 128)
			C = new(src.loc)
			C.name = "Drone plasma overcharge counter"
			C.origin_tech = "plasmatech=[rand(3,6)]"

		if(spawnees & 256)
			C = new(src.loc)
			C.name = "Drone targetting circuitboard"
			C.origin_tech = "combat=[rand(3,6)]"

		if(spawnees & 512)
			C = new(src.loc)
			C.name = "Corrupted drone morality core"
			C.origin_tech = "illegal=[rand(3,6)]"

	..()

/obj/item/projectile/beam/drone
	damage = 10

/obj/item/projectile/beam/pulse/drone
	damage = 7
