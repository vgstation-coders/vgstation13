/obj/item/device/ano_scanner
	name = "\improper Alden-Saraspova counter"
	desc = "Aids in triangulation of exotic particles. Too sensible however to locate already excavated anomalies."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "ano_scanner"
	item_state = "lampgreen"
	w_class = W_CLASS_TINY
	flags = FPRINT
	slot_flags = SLOT_BELT
	var/nearest_artifact_id = "unknown"
	var/nearest_artifact_distance = -1
	var/last_scan_time = 0
	var/scan_delay = 25
	toolsounds = list('sound/items/healthanalyzer.ogg')

/obj/item/device/ano_scanner/attack_self(var/mob/user)
	return src.interact(user)

/obj/item/device/ano_scanner/interact(var/mob/user)
	var/message = "Background radiation levels detected."

	if(nearest_artifact_distance >= 0)
		message = "Exotic energy detected on wavelength '[nearest_artifact_id]' in a radius of [nearest_artifact_distance]m"

	to_chat(user, "<span class='info'>[message]</span>")

	if(world.time - last_scan_time >= scan_delay)
		spawn(0)
			scan(user)

/obj/item/device/ano_scanner/proc/scan(var/mob/user)
	last_scan_time = world.time
	nearest_artifact_distance = -1

	var/turf/cur_turf = get_turf(src)

	if(SSxenoarch) //Sanity check due to runtimes ~Z
		for(var/turf/unsimulated/mineral/T in SSxenoarch.artifact_spawning_turfs)
			if(T.artifact_find)
				if(T.z == cur_turf.z)
					var/cur_dist = sqrt(get_dist_squared(cur_turf, T))
					if((nearest_artifact_distance < 0 || cur_dist < nearest_artifact_distance) && cur_dist <= T.artifact_find.artifact_detect_range)
						nearest_artifact_distance = cur_dist + rand() * 2 - 1
						nearest_artifact_id = T.artifact_find.artifact_id
			else
				SSxenoarch.artifact_spawning_turfs.Remove(T)

	playtoolsound(src, 50)
	cur_turf.visible_message("<span class='info'>[src] clicks.</span>")
