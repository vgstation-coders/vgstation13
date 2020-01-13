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
	var/explosive = 1
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

/obj/item/projectile/rocket/to_bump(var/atom/A)
	if(explosive == 1)
		explosion(A, exdev, exheavy, exlight, exflash) 
		if(!gcDestroyed)
			qdel(src)
	else
		..()
		if(!gcDestroyed)
			qdel(src)

/obj/item/projectile/rocket/lowyield
	name = "low yield rocket"
	icon_state = "rpground"
	damage = 45
	stun = 10
	weaken = 10
	exdev 	= -1
	exheavy = 0
	exlight = 3
	exflash = 5

/obj/item/projectile/rocket/blank
	name = "blank rocket"
	damage = 5
	weaken = 10
	agony = 10
	exdev 	= -1
	exheavy = 0
	exlight = 0
	exflash = 0

/obj/item/projectile/rocket/blank/emp
	name = "EMP rocket"
	damage = 10
	agony = 30
	emheavy = 3
	emlight = 5

/obj/item/projectile/rocket/emp/to_bump(var/atom/A)
	empulse(A, 3, 5)
	..()
	
/obj/item/projectile/rocket/blank/stun
	name = "stun rocket"
	damage = 15
	stun = 20
	weaken = 20
	agony = 30

/obj/item/projectile/rocket/stun/to_bump(var/atom/A)
	flashbangprime(TRUE, FALSE, FALSE)
	..()
		
/obj/item/projectile/rocket/lowyield/extreme
	name = "extreme yield rocket"
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
	var/emagged = 0//the value is set by the Nikita when it fires it

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
	explosion(A, exdev, exheavy, exlight, exflash)
	if(!gcDestroyed)
		qdel(src)

/obj/item/projectile/rocket/nikita/proc/reset_view()
	var/datum/control/C = mob.orient_object[src]
	if(C)
		C.break_control()
		qdel(C)
