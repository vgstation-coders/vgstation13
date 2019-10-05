/obj/item/key/firebird
	name = "\improper Firebird key"
	desc = "A keyring with a small steel key, and a fancy blue and gold fob."
	icon_state = "magic_keys"

/obj/effect/effect/trails/firebird
	base_name = "fire"

/obj/effect/effect/trails/firebird/Play()
	dir=pick(cardinal)
	spawn(rand(10,20))
		if(src)
			returnToPool(src)

/datum/effect/effect/system/trail/firebird
	trail_type = /obj/effect/effect/trails/firebird

/obj/structure/bed/chair/vehicle/firebird
	name = "\improper Firebird"
	desc = "A Pontiac Firebird Trans Am with skulls and crossbones on the hood, dark grey paint, and gold trim.  No magic required for this baby."
	icon_state = "firebird"
	//nick = "TRUE POWER"
	keytype = /obj/item/key/firebird
	can_spacemove = 1
	can_have_carts = FALSE
	//ethereal=1 // NERF
	var/can_move = 1
	layer = FLY_LAYER
	plane = ABOVE_HUMAN_PLANE
	pass_flags = PASSMOB|PASSDOOR
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/firebird

	var/datum/effect/effect/system/trail/firebird/ion_trail

/obj/structure/bed/chair/vehicle/firebird/New()
	..()
	ion_trail = new /datum/effect/effect/system/trail/firebird()
	ion_trail.set_up(src)
	ion_trail.start()

/obj/structure/bed/chair/vehicle/firebird/can_apply_inertia()
	return FALSE

/obj/structure/bed/chair/vehicle/firebird/Process_Spacemove(var/check_drift = 0)
	return TRUE

/* Server vote on 16-12-2014 to disable wallmoving (10-7 Y)
// Shit be ethereal.
/obj/structure/bed/chair/vehicle/firebird/Cross(atom/movable/mover, turf/target height=1.5, air_group = 0)
	return 1
*/

/obj/structure/bed/chair/vehicle/firebird/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 7 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 3 * PIXEL_MULTIPLIER, "y" = 7 * PIXEL_MULTIPLIER),//13
		"[NORTH]" = list("x" = 0, "y" = 4 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = -3 * PIXEL_MULTIPLIER, "y" = 7 * PIXEL_MULTIPLIER)//-13
		)

/obj/structure/bed/chair/vehicle/firebird/handle_layer()
	return

/obj/structure/bed/chair/vehicle/firebird/to_bump(var/atom/obstacle)
	if(throwing)
		return ..()
	else
		return obstacle.bumped_by_firebird(src) //Yep

/* Server vote on 16-12-2014 to disable wallmoving (10-7 Y)
/obj/structure/bed/chair/vehicle/firebird/to_bump(var/atom/obstacle)
	if(can_move)
		can_move = 0
		alpha=128
		forceMove(get_step(src,src.dir))
		if(locked_to_mob)
			if(locked_to_mob.loc != loc)
				locked_to_mob.locked_to = null //Temporary, so Move() succeeds.
				locked_to_mob.locked_to = src //Restoring
		sleep(10) // 1s
		alpha=255
		can_move = 1
	else
		. = ..()
	return
*/

/obj/structure/bed/chair/vehicle/firebird/santa
	name = "magic snowmobile"
	desc = "After a complaint from space PETA, santa's been forced to take a less elegant ride."
	icon_state = "snowmobile"

/obj/effect/decal/mecha_wreckage/vehicle/firebird
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gokart_wreck"
	name = "\improper Firebird wreckage"
	desc = "The magic is gone."
