/obj/item/key/tractor
	name = "tractor key"
	desc = "Shiny keys."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/tractor
	name = "tractor"
	icon = 'goon/icons/vehicles.dmi'
	icon_state = "tractor"
	keytype = /obj/item/key/tractor
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/tractor

/obj/structure/bed/chair/vehicle/tractor/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 7 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 5 * PIXEL_MULTIPLIER, "y" = 4 * PIXEL_MULTIPLIER),
		"[NORTH]" = list("x" = 0, "y" = 4 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = -5 * PIXEL_MULTIPLIER, "y" = 4 * PIXEL_MULTIPLIER)
		)

/obj/structure/bed/chair/vehicle/tractor/handle_layer()
	if(dir == NORTH)
		plane = OBJ_PLANE
		layer = ABOVE_OBJ_LAYER
	else
		plane = ABOVE_HUMAN_PLANE
		layer = VEHICLE_LAYER

/obj/effect/decal/mecha_wreckage/vehicle/tractor
	// TODO: SPRITE PLS
	//icon = 'goon/icons/vehicles.dmi'
	//icon_state="tractor_destroyed"
	name = "tractor wreckage"
	desc = "The quartermaster sobs quietly on a pile of guns."
