/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, sec/detective gear, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */
 #define BOX_SPACE 7

/obj/item/weapon/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/smallboxes.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	icon_state = "box"
	item_state = "box"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC
	autoignition_temperature = 522 // Kelvin
	fire_fuel = 2
	autoignition_temperature = AUTOIGNITION_PAPER
	on_armory_manifest = TRUE

/obj/item/weapon/storage/box/large
	name = "large box"
	desc = "You could build a fort with this."
	icon_state = "largebox"
	item_state = "largebox"
	w_class = W_CLASS_LARGE // Big, bulky.
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amount = 4 // Takes 4 to make. - N3X
	starting_materials = list(MAT_CARDBOARD = 15000)
	storage_slots = 21
	max_combined_w_class = 42 // 21*2

	autoignition_temperature = 530 // Kelvin
	fire_fuel = 3

/obj/item/weapon/storage/box/surveillance
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cigarettes. A label on the packaging reads: \"Wouldn't a slow death make a change?\""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "Dpacket"
	item_state = "Dpacket"
	w_class = W_CLASS_TINY
	foldable = null
	items_to_spawn = list(
		/obj/item/device/camera_bug = 5,
		/obj/item/clothing/mask/cigarette/bugged = 3,
	)

/obj/item/weapon/storage/box/surveillance/examine(mob/user)
	..()
	if(is_holder_of(user, src))
		to_chat(user, "<span class='info'><b>When inspected hands-on,</b> the box is apparently modified with complex electronics.</span>")
		return
	if(isturf(loc) && user.Adjacent(src))
		to_chat(user, "Something's a little off...")

/obj/item/weapon/storage/box/surveillance/distance_interact(mob/user)
	if(istype(loc,/obj/item/weapon/storage/box/surveillance) && in_range(user,loc))
		playsound(loc, rustle_sound, 50, 1, -5)
		return TRUE
	return FALSE

/obj/item/weapon/storage/box/survival
	name = "survival equipment box"
	desc = "Makes braving the hazards of space a little bit easier."
	icon_state = "box_emergency"
	item_state = "box_emergency"
	items_to_spawn = list(
		/obj/item/clothing/mask/breath,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/stack/medical/bruise_pack/bandaid,
	)

/obj/item/weapon/storage/box/survival/vox
	icon_state = "box_vox"
	item_state = "box_vox"
	items_to_spawn = list(
		/obj/item/clothing/mask/breath/vox,
		/obj/item/weapon/tank/emergency_nitrogen,
		/obj/item/stack/medical/bruise_pack/bandaid,
	)

/obj/item/weapon/storage/box/survival/plasmaman
	icon_state = "box_plasmaman"
	item_state = "box_plasmaman"
	items_to_spawn = list(
		/obj/item/clothing/mask/breath,
		/obj/item/weapon/tank/emergency_plasma,
		/obj/item/stack/medical/bruise_pack/bandaid,
	)

/obj/item/weapon/storage/box/survival/engineer
	icon_state = "box_eva"
	item_state = "box_eva"
	items_to_spawn = list(
		/obj/item/clothing/mask/breath,
		/obj/item/weapon/tank/emergency_oxygen/engi,
		/obj/item/stack/medical/bruise_pack/bandaid,
	)

/obj/item/weapon/storage/box/survival/engineer/vox
	icon_state = "box_eva"
	item_state = "box_eva"
	items_to_spawn = list(
		/obj/item/clothing/mask/breath/vox,
		/obj/item/weapon/tank/emergency_nitrogen/engi,
		/obj/item/stack/medical/bruise_pack/bandaid,
	)

/obj/item/weapon/storage/box/survival/engineer/plasmaman
	icon_state = "box_plasmaman"
	item_state = "box_plasmaman"
	items_to_spawn = list(
		/obj/item/clothing/mask/breath,
		/obj/item/weapon/tank/emergency_plasma/engi,
		/obj/item/stack/medical/bruise_pack/bandaid,
	)

/obj/item/weapon/storage/box/survival/ert
	icon_state = "box_ERT"
	items_to_spawn = list(
		/obj/item/clothing/mask/gas/ert,
		/obj/item/weapon/tank/emergency_oxygen/double,
		/obj/item/stack/medical/bruise_pack/bandaid,
		/obj/item/ammo_storage/magazine/c45,
		/obj/item/ammo_storage/magazine/c45/rubber,
	)

/obj/item/weapon/storage/box/survival/nuke
	icon_state = "box_nuke"
	items_to_spawn = list(
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/stack/medical/bruise_pack/bandaid,
		/obj/item/weapon/reagent_containers/pill/cyanide, //For those who hate fun
		/obj/item/weapon/reagent_containers/pill/laststand, //HOOOOOO HOOHOHOHOHOHO - N3X
	)

/obj/item/weapon/storage/box/survival/nuke/vox/New()
	. = ..()
	new /obj/item/weapon/tank/emergency_nitrogen(src)

/obj/item/weapon/storage/box/survival/nuke/human/New()
	. = ..()
	new /obj/item/weapon/tank/emergency_oxygen/double(src)

/obj/item/weapon/storage/box/priority_care
	name = "priority care parcel"
	desc = "A small parcel of miscellaneous junk Nanotrasen hands out to their most requested employees."
	icon_state = "nt"
	item_state = "nt"

/obj/item/weapon/storage/box/priority_care/New()
	..()
	new /obj/item/weapon/spacecash/c100(src)
	new /obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating(src)
	var/possible_mug = pick(subtypesof(/obj/item/weapon/reagent_containers/food/drinks/flagmug))
	for(var/i in 1 to 3)
		var/toSpawn = pick(
			/obj/item/voucher/free_item/donk,
			/obj/item/voucher/free_item/hot_drink,
			/obj/item/voucher/free_item/glowing,
			/obj/item/voucher/free_item/snack,
			/obj/item/mounted/poster,
			/obj/item/weapon/pen/NT,
			/obj/item/clothing/accessory/medal/participation,
			possible_mug,
			/obj/item/weapon/lighter/NT,
			25;/obj/item/toy/syndicateballoon/ntballoon,
			25;/obj/item/weapon/reagent_containers/food/snacks/chococoin,
			25;/obj/item/weapon/tank/emergency_oxygen/engi,
			25;/obj/item/weapon/reagent_containers/hypospray/autoinjector,
			25;/obj/item/weapon/reagent_containers/food/drinks/thermos/full
		)
		new toSpawn(src)

/obj/item/weapon/storage/box/byond
	name = "\improper BYOND support package"
	desc = "A small box containing a branded trinket that the BYOND corporation sends to people that actually send them money."
	icon_state = "byond"
	item_state = "byond"
	storage_slots = 1 //not very useful for storage
	foldable = /obj/item/trash/byond_box //no free cardboard
	items_to_spawn = list(
		list(
			/obj/item/weapon/thermometer/byond,
			/obj/item/clothing/accessory/medal/byond,
			/obj/item/toy/syndicateballoon/byondballoon,
		)
	)

/obj/item/weapon/storage/box/gloves
	name = "box of latex gloves"
	desc = "A box containing white latex gloves. gloves. gloves."
	icon_state = "latex"
	items_to_spawn = list(/obj/item/clothing/gloves/latex = BOX_SPACE)

/obj/item/weapon/storage/box/bgloves
	name = "box of black gloves"
	desc = "A box containing black gloves."
	icon_state = "bgloves"
	items_to_spawn = list(/obj/item/clothing/gloves/black = BOX_SPACE)

/obj/item/weapon/storage/box/sunglasses
	name = "box of sunglasses"
	desc = "A box containing sunglasses."
	icon_state = "sunglass"
	items_to_spawn = list(/obj/item/clothing/glasses/sunglasses = BOX_SPACE)

/obj/item/weapon/storage/box/masks
	name = "sterile masks"
	desc = "This box contains sterile masks."
	icon_state = "sterile"
	items_to_spawn = list(/obj/item/clothing/mask/surgical = BOX_SPACE)


/obj/item/weapon/storage/box/syringes
	name = "syringes"
	desc = "A box containing syringes. A reminder label warns of syringes becoming potential biohazards when not properly sanitized."
	icon_state = "syringe"
	item_state = "syringe"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/syringe = 6,
		/obj/item/weapon/reagent_containers/syringe/giant,
	)

/obj/item/weapon/storage/box/beakers
	name = "beaker box"
	icon_state = "beaker"
	item_state = "beaker"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/glass/beaker = BOX_SPACE)

/obj/item/weapon/storage/box/injectors
	name = "\improper DNA injectors"
	desc = "This box contains injectors, it seems."
	icon_state = "box_injector"
	items_to_spawn = list(
		/obj/item/weapon/dnainjector/nofail/h2m = 3,
		/obj/item/weapon/dnainjector/nofail/m2h = 3,
	)

/obj/item/weapon/storage/box/blanks
	name = "box of blank shells"
	desc = "It has a picture of a gun and several warning symbols on the front."
	items_to_spawn = list(/obj/item/ammo_casing/shotgun/blank = BOX_SPACE)

/obj/item/weapon/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<FONT color=red><B>WARNING: Do not use without reading these precautions!</B></FONT>\n<B>These devices are extremely dangerous and can cause blindness or deafness if used incorrectly.</B>\nThe chemicals contained in these devices have been tuned for maximal effectiveness and due to\nextreme safety precuaiotn shave been incased in a tamper-proof pack. DO NOT ATTEMPT TO OPEN\nFLASH WARNING: Do not use continually. Excercise extreme care when detonating in closed spaces.\n\tMake attemtps not to detonate withing range of 2 meters of the intended target. It is imperative\n\tthat the targets visit a medical professional after usage. Damage to eyes increases extremely per\n\tuse and according to range. Glasses with flash resistant filters DO NOT always work on high powered\n\tflash devices such as this. <B>EXERCISE CAUTION REGARDLESS OF CIRCUMSTANCES</B>\nSOUND WARNING: Do not use continually. Visit a medical professional if hearing is lost.\n\tThere is a slight chance per use of complete deafness. Exercise caution and restraint.\nSTUN WARNING: If the intended or unintended target is too close to detonation the resulting sound\n\tand flash have been known to cause extreme sensory overload resulting in temporary\n\tincapacitation.\n<B>DO NOT USE CONTINUALLY</B>\nOperating Directions:\n\t1. Pull detonnation pin. <B>ONCE THE PIN IS PULLED THE GRENADE CAN NOT BE DISARMED!</B>\n\t2. Throw grenade. <B>NEVER HOLD A LIVE FLASHBANG</B>\n\t3. The grenade will detonste 10 seconds hafter being primed. <B>EXCERCISE CAUTION</B>\n\t-<B>Never prime another grenade until after the first is detonated</B>\nNote: Usage of this pyrotechnic device without authorization is an extreme offense and can\nresult in severe punishment upwards of <B>10 years in prison per use</B>.\n\nDefault 3 second wait till from prime to detonation. This can be switched with a screwdriver\nto 10 seconds.\n\nCopyright of Nanotrasen Industries- Military Armnaments Division\nThis device was created by Nanotrasen Labs a member of the Expert Advisor Corporation"
	icon_state = "flashbang"
	item_state = "flashbang"
	items_to_spawn = list(/obj/item/weapon/grenade/flashbang = BOX_SPACE)

/obj/item/weapon/storage/box/teargas
	name = "box of teargas grenades (WARNING)"
	desc = "<FONT color=red><B>WARNING: Do not use without reading these precautions!</B></FONT>\n<B>WARNING: These devices can expose you to chemicals including Lead Salts and Hexavalent Chromium, which are known to the Republic of New California to cause cancer, and Lead Salts, which are known to the Republic of New California to cause birth defects and other reproductive harm.</B>\nThe Tear-Gas™ Grenade is a high volume, continuous discharge grenade. Tear-Gas™ is discharged through four (4) gas ports located on top of the canister and one (1) located on the bottom. It is similar in size to the typical Flash-Bang™ Grenade.\nThe Tear-Gas™ Grenade was designed for training, but may also be used in operations. The Tear-Gas™ Grenade offers the same approximate stunning time as the Flash-Bang™ Grenade. The similar stunning times may make it the appropriate choice for training or simulation deployment of chemical agent canisters. The Tear-Gas™ formulation is considered to be less toxic than Chloral Hydrate (chloral) smoke. The Tear-Gas™ Grenade emits a very red smoke.\nIn operations, it can be utilized as a carrying agent (multiplier) for Flash-Bang™ Grenades or other stunning munitions, or for concealing the movement of security personnel. It may also be used as a distraction to focus attention away from other activities. The device should be deployed utilizing wind advantage.\nIt should NOT be deployed onto rooftops, in crawl spaces, or indoors due to its fire-producing capability. Hand throw or launch. Launching of grenades will provide deploying officers additional standoff situations.\n<B>WARNING: THIS PRODUCT IS TO BE USED ONLY BY AUTHORIZED AND TRAINED LAW ENFORCEMENT, CORRECTIONS, OR MILITARY PERSONNEL. THIS PRODUCT MAY CAUSE SERIOUS INJURY OR DEATH TO YOU OR OTHERS. THIS PRODUCT MAY CAUSE SERIOUS DAMAGE TO PROPERTY. HANDLE, STORE AND USE WITH EXTREME CARE AND CAUTION. USE ONLY AS INSTRUCTED.</B>"
	icon_state = "flashbang"
	item_state = "flashbang"
	items_to_spawn = list(/obj/item/weapon/grenade/chem_grenade/teargas = BOX_SPACE)

/obj/item/weapon/storage/box/syndigrenades
	name = "box of C28E pipe bombs (WARNING)"
	desc = "A box containing the cream of the crop of throwable syndicate explosive devices. There's instructions on the back explaining that you need to pull the pin and throw it, and a warning that forgetting either step could lead to bad results. A good thing to tell to demolition operatives."
	icon_state = "syndienade"
	items_to_spawn = list(/obj/item/weapon/grenade/syndigrenade = BOX_SPACE)

/obj/item/weapon/storage/box/syndisyringes
	name = "syndicate mix syringes (WARNING)"
	desc = "A box containing syndicate mix syringes. A clear warning label instructs that they should not be used on your teammates. Ranged executions galore."
	icon_state = "syndisyringe"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/syringe/syndi = BOX_SPACE)

/obj/item/weapon/storage/box/smokebombs
	name = "box of smokebombs"
	icon_state = "smokebomb"
	item_state = "flashbang"
	items_to_spawn = list(/obj/item/weapon/grenade/smokebomb = BOX_SPACE)

/obj/item/weapon/storage/box/stickybombs
	name = "box of stickybombs"
	icon_state = "stickybomb"
	items_to_spawn = list(/obj/item/stickybomb = 24)

/obj/item/weapon/storage/box/emps
	name = "emp grenades"
	desc = "A box containing EMP grenades."
	icon_state = "flashbang"
	items_to_spawn = list(/obj/item/weapon/grenade/empgrenade = 5)

/obj/item/weapon/storage/box/wind
	name = "wind grenades"
	desc = "A box containing wind grenades."
	icon_state = "flashbang"
	items_to_spawn = list(/obj/item/weapon/grenade/chem_grenade/wind = 3)

/obj/item/weapon/storage/box/foam
	name = "metal foam grenades"
	desc = "A box containing metal foam grenades."
	icon_state = "metalfoam"
	items_to_spawn = list(/obj/item/weapon/grenade/chem_grenade/metalfoam = BOX_SPACE)

/obj/item/weapon/storage/box/boxen
	name = "boxen ranching kit"
	desc = "Everything you need to engage in your own horrific flesh cloning."
	items_to_spawn = list(
		/obj/item/weapon/circuitboard/box_cloner,
		/obj/item/weapon/reagent_containers/food/snacks/meat/box,
		/obj/item/weapon/reagent_containers/food/snacks/meat/box,
	)

/obj/item/weapon/storage/box/trackimp
	name = "tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"
	items_to_spawn = list(
		/obj/item/weapon/implantcase/tracking = 4,
		/obj/item/weapon/implanter,
		/obj/item/weapon/implantpad,
		/obj/item/weapon/locator,
		/obj/item/device/locator_holomap,
	)

/obj/item/weapon/storage/box/chemimp
	name = "chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"
	items_to_spawn = list(
		/obj/item/weapon/implantcase/chem = 5,
		/obj/item/weapon/implanter,
		/obj/item/weapon/implantpad,
	)

/obj/item/weapon/storage/box/chemimp/remeximp
	items_to_spawn = list(
		/obj/item/weapon/implantcase/remote = 5,
		/obj/item/weapon/implanter,
		/obj/item/weapon/implantpad,
	)

/obj/item/weapon/storage/box/bolas
	name = "bolas box"
	desc = "Box of bolases. Make sure to take them out before throwing them."
	icon_state = "bolas"
	items_to_spawn = list(/obj/item/weapon/legcuffs/bolas = BOX_SPACE)

/obj/item/weapon/storage/box/rxglasses
	name = "prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"
	items_to_spawn = list(/obj/item/clothing/glasses/regular = BOX_SPACE)

/obj/item/weapon/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = BOX_SPACE)

/obj/item/weapon/storage/box/cdeathalarm_kit
	name = "Death Alarm Kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state = "beaker"
	items_to_spawn = list(/obj/item/weapon/implantcase/death_alarm = BOX_SPACE)

/obj/item/weapon/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/condiment = BOX_SPACE)

/obj/item/weapon/storage/box/cups
	name = "box of paper cups"
	desc = "It has a picture of a paper cup on the front."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/drinks/sillycup = BOX_SPACE)

/obj/item/weapon/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<span class='notice'>Instructions: Heat in microwave. Product will cool if not eaten within seven minutes.</span>"
	icon_state = "donk_kit"
	item_state = "donk_kit"
	var/pocket_amount = 6

/obj/item/weapon/storage/box/donkpockets/New()
	..()
	for(var/i=0,i<pocket_amount,i++)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)

/obj/item/weapon/storage/box/donkpockets/random_amount/New()
	pocket_amount = rand(1,6)
	..()

/obj/item/weapon/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycubebox"
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube")
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped = 6)

/obj/item/weapon/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Ahdomai. Just add water!"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube = 6)

/obj/item/weapon/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube = 6)

/obj/item/weapon/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube = 6)

/obj/item/weapon/storage/box/monkeycubes/isopodcubes
	name = "isopod cube box"
	desc = "Drymate brand isopod cubes, shipped from Secto 4. Just add water!"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/isopodcube = 6)

/obj/item/weapon/storage/box/monkeycubes/mousecubes
	name = "lab mouse cube box"
	desc = "Drymate brand laboratory mouse cubes, shipped from Yensid. Just add water!"
	icon_state = "mousecubebox"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/mousecube = 6)

/obj/item/weapon/storage/box/monkeycubes/spacecarpcube
	name = "space carp baby cube box"
	desc = "Drymate brand space carp baby cubes, shipped from F1SH-1NG. Just add water!"
	icon_state = "spacecarpcubebox"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/spacecarpcube = 6)

/obj/item/weapon/storage/box/ids
	name = "spare IDs"
	desc = "Contains blank identification cards."
	icon_state = "id"
	items_to_spawn = list(/obj/item/weapon/card/id = BOX_SPACE)

/obj/item/weapon/storage/box/seccarts
	name = "Spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda"
	items_to_spawn = list(/obj/item/weapon/cartridge/security = BOX_SPACE)

/obj/item/weapon/storage/box/handcuffs
	name = "spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"
	items_to_spawn = list(/obj/item/weapon/handcuffs = BOX_SPACE)

/obj/item/weapon/storage/box/large/securitygear
	name = "security essentials"
	desc = "A box containing essential security officer equipment. It has a piece of paper with the letters SEC written on it taped to one side."
	icon_state = "largebox_sec"
	fits_max_w_class = W_CLASS_MEDIUM
	can_add_combinedwclass = TRUE
	can_only_hold = list(
		"/obj/item/device/radio/headset/headset_sec",
		"/obj/item/clothing/glasses/sunglasses/sechud",
		"/obj/item/clothing/gloves/black",
		"/obj/item/weapon/storage/belt/security",
		"/obj/item/device/flashlight/tactical",
		"/obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical",
		"/obj/item/device/gps/secure",
		"/obj/item/device/flash",
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/melee/baton/loaded",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/taperoll/police",
		"/obj/item/device/hailer",
		"/obj/item/device/law_planner",
	)
	items_to_spawn = list(
		/obj/item/device/radio/headset/headset_sec,
		list(/obj/item/clothing/glasses/sunglasses/sechud/prescription,/obj/item/clothing/glasses/sunglasses/sechud),
		/obj/item/clothing/gloves/black,
		/obj/item/weapon/storage/belt/security,
		/obj/item/device/flashlight/tactical,
		/obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical,
		/obj/item/device/gps/secure,
		/obj/item/device/flash,
		/obj/item/weapon/grenade/flashbang,
		/obj/item/weapon/melee/baton/loaded,
		/obj/item/weapon/gun/energy/taser,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/taperoll/police,
		/obj/item/device/hailer,
		/obj/item/device/law_planner,
	)

/obj/item/weapon/storage/box/large/detectivegear
	name = "detective essentials"
	desc = "A box containing essential detective officer equipment. It has a piece of paper with the letters DET written on it taped to one side."
	icon_state = "largebox_det"
	fits_max_w_class = W_CLASS_MEDIUM
	can_add_combinedwclass = TRUE
	items_to_spawn = list(
		/obj/item/device/radio/headset/headset_sec,
			/obj/item/clothing/glasses/regular/tracking/detective,
		/obj/item/clothing/gloves/black,
		/obj/item/weapon/storage/belt/detective,
		/obj/item/weapon/switchtool/switchblade,
		/obj/item/device/gps/secure,
		/obj/item/ammo_storage/box/c38 = 2,
		/obj/item/ammo_storage/speedloader/c38,
		/obj/item/weapon/storage/box/evidence,
		/obj/item/device/detective_scanner,
		/obj/item/binoculars,
		/obj/item/device/radio/phone/surveillance,
		/obj/item/device/handtv,
		/obj/item/weapon/reagent_containers/spray/luminol,
		/obj/item/taperoll/police,
	)

/obj/item/weapon/storage/box/mousetraps
	name = "box of Pest-B-Gon Mousetraps"
	desc = "<span class='userdanger'>WARNING: Keep out of reach of children.</span>"
	icon_state = "mousetraps"
	items_to_spawn = list(/obj/item/device/assembly/mousetrap = 6)

/obj/item/weapon/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	items_to_spawn = list(/obj/item/weapon/storage/pill_bottle = BOX_SPACE)

/obj/item/weapon/storage/box/lethalshells
	name = "12-gauge slugs"
	icon_state = "slug_shells"
	can_add_storageslots = TRUE
	items_to_spawn = list(/obj/item/ammo_casing/shotgun = 16)

/obj/item/weapon/storage/box/beanbagshells
	name = "12-gauge beanbag shells"
	icon_state = "beanbag_shells"
	can_add_storageslots = TRUE
	items_to_spawn = list(/obj/item/ammo_casing/shotgun/beanbag = 16)

/obj/item/weapon/storage/box/stunshells
	name = "12-gauge stun shells"
	icon_state = "stun_shells"
	can_add_storageslots = TRUE
	items_to_spawn = list(/obj/item/ammo_casing/shotgun/stunshell = 16)

/obj/item/weapon/storage/box/dartshells
	name = "12-gauge darts"
	icon_state = "dart_shells"
	can_add_storageslots = TRUE
	items_to_spawn = list(/obj/item/ammo_casing/shotgun/dart = 16)

/obj/item/weapon/storage/box/buckshotshells
	name = "12-gauge 00 buckshot shells"
	icon_state = "buckshot_shells"
	can_add_storageslots = TRUE
	items_to_spawn = list(/obj/item/ammo_casing/shotgun/buckshot = 16)

/obj/item/weapon/storage/box/dragonsbreathshells
	name = "12-gauge dragon's breath shells"
	icon_state = "dragonsbreath_shells"
	can_add_storageslots = TRUE
	items_to_spawn = list(/obj/item/ammo_casing/shotgun/dragonsbreath = 16)

/obj/item/weapon/storage/box/fragshells
	name = "12-gauge high-explosive fragmentation shells"
	icon_state = "frag_shells"
	can_add_storageslots = TRUE
	items_to_spawn = list(/obj/item/ammo_casing/shotgun/frag = 16)

/obj/item/weapon/storage/box/labels
	name = "label roll box"
	desc = "A box of refill rolls for a hand labeler."
	icon_state = "labels"
	items_to_spawn = list(/obj/item/device/label_roll = BOX_SPACE)

/obj/item/weapon/storage/box/wreath/wreath_bow
	name = "wreath (bow) box"
	desc = "Just add hands for Christmas."
	icon_state = "wreath_bow"
	items_to_spawn = list(/obj/item/mounted/frame/wreath/wreath_bow = BOX_SPACE)

/obj/item/weapon/storage/box/wreath/wreath_nobow
	name = "wreath (holly) box"
	desc = "Emergency Christmas supplies."
	icon_state = "wreath_nobow"
	items_to_spawn = list(/obj/item/mounted/frame/wreath/wreath_nobow = BOX_SPACE)

/obj/item/weapon/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_only_hold = list("/obj/item/toy/snappop")
	items_to_spawn = list(/obj/item/toy/snappop = BOX_SPACE)

/obj/item/weapon/storage/box/syndicatefake/space
	name = "Space Suit and Helmet Replica"
	icon_state = "box_of_doom"
	item_state = "box_of_doom"
	items_to_spawn = list(
		/obj/item/clothing/suit/syndicatefake,
		/obj/item/clothing/head/syndicatefake,
	)

/obj/item/weapon/storage/box/syndicatefake/ninja
	name = "Ninja Suit and Hood Replica"
	icon_state = "box_of_doom"
	item_state = "box_of_doom"
	items_to_spawn = list(
		/obj/item/clothing/suit/spaceninjafake,
		/obj/item/clothing/head/spaceninjafake,
	)

/obj/item/weapon/storage/box/syndicatefake/ops
	name = "Operative Suit Replica"
	icon_state = "box_of_doom"
	item_state = "box_of_doom"
	items_to_spawn = list(
		/obj/item/clothing/suit/opsfake,
		/obj/item/clothing/head/opsfake,
	)

/obj/item/weapon/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/hypospray/autoinjector = BOX_SPACE)

/obj/item/weapon/storage/box/antiviral_syringes
	name = "box of anti-viral syringes"
	desc = "Contains anti-viral syringes."
	icon_state = "syringe"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/syringe/antiviral = BOX_SPACE)

/obj/item/weapon/storage/box/mugs
	name = "box of mugs"
	desc = "It's a box of mugs."
	icon_state = "box_mug"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/food/drinks/mug = 5,
	)

/obj/item/weapon/storage/box/mugs/New()
	..()
	var/flagmug = pick(subtypesof(/obj/item/weapon/reagent_containers/food/drinks/flagmug))
	new flagmug(src)

// TODO Change this to a box/large. - N3X
/obj/item/weapon/storage/box/lights
	name = "replacement bulbs"
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "box"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	can_only_hold = list("/obj/item/weapon/light/tube", "/obj/item/weapon/light/bulb")
	can_add_combinedwclass = TRUE
	can_add_storageslots = TRUE
	items_to_spawn = list(/obj/item/weapon/light/bulb = 21)
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/lights/tubes
	name = "replacement tubes"
	icon_state = "lighttube"
	items_to_spawn = list(/obj/item/weapon/light/tube = 21)

/obj/item/weapon/storage/box/lights/mixed
	name = "replacement lights"
	icon_state = "lightmixed"
	items_to_spawn = list(
		/obj/item/weapon/light/tube = 14,
		/obj/item/weapon/light/bulb = 7,
	)

/obj/item/weapon/storage/box/lights/he
	name = "high efficiency lights"
	icon_state = "lightmixed"
	items_to_spawn = list(
		/obj/item/weapon/light/tube/he = 14,
		/obj/item/weapon/light/bulb/he = 7,
	)

/obj/item/weapon/storage/box/lights/empty
	items_to_spawn = list() //Bro why isn't the default null
	max_combined_w_class = 21 //In the filled versions, these are set as they're filled.
	storage_slots = 21

/obj/item/weapon/storage/box/inflatables
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors. Specially designed for space-efficient packing of deflated structures."
	icon_state = "inf_box"
	can_only_hold = list(
		"/obj/item/inflatable/door",
		"/obj/item/inflatable/wall",
		"/obj/item/inflatable/shelter")
	can_add_combinedwclass = TRUE
	can_increase_wclass_stored = TRUE
	items_to_spawn = list(
		/obj/item/inflatable/door = 3,
		/obj/item/inflatable/wall = 4,
	)

/obj/item/weapon/storage/box/ornaments
	name = "box of ornaments"
	desc = "A box of seven glass Christmas ornaments. Color not included."
	icon_state = "ornament_box"
	foldable = null
	starting_materials = list(MAT_GLASS = 2000)		//needed for autolathe production
	items_to_spawn = list(/obj/item/ornament = 6)

/obj/item/weapon/storage/box/ornaments/New()
	..()
	if(prob(10))
		new /obj/item/ornament/topper(src)
	else
		new /obj/item/ornament(src)

/obj/item/weapon/storage/box/ornaments/teardrop_ornaments
	name = "box of teardrop ornaments"
	desc = "A box of seven teardrop-shaped glass Christmas ornaments. Color not included."
	icon_state = "teardrop_ornament_box"
	items_to_spawn = list(/obj/item/ornament/teardrop = BOX_SPACE)

/obj/item/weapon/storage/box/botanydisk
	name = "flora disk box"
	desc = "A box of flora data disks."
	icon_state = "botanydisk"
	items_to_spawn = list(/obj/item/weapon/disk/botany = BOX_SPACE)

/obj/item/weapon/storage/box/holobadge
	name = "holobadge box"
	desc = "A box containing holobadges."
	icon_state = "box_badge"
	items_to_spawn = list(
		/obj/item/clothing/accessory/holobadge = 4,
		/obj/item/clothing/accessory/holobadge/cord = 2,
	)

/obj/item/weapon/storage/box/spellbook
	name = "Spellbook Bundle"
	desc = "High quality discount spells! This bundle is non-refundable. The end user is solely liable for any damages arising from misuse of these products."

/obj/item/weapon/storage/box/spellbook/New()
	..()
	var/list/possible_books = subtypesof(/obj/item/weapon/spellbook/oneuse)
	for(var/S in possible_books)
		var/obj/item/weapon/spellbook/oneuse/O = S
		if(initial(O.disabled_from_bundle))
			possible_books -= O
	for(var/i =1; i <= BOX_SPACE; i++)
		var/randombook = pick(possible_books)
		var/book = new randombook(src)
		src.contents += book
		possible_books -= randombook
	var/randomsprite = pick("a","b")
	icon_state = "wizbox-[randomsprite]"

/obj/item/weapon/storage/box/chrono_grenades
	name = "box of chrono grenades"
	desc = "A box of seven experimental chrono grenades."
	icon_state = "chrono_grenade"
	items_to_spawn = list(/obj/item/weapon/grenade/chronogrenade = BOX_SPACE)

/obj/item/weapon/storage/box/balloons
	name = "box of balloons"
	desc = "A box containing seven balloons of various colors."
	icon_state = "balloon_box"
	items_to_spawn = list(/obj/item/toy/balloon = BOX_SPACE)

/obj/item/weapon/storage/box/chrono_grenades/future
	icon_state = "future_grenade"
	items_to_spawn = list(/obj/item/weapon/grenade/chronogrenade/future = BOX_SPACE)

/obj/item/weapon/storage/box/balloons/long
	name = "box of long balloons"
	desc = "A box containing seven long balloons of various colors."
	icon_state = "long_balloon_box"
	items_to_spawn = list(/obj/item/toy/balloon/long = BOX_SPACE)

/obj/item/weapon/storage/box/balloons/long/living
	items_to_spawn = list(/obj/item/toy/balloon/long/living = BOX_SPACE)

/obj/item/weapon/storage/box/chrono_grenades/past
	icon_state = "past_grenade"
	items_to_spawn = list(/obj/item/weapon/grenade/chronogrenade/past = BOX_SPACE)

// Who organizes this shit?

/obj/item/weapon/storage/box/actionfigure
	name = "box of action figures"
	desc = "The latest set of collectable action figures."
	icon_state = "box"

/obj/item/weapon/storage/box/actionfigure/New()
	..()
	for(var/i in 1 to 4)
		var/randomFigure = pick(subtypesof(/obj/item/toy/figure))
		new randomFigure(src)

/obj/item/weapon/storage/box/mechfigures
	name = "box of mech figurines"
	desc = "An old box of mech figurines."
	icon_state = "box"

/obj/item/weapon/storage/box/mechfigures/New()
	..()
	for(var/i in 1 to 4)
		var/randomFigurine = pick(/obj/item/toy/prize/ripley,
							/obj/item/toy/prize/fireripley,
							/obj/item/toy/prize/deathripley,
							/obj/item/toy/prize/gygax,
							/obj/item/toy/prize/durand,
							/obj/item/toy/prize/honk,
							/obj/item/toy/prize/marauder,
							/obj/item/toy/prize/seraph,
							/obj/item/toy/prize/mauler,
							/obj/item/toy/prize/odysseus,
							/obj/item/toy/prize/phazon)
		new randomFigurine(src)

/obj/item/weapon/storage/box/diy_soda
	name = "Dr. Pecker's DIY soda kit"
	desc = "A trendy and expensive 'DIY' soda that you have to mix yourself. Tastes like a science fair experiment."
	icon_state = "box_DIY_soda"
	vending_cat = "carbonated drinks"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial/tenwater,
		/obj/item/weapon/reagent_containers/glass/beaker/vial/tencarbon,
		/obj/item/weapon/reagent_containers/glass/beaker/vial/tenantitox,
		/obj/item/weapon/reagent_containers/glass/beaker/erlenmeyer/lemonlime,
		/obj/item/weapon/reagent_containers/glass/beaker/erlenmeyer/sodawater,
		/obj/item/weapon/reagent_containers/glass/beaker/large/erlenmeyer,
		/obj/item/weapon/paper/diy_soda,
	)


//Smart boxes.
/obj/item/weapon/storage/box/smartbox
	name = "Smart-box"
	desc = "A one-use box that leaves no trash or cardboard behind."
	foldable = null
	storage_slots = BOX_SPACE
	var/one_way = 0 //For one way boxes, you can take out but not put in. Could be moved to /box.


/obj/item/weapon/storage/box/smartbox/remove_from_storage(obj/item/W, atom/new_location, var/force = 0, var/refresh = 1)
	. = ..()
	if(contents.len <= 0) //If this is the last item, kill the box.
		new_location.visible_message("<span class='notice'>\The [src] fizzles away into a glittering dust.</span>")
		qdel(src)

/obj/item/weapon/storage/box/smartbox/attackby(obj/item/W, mob/user)
	if(one_way)
		to_chat(user, "<span class='warning'>\The [src] only lets items leave it!</span>") //Couldn't think of something better to explain the oneway interaction in-game.
		return
	else
		..()

//Clothing-boxes.
/obj/item/weapon/storage/box/smartbox/clothing_box
	name = "box"
	desc = "A smart-box style box for clothing, convenient for distributing clothes."
	icon_state = "clothing_box"
	foldable = null
	storage_slots = BOX_SPACE
	one_way = 1

//Every clothing box will base its label overlay off of the first object in its contents. Keep that in mind when making a new clothing box.
/obj/item/weapon/storage/box/smartbox/clothing_box/New()
    ..()
    if(contents.len)
        var/mutable_appearance/M = new(contents[1])
        M.layer = FLOAT_LAYER
        M.plane = FLOAT_PLANE
        M.transform *= 0.5
        overlays += M

/obj/item/weapon/storage/box/smartbox/clothing_box/chickensuit
	name = "Chicken suit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/chickensuit/New()
	new	/obj/item/clothing/head/chicken(src)
	new /obj/item/clothing/suit/chickensuit(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/chickensuitwhite
	name = "White chicken suit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/chickensuitwhite/New()
	new	/obj/item/clothing/head/chicken/white(src)
	new /obj/item/clothing/suit/chickensuit/white(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/monkeysuit
	name = "Monkey suit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/monkeysuit/New()
	new	/obj/item/clothing/mask/gas/monkeymask(src)
	new /obj/item/clothing/suit/monkeysuit(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/xenosuit
	name = "Xeno suit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/xenosuit/New()
	new /obj/item/clothing/head/xenos(src)
	new /obj/item/clothing/suit/xenos(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/gladiatorsuit
	name = "Gladiator suit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/gladiatorsuit/New()
	new /obj/item/clothing/head/helmet/gladiator(src)
	new /obj/item/clothing/under/gladiator(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/captaincasualoutfit
	name = "Captain's casual box"

/obj/item/weapon/storage/box/smartbox/clothing_box/captaincasualoutfit/New()
	new /obj/item/clothing/head/flatcap(src)
	new /obj/item/clothing/under/gimmick/rank/captain/suit(src)
	new /obj/item/clothing/glasses/gglasses(src)
	new /obj/item/clothing/shoes/jackboots(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/schoolgirloutfit
	name = "School girl outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/schoolgirloutfit/New()
	new /obj/item/clothing/head/kitty(src)
	new /obj/item/clothing/under/schoolgirl(src)
	new /obj/item/clothing/shoes/kneesocks(src)
	new /obj/item/clothing/under/blackskirt(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/pirateoutfit
	name = "Pirate outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/pirateoutfit/New()
	new /obj/item/clothing/glasses/eyepatch(src)
	new /obj/item/clothing/head/pirate(src)
	new /obj/item/clothing/suit/pirate(src)
	new /obj/item/clothing/head/bandana(src)
	new /obj/item/clothing/under/pirate(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/sovietoutfit
	name = "Soviet outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/sovietoutfit/New()
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/under/soviet(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/fakewizard
	name = "Wizard outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/fakewizard/New()
	new /obj/item/clothing/head/wizard/fake(src)
	new /obj/item/clothing/suit/wizrobe/fake(src)
	new /obj/item/weapon/staff(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/witch
	name = "Witch outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/witch/New()
	new /obj/item/clothing/head/witchwig(src)
	new /obj/item/weapon/staff/broom(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/marisa
	name = "Marisa outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/marisa/New()
	new /obj/item/clothing/head/wizard/marisa/fake(src)
	new /obj/item/clothing/suit/wizrobe/marisa/fake(src)
	new /obj/item/weapon/staff/broom(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/sexyclown
	name = "Sexy clown outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/sexyclown/New()
	new /obj/item/clothing/mask/gas/sexyclown(src)
	new /obj/item/clothing/under/sexyclown(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/sexymime
	name = "Sexy mime outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/sexymime/New()
	new /obj/item/clothing/mask/gas/sexymime(src)
	new /obj/item/clothing/under/sexymime(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/jester
	name = "Jester outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/jester/New()
	new /obj/item/clothing/head/jesterhat(src)
	new /obj/item/clothing/under/jester(src)
	new /obj/item/clothing/shoes/jestershoes(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/clownpiece
	name = "Clownpiece outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/clownpiece/New()
	new /obj/item/clothing/head/clownpiece(src)
	new /obj/item/clothing/suit/clownpiece(src)
	new /obj/item/clothing/under/clownpiece(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/plaguedoctor
	name = "Plague doctor outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/plaguedoctor/New()
	new /obj/item/clothing/mask/gas/plaguedoctor(src)
	new /obj/item/clothing/head/plaguedoctorhat(src)
	new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/maid
	name = "Maid outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/maid/New()
	new /obj/item/clothing/suit/maidapron(src)
	new /obj/item/clothing/head/maidhat(src)
	new /obj/item/clothing/under/maid(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/liberty
	name = "Patriot outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/liberty/New()
	new /obj/item/clothing/head/libertyhat(src)
	new /obj/item/clothing/suit/libertycoat(src)
	new /obj/item/clothing/under/libertyshirt(src)
	new /obj/item/clothing/shoes/libertyshoes(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/mega
	name = "Megaman outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/mega/New()
	new /obj/item/clothing/head/helmet/megahelmet(src)
	new /obj/item/clothing/under/mega(src)
	new /obj/item/clothing/gloves/megagloves(src)
	new /obj/item/clothing/shoes/megaboots(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/aviator
	name = "Aviator outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/aviator/New()
	new /obj/item/clothing/head/helmet/aviatorhelmet(src)
	new /obj/item/clothing/under/aviatoruniform(src)
	new /obj/item/clothing/shoes/aviatorboots(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/proto
	name = "Protoman outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/proto/New()
	new /obj/item/clothing/head/helmet/protohelmet(src)
	new /obj/item/clothing/under/proto(src)
	new /obj/item/clothing/gloves/protogloves(src)
	new /obj/item/clothing/shoes/protoboots(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/hastur
	name = "Hastur outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/hastur/New()
	new	/obj/item/clothing/head/hasturhood(src)
	new /obj/item/clothing/suit/hastur(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/owl
	name = "Owl outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/owl/New()
	new /obj/item/clothing/mask/gas/owl_mask(src)
	new /obj/item/clothing/under/owl(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/lordadmiral
	name = "Lord admiral outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/lordadmiral/New()
	new /obj/item/clothing/head/lordadmiralhat(src)
	new /obj/item/clothing/suit/lordadmiral(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/rotten
	name = "Rotten outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/rotten/New()
	new /obj/item/clothing/under/rottensuit(src)
	new /obj/item/clothing/shoes/rottenshoes(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/frank
	name = "Dr. Frank outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/frank/New()
	new /obj/item/clothing/under/franksuit(src)
	new /obj/item/clothing/gloves/frankgloves(src)
	new /obj/item/clothing/shoes/frankshoes(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/mexican //is this offensive?
	name = "Mexican outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/mexican/New()
	new /obj/item/clothing/head/sombrero(src)
	new /obj/item/clothing/suit/poncho(src)
	..()

//Premium boxes, no different than clothing_box, just sorting for clarity.
/obj/item/weapon/storage/box/smartbox/clothing_box/joe
	name = "Sniper outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/joe/New()
	new /obj/item/clothing/head/helmet/joehelmet(src)
	new /obj/item/clothing/under/joe(src)
	new /obj/item/clothing/gloves/joegloves(src)
	new /obj/item/clothing/shoes/joeboots(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/lola
	name = "Fighting clown outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/lola/New()
	new /obj/item/clothing/mask/gas/lola(src)
	new /obj/item/clothing/under/lola(src)
	new /obj/item/clothing/shoes/clown_shoes/lola(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/wizard_robes
	name = "Wizard robe box"

/obj/item/weapon/storage/box/smartbox/clothing_box/wizard_robes/New()
	new /obj/item/clothing/head/wizard(src)
	new /obj/item/clothing/suit/wizrobe(src)
	new /obj/item/clothing/shoes/sandal(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/red_wizrobes
	name = "Red wizard robe box"

/obj/item/weapon/storage/box/smartbox/clothing_box/red_wizrobes/New()
	new /obj/item/clothing/head/wizard/red(src)
	new /obj/item/clothing/suit/wizrobe/red(src)
	new /obj/item/clothing/shoes/sandal(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/clown_wizrobes
	name = "Clown wizard outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/clown_wizrobes/New()
	new /obj/item/clothing/head/wizard/clown(src)
	new /obj/item/clothing/suit/wizrobe/clown(src)
	new /obj/item/clothing/mask/gas/clown_hat/wiz(src)
	new /obj/item/clothing/shoes/sandal/slippers(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/marisa_wiz
	name = "Ordinary witch robe box"

/obj/item/weapon/storage/box/smartbox/clothing_box/marisa_wiz/New()
	new /obj/item/clothing/head/wizard/marisa(src)
	new /obj/item/clothing/suit/wizrobe/marisa(src)
	new /obj/item/clothing/shoes/sandal/marisa/leather(src)
	new /obj/item/weapon/staff/broom(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/hallowiz
	name = "Halloween robe box"

/obj/item/weapon/storage/box/smartbox/clothing_box/hallowiz/New()
	new /obj/item/clothing/head/wizard/hallowiz(src)
	new /obj/item/clothing/suit/wizrobe/hallowiz(src)
	new /obj/item/clothing/shoes/sandal(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/mystic_robes
	name = "Mystic robe box"

/obj/item/weapon/storage/box/smartbox/clothing_box/mystic_robes/New()
	new /obj/item/clothing/head/wizard/mystic(src)
	new /obj/item/clothing/suit/wizrobe/mystic(src)
	new /obj/item/clothing/shoes/sandal(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/winter_wiz
	name = "\"Winter robes\" box"

/obj/item/weapon/storage/box/smartbox/clothing_box/winter_wiz/New()
	new /obj/item/clothing/head/wizard/winter(src)
	new /obj/item/clothing/suit/wizrobe/winter(src)
	new /obj/item/clothing/shoes/sandal(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/magician
	name = "Magician outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/magician/New()
	new /obj/item/clothing/head/that/magic(src)
	new /obj/item/clothing/suit/wizrobe/magician(src)
	new /obj/item/clothing/shoes/sandal/marisa/leather(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/necromancer
	name = "Necromancer robe box"

/obj/item/weapon/storage/box/smartbox/clothing_box/necromancer/New()
	new /obj/item/clothing/head/wizard/necro(src)
	new /obj/item/clothing/suit/wizrobe/necro(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/pharaoh
	name = "Pharaoh robe box"

/obj/item/weapon/storage/box/smartbox/clothing_box/pharaoh/New()
	new /obj/item/clothing/head/pharaoh(src)
	new /obj/item/clothing/suit/wizrobe/pharaoh(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/clownpsyche
	name = "Clown psychedelic outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/clownpsyche/New()
	new /obj/item/clothing/mask/gas/clownmaskpsyche(src)
	new /obj/item/weapon/storage/backpack/clownpackpsyche(src)
	new /obj/item/clothing/under/clownpsyche(src)
	new /obj/item/clothing/shoes/clownshoespsyche(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/gemsuit
	name = "Gemsuit outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/gemsuit/New()
	new /obj/item/clothing/suit/space/rig/wizard(src)
	new /obj/item/clothing/head/helmet/space/rig/wizard(src)
	new /obj/item/clothing/gloves/purple(src)
	new /obj/item/clothing/shoes/sandal(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/surveyorset
	name = "hos surveyor outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/surveyorset/New()
	new /obj/item/clothing/suit/armor/hos/surveyor(src)
	new /obj/item/clothing/head/HoS/surveyor(src)
	..()

/obj/item/weapon/storage/box/smartbox/clothing_box/banana_set
	name = "Banana outfit box"

/obj/item/weapon/storage/box/smartbox/clothing_box/banana_set/New()
	new /obj/item/clothing/suit/banana_suit(src)
	new /obj/item/clothing/head/banana_hat(src)
	..()

/obj/item/weapon/storage/box/biscuit
	name = "biscuit box"
	desc = "Just the right way to start your day."
	icon = 'icons/obj/food_container.dmi'
	icon_state = "biscuitbox"
	storage_slots = 6
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks/risenshiny")
	foldable = /obj/item/stack/sheet/cardboard
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type = RECYK_MISC

/obj/item/weapon/storage/box/biscuit/New()
	..()
	for(var/i = 1 to 6)
		new /obj/item/weapon/reagent_containers/food/snacks/risenshiny(src)

/obj/item/weapon/storage/box/chemistry_kit
	name = "basic chemistry set"
	desc = "A box containing the basics for chemistry."

/obj/item/weapon/storage/box/chemistry_kit/New()
	new /obj/item/weapon/reagent_containers/glass/beaker/erlenmeyer(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/erlenmeyer(src)
	new /obj/item/weapon/electrolyzer(src)
	new /obj/item/weapon/cell/high(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/large/plasma(src)
	..()

/obj/item/weapon/storage/box/dorf
	name = "dwarven equipment box"
	desc = "Contains all the things a hardened dwarf needs to survive."
	icon_state = "dorf"

/obj/item/weapon/storage/box/dorf/New()
	..()
	new /obj/item/weapon/pickaxe(src)
	new /obj/item/clothing/glasses/scanner/meson(src)
	new /obj/item/blueprints/construction_permit(src)
	new /obj/item/weapon/reagent_containers/food/snacks/dorfbiscuit(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)

/obj/item/weapon/storage/box/demolition
	icon_state = "box_of_doom"
	items_to_spawn = list(
		/obj/item/device/modkit/demolition,
		/obj/item/ammo_storage/magazine/lawgiver/demolition = 2,
	)
