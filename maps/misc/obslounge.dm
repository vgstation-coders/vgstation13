/datum/map_element/dungeon/obslounge
    file_path = "maps/misc/obslounge.dmm"
    unique = TRUE
    var/obj/effect/landmark/obs_spawn/obs_spawner

/obj/effect/step_trigger/ghostizer/Trigger(var/atom/movable/A)
    if(isliving(A))
        var/mob/living/L = A
        qdel(L.ghostize())
        qdel(L)

/obj/effect/landmark/obs_spawn
    name = "obsgang spawner"

/obj/effect/landmark/obs_spawn/spawned_by_map_element(datum/map_element/ME, list/objects)
    if(ME.type == /datum/map_element/dungeon/obslounge)
        var/datum/map_element/dungeon/obslounge/OBS = ME
        OBS.obs_spawner = src

/obj/effect/landmark/obs_spawn/Crossed(H as mob|obj)
	..()
	if(istype(H, /mob/dead/observer))
		spawn_mob(H)

/obj/effect/landmark/obs_spawn/proc/spawn_mob(mob/M)
	var/mob/living/carbon/human/dummy/obser = new(loc)
	obser.key = M.key
