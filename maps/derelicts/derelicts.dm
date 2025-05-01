/datum/map_element/fixedvault/derelict_old
    name = "derelict oldstation"
    file_path = "maps/derelicts/derelict_old.dmm"
/datum/map_element/fixedvault/derelictpool
    name = "derelict pool"
    file_path = "maps/derelicts/derelict_pool.dmm"
/datum/map_element/fixedvault/derelict_syn
    name = "derelict synergy"
    file_path = "maps/derelicts/derelict_syn.dmm"
/datum/map_element/fixedvault/derelict_cult
    name = "derelict circle"
    file_path = "maps/derelicts/derelict_cult.dmm" 

/obj/effect/landmark/map_element/randomderelict
    maptype = /datum/map_element/fixedvault/derelict_old

//Pick from the list of maps
/obj/effect/landmark/map_element/randomderelict/New()
    maptype = pick(/datum/map_element/fixedvault/derelict_old, /datum/map_element/fixedvault/derelictpool, /datum/map_element/fixedvault/derelict_syn, /datum/map_element/fixedvault/derelict_cult)
    ..() 

//This part rotates the derelict. Fucks up decals though.
/*
/obj/effect/landmark/map_element/randomderelict/mapload()
    if(maptype)
        var/datum/map_element/ME = new maptype
        if(istype(ME))
            ME.load(src.x-1,src.y-1,src.z,pick(0,90,180,270), override_can_rotate = TRUE)
    qdel(src) 
*/

//Areas

/area/derelict
	name = "\improper Derelict Station"
	icon_state = "storage"

	general_area = /area/derelict
	general_area_name = "Derelict Station"
	shuttle_can_crush = FALSE

/area/derelict/hallway/primary
	name = "\improper Derelict Primary Hallway"
	icon_state = "hallP"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/derelict/hallway/secondary
	name = "\improper Derelict Secondary Hallway"
	icon_state = "hallS"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/derelict/arrival
	name = "\improper Derelict Arrival Centre"
	icon_state = "yellow"
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING
	
/area/derelict/storage/tech_storage
	name = "Derelict Tech Storage"
	icon_state = "storage"
	
/area/derelict/storage/aux_storage
	name = "Derelict Aux Storage"
	icon_state = "auxstorage"

/area/derelict/bridge/bridge
	name = "\improper Derelict Control Room"
	icon_state = "bridge"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

// This area is used in squidroid (Snaxi and Defficiency)
/area/derelict/secret
	name = "\improper Derelict Secret Room"
	icon_state = "library"
	holomap_draw_override = HOLOMAP_DRAW_EMPTY

/area/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/derelict/bridge/ai_upload
	name = "\improper Derelict Computer Core"
	icon_state = "ai"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/derelict/solar_control
	name = "\improper Derelict Solar Control"
	icon_state = "engine"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/derelict/atmos
	name = "\improper Derelict Atmospherics"
	icon_state = "atmos"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/derelict/research
	name = "\improper Derelict Research"
	icon_state = "toxmisc"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE
	
/area/derelict/library
	name = "Derelict Library"
	icon_state = "library"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/derelict/crew_quarters
	name = "\improper Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical/medbay
	name = "Derelict Medbay"
	icon_state = "medbay"
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/derelict/medical/morgue
	name = "\improper Derelict Morgue"
	icon_state = "morgue"
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/derelict/medical/chapel
	name = "\improper Derelict Chapel"
	icon_state = "chapel"

/area/derelict/teleporter
	name = "\improper Derelict Teleporter"
	icon_state = "teleporter"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

//This area is not used within derelicts, it's whiteship.
/area/derelict/ship
	name = "\improper Abandoned Ship"
	icon_state = "yellow"
	holomap_draw_override = HOLOMAP_DRAW_EMPTY

/area/solar/derelict_starboard
	name = "\improper Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "\improper Derelict Aft Solar Array"
	icon_state = "aderelict"

/area/derelict/singularity_engine
	name = "\improper Derelict Singularity Engine"
	icon_state = "engine"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/derelict/security
	name = "Derelict Security"
	icon_state = "security"
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/derelict/bar
	name = "Derelict Bar"
	icon_state = "bar"

/area/derelict/holodeck
	name = "Derelict Holodeck"
	icon_state = "Holodeck"
	
/area/derelict/kitchen
	name = "Derelict Kitchen"
	icon_state = "kitchen"

/area/derelict/mall
	name = "Derelict Mall"
	icon_state = "yellow"
	
/area/derelict/relax
	name = "Derelict Relaxation Room"
	icon_state = "fitness"
	
/area/derelict/hydro
	name = "Derelict Hydroponics"
	icon_state = "hydro"
	
/area/derelict/theatre
	name = "Derelict Theatre"
	icon_state = "Theatre"
	
/area/derelict/game_room
	name = "Derelict Game Room"
	icon_state = "library"

/area/derelict/maintenance/maintenance_port
	name = "Derelict Port Maintenance"
	icon_state = "pmaint"
	
/area/derelict/maintenance/maintenance_fore
	name = "Derelict Fore Maintenance"
	icon_state = "fmaint"
	
/area/derelict/maintenance/maintenance_starboard
	name = "Derelict Starboard Maintenance"
	icon_state = "smaint"

/area/derelict/maintenance/maintenance_central
	name = "Derelict Central Maintenance"
	icon_state = "maintcentral"
	
/area/derelict/mommi_nest
	name = "Derelict MoMMI Nest"
	icon_state = "ai"