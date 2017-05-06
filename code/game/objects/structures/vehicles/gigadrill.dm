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

/obj/structure/bed/chair/vehicle/gigadrill/Bump()
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
		M.GetDrilled()

/obj/effect/decal/mecha_wreckage/vehicle/gigadrill
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gigadrill_wreck"
	name = "gigadrill wreckage"
	desc = "The rocks are safer.  For now."

#undef DRILL_TIME
