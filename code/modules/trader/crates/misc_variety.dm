/***************
**  Contains:
**  Wonderful Wardrobe
**  Library of Babel
**  Random: circuits, drinks, snacks, materials, odd materials
***************/


/obj/structure/closet/secure_closet/wonderful
	name = "wonderful wardrobe"
	desc = "Stolen from Space Narnia."
	req_access = list(access_trade)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"
	is_wooden = TRUE
	starting_materials = list(MAT_WOOD = 2*CC_PER_SHEET_WOOD)
	w_type = RECYK_WOOD
	autoignition_temperature = AUTOIGNITION_WOOD
	var/wonder_whitelist = list(
	/obj/item/clothing/mask/morphing/corgi,
	/obj/item/clothing/under/rank/vice,
	list(/obj/item/clothing/suit/space/clown, /obj/item/clothing/head/helmet/space/clown),
	/obj/item/clothing/shoes/magboots/magnificent,
	list(/obj/item/clothing/suit/space/plasmaman/bee, /obj/item/clothing/head/helmet/space/plasmaman/bee, /obj/item/clothing/suit/space/plasmaman/cultist, /obj/item/clothing/head/helmet/space/plasmaman/cultist, /obj/item/clothing/head/helmet/space/plasmaman/security/captain, /obj/item/clothing/suit/space/plasmaman/security/captain, /obj/item/clothing/head/helmet/space/plasmaman/security/hos, /obj/item/clothing/suit/space/plasmaman/security/hos, /obj/item/clothing/head/helmet/space/plasmaman/security/hop, /obj/item/clothing/suit/space/plasmaman/security/hop),
	list(/obj/item/clothing/head/wizard/lich, /obj/item/clothing/suit/wizrobe/lich, /obj/item/clothing/suit/wizrobe/skelelich),
	/obj/item/clothing/under/skelesuit,
	list(/obj/item/clothing/suit/storage/wintercoat/engineering/ce, /obj/item/clothing/suit/storage/wintercoat/medical/cmo, /obj/item/clothing/suit/storage/wintercoat/security/hos, /obj/item/clothing/suit/storage/wintercoat/hop, /obj/item/clothing/suit/storage/wintercoat/security/captain, /obj/item/clothing/suit/storage/wintercoat/clown, /obj/item/clothing/suit/storage/wintercoat/slimecoat),
	list(/obj/item/clothing/suit/space/rig/wizard, /obj/item/clothing/gloves/purple/wizard, /obj/item/clothing/shoes/sandal),
	list(/obj/item/clothing/suit/space/ancient, /obj/item/clothing/head/helmet/space/ancient),
	list(/obj/item/clothing/shoes/clockwork_boots, /obj/item/clothing/suit/clockwork_robes),
	/obj/item/clothing/mask/necklace/xeno_claw,
	/obj/item/clothing/under/newclothes,
	/obj/item/clothing/suit/storage/draculacoat,
	list(/obj/item/clothing/head/helmet/richard, /obj/item/clothing/under/jacketsuit),
	list(/obj/item/clothing/under/rank/security/sneaksuit, /obj/item/clothing/head/headband),
	/obj/item/clothing/under/galo,
	/obj/item/clothing/suit/raincoat,
	list(/obj/item/clothing/accessory/armband, /obj/item/clothing/accessory/armband/cargo, /obj/item/clothing/accessory/armband/engine, /obj/item/clothing/accessory/armband/science, /obj/item/clothing/accessory/armband/hydro, /obj/item/clothing/accessory/armband/medgreen),
	list(/obj/item/clothing/head/helmet/space/grey, /obj/item/clothing/suit/space/grey),
	list(/obj/item/clothing/under/bikersuit, /obj/item/clothing/gloves/bikergloves, /obj/item/clothing/head/helmet/biker, /obj/item/clothing/shoes/mime/biker),
	list(/obj/item/clothing/monkeyclothes/space, /obj/item/clothing/head/helmet/space),
	/obj/item/device/radio/headset/headset_earmuffs,
	/obj/item/clothing/under/vault13,
	list(/obj/item/clothing/head/leather/xeno, /obj/item/clothing/suit/leather/xeno),
	/obj/item/clothing/accessory/rabbit_foot,
	/obj/item/clothing/accessory/wristwatch/black
	)

/obj/structure/closet/secure_closet/wonderful/spawn_contents()
	..()
	new /obj/item/clothing/shoes/clown_shoes/advanced(src)
	for(var/amount = 1 to 10)
		var/wonder_clothing = pick_n_take(wonder_whitelist)
		if(islist(wonder_clothing))
			for(var/i in wonder_clothing)
				new i(src)
		else
			new wonder_clothing(src)

//Mystery mob cubes//////////////

/obj/item/weapon/storage/box/mysterycubes
	name = "mystery cube box"
	desc = "Dehydrated friends!"
	icon = 'icons/obj/pbag.dmi'
	icon_state = "pbag"	//Supposed to look kind of shitty, cubes aren't even wrapped
	foldable = /obj/item/weapon/paper
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube/mysterycube")
	autoignition_temperature = AUTOIGNITION_PAPER

/obj/item/weapon/storage/box/mysterycubes/New()
	..()
	var/friendAmount = 1
	friendAmount = rand(1, 3)
	for(var/i = 1 to friendAmount)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/mysterycube(src)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/mysterycube
	name = "mystery cube"
	desc = "A portable friend!"
	var/static/list/potentialFriends = list()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/mysterycube/New()
	..()
	if(!length(potentialFriends))
		potentialFriends = existing_typesof(/mob/living/simple_animal) - (boss_mobs + blacklisted_mobs)
	contained_mob = pick(potentialFriends)


//Mystery chem beakers//////////////

/obj/item/weapon/storage/box/mystery_vial
	name = "assorted chemical pack"
	desc = "A mix of reagents from who knows where."
	icon_state = "beaker"

/obj/item/weapon/storage/box/mystery_vial/New()
	..()
	for(var/i = 1 to 5)
		new /obj/item/weapon/reagent_containers/glass/beaker/vial/mystery(src)

/obj/item/weapon/reagent_containers/glass/beaker/vial/mystery
	name = "recycled vial"
	desc = "Slightly scratched and worn, it looks like this wasn't its original purpose. The label has been sloppily peeled off."
	mech_flags = MECH_SCAN_FAIL	//Nip that in the bud
	var/static/list/illegalChems = list(	//Just a bad idea
		ADMINORDRAZINE,
		PROCIZINE,
		BLOCKIZINE,
		AUTISTNANITES,
		XENOMICROBES,
		PAISMOKE
	)

/obj/item/weapon/reagent_containers/glass/beaker/vial/mystery/New()
	..()
	var/list/mysteryChems = chemical_reagents_list - illegalChems
	reagents.add_reagent(pick(mysteryChems), volume)


//Mystery circuits////////////

/obj/item/weapon/storage/box/mystery_circuit
	name = "children's circuitry circus educational toy booster pack"
	desc = "Ages 6 and up!"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "circuit"

/obj/item/weapon/storage/box/mystery_circuit/New()
	..()
	var/list/legalCircuits = existing_typesof(/obj/item/weapon/circuitboard) - /obj/item/weapon/circuitboard/card/centcom	//Identical to spessmart spawner
	for(var/i = 1 to 3)
		var/boosterPack = pick(legalCircuits)
		new boosterPack(src)
	new /obj/item/tool/solder(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/sulphuric(src)
	new /obj/item/weapon/paper/permissionslip(src)

/obj/item/weapon/paper/permissionslip
	name = "circuitry circus education toy booster pack legally binding permission slip"
	desc = "Very clearly hand written."

/obj/item/weapon/paper/permissionslip/New()
	..()
	info = "The purchaser or purchasers of this or any other Circuitry Circus Education Toy Booster Pack <i>TM</i> recognizes, accepts, and is bound to the terms and conditions found within any Circuitry Circus Education Toy Starter Pack <i>TM</i>. This includes but is not limited to: <BR>the relinquishment of any state, country, nation, or planetary given rights protecting those of select ages from legal action based on misuse of the product.<BR>All: injuries, dismemberments, trauma (mental or physical), diseases, invasive species, deaths, memory loss, time loss, genetic recombination, or quantum displacement is the sole responsibility of the owner of the Circuitry Circus Education Toy Booster Pack <i>TM</i> <BR><BR>Please ask for your parent or guardian's permission before playing. Have fun."


//Mystery upgrades////////////

/obj/item/weapon/storage/box/mystery_upgrade
	name = "random cyborg upgrade pack"
	desc = "Magnetic gripper not included. Ever."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "circuit"

/obj/item/weapon/storage/box/mystery_upgrade/New()
	..()
	var/list/legalCircuits = existing_typesof(/obj/item/borg/upgrade) - /obj/item/borg/upgrade/magnetic_gripper //Moved from old trade vendor
	for(var/i = 1 to 3)
		var/boosterPack = pick(legalCircuits)
		new boosterPack(src)


//Mystery material//////////////////////

/obj/item/weapon/storage/box/large/mystery_material
	name = "surplus material scrap box"
	desc = "Caked in layers of dust, smells like a warehouse."
	var/list/surplusMat= list(
		/obj/item/stack/sheet/metal = 50,
		/obj/item/stack/sheet/glass/glass = 35,
		/obj/item/stack/sheet/plasteel = 25,
		/obj/item/stack/sheet/mineral/uranium = 20,
		/obj/item/stack/sheet/mineral/silver = 20,
		/obj/item/stack/sheet/mineral/gold = 15,
		/obj/item/stack/sheet/mineral/diamond = 5,
		/obj/item/stack/sheet/mineral/phazon = 1,
		/obj/item/stack/sheet/mineral/clown = 1
	)

/obj/item/weapon/storage/box/large/mystery_material/odd
	name = "surplus odd material scrap box"
	surplusMat = list(
		/obj/item/stack/sheet/bone = 50,
		/obj/item/stack/sheet/mineral/sandstone = 50,
		/obj/item/stack/sheet/brass = 35,
		/obj/item/stack/sheet/ralloy = 35,
		/obj/item/stack/sheet/mineral/gingerbread = 25,
		/obj/item/stack/sheet/animalhide/xeno = 10,
		/obj/item/stack/sheet/animalhide/human = 20,
		/obj/item/stack/sheet/snow = 25,
		/obj/item/stack/sheet/cardboard = 20,
		/obj/item/stack/telecrystal = 2,	//Emergent gameplay!
		/obj/item/stack/teeth/gold = 10,
		/obj/item/stack/tile/slime = 20
	)

/obj/item/weapon/storage/box/large/mystery_material/New()
	..()
	for(var/i = 1 to 6)
		var/theSurplus = pickweight(surplusMat)
		new theSurplus(src, surplusMat[theSurplus])


//Mystery food////////////////////

/obj/structure/closet/crate/freezer/bootlegpicnic
	name = "bootleg picnic supplies"
	desc = "Tangible proof against prohibition."

/obj/structure/closet/crate/freezer/bootlegpicnic/New()
	..()
	for(var/i = 1 to 4)
		var/bootlegSnack = pick(existing_typesof(/obj/item/weapon/reagent_containers/food/snacks))
		new bootlegSnack(src)
	for(var/i = 1 to 2)
		var/bootlegDrink = pick(existing_typesof(/obj/item/weapon/reagent_containers/food/drinks))
		new bootlegDrink(src)

/obj/structure/closet/crate/library
	name = "Library of Babel shipment"
	desc = "A shipment of nanodictionaries to be delivered to the Library of Babel. How'd it end up here?"
	icon_state = "plasmacrate"
	icon_opened = "plasmacrateopen"
	icon_closed = "plasmacrate"
	var/list/common_tongues = list(/obj/item/dictionary/insect,/obj/item/dictionary/root,/obj/item/dictionary/grey,
	/obj/item/dictionary/tradeband,/obj/item/dictionary/gutter,/obj/item/dictionary/clatter,/obj/item/dictionary/vox, /obj/item/dictionary/human)
	var/list/weird_tongues = list(/obj/item/dictionary/skrell,/obj/item/dictionary/catbeast,/obj/item/dictionary/clown,
	/obj/item/dictionary/unathi,/obj/item/dictionary/slime,/obj/item/dictionary/golem,/obj/item/dictionary/monkey,/obj/item/dictionary/martian)
	var/list/rare_tongues = list(/obj/item/dictionary/dsquad,/obj/item/dictionary/cult,/obj/item/dictionary/xeno)


/obj/structure/closet/crate/library/New()
	..()
	var/pix_x = -8
	for(var/i = 1 to 5)
		var/path
		switch(rand(99))
			if(0 to 79)
				path = pick(common_tongues)
			if(80 to 94)
				path = pick(weird_tongues)
			if(95 to 99)
				path = pick(rare_tongues)
		if(!path)
			continue
		var/obj/O = new path(src)
		O.pixel_x = pix_x
		pix_x += 4

/obj/item/dictionary/human/New()
	..()
	name = "solcom nanodictionary"
	desc += " The language of humans. Not to be confused with SOCOM."
	tongue = all_languages[LANGUAGE_HUMAN]
	progress_goal = 6
	progress_time = 12 SECONDS
	progress_fail_chance = 0

/obj/item/dictionary/skrell/New()
	..()
	name = "skrell nanodictionary"
	desc += " Finally, you'll be able to understand wetskrell.nt!"
	icon_state = "book4"
	tongue = all_languages[LANGUAGE_SKRELLIAN]
	progress_goal = 10
	progress_time = 6 SECONDS
	progress_fail_chance = 0

/obj/item/dictionary/catbeast/New()
	..()
	name = "catbeast nanodictionary"
	desc += " Slightly clawed."
	icon_state = "book9"
	tongue = all_languages[LANGUAGE_CATBEAST]
	progress_goal = 8
	progress_time = 6 SECONDS
	progress_fail_chance = 15

/obj/item/dictionary/clown/New()
	..()
	name = "hilarious nanodictionary"
	desc += " Is this a picturebook?"
	icon_state = "bookclown"
	tongue = all_languages[LANGUAGE_CLOWN]
	progress_goal = 4
	progress_time = 2 SECONDS
	progress_fail_chance = 90

/obj/item/dictionary/unathi/New()
	name = "unathi nanodictionary"
	desc += " This language is painstakingly slow to hiss out and learn."
	tongue = all_languages[LANGUAGE_UNATHI]
	progress_goal = 4
	progress_time = 18 SECONDS
	progress_fail_chance = 35

/obj/item/dictionary/insect/New()
	name = "insectoid nanodictionary"
	desc += " Lesson 1: Do not hit your teacher with books."
	tongue = all_languages[LANGUAGE_INSECT]
	progress_goal = 12
	progress_time = 4 SECONDS
	progress_fail_chance = 10

/obj/item/dictionary/root/New()
	name = "rootspeak nanodictionary"
	desc += " Speaking like a tree is harder than you'd think."
	tongue = all_languages[LANGUAGE_ROOTSPEAK]
	progress_goal = 4
	progress_time = 14 SECONDS
	progress_fail_chance = 55

/obj/item/dictionary/monkey/New()
	name = "monkey nanodictionary"
	desc += " For those with primal aspirations."
	icon_state = "book8"
	tongue = all_languages[LANGUAGE_MONKEY]
	progress_goal = 20
	progress_time = 2 SECONDS
	progress_fail_chance = 10

/obj/item/dictionary/tradeband/New()
	name = "tradeband nanodictionary"
	desc += " For the guild!"
	tongue = all_languages[LANGUAGE_TRADEBAND]
	progress_goal = 7
	progress_time = 7 SECONDS
	progress_fail_chance = 7

/obj/item/dictionary/gutter/New()
	name = "gutter nanodictionary"
	desc += " Surprisingly easy to pick up!"
	tongue = all_languages[LANGUAGE_GUTTER]
	progress_goal = 4
	progress_time = 8 SECONDS
	progress_fail_chance = 5

/obj/item/dictionary/mouse/New()
	name = "custodial nanodictionary"
	desc += " Can this one actually work? It's dripping..."
	icon_state = "chemistry"
	tongue = all_languages[LANGUAGE_MOUSE]
	progress_goal = 20
	progress_time = 15 SECONDS
	progress_fail_chance = 20

/obj/item/dictionary/clatter/New()
	name = "clatter nanodictionary"
	desc += " Unusually spooky."
	tongue = all_languages[LANGUAGE_CLATTER]
	progress_goal = 6
	progress_time = 11 SECONDS
	progress_fail_chance = 0

/obj/item/dictionary/golem/New()
	name = "golem nanodictionary"
	desc += " What a grind."
	icon_state = "bookstatue"
	tongue = all_languages[LANGUAGE_GOLEM]
	progress_goal = 4
	progress_time = 3 SECONDS
	progress_fail_chance = 95

/obj/item/dictionary/slime/New()
	name = "slime nanodictionary"
	desc += " Each word flows into the next."
	icon_state = "book7"
	tongue = all_languages[LANGUAGE_SLIME]
	progress_goal = 6
	progress_time = 5 SECONDS
	progress_fail_chance = 33

/obj/item/dictionary/grey/New()
	name = "grey nanodictionary"
	desc += " This language has no words for disobedience."
	tongue = all_languages[LANGUAGE_GREY]
	progress_goal = 6
	progress_time = 8 SECONDS
	progress_fail_chance = 0

/obj/item/dictionary/martian/New()
	name = "martian nanodictionary"
	desc += " You need to supply the extra arms."
	icon_state = "book2"
	tongue = all_languages[LANGUAGE_MARTIAN]
	progress_goal = 6
	progress_time = 12 SECONDS
	progress_fail_chance = 0

/obj/item/dictionary/cult/New()
	name = "Commentaries on the Arcane Tome"
	desc = "A particularly dubious-looking nanodictionary with the stated goal of translating the Arcane Tome of the Blood Cult dedicated to Nar-Sie. According to the unknown author, 'each word is razor-fed and secret, thinner than cataclysms, tarnished like red-drink.'"
	icon_state = "book"
	tongue = all_languages[LANGUAGE_CULT]
	progress_goal = 4
	progress_time = 60 SECONDS
	progress_fail_chance = 60

/obj/item/dictionary/xeno/New()
	name = "unknown nanodictionary"
	desc += " This one contains a lot of terrifying shrieks. Is this a language?"
	icon_state = "bookHacking"
	tongue = all_languages[LANGUAGE_XENO]
	progress_goal = 40
	progress_time = 6 SECONDS
	progress_fail_chance = 15

/obj/item/dictionary/dsquad/New()
	name = "redacted nanodictionary"
	desc += " Is it in some kind of code?"
	icon_state = "bookNuclear"
	tongue = all_languages[LANGUAGE_DEATHSQUAD]
	progress_goal = 20
	progress_time = 15 SECONDS
	progress_fail_chance = 25

/obj/item/weapon/storage/toolbox/nanopaint
	name = "nano painter's toolbox"
	desc = "Contains an assortment of luminous nano paints for the artistic trader."
	icon_state = "toolbox_nanopaint"
	item_state = "toolbox_nanopaint"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')
	attack_verb = list("daubs", "decorates", "slathers")
	max_combined_w_class = 42
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/vantablack,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/red,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/green,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/blue,
		/obj/item/clothing/glasses/sunglasses/polarized,
	)
