// shotgun ammo for the ammolathe

/*/datum/design/shotgun/box/lethalshells //ordinary box of shotgun shells
	name = "Lethal shell box"
	desc = "A box of shotgun slugs."
	id = "lethalshells"
	req_tech = list(Tc_COMBAT = 1, Tc_MATERIALS = 1)
	build_type = AMLATHE
	materials = list(MAT_IRON = 90000, MAT_GLASS = 20000, MAT_PLASTIC = 10000, MAT_CARDBOARD = 3500)
	category = "shotgun"
	build_path = /obj/item/weapon/storage/box/lethalshells          this is the basic gist of what im trying to get at
*/
/datum/design/shotgun/placeholdershotgun//This is a placeholder for proof that the ammolathe can produce stuff and functions. Requesting input from you autists on what to put in
	name = "shotgun placeholder"
	desc = "shotgun placeholder"
	id = "shotgun test"
	req_tech = list(Tc_COMBAT = 1, Tc_MATERIALS = 1)
	build_type = AMLATHE
	materials = list(MAT_IRON = 5000)
	category = "shotgun"
	build_path = /obj/item/weapon/storage/box/lethalshells