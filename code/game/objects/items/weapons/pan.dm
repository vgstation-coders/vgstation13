//Frying pan
	//todo:
	//add damage vs undead
	//not able to add stuff when it's still cooking
	//attacksounds
	//sizzle sounds/stuff having to be removed manually
	//fires/smoke when something burns
	//globalize recipies and stuff to subsystem to avoid redundancy with microwave
	//make list of acceptable containers more implicit?
	//fix removing stuff from pan (attack_self?)
	//emptying contents/reagents into other stuff?
	//burned mess sprite on top of pan rather than under?
	//inhand sprites
	//sizzling with reagents in it
	//reagent color overlays
	//fix spam cooking before cook finishes
	//fix food not appearing if pan is held
	//fix reagents not working
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
	//issue with random pixel offsets
	//front overlay not working
	//splash not occuring on attack
	//get splash sound working for sufficient volumes

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
	var/operating = 0 // Is it currently cooking? //todo: rename this
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items = list(
							/obj/item/weapon/kitchen/utensil,/obj/item/device/pda,/obj/item/device/paicard,
							/obj/item/weapon/cell,/obj/item/weapon/circuitboard,/obj/item/device/aicard
							)// List of the items you can put in
	var/global/list/accepts_reagents_from = list(/obj/item/weapon/reagent_containers/glass,
												/obj/item/weapon/reagent_containers/food/drinks,
												/obj/item/weapon/reagent_containers/food/condiment,
												/obj/item/weapon/reagent_containers/dropper)
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

/obj/item/weapon/reagent_containers/pan/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/pan/update_icon()
	message_admins("DEBUG 001")
	overlays.len = 0

	//reagents:
	if(reagents && reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "pan10")

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
		overlays += filling

	//non-reagent ingredients:
	message_admins("DEBUG 002")
	var/needs_front
	for(var/atom/content in contents)
		message_admins("DEBUG 003")
		needs_front = TRUE
		var/mutable_appearance/mini_ingredient = image("icon"=content)
		var/matrix/M = matrix()
		M.Scale(0.5, 0.5)
		mini_ingredient.transform = M
		overlays += mini_ingredient

	//put a front over the ingredients where they're occluded from view by the side of the pan
	message_admins("DEBUG 004")
	if(needs_front)
		message_admins("DEBUG 005")
		var/image/front = image('icons/obj/pan.dmi', src, "pan_front")
		overlays += front

/obj/item/weapon/reagent_containers/pan/afterattack(var/atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	if (!adjacency_flag)
		return

	drop_ingredients(target, user, deliberate = TRUE)

/obj/item/weapon/reagent_containers/pan/attackby(var/obj/item/I, var/mob/user)

	//Sanity to avoid adding something to the pan when cooking has already been initiated
	if(operating)
		to_chat(usr, "<span class='notice'>Something is already cooking on [src]!</span>")

	//If we're using a reagent container that can transfer to the pan, transfer to the pan.
	if(is_type_in_list(I,accepts_reagents_from))
		var/obj/item/weapon/reagent_containers/R = I
		R.transfer(src, user)

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

//temporarily make attack_self() cook the food for testing
/obj/item/weapon/reagent_containers/pan/attack_self(mob/user as mob)
	cook()

/obj/item/weapon/reagent_containers/pan/proc/drop_ingredients(atom/target, deliberate = FALSE)
	var/mob/dropper = usr
	if(contents.len == 0 && reagents.total_volume == 0)
		return
	spill_reagents(target)
	for(var/atom/movable/AM in contents)
		AM.forceMove(target ? get_turf(target) : get_turf(src))
	(deliberate && loc == dropper) ? dropper.visible_message( \
				"<span class='notice'>[dropper] dumps[target ? "" : " out"] the contents of [src][target ? " onto [target]" : ""].</span>", \
				"<span class='notice'>You dump[target ? "" : " out"] the contents of [src][target ? " onto [target]" : ""].</span>") : visible_message("<span class='warning'>Everything spills out of [src]!</span>")
	update_icon()

/obj/item/weapon/reagent_containers/pan/proc/start()
	visible_message("<span class='notice'>[src] starts cooking.</span>", "<span class='notice'>You hear \a [src] cooking.</span>")
	operating = 1
	//icon_state = "mw1"

/obj/item/weapon/reagent_containers/pan/proc/abort()
	operating = 0 // Turn it off again aferwards
	//icon_state = "mw"

/obj/item/weapon/reagent_containers/pan/proc/stop()
	operating = 0 // Turn it off again aferwards
	//icon_state = "mw"

/obj/item/weapon/reagent_containers/pan/proc/fail()
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
	return ffuu

/obj/item/weapon/reagent_containers/pan/proc/iscooking(var/seconds as num) //Whether or not something is currently cooking in the pan
	for (var/i=1 to seconds)
		sleep(10/speed_multiplier)
	return 1

/obj/item/weapon/reagent_containers/pan/proc/cook(mob/user)
	if(operating)
		return
	start()
	if (reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if (!iscooking(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked

	if (!recipe)
		if (has_extra_item())
			if(!iscooking(4))
				abort()
				return
			cooked = fail()
			cooked.forceMove(src)

		else
			if(!iscooking(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.forceMove(src)
		update_icon()
		return
	else
		var/halftime = round(recipe.time/10/2)
		if (!iscooking(halftime))
			abort()
			return
		if (!iscooking(halftime))
			abort()
			cooked = fail()
			cooked.forceMove(src)
			update_icon()
			return
		cooked = recipe.make_food(src,user)
		stop()
		cooked?.forceMove(src)
		update_icon()
		return

/obj/item/weapon/reagent_containers/pan/proc/has_extra_item()
	for (var/obj/O in contents)
		if ( \
				!istype(O,/obj/item/weapon/reagent_containers/food) && \
				!istype(O, /obj/item/weapon/grown) \
			)
			return 1
	return 0

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
