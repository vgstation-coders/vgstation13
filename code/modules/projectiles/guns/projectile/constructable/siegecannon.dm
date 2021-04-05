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
	else
		loadCannon(W, user)

/obj/structure/siege_cannon/attack_hand(mob/user)
	if(user.stat)
		return
	siegeFire(user)

/obj/structure/siege_cannon/proc/fillCannon(var/obj/item/weapon/reagent_containers/G, mob/user)
	if(G.is_empty() || G.reagents.reagent_list.len > 1)
		return
	if(!G.is_open_container())
		loadCannon(G, user)
		return
	if(wFuel >= maxFuel)
		to_chat(user,"<span class='warning'>The [src] is already full.</span>" )
		return
	for(var/datum/reagent/R in G.reagents.reagent_list)
		if(R.id != FUEL)
			to_chat(user,"<span class='warning'>The [src] can't accept that as fuel.</span>" )
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
		return
	if(cAmmo.w_class > maxSize)
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
	if(loadedMob || loadedItem)
		to_chat(user,"<span class='warning'>\The [src] is already full.</span>" )
		return
	visible_message("<span class='warning'>\The [user] is stuffing [C] into \the [src].</span>")
	if(do_after(user, C, 3 SECONDS))
		loadMob(C, user)

/obj/structure/siege_cannon/proc/loadMob(var/mob/living/mLoad, mob/user)
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
	var/mSpeed = 32		//Twice that of an non-emagged mass driver.
	if(M_FAT in loadedMob.mutations)
		mSpeed = 40	//Big boi
	loadedMob.forceMove(loc)
	loadedMob.throw_at(target, wFuel*2, mSpeed)
	loadedMob = null

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


//Cannonball////////

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

/obj/item/cannonball/throw_impact(atom/hit_atom)
	..()
	if(cannonFired && !hit_atom.gcDestroyed)
		cannonEffect(hit_atom)

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
	else if(isliving(cTarg))
		siegeMob(cTarg)
	cannonAdjust()

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
