/obj/machinery/power/solar/panel
	name = "solar panel"
	desc = "Generates power to the cables underneath it based on its current alignment with the nearest star."
	icon = 'icons/obj/power.dmi'
	icon_state = "solars"
	appearance_flags = PIXEL_SCALE
	id_tag = 0
	penetration_dampening = 1 // Fragile
	health = 15 //Fragile shit, even with state-of-the-art reinforced glass
	maxHealth = 15 //If ANYONE ever makes it so that solars can be directly repaired without glass, also used for fancy calculations
	plane = ABOVE_HUMAN_PLANE
	layer = LIGHT_FIXTURE_LAYER
	//originally FLY_LAYER
	luminosity = 1
	var/obscured = 0
	var/sunfrac = 0
	var/adir = 180	//the current orientation of the panel (in degrees). Can be set in the map editor to have panels pre-rotated. 0 is north, 90 is east, 180 is south, 270 is west.
	var/ndir = 180	//the target orientation of the panel (in degrees)
	var/rotation_speed = 10	//how many degrees at most can the panel rotate per process()
	var/turn_angle = 0
	var/glass_quality_factor = 1 //Rglass is average. Glass is shite. Tinted glass is "Are you even trying?" tier if anyone ever makes a sheet version
	var/tracker = 0
	var/obj/machinery/power/solar/control/control
	var/obj/machinery/power/solar_assembly/solar_assembly
	var/image/base
	var/image/glow
	var/image/progbar = null	//progress bar for manual rotation
	var/mob/manual_user = null
	var/starting_angle	//tracking the starting angle of a manual rotation for progress bar purposes
	var/target_angle	//tracking the target angle of a manual rotation for progress bar purposes

	var/pulse = 0.2	//color matrix stuff
	var/glow_intensity = 100	//max alpha of the glow when the panel is aligned with the star

/obj/machinery/power/solar/panel/New(loc, var/obj/machinery/power/solar_assembly/S)
	..(loc)
	make(S)
	update_icon()
	//initialize() called by the parent New()

/obj/machinery/power/solar/panel/initialize()
	..()
	base = image(icon, src, "sp_base")
	base.appearance_flags = RESET_TRANSFORM|RESET_ALPHA|RESET_COLOR
	base.plane = relative_plane(OBJ_PLANE)
	underlays += base
	glow = image(icon, src, "solar_glow[tracker]")
	glow.blend_mode = BLEND_ADD
	var/matrix/glow_matrix = matrix()
	glow.transform = glow_matrix.Scale(1.2)
	transform = turn(matrix(), adir)
	if (sun)
		sun.occlusion(src)//calls update_solar_exposure and update_icon
	else
		update_solar_exposure()
		update_icon()

/obj/machinery/power/solar/panel/Destroy()
	manual_user = null//just to be sure
	..()

/obj/machinery/power/solar/panel/proc/make(var/obj/machinery/power/solar_assembly/S)
	if(!S)
		solar_assembly = new /obj/machinery/power/solar_assembly()
		solar_assembly.glass_type = /obj/item/stack/sheet/glass/rglass
		solar_assembly.anchored = 1
		solar_assembly.tracker = tracker
	else
		solar_assembly = S
		var/obj/item/stack/sheet/glass/G = solar_assembly.glass_type //This is how you call up variables from an object without making one
		glass_quality_factor = initial(G.glass_quality) //Don't use istype checks kids
		maxHealth = initial(G.shealth)
		health = initial(G.shealth)
	solar_assembly.forceMove(src)

/obj/machinery/power/solar/panel/attack_hand(var/mob/user)
	to_chat(user,"<span class='info'>You could disassemble the panel with a crowbar, or manually adjust its rotation with a wrench.</span>")

/obj/machinery/power/solar/panel/attackby(obj/item/weapon/W, mob/user)
	if(iscrowbar(W))
		var/turf/T = get_turf(src)
		var/obj/item/stack/sheet/glass/G = solar_assembly.glass_type
		to_chat(user, "<span class='notice'>You begin taking the [initial(G.name)] off the [src].</span>")
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, src, 50))
			if(solar_assembly)
				solar_assembly.forceMove(T)
				solar_assembly.give_glass()
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] takes the [initial(G.name)] off the [src].</span>",\
			"<span class='notice'>You take the [initial(G.name)] off the [src].</span>")
			qdel(src)
	else if(iswrench(W) && !tracker)
		if (manual_user)
			if (manual_user == user)
				to_chat(user, "<span class='warning'>You are already rotating this solar panel.</span>")
			else
				to_chat(user, "<span class='warning'>Someone else is currently rotating this solar panel.</span>")
		else
			var/target = input("Which orientation (in degrees) do you want the panel to face?","Set Orientation",adir) as num|null
			if (!isnull(target) && !manual_user && Adjacent(user) && iswrench(user.get_active_hand()) && !user.incapacitated())
				target = (360 + clamp(target,-360,360)) % 360//sanitizing
				to_chat(user, "<span class='notice'>You begin rotating the solar panel.</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
				starting_angle = adir
				target_angle = target
				update_progbar()
				manual_user = user
				if (user.client)
					user.client.images |= progbar
				spawn()
					ndir = target
					manual_rotation(user, target)
	else if(W)
		user.do_attack_animation(src, user)
		shake(1, 3)
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		add_hiddenprint(user)
		user.delayNextAttack(10)
		user.visible_message("<span class='warning'>[user] smashes \the [src] with \a [W].</span>", \
							 "<span class='warning'>You smash \the [src] with \a [W].</span>")
		health -= W.force
		healthcheck()
	..()

/obj/machinery/power/solar/panel/proc/panel_rotation(var/target, var/speed)
	if(adir != target)
		// Take the shortest rotation possible
		var/direction = ((abs(target - adir) < 180) ? (target - adir) : (adir - target))
		adir = (360 + adir + clamp(clamp(direction,-1*(360 - max(target,adir) + min(target,adir)),360 - max(target,adir) + min(target,adir)), -speed, speed)) % 360
		//the extra 360 ensures the result of the % is positive
		//the inside clamp() prevents the rotation from overshooting its target if it passes the 0°|360° mark
		update_solar_exposure()
		update_icon()

/obj/machinery/power/solar/panel/proc/manual_rotation(var/mob/living/carbon/human/user, var/target_rotation)
	panel_rotation(target_rotation, rotation_speed * 3)
	update_progbar()
	sleep(20)
	if(adir != target_rotation)
		if (Adjacent(user) && iswrench(user.get_active_hand()) && !user.incapacitated())
			manual_rotation(user, target_rotation)
			return
		else
			to_chat(user,"<span class='warning'>You abort the rotation of the panel.</span>")
	else
		to_chat(user,"<span class='notice'>You finish rotating the panel.</span>")
	manual_user = null
	if (user.client)
		user.client.images -= progbar

/obj/machinery/power/solar/panel/proc/update_progbar()
	if (!progbar)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = src, "icon_state" = "prog_bar_0")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.pixel_x = 16 * PIXEL_MULTIPLIER
		progbar.pixel_y = 16 * PIXEL_MULTIPLIER
		progbar.appearance_flags = RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM
		progbar.layer = HUD_ABOVE_ITEM_LAYER

	var/total_degrees = abs(starting_angle - target_angle)
	var/remaining_degrees  = abs(adir - target_angle)

	if (total_degrees > 180)
		total_degrees = 360 - max(starting_angle,target_angle) + min(starting_angle,target_angle)
	if (remaining_degrees > 180)
		remaining_degrees = 360 - max(adir,target_angle) + min(adir,target_angle)
	total_degrees = max(1, total_degrees)
	progbar.icon_state = "prog_bar_[round((100 - min(1, remaining_degrees / total_degrees) * 100), 10)]"

/obj/machinery/power/solar/panel/attack_animal(var/mob/living/simple_animal/user)
	user.do_attack_animation(src, user)
	shake(1, 3)
	playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] smashes \the [src].</span>", \
						 "<span class='warning'>You smash \the [src].</span>")
	health -= user.get_unarmed_damage(src)
	healthcheck()

/obj/machinery/power/solar/panel/attack_alien(var/mob/living/carbon/alien/humanoid/user)
	if(istype(user, /mob/living/carbon/alien/larva))
		return
	user.do_attack_animation(src, user)
	shake(1, 3)
	playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
	user.delayNextAttack(8)
	var/alienverb = pick(list("slam", "rip", "claw"))
	user.visible_message("<span class='warning'>[user] [alienverb]s \the [src].</span>", \
						 "<span class='warning'>You [alienverb] \the [src].</span>")
	health -= rand(15,30)
	healthcheck()

/obj/machinery/power/solar/panel/blob_act()
	if(prob(30))
		broken() //Good hit
	else
		health--
	healthcheck()

/obj/machinery/power/solar/panel/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		health -= Proj.damage
		healthcheck()
	return ..()

/obj/machinery/power/solar/panel/proc/healthcheck()
	if(health <= 0)
		if(!(stat & BROKEN) && health > -maxHealth)
			broken()
		else
			var/obj/item/stack/sheet/glass/G = solar_assembly.glass_type
			var/shard = initial(G.shard_type)
			solar_assembly.glass_type = null //The glass you're looking for is below pal
			solar_assembly.forceMove(get_turf(src))
			new shard(loc)
			new shard(loc)
			qdel(src)
			return
	update_icon()

/obj/machinery/power/solar/panel/update_icon()
	..()
	underlays.len = 0
	underlays += base
	if(!tracker)
		if (solar_assembly)
			var/obj/item/stack/sheet/glass/G = solar_assembly.glass_type
			var/panel = "solar_panel_" + initial(G.sname)
			if(stat & BROKEN)
				panel += "-b"
			else if (health < maxHealth)
				panel += "-d"//damaged panels generate less power so we might as well help players notice those
			icon_state = panel

		var/illumination = (pulse * sunfrac * max(0,health/maxHealth)) - (pulse/2)
		animate(src, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,illumination,illumination,illumination,0), transform = turn(matrix(), adir), time = 20)

		overlays.len = 0
		if ((sunfrac > 0) && !(stat & BROKEN))
			glow.alpha = sunfrac * max(0,health/maxHealth) * glow_intensity
			overlays += glow
	else
		overlays.len = 0
		icon_state = "tracker"
		if(stat & BROKEN)
			icon_state += "-b"
		else if(obscured)
			icon_state += "-dark"
		else
			glow.transform = turn(matrix(), (sun.angle + 180) % 360)
			glow.alpha = glow_intensity
			overlays += glow


/obj/machinery/power/solar/panel/proc/update_solar_exposure()
	if(!sun)
		obscured = 1

	if(obscured)
		sunfrac = 0
		plane = ABOVE_HUMAN_PLANE
		layer = LIGHT_FIXTURE_LAYER
		return

	plane = ABOVE_LIGHTING_PLANE
	layer = ABOVE_LIGHTING_LAYER

	var/p_angle = abs(sun.angle - adir)

	if (p_angle > 180)
		p_angle = 360 - max(sun.angle, adir) + min(sun.angle, adir)

	if(p_angle > 90)			//If facing more than 90deg from sun, zero output
		sunfrac = 0
		return

	sunfrac = cos(p_angle) ** 2

/obj/machinery/power/solar/panel/process()//TODO: remove/add this from machines to save on processing as needed ~Carn PRIORITY
	if(stat & BROKEN)
		return

	if(control && !(control.stat & (NOPOWER | BROKEN | FORCEDISABLE)))
		panel_rotation(ndir, rotation_speed)//automatic panel rotation only occurs when connected to a solar panel control computer

	if(obscured)
		return//no line of sight to the star? no power.

	var/sgen = SOLARGENRATE * sunfrac * glass_quality_factor * (health / maxHealth) //Raw generating power * Sun angle effect * Glass quality * Current panel health. Simple but thorough

	add_avail(sgen)

	if(powernet && control)
		if(powernet.nodes.Find(control))
			control.gen += sgen

/obj/machinery/power/solar/panel/proc/broken()
	stat |= BROKEN
	update_icon()

	if(health > 1)
		health = 1 //Only holding up on shards and scrap

/obj/machinery/power/solar/panel/ex_act(severity)
	switch(severity)
		if(1)
			solar_assembly.glass_type = null //The glass you're looking for is below pal
			if(prob(15))
				new /obj/item/weapon/shard(loc)
			kill()
		if(2)
			if(prob(25))
				solar_assembly.glass_type = null //The glass you're looking for is below pal
				new /obj/item/weapon/shard(loc)
				kill()
			else
				broken()
		if(3)
			if(prob(35))
				broken()
			else
				health-- //Let shrapnel have its effect
				healthcheck()

/obj/machinery/power/solar/panel/emp_act(var/severity)
	if(stat & (BROKEN))
		return
	switch(severity)
		if(1)
			if(prob(30))
				broken()
			ndir = rand(adir-90,adir+90)
			panel_rotation(ndir, 90)
		if(2)
			ndir = rand(adir-45,adir+45)
			panel_rotation(ndir, 45)

/obj/machinery/power/solar/panel/proc/kill() //To make sure you eliminate the assembly as well
	if(solar_assembly)
		var/obj/machinery/power/solar_assembly/assembly = solar_assembly
		solar_assembly = null
		qdel(assembly)
	qdel(src)

/obj/machinery/power/solar/panel/disconnect_from_network()
	. = ..()

	if(.)
		control = null
