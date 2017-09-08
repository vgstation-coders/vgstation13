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

Airflow(zone/A, zone/B)
	Causes objects to fly along a pressure gradient.
	Called by zone updates. A and B are two connected zones.

AirflowSpace(zone/A)
	Causes objects to fly into space.
	Called by zone updates. A is a zone connected to space.

atom/movable/GotoAirflowDest(n)
atom/movable/RepelAirflowDest(n)
	Called by main airflow procs to cause the object to fly to or away from destination at speed n.
	Probably shouldn't call this directly unless you know what you're
	doing and have set airflow_dest. airflow_hit() will be called if the object collides with an obstacle.

*/

/mob/var/tmp/last_airflow_stun = 0
/mob/proc/airflow_stun()
	if(isDead() || (flags & INVULNERABLE) || (status_flags & GODMODE))
		return 0
	if(world.time < last_airflow_stun + zas_settings.Get(/datum/ZAS_Setting/airflow_stun_cooldown))
		return 0
//	if(!zas_settings.Get(/datum/ZAS_Setting/airflow_push) || !(M_HARDCORE in mutations)) //This block was added in the original XGM PR, but, again, I don't want to bundle balance with system.
//		return 0
//	if(locked_to)
//		to_chat(src, "<span class='notice'>Air suddenly rushes past you!</span>")
//		return 0
	if(!(status_flags & CANSTUN) && !(status_flags & CANKNOCKDOWN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return 0
	if(knockdown <= 0)
		to_chat(src, "<span class='warning'>The sudden rush of air knocks you over!</span>")
	SetKnockdown(5)
	last_airflow_stun = world.time

/mob/living/silicon/airflow_stun()
	return

/mob/living/carbon/slime/airflow_stun()
	return

/mob/living/carbon/human/airflow_stun()
	if(world.time < last_airflow_stun + zas_settings.Get(/datum/ZAS_Setting/airflow_stun_cooldown))
		return 0
	if(locked_to || (flags & INVULNERABLE))
		return 0
	if(shoes)
		if(CheckSlip() < 1)
			return 0
	if(!(status_flags & CANSTUN) && !(status_flags & CANKNOCKDOWN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return 0

	if(knockdown <= 0)
		to_chat(src, "<span class='warning'>The sudden rush of air knocks you over!</span>")
	SetKnockdown(rand(1,5))
	last_airflow_stun = world.time

/atom/movable/proc/check_airflow_movable(n)
	return (!anchored && n >= zas_settings.Get(/datum/ZAS_Setting/airflow_dense_pressure))

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
	if(anchored)
		return 0
	switch(w_class) //Note that switch() evaluates the FIRST matching case, so the case that executes for a given w_class is the one for which it is the UPPER bound.
		if(0 to W_CLASS_TINY)
			return 1
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

// Mainly for bustanuts.

/atom/movable/proc/AirflowCanPush()
	return 1

/mob/AirflowCanPush()
	return 1

/mob/living/carbon/human/AirflowCanPush()
	if(reagents.has_reagent(MEDCORES))
		return 0
	return ..()

/atom/movable/proc/GotoAirflowDest(n)
	last_airflow = world.time
	if(pulledby)
		return
	if(airflow_dest == loc)
		return
	if(ismob(src))
		var/mob/M = src
		if(M.status_flags & GODMODE || (flags & INVULNERABLE))
			return
		if(M.grabbed_by.len)
			return
		if(istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			if(H.locked_to)
				return
			if(H.shoes)
				if(H.CheckSlip() < 0)
					return
		to_chat(src, "<SPAN CLASS='warning'>You are sucked away by airflow!</SPAN>")
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
			if(!isturf(loc))
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
	if(pulledby)
		return
	if(airflow_dest == loc)
		step_away(src,loc)
	if(ismob(src))
		var/mob/M = src
		if(M.status_flags & GODMODE || (flags & INVULNERABLE))
			return
		if(M.grabbed_by.len)
			return
		if(istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			if(H.locked_to)
				return
			if(H.shoes)
				if(H.CheckSlip() < 0)
					return
		to_chat(src, "<SPAN CLASS='warning'>You are pushed away by airflow!</SPAN>")
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
			if((!( src.airflow_dest ) || src.loc == src.airflow_dest))
				airflow_dest = locate(Clamp(x + xo, 1, world.maxx), Clamp(y + yo, 1, world.maxy), z)
			if((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
				break
			if(!isturf(loc))
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

/atom/movable/to_bump(atom/Obstacle)
	if(airflow_speed > 0 && airflow_dest)
		airflow_hit(Obstacle)
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
		SetKnockdown(item.w_class)
	else
		SetKnockdown(rand(1,5))
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

	if(zas_settings.Get(/datum/ZAS_Setting/airflow_push) || AirflowCanPush())
		if(airflow_speed > 10)
			paralysis += round(airflow_speed * zas_settings.Get(/datum/ZAS_Setting/airflow_stun))
			stunned = max(stunned,paralysis + 3)
		else
			stunned += round(airflow_speed * zas_settings.Get(/datum/ZAS_Setting/airflow_stun)/2)

	. = ..()
