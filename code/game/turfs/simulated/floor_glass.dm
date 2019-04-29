/turf/simulated/floor/glass
	name = "glass floor"
	desc = "A floor made of reinforced glass, used for looking into the void."

	// Oldspace for people who don't have parallax.
	icon = 'icons/turf/space.dmi'
	icon_state = "0"

	plane = SPACE_BACKGROUND_PLANE
	dynamic_lighting = 0
	luminosity = 1
	intact = 0 // make pipes appear above space

	var/health=80 // 2x that of an rwindow
	var/sheetamount = 1 //Number of sheets needed to build this floor (determines how much shit is spawned via Destroy())
	var/cracked_base = "fcrack"
	var/shardtype = /obj/item/weapon/shard
	var/sheettype = /obj/item/stack/sheet/glass/rglass //Used for deconstruction
	var/glass_state = "glass_floor" // State of the glass itself.
	var/reinforced = 0
	var/construction_state = 2 // Fully constructed.
	var/static/list/floor_overlays = list()
	var/static/list/damage_overlays = list()
	var/image/current_damage_overlay

/turf/simulated/floor/glass/New(loc)
	..(loc)
	icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
	if(!floor_overlays[icon_state])
		var/image/floor_overlay = image('icons/turf/overlays.dmi', glass_state)
		floor_overlay.plane = TURF_PLANE
		floor_overlay.layer = TURF_LAYER
		floor_overlays[icon_state] = floor_overlay
	overlays += floor_overlays[icon_state]
	update_icon()

/turf/simulated/floor/glass/update_icon()
	var/current_health = health
	var/max_health = initial(health)
	if(current_health >= max_health)
		if(current_damage_overlay)
			overlays -= current_damage_overlay
			current_damage_overlay = null
		return
	var/damage_fraction = Clamp(round((max_health - current_health) / max_health * 5) + 1, 1, 5) //gives a number, 1-5, based on damagedness
	var/icon_state = "[cracked_base][damage_fraction]"
	if(!damage_overlays[icon_state])
		var/image/_damage_overlay = image('icons/obj/structures.dmi', icon_state)
		_damage_overlay.plane = TURF_PLANE
		_damage_overlay.layer = TURF_LAYER
		damage_overlays[icon_state] = _damage_overlay
	var/damage_overlay = damage_overlays[icon_state]
	if(current_damage_overlay == damage_overlay)
		return
	overlays -= current_damage_overlay
	current_damage_overlay = damage_overlay
	overlays += damage_overlay


/turf/simulated/floor/glass/examine(var/mob/user)
	..()
	if(health >= initial(health)) //Sanity
		to_chat(user, "It's in perfect shape without a single scratch.")
	else if(health >= 0.8*initial(health))
		to_chat(user, "It has a few scratches and a small impact.")
	else if(health >= 0.5*initial(health))
		to_chat(user, "It has a few impacts with some cracks running from them.")
	else if(health >= 0.2*initial(health))
		to_chat(user, "It's covered in impact marks and most of the outer layer is cracked.")
	else
		to_chat(user, "It's cracked over multiple layers and has many impact marks.")

/turf/simulated/floor/glass/proc/break_turf(var/no_teleport=FALSE)
	if(loc)
		playsound(src, "shatter", 70, 1)
	//ReplaceWithLattice()
	// TODO: Break all pipes/wires? //Maybe not, N3X.

	spawnBrokenPieces(src)
	ChangeTurf(/turf/space)

/turf/simulated/floor/glass/proc/spawnBrokenPieces(var/turf/T)
	getFromPool(shardtype, T, sheetamount)
	getFromPool(/obj/item/stack/rods, T, sheetamount+1) // Includes lattice

/turf/simulated/floor/glass/proc/healthcheck(var/mob/M, var/sound = 1, var/method="unknown", var/no_teleport=TRUE)
	if(health <= 0)
		if(M)
			var/pressure = 0
			if(src.zone)
				var/datum/gas_mixture/environment = src.return_air()
				pressure = environment.return_pressure()
			if (pressure > 0)
				message_admins("Glass floor with pressure [pressure]kPa broken (method=[method]) by [M.real_name] ([formatPlayerPanel(M,M.ckey)]) at [formatJumpTo(src)]!")
				log_admin("Window with pressure [pressure]kPa broken (method=[method]) by [M.real_name] ([M.ckey]) at [src]!")
			M.visible_message("<span class='danger'>[M] falls through the glass!</span>", "<span style='font-size:largest' class='danger'>\The [src] breaks!</span>", "You hear breaking glass.")
		break_turf(no_teleport)
	else
		if(sound)
			playsound(src, 'sound/effects/Glasshit.ogg', 100, 1)
		update_icon()


/turf/simulated/floor/glass/levelupdate()
	update_holomap_planes()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(FALSE) // ALWAYS show subfloor stuff.

/turf/simulated/floor/glass/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck(Proj.firer, TRUE, "bullet_act")
	return
/turf/simulated/floor/glass/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= rand(100, 150)
			healthcheck(method="ex_act", no_teleport=TRUE)
			return
		if(2.0)
			health -= rand(20, 50)
			healthcheck(method="ex_act", no_teleport=TRUE)
			return
		if(3.0)
			health -= rand(5, 15)
			healthcheck(method="ex_act", no_teleport=TRUE)
			return

/turf/simulated/floor/glass/Entered(var/atom/movable/mover)
	if(!reinforced  && istype(mover,/obj/mecha)) //OSHA spec glass flooring, woohoo
		var/obj/mecha/M = mover
		M.visible_message("<span class='warning'>\The [M] damages \the [src] with its sheer weight!</span>",
		"<span class='warning'>You damage \the [src] with your sheer weight!</span>",
		"<span class='italics'>You hear glass cracking!</span>")
		health -= rand(20, 40)
		healthcheck(M.occupant, FALSE, "mech weight")
	return 1

//Someone threw something at us, please advise
// I don't think this shit works on turfs, but it's here just in case.
/turf/simulated/floor/glass/hitby(AM as mob|obj)
	. =  ..()
	if(.)
		return
	if(ismob(AM))
		var/mob/M = AM //Duh
		health -= 10 //We estimate just above a slam but under a crush, since mobs can't carry a throwforce variable
		healthcheck(M, TRUE, "hitby")
		visible_message("<span class='danger'>\The [M] slams into \the [src].</span>", \
		"<span class='danger'>You slam into \the [src].</span>")
	else if(isobj(AM))
		var/obj/item/I = AM
		health -= I.throwforce
		healthcheck()
		visible_message("<span class='danger'>\The [I] slams into \the [src].</span>")
		healthcheck(null, TRUE, "hitby obj")

/turf/simulated/floor/glass/attack_hand(mob/living/user as mob)
	//Bang against the window
	if(usr.a_intent == I_HURT)
		if(M_HULK in user.mutations)
			user.do_attack_animation(src, user)
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
			user.visible_message("<span class='danger'>[user] smashes \the [src]!</span>")
			health -= 25
			healthcheck(user, TRUE, "attack_hand hulk")
			user.delayNextAttack(8)
			return
		user.do_attack_animation(src, user)
		user.delayNextAttack(10)
		playsound(src, 'sound/effects/glassknock.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] bangs against \the [src]!</span>", \
		"<span class='warning'>You bang against \the [src]!</span>", \
		"You hear banging.")
		healthcheck(user, TRUE, "attack_hand hurt")

	return

/turf/simulated/floor/glass/attack_paw(mob/user as mob)
	return attack_hand(user)

/turf/simulated/floor/glass/proc/attack_generic(mob/living/user as mob, damage = 0)	//used by attack_alien, attack_animal, and attack_slime

	user.do_attack_animation(src, user)
	user.delayNextAttack(10)
	health -= damage
	user.visible_message("<span class='danger'>\The [user] smashes into \the [src]!</span>", \
	"<span class='danger'>You smash into \the [src]!</span>")
	healthcheck(user, TRUE, "attack_generic")

/turf/simulated/floor/glass/attack_alien(mob/user as mob)
	if(islarva(user))
		return
	attack_generic(user, 15)

/turf/simulated/floor/glass/attack_animal(mob/user as mob)

	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)

/turf/simulated/floor/glass/attack_slime(mob/user as mob)
	if(!isslimeadult(user))
		return
	attack_generic(user, rand(10, 15))

/turf/simulated/floor/glass/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/weapon/grab) && Adjacent(user))
		if(handle_grabslam(W, user))
			return
	if(issilicatesprayer(W))
		return // Do nothing. (preattack based)
	switch(construction_state)
		if(2) // intact
			if(W.is_screwdriver(user))
				playsound(src, 'sound/items/Screwdriver.ogg', 75, 1)
				user.visible_message("<span class='warning'>[user] unfastens \the [src] from its frame.</span>", \
				"<span class='notice'>You unfasten \the [src] from its frame.</span>")
				construction_state -= 1
				return
		if(1)
			if(W.is_screwdriver(user))
				playsound(src, 'sound/items/Screwdriver.ogg', 75, 1)
				user.visible_message("<span class='notice'>[user] fastens \the [src] to its frame.</span>", \
				"<span class='notice'>You fasten \the [src] to its frame.</span>")
				construction_state += 1
				return
			if(iscrowbar(W))
				playsound(src, 'sound/items/Crowbar.ogg', 75, 1)
				user.visible_message("<span class='warning'>[user] pries \the [src] from its frame.</span>", \
				"<span class='notice'>You pry \the [src] from its frame.</span>")
				construction_state -= 1
				return
		if(0)
			if(iscrowbar(W))
				playsound(src, 'sound/items/Crowbar.ogg', 75, 1)
				user.visible_message("<span class='notice'>[user] pries \the [src] into its frame.</span>", \
				"<span class='notice'>You pry \the [src] into its frame.</span>")
				construction_state += 1
				return

			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				user.visible_message("<span class='notice'>[user] begins removing \the [src].</span>", \
				"<span class='notice'>You begin removing \the [src].</span>", \
				"<span class='warning'>You hear welding noises.</span>")
				if(WT.do_weld(user, src, 40, 0) && construction_state == 0)
					user.visible_message("<span class='notice'>[user] removes \the [src].</span>", \
					"<span class='notice'>You remove \the [src].</span>", \
					"<span class='warning'>You hear welding noises.</span>")
					var/pressure = 0
					if(src.zone)
						var/datum/gas_mixture/environment = src.return_air()
						pressure = environment.return_pressure()
					if (pressure > 0)
						message_admins("Glass floor with pressure [pressure]kPa deconstructed by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(src)]!")
						log_admin("Window with pressure [pressure]kPa deconstructed by [user.real_name] ([user.ckey]) at [src]!")

					getFromPool(sheettype, src, sheetamount)
					src.ReplaceWithLattice()
	if(ishuman(user) && user.a_intent != I_HURT)
		return
	unhandled_attackby(W, user)

/turf/simulated/floor/glass/proc/unhandled_attackby(var/obj/item/W, var/mob/user)
	user.do_attack_animation(src, W)
	if(W.damtype == BRUTE || W.damtype == BURN)
		user.delayNextAttack(10)
		health -= W.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>", \
		"<span class='warning'>You hit \the [src] with \the [W].</span>")
		healthcheck(user, TRUE, "attackby [W]")
		return TRUE
	return FALSE

/turf/simulated/floor/glass/proc/handle_grabslam(var/obj/item/weapon/grab/G, var/mob/user)
	if(istype(G.affecting, /mob/living))
		var/mob/living/M = G.affecting
		var/gstate = G.state
		returnToPool(G)	//Gotta delete it here because if window breaks, it won't get deleted
		user.do_attack_animation(src, G)
		switch(gstate)
			if(GRAB_PASSIVE)
				M.apply_damage(5) //Meh, bit of pain, window is fine, just a shove
				visible_message("<span class='warning'>\The [user] shoves \the [M] into \the [src]!</span>", \
				"<span class='warning'>You shove \the [M] into \the [src]!</span>")
			if(GRAB_AGGRESSIVE)
				M.apply_damage(10) //Nasty, but dazed and concussed at worst
				health -= 5
				visible_message("<span class='danger'>\The [user] slams \the [M] into \the [src]!</span>", \
				"<span class='danger'>You slam \the [M] into \the [src]!</span>")
			if(GRAB_NECK to GRAB_KILL)
				M.Stun(3)
				M.Knockdown(3) //Almost certainly shoved head or face-first, you're going to need a bit for the lights to come back on
				M.apply_damage(20) //That got to fucking hurt, you were basically flung into a window, most likely a shattered one at that
				health -= 20 //Window won't like that
				visible_message("<span class='danger'>\The [user] crushes \the [M] into \the [src]!</span>", \
				"<span class='danger'>You crush \the [M] into \the [src]!</span>")
		healthcheck(user, TRUE, "grabslam [user] -> [M]")
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been window slammed by [user.name] ([user.ckey]) ([gstate]).</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Window slammed [M.name] ([gstate]).</font>")
		msg_admin_attack("[user.name] ([user.ckey]) window slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		log_attack("[user.name] ([user.ckey]) window slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		return TRUE
	return FALSE

/turf/simulated/floor/glass/airless
	icon_state = "floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/glass/plasma
	name = "plasma glass floor"
	desc = "A floor made of reinforced plasma glass, used for looking into the void."
	shardtype = /obj/item/weapon/shard/plasma
	sheettype = /obj/item/stack/sheet/glass/plasmarglass
	glass_state = "plasma_glass_floor"
	health = 160
	reinforced=TRUE

/turf/simulated/floor/glass/plasma/airless
	icon_state = "floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
