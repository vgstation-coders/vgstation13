
//////////////////////BEE CORPSES///////////////////////////////////////

/obj/effect/decal/cleanable/bee
	name = "dead bee"
	desc = "This one stung for the last time."
	gender = PLURAL
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bee_dead"
	anchored = 0
	mouse_opacity = 1
	plane = LYING_MOB_PLANE
	var/single = 1

/obj/effect/decal/cleanable/bee/New(var/loc, var/age, var/icon_state, var/color, var/dir, var/pixel_x, var/pixel_y)
	..()
	if (isnum(color) && color > 0)
		src.icon_state = "bees0"
		var/failsafe = min(color,30)
		for (var/i = 1 to failsafe)
			var/image/I = image(icon,icon_state)
			I.pixel_x = rand(-10,10)
			I.pixel_y = rand(-4,4)
			I.dir = pick(cardinal)
			overlays += I
		color = null
	else
		var/image/I = image(src.icon,src.icon_state)
		I.pixel_x = rand(-10,10)
		I.pixel_y = rand(-4,4)
		I.dir = pick(cardinal)

		for (var/obj/effect/decal/cleanable/bee/corpse in get_turf(src))
			if (corpse != src)
				corpse.overlays += I
				if (corpse.single)
					corpse.name += "s"
					corpse.single = 0
				qdel(src)
				return
			else
				icon_state = "bees0"
				overlays += I

/obj/effect/decal/cleanable/bee/queen_bee
	name = "dead queen bee"
	icon_state = "queen_bee_dead"

/obj/effect/decal/cleanable/bee/atom2mapsave()
	icon_state = initial(icon_state)
	if (overlays.len > 0)
		color = overlays.len//a bit hacky but hey
	. = ..()

//Chill Bugs
/obj/effect/decal/cleanable/bee/chill
	name = "dead chill bug"
	desc = "This one stung for the last time."
	icon_state = "chill_bee_dead"

/obj/effect/decal/cleanable/bee/queen_bee/chill
	name = "dead chill bug queen"
	icon_state = "chill_queen_bee_dead"

//Hornets
/obj/effect/decal/cleanable/bee/hornet
	name = "dead hornet"
	desc = "This one stung for the last time."
	icon_state = "hornet_bee_dead"

/obj/effect/decal/cleanable/bee/queen_bee/hornet
	name = "dead hornet queen"
	icon_state = "hornet_queen_bee_dead"

