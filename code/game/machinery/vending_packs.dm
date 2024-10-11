/obj/structure/vendomatpack
	name = "Vending machine recharge pack"
	desc = "Drag it on a vending machine to replenish its products."
	icon = 'icons/obj/vending_pack.dmi'
	icon_state = "generic"
	density = 1
	flags = FPRINT
	var/targetvendomat = /obj/machinery/vending
	var/list/stock = list()
	var/list/secretstock = list()
	var/list/preciousstock = list()
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()

//////CUSTOM PACKS///////

/obj/structure/vendomatpack/custom
	name = "empty recharge pack"
	targetvendomat = /obj/machinery/vending/sale
	icon_state = "generic"

/obj/structure/vendomatpack/custom/New()
	..()
	overlays += image('icons/obj/vending_pack.dmi',"emptypack")

/obj/structure/vendomatpack/custom/attackby(obj/item/O, mob/user)
	var/list/nuke_disks = O.search_contents_for(/obj/item/weapon/disk/nuclear)
	if(nuke_disks.len) //There's something, it's a nuke disk, no need to recheck
		to_chat(user, "<span class='warning'>Suddenly your hand stops responding. You can't put that in, something forbidden is within it.</span>")
		return
	if(istype(O, /obj/item/weapon/disk/nuclear)) //Need to check separately if it's the thing you're shoving in
		to_chat(user, "<span class='warning'>Suddenly your hand stops responding. You can't put that in a vending machine.</span>")
		return
	user.drop_item(O, src)

/obj/structure/vendomatpack/custom/attack_hand(mob/user)
	var/selected_item = input("Select an item to remove", "[src]") as null|anything in contents
	var/obj/item/I = selected_item
	if(I != null && loc)
		if(!Adjacent(user))
			return
		user.put_in_hands(I)

/obj/structure/vendomatpack/undefined
	//a placeholder for vending machines that don't have their own recharge packs

/obj/structure/vendomatpack/partial
	name = "Used recharge pack"
	desc = "A partially filled recharge pack that can still be used on a vending machine."

/obj/structure/vendomatpack/boozeomat
	name = "Booze-O-Mat recharge pack"
	targetvendomat = /obj/machinery/vending/boozeomat
	icon_state = "boozeomat"

/obj/structure/vendomatpack/assist
	name = "Vendomat recharge pack"
	targetvendomat = /obj/machinery/vending/assist
	icon_state = "vendomat"

/obj/structure/vendomatpack/coffee
	name = "Hot Drinks machine recharge pack"
	targetvendomat = /obj/machinery/vending/coffee
	icon_state = COFFEE

/obj/structure/vendomatpack/snack
	name = "Getmore Chocolate Corp recharge pack"
	targetvendomat = /obj/machinery/vending/snack
	icon_state = "snack"

/obj/structure/vendomatpack/cola
	name = "Robust Softdrinks recharge pack"
	targetvendomat = /obj/machinery/vending/cola
	icon_state = "Cola_Machine"

/obj/structure/vendomatpack/cigarette
	name = "Cigarette machine recharge pack"
	targetvendomat = /obj/machinery/vending/cigarette
	icon_state = "cigs"

/obj/structure/vendomatpack/medical
	name = "NanoMed recharge pack"
	targetvendomat = /obj/machinery/vending/medical
	icon_state = "med"

/obj/structure/vendomatpack/security
	name = "SecTech recharge pack"
	targetvendomat = /obj/machinery/vending/security
	icon_state = "sec"

/obj/structure/vendomatpack/hydronutrients
	name = "NutriMax recharge pack"
	targetvendomat = /obj/machinery/vending/hydronutrients
	icon_state = "nutri"

/obj/structure/vendomatpack/hydroseeds
	name = "MegaSeed Servitor recharge pack"
	targetvendomat = /obj/machinery/vending/hydroseeds
	icon_state = "seeds"

/obj/structure/vendomatpack/dinnerware
	name = "Dinnerware recharge pack"
	targetvendomat = /obj/machinery/vending/dinnerware
	icon_state = "dinnerware"

/obj/structure/vendomatpack/sovietsoda
	name = "BODA recharge pack"
	targetvendomat = /obj/machinery/vending/sovietsoda
	icon_state = "sovietsoda"

/obj/structure/vendomatpack/tool
	name = "YouTool recharge pack"
	targetvendomat = /obj/machinery/vending/tool
	icon_state = "tool"

/obj/structure/vendomatpack/engivend
	name = "Engi-Vend recharge pack"
	targetvendomat = /obj/machinery/vending/engivend
	icon_state = "engivend"

/obj/structure/vendomatpack/building
	name = "Habitat Depot recharge pack"
	targetvendomat = /obj/machinery/vending/building
	icon_state = "building"

/obj/structure/vendomatpack/autodrobe
	name = "AutoDrobe recharge pack"
	targetvendomat = /obj/machinery/vending/autodrobe
	icon_state = "theater"

/obj/structure/vendomatpack/hatdispenser
	name = "Hatlord 9000 recharge pack"
	targetvendomat = /obj/machinery/vending/hatdispenser
	icon_state = "hats"

/obj/structure/vendomatpack/suitdispenser
	name = "Suitlord 9000 recharge pack"
	targetvendomat = /obj/machinery/vending/suitdispenser
	icon_state = "suits"

/obj/structure/vendomatpack/shoedispenser
	name = "Shoelord 9000 recharge pack"
	targetvendomat = /obj/machinery/vending/shoedispenser
	icon_state = "shoes"

/obj/structure/vendomatpack/discount
	name = "Discount Dan's recharge pack"
	targetvendomat = /obj/machinery/vending/discount
	icon_state = DISCOUNT

/obj/structure/vendomatpack/groans
	name = "Groans Soda recharge pack"
	targetvendomat = /obj/machinery/vending/groans
	icon_state = "groans"

/obj/structure/vendomatpack/magivend
	name = "MagiVend recharge pack"
	targetvendomat = /obj/machinery/vending/magivend
	icon_state = "MagiVend"

/obj/structure/vendomatpack/nazivend
	name = "Nazivend recharge pack"
	targetvendomat = /obj/machinery/vending/nazivend
	icon_state = "nazi"

/obj/structure/vendomatpack/sovietvend
	name = "KomradeVendtink recharge pack"
	targetvendomat = /obj/machinery/vending/sovietvend
	icon_state = "soviet"

/obj/structure/vendomatpack/nuka
	name = "Nuka Cola recharge pack"
	targetvendomat = /obj/machinery/vending/nuka
	icon_state = "nuka"

/obj/structure/vendomatpack/chapelvend
	name = "Chapelvend recharge pack"
	targetvendomat = /obj/machinery/vending/chapel
	icon_state = "chapel"

/obj/structure/vendomatpack/barbervend
	name = "Barbervend recharge pack"
	targetvendomat = /obj/machinery/vending/barber
	icon_state = "barber"

/obj/structure/vendomatpack/makeup
	name = "Shuo-Cai Cosmetics recharge pack"
	targetvendomat = /obj/machinery/vending/makeup
	icon_state = "makeup"

/obj/structure/vendomatpack/offlicence
	name = "Offworld Off-Licence recharge pack"
	targetvendomat = /obj/machinery/vending/offlicence
	icon_state = "offlicence"

/obj/structure/vendomatpack/circus
	name = "Circus of Values recharge pack"
	targetvendomat = /obj/machinery/vending/circus
	icon_state = "circus"

/obj/structure/vendomatpack/mining
	name = "Dwarven Mining Equipment recharge pack"
	targetvendomat = /obj/machinery/vending/mining
	icon_state = "mining"

/obj/structure/vendomatpack/games
	name = "Al's Fun And Games recharge pack"
	targetvendomat = /obj/machinery/vending/games
	icon_state = "games"

/obj/structure/vendomatpack/team_security
	name = "Team Security recharge pack"
	targetvendomat = /obj/machinery/vending/team_security
	icon_state = "team_security"

/obj/structure/vendomatpack/telecomms
	name = "Telecommunications Supplies recharge pack"
	targetvendomat = /obj/machinery/vending/telecomms
	icon_state = "telecomms"

//////EMPTY PACKS//////

/obj/item/emptyvendomatpack
	name = "Empty vendomat recharge pack"
	desc = "You could return it to cargo or just flatten it."
	icon = 'icons/obj/vending_pack.dmi'
	icon_state = "generic"
	item_state = "syringe_kit"
	w_class = W_CLASS_LARGE
	w_type = RECYK_WOOD
	flags = FPRINT
	flammable = TRUE

	var/foldable = /obj/item/stack/sheet/cardboard
	var/foldable_amount = 4


/obj/item/emptyvendomatpack/attack_self()
	to_chat(usr, "<span class='notice'>You fold [src] flat.</span>")
	new src.foldable(get_turf(src),foldable_amount)
	qdel(src)


//////CARGO STACKS OF PACKS//////

/obj/structure/stackopacks
	name = "stack of recharge packs"
	desc = "A bunch of hefty carboard boxes."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "stackopack"
	density = 1
	flags = FPRINT

/obj/structure/stackopacks/attack_hand(mob/user as mob)
	to_chat(user, "<span class='notice'>You need some wirecutters to remove the coil first!</span>")
	return

/obj/structure/stackopacks/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_wirecutter(user) || istype(W,/obj/item/weapon/shard) || istype(W,/obj/item/weapon/kitchen/utensil/knife/large) || istype(W,/obj/item/tool/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/kitchen/utensil/knife))
		var/turf/T = get_turf(src)
		for(var/obj/O in contents)
			O.forceMove(T)
		to_chat(user, "<span class='notice'>You remove the protective coil.</span>")
		qdel(src)
	else
		return attack_hand(user)

/obj/structure/stackopacks/attack_animal(mob/living/simple_animal/M as mob)
	var/turf/T = get_turf(src)
	for(var/obj/O in contents)
		O.forceMove(T)
	to_chat(M, "<span class='notice'>You rip the protective coil apart.</span>")
	qdel(src)

/obj/structure/stackopacks/attack_paw(mob/M as mob)
	var/turf/T = get_turf(src)
	for(var/obj/O in contents)
		O.forceMove(T)
	to_chat(M, "<span class='notice'>You rip the protective coil apart.</span>")
	qdel(src)

/obj/structure/stackopacks/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	var/turf/T = get_turf(src)
	for(var/obj/O in contents)
		O.forceMove(T)
	to_chat(M, "<span class='notice'>You rip the protective coil apart.</span>")
	qdel(src)

/obj/structure/vendomatpack/zamsnax
	name = "Zam Snax recharge pack"
	targetvendomat = /obj/machinery/vending/zamsnax
	icon_state = "ZAMsnax"

/obj/structure/vendomatpack/lotto
	name = "Lotto Ticket recharge pack"
	targetvendomat = /obj/machinery/vending/lotto
	icon_state = "sale"

/obj/structure/vendomatpack/syndicatesuits
	name = "Syndicate Suits recharge pack"
	targetvendomat = /obj/machinery/vending/coffee
	icon_state = "syndicatesuits"

/obj/structure/vendomatpack/meat
	name = "Meat Fridge recharge pack"
	desc = "You could return it to cargo or just flatten it. The label looks like it was partially cut off."
	targetvendomat = /obj/machinery/vending/meat
	icon_state = "meat"

/obj/structure/vendomatpack/artsupply
	name = "\improper Le Patron des Arts recharge pack"
	targetvendomat = /obj/machinery/vending/art
	icon_state = "circus"
