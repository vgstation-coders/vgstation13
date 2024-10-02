//////SUPPLIES//////

/datum/supply_packs/toner
	name = "Toner cartridges"
	contains = list(/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner)
	cost = 10
	containertype = /obj/structure/closet/crate/basic
	containername = "toner cartridges crate"
	group = "Supplies"
	containsdesc = "For when the clown decides to use up all of your photocopier ink. Contains an excessive six sets of replacement toner."

/datum/supply_packs/labels
	name = "Label rolls"
	contains = list(/obj/item/weapon/storage/box/labels,
					/obj/item/weapon/storage/box/labels, //21 label rolls is enough to label Beepsky "SHITCURITRON" 375 times,
					/obj/item/weapon/storage/box/labels) //so this might be a bit excessive.
	cost = 10
	containertype = /obj/structure/closet/crate/basic
	containername = "label rolls crate"
	group = "Supplies"
	containsdesc = "Contains three boxes of fresh labeler rolls. Enough to label Beepsky 'SHITCURITRON' 375 times."

/datum/supply_packs/internals
	name = "O2 internals resupply"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air)
	cost = 10
	containertype = /obj/structure/closet/crate/internals
	containername = "o2 internals crate"
	group = "Supplies"
	containsicon = /obj/item/weapon/tank/air
	containsdesc = "Three sets of air tanks with gas masks, perfect for when your station is experiencing atmospherics issues and all of the O2 lockers are empty."

/datum/supply_packs/vox_supply
	name = "N2 internals resupply"
	contains = list(/obj/item/weapon/tank/nitrogen,
					/obj/item/weapon/tank/nitrogen,
					/obj/item/weapon/tank/nitrogen,
					/obj/item/clothing/mask/breath/vox,
					/obj/item/clothing/mask/breath/vox,
					/obj/item/clothing/mask/breath/vox)
	cost = 30
	containertype = /obj/structure/closet/crate/basic
	containername = "n2 internals crate"
	group = "Supplies"
	containsicon = /obj/item/weapon/tank/nitrogen
	containsdesc = "For when the birds are in town but you don't have enough tanks to go around. Comes with three nitrogen tanks and three masks."

/datum/supply_packs/plasmaman_supply
	name = "Plasma internals resupply"
	contains = list(/obj/item/weapon/tank/plasma/plasmaman,
					/obj/item/weapon/tank/plasma/plasmaman,
					/obj/item/weapon/tank/plasma/plasmaman,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	cost = 30
	containertype = /obj/structure/closet/crate/basic
	containername = "plasma internals crate"
	group = "Supplies"
	containsicon = /obj/item/weapon/tank/plasma/plasmaman
	containsdesc = "Three tanks of plasma gas, perfect for replacing your used plasma air container. Comes with three bonus masks."

/datum/supply_packs/evacuation
	name = "Emergency equipment"
	contains = list(/obj/item/weapon/storage/toolbox/emergency,
					/obj/item/weapon/storage/toolbox/emergency,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/machinery/bot/floorbot,
					/obj/machinery/bot/floorbot,
					/obj/machinery/bot/medbot,
					/obj/machinery/bot/medbot,
					/obj/item/clothing/accessory/rad_patch,
					/obj/item/clothing/accessory/rad_patch,
					/obj/item/clothing/accessory/rad_patch)
	cost = 40
	containertype = /obj/structure/closet/crate/internals
	containername = "emergency crate"
	group = "Supplies"
	containsdesc = "General equipment for use in any emergency. Includes first response medical robots, basic air tanks and masks, two general emergency kits, two hazard vests, radiation patches, and two floor robots for resealing breaches."

/datum/supply_packs/janitor
	name = "Janitorial supplies"
	contains = list(/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bottle/bleach,
					/obj/item/weapon/soap,
					/obj/item/weapon/storage/bag/trash,
					/obj/item/weapon/reagent_containers/spray/cleaner,
					/obj/item/weapon/reagent_containers/glass/rag,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/storage/box/mousetraps)
	cost = 15
	containertype = /obj/structure/closet/crate/basic
	containername = "janitorial supplies crate"
	group = "Supplies"
	containsdesc = "A basic janitorial supply kit. Includes a soap and bucket, a large trash bag, and three cleaning grenades. Does NOT include PPE! Please remember to order those supplies separately. Mop and cautions signs also sold separately."

/datum/supply_packs/mopbucket
	name = "Mop and Bucket"
	contains = list(/obj/item/weapon/mop,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/structure/mopbucket)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "mop and bucket crate"
	group = "Supplies"
	containsdesc = "A replacement mop and warning signs for floor cleaning."

/datum/supply_packs/trashcompactor
	name = "Trash compactor"
	contains = list(/obj/machinery/disposal/compactor/unplugged)
	cost = 100
	containertype = /obj/structure/largecrate
	containername = "trash compactor crate"
	group = "Supplies"
	containsdesc = "When disposals stops working and you've gotta get rid of your trash. Comes with one compactor."

/datum/supply_packs/lightbulbs
	name = "Replacement lights"
	contains = list(/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed)
	cost = 10
	containertype = /obj/structure/closet/crate/basic
	containername = "replacement lights crate"
	group = "Supplies"
	containsdesc = "Three boxes of replacement lights, including both bulbs and tubes."

/datum/supply_packs/helightbulbs
	name = "High efficiency lights"
	contains = list(/obj/item/weapon/storage/box/lights/he,
					/obj/item/weapon/storage/box/lights/he)
	cost = 20
	containertype = /obj/structure/closet/crate/basic
	containername = "high efficiency lights crate"
	group = "Supplies"
	containsdesc = "The latest and greatest in lighting technology. Brighter tubes that use less power! Comes with two boxes containing bulbs and tubes."

/datum/supply_packs/newscaster
	name = "Newscaster"
	contains = list(/obj/item/mounted/frame/newscaster,
					/obj/item/mounted/frame/newscaster,
					/obj/item/mounted/frame/newscaster)
	cost = 10
	containertype = /obj/structure/closet/crate/basic
	containername = "newscaster crate"
	group = "Supplies"
	containsdesc = "Three newscasters. Perfect to make sure your journalism is heard."

/datum/supply_packs/office_supplies
	name = "Office supplies"
	contains = list(/obj/item/weapon/paper_pack,
					/obj/item/weapon/folder/black,
					/obj/item/weapon/folder/white,
					/obj/item/weapon/folder/blue,
					/obj/item/weapon/folder/red,
					/obj/item/weapon/folder/orange,
					/obj/item/weapon/pen,
					/obj/item/weapon/pen/blue,
					/obj/item/weapon/pen/red,
					/obj/item/weapon/pen/fountain,
					/obj/item/device/flashlight/lamp,
					/obj/item/device/flashlight/lamp)
	cost = 15
	containertype = /obj/structure/closet/crate/basic
	containername = "office supply crate"
	group = "Supplies"
	containsdesc = "Paperwork supplies. Includes a paper pack, folders, pens, and some desk lamps."

/datum/supply_packs/space_heaters
	name = "Space Heaters"
	contains = list(/obj/machinery/space_heater,
					/obj/machinery/space_heater)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "space heater crate"
	group = "Supplies"
	containsdesc = "Currently on a two-for-one special. Perfect for when your coworkers set the thermostat too low, or your bosses decide to make your space station base on a snow planet for some reason."

/datum/supply_packs/air_conditioners
	name = "Air Conditioners"
	contains = list(/obj/machinery/space_heater/air_conditioner,
					/obj/machinery/space_heater/air_conditioner)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "air conditioner crate"
	group = "Supplies"
	containsdesc = "Currently on a two-for-one special. Perfect for when your coworkers accidentally release plasma gas into your oxygenated atmosphere and light it."

/datum/supply_packs/porcelain
	name = "Porcelain furniture"
	contains = list()
	cost = 10
	containertype = /obj/structure/largecrate/porcelain
	containername = "porcelain crate"
	group = "Supplies"
	containsicon = /obj/structure/toilet
	containsdesc = "A crate containing one sink and one toilet. Necessary for a proper dorm environment."

/datum/supply_packs/showers
	name = "Showers"
	contains = list()
	cost = 10
	containertype = /obj/structure/largecrate/showers
	containername = "showers crate"
	group = "Supplies"
	containsicon = /obj/machinery/shower
	containsdesc = "Hit the showers! Contains two showers."

/datum/supply_packs/clock
	name = "Grandfather Clock"
	contains = list(/obj/structure/clock/unanchored)
	cost = 40
	containertype = /obj/structure/largecrate
	containername = "ticking crate"
	group = "Supplies"
	containsdesc = "An old grandfather clock. Add that old timey feel to a room."

/datum/supply_packs/anvil
	name = "Anvil"
	contains = list(/obj/item/anvil,/obj/item/clothing/suit/leather_apron)
	cost = 150
	containertype = /obj/structure/largecrate
	containername = "anvil crate"
	group = "Supplies"
	containsdesc = "A heavy, metal anvil. Comes with a free leather apron!"

/datum/supply_packs/metal50
	name = "50 metal sheets"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/engi
	containername = "metal sheets crate"
	group = "Supplies"
	containsdesc = "The classic stack of 50 metal. Order as many as you need, space man."

/datum/supply_packs/glass50
	name = "50 glass sheets"
	contains = list(/obj/item/stack/sheet/glass/glass)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/engi
	containername = "glass sheets crate"
	group = "Supplies"
	containsdesc = "50 sheets of glass, for when the miner forgets to dig up his sand."

/datum/supply_packs/plastic50
	name = "50 plastic sheets"
	contains = list(/obj/item/stack/sheet/mineral/plastic)
	amount = 50
	cost = 30
	containertype = /obj/structure/closet/crate/engi
	containername = "plastic sheets crate"
	group = "Supplies"
	containsdesc = "A mechanic's best friend. A stack of 50 sheets."

/datum/supply_packs/wood50
	name = "50 wooden planks"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 50
	cost = 20
	containertype = /obj/structure/closet/crate/engi
	containername = "wooden planks crate"
	group = "Supplies"
	containsdesc = "All the wooden planks you could ever ask for, so long as you ask for no more than 50."

/datum/supply_packs/carpet
	name = "30 carpet tiles"
	contains = list(/obj/item/stack/tile/carpet)
	amount = 30
	cost = 15
	containertype = /obj/structure/closet/crate/basic
	containername = "carpet crate"
	group = "Supplies"
	containsdesc = "A formal carpet, able to cover about thirty square meters of area."

/datum/supply_packs/arcade
	name = "30 arcade tiles"
	contains = list(/obj/item/stack/tile/arcade)
	amount = 30
	cost = 15
	containertype = /obj/structure/closet/crate/basic
	containername = "arcade tiles crate"
	group = "Supplies"
	containsdesc = "We're having fun tonight! Thirty pre-cut squares of fun, squishy, and slightly sticky arcade flooring."

/datum/supply_packs/grass
	name = "30 grass tiles"
	contains = list(/obj/item/stack/tile/grass)
	amount = 30
	cost = 15
	containertype = /obj/structure/closet/crate/freezer
	containername = "grass crate"
	group = "Supplies"
	containsdesc = "All-natural grass, sealed in a crate that preserves its freshness. Can cover about thirty square meters."

/datum/supply_packs/watertank
	name = "Water tank"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "water tank crate"
	group = "Supplies"
	containsdesc = "A water tank. Contains a little over six full buckets worth of water."

/datum/supply_packs/fueltank
	name = "Fuel tank"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 15
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"
	group = "Supplies"
	containsdesc = "A fuel tank, perfect for refueling welding tools. Warning, contents are volatile."

/datum/supply_packs/silicatetank
	name = "Silicate tank"
	contains = list(/obj/structure/reagent_dispensers/silicate)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "silicate tank crate"
	group = "Supplies"
	containsdesc = "A tank filled with silicate, perfect for repairing windows with."

/datum/supply_packs/sacidtank
	name = "Sulphuric acid tank"
	contains = list(/obj/structure/reagent_dispensers/sacid)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/large/reinforced/shard/empty
	containername = "sulphuric acid tank crate"
	group = "Supplies"
	one_access = list(access_engine_minor, access_science)
	containsdesc = "A tank filled to the brim with sulphuric acid. For when you're doing a lot of circuit board work, or you're a really thirsty alien."

/datum/supply_packs/firefighting
	name = "Firefighting equipment"
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/weapon/extinguisher,
					/obj/item/weapon/extinguisher,)
	cost = 20
	containertype = /obj/structure/closet/crate/basic
	containername = "firefighting equipment crate"
	group = "Supplies"
	containsdesc = "Standard firefighting gear. Includes two full suits to protect upcoming firemen against the dangers of fire, plus two classic fire extinguishers. Fire axe not included."

/datum/supply_packs/paintgeneral
	name = "Painter general supplies"
	contains = list(/obj/item/weapon/storage/fancy/crayons,
					/obj/item/weapon/storage/toolbox/paint,
					/obj/item/painting_brush,
					/obj/item/paint_roller,
					/obj/item/palette,
					/obj/structure/easel,
					/obj/item/mounted/frame/painting/custom,
					/obj/item/mounted/frame/painting/custom,
					/obj/item/mounted/frame/painting/custom/landscape,
					/obj/item/mounted/frame/painting/custom/portrait,
					/obj/item/mounted/frame/painting/custom/large,
					/obj/item/stack/sheet/wood/bigstack,
					)
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "\improper Painter supplies crate"
	group = "Supplies"
	containsicon = "painting"
	containsdesc = "An all-in-one crate containing everything a painter needs to get started."

/datum/supply_packs/paintsamples
	name = "Random paint samples"
	contains = list(/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random,
					/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random,
					/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random,
					/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random,
					/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random,
					/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random,
					/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random,
					/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random,
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper Paints crate"
	group = "Supplies"
	containsicon = "paints"
	containsdesc = "A collection of 8 paint buckets, containing various known and less known paints."

/datum/supply_packs/posters
	name = "Posters assortment"
	contains = list(/obj/item/mounted/poster,
					/obj/item/mounted/poster,
					/obj/item/mounted/poster,
					/obj/item/mounted/poster)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper Posters crate"
	group = "Supplies"
	containsicon = "posters"
	containsdesc = "A pack of 4 random posters."

/datum/supply_packs/photoset
	name = "Photography equipment"
	contains = list(/obj/item/device/camera,
					/obj/item/device/camera_film,
					/obj/item/device/camera_film,
					/obj/item/weapon/storage/photo_album)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper Photography crate"
	group = "Supplies"
	containsicon = /obj/item/device/camera
	containsdesc = "A starter photography kit. Comes with a camera, some film, and a photo album."

/datum/supply_packs/marbleblock
	name = "Marble block"
	contains = list(/obj/structure/block)
	cost = 50
	containertype = /obj/structure/largecrate
	containername = "marble block crate"
	group = "Supplies"
	containsdesc = "Contains an entire marble block. Chisel not included!"

/datum/supply_packs/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/weapon/storage/pill_bottle/zoom,
					/obj/item/weapon/storage/pill_bottle/speedcrank,
					/obj/item/weapon/storage/pill_bottle/happy,
					/obj/item/weapon/reagent_containers/glass/bottle/pcp,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe,
					/obj/item/weapon/storage/bag/wiz_cards/frog)

	name = "Contraband crate"
	cost = 30
	containertype = /obj/structure/closet/crate/basic
	containername = "unlabeled crate"
	contraband = 1
	containsdesc = "Illicit, smuggled goods. Don't let security find this."
	group = "Supplies"

/datum/supply_packs/boxes
	name = "Empty box supply"
	contains = list(/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box)
	cost = 10
	containertype = /obj/structure/closet/crate/basic
	containername = "empty box crate"
	group = "Supplies"
	containsdesc = "A box filled with ten empty boxes."

/datum/supply_packs/eftpos
	contains = list(/obj/item/device/eftpos)
	name = "EFTPOS scanner"
	cost = 10
	containertype = /obj/structure/closet/crate/basic
	containername = "\improper EFTPOS crate"
	group = "Supplies"
	containsdesc = "A replacement EFTPOS scanner. Great for being a paperweight."

/datum/supply_packs/floodlight
	name = "Emergency floodlight"
	contains = list(/obj/machinery/floodlight)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "emergency floodlight crate"
	group = "Supplies"
	containsdesc = "A single large floodlight."

/datum/supply_packs/airbags
	name = "Personal airbags"
	contains = list(/obj/item/airbag,
					/obj/item/airbag,
					/obj/item/airbag,
					/obj/item/airbag,
					/obj/item/airbag)
	cost = 25
	containertype = /obj/structure/closet/crate/basic
	containername = "airbag crate"
	group = "Supplies"
	containsdesc = "For when the airflow on the station becomes violent. This will save your life! Contains 5 airbags."

/datum/supply_packs/religious//you can only order default-looking bibles for now
	name = "Religious Paraphernalia"
	contains = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/weapon/storage/bible,
					/obj/item/weapon/storage/fancy/incensebox/harebells,
					/obj/item/weapon/thurible)
	cost = 100
	containertype = /obj/structure/closet/crate/basic
	containername = "religious stuff crate"
	group = "Supplies"
	containsdesc = "A starter religious set. Contains a bible, some holy water, and a bit of incense."
