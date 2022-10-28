//Plug-in Upgrade System, designed for Sleepers
//WIP VERSION DO NOT MERGE
/obj/item/device/plugin
	name = "plug-in device"
	desc = "Some device with a bunch of semi-standardized connectors."
	icon_state = "modkit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"
	var/icon/provide_overlay = null

/obj/item/device/plugin/sleeper
	name = "sleeper plug-in device"
	desc = "A plug-in device that looks like it would fit into a sleeper."

	var/list/t1chems = list()
	var/list/t2chems = list()
	var/list/t3chems = list()
	var/list/t4chems = list()
	var/list/emagchems = list()

	var/custom_hiss = null
	var/override_chems = FALSE
	var/override_crit = FALSE
	var/list/advertisements = list()

/obj/item/device/plugin/sleeper/ntbasic
	name = "Nanotrasen Simple Sleeper Upgrade Module"
	t1chems = list(COPPER = "Copper")

/obj/item/device/plugin/sleeper/ntresearch
	name = "Nanotrasen Experimental Sleeper Upgrade Module"

/obj/item/device/plugin/sleeper/dan
	name = "Discount Dan's Discount Nutrition Injectors"
	advertisements = list("This injection was brought to you by Discount Dan!")
	emagchems = list(CHEESYGLOOP = "Cheesy Gloop")

/obj/item/device/plugin/sleeper/trader
	name = "Vox Shoal Sleeper Optimization Kit"
	mech_flags = MECH_SCAN_FAIL
	t2chems = list(GRAVY = "Mmm... Gravy")

/obj/item/device/plugin/sleeper/alien
	name = "unknown device"
	desc = "A strange object. It has an image of what looks like a sleeper on it."
	override_chems = TRUE
	override_crit = TRUE
	t1chems = list(SIMPOLINOL = "Simpolinol")

/obj/item/device/plugin/sleeper/clown
	name = "Funny looking device"
	desc = "A strange object. It has an image of what looks like a sleeper on it."
	custom_hiss = 'sound/items/bikehorn.ogg'

