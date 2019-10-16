//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

#define BLOB_PROBABILITY 40
#define HEADBUTT_PROBABILITY 40
#define BRAINLOSS_FOR_HEADBUTT 60

var/list/all_doors = list()
/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/door.dmi'
	icon_state = "door_closed"
	anchored = 1
	opacity = 1
	density = 1
	layer = OPEN_DOOR_LAYER
	penetration_dampening = 10
	var/open_layer = OPEN_DOOR_LAYER
	var/closed_layer = CLOSED_DOOR_LAYER
	var/secondsElectrified = 0
	var/visible = 1
	var/operating = 0
	var/autoclose = 0
	var/glass = 0
	var/normalspeed = 1

	machine_flags = SCREWTOGGLE

	// for glass airlocks/opacity firedoors
	var/heat_proof = 0

	var/air_properties_vary_with_direction = 0

	// multi-tile doors
	dir = EAST
	var/width = 1

	// from old /vg/
	// the object that's jammed us open/closed
	var/obj/jammed = null

	// if the door has certain variation, like rapid (r_)
	var/prefix = null

	// TODO: refactor to best :(
	var/animation_delay = 10
	var/animation_delay_2 = null

	// turf animation
	var/atom/movable/overlay/c_animation = null
	var/makes_noise = 0
	var/soundeffect = 'sound/machines/airlock.ogg'
	var/soundpitch = 30

	var/explosion_block = 0 //regular airlocks are 1, blast doors are 3, higher values mean increasingly effective at blocking explosions.

/obj/machinery/door/projectile_check()
	if(opacity)
		return PROJREACT_WALLS
	else
		return PROJREACT_WINDOWS

/obj/machinery/door/hitby(atom/movable/AM)
	. = ..()
	if(.)
		return
	var/obj/item/thing = AM
	if(!istype(thing))
		return FALSE
	if(operating || !density)
		return FALSE
	if(!length(thing.GetAccess()))
		return FALSE
	if(!check_access(thing))
		denied()
		return FALSE
	open()
	return TRUE

/obj/machinery/door/Bumped(atom/AM)
	if (ismob(AM))
		var/mob/M = AM

		if(!M.restrained() && (M.size > SIZE_TINY))
			bump_open(M)

		return

	if (istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM

		if (check_access(bot.botcard) && !operating)
			open()

		return

	if (istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM

		if (density)
			if (mecha.occupant && !operating && (allowed(mecha.occupant) || check_access_list(mecha.operation_req_access)))
				open()
			else if(!operating)
				denied()

	if (istype(AM, /obj/structure/bed/chair/vehicle))
		var/obj/structure/bed/chair/vehicle/vehicle = AM

		if (density)
			if (vehicle.is_locking(/datum/locking_category/buckle/chair/vehicle, subtypes=TRUE) && !operating && allowed(vehicle.get_locked(/datum/locking_category/buckle/chair/vehicle, subtypes=TRUE)[1]))
				if(istype(vehicle, /obj/structure/bed/chair/vehicle/firebird))
					vehicle.forceMove(get_step(vehicle,vehicle.dir))//Firebird doesn't wait for no slowpoke door to fully open before dashing through!
				open()
			else if(!operating)
				denied()

/obj/machinery/door/proc/headbutt_check(mob/user, var/stun_time = 0, var/knockdown_time = 0, var/damage = 0) //This is going to be an airlock proc until someone makes headbutting a more official thing
	if(prob(HEADBUTT_PROBABILITY) && density && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= BRAINLOSS_FOR_HEADBUTT)
			playsound(src, 'sound/effects/bang.ogg', 25, 1)
			H.visible_message("<span class='warning'>[user] headbutts the airlock.</span>")
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				H.Stun(stun_time)
				H.Knockdown(knockdown_time)
				var/datum/organ/external/O = H.get_organ(LIMB_HEAD)
				if(O)
					O.take_damage(damage) //Brute damage only
			return

/obj/machinery/door/proc/bump_open(mob/user as mob)
	// TODO: analyze this
	headbutt_check(user, 8, 5, 10)

	if(user.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) //Fakkit
		return

	add_fingerprint(user)

	if(!requiresID())
		user = null

	if(allowed(user))
		if (isshade(user))
			user.forceMove(loc)//They're basically slightly tangible ghosts, they can fit through doors as soon as they begin openning.
		open()
	else if(!operating)
		denied()

/obj/machinery/door/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	attack_hand(user)

/obj/machinery/door/attack_paw(mob/user as mob)
	attack_hand(user)

/obj/machinery/door/attack_hand(mob/user as mob)
	headbutt_check(user, 8, 5, 10)

	if(isobserver(user)) //Adminghosts don't want to toggle the door open, they want to see the AI interface
		return

	add_fingerprint(user)

	if (!requiresID())
		user = null

	if (allowed(user))
		if (!density)
			return close()
		else
			return open()

	if(horror_force(user))
		return

	denied()

/obj/machinery/door/attackby(obj/item/I, mob/user)
	if(..())
		return

	if(istype(I, /obj/item/device/detective_scanner))
		return //It does its own thing on attack

	if (allowed(user))
		if (!density)
			return close()
		else
			return open()


	if(horror_force(user))
		return

	denied()

/obj/machinery/door/proc/horror_force(var/mob/living/carbon/human/H) //H is for HORROR, BABY!
	if(!ishorrorform(H))
		return FALSE

	playsound(H.loc, 'sound/effects/horrorforce2.ogg', 80)
	visible_message("<span class='danger'>\The [src]'s motors whine as several great tendrils begin trying to force it open!</span>")
	if(do_after(H, src, 32))
		open(1)
		visible_message("<span class='danger'>[H.name] forces \the [src] open!</span>")

		// Open firedoors, too.
		for(var/obj/machinery/door/firedoor/FD in loc)
			FD.open(1)
	else
		to_chat(H, "<span class='warning'>You fail to open \the [src].</span>")

	return TRUE

/obj/machinery/door/blob_act()
	if(prob(BLOB_PROBABILITY))
		qdel(src)

/obj/machinery/door/proc/door_animate(var/animation as text)
	switch (animation)
		if ("opening")
			flick("[prefix]door_opening", src)
		if ("closing")
			flick("[prefix]door_closing", src)

/obj/machinery/door/update_icon()
	if(!density)
		icon_state = "[prefix]door_open"
	else
		icon_state = "[prefix]door_closed"

	sleep(animation_delay_2)


/obj/machinery/door/proc/open()
	if(!density)
		return 1
	if(operating > 0)
		return
	if(!ticker)
		return 0
	if(!operating)
		operating = 1

	if(makes_noise)
		playsound(src, soundeffect, soundpitch, 1)

	set_opacity(0)
	door_animate("opening")
	sleep(animation_delay)
	layer = open_layer
	setDensity(FALSE)
	explosion_resistance = 0
	update_icon()
	set_opacity(0)
	update_nearby_tiles()
	//update_freelook_sight()

	if(operating == 1)
		operating = 0

	return 1

/obj/machinery/door/proc/autoclose()
	var/obj/machinery/door/airlock/A = src
	if(!A.density && !A.operating && !A.locked && !A.welded && A.autoclose && !A.jammed)
		close()
	return

/obj/machinery/door/proc/close()
	if (density || operating || jammed)
		return
	operating = 1

	layer = closed_layer

	if (makes_noise)
		playsound(src, soundeffect, soundpitch, 1)

	setDensity(TRUE)
	door_animate("closing")
	sleep(animation_delay)
	update_icon()

	if (!glass)
		src.set_opacity(1)
		// Copypasta!!!
		var/obj/effect/beam/B = locate() in loc
		if(B)
			qdel(B)

	// TODO: rework how fire works on doors
	var/obj/effect/fire/F = locate() in loc
	if(F)
		qdel(F)

	update_nearby_tiles()
	operating = 0

/obj/machinery/door/New()
	. = ..()
	all_doors += src

	if(density)
		// above most items if closed
		layer = closed_layer

		explosion_resistance = initial(explosion_resistance)
	else
		layer = open_layer

		explosion_resistance = 0

	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * WORLD_ICON_SIZE
			bound_height = WORLD_ICON_SIZE
		else
			bound_width = WORLD_ICON_SIZE
			bound_height = width * WORLD_ICON_SIZE

	update_nearby_tiles()

/obj/machinery/door/cultify()
	if(invisibility != INVISIBILITY_MAXIMUM)
		invisibility = INVISIBILITY_MAXIMUM
		setDensity(FALSE)
		anim(target = src, a_icon = 'icons/effects/effects.dmi', a_icon_state = "breakdoor", sleeptime = 10)
		qdel(src)

/obj/machinery/door/Destroy()
	update_nearby_tiles()
	all_doors -= src
	..()

/obj/machinery/door/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group)
		return 0
	if(istype(mover))
		if(mover.checkpass(PASSGLASS))
			return !opacity
		if(mover.checkpass(PASSDOOR))
			return 1
	return !density

/obj/machinery/door/Crossed(AM as mob|obj) //Since we can't actually quite open AS the car goes through us, we'll do the next best thing: open as the car goes into our tile.
	if(istype(AM, /obj/structure/bed/chair/vehicle/firebird)) //Which is not 100% correct for things like windoors but it's close enough.
		open()
	return ..()

/obj/machinery/door/proc/CanAStarPass(var/obj/item/weapon/card/id/ID)
	return !density || check_access(ID)


/obj/machinery/door/emp_act(severity)
	if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
		open(6)
	if(prob(40/severity))
		if(secondsElectrified == 0)
			secondsElectrified = -1
			spawn(300)
				secondsElectrified = 0
	..()


/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(25))
				qdel(src)
		if(3.0)
			if(prob(80))
				spark(src, 2)
	return

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/proc/update_nearby_tiles(var/turf/T)
	if(!SS_READY(SSair))
		return 0

	if(!T)
		T = get_turf(src)
	if(!isturf(T))
		return 0

	update_heat_protection(T)
	SSair.mark_for_update(T)

	update_freelok_sight()
	return 1

/obj/machinery/door/forceMove(atom/destination, no_tp=0, harderforce = FALSE, glide_size_override = 0)
	var/turf/T = loc
	..()
	update_nearby_tiles(T)
	update_nearby_tiles()

/obj/machinery/door/proc/update_heat_protection(var/turf/simulated/source)
	if(istype(source))
		if(src.density && (src.opacity || src.heat_proof))
			source.thermal_conductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)

/obj/machinery/door/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	update_nearby_tiles()
	. = ..()
	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * WORLD_ICON_SIZE
			bound_height = WORLD_ICON_SIZE
		else
			bound_width = WORLD_ICON_SIZE
			bound_height = width * WORLD_ICON_SIZE

	update_nearby_tiles()

// Flash denied and such.
/obj/machinery/door/proc/denied()
	playsound(loc, 'sound/machines/denied.ogg', 50, 1)
	if (density) //Why are we playing a denied animation on an OPEN DOOR
		door_animate("deny")

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/morgue.dmi'
	animation_delay = 15
	penetration_dampening = 15
