//#define BLUESPACELEAK_FLAT if you touch this I'll cut your fingers

// QUALITY COPYPASTA
/turf/unsimulated/wall/supermatter
	name = "Supermatter Sea"
	desc = "THE END IS right now actually."
	icon='icons/turf/space.dmi'
#ifdef BLUESPACELEAK_FLAT
	icon_state = "bluespace"
#else
	icon_state = "bluespacecrystal1"
#endif

	light_range = 5
	light_power = 2
	light_color="#0066FF"
	layer = SUPERMATTER_WALL_LAYER
	plane = LIGHTING_PLANE

	var/next_check=0
	var/list/avail_dirs = list(NORTH,SOUTH,EAST,WEST)

	dynamic_lighting = 0

/turf/unsimulated/wall/supermatter/New()
	processing_objects |= src
#ifndef BLUESPACELEAK_FLAT
	icon_state = "bluespacecrystal[rand(1,3)]"
	var/nturns=pick(0,3)
	if(nturns)
		var/matrix/M = matrix()
		M.Turn(90*nturns)
		transform = M
#endif
	return ..()

/turf/unsimulated/wall/supermatter/Destroy()
	processing_objects -= src
	return ..()

/turf/unsimulated/wall/supermatter/process()
	// Only check infrequently.
	if(next_check>world.time)
		return

	// No more available directions? Shut down process().
	if(avail_dirs.len==0)
		processing_objects.Remove(src)
		return 1

	// We're checking, reset the timer.
	next_check = world.time+5 SECONDS

	// Choose a direction.
	var/pdir = pick(avail_dirs)
	avail_dirs -= pdir
	var/turf/T=get_step(src,pdir)
	if(istype(T, /turf/unsimulated/wall/supermatter/))
		avail_dirs -= pdir
		return

	// EXPAND DONG
	if(isturf(T))
		// This is normally where a growth animation would occur
#ifdef BLUESPACELEAK_FLAT
		new /obj/effect/overlay/bluespacify(T)
#endif
		spawn(10)
			// Nom.
			for(var/atom/movable/A in T)
				if(A)
					if(istype(A,/mob/living))
						qdel(A)
						A = null
					else if(istype(A,/mob)) // Observers, AI cameras.
						continue
					qdel(A)
					A = null
				CHECK_TICK
			T.ChangeTurf(type)
			var/turf/unsimulated/wall/supermatter/SM = T
			if(SM.avail_dirs)
				SM.avail_dirs -= get_dir(T, src)

/turf/unsimulated/wall/supermatter/attack_paw(mob/user as mob)
	return attack_hand(user)

/turf/unsimulated/wall/supermatter/attack_robot(mob/user as mob)
	if(Adjacent(user))
		return attack_hand(user)
	else
		to_chat(user, "<span class = \"warning\">What the fuck are you doing?</span>")
	return

// /vg/: Don't let ghosts fuck with this.
/turf/unsimulated/wall/supermatter/attack_ghost(mob/user as mob)
	user.examination(src)

/turf/unsimulated/wall/supermatter/attack_ai(mob/user as mob)
	return user.examination(src)

/turf/unsimulated/wall/supermatter/attack_hand(mob/user as mob)
	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src]... And then blinks out of existance.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything immediately goes quiet. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an unearthly noise.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	Consume(user)

/turf/unsimulated/wall/supermatter/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	user.visible_message("<span class=\"warning\">\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class=\"danger\">You touch \the [W] to \the [src] when everything suddenly goes silent.\"</span>\n<span class=\"notice\">\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class=\"warning\">Everything suddenly goes silent.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	user.drop_from_inventory(W)
	Consume(W)


/turf/unsimulated/wall/supermatter/Bumped(atom/AM as mob|obj)
	if(istype(AM, /mob/living))
		AM.visible_message("<span class=\"warning\">\The [AM] slams into \the [src] inducing a resonance... \his body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an unearthly noise as a wave of heat washes over you.</span>")
	else
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	Consume(AM)


/turf/unsimulated/wall/supermatter/proc/Consume(var/mob/living/user)
	if(istype(user,/mob/dead/observer))
		return

	qdel(user)

/turf/unsimulated/wall/supermatter/singularity_act()
	return

/turf/unsimulated/wall/supermatter/no_spread
	avail_dirs = list()
