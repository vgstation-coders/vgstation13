/area/shuttle/odyssey
	name = "\improper NTEV Theseus"
	icon_state = "shuttle"
	requires_power = 1
	base_turf_type = /turf/space // Fallback only; get_base_turf_type() resolves per-vLevel.

// What's outside the ship depends on where the ship is sitting:
//   - VZ_PLANET: expose the planet surface so a breach reveals the ground.
//   - VZ_TRANSIT: a visual /turf/space/breach that scrolls in the same direction as the surrounding hyperspace turfs but doesn't teleport mobs.
//   - everything else (VZ_SPACE, VZ_PARKING): plain /turf/space, since the ship is just sitting in space.
/area/shuttle/odyssey/get_base_turf_type(turf/T)
	var/datum/virtual_z/vz = T?.get_virtual_z()
	if(vz)
		switch(vz.level_type)
			if(VZ_PLANET)
				if(vz.base_turf && vz.base_turf != /turf/space)
					return vz.base_turf
				if(vz.planet?.default_baseturf)
					return vz.planet.default_baseturf
			if(VZ_TRANSIT)
				return /turf/space/breach
	return /turf/space

/area/shuttle/odyssey/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/shuttle/odyssey/bridge_lobby
	name = "\improper Bridge Lobby"
	icon_state = "hallF"

/area/shuttle/odyssey/hallway/fore
	name = "\improper Fore Hallway"
	icon_state = "hallF"

/area/shuttle/odyssey/hallway/aft
	name = "\improper Aft Hallway"
	icon_state = "hallA"

/area/shuttle/odyssey/hallway/central
	name = "\improper Central Connector"
	icon_state = "hallC"

/area/shuttle/odyssey/hallway/port
	name = "\improper Port Airlock"
	icon_state = "hallP"

/area/shuttle/odyssey/hallway/starboard
	name = "\improper Starboard Airlock"
	icon_state = "hallS"

/area/shuttle/odyssey/quarters/crew
	name = "\improper Crew Quarters"
	icon_state = "crew_quarters"

/area/shuttle/odyssey/quarters/heads
	name = "\improper Head Quarters"
	icon_state = "head_quarters"

/area/shuttle/odyssey/restroom
	name = "\improper Restroom"
	icon_state = "restrooms"

/area/shuttle/odyssey/stasis
	name = "\improper Stasis"
	icon_state = "cryo"

/area/shuttle/odyssey/cafeteria
	name = "\improper Cafeteria"
	icon_state = "cafeteria"

/area/shuttle/odyssey/logistics
	name = "\improper Logistics"
	icon_state = "mining"

/area/shuttle/odyssey/mining_storage
	name = "\improper Mining Storage"
	icon_state = "storage"

/area/shuttle/odyssey/infirmary
	name = "\improper Infirmary"
	icon_state = "medbay"

/area/shuttle/odyssey/engineering
	name = "\improper Engineering"
	icon_state = "engine_lobby"

/area/shuttle/odyssey/engineering/gas_storage/port
	name = "\improper Port Gas Storage"
	icon_state = "atmos"

/area/shuttle/odyssey/engineering/gas_storage/starboard
	name = "\improper Starboard Gas Storage"
	icon_state = "atmos"

/area/shuttle/odyssey/engineering/engine_room
	name = "\improper Engine Room"
	icon_state = "engine"

/area/shuttle/odyssey/janitor
	name = "\improper Janitor"
	icon_state = "janitor"

/area/shuttle/odyssey/maintenance/port
	name = "\improper Port Engine Maintenance"
	icon_state = "apmaint"

/area/shuttle/odyssey/maintenance/starboard
	name = "\improper Starboard Engine Maintenance"
	icon_state = "asmaint"

/area/shuttle/odyssey/maintenance/vacant_office
	name = "\improper Vacant Office"
	icon_state = "construction"

/area/shuttle/odyssey/crew_quarters/heads/ce
	name = "\improper Chief Engineer's Office"
	icon_state = "head_quarters"

/area/shuttle/odyssey/science/lab
	name = "\improper Research and Development"
	icon_state = "toxlab"

/area/shuttle/odyssey/infirmary/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"
	
/area/shuttle/odyssey/security/holding_cell
	name = "\improper Holding Cell"
	icon_state = "sec_prison"

/area/shuttle/odyssey/exterior
	name = "\improper Exterior"
	icon_state = "red"
	base_turf_type = /turf/space // Inherits the vLevel-aware get_base_turf_type() from the parent area.

/area/surface/nt_outpost
	name = "\improper Nanotrasen Outpost"
	icon_state = "bluenew"
	requires_power = 0

/area/odyssey
	name = "\improper Theseus"
	icon_state = "odyssey"
	requires_power = 0

/area/odyssey/admin
	name = "\improper Outpost Administration"
	icon_state = "conference"

/area/odyssey/cargo
	name = "\improper Outpost Cargo"
	icon_state = "cargo_bay"

/area/odyssey/clinic
	name = "\improper Outpost Clinic"
	icon_state = "virology"

/area/odyssey/store
	name = "\improper Outpost Store"
	icon_state = "blue"

/area/odyssey/mineral_processing
	name = "\improper Mineral Processing"
	icon_state = "mining_production"

/area/shuttle/odyssey_transfer
	name = "\improper NTEV Theseus Crew Transfer Shuttle"
	icon_state = "shuttle"
	requires_power = 0
