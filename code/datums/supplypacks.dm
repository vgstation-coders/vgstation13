//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been emagged.
//ANOTER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

var/list/all_supply_groups = list("Supplies","Clothing","Security","Hospitality","Engineering","Medical","Science","Hydroponics","Vending Machine packs")

/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/containertype = null
	var/containername = null
	var/access = null
	var/hidden = 0 //Emaggable
	var/contraband = 0 //Hackable via tools
	var/group = "Supplies"

/datum/supply_packs/New()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)	continue
		var/atom/movable/AM = new path()
		manifest += "<li>[AM.name]</li>"
		AM.loc = null	//just to make sure they're deleted by the garbage collector
	manifest += "</ul>"

//////SUPPLIES//////

/datum/supply_packs/toner
	name = "Toner Cartridges"
	contains = list(/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Toner Cartridges"
	group = "Supplies"

/datum/supply_packs/labels
	name = "Label Rolls"
	contains = list(/obj/item/weapon/storage/box/labels,
					/obj/item/weapon/storage/box/labels, //21 label rolls is enough to label Beepsky "SHITCURITRON" 375 times,
					/obj/item/weapon/storage/box/labels) //so this might be a bit excessive.
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Label Rolls"
	group = "Supplies"

/datum/supply_packs/internals
	name = "Internals crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air)
	cost = 10
	containertype = /obj/structure/closet/crate/internals
	containername = "Internals crate"
	group = "Supplies"

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
					/obj/machinery/bot/medbot)
	cost = 40
	containertype = /obj/structure/closet/crate/internals
	containername = "Emergency Crate"
	group = "Supplies"

/datum/supply_packs/janitor
	name = "Janitorial supplies"
	contains = list(/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/mop,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/storage/bag/trash,
					/obj/item/weapon/reagent_containers/spray/cleaner,
					/obj/item/weapon/reagent_containers/glass/rag,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/structure/mopbucket)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Janitorial supplies"
	group = "Supplies"

/datum/supply_packs/lightbulbs
	name = "Replacement lights"
	contains = list(/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Replacement lights"
	group = "Supplies"

/datum/supply_packs/helightbulbs
	name = "High efficiency lights"
	contains = list(/obj/item/weapon/storage/box/lights/he,
					/obj/item/weapon/storage/box/lights/he)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "High efficiency lights"
	group = "Supplies"

/datum/supply_packs/newscaster
	name = "Newscaster crate"
	contains = list(/obj/item/mounted/frame/newscaster,
					/obj/item/mounted/frame/newscaster,
					/obj/item/mounted/frame/newscaster)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Newscaster crate"
	group = "Supplies"

/datum/supply_packs/mule
	name = "MULEbot Crate"
	contains = list(/obj/machinery/bot/mulebot)
	cost = 20
	containertype = /obj/structure/largecrate/mule
	containername = "MULEbot Crate"
	group = "Supplies"

/datum/supply_packs/porcelain
	name = "Porcelain Crate"
	contains = list()
	cost = 10
	containertype = /obj/structure/largecrate/porcelain
	containername = "Porcelain Crate"
	group = "Supplies"

/datum/supply_packs/showers
	name = "Showers Crate"
	contains = list()
	cost = 10
	containertype = /obj/structure/largecrate/showers
	containername = "Showers Crate"
	group = "Supplies"

/datum/supply_packs/metal50
	name = "50 Metal Sheets"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/engi
	containername = "Metal sheets crate"
	group = "Supplies"

/datum/supply_packs/glass50
	name = "50 Glass Sheets"
	contains = list(/obj/item/stack/sheet/glass/glass)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/engi
	containername = "Glass sheets crate"
	group = "Supplies"

/datum/supply_packs/wood25
	name = "25 Wooden Planks"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 25
	cost = 12
	containertype = /obj/structure/closet/crate/engi
	containername = "Wooden planks crate"
	group = "Supplies"

/datum/supply_packs/carpet
	name = "30 Carpet Tiles"
	contains = list(/obj/item/stack/tile/carpet)
	amount = 30
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "Carpet Crate"
	group = "Supplies"

/datum/supply_packs/arcade
	name = "30 Arcade Tiles"
	contains = list(/obj/item/stack/tile/arcade)
	amount = 30
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "Arcade Tiles Crate"
	group = "Supplies"

/datum/supply_packs/grass
	name = "30 Grass Tiles"
	contains = list(/obj/item/stack/tile/grass)
	amount = 30
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "Grass Crate"
	group = "Supplies"

/datum/supply_packs/watertank
	name = "Water tank crate"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "water tank crate"
	group = "Supplies"

/datum/supply_packs/fueltank
	name = "Fuel tank crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"
	group = "Supplies"

/datum/supply_packs/silicatetank
	name = "Silicate tank crate"
	contains = list(/obj/structure/reagent_dispensers/silicate)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "silicate tank crate"
	group = "Supplies"

/datum/supply_packs/mining
	name = "Mining Equipment"
	contains = list(/obj/item/weapon/pickaxe/drill,
					/obj/item/weapon/pickaxe,
					/obj/item/weapon/pickaxe,
					/obj/item/device/flashlight/lantern,
					/obj/item/device/flashlight/lantern,
					/obj/item/device/flashlight/lantern,
					/obj/item/device/mining_scanner,
					/obj/item/weapon/storage/bag/ore,
					/obj/item/weapon/storage/bag/ore,
					/obj/item/weapon/storage/bag/ore,
					/obj/item/weapon/storage/bag/money,
					/obj/item/weapon/storage/bag/money)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "Mining Equipment Crate"
	access = access_mining
	group = "Supplies"

/datum/supply_packs/artscrafts
	name = "Arts and Crafts supplies"
	contains = list(/obj/item/weapon/storage/fancy/crayons,
	/obj/item/device/camera,
	/obj/item/device/camera_film,
	/obj/item/device/camera_film,
	/obj/item/weapon/storage/photo_album,
	/obj/item/stack/package_wrap,
	/obj/item/weapon/reagent_containers/glass/paint/red,
	/obj/item/weapon/reagent_containers/glass/paint/green,
	/obj/item/weapon/reagent_containers/glass/paint/blue,
	/obj/item/weapon/reagent_containers/glass/paint/yellow,
	/obj/item/weapon/reagent_containers/glass/paint/violet,
	/obj/item/weapon/reagent_containers/glass/paint/black,
	/obj/item/weapon/reagent_containers/glass/paint/white,
	/obj/item/weapon/reagent_containers/glass/paint/remover,
	/obj/item/mounted/poster,
	/obj/item/stack/package_wrap/gift,
	/obj/item/stack/package_wrap/gift,
	/obj/item/stack/package_wrap/gift)
	cost = 10
	containertype = "/obj/structure/closet/crate"
	containername = "Arts and Crafts crate"
	group = "Supplies"


/datum/supply_packs/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/seeds/bloodtomatoseed,
					/obj/item/weapon/storage/pill_bottle/zoom,
					/obj/item/weapon/storage/pill_bottle/happy,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe,
					/obj/item/weapon/storage/bag/wiz_cards/frog)

	name = "Contraband crate"
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "Unlabeled crate"
	contraband = 1
	group = "Supplies"

/datum/supply_packs/boxes
	name = "Empty Box supplies"
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
	containertype = "/obj/structure/closet/crate"
	containername = "Empty Box crate"
	group = "Supplies"

/datum/supply_packs/eftpos
	contains = list(/obj/item/device/eftpos)
	name = "EFTPOS scanner"
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "EFTPOS crate"
	group = "Supplies"

//////CLOTHING//////

/datum/supply_packs/costume
	name = "Standard Costume crate"
	contains = list(/obj/item/weapon/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/clown,
					/obj/item/weapon/bikehorn,
					/obj/item/clothing/under/mime,
					/obj/item/clothing/shoes/mime,
					/obj/item/clothing/gloves/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/suit/suspenders,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "Standard Costumes"
	access = access_theatre
	group = "Clothing"

/datum/supply_packs/wizard
	name = "Wizard costume"
	contains = list(/obj/item/weapon/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "Wizard costume crate"
	group = "Clothing"

/datum/supply_packs/randomised
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/HoS,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	name = "Collectable hat crate!"
	cost = 200
	containertype = /obj/structure/closet/crate
	containername = "Collectable hats crate! Brought to you by Bass.inc!"
	group = "Clothing"

/datum/supply_packs/randomised/New()
	manifest += "Contains any [num_contained] of:"
	..()

/datum/supply_packs/formal_wear
	contains = list(/obj/item/clothing/head/that,
					/obj/item/clothing/suit/storage/lawyer/bluejacket,
					/obj/item/clothing/suit/storage/lawyer/purpjacket,
					/obj/item/clothing/under/suit_jacket,
					/obj/item/clothing/under/suit_jacket/female,
					/obj/item/clothing/under/suit_jacket/really_black,
					/obj/item/clothing/under/suit_jacket/red,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/suit/wcoat)
	name = "Formalwear closet"
	cost = 30
	containertype = /obj/structure/closet
	containername = "Formalwear for the best occasions."
	group = "Clothing"

/datum/supply_packs/waifu
	name = "Feminine formalwear"
	contains = list(/obj/item/clothing/under/dress/dress_fire,
					/obj/item/clothing/under/dress/dress_green,
					/obj/item/clothing/under/dress/dress_orange,
					/obj/item/clothing/under/dress/dress_pink,
					/obj/item/clothing/under/dress/dress_yellow,
					/obj/item/clothing/under/dress/dress_saloon,
					/obj/item/clothing/head/hairflower,
					/obj/item/clothing/under/wedding/bride_orange,
					/obj/item/clothing/under/wedding/bride_purple,
					/obj/item/clothing/under/wedding/bride_blue,
					/obj/item/clothing/under/wedding/bride_red,
					/obj/item/clothing/under/wedding/bride_white,
					/obj/item/clothing/under/sundress,
					/obj/item/weapon/lipstick/random,
					/obj/item/weapon/lipstick/random)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "Feminine clothing"
	group = "Clothing"

/datum/supply_packs/knight //why seperate them
	name = "Knight Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/knight,
					/obj/item/clothing/suit/armor/knight/red,
					/obj/item/clothing/suit/armor/knight/yellow,
					/obj/item/clothing/suit/armor/knight/blue,
					/obj/item/clothing/head/helmet/knight,
					/obj/item/clothing/head/helmet/knight/red,
					/obj/item/clothing/head/helmet/knight/yellow,
					/obj/item/clothing/head/helmet/knight/blue)
	cost = 35
	containertype = /obj/structure/closet/crate
	containername = "knight armor crate"
	group = "Clothing"

/datum/supply_packs/vox_supply
	name = "Vox Resupply Crate"
	contains = list(/obj/item/clothing/suit/space/vox/civ,
					/obj/item/clothing/head/helmet/space/vox/civ,
					/obj/item/weapon/tank/nitrogen,
					/obj/item/clothing/mask/breath/vox)
	cost = 100
	containertype = /obj/structure/closet/crate
	containername = "Vox Resupply Crate"
	group = "Clothing"

/datum/supply_packs/plasmaman_supply
	name = "Plasmaman Containment Crate"
	contains = list(/obj/item/clothing/suit/space/plasmaman/assistant,
					/obj/item/clothing/head/helmet/space/plasmaman/assistant,
					/obj/item/weapon/tank/plasma/plasmaman,
					/obj/item/clothing/mask/breath)
	cost = 100
	containertype = /obj/structure/closet/crate
	containername = "Plasmaman Containment Crate"
	group = "Clothing"

/datum/supply_packs/grey_supply
	name = "Grey Space-Ex Crate"
	contains = list(/obj/item/clothing/suit/space/grey,
					/obj/item/clothing/head/helmet/space/grey,
					/obj/item/weapon/tank/oxygen/red,
					/obj/item/clothing/mask/breath)
	cost = 100
	containertype = /obj/structure/closet/crate
	containername = "Grey Space-Ex Crate"
	group = "Clothing"

//////SECURITY//////

/datum/supply_packs/specialops
	name = "Special Ops supplies"
	contains = list(/obj/item/weapon/storage/box/emps,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/pen/paralysis,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "Special Ops crate"
	group = "Security"
	hidden = 1

/datum/supply_packs/beanbagammo
	name = "Beanbag shells"
	contains = list(/obj/item/ammo_casing/shotgun/beanbag,
					/obj/item/ammo_casing/shotgun/beanbag,
					/obj/item/ammo_casing/shotgun/beanbag,
					/obj/item/ammo_casing/shotgun/beanbag,
					/obj/item/ammo_casing/shotgun/beanbag,
					/obj/item/ammo_casing/shotgun/beanbag,
					/obj/item/ammo_casing/shotgun/beanbag,
					/obj/item/ammo_casing/shotgun/beanbag,
					/obj/item/ammo_casing/shotgun/beanbag,
					/obj/item/ammo_casing/shotgun/beanbag)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Beanbag shells"
	group = "Security"

/datum/supply_packs/weapons
	name = "Weapons crate"
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/taser,
					/obj/item/weapon/gun/energy/taser,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/bolas)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "Weapons crate"
	access = access_security
	group = "Security"

/datum/supply_packs/eweapons
	name = "Incendiary weapons crate"
	contains = list(/obj/item/weapon/gun/projectile/flamethrower/full,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "Incendiary weapons crate"
	access = access_heads
	group = "Security"

/datum/supply_packs/armor
	name = "Armor crate"
	contains = list(/obj/item/clothing/head/helmet/tactical/sec,
					/obj/item/clothing/head/helmet/tactical/sec,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "Armor crate"
	access = access_security
	group = "Security"

/datum/supply_packs/riot
	name = "Riot gear crate"
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/handcuffs,
					/obj/item/weapon/handcuffs,
					/obj/item/weapon/handcuffs,
					/obj/item/clothing/head/helmet/tactical/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/head/helmet/tactical/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/head/helmet/tactical/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/weapon/storage/box/bolas,
					/obj/item/weapon/storage/box/bolas)
	cost = 60
	containertype = /obj/structure/closet/crate/secure
	containername = "Riot gear crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/loyalty
	name = "Loyalty implant crate"
	contains = list (/obj/item/weapon/storage/lockbox/loyalty)
	cost = 60
	containertype = /obj/structure/closet/crate/secure
	containername = "Loyalty implant crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/tracking
	name = "Tracking implant crate"
	contains = list (/obj/item/weapon/storage/lockbox/tracking)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "Tracking implant crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/chem
	name = "Chemical implant crate"
	contains = list (/obj/item/weapon/storage/lockbox/chem)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "Chemical implant crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/ballistic
	name = "Ballistic gear crate"
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/weapon/gun/projectile/shotgun/pump/combat,
					/obj/item/weapon/gun/projectile/shotgun/pump/combat)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "Ballistic gear crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/shotgunammo
	name = "Shotgun shells"
	contains = list(/obj/item/weapon/storage/box/lethalshells,
					/obj/item/weapon/storage/box/buckshotshells,
					/obj/item/weapon/storage/box/beanbagshells,
					/obj/item/weapon/storage/box/stunshells,
					/obj/item/weapon/storage/box/dartshells)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "Shotgun shells"
	access = access_armory
	group = "Security"

/datum/supply_packs/expenergy
	name = "Experimental energy gear crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "Experimental energy gear crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/exparmor
	name = "Experimental armor crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/head/helmet/tactical/riot,
					/obj/item/clothing/suit/armor/riot)
	cost = 35
	containertype = /obj/structure/closet/crate/secure
	containername = "Experimental armor crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/securitybarriers
	name = "Security Checkpoint Equipment"
	contains = list(/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/detector)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "Security Barriers crate"
	group = "Security"

//////HOSPITALITY//////

/datum/supply_packs/food
	name = "Basic cooking crate"
	contains = list(/obj/item/weapon/reagent_containers/food/drinks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/storage/fancy/egg_box)
	cost = 10
	containertype = /obj/structure/closet/crate/freezer
	containername = "Basic cooking crate"
	group = "Hospitality"

/datum/supply_packs/randomised/fruit
	name = "Fruit crate"
	num_contained = 16
	contains = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon,
					/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
					/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
					/obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
					/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
					/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes,
					/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
					/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
					/obj/item/weapon/reagent_containers/food/snacks/grown/orange)
	cost = 20
	containertype = /obj/structure/closet/crate/freezer
	containername = "Fruit crate"
	group = "Hospitality"

/datum/supply_packs/exotic_garnishes //We don't use a randomised crate because we want some special reagents, and also to control chances
	name = "Exotic garnishes"
	contains = list(/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic,
					/obj/item/weapon/reagent_containers/food/condiment/exotic)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "Exotic garnishes"
	access = access_kitchen
	group = "Hospitality"

/datum/supply_packs/randomised/trophy_meats
	name = "Trophy meats"
	num_contained = 8
	contains = list(/obj/item/weapon/reagent_containers/food/snacks/meat/mimic,
					/obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat,
					/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
					/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
					/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/imitation,
					/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
					/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
					/obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg,
					/obj/item/weapon/reagent_containers/food/snacks/spidereggs)
	cost = 30
	containertype = /obj/structure/closet/crate/secure
	containername = "Trophy meats"
	access = access_kitchen
	group = "Hospitality"

/datum/supply_packs/party
	name = "Party equipment"
	contains = list(/obj/item/weapon/storage/box/drinkingglasses,
					/obj/item/weapon/reagent_containers/food/drinks/shaker,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/patron,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
					/obj/item/weapon/lipstick/random,
					/obj/item/weapon/reagent_containers/food/drinks/ale,
					/obj/item/weapon/reagent_containers/food/drinks/ale,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/device/maracas,
					/obj/item/device/maracas)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "Party equipment"
	group = "Hospitality"

/datum/supply_packs/randomised/pizza
	num_contained = 5
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable)
	name = "Surprise pack of five pizzas"
	cost = 75
	containertype = /obj/structure/closet/crate/freezer
	containername = "Pizza crate"
	group = "Hospitality"

/datum/supply_packs/cafe
	name = "Cafe equipment"
	contains = list(/obj/item/weapon/circuitboard/chem_dispenser/brewer,
	/obj/item/weapon/storage/box/mugs,
	/obj/item/weapon/storage/box/mugs,
	/obj/item/weapon/reagent_containers/glass/kettle/red)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "Cafe equipment"
	group = "Hospitality"

/datum/supply_packs/bar
	name = "Advanced Bartending equipment"
	contains = list(/obj/item/weapon/circuitboard/chem_dispenser/soda_dispenser,
	/obj/item/weapon/circuitboard/chem_dispenser/booze_dispenser,
	/obj/item/weapon/storage/box/drinkingglasses,
	/obj/item/weapon/storage/box/drinkingglasses,
	/obj/item/weapon/reagent_containers/food/drinks/shaker)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "Bartending equipment"
	group = "Hospitality"

/datum/supply_packs/festive
	name = "Festive supplies"
	contains = list(/obj/item/stack/package_wrap/gift,
					/obj/item/stack/package_wrap/gift,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/weapon/toy/xmas_cracker,
					/obj/item/clothing/head/christmas/santahat/red,
					/obj/item/clothing/head/christmas/santahat/green,
					/obj/item/clothing/suit/jumper/christmas/red,
					/obj/item/clothing/suit/jumper/christmas/green,
					/obj/item/clothing/suit/jumper/christmas/blue,
					/obj/item/clothing/mask/scarf/red,
					/obj/item/clothing/mask/scarf/blue,
					/obj/item/clothing/mask/scarf/green,
					/obj/item/clothing/under/wintercasualwear)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "Festivus supplies"
	group = "Hospitality"


//////ENGINEERING//////

/datum/supply_packs/electrical
	name = "Electrical maintenance crate"
	contains = list(/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/clothing/gloves/yellow,
					/obj/item/clothing/gloves/yellow,
					/obj/item/weapon/cell,
					/obj/item/weapon/cell,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cell/high)
	cost = 15
	containertype = /obj/structure/closet/crate/engi
	containername = "Electrical maintenance crate"
	group = "Engineering"

/datum/supply_packs/mechanical
	name = "Mechanical maintenance crate"
	contains = list(/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat)
	cost = 10
	containertype = /obj/structure/closet/crate/engi
	containername = "Mechanical maintenance crate"
	group = "Engineering"

/datum/supply_packs/solar
	name = "Solar Pack crate"
	contains  = list(/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly, //21 Solar Assemblies. 1 Extra for the controller
					/obj/item/weapon/circuitboard/solar_control,
					/obj/item/weapon/tracker_electronics,
					/obj/item/weapon/paper/solar)
	cost = 20
	containertype = /obj/structure/closet/crate/engi
	containername = "solar pack crate"
	group = "Engineering"

/datum/supply_packs/engine
	name = "Emitter crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Emitter crate"
	access = access_ce
	group = "Engineering"

/datum/supply_packs/engine/field_gen
	name = "Field Generator crate"
	contains = list(/obj/machinery/field_generator,
					/obj/machinery/field_generator)
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Field Generator crate"
	access = access_ce
	group = "Engineering"

/datum/supply_packs/engine/sing_gen
	name = "Singularity Generator crate"
	contains = list(/obj/machinery/the_singularitygen)
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Singularity Generator crate"
	access = access_ce
	group = "Engineering"

/datum/supply_packs/engine/collector
	name = "Collector crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	containername = "Collector crate"
	group = "Engineering"

/datum/supply_packs/engine/PA
	name = "Particle Accelerator crate"
	cost = 40
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Particle Accelerator crate"
	access = access_ce
	group = "Engineering"

/datum/supply_packs/mecha_ripley
	name = "Circuit Crate (\"Ripley\" APLU)"
	contains = list(/obj/item/weapon/book/manual/ripley_build_and_repair,
					/obj/item/weapon/circuitboard/mecha/ripley/main, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/ripley/peripherals) //TEMPORARY due to lack of circuitboard printer
	cost = 30
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "APLU \"Ripley\" Circuit Crate"
	access = access_robotics
	group = "Engineering"

/datum/supply_packs/mecha_odysseus
	name = "Circuit Crate (\"Odysseus\")"
	contains = list(/obj/item/weapon/circuitboard/mecha/odysseus/peripherals, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/odysseus/main) //TEMPORARY due to lack of circuitboard printer
	cost = 25
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "\"Odysseus\" Circuit Crate"
	access = access_robotics
	group = "Engineering"

/datum/supply_packs/shieldgens
	name = "Shield Generators"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Shield Generators crate"
	access = access_teleporter
	group = "Engineering"

/datum/supply_packs/engine/amrcontrol
	name = "Antimatter control unit crate"
	contains = list(/obj/machinery/power/am_control_unit)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Antimatter Control Unit crate"
	access = access_engine
	group = "Engineering"

/datum/supply_packs/engine/amrparts
	name = "AMR Parts crate"
	contains  = list(/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "packaged antimatter reactor crate"
	access = access_engine
	group = "Engineering"

/datum/supply_packs/engine/amrcontainment
	name = "Antimatter containment jar crate"
	contains = list(/obj/item/weapon/am_containment,
					/obj/item/weapon/am_containment,
					/obj/item/weapon/am_containment)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Antimatter containment jar crate"
	access = access_engine
	group = "Engineering"

/datum/supply_packs/rust_injector
	contains = list(/obj/machinery/power/rust_fuel_injector)
	name = "R-UST Mk. 7 fuel injector"
	cost = 25
	containertype = /obj/structure/closet/crate/secure/large
	containername = "R-UST Mk. 7 injector crate"
	group = "Engineering"
	access = access_engine

/datum/supply_packs/rust_gyrotron
	contains = list(/obj/machinery/rust/gyrotron)
	name = "R-UST Mk. 7 gyrotron"
	cost = 25
	containertype = /obj/structure/closet/crate/secure/large
	containername = "R-UST Mk. 7 gyrotron crate"
	group = "Engineering"
	access = access_engine

/datum/supply_packs/rust_compressor
	contains = list(/obj/item/weapon/module/rust_fuel_compressor)
	name = "R-UST Mk. 7 fuel compressor circuitry"
	cost = 30
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "R-UST Mk. 7 fuel compressor circuitry"
	group = "Engineering"
	access = access_engine

/datum/supply_packs/rust_assembly_port
	contains = list(/obj/item/weapon/module/rust_fuel_port)
	name = "R-UST Mk. 7 fuel assembly port circuitry"
	cost = 20
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "R-UST Mk. 7 fuel assembly port circuitry"
	group = "Engineering"
	access = access_engine

/datum/supply_packs/rust_core
	contains = list(/obj/machinery/power/rust_core)
	name = "R-UST Mk. 7 Tokamak Core"
	cost = 50
	containertype = /obj/structure/closet/crate/secure/large
	containername = "R-UST Mk. 7 tokamak crate"
	group = "Engineering"
	access = access_engine

/datum/supply_packs/shield_gen
	contains = list(/obj/item/weapon/circuitboard/shield_gen)
	name = "Experimental shield generator circuitry"
	cost = 30
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Experimental shield generator"
	group = "Engineering"
	access = access_ce

/datum/supply_packs/shield_cap
	contains = list(/obj/item/weapon/circuitboard/shield_cap)
	name = "Experimental shield capacitor circuitry"
	cost = 30
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Experimental shield capacitor"
	group = "Engineering"
	access = access_ce

/datum/supply_packs/teg
	contains = list(/obj/machinery/power/generator)
	name = "Mark I Thermoelectric Generator"
	cost = 75
	containertype = /obj/structure/closet/crate/secure/large
	containername = "Mk1 TEG crate"
	group = "Engineering"
	access = access_engine

/datum/supply_packs/circulator
	contains = list(/obj/machinery/atmospherics/binary/circulator)
	name = "Binary atmospheric circulator"
	cost = 60
	containertype = /obj/structure/closet/crate/secure/large
	containername = "Atmospheric circulator crate"
	group = "Engineering"
	access = access_engine

/datum/supply_packs/supermatter_shard
	contains = list(/obj/machinery/power/supermatter/shard)
	name = "Supermatter Shard"
	cost = 500 //So cargo thinks thrice before killing themselves with it. You're going to need a department account most likely.
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Supermatter Shard Crate"
	group = "Engineering"
	access = access_ce

//////MEDICAL//////

/datum/supply_packs/medical
	name = "Medical crate"
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
					/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
					/obj/item/weapon/reagent_containers/glass/bottle/stoxin,
					/obj/item/weapon/storage/box/syringes,
					/obj/item/weapon/storage/bag/chem,
					/obj/item/weapon/storage/box/autoinjectors)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "Medical crate"
	group = "Medical"

/datum/supply_packs/virus
	name = "Virus crate"
/*	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/flu_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/cold,
					/obj/item/weapon/reagent_containers/glass/bottle/epiglottis_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/liver_enhance_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/weapon/reagent_containers/glass/bottle/magnitis,
					/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/weapon/reagent_containers/glass/bottle/brainrot,
					/obj/item/weapon/reagent_containers/glass/bottle/hullucigen_virion,
					/obj/item/weapon/storage/box/syringes,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/reagent_containers/glass/bottle/mutagen)*/
	contains = list(/obj/item/weapon/virusdish/random,
					/obj/item/weapon/virusdish/random,
					/obj/item/weapon/virusdish/random,
					/obj/item/weapon/virusdish/random)
	cost = 25
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Virus crate"
	access = access_cmo
	group = "Medical"

/datum/supply_packs/surgery
	name = "Surgery crate"
	contains = list(/obj/item/weapon/cautery,
					/obj/item/weapon/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/weapon/tank/anesthetic,
					/obj/item/weapon/FixOVein,
					/obj/item/weapon/hemostat,
					/obj/item/weapon/scalpel,
					/obj/item/weapon/bonegel,
					/obj/item/weapon/retractor,
					/obj/item/weapon/bonesetter,
					/obj/item/weapon/circular_saw)
	cost = 25
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Surgery crate"
	access = access_medical
	group = "Medical"

/datum/supply_packs/sterile
	name = "Sterile equipment crate"
	contains = list(/obj/item/clothing/under/rank/medical/green,
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/weapon/storage/box/masks,
					/obj/item/weapon/storage/box/gloves)
	cost = 15
	containertype = "/obj/structure/closet/crate"
	containername = "Sterile equipment crate"
	group = "Medical"

/datum/supply_packs/bloodbags
	name = "Bloodbag Crate"
	contains = list(/obj/item/weapon/reagent_containers/blood/APlus,
					/obj/item/weapon/reagent_containers/blood/AMinus,
					/obj/item/weapon/reagent_containers/blood/BPlus,
					/obj/item/weapon/reagent_containers/blood/BMinus,
					/obj/item/weapon/reagent_containers/blood/OPlus,
					/obj/item/weapon/reagent_containers/blood/OMinus,
					/obj/item/weapon/reagent_containers/blood/empty)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "Bloodbag Crate"
	access = access_medical
	group = "Medical"

/datum/supply_packs/wheelchair
	name = "Wheelchair Crate"
	contains = list(/obj/structure/bed/chair/vehicle/wheelchair)
	cost = 40
	containertype = /obj/structure/closet/crate/medical
	containername = "Wheelchair Crate"
	group = "Medical"

/datum/supply_packs/wheelchair_motorized
	name = "Motorized Wheelchair Crate"
	contains = list(/obj/structure/bed/chair/vehicle/wheelchair/motorized)
	cost = 200
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Motorized Wheelchair Crate"
	access = access_cmo
	group = "Medical"

//////SCIENCE//////

/datum/supply_packs/research_parts
	name = "RnD Stock Parts Crate"
	contains = list(
					/obj/item/weapon/circuitboard/protolathe,
					/obj/item/weapon/circuitboard/rdconsole,
					/obj/item/weapon/circuitboard/circuit_imprinter,
					/obj/item/weapon/circuitboard/destructive_analyzer,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/manipulator,
					/obj/item/weapon/stock_parts/manipulator,
					/obj/item/weapon/stock_parts/manipulator,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/stock_parts/scanning_module,
					/obj/item/weapon/stock_parts/micro_laser)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "RnD Stock Parts Crate"
	access = access_research
	group = "Science"

/datum/supply_packs/research_nanotrasen
	name = "RnD Experimental Crate"
	contains = list(
		/obj/item/weapon/disk/tech_disk/nanotrasen,
		/obj/item/weapon/paper/tech_nanotrasen,
		)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "RnD Experimental Crate"
	access = access_research
	group = "Science"

/datum/supply_packs/robotics
	name = "Robotics Assembly Crate"
	contains = list(/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cell/high)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "Robotics Assembly"
	access = access_robotics
	group = "Science"

/datum/supply_packs/plasma
	name = "Plasma assembly crate"
	contains = list(/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "Plasma assembly crate"
	access = access_tox_storage
	group = "Science"

/datum/supply_packs/borer
	name = "Borer Egg Crate"
	contains = list (/obj/item/weapon/reagent_containers/food/snacks/borer_egg)
	cost = 100
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "Borer egg crate"
	access = access_xenobiology
	group = "Science"

//////HYDROPONICS//////

/datum/supply_packs/monkey
	name = "Monkey crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes)
	cost = 20
	containertype = /obj/structure/closet/crate/freezer
	containername = "Monkey crate"
	group = "Hydroponics"

/datum/supply_packs/farwa
	name = "Farwa crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/farwacubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "Farwa crate"
	group = "Hydroponics"

/datum/supply_packs/skrell
	name = "Neaera crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/neaeracubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "Neaera crate"
	group = "Hydroponics"

/datum/supply_packs/stok
	name = "Stok crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/stokcubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "Stok crate"
	group = "Hydroponics"

/datum/supply_packs/vox
	name = "Genetically modified chicken crate"
	contains = list(/obj/item/weapon/storage/fancy/egg_box/vox)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "Green egg crate"
	group = "Hydroponics"

/* Defined below
/datum/supply_packs/lisa
	name = "Corgi Crate"
	contains = list()
	cost = 50
	containertype = /obj/structure/largecrate/lisa
	containername = "Corgi Crate"
	group = "Hydroponics" */

/datum/supply_packs/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/hatchet,
					/obj/item/weapon/minihoe,
					/obj/item/weapon/minihoe,
					/obj/item/device/analyzer/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron, // Updated with new things
					/obj/item/weapon/storage/box/botanydisk) //Updated with flora disks
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "Hydroponics crate"
	access = access_hydroponics
	group = "Hydroponics"

//farm animals - useless and annoying, but potentially a good source of food
/datum/supply_packs/cow
	name = "Cow Crate"
	cost = 30
	containertype = /obj/structure/largecrate/cow
	containername = "Cow Crate"
	access = access_hydroponics
	group = "Hydroponics"

/datum/supply_packs/goat
	name = "Goat Crate"
	cost = 25
	containertype = /obj/structure/largecrate/goat
	containername = "Goat Crate"
	access = access_hydroponics
	group = "Hydroponics"

/datum/supply_packs/chicken
	name = "Chicken Crate"
	cost = 20
	containertype = /obj/structure/largecrate/chick
	containername = "Chicken Crate"
	access = access_hydroponics
	group = "Hydroponics"

/datum/supply_packs/lisa
	name = "Corgi Crate"
	contains = list()
	cost = 50
	containertype = /obj/structure/largecrate/lisa
	containername = "Corgi Crate"
	group = "Hydroponics"

/datum/supply_packs/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/weapon/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "Weed control crate"
	access = access_hydroponics
	group = "Hydroponics"

/datum/supply_packs/exoticseeds
	name = "Exotic seeds crate"
	contains = list(/obj/item/seeds/dionanode,
					/obj/item/seeds/dionanode,
					/obj/item/seeds/libertymycelium,
					/obj/item/seeds/reishimycelium,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/kudzuseed,
					/obj/item/seeds/nofruitseed)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "Exotic Seeds crate"
	access = access_hydroponics
	group = "Hydroponics"

/datum/supply_packs/bee_keeper
	name = "Beekeeping Crate"
	contains = list(
		/obj/item/beezeez,
		/obj/item/beezeez,
		/obj/item/weapon/bee_net,
		/obj/item/weapon/extinguisher/mini,
		/obj/item/apiary,
		/obj/item/queen_bee,
		/obj/item/queen_bee,
		/obj/item/queen_bee,
		/obj/item/clothing/suit/bio_suit/beekeeping,
		/obj/item/clothing/head/bio_hood/beekeeping,
		/obj/item/weapon/book/manual/hydroponics_beekeeping,
		)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "Beekeeping crate"
	access = access_hydroponics
	group = "Hydroponics"

/datum/supply_packs/ranching
	name = "Ranching Crate"
	contains = list(
			/obj/item/weapon/circuitboard/egg_incubator,
			/obj/item/weapon/stock_parts/capacitor,
			/obj/item/weapon/stock_parts/capacitor,
			/obj/item/weapon/stock_parts/matter_bin,
			/obj/item/weapon/reagent_containers/food/snacks/egg,
			/obj/item/weapon/reagent_containers/food/snacks/egg,
			/obj/item/weapon/reagent_containers/food/snacks/egg,
			/obj/item/weapon/kitchen/utensil/knife/large,
			/obj/item/clothing/head/cowboy
		)
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "Ranching crate"
	group = "Hydroponics"

/datum/supply_packs/Hydroponics_Trays
	name = "Hydroponic Trays Components Crate"
	contains = list(
					/obj/item/weapon/circuitboard/hydroponics,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/scanning_module,
					/obj/item/weapon/stock_parts/capacitor,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/stock_parts/console_screen,
					/obj/item/weapon/circuitboard/hydroponics,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/scanning_module,
					/obj/item/weapon/stock_parts/capacitor,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/stock_parts/console_screen)
	cost = 12
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "Hydroponic Trays Components Crate"
	access = access_hydroponics
	group = "Hydroponics"

/////VENDING MACHINES PACKS////////

/datum/supply_packs/snackmachines
	name = "Snacks n Cigs stack of packs"
	contains = list(/obj/structure/vendomatpack/snack,
					/obj/structure/vendomatpack/snack,
					/obj/structure/vendomatpack/snack,
					/obj/structure/vendomatpack/cola,
					/obj/structure/vendomatpack/coffee,
					/obj/structure/vendomatpack/cigarette)
	cost = 30
	containertype = /obj/structure/stackopacks
	containername = "Snacks n Cigs  stack of packs"
	group = "Vending Machine packs"

/datum/supply_packs/snackmachinesalt
	name = "Groans n Dan stack of packs"
	contains = list(/obj/structure/vendomatpack/discount,
					/obj/structure/vendomatpack/discount,
					/obj/structure/vendomatpack/groans,
					/obj/structure/vendomatpack/groans)
	cost = 20
	containertype = /obj/structure/stackopacks
	containername = "Groans n Dan stack of packs"
	group = "Vending Machine packs"

/datum/supply_packs/hospitalitymachines
	name = "Theatre, Bar n Kitchen stack of packs"
	contains = list(/obj/structure/vendomatpack/boozeomat,
					/obj/structure/vendomatpack/dinnerware,
					/obj/structure/vendomatpack/autodrobe)
	cost = 15
	containertype = /obj/structure/stackopacks
	containername = "Theatre, Bar n Kitchen stack of packs"
	group = "Vending Machine packs"

/datum/supply_packs/securitymachines
	name = "Security stack of packs"
	contains = list(/obj/structure/vendomatpack/security,
					/obj/structure/vendomatpack/security)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "Security stack of packs"
	group = "Vending Machine packs"

/datum/supply_packs/medbaymachines
	name = "Medical stack of packs"
	contains = list(/obj/structure/vendomatpack/medical,
					/obj/structure/vendomatpack/medical)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "Medical stack of packs"
	group = "Vending Machine packs"

/datum/supply_packs/botanymachines
	name = "Hydroponics stack of packs"
	contains = list(/obj/structure/vendomatpack/hydronutrients,
					/obj/structure/vendomatpack/hydroseeds)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "Hydroponics stack of packs"
	group = "Vending Machine packs"

/datum/supply_packs/toolsmachines
	name = "Tools n Engineering stack of packs"
	contains = list(/obj/structure/vendomatpack/tool,
					/obj/structure/vendomatpack/tool,
					/obj/structure/vendomatpack/assist,
					/obj/structure/vendomatpack/engivend)
	cost = 20
	containertype = /obj/structure/stackopacks
	containername = "Tools n Engineering stack of packs"
	group = "Vending Machine packs"

/datum/supply_packs/clothesmachines
	name = "Clothing stack of packs"
	contains = list(/obj/structure/vendomatpack/hatdispenser,
					/obj/structure/vendomatpack/suitdispenser,
					/obj/structure/vendomatpack/shoedispenser)
	cost = 15
	containertype = /obj/structure/stackopacks
	containername = "Clothing stack of packs"
	group = "Vending Machine packs"

/*
/datum/supply_packs/sovietmachines
	name = "Old and Forgotten stack of packs"
	contains = list(/obj/structure/vendomatpack/sovietsoda,
					/obj/structure/vendomatpack/sovietsoda,
					/obj/structure/vendomatpack/nazivend,
					/obj/structure/vendomatpack/sovietvend)
	cost = 20
	containertype = /obj/structure/stackopacks
	containername = "Old and Forgotten stack of packs"
	group = "Vending Machine packs"
	hidden = 1
*/

/datum/supply_packs/magimachines
	name = "Strange and Bright stack of packs"
	contains = list(/obj/structure/vendomatpack/magivend)
	cost = 80
	containertype = /obj/structure/stackopacks
	containername = "Strange and Bright stack of packs"
	group = "Vending Machine packs"
	hidden = 1
