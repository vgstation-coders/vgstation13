//////SECURITY//////

/datum/supply_packs/specialops
	name = "Special Ops supplies"
	contains = list(/obj/item/weapon/storage/box/emps,
					/obj/item/weapon/storage/box/smokebombs,
					/obj/item/weapon/gun/projectile/silenced,
					/obj/item/ammo_storage/magazine/c45)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "special ops crate"
	group = "Security"
	hidden = 1
	containsdesc = "Hello, operative. With this crate, you, too, can be smooth."

/datum/supply_packs/randomised/russianguns
	name = "Russian weapons"
	num_contained = 3 //number of items picked to be contained in a randomised
	contains = list(/obj/item/weapon/gun/projectile/mosin,
					/obj/item/ammo_storage/speedloader/a762x55,
					/obj/item/ammo_storage/speedloader/a762x55,
					/obj/item/ammo_storage/speedloader/a762x55,
					/obj/item/ammo_storage/speedloader/a762x55/empty,
					/obj/item/ammo_storage/speedloader/a762x55/empty,
					/obj/item/ammo_storage/speedloader/a762x55/empty,
					/obj/item/ammo_storage/box/b762x55,
					/obj/item/ammo_storage/box/b762x55,
					/obj/item/ammo_storage/box/b762x55,
					/obj/item/weapon/gun/energy/laser/LaserAK,
					/obj/item/weapon/gun/energy/laser/LaserAK)
	cost = 150
	containertype = /obj/structure/closet/crate/basic
	containername = "russian weapons crate"
	containsdesc = "Army surplus, ordered directly from Space Russia."
	group = "Security"
	hidden = 1

/datum/supply_packs/secway
	name = "Secway"
	contains = list(/obj/structure/bed/chair/vehicle/secway)
	cost = 150
	containertype = /obj/structure/closet/crate/secure/large
	containername = "secway crate"
	access = list(access_security)
	group = "Security"
	containsdesc = "Our strongest warriors need the mightiest of steeds."

/datum/supply_packs/beanbagammo
	name = "Beanbag shells"
	contains = list(/obj/item/weapon/storage/box/beanbagshells)
	cost = 10
	containertype = /obj/structure/closet/crate/basic
	containername = "beanbag shells crate"
	group = "Security"
	containsdesc = "A refill for the bartender's standard issue. Safe for human consumption."

/datum/supply_packs/weapons
	name = "Security weapons"
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/taser,
					/obj/item/weapon/gun/energy/taser,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/weapon/storage/box/bolas)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "security weapons crate"
	access = list(access_security)
	group = "Security"
	containsdesc = "A kit of standard-issue weapons from Security. Includes two batons, two tasers, two emergency laser guns, and several accessories."

/datum/supply_packs/greyweapons
	name = "MDF surplus weapons"
	contains = list(/obj/item/weapon/melee/stunprobe,
					/obj/item/weapon/melee/stunprobe,
					/obj/item/weapon/gun/energy/smalldisintegrator,
					/obj/item/weapon/gun/energy/smalldisintegrator)
	cost = 60
	containertype = /obj/structure/closet/crate/secure/ayy_mdf
	containername = "MDF standard weapons crate"
	one_access = list(access_armory, access_mothership_military)
	group = "Security"
	hidden = 1
	containsdesc = "Surplus weapons from the nearest mothership military outpost, for quelling a human uprising."

/datum/supply_packs/smartlaser
	name = "Smart laser guns"
	contains = list(/obj/item/weapon/gun/energy/laser/smart,
					/obj/item/weapon/gun/energy/laser/smart,
					/obj/item/weapon/gun/energy/laser/smart,
					/obj/item/weapon/gun/energy/laser/smart)
	cost = 60
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "smart laser guns crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "Four high tech laser guns from Central Command. Handle with care."

/datum/supply_packs/eweapons
	name = "Incendiary weapons"
	contains = list(/obj/item/weapon/gun/projectile/flamethrower/full,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "incendiary weapons crate"
	access = list(access_heads)
	group = "Security"
	containsdesc = "A flamethrower and three incendiary grenades, perfect for dealing with alien infestations aboard your station."

/datum/supply_packs/armor
	name = "Armor"
	contains = list(/obj/item/clothing/head/helmet/tactical/sec,
					/obj/item/clothing/head/helmet/tactical/sec,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "armor crate"
	access = list(access_security)
	group = "Security"
	containsdesc = "A crate with two bulletproof vests, two general armor vests, and two tactical helmets."

/datum/supply_packs/greyarmor
	name = "MDF surplus standard armor"
	contains = list(/obj/item/clothing/suit/armor/mothership,
					/obj/item/clothing/suit/armor/mothership,
					/obj/item/clothing/under/grey/grey_soldier,
					/obj/item/clothing/under/grey/grey_soldier,
					/obj/item/clothing/shoes/jackboots/mothership,
					/obj/item/clothing/shoes/jackboots/mothership,
					/obj/item/clothing/head/helmet/mothership,
					/obj/item/clothing/head/helmet/mothership)
	cost = 60
	containertype = /obj/structure/closet/secure_closet/ayy2
	containername = "MDF standard armor locker"
	one_access = list(access_security, access_mothership_military)
	group = "Security"
	contraband = 1
	containsdesc = "Surplus armor from the mothership. Not fitted for human consumption."

/datum/supply_packs/grey_rigkits2
	name = "MDF rig parts"
	contains = list(/obj/item/device/rigparts/ayy_soldier)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/ayy_mdf
	one_access = list(access_armory, access_mothership_military)
	containername = "MDF rig parts crate"
	group = "Security"
	contraband = 1
	containsdesc = "A mothership military shipment containing the parts for an armored hardsuit. A human won't be able to squeeze their fat body into this."

/datum/supply_packs/greyexplorerarmor
	name = "GDR surplus explorer armor"
	contains = list(/obj/item/clothing/suit/armor/mothership/explorer,
					/obj/item/clothing/suit/armor/mothership/explorer,
					/obj/item/clothing/under/grey/grey_scout,
					/obj/item/clothing/under/grey/grey_scout,
					/obj/item/clothing/shoes/jackboots/mothership,
					/obj/item/clothing/shoes/jackboots/mothership,
					/obj/item/clothing/head/helmet/mothership_explorer,
					/obj/item/clothing/head/helmet/mothership_explorer)
	cost = 60
	containertype = /obj/structure/closet/secure_closet/ayy
	containername = "GDR explorer armor locker"
	one_access = list(access_security, access_mothership_military)
	group = "Security"
	contraband = 1
	containsdesc = "Surplus equipment from the mothership. Contains two explorer armor kits."

/datum/supply_packs/riot
	name = "Riot gear"
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/clothing/head/helmet/tactical/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/head/helmet/tactical/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/head/helmet/tactical/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/weapon/storage/box/bolas,
					/obj/item/weapon/storage/box/bolas,
					/obj/item/weapon/storage/box/bolas)
	cost = 60
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "riot gear crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "When a riot breaks out, this crate will give you 3 suits perfect for the job, be it being in the riot or outside of it."

/datum/supply_packs/tactical
	name = "Tactical Assault gear"
	contains = list(/obj/item/clothing/suit/armor/plate_carrier,
					/obj/item/clothing/suit/armor/plate_carrier,
					/obj/item/clothing/suit/armor/plate_carrier,
					/obj/item/weapon/armor_plate,
					/obj/item/weapon/armor_plate,
					/obj/item/weapon/armor_plate/bullet_resistant,
					/obj/item/weapon/armor_plate/bullet_resistant,
					/obj/item/weapon/armor_plate/laser_resistant,
					/obj/item/weapon/armor_plate/laser_resistant,
					/obj/item/clothing/head/helmet/visor,
					/obj/item/clothing/head/helmet/visor,
					/obj/item/clothing/head/helmet/visor,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot)
	cost = 120
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "tactical assault gear crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "Tacticool armor carriers, perfect for inserting armored plates into. Comes with three full defensive sets."

/datum/supply_packs/loyalty
	name = "Loyalty implants"
	contains = list (/obj/item/weapon/storage/lockbox/loyalty)
	cost = 60
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "loyalty implant crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "Directly from Central Command, these implants will insure loyalty to NanoTrasen."

/datum/supply_packs/exile
	name = "Exile implants"
	contains = list (/obj/item/weapon/storage/lockbox/exile)
	cost = 150
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "exile implant crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "A lockbox containing exile implants. Prevents their bearers from returning to the station when cast away."

/datum/supply_packs/tracking
	name = "Tracking implants"
	contains = list (/obj/item/weapon/storage/lockbox/tracking)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "tracking implant crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "Cybernetic implants for tracking their owners."

/datum/supply_packs/chem
	name = "Chemical implants"
	contains = list (/obj/item/weapon/storage/lockbox/chem)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "chemical implant crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "Special implants able to hold a chemical and remotely release it on command."

/datum/supply_packs/holy
	name = "Holy implants"
	contains = list (/obj/item/weapon/storage/lockbox/holy)
	cost = 60
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "holy implant crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "Implants containing blessed holy water. Perfect for saying you have the blood of a deity inside of you."

/datum/supply_packs/ballistic
	name = "Combat shotguns"
	contains = list(/obj/item/weapon/gun/projectile/shotgun/pump/combat,
					/obj/item/weapon/gun/projectile/shotgun/pump/combat)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "combat shotgun crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "Now we're talking. Comes with two combat shotguns, pre-loaded."

/datum/supply_packs/shotgunammo
	name = "Shotgun shells"
	contains = list(/obj/item/weapon/storage/box/lethalshells,
					/obj/item/weapon/storage/box/buckshotshells,
					/obj/item/weapon/storage/box/stunshells,
					/obj/item/weapon/storage/box/dartshells)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "shotgun shells crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "A refill of various shotgun shells. Includes standard, buckshot, stun, and darts."

/datum/supply_packs/expenergy
	name = "High-Tech energy weapons"
	contains = list(/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "\improper High-Tech energy weapons crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "Advanced energy guns, capable of being set between stun and kill modes."

/datum/supply_packs/exparmor
	name = "Experimental armor"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/head/helmet/tactical/riot,
					/obj/item/clothing/suit/armor/riot)
	cost = 35
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "experimental armor crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "Three kits of advanced, experimental armor, directly from Central Command. Each are specialized against different forms of attack."

/datum/supply_packs/securitybarriers
	name = "Security checkpoint equipment"
	contains = list(/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/detector)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "security checkpoint crate"
	group = "Security"
	containsdesc = "A deployable security kit, containing four barriers and a detector."

/datum/supply_packs/auto380
	name = "NT Glock pack"
	contains = list(/obj/item/weapon/gun/projectile/glock,
					/obj/item/weapon/gun/projectile/glock,
					/obj/item/voucher/free_item/glockammo,
					/obj/item/voucher/free_item/glockammo)
	cost = 60
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = ".380 pistols crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = "The classic sidearm. Contains two glocks and two vouchers for ammo from your nearest SecTech!"

/datum/supply_packs/auto380/lethals
	name = "NT Glock lethal ammo"
	contains = list(/obj/item/ammo_storage/box/b380auto,
					/obj/item/ammo_storage/magazine/m380auto/empty,
					/obj/item/ammo_storage/magazine/m380auto/empty,
					/obj/item/ammo_storage/magazine/m380auto)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/gear
	containername = ".380 pistol lethal ammo crate"
	access = list(access_armory)
	group = "Security"
	containsdesc = ".380 pistol ammo, perfect for an NT Glock. Contains a box of ammo, one pre-filled magazine, and two spare magazines."

/datum/supply_packs/auto380/practice
	name = "NT Glock practice ammo"
	contains = list(/obj/item/ammo_storage/box/b380auto/practice,
					/obj/item/ammo_storage/magazine/m380auto/practice/empty,
					/obj/item/ammo_storage/magazine/m380auto/practice/empty,
					/obj/item/ammo_storage/magazine/m380auto/practice)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/gear
	containername = ".380 pistol practice ammo crate"
	access = list(access_security)
	group = "Security"
	containsdesc = "Practice ammo kit for learning to shoot your NT Glock."

/datum/supply_packs/auto380/rubber
	name = "NT Glock rubber ammo"
	contains = list(/obj/item/ammo_storage/box/b380auto/rubber,
					/obj/item/ammo_storage/magazine/m380auto/rubber/empty,
					/obj/item/ammo_storage/magazine/m380auto/rubber/empty,
					/obj/item/ammo_storage/magazine/m380auto/rubber)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/gear
	containername = ".380 pistol rubber ammo crate"
	access = list(access_security)
	group = "Security"
	containsdesc = "Rubber ammo kit for any gun that can accept .380 ammo, such as the NT Glock."

/datum/supply_packs/secbiosuits
	name = "Biohazard Emergency Biosuits"
	contains = list(/obj/item/clothing/head/bio_hood/security,
					/obj/item/clothing/head/bio_hood/security,
					/obj/item/clothing/head/bio_hood/security,
					/obj/item/clothing/suit/bio_suit/security,
					/obj/item/clothing/suit/bio_suit/security,
					/obj/item/clothing/suit/bio_suit/security)
	cost = 85
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "Security Biosuits"
	group = "Security"
	containsdesc = "Biosuits for security, for when the disease outbreak gets bad. Contains three suits."
