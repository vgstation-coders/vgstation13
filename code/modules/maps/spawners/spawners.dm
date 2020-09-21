
//**************************************************************
//
// Spawners
// -------------
// Enjoy.
//
//**************************************************************

/obj/abstract/map/spawner
	icon = 'icons/obj/map/spawners.dmi'
	var/amount = 1
	var/chance = 100
	var/jiggle = 0
	var/list/to_spawn = list()

/obj/abstract/map/spawner/perform_spawn()

	for(amount, amount, amount--)
		if(prob(chance))
			CreateItem(pick(to_spawn))
	qdel(src)

/obj/abstract/map/spawner/proc/CreateItem(new_item_type)
	var/obj/spawned = new new_item_type(loc)

	if(jiggle)
		spawned.pixel_x = rand(-jiggle, jiggle)
		spawned.pixel_y = rand(-jiggle, jiggle)

	return spawned

//**************************************************************
// Subtypes ////////////////////////////////////////////////////
//**************************************************************

// Medical /////////////////////////////////////////////////////

/obj/abstract/map/spawner/medical/drugs
	name = "medical drug spawner"
	icon_state = "med_drugs"
	amount = 5
	chance = 50
	to_spawn = list(
		/obj/item/reagent_containers/glass/beaker/cryoxadone,
		/obj/item/reagent_containers/glass/bottle/antitoxin,
		/obj/item/reagent_containers/glass/bottle/mutagen,
		/obj/item/reagent_containers/glass/bottle/capsaicin,
		/obj/item/reagent_containers/glass/bottle/frostoil,
		/obj/item/reagent_containers/glass/bottle/inaprovaline,
		/obj/item/reagent_containers/glass/bottle/stoxin,
		/obj/item/reagent_containers/glass/bottle/chloralhydrate,
		/obj/item/reagent_containers/syringe/inaprovaline,
		/obj/item/reagent_containers/syringe/antitoxin,
		/obj/item/reagent_containers/syringe/antiviral,
		/obj/item/storage/pill_bottle/antitox,
		/obj/item/storage/pill_bottle/inaprovaline,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/reagent_containers/blood/OMinus,
		/obj/item/reagent_containers/hypospray/autoinjector,
		)

/obj/abstract/map/spawner/medical/pills
	name = "medical pill spawner"
	icon_state = "med_pills"
	amount = 10
	chance = 75
	jiggle = 6
	to_spawn = list(
		/obj/item/reagent_containers/pill/antitox,
		/obj/item/reagent_containers/pill/tox,
		/obj/item/reagent_containers/pill/stox,
		/obj/item/reagent_containers/pill/kelotane,
		/obj/item/reagent_containers/pill/tramadol,
		/obj/item/reagent_containers/pill/citalopram,
		/obj/item/reagent_containers/pill/inaprovaline,
		/obj/item/reagent_containers/pill/dexalin,
		/obj/item/reagent_containers/pill/bicaridine,
		/obj/item/reagent_containers/pill/happy,
		/obj/item/reagent_containers/pill/zoom,
		)

// Security ////////////////////////////////////////////////////

/obj/abstract/map/spawner/security/armor
	name = "armory armor spawner"
	icon_state = "armory_armor"
	to_spawn = list(
		/obj/item/clothing/suit/armor/riot,
		/obj/item/clothing/suit/armor/bulletproof,
		/obj/item/clothing/suit/armor/laserproof,
		/obj/item/clothing/suit/armor/heavy,
		/obj/item/clothing/suit/armor/reactive,
		)

/obj/abstract/map/spawner/security/gear
	name = "armory gear spawner"
	icon_state = "armory_gear"
	amount = 3
	to_spawn = list(
		/obj/item/clothing/head/helmet/tactical/riot,
		/obj/item/shield/riot,
		/obj/item/melee/baton/loaded,
		/obj/item/clothing/suit/armor/vest/security,
		/obj/item/storage/belt/security,
		/obj/item/gun/energy/taser,
		/obj/item/device/hailer,
		)

/obj/abstract/map/spawner/security/weapons
	name = "armory weapon spawner"
	icon_state = "armory_weapons"
	to_spawn = list(
		/obj/item/gun/energy/gun,
		/obj/item/gun/energy/ionrifle,
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/laser/cannon,
		/obj/item/gun/projectile/automatic/uzi,
		/obj/item/gun/projectile/automatic,
		/obj/item/gun/projectile/automatic/l6_saw,
		/obj/item/gun/projectile/deagle,
		/obj/item/gun/projectile/mateba,
		/obj/item/gun/projectile/pistol,
		/obj/item/gun/projectile/shotgun/pump,
		/obj/item/gun/projectile/shotgun/pump/combat,
		)

/obj/abstract/map/spawner/security/misc
	name = "armory misc spawner"
	icon_state = "armory_misc"
	amount = 2
	jiggle = 5
	to_spawn = list(
		/obj/item/storage/box/flashbangs,
		/obj/item/storage/box/emps,
		/obj/item/storage/box/handcuffs,
		/obj/item/storage/box/donkpockets,
		/obj/item/storage/fancy/donut_box,
		)

// Engineering /////////////////////////////////////////////////

/obj/abstract/map/spawner/engi/materials
	name = "engie materials spawner"
	icon_state = "engi_materials"
	amount = 2
	chance = 75
	to_spawn = list(
		/obj/item/stack/sheet/glass/glass{amount = 50},
		/obj/item/stack/sheet/glass/rglass{amount = 50},
		/obj/item/stack/sheet/glass/plasmaglass{amount = 50},
		/obj/item/stack/light_w{amount = 50},
		/obj/item/stack/sheet/mineral/plastic{amount = 50},
		/obj/item/stack/sheet/metal{amount = 50},
		/obj/item/stack/sheet/plasteel{amount = 50},
		/obj/item/stack/sheet/wood{amount = 50},
		/obj/item/stack/rods{amount = 50},
		/obj/item/stack/tile/grass{amount = 50},
		)

/obj/abstract/map/spawner/engi/dispensers
	name = "engie dispenser spawner"
	icon_state = "engi_dispensers"
	chance = 50
	to_spawn = list(
		/obj/structure/reagent_dispensers/fueltank,
		/obj/structure/reagent_dispensers/watertank,
		)

/obj/abstract/map/spawner/engi/machinery
	name = "engie machinery spawner"
	icon_state = "engi_machinery"
	chance = 75
	to_spawn = list(
		/obj/machinery/atmospherics/binary/circulator,
		/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe,
		/obj/machinery/field_generator,
		/obj/machinery/floodlight,
		/obj/machinery/mineral/mint,
		/obj/machinery/monkey_recycler,
		/obj/machinery/photocopier,
		/obj/machinery/pipedispenser,
		/obj/machinery/porta_turret,
		/obj/machinery/power/am_control_unit,
		/obj/machinery/power/emitter,
		/obj/machinery/power/generator,
		/obj/machinery/power/port_gen/pacman/mrs,
		/obj/machinery/power/rad_collector,
		/obj/machinery/power/rust_core,
		/obj/machinery/power/rust_fuel_injector,
		/obj/machinery/power/battery/smes,
		/obj/machinery/processor,
		/obj/machinery/recharge_station,
		/obj/machinery/rust/gyrotron,
		/obj/machinery/shield_gen,
		/obj/machinery/shieldgen,
		/obj/machinery/shieldwallgen,
		/obj/machinery/space_heater,
		/obj/machinery/suit_storage_unit/engie,
		/obj/machinery/telecomms/allinone,
		/obj/machinery/teleport/station,
		/obj/machinery/the_singularitygen,
		/obj/machinery/vending/dinnerware,
		/obj/machinery/vending/engineering,
		/obj/machinery/vending/plasmaresearch,
		/obj/machinery/vending/robotics,
		/obj/machinery/vending/sovietsoda,
		/obj/structure/AIcore,
		/obj/structure/piano,
		/obj/structure/particle_accelerator/fuel_chamber,
		/obj/structure/reagent_dispensers/fueltank,
		/obj/structure/reagent_dispensers/water_cooler,
		/obj/structure/safe,
		/obj/structure/shuttle/engine/router,
		/obj/structure/toilet,
		/obj/structure/turret/gun_turret,
		/obj/spacepod/random,
		)

// Assistants //////////////////////////////////////////////////

/obj/abstract/map/spawner/assistant/tools
	name = "assistant tool spawner"
	icon_state = "ass_tools"
	amount = 3
	chance = 50
	to_spawn = list(
		/obj/item/device/analyzer,
		/obj/item/device/assembly/igniter,
		/obj/item/device/assembly/infra,
		/obj/item/device/assembly/mousetrap,
		/obj/item/device/assembly/prox_sensor,
		/obj/item/device/assembly/signaler,
		/obj/item/device/assembly/timer,
		/obj/item/device/assembly/voice,
		/obj/item/device/flashlight,
		/obj/item/device/lightreplacer,
		/obj/item/device/multitool,
		/obj/item/device/radio,
		/obj/item/device/t_scanner,
		/obj/item/device/taperecorder,
		/obj/item/device/toner,
		/obj/item/device/label_roll,
		/obj/item/toy/snappop,
		/obj/item/toy/crayon/blue,
		/obj/item/toy/crayon/orange,
		/obj/item/c_tube,
		/obj/item/stack/cable_coil/random,
		/obj/item/camera_assembly,
		/obj/item/cell,
		/obj/item/crowbar,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/extinguisher,
		/obj/item/hand_labeler,
		/obj/item/light/bulb,
		/obj/item/light/tube,
		/obj/item/lighter/random,
		/obj/item/pen,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/micro_laser,
		/obj/item/storage/belt/utility,
		/obj/item/storage/toolbox/electrical,
		)

/obj/abstract/map/spawner/assistant/materials
	name = "assistant materials spawner"
	icon_state = "ass_materials"
	amount = 2
	chance = 50
	to_spawn = list(
		/obj/item/stack/sheet/glass/glass{amount = 50},
		/obj/item/stack/sheet/leather{amount = 50},
		/obj/item/stack/sheet/mineral/plastic{amount = 50},
		/obj/item/stack/sheet/metal{amount = 50},
		/obj/item/stack/sheet/wood{amount = 50},
		/obj/item/stack/sheet/cloth{amount = 50},
		/obj/item/stack/sheet/cardboard{amount = 50},
		/obj/item/stack/rods{amount = 50},
		/obj/item/stack/sheet/mineral/sandstone{amount = 50},
		)

// Maintenance /////////////////////////////////////////////////

/obj/abstract/map/spawner/maint
	name = "maint loot spawner"
	icon_state = "maint"
	amount = 2
	chance = 50
	to_spawn = list(
		/obj/item/device/assembly/igniter,
		/obj/item/device/assembly/infra,
		/obj/item/device/assembly/mousetrap,
		/obj/item/device/assembly/prox_sensor,
		/obj/item/device/assembly/signaler,
		/obj/item/device/assembly/timer,
		/obj/item/device/assembly/voice,
		/obj/item/storage/belt/utility,
		/obj/item/device/multitool,
		/obj/item/device/paicard,
		/obj/item/device/flashlight,
		/obj/item/device/flashlight/lantern,
		/obj/item/device/flashlight/flare,
		/obj/item/weldingtool/largetank,
		/obj/item/device/gps,
		/obj/item/device/gps/science,
		/obj/item/device/gps/engineering,
		/obj/item/cell/super,
		/obj/item/soap/nanotrasen,
		/obj/item/device/flash,
		/obj/item/device/transfer_valve,
		/obj/item/device/camera_bug,
		/obj/item/device/handtv,
		/obj/item/device/camera,
		/obj/item/device/camera_film,
		/obj/item/device/encryptionkey,
		/obj/item/device/encryptionkey/binary,
		/obj/item/device/hailer,
		/obj/item/device/healthanalyzer,
		/obj/item/device/mass_spectrometer,
		/obj/item/device/megaphone,
		/obj/item/device/mmi/radio_enabled,
		/obj/item/device/reagent_scanner,
		/obj/item/device/soundsynth,
		/obj/item/toy/balloon/glove,
		/obj/item/storage/toolbox/electrical,
		/obj/item/ammo_storage/magazine/a12mm,
		/obj/item/ammo_storage/box/c45,
		/obj/item/ammo_storage/box/a418,
		/obj/item/ammo_storage/magazine/a75,
		/obj/item/ammo_storage/speedloader/c38,
		/obj/item/ammo_storage/box/c9mm,
		/obj/item/ammo_storage/magazine/mc9mm,
		/obj/item/bodybag,
		/obj/item/clothing/ears/earmuffs,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/clothing/glasses/regular,
		/obj/item/clothing/glasses/regular/hipster,
		/obj/item/clothing/glasses/sunglasses/blindfold,
		/obj/item/clothing/glasses/sunglasses/prescription,
		/obj/item/clothing/glasses/welding,
		/obj/item/clothing/gloves/brown,
		/obj/item/clothing/gloves/latex,
		/obj/item/clothing/gloves/black,
		/obj/item/clothing/gloves/fyellow,
		/obj/item/clothing/gloves/purple,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/cakehat,
		/obj/item/clothing/head/cardborg,
		/obj/item/clothing/head/chicken,
		/obj/item/clothing/head/collectable/flatcap,
		/obj/item/clothing/head/collectable/pirate,
		/obj/item/clothing/head/collectable/wizard,
		/obj/item/clothing/head/collectable/tophat,
		/obj/item/clothing/head/nun_hood,
		/obj/item/clothing/head/plaguedoctorhat,
		/obj/item/clothing/head/soft/grey,
		/obj/item/clothing/head/surgery/blue,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/mask/cigarette,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/glasses/welding/superior,
		/obj/item/clothing/glasses/sunglasses/sechud,
		/obj/item/clothing/glasses/scanner/meson,
		/obj/item/clothing/gloves/yellow,
		/obj/item/clothing/gloves/knuckles,
		/obj/item/clothing/gloves/knuckles/spiked,
		/obj/item/clothing/head/bomb_hood,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/mask/gas/monkeymask,
		/obj/item/clothing/mask/gas/owl_mask,
		/obj/item/clothing/mask/gas/plaguedoctor,
		/obj/item/clothing/mask/gas/sexyclown,
		/obj/item/clothing/mask/muzzle,
		/obj/item/clothing/mask/pig,
		/obj/item/clothing/mask/horsehead,
		/obj/item/clothing/shoes/sandal,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
		/obj/item/clothing/suit/bomb_suit,
		/obj/item/clothing/suit/fire/firefighter,
		/obj/item/clothing/suit/monkeysuit,
		/obj/item/clothing/suit/pirate,
		/obj/item/clothing/suit/radiation,
		/obj/item/clothing/suit/tag/redtag,
		/obj/item/clothing/suit/storage/fr_jacket,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/storage/lawyer/purpjacket,
		/obj/item/clothing/suit/storage/paramedic,
		/obj/item/clothing/suit/suspenders,
		/obj/item/clothing/suit/syndicatefake,
		/obj/item/clothing/suit/unathi/mantle,
		/obj/item/clothing/suit/unathi/robe,
		/obj/item/clothing/accessory/tie/horrible,
		/obj/item/clothing/accessory/armband/cargo,
		/obj/item/clothing/accessory/armband,
		/obj/item/clothing/accessory/armband/engine,
		/obj/item/clothing/accessory/armband/hydro,
		/obj/item/clothing/accessory/holster/handgun/wornout,
		/obj/item/clothing/under/blackskirt,
		/obj/item/clothing/mask/gas/voice,
		/obj/item/clothing/head/bandana,
		/obj/item/clothing/head/rabbitears,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/hairflower,
		/obj/item/clothing/head/helmet/roman,
		/obj/item/clothing/head/helmet/roman/legionaire,
		/obj/item/clothing/head/pumpkinhead,
		/obj/item/clothing/head/soft/rainbow,
		/obj/item/clothing/head/soft/sec,
		/obj/item/clothing/head/syndicatefake,
		/obj/item/clothing/head/wizard/marisa/fake,
		/obj/item/clothing/suit/wizrobe/marisa/fake,
		/obj/item/clothing/head/wizard/fake,
		/obj/item/clothing/suit/wizrobe/fake,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/mask/luchador/tecnicos,
		/obj/item/clothing/mask/luchador/rudos,
		/obj/item/clothing/mask/cigarette/cigar,
		/obj/item/clothing/mask/fakemoustache,
		/obj/item/clothing/shoes/galoshes,
		/obj/item/clothing/shoes/jackboots,
		/obj/item/clothing/shoes/roman,
		/obj/item/clothing/shoes/syndigaloshes,
		/obj/item/clothing/suit/chickensuit,
		/obj/item/clothing/under/captain_fly,
		/obj/item/clothing/under/dress/dress_saloon,
		/obj/item/clothing/under/dress/dress_yellow,
		/obj/item/clothing/under/dress/dress_pink,
		/obj/item/clothing/under/dress/dress_orange,
		/obj/item/clothing/under/dress/dress_fire,
		/obj/item/clothing/under/dress/dress_green,
		/obj/item/clothing/under/gladiator,
		/obj/item/clothing/under/johnny,
		/obj/item/clothing/under/kilt,
		/obj/item/clothing/under/lawyer/purpsuit,
		/obj/item/clothing/under/lawyer/female,
		/obj/item/clothing/under/overalls,
		/obj/item/clothing/under/owl,
		/obj/item/clothing/under/pirate,
		/obj/item/clothing/under/psyche,
		/obj/item/clothing/under/psysuit,
		/obj/item/clothing/under/rainbow,
		/obj/item/clothing/under/schoolgirl,
		/obj/item/clothing/under/sexyclown,
		/obj/item/clothing/under/rank/mailman,
		/obj/item/clothing/under/shorts/green,
		/obj/item/clothing/under/shorts/red,
		/obj/item/clothing/under/shorts/grey,
		/obj/item/clothing/under/stripper/mankini,
		/obj/item/clothing/under/sundress,
		/obj/item/clothing/under/swimsuit/black,
		/obj/item/clothing/under/swimsuit/purple,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/under/waiter,
		/obj/item/clothing/under/wedding/bride_blue,
		/obj/item/clothing/under/wedding/bride_purple,
		/obj/item/clothing/under/wedding/bride_white,
		/obj/item/pizzabox/meat,
		/obj/item/pizzabox/margherita,
		/obj/item/pizzabox/vegetable,
		/obj/item/pizzabox/mushroom,
		/obj/item/robot_parts/robot_component/actuator,
		/obj/item/robot_parts/robot_component/armour,
		/obj/item/robot_parts/robot_component/binary_communication_device,
		/obj/item/robot_parts/chest,
		/obj/item/robot_parts/robot_suit,
		/obj/item/roller,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/nanopaste,
		/obj/item/taperoll/engineering,
		/obj/item/taperoll/police,
		/obj/item/toy/ammo/gun,
		/obj/item/toy/waterballoon,
		/obj/item/toy/crayon/red,
		/obj/item/toy/crayon/yellow,
		/obj/item/toy/crayon/blue,
		/obj/item/toy/crossbow,
		/obj/item/toy/gun,
		/obj/item/toy/snappop,
		/obj/item/toy/sword,
		/obj/item/toy/bomb,
		/obj/item/clothing/mask/facehugger/toy,
		/obj/item/trash/candle,
		/obj/item/trash/candy,
		/obj/item/trash/cheesie,
		/obj/item/trash/chips,
		/obj/item/trash/plate,
		/obj/item/trash/popcorn,
		/obj/item/trash/raisins,
		/obj/item/trash/sosjerky,
		/obj/item/clothing/accessory/medal/conduct,
		/obj/item/bananapeel,
		/obj/item/corncob,
		/obj/item/bikehorn,
		/obj/item/c_tube,
		/obj/item/beartrap,
		/obj/item/caution,
		/obj/item/rack_parts,
		/obj/item/caution/cone,
		/obj/item/beach_ball,
		/obj/item/bee_net,
		/obj/item/bikehorn/rubberducky,
		/obj/item/broken_bottle,
		/obj/item/bucket_sensor,
		/obj/item/stack/cable_coil,
		/obj/item/camera_assembly,
		/obj/item/trash/cigbutt/cigarbutt,
		/obj/item/storage/bag/clipboard,
		/obj/item/coin,
		/obj/item/coin/gold,
		/obj/item/coin/clown,
		/obj/item/coin/diamond,
		/obj/item/coin/iron,
		/obj/item/coin/phazon,
		/obj/item/coin/plasma,
		/obj/item/coin/silver,
		/obj/item/coin/uranium,
		/obj/item/dice,
		/obj/item/disk,
		/obj/item/disk/hdd,
		/obj/item/handcuffs,
		/obj/item/handcuffs/cable,
		/obj/item/hatchet,
		/obj/item/kitchen/rollingpin,
		/obj/item/lighter/random,
		/obj/item/lipstick/random,
		/obj/item/minihoe,
		/obj/item/mop,
		/obj/item/newspaper,
		/obj/item/pen,
		/obj/item/scalpel,
		/obj/item/shard,
		/obj/item/stool,
		/obj/item/reagent_containers/blood/OMinus,
		/obj/item/reagent_containers/glass/bottle/ammonia,
		/obj/item/reagent_containers/glass/bottle/capsaicin,
		/obj/item/reagent_containers/glass/bottle/diethylamine,
		/obj/item/reagent_containers/food/drinks/beer,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe,
		/obj/item/reagent_containers/food/drinks/bottle/cream,
		/obj/item/reagent_containers/food/drinks/bottle/orangejuice,
		/obj/item/reagent_containers/food/drinks/bottle/tequila,
		/obj/item/reagent_containers/food/drinks/bottle/vermouth,
		/obj/item/reagent_containers/food/drinks/bottle/wine,
		/obj/item/reagent_containers/food/drinks/coffee,
		/obj/item/reagent_containers/food/drinks/soda_cans/cola,
		/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb,
		/obj/item/reagent_containers/food/drinks/soda_cans/starkist,
		/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko,
		/obj/item/reagent_containers/food/snacks/pie/amanita_pie,
		/obj/item/reagent_containers/food/snacks/amanitajelly,
		/obj/item/reagent_containers/food/snacks/applecakeslice,
		/obj/item/reagent_containers/food/snacks/pie/applepie,
		/obj/item/reagent_containers/food/snacks/bigbiteburger,
		/obj/item/reagent_containers/food/snacks/boiledegg,
		/obj/item/reagent_containers/food/snacks/brainburger,
		/obj/item/reagent_containers/food/snacks/meat/carpmeat,
		/obj/item/reagent_containers/food/snacks/cheesiehonkers,
		/obj/item/reagent_containers/food/snacks/chips,
		/obj/item/reagent_containers/food/snacks/chocolatebar/wrapped,
		/obj/item/reagent_containers/food/snacks/clownstears,
		/obj/item/reagent_containers/food/snacks/coldchili,
		/obj/item/reagent_containers/food/snacks/corgikabob,
		/obj/item/reagent_containers/food/snacks/donkpocket,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/reagent_containers/food/snacks/meat/animal/monkey,
		/obj/item/reagent_containers/food/snacks/no_raisin,
		/obj/item/reagent_containers/food/snacks/pie/plump_pie,
		/obj/item/reagent_containers/food/snacks/soylenviridians,
		/obj/item/reagent_containers/food/snacks/syndicake,
		/obj/item/reagent_containers/food/snacks/tofurkey,
		/obj/item/device/radio/headset/headset_earmuffs,
		/obj/item/solder/pre_fueled,
		/obj/item/storage/box/smokebombs,
		/obj/item/storage/box/wind,
		/obj/item/storage/box/foam,
		/obj/item/reagent_containers/food/snacks/grown/peanut,
		/obj/structure/popout_cake,
		/obj/structure/bed/chair/vehicle/wheelchair/multi_people,
		/obj/item/stack/package_wrap/syndie,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/switchtool/swiss_army_knife
		)

/obj/abstract/map/spawner/maint/lowchance
	name = "low-chance maint spawner"
	amount = 1
	chance = 10

/obj/abstract/map/spawner/highrisk
	name = "high risk spawner"
	icon_state = "maint"
	chance = 20
	/* Removed until they get properly converted to virus2 or something
		/obj/item/reagent_containers/glass/bottle/epiglottis_virion,
		/obj/item/reagent_containers/glass/bottle/flu_virion,
		/obj/item/reagent_containers/glass/bottle/pierrot_throat,
		/obj/item/reagent_containers/glass/bottle/cold,
	*/
	to_spawn = list(
		/obj/item/reagent_containers/glass/bottle/chloralhydrate,
		/obj/item/reagent_containers/glass/bottle/magnitis,
		/obj/item/device/powersink,
		/obj/item/device/powersink,
		/obj/item/gun/projectile/flamethrower/full,
		/obj/item/gun/projectile/deagle/gold,
		/obj/item/clothing/shoes/magboots/magnificent,
		/obj/item/gun/projectile/russian,
	)

/obj/abstract/map/spawner/floorpill
	name = "floor pill spawner"
	icon_state = "maint_pills"
	chance = 20
	to_spawn = list(
		/obj/item/reagent_containers/pill/random/maintenance
	)

/obj/abstract/map/spawner/floorpill/guaranteed
	chance = 100

// Space ///////////////////////////////////////////////////////

/obj/abstract/map/spawner/space/weapons
	name = "space weapons spawner"
	icon_state = "space_weapons"
	chance = 20
	to_spawn = list(
		/obj/item/kitchen/utensil/knife/large/butch/meatcleaver,
		/obj/item/crossbow,
		/obj/item/grenade/spawnergrenade/manhacks,
		/obj/item/grenade/spawnergrenade/spesscarp,
		/obj/item/grenade/flashbang/clusterbang,
		/obj/item/grenade/empgrenade,
		/obj/item/gun/dartgun/vox/raider,
		/obj/item/gun/energy/decloner,
		/obj/item/gun/energy/laser/retro,
		/obj/item/gun/energy/mindflayer,
		/obj/item/gun/energy/temperature,
		/obj/item/gun/energy/xray,
		/obj/item/gun/projectile/gyropistol,
		/obj/item/gun/projectile/pistol,
		/obj/item/gun/projectile/russian,
		/obj/item/gun/projectile/silenced,
		/obj/item/harpoon,
		/obj/item/melee/classic_baton,
		/obj/item/pickaxe/plasmacutter/accelerator,
		/obj/item/shield/energy,
		)

/obj/abstract/map/spawner/space/weapons2
	name = "exotic space weapons spawner"
	icon_state = "space_weapons"
	amount = 2
	to_spawn = list(
		/obj/item/grenade/spawnergrenade/beenade,
		/obj/item/grenade/spawnergrenade/spesscarp,
		/obj/item/grenade/flashbang/clusterbang,
		/obj/item/gun/energy/decloner,
		/obj/item/gun/energy/mindflayer,
		/obj/item/gun/energy/laser/retro,
		/obj/item/gun/energy/gun/nuclear,
		/obj/item/gun/energy/gun,
		/obj/item/gun/energy/xray,
		/obj/item/gun/energy/radgun,
		/obj/item/gun/energy/crossbow,
		/obj/item/gun/projectile/gyropistol,
		/obj/item/gun/projectile/hecate,
		/obj/item/gun/projectile/pistol,
		/obj/item/gun/projectile/mateba,
		/obj/item/gun/projectile/silenced,
		/obj/item/gun/projectile/deagle/camo,
		/obj/item/gun/projectile/automatic/xcom,
		/obj/item/gun/osipr,
		/obj/item/gun/gravitywell,
		/obj/item/gun/grenadelauncher,
		)

/obj/abstract/map/spawner/space/tools
	name = "space tool spawner"
	icon_state = "space_tools"
	chance = 50
	to_spawn = list(
		/obj/item/bluespace_crystal,
		/obj/item/bodybag/cryobag,
		/obj/item/borg/upgrade/syndicate,
		/obj/item/clothing/glasses/thermal,
		/obj/item/device/aicard,
		/obj/item/device/ano_scanner,
		/obj/item/device/flashlight/lantern,
		/obj/item/device/flashlight,
		/obj/item/device/handtv,
		/obj/item/device/paicard,
		/obj/item/device/robotanalyzer,
		/obj/item/device/t_scanner,
		/obj/item/device/transfer_valve,
		/obj/item/device/wormhole_jaunter,
		/obj/item/device/reagent_scanner/adv,
		/obj/item/mecha_parts/mecha_equipment/repair_droid,
		/obj/item/mecha_parts/mecha_equipment/teleporter,
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay,
		/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill,
		/obj/item/mecha_parts/mecha_equipment/tool/cable_layer,
		/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion,
		/obj/item/mecha_parts/mecha_equipment/wormhole_generator,
		/obj/item/mecha_parts/mecha_tracking,
		/obj/item/mecha_parts/part/phazon_phase_array,
		/obj/item/mecha_parts/part/durand_torso,
		/obj/item/mecha_parts/part/gygax_right_leg,
		/obj/item/mecha_parts/part/odysseus_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/robot_parts/robot_suit,
		/obj/item/robot_parts/head,
		/obj/item/autopsy_scanner,
		/obj/item/stack/cable_coil/pink,
		/obj/item/cell/hyper,
		/obj/item/ed209_assembly,
		/obj/item/firstaid_arm_assembly,
		/obj/item/grenade/chem_grenade/metalfoam,
		/obj/item/grenade/chem_grenade/antiweed,
		/obj/item/hatchet,
		/obj/item/pickaxe/jackhammer,
		/obj/item/device/rcd/rpd,
		/obj/item/device/rcd,
		/obj/item/stack/rcd_ammo,
		/obj/item/device/rcd/matter/rsf,
		/obj/item/weldingtool/hugetank,
		/obj/item/tank/plasma,
		/obj/item/gun_part/silencer,
		/obj/item/storage/backpack/holding,
		)

/obj/abstract/map/spawner/space/gear
	name = "space gear spawner"
	icon_state = "space_gear"
	chance = 30
	to_spawn = list(
		/obj/item/clothing/mask/cigarette/cigar/cohiba,
		/obj/item/clothing/mask/cigarette/pipe/cobpipe,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/mask/gas/cyborg,
		/obj/item/clothing/shoes/magboots,
		/obj/item/clothing/gloves/yellow,
		/obj/item/clothing/suit/bio_suit/janitor,
		/obj/item/clothing/suit/fire/heavy,
		/obj/item/clothing/suit/radiation,
		/obj/item/clothing/head/helmet/space/syndicate/black/blue,
		/obj/item/clothing/suit/space/syndicate/black/blue,
		/obj/item/clothing/head/helmet/space/syndicate/black/med,
		/obj/item/clothing/suit/space/syndicate/black/med,
		/obj/item/clothing/head/helmet/space/syndicate/black/engie,
		/obj/item/clothing/suit/space/syndicate/black/engie,
		/obj/item/clothing/accessory/storage/webbing,
		/obj/item/clothing/accessory/storage/brown_vest,
		/obj/item/organ/external/head,
		/obj/item/organ/external/r_leg,
		/obj/item/organ/external/l_arm,
		/obj/item/organ/external/l_foot,
		)

/obj/abstract/map/spawner/space/supply
	name = "space supply spawner"
	icon_state = "space_supply"
	amount = 2
	chance = 50
	to_spawn = list(
		/obj/item/clothing/mask/breath/medical,
		/obj/item/device/radio,
		/obj/item/device/flashlight/flare,
		/obj/item/extinguisher,
		/obj/item/tank/oxygen/yellow,
		/obj/item/tank/nitrogen,
		/obj/item/tank/emergency_oxygen/engi,
		/obj/item/tank/emergency_oxygen/double,
		/obj/item/tank/anesthetic,
		/obj/item/storage/toolbox/electrical,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/storage/box/autoinjectors,
		/obj/item/storage/box/donkpockets,
		/obj/item/storage/fancy/matchbox,
		/obj/item/storage/fancy/donut_box,
		/obj/item/storage/firstaid/adv,
		/obj/item/storage/firstaid/regular,
		/obj/item/reagent_containers/pill/happy,
		/obj/item/reagent_containers/glass/bottle/random,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/snacks/appendixburger,
		/obj/item/reagent_containers/food/snacks/bloodsoup,
		/obj/item/reagent_containers/food/snacks/candy/donor,
		/obj/item/reagent_containers/food/snacks/clownburger,
		/obj/item/reagent_containers/food/snacks/mysterysoup,
		/obj/item/reagent_containers/food/snacks/donut/chaos,
		//obj/item/reagent_containers/food/snacks/grown/ghost_chilli,
		/obj/item/reagent_containers/food/snacks/wingfangchu,
		/obj/item/reagent_containers/food/snacks/soylentgreen,
		/obj/item/reagent_containers/food/snacks/meat/bearmeat,
		/obj/item/reagent_containers/food/snacks/meat/xenomeat,
		)

/obj/abstract/map/spawner/space/drinks
	name = "space drinks spawner"
	icon_state = "space_drinks"
	chance = 50
	amount = 4
	jiggle = 5
	to_spawn = list(
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/beer,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe,
		/obj/item/reagent_containers/food/drinks/bottle/rum,
		/obj/item/reagent_containers/food/drinks/soda_cans/grifeo,
		/obj/item/reagent_containers/food/drinks/groansbanned,
		)

/obj/abstract/map/spawner/space/russian
	name = "space russian spawner"
	icon_state = "space_russian"
	chance = 5
	to_spawn = list(/mob/living/simple_animal/hostile/humanoid/russian/ranged)


/obj/abstract/map/spawner/space/vox/trader/spacesuit // for the vox outpost trader closets to spawn a random hardsuit. Each hardsuit has the same stats which are ofcourse very poor armor.
 	name = "trader spacesuit spawner"
 	icon_state = "space_supply"

/obj/abstract/map/spawner/space/vox/trader/spacesuit/perform_spawn()
	var/i = rand(1, 4) // 1 in 4 chance of spawning a single of listed below
	switch (i)
		if (1)
			new /obj/item/clothing/suit/space/vox/civ/trader(src.loc) // standard brownsuit and helmet
			new /obj/item/clothing/head/helmet/space/vox/civ/trader(src.loc)

		if (2)
			new /obj/item/clothing/suit/space/vox/civ/trader/carapace(src.loc) // carapace
			new /obj/item/clothing/head/helmet/space/vox/civ/trader/carapace(src.loc)
		if (3)
			new /obj/item/clothing/suit/space/vox/civ/trader/medic(src.loc) // aqua coloured hardsuit
			new /obj/item/clothing/head/helmet/space/vox/civ/trader/medic(src.loc)
		if (4)
			new /obj/item/clothing/suit/space/vox/civ/trader/stealth(src.loc) // black hardsuit. Not capable of any form of stealth systems or shit like that
			new /obj/item/clothing/head/helmet/space/vox/civ/trader/stealth(src.loc)
	qdel(src)
// Mobs ////////////////////////////////////////////////////////

/obj/abstract/map/spawner/mobs/monkeys
	name = "monkey spawner"
	icon_state = "mob_monkey"
	chance = 50
	to_spawn = list(
		/mob/living/carbon/monkey,
		/mob/living/carbon/monkey/tajara,
		/mob/living/carbon/monkey/skrell,
		/mob/living/carbon/monkey/unathi,
		/mob/living/carbon/monkey/grey,
		/mob/living/carbon/monkey/mushroom,
		/mob/living/carbon/monkey/rock,
		/mob/living/carbon/monkey/diona,
		/mob/living/carbon/monkey/skellington,
		/mob/living/carbon/monkey/skellington/plasma)


/obj/abstract/map/spawner/mobs/carp
	name = "carp spawner"
	icon_state = "mob_carp"
	chance = 50
	to_spawn = list(/mob/living/simple_animal/hostile/carp)

/obj/abstract/map/spawner/mobs/lizard
	name = "lizard spawner"
	icon_state = "mob_lizard"
	amount = 2
	chance = 50
	to_spawn = list(/mob/living/simple_animal/hostile/lizard)

/obj/abstract/map/spawner/mobs/mouse
	name = "mouse spawner"
	icon_state = "mob_mouse"
	amount = 2
	chance = 50
	to_spawn = list(/mob/living/simple_animal/mouse/common)

/obj/abstract/map/spawner/mobs/bear
	name = "bear spawner"
	icon_state = "mob_bear"
	chance = 50
	to_spawn = list(/mob/living/simple_animal/hostile/bear)

/obj/abstract/map/spawner/mobs/spider
	name = "spider spawner"
	icon_state = "mob_spider"
	amount = 3
	chance = 50
	to_spawn = list(
		/mob/living/simple_animal/hostile/giant_spider,
		/mob/living/simple_animal/hostile/giant_spider/nurse,
		/mob/living/simple_animal/hostile/giant_spider/hunter,
		)
/obj/abstract/map/spawner/mobs/wolf
	name = "wolf spawner"
	icon_state = "mob_wolf"
	amount = 7
	to_spawn = list(
		/mob/living/simple_animal/hostile/wolf,
		/mob/living/simple_animal/hostile/wolf,
		/mob/living/simple_animal/hostile/wolf,
		/mob/living/simple_animal/hostile/wolf,
		/mob/living/simple_animal/hostile/wolf/alpha,
		/mob/living/simple_animal/hostile/wolf/alpha,
		)

/obj/abstract/map/spawner/mobs/deer
	name = "deer spawner"
	icon_state = "mob_deer"
	amount = 5
	to_spawn = list(/mob/living/simple_animal/hostile/deer)

/obj/abstract/map/spawner/mobs/humanoid/wiz
	name = "wizard spawner"
	icon_state = "mob_wiz"
	amount = 2
	chance = 50
	to_spawn = list(/mob/living/simple_animal/hostile/humanoid/wizard)

/obj/abstract/map/spawner/mobs/medivault
	name = "medivault spawner"
	icon_state = "mob_medivault"
	chance = 60
	to_spawn = list(
		/mob/living/simple_animal/hostile/necro/skeleton,
		/mob/living/simple_animal/hostile/necro/skeleton,
		/mob/living/simple_animal/hostile/necro/skeleton,
		/mob/living/simple_animal/hostile/necro/zombie/leatherman,
		/mob/living/simple_animal/hostile/necro/zombie/ghoul,
		/mob/living/simple_animal/hostile/necro/zombie/ghoul,
		/mob/living/simple_animal/hostile/necro/zombie/ghoul,
		/mob/living/simple_animal/hostile/necro/zombie,
		/mob/living/simple_animal/hostile/necro/zombie,
		/mob/living/simple_animal/hostile/necro/zombie,
		/mob/living/simple_animal/hostile/necro/zombie,
		)

/obj/abstract/map/spawner/misc/medivault
	name = "medivault loot spawner"
	icon_state = "loot_medivault"
	chance = 80
	amount = 1
	jiggle = 5
	to_spawn = list(/obj/item/dnainjector/nofail/polymorph,
	/obj/item/dnainjector/nofail/polymorph,
	/obj/item/dnainjector/nofail/telemut,
	/obj/item/dnainjector/nofail/telemut,
	/obj/item/dnainjector/nofail/randompower,
	/obj/item/dnainjector/nofail/randompower,
	/obj/item/dnainjector/nofail/randompower,
	/obj/item/dnainjector/nofail/hulkmut,
	/obj/item/dnainjector/nofail/nobreath,
	/obj/item/dnainjector/nofail/nobreath,
	/obj/item/storage/firstaid/adv,
	/obj/item/storage/firstaid/adv,
	/obj/item/storage/firstaid/adv,
	/obj/item/storage/pill_bottle/hyperzine,
	/obj/item/storage/pill_bottle/hyperzine,
	/obj/item/reagent_containers/glass/beaker/mednanobots,
	/obj/item/reagent_containers/glass/beaker/mednanobots,
	/obj/item/gun/energy/laser/smart,
	/obj/item/gun/energy/laser/pistol,
	/obj/item/gun/energy/laser/pistol,
	/obj/item/gun/projectile/shotgun/pump/combat,


)

// Robutts /////////////////////////////////////////////////////

/obj/abstract/map/spawner/robot/any
	name = "robot spawner"
	icon_state = "robot_any"
	chance = 20
	to_spawn = list(
		/obj/machinery/bot/cleanbot,
		/obj/machinery/bot/farmbot,
		/obj/machinery/bot/floorbot,
		/obj/machinery/bot/medbot,
		/obj/machinery/bot/secbot,
		)

/obj/abstract/map/spawner/robot/sec
	name = "secbot spawner"
	icon_state = "robot_sec"
	to_spawn = list(/obj/machinery/bot/secbot)

/obj/abstract/map/spawner/robot/clean
	name = "cleanbot spawner"
	icon_state = "robot_clean"
	to_spawn = list(/obj/machinery/bot/cleanbot)

/obj/abstract/map/spawner/robot/med
	name = "medbot spawner"
	icon_state = "robot_med"
	to_spawn = list(/obj/machinery/bot/medbot)

/obj/abstract/map/spawner/robot/floor
	name = "floorbot spawner"
	icon_state = "robot_floor"
	to_spawn = list(/obj/machinery/bot/floorbot)

/obj/abstract/map/spawner/robot/farm
	name = "farmbot spawner"
	icon_state = "robot_farm"
	to_spawn = list(/obj/machinery/bot/farmbot)

// Seeds ///////////////////////////////////////////////////////

/obj/abstract/map/spawner/misc/seeds
	name = "seed spawner"
	icon_state = "seeds"
	chance = 50
	amount = 4
	jiggle = 5
	to_spawn = list(
		/obj/item/seeds/amanitamycelium,
		/obj/item/seeds/ambrosiadeusseed,
		/obj/item/seeds/ambrosiavulgarisseed,
		/obj/item/seeds/angelmycelium,
		/obj/item/seeds/appleseed,
		/obj/item/seeds/bananaseed,
		/obj/item/seeds/berryseed,
		/obj/item/seeds/bloodtomatoseed,
		/obj/item/seeds/bluespacetomatoseed,
		/obj/item/seeds/cabbageseed,
		/obj/item/seeds/carrotseed,
		/obj/item/seeds/chantermycelium,
		/obj/item/seeds/cherryseed,
		/obj/item/seeds/chiliseed,
		/obj/item/seeds/cocoapodseed,
		/obj/item/seeds/cornseed,
		/obj/item/seeds/deathberryseed,
		/obj/item/seeds/deathnettleseed,
		/obj/item/seeds/eggplantseed,
		/obj/item/seeds/eggyseed,
		/obj/item/seeds/glowberryseed,
		/obj/item/seeds/glowshroom,
		/obj/item/seeds/goldappleseed,
		/obj/item/seeds/grapeseed,
		/obj/item/seeds/grassseed,
		/obj/item/seeds/greengrapeseed,
		/obj/item/seeds/harebell,
		/obj/item/seeds/icepepperseed,
		/obj/item/seeds/killertomatoseed,
		/obj/item/seeds/koiseed,
		/obj/item/seeds/kudzuseed,
		/obj/item/seeds/lemonseed,
		/obj/item/seeds/libertymycelium,
		/obj/item/seeds/limeseed,
		/obj/item/seeds/moonflowerseed,
		/obj/item/seeds/nettleseed,
		/obj/item/seeds/novaflowerseed,
		/obj/item/seeds/orangeseed,
		/obj/item/seeds/plastiseed,
		/obj/item/seeds/plumpmycelium,
		/obj/item/seeds/poisonberryseed,
		/obj/item/seeds/poisonedappleseed,
		/obj/item/seeds/poppyseed,
		/obj/item/seeds/potatoseed,
		/obj/item/seeds/pumpkinseed,
		/obj/item/seeds/reishimycelium,
		/obj/item/seeds/dionanode,
		/obj/item/seeds/riceseed,
		/obj/item/seeds/soyaseed,
		/obj/item/seeds/sugarcaneseed,
		/obj/item/seeds/sunflowerseed,
		//obj/item/seeds/synthbrainseed,
		//obj/item/seeds/synthbuttseed,
		//obj/item/seeds/synthmeatseed,
		/obj/item/seeds/tomatoseed,
		/obj/item/seeds/towermycelium,
		/obj/item/seeds/walkingmushroommycelium,
		/obj/item/seeds/watermelonseed,
		/obj/item/seeds/wheatseed,
		/obj/item/seeds/whitebeetseed,
		/obj/item/seeds/cinnamomum,
		)

// Gym ///////////////////////////////////////////////////////

/obj/abstract/map/spawner/misc/gym //for the gym space vault
	name = "gym spawner"
	icon_state = "gym"
	chance = 80
	amount = 1
	jiggle = 5
	to_spawn = list(
		/obj/item/dnainjector/nofail/hulkmut,
		/obj/item/dnainjector/nofail/midgit,
		/obj/item/dnainjector/nofail/fat,
		/obj/item/dnainjector/nofail/runfast,
		/obj/item/dnainjector/nofail/strong,
		/obj/item/reagent_containers/food/snacks/chicken_fillet,
		/obj/item/clothing/under/shorts/black,
		/obj/item/clothing/under/shorts/blue,
		/obj/item/clothing/under/shorts/red,
		/obj/item/handcuffs,
		/obj/item/storage/pill_bottle/hyperzine,
		/obj/item/storage/pill_bottle/creatine,
		/obj/item/storage/firstaid/regular,
		/obj/item/storage/box/handcuffs,
		)


// Safe /////////////////////////////////////////////////////
//Does not come with a safe.
/obj/abstract/map/spawner/safe/any
	name = "safe any spawner "
	icon_state = "safe"
	to_spawn = list(
		/obj/item/storage/pill_bottle/creatine,
		/obj/item/storage/pill_bottle/nanobot,
		/obj/item/reagent_containers/glass/bottle/frostoil,
		/obj/item/reagent_containers/glass/bottle/chloralhydrate,
		/obj/item/storage/firstaid/adv,
		/obj/item/gun/syringe/rapidsyringe,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/shield/energy,
		/obj/item/reagent_containers/glass/bottle/random,
		/obj/item/dnainjector/nofail/randompower,
		/obj/item/gun/projectile/russian,
		/obj/item/bikehorn,
		/obj/item/storage/box/emps,
		/obj/item/card/id/captains_spare,
		/obj/item/clothing/accessory/medal,
		/obj/item/clothing/accessory/medal/conduct,
		/obj/item/clothing/accessory/medal/bronze_heart,
		/obj/item/clothing/accessory/medal/nobel_science,
		/obj/item/clothing/accessory/medal/silver,
		/obj/item/clothing/accessory/medal/silver/valor,
		/obj/item/clothing/accessory/medal/silver/security,
		/obj/item/clothing/accessory/medal/gold,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/accessory/medal/gold/heroism,
		/obj/item/clothing/accessory/storage/webbing,
		/obj/item/clothing/suit/armor/laserproof,
		/obj/item/clothing/accessory/holster/handgun,
		/obj/item/clothing/glasses/scanner/night,
		/obj/item/clothing/head/collectable/petehat,
		/obj/item/clothing/head/HoS/dermal,
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/gloves/anchor_arms,
		/obj/item/clothing/suit/space/rig/soviet,
		/obj/item/clothing/suit/space/rig/nazi,
		/obj/item/reagent_containers/food/snacks/superbiteburger,
		/obj/item/reagent_containers/food/snacks/roburger,
		/obj/item/reagent_containers/food/snacks/mommispaghetti,
		/obj/item/reagent_containers/food/snacks/yellowcake,
		/obj/item/reagent_containers/food/snacks/muffin/bluespace,
		/obj/item/reagent_containers/food/snacks/potentham,
		/obj/item/reagent_containers/food/snacks/chocolatebar/wrapped,
		/obj/item/reagent_containers/food/snacks/no_raisin,
		/obj/item/mounted/frame/painting
)


/obj/abstract/map/spawner/safe/medical
	name = "safe medical spawner"
	icon_state = "safe"
	to_spawn = list(/obj/item/storage/pill_bottle/creatine,
	/obj/item/storage/pill_bottle/nanobot,
	/obj/item/storage/firstaid/adv,
	/obj/item/reagent_containers/glass/bottle/random,
	/obj/item/reagent_containers/glass/bottle/frostoil,
	/obj/item/reagent_containers/glass/bottle/chloralhydrate,
	/obj/item/dnainjector/nofail/randompower,
	/obj/item/gun/syringe/rapidsyringe,
	/obj/item/voucher/free_item/medical_safe
)


/obj/abstract/map/spawner/safe/food
	name = "safe food spawner"
	icon_state = "safe"
	to_spawn = list(/obj/item/reagent_containers/food/drinks/bottle/vodka,
	/obj/item/voucher/free_item/snack,
	/obj/item/voucher/free_item/hot_drink,
	/obj/item/reagent_containers/food/snacks/chocolatebar/wrapped,
	/obj/item/reagent_containers/food/snacks/no_raisin,
	/obj/item/reagent_containers/food/snacks/superbiteburger,
	/obj/item/reagent_containers/food/snacks/roburger,
	/obj/item/reagent_containers/food/snacks/mommispaghetti,
	/obj/item/reagent_containers/food/snacks/yellowcake,
	/obj/item/reagent_containers/food/snacks/muffin/bluespace,
	/obj/item/reagent_containers/food/snacks/potentham
)

/obj/abstract/map/spawner/safe/weapon
	name = "safe weapon spawner"
	icon_state = "safe"
	to_spawn = list(/obj/item/shield/energy,
	/obj/item/gun/energy/gun/nuclear,
	/obj/item/gun/projectile/mateba,
	/obj/item/gun/projectile/deagle/gold,
	/obj/item/bikehorn,
	/obj/item/storage/box/emps,
	/obj/item/gun/projectile/automatic/uzi,
	/obj/item/melee/energy/axe/rusty,
	/obj/item/gun/projectile/russian,
	/obj/item/gun/mahoguny,
	/obj/item/gun/stickybomb,
	/obj/item/gun/siren
)

/obj/abstract/map/spawner/safe/clothing
	name = "safe clothing spawner"
	icon_state = "safe"
	to_spawn = list(/obj/item/shield/energy,
	/obj/item/clothing/accessory/storage/webbing,
	/obj/item/clothing/under/sexyclown,
	/obj/item/clothing/suit/armor/laserproof,
	/obj/item/clothing/accessory/holster/handgun,
	/obj/item/clothing/head/helmet/siren,
	/obj/item/clothing/glasses/scanner/night,
	/obj/item/clothing/head/collectable/petehat,
	/obj/item/clothing/head/HoS/dermal,
	/obj/item/clothing/under/chameleon,
	/obj/item/clothing/gloves/anchor_arms,
	/obj/item/clothing/suit/space/rig/soviet,
	/obj/item/clothing/suit/space/rig/nazi,
	/obj/abstract/spawn_all/dredd_gear
)

/obj/abstract/map/spawner/safe/medal
	name = "safe medal spawner"
	icon_state = "safe"
	to_spawn = list(/obj/item/clothing/accessory/medal,
	/obj/item/clothing/accessory/medal/conduct,
	/obj/item/clothing/accessory/medal/bronze_heart,
	/obj/item/clothing/accessory/medal/nobel_science,
	/obj/item/clothing/accessory/medal/silver,
	/obj/item/clothing/accessory/medal/silver/valor,
	/obj/item/clothing/accessory/medal/silver/security,
	/obj/item/clothing/accessory/medal/gold,
	/obj/item/clothing/accessory/medal/gold/captain,
	/obj/item/clothing/accessory/medal/gold/heroism
)
//Food spawners////////////////////////////////////
/obj/abstract/map/spawner/food/voxfood //spawns food for the vox raiders
	name = "vox food spawner"
	icon_state = "food"
	amount = 7
	jiggle = 5
	to_spawn = list (/obj/item/reagent_containers/food/snacks/hoboburger,
	/obj/item/reagent_containers/food/snacks/hoboburger,
	/obj/item/reagent_containers/food/snacks/sweetandsourpork,
	/obj/item/reagent_containers/food/snacks/zhulongcaofan,
	/obj/item/reagent_containers/food/snacks/zhulongcaofan,
	/obj/item/reagent_containers/food/snacks/zhulongcaofan,
	/obj/item/reagent_containers/food/snacks/porktenderloin,
	/obj/item/reagent_containers/food/snacks/voxstew,
	/obj/item/reagent_containers/food/snacks/woodapplejam,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/risenshiny,
	/obj/item/reagent_containers/food/snacks/sweetandsourpork,
	/obj/item/reagent_containers/food/snacks/sundayroast,
	/obj/item/reagent_containers/food/snacks/pie/breadfruit,
	/obj/item/reagent_containers/food/snacks/pie/breadfruit,
	/obj/item/reagent_containers/food/snacks/garlicbread,
	/obj/item/reagent_containers/food/snacks/garlicbread,
	/obj/item/reagent_containers/food/snacks/mushnslush,
	/obj/item/reagent_containers/food/snacks/candiedwoodapple,
	/obj/item/reagent_containers/food/snacks/bacon,
	/obj/item/reagent_containers/food/snacks/bacon,
	/obj/item/reagent_containers/food/snacks/bacon
)
//Syndiecargo loot spawners////////////////////////
/obj/abstract/map/spawner/misc/syndiecargo
	name = "syndiecargo loot spawner"
	icon_state = "syndicargo"
	amount = 2
	jiggle = 5
	to_spawn = list (/obj/item/clothing/mask/gas/voice,
	/obj/item/melee/classic_baton,
	/obj/item/clothing/gloves/knuckles,
	/obj/item/ammo_storage/magazine/a12mm/ops,
	/obj/item/storage/pill_bottle/random,
	/obj/item/gun/projectile/automatic/lockbox,
	/obj/item/handcuffs,
	/obj/item/clothing/accessory/holomap_chip/operative
)

//Theater///////////////////////////////////////////

/obj/abstract/map/spawner/theater/costumes
	name = "theater costume spawner"
	icon_state = "costumes"

/obj/abstract/map/spawner/theater/costumes/perform_spawn()
	var/i = rand(1, 22)
	switch (i)
		if (1)
			new /obj/item/clothing/suit/chickensuit(src.loc)
			new	/obj/item/clothing/head/chicken(src.loc)
			new	/obj/item/reagent_containers/food/snacks/egg(src.loc)

		if (2)
			new /obj/item/clothing/under/gladiator(src.loc)
			new	/obj/item/clothing/head/helmet/gladiator(src.loc)
		if (3)
			new /obj/item/clothing/under/gimmick/rank/captain/suit(src.loc)
			new	/obj/item/clothing/head/flatcap(src.loc)
			new	/obj/item/clothing/suit/storage/labcoat/mad(src.loc)
			new	/obj/item/clothing/glasses/gglasses(src.loc)
		if (4)
			new /obj/item/clothing/under/gimmick/rank/captain/suit(src.loc)
			new	/obj/item/clothing/head/flatcap(src.loc)
			new	/obj/item/clothing/mask/cigarette/cigar/havana(src.loc)
			new	/obj/item/clothing/shoes/jackboots(src.loc)
		if (5)
			new	/obj/item/clothing/under/schoolgirl(src.loc)
			new	/obj/item/clothing/head/kitty(src.loc)
		if (6)
			new /obj/item/clothing/under/blackskirt(src.loc)
			new	/obj/item/clothing/head/rabbitears(src.loc)
			new	/obj/item/clothing/glasses/sunglasses/blindfold(src.loc)
		if (7)
			new /obj/item/clothing/suit/wcoat(src.loc)
			new	/obj/item/clothing/under/suit_jacket(src.loc)
			new	/obj/item/clothing/head/that(src.loc)
		if (8)
			new /obj/item/clothing/gloves/white(src.loc)
			new	/obj/item/clothing/shoes/white(src.loc)
			new	/obj/item/clothing/under/scratch(src.loc)
			new	/obj/item/clothing/head/cueball(src.loc)
		if (9)
			new /obj/item/clothing/under/kilt(src.loc)
			new	/obj/item/clothing/head/beret(src.loc)
		if (10)
			new /obj/item/clothing/suit/wcoat(src.loc)
			new	/obj/item/clothing/glasses/monocle(src.loc)
			new	/obj/item/clothing/head/that(src.loc)
			new	/obj/item/clothing/shoes/black(src.loc)
			new	/obj/item/cane(src.loc)
			new	/obj/item/clothing/under/sl_suit(src.loc)
			new	/obj/item/clothing/mask/fakemoustache(src.loc)
		if (11)
			new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(src.loc)
			new	/obj/item/clothing/head/plaguedoctorhat(src.loc)
		if (12)
			new /obj/item/clothing/under/owl(src.loc)
			new	/obj/item/clothing/mask/gas/owl_mask(src.loc)
		if (13)
			new /obj/item/clothing/under/waiter(src.loc)
			new	/obj/item/clothing/head/kitty(src.loc)
			new	/obj/item/clothing/suit/apron(src.loc)
		if (14)
			new /obj/item/clothing/under/pirate(src.loc)
			new	/obj/item/clothing/suit/pirate(src.loc)
			new	/obj/item/clothing/head/pirate(src.loc)
			new	/obj/item/clothing/glasses/eyepatch(src.loc)
		if (15)
			new /obj/item/clothing/under/soviet(src.loc)
			new	/obj/item/clothing/head/ushanka(src.loc)
		if (16)
			new /obj/item/clothing/suit/imperium_monk(src.loc)
			new	/obj/item/clothing/mask/gas/cyborg(src.loc)
		if (17)
			new /obj/item/clothing/suit/holidaypriest(src.loc)
		if (18)
			new /obj/item/clothing/head/wizard/marisa/fake(src.loc)
			new	/obj/item/clothing/suit/wizrobe/marisa/fake(src.loc)
		if (19)
			new /obj/item/clothing/under/sundress(src.loc)
			new	/obj/item/clothing/head/witchwig(src.loc)
			new	/obj/item/staff/broom(src.loc)
		if (20)
			new /obj/item/clothing/suit/wizrobe/fake(src.loc)
			new	/obj/item/clothing/head/wizard/fake(src.loc)
			new	/obj/item/staff(src.loc)
		if (21)
			new /obj/item/clothing/mask/gas/sexyclown(src.loc)
			new	/obj/item/clothing/under/sexyclown(src.loc)
		if (22)
			new /obj/item/clothing/mask/gas/sexymime(src.loc)
			new	/obj/item/clothing/under/sexymime(src.loc)
	qdel(src)

// Spawn all in the turf
/obj/abstract/spawn_all
	var/list/to_spawn = list()
	var/where_to_spawn = SPAWN_ON_TURF

/obj/abstract/spawn_all/New()
	. = ..()
	var/location
	if (where_to_spawn == SPAWN_ON_TURF)
		location = get_turf(src)
	else
		location = src.loc
	for (var/thing in to_spawn)
		new thing(location)
	qdel(src)

/obj/abstract/spawn_all/dredd_gear
	to_spawn = list(
		/obj/item/clothing/under/darkred,
		/obj/item/clothing/glasses/hud/security,
		/obj/item/clothing/gloves/combat,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/head/helmet/dredd,
		/obj/item/clothing/mask/gas/swat,
		/obj/item/storage/belt/security,
		/obj/item/clothing/suit/armor/xcomsquaddie/dredd,
		/obj/item/gun/lawgiver,
	)
