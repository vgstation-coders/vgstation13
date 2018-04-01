/obj/effect/ebeam/curse_arm
	name = "curse arm"
	layer = LARGE_MOB_LAYER

/obj/item/projectile/curse_hand
	name = "curse hand"
	icon_state = "cursehand"
	hitsound = 'sound/effects/curse4.ogg'
	layer = LARGE_MOB_LAYER
	damage_type = BURN
	damage = 10
	knockdown = 20
	speed = 2
	range = 16
	forcedodge = TRUE
	var/datum/beam/arm
	var/handedness = 0

/obj/item/projectile/curse_hand/Initialize(mapload)
	. = ..()
	handedness = prob(50)
	update_icon()

/obj/item/projectile/curse_hand/update_icon()
	icon_state = "[icon_state][handedness]"

/obj/item/projectile/curse_hand/fire(setAngle)
	if(starting)
		arm = starting.Beam(src, icon_state = "curse[handedness]", time = INFINITY, maxdistance = INFINITY, beam_type=/obj/effect/ebeam/curse_arm)
	..()

/obj/item/projectile/curse_hand/prehit(atom/target)
	if(target == original)
		forcedodge = FALSE
	else if(!isturf(target))
		return FALSE
	return ..()

/obj/item/projectile/curse_hand/Destroy()
	if(arm)
		arm.End()
		arm = null
	if(forcedodge)
		playsound(src, 'sound/effects/curse3.ogg', 25, 1, -1)
	var/turf/T = get_step(src, dir)
	new/obj/effect/temp_visual/dir_setting/curse/hand(T, dir, handedness)
	for(var/obj/effect/temp_visual/dir_setting/curse/grasp_portal/G in starting)
		qdel(G)
	new /obj/effect/temp_visual/dir_setting/curse/grasp_portal/fading(starting, dir)
	var/datum/beam/D = starting.Beam(T, icon_state = "curse[handedness]", time = 32, maxdistance = INFINITY, beam_type=/obj/effect/ebeam/curse_arm, beam_sleep_time = 1)
	for(var/b in D.elements)
		var/obj/effect/ebeam/B = b
		animate(B, alpha = 0, time = 32)
	return ..()

