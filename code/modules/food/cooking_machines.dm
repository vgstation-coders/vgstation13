
//**************************************************************
//
// Cooking Machinery
// ---------------------
// Now with inheritance!
// Set deepFriedEverything to 0 to disable silliness.
// You can also do this in-game with toggleFryers().
//
//**************************************************************

// Globals /////////////////////////////////////////////////////

var/global/deepFriedEverything = 0
var/global/deepFriedNutriment = 0
var/global/foodNesting = 0
var/global/recursiveFood = 0
var/global/ingredientLimit = 10

/client/proc/configFood()
	set name = "Configure Food"
	set category = "Debug"

	. = (alert("Deep Fried Everything?",,"Yes","No")=="Yes")
	if(.)
		deepFriedEverything = 1
	else
		deepFriedEverything = 0
	. = (alert("Food Nesting?",,"Yes","No")=="Yes")
	if(.)
		foodNesting = 1
	else
		foodNesting = 0
	. = (alert("Enable recursive food? (WARNING: May cause server instability!)",,"Yes","No")=="Yes")
	if(.)
		recursiveFood = 1
	else
		recursiveFood = 0
	. = (input("Deep Fried Nutriment? (1 to 50)"))
	. = text2num(.)
	if(isnum(.) && (. in 1 to 50))
		deepFriedNutriment = . //This is absolutely terrible
	else
		to_chat(usr, "That wasn't a valid number.")
	. = (input("Ingredient Limit? (1 to 100)"))
	. = text2num(.)
	if(isnum(.) && (. in 1 to 100))
		ingredientLimit = .
	else
		to_chat(usr, "That wasn't a valid number.")
	log_admin("[key_name(usr)] set deepFriedEverything to [deepFriedEverything].")
	log_admin("[key_name(usr)] set foodNesting to [foodNesting].")
	log_admin("[key_name(usr)] set deepFriedNutriment to [deepFriedNutriment]")
	log_admin("[key_name(usr)] set ingredientLimit to [ingredientLimit]")

	message_admins("[key_name(usr)] set deepFriedEverything to [deepFriedEverything].")
	message_admins("[key_name(usr)] set foodNesting to [foodNesting].")
	message_admins("[key_name(usr)] set deepFriedNutriment to [deepFriedNutriment]")
	message_admins("[key_name(usr)] set ingredientLimit to [ingredientLimit]")
	return

// Base (Oven) /////////////////////////////////////////////////

/obj/machinery/cooking
	name = "Waffle Inc. Ez-bake FUN oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	var/icon_state_on = "oven_on"
	var/recursive_ingredients = 0 //allow /food/snacks/customizable as a valid ingredient
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500

	machine_flags = WRENCHMOVE | FIXED2WORK //need to add circuits before the other flags get in

	var/active				=	0 //Currently cooking?
	var/cookSound			=	'sound/machines/ding.ogg'
	var/cookTime			=	150	//In ticks
	var/obj/item/ingredient	=	null //Current ingredient
	var/list/foodChoices	=	list() //Null if not offered

	var/cooks_in_reagents = 0 //are we able to add stuff to the machine so that reagents are added to food?
	var/cks_max_volume = 50

/obj/machinery/cooking/cultify()
	new /obj/structure/cult_legacy/talisman(loc)
	..()

/obj/machinery/cooking/New()
	if (ticker)
		initialize()

	return ..()

/obj/machinery/cooking/initialize()
	if (foodChoices)
		var/obj/item/food

		for (var/path in getFoodChoices())
			food = path

			foodChoices.Add(list(initial(food.name) = path))

	if (cooks_in_reagents) // if we can cook in something
		create_reagents(cks_max_volume) // maximum volume is set by the machine var

/obj/machinery/cooking/proc/getFoodChoices()
	return (typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook)-(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook))

/obj/machinery/cooking/is_open_container()
	if(cooks_in_reagents)
		return TRUE

// Interactions ////////////////////////////////////////////////

/obj/machinery/cooking/examine(mob/user)
	. = ..()
	if(src.active)
		to_chat(user, "<span class='info'>It's currently processing [src.ingredient ? src.ingredient.name : ""].</span>")
	if(src.cooks_in_reagents)
		to_chat(user, "<span class='info'>It seems to have [reagents.total_volume] units left.</span>")

/obj/machinery/cooking/attack_hand(mob/user)
	if(isobserver(user))
		to_chat(user, "Your ghostly hand goes straight through.")
	else if(isMoMMI(user))// *buzz
		to_chat(user, "This is old analog equipment. You can't interface with it.")

	else if(src.active)
		if(alert(user,"Remove \the [src.ingredient.name]?",,"Yes","No") == "Yes")
			if(src.ingredient && (get_turf(src.ingredient)==get_turf(src)))
				if(Adjacent(user))
					src.active = 0
					src.icon_state = initial(src.icon_state)
					src.ingredient.mouse_opacity = 1
					user.put_in_hands(src.ingredient)
					to_chat(user, "<span class='notice'>You remove \the [src.ingredient.name] from \the [src.name].</span>")
					src.ingredient = null
				else
					to_chat(user, "You are too far away from [src.name].")
			else
				src.active = 0
		else
			to_chat(user, "You leave \the [src.name] alone.")
	else
		. = ..()

/obj/machinery/cooking/attackby(obj/item/I, mob/user)
	if(src.active)
		to_chat(user, "<span class='warning'>[src.name] is currently busy.</span>")
		return
	else if(..())
		return TRUE
	else if(stat & (NOPOWER | BROKEN))
		to_chat(user, "<span class='warning'> The power's off, it's no good. </span>")
		return
	else if(isMoMMI(user))// *buzz
		to_chat(user, "<span class='warning'>That's a terrible idea.</span>")
		return
	else
		src.takeIngredient(I,user)
	return

/obj/machinery/cooking/verb/flush_reagents()
	set name = "Remove ingredients"
	set category = "Object"
	set src in oview(1)

	if(isjustobserver(usr) || ismouse(usr))
		return

	if(active)
		to_chat(usr, "<span class='warning'>\The [src] is currently busy!</span>")
		return

	if(cooks_in_reagents)
		if(do_after(usr, src, src.reagents.total_volume / 10))
			src.reagents.clear_reagents()
			if(usr)
				to_chat(usr, "You clean \the [src] of any ingredients.")

// Food Processing /////////////////////////////////////////////

//Returns "valid" or the reason for denial.
/obj/machinery/cooking/proc/validateIngredient(var/obj/item/I, var/force_cook)
	if(istype(I,/obj/item/weapon/grab) || istype(I,/obj/item/tk_grab))
		. = "It won't fit."
	else if(istype(I,/obj/item/weapon/disk/nuclear))
		. = "It's the fucking nuke disk!"
	else if(!recursive_ingredients && !recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
		. = "It would be a straining topological exercise."
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks) || istype(I,/obj/item/weapon/holder) || deepFriedEverything || force_cook)
		. = "valid"
	else if(istype(I,/obj/item/weapon/reagent_containers))
		. = "transto"
	else if(istype(I,/obj/item/organ/internal))
		var/obj/item/organ/internal/organ = I
		if(organ.robotic)
			. = "That's a prosthetic. It wouldn't taste very good."
		else
			. = "valid"
	else
		. = "It's not edible food."
	return

/obj/machinery/cooking/proc/takeIngredient(var/obj/item/I,mob/user,var/force_cook)
	. = src.validateIngredient(I, force_cook)
	if(. == "transto")
		return
	if(. == "valid")
		if(src.foodChoices)
			. = src.foodChoices[(input("Select production.") in src.foodChoices)]
		if (!Adjacent(user) || user.stat || ((user.get_active_hand() != (I) && !isgripper(user.get_active_hand())) && !force_cook))
			return FALSE

		if(user.drop_item(I, src))
			src.ingredient = I
			spawn() src.cook(.)
			to_chat(user, "<span class='notice'>You add \the [I.name] to \the [src.name].</span>")
			return TRUE
	else
		to_chat(user, "<span class='warning'>You can't put that in \the [src.name]. \n[.]</span>")
	return FALSE

/obj/machinery/cooking/proc/transfer_reagents_to_food(var/obj/item/I)
	var/obj/item/target_food
	if(I)
		target_food = I
	else if (src.ingredient)
		target_food = ingredient

	if(!target_food || !src.reagents || !src.reagents.total_volume) //we have nothing to transfer to or nothing to transfer from
		return

	if(istype(target_food,/obj/item/weapon/reagent_containers))
		for(var/datum/reagent/reagent in reagents.reagent_list)
			src.reagents.trans_id_to(target_food, reagent.id, max(5, target_food.w_class * 5) / reagents.reagent_list.len)
	return

/obj/machinery/cooking/proc/cook_after(var/delay, var/numticks = 5) //adaptation of do_after()
	var/delayfraction = round(delay/numticks)
	for (var/i = 1 to numticks)
		sleep(delayfraction)
		if (!src.ingredient || !active || get_turf(src.ingredient)!=get_turf(src))
			return FALSE
	return TRUE

/obj/machinery/cooking/proc/cook(var/foodType)
	src.active = 1
	src.icon_state = src.icon_state_on
	if (cook_after(src.cookTime, 25))
		src.makeFood(foodType)
		playsound(src,src.cookSound,100,1)
	src.active = 0
	src.icon_state = initial(src.icon_state)
	return

/obj/machinery/cooking/proc/makeFood(var/foodType)
	if(istype(src.ingredient, /obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.ingredient
		if(H.stored_mob)
			H.stored_mob.ghostize()
			H.stored_mob.death()
			H.contents -= H.stored_mob
			qdel(H.stored_mob)
			H.stored_mob = null

	var/obj/item/I = src.ingredient
	var/obj/item/weapon/reagent_containers/food/new_food = new foodType(src.loc,I)
	for(var/obj/item/embedded in I.contents)
		embedded.forceMove(src.loc)
	if(cooks_in_reagents)
		transfer_reagents_to_food(new_food)

	if(I.reagents)
		I.reagents.trans_to(new_food,I.reagents.total_volume)

	if (istype(new_food, /obj/item/weapon/reagent_containers/food/snacks/customizable))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/F = new_food
		F.ingredients += I
		F.updateName()
		F.overlays += F.generateFilling(I)
	else if (istype(new_food, /obj/item/weapon/reagent_containers/food/drinks/bottle/customizable))
		var/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/F = new_food
		F.ingredients += I
		F.updateName()
		F.overlays += F.generateFilling(I)
	src.ingredient = null
	return new_food

// Candy Machine ///////////////////////////////////////////////

/obj/machinery/cooking/candy
	name = "candy machine"
	desc = "Makes you the candyman."
	icon_state = "mixer_off"
	icon_state_on = "mixer_on"
	cookSound = 'sound/machines/juicer.ogg'


/obj/machinery/cooking/candy/validateIngredient(var/obj/item/I)
	. = ..()
	if ((. == "valid") && (!foodNesting))
		for (var/food in foodChoices)
			if (findtext(I.name, food))
				. = "It's already candy."
				break

/*/obj/machinery/cooking/candy/makeFood(var/foodType)
	var/old_food = src.ingredient.name
	var/obj/item/weapon/reagent_containers/food/new_food = ..()
	new_food.name = "[old_food] [new_food.name]"
	return new_food*/

/obj/machinery/cooking/candy/getFoodChoices()
	return (typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/candy)-(/obj/item/weapon/reagent_containers/food/snacks/customizable/candy))


// Still ///////////////////////////////////////////////////////

/obj/machinery/cooking/still
	name = "still"
	desc = "Alright, so, t'make some moonshine, fust yo' gotta combine some of this hyar egg wif th' deep fried sausage."
	icon_state = "still_off"
	icon_state_on = "still_on"
	cookSound = 'sound/machines/juicer.ogg'

/obj/machinery/cooking/still/validateIngredient(var/obj/item/I)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/grown))
		. = "valid"
	else
		. = "It ain't grown food!"
	return

/obj/machinery/cooking/still/getFoodChoices()
	return (typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable)-(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable))

// Cereal Maker ////////////////////////////////////////////////

/obj/machinery/cooking/cerealmaker
	name = "cereal maker"
	desc = "Sorry, Dann-O's are not available. But everything else is."
	icon_state = "cereal_off"
	icon_state_on = "cereal_on"
	foodChoices = null

/obj/machinery/cooking/cerealmaker/validateIngredient(var/obj/item/I)
	. = ..()
	if((. == "valid") && (!foodNesting))
		if(findtext(I.name,"cereal"))
			. = "It's already cereal."
	return

/obj/machinery/cooking/cerealmaker/makeFood()
	var/obj/item/weapon/reagent_containers/food/snacks/cereal/C = new(src.loc)
	for(var/obj/item/embedded in src.ingredient.contents)
		embedded.forceMove(src.loc)
	if(src.ingredient.reagents)
		src.ingredient.reagents.trans_to(C,src.ingredient.reagents.total_volume)
	if(cooks_in_reagents)
		src.transfer_reagents_to_food(C) //add the stuff from the machine
	C.name = "[src.ingredient.name] cereal"
	var/image/I = image(getFlatIcon(src.ingredient, src.ingredient.dir, 0))
	I.transform *= 0.7
	C.overlays += I

	if(istype(src.ingredient, /obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.ingredient
		if(H.stored_mob)
			H.stored_mob.ghostize()
			H.stored_mob.death()

			qdel(H.stored_mob)

	qdel(src.ingredient)
	src.ingredient = null

	return

// Deep Fryer //////////////////////////////////////////////////

#define DEEPFRY_MINOIL	50

/obj/machinery/cooking/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon_state = "fryer_off"
	icon_state_on = "fryer_on"
	foodChoices = null
	cookTime = 170
	recursive_ingredients = 1
	cks_max_volume = 400
	cooks_in_reagents = 1

/obj/machinery/cooking/deepfryer/initialize()
	..()
	reagents.add_reagent(CORNOIL, 300)

/obj/machinery/cooking/deepfryer/proc/empty_icon() //sees if the value is empty, and changes the icon if it is
	reagents.update_total() //make the values refresh
	if(ingredient)
		icon_state = "fryer_on"
		playsound(src,'sound/machines/deep_fryer.ogg',100,1) // If cookSound is used, the sound starts when the cooking ends. We don't want that.
	else if(reagents.total_volume < DEEPFRY_MINOIL)
		icon_state = "fryer_empty"
	else
		icon_state = initial(icon_state)

/obj/machinery/cooking/deepfryer/attackby()
	. = ..()
	empty_icon()

/obj/machinery/cooking/deepfryer/takeIngredient(var/obj/item/I, mob/user, force_cook)
	if(reagents.total_volume < DEEPFRY_MINOIL)
		to_chat(user, "\The [src] doesn't have enough oil to fry in.")
		return
	else
		return ..()

/obj/machinery/cooking/deepfryer/validateIngredient(var/obj/item/I, force_cook)
	. = ..()
	if((. == "valid") && (!foodNesting))
		if(findtext(I.name,"fried"))
			. = "It's already deep-fried."
		else if(findtext(I.name,"grilled"))
			. = "It's already grilled."
	return

/obj/machinery/cooking/deepfryer/flush_reagents()
	..()
	empty_icon()

/obj/machinery/cooking/deepfryer/makeFood(var/obj/item/I)
	if(istype(src.ingredient,/obj/item/weapon/reagent_containers/food/snacks))
		if(cooks_in_reagents)
			src.transfer_reagents_to_food(src.ingredient)
		src.ingredient.name = "deep fried [src.ingredient.name]"
		src.ingredient.color = "#FFAD33"
		src.ingredient.forceMove(src.loc)
		for(var/obj/item/embedded in src.ingredient.contents)
			embedded.forceMove(ingredient)
	else //some admin enabled funfood and we're frying the captain's ID or someshit
		var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/D = new(src.loc)
		if(cooks_in_reagents)
			src.transfer_reagents_to_food(D)
		D.name = "deep fried [src.ingredient.name]"
		D.color = "#FFAD33"
		D.icon = src.ingredient.icon
		D.icon_state = src.ingredient.icon_state
		D.overlays = src.ingredient.overlays

		if(istype(src.ingredient, /obj/item/weapon/holder))
			var/obj/item/weapon/holder/H = src.ingredient
			if(H.stored_mob)
				H.stored_mob.ghostize()
				H.stored_mob.death()
				qdel(H.stored_mob)

		for(var/obj/item/embedded in src.ingredient.contents)
			embedded.forceMove(D)

		qdel(src.ingredient)

	src.ingredient = null
	empty_icon() //see if the icon needs updating from the loss of oil
	return

/obj/machinery/cooking/deepfryer/npc_tamper_act(mob/living/L)
	//Deepfry a random nearby item
	var/list/pickable_items = list()

	for(var/obj/item/I in adjacent_atoms(L))
		pickable_items.Add(I)

	if(!pickable_items.len)
		return

	var/obj/item/I = pick(pickable_items)

	takeIngredient(I, L, TRUE) //shove the item in, even if it can't be deepfried normally
	empty_icon()


// confectionator ///////////////////////////////////////
// its like a deepfrier

// but with sugar

#define CONFECTIONATOR_MINSUGAR 50

/obj/machinery/cooking/deepfryer/confectionator
	name = "confectionator"
	desc = "Creates sugar copies of stuff."
	icon_state = "confectionator_off"
	icon_state_on = "confectionator_on"
	foodChoices = null
	cookTime = 100
	recursive_ingredients = 1
	cks_max_volume = 400
	cooks_in_reagents = 1
	machine_flags = WRENCHMOVE | CROWDESTROY | SCREWTOGGLE | FIXED2WORK | SHUTTLEWRENCH

/obj/machinery/cooking/deepfryer/confectionator/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/confectionator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/matter_bin
	)

	RefreshParts()

/obj/machinery/cooking/deepfryer/confectionator/validateIngredient(var/obj/item/I, var/force_cook)
	if(I.w_class < W_CLASS_LARGE)
		. = "valid"

	else
		. = "The confectionator will not be able to replicate that."
	if((. == "valid") && (!foodNesting))
		if(findtext(I.name,"sugar"))
			. = "It's already a sugar copy."

/obj/machinery/cooking/deepfryer/confectionator/initialize()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(SUGAR, 300)


/obj/machinery/cooking/deepfryer/confectionator/empty_icon() //sees if the value is empty, and changes the icon if it is
	reagents.update_total() //make the values refresh
	if(ingredient)
		icon_state = "confectionator_on"
		playsound(src,'sound/machines/juicer.ogg',100,1) // If cookSound is used, the sound starts when the cooking ends. We don't want that.
	else if(reagents.total_volume < CONFECTIONATOR_MINSUGAR)
		icon_state = "confectionator_empty"
	else
		icon_state = initial(icon_state)

/obj/machinery/cooking/deepfryer/confectionator/takeIngredient(var/obj/item/I, mob/user, force_cook)
	if(reagents.total_volume < CONFECTIONATOR_MINSUGAR)
		to_chat(user, "\The [src] doesn't have enough sugar.")
		return
	else
		return ..()

/obj/machinery/cooking/deepfryer/confectionator/makeFood(var/obj/item/I)

	var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/D = new(src.loc)
	if(cooks_in_reagents)
		src.transfer_reagents_to_food(D)
	D.appearance = src.ingredient.appearance
	D.name = "sugar [src.ingredient.name]"
	D.desc = "It's \an [src.ingredient.name] made out of sugar!"
	D.color = list(
    				1, 0, 0, 0,
  					0, 1, 0, 0,
   					0, 0, 1, 0,
   					0, 0, 0, 1,
   					0.18, 0.08, 0.08, 0
					)
	if(src.ingredient.inhand_states)
		D.inhand_states = src.ingredient.inhand_states

	src.ingredient.forceMove(src.loc) // returns the item instead of destroying it, as the confectionator creates a sugar copy
	src.ingredient = null
	empty_icon() //see if the icon needs updating from the loss of sugar
	return


// Grill ///////////////////////////////////////////////////////

/obj/machinery/cooking/grill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon_state = "grill_off"
	icon_state_on = "grill_on"
	foodChoices = null
	cookTime = 210
	recursive_ingredients = 1

	cooks_in_reagents = 1

/obj/machinery/cooking/grill/validateIngredient(var/obj/item/I)
	. = ..()
	if((. == "valid") && (!foodNesting))
		if(findtext(I.name,"fried"))
			. = "It's already deep-fried."
		else if(findtext(I.name,"rotisserie"))
			. = "It's already rotisseried"
		else if(findtext(I.name,"grilled"))
			. = "It's already grilled."
	return

/obj/machinery/cooking/grill/cook()
	var/foodname = "rotisserie [src.ingredient.name]"
	src.active = 1
	src.icon_state = src.icon_state_on
	src.ingredient.pixel_y += 5 * PIXEL_MULTIPLIER
	src.ingredient.forceMove(src.loc)
	src.ingredient.mouse_opacity = 0
	if (cook_after(src.cookTime/3, 14))
		src.ingredient.color = "#C28566"
		if (cook_after(src.cookTime/3, 14))
			src.ingredient.color = "#A34719"
			if (cook_after(src.cookTime/3, 14))
				src.makeFood()
				if(use_power)
					playsound(src,src.cookSound,100,1)
				else
					src.visible_message("<span class='notice'>\the [foodname] looks ready to eat!</span>")
	src.icon_state = initial(src.icon_state)
	src.active = 0
	return

/obj/machinery/cooking/grill/makeFood()
	if(cooks_in_reagents)
		src.transfer_reagents_to_food()
	if(istype(src.ingredient,/obj/item/weapon/reagent_containers/food))
		var/obj/item/weapon/reagent_containers/food/F = src.ingredient
		F.reagents.add_reagent(NUTRIMENT,10)
		F.reagents.trans_to(src.ingredient,src.ingredient.reagents.total_volume)
	src.ingredient.mouse_opacity = 1
	if(!(findtext(src.ingredient.name,"rotisserie")))
		src.ingredient.name = "grilled [src.ingredient.name]"
	src.ingredient.forceMove(src.loc)

	if(istype(src.ingredient, /obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.ingredient
		if(H.stored_mob)
			H.stored_mob.ghostize()
			H.stored_mob.death()
			qdel(H.stored_mob)

	src.ingredient = null
	return

/obj/machinery/cooking/grill/spit
	name = "spit"
	desc = "the prime in clown cooking technology."
	density = 0
	icon_state = "spit"
	icon_state_on = "spit"
	use_power = 0
	cooks_in_reagents = 0
	machine_flags = null

/obj/machinery/cooking/grill/spit/cook()
	src.ingredient.pixel_y += 7 * PIXEL_MULTIPLIER
	..()
/obj/machinery/cooking/grill/spit/makeFood()
	src.ingredient.name = "rotisserie [src.ingredient.name]"
	..()

/obj/machinery/cooking/grill/spit/attackby(obj/item/I, mob/user)
	user.delayNextAttack(30)
	if(istype(I,/obj/item/weapon/crowbar) && do_after(user,src,30))
		user.visible_message("<span class='notice'>[user] dissassembles the [src].</span>", "<span class='notice'>You dissassemble \the [src].</span>")
		if(src.ingredient)
			ingredient.forceMove(src.loc)
			src.ingredient = null
		new /obj/item/stack/sheet/wood(user.loc)
		qdel(src)
	else
		..()

/obj/machinery/cooking/grill/spit/validateIngredient()
	. = ..()
	if(. == "valid")
		var/turf/turfunder = loc
		var/campfirefound = 0
		for(var/obj/machinery/M in turfunder.contents)
			if(istype(M,/obj/machinery/space_heater/campfire))
				campfirefound = 1
				var/obj/machinery/space_heater/campfire/campfire = M
				if(!campfire.on)
					. = "The campfire isn't lit."
		if(!campfirefound)
			. = "There's no campfire to cook on!"


//=====Actual fucking sensible cooking machines that don't magic bullshit out of thin air

/obj/machinery/oven
	name = "oven"
	desc = "For the chef that has everything."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	var/icon_state_on = "oven_on"
	idle_power_usage = 200
	active_power_usage = 5000
	heat_production = 1500
	source_temperature = T0C+180
	density = 1
	anchored = 1
	use_power = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	var/obj/item/weapon/reagent_containers/within

/obj/machinery/oven/New()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/oven,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

	..()

/obj/machinery/oven/Destroy()
	qdel(within)
	within = null
	..()

/obj/machinery/oven/RefreshParts()
	var/T = 1
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating-1
	active_power_usage = initial(active_power_usage)/T
	T = 1
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		T += M.rating-1
	heat_production = initial(heat_production)*T
	source_temperature = initial(source_temperature)+(T>1 ? T*10: 0)

/obj/machinery/oven/attackby(obj/item/I, mob/user)
	..()
	if(istype(I,/obj/item/weapon/reagent_containers) && !within)
		if(user.drop_item(I,src))
			to_chat(user, "<span class = 'notice'>You place \the [I] into \the [src].</span>")
			within = I
			toggle(user)
		return 1 //Return 1 when handling reagent containers so they don't splash stuff everywhere
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if (istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			user.visible_message("<span class = 'warning'>\The [user] begins to slam \the [M]'s head into \the [src]!</span>",
		"<span class = 'warning'>You begin to slam \the [M]'s head into \the [src].</span>")
			if(do_after_many(user, list(src, M), 1 SECONDS))
				playsound(src, 'sound/effects/clang.ogg', 50, 1)
				user.visible_message("<span class = 'warning'>\The [user] slams \the [M]'s head into \the [src]!</span>")
				M.apply_damage(10, BRUTE, LIMB_HEAD, used_weapon = "Concussive slamming by something on a hinge.")
				if(use_power == 2)
					M.apply_damage((source_temperature-T0C)/10, BURN, LIMB_HEAD, used_weapon = "Contact with heating element.")


/obj/machinery/oven/attack_hand(mob/user)
	if(isjustobserver(user))
		to_chat(user, "<span class = 'warning'>There will be no spooking in my fucking kitchen!</span>")
		return
	if(use_power == 1 && within)
		if(user.put_in_active_hand(within))
			to_chat(user, "<span class = 'notice'>You take \the [within] from \the [src].</span>")
			within = null
	else if(use_power == 2)
		toggle(user)

/obj/machinery/oven/proc/toggle(mob/user)
	if(use_power == 1)
		icon_state = icon_state_on
		use_power = 2
		processing_objects.Add(src)
	else if(use_power == 2)
		icon_state = initial(icon_state)
		use_power = 1
		processing_objects.Remove(src)
	if(user)
		to_chat(user, use_power ? "<span class = 'notice'>You turn \the [src] [use_power == 2 ? "on" : "off"].</span>" : "<span class = 'warning'>\The [src] doesn't seem to be plugged in!</span>")

/obj/machinery/oven/process()
	if(!use_power)
		toggle()
	if(within)
		within.attempt_heating(src)