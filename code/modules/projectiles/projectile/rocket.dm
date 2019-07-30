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
		explosion(A, 1, 3, 5, 8) //RPGs pack a serious punch and will cause massive structural damage in your average room, but won't punch through reinforced walls
		if(!gcDestroyed)
			qdel(src)
	else
		..()
		if(!gcDestroyed)
			qdel(src)

/obj/item/projectile/rocket/lowyield
	name = "low yield rocket"
	icon_state = "rpground"
	explosive = 0
	damage = 45
	stun = 10
	weaken = 10
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"

/obj/item/projectile/rocket/lowyield/to_bump(var/atom/A)
	explosion(A, -1, 0, 3, 5) //RPGs pack a serious punch and will cause massive structural damage in your average room, but won't punch through reinforced walls
	..()
	if(!gcDestroyed)
		qdel(src)

/obj/item/projectile/rocket/blank
	name = "blank rocket"
	icon_state = "rpground"
	explosive = 0
	damage = 5
	stun = 5
	weaken = 10
	agony = 10
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"

/obj/item/projectile/rocket/blank/to_bump(var/atom/A)
	explosion(A, -1, 0, 0, 0)
	..()
	if(!gcDestroyed)
		qdel(src)

/obj/item/projectile/rocket/emp
	name = "EMP rocket"
	icon_state = "rpground"
	explosive = 0
	damage = 10
	stun = 5
	weaken = 10
	agony = 30
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"

/obj/item/projectile/rocket/emp/to_bump(var/atom/A)
	explosion(A, -1, 0, 0, 0)
	empulse(A, 3, 5)
	..()
	if(!gcDestroyed)
		qdel(src)

/obj/item/projectile/rocket/stun
	name = "stun rocket"
	icon_state = "rpground"
	explosive = 0
	damage = 15
	stun = 20
	weaken = 20
	agony = 30
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"

/obj/item/projectile/rocket/stun/to_bump(var/atom/A)
	explosion(A, -1, 0, 0, 0)
	flashbangprime(TRUE, FALSE, FALSE)
	..()
	if(!gcDestroyed)
		qdel(src)

/obj/item/projectile/nikita
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

/obj/item/projectile/nikita/OnFired()
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

/obj/item/projectile/nikita/emp_act(severity)
	new/obj/item/ammo_casing/rocket_rpg/nikita(get_turf(src))
	if(nikita)
		nikita.fired = null
	qdel(src)

/obj/item/projectile/nikita/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			detonate()

/obj/item/projectile/nikita/Destroy()
	reset_view()
	if(nikita)
		nikita.fired = null
	..()

/obj/item/projectile/nikita/to_bump(var/atom/A)
	if(bumped)
		return
	if(emagged && (A == mob))
		return
	bumped = 1
	detonate(get_turf(A))

/obj/item/projectile/nikita/Bumped(var/atom/A)
	if(emagged && (A == mob))
		return
	detonate(A)

/obj/item/projectile/nikita/process_step()
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

/obj/item/projectile/nikita/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return (!density || !height || air_group)

/obj/item/projectile/nikita/proc/check_user()
	if(!mob || !mob.client)
		return 0
	if(mob.stat || (mob.get_active_hand() != nikita))
		reset_view()
		return 0
	return 1

/obj/item/projectile/nikita/proc/detonate(var/atom/A)
	explosion(A, 1, 3, 5, 8) //Nikita rockets pack a serious punch and will cause massive structural damage in your average room, but won't punch through reinforced walls
	if(!gcDestroyed)
		qdel(src)

/obj/item/projectile/nikita/proc/reset_view()
	var/datum/control/C = mob.orient_object[src]
	if(C)
		C.break_control()
		qdel(C)
