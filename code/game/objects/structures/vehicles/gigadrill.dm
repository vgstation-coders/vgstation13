#define DRILL_TIME 2

/obj/item/key/gigadrill
	name = "gigadrill key"
	desc = "A dusty and old key."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/gigadrill
	name = "gigadrill"
	icon_state = "gigadrill"
	keytype = /obj/item/key/gigadrill
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/gigadrill
	var/turf/drilling_turf

/obj/structure/bed/chair/vehicle/gigadrill/buckle_mob(mob/M, mob/user)
  ..()
  update_icon()

/obj/structure/bed/chair/vehicle/gigadrill/attack_hand()
	..()
	update_icon()

/obj/structure/bed/chair/vehicle/gigadrill/to_bump()
	..()
	if(occupant)
		occupant.pixel_y += 2
		spawn(1)
		occupant.pixel_y -= 2

/obj/structure/bed/chair/vehicle/gigadrill/handle_layer()
	if(dir == NORTH)
		plane = OBJ_PLANE
		layer = ABOVE_OBJ_LAYER
	else
		plane = ABOVE_HUMAN_PLANE
		layer = VEHICLE_LAYER

/obj/structure/bed/chair/vehicle/gigadrill/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 18 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 18 * PIXEL_MULTIPLIER, "y" = 9 * PIXEL_MULTIPLIER),
		"[NORTH]" = list("x" = 0, "y" = 7 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = -18 * PIXEL_MULTIPLIER, "y" = 9 * PIXEL_MULTIPLIER)
		)

/obj/structure/bed/chair/vehicle/gigadrill/update_icon()
  if(occupant)
    icon_state = "gigadrill_mov"
  else
    icon_state = "gigadrill"

/obj/structure/bed/chair/vehicle/gigadrill/proc/drill(atom/target)
	if(!occupant)
		return

	if(istype(target, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = target
		if(M.finds && M.finds.len) //Shameless copypaste. TODO: Make an actual proc for this then apply it to mechs as well.
			if(prob(5))
				M.excavate_find(5, M.finds[1])
			else if(prob(50))
				M.finds.Remove(M.finds[1])
				if(prob(50))
					M.artifact_debris()
		M.GetDrilled()

/obj/effect/decal/mecha_wreckage/vehicle/gigadrill
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gigadrill_wreck"
	name = "gigadrill wreckage"
	desc = "The rocks are safer.  For now."

#undef DRILL_TIME
