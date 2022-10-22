//Frying pan
	//todo:
	//add damage vs undead
	//not able to add stuff when it's still cooking
	//attacksounds
	//sizzle sounds/stuff having to be removed manually
	//fires/smoke when something burns
	//globalize recipes and stuff to subsystem to avoid redundancy with microwave
	//implement recipes only being cookable on a pan versus a microwave based on flag
	//make list of acceptable containers more implicit or do away with it as it's already a reagent container?
	//emptying contents/reagents into other stuff?
	//inhand sprites
	//sizzling with reagents in it
	//crafting/cargo/vending/mapping
	//change visible message when start cooking etc.
	//bunsen burners
	//cooking automatically in high heat?
	//cook with heat transfer rather than timer
	//barrels
	//campfires
	//spits?
	//different cook timing based on heat
	//fireplace
	//oven
	//frying stuff in oil?
	//leaving the pan on the stove causing a burned mess or a fire
	//hot pans with glowing red sprite and extra damage
	//throwing stuff at people with pans or stuff falling out when used as a weapon
	//getting scalding oil or other reagents on people
	//sounds on grill, cook etc
	//pan not getting erased when placed on grill is ready
	//food being ready/steam sprite that turns to smoke and fire/burned mess if left on too long
	//do independant in microwave for "fullness" for reagents vs. contents
	//empty contents on floor when splashing
	//disarm intent attack_hand to dump it on a table or on the floor
	//glued stuff sticking in the frying pan
	//add check for being out in the open (dont dump contents inside of a locker, mech, etc.)
	//issue with adding reagents after it already started cooking
	//componentize
	//spilling when thrown/propelled/impacted
	//cooktop component
	//what to do with only reagents/no burned mess/etc(just heat the reagents?)
	//body-part specific text
	//consider only generating the front icon once
	//address infinite toxin farming
	//check that timing is consistent
	//check removing stuff from the grill when power's off
	//chef meals count (passing user into the cooking)
	//is has_extra_item necessary?

/obj/item/weapon/reagent_containers/pan
	name = "frying pan"
	desc = "A sturdy iron frying pan used for cooking."
	icon = 'icons/obj/pan.dmi'
	icon_state = "pan_frying"
	w_class = W_CLASS_MEDIUM
	force = 12
	throwforce = 10
	volume = 100
	flags = FPRINT  | OPENCONTAINER
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,20,50,100)
	attack_mob_instead_of_feed = TRUE
	attack_verb = list("smashes", "bludgeons", "batters", "pans")
	var/limit = 10 //Number of ingredients that the pan can hold at once.
	//var/speed_multiplier = 0.5 //Cooks half as fast as a microwave so it's easier to get stuff on the pan without failing the recipe.
	var/speed_multiplier = 2 //for debugging
	var/reagent_disposal = 1 //Does it empty out reagents when you eject? Default yes.
	var/currentlycooking = 0 //Is it currently cooking?
	var/cookingprogress = 0 //How far along into cooking something are we? Increments by 1 every process() tick. When it reaches, the cook time of the recipe, the recipe is cooked.
	var/datum/recipe/currentrecipe //What recipe is currently being cooked?
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items = list(
							/obj/item/weapon/kitchen/utensil,/obj/item/device/pda,/obj/item/device/paicard,
							/obj/item/weapon/cell,/obj/item/weapon/circuitboard,/obj/item/device/aicard
							)// List of the items you can put in
/*

/obj/item/weapon/reagent_containers/pan/skillet
	name = "skillet"
	desc = "A metal pan used to contain food while cooking."
	icon = 'icons/obj/pan.dmi'
	icon_state = "pan_skillet"

/obj/item/weapon/reagent_containers/pan/wok
	name = "wok"
	desc = "A large, rounded pan used for cooking."
	icon_state = "pan_wok"
*/

/obj/item/weapon/reagent_containers/pan/New()
	. = ..()

	if (!available_recipes)
		available_recipes = new
		for (var/type in (typesof(/datum/recipe)-/datum/recipe))
			available_recipes+= new type
		for (var/datum/recipe/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
		sortTim(available_recipes, /proc/cmp_microwave_recipe_dsc)

	update_icon()

/obj/item/weapon/reagent_containers/pan/proc/contains_anything()
	if(reagents.total_volume || contents.len)
		return TRUE
	else
		return FALSE

/obj/item/weapon/reagent_containers/pan/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/pan/update_icon()

	overlays.len = 0

	if(blood_overlay)
		overlays += blood_overlay

	//reagents:
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "pan20")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 19)
				filling.icon_state = "pan20"
			if(20 to 39)
				filling.icon_state = "pan40"
			if(40 to 59)
				filling.icon_state = "pan60"
			if(60 to 79)
				filling.icon_state = "pan80"
			if(80 to INFINITY)
				filling.icon_state = "pan100"
		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		//filling.layer = layer
		overlays += filling

	//non-reagent ingredients:
	if(contents.len)
		var/matrix/M = matrix()
		M.Scale(0.5, 0.5)
		for(var/atom/content in contents)
			var/mutable_appearance/mini_ingredient = image("icon"=content)
			mini_ingredient.transform = M
			mini_ingredient.pixel_x = 0
			mini_ingredient.pixel_y = 0
			mini_ingredient.layer = FLOAT_LAYER
			mini_ingredient.plane = FLOAT_PLANE
			overlays += mini_ingredient
		//put a front over the ingredients where they're occluded from view by the side of the pan
		var/image/pan_front = image('icons/obj/pan.dmi', src, "pan_front")
		overlays += pan_front
		//put blood back onto the pan front
		if(blood_overlay)

			var/icon/I = new /icon('icons/obj/pan.dmi', "pan_front")
			I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
			I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant

			var/image/frontblood = image(I)
			frontblood.color = blood_color

			overlays += frontblood
			//overlays += blood_overlays["[type]_front"]

/////////////////////Dumping-and-splashing-related stuff/////////////////////
/obj/item/weapon/reagent_containers/pan/afterattack(var/atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	if (!adjacency_flag)
		return

	message_admins("[target]|[user]|[adjacency_flag]|[click_params]")
	//we drop ingredients out of the pan here in three situations:
		//if we are on disarm intent and use it on a table
		//if we use it on a non-dense turf
		//if we use it on a mob

	message_admins("[user]|[user.a_intent]|[user.a_intent == TRUE]|[istable(target)]")
	if((user.a_intent == I_DISARM) && istable(target))
		drop_ingredients(target, user)
	else if(isturf(target))
		var/turf/T = target
		if(!T.density)
			drop_ingredients(target, user)
	else if(ismob(target))
		drop_ingredients(target, user)

	//todo: transferring directly to plates and trays and other foods

/obj/item/weapon/reagent_containers/pan/attackby(var/obj/item/I, var/mob/user)

	//Sanity to avoid adding something to the pan when cooking has already been initiated
	if(currentlycooking)
		to_chat(usr, "<span class='notice'>Something is already cooking on [src]!</span>")

	//If we're using a plant bag, add the contents to the pan.
	else if(istype(I, /obj/item/weapon/storage/bag/plants) || istype(I, /obj/item/weapon/storage/bag/food/borg))
		if(contents.len >= limit)
			to_chat(usr, "<span class='notice'>[src] is completely full!</span>")
			update_icon()
		var/obj/item/weapon/storage/bag/B = I
		for (var/obj/item/weapon/reagent_containers/food/snacks/G in I.contents)
			B.remove_from_storage(G,src)
			if(contents.len >= limit) //Sanity checking so the pan doesn't overfill
				to_chat(user, "<span class='notice'>You fill [src] to the brim.</span>")
				break
		update_icon()

	//If we're using an acceptable item, add the item to the pan.
	else if(is_type_in_list(I,acceptable_items))
		if(contents.len >= limit)
			to_chat(usr, "<span class='notice'>[src] is completely full!</span>")
		else if (istype(I,/obj/item/stack))
			var/obj/item/stack/ST = I
			if(ST.amount > 1)
				new ST.type (src)
				ST.use(1)
				user.visible_message( \
					"<span class='notice'>[user] adds one of [I] to [src].</span>", \
					"<span class='notice'>You add one of [I] to [src].</span>")
				updateUsrDialog()
				update_icon()
		else if(user.drop_item(I, src))
			user.visible_message( \
				"<span class='notice'>[user] adds [I] to [src].</span>", \
				"<span class='notice'>You add [I] to [src].</span>")
			update_icon()

	else if(istype(I,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		to_chat(user, "<span class='notice'>The thought of stuffing [G.affecting] into [src] amuses you.</span>")

	else
		to_chat(user, "<span class='notice'>You have no idea what you can cook with [I].</span>")


/obj/item/weapon/reagent_containers/pan/attack_self(mob/user as mob)
	if(user.a_intent == I_DISARM)
		drop_ingredients()
		return
	//temporarily make attack_self() cook the food for testing
	if(!currentlycooking)
		cook_start()
	else
		cook_abort()

/obj/item/weapon/reagent_containers/pan/proc/drop_ingredients(atom/target)
	var/mob/dropper = usr
	if(!contains_anything())
		return FALSE //Return FALSE if there's nothing to drop.

	var/splashverb = reagents.total_volume ? "splashes" : "dumps"

	var/transfer_result = transfer(target, dropper, splashable_units = -1) // Potentially splash with everything inside
	if(transfer_result >= 10)
		playsound(target ? target : src, 'sound/effects/slosh.ogg', 25, 1)

	for(var/atom/movable/AM in contents)
		AM.forceMove(target ? get_turf(target) : get_turf(src))
		AM.pixel_x = rand(-10, 10)
		AM.pixel_y = rand(-10, 10)

	var/spanclass = "notice"
	if(ismob(target) && (dropper != target))
		spanclass = "warning"

	//now display the appropriate message:
	if(dropper)
		//if we splashed someone while also attacking them, say that the contents spill out onto them
		if((dropper.a_intent != I_HELP) && ismob(target))
			var/mob/M = target
			M.visible_message( \
					"<span class='[spanclass]'>The contents of [src] spill out onto [M][spanclass == "warning" ? "!" : "."]</span>", \
					"<span class='[spanclass]'>The contents of [src] spill out onto you[spanclass == "warning" ? "!" : "."]</span>")
		//otherwise, say that the wielder spills it onto the target
		else
			dropper.visible_message( \
					"<span class='[spanclass]'>[dropper] [splashverb][target ? "" : " out"] the contents of [src][target ? " onto [target == dropper ? get_reflexive_pronoun(dropper) : target]" : ""][spanclass == "warning" ? "!" : "."]</span>", \
					"<span class='[spanclass]'>You [shift_verb_tense(splashverb)][target ? "" : " out"] the contents of [src][target ? " onto [target == dropper ? "yourself" : target]" : ""].</span>")
	else
		visible_message("<span class='warning'>Everything spills out of [src] [target ? "onto [target]" : ""]!</span>")

	cook_abort() //sanity
	update_icon()
	return TRUE

/obj/item/weapon/reagent_containers/pan/container_splash_sub(var/datum/reagents/reagents, var/atom/target, var/amount, var/mob/user = null)

	var/datum/organ/external/affecting = user && user.zone_sel ? user.zone_sel.selecting : null //Find what the player is aiming at

	reagents.reaction(target, TOUCH, amount_override = max(0,amount), zone_sels = affecting ? list(affecting) : ALL_LIMBS)

	if(user)
		user.investigation_log(I_CHEMS, "has splashed [amount > 0 ? "[amount]u of [reagents.get_reagent_ids()]" : "[reagents.get_reagent_ids(1)]"] from \a [reagents.my_atom] \ref[reagents.my_atom] onto \the [target][ishuman(target) ? "'s [parse_zone(affecting)]" : ""].")

	reagents.reaction(get_turf(target ? target : src), TOUCH) //Spill the remainder onto the floor.
	if(amount > 0)
		reagents.remove_any(amount)
	else
		reagents.clear_reagents()

/obj/item/weapon/reagent_containers/pan/attack(mob/M as mob, mob/user as mob, def_zone)
	//If there's something in the pan, and we're on help intent, only splash the mob.
	if(contains_anything() && (user.a_intent == I_HELP))
		return
	return ..()

/*
//generate both base and front overlays
/obj/item/weapon/reagent_containers/pan/generate_blood_overlay()
	if(blood_overlays["[type]"] && blood_overlays["[type]_front"])
		return
	var/icon/Base = new /icon(icon, icon_state)
	Base.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
	Base.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
	blood_overlays["[type]"] = image(Base)
	var/icon/Front = new /icon(icon, "pan_front")
	Front.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
	Front.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
	blood_overlays["[type]_front"] = image(Front)
*/

/////////////////////Cooking-related stuff/////////////////////
/obj/item/weapon/reagent_containers/pan/proc/cook_start() //called when the pan is placed on a valid cooktop (eg. placed on grill)
	visible_message("<span class='notice'>[src] starts cooking.</span>", "<span class='notice'>You hear \a [src] cooking.</span>")
	currentlycooking = 1
	processing_objects.Add(src)
	currentrecipe = select_recipe(available_recipes,src)

/obj/item/weapon/reagent_containers/pan/proc/cook_stop() //called when the pan is no longer on a valid cooktop (eg. removed from grill)
	currentlycooking = 0
	processing_objects.Remove(src)

/obj/item/weapon/reagent_containers/pan/proc/cook_abort() //called when things are dumped out of the pan
	currentlycooking = 0
	cookingprogress = 0
	processing_objects.Remove(src)
	currentrecipe = select_recipe(available_recipes,src)

/obj/item/weapon/reagent_containers/pan/proc/cook_fail() //called when the recipe is invalid (including overcooking something by not removing the pan from the cooktop in time, which is the same as attempting to cook the already-cooked resulting dish)
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in contents-ffuu)
		amount++
		if (O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
		O = null
	reagents.clear_reagents()
	ffuu.reagents.add_reagent(CARBON, amount)
	ffuu.reagents.add_reagent(TOXIN, amount/10)
	if(Holiday == APRIL_FOOLS_DAY)
		playsound(src, "goon/sound/effects/dramatic.ogg", 100, 0)
	ffuu.pixel_x = 0
	ffuu.pixel_y = 0
	currentrecipe = select_recipe(available_recipes, src)
	return ffuu

/obj/item/weapon/reagent_containers/pan/proc/on_valid_cooktop()
	if(istype(loc, /obj/machinery/cooking/grill)) //todo: generalize this, but for now just check if we're on a grill or not
		return TRUE
	return FALSE

/obj/item/weapon/reagent_containers/pan/proc/cooktop_is_on()
	if(istype(loc, /obj/machinery/cooking/grill)) //todo: generalize this, but for now just check if the grill we're on is powered or not
		var/obj/machinery/cooking/grill/G = loc
		if(!(G.stat & (FORCEDISABLE | NOPOWER | BROKEN)))
			return TRUE
	return FALSE

/obj/item/weapon/reagent_containers/pan/process()
	if(!on_valid_cooktop())
		cook_stop()

	if(!cooktop_is_on()) //if the power went out on the grill, don't cook
		return

	cookingprogress += speed_multiplier

	if(cookingprogress >= (currentrecipe ? currentrecipe.time : 10 SECONDS)) //it's done when it's cooked for the cooking time, or a default of 10 seconds if there's no valid recipe

		cookingprogress = 0 //reset the cooking progress

		var/obj/cooked
		if(currentrecipe)
			cooked = currentrecipe.make_food(src)
			visible_message("<span class='notice'>[cooked] looks done.</span>")
		else
			cooked = cook_fail()
		if(cooked)
			cooked.forceMove(src)
			update_icon()

		//re-check the recipe. generally this will return null because we'll continue cooking the previous result, which will lead to a burned mess
		currentrecipe = select_recipe(available_recipes, src)

/*
/obj/item/weapon/reagent_containers/pan/proc/iscooking(var/seconds as num) //Whether or not something is currently cooking in the pan
	for (var/i=1 to seconds)
		sleep(10/speed_multiplier)
	return 1
*/

/obj/item/weapon/reagent_containers/pan/proc/build_list_of_contents()
	var/dat = ""
	var/list/items_counts = new
	var/list/items_measures = new
	var/list/items_measures_p = new
	for (var/obj/O in contents)
		var/display_name = O.name
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
			items_measures[display_name] = "slab of meat"
			items_measures_p[display_name] = "slabs of meat"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat))
			items_measures[display_name] = "fillet of fish"
			items_measures_p[display_name] = "fillets of fish"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
			items_measures[display_name] = "egg"
			items_measures_p[display_name] = "eggs"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
			items_measures[display_name] = "tofu chunk"
			items_measures_p[display_name] = "tofu chunks"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
			display_name = "Turnovers"
			items_measures[display_name] = "turnover"
			items_measures_p[display_name] = "turnovers"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans))
			items_measures[display_name] = "soybean"
			items_measures_p[display_name] = "soybeans"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/grapes))
			display_name = "Grapes"
			items_measures[display_name] = "bunch of grapes"
			items_measures_p[display_name] = "bunches of grapes"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes))
			display_name = "Green Grapes"
			items_measures[display_name] = "bunch of green grapes"
			items_measures_p[display_name] = "bunches of green grapes"
		if (istype(O,/obj/item/weapon/kitchen/utensil)) //any spoons, forks, knives, etc
			items_measures[display_name] = "utensil"
			items_measures_p[display_name] = "utensils"
		items_counts[display_name]++
	for (var/O in items_counts)
		var/N = items_counts[O]
		if (!(O in items_measures))
			dat += {"<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s<BR>"}
		else
			if (N==1)
				dat += {"<B>[capitalize(O)]:</B> [N] [items_measures[O]]<BR>"}
			else
				dat += {"<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]<BR>"}

	for (var/datum/reagent/R in reagents.reagent_list)
		var/display_name = R.name
		if (R.id == CAPSAICIN)
			display_name = "Hotsauce"
		if (R.id == FROSTOIL)
			display_name = "Coldsauce"
		dat += {"<B>[display_name]:</B> [R.volume] unit\s<BR>"}
	return dat

/obj/item/weapon/reagent_containers/pan/examine(mob/user)
	to_chat(user, "[bicon(src)] That's \a [name]. It is [wclass2text(w_class)].")
	if(desc)
		to_chat(user, desc)
	if(get_dist(user, src) <= 3)
		if(contents.len==0 && reagents.reagent_list.len==0)
			to_chat(user, "It's empty.")
		else
			var/list_of_contents = "It contains:<br>" + build_list_of_contents()
			to_chat(user, list_of_contents)
