//Plug-in Upgrade System, designed for Sleepers
/obj/item/device/plugin
	name = "plug-in device"
	desc = "Some device with a bunch of semi-standardized connectors. You can't tell what device this would fit into."
	icon_state = "modkit"
	item_state = "modkit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	force = 6
	throwforce = 15
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=4"
	//Will forcibly eject all other plugins from the machine when installed
	var/solo = FALSE

/obj/item/device/plugin/sleeper
	name = "sleeper plug-in device"
	desc = "A plug-in device that looks like it can connect to a sleeper."
	icon = 'icons/obj/machines/plugins/sleeperplugin.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/sleeperplugins.dmi', "right_hand" = 'icons/mob/in-hand/right/sleeperplugins.dmi')
	//Which chemicals are provided based on upgrade tier of the sleeper
	var/list/t1chems = list()
	var/list/t2chems = list()
	var/list/t3chems = list()
	var/list/t4chems = list()
	//Chems which are provided on an emagged sleeper with this plugin
	var/list/emagchems = list()

	//Hiss on exiting, good for honking clown plugins
	var/custom_hiss = null
	//Replace ALL other chems in the sleeper with this plugin's
	var/override_all_chems = FALSE
	//Able remove specific chemicals from the list completely. Usually used to remove specific base sleeper chemicals from being used.
	var/list/remove_chems = list()
	//Able to inject all chems on crit patients. Used mostly for terrible plugins that also override chems like above.
	var/override_all_crit = FALSE
	//Able to inject specific chems on crit patients. Used as a list.
	var/list/override_crit_chems = list()
	//List of advertisements to speak on injection. Will not speak if empty. Will combine if multiple.
	var/list/advertisements = list()
	//Will make the sleeper UI very colorful if set to TRUE
	var/funny = FALSE
	//Will lock down the information button on sleeper chemicals
	var/hides_info = FALSE

/**
	* Provides the core overlay of a sleeper, such as a recolor
	*/
/obj/item/device/plugin/sleeper/proc/provide_overlay(var/obj/machinery/sleeper/my_sleeper)
	return

/**
	* This will add any overlays that go on top of any basic sleeper recolors, such as screens or monitors.
	*/
/obj/item/device/plugin/sleeper/proc/provide_extra_overlay(var/obj/machinery/sleeper/my_sleeper)
	return

/obj/item/device/plugin/sleeper/ntbasic
	name = "Nanotrasen Simple Sleeper Upgrade Module"
	icon_state = "ntbasic"
	item_state = "ntbasic"
	flags = TWOHANDABLE | MUSTTWOHAND
	override_crit_chems = list(STOXIN2, LOCUTOGEN)
	//Additional effect located in reagents_medical.dm for STOXIN2 - doubles the sleep speed
	t1chems = list(
		IRON = "Iron",
		PICCOLYN = "Piccolyn",
		)
	t2chems = list(
		SPRINKLES = "Sprinkles",
		MANNITOL = "Mannitol"
		)
	t3chems = list(
		HYRONALIN = "Hyronalin"
		)

/obj/item/device/plugin/sleeper/ntbasic/provide_extra_overlay(var/obj/machinery/sleeper/my_sleeper)
	var/image/I = new('icons/obj/machines/plugins/sleeperplugin64x32.dmi', "ntbasic_[(my_sleeper.stat & (BROKEN|NOPOWER|FORCEDISABLE)) ? "off" : "on"]")
	I.pixel_x = -16
	my_sleeper.overlays += I

/obj/item/device/plugin/sleeper/ntresearch
	name = "Nanotrasen Experimental Sleeper Upgrade Module"
	icon_state = "miniconsole"
	item_state = "modkit"
	force = 3
	throwforce = 6
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	override_crit_chems = list(STOXIN2, LOCUTOGEN)
	t1chems = list(
		MAHKOEXPITOL = "Mahkoexpitol",
		BIOFOAM = "Biofoam"
		)
	t2chems = list(
		DEXALINP = "Dexalin Plus",
		MEDCOFFEE = "Lifeline"
		)
	t3chems = list(
		LOCUTOGEN = "Locutogen",
		MORATHIAL = "Morathial"
		)

/obj/item/device/plugin/sleeper/ntresearch/provide_extra_overlay(var/obj/machinery/sleeper/my_sleeper)
	my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "miniconsole_[(my_sleeper.stat & (BROKEN|NOPOWER|FORCEDISABLE)) ? "off" : "on"]")

/obj/item/device/plugin/sleeper/dan
	name = "Discount Dan's Discount Nutrition Injectors"
	icon_state = "dan"
	item_state = "danplug"
	advertisements = list("This injection was brought to you by Discount Dan!",
		"Discount Dan, he's the man!",
		"There ain't nothing better in this world than an injection of mystery.",
		"Don't listen to those other machines, buy my product!",
		"Quantity over Quality!",
		"Don't listen to those eggheads at the CDC, buy now!",
		"Discount Dan's: We're good for you! Nope, couldn't say it with a straight face.",
		"Discount Dan's: Only the best quality produ-*BZZT*")
	t1chems = list(
		DISCOUNT = "Discount Dan's Sauce",
		GRAPEJUICE = "Discount Raisin Juice",
		TENDIES = "Discount Tenders"
		)
	t2chems = list(
		REFRIEDBEANS = "Discount Beans",
		OFFCOLORCHEESE = "Discount Cheese"
		)
	t3chems = list(
		BEFF = "Discount Beef"
		)
	//west demanded this, so i've uncommented it. The murder sleeper is here.
	emagchems = list(CHEESYGLOOP = "Cheesy Gloop")

/obj/item/device/plugin/sleeper/dan/provide_overlay(var/obj/machinery/sleeper/my_sleeper)
	my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "dan_blue_[my_sleeper.occupant ? "closed" : "open"]")

/obj/item/device/plugin/sleeper/dan/provide_extra_overlay(var/obj/machinery/sleeper/my_sleeper)
	//beff injectors
	my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "dan_beff")

/obj/item/device/plugin/sleeper/trader
	name = "Vox Shoal Sleeper Optimization kit"
	icon_state = "vox"
	item_state = "voxplug"
	flags = TWOHANDABLE | MUSTTWOHAND
	mech_flags = MECH_SCAN_FAIL
	override_crit_chems = list(NITROGEN)
	remove_chems = list(TRICORDRAZINE)
	t1chems = list(
		NITROGEN = "Nitrogen",
		CHILLWAX = "Chillwax",
		)
	t2chems = list(
		MAPLESYRUP = "Maple Syrup",
		GRAVY = "Gravy"
		)
	t3chems = list(
		PRIAXATE = "Priaxate"
		)

/obj/item/device/plugin/sleeper/trader/provide_overlay(var/obj/machinery/sleeper/my_sleeper)
	my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "vox_[my_sleeper.occupant ? "closed" : "open"]")

/obj/item/device/plugin/sleeper/alien
	name = "unknown device"
	desc = "A strange object. It has an image of what looks like a sleeper on it."
	icon_state = "alien"
	item_state = "alienplug"
	flags = TWOHANDABLE | MUSTTWOHAND
	override_all_chems = TRUE
	override_all_crit = TRUE
	hides_info = TRUE
	solo = TRUE
	mech_flags = MECH_SCAN_FAIL

/obj/item/device/plugin/sleeper/alien/New()
	var/list/karmodrinks = list(SMOKYROOM, RAGSTORICHES, BAD_TOUCH, ELECTRIC_SHEEP, SUICIDE, SCIENTISTS_SERENDIPITY, METABUDDY,
								WAIFU, HUSBANDO, TOMBOY, BEEPSKY_CLASSIC, WEED_EATER, SPIDERS, GRAVSINGULO)
	t1chems = list(
		UNKNOWNALPHA = gen_alienchem_name(),
		pick_n_take(karmodrinks) = gen_alienchem_name()
		)
	t2chems = list(
		UNKNOWNDELTA = gen_alienchem_name(),
		pick_n_take(karmodrinks) = gen_alienchem_name()
		)
	t3chems = list(
		UNKNOWNOMEGA = gen_alienchem_name(),
		pick_n_take(karmodrinks) = gen_alienchem_name()
		)
	t4chems = list(
		pick_n_take(karmodrinks) = gen_alienchem_name(),
		pick_n_take(karmodrinks) = gen_alienchem_name()
		)
	//Mix them up so you don't know what's the karmo drink and the unknown agent!
	shuffle(t1chems)
	shuffle(t2chems)
	shuffle(t3chems)
	shuffle(t4chems)

/obj/item/device/plugin/sleeper/alien/proc/gen_alienchem_name()
	var/genned = ""
	var/list/syllables = list("sa","lu","to","n","bo","na","ve","spe","ro","no","non","ki","el","vi","far","tas",
	"ne","da","dan","ko","kon","ka","kaj","kin","de","ami","ko","kio","vin","nen","ne","nio","mi","gi","gis","per",
	"po","vas","va","he","min","mi","cu","dig","di","gi","gis","nu","ven","as","kie","re","ven","dau")
	for(var/i = 1 to pick(2,3,3,4))
		genned += pick(syllables)
	return capitalize(genned)

/obj/item/device/plugin/sleeper/alien/provide_overlay(var/obj/machinery/sleeper/my_sleeper)
	my_sleeper.icon = 'maps/defficiency/medbay.dmi'
	my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "alien_[my_sleeper.occupant ? "closed" : "open"]")

/obj/item/device/plugin/sleeper/alien/provide_extra_overlay(var/obj/machinery/sleeper/my_sleeper)
	//the evil light
	if(!(my_sleeper.stat & (BROKEN|NOPOWER|FORCEDISABLE)))
		my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "alien_effect_on")

/obj/item/device/plugin/sleeper/clown
	name = "funny looking device"
	desc = "A strange object. It has an image of what looks like a sleeper on it."
	icon_state = "clown"
	item_state = "clownplug"
	flags = TWOHANDABLE | MUSTTWOHAND
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

/obj/item/device/plugin/sleeper/clown/provide_overlay(var/obj/machinery/sleeper/my_sleeper)
	my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "clown_pink_[my_sleeper.occupant ? "closed" : "open"]")
	//rainbow glass
	if(my_sleeper.occupant)
		my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "clown_closed_[(my_sleeper.stat & (BROKEN|NOPOWER|FORCEDISABLE)) ? "off" : "on"]")
		//the hugger
		my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "clown_hug_closed")
	else
		my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "clown_open")
		my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "clown_hug")

/obj/item/device/plugin/sleeper/gunk
	name = "damaged device"
	desc = "This looks like it was once a high tech piece of equipment, but now it's covered in toxic waste. You can vaguely make out what looks like an image of a sleeper under the mess."
	icon_state = "gunk"
	item_state = "gunkplug"
	flags = TWOHANDABLE | MUSTTWOHAND
	override_all_chems = TRUE
	t1chems = list(
		TOXICWASTE = "Toxic Waste",
		CHEMICAL_WASTE = "Chemical Waste",
		SALTWATER = "Salt Water"
		)
	t2chems = list(
		BOOGER = "Boogers",
		VOMIT = "Vomit",
		BILK = "Bilk"
		)
	t3chems = list(
		MUCUS = "Mucus",
		//watch out this is literal garbage
		CHUMPARI = "Waste Water"
		)

/obj/item/device/plugin/sleeper/gunk/provide_overlay(var/obj/machinery/sleeper/my_sleeper)
	my_sleeper.overlays += new /image('icons/obj/machines/plugins/sleeperplugin.dmi', "vomit")
