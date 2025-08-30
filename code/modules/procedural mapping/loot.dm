#define COMMON_LOOT 100
#define UNCOMMON_LOOT 50
#define RARE_LOOT 10
#define VERY_RARE_LOOT 1

//Loot tables
/datum/loot_table
	var/list/loot = list()


/datum/loot_table/bedsheet
	loot = list(
		/obj/item/weapon/bedsheet/black = COMMON_LOOT,
		/obj/item/weapon/bedsheet/blue = COMMON_LOOT,
		/obj/item/weapon/bedsheet/brown = COMMON_LOOT,
		/obj/item/weapon/bedsheet/green = COMMON_LOOT,
		/obj/item/weapon/bedsheet/medical = COMMON_LOOT,
		/obj/item/weapon/bedsheet/orange = COMMON_LOOT,
		/obj/item/weapon/bedsheet/plaid = UNCOMMON_LOOT,
		/obj/item/weapon/bedsheet/purple = COMMON_LOOT,
		/obj/item/weapon/bedsheet/red = COMMON_LOOT,
		/obj/item/weapon/bedsheet/yellow = COMMON_LOOT,
		/obj/item/weapon/bedsheet/clown = UNCOMMON_LOOT,
		/obj/item/weapon/bedsheet/linen = UNCOMMON_LOOT,
		/obj/item/weapon/bedsheet/mime = UNCOMMON_LOOT,
		/obj/item/weapon/bedsheet/rainbow = UNCOMMON_LOOT,
		/obj/item/weapon/bedsheet/rd = RARE_LOOT,
		/obj/item/weapon/bedsheet/hop = RARE_LOOT,
		/obj/item/weapon/bedsheet/hos = RARE_LOOT,
		/obj/item/weapon/bedsheet/captain = RARE_LOOT,
		/obj/item/weapon/bedsheet/ce = RARE_LOOT,
	)

/datum/loot_table/bureaucracy
	loot = list(
		/obj/item/toy/crayon/black = COMMON_LOOT,
		/obj/item/toy/crayon/blue = COMMON_LOOT,
		/obj/item/toy/crayon/green = COMMON_LOOT,
		/obj/item/toy/crayon/mime = COMMON_LOOT,
		/obj/item/toy/crayon/orange = COMMON_LOOT,
		/obj/item/toy/crayon/purple = COMMON_LOOT,
		/obj/item/toy/crayon/rainbow = COMMON_LOOT,
		/obj/item/toy/crayon/red = COMMON_LOOT,
		/obj/item/toy/crayon/yellow = COMMON_LOOT,
		/obj/item/weapon/folder = COMMON_LOOT,
		/obj/item/weapon/folder/black = COMMON_LOOT,
		/obj/item/weapon/folder/blue = COMMON_LOOT,
		/obj/item/weapon/folder/green = COMMON_LOOT,
		/obj/item/weapon/folder/mime = COMMON_LOOT,
		/obj/item/weapon/folder/orange = COMMON_LOOT,
		/obj/item/weapon/folder/purple = COMMON_LOOT,
		/obj/item/weapon/folder/rainbow = COMMON_LOOT,
		/obj/item/weapon/folder/red = COMMON_LOOT,
		/obj/item/weapon/folder/white = COMMON_LOOT,
		/obj/item/weapon/folder/yellow = COMMON_LOOT,
		/obj/item/weapon/gavelblock = COMMON_LOOT,
		/obj/item/weapon/gavelhammer = COMMON_LOOT,
		/obj/item/weapon/hand_labeler = COMMON_LOOT,
		/obj/item/weapon/paper/random = COMMON_LOOT,
		/obj/item/weapon/paper_bin = COMMON_LOOT,
		/obj/item/weapon/paper_pack = COMMON_LOOT,
		/obj/item/weapon/pen = COMMON_LOOT,
		/obj/item/weapon/pen/blue = COMMON_LOOT,
		/obj/item/weapon/pen/fountain = COMMON_LOOT,
		/obj/item/weapon/pen/invisible = COMMON_LOOT,
		/obj/item/weapon/pen/red = COMMON_LOOT,
		/obj/item/weapon/stamp/denied = COMMON_LOOT,
		/obj/item/weapon/storage/photo_album = COMMON_LOOT,
		/obj/item/weapon/glue/temp_glue = UNCOMMON_LOOT,
		/obj/item/weapon/pen/multi = UNCOMMON_LOOT,
		/obj/item/weapon/pen/sleepypen = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/captain = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/ce = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/chaplain = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/clown = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/cmo = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/hop = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/hos = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/hos = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/iaa = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/judge = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/mime = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/rd = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/trader = UNCOMMON_LOOT,
		/obj/item/weapon/stamp/warden = UNCOMMON_LOOT,
		/obj/item/weapon/storage/briefcase = UNCOMMON_LOOT,
		/obj/item/weapon/storage/briefcase/centcomm = UNCOMMON_LOOT,
		/obj/item/weapon/glue = RARE_LOOT,
		/obj/item/weapon/pen/paralysis = RARE_LOOT,
		/obj/item/weapon/pen/tactical = RARE_LOOT,
		/obj/item/weapon/storage/briefcase/insurance = RARE_LOOT,
		/obj/item/weapon/storage/briefcase/orderly = RARE_LOOT,
		/obj/item/weapon/storage/briefcase/false_bottomed = VERY_RARE_LOOT,
	)

/datum/loot_table/clothing
	loot = list()

/datum/loot_table/combat
	loot = list()

/datum/loot_table/decoration
	loot = list()

/datum/loot_table/engineering
	loot = list()

/datum/loot_table/entertainment
	loot = list()

/datum/loot_table/exotic
	loot = list()

/datum/loot_table/food_or_drink
	loot = list()

/datum/loot_table/medical
	loot = list()

/datum/loot_table/module
	loot = list(
		/obj/item/weapon/aiModule/core/asimov = COMMON_LOOT,
		/obj/item/weapon/aiModule/core/corp = COMMON_LOOT,
		/obj/item/weapon/aiModule/core/nanotrasen = COMMON_LOOT,
		/obj/item/weapon/aiModule/core/robocop = COMMON_LOOT,
		/obj/item/weapon/aiModule/freeform/core = COMMON_LOOT,
		/obj/item/weapon/aiModule/keeper = COMMON_LOOT,
		/obj/item/weapon/aiModule/purge = COMMON_LOOT,
		/obj/item/weapon/aiModule/core/hogan = UNCOMMON_LOOT,
		/obj/item/weapon/aiModule/core/lazymov = UNCOMMON_LOOT,
		/obj/item/weapon/aiModule/core/paladin = UNCOMMON_LOOT,
		/obj/item/weapon/aiModule/core/tyrant = UNCOMMON_LOOT,
		/obj/item/weapon/aiModule/randomize = UNCOMMON_LOOT,
		/obj/item/weapon/aiModule/standard/protectStation = UNCOMMON_LOOT,
		/obj/item/weapon/aiModule/standard/teleporterOffline = UNCOMMON_LOOT,
		/obj/item/weapon/aiModule/core/antimov = RARE_LOOT,
		/obj/item/weapon/aiModule/standard/oxygen = RARE_LOOT,
		/obj/item/weapon/aiModule/standard/quarantine = RARE_LOOT,
		/obj/item/weapon/aiModule/freeform/syndicate = VERY_RARE_LOOT,
		/obj/item/weapon/aiModule/targetted/safeguard = VERY_RARE_LOOT,
		/obj/item/weapon/aiModule/targetted/oneHuman = VERY_RARE_LOOT,
	)

/datum/loot_table/structure
	loot = list()

/datum/loot_table/trash
	loot = list()

#undef COMMON_LOOT
#undef UNCOMMON_LOOT
#undef RARE_LOOT
#undef VERY_RARE_LOOT
