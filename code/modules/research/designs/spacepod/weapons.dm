/datum/design/pod_gun_taser
	name = "Spacepod Equipment (Taser)"
	desc = "Allows for the construction of a spacepod mounted taser."
	id = "podgun_taser"
	build_type = PODFAB
	req_tech = list(Tc_MATERIALS = 2, Tc_COMBAT = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/taser
	category = "Pod_Weaponry"
	materials = list(MAT_IRON = 15000)

/datum/design/pod_gun_btaser
	name = "Spacepod Equipment (Burst Taser)"
	desc = "Allows for the construction of a spacepod mounted taser. This is the burst-fire model."
	id = "podgun_btaser"
	build_type = PODFAB
	req_tech = list(Tc_MATERIALS = 3, Tc_COMBAT = 3)
	build_path = /obj/item/device/spacepod_equipment/weaponry/taser/burst
	category = "Pod_Weaponry"
	materials = list(MAT_IRON = 15000)

/datum/design/pod_gun_laser
	name = "Spacepod Equipment (Laser)"
	desc = "Allows for the construction of a spacepod mounted laser."
	id = "podgun_laser"
	build_type = PODFAB
	req_tech = list(Tc_MATERIALS = 3, Tc_COMBAT = 3, Tc_PLASMATECH = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/laser
	category = "Pod_Weaponry"
	materials = list(MAT_IRON = 15000)
	locked = 1

/datum/design/pod_cargo_crate
	name = "Spacepod Cargo Bay (Crate)"
	desc = "Allows a space pod to hold a crate."
	id = "pod_crate"
	build_type = PODFAB
	build_path = /obj/item/device/spacepod_equipment/cargo/crate
	req_tech = list(Tc_MATERIALS = 2)
	category = "Pod_Parts"
	materials = list(MAT_IRON = 15000)

/datum/design/pod_lock
	name = "Spacepod Equipment (Toggle Lock)"
	desc = "Allows for the construction of a spacepod mounted locking system."
	id = "pod_lock"
	build_type = PODFAB
	build_path = /obj/item/device/spacepod_equipment/locking/lock
	req_tech = list(Tc_MATERIALS = 2, Tc_BLUESPACE = 2)
	category = "Pod_Parts"
	materials = list(MAT_IRON = 3500)

/datum/design/pod_key
	name = "Spacepod Equipment (Key)"
	desc = "To be paired with a toggle lock system."
	id = "pod_key"
	build_type = PODFAB
	build_path = /obj/item/device/pod_key
	req_tech = list(Tc_MATERIALS = 2, Tc_BLUESPACE = 2)
	category = "Pod_Parts"
	materials = list(MAT_IRON = 1500)
