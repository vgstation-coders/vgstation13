//Loot tables
/datum/loot_table
	var/list/loot = list()


/datum/loot_table/bedsheet
	loot = list(
		"common" = list(
			/obj/item/weapon/bedsheet/black,
			/obj/item/weapon/bedsheet/blue,
			/obj/item/weapon/bedsheet/brown,
			/obj/item/weapon/bedsheet/green,
			/obj/item/weapon/bedsheet/medical,
			/obj/item/weapon/bedsheet/orange,
			/obj/item/weapon/bedsheet/purple,
			/obj/item/weapon/bedsheet/red,
			/obj/item/weapon/bedsheet/yellow,
		),
		"uncommon" = list(
			/obj/item/weapon/bedsheet/plaid,
			/obj/item/weapon/bedsheet/clown,
			/obj/item/weapon/bedsheet/linen,
			/obj/item/weapon/bedsheet/mime,
			/obj/item/weapon/bedsheet/rainbow,
		),
		"rare" = list(
			/obj/item/weapon/bedsheet/rd,
			/obj/item/weapon/bedsheet/hop,
			/obj/item/weapon/bedsheet/hos,
			/obj/item/weapon/bedsheet/captain,
			/obj/item/weapon/bedsheet/ce,
		),
		"very rare" = list()
	)

/datum/loot_table/bureaucracy
	loot = list(
		"common" = list(
			/obj/item/toy/crayon/black,
			/obj/item/toy/crayon/blue,
			/obj/item/toy/crayon/green,
			/obj/item/toy/crayon/mime,
			/obj/item/toy/crayon/orange,
			/obj/item/toy/crayon/purple,
			/obj/item/toy/crayon/rainbow,
			/obj/item/toy/crayon/red,
			/obj/item/toy/crayon/yellow,
			/obj/item/weapon/folder,
			/obj/item/weapon/folder/black,
			/obj/item/weapon/folder/blue,
			/obj/item/weapon/folder/green,
			/obj/item/weapon/folder/mime,
			/obj/item/weapon/folder/orange,
			/obj/item/weapon/folder/purple,
			/obj/item/weapon/folder/rainbow,
			/obj/item/weapon/folder/red,
			/obj/item/weapon/folder/white,
			/obj/item/weapon/folder/yellow,
			/obj/item/weapon/gavelblock,
			/obj/item/weapon/gavelhammer,
			/obj/item/weapon/hand_labeler,
			/obj/item/weapon/paper/random,
			/obj/item/weapon/paper_bin,
			/obj/item/weapon/paper_pack,
			/obj/item/weapon/pen,
			/obj/item/weapon/pen/blue,
			/obj/item/weapon/pen/fountain,
			/obj/item/weapon/pen/invisible,
			/obj/item/weapon/pen/red,
			/obj/item/weapon/stamp/denied,
			/obj/item/weapon/storage/photo_album,
		),
		"uncommon" = list(
			/obj/item/weapon/glue/temp_glue,
			/obj/item/weapon/pen/multi,
			/obj/item/weapon/pen/sleepypen,
			/obj/item/weapon/stamp/captain,
			/obj/item/weapon/stamp/ce,
			/obj/item/weapon/stamp/chaplain,
			/obj/item/weapon/stamp/clown,
			/obj/item/weapon/stamp/cmo,
			/obj/item/weapon/stamp/hop,
			/obj/item/weapon/stamp/hos,
			/obj/item/weapon/stamp/hos,
			/obj/item/weapon/stamp/iaa,
			/obj/item/weapon/stamp/judge,
			/obj/item/weapon/stamp/mime,
			/obj/item/weapon/stamp/rd,
			/obj/item/weapon/stamp/trader,
			/obj/item/weapon/stamp/warden,
			/obj/item/weapon/storage/briefcase,
			/obj/item/weapon/storage/briefcase/centcomm,
		),
		"rare" = list(
			/obj/item/weapon/glue,
			/obj/item/weapon/pen/paralysis,
			/obj/item/weapon/pen/tactical,
			/obj/item/weapon/storage/briefcase/insurance,
			/obj/item/weapon/storage/briefcase/orderly,
		),
		"very rare" = list(
			/obj/item/weapon/storage/briefcase/false_bottomed,
		)
	)

/datum/loot_table/clothing
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)

/datum/loot_table/combat
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)

/datum/loot_table/decoration
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)

/datum/loot_table/engineering
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)

/datum/loot_table/entertainment
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)

/datum/loot_table/exotic
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)

/datum/loot_table/food_or_drink
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)

/datum/loot_table/medical
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)

/datum/loot_table/module
	loot = list(
		"common" = list(
			/obj/item/weapon/aiModule/core/asimov,
			/obj/item/weapon/aiModule/core/corp,
			/obj/item/weapon/aiModule/core/nanotrasen,
			/obj/item/weapon/aiModule/core/robocop,
			/obj/item/weapon/aiModule/freeform/core,
			/obj/item/weapon/aiModule/keeper,
			/obj/item/weapon/aiModule/purge,
		),
		"uncommon" = list(
			/obj/item/weapon/aiModule/core/hogan,
			/obj/item/weapon/aiModule/core/lazymov,
			/obj/item/weapon/aiModule/core/paladin,
			/obj/item/weapon/aiModule/core/tyrant,
			/obj/item/weapon/aiModule/randomize,
			/obj/item/weapon/aiModule/standard/protectStation,
			/obj/item/weapon/aiModule/standard/teleporterOffline,
		),
		"rare" = list(
			/obj/item/weapon/aiModule/core/antimov,
			/obj/item/weapon/aiModule/standard/oxygen,
			/obj/item/weapon/aiModule/standard/quarantine,
		),
		"very rare" = list(
			/obj/item/weapon/aiModule/freeform/syndicate,
			/obj/item/weapon/aiModule/targetted/safeguard,
			/obj/item/weapon/aiModule/targetted/oneHuman,
		)
	)

/datum/loot_table/structure
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)

/datum/loot_table/trash
	loot = list(
		"common" = list(),
		"uncommon" = list(),
		"rare" = list(),
		"very rare" = list()
	)
