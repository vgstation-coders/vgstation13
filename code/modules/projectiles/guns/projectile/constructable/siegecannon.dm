/obj/structure/siege_cannon
	name = "\improper Siege Cannon"
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
	if(W.is_wrench(user))
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
		to_chat(user,"<span class='warning'>\The [src] is already full.</span>" )
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
			to_chat(user,"<span class='warning'>\The [cAmmo] is too large to fit in \the [src].</span>")
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
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL*20)
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
	if(!..() && isliving(hit_atom) && cannonFired)
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

// Making fuse bombs
/obj/item/cannonball/iron/attackby(var/obj/item/I, mob/user as mob)
	if(istype(I, /obj/item/tool/surgicaldrill))
		to_chat(user, "<span  class='notice'>You begin drilling a hole in the [src] with the [I].</span>")
		var/drilltime = 20
		if(istype(I, /obj/item/tool/surgicaldrill/diamond))
			drilltime = 5
		if(do_after(user, src, drilltime))
			var/obj/item/cannonball/fuse_bomb/F = new /obj/item/cannonball/fuse_bomb(src.loc)
			F.assembled = 0
			F.name = "empty fuse bomb assembly"
			F.desc = "Just add fire. And fuel."
			F.update_icon()
			to_chat(user, "<span  class='notice'>You drill a hole in the [src] with the [I].</span>")
			qdel(src)

//Fuse bomb//////// -Refactored as cannonball by kanef, was originally a device for some reason. Nothing needed to be changed since icon state is the only unique var in that type, and it's set here anyways
/obj/item/cannonball/fuse_bomb
	name = "fuse bomb"
	desc = "fshhhhhhhh BOOM!"
	icon = 'icons/obj/device.dmi'
	icon_state = "fuse_bomb_5"
	item_state = "fuse_bomb"
	flags = FPRINT
	throwforce = 2
	throw_speed = 2
	throw_range = 4	//Lighter than cannonballs, but not too light
	force = 5
	adjForce = 10
	var/assembled = 2
	var/fuse_lit = 0
	var/seconds_left = 5

/obj/item/cannonball/fuse_bomb/admin//spawned by the adminbus, doesn't send an admin message, but the logs are still kept.

/obj/item/cannonball/fuse_bomb/attack_self(mob/user as mob)
	if(assembled == 2)
		if(!fuse_lit)
			lit(user)
		else
			fuse_lit = 0
			update_icon()
			to_chat(user, "<span class='warning'>You extinguish the fuse with [seconds_left] seconds left!</span>")
	return

/obj/item/cannonball/fuse_bomb/afterattack(atom/target, mob/user , flag) //Filling up the bomb
	if(assembled == 0)
		if(istype(target, /obj/structure/reagent_dispensers) && !target.is_open_container() && target.Adjacent(user))
			if(target.reagents.get_reagent_amount(FUEL) < 200)
				to_chat(user, "<span  class='notice'>There's not enough fuel left to work with.</span>")
				return
			target.reagents.remove_reagent(FUEL, 200, 1)//Deleting 200 fuel from the welding fuel tank,
			assembled = 1
			to_chat(user, "<span  class='notice'>You've filled the [src] with welding fuel.</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
			name = "fuse bomb assembly"
			desc = "Just add fire."
			return

/obj/item/cannonball/fuse_bomb/attackby(obj/item/I as obj, mob/user as mob)
	..()
	if(assembled == 1)
		if(istype(I, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = I
			to_chat(user, "<span  class='notice'>You begin wiring the [src].</span>")
			if(do_after(user, src, 20))
				C.use(1)
				assembled = 2
				to_chat(user, "<span  class='notice'>You wire the [src].</span>")
				name = "fuse bomb"
				desc = "fshhhhhhhh BOOM!"
				update_icon()
	else if(assembled == 2)
		if(!fuse_lit)
			if(iswelder(I))
				var/obj/item/tool/weldingtool/WT = I
				if(WT.isOn())
					lit(user,I)
			else if(istype(I, /obj/item/weapon/lighter))
				var/obj/item/weapon/lighter/L = I
				if(L.lit)
					lit(user,I)
			else if(istype(I, /obj/item/weapon/match))
				var/obj/item/weapon/match/M = I
				if(M.lit)
					lit(user,I)
			else if(istype(I, /obj/item/candle))
				var/obj/item/candle/C = I
				if(C.lit)
					lit(user,I)
			else if(I.is_wirecutter(user))
				assembled = 1
				to_chat(user, "<span  class='notice'>You remove the fuse from the [src].</span>")
				name = "fuse bomb assembly"
				desc = "Just add fire."
				update_icon()
		else
			if(I.is_wirecutter(user))
				fuse_lit = 0
				update_icon()
				to_chat(user, "<span class='warning'>You extinguish the fuse with [seconds_left] seconds left!</span>")


/obj/item/cannonball/fuse_bomb/proc/lit(mob/user as mob, var/obj/O=null)
	fuse_lit = 1
	to_chat(user, "<span class='warning'>You lit the fuse[O ? " with [O]":""]! [seconds_left] seconds till detonation!</span>")
	admin_warn(user)
	add_fingerprint(user)
	update_icon()
	fuse_burn(user)

/obj/item/cannonball/fuse_bomb/proc/fuse_burn(var/mob/user)
	set waitfor = 0

	if(src && src.fuse_lit)
		if(src.seconds_left)
			sleep(10)
			src.seconds_left--
			src.update_icon()
			.(user)
		else
			src.detonation(user)
	return

/obj/item/cannonball/fuse_bomb/extinguish()
	..()
	fuse_lit = 0
	update_icon()

/obj/item/cannonball/fuse_bomb/proc/detonation(var/mob/user)
	explosion(get_turf(src), -1, 0, 4, whodunnit = user) //buff range to compensate for this somehow breaching
	qdel(src)

/obj/item/cannonball/fuse_bomb/admin/detonation(var/mob/user) //okay, this one can breach if it wants
	explosion(get_turf(src), -1, 1, 3, whodunnit = user)
	qdel(src)

/obj/item/cannonball/fuse_bomb/update_icon()
	if (assembled == 2)
		icon_state = "fuse_bomb_[seconds_left][fuse_lit ? "-lit":""]"
	else
		icon_state = "fuse_bomb_1"

/obj/item/cannonball/fuse_bomb/proc/admin_warn(mob/user as mob)
	var/turf/bombturf = get_turf(src)
	var/area/A = get_area(bombturf)

	var/demoman_name = ""
	if(!user)
		demoman_name = "Unknown"
	else
		demoman_name = "[user.name]([user.ckey])"

	var/log_str = "Bomb fuse lit in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name]</a> by [demoman_name]"

	if(user)
		log_str += "(<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)"

	bombers += log_str
	message_admins(log_str, 0, 1)
	log_game(log_str)

/obj/item/cannonball/fuse_bomb/admin/admin_warn(mob/user as mob)
	var/turf/bombturf = get_turf(src)
	var/area/A = get_area(bombturf)

	var/demoman_name = ""
	if(!user)
		demoman_name = "Unknown"
	else
		demoman_name = "[user.name]([user.ckey])"

	var/log_str = "Bomb fuse lit in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name]</a> by [demoman_name]"

	if(user)
		log_str += "(<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)"

	bombers += log_str
	log_game(log_str)

/obj/item/cannonball/fuse_bomb/ex_act(severity, var/child = null, var/mob/whodunnit)//MWAHAHAHA
	detonation(whodunnit)

/obj/item/cannonball/fuse_bomb/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)//consistency
	..()
	fuse_burn()

/obj/item/cannonball/fuse_bomb/cultify()
	return

/obj/item/cannonball/fuse_bomb/cannonEffect(var/atom/cTarg)
	if(assembled == 2 && fuse_lit)
		detonation()
	else if(isliving(cTarg))
		var/mob/living/L = cTarg
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.Knockdown(2) //hollow means less stun time
		else if(L.size == SIZE_TINY)	//splat
			L.gib()

//Bananium////////

/obj/item/cannonball/bananium
	name = "clownnonball"
	desc = "A large sphere of honk."
	icon = 'icons/obj/siege_cannon.dmi'
	icon_state = "clownnonball"
	starting_materials = list(MAT_CLOWN = CC_PER_SHEET_CLOWN*20)
	adjRange = 50
	adjSpeed = 1
	adjForce = 0
	var/isBouncing = FALSE	//Prevents it bouncing infinitely due to some dark curse of throw_at()
	var/lastBounceCount = 0

/obj/item/cannonball/bananium/throw_at(atom/target, range, speed, override = 1)
	if(!cannonFired)
		..()
	else if(!isBouncing)
		isBouncing = TRUE
		..(target, 50, 1000, 1, 1)	//Always travels as slow as possible. High speed is to appease throw_at and doesn't translate to any damage

/obj/item/cannonball/bananium/cannonEffect(var/atom/cTarg)
	if(ishuman(cTarg))
		honkMob(cTarg)
	honkBounce(cTarg)

/obj/item/cannonball/bananium/throw_impact(atom/hit_atom, var/speed, mob/user)
	if(..())
		return
	if(!cannonFired)
		lastBounceCount = 0
		return
	lastBounceCount++
	if(isliving(hit_atom))
		honkMob(hit_atom)
		honkBounce(hit_atom)
	else if(isitem(hit_atom) && hit_atom.density)
		spawn(10)	//Give throwing time to stop bullying me
			if(!throwing && cannonFired)

				honkBounce(hit_atom,lastBounceCount)


/obj/item/cannonball/bananium/proc/honkMob(var/mob/living/L)
	L.Knockdown(rand(2,10))
	playsound(src, 'sound/items/bikehorn.ogg', 75, 1)

/obj/item/cannonball/bananium/proc/honkBounce(var/atom/cTarg, var/tot_bounces = 0)
	if(tot_bounces > 10)
		stopBouncing()
		return 0
	var/list/honkStep = alldirs.Copy()
	var/honkDir = get_dir(src, cTarg)
	honkStep -= list(honkDir, turn(honkDir, 45), turn(honkDir, -45))	//Every direction possible except directly, or diagonally, toward what we hit
	honkDir = pick(honkStep)
	spawn(10)	//Prevents multiple instances of throw_at() from being active
		bounceStep(honkDir)

/obj/item/cannonball/bananium/proc/bounceStep(var/honkDir)
	if(lastBounceCount > 25)
		stopBouncing()
	if(cannonFired)
		if(prob(10) && istype(get_turf(src), /turf/simulated))
			var/turf/simulated/T = get_turf(src)
			T.wet(800, TURF_WET_LUBE)
		var/target = get_ranged_target_turf(src, honkDir, 50)
		isBouncing = FALSE
		throw_at(target, 50, 1000, 1, 1)

/obj/item/cannonball/bananium/proc/stopBouncing()
	throwing = 0
	kinetic_acceleration = 0
	isBouncing = FALSE
	lastBounceCount = 0
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

