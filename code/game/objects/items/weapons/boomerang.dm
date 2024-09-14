
//////////////////////////////BOOMERANG ITEM////////////////////////////////

/obj/item/weapon/boomerang
	name = "boomerang"
	desc = "A heavy, curved piece of wood used by Space Australians for hunting, sport, entertainment, cooking, religious rituals and warfare. When thrown, it will either deal a devastating blow to somebody's head, or return back to the thrower." //also used for shitposting
	icon = 'icons/obj/boomerang.dmi'
	icon_state = "boomerang"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boomerang.dmi', "right_hand" = 'icons/mob/in-hand/right/boomerang.dmi')

	w_class = W_CLASS_MEDIUM
	force = 7
	throwforce = 10
	throw_range = 7
	throw_speed = 5

	starting_materials = list(MAT_WOOD = CC_PER_SHEET_WOOD * 6)
	w_type = RECYK_WOOD
	flammable = TRUE

	var/mob/living/carbon/originator = null
	var/thrown = FALSE
	var/throw_mult = 1
	var/stun = 0
	var/weaken = 2
	var/sound_throw = 'sound/weapons/boomerang_start.ogg'
	var/sound_loop = 'sound/weapons/boomerang_loop.ogg'
	var/sound_bump = 'sound/weapons/kick.ogg'
	var/last_sound_loop = 0

/obj/item/weapon/boomerang/proc/on_step(var/obj/O)
	if (world.time > (last_sound_loop+10))
		last_sound_loop = world.time
		playsound(loc,sound_loop, 35, 0)

/obj/item/weapon/boomerang/proc/return_check()//lets you add conditions for the boomerang to come back
	return TRUE

/obj/item/weapon/boomerang/proc/apply_status_effects(var/mob/living/carbon/C, var/minimal_effect = 0)
	var/obj/item/I = null
	if (ishuman(C))
		var/mob/living/carbon/human/H = C
		I = H.head
	else if (ismonkey(C))
		var/mob/living/carbon/monkey/M = C
		I = M.hat
	if (istype(I) && (I.armor["melee"] > 0 || I.armor["bullet"] > 0))
		return
	C.Stun(max(minimal_effect,stun))
	C.Knockdown(max(minimal_effect,weaken))

/obj/item/weapon/boomerang/proc/on_return()
	if (istype(originator) && clumsy_check(originator) && prob(30))
		to_chat(originator, "<span class='warning'>Your clumsy hands fail to catch \the [src]!")
		apply_status_effects(originator,1)
		playsound(src, throw_impact_sound, 80, 1)
		log_attack("<font color='red'>[originator] ([originator ? originator.ckey : "what"]) was hit by [src] thrown by themselves because they're just that clumsy.</font>")
		return TRUE
	return (istype(originator) && originator.can_catch(src, throw_speed*throw_mult) && originator.put_in_hands(src))

/obj/item/weapon/boomerang/pickup(var/mob/user)
	thrown = FALSE

/obj/item/weapon/boomerang/dropped(var/mob/user)
	reset_plane_and_layer()

/obj/item/weapon/boomerang/attack_self(var/mob/living/user)
	if (!user.in_throw_mode)
		user.throw_mode_on()

/obj/item/weapon/boomerang/pre_throw(var/atom/movable/target, var/mob/living/user)
	thrown = TRUE
	throw_mult = 1
	playsound(loc,sound_throw, 70, 0)
	if (user)
		originator = user
		if(ishuman(originator))
			var/mob/living/carbon/human/H = originator
			throw_mult = H.species.throw_mult
			throw_mult += (H.get_strength()-1)/2 //For each level of strength above 1, add 0.5
	return ..()

/obj/item/weapon/boomerang/throw_at(var/atom/targ, var/range, var/speed, var/override = 1, var/fly_speed = 0)
	var/turf/starting = get_turf(src)
	var/turf/target = get_turf(targ)
	var/obj/item/projectile/boomerang/B = new (starting)
	B.name = name
	B.desc = desc
	B.original = target
	B.target = target
	B.current = starting
	B.starting = starting
	B.yo = target.y - starting.y
	B.xo = target.x - starting.x
	//B.damage = throwforce //Actual damage is down by calls to throw_impact(). The projectile damage should remain at zero unless you want to break open crates with it
	B.projectile_speed = 0.66/throw_mult
	B.icon_state = "[icon_state]-spin"
	B.overlays += overlays
	B.plane = plane
	B.color = color
	B.luminosity = luminosity
	B.firer = originator
	B.stun = stun
	B.kill_count = throw_range
	B.weaken = weaken
	B.OnFired()
	B.process()
	B.boomerang = src
	forceMove(B)

/obj/item/weapon/boomerang/apply_inertia(direction)
	if (!thrown)
		return ..()

//////////////////////////////BOOMERANG PROJECTILE - INITIAL////////////////////////////////

/obj/item/projectile/boomerang
	name = "boomerang"
	icon = 'icons/obj/boomerang.dmi'
	icon_state = "boomerang-spin"
	damage = 0
	flag = "energy"
	custom_impact = 1
	projectile_speed = 0.66
	lock_angle = 1
	kill_count = 7
	grillepasschance = 0
	var/obj/item/weapon/boomerang/boomerang
	var/list/hit_atoms = list()

/obj/item/projectile/boomerang/to_bump(var/atom/A)
	if (!(A in hit_atoms))
		hit_atoms += A
		if (boomerang)
			boomerang.throw_impact(A,boomerang.throw_speed*boomerang.throw_mult,boomerang.originator)
			if (boomerang.loc != src)//boomerang got grabbed most likely
				boomerang.originator = null
				boomerang = null
				qdel(src)
				return
			else if (iscarbon(A))
				boomerang.apply_status_effects(A)
				forceMove(A.loc)
				A.Bumped(boomerang)
				bumped = TRUE
				bullet_die()
				return
			A.Bumped(boomerang)
	return ..(A)

/obj/item/projectile/boomerang/OnDeath()
	if (boomerang && bumped)
		playsound(loc,boomerang.sound_bump, 50, 1)
	return_to_sender()

/obj/item/projectile/boomerang/on_step()
	if (boomerang && !boomerang.gcDestroyed)
		boomerang.on_step(src)
	else
		bullet_die()

/obj/item/projectile/boomerang/proc/return_to_sender()
	if (!boomerang)
		qdel(src)
		return
	var/turf/T = get_turf(src)
	if (!boomerang.return_check())
		boomerang.forceMove(T)
		boomerang.thrown = FALSE
		boomerang.dropped()
		boomerang = null
		return
	//if there is no air, no return trip
	var/datum/gas_mixture/current_air = T.return_air()
	var/atmosphere = 0
	if(current_air)
		atmosphere = current_air.return_pressure()

	if (atmosphere < ONE_ATMOSPHERE/2)
		visible_message("\The [boomerang] dramatically fails to come back due to the lack of air pressure.")
		boomerang.forceMove(T)
		boomerang.thrown = FALSE
		boomerang.dropped()
		boomerang = null
		return

	var/atom/return_target
	if (firer)
		if (isturf(firer.loc) && (firer.z == z) && (get_dist(firer,src) <= 26))
			return_target = firer

	if (!return_target)
		return_target = starting

	var/obj/effect/tracker/boomerang/Tr = new (T)
	Tr.target = return_target
	Tr.appearance = appearance
	Tr.refresh = projectile_speed
	Tr.luminosity = luminosity
	Tr.boomerang = boomerang
	Tr.hit_atoms = hit_atoms.Copy()
	boomerang.forceMove(Tr)
	boomerang = null

//////////////////////////////BOOMERANG TRACKER - RETURN////////////////////////////////

/obj/effect/tracker/boomerang
	name = "boomerang"
	icon = 'icons/obj/boomerang.dmi'
	icon_state = "boomerang-spin"
	mouse_opacity = 1
	density = 1
	pass_flags = PASSTABLE | PASSRAILING
	var/obj/item/weapon/boomerang/boomerang
	var/list/hit_atoms = list()

/obj/effect/tracker/boomerang/Destroy()
	var/turf/T = get_turf(src)
	if (T && boomerang)
		boomerang.forceMove(T)
		boomerang.thrown = FALSE
		boomerang.dropped()
		boomerang.originator = null
		boomerang = null
	..()

/obj/effect/tracker/boomerang/on_step()
	if (boomerang && !boomerang.gcDestroyed)
		boomerang.on_step(src)
	else
		qdel(src)

/obj/effect/tracker/boomerang/Bumped(var/atom/movable/AM)
	make_contact(AM)

/obj/effect/tracker/boomerang/to_bump(var/atom/Obstacle)
	return make_contact(Obstacle)

/obj/effect/tracker/boomerang/proc/make_contact(var/atom/Obstacle)
	if (boomerang)
		if (!(Obstacle in hit_atoms))
			hit_atoms += Obstacle
			if (Obstacle == boomerang.originator)
				if (on_expire(FALSE))
					qdel(src)
					return TRUE
			boomerang.throw_impact(Obstacle,boomerang.throw_speed*boomerang.throw_mult,boomerang.originator)
			if (boomerang.loc != src)//boomerang got grabbed most likely
				boomerang.originator = null
				boomerang = null
				qdel(src)
				return TRUE
			else if (iscarbon(Obstacle))
				boomerang.apply_status_effects(Obstacle)
				return FALSE
			Obstacle.Bumped(boomerang)
			if (!ismob(Obstacle))
				on_expire(TRUE)
				qdel(src)
				return TRUE
		return FALSE
	else
		qdel(src)
		return FALSE

/obj/effect/tracker/boomerang/on_expire(var/bumped_atom = FALSE)
	if (boomerang && boomerang.originator && Adjacent(boomerang.originator))
		if (boomerang.on_return())
			playsound(loc,'sound/effects/slap2.ogg', 15, 1)
			if (boomerang)
				boomerang.originator = null
			boomerang = null
			return TRUE
	else if (boomerang && bumped_atom)
		playsound(loc,boomerang.sound_bump, 50, 1)
	return FALSE



//////////////////////////////BOOMERANG SUB-TYPES////////////////////////////////

//Toy
/obj/item/weapon/boomerang/toy
	name = "toy boomerang"
	desc = "A small plastic boomerang for children."

	icon_state = "boomerang_toy"

	w_class = W_CLASS_SMALL

	throwforce = 2
	force = 1
	stun = 0
	weaken = 0

	sound_bump = 'sound/effects/pop.ogg'
	throw_impact_sound = 'sound/weapons/tap.ogg'

	starting_materials = list(MAT_PLASTIC = 1200)
	melt_temperature = MELTPOINT_PLASTIC
	w_type = RECYK_PLASTIC

//Castlevania, deals double damage to supernatural mobs
/obj/item/weapon/boomerang/cross
	name = "battle cross"
	desc = "A holy silver cross that dispels evil and smites unholy creatures."

	icon_state = "cross_modern"

	starting_materials = list(MAT_SILVER = CC_PER_SHEET_SILVER * 16)
	melt_temperature = MELTPOINT_SILVER
	w_type = 0
	luminosity = 2

	stun = 1
	weaken = 2

	sound_throw = 'sound/weapons/boomerang_cross_start.ogg'
	sound_loop = 'sound/weapons/boomerang_cross_loop.ogg'

	var/flickering = 0
	var/classic = FALSE

/obj/item/weapon/boomerang/cross/New()
	..()
	update_moody_light(icon, "[icon_state]-moody")

/obj/item/weapon/boomerang/throw_at(var/atom/targ, var/range, var/speed, var/override = 1, var/fly_speed = 0)
	plane = ABOVE_LIGHTING_PLANE
	..()

/obj/item/weapon/boomerang/cross/on_step(var/obj/O)
	..()
	dir = turn(dir, 45)
	var/obj/effect/afterimage/A = new(O.loc, O, fadout = 5, initial_alpha = 100, pla = ABOVE_LIGHTING_PLANE)
	A.icon_state = icon_state
	A.dir = dir
	A.layer = O.layer - 1
	A.color = "#1E45FF"
	if (istype(O,/obj/effect/tracker))//only display those particles on the way back
		A.add_particles(PS_CROSS_DUST)
		A.add_particles(PS_CROSS_ORB)

	flickering = (flickering + 1) % 4
	if (flickering > 1)
		O.color = "#53A6FF"
	else
		O.color = null

/obj/item/weapon/boomerang/cross/return_check()
	if (originator && originator.mind)
		if (istype(originator.mind.faith, /datum/religion/belmont))
			return TRUE
		to_chat(originator, "<span class='rose'>Only a true vampire hunter may use \the [src] to its full potential.</span>")
	return FALSE

/obj/item/weapon/boomerang/cross/throw_impact(var/atom/hit_atom, var/speed, var/mob/user, var/list/impact_whitelist)
	if(istype(hit_atom,/obj/machinery/computer/arcade))
		playsound(hit_atom,'sound/weapons/boomerang_cross_transform.ogg', 30, 0)
		classic = !classic
		icon_state = "[classic ? "cross_classic" : "cross_modern"]"
		if (istype(loc,/obj))
			var/obj/O = loc
			O.icon_state = "[icon_state]-spin"
		update_moody_light(icon, "[icon_state]-moody")
	..()

//Kamina
/obj/item/weapon/boomerang/kaminaglasses
	name = "Kamina's glasses"
	desc = "I'm going to tell you something important now, so you better dig the wax out of those huge ears of yours and listen! The reputation of Team Gurren echoes far and wide. When they talk about its badass leader - the man of indomitable spirit and masculinity - they're talking about me! The mighty Kamina!"

	icon_state = "kaminaglasses"

	throwforce = 15
	force = 10
	stun = 0
	weaken = 0

	sound_bump = 'sound/effects/Glasshit.ogg'
	throw_impact_sound = 'sound/weapons/bladeslice.ogg'

	w_type = RECYK_GLASS
	starting_materials = list(MAT_GLASS = CC_PER_SHEET_GLASS/2)
	melt_temperature = MELTPOINT_GLASS

	var/obj/item/clothing/glasses/kaminaglasses/KG = null

/obj/item/weapon/boomerang/kaminaglasses/Destroy()
	playsound(get_turf(src),'sound/effects/lagann_eyecatch2.ogg', 30, 0)
	..()

/obj/item/weapon/boomerang/kaminaglasses/dropped(var/mob/user)
	if (!thrown)
		if (KG)
			KG.forceMove(get_turf(src))
			KG = null
		qdel(src)
	else
		..()

/obj/item/weapon/boomerang/kaminaglasses/on_return()
	if (istype(originator) && KG)
		if (KG.mob_can_equip(originator, slot_glasses, TRUE) == CAN_EQUIP)
			originator.equip_to_slot(KG, slot_glasses)
			KG = null
			loc = originator.loc//just to be sure that the sound is centered on them
			qdel(src)
			return TRUE
	return ..()

//Simon
/obj/item/weapon/boomerang/kaminaglasses/simonglasses
	name = "Simon's glasses"
	desc = "Just who the hell do you think I am?"

	icon_state = "simonglasses"
