/obj/structure/grille
	name = "grille"
	desc = "A matrix of metal rods, usually used as a support for window bays, with screws to secure it to the floor."
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = 1
	anchored = 1
	flags = FPRINT
	siemens_coefficient = 1
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = BELOW_OBJ_LAYER
	explosion_resistance = 5
	var/health = 20 //Relatively "strong" since it's hard to dismantle via brute force
	var/broken = 0
	var/grille_material = /obj/item/stack/rods

/obj/structure/grille/examine(mob/user)

	..()
	if(!anchored)
		to_chat(user, "Its screws are loose.")
	if(broken) //We're not going to bother with the damage
		to_chat(user, "It has been completely smashed apart, only a few rods are still holding together")

/obj/structure/grille/cultify()
	new /obj/structure/grille/cult(get_turf(src))
	returnToPool(src)

/obj/structure/grille/proc/healthcheck(var/hitsound = 0) //Note : Doubles as the destruction proc()
	if(hitsound)
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	if(health <= (0.25*initial(health)) && !broken) //Modular, 1/4th of original health. Do make sure the grille isn't broken !
		broken = 1
		icon_state = "[initial(icon_state)]-b"
		setDensity(FALSE) //Not blocking anything anymore
		new grille_material(get_turf(src)) //One rod set
	else if(health > (0.25*initial(health)) && broken) //Repair the damage to this bitch
		broken = 0
		icon_state = initial(icon_state)
		setDensity(TRUE)
	if(health <= 0) //Dead
		new grille_material(get_turf(src)) //Drop the second set of rods
		qdel(src)

/obj/structure/grille/ex_act(severity)
	switch(severity)
		if(1)
			health -= rand(30, 50)
		if(2)
			health -= rand(15, 30)
		if(3)
			health -= rand(5, 15)
	healthcheck(hitsound = 1)
	return

/obj/structure/grille/blob_act()
	anim(target = loc, a_icon = 'icons/mob/blob/blob.dmi', flick_anim = "blob_act", sleeptime = 15, lay = 12)
	health -= rand(initial(health)*0.8, initial(health)*3) //Grille will always be blasted, but chances of leaving things over
	healthcheck(hitsound = 1)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user))
		shock(user, 60) //Give the user the benifit of the doubt

/obj/structure/grille/hitby(AM as mob|obj)
	. = ..()
	if(.)
		return
	if(ismob(AM))
		var/mob/M = AM
		health -= 10
		healthcheck(TRUE)
		visible_message("<span class='danger'>\The [M] slams into \the [src].</span>", \
		"<span class='danger'>You slam into \the [src].</span>")
	else if(isobj(AM))
		var/obj/item/I = AM
		health -= I.throwforce
		healthcheck(TRUE)
		visible_message("<span class='danger'>\The [I] slams into \the [src].</span>")

/obj/structure/grille/attack_paw(mob/user as mob)
	attack_hand(user)

/obj/structure/grille/attack_hand(mob/user as mob)
	user.do_attack_animation(src, user)
	var/humanverb = pick(list("kick", "slam", "elbow")) //Only verbs with a third person "s", thank you
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] [humanverb]s \the [src].</span>", \
	"<span class='warning'>You [humanverb] \the [src].</span>", \
	"<span class='warning'>You hear twisting metal.</span>")
	if(M_HULK in user.mutations)
		health -= 5 //Fair hit
	else
		health -= 3 //Do decent damage, still not as good as using a real tool
	healthcheck(hitsound = 1)
	shock(user, 100) //If there's power running in the grille, allow the attack but grill the user

/obj/structure/grille/attack_alien(mob/user as mob)
	if(istype(user, /mob/living/carbon/alien/larva))
		return
	user.do_attack_animation(src, user)
	var/alienverb = pick(list("slam", "rip", "claw")) //See above
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] [alienverb]s \the [src].</span>", \
						 "<span class='warning'>You [alienverb] \the [src].</span>", \
						 "You hear twisting metal.")
	health -= 5
	healthcheck(hitsound = 1)
	shock(user, 75) //Ditto above

/obj/structure/grille/attack_slime(mob/user as mob)
	if(!istype(user, /mob/living/carbon/slime/adult))
		return
	user.do_attack_animation(src, user)
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] smashes against \the [src].</span>", \
						 "<span class='warning'>You smash against \the [src].</span>", \
						 "You hear twisting metal.")
	health -= 3
	healthcheck(hitsound = 1)
	shock(user, 100)
	return

/obj/structure/grille/attack_animal(var/mob/living/simple_animal/M as mob)
	M.delayNextAttack(8)
	if(M.melee_damage_upper == 0)
		return
	M.do_attack_animation(src, M)
	M.visible_message("<span class='warning'>[M] smashes against \the [src].</span>", \
					  "<span class='warning'>You smash against \the [src].</span>", \
					  "You hear twisting metal.")
	health -= rand(M.melee_damage_lower, M.melee_damage_upper)
	healthcheck(hitsound = 1)
	shock(M, 100)
	return


/obj/structure/grille/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || (height == 0))
		return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			var/obj/item/projectile/projectile = mover
			return prob(projectile.grillepasschance) //Fairly hit chance
		else
			return !density

/obj/structure/grille/projectile_check() //handled by the projectile's grillepasschance in Cross()
	return

/obj/structure/grille/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	health -= Proj.damage //Just use the projectile damage, it already has high odds of "missing"
	healthcheck(hitsound = 1)
	return 0

/obj/structure/grille/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if(isglasssheet(W))
		var/obj/item/stack/sheet/glass/G = W
		for(var/datum/stack_recipe/SR in G.recipes)
			if(ispath(SR.result_type, /obj/structure/window))
				var/obj/structure/window/S = SR.build(user,G,1,loc)
				if(S)
					S.forceMove(get_turf(src))
					S.dir = get_dir(src, user)
					S.ini_dir = S.dir
					return
		return
	if(iswirecutter(W))
		if(!shock(user, 100, W.siemens_coefficient)) //Prevent user from doing it if he gets shocked
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
			drop_stack(grille_material, get_turf(src), broken ? 1 : 2, user) //Drop the rods, taking account on whenever the grille is broken or not !
			qdel(src)
			return
		return //Return in case the user starts cutting and gets shocked, so that it doesn't continue downwards !
	else if((W.is_screwdriver(user)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90, W.siemens_coefficient))
			playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the grille [anchored ? "to" : "from"] the floor.</span>", \
			"<span class='notice'>You [anchored ? "fasten" : "unfasten"] the grille [anchored ? "to" : "from"] the floor.</span>")
			return
	var/dam = 0
	if(istype(W, /obj/item/weapon/fireaxe)) //Fireaxes instantly kill grilles
		dam = health
	else if(istype(W, /obj/item/weapon/shard))
		dam = W.force * 0.1 //Turns the base shard into a .5 damage item. If you want to break an electrified grille with that, you're going to EARN IT, ROD. BY. ROD.
	else
		switch(W.damtype)
			if("fire")
				dam = W.force //Fire-based tools like welding tools are ideal to work through small metal rods !
			if("brute")
				dam = W.force * 0.5 //Rod matrices have an innate resistance to brute damage

	if(!(W.sharpness_flags & INSULATED_EDGE))
		shock(user, 100 * W.siemens_coefficient, W.siemens_coefficient) //Chance of getting shocked is proportional to conductivity

	if(dam)
		user.do_attack_animation(src, W)
		visible_message("<span class='danger'>[user] hits [src] with [W].</span>")
	health -= dam
	healthcheck(hitsound = 1)
	..()
//Shock user with probability prb (if all connections & power are working)
//Returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user as mob, prb, siemens_coeff)
	if(!anchored || broken)	//De-anchored and destroyed grilles are never connected to the powernet !
		return 0
	if(!prob(prb)) //If the probability roll failed, don't go further
		return 0
	if(!Adjacent(user)) //To prevent TK and mech users from getting shocked
		return 0
	//Process the shocking via powernet, our job is done here
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, siemens_coeff))
			spark(src)
			return 1
		else
			return 0
	return 0

/obj/structure/grille/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 1500)
		health -= 1
		healthcheck() //Note : This healthcheck is silent, and it's going to stay that way
	..()

/obj/structure/grille/clockworkify()
	var/our_glow = broken ? BROKEN_REPLICANT_GRILLE_GLOW : REPLICANT_GRILLE_GLOW
	GENERIC_CLOCKWORK_CONVERSION(src, /obj/structure/grille/replicant, our_glow)

/obj/structure/grille/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"health",
		"broken")

	reset_vars_after_duration(resettable_vars, duration)

/obj/structure/grille/AltClick(var/mob/user)
	. = ..()
	var/turf/T = loc
	if (istype(T))
		if (user.listed_turf == T)
			user.listed_turf = null
		else
			user.listed_turf = T
			user.client.statpanel = T.name

//Mapping entities and alternatives !

/obj/structure/grille/broken //THIS IS ONLY TO BE USED FOR MAPPING, THANK YOU FOR YOUR UNDERSTANDING

	//We need to set all variables for broken grilles manually, notably to have those show up nicely in mapmaker
	icon_state = "grille-b"
	broken = 1
	density = 0 //Not blocking anything anymore

/obj/structure/grille/broken/New()
	..()
	health -= rand(initial(health)*0.8, initial(health)*0.9) //Largely under broken threshold, this is used to adjust the health, NOT to break it
	healthcheck() //Send this to healthcheck just in case we want to do something else with it

/obj/structure/grille/broken/healthcheck(var/hitsound = 0) //needed because initial icon_state for broken is grille-b for mapping
	..()
	if(broken)
		icon_state = "grille-b"
	else
		icon_state = "grille"

/obj/structure/grille/cult //Used to get rid of those ugly fucking walls everywhere while still blocking air

	name = "cult grille"
	desc = "A matrix built out of an unknown material, with some sort of force field blocking air around it"
	icon_state = "grillecult"
	health = 40 //Make it strong enough to avoid people breaking in too easily

/obj/structure/grille/cult/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || !broken)
		return 0 //Make sure air doesn't drain
	return ..()


/obj/structure/grille/invulnerable
	desc = "A reinforced grille made with advanced alloys and techniques. It's impossible to break one without the use of heavy machinery."

/obj/structure/grille/invulnerable/healthcheck(hitsound)
	return

/obj/structure/grille/invulnerable/ex_act()
	return

/obj/structure/grille/invulnerable/attackby()
	return

/obj/structure/grille/replicant
	name = "replicant grille"
	desc = "A strangely-shaped grille."
	icon_state = "replicantgrille"
	health = 30
	grille_material = /obj/item/stack/sheet/ralloy

/obj/structure/grille/replicant/cultify()
	return

/obj/structure/grille/replicant/clockworkify()
	return
