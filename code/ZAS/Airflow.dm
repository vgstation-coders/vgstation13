/*
Contains helper procs for airflow, handled in /connection_group.
*/

/mob/var/tmp/last_airflow_stun = 0
/mob/proc/airflow_stun()
	if(isDead() || (flags & INVULNERABLE) || (status_flags & GODMODE))
		return 0
	if(last_airflow_stun > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_stun_cooldown))
		return 0
	if(!zas_settings.Get(/datum/ZAS_Setting/airflow_push) || !(M_HARDCORE in mutations))
		return 0
	if(locked_to)
		to_chat(src, "<span class='notice'>Air suddenly rushes past you!</span>")
		return 0
	if(!(status_flags & CANSTUN) && !(status_flags & CANWEAKEN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return 0
	if(weakened <= 0)
		to_chat(src, "<span class='warning'>The sudden rush of air knocks you over!</span>")
	SetWeakened(5)
	last_airflow_stun = world.time

/mob/living/silicon/airflow_stun()
	return

/mob/living/carbon/slime/airflow_stun()
	return

/mob/living/carbon/human/airflow_stun()
	if(last_airflow_stun > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_stun_cooldown))
		return 0
	if(locked_to || (flags & INVULNERABLE))
		return 0
	if(shoes)
		if(CheckSlip() < 1)
			return 0
	if(!(status_flags & CANSTUN) && !(status_flags & CANWEAKEN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return 0

	if(weakened <= 0)
		to_chat(src, "<span class='warning'>The sudden rush of air knocks you over!</span>")
	SetWeakened(rand(1,5))
	last_airflow_stun = world.time

/atom/movable/proc/check_airflow_movable(n)
	if(anchored && !ismob(src))
		return 0
	if(!isobj(src) && n < zas_settings.Get(/datum/ZAS_Setting/airflow_medium_pressure))
		return 0

	return 1

/mob/check_airflow_movable(n)
	if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_heavy_pressure))
		return 0
	return 1

/mob/dead/observer/check_airflow_movable()
	return 0

/mob/living/silicon/check_airflow_movable()
	return 0

/mob/virtualhearer/check_airflow_movable()
	return 0

/obj/item/check_airflow_movable(n)
	if(isnull(w_class))
		if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_dense_pressure)) return 0 //most non-item objs don't have a w_class yet
	else
		switch(w_class)
			if(0 to W_CLASS_SMALL)
				if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_lightest_pressure)) return 0
			if(W_CLASS_SMALL to W_CLASS_MEDIUM)
				if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_light_pressure)) return 0
			if(W_CLASS_MEDIUM to W_CLASS_LARGE)
				if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_medium_pressure)) return 0
			if(W_CLASS_LARGE to W_CLASS_HUGE)
				if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_heavy_pressure)) return 0
			if(W_CLASS_HUGE to INFINITY)
				if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_dense_pressure)) return 0
	return ..()

/atom/movable/var/tmp/turf/airflow_dest
/atom/movable/var/tmp/airflow_speed = 0
/atom/movable/var/tmp/airflow_time = 0
/atom/movable/var/tmp/last_airflow = 0

/atom/movable/proc/AirflowCanMove(n)
	return 1

/mob/AirflowCanMove(n)
	if(status_flags & GODMODE || (flags & INVULNERABLE))
		return 0
	if(locked_to)
		return 0
	if(M_HARDCORE in mutations)
		return 1
	if(CheckSlip() < 0)
		return 0
	if(!(status_flags & CANSTUN) && !(status_flags & CANWEAKEN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return 0

	return 1

/atom/movable/proc/GotoAirflowDest(n)
	if(!airflow_dest)
		return
	if(airflow_speed < 0)
		return
	if(last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay))
		return

	if(airflow_speed)
		airflow_speed = n/max(get_dist(src,airflow_dest),1)
		return
	if(airflow_dest == loc)
		step_away(src,loc)
	if(!src.AirflowCanMove(n))
		return
	if(ismob(src))
		to_chat(src, "<span clas='danger'>You are pushed away by airflow!</span>")
	last_airflow = world.time

	var/airflow_falloff = 9 - sqrt((x - airflow_dest.x) ** 2 + (y - airflow_dest.y) ** 2)
	if(airflow_falloff < 1)
		airflow_dest = null
		return
	airflow_speed = Clamp(n * (9 / airflow_falloff), 1, 9)
	var
		xo = airflow_dest.x - src.x
		yo = airflow_dest.y - src.y
		od = 0
	airflow_dest = null
	if(!density)
		density = 1
		od = 1

	spawn(0)
		while(airflow_speed > 0 && Process_Spacemove(1))
			airflow_speed = min(airflow_speed,15)
			airflow_speed -= zas_settings.Get(/datum/ZAS_Setting/airflow_speed_decay)
			if(airflow_speed > 7)
				if(airflow_time++ >= airflow_speed - 7)
					if(od)
						density = 0
					sleep(tick_multiplier)
			else
				if(od)
					density = 0
				sleep(max(1,10-(airflow_speed+3)) * tick_multiplier)
			if(od)
				density = 1
			if ((!( src.airflow_dest ) || src.loc == src.airflow_dest))
				airflow_dest = locate(Clamp(x + xo, 1, world.maxx), Clamp(y + yo, 1, world.maxy), z)
			if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
				break
			if(!istype(loc, /turf))
				break
			step_towards(src, src.airflow_dest)
			var/mob/M = src
			if(istype(M) && M.client)
				M.delayNextMove(zas_settings.Get(/datum/ZAS_Setting/airflow_mob_slowdown))
		airflow_dest = null
		airflow_speed = 0
		airflow_time = 0
		if(od)
			density = 0


/atom/movable/proc/RepelAirflowDest(n)
	if(!airflow_dest)
		return
	if(airflow_speed < 0)
		return
	if(last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay))
		return

	if(airflow_speed)
		airflow_speed = n/max(get_dist(src,airflow_dest),1)
		return
	if(airflow_dest == loc)
		step_away(src,loc)
	if(!src.AirflowCanMove(n))
		return
	if(ismob(src))
		to_chat(src, "<span clas='danger'>You are pushed away by airflow!</span>")
	last_airflow = world.time

	var/airflow_falloff = 9 - sqrt((x - airflow_dest.x) ** 2 + (y - airflow_dest.y) ** 2)
	if(airflow_falloff < 1)
		airflow_dest = null
		return
	airflow_speed = Clamp(n * (9 / airflow_falloff), 1, 9)
	var
		xo = -(airflow_dest.x - src.x)
		yo = -(airflow_dest.y - src.y)
		od = 0
	airflow_dest = null
	if(!density)
		density = 1
		od = 1

	spawn(0)
		while(airflow_speed > 0)
			airflow_speed = min(airflow_speed,15)
			airflow_speed -= zas_settings.Get(/datum/ZAS_Setting/airflow_speed_decay)
			if(airflow_speed > 7)
				if(airflow_time++ >= airflow_speed - 7)
					sleep(tick_multiplier)
			else
				sleep(max(1,10-(airflow_speed+3)) * tick_multiplier)
			if ((!( src.airflow_dest ) || src.loc == src.airflow_dest))
				airflow_dest = locate(Clamp(x + xo, 1, world.maxx), Clamp(y + yo, 1, world.maxy), z)
			if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
				break
			if(!istype(loc, /turf))
				break
			step_towards(src, src.airflow_dest)
			if(ismob(src) && src:client)
				var/mob/M = src
				M.delayNextMove(zas_settings.Get(/datum/ZAS_Setting/airflow_mob_slowdown))
		airflow_dest = null
		airflow_speed = 0
		airflow_time = 0
		if(od)
			density = 0

/atom/movable/Bump(atom/A)
	if(airflow_speed > 0 && airflow_dest)
		airflow_hit(A)
	else
		airflow_speed = 0
		airflow_time = 0
		. = ..()
	sound_override = 0

atom/movable/proc/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

mob/airflow_hit(atom/A)
	if(size == SIZE_TINY)
		return //Slamming into a mouse/roach doesn't make much sense
	if(!sound_override)
		visible_message(message = "<span class='danger'>\The [src] slams into \a [A]!</span>", blind_message = "<span class='danger'>You hear a loud slam!</span>")
	//playsound(get_turf(src), "smash.ogg", 25, 1, -1)
	if(istype(A,/obj/item))
		var/obj/item/item = A
		SetWeakened(item.w_class)
	else
		SetWeakened(rand(1,5))
	. = ..()

obj/airflow_hit(atom/A)
	if(!sound_override)
		visible_message(message = "<span class='danger'>\The [src] slams into \a [A]!</span>", blind_message = "<span class='warning'>You hear a loud slam!</span>")
	//playsound(get_turf(src), "smash.ogg", 25, 1, -1)
	. = ..()

obj/item/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

mob/living/carbon/human/airflow_hit(atom/A)
	var/b_loss = airflow_speed * zas_settings.Get(/datum/ZAS_Setting/airflow_damage)

	var/head_damage = ((b_loss/3)/100) * (100 - getarmor(LIMB_HEAD,"melee"))
	apply_damage(head_damage, BRUTE, LIMB_HEAD, 0, 0, used_weapon = "Airflow")

	var/chest_damage = ((b_loss/3)/100) * (100 - getarmor(LIMB_CHEST,"melee"))
	apply_damage(chest_damage, BRUTE, LIMB_HEAD, 0, 0, used_weapon = "Airflow")

	var/groin_damage = ((b_loss/3)/100) * (100 - getarmor(LIMB_GROIN,"melee"))
	apply_damage(groin_damage, BRUTE, LIMB_HEAD, 0, 0, used_weapon = "Airflow")

	if((head_damage + chest_damage + groin_damage) > 15)
		var/turf/T = get_turf(src)
		T.add_blood(src)
		bloody_body(src)

	if(zas_settings.Get(/datum/ZAS_Setting/airflow_push) || (M_HARDCORE in mutations))
		if(airflow_speed > 10)
			Paralyse(round(airflow_speed * zas_settings.Get(/datum/ZAS_Setting/airflow_stun)))
			Stun(paralysis + 3)
		else
			Stun(round(airflow_speed * zas_settings.Get(/datum/ZAS_Setting/airflow_stun)/2))

	. = ..()

zone/proc/movables()
	. = list()
	for(var/turf/T in contents)
		for(var/atom/movable/A in T)
			if(A.anchored || istype(A, /obj/effect) || isobserver(A) || isAIEye(A))
				continue
			. += A
