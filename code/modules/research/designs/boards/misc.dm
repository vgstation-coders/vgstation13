/datum/design/air_alarm
	name = "Circuit Design (Air Alarm)"
	desc = "Allows for the construction of circuit boards used to build an Air Alarm."
	id = "air_alarm"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 3)
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/air_alarm

/datum/design/fire_alarm
	name = "Circuit Design (Fire Alarm)"
	desc = "Allows for the construction of circuit boards used to build a Fire Alarm."
	id = "fire_alarm"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 3)
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/fire_alarm

/datum/design/airlock
	name = "Circuit Design (Airlock)"
	desc = "Allows for the construction of circuit boards used to build an airlock."
	id = "airlock"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 3)
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/airlock

/datum/design/intercom
	name = "Circuit Design (Intercom)"
	desc = "Allows for the construction of circuit boards used to build an intercom."
	id = "intercom"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 3)
	category = "Engineering Boards"
	build_path = /obj/item/weapon/intercom_electronics

/datum/design/apc_board
	name = "Circuit Design (Power Control Module)"
	desc = "Allows for the construction of circuit boards used to build a new APC"
	id = "apc_board"
	req_tech = list(Tc_POWERSTORAGE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 3)
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/power_control

/datum/design/station_map
	name = "Circuit Design (Station Holomap)"
	desc = "Allows for the construction of circuit boards used to build a station holomap"
	id = "station_map"
	req_tech = list(Tc_MAGNETS = 2, Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 3)
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/station_map

//ECBs

/datum/design/access_control
	name = "Circuit Design (Access Control)"
	desc = "Allows for the construction of ECB used to build an access control panel."
	id = "access_control"
	req_tech = list(Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/ecb/access_controller

/datum/design/airlock_control
	name = "Circuit Design (Airlock Control)"
	desc = "Allows for the construction of ECB used to build an airlock control panel."
	id = "airlock_control"
	req_tech = list(Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/ecb/airlock_controller

/datum/design/advanced_airlock_control
	name = "Circuit Design (Advanced Airlock Control)"
	desc = "Allows for the construction of ECB used to build an advanced control panel."
	id = "advanced_airlock_control"
	req_tech = list(Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	circuitboard/ecb/access_controller
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/ecb/advanced_airlock_controller
