//Its a door. Doors are too machiney, lets make it a structure instead! -Oldcoders
//That was a bad idea, lets make it a machine instead!

/obj/machinery/door/mineral
	name = "mineral door"
	use_power = 0
	machine_flags = 0
	icon = 'icons/obj/doors/mineral.dmi'
	icon_state = "metaldoor_closed"
	prefix = "metal" //Corresponds to the mineral type

	explosion_block = 1

	soundeffect = 'sound/effects/stonedoor_openclose.ogg'
	var/hardness = 3
	var/oreAmount = 7

/obj/machinery/door/mineral/New(location)
	..()
	icon_state = "[prefix]door_closed"
	name = "[prefix] door"

/obj/machinery/door/mineral/Bumped(atom/user)
	if(operating)
		return

	if(istype(user, /obj/mecha))
		open()
	else if (istype(user, /obj/machinery/bot))
		open()
	else if(ismob(user))
		var/mob/M = user
		if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) //This is what we call blind trust
			return
		TryToSwitchState(user)
	return


/obj/machinery/door/mineral/attack_ai(mob/user as mob) //those aren't really machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user) && get_dist(user,src) <= 1) //but robots can, not remotely though
		return TryToSwitchState(user) //also >nesting if statements

/obj/machinery/door/mineral/attack_paw(mob/user as mob)
	return TryToSwitchState(user)

/obj/machinery/door/mineral/attack_hand(mob/user as mob)
	return TryToSwitchState(user)

/obj/machinery/door/mineral/proc/TryToSwitchState(mob/user as mob)
	if(operating)
		return

	if(!user.restrained() && (user.size > SIZE_TINY))
		add_fingerprint(user)
		SwitchState()
	return

/obj/machinery/door/mineral/proc/SwitchState()
	if(!density)
		return close()
	else
		return open()

/obj/machinery/door/mineral/open()
	playsound(src, soundeffect, 100, 1)
	return ..()

/obj/machinery/door/mineral/close()
	playsound(src, soundeffect, 100, 1)
	return ..()

/obj/machinery/door/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/digTool = W
		to_chat(user, "You start digging \the [src].")
		if(do_after(user, src, digTool.digspeed*hardness) && src)
			to_chat(user, "You finished digging.")
			return Dismantle()
	else if(istype(W, /obj/item/weapon/card))
		to_chat(user, "You swipe your card at \the [src], petulantly expecting a result.")
		return
	else
		hardness -= W.force/100
		to_chat(user, "You hit \the [src] with your [W.name]!")
		user.delayNextAttack(10)
		CheckHardness()
	return

/obj/machinery/door/mineral/proc/CheckHardness()
	if(hardness <= 0)
		Dismantle(1)
	return

/obj/machinery/door/mineral/proc/Dismantle(devastated = 0)
	var/obj/item/stack/ore
	if(src.prefix == "metal")
		ore = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
	else
		var/P = text2path("/obj/item/stack/sheet/mineral/[prefix]")
		if(P)
			ore = new P(get_turf(src))

	if(ore)
		var/new_amount = oreAmount
		if(devastated)
			new_amount -= 2

		ore.set_amount(new_amount)

	qdel(src)

/obj/machinery/door/mineral/ex_act(severity = 1)
	switch(severity)
		if(1)
			Dismantle(1)
		if(2)
			if(prob(20))
				Dismantle(1)
			else
				hardness--
				CheckHardness()
		if(3)
			hardness -= 0.1
			CheckHardness()

/obj/machinery/door/mineral/iron
	prefix = "metal"
	icon_state = "metaldoor_closed"

/obj/machinery/door/mineral/silver
	prefix = "silver"
	icon_state = "silverdoor_closed"

/obj/machinery/door/mineral/gold
	prefix = "gold"
	icon_state = "golddoor_closed"
	hardness = 1

/obj/machinery/door/mineral/uranium
	prefix = "uranium"
	icon_state = "uraniumdoor_closed"
	luminosity = 2

/obj/machinery/door/mineral/sandstone
	prefix = "sandstone"
	icon_state = "sandstonedoor_closed"
	hardness = 0.5
	explosion_block = 0

/obj/machinery/door/mineral/transparent
	opacity = 0

	close()
		..()
		opacity = 0

/obj/machinery/door/mineral/transparent/plasma
	prefix = "plasma"
	icon_state = "plasmadoor_closed"
	hardness = 4

/obj/machinery/door/mineral/transparent/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			TemperatureAct(100)
	return ..()

/obj/machinery/door/mineral/transparent/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		TemperatureAct(exposed_temperature)

/obj/machinery/door/mineral/transparent/plasma/proc/TemperatureAct(temperature)
	for(var/turf/simulated/floor/target_tile in range(2,loc))

		var/datum/gas_mixture/napalm = new //Napalm? Whelp. There should be a better way for this.

		var/toxinsToDeduce = temperature/10

		napalm.temperature = 200+T0C
		napalm.adjust_gas(GAS_PLASMA, toxinsToDeduce)

		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(temperature, 400,surfaces=1)

		hardness -= toxinsToDeduce/100
		CheckHardness()
	return

/obj/machinery/door/mineral/transparent/diamond
	prefix = "diamond"
	icon_state = "diamonddoor_closed"
	hardness = 10
	explosion_block = 3

/obj/machinery/door/mineral/wood
	prefix = "wood"
	icon_state = "wooddoor_closed"
	hardness = 1
	soundeffect = 'sound/effects/doorcreaky.ogg'

/obj/machinery/door/mineral/wood/Dismantle(devastated = 0)
	var/obj/item/stack/resource = new/obj/item/stack/sheet/wood
	if(!devastated)
		resource.amount = oreAmount
		new resource(get_turf(src))
	qdel(src)
	return

/obj/machinery/door/mineral/resin
	prefix = "resin"
	icon_state = "resindoor_closed"
	hardness = 1.5
	var/close_delay = 100
	soundeffect = 'sound/effects/attackblob.ogg'

/obj/machinery/door/mineral/resin/TryToSwitchState(atom/user)
	if(isalien(user) && !operating)
		add_fingerprint(user)
		SwitchState()

/obj/machinery/door/mineral/resin/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage_type == BRUTE || Proj.damage_type == BURN)
		hardness -= Proj.damage/100
		CheckHardness()

/obj/machinery/door/mineral/resin/open()
	..()
	spawn(close_delay)
		if(!operating && !density)
			close()

/obj/machinery/door/mineral/resin/Dismantle(devastated = 0)
	qdel(src)
	return

/obj/machinery/door/mineral/resin/CheckHardness()
	playsound(src, soundeffect, 100, 1)
	return ..()

/obj/machinery/door/mineral/resin/acidable()
	return 0

/obj/machinery/door/mineral/hive
	prefix = ""
	icon = 'icons/obj/doors/morgue.dmi'
	icon_state = "door_closed"
	hardness = 1 //very weak

/obj/machinery/door/mineral/hive/New()
	..()

	dir = pick(cardinal)
	//Random direction for a more chaotic look

/obj/machinery/door/mineral/transparent/icicle
	name = "icicle door"
	use_power = 0
	machine_flags = 0
	icon = 'icons/obj/doors/mineral.dmi'
	icon_state = "icicledoor_closed"
	prefix = "icicle"
	hardness = 0.5

	soundeffect = 'sound/effects/ice_breaking.ogg'

/obj/machinery/door/mineral/transparent/icicle/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || (height == 0))
		return 1
	else
		return ..()

/obj/machinery/door/mineral/transparent/icicle/horizontal
	name = "icicle door"
	icon_state = "iciclehorizontaldoor_closed"
	prefix = "iciclehorizontal"

/obj/machinery/door/mineral/transparent/icicle/horizontal/New(location)
	..()
	icon_state = "[prefix]door_closed"
	name = "icicle door"

/obj/machinery/door/mineral/cult
	name = "cult door"
	icon = 'icons/obj/doors/doorcult.dmi'
	icon_state = "cultdoor_closed0"

	explosion_block = 1
	prefix = "cult"
	animation_delay = 0
	var/health = 100
	var/maxHealth = 100

/obj/machinery/door/mineral/cult/New()
	..()
	update_icon()
	playsound(src, soundeffect, 100, 1)
	flick("cultdoor_spawn", src)

/obj/machinery/door/mineral/cult/Destroy()
	if (loc)
		playsound(loc, 'sound/effects/stone_crumble.ogg', 100, 1)
	anim(location = loc,target = loc.loc,a_icon = 'icons/obj/doors/doorcult.dmi', flick_anim = "cultdoor_breakdown")
	..()

/obj/machinery/door/mineral/cult/Uncrossed(var/atom/movable/mover)
	if (!density && !operating && !(locate(/mob/living) in loc))
		if (ismob(mover))
			var/mob/M = mover
			if (M.pulling && loc)
				M.pulling.forceMove(loc)//so we don't stop pulling stuff when moving through cult doors
		close()

/obj/machinery/door/mineral/cult/TryToSwitchState(atom/user)
	if (ismob(user))
		var/mob/M = user
		if(isanycultist(M) && !operating)
			add_fingerprint(M)
			SwitchState()

/obj/machinery/door/mineral/cult/cultify()
	return

/obj/machinery/door/mineral/cult/update_icon()
	..()
	if(density)
		icon_state += "[min(3,round((maxHealth-health)/25))]"

/obj/machinery/door/mineral/cult/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage_type == BRUTE || Proj.damage_type == BURN)
		health -= Proj.damage
		CheckHardness()

/obj/machinery/door/mineral/cult/attackby(var/obj/item/weapon/W, var/mob/user)
	if(istype(W, /obj/item/weapon/card))
		user.visible_message("\The [user] swipes their card at \the [src], petulantly expecting a result.</span>",
							"You swipe your card at \the [src], petulantly expecting a result.")
	else
		health -= W.force
		to_chat(user, "You hit \the [src] with your [W.name]!")
		if(W.hitsound)
			playsound(src, W.hitsound, 50, 1, -1)
		user.delayNextAttack(10)
		CheckHardness()

/obj/machinery/door/mineral/cult/CheckHardness()
	update_icon()
	if(health <= 0)
		qdel(src)
