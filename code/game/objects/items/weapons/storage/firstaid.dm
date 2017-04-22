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
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	var/empty = 0


/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

/obj/item/weapon/storage/firstaid/fire/empty
	empty = 1

/obj/item/weapon/storage/firstaid/fire/New()
	..()
	if (empty)
		return

	icon_state = pick("ointment","firefirstaid")

	new /obj/item/device/healthanalyzer(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/weapon/reagent_containers/pill/kelotane(src)
	new /obj/item/weapon/reagent_containers/pill/kelotane(src)
	new /obj/item/weapon/reagent_containers/pill/kelotane(src)
	return


/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

/obj/item/weapon/storage/firstaid/regular/New()
	..()
	if (empty)
		return
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/clothing/suit/spaceblanket(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/device/healthanalyzer(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	return

/obj/item/weapon/storage/firstaid/toxin
	name = "toxin first-aid kit"
	desc = "Used to treat when you have a high amount of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

/obj/item/weapon/storage/firstaid/toxin/empty
	empty = 1

/obj/item/weapon/storage/firstaid/toxin/New()
	..()
	if (empty)
		return

	icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

	new /obj/item/weapon/reagent_containers/syringe/antitoxin(src)
	new /obj/item/weapon/reagent_containers/syringe/antitoxin(src)
	new /obj/item/weapon/reagent_containers/syringe/antitoxin(src)
	new /obj/item/weapon/reagent_containers/pill/antitox(src)
	new /obj/item/weapon/reagent_containers/pill/antitox(src)
	new /obj/item/weapon/reagent_containers/pill/antitox(src)
	new /obj/item/device/healthanalyzer(src)
	return

/obj/item/weapon/storage/firstaid/o2
	name = "oxygen deprivation first-aid kit"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-oxy"

/obj/item/weapon/storage/firstaid/o2/empty
	empty = 1

/obj/item/weapon/storage/firstaid/o2/New()
	..()
	if (empty)
		return
	for (var/i = 1 to 4)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/weapon/reagent_containers/syringe/inaprovaline(src)
	new /obj/item/device/healthanalyzer(src)
	return

/obj/item/weapon/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"

/obj/item/weapon/storage/firstaid/adv/New()
	..()
	if (empty)
		return
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	return

/obj/item/weapon/storage/firstaid/internalbleed
	name = "internal bleeding first-aid kit"
	desc = "Used to stabilize patients suffering from internal bleeding."
	icon_state = "internalbleedfirstaid"
	item_state = "firstaid-internalbleed"


/obj/item/weapon/storage/firstaid/internalbleed/New()
	..()
	if (empty)
		return
	for (var/i = 1 to 4)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector(src)
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
	can_only_hold = list("/obj/item/weapon/reagent_containers/pill","/obj/item/weapon/dice","/obj/item/weapon/paper", "/obj/item/weapon/reagent_containers/food/snacks/sweet")
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


/obj/item/weapon/storage/pill_bottle/MouseDrop(obj/over_object as obj) //Quick pillbottle fix. -Agouri
	if (ishuman(usr) || ismonkey(usr)) //Can monkeys even place items in the pocket slots? Leaving this in just in case~
		var/mob/M = usr //I don't see how this is necessary
		if (!( istype(over_object, /obj/abstract/screen/inventory) ))
			return ..()
		if (!M.incapacitated() && Adjacent(M))
			var/obj/abstract/screen/inventory/SI = over_object

			if(SI.hand_index && M.put_in_hand_check(src, SI.hand_index))
				M.u_equip(src, 0)
				M.put_in_hand(SI.hand_index, src)
				src.add_fingerprint(usr)

			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if (usr.s_active)
				usr.s_active.close(usr)
			src.show_to(usr)
			return
	return

/obj/item/weapon/storage/pill_bottle/AltClick()
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

/obj/item/weapon/storage/pill_bottle/kelotane/New()
	..()
	for (var/i = 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/kelotane(src)


/obj/item/weapon/storage/pill_bottle/antitox
	name = "pill bottle (Anti-toxin)"
	desc = "Contains pills used to counter toxins."

/obj/item/weapon/storage/pill_bottle/antitox/New()
	..()
	for (var/i = 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/antitox(src)


/obj/item/weapon/storage/pill_bottle/inaprovaline
	name = "pill bottle (inaprovaline)"
	desc = "Contains pills used to stabilize patients."

/obj/item/weapon/storage/pill_bottle/inaprovaline/New()
	..()
	for (var/i = 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/inaprovaline(src)


/obj/item/weapon/storage/pill_bottle/dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"

/obj/item/weapon/storage/pill_bottle/dice/New()
	..()
	overlays -= colour_overlay
	colour_overlay = null
	new /obj/item/weapon/dice/d4(src)
	new /obj/item/weapon/dice(src)
	new /obj/item/weapon/dice/d8(src)
	new /obj/item/weapon/dice/d10(src)
	new /obj/item/weapon/dice/d00(src)
	new /obj/item/weapon/dice/d12(src)
	new /obj/item/weapon/dice/d20(src)


/obj/item/weapon/storage/pill_bottle/hyperzine
	name = "pill bottle (hyperzine)"
	desc = "Contains pills used to keep you active."

/obj/item/weapon/storage/pill_bottle/hyperzine/New()
	..()
	for (var/i = 1 to 6)
		new /obj/item/weapon/reagent_containers/pill/hyperzine(src)


/obj/item/weapon/storage/pill_bottle/creatine
	name = "Workout Supplements"
	desc = "Because working out is far too much effort."

/obj/item/weapon/storage/pill_bottle/creatine/New()
	..()
	new /obj/item/weapon/reagent_containers/pill/creatine_safe(src)
	for (var/i = 1 to 5)
		new /obj/item/weapon/reagent_containers/pill/creatine_supplement (src)


/obj/item/weapon/storage/pill_bottle/nanobot
	name = "Experimental Medication"
	desc = "Hazardous.  Warranty voided if consumed."

	/obj/item/weapon/storage/pill_bottle/nanobot/New()
		..()
		for (var/i = 1 to 5)
			new /obj/item/weapon/reagent_containers/pill/nanobot(src)

/obj/item/weapon/storage/pill_bottle/radiation
	name = "pill bottle (radiation treatment)"
	desc = "Contains pills used to treat radiation sickness."

/obj/item/weapon/storage/pill_bottle/radiation/New()
	..()
	for(var/i = 1 to 3)
		new /obj/item/weapon/reagent_containers/pill/hyronalin(src)
		new /obj/item/weapon/reagent_containers/pill/arithrazine(src)

/obj/item/weapon/storage/pill_bottle/sweets
	name = "bag of sweets"
	desc = "Tasty!"
	icon = 'icons/obj/candymachine.dmi'
	icon_state = "candybag"
	var/spawn_type = /obj/item/weapon/reagent_containers/food/snacks/sweet

	/obj/item/weapon/storage/pill_bottle/sweets/New()
		..()
		overlays -= colour_overlay
		colour_overlay = null
		for (var/i = 1 to 10)
			new spawn_type(src)

/obj/item/weapon/storage/pill_bottle/sweets/strange
	spawn_type = /obj/item/weapon/reagent_containers/food/snacks/sweet/strange
