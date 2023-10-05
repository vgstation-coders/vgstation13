/*
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	Contains:
 *		Trash Bag
 *		Mining Satchel
 *		Plant Bag
 *		Sheet Snatcher
 *
 *	-Sayu
 */

//  Generic non-item
/obj/item/weapon/storage/bag
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	display_contents_with_number = FALSE // UNStABLE AS FuCK, turn on when it stops crashing clients
	use_to_pickup = TRUE
	slot_flags = SLOT_BELT
	flags = FPRINT
	autoignition_temperature = AUTOIGNITION_FABRIC

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/weapon/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/trash.dmi'
	icon_state = "trashbag0"
	item_state = "trashbag"

	w_class = W_CLASS_LARGE
	fits_max_w_class = W_CLASS_SMALL
	storage_slots = 21
	max_combined_w_class = 21
	can_only_hold = list() // any
	cant_hold = list("/obj/item/weapon/disk/nuclear", "/obj/item/weapon/pinpointer") //No janiborg, stop stealing the pinpointer with your bag.
	slot_flags = SLOT_BELT | SLOT_OCLOTHING
	no_storage_slot = list(slot_wear_suit) //when worn on the suit slot it will function purely as a suit and will not store items

/obj/item/weapon/storage/bag/trash/update_icon()
	if(contents.len == 0)
		icon_state = "trashbag0"
		slowdown = 1
	else if(contents.len < 12)
		icon_state = "trashbag1"
		slowdown = 1.4
	else if(contents.len < 21)
		icon_state = "trashbag2"
		slowdown = 1.6
	else
		icon_state = "trashbag3"
		slowdown = 1.8

/obj/item/weapon/storage/bag/trash/bio
	name = "hazardous waste bag"
	desc = "A heavy-duty sterilized garbage bag for handling infectious medical waste and sharps."
	icon_state = "biobag0"
	item_state = "biobag"

	sterility = 100
	fits_max_w_class = W_CLASS_LARGE
	can_only_hold = list(
		"/obj/item/trash",
		"/obj/item/weapon/shard",
		"/obj/item/weapon/reagent_containers",
		"/obj/item/organ",
		"/obj/item/stack/medical",
	)
	slot_flags = SLOT_BELT

/obj/item/weapon/storage/bag/trash/bio/update_icon()
	if(contents.len == 0)
		icon_state = "biobag0"
		slowdown = 1
	else if(contents.len < 12)
		icon_state = "biobag1"
		slowdown = 1.4
	else if(contents.len < 21)
		icon_state = "biobag2"
		slowdown = 1.6
	else
		icon_state = "biobag3"
		slowdown = 1.8

// -----------------------------
//        Plastic Bag
// -----------------------------

/obj/item/weapon/storage/bag/plasticbag
	name = "plastic bag"
	desc = "It's a very flimsy, very noisy alternative to a bag."
	icon = 'icons/obj/trash.dmi'
	icon_state = "plasticbag"
	item_state = "plasticbag"
	species_fit = list(INSECT_SHAPED)
	w_class = W_CLASS_LARGE
	fits_max_w_class = W_CLASS_SMALL
	storage_slots = 21
	can_only_hold = list() // any
	cant_hold = list("/obj/item/weapon/disk/nuclear")
	body_parts_covered = FULL_HEAD|BEARD
	slot_flags = SLOT_BELT | SLOT_HEAD
	clothing_flags = BLOCK_BREATHING | BLOCK_GAS_SMOKE_EFFECT
	no_storage_slot = list(slot_head)
	foldable = /obj/item/folded_bag
	starting_materials = list(MAT_PLASTIC = 3*CC_PER_SHEET_MISC) //Recipe calls for 3 sheets
	w_type = RECYK_PLASTIC

/obj/item/weapon/storage/bag/plasticbag/suicide_act(var/mob/living/user)
	user.visible_message("<span class='danger'>[user] puts the [src.name] over \his head and tightens the handles around \his neck! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_OXYLOSS)


// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/weapon/storage/bag/ore
	name = "\improper Mining Satchel" //need the improper for the
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_satchel"
	slot_flags = SLOT_BELT | SLOT_POCKET
	w_class = W_CLASS_MEDIUM
	storage_slots = 50
	fits_max_w_class = 3
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	can_only_hold = list("/obj/item/stack/ore")
	display_contents_with_number = TRUE

/obj/item/weapon/storage/bag/ore/auto
	name = "automatic ore loader"
	desc = "A mining satchel with a built-in inserter used to automatically move ore over short distances."
	icon_state = "tech_satchel"
	actions_types = list(/datum/action/item_action/toggle_auto_handling)
	var/handling = FALSE

/datum/action/item_action/toggle_auto_handling
	name = "Toggle Ore Loader"

/datum/action/item_action/toggle_auto_handling/Trigger()
	var/obj/item/weapon/storage/bag/ore/auto/T = target
	var/mob/user = usr

	if(!usr)
		if(!ismob(T.loc))
			return
		user = T.loc
	if(!istype(T))
		return

	T.handling = !T.handling

	to_chat(user, "You turn \the [T.name] [T.handling? "on":"off"].")

	if(T.handling == TRUE)
		user.register_event(/event/moved, T, /obj/item/weapon/storage/bag/ore/auto/proc/mob_moved)
	else
		user.unregister_event(/event/moved, T, /obj/item/weapon/storage/bag/ore/auto/proc/mob_moved)

/obj/item/weapon/storage/bag/ore/auto/proc/auto_collect(var/turf/collect_loc)
	for(var/obj/item/stack/ore/ore in collect_loc.contents)
		preattack(collect_loc, src, TRUE)
		break

/obj/item/weapon/storage/bag/ore/auto/proc/auto_fill(var/mob/holder)
	var/obj/structure/ore_box/box = null
	if(istype(holder.pulling, /obj/structure/ore_box))
		box = holder.pulling
	if(box)
		for(var/obj/item/stack/ore/ore in contents)
			if(box.try_add_ore(ore))
				remove_from_storage(ore)
				qdel(ore)

/obj/item/weapon/storage/bag/ore/auto/proc/mob_moved(atom/movable/mover)
	if(isrobot(mover))
		var/mob/living/silicon/robot/S = mover
		if(locate(src) in S.get_all_slots())
			auto_collect(get_turf(src))
			auto_fill(mover)
	else if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.is_holding_item(src))
			auto_collect(get_turf(src))
			auto_fill(living_mover)

/obj/item/weapon/storage/bag/ore/auto/pickup(mob/user)
	if(handling)
		user.register_event(/event/moved, src, nameof(src::mob_moved()))

/obj/item/weapon/storage/bag/ore/auto/dropped(mob/user)
	user.unregister_event(/event/moved, src, nameof(src::mob_moved()))

// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/weapon/storage/bag/plants
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "plantbag"
	name = "Plant Bag"
	storage_slots = 50; //the number of plant pieces it can carry.
	fits_max_w_class = 3
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	w_class = W_CLASS_TINY
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks/grown","/obj/item/seeds","/obj/item/weapon/grown", "/obj/item/weapon/reagent_containers/food/snacks/meat", "/obj/item/weapon/reagent_containers/food/snacks/egg", "/obj/item/weapon/reagent_containers/food/snacks/honeycomb")
	display_contents_with_number = TRUE

/obj/item/weapon/storage/bag/plants/CtrlClick()
	if(isturf(loc))
		return ..()
	if(!usr.isUnconscious() && Adjacent(usr))
		change()
		return
	return ..()

var/global/list/plantbag_colour_choices = list("plantbag", "green red stripe", "green blue stripe", "green yellow stripe", "green purple stripe", "green lime stripe", "green black stripe", "green white stripe", "cyan", "cyan red stripe", "cyan blue stripe", "cyan yellow stripe", "cyan purple stripe", "cyan lime stripe", "cyan black stripe", "cyan white stripe")
/obj/item/weapon/storage/bag/plants/verb/change()
	set name = "Change Bag Colour"
	set category = "Object"
	set src in usr
	var/plantbag_colour
	plantbag_colour = input("Select Colour to change it to", "Plant Bag Colour", plantbag_colour) as null|anything in plantbag_colour_choices
	if(!plantbag_colour||(usr.stat))
		return
	icon_state = plantbag_colour

/obj/item/weapon/storage/bag/plants/portactor
	name = "portable seed extractor"
	desc = "A heavy-duty, yet portable seed extractor. Less efficient than the stationary machine, this version can extract at most two seeds per sample."
	icon_state = "portaseeder"
	actions_types = list(/datum/action/item_action/dissolve_contents)

/datum/action/item_action/dissolve_contents
	name = "Dissolve Contents"
	desc = "Activate to convert the harvested contents into plantable seeds."

/datum/action/item_action/dissolve_contents/Trigger()
	var/obj/item/weapon/storage/bag/plants/portactor/P = target
	var/mob/user = usr

	if(!usr)
		if(!ismob(P.loc))
			return
		user = P.loc

	if(!istype(P) || !user)
		return

	if(P.contents)
		var/played = FALSE
		for(var/obj/item/I in P.contents)
			if(seedify(I) && !played)
				playsound(P, 'sound/machines/juicerfast.ogg', 50, 1)
				played = TRUE
		P.orient2hud(user)
		if(user.s_active)
			user.s_active.show_to(user)


/obj/item/weapon/storage/bag/plants/portactor/CtrlClick()
	return

// -----------------------------
//          Materials bag
// -----------------------------

/obj/item/weapon/storage/bag/materials
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "matsbag"
	name = "Materials Bag"
	desc = "Can hold most materials and shards."
	storage_slots = 50; //the number of plant pieces it can carry.
	fits_max_w_class = 3
	max_combined_w_class = 200
	w_class = W_CLASS_TINY
	can_only_hold = list("/obj/item/stack/sheet","/obj/item/weapon/shard")
	display_contents_with_number = TRUE

// -----------------------------
//          Food bag
// -----------------------------

/obj/item/weapon/storage/bag/food
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "foodbag0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/backpacks_n_bags.dmi', "right_hand" = 'icons/mob/in-hand/right/backpacks_n_bags.dmi')
	name = "Food Delivery Bag"
	storage_slots = 14; //the number of food items it can carry.
	fits_max_w_class = 3
	max_combined_w_class = 28 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	w_class = W_CLASS_MEDIUM
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks","/obj/item/weapon/reagent_containers/food/drinks","/obj/item/weapon/reagent_containers/food/condiment","/obj/item/weapon/kitchen/utensil")

/obj/item/weapon/storage/bag/food/update_icon()
	if(contents.len < 1)
		icon_state = "foodbag0"
	else icon_state = "foodbag1"

/obj/item/weapon/storage/bag/food/menu1/New()
	..()
	new/obj/item/weapon/reagent_containers/food/snacks/monkeyburger(src)//6 nutriments
	new/obj/item/weapon/reagent_containers/food/snacks/fries/cone(src)//4 nutriments
	new/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola(src)//-3 drowsy
	new/obj/item/weapon/reagent_containers/food/condiment/small/ketchup(src)
	new/obj/item/weapon/reagent_containers/food/condiment/small/mayo(src)
	update_icon()

/obj/item/weapon/storage/bag/food/menu2/New()
	..()
	new/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger(src)//14 nutriments
	new/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/punnet(src)//6 nutriments
	new/obj/item/weapon/kitchen/utensil/fork/plastic(src)
	new/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind(src)//-7 drowsy, -1 sleepy
	new/obj/item/weapon/reagent_containers/food/condiment/small/ketchup(src)
	new/obj/item/weapon/reagent_containers/food/condiment/small/mayo(src)
	update_icon()

/obj/item/weapon/storage/bag/zam_food
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "Zam_foodbag0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/backpacks_n_bags.dmi', "right_hand" = 'icons/mob/in-hand/right/backpacks_n_bags.dmi')
	name = "Zam Food Bag"
	desc = "A gift from the mothership to keep your Zam drinks cool and your Zam meals warm. Praise the mothership!"
	storage_slots = 14
	fits_max_w_class = 3
	max_combined_w_class = 28
	w_class = W_CLASS_MEDIUM
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks","/obj/item/weapon/reagent_containers/food/drinks","/obj/item/weapon/reagent_containers/food/condiment","/obj/item/weapon/kitchen/utensil")

/obj/item/weapon/storage/bag/zam_food/update_icon()
	if(contents.len < 1)
		icon_state = "Zam_foodbag0"
	else icon_state = "Zam_foodbag1"

/obj/item/weapon/storage/bag/zam_food/zam_menu1/New()
	..()
	new/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1/wrapped(src)//18 nutriments
	new/obj/item/weapon/reagent_containers/food/snacks/zamitos(src)
	new/obj/item/weapon/kitchen/utensil/fork/teflon(src)
	new/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_trustytea(src)//tea you can't trust
	new/obj/item/weapon/reagent_containers/food/condiment/small/zammild(src)
	new/obj/item/weapon/reagent_containers/food/condiment/small/zamspicytoxin(src)
	update_icon()

/obj/item/weapon/storage/bag/zam_food/zam_menu2/New()
	..()
	new/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2/wrapped(src)//15 nutriments
	new/obj/item/weapon/reagent_containers/food/snacks/zamitos(src)
	new/obj/item/weapon/kitchen/utensil/fork/teflon(src)
	new/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_formicfizz(src)//yum yum melts my tum
	new/obj/item/weapon/reagent_containers/food/condiment/small/zammild(src)
	new/obj/item/weapon/reagent_containers/food/condiment/small/zamspicytoxin(src)
	update_icon()

/obj/item/weapon/storage/bag/zam_food/zam_menu3/New()
	..()
	new/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3/wrapped(src)//12 nutriments
	new/obj/item/weapon/reagent_containers/food/snacks/zamitos(src)
	new/obj/item/weapon/kitchen/utensil/fork/teflon(src)
	new/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_sulphuricsplash(src)
	new/obj/item/weapon/reagent_containers/food/condiment/small/zammild(src)
	new/obj/item/weapon/reagent_containers/food/condiment/small/zamspicytoxin(src)
	update_icon()

// -----------------------------
//          Borg Food bag
// -----------------------------

/obj/item/weapon/storage/bag/food/borg
	name = "Food Transport Bag"
	desc = "Useful for manipulating food items in the kitchen."

// -----------------------------
//          Pill Collector
// -----------------------------

/obj/item/weapon/storage/bag/chem
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pcollector"
	name = "Pill Collector"
	item_state = "pcollector"
	origin_tech = Tc_BIOTECH + "=2;" + Tc_MATERIALS + "=1"
	storage_slots = 50; //the number of plant pieces it can carry.
	fits_max_w_class = 3
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	w_class = W_CLASS_TINY
	can_only_hold = list("/obj/item/weapon/reagent_containers/glass/bottle","/obj/item/weapon/reagent_containers/pill","/obj/item/weapon/reagent_containers/syringe")

// -----------------------------
//        Sheet Snatcher
// -----------------------------
// Because it stacks stacks, this doesn't operate normally.
// However, making it a storage/bag allows us to reuse existing code in some places. -Sayu

/obj/item/weapon/storage/bag/sheetsnatcher
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	name = "Sheet Snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."

	var/capacity = 300; //the number of sheets it can carry.
	w_class = W_CLASS_MEDIUM

	allow_quick_empty = 1 // this function is superceded

/obj/item/weapon/storage/bag/sheetsnatcher/New()
	..()
	//verbs -= /obj/item/weapon/storage/verb/quick_empty
	//verbs += /obj/item/weapon/storage/bag/sheetsnatcher/quick_empty

/obj/item/weapon/storage/bag/sheetsnatcher/can_be_inserted(obj/item/W as obj, stop_messages = FALSE)
	if(!istype(W,/obj/item/stack/sheet) || istype(W,/obj/item/stack/sheet/mineral/sandstone) || istype(W,/obj/item/stack/sheet/wood))
		if(!stop_messages)
			to_chat(usr, "The snatcher does not accept [W].")
		return FALSE //I don't care, but the existing code rejects them for not being "sheets" *shrug* -Sayu
	var/current = 0
	for(var/obj/item/stack/sheet/S in contents)
		current += S.amount
	if(capacity == current)//If it's full, you're done
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>The snatcher is full.</span>")
		return FALSE
	return TRUE


// Modified handle_item_insertion.  Would prefer not to, but...
/obj/item/weapon/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/W as obj, prevent_warning = FALSE)
	var/obj/item/stack/sheet/S = W
	if(!istype(S))
		return FALSE

	var/amount
	var/inserted = FALSE
	var/current = 0
	for(var/obj/item/stack/sheet/S2 in contents)
		current += S2.amount
	if(capacity < current + S.amount)//If the stack will fill it up
		amount = capacity - current
	else
		amount = S.amount

	for(var/obj/item/stack/sheet/sheet in contents)
		if(S.type == sheet.type) // we are violating the amount limitation because these are not sane objects
			sheet.amount += amount	// they should only be removed through procs in this file, which split them up.
			S.amount -= amount
			inserted = TRUE
			break

	if(!inserted || !S.amount)
		usr.u_equip(S,1)
		usr.update_icons()	//update our overlays
		if (usr.client && usr.s_active != src)
			usr.client.screen -= S
		//S.dropped(usr)
		if(!S.amount)
			QDEL_NULL (S)
		else
			S.forceMove(src)

	orient2hud(usr)
	if(usr.s_active)
		usr.s_active.show_to(usr)
	update_icon()
	return TRUE


// Sets up numbered display to show the stack size of each stored mineral
// NOTE: numbered display is turned off currently because it's broken
/obj/item/weapon/storage/bag/sheetsnatcher/orient2hud(mob/user as mob)
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/stack/sheet/I in contents)
			adjusted_contents++
			var/datum/numbered_display/D = new/datum/numbered_display(I)
			D.number = I.amount
			numbered_contents.Add( D )

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	src.standard_orient_objs(row_num, col_count, numbered_contents)
	return


// Modified quick_empty verb drops appropriate sized stacks
/obj/item/weapon/storage/bag/sheetsnatcher/quick_empty()
	var/location = get_turf(src)
	for(var/obj/item/stack/sheet/S in contents)
		while(S.amount)
			var/obj/item/stack/sheet/N = new S.type(location)
			var/stacksize = min(S.amount,N.max_amount)
			N.amount = stacksize
			S.amount -= stacksize
		if(!S.amount)
			QDEL_NULL (S) // todo: there's probably something missing here
	orient2hud(usr)
	if(usr.s_active)
		usr.s_active.show_to(usr)
	update_icon()

// Instead of removing
/obj/item/weapon/storage/bag/sheetsnatcher/remove_from_storage(obj/item/W, atom/new_location, var/force = 0, var/refresh = 1)
	var/obj/item/stack/sheet/S = W
	if(!istype(S))
		return FALSE

	//I would prefer to drop a new stack, but the item/attack_hand code
	// that calls this can't receive a different object than you clicked on.
	//Therefore, make a new stack internally that has the remainder.
	// -Sayu

	if(S.amount > S.max_amount)
		var/obj/item/stack/sheet/temp = new S.type(src)
		temp.amount = S.amount - S.max_amount
		S.amount = S.max_amount

	return ..(S,new_location)

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/weapon/storage/bag/sheetsnatcher/borg
	name = "Sheet Snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization

// -----------------------------
//          Gadget Bag
// -----------------------------

/obj/item/weapon/storage/bag/gadgets
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "gadget_bag"
	slot_flags = SLOT_BELT
	name = "gadget bag"
	desc = "This bag can be used to store many machine components."
	storage_slots = 50;
	max_combined_w_class = 200
	w_class = W_CLASS_TINY
	can_only_hold = list("/obj/item/weapon/stock_parts", "/obj/item/weapon/reagent_containers/glass/beaker", "/obj/item/weapon/cell", "/obj/item/weapon/circuitboard")
	display_contents_with_number = TRUE

/obj/item/weapon/storage/bag/gadgets/mass_remove(atom/A)
	var/lowest_rating = INFINITY //Get the lowest rating, so only mass drop the lowest parts.
	for(var/obj/item/B in contents)
		if(B.get_rating() < lowest_rating)
			lowest_rating = B.get_rating()

	for(var/obj/item/B in contents) //Now that we have the lowest rating we can dump only parts at the lowest rating.
		if(B.get_rating() > lowest_rating)
			continue
		remove_from_storage(B, A)

// -----------------------------
//          Money Bag
// -----------------------------

// This used to be /obj/item/weapon/moneybag

/obj/item/weapon/storage/bag/money
	icon = 'icons/obj/storage/storage.dmi'
	name = "money bag"
	icon_state = "moneybag"

	desc = "You had an uncle who was obsessed with these once."

	flags = FPRINT
	w_class = W_CLASS_LARGE
	storage_slots = 300
	fits_max_w_class = 300 //There is no way this could go wrong, right?
	max_combined_w_class = 300
	display_contents_with_number = TRUE //With lods of emone, you're gonna need some compression
	can_only_hold = list("/obj/item/weapon/coin", "/obj/item/stack/ore", "/obj/item/weapon/spacecash")
	cant_hold = list()

/obj/item/weapon/storage/bag/money/treasure
	name = "bag of treasure"
	desc = "Some pirate must have spent a long time collecting this."

/obj/item/weapon/storage/bag/money/treasure/New()
	..()
	for(var/i = 1 to storage_slots)
		new /obj/item/weapon/coin/gold(src)

// -----------------------------
//          Potion Bag
// -----------------------------

/obj/item/weapon/storage/bag/potion
	name = "\improper Bag of potions"
	desc = "Not too dissimilar to the fabled bag of alcohol. The wizard federation is not responsible for possible rainbow puking."
	icon = 'icons/obj/pbag.dmi'
	icon_state = "pbag"
	item_state = "pbag"
	body_parts_covered = FULL_HEAD|BEARD
	slot_flags = SLOT_BELT | SLOT_HEAD
	storage_slots = 50
	fits_max_w_class = 3
	max_combined_w_class = 200
	w_class = W_CLASS_SMALL
	can_only_hold = list("/obj/item/potion")

/obj/item/weapon/storage/bag/potion/bundle
	name = "Potion bundle"
	desc = "What could potionly go wrong?"

/obj/item/weapon/storage/bag/potion/bundle/New()
	..()
	for(var/i=1 to 50)
		new /obj/item/potion/random(src)

/obj/item/weapon/storage/bag/potion/lesser_bundle
	name = "Lesser potion bundle"
	desc = "What could potionly go slightly less wrong?"

/obj/item/weapon/storage/bag/potion/lesser_bundle/New()
	..()
	for(var/i=1 to 12)
		new /obj/item/potion/random(src)

/obj/item/weapon/storage/bag/potion/predicted_potion_bundle
	name = "Predicted potion bundle"
	desc = "What could potionly go right?"

/obj/item/weapon/storage/bag/potion/predicted_potion_bundle/New()
	..()
	for(var/i = 1 to 40)
		var/potiontype = pick(existing_typesof(/obj/item/potion))
		new potiontype(src)

/obj/item/weapon/storage/bag/potion/lesser_predicted_potion_bundle
	name = "Lesser predicted potion bundle"
	desc = "What could potionly go slightly more right?"

/obj/item/weapon/storage/bag/potion/lesser_predicted_potion_bundle/New()
	..()
	for(var/i = 1 to 10)
		var/potiontype = pick(existing_typesof(/obj/item/potion))
		new potiontype(src)

/obj/item/weapon/storage/bag/potion/dice_potion_bundle
	name = "Lucky potion bundle"
	desc = "A bundle of potions for a lucky individual"

/obj/item/weapon/storage/bag/potion/dice_potion_bundle/New()
	..()
	for(var/i = 1 to 5)
		var/potiontype = pick(existing_typesof(/obj/item/potion))
		new potiontype(src)

/obj/item/weapon/storage/bag/ammo_pouch
	name = "ammunition pouch"
	desc = "Designed to hold stray magazines and spare bullets."
	icon_state = "ammo_pouch"
	can_only_hold = list("/obj/item/ammo_casing", "/obj/item/projectile/bullet", "/obj/item/ammo_storage/magazine", "/obj/item/ammo_storage/speedloader", "/obj/item/stack/rcd_ammo", "/obj/item/weapon/grenade")
	storage_slots = 3
	w_class = W_CLASS_LARGE
	slot_flags = SLOT_BELT | SLOT_POCKET



// -----------------------------
//          Xenobiology Bag
// -----------------------------


/obj/item/weapon/storage/bag/xenobio
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "slimebag"
	name = "extract bag"
	desc = "A bag designed to hold slime extract and other slime-related products."
	item_state = "satchel"
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=1"
	storage_slots = 50
	fits_max_w_class = 3
	max_combined_w_class = 200
	w_class = W_CLASS_TINY
	can_only_hold = list("/obj/item/slime_extract","/obj/item/weapon/slimenutrient","/obj/item/weapon/slimesteroid", "/obj/item/weapon/slimepotion", "/obj/item/weapon/slimepotion2", "/obj/item/weapon/slimesteroid2", "/obj/item/weapon/slimeres", "/obj/item/weapon/slimedupe")
	display_contents_with_number = TRUE



// -----------------------------
//          Book Bag
// -----------------------------

/obj/item/weapon/storage/bag/bookbag
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "bookbag"
	name = "book bag"
	desc = "A bag designed to hold books."
	item_state = "satchel"
	storage_slots = 25
	fits_max_w_class = 3
	max_combined_w_class = 200
	w_class = W_CLASS_TINY
	can_only_hold = list("/obj/item/weapon/book","/obj/item/weapon/tome","/obj/item/weapon/tome_legacy","/obj/item/weapon/spellbook","/obj/item/weapon/paper","/obj/item/weapon/paper/nano","/obj/item/weapon/barcodescanner","obj/item/weapon/pen","obj/item/weapon/folder")

