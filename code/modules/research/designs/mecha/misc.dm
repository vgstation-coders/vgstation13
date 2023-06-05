/datum/design/phazon_phase_array
	name = "Phazon Phase Array"
	desc = "Show physics who's boss."
	id = "phazon_phasearray"
	req_tech = list(Tc_BLUESPACE = 10, Tc_PROGRAMMING = 4)
	build_type = MECHFAB
	materials = list(MAT_IRON = 5000, MAT_PHAZON = 2000)
	category = "Exosuit_Modules"
	build_path = /obj/item/mecha_parts/part/phazon_phase_array

/datum/design/firefighter_chassis
	name = "Structure (Firefighter chassis)"
	desc = "Used to build a Ripley Firefighter chassis."
	id = "firef_chassis"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/firefighter
	category = "Exosuit_Modules"
	materials = list(MAT_IRON=25000)

/datum/design/ripleyupgrade
	name = "APLU 'Ripley' MK-II Upgrade Kit"
	desc = "Used to upgrade an existing MK-I Ripley to its space-proof cousin. Cannot be removed once applied."
	id = "ripley_upgrade"
	req_tech = list(Tc_ENGINEERING = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/ripleyupgrade
	category = "Exosuit_Modules"
	materials = list(MAT_IRON= 20000, MAT_PLASMA = 5000)