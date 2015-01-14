#define METEOR_TEMPERATURE

/var/meteor_wave_delay = 300 //Failsafe wait between waves in tenths of seconds
//Set it above 100 (10s delay) if you want to minimize lag for some reason

/var/meteors_in_wave = 10 //Failsafe in case a number isn't called
/var/meteorwavecurrent = 0
/var/max_meteor_size=0
/var/chosen_dir = 1

/proc/meteor_wave(var/number = meteors_in_wave, var/max_size=0, var/list/types=null) //Call above constants to change
	if(!ticker || meteorwavecurrent)
		return
	meteorwavecurrent = 1
	meteor_wave_delay = (rand(30,45))*10 //Between 30 and 45 seconds, makes everything more chaotic
	chosen_dir = pick(cardinal) //Pick a direction
	max_meteor_size=max_size
	for(var/i = 0 to number)
		spawn(rand(15,20)) //1.5 to 2 seconds between meteors
			var/meteor_type=null
			if(types!=null)
				meteor_type=pick(types)
			spawn_meteor(chosen_dir,meteor_type)
	spawn(meteor_wave_delay)
		meteorwavecurrent = 0

/proc/spawn_meteor(var/chosen_dir, var/meteorpath=null)

	var/startx
	var/starty
	var/endx
	var/endy
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 5 //Try only five times maximum

	do
		switch(chosen_dir)
			if(1) //NORTH
				starty = world.maxy-(TRANSITIONEDGE+1)
				startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
				endy = TRANSITIONEDGE
				endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
			if(2) //SOUTH
				starty = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
				startx = world.maxx-(TRANSITIONEDGE+1)
				endy = rand(TRANSITIONEDGE, world.maxy-TRANSITIONEDGE)
				endx = TRANSITIONEDGE
			if(4) //EAST
				starty = (TRANSITIONEDGE+1)
				startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
				endy = world.maxy-TRANSITIONEDGE
				endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
			if(8) //WEST
				starty = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
				startx = (TRANSITIONEDGE+1)
				endy = rand(TRANSITIONEDGE,world.maxy-TRANSITIONEDGE)
				endx = world.maxx-TRANSITIONEDGE

		pickedstart = locate(startx, starty, 1)
		pickedgoal = locate(endx, endy, 1)
		max_i--
		if(max_i <= 0)
			return
	while(!istype(pickedstart, /turf/space))

	var/atom/movable/M
	if(meteorpath)
		M = new meteorpath(pickedstart)
	else
		switch(rand(1, 100))
			if(1 to 5) //5 % chance of huge boom
				if(!max_meteor_size || max_meteor_size>=3)
					M = new /obj/effect/meteor/big(pickedstart)
			if(6 to 60) //55 % chance of medium boom
				if(!max_meteor_size || max_meteor_size>=2)
					M = new /obj/effect/meteor(pickedstart)
			if(61 to 100) //40 % chance of small boom
				if(!max_meteor_size || max_meteor_size>=1)
					M = new /obj/effect/meteor/small(pickedstart)
	if(M)
		// This currently doesn't do dick.
		//M.dest = pickedgoal
		walk_towards(M, pickedgoal, 1)
	return

/obj/effect/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "flaming"
	density = 1
	anchored = 1.0
	//var/dest
	pass_flags = PASSTABLE

/obj/effect/meteor/small
	name = "small meteor"
	icon_state = "smallf"
	pass_flags = PASSTABLE

/obj/effect/meteor/Move()
	..()
	return

/obj/effect/meteor/Bump(atom/A)
	spawn(0)
		for(var/mob/M in range(10, src))
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) //bad idea to shake an ai's view
				shake_camera(M, 3, 2) //Medium hit
		if(A)
			A.meteorhit(src)
			playsound(get_turf(src), "explosion", 50, 1) //Medium boom
			explosion(src.loc, 2, 4, 6, 8, 0) //Medium meteor, medium boom
			qdel(src)

/obj/effect/meteor/ex_act(severity)

	if(severity < 4)
		qdel(src)
	return

/obj/effect/meteor/small
	name = "small meteor"
	icon_state = "smallf"
	pass_flags = PASSTABLE

/obj/effect/meteor/small/Bump(atom/A)
	spawn(0)
		for(var/mob/M in range(8, src))
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) //bad idea to shake an ai's view
				shake_camera(M, 2, 1) //Poof
		if(A)
			A.meteorhit(src)
			playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 10, 1)
			explosion(src.loc, -1, 1, 3, 4, 0) //Tiny meteor doesn't cause too much damage
			qdel(src)


/obj/effect/meteor/big
	name = "big meteor"
	pass_flags = 0 //Nope, you're not dodging that table

/obj/effect/meteor/big/ex_act(severity)
		return

/obj/effect/meteor/big/Bump(atom/A)
	spawn(0)

		for(var/mob/M in range(15, src)) //Now that's visible
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) //bad idea to shake an ai's view
				shake_camera(M, 7, 3) //Massive shellshock
		if(A)
			explosion(src.loc, 4, 6, 8, 8, 0) //You have been visited by the nuclear meteor
			playsound(get_turf(src), "explosion", 100, 1) //Deafening boom, default is 50
			qdel(src)

/obj/effect/meteor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pickaxe))
		qdel(src)
	..()

/obj/effect/meteor/Destroy()
	walk(src,0) //this cancels the walk_towards() proc
	..()