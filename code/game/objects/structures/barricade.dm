/*
 * Wooden barricades have been reworked. You can now make forts with them
 * Or at least, build a lot of interesting things
 * Also the base tile type is a "pane", just like windows
 * And you have special sub-types that go on windows
 * This really shouldn't be in here
 */

/obj/structure/barricade
	name = "wood barricade"
	desc = "A barricade made out of wood planks, it looks like it can take a few solid hits."
	icon = 'icons/obj/barricade.dmi'
	icon_state = "barricade"
	anchored = 1
	density = 1
	layer = 3.2 //Same as windows
	var/health = 100 //Pretty strong
	var/maxhealth = 100
	var/sheetamount = 1 //Number of sheets needed to build this barricade (determines how much shit is spawned via Destroy())
	var/busy = 0 //Oh god fucking do_after's

	var/fire_temp_threshold = 100 //Wooden barricades REALLY don't like fire
	var/fire_volume_mod = 10 //They REALLY DON'T

/obj/structure/barricade/New(loc)

	..(loc)
	flags |= ON_BORDER
	update_icon()

/obj/structure/barricade/examine(mob/user)

	..()
	//Switch most likely can't take inequalities, so here's that if block
	if(health >= initial(health)) //Sanity
		user << "It's in perfect shape, not even a scratch."
	else if(health >= 0.8*initial(health))
		user << "It has a few splinters and a plank is broken."
	else if(health >= 0.5*initial(health))
		user << "It has a fair amount of splinters and broken plants."
	else if(health >= 0.2*initial(health))
		user << "It has most of its planks broken, you can barely tell how much weight the support beams are bearing."
	else
		user << "It has only one or two planks still in shape, it's a miracle it's even standing."

//New standard proc for directional structures, I guess
/obj/structure/barricade/proc/is_fulltile()

	return 0


//Allows us to quickly check if we should break the barricade, can handle not having an user
//Sound is technically deprecated, but barricades should really have a build sound
/obj/structure/barricade/proc/healthcheck(var/mob/M, var/sound = 1)

	if(health <= 0)
		Destroy()

//This ex_act just removes health to be fully modular in general
/obj/structure/barricade/ex_act(severity)

	switch(severity)
		if(1.0) //Certain kill
			health -= rand(100, 150)
			healthcheck()
			return
		if(2.0)
			health -= rand(20, 50)
			healthcheck()
			return
		if(3.0)
			health -= rand(5, 15)
			healthcheck()
			return

/obj/structure/barricade/blob_act()

	health -= rand(30, 50)
	healthcheck()

/obj/structure/barricade/bullet_act(var/obj/item/projectile/Proj)

	health -= Proj.damage
	..()
	healthcheck(Proj.firer)
	return

/obj/structure/barricade/CheckExit(var/atom/movable/O, var/turf/target)

	if(istype(O) && O.checkpass(PASSGLASS)) //PASSGLASS is fine in that case
		return 1
	if(get_dir(O.loc, target) == dir)
		return !density
	return 1

/obj/structure/barricade/CanPass(atom/movable/mover, turf/target, height = 0)

	if(istype(mover) && mover.checkpass(PASSGLASS)) //PASSGLASS is fine in that case
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	return 1

//Someone threw something at us, please advise
/obj/structure/barricade/hitby(AM as mob|obj)

	..()
	if(ismob(AM))
		var/mob/M = AM //Duh
		health -= 10 //We estimate just above a slam but under a crush, since mobs can't carry a throwforce variable
		healthcheck(M)
		visible_message("<span class='danger'>\The [M] slams into \the [src].</span>", \
		"<span class='danger'>You slam into \the [src].</span>")
	else if(isobj(AM))
		var/obj/item/I = AM
		health -= I.throwforce
		healthcheck()
		visible_message("<span class='danger'>\The [I] slams into \the [src].</span>")

/obj/structure/barricade/attack_hand(mob/user as mob)

	if(M_HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes \the [src]!</span>")
		health -= 25
		healthcheck()
		user.delayNextAttack(8)

	//Bang against the barricade
	else if(usr.a_intent == I_HURT)
		user.delayNextAttack(10)
		health -= 2
		healthcheck()
		//playsound(get_turf(src), 'sound/effects/glassknock.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] bangs against \the [src]!</span>", \
		"<span class='warning'>You bang against \the [src]!</span>", \
		"You hear banging.")

	//Knock against it
	else
		user.delayNextAttack(10)
		//playsound(get_turf(src), 'sound/effects/glassknock.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] knocks on \the [src].</span>", \
		"<span class='notice'>You knock on \the [src].</span>", \
		"You hear knocking.")
	return

/obj/structure/barricade/attack_paw(mob/user as mob)

	return attack_hand(user)

/obj/structure/barricade/proc/attack_generic(mob/user as mob, damage = 0)	//Used by attack_alien, attack_animal, and attack_slime

	user.delayNextAttack(10)
	health -= damage
	user.visible_message("<span class='danger'>\The [user] smashes into \the [src]!</span>", \
	"<span class='warning'>You smash into \the [src]!</span>")
	healthcheck(user)

/obj/structure/barricade/attack_alien(mob/user as mob)

	if(islarva(user))
		return
	attack_generic(user, 15)

/obj/structure/barricade/attack_animal(mob/user as mob)

	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/barricade/attack_slime(mob/user as mob)

	if(!isslimeadult(user))
		return
	attack_generic(user, rand(10, 15))

/obj/structure/barricade/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/weapon/grab) && Adjacent(user))
		var/obj/item/weapon/grab/G = W
		if(istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			var/gstate = G.state
			returnToPool(W)	//Gotta delete it here because if window breaks, it won't get deleted
			switch(gstate)
				if(GRAB_PASSIVE)
					M.apply_damage(5) //Meh, bit of pain, barricade is fine, just a shove
					visible_message("<span class='warning'>\The [user] shoves \the [M] into \the [src]!</span>", \
					"<span class='warning'>You shove \the [M] into \the [src]!</span>")
				if(GRAB_AGGRESSIVE)
					M.apply_damage(10) //Nasty, but dazed and concussed at worst
					health -= 5
					visible_message("<span class='danger'>\The [user] slams \the [M] into \the [src]!</span>", \
					"<span class='danger'>You slam \the [M] into \the [src]!</span>")
				if(GRAB_NECK to GRAB_KILL)
					M.Weaken(3) //Almost certainly shoved head or face-first, you're going to need a bit for the lights to come back on
					M.apply_damage(20) //That got to fucking hurt, you were basically flung into a barricade, most likely a splintered one at that
					health -= 20 //Barricade won't like that
					visible_message("<span class='danger'>\The [user] crushes \the [M] into \the [src]!</span>", \
					"<span class='danger'>You crush \the [M] into \the [src]!</span>")
			healthcheck(user)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been barricade slammed by [user.name] ([user.ckey]) ([gstate]).</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Barricade slammed [M.name] ([gstate]).</font>")
			msg_admin_attack("[user.name] ([user.ckey]) barricade slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			log_attack("[user.name] ([user.ckey]) barricade slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			return

	if(istype(W, /obj/item/weapon/crowbar) && user.a_intent == I_HURT && !busy) //Only way to deconstruct, needs harm intent
		playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
		user.visible_message("<span class='warning'>[user] starts struggling to pry \the [src] back into planks.</span>", \
		"<span class='notice'>You start struggling to pry \the [src] back into planks.</span>")
		busy = 1

		if(do_after(user, src, 100)) //Takes a long while because it is a barricade instant kill
			playsound(loc, 'sound/items/Deconstruct.ogg', 75, 1)
			user.visible_message("<span class='warning'>[user] finishes turning \the [src] back into planks.</span>", \
			"<span class='notice'>You finish turning \the [src] back into planks.</span>")
			getFromPool(/obj/item/stack/sheet/wood, get_turf(src), sheetamount)
			busy = 0
			qdel(src)
			return
		else
			busy = 0

	if(W.damtype == BRUTE || W.damtype == BURN)
		user.delayNextAttack(10)
		health -= W.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>", \
		"<span class='warning'>You hit \the [src] with \the [W].</span>")
		healthcheck(user)
		return
	else
		//playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		..()

/obj/structure/barricade/proc/can_be_reached(mob/user)

	if(!is_fulltile())
		if(get_dir(user, src) & dir)
			for(var/obj/O in loc)
				if(!O.CanPass(user, user.loc, 1, 0))
					return 0
	return 1

/obj/structure/barricade/Destroy()

	density = 0 //Sanity while we do the rest
	getFromPool(/obj/item/stack/sheet/wood, loc, sheetamount)
	..()

/obj/structure/barricade/update_icon()

	return

/obj/structure/barricade/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)

	if(exposed_temperature > T0C + fire_temp_threshold)
		health -= round(exposed_volume/fire_volume_mod)
		healthcheck(sound = 0)
	..()

/obj/structure/barricade/full
	name = "wood barricade"
	desc = "A barricade made out of wood planks, it is very likely going to be a tough nut to crack"
	icon_state = "barricade_full"
	health = 500
	maxhealth = 500
	sheetamount = 3

/obj/structure/barricade/full/New(loc)

	..(loc)
	flags &= ~ON_BORDER

/obj/structure/barricade/full/CheckExit(atom/movable/O as mob|obj, target as turf)

	return 1

/obj/structure/barricade/full/CanPass(atom/movable/mover, turf/target, height = 1.5, air_group = 0)

	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	return 0

/obj/structure/barricade/full/can_be_reached(mob/user)

	return 1 //That about it Captain

/obj/structure/barricade/full/is_fulltile()

	return 1

/obj/structure/barricade/full/block //Used by the barricade kit when it is placed on airlocks or windows

	icon_state = "barricade_block"
	health = 50 //Can take a few hits, but not very robust
	maxhealth = 50
	sheetamount = 1
	opacity = 0 //You CAN see through this one, because it's just two wood planks hastily nailed onto the airlock/window
