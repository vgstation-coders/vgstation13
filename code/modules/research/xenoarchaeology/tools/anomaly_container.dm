/obj/structure/anomaly_container
	name = "anomaly container"
	desc = "Used to safely contain and move anomalies."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anomaly_container"
	density = 1

	var/obj/machinery/artifact/contained

/obj/structure/anomaly_container/attack_hand(var/mob/user)
	if(!contained)
		return
	if(alert(user, "Do you wish release \the [contained] from \the [src]?", "Confirm", "Yes", "No") != "Yes")
		return
	if(Adjacent(user))
		release()

/obj/structure/anomaly_container/attack_robot(var/mob/user)
	if(!contained)
		return
	if(alert(user, "Do you wish release \the [contained] from \the [src]?", "Confirm", "Yes", "No") != "Yes")
		return
	if(Adjacent(user))
		release()

/obj/structure/anomaly_container/proc/contain(var/obj/machinery/artifact/artifact)
	if(contained)
		return
	contained = artifact
	artifact.forceMove(src)
	underlays += image(artifact)
	desc = "Used to safely contain and move anomalies. \The [contained] is kept inside."

/obj/structure/anomaly_container/proc/release()
	contained.forceMove(get_turf(src))
	contained = null
	underlays.Cut()
	desc = initial(desc)

/obj/machinery/artifact/MouseDrop(var/obj/structure/anomaly_container/over_object)
	if(istype(over_object) && Adjacent(over_object) && can_MouseDrop(over_object, usr))
		Bumped(usr)
		over_object.contain(src)
