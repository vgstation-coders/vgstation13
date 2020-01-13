/obj/structure/anomaly_container
	name = "anomaly container"
	desc = "Used to safely contain and move anomalies."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anomaly_container"
	density = 1

	var/obj/machinery/artifact/contained

/obj/structure/anomaly_container/attack_hand(var/mob/user)
	if(contained)
		if(alert(user, "Do you wish release \the [contained] from \the [src]?", "Confirm", "Yes", "No") != "No")
			if(Adjacent(user) && !user.incapacitated() && !user.lying)
				src.investigation_log(I_ARTIFACT, "|| [contained] released by [key_name(user)].")
				release()

/obj/structure/anomaly_container/attack_robot(var/mob/user)
	return attack_hand(user)

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

/obj/machinery/artifact/MouseDropFrom(var/obj/structure/anomaly_container/over_object)
	if(istype(over_object) && Adjacent(over_object) && Adjacent(usr))
		Bumped(usr)
		over_object.contain(src)
		src.investigation_log(I_ARTIFACT, "|| stored inside [over_object] by [key_name(usr)].")
