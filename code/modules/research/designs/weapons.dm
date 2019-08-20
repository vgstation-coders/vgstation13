/datum/design/kinetic_accelerator
	name = "Kinetic Accelerator"
	desc = "A gun that fires projectiles which are deadly in a vacuum. For some reason, this is considered mining equipment."
	id = "kineticaccelerator"
	req_tech = list(Tc_COMBAT = 2, Tc_MATERIALS = 6)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 400, MAT_PLASMA = 4000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/kinetic_accelerator
	locked = TRUE
	req_lock_access = list(access_mining)

/datum/design/nuclear_gun
	name = "Advanced Energy Gun Modkit"
	desc = "Can be used on an energy gun to grant it the ability to recharge itself over time."
	id = "nuclear_gun"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 5, Tc_POWERSTORAGE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000, MAT_URANIUM = 500)
	reliability_base = 76
	category = "Weapons"
	build_path = /obj/item/device/modkit/aeg_parts


/datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "The prize of the Head of Security."
	id = "stunrevolver"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 3, Tc_POWERSTORAGE = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 4000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/stunrevolver
	locked = TRUE
	req_lock_access = list(access_security, access_weapons)

/datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 3, Tc_POWERSTORAGE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 2000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/laser/cannon
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/xcomplasmapistol
	name = "Plasma Pistol"
	desc = "A plasma pistol."
	id = "xcomplasmapistol"
	req_tech = list(Tc_COMBAT = 5, Tc_MATERIALS = 3, Tc_POWERSTORAGE = 3, Tc_PLASMATECH = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_PLASMA = 12000, MAT_URANIUM = 4000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/plasma/pistol
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/xcomplasmarifle
	name = "Plasma Cannon"
	desc = "A plasma cannon."
	id = "xcomplasmarifle"
	req_tech = list(Tc_COMBAT = 5, Tc_MATERIALS = 3, Tc_POWERSTORAGE = 3, Tc_PLASMATECH = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 3000, MAT_PLASMA = 28000, MAT_URANIUM = 12000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/plasma/rifle
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/xcomlightplasmarifle
	name = "Plasma Rifle"
	desc = "A plasma rifle."
	id = "xcomlightplasmarifle"
	req_tech = list(Tc_COMBAT = 5, Tc_MATERIALS = 3, Tc_POWERSTORAGE = 3, Tc_PLASMATECH = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_PLASMA = 20000, MAT_URANIUM = 8000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/plasma/light
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/xcomlaserrifle
	name = "Laser Rifle"
	desc = "A laser rifle."
	id = "xcomlaserrifle"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 3, Tc_POWERSTORAGE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 2000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/laser/rifle
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/xcomlaserpistol
	name = "Laser Pistol"
	desc = "A laser pistol."
	id = "xcomlaserpistol"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 3, Tc_POWERSTORAGE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 1000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/laser/pistol
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/ioncarbine
	name = "Ion Carbine"
	desc = "A stopgap ion weapon designed to disable mechanical threats."
	id = "ioncarbine"
	req_tech = list(Tc_COMBAT = 5, Tc_MATERIALS = 3, Tc_POWERSTORAGE = 3, Tc_MAGNETS = 5)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 1000, MAT_URANIUM = 8000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/ionrifle/ioncarbine
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/xcomar
	name = "Assault Rifle"
	desc = "An Assault Rifle."
	id = "xcomar"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 12500, MAT_GLASS = 12500)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/projectile/automatic/xcom/lockbox
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/ammo_12mm
	name = "Ammunition Box (12mm)"
	desc = "A box of 12mm ammunition."
	id = "ammo_12mm"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 4250, MAT_SILVER = 250)
	category = "Weapons"
	build_path = /obj/item/ammo_storage/box/c12mm/assault

/datum/design/magazine_12mm
	name = "Magazine (12mm)"
	desc = "A magazine that holds 12mm ammunition."
	id = "magazine_12mm"
	req_tech = list(Tc_COMBAT = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 400)
	category = "Weapons"
	build_path = /obj/item/ammo_storage/magazine/a12mm/empty

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 4, Tc_BIOTECH = 5, Tc_POWERSTORAGE = 4, Tc_SYNDICATE = 3) //More reasonable
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GOLD = 5000,MAT_URANIUM = 10000) //, MUTAGEN = 40)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/decloner
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/chemsprayer
	name = "Chem Sprayer"
	desc = "An advanced chem spraying device."
	id = "chemsprayer"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 3, Tc_ENGINEERING = 3, Tc_BIOTECH = 2, Tc_SYNDICATE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000)
	reliability_base = 100
	category = "Weapons"
	build_path = /obj/item/weapon/reagent_containers/spray/chemsprayer
	req_lock_access = list(access_medical, access_cmo)

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 3, Tc_ENGINEERING = 3, Tc_BIOTECH = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe

/datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favoured by syndicate infiltration teams."
	id = "largecrossbow"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 5, Tc_ENGINEERING = 3, Tc_BIOTECH = 4, Tc_SYNDICATE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000, MAT_URANIUM = 1000, MAT_SILVER = 1000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/crossbow/largecrossbow
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that changes the body temperature of its targets."
	id = "temp_gun"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 4, Tc_POWERSTORAGE = 3, Tc_MAGNETS = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 500, MAT_SILVER = 3000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/temperature
	locked = TRUE
	req_lock_access = list(access_rnd, access_robotics, access_rd)

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3000)
	reliability_base = 79
	category = "Weapons"
	build_path = /obj/item/weapon/grenade/chem_grenade/large

/datum/design/ex_grenade
	name = "EX Grenade"
	desc = "A large grenade that is designed to hold three containers."
	id = "ex_Grenade"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 2, Tc_ENGINEERING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3000)
	reliability_base = 79
	category = "Weapons"
	build_path = /obj/item/weapon/grenade/chem_grenade/exgrenade

/datum/design/smg
	name = "Submachine Gun"
	desc = "A lightweight, fast firing gun."
	id = "smg"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 10000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/projectile/automatic/lockbox
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/ammo_9mm
	name = "Ammunition Box (9mm)"
	desc = "A box of prototype 9mm ammunition."
	id = "ammo_9mm"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3750, MAT_SILVER = 100)
	category = "Weapons"
	build_path = /obj/item/ammo_storage/box/c9mm

/datum/design/magazine_9mm
	name = "Magazine (9mm SMG)"
	desc = "A SMG magazine that holds 9mm ammunition."
	id = "magazine_9mm"
	req_tech = list(Tc_COMBAT = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 300)
	category = "Weapons"
	build_path = /obj/item/ammo_storage/magazine/smg9mm/empty

/datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell for a shotgun."
	id = "stunshell"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 4000)
	category = "Weapons"
	build_path = /obj/item/ammo_casing/shotgun/stunshell

/datum/design/pneumatic
	name = "Pneumatic Cannon"
	desc = "A launcher powered by compressed air."
	id = "pneumatic"
	req_tech = list(Tc_MATERIALS = 3, Tc_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 12000)
	category = "Weapons"
	build_path = /obj/item/weapon/storage/pneumatic

//Ammolathe designs. They lack research values so they can't be researched.
//Weapons

/datum/design/glock
	name = "NT Glock"
	desc = "A NT Glock. It uses .380AUTO rounds."
	id = "glock"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 10000)
	build_path = /obj/item/weapon/gun/projectile/glock/lockbox
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/vector
	name = "Vector"
	desc = "A lightweight and compact gun, it has a detachable receiver that contains a recoil mitigation system."
	id = "vector"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 12500, MAT_GLASS = 12500)
	build_path = /obj/item/weapon/gun/projectile/automatic/vector/lockbox
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

/datum/design/rocketlauncher
	name = "rocket launcher"
	desc = "Watch the backblast, you idiot."
	id = "RPG"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 50000, MAT_GLASS = 50000, MAT_GOLD = 6000)
	build_path = /obj/item/weapon/gun/projectile/rocketlauncher/nanotrasen/lockbox
	locked = TRUE
	req_lock_access = list(access_armory, access_weapons)

//Single ammunition

/datum/design/rocket_rpg/lowyield
	name = "low yield rocket"
	desc = "Explosive supplement to Nanotrasen's rocket launchers."
	id = "lowyield_rocket"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 20000)
	build_path = /obj/item/ammo_casing/rocket_rpg/lowyield

/datum/design/rocket_rpg/blank
	name = "blank rocket"
	desc = "This rocket left intentionally blank."
	id = "blank_rocket"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 100)
	build_path = /obj/item/ammo_casing/rocket_rpg/blank

/datum/design/rocket_rpg/emp
	name = "EMP rocket"
	desc = "EMP rocket for the Nanotrasen rocket launcher"
	id = "emp_rocket"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 20000, MAT_URANIUM = 500)
	build_path = /obj/item/ammo_casing/rocket_rpg/emp

/datum/design/rocket_rpg/stun
	name = "stun rocket"
	desc = "Stun rocket for the Nanotrasen rocket launcher. Not a flashbang."
	id = "emp_rocket"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 20000, MAT_SILVER = 1000)
	build_path = /obj/item/ammo_casing/rocket_rpg/stun

//Box ammunition
/datum/design/ammo_b380auto
	name = "Ammunition Box (.380AUTO)"
	desc = "A box of .380AUTO bullets."
	id = "ammo_380auto"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 3750, MAT_SILVER = 100)
	build_path = /obj/item/ammo_storage/box/b380auto

/datum/design/ammo_b380auto/practice
	name = "Ammunition Box (.380AUTO practice)"
	desc = "A box of .380AUTO practice bullets."
	id = "ammo_380auto_P"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 3750, MAT_SILVER = 100)
	build_path = /obj/item/ammo_storage/box/b380auto/practice

/datum/design/ammo_b380auto/rubber
	name = "Ammunition Box (.380AUTO rubber)"
	desc = "A box of .380AUTO rubber bullets."
	id = "ammo_380auto_R"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 3750, MAT_SILVER = 100)
	build_path = /obj/item/ammo_storage/box/b380auto/rubber

//Magazines
//Normal 9mm and 12mm already have a designs above.
/datum/design/magazine_9mm_beretta
	name = "Magazine (9mm beretta)"
	desc = "A magazine designed for the Beretta 92FS."
	id = "magazine_9mm_beretta"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 400)
	build_path = /obj/item/ammo_storage/magazine/beretta/empty

/datum/design/magazine_357
	name = "Automag magazine (.357)"
	desc = "A magazine designed for the Automag VI handcannon."
	id = "magazine_357"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 400)
	build_path = /obj/item/ammo_storage/magazine/a357/empty

/datum/design/magazine_380
	name = "Pistol magazine (.380AUTO)"
	desc = "A magazine designed for common .380AUTO pistols."
	id = "magazine_380"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 400)
	build_path = /obj/item/ammo_storage/magazine/m380auto/empty

/datum/design/magazine_380_extended
	name = "Extended magazine (.380AUTO)"
	desc = "A magazine designed for .380AUTO vectors."
	id = "magazine_380_e"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 800)
	build_path = /obj/item/ammo_storage/magazine/m380auto/extended/empty

/datum/design/magazine_c45
	name = "Pistol magazine (.45)"
	desc = "A magazine designed for common .45 pistols."
	id = "magazine_45"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 400)
	build_path = /obj/item/ammo_storage/magazine/c45/empty

/datum/design/magazine_45_uzi
	name = "Magazine (.45 uzi)"
	desc = "A magazine designed for .45 uzis."
	id = "magazine_45_uzi"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 400)
	build_path = /obj/item/ammo_storage/magazine/uzi45/empty

/datum/design/magazine_50
	name = "Magazine (.50)"
	desc = "A magazine designed for .50."
	id = "magazine_50"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 400)
	build_path = /obj/item/ammo_storage/magazine/a50/empty

/datum/design/magazine_75
	name = "Magazine (.75)"
	desc = "A magazine designed for .75."
	id = "magazine_75"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 400)
	build_path = /obj/item/ammo_storage/magazine/a75/empty

/datum/design/magazine_a762
	name = "Magazine (a762)"
	desc = "A magazine designed for a762."
	id = "magazine_a762"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 400)
	build_path = /obj/item/ammo_storage/magazine/a762/empty

/datum/design/magazine_12ga
	name = "Magazine (12ga)"
	desc = "A box magazine designed for the NT-12."
	id = "magazine_12ga"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 400)
	build_path = /obj/item/ammo_storage/magazine/a12ga/empty

//Misc
/datum/design/vectorreceiver
	name = "Vector Receiver"
	desc = "A receiver for a Vector pre-set to .380."
	id = "vectorreceiver"
	build_type = AMMOLATHE
	materials = list(MAT_IRON = 12500, MAT_GLASS = 12500)
	build_path = /obj/item/weapon/vectorreceiver

//Hidden
