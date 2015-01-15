#define METEOR_TEMPERATURE

var/strike_to_info = 150 //Failsafe wait between waves in tenths of seconds
var/info_to_strike = 450
//Set it above 100 (10s delay) if you want to minimize lag for some reason

var/meteors_in_wave = 10 //Failsafe in case a number isn't called
var/meteorwavecurrent = 0
var/max_meteor_size = 0
var/chosen_dir = 1
var/meteor_state_confirmation = 0 //Hacky way of ALWAYS having the meteor monitors aware of meteors

/proc/meteor_wave(var/number = meteors_in_wave, var/max_size = 0, var/list/types = null) //Call above constants to change
	if(!ticker || meteorwavecurrent)
		return
	meteorwavecurrent = 1
	strike_to_info = rand(10,15)*10 //Nothing happens during that time, as in nothing. Info dumps once that's done
	chosen_dir = pick(cardinal) //Pick a direction
	max_meteor_size = max_size //Used by meteor events
	info_to_strike = rand(45, 60)*10 //We dumped the info, now begins the real delay until shit goes down
	meteor_wave_infodump(1) //Let's dump that info
	message_admins("METEORS : Meteor wave of size [meteors_in_wave], coming from bitflag direction [cardinal] (1 = North, 2 = South, 4 = East, 8 = West), bound to strike in [info_to_strike]. Brace for impact")
	spawn(info_to_strike) //The meteor wave 'is happening'. Namely, it's on its merry way
		meteor_wave_infodump(2)
		for(var/i = 0 to number)
			spawn(rand(15,20)) //1.5 to 2 seconds between meteors
				spawn_meteor(chosen_dir)
		spawn(strike_to_info)
			meteor_wave_infodump(3) //It TECHNICALLY has no effects, but it avoids wiping the fancy statistics for no reason
			meteorwavecurrent = 0

//BEING BUILT, UNCOMMENT AND REMOVE THIS NOTICE WHEN WE ARE GOOD TO GO - Dylanstrategie
/proc/meteor_wave_infodump(var/infotorefresh)
	for(var/obj/machinery/computer/meteormonitor/m_monitor in meteormonitorlist) //Get the monitors
		if(m_monitor) //Did we find any ?
			//Good, time to dump
			if(meteor_state_confirmation == 1) //Did we warn them today ?
				m_monitor.meteor_storm = 1
			switch(infotorefresh) //Allows us to call the right procs easily
				if(1) //Meteor wave inbound
					m_monitor.meteor_wave_inbound = 1 //We're sure about that one, yessir !
					switch(chosen_dir)
						if(1)
							m_monitor.meteor_wave_dirinfo = "north"
						if(2)
							m_monitor.meteor_wave_dirinfo = "south"
						if(4)
							m_monitor.meteor_wave_dirinfo = "east"
						if(8)
							m_monitor.meteor_wave_dirinfo = "west"
						else //What the hell ?
							m_monitor.meteor_wave_dirinfo = "/unknown direction/"
					m_monitor.meteor_wave_sizeinfo = meteors_in_wave
					m_monitor.meteor_wave_tod = worldtime2text()
					m_monitor.meteor_wave_strikedelay = info_to_strike
					//Do you like fluff ? I like fluff
					var/m_name1 = list("Alpha", "Beta", "Delta", "Epsilon", "Gamma", "Omega", "Pi")
					var/m_name2 = list("Local", "Sectorial", "Inner Belt", "Outer Belt")
					var/m_name3 = list("Cluster", "Group", "Cloud", "Field")
					var/m_finalname = "[meteors_in_wave > 300 ? "Major":"Minor"] [pick(m_name2)] Meteor [pick(m_name3)] [pick(m_name1)]-[rand(1,99)]"
					m_monitor.meteor_wave_name = m_finalname
				if(2) //It's on ! IT'S ON !
					m_monitor.meteor_wave_live = 1
				if(3) //We're done, let's clear up all that nasty info up (If you really want logging, add it in I guess)
					m_monitor.meteor_wave_inbound = 0
					m_monitor.meteor_wave_live = 0
					m_monitor.meteor_wave_dirinfo = "/unknown direction/"
					m_monitor.meteor_wave_sizeinfo = 0
					m_monitor.meteor_wave_tod = "/ERROR/"
					m_monitor.meteor_wave_strikedelay = 0
					m_monitor.meteor_wave_name = "Database Error"
				if(4) //A meteor storm has been detected in this sector and is expected to strike...
					m_monitor.meteor_storm = 1 //Hit the switch
				/* //Linked to events, not finished in this PR
				if(5) //Stray meteor
					m_monitor.emergency_warning = 1
					m_monitor.emergency_warning_type = 1
				if(6) //Stray meteor data wipe
					m_monitor.emergency_warning = 0
					m_monitor.emergency_warning_type = 0
				if(7) //Supply drop. Not related to care packages in any way, shape or form, no sir !
					m_monitor.emergency_warning = 1
					m_monitor.emergency_warning_type = 2
					m_monitor.meteor_supplydrop_tag = targetgpstag
					message_admins("Firing GPS warning")
				if(8) //Supply drop data wipe
					m_monitor.emergency_warning = 0
					m_monitor.emergency_warning_type = 0
					m_monitor.meteor_supplydrop_tag = "Illegal Tag Name"
					message_admins("Wiping GPS warning")
				*/
				else
					return //What the fuck are you doing ?
		else
			//message_admins("No meteor monitor found. This is for testing purposes")
			return

/proc/spawn_meteor(var/chosen_dir, var/meteorpath = null)

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
				if(!max_meteor_size || max_meteor_size >= 3)
					M = new /obj/effect/meteor/big(pickedstart)
			if(6 to 60) //55 % chance of medium boom
				if(!max_meteor_size || max_meteor_size >= 2)
					M = new /obj/effect/meteor(pickedstart)
			if(61 to 100) //40 % chance of small boom
				if(!max_meteor_size || max_meteor_size >= 1)
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