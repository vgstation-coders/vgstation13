
/*
 * Use: Caches beam state images and holds turfs that had these images overlaid.
 * Structure:
 * beam_master
 *     icon_states/dirs of beams
 *         image for that beam
 *     references for fired beams
 *         icon_states/dirs for each placed beam image
 *             turfs that have that icon_state/dir
 */
var/list/beam_master = list()

/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	invisibility = 101
	animate_movement = 2
	linear_movement = 1
	layer = PROJECTILE_LAYER
	plane = LIGHTING_PLANE
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 30
	damage_type = BURN
	flag = "laser"
	eyeblur = 4
	fire_sound = 'sound/weapons/Laser.ogg'
	var/frequency = 1
	var/wait = 0
	var/beam_color= null


/obj/item/projectile/beam/OnFired()	//if assigned, allows for code when the projectile gets fired
	target = get_turf(original)
	dist_x = abs(target.x - starting.x)
	dist_y = abs(target.y - starting.y)

	override_starting_X = starting.x
	override_starting_Y = starting.y
	override_target_X = target.x
	override_target_Y = target.y

	if (target.x > starting.x)
		dx = EAST
	else
		dx = WEST

	if (target.y > starting.y)
		dy = NORTH
	else
		dy = SOUTH

	if(dist_x > dist_y)
		error = dist_x/2 - dist_y
	else
		error = dist_y/2 - dist_x

	target_angle = round(Get_Angle(starting,target))

	return 1

/obj/item/projectile/beam/process()
	var/lastposition = loc
	var/reference = "\ref[src]" //So we do not have to recalculate it a ton

	target = get_turf(original)
	dist_x = abs(target.x - src.x)
	dist_y = abs(target.y - src.y)

	if (target.x > src.x)
		dx = EAST
	else
		dx = WEST

	if (target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH
	var/target_dir = SOUTH

	if(dist_x > dist_y)
		error = dist_x/2 - dist_y

		spawn
			reference = bresenham_step(dist_x,dist_y,dx,dy,lastposition,target_dir,reference)

	else
		error = dist_y/2 - dist_x
		spawn
			reference = bresenham_step(dist_y,dist_x,dy,dx,lastposition,target_dir,reference)

	cleanup(reference)

/obj/item/projectile/beam/bresenham_step(var/distA, var/distB, var/dA, var/dB, var/lastposition, var/target_dir, var/reference)
	var/first = 1
	var/tS = 0
	while(src && src.loc)// only stop when we've hit something, or hit the end of the map
		bumped = 0
		if(first && timestopped)
			tS = 1
			timestopped = 0
		if(error < 0)
			var/atom/step = get_step(src, dB)
			if(!step)
				bullet_die()
			src.Move(step)
			error += distA
			target_dir = null
		else
			var/atom/step = get_step(src, dA)
			if(!step)
				bullet_die()
			src.Move(step)
			error -= distB
			target_dir = dA
			if(error < 0)
				target_dir = dA + dB

		if(isnull(loc))
			return reference
		if(lastposition == loc && (!tS && !timestopped && !loc.timestopped))
			kill_count = 0
		lastposition = loc
		if(kill_count < 1)
			bullet_die()
			return reference
		if(travel_range)
			if(get_exact_dist(starting, get_turf(src)) > travel_range)
				bullet_die()
				return reference
		kill_count--
		if(bump_original_check())
			return reference

		if(linear_movement)
			update_pixel()

			//If the icon has not been added yet
			if( !("[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]_color[beam_color]" in beam_master))
				var/image/I = image(icon,"[icon_state]_pixel",13,target_dir) //Generate it.
				if(beam_color)
					I.color = beam_color
				I.transform = turn(I.transform, target_angle+45)
				I.pixel_x = PixelX
				I.pixel_y = PixelY
				I.plane = EFFECTS_PLANE
				I.layer = PROJECTILE_LAYER
				beam_master["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]_color[beam_color]"] = I //And cache it!

			//Finally add the overlay
			if(src.loc && target_dir)
				src.loc.overlays += beam_master["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]_color[beam_color]"]

				//Add the turf to a list in the beam master so they can be cleaned up easily.
				if(reference in beam_master)
					var/list/turf_master = beam_master[reference]
					if("[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]_color[beam_color]" in turf_master)
						var/list/turfs = turf_master["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]_color[beam_color]"]
						turfs += loc
					else
						turf_master["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]_color[beam_color]"] = list(loc)
				else
					var/list/turfs = list()
					turfs["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]_color[beam_color]"] = list(loc)
					beam_master[reference] = turfs
		else
			//If the icon has not been added yet
			if( !("[icon_state][target_dir]" in beam_master))
				var/image/I = image(icon,icon_state,10,target_dir) //Generate it.
				I.plane = EFFECTS_PLANE
				I.layer = PROJECTILE_LAYER
				beam_master["[icon_state][target_dir]"] = I //And cache it!

			//Finally add the overlay
			if(src.loc && target_dir)
				src.loc.overlays += beam_master["[icon_state][target_dir]"]

				//Add the turf to a list in the beam master so they can be cleaned up easily.
				if(reference in beam_master)
					var/list/turf_master = beam_master[reference]
					if("[icon_state][target_dir]" in turf_master)
						var/list/turfs = turf_master["[icon_state][target_dir]"]
						turfs += loc
					else
						turf_master["[icon_state][target_dir]"] = list(loc)
				else
					var/list/turfs = list()
					turfs["[icon_state][target_dir]"] = list(loc)
					beam_master[reference] = turfs
		if(tS)
			timestopped = loc.timestopped
			tS = 0
		if(wait)
			sleep(wait)
			wait = 0
		while((loc.timestopped || timestopped) && !first)
			sleep(3)
		first = 0


	return reference


/obj/item/projectile/beam/dumbfire(var/dir)
	var/reference = "\ref[src]" // So we do not have to recalculate it a ton.

	spawn(0)
		var/target_dir = dir ? dir : src.dir// TODO: remove dir arg. Or don't because the way this was set up without it broke spacepods.
		var/first = 1
		var/tS = 0
		while(loc) // Move until we hit something.
			if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
				returnToPool(src)
				break
			if(first && timestopped)
				tS = 1
				timestopped = 0
			step(src, target_dir) // Move.
			if(tS)
				tS = 0
				timestopped = loc.timestopped
			if(bumped)
				break

			if(kill_count-- < 1)
				returnToPool(src)
				break

			// Add the overlay as we pass over tiles.

			// If the icon has not been added yet.
			if(!beam_master.Find("[icon_state][target_dir]"))
				beam_master["[icon_state][target_dir]"] = image(icon, icon_state, 10, target_dir) // Generate, and cache it!

			// Finally add the overlay
			loc.overlays.Add(beam_master["[icon_state][target_dir]"])

			// Add the turf to a list in the beam master so they can be cleaned up easily.
			if(beam_master.Find(reference))
				var/list/turf_master = beam_master[reference]

				if(turf_master.Find("[icon_state][target_dir]"))
					turf_master["[icon_state][target_dir]"] += loc
				else
					turf_master["[icon_state][target_dir]"] = list(loc)
			else
				var/list/turfs = new
				turfs["[icon_state][target_dir]"] = list(loc)
				beam_master[reference] = turfs
			while((loc.timestopped || timestopped) && !first)
				sleep(3)
			first = 0


	cleanup(reference)

/obj/item/projectile/beam/proc/cleanup(const/reference)
	var/TS
	var/atom/lastloc
	var/starttime = world.time
	var/cleanedup = 0
	while(world.time - starttime < 3 || TS)
		if(loc)
			lastloc = loc
		TS = lastloc.timestopped
		if(TS)
			if(world.time - starttime > 3)
				if(!cleanedup)
					var/list/turf_master = beam_master[reference]

					for(var/laser_state in turf_master)
						var/list/turfs = turf_master[laser_state]
						for(var/turf/T in turfs)
							if(!T.timestopped)
								T.overlays.Remove(beam_master[laser_state])
					cleanedup = 1
			sleep(2)

		else
			sleep(1)

	if(cleanedup)
		sleep(2)
	var/list/turf_master = beam_master[reference]

	for(var/laser_state in turf_master)
		var/list/turfs = turf_master[laser_state]

		for(var/turf/T in turfs)
			T.overlays.Remove(beam_master[laser_state])

		turfs.len = 0

// Special laser the captains gun uses
/obj/item/projectile/beam/captain
	name = "captain laser"
	icon_state = "laser_old"
	damage = 40
	linear_movement = 0

/obj/item/projectile/beam/retro
	icon_state = "laser_old"
	linear_movement = 0

/obj/item/projectile/beam/lightning
	invisibility = 101
	name = "lightning"
	damage = 0
	icon = 'icons/obj/lightning.dmi'
	icon_state = "lightning"
	stun = 10
	weaken = 10
	stutter = 50
	eyeblur = 50
	var/tang = 0
	layer = PROJECTILE_LAYER
	var/turf/last = null
	kill_count = 12

/obj/item/projectile/beam/lightning/proc/adjustAngle(angle)
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

/obj/item/projectile/beam/lightning/process()
	icon_state = "lightning"
	var/first = 1 //So we don't make the overlay in the same tile as the firer
	var/broke = 0
	var/broken
	var/atom/curr = current
	var/Angle=round(Get_Angle(firer,curr))
	var/icon/I=new('icons/obj/lightning.dmi',icon_state)
	var/icon/Istart=new('icons/obj/lightning.dmi',"[icon_state]start")
	var/icon/Iend=new('icons/obj/lightning.dmi',"[icon_state]end")
	I.Turn(Angle+45)
	Istart.Turn(Angle+45)
	Iend.Turn(Angle+45)
	var/DX=(WORLD_ICON_SIZE*curr.x+curr.pixel_x)-(WORLD_ICON_SIZE*firer.x+firer.pixel_x)
	var/DY=(WORLD_ICON_SIZE*curr.y+curr.pixel_y)-(WORLD_ICON_SIZE*firer.y+firer.pixel_y)
	var/N=0
	var/length=round(sqrt((DX)**2+(DY)**2))
	var/count = 0
	var/turf/T = get_turf(src)
	var/list/ouroverlays = list()

	spawn() for(N,N<length,N+=WORLD_ICON_SIZE)
		if(count >= kill_count)
			break
		count++
		var/obj/effect/overlay/beam/persist/X=getFromPool(/obj/effect/overlay/beam/persist,T)
		X.BeamSource=src
		ouroverlays += X
		if((N+WORLD_ICON_SIZE*2>length) && (N+WORLD_ICON_SIZE<=length))
			X.icon=Iend
		else if(N==0)
			X.icon=Istart
		else if(N+WORLD_ICON_SIZE>length)
			X.icon=null
		else
			X.icon=I

		var/Pixel_x=round(sin(Angle)+WORLD_ICON_SIZE*sin(Angle)*(N+WORLD_ICON_SIZE/2)/WORLD_ICON_SIZE/2)
		var/Pixel_y=round(cos(Angle)+WORLD_ICON_SIZE*cos(Angle)*(N+WORLD_ICON_SIZE/2)/WORLD_ICON_SIZE)
		if(DX==0)
			Pixel_x=0
		if(DY==0)
			Pixel_y=0
		if(Pixel_x>WORLD_ICON_SIZE)
			for(var/a=0, a<=Pixel_x,a+=WORLD_ICON_SIZE)
				X.x++
				Pixel_x-=WORLD_ICON_SIZE
		if(Pixel_x<-WORLD_ICON_SIZE)
			for(var/a=0, a>=Pixel_x,a-=WORLD_ICON_SIZE)
				X.x--
				Pixel_x+=WORLD_ICON_SIZE
		if(Pixel_y>WORLD_ICON_SIZE)
			for(var/a=0, a<=Pixel_y,a+=WORLD_ICON_SIZE)
				X.y++
				Pixel_y-=WORLD_ICON_SIZE
		if(Pixel_y<-WORLD_ICON_SIZE)
			for(var/a=0, a>=Pixel_y,a-=WORLD_ICON_SIZE)
				X.y--
				Pixel_y+=WORLD_ICON_SIZE

		//Now that we've calculated the total offset in pixels, we move each beam parts to their closest corresponding turfs
		var/x_increm = 0
		var/y_increm = 0

		while(Pixel_x >= WORLD_ICON_SIZE || Pixel_x <= -WORLD_ICON_SIZE)
			if(Pixel_x > 0)
				Pixel_x -= WORLD_ICON_SIZE
				x_increm++
			else
				Pixel_x += WORLD_ICON_SIZE
				x_increm--

		while(Pixel_y >= WORLD_ICON_SIZE || Pixel_y <= -WORLD_ICON_SIZE)
			if(Pixel_y > 0)
				Pixel_y -= WORLD_ICON_SIZE
				y_increm++
			else
				Pixel_y += WORLD_ICON_SIZE
				y_increm--

		X.x += x_increm
		X.y += y_increm

		X.pixel_x=Pixel_x
		X.pixel_y=Pixel_y
		var/turf/TT = get_turf(X.loc)
		while((TT.timestopped || timestopped || X.timestopped) && count)
			sleep(2)
		if(TT == firer.loc)
			continue
		if(TT.density)
			qdel(X)
			X = null
			break
		for(var/atom/movable/O in TT)
			if(!O.Cross(src))
				qdel(X)
				broke = 1
				break
		for(var/mob/living/O in TT.contents)
			if(istype(O, /mob/living))
				if(O.density)
					qdel(X)
					X = null
					broke = 1
					break
		if(broke)
			if(X)
				qdel(X)
				X = null
			break
	spawn(10)
		for(var/atom/thing in ouroverlays)
			if(!thing.timestopped && thing.loc && !thing.loc.timestopped)
				ouroverlays -= thing
				returnToPool(thing)
	spawn
		var/tS = 0
		while(loc) //Move until we hit something
			if(tS)
				tS = 0
				timestopped = loc.timestopped
			while((loc.timestopped || timestopped) && !first)
				tS = 1
				sleep(3)
			if(first)
				icon = midicon
				if(timestopped || loc.timestopped)
					tS = 1
					timestopped = 0
			if((!( current ) || loc == current)) //If we pass our target
				broken = 1
				icon = endicon
				tang = adjustAngle(get_angle(original,current))
				if(tang > 180)
					tang -= 180
				else
					tang += 180
				icon_state = "[tang]"
				var/turf/simulated/floor/f = current
				if(f && istype(f))
					f.break_tile()
					f.hotspot_expose(1000,CELL_VOLUME,surfaces=1)
			if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
//				to_chat(world, "deleting")
				//del(src) //Delete if it passes the world edge
				broken = 1
				return
			if(kill_count < 1)
//				to_chat(world, "deleting")
				//del(src)
				broken = 1
			kill_count--
//			to_chat(world, "[x] [y]")
			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						icon = endicon
					if(!broken)
						tang = adjustAngle(get_angle(original,current))
						if(tang > 180)
							tang -= 180
						else
							tang += 180
						icon_state = "[tang]"
					to_bump(original)
			first = 0
			if(broken)
//				to_chat(world, "breaking")
				break
			else
				last = get_turf(src.loc)
				step_towards(src, current) //Move~
				if(src.loc != current)
					tang = adjustAngle(get_angle(src.loc,current))
				icon_state = "[tang]"
		if(ouroverlays.len)
			sleep(10)
			for(var/atom/thing in ouroverlays)
				ouroverlays -= thing
				returnToPool(thing)

		//del(src)
		returnToPool(src)

/*cleanup(reference) //Waits .3 seconds then removes the overlay.
//	to_chat(world, "setting invisibility")
	sleep(50)
	src.invisibility = 101
	return*/

/obj/item/projectile/beam/lightning/on_hit(atom/target, blocked = 0)
	if(istype(target, /mob/living))
		var/mob/living/M = target
		M.playsound_local(src, "explosion", 50, 1)
	..()

/obj/item/projectile/beam/lightning/spell
	var/spell/lightning/our_spell
	weaken = 0
	stun = 0
/obj/item/projectile/beam/lightning/spell/to_bump(atom/A as mob|obj|turf|area)
	. = ..()
	if(.)
		our_spell.lastbumped = A
	return .

/obj/item/projectile/beam/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"
	eyeblur = 2

/obj/item/projectile/beam/practice/stormtrooper
	fire_sound = "sound/weapons/blaster-storm.ogg"

/obj/item/projectile/beam/practice/stormtrooper/on_hit(var/atom/target, var/blocked = 0)
	if(..(target, blocked))
		var/mob/living/L = target
		var/message = pick("\the [src] narrowly whizzes past [L]!","\the [src] almost hits [L]!","\the [src] straight up misses its target.","[L]'s hair is singed off by \the [src]!","\the [src] misses [L] by a millimetre!","\the [src] doesn't hit","\the [src] misses its intended target.","[L] has a lucky escape from \the [src]!")
		target.loc.visible_message("<span class='danger'>[message]</span>")

/obj/item/projectile/beam/lightlaser
	name = "light laser"
	damage = 25

/obj/item/projectile/beam/weaklaser
	name = "weak laser"
	damage = 15

/obj/item/projectile/beam/veryweaklaser
	name = "very weak laser"
	damage = 5

/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 30
	kill_count = 500
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration = -1
	fire_sound = 'sound/weapons/laser3.ogg'

/obj/item/projectile/beam/xray/to_bump(atom/A)
	if(..())
		damage -= 3
		if(istype(A, /turf/simulated/wall/r_wall) || (istype(A, /obj/machinery/door/poddoor) && !istype(A, /obj/machinery/door/poddoor/shutters)))	//if we hit an rwall or blast doors, but not shutters, the beam dies
			bullet_die()
		if(damage <= 0)
			bullet_die()

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	destroy = 1
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/projectile/beam/deathlaser
	name = "death laser"
	icon_state = "heavylaser"
	damage = 60

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30

/obj/item/projectile/beam/emitter/singularity_pull()
	return

////////Laser Tag////////////////////
/obj/item/projectile/beam/lasertag
	name = "lasertag beam"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"
	icon_state = "bluelaser"
	var/list/enemy_vest_types = list(/obj/item/clothing/suit/redtag)

/obj/item/projectile/beam/lasertag/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if(is_type_in_list(M.wear_suit, enemy_vest_types))
			if(!M.lying) //Kick a man while he's down, will ya
				var/obj/item/weapon/gun/energy/tag/taggun = shot_from
				if(istype(taggun))
					taggun.score()
			M.Knockdown(5)
	return 1

/obj/item/projectile/beam/lasertag/blue
	icon_state = "bluelaser"
	enemy_vest_types = list(/obj/item/clothing/suit/redtag)

/obj/item/projectile/beam/lasertag/red
	icon_state = "laser"
	enemy_vest_types = list(/obj/item/clothing/suit/bluetag)

/obj/item/projectile/beam/lasertag/omni //A laser tag ray that stuns EVERYONE
	icon_state = "omnilaser"
	enemy_vest_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)



/obj/item/projectile/beam/bison
	name = "heat ray"
	damage_type = BURN
	flag = "laser"
	kill_count = 100
	layer = PROJECTILE_LAYER
	damage = 15
	icon = 'icons/obj/lightning.dmi'
	icon_state = "heatray"
	animate_movement = 0
	linear_movement = 0
	pass_flags = PASSTABLE
	var/drawn = 0
	var/tang = 0
	var/turf/last = null
	fire_sound = 'sound/weapons/bison_fire.ogg'

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
	target = get_turf(original)
	dist_x = abs(target.x - src.x)
	dist_y = abs(target.y - src.y)

	if (target.x > src.x)
		dx = EAST
	else
		dx = WEST

	if (target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH

	if(dist_x > dist_y)
		error = dist_x/2 - dist_y

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
				if(loc == target)
					if(!(original in permutated))
						draw_ray(target)
						to_bump(original)

	else
		error = dist_y/2 - dist_x
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
						to_bump(original)

/obj/item/projectile/beam/bison/bullet_die()
	draw_ray(loc)
	..()

/obj/item/projectile/beam/bison/proc/draw_ray(var/turf/lastloc)
	if(drawn)
		return
	drawn = 1
	var/atom/curr = lastloc
	if(!firer)
		firer = starting
	var/Angle=round(Get_Angle(firer,curr))
	var/icon/I=new('icons/obj/lightning.dmi',icon_state)
	var/icon/Istart=new('icons/obj/lightning.dmi',"[icon_state]start")
	var/icon/Iend=new('icons/obj/lightning.dmi',"[icon_state]end")
	I.Turn(Angle+45)
	Istart.Turn(Angle+45)
	Iend.Turn(Angle+45)
	var/DX=(WORLD_ICON_SIZE*curr.x+curr.pixel_x)-(WORLD_ICON_SIZE*firer.x+firer.pixel_x)
	var/DY=(WORLD_ICON_SIZE*curr.y+curr.pixel_y)-(WORLD_ICON_SIZE*firer.y+firer.pixel_y)
	var/N=0
	var/length=round(sqrt((DX)**2+(DY)**2))
	var/count = 0
	var/turf/T = get_turf(firer)
	var/timer_total = 16
	var/increment = timer_total/max(1,round(length/32))
	var/current_timer = 5

	for(N,N<(length+16),N+=WORLD_ICON_SIZE)
		if(count >= kill_count)
			break
		count++
		var/obj/effect/overlay/beam/X=getFromPool(/obj/effect/overlay/beam,T,current_timer,1)
		X.BeamSource=src
		current_timer += increment
		if((N+64>(length+16)) && (N+WORLD_ICON_SIZE<=(length+16)))
			X.icon=Iend
		else if(N==0)
			X.icon=Istart
		else if(N+WORLD_ICON_SIZE>(length+16))
			X.icon=null
		else
			X.icon=I


		var/Pixel_x=round(sin(Angle)+WORLD_ICON_SIZE*sin(Angle)*(N+WORLD_ICON_SIZE/2)/WORLD_ICON_SIZE)
		var/Pixel_y=round(cos(Angle)+WORLD_ICON_SIZE*cos(Angle)*(N+WORLD_ICON_SIZE/2)/WORLD_ICON_SIZE)
		if(DX==0)
			Pixel_x=0
		if(DY==0)
			Pixel_y=0
		if(Pixel_x>WORLD_ICON_SIZE)
			for(var/a=0, a<=Pixel_x,a+=WORLD_ICON_SIZE)
				X.x++
				Pixel_x-=WORLD_ICON_SIZE
		if(Pixel_x<-WORLD_ICON_SIZE)
			for(var/a=0, a>=Pixel_x,a-=WORLD_ICON_SIZE)
				X.x--
				Pixel_x+=WORLD_ICON_SIZE
		if(Pixel_y>WORLD_ICON_SIZE)
			for(var/a=0, a<=Pixel_y,a+=WORLD_ICON_SIZE)
				X.y++
				Pixel_y-=WORLD_ICON_SIZE
		if(Pixel_y<-WORLD_ICON_SIZE)
			for(var/a=0, a>=Pixel_y,a-=WORLD_ICON_SIZE)
				X.y--
				Pixel_y+=WORLD_ICON_SIZE

		//Now that we've calculated the total offset in pixels, we move each beam parts to their closest corresponding turfs
		var/x_increm = 0
		var/y_increm = 0

		while(Pixel_x >= WORLD_ICON_SIZE || Pixel_x <= -WORLD_ICON_SIZE)
			if(Pixel_x > 0)
				Pixel_x -= WORLD_ICON_SIZE
				x_increm++
			else
				Pixel_x += WORLD_ICON_SIZE
				x_increm--

		while(Pixel_y >= WORLD_ICON_SIZE || Pixel_y <= -WORLD_ICON_SIZE)
			if(Pixel_y > 0)
				Pixel_y -= WORLD_ICON_SIZE
				y_increm++
			else
				Pixel_y += WORLD_ICON_SIZE
				y_increm--

		X.x += x_increm
		X.y += y_increm
		X.pixel_x=Pixel_x
		X.pixel_y=Pixel_y
		var/turf/TT = get_turf(X.loc)
		if(TT == firer.loc)
			continue

/obj/item/projectile/beam/bison/to_bump(atom/A as mob|obj|turf|area)
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

/obj/item/projectile/beam/apply_projectile_color(var/color)
	beam_color = color

//Used by the pain mirror spell
//Damage type and damage done varies
/obj/item/projectile/beam/pain
	name = "bolt of pain"
	pass_flags = PASSALL //Go through everything
	icon_state = "pain"

/obj/item/projectile/beam/white
	icon_state = "whitelaser"

/obj/item/projectile/beam/rainbow/braindamage
	damage = 5
	icon_state = "whitelaser"

/obj/item/projectile/beam/rainbow/braindamage/on_hit(var/atom/target, var/blocked = 0)
	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(!(victim.mind && victim.mind.assigned_role == "Clown"))
			victim.adjustBrainLoss(20)
			victim.hallucination += 20

/obj/item/projectile/beam/bullwhip
	name = "bullwhip"
	icon_state = "whip"
	damage = 0
	fire_sound = null
	travel_range = 3
	bounce_sound = "sound/weapons/whip_crack.ogg"
	pass_flags = PASSTABLE
	var/obj/item/weapon/bullwhip/whip = null
	var/mob/user = null
	var/has_played_sound = FALSE

/obj/item/projectile/beam/bullwhip/New(atom/A, dir, var/spawning_whip, var/whipper)
	..(A,dir)
	whip = spawning_whip
	user = whipper
	if(!istype(whip) || !istype(user))
		spawn()
			returnToPool(src)

/obj/item/projectile/beam/bullwhip/on_hit(var/atom/atarget)
	whip.attack(atarget, user)
	user.delayNextAttack(10)
	has_played_sound = TRUE

/obj/item/projectile/beam/bullwhip/OnDeath()
	if(!has_played_sound && get_turf(src))
		playsound(get_turf(src), bounce_sound, 30, 1)
		user.delayNextAttack(2)

/obj/item/projectile/beam/liquid_stream
	name = "stream of liquid"
	icon_state = "liquid_stream"
	damage = 0
	fire_sound = null
	custom_impact = 1
	penetration = 0
	pass_flags = PASSTABLE
	var/has_splashed = FALSE

/obj/item/projectile/beam/liquid_stream/New(atom/A, var/t_range)
	..(A)
	create_reagents(10)
	if(t_range)
		travel_range = t_range
	else
		travel_range = 0

/obj/item/projectile/beam/liquid_stream/OnFired()
	beam_color = mix_color_from_reagents(reagents.reagent_list)
	alpha = mix_alpha_from_reagents(reagents.reagent_list)
	..()

/obj/item/projectile/beam/liquid_stream/to_bump(atom/A)
	if(!A)
		return
	..()
	if(reagents.total_volume)
		for(var/datum/reagent/R in reagents.reagent_list)
			reagents.add_reagent(R.id, reagents.get_reagent_amount(R.id))
		if(istype(A, /mob))
			var/splash_verb = pick("douses","completely soaks","drenches","splashes")
			A.visible_message("<span class='warning'>\The [src] [splash_verb] [A]!</span>",
								"<span class='warning'>\The [src] [splash_verb] you!</span>")
			splash_sub(reagents, get_turf(A), reagents.total_volume/2)
		else
			splash_sub(reagents, get_turf(src), reagents.total_volume/2)
		splash_sub(reagents, A, reagents.total_volume)
		has_splashed = TRUE
		return 1

/obj/item/projectile/beam/liquid_stream/OnDeath()
	if(!has_splashed && get_turf(src))
		splash_sub(reagents, get_turf(src), reagents.total_volume)

/obj/item/projectile/beam/liquid_stream/proc/adjust_strength(var/t_range)
	if(t_range)
		travel_range = t_range
	else
		travel_range = 0

/obj/item/projectile/beam/combustion
	name = "combustion beam"
	icon_state = "heavylaser"
	damage = 0
	fire_sound = 'sound/weapons/railgun_highpower.ogg'

/obj/item/projectile/beam/combustion/Bump(atom/A)
	if(!A)
		return
	..()
	var/turf/T = get_turf(A)
	explosion(T,0,0,5)
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(3, 0, T)
	smoke.start()
	return 1
