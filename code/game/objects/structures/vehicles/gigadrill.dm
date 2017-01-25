#define DRILL_TIME 2

/obj/item/key/gigadrill
	name = "gigadrill key"
	desc = "A dusty and old key."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/gigadrill
	name = "gigadrill"
	icon_state = "gigadrill"
	keytype = /obj/item/key/gigadrill
	var/turf/drilling_turf

/obj/structure/bed/chair/vehicle/gigadrill/buckle_mob(mob/M, mob/user)
  ..()
  update_icon()

/obj/structure/bed/chair/vehicle/gigadrill/attack_hand()
	..()
	update_icon()

/obj/structure/bed/chair/vehicle/gigadrill/process()
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

/obj/structure/bed/chair/vehicle/gigadrill/update_icon()
  if(occupant)
    icon_state = "gigadrill_mov"
  else
    icon_state = "gigadrill"

/obj/structure/bed/chair/vehicle/gigadrill/Bump(atom/A)
	if(occupant && !drilling_turf)
		if(istype(A, /turf/unsimulated/mineral))
			var/turf/unsimulated/mineral/M = A
			drilling_turf = get_turf(src)
			anchored = 1
			spawn(DRILL_TIME)
			if(get_turf(src) == drilling_turf && occupant)
				M.GetDrilled()
				src.forceMove(M)
			drilling_turf = null
			anchored = 0

#undef DRILL_TIME
