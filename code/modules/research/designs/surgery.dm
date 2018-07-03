/datum/design/laserscalpel1
	name = "Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, allowing for bloodless incisions and built-in cautery."
	id = "laserscalpel1"
	req_tech = list(Tc_MATERIALS = 3, Tc_ENGINEERING = 2, Tc_BIOTECH = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000)
	category = "Surgery"
	build_path = /obj/item/weapon/scalpel/laser

/datum/design/laserscalpel2
	name = "High Precision Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, allowing for bloodless incisions and built-in cautery."
	id = "laserscalpel2"
	req_tech = list(Tc_MATERIALS = 4, Tc_ENGINEERING = 3, Tc_BIOTECH = 4)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000, MAT_URANIUM = 500)
	category = "Surgery"
	build_path = /obj/item/weapon/scalpel/laser/tier2

/datum/design/incisionmanager
	name = "Surgical Incision Manager"
	desc = "A true extension of the surgeon's body, this marvel instantly cuts the organ, clamp any bleeding, and retract the skin, allowing for the immediate commencement of therapeutic steps."
	id = "incisionmanager"
	req_tech = list(Tc_MATERIALS = 5, Tc_ENGINEERING = 4, Tc_BIOTECH = 5)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000, MAT_URANIUM = 250, MAT_SILVER = 500)
	category = "Surgery"
	build_path = /obj/item/weapon/retractor/manager

/datum/design/pico_grasper
	name = "Precision Grasper"
	desc = "A thin rod with pico manipulators embedded in it allowing for fast and precise extraction."
	id = "pico_grasper"
	req_tech = list(Tc_MATERIALS = 4, Tc_ENGINEERING = 3, Tc_BIOTECH = 4)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000, MAT_PLASMA = 80)
	category = "Surgery"
	build_path = /obj/item/weapon/hemostat/pico

/datum/design/plasmasaw
	name = "Plasma Saw"
	desc = "Perfect for cutting through ice."
	id = "plasmasaw"
	req_tech = list(Tc_MATERIALS = 5, Tc_ENGINEERING = 4, Tc_BIOTECH = 5, Tc_PLASMATECH = 3)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000, MAT_PLASMA = 500)
	category = "Surgery"
	build_path = /obj/item/weapon/circular_saw/plasmasaw

/datum/design/bonemender
	name = "Bone Mender"
	desc = "A favorite among skeletons. It even sounds like a skeleton too."
	id = "bonemender"
	req_tech = list(Tc_MATERIALS = 5, Tc_ENGINEERING = 4, Tc_BIOTECH = 5)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000, MAT_GOLD = 500, MAT_SILVER = 250)
	category = "Surgery"
	build_path = /obj/item/weapon/bonesetter/bone_mender

/datum/design/clot
	name = "Capillary Laying Operation Tool"
	desc = "A canister like tool that has two containers on it that stores synthetic vein or biofoam. There's a small processing port on the side where gauze can be inserted to produce biofoam."
	id = "clot"
	req_tech = list(Tc_MATERIALS = 5, Tc_ENGINEERING = 4, Tc_BIOTECH = 5)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 8000, MAT_SILVER = 1000)
	category = "Surgery"
	build_path = /obj/item/weapon/FixOVein/clot

/datum/design/diamond_surgicaldrill
	name = "Diamond Surgical Drill"
	desc = "Yours is the drill that will pierce the tiny heavens!"
	id = "diamond_surgicaldrill"
	req_tech = list(Tc_MATERIALS = 6, Tc_ENGINEERING = 4, Tc_BIOTECH = 5)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000, MAT_DIAMOND = 800)
	category = "Surgery"
	build_path = /obj/item/weapon/surgicaldrill/diamond

/datum/design/switchtool
	name = "Surgeon's Switchtool"
	desc = "A switchtool containing most of the necessary items for impromptu surgery. For the surgeon on the go."
	id = "switchtool"
	req_tech = list(Tc_MATERIALS = 5, Tc_BLUESPACE = 3, Tc_BIOTECH = 3)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000)
	category = "Surgery"
	build_path = /obj/item/weapon/switchtool/surgery

/datum/design/surgery_rollerbed
	name = "Mobile Operating Table"
	desc = "A collapsed mobile operating table that can be carried around."
	id = "surgery_rollerbed"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/roller/surgery
	req_tech = list(Tc_BIOTECH = 5, Tc_ENGINEERING = 4, Tc_PROGRAMMING = 2)
	materials = list(MAT_IRON = 10000, MAT_GLASS = 5000)
	category = "Surgery"
