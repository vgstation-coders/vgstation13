/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */
/obj/item/weapon/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/firstaid-kits.dmi', "right_hand" = 'icons/mob/in-hand/right/firstaid-kits.dmi')
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	autoignition_temperature = AUTOIGNITION_PAPER


/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"
	items_to_spawn = list(
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/weapon/reagent_containers/pill/kelotane = 3,
	)

/obj/item/weapon/storage/firstaid/fire/empty
	items_to_spawn = list()

/obj/item/weapon/storage/firstaid/fire/New()
	..()
	icon_state = pick("ointment","firefirstaid")


/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"
	items_to_spawn = list(
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/clothing/suit/spaceblanket,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector,
	)

/obj/item/weapon/storage/firstaid/regular/empty
	name = "First-Aid (empty)"
	items_to_spawn = list()

/obj/item/weapon/storage/firstaid/toxin
	name = "toxin first-aid kit"
	desc = "Used to treat when you have a high amount of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/syringe/antiviral,
		/obj/item/weapon/reagent_containers/syringe/antitoxin = 2,
		/obj/item/weapon/reagent_containers/pill/antitox = 3,
		/obj/item/device/healthanalyzer,
	)

/obj/item/weapon/storage/firstaid/toxin/empty
	items_to_spawn = list()

/obj/item/weapon/storage/firstaid/toxin/New()
	..()
	icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")


/obj/item/weapon/storage/firstaid/o2
	name = "oxygen deprivation first-aid kit"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-oxy"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/pill/dexalin = 4,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector,
		/obj/item/weapon/reagent_containers/syringe/inaprovaline,
		/obj/item/device/healthanalyzer,
	)

/obj/item/weapon/storage/firstaid/o2/empty
	items_to_spawn = list()

/obj/item/weapon/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/advanced/bruise_pack = 3,
		/obj/item/stack/medical/advanced/ointment = 2,
		/obj/item/stack/medical/splint,
	)

/obj/item/weapon/storage/firstaid/internalbleed
	name = "internal bleeding first-aid kit"
	desc = "Used to stabilize patients suffering from internal bleeding."
	icon_state = "internalbleedfirstaid"
	item_state = "firstaid-internalbleed"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector = 4)


/*
 * Pill Bottles
 */
/obj/item/weapon/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = W_CLASS_SMALL
	can_only_hold = list("/obj/item/weapon/reagent_containers/pill","/obj/item/weapon/dice","/obj/item/weapon/paper", "/obj/item/weapon/reagent_containers/food/snacks/sweet", "/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint")
	allow_quick_gather = 1
	use_to_pickup = 1
	storage_slots = 14
	starting_materials = list(MAT_IRON = 10, MAT_GLASS = 60)
	var/melted = 0
	var/image/colour_overlay

/obj/item/weapon/storage/pill_bottle/New()
	..()
	colour_overlay = image('icons/obj/chemical.dmi',"bottle_colour")
	overlays += colour_overlay

/obj/item/weapon/storage/pill_bottle/CtrlClick()
	if(isturf(loc))
		return ..()
	if(!usr.isUnconscious() && Adjacent(usr))
		change()
		return
	return ..()

/obj/item/weapon/storage/pill_bottle/attackby(var/obj/item/I, var/mob/user)
	if(!I)
		return
	if(!melted)
		if(I.is_hot())
			to_chat(user, "You slightly melt the plastic on the side of \the [src] with \the [I].")
			melted = 1
	if(istype(I, /obj/item/weapon/storage/bag/chem))
		var/obj/item/weapon/storage/bag/chem/C = I
		to_chat(user, "<span class='notice'>You transfer the contents of [C].<span>")
		for(var/obj/item/O in C.contents)
			if(can_be_inserted(O))
				handle_item_insertion(O, 1)
		return 1
	if(istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/device/flashlight/pen))
		set_tiny_label(user)
		return 1
	. = ..()

var/global/list/bottle_colour_choices = list("Blue" = "#0094FF","Dark Blue" = "#00137F","Green" = "#129E0A","Orange" = "#FF6A00","Purple" = "#A17FFF","Red" = "#BE0000","Yellow" = "#FFD800","Grey" = "#9F9F9F","White" = "#FFFFFF","Custom" = "#FFFFFF",)
/obj/item/weapon/storage/pill_bottle/verb/change()
	set name = "Add Coloured Label"
	set category = "Object"
	set src in usr
	if(!colour_overlay)
		return
	var/bottle_colour
	bottle_colour = input("Select Colour to change it to", "Pill Bottle Colour", bottle_colour) as null|anything in bottle_colour_choices
	if(!bottle_colour||(usr.stat))
		return
	if(bottle_colour == "Custom")
		bottle_colour = input("Select Colour to change it to", "Pill Bottle Colour", bottle_colour) as color
	else
		bottle_colour = bottle_colour_choices[bottle_colour]
	overlays -= colour_overlay
	colour_overlay.color = "[bottle_colour]"
	overlays += colour_overlay


/obj/item/weapon/storage/pill_bottle/kelotane
	name = "pill bottle (kelotane)"
	desc = "Contains pills used to treat burns."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/pill/kelotane = 7)


/obj/item/weapon/storage/pill_bottle/antitox
	name = "pill bottle (Anti-toxin)"
	desc = "Contains pills used to counter toxins."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/pill/antitox = 7)


/obj/item/weapon/storage/pill_bottle/inaprovaline
	name = "pill bottle (inaprovaline)"
	desc = "Contains pills used to stabilize patients."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/pill/inaprovaline = 7)


/obj/item/weapon/storage/pill_bottle/dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	items_to_spawn = list(
		/obj/item/weapon/dice/d4,
		/obj/item/weapon/dice,
		/obj/item/weapon/dice/d8,
		/obj/item/weapon/dice/d10,
		/obj/item/weapon/dice/d00,
		/obj/item/weapon/dice/d12,
		/obj/item/weapon/dice/d20,
	)

/obj/item/weapon/storage/pill_bottle/dice/fudge
	name = "bag of fudge dice"
	items_to_spawn = list(
		/obj/item/weapon/dice/fudge,
		/obj/item/weapon/dice/fudge,
		/obj/item/weapon/dice/fudge,
		/obj/item/weapon/dice/fudge,
		/obj/item/weapon/dice/fudge,
		/obj/item/weapon/dice/fudge,
		/obj/item/weapon/dice/fudge,
	)

/obj/item/weapon/storage/pill_bottle/dice/d6
	name = "bag of d6"
	items_to_spawn = list(
		/obj/item/weapon/dice,
		/obj/item/weapon/dice,
		/obj/item/weapon/dice,
		/obj/item/weapon/dice,
		/obj/item/weapon/dice,
		/obj/item/weapon/dice,
		/obj/item/weapon/dice,
	)

/obj/item/weapon/storage/pill_bottle/dice/New()
	..()
	overlays -= colour_overlay
	colour_overlay = null
	verbs -= /obj/item/weapon/storage/pill_bottle/verb/change

/obj/item/weapon/storage/pill_bottle/dice/d6/New()
	..()
	var/colorchoice = pick(
		300; "#ffffff", //white
		100; "#00aedb", //teal
		100; "#d11141", //red
		100; "#00b159", //green
		100; "#ffc425", //gold
		)
	for(var/obj/O in contents)
		O.color = colorchoice

/obj/item/weapon/storage/pill_bottle/dice/cup
	name = "dice cup"
	icon = 'icons/obj/drinks.dmi'
	icon_state = "sakeglass"
	items_to_spawn = list()

/obj/item/weapon/storage/pill_bottle/dice/cup/on_attack(atom/attacked, mob/user)
	..()
	if(contents.len)
		empty_contents_to(get_turf(attacked))

/obj/item/weapon/storage/pill_bottle/dice/cup/throw_impact(atom/impacted_atom, speed, mob/user)
	if(..() && contents.len)
		empty_contents_to(get_turf(src))

/obj/item/weapon/storage/pill_bottle/dice/cup/empty_contents_to(var/atom/place)
	var/turf = get_turf(place)
	if(contents.len)
		visible_message("<span class='notice'>Everything goes flying out of \the [src]!</span>")
	var/list/results_list = list()
	var/total_result = 0
	var/has_dice = 0
	for(var/obj/item/weapon/dice/objects in contents)
		has_dice = 1
		remove_from_storage(objects, turf)
		objects.pixel_x = rand(-6,6) * PIXEL_MULTIPLIER
		objects.pixel_y = rand(-6,6) * PIXEL_MULTIPLIER
		var/result = objects.diceroll(usr, TRUE, TRUE)
		results_list += result
		//fudge dice are -1 -1 0 0 1 1
		if(istype(objects,/obj/item/weapon/dice/fudge))
			switch(result)
				if("+")
					total_result += 1
				if("-")
					total_result += -1
				if("a blank side")
					total_result += 0
		else
			total_result += result
	if(has_dice)
		var/result_string = jointext(results_list, ", ")
		if(usr) //Dice was rolled in someone's hand
			usr.visible_message("<span class='notice'>[usr] has rolled dice out of \the [src]. The results were <i>[result_string]</i>, totaling <b>[total_result]</b>.</span>", \
								 "<span class='notice'>You roll the dice. The results were <i>[result_string]</i>, totaling <b>[total_result]</b>.</span>", \
								 "<span class='notice'>You hear the rolling of dice.</span>")
		else
			visible_message("<span class='notice'>Dice roll out of \the [src]. The results were <i>[result_string]</i>, totaling <b>[total_result]</b>.</span>")
	..()

/obj/item/weapon/storage/pill_bottle/dice/with_die/New()
	. = ..()
	new /obj/item/weapon/dice/borg(src)


/obj/item/weapon/storage/pill_bottle/hyperzine
	name = "pill bottle (hyperzine)"
	desc = "Contains pills used to keep you active."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/pill/hyperzine = 6)


/obj/item/weapon/storage/pill_bottle/creatine
	name = "Workout Supplements"
	desc = "Because working out is far too much effort."
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/pill/creatine_safe,
		/obj/item/weapon/reagent_containers/pill/creatine_supplement = 5,
	)


/obj/item/weapon/storage/pill_bottle/nanobot
	name = "Experimental Medication"
	desc = "Hazardous.  Warranty voided if consumed."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/pill/nanobot = 6)

/obj/item/weapon/storage/pill_bottle/radiation
	name = "pill bottle (radiation treatment)"
	desc = "Contains pills used to treat radiation sickness."
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/pill/hyronalin = 3,
		/obj/item/weapon/reagent_containers/pill/arithrazine = 3,
	)

/obj/item/weapon/storage/pill_bottle/sweets
	name = "bag of sweets"
	desc = "Tasty!"
	icon = 'icons/obj/candymachine.dmi'
	icon_state = "candybag"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/sweet = 10)

/obj/item/weapon/storage/pill_bottle/sweets/New()
	..()
	overlays -= colour_overlay
	colour_overlay = null

/obj/item/weapon/storage/pill_bottle/sweets/strange
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/sweet/strange = 10)

/obj/item/weapon/storage/pill_bottle/syndiemints
	name = "box of mints"
	desc = "Gets rid of halitosis and satisfied customers in one go! You shouldn't be seeing this."
	icon = 'icons/obj/candymachine.dmi'
	icon_state = "mintboxgeneric"
	storage_slots = 50
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint = 50)

/obj/item/weapon/storage/pill_bottle/syndiemints/New()
	..()
	overlays = null //no overlay fuck you

	switch(rand(3))
		if(0)
			name = "NanoFresh"
			desc = "An explosion of freshness in each candy!"
			icon_state = "mintboxnanotrasen"
			items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/nano = 50)
		if(1)
			name = "Synd-Sacs"
			desc = "Freshen your fate!"
			icon_state = "mintboxsyndie"
			items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/syndie = 50)
		if(2)
			name = "Discount Dan's Minty Delight"
			desc = "Toxin 'Free'!"
			icon_state = "mintboxgeneric"
			items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/discount = 50)
		if(3)
			name = "Uncle Ian's homemade mints"
			desc = "Graphic Design is my passion!"
			icon_state = "mintboxgraphicdesign"
			items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/homemade = 50)
	..()

/obj/item/weapon/storage/pill_bottle/mint
	name = "You shouldn't be seeing this Mints!"
	desc = "The lastest hip mint sensation in you shouldn't be seeing this! Tell your nearest poopmin(t)."
	icon = 'icons/obj/candymachine.dmi'
	storage_slots = 50

/obj/item/weapon/storage/pill_bottle/mint/discount
	name = "Discount Dan's Minty Delight"
	desc = "Toxin 'Free'!"
	icon_state = "mintboxgeneric"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/discount/safe = 50)

/obj/item/weapon/storage/pill_bottle/mint/nano
	name = "NanoFresh"
	desc = "An explosion of freshness in each candy!"
	icon_state = "mintboxnanotrasen"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/nano/safe = 50)

/obj/item/weapon/storage/pill_bottle/mint/homemade
	name = "Uncle Ian's homemade mints"
	desc = "Graphic Design is my passion!"
	icon_state = "mintboxgraphicdesign"
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/homemade/safe = 50)

/obj/item/weapon/storage/pill_bottle/lollipops
	name = "bag of lollipops"
	desc = "Ha, sucker!"
	icon = 'icons/obj/candymachine.dmi'
	icon_state = "lollibag"
	max_combined_w_class = 4
	storage_slots = 4
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks/lollipop","/obj/item/trash/lollipopstick")
	items_to_spawn = list(/obj/item/weapon/reagent_containers/food/snacks/lollipop = 4)

/obj/item/weapon/storage/pill_bottle/lollipops/New()
	..()
	overlays = null

/obj/item/weapon/storage/pill_bottle/nanofloxacin
	name = "pill bottle (nanofloxacin)"
	desc = "Contains pills used to exterminate pathogen. May also exterminate yourself if taken in larger doses."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/pill/nanofloxacin = 12)
