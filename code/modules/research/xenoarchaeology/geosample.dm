/*
#define FIND_PLANT 1
#define FIND_BIO 2
#define FIND_METEORIC 3
#define FIND_ICE 4
#define FIND_CRYSTALLINE 5
#define FIND_METALLIC 6
#define FIND_IGNEOUS 7
#define FIND_METAMORPHIC 8
#define FIND_SEDIMENTARY 9
#define FIND_NOTHING 10
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Rock sliver

/obj/item/weapon/rocksliver
	name = "rock sliver"
	desc = "It looks extremely delicate."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "sliver1"	//0-4
	w_class = W_CLASS_TINY
	//item_state = "electronic"
	var/datum/geosample/geological_data

/obj/item/weapon/rocksliver/New()
	. = ..()
	icon_state = "sliver[rand(1,3)]"
	pixel_x = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_y = rand(-8, 0) * PIXEL_MULTIPLIER

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Geosample datum

/datum/geosample
	var/artifact_id = ""					//id of a nearby artifact, if there is one
	var/artifact_distance = -1				//proportional to distance

//have this separate from UpdateTurf() so that we dont have a billion turfs being updated (redundantly) every time an artifact spawns
/datum/geosample/proc/UpdateNearbyArtifactInfo(var/turf/unsimulated/mineral/container)
	if(!container || !istype(container))
		return

	if(container.artifact_find)
		artifact_distance = rand() // 0-1
		artifact_id = container.artifact_find.artifact_id
		return

	if(!SSxenoarch) //Sanity check due to runtimes ~Z
		return

	for(var/turf/unsimulated/mineral/T in SSxenoarch.artifact_spawning_turfs)
		if(T.artifact_find)
			var/cur_dist = get_dist(container, T)
			if( (artifact_distance < 0 || cur_dist < artifact_distance) && cur_dist <= T.artifact_find.artifact_detect_range )
				artifact_distance = cur_dist + rand() * 2 - 1
				artifact_id = T.artifact_find.artifact_id
		else
			SSxenoarch.artifact_spawning_turfs.Remove(T)

/*
#undef FIND_PLANT
#undef FIND_BIO
#undef FIND_METEORIC
#undef FIND_ICE
#undef FIND_CRYSTALLINE
#undef FIND_METALLIC
#undef FIND_IGNEOUS
#undef FIND_METAMORPHIC
#undef FIND_SEDIMENTARY
#undef FIND_NOTHING
*/
