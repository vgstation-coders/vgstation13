/area/ret/eng
	engine_smes
		name = "\improper Engineering SMES"
		icon_state = "engine_smes"
		requires_power = 0

	engine
		name = "RET Engineering"
		icon_state = "engine"

	engine_storage
		name = "RET Engineering Secure Storage"
		icon_state = "engine_storage"

	break_room
		name = "\improper RET Engineering Foyer"
		icon_state = "engine_lobby"

	burn_chamber
		name = "RET Burn Chamber"
		icon_state = "thermo_engine"

	atmos
		name = "RET Atmospherics"
		icon_state = "atmos"

	airlock1
		name = "RET Airlock no 1"
		icon_state = "engine"
	airlock2
		name = "RET Airlock no 2"
		icon_state = "engine"

/area/ret/bar
	name = "\improper Bar"
	icon_state = "bar"
/area/ret/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"






/area/ret/solar/solar
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = 0

	fportret
		name = "\improper FORE RET Port Solar Array"
		icon_state = "panelsA"
	aftportret
		name = "\improper AFT RET Port Solar Array"
		icon_state = "panelsA"


/area/ret/solar/fportsolarRET
	name = "FORE RET Port Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/ret/solar/aportsolarRET
	name = "AFT RET Port Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/ret/teleporter
	name = "\improper RET Teleporter"
	icon_state = "teleporter"

/area/ret/bridge
	name = "\improper RET Bridge"
	icon_state = "bridge"
	music = "signal"
	jammed=1

/area/ret/security/prison
	name = "\improper RET Prison Wing"
	icon_state = "sec_prison"

/area/ret/security/lobby
	name = "\improper RET Security Lobby"
	icon_state = "sec_lobby"
/area/ret/research
	name = "\improper RET Research"
	icon_state = "toxins"



/area/ret/hallway/central
	name = "\improper Central Primary Hallway"
	icon_state = "hallC"

/area/ret/hallway/maintenance/fore1
	name = "1Fore Maintenance"
	icon_state = "hallF"
/area/ret/hallway/maintenance/fore2
	name = "2Fore Maintenance"
	icon_state = "hallF"
/area/ret/hallway/maintenance/starboard1
	name = "1Starboard Maintenance"
	icon_state = "smaint"
/area/ret/hallway/maintenance/starboard2
	name = "2Starboard Maintenance"
	icon_state = "smaint"


/area/ret/crew_quarters/sleep
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/ret/crew_quarters/lobby
	name = "\improper Lobby Room"
	icon_state = "locker"