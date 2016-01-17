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
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/weapon/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

	autoignition_temperature = 522 // Kelvin
	fire_fuel = 2

/obj/item/weapon/storage/box/large
	name = "large box"
	desc = "You could build a fort with this."
	icon_state = "largebox"
	item_state = "largebox"
	w_class = 42 // Big, bulky.
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amount = 4 // Takes 4 to make. - N3X
	starting_materials = list(MAT_CARDBOARD = 15000)
	storage_slots = 21
	max_combined_w_class = 42 // 21*2

	autoignition_temperature = 530 // Kelvin
	fire_fuel = 3

/obj/item/weapon/storage/box/surveillance
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "Dpacket"
	item_state = "Dpacket"
	w_class = 1
	foldable = null
	New()
		..()
		contents = list()
		sleep(1)
		for(var/i = 1 to 5)
			new /obj/item/device/camera_bug(src)

/obj/item/weapon/storage/box/survival
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/clothing/mask/breath(src)
		new /obj/item/weapon/tank/emergency_oxygen(src)
		return

/obj/item/weapon/storage/box/survival/vox
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/clothing/mask/breath/vox(src)
		new /obj/item/weapon/tank/emergency_nitrogen(src)
		return

/obj/item/weapon/storage/box/engineer/
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/clothing/mask/breath(src)
		new /obj/item/weapon/tank/emergency_oxygen/engi(src)
		return


/obj/item/weapon/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/clothing/gloves/latex(src)

/obj/item/weapon/storage/box/bgloves
	name = "box of black gloves"
	desc = "Contains black gloves."
	icon_state = "bgloves"

	New()
		..()
		for(var/i = 0, i < 7, i++)
			new /obj/item/clothing/gloves/black(src)

/obj/item/weapon/storage/box/sunglasses
	name = "box of sunglasses"
	desc = "Contains sunglasses."
	icon_state = "sunglass"

	New()
		..()
		for(var/i = 0, i < 7, i++)
			new /obj/item/clothing/glasses/sunglasses(src)

/obj/item/weapon/storage/box/masks
	name = "sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/clothing/mask/surgical(src)


/obj/item/weapon/storage/box/syringes
	name = "syringes"
	desc = "A biohazard alert warning is printed on the box"
	icon_state = "syringe"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/reagent_containers/syringe(src)

/obj/item/weapon/storage/box/beakers
	name = "beaker box"
	icon_state = "beaker"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/reagent_containers/glass/beaker(src)

/obj/item/weapon/storage/box/injectors
	name = "\improper DNA injectors"
	desc = "This box contains injectors it seems."

	New()
		..()
		for(var/i=0,i<3,i++)
			new /obj/item/weapon/dnainjector/nofail/h2m(src)
		for(var/i=0,i<3,i++)
			new /obj/item/weapon/dnainjector/nofail/m2h(src)


/obj/item/weapon/storage/box/blanks
	name = "box of blank shells"
	desc = "It has a picture of a gun and several warning symbols on the front."

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/ammo_casing/shotgun/blank(src)



/obj/item/weapon/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/grenade/flashbang(src)

/obj/item/weapon/storage/box/smokebombs
	name = "box of smokebombs"
	icon_state = "smokebomb"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/grenade/smokebomb(src)

/obj/item/weapon/storage/box/stickybombs
	name = "box of stickybombs"
	icon_state = "stickybomb"

	New()
		..()
		for(var/i=0,i<24,i++)
			new /obj/item/stickybomb(src)

/obj/item/weapon/storage/box/emps
	name = "emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"

	New()
		..()
		for(var/i=0,i<5,i++)
			new /obj/item/weapon/grenade/empgrenade(src)

/obj/item/weapon/storage/box/foam
	name = "metal foam grenades"
	desc = "A box containing 7 metal foam grenades"
	icon_state = "metalfoam"

	New()
		..()
		for(var/i = 0, i < 7, i++)
			new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)

/obj/item/weapon/storage/box/trackimp
	name = "tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"

	New()
		..()
		for(var/i=0,i<4,i++)
			new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantpad(src)
		new /obj/item/weapon/locator(src)

/obj/item/weapon/storage/box/chemimp
	name = "chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"

	New()
		..()
		for(var/i=0,i<5,i++)
			new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantpad(src)

/obj/item/weapon/storage/box/bolas
	name = "bolas box"
	desc = "Box of bolases. Make sure to take them out before throwing them."
	icon_state = "bolas"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/legcuffs/bolas(src)


/obj/item/weapon/storage/box/rxglasses
	name = "prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/clothing/glasses/regular(src)

/obj/item/weapon/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

	New()
		..()
		for(var/i=0,i<6,i++)
			new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)

/obj/item/weapon/storage/box/cdeathalarm_kit
	name = "Death Alarm Kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state = "syringe_kit"

	New()
		..()
		new /obj/item/weapon/implanter(src)
		for(var/i=0,i<6,i++)
			new /obj/item/weapon/implantcase/death_alarm(src)

/obj/item/weapon/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

	New()
		..()
		for(var/i=0,i<6,i++)
			new /obj/item/weapon/reagent_containers/food/condiment(src)



/obj/item/weapon/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/reagent_containers/food/drinks/sillycup(src)


/obj/item/weapon/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"

	New()
		..()
		for(var/i=0,i<6,i++)
			new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)

/obj/item/weapon/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube")
	New()
		..()
		if(src.type == /obj/item/weapon/storage/box/monkeycubes)
			for(var/i = 1; i <= 5; i++)
				new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src)

/obj/item/weapon/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Ahdomai. Just add water!"
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube(src)

/obj/item/weapon/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube(src)

/obj/item/weapon/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube(src)

/obj/item/weapon/storage/box/ids
	name = "spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/card/id(src)

/obj/item/weapon/storage/box/seccarts
	name = "Spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/cartridge/security(src)


/obj/item/weapon/storage/box/handcuffs
	name = "spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/handcuffs(src)

/obj/item/weapon/storage/box/mousetraps
	name = "box of Pest-B-Gon Mousetraps"
	desc = "<span class='danger'>WARNING:</span> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"

	New()
		..()
		for(var/i=0,i<6,i++)
			new /obj/item/device/assembly/mousetrap(src)

/obj/item/weapon/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."

	New()
		..()
		for(var/i=0,i<7,i++)
			new /obj/item/weapon/storage/pill_bottle(src)

/obj/item/weapon/storage/box/lethalshells
	name = "lethal shells"
	icon_state = "lethal shells"

	New()
		..()
		for(var/i=0,i<15,i++)
			new /obj/item/ammo_casing/shotgun(src)

/obj/item/weapon/storage/box/beanbagshells
	name = "bean bag shells"
	icon_state = "bean bag shells"

	New()
		..()
		for(var/i=0,i<15,i++)
			new /obj/item/ammo_casing/shotgun/beanbag(src)

/obj/item/weapon/storage/box/stunshells
	name = "stun shells"
	icon_state = "stun shells"

	New()
		..()
		for(var/i=0,i<15,i++)
			new /obj/item/ammo_casing/shotgun/stunshell(src)

/obj/item/weapon/storage/box/dartshells
	name = "shotgun darts"
	icon_state = "dart shells"

	New()
		..()
		for(var/i=0,i<15,i++)
			new /obj/item/ammo_casing/shotgun/dart(src)

/obj/item/weapon/storage/box/labels
	name = "label roll box"
	desc = "A box of refill rolls for a hand labeler."
	icon_state = "labels"

	New()
		..()
		for(var/i=1; i <= storage_slots; i++)
			new /obj/item/device/label_roll(src)

/obj/item/weapon/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_hold = list("/obj/item/toy/snappop")
	New()
		..()
		for(var/i=1; i <= storage_slots; i++)
			new /obj/item/toy/snappop(src)

/obj/item/weapon/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"
	New()
		..()
		for (var/i; i < storage_slots; i++)
			new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)

/obj/item/weapon/storage/box/mugs
	name = "box of mugs"
	desc = "It's a box of mugs."
	icon_state = "box"

	New()
		..()
		for(var/i=0,i<6,i++)
			new /obj/item/weapon/reagent_containers/food/drinks/mug(src)

// TODO Change this to a box/large. - N3X
/obj/item/weapon/storage/box/lights
	name = "replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots=21
	can_hold = list("/obj/item/weapon/light/tube", "/obj/item/weapon/light/bulb")
	max_combined_w_class = 21
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/lights/bulbs/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/bulb(src)

/obj/item/weapon/storage/box/lights/tubes
	name = "replacement tubes"
	icon_state = "lighttube"

/obj/item/weapon/storage/box/lights/tubes/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/tube(src)

/obj/item/weapon/storage/box/lights/mixed
	name = "replacement lights"
	icon_state = "lightmixed"

/obj/item/weapon/storage/box/lights/mixed/New()
	..()
	for(var/i = 0; i < 14; i++)
		new /obj/item/weapon/light/tube(src)
	for(var/i = 0; i < 7; i++)
		new /obj/item/weapon/light/bulb(src)

/obj/item/weapon/storage/box/lights/tubes/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/tube(src)

/obj/item/weapon/storage/box/lights/he
	name = "high efficiency lights"
	icon_state = "lightmixed"

/obj/item/weapon/storage/box/lights/he/New()
	..()
	for(var/i = 0; i < 14; i++)
		new /obj/item/weapon/light/tube/he(src)
	for(var/i = 0; i < 7; i++)
		new /obj/item/weapon/light/bulb/he(src)
