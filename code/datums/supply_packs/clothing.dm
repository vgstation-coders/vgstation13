//////CLOTHING//////

/datum/supply_packs/costume
	name = "Standard costumes"
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
					/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing,
					/obj/item/weapon/hair_dye)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "standard costumes crate"
	access = list(access_theatre)
	group = "Clothing"
	containsdesc = "A set of replacement clown and mime costumes, for when the originals mysteriously wind up lost in space alongside the person inside them. Includes a bottle of Nothing extra."

/datum/supply_packs/spookycostume
	name = "Halloween costumes"
	contains = list(
					/obj/item/weapon/facepaint_spray,

					/obj/item/clothing/suit/space/plasmaman/moltar,
					/obj/item/clothing/head/helmet/space/plasmaman/moltar,
					/obj/item/clothing/head/snake,
					/obj/item/clothing/head/franken_bolt,
					/obj/item/clothing/head/alien_antenna,
					/obj/item/clothing/suit/bedsheet_ghost,

					//Slasher set
					/obj/item/toy/chainsaw,
					/obj/item/clothing/mask/gas/slasher,

					//Skeleton "set"
					/obj/item/clothing/under/skelesuit,
					/obj/item/clothing/under/skelesuit,

					//Reaper set
					/obj/item/clothing/mask/gas/grim_reaper,
					/obj/item/clothing/suit/reaper_robes,
					/obj/item/toy/scythe,

					//Vampire set
					/obj/item/clothing/suit/storage/draculacoat_fake,
					/obj/item/clothing/mask/vamp_fangs,

					//Devil set
					/obj/item/clothing/head/devil_horns,
					/obj/item/toy/pitchfork,
					/obj/item/clothing/under/color/red,
					/obj/item/weapon/bedsheet/red
					)
	cost = 31
	containertype = /obj/structure/closet/crate/basic
	containername = "halloween costumes crate"
	group = "Clothing"
	containsdesc = "A spooky set of costumes, just in time for Halloween! Contains many a disguise, assemble your own unique monstrous guise!"

/datum/supply_packs/wizard
	name = "Wizard costume"
	contains = list(/obj/item/weapon/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	cost = 20
	containertype = /obj/structure/closet/crate/basic
	containername = "wizard costume crate"
	group = "Clothing"
	containsdesc = "A knock-off wizard outfit, not sanctioned by the Wizard Federation."

/datum/supply_packs/mann_co_key
	name = "Mann Co. key"
	cost = 200
	containertype = /obj/structure/closet/crate/basic
	contains = list(/obj/item/mann_co_key)
	containername = "crate"
	group = "Clothing"
	containsicon = "mannco_crate"
	require_holiday = APRIL_FOOLS_DAY
	containsdesc = "This crate contains a key for a crate."

/datum/supply_packs/mann_co_crate
	name = "Mann Co. crate"
	cost = 200
	containertype = /obj/structure/mann_co_crate
	contains = list()
	containername = "crate"
	group = "Clothing"
	require_holiday = APRIL_FOOLS_DAY
	containsicon = "mannco_key"
	containsdesc = "This crate contains a crate for a key."

/datum/supply_packs/randomised/cheap_hats
	name = "Cheap hats"
	cost = 50
	containername = "dusty crate"
	num_contained = 5
	contains = list(\
	/obj/item/clothing/head/bandana,
	/obj/item/clothing/head/bearpelt,
	/obj/item/clothing/head/beaverhat,
	/obj/item/clothing/head/beret,
	/obj/item/clothing/head/boaterhat,
	/obj/item/clothing/head/bowlerhat,
	/obj/item/clothing/head/chefhat,
	/obj/item/clothing/head/cowboy,
	/obj/item/clothing/head/dunce_cap,
	/obj/item/clothing/head/fedora,
	/obj/item/clothing/head/fedora/brown,
	/obj/item/clothing/head/fedora/white,
	/obj/item/clothing/head/fez,
	/obj/item/clothing/head/flatcap,
	/obj/item/clothing/head/greenbandana,
	/obj/item/clothing/head/headband,
	/obj/item/clothing/head/libertyhat,
	/obj/item/clothing/head/mailman,
	/obj/item/clothing/head/naziofficer,
	/obj/item/clothing/head/panzer,
	/obj/item/clothing/head/powdered_wig,
	/obj/item/clothing/head/soft/mime,
	/obj/item/clothing/head/squatter_hat,
	/obj/item/clothing/head/that,
	/obj/item/clothing/head/ushanka,
	/obj/item/clothing/head/wizard/magus/fake,
	/obj/item/clothing/head/wizard/clown/fake,
	)
	containsdesc = "A random assortment of assorted hats from the Surplus Hat Company™. Always contains exactly three random hats."

/datum/supply_packs/randomised/cheap_glasses
	name = "Cheap glasses"
	cost = 50
	containername = "dusty crate"
	num_contained = 5
	contains = list(\
	/obj/item/clothing/glasses/eyepatch,
	/obj/item/clothing/glasses/gglasses,
	/obj/item/clothing/glasses/kaminaglasses,
	/obj/item/clothing/glasses/monocle,
	/obj/item/clothing/glasses/regular,
	/obj/item/clothing/glasses/regular/hipster,
	/obj/item/clothing/glasses/scanner/science,
	/obj/item/clothing/glasses/simonglasses,
	/obj/item/clothing/glasses/sunglasses,
	/obj/item/clothing/glasses/sunglasses/big,
	/obj/item/clothing/glasses/sunglasses/blindfold,
	/obj/item/clothing/glasses/sunglasses/prescription,
	/obj/item/clothing/glasses/sunglasses/purple,
	/obj/item/clothing/glasses/sunglasses/rockstar,
	/obj/item/clothing/glasses/sunglasses/star,
	/obj/item/clothing/glasses/sunglasses/red,
	/obj/item/clothing/glasses/sunglasses/security,
	)
	containsdesc = "A random assortment of assorted glasses of various prescription strengths. You're bound to find one that works, there's five in a box."

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
	containertype = /obj/structure/closet/basic
	containername = "formalwear crate"
	group = "Clothing"
	containsdesc = "A few choice selections of formal attire. Contains four suits, two jackets, two shoes, a waistcoat, and a top hat."

/datum/supply_packs/formal_wear/armored
	contains = list(/obj/item/clothing/head/that/armored,
					/obj/item/clothing/head/that/armored,
					/obj/item/clothing/under/sl_suit/armored,
					/obj/item/clothing/under/sl_suit/armored)
	name = "Armored formalwear closet"
	cost = 100
	containertype = /obj/structure/closet/basic
	containername = "armored formalwear crate"
	contraband = 1
	group = "Clothing"
	containsdesc = "Contains two sets of reinforced formal attire. Keep stylish even under threat of gunfire."

/datum/supply_packs/janny_gear
	contains = list(/obj/item/clothing/suit/apron/overalls,
					/obj/item/clothing/gloves/black,
					/obj/item/weapon/storage/belt/janitor,
					/obj/item/clothing/shoes/galoshes)
	name = "Custodial gear"
	cost = 100
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "custodial gear crate"
	access = list(access_janitor)
	group = "Clothing"
	containsdesc = "Replacement janitor PPE. Includes overalls, a belt, gloves, and galoshes."

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
	containertype = /obj/structure/closet/crate/basic
	containername = "feminine formalwear crate"
	group = "Clothing"
	containsdesc = "Contains a massive collection of dresses and some lipstick to match."

/datum/supply_packs/knight //why seperate them
	name = "Knight armors"
	contains = list(/obj/item/clothing/suit/armor/knight,
					/obj/item/clothing/suit/armor/knight/red,
					/obj/item/clothing/suit/armor/knight/yellow,
					/obj/item/clothing/suit/armor/knight/blue,
					/obj/item/clothing/head/helmet/knight,
					/obj/item/clothing/head/helmet/knight/red,
					/obj/item/clothing/head/helmet/knight/yellow,
					/obj/item/clothing/head/helmet/knight/blue)
	cost = 35
	containertype = /obj/structure/closet/crate/basic
	containername = "knight armor crate"
	group = "Clothing"
	containsdesc = "Contains four sets of knightly armor - one of every color!"

/datum/supply_packs/space_suits
	name = "Space suit"
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/weapon/tank/oxygen,
					/obj/item/weapon/tank/emergency_oxygen/engi,
					/obj/item/clothing/mask/breath)
	cost = 150
	containertype = /obj/structure/closet/crate/basic
	containername = "space suit crate"
	group = "Clothing"
	containsicon = "space_suit"
	containsdesc = "Contains an entire space-worthy softsuit. Includes a small oxygen tank!"

/datum/supply_packs/vox_suit
	name = "Vox pressure suit set"
	contains = list(/obj/item/clothing/suit/space/vox/civ,
					/obj/item/clothing/head/helmet/space/vox/civ,
					/obj/item/weapon/tank/nitrogen,
					/obj/item/weapon/tank/emergency_nitrogen/engi,
					/obj/item/clothing/mask/breath/vox)
	cost = 100
	containertype = /obj/structure/closet/crate/basic
	containername = "vox suit crate"
	group = "Clothing"
	containsicon = "vox_suit"
	containsdesc = "A full vox pressure suit crate, containing a standard assistant pressure suit. Includes a full nitrogen internals kit."

/datum/supply_packs/plasmaman_suit
	name = "Plasmaman pressure suit set"
	contains = list(/obj/item/clothing/suit/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/weapon/tank/plasma/plasmaman,
					/obj/item/weapon/tank/emergency_plasma/engi,
					/obj/item/clothing/mask/breath)
	cost = 100
	containertype = /obj/structure/closet/crate/basic
	containername = "plasmaman suit crate"
	group = "Clothing"
	containsicon = "plasmaman_suit"
	containsdesc = "A full plasmaman suit, with a bonus plasma internals kit to go with it."

/datum/supply_packs/grey_supply
	name = "Grey Space-Ex"
	contains = list(/obj/item/clothing/suit/space/grey,
					/obj/item/clothing/head/helmet/space/grey,
					/obj/item/weapon/tank/oxygen/red,
					/obj/item/clothing/mask/gas/mothership)
	cost = 175
	containertype = /obj/structure/closet/crate/ayy
	containername = "grey Space-Ex crate"
	group = "Clothing"
	containsdesc = "Contains a space-worthy softsuit that is perfectly fitted for a grey. Includes a fancy red oxygen tank!"

/datum/supply_packs/grey_uniform
	name = "Mothership uniforms"
	var/laborer = list(/obj/item/clothing/under/grey/grey_worker,
					/obj/item/clothing/under/grey/grey_worker,
					/obj/item/clothing/shoes/jackboots/mothership,
					/obj/item/clothing/shoes/jackboots/mothership)
	var/scientist = list(/obj/item/clothing/under/grey/grey_researcher,
					/obj/item/clothing/under/grey/grey_researcher,
					/obj/item/clothing/suit/storage/labcoat/mothership,
					/obj/item/clothing/suit/storage/labcoat/mothership,
					/obj/item/clothing/shoes/jackboots/mothership,
					/obj/item/clothing/shoes/jackboots/mothership)
	cost = 50
	containertype = /obj/structure/closet/ayy
	containername = "mothership uniform locker"
	containsicon = "grey_uniform"
	containsdesc = "A batch of clothing from the grey mothership. Comes with either two outfits for workers, or two outfits for researchers. Whatever they had extra."
	group = "Clothing"

/datum/supply_packs/grey_uniform/New()
	..()
	selection_from = list(laborer, scientist)

/datum/supply_packs/grey_internals
	name = "GDR half-masks"
	contains = list(/obj/item/clothing/mask/gas/mothership,
					/obj/item/clothing/mask/gas/mothership,
					/obj/item/clothing/mask/gas/mothership,
					/obj/item/weapon/tank/emergency_oxygen/engi,
					/obj/item/weapon/tank/emergency_oxygen/engi,
					/obj/item/weapon/tank/emergency_oxygen/engi)
	cost = 40
	containertype = /obj/structure/closet/crate/ayy3
	containername = "GDR half-mask crate"
	contraband = 1
	group = "Clothing"
	containsdesc = "Three respirator mask units from the nearest mothership outpost."

/datum/supply_packs/neorussian
	name = "Neo-Russian supplies"
	contains = list(/obj/item/clothing/suit/armor/vest/neorussian,
					/obj/item/clothing/mask/neorussian,
					/obj/item/clothing/head/helmet/neorussian,
					/obj/item/clothing/accessory/storage/neorussian,
					/obj/item/clothing/gloves/neorussian,
					/obj/item/clothing/gloves/neorussian/fingerless,
					/obj/item/clothing/under/neorussian,
					/obj/item/clothing/shoes/jackboots/neorussian)
	cost = 225
	containertype = /obj/structure/closet/crate/basic
	containername = "neo-Russian crate"
	group = "Clothing"
	contraband = 1
	containsdesc = "In the vast expanse of the cosmos, lies the nation of Иeo-Яussia. Founded by intᴙepid Soviet cosmonauts who daᴙed to jouᴙney beyond the confines of ouᴙ blue planet, they discoveᴙed an untouched celestial body and claimed it in the name of the Motheᴙland. These pioneeᴙs, fueled by the spiᴙit of expЮᴙation, vodka, and communist ideals, quickly established a thᴙiving coЮny that echoed the gᴙandeuᴙ of the old-woᴙld USSЯ. Иeo-Яussia, as it came to be known, was a blend of old-woᴙld tᴙadition and cutting-edge spacefaᴙing technoЮgy that now ᴙivals Эaᴙth."

/datum/supply_packs/russianclothing
	name = "Russian clothing"
	contains = list(/obj/item/clothing/head/squatter_hat,
					/obj/item/clothing/under/squatter_outfit,
					/obj/item/clothing/head/russobluecamohat,
					/obj/item/clothing/under/russobluecamooutfit,
					/obj/item/clothing/head/russofurhat,
					/obj/item/clothing/suit/russofurcoat,
					/obj/item/weapon/disk/shuttle_coords/disk_jockey)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "russian clothing crate"
	group = "Clothing"
	contraband = 1
	containsdesc = "In Soviet Russia, clothes wear you! Comes with the location of an underground propaganda radio station."

/datum/supply_packs/contacts
	name = "Contact lenses"
	contains = list(/obj/item/clothing/glasses/contacts,
					/obj/item/clothing/glasses/contacts,
					/obj/item/clothing/glasses/contacts,
					/obj/item/clothing/glasses/contacts,
					/obj/item/weapon/nanitecontacts,
					/obj/item/weapon/nanitecontacts)
	cost = 150
	containertype = /obj/structure/closet/crate/basic
	containername = "contacts crate"
	group = "Clothing"
	containsdesc = "Multiple packs of contact lenses, including two sets of nanite contacts."

/datum/supply_packs/security_formal_wear
	var/Blue = list(/obj/item/clothing/suit/secdressjacket/hos_blue,
					/obj/item/clothing/suit/secdressjacket/warden_blue,
					/obj/item/clothing/suit/secdressjacket/officer_blue,
					/obj/item/clothing/under/rank/secformal/headofsecurity_blue,
					/obj/item/clothing/under/rank/secformal/warden_blue,
					/obj/item/clothing/under/rank/secformal/officer_blue)
	var/Navy = list(/obj/item/clothing/suit/secdressjacket/hos_navy,
					/obj/item/clothing/suit/secdressjacket/warden_navy,
					/obj/item/clothing/suit/secdressjacket/officer_navy,
					/obj/item/clothing/under/rank/secformal/headofsecurity_navy,
					/obj/item/clothing/under/rank/secformal/warden_navy,
					/obj/item/clothing/under/rank/secformal/officer_navy)
	var/Tan = list(/obj/item/clothing/suit/secdressjacket/hos_tan,
					/obj/item/clothing/suit/secdressjacket/warden_tan,
					/obj/item/clothing/suit/secdressjacket/officer_tan,
					/obj/item/clothing/under/rank/secformal/headofsecurity_tan,
					/obj/item/clothing/under/rank/secformal/warden_tan,
					/obj/item/clothing/under/rank/secformal/officer_tan)
	contains = list(/obj/item/clothing/head/beret/headofsecurity,
					/obj/item/clothing/head/beret/warden,
					/obj/item/clothing/head/beret/officer,
					/obj/item/clothing/shoes/secshoes,
					/obj/item/clothing/shoes/secshoes,
					/obj/item/clothing/shoes/secshoes)
	name = "Security Formalwear Closet"
	cost = 30
	containertype = /obj/structure/closet/secure_closet/security/empty
	containername = "Security Formalwear"
	containsicon = "security_formal_wear"
	containsdesc = "Formalwear for the security team, ordered directly from Central Command. Includes one suit for the Head of Security, one for the Warden, and one for a Security Officer of any rank."
	access = list(access_security)
	group = "Clothing"

/datum/supply_packs/security_formal_wear/New()
	..()
	selection_from = list(Blue, Navy, Tan)

//Winter Coats//

/datum/supply_packs/engwinter
	name = "Engineering Winterwear"
	contains = list(/obj/item/clothing/suit/storage/wintercoat/engineering,
					/obj/item/clothing/suit/storage/wintercoat/engineering,
					/obj/item/clothing/suit/storage/wintercoat/engineering/atmos,
					/obj/item/clothing/suit/storage/wintercoat/engineering/mechanic,
					/obj/item/clothing/suit/storage/wintercoat/engineering/ce)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "engineering winter coats"
	group = "Clothing"
	containsdesc = "For when you let the frozen core out. Contains winter coats for two engineers, one atmos technician, one mechanic, and one Chief Engineer."

/datum/supply_packs/sciwinter
	name = "Science Winterwear"
	contains = list(/obj/item/clothing/suit/storage/wintercoat/medical/science,
					/obj/item/clothing/suit/storage/wintercoat/medical/science,
					/obj/item/clothing/suit/storage/wintercoat/medical/science,
					/obj/item/clothing/suit/storage/wintercoat/medical/science
					/* RD */)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "science winter coats"
	group = "Clothing"
	containsdesc = "It's a cold day for these scientists. Contains four winter coats for science."

/datum/supply_packs/secwinter
	name = "Security Winterwear"
	contains = list(/obj/item/clothing/suit/storage/wintercoat/security,
					/obj/item/clothing/suit/storage/wintercoat/security,
					/obj/item/clothing/head/ushanka/security,
					/obj/item/clothing/head/ushanka/security,
					/obj/item/clothing/suit/storage/wintercoat/security/warden,
					/obj/item/clothing/suit/storage/wintercoat/security/hos)
	cost = 150
	containertype = /obj/structure/closet/crate/secure/basic
	containername = "security winter coats"
	access = list(access_security)
	group = "Clothing"
	containsdesc = "Job's never over, not even when it's snowing in the space station. Contains a coat for the Head of Security, Warden, and two security officers."

/datum/supply_packs/medwinter
	name = "Medical Winterwear"
	contains = list(/obj/item/clothing/suit/storage/wintercoat/medical,
					/obj/item/clothing/suit/storage/wintercoat/medical,
					/obj/item/clothing/suit/storage/wintercoat/medical,
					/obj/item/clothing/suit/storage/wintercoat/medical/paramedic,
					/obj/item/clothing/suit/storage/wintercoat/medical/paramedic,
					/obj/item/clothing/suit/storage/wintercoat/medical/cmo)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "medical winter coats"
	group = "Clothing"
	containsdesc = "For when the cryo tubes start leaking. Contains winter coats for three doctors, two paramedics, and the Chief Medical Officer."

/datum/supply_packs/svcwinter
	name = "Service Winterwear"
	contains = list(/obj/item/clothing/suit/storage/wintercoat/hydro,
					/obj/item/clothing/suit/storage/wintercoat/hydro,
					/obj/item/clothing/suit/storage/wintercoat/bartender,
					/obj/item/clothing/suit/storage/wintercoat/bartender
					/* chef */)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "service winter coats"
	group = "Clothing"
	containsdesc = "Supplies for the essential workers when, despite everything being snowed in, people still want to shop. Contains enough winter coats for two hydroponics workers and two bartenders."

/datum/supply_packs/civwinter
	name = "Civilian Winterwear"
	contains = list(/obj/item/clothing/suit/storage/wintercoat/prisoner,
					/obj/item/clothing/suit/storage/wintercoat/janitor,
					/obj/item/clothing/suit/storage/wintercoat,
					/obj/item/clothing/suit/storage/wintercoat,
					/obj/item/clothing/suit/storage/wintercoat,
					/obj/item/clothing/suit/storage/wintercoat)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "civilian winter coats"
	group = "Clothing"
	containsdesc = "Generic winter coats for the assistant who doesn't feel like selecting a color. Contains four normal coats, one coat for the janitor, and one for a prisoner."

/datum/supply_packs/crgwinter
	name = "Cargo Winterwear"
	contains = list(/obj/item/clothing/suit/storage/wintercoat/cargo,
					/obj/item/clothing/suit/storage/wintercoat/cargo,
					/obj/item/clothing/suit/storage/wintercoat/cargo,
					/obj/item/clothing/suit/storage/wintercoat/miner,
					/obj/item/clothing/suit/storage/wintercoat/miner,
					/obj/item/clothing/suit/storage/wintercoat/miner)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "cargo winter coats"
	group = "Clothing"
	containsdesc = "For when you're on a snow planet and someone's shot open your window. Again. Coats for three cargo men and three miners."

/datum/supply_packs/mscwinter
	name = "Misc. Winterwear"
	contains = list(/obj/item/clothing/suit/storage/wintercoat/security/captain,
					/obj/item/clothing/suit/storage/wintercoat/hop,
					/obj/item/clothing/suit/storage/wintercoat/clown,
					/obj/item/clothing/suit/storage/wintercoat/prisoner,
					/obj/item/clothing/suit/storage/wintercoat/mime)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "miscellaneous winter coats"
	group = "Clothing"
	containsdesc = "Coats that just don't fit in with the others. Includes one for a Captain, Head of Personnel, Clown, Mime, and even a prisoner."

/datum/supply_packs/knittingbundle
	name = "Knitting bundle"
	contains = list(/obj/item/knitting_needles,
					/obj/item/stack/sheet/cloth/bigstack,
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper Knitting bundle"
	group = "Clothing"
	containsicon = "knitting"
	containsdesc = "Some knitting needles and a roll of cloth to get you started on your clothesmaking journey."
