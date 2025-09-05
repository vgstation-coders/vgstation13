#define COMMON_LOOT "common"
#define UNCOMMON_LOOT "uncommon"
#define RARE_LOOT "rare"
#define VERY_RARE_LOOT "very rare"

//Loot tables
/datum/loot_table
	var/list/loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(),
		VERY_RARE_LOOT = list()
	)
	var/list/thresholds = list(
		COMMON_LOOT = 0,
		UNCOMMON_LOOT = 50,
		RARE_LOOT = 80,
		VERY_RARE_LOOT = 95
	)
	//Indicates which planets can spawn this loot table
	var/loot_flags = LOOT_TYPE_BEACH|LOOT_TYPE_DESERT|LOOT_TYPE_GRASS|LOOT_TYPE_JUNGLE|LOOT_TYPE_LAVA|LOOT_TYPE_SNOW|LOOT_TYPE_URBAN|LOOT_TYPE_XENO

// Rolls on the loot table, returning an item or null if nothing was found
/datum/loot_table/proc/loot_roll(roll_mod = 0)
	var/roll = rand(1, 100) + roll_mod

	var/list/possible_loot = list()

	for(var/rank in list(COMMON_LOOT, UNCOMMON_LOOT, RARE_LOOT, VERY_RARE_LOOT))
		if(roll >= thresholds[rank] && length(loot[rank]))
			possible_loot += loot[rank]

	if(length(possible_loot))
		return possible_loot[rand(1, length(possible_loot))]

// Merges multiple loot tables, returning a new one with the contents of all
/proc/merge_loot_table(...)
	var/list/tables = args
	if(!length(tables))
		return new /datum/loot_table

	var/datum/loot_table/new_table = new
	var/datum/loot_table/first_table = tables[1]
	if(!istype(first_table, /datum/loot_table))
		CRASH("Tried to merge a non-loot table!")

	// Initialize with the first table's structure
	for(var/rank in first_table.loot)
		new_table.loot[rank] = list()

	// Merge all tables
	for(var/datum/loot_table/table in tables)
		if(!istype(table, /datum/loot_table))
			CRASH("Tried to merge a non-loot table!")
		for(var/rank in new_table.loot)
			if(table.loot[rank])
				new_table.loot[rank] += table.loot[rank]

	return new_table

/datum/loot_table/bedsheet
	loot = list(
		COMMON_LOOT = list(
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
		UNCOMMON_LOOT = list(
			/obj/item/weapon/bedsheet/plaid,
			/obj/item/weapon/bedsheet/clown,
			/obj/item/weapon/bedsheet/linen,
			/obj/item/weapon/bedsheet/mime,
			/obj/item/weapon/bedsheet/rainbow,
		),
		RARE_LOOT = list(
			/obj/item/weapon/bedsheet/rd,
			/obj/item/weapon/bedsheet/hop,
			/obj/item/weapon/bedsheet/hos,
			/obj/item/weapon/bedsheet/captain,
			/obj/item/weapon/bedsheet/ce,
		),
		VERY_RARE_LOOT = list()
	)

/datum/loot_table/bureaucracy
	loot = list(
		COMMON_LOOT = list(
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
		UNCOMMON_LOOT = list(
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
		RARE_LOOT = list(
			/obj/item/weapon/glue,
			/obj/item/weapon/pen/paralysis,
			/obj/item/weapon/pen/tactical,
			/obj/item/weapon/storage/briefcase/insurance,
			/obj/item/weapon/storage/briefcase/orderly,
		),
		VERY_RARE_LOOT = list(
			/obj/item/weapon/storage/briefcase/false_bottomed,
		)
	)

/datum/loot_table/clothing

/datum/loot_table/clothing/New()
	loot[COMMON_LOOT] += subtypesof(/obj/item/clothing) - subtypesof(/obj/item/clothing/suit/armor)

/datum/loot_table/combat
	loot_flags = LOOT_TYPE_DESERT|LOOT_TYPE_JUNGLE|LOOT_TYPE_LAVA|LOOT_TYPE_SNOW|LOOT_TYPE_URBAN|LOOT_TYPE_XENO
	loot = list(
		COMMON_LOOT = list(
			/obj/item/weapon/bat,
			/obj/item/weapon/bat/spiked,
			/obj/item/weapon/beartrap,
			/obj/item/weapon/blunderbuss,
			/obj/item/weapon/boomerang,
			/obj/item/weapon/brick_sock,
			/obj/item/weapon/brick_sock/soap,
			/obj/item/weapon/cane,
			/obj/item/weapon/hammer,
			/obj/item/weapon/pitchfork,
			/obj/item/weapon/mop,
			/obj/item/weapon/melee/training_sword,
			/obj/item/weapon/scythe,
			/obj/item/weapon/shield/riot/buckler,
			/obj/item/weapon/shield/riot/roman,
			/obj/item/weapon/spear,
			/obj/item/weapon/melee/baton/cattleprod,
			/obj/item/weapon/melee/classic_baton,
			/obj/item/weapon/melee/wooden_club
			),
		UNCOMMON_LOOT = list(
			/obj/item/weapon/claymore,
			/obj/item/weapon/crossbow,
			/obj/item/weapon/fireaxe,
			/obj/item/weapon/grenade/flashbang,
			/obj/item/weapon/grenade/smokebomb,
			/obj/item/weapon/harpoon,
			/obj/item/weapon/hatchet,
			/obj/item/weapon/hatchet/tomahawk,
			/obj/item/weapon/hatchet/unathiknife,
			/obj/item/weapon/katana,
			/obj/item/weapon/shield/riot,
			/obj/item/weapon/melee/baton,
			/obj/item/weapon/melee/classic_baton/daystick,
			/obj/item/weapon/melee/energy/axe/rusty,
			/obj/item/weapon/melee/lance,
			/obj/item/weapon/gun/mahoguny,
			/obj/item/weapon/gun/lolly_lobber,
			),
		RARE_LOOT = list(
			/obj/item/weapon/banhammer,
			/obj/item/weapon/batteringram,
			/obj/item/weapon/blunderbuss/flawless,
			/obj/item/weapon/butterflyknife,
			/obj/item/weapon/caber,
			/obj/item/weapon/rsscimmy,
			/obj/item/weapon/shield/energy,
			/obj/item/weapon/melee/baton/harm,
			/obj/item/weapon/melee/baton/stunprobe,
			/obj/item/weapon/melee/energy/axe,
			/obj/item/weapon/melee/energy/sword,
			/obj/item/weapon/melee/energy/hfmachete,
			/obj/item/weapon/melee/lance/dire,
			/obj/item/weapon/melee/morningstar,
			/obj/item/weapon/melee/telebaton,
			/obj/item/weapon/gun/energy,
			/obj/item/weapon/gun/siren,
			/obj/item/weapon/gun/siren/caduceus,
			/obj/item/weapon/gun/siren/supersoaker,
			/obj/item/weapon/gun/portalgun,
			/obj/item/weapon/gun/grenadelauncher,
		),
		VERY_RARE_LOOT = list(
			/obj/item/weapon/butterflyknife/viscerator,
			/obj/item/weapon/c4,
			/obj/item/weapon/caber/admin,
			/obj/item/weapon/damocles,
			/obj/item/weapon/grenade/spawnergrenade/bearnade,
			/obj/item/weapon/grenade/spawnergrenade/beenade,
			/obj/item/weapon/grenade/spawnergrenade/manhacks,
			/obj/item/weapon/grenade/spawnergrenade/mothershipdrone,
			/obj/item/weapon/grenade/spawnergrenade/spesscarp,
			/obj/item/weapon/grenade/syndigrenade,
			/obj/item/weapon/katana/hfrequency,
			/obj/item/weapon/katana/magic,
			/obj/item/weapon/organ_remover/traitor,
			/obj/item/weapon/melee/morningstar/catechizer,
			/obj/item/weapon/gun/banannon,
			/obj/item/weapon/gun/bulletstorm,
			/obj/item/weapon/gun/tesla/preloaded,
			/obj/item/weapon/gun/stickybomb,
			/obj/item/weapon/gun/osipr,
			/obj/item/weapon/gun/grenadelauncher/syndicate,
			/obj/item/weapon/gun/gatling,
			/obj/item/weapon/gun/gatling/beegun,
			/obj/item/weapon/gun/gatling/beegun/chillgun,
			/obj/item/weapon/gun/gatling/beegun/hornetgun,
		)
	)

/datum/loot_table/decoration
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(),
		VERY_RARE_LOOT = list()
	)

/datum/loot_table/engineering
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(),
		VERY_RARE_LOOT = list()
	)

/datum/loot_table/entertainment
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(),
		VERY_RARE_LOOT = list()
	)

/datum/loot_table/exotic
	loot_flags = LOOT_TYPE_LAVA|LOOT_TYPE_XENO
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(),
		VERY_RARE_LOOT = list()
	)

/datum/loot_table/food_or_drink
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(),
		VERY_RARE_LOOT = list()
	)

/datum/loot_table/medical
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(
			/obj/item/weapon/dnainjector/nofail/randompower,),
		VERY_RARE_LOOT = list(
			/obj/item/weapon/dnascrambler,)
	)

/datum/loot_table/module
	loot = list(
		COMMON_LOOT = list(
			/obj/item/weapon/aiModule/core/asimov,
			/obj/item/weapon/aiModule/core/corp,
			/obj/item/weapon/aiModule/core/nanotrasen,
			/obj/item/weapon/aiModule/core/robocop,
			/obj/item/weapon/aiModule/freeform/core,
			/obj/item/weapon/aiModule/keeper,
			/obj/item/weapon/aiModule/purge,
		),
		UNCOMMON_LOOT = list(
			/obj/item/weapon/aiModule/core/hogan,
			/obj/item/weapon/aiModule/core/lazymov,
			/obj/item/weapon/aiModule/core/paladin,
			/obj/item/weapon/aiModule/core/tyrant,
			/obj/item/weapon/aiModule/randomize,
			/obj/item/weapon/aiModule/standard/protectStation,
			/obj/item/weapon/aiModule/standard/teleporterOffline,
		),
		RARE_LOOT = list(
			/obj/item/weapon/aiModule/core/antimov,
			/obj/item/weapon/aiModule/standard/oxygen,
			/obj/item/weapon/aiModule/standard/quarantine,
		),
		VERY_RARE_LOOT = list(
			/obj/item/weapon/aiModule/freeform/syndicate,
			/obj/item/weapon/aiModule/targetted/safeguard,
			/obj/item/weapon/aiModule/targetted/oneHuman,
		)
	)

/datum/loot_table/structure
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(),
		VERY_RARE_LOOT = list()
	)

/datum/loot_table/trash
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(),
		VERY_RARE_LOOT = list()
	)

//Top-tier loot only found in ruins
/datum/loot_table/ruins
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(
			/obj/item/weapon/organ_remover/adminbus_edition,
		),
		VERY_RARE_LOOT = list(
			/obj/item/weapon/meteor_gun, //lol
		)
	)

#undef COMMON_LOOT
#undef UNCOMMON_LOOT
#undef RARE_LOOT
#undef VERY_RARE_LOOT
