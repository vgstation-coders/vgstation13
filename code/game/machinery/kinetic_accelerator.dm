/obj/machinery/kinetic_accelerator
	name = "\improper Kinetic Accelerator"
	desc = "Makes things go fast."

	density = 0
	anchored = 1

	icon = 'icons/obj/kinetic_accel.dmi'
	icon_state = "linacc1"

	var/power = 0.25
	var/maxspeed = 5

/obj/machinery/kinetic_accelerator/Crossed(var/atom/movable/A)
	if(!istype(A))
		return
	if(A.throwing)
		A.kinetic_acceleration = min(maxspeed,A.kinetic_acceleration + power)