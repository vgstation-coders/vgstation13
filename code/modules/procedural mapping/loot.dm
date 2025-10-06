#define COMMON_LOOT "common"
#define UNCOMMON_LOOT "uncommon"
#define RARE_LOOT "rare"
#define VERY_RARE_LOOT "very rare"
#define ULTRA_RARE_LOOT "ultra rare"


///////////// LOOT TABLES /////////////
//Unweighted
/datum/loot_table
	var/roll_mod = 0
	var/list/loot = list()

//Weighted
/datum/loot_table/weighted
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(),
		VERY_RARE_LOOT = list(),
		ULTRA_RARE_LOOT = list()
	)
	var/list/thresholds = list(
		COMMON_LOOT = 0,
		UNCOMMON_LOOT = 50,
		RARE_LOOT = 80,
		VERY_RARE_LOOT = 95,
		ULTRA_RARE_LOOT = 99
	)

// Rolls on the loot table, returning an item or null if nothing was found
/datum/loot_table/proc/loot_roll(var/rolls)
	var/list/results = list()
	for(var/i = 1; i <= rolls; i++)
		var/chosen_loot = pick(loot)
		if(chosen_loot)
			results += chosen_loot
	return results

/datum/loot_table/weighted/loot_roll(var/rolls)
	var/chosen_loot
	var/roll
	var/list/results = list()
	for(var/i = 1; i <= rolls; i++)
		roll = rand(1, 100) + roll_mod
		for(var/rarity in list(ULTRA_RARE_LOOT, VERY_RARE_LOOT, RARE_LOOT, UNCOMMON_LOOT, COMMON_LOOT))
			if(roll >= thresholds[rarity] && length(loot[rarity]))
				chosen_loot = pick(loot[rarity])
				break
		if(chosen_loot)
			results += chosen_loot
	return results


/datum/loot_table/bedsheet/New()
	loot += subtypesof(/obj/item/weapon/bedsheet)

/datum/loot_table/weighted/bureaucracy
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

/datum/loot_table/clothing/New()
	loot = subtypesof(/obj/item/clothing) - subtypesof(/obj/item/clothing/suit/armor)

/datum/loot_table/weighted/combat
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

/datum/loot_table/weighted/exotic
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

/datum/loot_table/weighted/structure
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

///////////// LOOT SPAWNERS /////////////
//I know I am recreating spawners here; I will unify the loot system Soon™.
/obj/abstract/loot_spawner
	name = "loot spawner"
	icon = 'icons/obj/map/spawners.dmi'
	icon_state = "loot"
	var/datum/loot_table/table //table to roll on
	var/list/loot = list() //list of loot to spawn
	var/list/base_containers = list(
		/obj/structure/closet/crate,
		/obj/structure/closet/crate/chest,
	)
	var/list/containers = list()
	var/roll_min = 1 //minimum rolls
	var/roll_max = 3 //maximum rolls
	var/rolls

/obj/abstract/loot_spawner/New(var/cave = FALSE,var/override = FALSE)
	..()
	if(!table)
		Destroy()
		return
	rolls = rand(roll_min, roll_max)
	table = new table()
	loot = table.loot_roll(rolls)
	if(containers.len)
		if(!override)
			if(cave) //spawn into chests if in a cave
				containers = list(
					/obj/structure/closet/crate/chest,
				)
			else
				containers = containers + base_containers
		spawn_into_container()
	else
		var/list/valid_turfs = list()
		for(var/turf/T in range(2, src))
			if(!T.density && !iswall(T))
				valid_turfs += T
		for(var/item_type in loot)
			new item_type(pick(valid_turfs))
	Destroy()

/obj/abstract/loot_spawner/proc/spawn_into_container()
	var/possible_container = pick(containers)
	if(ispath(possible_container, /obj/structure))
		var/obj/structure/container = new possible_container(loc)
		QDEL_LIST(container.contents) //no spawning with pre-existing contents
		for(var/item_type in loot)
			container.contents += new item_type()
		container = null
	else if(ispath(possible_container, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/container = new possible_container(loc)
		QDEL_LIST(container.contents)
		for(var/item_type in loot)
			container.contents += new item_type()
		container = null

/obj/abstract/loot_spawner/Destroy()
	loot = list()
	containers = list()
	table = null
	..()

/obj/abstract/loot_spawner/bedsheet
	name = "bedsheet spawner"
	icon_state = "loot_bedsheet"
	table = /datum/loot_table/bedsheet
	roll_min = 3
	roll_max = 10
	containers = list(
		/obj/structure/closet/crate/bin
	)

/obj/abstract/loot_spawner/bureaucracy
	name = "bureaucracy spawner"
	icon_state = "loot_bureaucracy"
	table = /datum/loot_table/weighted/bureaucracy
	roll_min = 2
	roll_max = 5
	containers = list(
		/obj/item/weapon/storage/briefcase,
		/obj/item/weapon/storage/briefcase/centcomm,
		/obj/item/weapon/storage/backpack,
		/obj/item/weapon/storage/backpack/messenger,
		/obj/item/weapon/storage/backpack/satchel,
		/obj/item/weapon/storage/box,
		/obj/item/weapon/storage/box/large,
	)

/obj/abstract/loot_spawner/clothing
	name = "clothing spawner"
	icon_state = "loot_clothing"
	table = /datum/loot_table/clothing
	roll_min = 3
	roll_max = 10
	containers = list(
		/obj/structure/closet/crate/bin,
		/obj/structure/closet/cabinet,
		/obj/item/weapon/storage/backpack,
		/obj/item/weapon/storage/bag/trash,
		/obj/item/weapon/storage/box,
		/obj/item/weapon/storage/box/large,
		/obj/item/weapon/storage/briefcase,
	)

/obj/abstract/loot_spawner/combat
	name = "combat spawner"
	icon_state = "loot_combat"
	table = /datum/loot_table/weighted/combat
	roll_min = 3
	roll_max = 10
	containers = list(
		/obj/item/weapon/storage/backpack/satchel_sec,
		/obj/structure/closet/syndicate,
	)

/obj/abstract/loot_spawner/decoration
	name = "decoration spawner"
	icon_state = "loot_decoration"
	table = /datum/loot_table/decoration
	roll_min = 3
	roll_max = 10
	containers = list(
		/obj/structure/closet,
		/obj/structure/closet/cabinet,
		/obj/structure/closet/crate/bin,
		/obj/structure/closet/crate/plastic,
		/obj/structure/closet/crate/trashcart,
	)

/obj/abstract/loot_spawner/engineering
	name = "engineering spawner"
	icon_state = "loot_engineering"
	table = /datum/loot_table/engineering
	roll_min = 2
	roll_max = 5
	containers = list(
		/obj/structure/closet/radiation,
		/obj/structure/closet/toolcloset,
		/obj/structure/closet/crate/engi,
		/obj/structure/closet/crate/trashcart,
	)

/obj/abstract/loot_spawner/entertainment
	name = "entertainment spawner"
	icon_state = "loot_entertainment"
	table = /datum/loot_table/entertainment
	roll_min = 3
	roll_max = 10
	containers = list(
		/obj/structure/closet,
		/obj/structure/closet/cabinet,
		/obj/structure/closet/crate/bin,
		/obj/structure/closet/crate/plastic,
		/obj/structure/closet/crate/trashcart,
		/obj/item/weapon/storage/box,
		/obj/item/weapon/storage/box/large,
	)

/obj/abstract/loot_spawner/exotic
	name = "exotic spawner"
	icon_state = "loot_exotic"
	table = /datum/loot_table/weighted/exotic
	roll_min = 1
	roll_max = 3
	containers = list(
		/obj/structure/closet/crate/ayy,
		/obj/structure/closet/crate/ayy2,
		/obj/structure/closet/crate/ayy3,
		/obj/structure/closet/ayy,
		/obj/structure/closet/ayy2,
		/obj/structure/closet/ayy3,
		/obj/structure/closet/acloset,
	)

/obj/abstract/loot_spawner/exotic/New(var/cave, var/override)
	..(cave, TRUE) //always spawn in the alien crates and not chests or regular crates

/obj/abstract/loot_spawner/food_or_drink
	name = "food_or_drink spawner"
	icon_state = "loot_food"
	table = /datum/loot_table/food_or_drink
	roll_min = 3
	roll_max = 10
	containers = list(
		/obj/structure/closet/cabinet,
		/obj/structure/closet/crate/bin,
		/obj/structure/closet/crate/freezer,
		/obj/structure/closet/crate/plastic,
		/obj/structure/closet/crate/trashcart,
		/obj/item/weapon/storage/box,
		/obj/item/weapon/storage/box/large,
	)

/obj/abstract/loot_spawner/medical
	name = "medical spawner"
	icon_state = "loot_medical"
	table = /datum/loot_table/medical
	roll_min = 3
	roll_max = 10
	containers = list(
		/obj/structure/closet/crate/freezer,
		/obj/structure/closet/crate/medical,
		/obj/structure/closet/crate/plastic,
	)

/obj/abstract/loot_spawner/module
	name = "module spawner"
	icon_state = "loot_module"
	table = /datum/loot_table/module
	roll_min = 3
	roll_max = 10
	containers = list(
		/obj/structure/closet/crate/sci,
		/obj/item/weapon/storage/box/mystery_circuit,
	)

/obj/abstract/loot_spawner/structure
	name = "structure spawner"
	icon_state = "loot_structure"
	table = /datum/loot_table/weighted/structure
	roll_min = 1
	roll_max = 1
	containers = list() //do not spawn in containers

/obj/abstract/loot_spawner/trash
	name = "trash spawner"
	icon_state = "loot_trash"
	table = /datum/loot_table/trash
	roll_min = 3
	roll_max = 10
	containers = list(
		/obj/structure/closet/crate/bin,
		/obj/structure/closet/crate/miningcar,
		/obj/structure/closet/crate/trashcart,
	)

/obj/abstract/loot_spawner/trash/on_ground
	containers = list()

#undef COMMON_LOOT
#undef UNCOMMON_LOOT
#undef RARE_LOOT
#undef VERY_RARE_LOOT
