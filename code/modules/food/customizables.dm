
//**************************************************************
//
// Customizable Food
// ---------------------------
// Did the best I could. Still tons of duplication.
// Part of it is due to shitty reagent system.
// Other part due to limitations of attackby().
//
//**************************************************************

// Various Snacks //////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/breadslice/attackby(obj/item/I, mob/user, params)
	if(!handle_customizable_addition(I, user, params, /obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich))
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/breadslice/nova/attackby(obj/item/I, mob/user, params)
	if(!handle_customizable_addition(I, user, params, /obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich/nova))
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/I, mob/user, params)
	if(!handle_customizable_addition(I, user, params, /obj/item/weapon/reagent_containers/food/snacks/customizable/burger))
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/attackby(obj/item/I, mob/user, params)
	if(!handle_customizable_addition(I, user, params, /obj/item/weapon/reagent_containers/food/snacks/customizable/pizza))
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti/attackby(obj/item/I, mob/user, params)
	if(!handle_customizable_addition(I, user, params, /obj/item/weapon/reagent_containers/food/snacks/customizable/pasta))
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/proc/handle_customizable_addition(obj/item/I, mob/user, params, snacktype)
	//If we're using a pan, try to add something from the pan.
	var/obj/item/weapon/reagent_containers/pan/P
	if(istype(I, /obj/item/weapon/reagent_containers/pan))
		P = I
		var/atom/movable/thing_to_add = P.something_in_pan()
		if(thing_to_add)
			I = thing_to_add

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
		if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
			to_chat(user, "<span class='warning'>Sorry, no recursive food.</span>")
			return TRUE
		var/obj/F = new snacktype (get_turf(src),I)
		if(isitem(F))
			var/obj/item/Food = F
			Food.luckiness += I.luckiness
		F.pixel_x = pixel_x
		F.pixel_y = pixel_y
		F.attackby(I, user, params)
		P?.update_icon()
		qdel(src)
		return TRUE

// Custom Meals ////////////////////////////////////////////////


/obj/item/trash/plate
	name = "plate"
	desc = "Someone ate something on it."
	icon_state = "plate"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/trash.dmi', "right_hand" = 'icons/mob/in-hand/right/trash.dmi')
	item_state = "plate1"
	throwforce = 5
	var/clean = FALSE
	var/list/plates = list() // If the plates are stacked, they come here
	var/new_stack = 0 // allows mappers to create plate stacks
	var/trash_color = null
	autoignition_temperature = null

/obj/item/trash/plate/clean
	icon_state = "cleanplate"
	desc = "Clean enough to eat on, probably."
	clean = TRUE

/obj/item/trash/plate/clean/stack
	name = "plates"
	new_stack = 9 // 10 plates total

/obj/item/trash/plate/New(turf/loc)
	..()
	for (var/i = 1 to new_stack)
		var/obj/item/trash/plate/P = new (src)
		P.clean = clean
		P.update_icon()
		plates += P
	update_icon()

/obj/item/trash/plate/update_icon()
	overlays.len = 0
	if(clean)
		desc = "Clean enough to eat on, probably."
		icon_state = "cleanplate"
	else
		desc = "Someone ate something on it."
		if (trash_color)
			icon_state = "cleanplate"
			var/image/I = image(icon, src, "plate-remains")
			I.color = trash_color
			overlays += I
		else
			icon_state = "plate"
	var/offset_y = 2
	name = "plate"
	gender = NEUTER
	for (var/obj/item/trash/plate/plate in plates)
		name = "plates"
		gender = PLURAL
		var/image/I = image(plate.icon, src, plate.icon_state)
		if (!plate.clean && plate.trash_color)
			var/image/I_remains = image(icon, src, "plate-remains")
			I_remains.color = plate.trash_color
			I.overlays += I_remains
		I.pixel_y = offset_y
		overlays += I
		offset_y += 2
	switch(plates.len)
		if (0,1)
			item_state = "plate1"
		if (2,3)
			item_state = "plate2"
		if (4,5)
			item_state = "plate3"
		if (6,7)
			item_state = "plate4"
		if (8,9)
			item_state = "plate5"
	if (iscarbon(loc))
		var/mob/living/carbon/M = loc
		M.update_inv_hands()

/obj/item/trash/plate/SlipDropped(var/mob/living/user, var/slip_dir, var/slipperiness = TURF_WET_WATER)
	if (!user)
		return
	if (!slip_dir)
		slip_dir = user.dir
	var/turf/T = get_turf(src)
	if (user.drop_item(src, T))
		to_chat(user, "<span class='danger'>You drop \the [src] as you tumble.</span>")
		var/distance = 1
		if (slipperiness == TURF_WET_LUBE)
			distance = 6
		for (var/i = 1 to distance)
			T = get_step(T,slip_dir)
		throw_at(T,throw_range,throw_speed)
	else
		to_chat(user, "<span class='notice'>You somehow hold onto \the [src] as you fall.</span>")

/obj/item/trash/plate/proc/pick_a_plate(var/mob/user)
	if (plates.len > 0)
		var/obj/item/trash/plate/plate = plates[plates.len]
		plates -= plate

		user.put_in_hands(plate)
		to_chat(user, "<span class='warning'>You remove the topmost plate from the stack.</span>")
		plate.update_icon()
		update_icon()


/obj/item/trash/plate/throw_impact(atom/hit_atom)
	if(..())
		return
	for (var/obj/item/trash/plate/P in plates)
		plates -= P
		if(prob(70))
			playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 75, 1)
			new/obj/effect/decal/cleanable/broken_plate(loc)
			visible_message("<span class='warning'>\The [name] [(plates.len > 0)?"have":"has"] been smashed.</span>","<span class='warning'>You hear a crashing sound.</span>")
			qdel(P)
		else
			P.forceMove(loc)
			P.pixel_x = rand (-3,3) * PIXEL_MULTIPLIER
			P.pixel_y = rand (-3,3) * PIXEL_MULTIPLIER

	if(prob(70))
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 75, 1)
		new/obj/effect/decal/cleanable/broken_plate(loc)
		visible_message("<span class='warning'>\The [name] has been smashed.</span>","<span class='warning'>You hear a crashing sound.</span>")
		qdel(src)
	else
		update_icon()


/obj/item/trash/plate/attack_hand(var/mob/user)
	if(plates.len > 0)
		if(user.get_inactive_hand() != src)
			..()
			return

		pick_a_plate(user)
		return
	..()

/obj/item/trash/plate/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if (plates.len > 0)
		if (over_object != usr)
			return
		var/mob/living/carbon/C = usr
		if (!istype(C))
			return
		if(C.incapacitated() || C.lying || !Adjacent(C))
			return

		pick_a_plate(C)

/obj/item/trash/plate/AltClick()
	if (plates.len > 0)
		var/mob/living/carbon/C = usr
		if (!istype(C))
			return
		if(C.incapacitated() || C.lying || !Adjacent(C))
			return

		pick_a_plate(C)

/obj/item/trash/plate/attackby(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/trash/plate))
		var/obj/item/trash/plate/plate = I
		// Make a list of all plates to be added
		var/list/platestoadd = list()
		platestoadd += plate
		for(var/obj/item/trash/plate/i in plate.plates)
			platestoadd += i

		if( (plates.len+1) + platestoadd.len <= 10 )
			if(user.drop_item(I, src))
				plate.plates = list()
				plates.Add(platestoadd)
				plate.update_icon()
				update_icon()
				to_chat(user, "<span class='notice'>You stack another plate on top.</span>")
		else
			to_chat(user, "<span class='warning'>The stack is too high!</span>")
		return TRUE

	if(istype(I,/obj/item/weapon/soap)) // We can clean them all at once for convenience
		if (plates.len > 0)
			for (var/obj/item/trash/plate/plate in plates)
				plate.clean_act(CLEANLINESS_SPACECLEANER)
			visible_message("<span class='notice'>[user] cleans the stack of plates with \the [I]. </span>","<span class='notice'>You clean the stack of plates with \the [I]. </span>")
		else
			visible_message("<span class='notice'>[user] cleans the plate with \the [I]. </span>","<span class='notice'>You clean the plate with \the [I]. </span>")
		clean_act(CLEANLINESS_SPACECLEANER)
		return TRUE

	if(istype(I, /obj/item/weapon/reagent_containers/pan))
		var/obj/item/weapon/reagent_containers/pan/P = I
		var/atom/movable/thing_to_plate = P.something_in_pan()
		if(thing_to_plate)
			if(try_to_put_on_plate(user, thing_to_plate, params))
				P.cook_reboot(user)
				P.update_icon()

	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
		try_to_put_on_plate(user, I, params)
	else
		return ..()

/obj/item/trash/plate/clean_act(var/cleanliness)
	..()
	if (cleanliness >= CLEANLINESS_SPACECLEANER)
		clean = TRUE
		update_icon()

/obj/item/trash/plate/proc/try_to_put_on_plate(var/mob/user, var/obj/item/weapon/reagent_containers/food/snacks/snack, params)
	if(istype(snack,/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom)) //no platestacking even with recursive food, for now
		to_chat(user, "<span class='warning'>That's already got a plate!</span>")
		return

	var/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom/F = new(get_turf(src),snack)

	F.valid_utensils = snack.valid_utensils
	F.reagents.chem_temp = snack.reagents.chem_temp

	if (virus2?.len)
		for (var/ID in virus2)
			var/datum/disease2/disease/D = virus2[ID]
			F.infect_disease2(D,1, "added on a plate",0)
	F.attackby(snack, user, params)
	if (istype(F))
		if (snack.item_state)
			F.item_state = snack.item_state
		else
			F.item_state = snack.icon_state
		F.particles = snack.particles
	if (plates.len > 0)
		user.put_in_hands(F)
		var/obj/item/trash/plate/plate = plates[plates.len]
		plates -= plate
		qdel(plate)
		update_icon()
	else
		F.pixel_x = pixel_x
		F.pixel_y = pixel_y
		qdel(src)
	return F


/obj/item/trash/bowl
	name = "bowl"
	desc = "An empty bowl. Put some food in it to start making a soup."
	icon = 'icons/obj/food_custom.dmi'
	icon_state = "soup"
	item_state = "bowl"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')

/obj/item/trash/bowl/attackby(obj/item/I,mob/user,params)
	if(istype(I,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/S = I
		S.use(1)
		var/obj/item/weapon/reagent_containers/glass/mortar/mortimer = new(get_turf(src))
		to_chat(user, "<span class='notice'>You fashion a crude mortar out of the wooden bowl and a metal sheet.</span>")
		qdel(src)
		user.put_in_hands(mortimer)
	if(istype(I,/obj/item/stack/sheet/leather))
		var/obj/item/stack/sheet/leather/L = I
		L.use(1)
		var/obj/item/device/instrument/drum/drum_makeshift/drumbowl = new(get_turf(src))
		to_chat(user, "<span class='notice'>You fashion a crude drum out of the wooden bowl and a leather sheet.</span>")
		qdel(src)
		user.put_in_hands(drumbowl)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
			to_chat(user, "<span class='warning'>Sorry, no recursive food.</span>")
			return
		var/obj/F = new/obj/item/weapon/reagent_containers/food/snacks/customizable/soup(get_turf(src),I)
		F.attackby(I, user,params)
		qdel(src)
	else
		return ..()

// Customizable Foods //////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable
	icon = 'icons/obj/food_custom.dmi'
	trash = /obj/item/trash/plate
	bitesize = 2

	var/ingMax = 100
	var/list/ingredients = list()
	var/stackIngredients = 0
	var/fullyCustom = 0
	var/addTop = 0
	var/image/topping
	var/image/filling

/obj/item/weapon/reagent_containers/food/snacks/customizable/New(loc,var/obj/item/ingredient)
	. = ..()
	topping = image(icon,,"[initial(icon_state)]_top")
	filling = image(icon,,"[initial(icon_state)]_filling")
	reagents.add_reagent(NUTRIMENT,3)
	if (ingredient)
		if (ingredient.virus2?.len)
			for (var/ID in ingredient.virus2)
				var/datum/disease2/disease/D = ingredient.virus2[ID]
				infect_disease2(D,1, "added to a custom food item",0)
		virus2 = virus_copylist(ingredient.virus2)
	updateName()

/obj/item/weapon/reagent_containers/food/snacks/customizable/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if((contents.len >= ingMax) || (contents.len >= ingredientLimit))
			to_chat(user, "<span class='warning'>That's already looking pretty stuffed.</span>")
			return

		var/obj/item/weapon/reagent_containers/food/snacks/S = I
		if(istype(S,/obj/item/weapon/reagent_containers/food/snacks/customizable))
			var/obj/item/weapon/reagent_containers/food/snacks/customizable/SC = S
			if(fullyCustom && SC.fullyCustom)
				to_chat(user, "<span class='warning'>You slap yourself on the back of the head for thinking that stacking plates is an interesting dish.</span>")
				return
		if(!recursiveFood && !fullyCustom && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
			to_chat(user, "<span class='warning'>[pick("As uniquely original as that idea is, you can't figure out how to perform it.","That would be a straining topological exercise.","This world just isn't ready for your cooking genius.","It's possible that you may have a problem.","It won't fit.","You don't think that would taste very good.","Quit goofin' around.")]</span>")
			return
		if(!user.drop_item(I, src))
			user << "<span class='warning'>\The [I] is stuck to your hands!</span>"
			return

		S.reagents.trans_to(src,S.reagents.total_volume)
		ingredients += S

		if(addTop)
			extra_food_overlay.overlays -= topping //thank you Comic
		if(!fullyCustom && !stackIngredients && overlays.len)
			extra_food_overlay.overlays -= filling //we can't directly modify the overlay, so we have to remove it and then add it again
			var/newcolor = S.filling_color != "#FFFFFF" ? S.filling_color : AverageColor(getFlatIcon(S, S.dir, 0), 1, 1)
			filling.color = BlendRGB(filling.color, newcolor, 1/ingredients.len)
			extra_food_overlay.overlays += image(filling)
		else
			extra_food_overlay.overlays += generateFilling(S, params)
			if(fullyCustom)
				icon_state = S.plate_icon
		if(addTop)
			drawTopping()
		update_icon()
		updateName()
		to_chat(user, "<span class='notice'>You add the [I.name] to the [name].</span>")
	else
		. = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/generateFilling(var/obj/item/weapon/reagent_containers/food/snacks/S, params)
	var/image/I
	if(fullyCustom)
		I = image(S.icon,src,S.icon_state)
		I.appearance = S.appearance
		I.plane = FLOAT_PLANE
		I.layer = FLOAT_LAYER
		I.pixel_y = 12 * PIXEL_MULTIPLIER - empty_Y_space(icon(S.icon,S.icon_state)) + S.plate_offset_y
	else
		I = filling
		if(istype(S) && S.filling_color != "#FFFFFF")
			I.color = S.filling_color
		else
			I.color = AverageColor(getFlatIcon(S, S.dir, 0), 1, 1)
		if(stackIngredients)
			I.pixel_y = ingredients.len * 2 * PIXEL_MULTIPLIER
	if(fullyCustom || stackIngredients)
		var/clicked_x = text2num(params2list(params)["icon-x"])
		if (isnull(clicked_x))
			I.pixel_x = 0
		else if (clicked_x < 9 * PIXEL_MULTIPLIER)
			I.pixel_x = -2 * PIXEL_MULTIPLIER //this looks pretty shitty
		else if (clicked_x < 14 * PIXEL_MULTIPLIER)
			I.pixel_x = -1 * PIXEL_MULTIPLIER //but hey
		else if (clicked_x < 19 * PIXEL_MULTIPLIER)
			I.pixel_x = 0  //it works
		else if (clicked_x < 25 * PIXEL_MULTIPLIER)
			I.pixel_x = 1 * PIXEL_MULTIPLIER
		else
			I.pixel_x = 2 * PIXEL_MULTIPLIER

	return I

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/updateName()
	var/i = 1
	var/new_name
	for(var/obj/item/S in ingredients)
		if(i == 1)
			new_name += "[S.name]"
			if (fullyCustom)
				desc = S.desc
		else if(i == ingredients.len)
			new_name += " and [S.name]"
		else
			new_name += ", [S.name]"
		i++
	if (!fullyCustom)
		new_name = "[new_name] [initial(name)]"
	if(length(new_name) >= 150)
		name = "something yummy"
	else
		name = new_name
	return new_name

/obj/item/weapon/reagent_containers/food/snacks/customizable/Destroy()
	for(. in ingredients) qdel(.)
	return ..()

// Sandwiches //////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich
	name = "sandwich"
	desc = "A timeless classic."
	icon_state = "c_sandwich"
	stackIngredients = 1
	addTop = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich/nova
	icon_state = "c_sandwich_nova"
	plate_icon = "novacustom"


/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich/nova/New(loc,ingredient)
	. = ..()
	reagents.add_reagent(HELL_RAMEN, 0.6)
	reagents.add_reagent(NOVAFLOUR, 0.2)

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/breadslice) && !addTop)
		I.reagents.trans_to(src,I.reagents.total_volume)
		addTop = 1
		drawTopping()
		if (I.virus2?.len)
			for (var/ID in I.virus2)
				var/datum/disease2/disease/D = I.virus2[ID]
				infect_disease2(D,1, "added to a sandwhich",0)
		qdel(I)
		update_icon()
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/drawTopping()
	var/image/I = topping
	I.pixel_y = (ingredients.len+1)*2 * PIXEL_MULTIPLIER
	extra_food_overlay.overlays += I

/obj/item/weapon/reagent_containers/food/snacks/customizable/burger
	name = "burger"
	desc = "The apex of space culinary achievement."
	icon_state = "c_burger"
	stackIngredients = 1
	addTop = 1

// Misc Subtypes ///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom
	name = "something on a plate"
	desc = "A unique dish."
	icon_state = "fullycustom"
	fullyCustom = 1 //how the fuck do you forget to add this?
	ingMax = 1

/obj/item/weapon/reagent_containers/food/snacks/customizable/soup
	name = "soup"
	desc = "A bowl with liquid and... stuff in it."
	icon_state = "soup"
	trash = /obj/item/trash/bowl
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza
	name = "pan pizza"
	desc = "A personalized pan pizza meant for only one person."
	icon_state = "personal_pizza"

/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta
	name = "spaghetti"
	desc = "Noodles. With stuff. Delicious."
	icon_state = "pasta_bot"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/bread
	name = "bread"
	icon_state = "breadcustom"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/customizable/slices/breadslice
	slices_num = 5
	storage_slots = 3

/obj/item/weapon/reagent_containers/food/snacks/customizable/slices/breadslice
	name = "slice"
	desc = "Moist and oozing with flavor, just like how bread should be."
	icon_state = "breadslicecustom"
	trash = /obj/item/trash/plate
	bitesize = 2
	ingMax = 0
	plate_offset_y = -5
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/pie
	name = "pie"
	icon_state = "piecustom"
	trash = /obj/item/trash/pietin
	ingMax = 1

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/cake
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/customizable/slices/cakeslicecustom
	slices_num = 5
	storage_slots = 3

/obj/item/weapon/reagent_containers/food/snacks/customizable/slices/cakeslicecustom
	name = "slice"
	desc = "Delicious and moist."
	icon_state = "cakeslicecustom"
	trash = /obj/item/trash/plate
	bitesize = 2
	ingMax = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/jelly
	name = "jelly"
	desc = "Totally jelly."
	icon_state = "jellycustom"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/donkpocket
	name = "donk pocket"
	desc = "You wanna put a bangin-Oh nevermind."
	icon_state = "donkcustom"
	trash = null
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/kebab
	name = "kebab"
	icon_state = "kababcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/salad
	name = "salad"
	desc = "Very tasty."
	icon_state = "saladcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/waffles
	name = "waffles"
	desc = "Made with love."
	icon_state = "wafflecustom"
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/
	trash = null

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cookie
	name = "cookie"
	icon_state = "cookiecustom"
	valid_utensils = 0
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cotton
	name = "flavored cotton candy"
	icon_state = "cottoncandycustom"
	valid_utensils = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gummybear
	name = "flavored giant gummy bear"
	icon_state = "gummybearcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gummyworm
	name = "flavored giant gummy worm"
	icon_state = "gummywormcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/jellybean
	name = "flavored giant jelly bean"
	icon_state = "jellybeancustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/jawbreaker
	name = "flavored jawbreaker"
	icon_state = "jawbreakercustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/candycane
	name = "flavored candy cane"
	icon_state = "candycanecustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gum
	name = "flavored gum"
	icon_state = "gumcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/donut
	name = "filled donut"
	desc = "Nothing beats a jelly-filled donut."
	icon_state = "donutcustom"
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/bar
	name = "flavored chocolate bar"
	desc = "Made in a factory downtown."
	icon_state = "barcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/sucker
	name = "flavored sucker"
	desc = "Suck suck suck."
	icon_state = "suckercustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cash
	name = "flavored chocolate cash"
	desc = "I got piles!" //I bet you do
	icon_state = "cashcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/coin
	name = "flavored chocolate coin"
	icon_state = "coincustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/coin/New()
	..()
	add_component(/datum/component/coinflip)

// Customizable Drinks /////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable
	volume = 100
	var/list/ingredients = list()
	var/initReagent
	var/ingMax = 3
	var/image/filling
	isGlass = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/New()
	. = ..()
	reagents.add_reagent(initReagent,50)
	var/icon/opaquefilling = new(icon,"[initial(icon_state)]_filling")
	opaquefilling.ChangeOpacity(0.8)
	filling = image(opaquefilling)
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/pen))
		var/n_name = copytext(sanitize(input(user, "What would you like to name this drink?", "Booze Renaming", null) as text|null), 1, MAX_NAME_LEN*3)
		if(n_name && Adjacent(user) && !user.stat)
			name = "[n_name]"
		return
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(ingredients.len < ingMax)
			var/obj/item/weapon/reagent_containers/food/snacks/S = I

			if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
				to_chat(user, "<span class='warning'>[pick("Sorry, no recursive food.","That would be a straining topological exercise.","This world just isn't ready for your cooking genius.","It's possible that you may have a problem.","It won't fit.","You don't think that would taste very good.","Quit goofin' around.")]</span>")
				return
			if(user.drop_item(I, src))
				to_chat(user, "<span class='notice'>You add the [S.name] to the [name].</span>")
				S.reagents.trans_to(src,S.reagents.total_volume)
				ingredients += S
				updateName()
				var/newcolor = S.filling_color != "#FFFFFF" ? S.filling_color : AverageColor(getFlatIcon(S, S.dir, 0), 1, 1)
				filling.color = BlendRGB(filling.color, newcolor, 1/ingredients.len)
				update_icon()
		else
			to_chat(user, "<span class='warning'>That won't fit.</span>")
	else
		. = ..()
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/update_icon()
	overlays.len = 0//no choice here but to redraw everything in the correct order so filling doesn't appear over ice, blood and fire.
	overlays += filling
	update_temperature_overlays()
	update_blood_overlay()//re-applying blood stains
	if (on_fire && fire_overlay)
		overlays += fire_overlay

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/proc/updateName() //copypaste of food's updateName()
	var/i = 1
	var/new_name
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in ingredients)
		if(i == 1)
			new_name += "[S.name]"
		else if(i == ingredients.len)
			new_name += " and [S.name]"
		else
			new_name += ", [S.name]"
		i++
	new_name = "[new_name] [initial(name)]"
	if(length(new_name) >= 150)
		name = "something yummy"
	else
		name = new_name
	return new_name

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/proc/generateFilling(var/obj/item/weapon/reagent_containers/food/snacks/S)
	var/image/I = filling
	if(S.filling_color != "#FFFFFF")
		I.color = S.filling_color
	else
		I.color = AverageColor(getFlatIcon(S, S.dir, 0), 1, 1)
	return I

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/Destroy()
	for(. in ingredients) qdel(.)
	return ..()

// Drink Subtypes //////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/wine
	name = "wine"
	desc = "Classy."
	icon_state = "winecustom"
	initReagent = WINE

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/whiskey
	name = "whiskey"
	desc = "A bottle of quite-a-bit-proof whiskey."
	icon_state = "whiskeycustom"
	initReagent = WHISKEY

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vermouth
	name = "vermouth"
	desc = "Shaken, not stirred."
	icon_state = "vermouthcustom"
	initReagent = VERMOUTH

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vodka
	name = "vodka"
	desc = "Get drunk, comrade."
	icon_state = "vodkacustom"
	initReagent = VODKA

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/ale
	name = "ale"
	desc = "Strike the asteroid!"
	icon_state = "alecustom"
	initReagent = ALE

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/degreaser
	name = "engine degreaser"
	desc = "Engines, full speed!"
	icon_state = "degreasercustom"
	initReagent = ETHANOL
