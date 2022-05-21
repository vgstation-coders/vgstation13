#define NO_GLASS 0
#define NORMAL_GLASS 1
#define PLASMA_GLASS 2

/obj/structure/railing
	name = "railing"
	desc = "For protecting people from going too far over ledges."
	anchored = 1
	density = 1
	icon = 'icons/obj/structures/railing.dmi'
	icon_state = "metalrailing0"
	plane = ABOVE_HUMAN_PLANE
	layer = RAILING_LAYER
	flow_flags = ON_BORDER
	pass_flags_self = PASSTABLE|PASSGLASS
	var/railingtype = "metal"
	var/junction = 0
	var/wrenchtime = 10
	var/weldtime = 25
	var/sheettype = /obj/item/stack/sheet/metal
	var/hit_behind_chance = 90
	var/wired = FALSE
	var/wire_color = "#FFFFFF"
	var/glasstype = NO_GLASS
	var/glasshealth = 0
	health = 100

/obj/structure/railing/New(loc)
	..(loc)
	setup_border_dummy()
	desc = "A [railingtype] railing, for protecting people from going too far over ledges."
	update_icon()

/obj/structure/railing/initialize()
	relativewall()
	relativewall_neighbours()

/obj/structure/railing/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(locate(/obj/effect/unwall_field) in loc) //Annoying workaround for this
		return TRUE
	if(air_group || (height==0))
		return TRUE
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(ismob(mover))
		var/mob/M = mover
		if(M.flying)
			return TRUE
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return TRUE
	return bounds_dist(border_dummy, mover) >= 0

/obj/structure/railing/MouseDropTo(atom/movable/O, mob/user, src_location, over_location, src_control, over_control, params)
	if(!ishigherbeing(user) || !Adjacent(user) || user.incapacitated() || user.lying) // Doesn't work if you're not dragging yourself, not a human, not in range or incapacitated
		return
	if(O == user)
		hurdle(user)

/obj/structure/railing/proc/hurdle(atom/movable/jumper)
	var/turf/T = get_turf(src)
	if(get_turf(jumper) == T)
		T = get_step(src,dir)
	if(locate(/obj/effect/unwall_field) in T)
		jumper.forceMove(T)
	for(var/atom/movable/AM in T.contents)
		// Border dummies weren't playing nice on the nearby turf
		if(AM == src || istype(AM,/obj/structure/railing) || istype(AM,/atom/movable/border_dummy))
			continue
		if(!AM.Cross(jumper))
			return
	jumper.forceMove(T)
	shock_check(jumper)

/obj/structure/railing/to_bump(atom/Obstacle)
	..()
	shock_check(Obstacle)

/obj/structure/railing/proc/shock_check(mob/living/shockee)
	if(!wired || !istype(shockee))
		return
	for(var/obj/structure/cable/C in get_turf(src))
		if(C && (C.d1 == dir || C.d2 == dir))
			electrocute_mob(shockee, C.get_powernet(), C)
			return
	for(var/obj/structure/cable/C in get_step(src,dir))
		if(C && (C.d1 == opposite_dirs[dir] || C.d2 == opposite_dirs[dir]))
			electrocute_mob(shockee, C.get_powernet(), C)
			return

/turf/MouseDropTo(atom/movable/O, mob/user, src_location, over_location, src_control, over_control, params)
	var/obj/structure/railing/R = (locate() in src) || (locate() in get_turf(user))
	if(R)
		R.MouseDropTo(O,user,src_location,over_location,src_control,over_control,params)

//checks if projectile 'P' from turf 'from' can hit whatever is behind the railing. Returns 1 if it can, 0 if bullet stops.
/obj/structure/railing/proc/check_cover(obj/item/projectile/P, turf/from)
	var/shooting_at_directly = P.original == src
	var/chance = hit_behind_chance
	if(glasstype)
		chance = min(40,chance)
	if(!shooting_at_directly)
		if(get_dir(loc, from) != dir) // The direction needs to be right
			return 1
		if(get_dist(P.starting, loc) <= 1) //These won't help you if people are THIS close
			return 1
		if(ismob(P.original))
			var/mob/M = P.original
			if(M.lying)
				chance -= 20 //Lying down lets you catch less bullets
	if(shooting_at_directly || !(prob(chance)))
		if(glasstype && glasshealth > 0)
			glasshealth -= P.damage/2
			visible_message("<span class='warning'>[P] hits \the [src] glass!</span>")
			return 0
		else
			if(glasstype)
				visible_message("<span class='warning'>[P] breaks \the [src] glass!</span>")
				break_glass(TRUE)
				return 0
			health -= P.damage/2
			if (health > 0)
				visible_message("<span class='warning'>[P] hits \the [src]!</span>")
				return 0
			else
				visible_message("<span class='warning'>[src] breaks down!</span>")
				make_into_sheets()
				return 1
	return 1

/obj/structure/railing/canSmoothWith()
	return list(/obj/structure/railing)

/obj/structure/railing/isSmoothableNeighbor(atom/A)
	if(istype(A,/obj/structure/railing))
		var/obj/structure/railing/O = A
		return O.anchored && O.dir == src.dir && ..()

/obj/structure/railing/relativewall()
	junction = findSmoothingNeighbors()
	switch(dir)
		if(NORTH, SOUTH)
			junction &= ~NORTH
			junction &= ~SOUTH
		if(EAST, WEST)
			junction &= ~EAST
			junction &= ~WEST
	icon_state = anchored ? "[railingtype]railing[junction]" : "[railingtype]railing0"

/obj/structure/railing/update_icon()
	overlays.Cut()
	if(wired)
		var/image/I = image(icon = icon, icon_state = "[railingtype]electric")
		I.color = wire_color
		overlays += I
	if(glasstype)
		overlays += image(icon = icon, icon_state = "[railingtype][glasstype == PLASMA_GLASS ? "p" : ""]glass")

/obj/structure/railing/attackby(var/obj/item/C, var/mob/user)
	if(..())
		return 1
	if(C.is_wrench(user))
		user.visible_message("<span class='notice'>[user] starts to [anchored ? "un" : ""]anchor [src] with \a [C].</span>",\
		"<span class='notice'>You begin to [anchored ? "un" : ""]anchor [src] with \the [C].</span>")
		C.playtoolsound(src, 50)
		if(do_after(user, src, wrenchtime))
			user.visible_message("<span class='notice'>[user] [anchored ? "un" : ""]anchored [src] with \a [C].</span>",\
			"<span class='notice'>You [anchored ? "un" : ""]anchor [src] with \the [C].</span>")
			anchored = !anchored
			relativewall()
			relativewall_neighbours()
			return
	if(!anchored)
		if(iswelder(C) && railingtype != "wooden")
			var/obj/item/tool/weldingtool/WT = C
			user.visible_message("<span class='notice'>[user] starts to deconstruct [src] with \a [C].</span>",\
			"<span class='notice'>You begin to deconstruct [src] with \the [C].</span>")
			if(WT.do_weld(user, src, weldtime, 0))
				user.visible_message("<span class='notice'>[user] deconstructed [src] with \a [C].</span>",\
				"<span class='notice'>You deconstruct [src] with \the [C].</span>")
				make_into_sheets()
				return
		if(iscrowbar(C) && railingtype == "wooden")
			user.visible_message("<span class='notice'>[user] starts to deconstruct [src] with \a [C].</span>",\
			"<span class='notice'>You begin to deconstruct [src] with \the [C].</span>")
			C.playtoolsound(src, 50)
			if(do_after(user, src, weldtime))
				user.visible_message("<span class='notice'>[user] deconstructed [src] with \a [C].</span>",\
				"<span class='notice'>You deconstruct [src] with \the [C].</span>")
				make_into_sheets()
				return
	if(anchored)
		if(iscablecoil(C) && !wired)
			var/obj/item/stack/cable_coil/CC = C
			if(CC.use(2))
				user.visible_message("<span class='notice'>[user] adds wiring to [src].</span>",\
				"<span class='notice'>You add wiring to [src].</span>")
				wired = TRUE
				wire_color = CC._color
				update_icon()
		if(C.is_wirecutter(user) && wired)
			user.visible_message("<span class='notice'>[user] removes wiring from [src].</span>",\
			"<span class='notice'>You removed wiring from [src].</span>")
			C.playtoolsound(src, 50)
			wired = FALSE
			var/obj/item/stack/cable_coil/CC2 = new /obj/item/stack/cable_coil(get_turf(user),2)
			CC2._color = wire_color
			CC2.update_icon()
			update_icon()
		if(((is_type_in_list(C,list(/obj/item/stack/sheet/glass/glass,/obj/item/stack/sheet/glass/plasmaglass)) && railingtype != "plasteel") ||\
			(is_type_in_list(C,list(/obj/item/stack/sheet/glass/rglass,/obj/item/stack/sheet/glass/plasmarglass)) && railingtype == "plasteel"))\
			&& !glasstype)
			var/obj/item/stack/sheet/glass/GS = C
			var/isplasmaglass = is_type_in_list(GS,list(/obj/item/stack/sheet/glass/plasmaglass,/obj/item/stack/sheet/glass/plasmarglass))
			if(GS.use(railingtype == "wooden" ? 1 : 2))
				user.visible_message("<span class='notice'>[user] begins to add [isplasmaglass ? "plasma " : ""]glass sheets to [src].</span>",\
				"<span class='notice'>You begins to add [isplasmaglass ? "plasma " : ""]glass sheets to [src].</span>")
				if(do_after(user, src, wrenchtime))
					user.visible_message("<span class='notice'>[user] adds [isplasmaglass ? "plasma " : ""]glass sheets to [src].</span>",\
					"<span class='notice'>You add [isplasmaglass ? "plasma " : ""]glass sheets to [src].</span>")
					glasstype = isplasmaglass ? PLASMA_GLASS : NORMAL_GLASS
					switch(railingtype)
						if("wooden")
							glasshealth = 10 * glasstype
						if("metal")
							glasshealth = 25 * glasstype
						if("plasteel")
							glasshealth = 50 * glasstype
					update_icon()
		if(iscrowbar(C) && glasstype)
			user.visible_message("<span class='notice'>[user] starts to remove [glasstype == PLASMA_GLASS ? "plasma " : ""]glass from [src] with \a [C].</span>",\
			"<span class='notice'>You begin to remove [glasstype == PLASMA_GLASS ? "plasma " : ""]glass from [src] with \the [C].</span>")
			C.playtoolsound(src, 50)
			if(do_after(user, src, wrenchtime))
				user.visible_message("<span class='notice'>[user] removed [glasstype == PLASMA_GLASS ? "plasma " : ""]glass from [src] with \a [C].</span>",\
				"<span class='notice'>You removed [glasstype == PLASMA_GLASS ? "plasma " : ""]glass from [src] with \the [C].</span>")
				break_glass()
				return
	return 1

/obj/structure/railing/proc/make_into_sheets(var/damage = FALSE)
	break_glass(damage)
	if(wired)
		wired = FALSE
		var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(get_turf(src),2)
		CC._color = wire_color
		CC.update_icon()
	var/obj/item/stack/sheet/M = new sheettype(loc)
	M.amount = 2
	qdel(src)

/obj/structure/railing/proc/break_glass(var/damage = FALSE)
	if(glasstype)
		if(damage && railingtype == "plasteel")
			new /obj/item/stack/rods(get_turf(src),2)
		switch(glasstype)
			if(NORMAL_GLASS)
				if(damage)
					new /obj/item/weapon/shard(get_turf(src))
					new /obj/item/weapon/shard(get_turf(src))
				else
					var/glasstospawn = railingtype == "plasteel" ? /obj/item/stack/sheet/glass/rglass : /obj/item/stack/sheet/glass/glass
					new glasstospawn(get_turf(src),railingtype == "wooden" ? 1 : 2)
			if(PLASMA_GLASS)
				if(damage)
					new /obj/item/weapon/shard/plasma(get_turf(src))
					new /obj/item/weapon/shard/plasma(get_turf(src))
				else
					var/glasstospawn = railingtype == "plasteel" ? /obj/item/stack/sheet/glass/plasmarglass : /obj/item/stack/sheet/glass/plasmaglass
					new glasstospawn(get_turf(src),railingtype == "wooden" ? 1 : 2)
		if(damage)
			playsound(src, "shatter", 70, 1)
		glasstype = NO_GLASS
		glasshealth = 0
		update_icon()

/obj/structure/railing/attack_hand(mob/living/user)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		make_into_sheets(TRUE)

/obj/structure/railing/attack_paw(mob/living/user)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		make_into_sheets(TRUE)

/obj/structure/railing/attack_alien(mob/living/user)
	user.do_attack_animation(src, user)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	make_into_sheets(TRUE)

/obj/structure/railing/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash_flags & SMASH_LIGHT_STRUCTURES)
		user.do_attack_animation(src, user)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		make_into_sheets(TRUE)

/obj/structure/railing/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
			else
				make_into_sheets(TRUE)
		if(3)
			if(prob(50))
				make_into_sheets(TRUE)
			else
				break_glass(TRUE)

/obj/structure/railing/loose
	anchored = 0

/obj/structure/railing/wired
	wired = TRUE

/obj/structure/railing/glass
	glasstype = NORMAL_GLASS

/obj/structure/railing/pglass
	glasstype = PLASMA_GLASS

/obj/structure/railing/plasteel
	name = "reinforced railing"
	railingtype = "plasteel"
	wrenchtime = 20
	weldtime = 50
	sheettype = /obj/item/stack/sheet/plasteel
	health = 100
	icon_state = "plasteelrailing0"
	hit_behind_chance = 70

/obj/structure/railing/plasteel/ex_act(severity)
	var/nu_severity = severity + 1
	..(nu_severity)
	if(nu_severity == 4 && prob(50))
		break_glass(TRUE)

/obj/structure/railing/plasteel/loose
	anchored = 0

/obj/structure/railing/plasteel/wired
	wired = TRUE

/obj/structure/railing/plasteel/glass
	glasstype = NORMAL_GLASS

/obj/structure/railing/plasteel/pglass
	glasstype = PLASMA_GLASS

/obj/structure/railing/wood
	railingtype = "wooden"
	sheettype = /obj/item/stack/sheet/wood
	health = 30
	icon_state = "woodenrailing0"
	hit_behind_chance = 50

/obj/structure/railing/wood/ex_act(severity)
	var/nu_severity = max(1,severity - 1)
	..(nu_severity)

/obj/structure/railing/wood/loose
	anchored = 0

/obj/structure/railing/wood/wired
	wired = TRUE

/obj/structure/railing/wood/glass
	glasstype = NORMAL_GLASS

/obj/structure/railing/wood/pglass
	glasstype = PLASMA_GLASS
