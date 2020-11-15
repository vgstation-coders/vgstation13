/obj/item/device/artifact_finder
	name = "\improper Anomalous Energies Locator"
	desc = "Finds the closest source of anomalous exotic particles. Unlike the Alden-Saraspova Counter, it cannot locate buried anomalies."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "arti_finder"
	item_state = "lampgreen"
	w_class = W_CLASS_TINY
	flags = FPRINT
	slot_flags = SLOT_BELT
	var/last_scan_time = 0
	var/scan_cooldown = 10

/obj/item/device/artifact_finder/attack_self(var/mob/user)
	if(last_scan_time && (world.time - last_scan_time < scan_cooldown))
		return
	last_scan_time = world.time

	var/message = "No active particle emission detected under 1km."

	var/closest_id = null
	var/closest_dist = ARBITRARILY_LARGE_NUMBER

	var/turf/T = get_turf(src)
	for (var/artifact_id in excavated_large_artifacts)
		var/obj/machinery/artifact/A = excavated_large_artifacts[artifact_id]
		if (!istype(A))
			continue
		var/turf/U = get_turf(A)
		if (T.z != U.z)
			continue
		if (istype(A.loc, /obj/structure/anomaly_container))
			continue
		var/detectable = FALSE
		if (A.primary_effect && (A.primary_effect.activated || A.primary_effect.isolated))
			detectable = TRUE
		if (A.secondary_effect && (A.secondary_effect.activated || A.secondary_effect.isolated))
			detectable = TRUE
		if (!detectable)
			continue

		var/arti_dist = sqrt(get_dist_squared(U, T))
		if (arti_dist < closest_dist)
			closest_dist = arti_dist
			closest_id = A.artifact_id
			dir = get_dir(T,U)

	for (var/obj/item/weapon/anodevice/A in anomaly_power_utilizers)
		var/turf/U = get_turf(A)
		if (T.z != U.z)
			continue
		if(!A.inserted_battery || !A.inserted_battery.battery_effect)
			continue
		if (A.inserted_battery.battery_effect.activated || A.inserted_battery.battery_effect.isolated)
			var/device_dist = sqrt(get_dist_squared(U, T))
			if (device_dist < closest_dist)
				closest_dist = device_dist
				closest_id = A.inserted_battery.effect_id
				dir = get_dir(T,U)

	if(closest_id)
		message = "Strong exotic energy detected on wavelength '[closest_id]' coming from [closest_dist]m to the [dir2text(dir)]."
		flick("arti_finder_dir",src)

	to_chat(user, "<span class='info'>[message]</span>")
