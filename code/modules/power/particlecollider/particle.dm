/obj/item/projectile/particle
	name = "unconfigured particle"
	icon_state = "spark"
	var/speed = 1
	var/charge = 1
	var/active = TRUE
	var/lifetime = 100
	
/obj/item/projectile/particle/New()
	..()
	dir = pick(alldirs) //TODO make this work so it flies off in a random direction instead of always south
	spawn(1)
		move()
		
//TODO use normal projectile movement
//this is horrible
/obj/item/projectile/particle/proc/move()
	if(!loc)
		return
	while(lifetime && active)
		sleep(10)
		forceMove(get_step(loc,dir))
		for (var/obj/machinery/power/collider/C in loc)
			C.particle_event(src)
		lifetime -= 1
	if(lifetime <= 0)
		src.visible_message("/the [src] fizzles out into nothingness.")
		qdel(src)