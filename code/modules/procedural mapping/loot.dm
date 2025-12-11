#define COMMON_LOOT "common"
#define UNCOMMON_LOOT "uncommon"
#define RARE_LOOT "rare"
#define VERY_RARE_LOOT "very rare"

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
	)
	var/list/thresholds = list(
		COMMON_LOOT = 0,
		UNCOMMON_LOOT = 50,
		RARE_LOOT = 80,
		VERY_RARE_LOOT = 95,
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
		for(var/rarity in list(VERY_RARE_LOOT, RARE_LOOT, UNCOMMON_LOOT, COMMON_LOOT))
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
		UNCOMMON_LOOT = list(
			/obj/item/weapon/glue/temp_glue,
			/obj/item/weapon/pen/multi,
			/obj/item/weapon/pen/sleepypen,
			/obj/item/weapon/stamp/captain,
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
			/obj/item/weapon/gun/siren/supersoaker,
			/obj/item/weapon/gun/portalgun,
			/obj/item/weapon/gun/grenadelauncher,
			/obj/item/weapon/sord,
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
		/obj/item/painting_brush,
		/obj/item/candle,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass,
		/obj/item/weapon/beach_ball,
		/obj/item/trash/candle,
		/obj/item/mounted/poster,
		/obj/item/weapon/storage/photo_album,
		/obj/item/device/flashlight/lamp,
		/obj/item/device/flashlight/lamp/green,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/mounted/frame/painting,
		/obj/item/mounted/frame/wreath,
		/obj/item/weapon/reagent_containers/glass/rag,
		/obj/item/weapon/lipstick/random,
		/obj/item/weapon/reagent_containers/food/drinks/flask,
		/obj/item/weapon/lighter/zippo,
		/obj/item/mounted/frame/painting/custom/random,
	)

/datum/loot_table/engineering
	loot = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wirecutters,
		/obj/item/device/multitool,
		/obj/item/device/t_scanner,
		/obj/item/device/analyzer,
		/obj/item/stack/cable_coil,
		/obj/item/stack/rods,
		/obj/item/device/flashlight,
		/obj/item/taperoll/engineering,
		/obj/item/weapon/extinguisher,
		/obj/item/device/geiger_counter,
		/obj/item/clothing/glasses/scanner/meson,
		/obj/item/clothing/head/hardhat,
		/obj/item/clothing/gloves/yellow,
		/obj/item/weapon/rcl,
		/obj/item/weapon/cell,
		/obj/item/weapon/glowstick,
		/obj/item/weapon/glowstick/red,
		/obj/item/weapon/glowstick/blue,
		/obj/item/weapon/circuitboard/airlock,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass,
		/obj/item/weapon/storage/belt/utility,
	)

/datum/loot_table/entertainment
	loot = list(
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/toy/katana,
		/obj/item/toy/foamblade,
		/obj/item/toy/gun,
		/obj/item/toy/crossbow,
		/obj/item/toy/cards,
		/obj/item/toy/cards/une,
		/obj/item/weapon/dice,
		/obj/item/weapon/storage/pill_bottle/dice,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/durand,
		/obj/item/toy/figure/clown,
		/obj/item/toy/figure/mime,
		/obj/item/toy/snappop,
		/obj/item/toy/bomb,
		/obj/item/toy/minimeteor,
		/obj/item/weapon/bikehorn,
		/obj/item/device/instrument/violin,
		/obj/item/device/instrument/guitar,
		/obj/item/device/instrument/harmonica,
		/obj/item/device/instrument/trombone,
		/obj/item/device/instrument/accordion,
		/obj/item/device/instrument/saxophone,
		/obj/item/device/instrument/recorder,
		/obj/item/device/instrument/glockenspiel,
		/obj/item/device/instrument/drum,
		/obj/item/device/instrument/drum/drum_makeshift,
		/obj/item/device/instrument/drum/drum_makeshift/bongos,
		/obj/structure/piano,
		/obj/structure/piano/xylophone,
		/obj/item/toy/plushie/bumbler,
		/obj/item/toy/plushie/bunny,
		/obj/item/toy/plushie/carp,
		/obj/item/toy/plushie/cat,
		/obj/item/toy/plushie/chicken,
		/obj/item/toy/plushie/corgi,
		/obj/item/toy/plushie/fancypenguin,
		/obj/item/toy/plushie/goat,
		/obj/item/toy/plushie/kitten,
		/obj/item/toy/plushie/kitten/wizard,
		/obj/item/toy/plushie/ladybug,
		/obj/item/toy/plushie/monkey,
		/obj/item/toy/plushie/narsie,
		/obj/item/toy/plushie/orca,
		/obj/item/toy/plushie/parrot,
		/obj/item/toy/plushie/penguin,
		/obj/item/toy/plushie/peacekeeper,
		/obj/item/toy/plushie/possum,
		/obj/item/toy/plushie/ratvar,
		/obj/item/toy/plushie/roach,
		/obj/item/toy/plushie/spacebear,
		/obj/item/toy/plushie/teddy,
		/obj/item/toy/plushie/fumo/atmostech,
		/obj/item/toy/plushie/fumo/assistant,
		/obj/item/toy/plushie/fumo/borg,
		/obj/item/toy/plushie/fumo/chef,
		/obj/item/toy/plushie/fumo/clown,
		/obj/item/toy/plushie/fumo/clown/clownette,
		/obj/item/toy/plushie/fumo/captain,
		/obj/item/toy/plushie/fumo/engi,
		/obj/item/toy/plushie/fumo/librarian,
		/obj/item/toy/plushie/fumo/mime,
		/obj/item/toy/plushie/fumo/miner,
		/obj/item/toy/plushie/fumo/nukeop,
		/obj/item/toy/plushie/fumo/nurse,
		/obj/item/toy/plushie/fumo/plasmaman,
		/obj/item/toy/plushie/fumo/scientist,
		/obj/item/toy/plushie/fumo/secofficer,
		/obj/item/toy/plushie/fumo/vox,
		/obj/item/toy/plushie/fumo/wizard,
		/obj/item/toy/plushie/fumo/touhou/alice,
		/obj/item/toy/plushie/fumo/touhou/cirno,
		/obj/item/toy/plushie/fumo/touhou/marisa,
		/obj/item/toy/plushie/fumo/touhou/mokou,
		/obj/item/toy/plushie/fumo/touhou/nitori,
		/obj/item/toy/plushie/fumo/touhou/patchouli,
		/obj/item/toy/plushie/fumo/touhou/reimu,
		/obj/item/toy/plushie/fumo/touhou/remilia,
		/obj/item/toy/plushie/fumo/touhou/sakuya,
		/obj/item/toy/plushie/fumo/touhou/yukari,
		/obj/item/toy/plushie/chicken/pomf,
		/obj/item/weapon/bikehorn,
		/obj/item/weapon/bikehorn/ankhhorn,
		/obj/item/weapon/bikehorn/rubberducky,
		/obj/item/weapon/bikehorn/rubberducky/quantum,
		/obj/item/weapon/bikehorn/skullhorn,
		/obj/item/weapon/bikehorn/syndicate,
		/obj/item/clothing/gloves/fyellow/insulted
	)

/datum/loot_table/weighted/exotic
	loot = list(
		COMMON_LOOT = list(
			/obj/item/weapon/fossil/plant,
			/obj/item/weapon/fossil/egg,
			/obj/item/weapon/strangerock,
		),
		UNCOMMON_LOOT = list(
			/obj/item/weapon/glow_orb,
			/obj/item/soulstone,
			/obj/item/weapon/reagent_containers/glass/replenishing,
			/obj/item/device/plugin/sleeper/alien,
			/obj/item/clothing/under/grey/grey_worker,
			/obj/item/clothing/under/grey/grey_scout,
			/obj/item/dictionary/martian,
			/obj/item/weapon/blood_tesseract/xenoarchfind,
		),
		RARE_LOOT = list(
			/obj/item/weapon/robot_spawner/strange/ball,
			/obj/item/weapon/robot_spawner/strange/egg,
			/obj/item/weapon/butterflyknife/viscerator/bunny,
			/obj/item/supermatter_splinter,
			/obj/structure/crystal,
			/obj/item/clothing/under/grey/grey_soldier,
			/obj/item/clothing/under/grey/grey_researcher,
			/obj/machinery/power/supermatter/shard,
			/obj/item/weapon/grenade/dudebomb,
		),
		VERY_RARE_LOOT = list(
			/obj/item/weapon/nullrod/sword/chaos/mimicry,
			/obj/item/weapon/dnascrambler,
			/obj/item/clothing/gloves/warping_claws,
			/obj/item/clothing/under/grey/grey_leader,
			/obj/machinery/vending/artifact,
			/obj/machinery/artifact,
			/obj/machinery/auto_cloner,
			/obj/machinery/communication,
			/obj/machinery/replicator,
			/obj/machinery/power/supermatter,
		)
	)

/datum/loot_table/food_or_drink/New()
	loot = subtypesof(/obj/item/weapon/reagent_containers/food)

/datum/loot_table/weighted/medical
	loot = list(
		COMMON_LOOT = list(
			/obj/item/weapon/reagent_containers/syringe,
			/obj/item/stack/medical/bruise_pack,
			/obj/item/stack/medical/ointment,
			/obj/item/stack/medical/splint,
			/obj/item/weapon/reagent_containers/pill/antitox,
			/obj/item/device/healthanalyzer,
			/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
			/obj/item/weapon/reagent_containers/glass/beaker/vial,
			/obj/item/weapon/storage/pill_bottle,
			/obj/item/weapon/thermometer,
		),
		UNCOMMON_LOOT = list(
			/obj/item/weapon/reagent_containers/hypospray,
			/obj/item/clothing/glasses/hud/health,
			/obj/item/weapon/storage/pill_bottle/antitox,
			/obj/item/weapon/storage/pill_bottle,
			/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
			/obj/item/weapon/storage/firstaid/regular,
			/obj/item/weapon/storage/firstaid/toxin,
			/obj/item/device/antibody_scanner,
			/obj/item/weapon/reagent_containers/glass/bottle/stoxin,
			/obj/item/weapon/reagent_containers/glass/bottle/charcoal,
			/obj/item/stack/medical/advanced/bruise_pack,
			/obj/item/stack/medical/advanced/ointment,
		),
		RARE_LOOT = list(
			/obj/item/weapon/dnainjector/nofail/randompower,
			/obj/item/weapon/storage/firstaid/adv,
			/obj/item/weapon/autopsy_scanner,
			/obj/item/tool/scalpel,
			/obj/item/tool/surgicaldrill,
			/obj/item/tool/FixOVein,
			/obj/item/tool/bonegel,
			/obj/item/tool/bonesetter,
			/obj/item/weapon/storage/firstaid/internalbleed,
			/obj/item/weapon/implanter/adrenalin,
		),
		VERY_RARE_LOOT = list(
			/obj/item/weapon/dnascrambler,
			/obj/item/weapon/reagent_containers/glass/bottle/peridaxon,
			/obj/item/weapon/organ_remover/traitor,
			/obj/item/weapon/implanter/peace,
			/obj/item/weapon/medbot_cube,
		)
	)

/datum/loot_table/module
	loot = list(
		/obj/item/weapon/aiModule/core/asimov,
		/obj/item/weapon/aiModule/core/corp,
		/obj/item/weapon/aiModule/core/nanotrasen,
		/obj/item/weapon/aiModule/core/robocop,
		/obj/item/weapon/aiModule/freeform/core,
		/obj/item/weapon/aiModule/keeper,
		/obj/item/weapon/aiModule/purge,
		/obj/item/weapon/aiModule/core/hogan,
		/obj/item/weapon/aiModule/core/lazymov,
		/obj/item/weapon/aiModule/core/paladin,
		/obj/item/weapon/aiModule/core/tyrant,
		/obj/item/weapon/aiModule/randomize,
		/obj/item/weapon/aiModule/standard/protectStation,
		/obj/item/weapon/aiModule/standard/teleporterOffline,
		/obj/item/weapon/aiModule/core/antimov,
		/obj/item/weapon/aiModule/standard/oxygen,
		/obj/item/weapon/aiModule/standard/quarantine,
		/obj/item/weapon/aiModule/freeform/syndicate,
		/obj/item/weapon/aiModule/targetted/safeguard,
		/obj/item/weapon/aiModule/targetted/oneHuman,
	)

/datum/loot_table/weighted/structure
	loot = list(
		COMMON_LOOT = list(),
		UNCOMMON_LOOT = list(),
		RARE_LOOT = list(
			/obj/machinery/vending/cola,
			/obj/machinery/vending/snack,
			/obj/machinery/vending/coffee,
			/obj/machinery/vending/artifact,
		),
		VERY_RARE_LOOT = list(
			/obj/structure/bed/chair/wood/throne,
			/obj/machinery/replicator,
			/obj/machinery/communication,
			/obj/machinery/artifact,
			/obj/machinery/auto_cloner,
		)
	)

/datum/loot_table/trash
	loot = list(
		/obj/item/trash/raisins,
		/obj/item/trash/candy,
		/obj/item/trash/chips,
		/obj/item/trash/popcorn,
		/obj/item/trash/sosjerky,
		/obj/item/trash/syndi_cakes,
		/obj/item/trash/waffles,
		/obj/item/trash/plate,
		/obj/item/trash/snack_bowl,
		/obj/item/trash/pistachios,
		/obj/item/trash/tray,
		/obj/item/trash/candle,
		/obj/item/trash/liquidfood,
		/obj/item/trash/soda_cans,
		/obj/item/trash/cigbutt,
		/obj/item/trash/cigbutt/spaceportbutt,
		/obj/item/trash/broken_ashtray,
		/obj/item/trash/used_tray,
		/obj/item/trash/emptybowl,
		/obj/item/trash/packet/ketchup,
		/obj/item/trash/packet/mayo,
		/obj/item/trash/packet/soysauce,
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
	if(ispath(possible_container, /obj/structure/closet/crate/chest) && prob(10)) // it's a mimic!!
		new /mob/living/simple_animal/hostile/mimic/crate/chest(loc)
		return
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
	table = /datum/loot_table/weighted/medical
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

/obj/abstract/loot_spawner/story
	containers = list(
		/obj/item/weapon/storage/briefcase,
		/obj/item/weapon/storage/briefcase/centcomm,
	)

/obj/abstract/loot_spawner/story/New(var/spawn_loc, var/loot_type, var/list/container_types)
	if(spawn_loc)
		loc = spawn_loc
	if(!loot_type)
		qdel(src)
		return
	roll_min = rand(1,3)
	roll_max = rand(roll_min,10)
	table = loot_type
	if(container_types?.len)
		containers = container_types
	rolls = rand(roll_min, roll_max)
	table = new table()
	loot = table.loot_roll(rolls)
	if(containers.len)
		containers = containers + base_containers
		spawn_into_container()
	else
		var/list/valid_turfs = list()
		for(var/turf/T in range(2, src))
			if(!T.density && !iswall(T))
				valid_turfs += T
		for(var/item_type in loot)
			new item_type(pick(valid_turfs))
	qdel(src)

#undef COMMON_LOOT
#undef UNCOMMON_LOOT
#undef RARE_LOOT
#undef VERY_RARE_LOOT
