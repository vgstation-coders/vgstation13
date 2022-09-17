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
	desc = "Allows for the construction of circuit boards used to build a new APC."
	id = "apc_board"
	req_tech = list(Tc_POWERSTORAGE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 3)
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/power_control

/datum/design/station_map
	name = "Circuit Design (Station Holomap)"
	desc = "Allows for the construction of circuit boards used to build a station holomap."
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
	category = "Engineering Boards"
	build_path = /obj/item/weapon/circuitboard/ecb/advanced_airlock_controller

//RIG suit modules

/datum/design/rigsuit_health
	name = "Rigsuit health display"
	desc = "When installed, allows for onlookers to see the health of a person wearing a rigsuit."
	id = "rigsuit_health"
	req_tech = list(Tc_PROGRAMMING = 3)
	build_type = MECHFAB
	category = "Hardsuit_Upgrades"
	materials = list(MAT_GLASS = 2000, MAT_SILVER = 150)
	build_path = /obj/item/rig_module/health_readout

/datum/design/rigsuit_autorefill
	name = "Rigsuit atmosphere syphoner"
	desc = "When installed, the user's internals are replenished from the atmosphere they reside within."
	id = "rigsuit_autorefill"
	req_tech = list(Tc_PROGRAMMING = 3)
	build_type = MECHFAB
	category = "Hardsuit_Upgrades"
	materials = list(MAT_GLASS = 2000, MAT_SILVER = 150)
	build_path = /obj/item/rig_module/tank_refiller

/datum/design/rigsuit_gottagofast
	name = "Rigsuit joint lubrication"
	desc = "When installed, the module makes use of internal power supplies to optimize rigsuit joints, for better maneuverability."
	id = "rigsuit_lube"
	req_tech = list(Tc_PROGRAMMING = 3)
	build_type = MECHFAB
	category = "Hardsuit_Upgrades"
	materials = list(MAT_GLASS = 2000, MAT_SILVER = 150)
	build_path = /obj/item/rig_module/speed_boost

/datum/design/rigsuit_plasmaproof
	name = "Rigsuit plasma sealant"
	desc = "When installed and activated, ensures that the suit is now resistant to plasma contamination."
	id = "rigsuit_plasma"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_PLASMATECH = 4)
	build_type = MECHFAB
	category = "Hardsuit_Upgrades"
	materials = list(MAT_GLASS = 2000, MAT_SILVER = 1000, MAT_PLASMA = 1000)
	build_path = /obj/item/rig_module/plasma_proof

/datum/design/rigsuit_empshield
	name = "Rigsuit EMP dissipation module"
	desc = "When installed and activated, the suit is protected from EMPs but at the cost of additional cell charge depending on the severity."
	id = "rigsuit_empshield"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_POWERSTORAGE = 3, Tc_MAGNETS = 3)
	build_type = MECHFAB
	category = "Hardsuit_Upgrades"
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 2000)
	build_path = /obj/item/rig_module/emp_shield

/datum/design/rigsuit_radshield
	name = "Rigsuit radiation absorption device"
	desc = "When installed and activated, the suit protects the wearer from incoming radiation until its collectors are full."
	id = "rigsuit_radshield"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 4, Tc_POWERSTORAGE = 3, Tc_PLASMATECH = 2)
	build_type = MECHFAB
	category = "Hardsuit_Upgrades"
	materials = list(MAT_GLASS = 2000, MAT_PLASMA = 1000)
	build_path = /obj/item/rig_module/rad_shield

/datum/design/rigsuit_radshield_adv
	name = "Rigsuit high capacity radiation absorption device"
	desc = "An improved version of the R.A.D. featuring a higher capacity. When installed and activated, the suit protects the wearer from incoming radiation until its collectors are full."
	id = "rigsuit_radshield_adv"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 6, Tc_POWERSTORAGE = 4, Tc_PLASMATECH = 3)
	build_type = MECHFAB
	category = "Hardsuit_Upgrades"
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 1000, MAT_PLASMA = 1000)
	build_path = /obj/item/rig_module/rad_shield/adv

//Transit tube module

/datum/design/transit_pod
	name = "Circuit Design (Transit Pod Mainboard)"
	desc = "Allows for the construction of a transit tube pod."
	id = "transitpod_main"
	req_tech = list(Tc_PROGRAMMING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Misc"
	build_path = /obj/item/weapon/circuitboard/mecha/transitpod