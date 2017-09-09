#define DRILL_TIME 2

/obj/item/key/gigadrill
	name = "drill core"
	desc = "A dusty and old tiny drill."
	icon_state = "drill_core"

/obj/structure/bed/chair/vehicle/gigadrill
	name = "lagann"
	icon_state = "lagann_standby"
	keytype = /obj/item/key/gigadrill
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/gigadrill
	var/turf/drilling_turf

/obj/structure/bed/chair/vehicle/gigadrill/buckle_mob(mob/M, mob/user)
  ..()
  update_icon()

/obj/structure/bed/chair/vehicle/gigadrill/attack_hand()
	..()
	update_icon()

/obj/structure/bed/chair/vehicle/gigadrill/handle_layer()
	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER

/obj/structure/bed/chair/vehicle/gigadrill/update_mob()
	if(occupant)
		occupant.pixel_x = 0
		occupant.pixel_y = 6 * PIXEL_MULTIPLIER

/obj/structure/bed/chair/vehicle/gigadrill/update_icon()
  if(occupant)
    icon_state = "lagann"
  else
    icon_state = "lagann_standby"

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
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "lagann_destroyed"
	name = "lagann wreckage"
	desc = "The heavens are safe. For now."

#undef DRILL_TIME
