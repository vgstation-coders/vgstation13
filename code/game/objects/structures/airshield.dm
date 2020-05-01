/obj/structure/airshield
	name = "airshield"
	desc = "A shield that allows only non-gasses to pass through."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "emancipation_grill_on"
	opacity = 1
	density = 0
	anchored = 1
	plane = ABOVE_HUMAN_PLANE

/obj/structure/airshield/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover))
		return ..()
	return FALSE