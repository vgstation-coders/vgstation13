/obj/item/projectile/rocket
	name = "rocket"
	icon_state = "rpground"
	damage = 50
	stun = 5
	weaken = 5
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	var/embed = 1
	var/picked_up_speed = 0.66 //This is basically projectile speed, so
	fire_sound = 'sound/weapons/rocket.ogg'
	var/exdev 	= 1 //RPGs pack a serious punch and will cause massive structural damage in your average room,
	var/exheavy = 3 //but won't punch through reinforced walls
	var/exlight = 5
	var/exflash = 8
	var/emheavy = -1
	var/emlight = -1

/obj/item/projectile/rocket/process_step()
	if(src.loc)
		if(picked_up_speed > 1)
			picked_up_speed--
		if(dist_x > dist_y)
			bresenham_step(dist_x,dist_y,dx,dy)
		else
			bresenham_step(dist_y,dist_x,dy,dx)
		if(linear_movement)
			update_pixel()
			pixel_x = PixelX
			pixel_y = PixelY
		sleep(picked_up_speed)

// -- Random critz
/obj/item/projectile/rocket/become_crit()
	exdev += 2
	exheavy += 2
	exlight += 2
	..()

/obj/item/projectile/rocket/calculate_falloff(var/atom/impact)
	var/dist_falloff = get_dist(firer, impact) - 5
	var/total_falloff = clamp((1 - dist_falloff/15), 0.5, 1) // No rampup + more distance for firing
	return total_falloff

/obj/item/projectile/rocket/do_falloff(var/total_falloff)
	. = ..()
	exdev = Floor(total_falloff*exdev)
	exheavy = Floor(total_falloff*exheavy)
	exlight = Floor(total_falloff*exlight)
	exflash = Floor(total_falloff*exflash)
	emheavy = Floor(total_falloff*emheavy)
	emlight = Floor(total_falloff*emlight)

/obj/item/projectile/rocket/to_bump(var/atom/A)
	var/A_turf = get_turf(A)
	..()
	if(special_collision == PROJECTILE_COLLISION_DEFAULT || special_collision == PROJECTILE_COLLISION_BLOCKED)
		explosion(A_turf, exdev, exheavy, exlight, exflash, whodunnit = firer)
		if(!gcDestroyed)
			qdel(src)

/obj/item/projectile/rocket/lowyield
	name = "low yield rocket"
	icon_state = "rpground_lowyield"
	damage = 45
	stun = 10
	weaken = 10
	exdev 	= -1
	exheavy = 0
	exlight = 3
	exflash = 5

/obj/item/projectile/rocket/blank
	name = "blank rocket"
	icon_state = "rpground_blank"
	damage = 5
	weaken = 10
	agony = 10
	exdev 	= -1
	exheavy = 0
	exlight = 0
	exflash = 0

/obj/item/projectile/rocket/blank/emp
	name = "EMP rocket"
	icon_state = "rpground_emp"
	damage = 10
	agony = 30
	emheavy = 3
	emlight = 5


/obj/item/projectile/rocket/blank/emp/to_bump(var/atom/A)
	empulse(A, 3, 5)
	..()


/obj/item/projectile/rocket/blank/stun
	name = "stun rocket"
	icon_state = "rpground_stun"
	damage = 15
	stun = 20
	weaken = 20
	agony = 30


/obj/item/projectile/rocket/blank/stun/to_bump(var/atom/A)
	flashbangprime(TRUE, FALSE, FALSE)
	..()



/obj/item/projectile/rocket/lowyield/extreme
	name = "extreme yield rocket"
	icon_state = "rpground_extreme"
	damage = 200
	exdev 	= 7
	exheavy = 14
	exlight = 28
	exflash = 32

/obj/item/projectile/rocket/nikita
	name = "\improper Nikita missile"
	desc = "One does not simply dodge a nikita missile."
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "nikita"
	damage = 50
	stun = 5
	weaken = 5
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	animate_movement = 2
	linear_movement = 0
	kill_count = 100
	layer = PROJECTILE_LAYER
	var/mob/living/carbon/mob = null
	var/obj/item/weapon/gun/projectile/rocketlauncher/nikita/nikita = null
	var/steps_since_last_turn = 0
	var/last_dir = null

/obj/item/projectile/rocket/nikita/OnFired()
	nikita = shot_from
	emagged = nikita.emagged

	if(nikita && istype(nikita.loc,/mob/living/carbon))
		var/mob/living/carbon/C = nikita.loc
		if(C.get_active_hand() == nikita)
			mob = C
			var/datum/control/new_control = new /datum/control/lock_move(mob, src)
			mob.orient_object.Add(new_control)
			new_control.take_control()
			mob.drop_item(nikita)
			nikita = null

	dir = get_dir_cardinal(starting,original)
	last_dir = dir

	if(mob && emagged)
		for(var/obj/item/W in mob.get_all_slots())
			mob.drop_from_inventory(W)//were you're going you won't need those!

/obj/item/projectile/rocket/nikita/emp_act(severity)
	new/obj/item/ammo_casing/rocket_rpg/nikita(get_turf(src))
	if(nikita)
		nikita.fired = null
	qdel(src)

/obj/item/projectile/rocket/nikita/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			detonate()
	return ..()

/obj/item/projectile/rocket/nikita/Destroy()
	reset_view()
	if(nikita)
		nikita.fired = null
	..()

/obj/item/projectile/rocket/nikita/to_bump(var/atom/A)
	if(bumped)
		return
	if(emagged && (A == mob))
		return
	bumped = 1
	detonate(get_turf(A))

/obj/item/projectile/rocket/nikita/Bumped(var/atom/A)
	if(emagged && (A == mob))
		return
	detonate(A)

/obj/item/projectile/rocket/nikita/process_step()
	if(!emagged && !check_user())//if the original user dropped the Nikita and the missile is still in the air, we check if someone picked it up.
		if(nikita && istype(nikita.loc,/mob/living/carbon))
			var/mob/living/carbon/C = nikita.loc
			if(C.get_active_hand() == nikita)
				mob = C
				var/datum/control/new_control = new /datum/control/lock_move(mob, src)
				mob.orient_object.Add(new_control)
				new_control.take_control()

	if(src.loc)
		var/atom/step = get_step(src, dir)
		if(!step)
			qdel(src)
		src.Move(step)

	if(mob && loc)
		if(emagged)
			mob.forceMove(loc)
			mob.dir = dir
		else
			mob.dir = get_dir(mob,src)

	if(!emagged)
		kill_count--
	if(!kill_count)
		detonate()

	if(kill_count == (initial(kill_count)/5))
		mob.playsound_local(mob, 'sound/machines/twobeep.ogg', 30, 1)
		to_chat(mob, "<span class='warning'>WARNING: 20% fuel left on missile before self-detonation.<span>")
	if(dir != last_dir)
		last_dir = dir
		steps_since_last_turn = 0

	var/sleeptime = max(1,(steps_since_last_turn * -1) + 5)//5, 4, 3, 2, 1, 1, 1, 1, 1,...

	steps_since_last_turn++

	sleep(sleeptime)

/obj/item/projectile/rocket/nikita/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return (!density || !height || air_group)

/obj/item/projectile/rocket/nikita/proc/check_user()
	if(!mob || !mob.client)
		return 0
	if(mob.stat || (mob.get_active_hand() != nikita))
		reset_view()
		return 0
	return 1

/obj/item/projectile/rocket/nikita/proc/detonate(var/atom/A)
	explosion(A, exdev, exheavy, exlight, exflash, whodunnit = firer)
	if(!gcDestroyed)
		qdel(src)

/obj/item/projectile/rocket/nikita/proc/reset_view()
	if(!mob)
		return
	var/datum/control/C = mob.orient_object[src]
	if(C)
		C.break_control()
		qdel(C)


//Clown missiles

/obj/item/projectile/rocket/clown
	name = "clown rocket" //abstract
	damage = 0
	weaken = 0
	agony = 0
	exdev 	= -1
	exheavy = 0
	exlight = 0
	exflash = 0
	stun = 5
	var/payload = TRUE
	var/payload_type
	var/payload_power = 5
	var/payload_radius = 2


/obj/item/projectile/rocket/clown/to_bump(var/atom/A)
	if(payload)
		launch_payload()
	..()


/obj/item/projectile/rocket/clown/proc/launch_payload()
	if(payload_type)
		var/atom/curloc = get_turf(src)
		var/list/possible_targets= block_borders(locate(curloc.x-payload_radius, curloc.y-payload_radius, curloc.z), locate(curloc.x+payload_radius, curloc.y+payload_radius, curloc.z))  //I want to throw at the outer reaches of the radius

		//create the payload and throw at each location
		for(var/atom/loc in possible_targets)
			var/atom/movable/payload = new payload_type(curloc)
			payload.throw_at(loc,9,payload_power) // the last one is throwspeed, maybe have the payload determine lethality


/obj/item/projectile/rocket/clown/mouse
	name = "mouse rocket"
	icon_state = "rpground_mouse"
	payload_type = /mob/living/simple_animal/mouse

/obj/item/projectile/rocket/clown/pizza
	name = "pizza rocket"
	icon_state = "rpground_pizza"
	payload_type = /obj/item/weapon/reagent_containers/food/snacks/margheritaslice/rocket

/obj/item/projectile/rocket/clown/pie
	name = "pie rocket"
	icon_state = "rpground_pie"
	payload_type = /obj/item/weapon/reagent_containers/food/snacks/pie

/obj/item/projectile/rocket/clown/cow
	name = "cow rocket"
	icon_state = "rpground_cow"
	payload_type =/mob/living/simple_animal/cow

/obj/item/projectile/rocket/clown/goblin
	name = "clown goblin rocket"
	icon_state = "rpground_clowngoblin"
	payload_type = /mob/living/simple_animal/hostile/retaliate/cluwne/goblin


/obj/item/projectile/rocket/clown/transmog
	//these missiles transmog victims in an aoe of the explosion depending on the transmog type for a duration
	name = "rocket"
	icon_state = "rpground"
	var/transmog_duration = 100
	var/transmog_type
	payload = FALSE


/obj/item/projectile/rocket/clown/transmog/to_bump(var/atom/A)
	aoe_transmog()
	..()

/obj/item/projectile/rocket/clown/transmog/proc/aoe_transmog()
	var/atom/curloc = get_turf(src)
	var/list/possible_targets= block(locate(curloc.x-payload_radius, curloc.y-payload_radius, curloc.z), locate(curloc.x+payload_radius, curloc.y+payload_radius, curloc.z))  //I want to throw at the outer reaches of the radius
	for(var/atom/loc in possible_targets)
		for(var/mob/living/M in loc)
			var/mob/living/holder = M.transmogrify(transmog_type)
			spawn(transmog_duration)
				holder.transmogrify()

/obj/item/projectile/rocket/clown/transmog/cluwne
	name = "cluwnification rocket"
	icon_state = "rpground_clowngoblin"
	transmog_type = /mob/living/simple_animal/hostile/retaliate/cluwne/tempcluwne

/obj/item/projectile/rocket/clown/transmog/cluwne/to_bump(var/atom/A)
	..()
	playsound(src,'sound/items/bikehorn.ogg',100)
