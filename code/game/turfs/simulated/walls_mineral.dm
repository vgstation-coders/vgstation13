/turf/simulated/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	explosion_block = 1
	var/last_event = 0
	var/active = null

/turf/simulated/wall/mineral/wood
	name = "wooden wall"
	desc = "A wall with wooden plating."
	icon_state = "wood0"
	walltype = "wood"
	mineral = "wood"
	girder_type = /obj/structure/girder/wood
	hardness = 0 // a hulk can smash through wood easily

/turf/simulated/wall/mineral/wood/attackby(var/obj/item/W, var/mob/user)
	if(W.sharpness_flags & CHOPWOOD)
		playsound(src, 'sound/effects/woodcuttingshort.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] smashes through \the [src] with \the [W].</span>", \
							"<span class='notice'>You smash through \the [src].</span>",\
							"<span class='warning'>You hear the sound of wood being cut</span>"
							)
		dismantle_wall()
	else
		..()

/turf/simulated/wall/mineral/wood/ex_act(var/severity)
	if(severity < 3)
		getFromPool(/obj/item/stack/sheet/wood, src, 2)
	..()

/turf/simulated/wall/mineral/brick
	name = "brick wall"
	desc = "A wall with brick siding, it looks nice"
	icon_state = "brick0"
	walltype = "brick"
	mineral = "brick"

/turf/simulated/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = "gold0"
	walltype = "gold"
	mineral = "gold"
	//var/electro = 1
	//var/shocked = null

/turf/simulated/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon_state = "silver0"
	walltype = "silver"
	mineral = "silver"
	//var/electro = 0.75
	//var/shocked = null

/turf/simulated/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = "diamond0"
	walltype = "diamond"
	mineral = "diamond"
	explosion_block = 3

/turf/simulated/wall/mineral/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon_state = "clown0"
	walltype = "clown"
	mineral = "clown"

/turf/simulated/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = "sandstone0"
	walltype = "sandstone"
	mineral = "sandstone"
	explosion_block = 0

/turf/simulated/wall/mineral/plastic
	name = "plastic wall"
	desc = "A wall made of colorful plastic blocks attached together."
	icon_state = "plastic0"
	walltype = "plastic"
	mineral = "plastic"
	opacity = 0
	explosion_block = 0

/turf/simulated/wall/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = "uranium0"
	walltype = "uranium"
	mineral = "uranium"
	explosion_block = 2

/turf/simulated/wall/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_radiation(12,RAD_EXTERNAL)
			for(var/turf/simulated/wall/mineral/uranium/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return

/turf/simulated/wall/mineral/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/turf/simulated/wall/mineral/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob)
	radiate()
	..()

/turf/simulated/wall/mineral/uranium/Bumped(AM as mob|obj)
	radiate()
	..()

/turf/simulated/wall/mineral/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon_state = "plasma0"
	walltype = "plasma"
	mineral = "plasma"

/turf/simulated/wall/mineral/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		ignite(W.is_hot())
		return
	..()

/turf/simulated/wall/mineral/plasma/proc/PlasmaBurn(temperature)
	var/pdiff = performWallPressureCheck(src.loc)
	if(pdiff > 0)
		investigation_log(I_ATMOS, "with a pdiff of [pdiff] has caught on fire at [formatJumpTo(get_turf(src))]!")
		message_admins("\The [src] with a pdiff of [pdiff] has caught of fire at [formatJumpTo(get_turf(src))]!")
	spawn(2)
	new /obj/structure/girder(src)
	src.ChangeTurf(/turf/simulated/floor)
	for(var/turf/simulated/floor/target_tile in range(0,src))
		/*if(target_tile.parent && target_tile.parent.group_processing)
			target_tile.parent.suspend_group_processing()*/
		var/datum/gas_mixture/napalm = new
		var/toxinsToDeduce = 20
		napalm.temperature = 400+T0C
		napalm.adjust_gas(GAS_PLASMA, toxinsToDeduce)
		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(temperature, 400,surfaces=1)
	for(var/obj/structure/falsewall/plasma/F in range(3,src))//Hackish as fuck, but until fire_act works, there is nothing I can do -Sieve
		var/turf/T = get_turf(F)
		T.ChangeTurf(/turf/simulated/wall/mineral/plasma/)
		qdel (F)
		F = null
	for(var/turf/simulated/wall/mineral/plasma/W in range(3,src))
		W.ignite((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)

/turf/simulated/wall/mineral/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/plasma/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/plasma/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj,/obj/item/projectile/beam))
		PlasmaBurn(2500)
	else if(istype(Proj,/obj/item/projectile/ion))
		PlasmaBurn(500)
	..()

/*
/turf/simulated/wall/mineral/proc/shock()
	if (electrocute_mob(user, C, src))
		spark(src, 5)
		return 1
	else
		return 0

/turf/simulated/wall/mineral/proc/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if((mineral == "gold") || (mineral == "silver"))
		if(shocked)
			shock()
*/

/turf/simulated/wall/mineral/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon_state = "clock"
	walltype = "clock"
	mineral = "brass"
//	dismantle_type = /turf/simulated/floor/engine/clockwork // SOON
	girder_type = /obj/structure/girder/clockwork

/turf/simulated/wall/mineral/clockwork/cultify()
	return

/turf/simulated/wall/mineral/clockwork/clockworkify()
	return