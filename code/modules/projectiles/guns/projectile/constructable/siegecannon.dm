/obj/structure/siege_cannon
	name = "Siege Cannon"
	desc = "A heavy-duty cannon. Capable of knocking down walls and fortifications when loaded with the right munitions."
	icon = 'icons/obj/siege_cannon.dmi'
	icon_state = "siege_cannon"
	density = TRUE
	var/obj/item/loadedItem = null
	var/mob/living/loadedMob = null
	var/wFuel = 0
	var/maxFuel = 20
	var/maxSize = W_CLASS_LARGE	//Anything bigger won't fit.
	var/beenClowned = FALSE

/obj/structure/siege_cannon/Destroy()
	unloadCannon()
	..()

/obj/structure/siege_cannon/proc/unloadCannon()
	if(loadedItem)
		loadedItem.forceMove(loc)
		loadedItem = null
	if(loadedMob)
		loadedMob.forceMove(loc)
		loadedMob = null

/obj/structure/siege_cannon/AltClick(var/mob/user)
	if(user.incapacitated() || !in_range(user, src) || user.loc == src)
		return
	to_chat(user,"<span class='notice'>You unload \the [src].</span>" )
	unloadCannon()

/obj/structure/siege_cannon/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers))
		fillCannon(W, user)
		return 1
	if(W.is_wrench())
		wrenchAnchor(user, W, 5)	//Half a second to wrench. Being able to turn it via verb while anchored is intentional.
	else if((istype(W, /obj/item/weapon/stamp/clown) || istype(W, /obj/item/toy/crayon/rainbow)) && !beenClowned)
		becomeClownnon(W, user)
	else
		loadCannon(W, user)

/obj/structure/siege_cannon/attack_hand(mob/user)
	if(user.stat)
		return
	siegeFire(user)

/obj/structure/siege_cannon/proc/fillCannon(var/obj/item/weapon/reagent_containers/G, mob/user)
	if(G.is_empty() || G.reagents.reagent_list.len > 1)
		loadCannon(G, user)
		return
	if(!G.is_open_container())
		loadCannon(G, user)
		return
	if(wFuel >= maxFuel)
		to_chat(user,"<span class='warning'>The [src] is already full.</span>" )
		return
	for(var/datum/reagent/R in G.reagents.reagent_list)
		if(R.id != FUEL)
			loadCannon(G, user)
			break //Just in case
		else
			var/tF = clamp(G.amount_per_transfer_from_this, 0, maxFuel - wFuel)
			G.reagents.remove_reagent(FUEL, tF)
			wFuel += tF
			if(wFuel == maxFuel)
				to_chat(user,"<span class='notice'>You completely fill \the [src] with [tF] units of fuel.</span>" )
			else
				to_chat(user,"<span class='notice'>You add [tF] units of fuel to \the [src].</span>" )

/obj/structure/siege_cannon/proc/loadCannon(var/obj/item/cAmmo, var/mob/user)
	if(loadedItem || loadedMob)
		to_chat(user,"<span class='warning'>\The [src] is already loaded.</span>")
		return
	if(istype(cAmmo, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = cAmmo
		if(G.affecting)
			loadMob(G.affecting, user)
			return
	if(cAmmo.w_class > maxSize)
		if(istype(cAmmo, /obj/item/anvil))
			to_chat(user,"<span class='warning'>You force \the [cAmmo] into \the [src], somehow.</span>")	//Terrifying
		else
			to_chat(user,"<span class='warning'>The [cAmmo] is too large to fit in \the [src].</span>")
			return
	if(user.drop_item(cAmmo, src))
		loadedItem = cAmmo
		to_chat(user,"<span class='notice'>You load \the [cAmmo] into \the [src].</span>" )

/obj/structure/siege_cannon/MouseDropTo(var/atom/movable/C, mob/user)
	if(user.incapacitated() || !in_range(user, src) || !in_range(user, C) || C.anchored)	//Copy pasted from chairs because sanity is hard
		return
	if(!isliving(C))
		return
	loadMob(C, user)

/obj/structure/siege_cannon/proc/loadMob(var/mob/living/mLoad, mob/user)
	if(loadedMob || loadedItem)
		to_chat(user,"<span class='warning'>\The [src] is already loaded.</span>")
		return
	visible_message("<span class='warning'>\The [user] is stuffing [mLoad] into \the [src].</span>")
	if(do_after(user, mLoad, 3 SECONDS))
		if(loadedMob || loadedItem)
			to_chat(user,"<span class='warning'>\The [src] is already loaded.</span>")
			return
		mLoad.forceMove(src)
		loadedMob = mLoad

/obj/structure/siege_cannon/relaymove(mob/user)
	if(do_after(user, src, 1 SECONDS))
		if(user.loc == src)
			user.forceMove(loc)
		loadedMob = null

/obj/structure/siege_cannon/proc/fireCheck()
	if(!wFuel)
		return FALSE
	if(!loadedItem && !loadedMob)
		return FALSE
	return TRUE

/obj/structure/siege_cannon/proc/siegeFire(mob/user)
	if(!fireCheck())
		return
	spark(src)
	playsound(src, 'sound/effects/Explosion_Small1.ogg', 100, 1)
	if(beenClowned)
		spawn(1)
			playsound(src, 'sound/items/bikehorn.ogg', 20, 1)
	if(loadedItem)
		itemFire()
	else if(loadedMob)
		mobFire()
	wFuel = 0

/obj/structure/siege_cannon/proc/itemFire()
	var/atom/target = get_edge_target_turf(src, dir)
	if(istype(loadedItem, /obj/item/cannonball) && wFuel == maxFuel)
		var/obj/item/cannonball/CB = loadedItem
		CB.cannonAdjust()
	var/fireSpeed = calcSpeed()
	loadedItem.forceMove(loc)
	loadedItem.throw_at(target, wFuel*2, fireSpeed)
	loadedItem = null

/obj/structure/siege_cannon/proc/calcSpeed()
	var/FS = (wFuel/2)*(round(loadedItem.w_class/2, 1))
	return FS

/obj/structure/siege_cannon/proc/mobFire()
	var/atom/target = get_edge_target_turf(src, dir)
	loadedMob.forceMove(loc)
	if(beenClowned)
		circusFlip(target, loadedMob)	//Passes loadedMob to flipMob because waitfor = FALSE can null it, causing runtimes
	else
		var/mSpeed = 32		//Twice that of an non-emagged mass driver.
		if(M_FAT in loadedMob.mutations)
			mSpeed = 40	//Big boi
		loadedMob.throw_at(target, wFuel*2, mSpeed)
	loadedMob = null

/obj/structure/siege_cannon/proc/circusFlip(var/atom/target, var/mob/living/flipMob)
	set waitfor = FALSE
	flipMob.throw_at(target, wFuel*2, 32, 1, 1)
	var/flips = 0
	while(flipMob.throwing)
		flipMob.transform = turn(flipMob.transform, 45)
		flips++
		sleep(1)
	flipMob.transform = null
	if(ishuman(flipMob))
		var/mob/living/carbon/human/H = flipMob
		if(!clumsy_check(H) && flips >= 8)
			H.vomit(0,1)
			H.Knockdown(flips/8)

/obj/structure/siege_cannon/proc/becomeClownnon(var/obj/item/C, mob/user)
	to_chat(user,"<span class='notice'>You begin modifying \the [src].</span>")
	if(do_after(user, src, 3 SECONDS))
		beenClowned = TRUE
		icon_state = "clownnon"
		name = "circus cannon"

/obj/structure/siege_cannon/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	src.dir = turn(src.dir, -90)
	return 1

/obj/structure/siege_cannon/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	src.dir = turn(src.dir, 90)
	return 1


//CANNONBALLS/////

/obj/item/cannonball
	name = "cannonball"
	desc = "A large sphere of iron."
	icon = 'icons/obj/siege_cannon.dmi'
	icon_state = "cannonball"
	throwforce = 3
	throw_speed = 1
	throw_range = 2	//Rather heavy
	force = 10	//Somehow less than a toolbox but okay
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL*3)
	w_type = RECYK_METAL
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND
	var/cannonFired = FALSE
	var/adjRange = 50
	var/adjSpeed = 4
	var/adjForce = 15

/obj/item/cannonball/proc/cannonAdjust()
	if(!cannonFired)
		cannonFired = TRUE
		throw_range = adjRange
		throw_speed = adjSpeed
		throwforce = adjForce
	else
		cannonFired = FALSE
		throw_range = 2
		throw_speed = 1
		throwforce = 3

/obj/item/cannonball/to_bump(atom/Obstacle)
	..()
	if(cannonFired && !Obstacle.gcDestroyed)
		cannonEffect(Obstacle)

/obj/item/cannonball/proc/cannonEffect(var/atom/cTarg)
	return

//Iron///////////////

/obj/item/cannonball/iron/cannonEffect(atom/cTarg)
	if(!isliving(cTarg) && !isfloor(cTarg))
		if(istype(cTarg, /obj/machinery) && !istype(cTarg, /obj/machinery/door))	//ex_act() for machines other than doors is a bit too destructive
			siegeMachine(cTarg)
		else if(istype(cTarg, /obj/structure/girder))
			var/eG = rand(1,2)	//Girders are shockingly resistant to explosions.
			cTarg.ex_act(eG)
		else
			var/eS = rand(2,3)
			cTarg.ex_act(eS)	//May destroy normal walls, has a chance of destroying r_walls but most likely just damages them. Structures are usually 50 50.
	cannonAdjust()

/obj/item/cannonball/iron/throw_impact(atom/hit_atom, var/speed, mob/user)
	..()
	if(isliving(hit_atom))
		siegeMob(hit_atom)

/obj/item/cannonball/iron/proc/siegeMachine(var/obj/machinery/M)
	if(prob(50))	//Let's just do a coin flip
		for(var/mob/living/L in M.contents)
			L.forceMove(M.loc)
		if(M.machine_flags & CROWDESTROY)
			M.dropFrame()
			M.spillContents()
			qdel(M)
		else if(M.wrenchable())
			M.state = 0
			M.anchored = FALSE
			M.power_change()
	else
		spark(M)

/obj/item/cannonball/iron/proc/siegeMob(var/mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.Knockdown(5)
	else if(L.size == SIZE_TINY)	//splat
		L.gib()

//Bananium////////

/obj/item/cannonball/bananium
	name = "clownnonball"
	desc = "A large sphere of honk."
	icon = 'icons/obj/siege_cannon.dmi'
	icon_state = "clownnonball"
	starting_materials = list(MAT_CLOWN = CC_PER_SHEET_METAL*3)
	adjRange = 50
	adjSpeed = 1
	adjForce = 0

/obj/item/cannonball/bananium/throw_at(atom/target, range, speed, override = 1)
	if(!cannonFired)
		..()
	else
		..(target, 50, 1000, 1, 1)	//Always travels as slow as possible. High speed is to appease throw_at and doesn't translate to any damage

/obj/item/cannonball/bananium/cannonEffect(var/atom/cTarg)
	if(ishuman(cTarg))
		honkMob(cTarg)
	honkBounce(cTarg)

/obj/item/cannonball/bananium/throw_impact(atom/hit_atom, var/speed, mob/user)
	..()
	if(!cannonFired)
		return
	if(isliving(hit_atom))
		honkMob(hit_atom)
	else if(isitem(hit_atom) && hit_atom.density)
		spawn(3)	//Give throwing time to stop bullying me
			if(!throwing && cannonFired)
				honkBounce(hit_atom)


/obj/item/cannonball/bananium/proc/honkMob(var/mob/living/L)
	L.Knockdown(rand(2,10))
	playsound(src, 'sound/items/bikehorn.ogg', 75, 1)
	honkBounce(L)

/obj/item/cannonball/bananium/proc/honkBounce(var/atom/cTarg)
	var/list/honkStep = alldirs.Copy()
	var/honkDir = get_dir(src, cTarg)
	honkStep -= list(honkDir, turn(honkDir, 45), turn(honkDir, -45))	//Every direction possible except directly, or diagonally, toward what we hit
	honkDir = pick(honkStep)
	spawn(3)	//Prevents multiple instances of throw_at() from being active
		bounceStep(honkDir)

/obj/item/cannonball/bananium/proc/bounceStep(var/honkDir)
	if(cannonFired)
		if(prob(10) && istype(get_turf(src), /turf/simulated))
			var/turf/simulated/T = get_turf(src)
			T.wet(800, TURF_WET_LUBE)
		var/target = get_ranged_target_turf(src, honkDir, 50)
		throw_at(target, 50, 1000, 1, 1)

/obj/item/cannonball/bananium/proc/stopBouncing()
	throwing = 0
	kinetic_acceleration = 0
	if(cannonFired)
		cannonAdjust()

/obj/item/cannonball/bananium/Crossed(atom/movable/A)	//Yes, you have to arrest the cannonball
	..()
	if(istype(A, /obj/item/projectile))
		var/obj/item/projectile/P = A
		if(P.stun && P.nodamage)
			P.bullet_die()
			stopBouncing()
	else if(isitem(A))
		if(istype(A, /obj/item/weapon/legcuffs/bolas) && A.throwing)
			stopBouncing()
		else if(istype(A, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = A
			if(B.status && B.throwing && prob(50))
				stopBouncing()

