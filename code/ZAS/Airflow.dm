/*

CONTAINS:
All AirflowX() procs, all Variable Setting Controls for airflow, save/load variable tweaks for airflow.

VARIABLES:

atom/movable/airflow_dest
	The destination turf of a flying object.

atom/movable/airflow_speed
	The speed (1-15) at which a flying object is traveling to airflow_dest. Decays over time.


OVERLOADABLE PROCS:

mob/airflow_stun()
	Contains checks for and results of being stunned by airflow.
	Called when airflow quantities exceed airflow_medium_pressure.
	RETURNS: Null

atom/movable/check_airflow_movable(n)
	Contains checks for moving any object due to airflow.
	n is the pressure that is flowing.
	RETURNS: 1 if the object moves under the air conditions, 0 if it stays put.

atom/movable/airflow_hit(atom/A)
	Contains results of hitting a solid object (A) due to airflow.
	A is the dense object hit.
	Use airflow_speed to determine how fast the projectile was going.


AUTOMATIC PROCS:

atom/movable/GotoAirflowDest(n)
	Called by main airflow procs to cause the object to fly to (n > 0) or away from (n < 0) destination at speed scaled by abs(n).
	Probably shouldn't call this directly unless you know what you're
	doing and have set airflow_dest. airflow_hit() will be called if the object collides with an obstacle.

*/

/mob/var/tmp/last_airflow_stun = 0
/mob/proc/airflow_stun()
	if(isDead() || (flags & INVULNERABLE) || (status_flags & GODMODE))
		return FALSE
	if(world.time < last_airflow_stun + zas_settings.Get(/datum/ZAS_Setting/airflow_stun_cooldown))
		return FALSE
//	if(!zas_settings.Get(/datum/ZAS_Setting/airflow_push) || !(M_HARDCORE in mutations)) //This block was added in the original XGM PR, but, again, I don't want to bundle balance with system.
//		return FALSE
//	if(locked_to)
//		to_chat(src, "<span class='notice'>Air suddenly rushes past you!</span>")
//		return FALSE
	if(!(status_flags & CANSTUN) && !(status_flags & CANKNOCKDOWN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return FALSE
	if(knockdown <= 0)
		to_chat(src, "<span class='warning'>The sudden rush of air knocks you over!</span>")
	SetKnockdown(5)
	last_airflow_stun = world.time

/mob/living/silicon/airflow_stun()
	return

/mob/living/carbon/slime/airflow_stun()
	return

/mob/living/carbon/human/airflow_stun(differential)
	if(world.time < last_airflow_stun + zas_settings.Get(/datum/ZAS_Setting/airflow_stun_cooldown))
		return FALSE
	if(locked_to || (flags & INVULNERABLE))
		return FALSE
	if(shoes)
		if((CheckSlip()) != TRUE)
			return FALSE
	if(!(status_flags & CANSTUN) && !(status_flags & CANKNOCKDOWN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return FALSE

	if(knockdown <= 0)
		to_chat(src, "<span class='warning'>The sudden rush of air knocks you over!</span>")
	SetKnockdown(rand(differential/20,differential/10))
	last_airflow_stun = world.time

/atom/movable/proc/check_airflow_movable(n)
	return (!anchored && n >= zas_settings.Get(/datum/ZAS_Setting/airflow_dense_pressure))

/mob/check_airflow_movable(n)
//	if(M_HARDCORE in mutations)
//		return TRUE //It really is hardcore //TOO hardcore, probably

	if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_heavy_pressure))
		return FALSE
	if(status_flags & GODMODE || (flags & INVULNERABLE))
		return FALSE
	if(locked_to)
		return FALSE
	if(CheckSlip() == SLIP_HAS_MAGBOOTS)
		return FALSE

	if (grabbed_by.len)
		return FALSE

	return TRUE

/mob/living/carbon/human/check_airflow_movable(n)
	if(reagents.has_reagent(MEDCORES))
		return FALSE
	return ..()

/mob/dead/observer/check_airflow_movable()
	return FALSE

/mob/living/silicon/check_airflow_movable()
	return FALSE

/mob/virtualhearer/check_airflow_movable()
	return FALSE

/obj/item/check_airflow_movable(n)
	if(anchored)
		return FALSE
	switch(w_class) //Note that switch() evaluates the FIRST matching case, so the case that executes for a given w_class is the one for which it is the UPPER bound.
		if(0 to W_CLASS_TINY)
			return TRUE
		if(W_CLASS_TINY to W_CLASS_SMALL)
			return (n >= zas_settings.Get(/datum/ZAS_Setting/airflow_lightest_pressure))
		if(W_CLASS_SMALL to W_CLASS_MEDIUM)
			return (n >= zas_settings.Get(/datum/ZAS_Setting/airflow_light_pressure))
		if(W_CLASS_MEDIUM to INFINITY)
			return (n >= zas_settings.Get(/datum/ZAS_Setting/airflow_medium_pressure))

/atom/movable/var/tmp/turf/airflow_dest
/atom/movable/var/tmp/airflow_speed = 0
/atom/movable/var/tmp/airflow_time = 0
/atom/movable/var/tmp/last_airflow = 0

/atom/movable/proc/GotoAirflowDest(n) //TODO GLIDESIZE HERE
	if(!airflow_dest || pulledby)
		return
	if(world.time < last_airflow + zas_settings.Get(/datum/ZAS_Setting/airflow_delay))
		return
	if(airflow_dest == loc)
		return
	if(ismob(src))
		to_chat(src, "<span class='warning'>You are sucked away by airflow!</span>")

	var/xo = airflow_dest.x - x
	var/yo = airflow_dest.y - y

	var/airflow_falloff = 9 - sqrt(xo ** 2 + yo ** 2)

	if(airflow_falloff < 1)
		airflow_dest = null
		return

	if(n < 0)
		n *= -2 //Back when GotoAirflowDest() and RepelAirflowDest() were separate procs, the latter was called with differential/5 rather than differential/10. This is to maintain consistency.
		xo *= -1
		yo *= -1

	airflow_speed = Clamp(n * (9 / airflow_falloff), 1, 9)

	airflow_dest = null

	var/od = FALSE
	if(!density)
		setDensity(TRUE)
		od = TRUE

	last_airflow = world.time

	spawn(0)
		var/turf/curturf = get_turf(src)
		while(airflow_speed > 0 && Process_Spacemove(1))
			airflow_speed = min(airflow_speed,15)
			airflow_speed -= zas_settings.Get(/datum/ZAS_Setting/airflow_speed_decay)
			var/sleep_time
			if(airflow_speed > 7)
				if(airflow_time++ >= airflow_speed - 7)
					if(od)
						setDensity(FALSE)
					sleep_time = tick_multiplier
			else
				if(od)
					setDensity(FALSE)
				sleep_time = max(1,10-(airflow_speed+3)) * tick_multiplier
			sleep(sleep_time)
			if(od)
				setDensity(TRUE)
			if ((!( src.airflow_dest ) || src.loc == src.airflow_dest))
				airflow_dest = locate(Clamp(x + xo, 1, world.maxx), Clamp(y + yo, 1, world.maxy), z)
			if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
				break
			if(!isturf(loc))
				break
			if(curturf != get_turf(src)) //We've managed to get to our feet and move away
				break
			if(!check_airflow_movable(n*10)) //We've turned our magboots on, or become unstunnable, etc.
				break
			set_glide_size(DELAY2GLIDESIZE(sleep_time))
			step_towards(src, src.airflow_dest)
			curturf = get_turf(src)
			var/mob/M = src
			if(istype(M) && M.client)
				M.delayNextMove(zas_settings.Get(/datum/ZAS_Setting/airflow_mob_slowdown))
		airflow_dest = null
		airflow_speed = 0
		airflow_time = 0
		if(od)
			setDensity(FALSE)

/atom/movable/to_bump(atom/Obstacle)
	if(airflow_speed > 0 && airflow_dest)
		airflow_hit(Obstacle)
	else
		airflow_speed = 0
		airflow_time = 0
		. = ..()
	sound_override = 0

/atom/movable/proc/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

/mob/airflow_hit(atom/A)
	if(size == SIZE_TINY)
		return //Slamming into a mouse/roach doesn't make much sense
	if(!sound_override)
		visible_message(message = "<span class='danger'>\The [src] slams into \a [A]!</span>", blind_message = "<span class='danger'>You hear a loud slam!</span>")
	//playsound(src, "smash.ogg", 25, 1, -1)
	if(istype(A,/obj/item))
		var/obj/item/item = A
		SetKnockdown(item.w_class)
	else
		SetKnockdown(rand(1,5))
	. = ..()

/obj/airflow_hit(atom/A)
	if(!sound_override)
		visible_message(message = "<span class='danger'>\The [src] slams into \a [A]!</span>", blind_message = "<span class='warning'>You hear a loud slam!</span>")
	//playsound(src, "smash.ogg", 25, 1, -1)
	. = ..()

/obj/item/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

/mob/living/carbon/human/airflow_hit(atom/A)
	var/b_loss = airflow_speed * zas_settings.Get(/datum/ZAS_Setting/airflow_damage)

	for(var/i in contents)
		if(istype(i, /obj/item/airbag))
			var/obj/item/airbag/airbag = i
			airbag.deploy(src)
			b_loss = 0
			break

	var/head_damage = ((b_loss/3)/100) * (100 - getarmor(LIMB_HEAD,"melee"))
	apply_damage(head_damage, BRUTE, LIMB_HEAD, 0, 0, used_weapon = "Airflow")

	var/chest_damage = ((b_loss/3)/100) * (100 - getarmor(LIMB_CHEST,"melee"))
	apply_damage(chest_damage, BRUTE, LIMB_CHEST, 0, 0, used_weapon = "Airflow")

	var/groin_damage = ((b_loss/3)/100) * (100 - getarmor(LIMB_GROIN,"melee"))
	apply_damage(groin_damage, BRUTE, LIMB_GROIN, 0, 0, used_weapon = "Airflow")

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

/zone/proc/movables() //TODO: Make airflow movement and stunning more closely-associated so this proc can handle differential checking.
	var/list/found = list()
	for(var/turf/simulated/T in contents)
		for(var/atom/movable/AM in T)
			found += AM
	return found
