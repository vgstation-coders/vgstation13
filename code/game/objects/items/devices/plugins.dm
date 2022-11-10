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
	var/funny = FALSE

/obj/item/device/plugin/sleeper/ntbasic
	name = "Nanotrasen Simple Sleeper Upgrade Module"
	t1chems = list(
		MANNITOL = "Mannitol",
		PICCOLYN = "Piccolyn",
		SPRINKLES = "Sprinkles",
		)
	t2chems = list(
		ANTI_TOXIN = "Dylovene"
		)
	t3chems = list(
		MEDCOFFEE = "Lifeline",
		LOCUTOGEN = "Locutogen"
		)

/obj/item/device/plugin/sleeper/ntresearch
	name = "Nanotrasen Experimental Sleeper Upgrade Module"
	t3chems = list(
		MAHKOEXPITOL = "Mahkoexpitol"
		)
	//t1chems = MEDCOFFEE,
	//t2 = METRAZENE (dex+)
	//t3 = MORATHIAL (internal wound healing like bicard overdose)

/obj/item/device/plugin/sleeper/dan
	name = "Discount Dan's Discount Nutrition Injectors"
	advertisements = list("This injection was brought to you by Discount Dan!")
	t1chems = list(
		DISCOUNT = "Discount Dan's Sauce",
		GRAPEJUICE = "Discount Raisin Juice",
		TENDIES = "Chicken Tenders"
		)
	t2chems = list(
		REFRIEDBEANS = "Re-Fried Beans",
		OFFCOLORCHEESE = "American Cheese"
		)
	t3chems = list(
		BEFF = "Beff"
		)
	//Example of use, not implemented because gloop is owchies
	//emagchems = list(CHEESYGLOOP = "Cheesy Gloop")

/obj/item/device/plugin/sleeper/trader
	name = "Vox Shoal Sleeper Optimization Kit"
	mech_flags = MECH_SCAN_FAIL
	t1chems = list(
		NITROGEN = "Nitrogen",
		GRAVY = "Gravy"
		)
	t3chems = list(
		MAPLESYRUP = "Maple Syrup",
		CHILLWAX = "Chillwax"
		)

/obj/item/device/plugin/sleeper/alien
	name = "unknown device"
	desc = "A strange object. It has an image of what looks like a sleeper on it."
	override_chems = TRUE
	override_crit = TRUE
	mech_flags = MECH_SCAN_FAIL
	t1chems = list(
		UNKNOWNALPHA = "Mystery1"
		)
	t2chems = list(
		UNKNOWNDELTA = "Mystery2"
		)
	t3chems = list(
		UNKNOWNOMEGA = "Mystery3"
		)

/obj/item/device/plugin/sleeper/alien/proc/genName()
	var/button_desc = "[pick("a yellow","a purple","a green","a blue","a red","an orange","a white")], "
		button_desc += "[pick("round","square","diamond","heart","dog","human")] shaped "
		button_desc += "[pick("toggle","switch","lever","button","pad","hole")]"
	return button_desc

/obj/item/device/plugin/sleeper/clown
	name = "funny looking device"
	desc = "A strange object. It has an image of what looks like a sleeper on it."
	custom_hiss = 'sound/items/bikehorn.ogg'
	funny = TRUE
	t1chems = list(
		BANANA = "Banana Juice",
		HONKSERUM = "Clown Juice"
		)
	t2chems = list(
		LUBE = "Lube Juice"
		)
	t3chems = list(
		COLORFUL_REAGENT = "Colorful Juice"
		)

/obj/item/device/plugin/sleeper/gunk
	name = "damaged device"
	desc = "This looks like it was once a high tech piece of equipment, but now it's covered in toxic waste."
	override_chems = TRUE
	t1chems = list(
		TOXICWASTE = "Toxic Waste",
		CHEMICAL_WASTE = "Chemical Waste",
		SALTWATER = "Salt Water"
		)
	t2chems = list(
		BOOGER = "Boogers",
		VOMIT = "Vomit",
		BILK = "Bilk",
		)
	t3chems = list(
		//watch out this is literal garbage
		CHUMPARI = "Chumpari"
		)

