/datum/design/misc/placeholdermisc //This is a placeholder for proof that the ammolathe can produce stuff and functions. Requesting input from you autists on what to put in
	name = "placeholdermisc"
	desc = "misc placeholder"
	id = "misc test"
	req_tech = list(Tc_COMBAT = 1, Tc_MATERIALS = 1) // i only made this thing just so i can have there be a way to build gun chargers without sucking admin dik to spawn one in
	build_type = AMLATHE // credit to sonix apache for the idea
	materials = list(MAT_IRON = 5000, MAT_GLASS = 3000) // i may have also been slightly inhebriated during 25% of the coding proccess
	category = "miscammo"
	build_path = /obj/item/weapon/storage/box/stunshells

/datum/design/misc/recharger //This is actually the one thing in the ammolathe folder that ISNT a placeholder
	name = "recharger kit"
	desc = "A kit to building a weapons charger"
	id = "recharger kit"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 5) // suggestions for tech levels n shit
	build_type = AMLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 10000) // suggestions for material price
	category = "miscammo"
	build_path = /obj/item/device/recharger_kit // the entire original point of this PR was to make these things

//	i swear on my life that in the final revision of the PR i will remove the shitposting