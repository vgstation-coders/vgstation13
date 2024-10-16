/*
 * False Walls
 */

// Minimum pressure difference to fail building falsewalls.
// Also affects admin alerts.
#define FALSEDOOR_MAX_PRESSURE_DIFF 25.0

/**
* Gets the highest and lowest pressures from the tiles in cardinal directions
* around us, then checks the difference.
*/
/proc/getOPressureDifferential(var/turf/loc)
	var/minp=SHORT_REAL_LIMIT;
	var/maxp=0;
	for(var/dir in cardinal)
		var/turf/simulated/T=get_turf(get_step(loc,dir))
		var/cp=0
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_readonly_air()
			cp = environment.return_pressure()
		else
			if(istype(T,/turf/simulated))
				continue
		if(cp<minp)
			minp=cp
		if(cp>maxp)
			maxp=cp
	return abs(minp-maxp)

/**
* Gets the highest and lowest pressures from the list of turfs provided
* around us, then checks the difference.
*/
/proc/getPressureDifferentialFromTurfList(var/list/turf/turf_list)
	var/minp=SHORT_REAL_LIMIT; // Lowest recorded pressure.
	var/maxp=0;        // Highest recorded pressure.
	for(var/turf/T in turf_list)
		var/cp = 0
		var/turf/simulated/TS = T
		if(TS && istype(TS) && TS.zone)
			var/datum/gas_mixture/environment = TS.return_readonly_air()
			cp = environment.pressure
		else
			if(istype(T,/turf/simulated))
				continue
		if(cp<minp) // If lower than the lowest pressure we've seen,
			minp=cp   // set it to our lowest recorded pressure
		if(cp>maxp) // Same, but for highest pressure.
			maxp=cp
	return abs(minp-maxp)


// Checks pressure here vs. around us.
/proc/performFalseWallPressureCheck(var/turf/loc)
	var/turf/simulated/lT=loc
	if(!istype(lT) || !lT.zone)
		return 0
	var/datum/gas_mixture/myenv=lT.return_readonly_air()
	var/pressure=myenv.pressure

	for(var/dir in cardinal)
		var/turf/simulated/T=get_turf(get_step(loc,dir))
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_readonly_air()
			var/pdiff = abs(pressure - environment.pressure)
			if(pdiff > FALSEDOOR_MAX_PRESSURE_DIFF)
				return pdiff
	return 0

/proc/performWallPressureCheck(var/turf/loc)
	var/pdiff = getOPressureDifferential(loc)
	if(pdiff > FALSEDOOR_MAX_PRESSURE_DIFF)
		return pdiff
	return 0

/proc/performWallPressureCheckFromTurfList(var/list/turf/turf_list)
	var/pdiff = getPressureDifferentialFromTurfList(turf_list)
	if(pdiff > FALSEDOOR_MAX_PRESSURE_DIFF)
		return pdiff
	return 0

/client/proc/pdiff()
	set name = "Get PDiff"
	set category = "Debug"

	if(!mob || !holder)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/pdiff = getOPressureDifferential(T)
	var/fwpcheck=performFalseWallPressureCheck(T)
	var/wpcheck=performWallPressureCheck(T)

	to_chat(src, "Pressure Differential (cardinals): [pdiff]")
	to_chat(src, "FWPCheck: [fwpcheck]")
	to_chat(src, "WPCheck: [wpcheck]")

/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	anchored = 1
	icon = 'icons/turf/walls.dmi'
	var/reinforced = 0
	var/mineral = "metal"
	var/opening = 0
	is_on_mesons = TRUE

	// WHY DO WE SMOOTH WITH FALSE R-WALLS WHEN WE DON'T SMOOTH WITH REAL R-WALLS.
/obj/structure/falsewall/canSmoothWith()
	var/static/list/smoothables = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
	)
	return smoothables

/obj/structure/falsewall/closed
	density = 1
	opacity = 1

/obj/structure/falsewall/examine(var/mob/user)
	..()
	if(Adjacent(user))
		to_chat(user, "<span class='rose'>Now that you're standing close to it, that wall appears a bit odd.</span>")

/obj/structure/falsewall/Destroy()
	var/temploc = src.loc
	loc.mouse_opacity = 1

	spawn(10)
		for(var/turf/simulated/wall/W in range(temploc,1))
			W.relativewall()

		for(var/obj/structure/falsewall/W in range(temploc,1))
			W.relativewall()
	..()

/obj/structure/falsewall/relativewall()

	if(!density)
		icon_state = reinforced ? "frwall_open" : "[mineral]fwall_open"
		return

	icon_state = "[reinforced ? "rwall" : mineral][..()]"

/obj/structure/falsewall/attack_ai(mob/user as mob)
	if(isMoMMI(user))
		src.add_hiddenprint(user)
		attack_hand(user)

/obj/structure/falsewall/attack_hand(mob/user as mob)
	if(opening)
		return

	var/wallword = reinforced ? "frwall" : "[mineral]fwall"
	if(density)
		opening = 1
		icon_state = "[wallword]_open"
		update_meson_image()
		flick("[wallword]_opening", src)
		loc.mouse_opacity = 1
		sleep(5)
		setDensity(FALSE)
		set_opacity(0)
		opening = 0
	else
		opening = 1
		flick("[wallword]_closing", src)
		icon_state = reinforced ? "r_wall" : "[mineral]0"
		setDensity(TRUE)
		sleep(5)
		set_opacity(1)
		src.relativewall()
		opening = 0
		loc.mouse_opacity = 0
		update_meson_image()

/obj/structure/falsewall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opening)
		to_chat(user, "<span class='warning'>You must wait until the door has stopped moving.</span>")
		return

	if(density)
		var/turf/T = get_turf(src)
		if(T.density)
			to_chat(user, "<span class='warning'>The wall is blocked!</span>")
			return
		if(W.is_screwdriver(user))
			user.visible_message("[user] tightens some bolts on the wall.", "You tighten the bolts on the wall.")
			W.playtoolsound(T, 50)
			if(!mineral || mineral == "metal")
				if(reinforced)
					T.ChangeTurf(/turf/simulated/wall/r_wall)
				else
					T.ChangeTurf(/turf/simulated/wall)
			else
				T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
			qdel(src)

		if(iswelder(W))
			var/obj/item/tool/weldingtool/WT = W
			if(WT.isOn() && WT.get_fuel() >= 1)
				user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s outer plating.</span>", \
				"<span class='notice'>You begin slicing through \the [src]'s outer plating.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(WT.do_weld(user, src, 100, 1))
					if(!istype(src))
						return
					playsound(src, 'sound/items/Welder.ogg', 100, 1)
					user.visible_message("<span class='warning'>[user] slices through \the [src]'s outer plating.</span>", \
					"<span class='notice'>You slice through \the [src]'s outer plating.</span>", \
					"<span class='warning'>You hear welding noises.</span>")
					dismantle()

		if(istype(W, /obj/item/weapon/pickaxe))
			var/obj/item/weapon/pickaxe/PK = W
			if(!(PK.diggables & DIG_WALLS))
				return
			if(mineral == "diamond")
				return

			user.visible_message("<span class='warning'>[user] begins [PK.drill_verb] straight into \the [src].</span>", \
			"<span class='notice'>You begin [PK.drill_verb] straight into \the [src].</span>")
			PK.playtoolsound(src, 100)
			if(do_after(user, src, (MINE_DURATION * PK.toolspeed) * 10))
				user.visible_message("<span class='notice'>[user]'s [PK] tears though the last of \the [src], leaving nothing but a girder.</span>", \
				"<span class='notice'>Your [PK] tears though the last of \the [src], leaving nothing but a girder.</span>")
				dismantle()
	else
		to_chat(user, "<span class='notice'>You can't reach, close it first!</span>")


/obj/structure/falsewall/proc/dismantle()
	var/turf/T = get_turf(src)
	if(!T)
		return
	if(reinforced)
		new /obj/item/stack/sheet/plasteel(T, 2)
		new /obj/structure/girder/reinforced/displaced(T)
	else
		if(mineral == "metal")
			new /obj/item/stack/sheet/metal(T, 2)
		else if(mineral == "wood")
			new /obj/item/stack/sheet/wood(T, 2)
		else
			var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
			if(M)
				new M(T, 2)
		new /obj/structure/girder/displaced(T)
	qdel(src)

/obj/structure/falsewall/suicide_act(var/mob/living/user)
	if(density)
		attack_hand(user)
		sleep(15)
	user.forceMove(get_turf(src))
	attack_hand(user)
	to_chat(viewers(user), "<span class='danger'>[user] is crushing \himself with the [src]! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_BRUTELOSS)

/*
 * False R-Walls
 */

/obj/structure/falsewall/rwall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal and anchored rods used to separate rooms and keep all but the most equipped crewmen out."
	icon_state = "r_wall"
	density = 1
	opacity = 1
	reinforced = 1

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = ""
	mineral = "uranium"
	var/active = null
	var/last_event = 0

/obj/structure/falsewall/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob)
	radiate()
	..()

/obj/structure/falsewall/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/obj/structure/falsewall/uranium/proc/radiate()
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
/*
 * Other misc falsewall types
 */

/obj/structure/falsewall/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = ""
	mineral = "gold"

/obj/structure/falsewall/gold/closed
	density = 1
	opacity = 1

/obj/structure/falsewall/gold/gold_old
	mineral = "gold_old"

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	icon_state = ""
	mineral = "silver"

/obj/structure/falsewall/silver/silver_old
	mineral = "silver_old"

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = ""
	mineral = "diamond"

/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definitely a bad idea."
	icon_state = ""
	mineral = "plasma"

/obj/structure/falsewall/plastic
	name = "plastic wall"
	desc = "A wall made of colorful plastic blocks attached together."
	icon_state = ""
	mineral = "plastic"

/obj/structure/falsewall/gingerbread
	name = "gingerbread wall"
	desc = "Extremely stale and generally unappetizing."
	icon_state = ""
	mineral = "gingerbread"
	density = 1
	opacity = 1
	anchored = 1

//-----------wtf?-----------start
/obj/structure/falsewall/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon_state = ""
	mineral = "clown"

/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = ""
	mineral = "sandstone"
//------------wtf?------------end
