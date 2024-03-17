/* Diffrent misc types of tiles
 * Contains:
 *		Grass
 *		Wood
 *		Carpet
 */

/*
 * Grass
 */
/obj/item/stack/tile/grass
	name = "grass tile"
	singular_name = "grass floor tile"
	desc = "A patch of grass, like they often use on golf courses."
	icon_state = "tile_grass"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 0 //no conduct
	max_amount = 60
	origin_tech = Tc_BIOTECH + "=1"

	material = "grass"
	autoignition_temperature = AUTOIGNITION_ORGANIC

/*
 * Wood
 */
/obj/item/stack/tile/wood
	name = "wooden floor tile"
	singular_name = "wooden floor tile"
	desc = "An easy to fit wooden floor tile."
	icon_state = "tile-wood"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 0 //no conduct
	max_amount = 60
	sheet_type = /obj/item/stack/sheet/wood
	material = "wood"
	autoignition_temperature = AUTOIGNITION_WOOD

/obj/item/stack/tile/wood/proc/build(turf/S as turf)
	if(S.air)
		var/datum/gas_mixture/GM = S.air
		if(GM.pressure > HALF_ATM)
			S.ChangeTurf(/turf/simulated/floor/plating/deck)
			return
	S.ChangeTurf(/turf/simulated/floor/plating/deck/airless)


/obj/item/stack/tile/wood/afterattack(atom/target, mob/user, adjacent, params)
	if(adjacent)
		if(isturf(target) || istype(target, /obj/structure/lattice/wood))
			var/turf/T = get_turf(target)
			var/obj/structure/lattice/L
			L = locate(/obj/structure/lattice/wood) in T
			if(!istype(L))
				return
			var/obj/item/stack/tile/wood/S = src
			if(!(T.canBuildPlating(S)))
				to_chat(user, "<span class='warning'>You can't get that deck up without some support!</span>")
				return
			if(S.use(1))
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				S.build(T)
				if(T.canBuildPlating(S) == BUILD_SUCCESS)
					qdel(L)

/obj/item/stack/tile/wood/attackby(var/obj/item/weapon/W, var/mob/user)
	if(W.is_wrench(user))
		if(use(4))
			W.playtoolsound(user, 50)
			drop_stack(sheet_type, get_turf(user), 1, user)
		else
			to_chat(user, "<span class='warning'>You need at least 4 [src]\s to get a wooden plank back!</span>")
		return

	. = ..()

/*
 * Carpets
 */
/obj/item/stack/tile/carpet
	name = "length of carpet"
	singular_name = "length of carpet"
	desc = "A piece of carpet. It is the same size as a floor tile."
	icon_state = "tile-carpet"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 0 //no conduct
	max_amount = 60

	material = "fabric"
	autoignition_temperature = AUTOIGNITION_FABRIC

/obj/item/stack/tile/carpet/shag
	name = "length of shag carpet"
	singular_name = "length of shag carpet"
	desc = "A shaggy piece of carpet."
	icon_state = "tile-shag"

/obj/item/stack/tile/arcade
	name = "length of arcade carpet"
	singular_name = "length of arcade carpet"
	desc = "A piece of arcade carpet. It has a snazzy space theme."
	icon_state = "tile-arcade"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 0 //no conduct
	max_amount = 60

	material = "fabric"
	autoignition_temperature = AUTOIGNITION_FABRIC

/obj/item/stack/tile/slime
	name = "tile of slime"
	desc = "A flat piece of slime made through xenobiology."
	icon_state = "tile-slime"
	w_class = W_CLASS_MEDIUM
	force = 1
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 1
	max_amount = 60
	autoignition_temperature = AUTOIGNITION_ORGANIC

/obj/item/stack/tile/slime/adjust_slowdown(mob/living/L, current_slowdown)
	if(isslimeperson(L) || isslime(L))
		current_slowdown *= 5
	else
		current_slowdown *= 0.01
	..()
