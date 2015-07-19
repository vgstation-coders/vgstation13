// RICOCHET SHOT
//A projectile that mones only in diagonal, bounces off walls and opaque doors, goes through everything else.
/obj/item/projectile/ricochet
	name = "ricochet shot"
	damage_type = BURN
	flag = "laser"
	kill_count = 100
	layer = 13
	damage = 30
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "ricochet_head"
	animate_movement = 0
	var/pos_from = EAST	//which side of the turf is the shot coming from
	var/pos_to = SOUTH	//which side of the turf is the shot heading to
	var/bouncin = 0

	//list of objects that'll stop the shot, and apply bullet_act
	var/list/obj/ricochet_bump = list(
		/obj/effect/blob,
		/obj/machinery/turret,
		/obj/machinery/turretcover,
		/obj/mecha,
		/obj/structure/reagent_dispensers/fueltank,
		/obj/structure/stool/bed/chair/vehicle,
		)

/obj/item/projectile/ricochet/OnFired()	//The direction and position of the projectile when it spawns depends heavily on where the player clicks.
	var/turf/T1 = get_turf(shot_from)	//From a single turf, a player can fire the ricochet rifle in 8 different directions.
	var/turf/T2 = get_turf(original)
	shot_from.update_icon()
	var/X = T2.x - T1.x
	var/Y = T2.y - T1.y
	var/X_spawn = 0
	var/Y_spawn = 0
	if(X>0)
		if(Y>0)
			if(X>Y)
				pos_from = WEST
				pos_to = NORTH
				X_spawn = 1
			else if(X<Y)
				pos_from = SOUTH
				pos_to = EAST
				Y_spawn = 1
			else
				if(prob(50))
					pos_from = WEST
					pos_to = NORTH
					X_spawn = 1
				else
					pos_from = SOUTH
					pos_to = EAST
					Y_spawn = 1
		else if(Y<0)
			if(X>(Y*-1))
				pos_from = WEST
				pos_to = SOUTH
				X_spawn = 1
			else if(X<(Y*-1))
				pos_from = NORTH
				pos_to = EAST
				Y_spawn = -1
			else
				if(prob(50))
					pos_from = WEST
					pos_to = SOUTH
					X_spawn = 1
				else
					pos_from = NORTH
					pos_to = EAST
					Y_spawn = -1
		else if(Y==0)
			pos_from = WEST
			X_spawn = 1
			if(prob(50))
				pos_to = NORTH
			else
				pos_to = SOUTH
	else if(X<0)
		if(Y>0)
			if((X*-1)>Y)
				pos_from = EAST
				pos_to = NORTH
				X_spawn = -1
			else if((X*-1)<Y)
				pos_from = SOUTH
				pos_to = WEST
				Y_spawn = 1
			else
				if(prob(50))
					pos_from = EAST
					pos_to = NORTH
					X_spawn = -1
				else
					pos_from = SOUTH
					pos_to = WEST
					Y_spawn = 1
		else if(Y<0)
			if((X*-1)>(Y*-1))
				pos_from = EAST
				pos_to = SOUTH
				X_spawn = -1
			else if((X*-1)<(Y*-1))
				pos_from = NORTH
				pos_to = WEST
				Y_spawn = -1
			else
				if(prob(50))
					pos_from = EAST
					pos_to = SOUTH
					X_spawn = -1
				else
					pos_from = NORTH
					pos_to = WEST
					Y_spawn = -1
		else if(Y==0)
			pos_from = EAST
			X_spawn = -1
			if(prob(50))
				pos_to = NORTH
			else
				pos_to = SOUTH
	else if(X==0)
		if(Y>0)
			Y_spawn = 1
			pos_from = SOUTH
			if(prob(50))
				pos_to = EAST
			else
				pos_to = WEST
		else if(Y<0)
			Y_spawn = -1
			pos_from = NORTH
			if(prob(50))
				pos_to = EAST
			else
				pos_to = WEST
	else
		OnDeath()
		loc = null
		returnToPool(src)
		return

	var/turf/newspawn = locate(T1.x + X_spawn, T1.y + Y_spawn, z)
	src.loc = newspawn

	update_icon()

/obj/item/projectile/ricochet/update_icon()//8 possible combinations
	switch(pos_to)
		if(NORTH)
			if(pos_from == WEST)
				dir = NORTHWEST
			else
				dir = EAST
		if(SOUTH)
			if(pos_from == WEST)
				dir = WEST
			else
				dir = SOUTHEAST
		if(EAST)
			if(pos_from == NORTH)
				dir = NORTHEAST
			else
				dir = SOUTH
		if(WEST)
			if(pos_from == NORTH)
				dir = NORTH
			else
				dir = SOUTHWEST

/obj/item/projectile/ricochet/proc/bounce()
	bouncin = 1
	var/obj/structure/ricochet_bump/bump = new(loc)
	bump.dir = pos_to
	playsound(get_turf(src), 'sound/items/metal_impact.ogg', 50, 1)
	switch(pos_to)
		if(NORTH)
			if(pos_from == WEST)
				pos_to = EAST
			else
				pos_to = WEST
			pos_from = NORTH
		if(SOUTH)
			if(pos_from == WEST)
				pos_to = EAST
			else
				pos_to = WEST
			pos_from = SOUTH
		if(EAST)
			if(pos_from == NORTH)
				pos_to = SOUTH
			else
				pos_to = NORTH
			pos_from = EAST
		if(WEST)
			if(pos_from == NORTH)
				pos_to = SOUTH
			else
				pos_to = NORTH
			pos_from = WEST

/obj/item/projectile/ricochet/proc/bulletdies()
	spawn()
		density = 0
		invisibility = 101
		//del(src)
		loc = null
		returnToPool(src)
		OnDeath()

/obj/item/projectile/ricochet/proc/admin_warn(mob/living/M)
	if(istype(firer, /mob))
		if(firer == M)
			log_attack("<font color='red'>[key_name(firer)] shot himself with a [type].</font>")
			M.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot himself with a <b>[type]</b>"
			firer.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot himself with a <b>[type]</b>"
			msg_admin_attack("[key_name(firer)] shot himself with a [type], [pick("top kek!","for shame.","he definitely meant to do that","probably not the last time either.")] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)")
			if(!iscarbon(firer))
				M.LAssailant = null
			else
				M.LAssailant = firer
		else
			log_attack("<font color='red'>[key_name(firer)] shot [key_name(M)] with a [type]</font>")
			M.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			firer.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			msg_admin_attack("[key_name(firer)] shot [key_name(M)] with a [type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)")
			if(!iscarbon(firer))
				M.LAssailant = null
			else
				M.LAssailant = firer
	else
		M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN/(no longer exists)</b> shot <b>UNKNOWN/(no longer exists)</b> with a <b>[type]</b>"
		msg_admin_attack("UNKNOWN/(no longer exists) shot UNKNOWN/(no longer exists) with a [type]. Wait what the fuck? (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)")
		log_attack("<font color='red'>UNKNOWN/(no longer exists) shot UNKNOWN/(no longer exists) with a [type]</font>")

/obj/item/projectile/ricochet/Bump(atom/A as mob|obj|turf|area)
	if(bumped)	return 0
	bumped = 1

	if(A)
		if(istype(A,/turf/) || (istype(A,/obj/machinery/door/) && A.opacity))
			bounce()

		else if(istype(A,/mob/living))//ricochet shots "never miss"
			if(istype(A,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = A
				if(istype(H.wear_suit,/obj/item/clothing/suit/armor/laserproof))// bwoing!!
					bounce()

				else
					A.bullet_act(src, def_zone)
					admin_warn(A)
					bulletdies()
			else
				A.bullet_act(src, def_zone)
				admin_warn(A)
				bulletdies()

		else if(is_type_in_list(A,ricochet_bump))//beware fuel tanks!
			A.bullet_act(src)
			bulletdies()

		else if((istype(A,/obj/structure/window) || istype(A,/obj/machinery/door/window) || istype(A,/obj/machinery/door/firedoor/border_only)) && (A.loc == src.loc))
							//all this part is to prevent a bug that causes the shot to go through walls
							//if they are one the same tile as a one-directional window/windoor and try to cross them
			var/turf/T = get_step(src, pos_to)
			if(T.density)
				bounce()

			else
				ricochet_jump()

		else
			ricochet_jump()

/obj/item/projectile/ricochet/process_step()//unlike laser guns the projectile isn't instantaneous, but it still travels twice as fast as kinetic bullets since it moves twices per ticks
	if(src.loc)
		if(kill_count < 1)
			bulletdies()
		kill_count--
		for(var/i=1;i<=2;i++)
			ricochet_movement()
		update_icon()
		sleep(1)

/obj/item/projectile/ricochet/proc/ricochet_step(var/phase=1)
	var/obj/structure/ricochet_trail/trail = new(loc)
	switch(pos_to)
		if(NORTH)
			if(pos_from == WEST)
				trail.dir = NORTH
			else
				trail.dir = EAST
		if(SOUTH)
			if(pos_from == WEST)
				trail.dir = WEST
			else
				trail.dir = SOUTH
		if(EAST)
			if(pos_from == NORTH)
				trail.dir = EAST
			else
				trail.dir = SOUTH
		if(WEST)
			if(pos_from == NORTH)
				trail.dir = NORTH
			else
				trail.dir = WEST
	if(phase)
		current = get_step(src, pos_to)
		step_towards(src, current)
	else
		var/turf/T = get_step(src, pos_to)
		loc = T

	if((bumped && !phase) || bouncin)
		return

	switch(pos_to)
		if(NORTH)
			if(pos_from == WEST)
				pos_to = EAST
			else
				pos_to = WEST
			pos_from = SOUTH
		if(SOUTH)
			if(pos_from == WEST)
				pos_to = EAST
			else
				pos_to = WEST
			pos_from = NORTH
		if(EAST)
			if(pos_from == NORTH)
				pos_to = SOUTH
			else
				pos_to = NORTH
			pos_from = WEST
		if(WEST)
			if(pos_from == NORTH)
				pos_to = SOUTH
			else
				pos_to = NORTH
			pos_from = EAST

/obj/item/projectile/ricochet/proc/ricochet_movement()//movement through empty space
	if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
		bulletdies()
		return
	ricochet_step()
	bumped = 0
	bouncin = 0

/obj/item/projectile/ricochet/proc/ricochet_jump()//movement through dense objects
	if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
		bulletdies()
		return
	ricochet_step(0)

/obj/structure/ricochet_trail	//so pretty
	name = "ricochet shot"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "ricochet"
	opacity = 0
	density = 0
	unacidable = 1
	anchored = 1
	layer = 12

/obj/structure/ricochet_trail/New()
	. = ..()
	spawn(30)
		qdel(src)

/obj/structure/ricochet_bump	//oh so pretty
	name = "ricochet shot"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "ricochet_bounce"
	opacity = 0
	density = 0
	unacidable = 1
	anchored = 1
	layer = 14

/obj/structure/ricochet_bump/New()
	. = ..()
	spawn(30)
		qdel(src)


/obj/item/projectile/beam/bison
	name = "heat ray"
	damage_type = BURN
	flag = "laser"
	kill_count = 100
	layer = 13
	damage = 15
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "heatray"
	animate_movement = 0
	pass_flags = PASSTABLE

	var/tang = 0
	var/turf/last = null
/obj/item/projectile/beam/bison/proc/adjustAngle(angle)
	angle = round(angle) + 45
	if(angle > 180)
		angle -= 180
	else
		angle += 180
	if(!angle)
		angle = 1
	/*if(angle < 0)
		//angle = (round(abs(get_angle(A, user))) + 45) - 90
		angle = round(angle) + 45 + 180
	else
		angle = round(angle) + 45*/
	return angle

/obj/item/projectile/beam/bison/process()
	//calculating the turfs that we go through
	var/lastposition = loc

	var/turf/target = get_turf(original)
	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)

	var/dx
	if (target.x > src.x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if (target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH

	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y

		spawn while(src && src.loc)
			// only stop when we've hit something, or hit the end of the map
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				error += dist_x
			else
				var/atom/step = get_step(src, dx)
				if(!step)
					break
				src.Move(step)
				error -= dist_y

			if(isnull(loc))
				draw_ray(lastposition)
				return
			if(lastposition == loc)
				kill_count = 0
			lastposition = loc
			if(kill_count < 1)
				//del(src)
				draw_ray(lastposition)
				returnToPool(src)
				return
			kill_count--

			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						draw_ray(target)
						Bump(original)

	else
		var/error = dist_y/2 - dist_x
		spawn while(src && src.loc)
			// only stop when we've hit something, or hit the end of the map
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step)
					break
				src.Move(step)
				error += dist_y
			else
				var/atom/step = get_step(src, dy)
				if(!step)
					break
				src.Move(step)
				error -= dist_x

			if(isnull(loc))
				draw_ray(lastposition)
				return
			if(lastposition == loc)
				kill_count = 0
			lastposition = loc
			if(kill_count < 1)
				//del(src)
				draw_ray(lastposition)
				returnToPool(src)
				return
			kill_count--

			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						draw_ray(target)
						Bump(original)

	return


/obj/item/projectile/beam/bison/proc/draw_ray(var/turf/lastloc)
	var/atom/curr = lastloc
	var/Angle=round(Get_Angle(firer,curr))
	var/icon/I=new('icons/obj/lightning.dmi',icon_state)
	var/icon/Istart=new('icons/obj/lightning.dmi',"[icon_state]start")
	var/icon/Iend=new('icons/obj/lightning.dmi',"[icon_state]end")
	I.Turn(Angle+45)
	Istart.Turn(Angle+45)
	Iend.Turn(Angle+45)
	var/DX=(32*curr.x+curr.pixel_x)-(32*firer.x+firer.pixel_x)
	var/DY=(32*curr.y+curr.pixel_y)-(32*firer.y+firer.pixel_y)
	var/N=0
	var/length=round(sqrt((DX)**2+(DY)**2))
	var/count = 0
	var/turf/T = get_turf(firer)

	var/timer_total = 16
	var/increment = timer_total/round(length/32)
	var/current_timer = 5

	for(N,N<length,N+=32)
		if(count >= kill_count)
			break
		count++
		var/obj/effect/overlay/beam/X=new(T,current_timer)
		X.BeamSource=src
		current_timer += increment
		if((N+64>length) && (N+32<=length))
			X.icon=Iend
		else if(N==0)
			X.icon=Istart
		else if(N+32>length)
			X.icon=null
		else
			X.icon=I

		var/Pixel_x=round(sin(Angle)+32*sin(Angle)*(N+16)/32)
		var/Pixel_y=round(cos(Angle)+32*cos(Angle)*(N+16)/32)
		if(DX==0) Pixel_x=0
		if(DY==0) Pixel_y=0
		if(Pixel_x>32)
			for(var/a=0, a<=Pixel_x,a+=32)
				X.x++
				Pixel_x-=32
		if(Pixel_x<-32)
			for(var/a=0, a>=Pixel_x,a-=32)
				X.x--
				Pixel_x+=32
		if(Pixel_y>32)
			for(var/a=0, a<=Pixel_y,a+=32)
				X.y++
				Pixel_y-=32
		if(Pixel_y<-32)
			for(var/a=0, a>=Pixel_y,a-=32)
				X.y--
				Pixel_y+=32
		X.pixel_x=Pixel_x
		X.pixel_y=Pixel_y
		var/turf/TT = get_turf(X.loc)
		if(TT == firer.loc)
			continue

	return

/obj/item/projectile/beam/bison/Bump(atom/A as mob|obj|turf|area)
	//Heat Rays go through mobs
	if(A == firer)
		loc = A.loc
		return 0 //cannot shoot yourself

	if(firer && istype(A, /mob/living))
		var/mob/living/M = A
		A.bullet_act(src, def_zone)
		loc = A.loc
		permutated.Add(A)
		visible_message("<span class='warning'>[A.name] is hit by the [src.name] in the [parse_zone(def_zone)]!</span>")//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
		if(istype(firer, /mob))
			log_attack("<font color='red'>[key_name(firer)] shot [key_name(M)] with a [type]</font>")
			M.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			firer.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			msg_admin_attack("[key_name(firer)] shot [key_name(M)] with a [type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)") //BS12 EDIT ALG
			if(!iscarbon(firer))
				M.LAssailant = null
			else
				M.LAssailant = firer
		else
			M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN/(no longer exists)</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			msg_admin_attack("UNKNOWN/(no longer exists) shot [key_name(M)] with a [type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)") //BS12 EDIT ALG
			log_attack("<font color='red'>UNKNOWN/(no longer exists) shot [key_name(M)] with a [type]</font>")
		return 1
	else
		return ..()
