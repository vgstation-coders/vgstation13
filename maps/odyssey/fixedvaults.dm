/datum/map_element/fixedvault/centcomm
    name = "central command"
    file_path = "maps/odyssey/centcomm.dmm"
    vz_type = VZ_PROTECTED

/datum/map_element/fixedvault/centcomm/initialize(list/objects)
    ..()
    // Odyssey packs centcomm into a virtual_z on a dynamic zLevel instead of its own
    // real z-level, so /obj/machinery/account_database/initialize()'s `z == map.zCentcomm`
    // check never matches and crew would spawn with no bank accounts.
    if(isnull(centcomm_account_db))
        for(var/obj/machinery/account_database/db in objects)
            centcomm_account_db = db
            break

    // /area/shuttle/supply lives in this fixedvault instead of the main map, so
    // cargo_shuttle.New() (a global var initializer, runs before fixedvaults load)
    // couldn't resolve its linked_area and the shuttle was never added to the global
    // shuttles list. Back-fill it here so setup_shuttles() can initialize it and
    // populate dock_station / dock_centcom.
    if(cargo_shuttle && !cargo_shuttle.linked_area)
        for(var/area/A in world)
            if(istype(A, /area/shuttle/supply))
                cargo_shuttle.linked_areas |= A
        for(var/area/A in cargo_shuttle.linked_areas)
            if(A.contents.len)
                cargo_shuttle.linked_area = A
                break
        if(!cargo_shuttle.linked_area && cargo_shuttle.linked_areas.len)
            cargo_shuttle.linked_area = cargo_shuttle.linked_areas[1]
        if(cargo_shuttle.linked_area)
            shuttles |= cargo_shuttle

/datum/map_element/fixedvault/derelict
    name = "derelict space station"
    file_path = "maps/odyssey/derelict.dmm"
    vz_type = VZ_SPACE

/datum/map_element/fixedvault/dj_sat
    name = "abandoned DJ satellite"
    file_path = "maps/odyssey/dj_sat.dmm"
    vz_type = VZ_SPACE

/datum/map_element/fixedvault/vox_parking
    name = "Vox parking station"
    file_path = "maps/odyssey/vox_parking.dmm"
    vz_type = VZ_PARKING

/datum/map_element/fixedvault/rendezvous
    name = "Vox Trade Shuttle - NTEV Odyssey Rendezvous Point"
    file_path = "maps/odyssey/rendezvous.dmm"
    vz_type = VZ_PARKING
