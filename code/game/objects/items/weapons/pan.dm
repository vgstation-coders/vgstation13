/////////////////////Frying pan/////////////////////

/obj/item/weapon/reagent_containers/pan
	name = "frying pan"
	desc = "A sturdy iron frying pan used for cooking."
	icon = 'icons/obj/pan.dmi'
	icon_state = "pan_frying"
	w_class = W_CLASS_MEDIUM
	force = 12
	throwforce = 10
	volume = 100
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL*10)
	w_type = RECYK_METAL
	flags = FPRINT  | OPENCONTAINER
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,20,50,100)
	attack_mob_instead_of_feed = TRUE
	attack_verb = list("smashes", "bludgeons", "batters", "pans")
	hitsound = list('sound/weapons/pan_01.ogg', 'sound/weapons/pan_02.ogg', 'sound/weapons/pan_03.ogg', 'sound/weapons/pan_04.ogg')
	throw_impact_sound = list('sound/weapons/pan_01.ogg', 'sound/weapons/pan_02.ogg', 'sound/weapons/pan_03.ogg', 'sound/weapons/pan_04.ogg')
	miss_sound = list('sound/weapons/pan_miss_01.ogg', 'sound/weapons/pan_miss_02.ogg')
	is_cookvessel = TRUE
	slot_flags = SLOT_HEAD
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 10, bomb = 25, bio = 0, rad = 0)
	body_parts_covered = HEAD
	slimeadd_message = "You spread the slime extract on the SRCTAG"
	slimes_accepted = SLIME_SILVER
	slimeadd_success_message = "It gives off a distinct shine as a result"
	var/mob/chef //The mob who most recently added a non-reagent ingredient to or picked up the pan.
	var/limit = 10 //Number of ingredients that the pan can hold at once.
	var/speed_multiplier = 1 //Can be changed to modify cooking speed.
	var/cookingprogress = 0 //How long have we been cooking the current recipe? When it reaches the cook time of the recipe, the recipe is cooked, and this is reset to 0.
	var/burned //Whether or not the current dish has been burned.
	var/datum/recipe/currentrecipe //What recipe is currently being cooked?
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items = list( // List of the items you can put in
							/obj/item/weapon/kitchen/utensil,/obj/item/device/pda,/obj/item/device/paicard,
							/obj/item/weapon/cell,/obj/item/weapon/circuitboard,/obj/item/device/aicard)
	var/global/list/accepts_reagents_from = list(/obj/item/weapon/reagent_containers/glass, //Used to suppress message when transferring from these to the pan.
												/obj/item/weapon/reagent_containers/food/drinks,
												/obj/item/weapon/reagent_containers/food/condiment,
												/obj/item/weapon/reagent_containers/syringe,
												/obj/item/weapon/reagent_containers/dropper)
	var/open_container_override = FALSE


/obj/item/weapon/reagent_containers/pan/New()
	. = ..()

	if(!available_recipes)
		available_recipes = generate_available_recipes(flags = COOKABLE_WITH_PAN)
		for(var/datum/recipe/recipe in available_recipes)
			for(var/item in recipe.items)
				acceptable_items |= item
		sortTim(available_recipes, /proc/cmp_microwave_recipe_dsc)

	update_icon()

/obj/item/weapon/reagent_containers/pan/proc/contains_anything()
	//Returns (1<<0) if contains reagents, (1<<1) if it contains non-reagent contents, and the bitwise OR if it contains both.
	var/result = 0
	if(reagents.total_volume)
		result |= (1<<0) //1
	if(contents.len)
		result |= (1<<1) //2
	return result

/obj/item/weapon/reagent_containers/pan/on_reagent_change()
	..()
	cook_reboot()
	update_icon()

/obj/item/weapon/reagent_containers/pan/update_temperature_overlays()
	//we only care about the steam

	var/average_chem_temp = 0
	var/chem_temps = 0
	if(reagents && reagents.total_volume)
		average_chem_temp = reagents.chem_temp
		chem_temps = 1
	for(var/atom/content in contents)
		if(content.reagents)
			average_chem_temp += content.reagents.chem_temp
			chem_temps++
	if (chem_temps)
		average_chem_temp /= chem_temps
	steam_spawn_adjust(average_chem_temp)

/obj/item/weapon/reagent_containers/pan/update_icon()
	overlays.len = 0
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
		update_temperature_overlays()
	else
		remove_particles(PS_STEAM)

		//Note: an alternative to the above might be to overlay all of the non-reagent ingredients onto a single icon, then mask it with the "pan_mask" icon_state.
		//This would obviate the need to regenerate the blood overlay, and help avoid anomalies with large ingredient sprites.
		//However I'm not totally sure how to do this nicely.
	set_blood_overlay()

/////////////////////Dumping-and-splashing-related stuff/////////////////////

/obj/item/weapon/reagent_containers/pan/afterattack(var/atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	if (!adjacency_flag)
		return

	//we drop ingredients out of the pan here in three situations:
		//if we are on disarm intent and use it on a table
		//if we use it on a non-dense turf
		//if we use it on a mob

	if((user.a_intent == I_DISARM) && istable(target))
		drop_ingredients(target, user)
	else if(isturf(target))
		var/turf/T = target
		if(!T.density)
			drop_ingredients(target, user)
	else if(ismob(target))
		drop_ingredients(target, user)
	else if(isobj(target) && (loc != target))
		var/obj/O = target
		if(!O.is_cooktop)
			transfer(target, user)

/obj/item/weapon/reagent_containers/pan/attackby(var/obj/item/I, var/mob/user)

	//If the pan is on someone's head, it's upside down so don't put anything in.
	if(is_on_someones_head())
		return

	//If we're using an acceptable item, add the item to the pan.
	if(is_type_in_list(I,acceptable_items))
		if(contents.len >= limit)
			to_chat(usr, "<span class='notice'>[src] is completely full!</span>")
		else if(istype(I,/obj/item/stack))
			var/obj/item/stack/ST = I
			if(ST.amount >= 1)
				user.visible_message( \
					"<span class='notice'>[user] adds \an [ST.singular_name] to [src].</span>", \
					"<span class='notice'>You add \an [ST.singular_name] to [src].</span>")
				new ST.type (src)
				ST.use(1)
				updateUsrDialog()
				cook_reboot(user) //Reset the cooking status.
				update_icon()
		else if(user.drop_item(I, src))
			user.visible_message( \
				"<span class='notice'>[user] adds [I] to [src].</span>", \
				"<span class='notice'>You add [I] to [src].</span>")
			cook_reboot(user) //Reset the cooking status.
			update_icon()

	//If we're using a plant bag, add the contents to the pan.
	else if (istype(I, /obj/item/weapon/storage/bag/plants) || istype(I, /obj/item/weapon/storage/bag/food/borg))
		if(contents.len >= limit)
			to_chat(usr, "<span class='notice'>[src] is completely full!</span>")
			return
		var/obj/item/weapon/storage/bag/B = I
		for (var/obj/item/weapon/reagent_containers/food/snacks/G in I.contents)
			B.remove_from_storage(G,src)
			if(contents.len >= limit) //Sanity checking so the pan doesn't overfill
				to_chat(user, "<span class='notice'>You fill [src] to the brim.</span>")
				break
		cook_reboot(user) //Reset the cooking status.
		update_icon()

	else if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		to_chat(user, "<span class='notice'>The thought of stuffing [G.affecting] into [src] amuses you.</span>")

	else if(!is_type_in_list(I, accepts_reagents_from))
		to_chat(user, "<span class='notice'>You have no idea what you can cook with [I].</span>")

/obj/item/weapon/reagent_containers/pan/attack_self(mob/user as mob)
	take_something_out(user)

/obj/item/weapon/reagent_containers/pan/AltClick(mob/user as mob)
	take_something_out(user)

/obj/item/weapon/reagent_containers/pan/proc/take_something_out(mob/user as mob)
	if(contents.len)
		var/atom/movable/content = contents[contents.len]
		user.put_in_hands(content)
		if(content.loc != src) //If something was taken out successfully.
			to_chat(user, "<span class='notice'>You take [content] out of [src].</span>")
			cook_reboot(user)
			update_icon()

/obj/item/weapon/reagent_containers/pan/proc/something_in_pan()
	if(contents.len)
		return contents[contents.len]

/obj/item/weapon/reagent_containers/pan/proc/drop_ingredients(atom/target, mob/dropper)

	var/contains = contains_anything()
	if(!contains)
		return FALSE //Return FALSE if there's nothing to drop.

	if(dropper ? !isturf(dropper.loc) : FALSE) //No pouring the contents of a pan out while hiding inside of a locker. Let's just say its too cramped.
		return FALSE

	var/splashverb
	if(!dropper)
		splashverb = "spills"
	else if(!(contains & COOKVESSEL_CONTAINS_CONTENTS))
		if(target)
			splashverb = "splashes"
		else
			splashverb = "pours"
	else if(istable(target))
		splashverb = "empties"
	else
		splashverb = "dumps"

	var/transfer_result = transfer(target ? target : get_turf(src), dropper, splashable_units = -1) // Potentially splash with everything inside
	if(transfer_result >= 10)
		playsound(target ? target : src, 'sound/effects/slosh.ogg', 25, 1)

	for(var/atom/movable/AM in contents)
		AM.forceMove(target ? get_turf(target) : get_turf(src))
		AM.pixel_x = rand(-5, 5)
		AM.pixel_y = rand(-5, 5)

	var/spanclass = "notice"
	if(ismob(target) && (dropper != target))
		spanclass = "warning"

	//now display the appropriate message:
	if(dropper)
		//if we splashed someone while also attacking them, say that the contents spill out onto them
		if((dropper.a_intent != I_HELP) && ismob(target))
			var/mob/M = target
			M.visible_message( \
					"<span class='[spanclass]'>[src]'s contents spill out onto [M][spanclass == "warning" ? "!" : "."]</span>", \
					"<span class='[spanclass]'>[src]'s contents spill out onto you[spanclass == "warning" ? "!" : "."]</span>")
		//otherwise, say that the wielder spills it onto the target
		else
			dropper.visible_message( \
					"<span class='[spanclass]'>[dropper] [splashverb][target ? "" : " out"] [src]'s contents [target ? " onto [target == dropper ? get_reflexive_pronoun(dropper.gender) : target]" : ""][spanclass == "warning" ? "!" : "."]</span>", \
					"<span class='[spanclass]'>You [shift_verb_tense(splashverb)][target ? "" : " out"] [src]'s contents [target ? " onto [target == dropper ? "yourself" : target]" : ""].</span>")
	else
		var/mob/living/carbon/on_head_someone = is_on_someones_head()
		if (on_head_someone)
			spanclass = "notice"
			on_head_someone.visible_message( \
					"<span class='[spanclass]'>[src]'s contents spill out onto [on_head_someone][spanclass == "warning" ? "!" : "."]</span>", \
					"<span class='[spanclass]'>[src]'s contents spill out onto you[spanclass == "warning" ? "!" : "."]</span>")
		else
			visible_message("<span class='warning'>[src]'s contents [shift_verb_tense(splashverb)] out[target ? " onto [target]" : ""]!</span>")

	cook_abort() //sanity
	update_icon()
	return TRUE

/obj/item/weapon/reagent_containers/pan/container_splash_sub(var/datum/reagents/reagents, var/atom/target, var/amount, var/mob/user = null)

	var/datum/organ/external/affecting = user && user.zone_sel ? user.zone_sel.selecting : null //Find what the player is aiming at

	reagents.reaction(target, TOUCH, amount_override = max(0,amount), zone_sels = affecting ? list(affecting) : (is_on_someones_head() ? LIMB_HEAD : ALL_LIMBS))

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

/obj/item/weapon/reagent_containers/pan/modify_attack_power(power, mob/attackee, mob/attacker)
	if(istype(attackee, /mob/living/simple_animal/hostile/necro))
		power *= 2 //L4D4EVR
	return power

/obj/item/weapon/reagent_containers/pan/empty_contents()
	set name = "Dump contents"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		to_chat(usr, "<span class='warning'>You can't do that while incapacitated.</span>")
		return
	if(!is_open_container(src))
		return
	if(!src.contains_anything())
		to_chat(usr, "<span class='warning'>\The [src] is empty.</span>")
		return
	if(isturf(usr.loc))
		usr.investigation_log(I_CHEMS, "has emptied \a [src] ([type]) containing [reagents.get_reagent_ids(1)] onto \the [usr.loc].")
		drop_ingredients(usr.loc, usr)

/obj/item/weapon/reagent_containers/pan/throw_impact(hit_atom, speed, user)
	if(ismob(hit_atom))
		drop_ingredients(target = hit_atom, dropper = null)
	return ..()

/////////////////////Cooking-related stuff/////////////////////

/obj/item/weapon/reagent_containers/pan/proc/cook_start() //called when the pan is placed on a valid cooktop (eg. placed on grill)
	var/contains_anything = contains_anything()
	if(contains_anything)
		fast_objects.Add(src)
	if(contains_anything & COOKVESSEL_CONTAINS_CONTENTS)
		currentrecipe = select_recipe(available_recipes,src)

/obj/item/weapon/reagent_containers/pan/proc/cook_stop() //called when the pan is no longer on a valid cooktop (eg. removed from grill). cooking progress is retained unless things are added or removed from the pan
	burned = FALSE
	fast_objects.Remove(src)

/obj/item/weapon/reagent_containers/pan/proc/cook_abort() //called when things are dumped out of the pan
	cook_stop()
	cook_reboot()

/obj/item/weapon/reagent_containers/pan/proc/cook_reboot(mob/user) //called when we want to restart the cooking process eg. when something was added to the pan
	reset_cooking_progress()
	chef = user
	currentrecipe = select_recipe(available_recipes,src)

/obj/item/weapon/reagent_containers/pan/proc/cook_fail() //called when the recipe is invalid (including overcooking something by not removing the pan from the cooktop in time, which is the same as attempting to cook the already-cooked resulting dish)
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for(var/obj/O in contents-ffuu)
		amount++
		if (O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	reagents.clear_reagents()
	ffuu.reagents.add_reagent(CARBON, amount)
	ffuu.reagents.add_reagent(TOXIN, amount/10)
	if(Holiday == APRIL_FOOLS_DAY)
		playsound(src, "goon/sound/effects/dramatic.ogg", 100, 0)
	ffuu.pixel_x = 0
	ffuu.pixel_y = 0
	currentrecipe = select_recipe(available_recipes, src)
	burned = TRUE
	return ffuu

/obj/item/weapon/reagent_containers/pan/process()
	steam_spawn_adjust(0)

	var/obj/O
	if(isobj(loc))
		O = loc
		if(!O.is_cooktop)
			cook_stop()
			return
	else
		cook_stop()
		return

	if(!(O?.can_cook())) //if eg. the power went out on the grill, don't cook
		return

	var/contains_anything = contains_anything()
	var/average_chem_temp = 0
	var/chem_temps = 0
	var/cook_energy = O.cook_energy()
	var/cook_temperature = O.cook_temperature()

	//If there are any reagents in the pan (salt, butter, etc), heat them.
	if(contains_anything & COOKVESSEL_CONTAINS_REAGENTS)
		reagents.heating(cook_energy, cook_temperature)
		average_chem_temp = reagents.chem_temp
		chem_temps = 1
	//If there are non-reagent contents (meat etc), heat them as well
	for(var/atom/content in contents)
		if(content.reagents)
			content.reagents.heating(cook_energy / contents.len, cook_temperature)
			average_chem_temp += content.reagents.chem_temp
			chem_temps++

	//making the pan steam when its content is hot enough
	if (chem_temps)
		average_chem_temp /= chem_temps
	steam_spawn_adjust(average_chem_temp)

	cookingprogress += (SS_WAIT_FAST_OBJECTS * speed_multiplier)

	if(cookingprogress >= (currentrecipe ? currentrecipe.time : 10 SECONDS) && !burned) //it's done when it's cooked for the cooking time, or a default of 10 seconds if there's no valid recipe. also if it's already been burned, don't keep looping burned mess -> burned mess.

		reset_cooking_progress() //reset the cooking progress

		var/obj/cooked
		if(currentrecipe)
			cooked = currentrecipe.make_food(src, chef)
			//shouldn't be needed anymore thanks to thermal entropy and visible steam
			/*
			//If we cooked successfully, don't make the reagents in the food too hot.
			if(!arcanetampered)
				if(cooked.reagents.total_volume)
					if(cooked.reagents.chem_temp > COOKTEMP_HUMANSAFE)
						cooked.reagents.chem_temp = COOKTEMP_HUMANSAFE
			*/
			visible_message("<span class='notice'>[cooked] looks done.</span>")
			playsound(src, 'sound/effects/frying.ogg', 50, 1)
		else if(contains_anything & COOKVESSEL_CONTAINS_CONTENTS) //Don't make a burned mess out of just reagents, even though recipes can call for only reagents (spaghetti). This allows using the pan to heat reagents.
			cooked = cook_fail()

		if(cooked)
			if (cooked.reagents?.chem_temp < COOKTEMP_READY)
				cooked.reagents?.chem_temp = COOKTEMP_READY//so cooking with frozen meat doesn't produce frozen steaks
				cooked.update_icon()
			cooked.forceMove(src)
			update_icon()
			O?.render_cookvessel()

		if(contains_anything)
			//re-check the recipe. generally this will return null because we'll continue cooking the previous result, which will lead to a burned mess
			currentrecipe = select_recipe(available_recipes, src)

	//Hotspot expose
	var/turf/T = get_turf(src)
	if(T)
		try_hotspot_expose(O ? O.cook_temperature() : COOKTEMP_DEFAULT, MEDIUM_FLAME, 0) //Everything but the first arg is taken from igniter.

/obj/item/weapon/reagent_containers/pan/proc/reset_cooking_progress()
	cookingprogress = 0

/obj/item/weapon/reagent_containers/pan/hide_own_reagents()
	return TRUE //because we have a custom examine() that displays the reagents and contents in microwave format

/obj/item/weapon/reagent_containers/pan/examine(mob/user)
	. = ..()
	var/mob/wearer = is_on_someones_head()
	if(wearer)
		to_chat(user, "It looks like [wearer == user ? "you're" : "[wearer] is"] using [src] as a drying pan.")
	else if((get_dist(user, src) <= 3))
		if(contains_anything())
			var/list_of_contents = "It contains:<br>" + build_list_of_contents()
			to_chat(user, "<span class='notice'>[list_of_contents]</span>")
		else
			to_chat(user, "It's empty.")

/////////////////////Wearing the pan/////////////////////

/obj/item/weapon/reagent_containers/pan/equipped(user, slot, hand_index)
	. = .. ()
	chef = user
	if(slot == slot_head)
		//Have to temporarily change a few values to get this to work properly.
		open_container_override = TRUE
		var/prev_heat_conductivity = heat_conductivity
		heat_conductivity = 1
		pour_on_self(user)
		open_container_override = FALSE
		heat_conductivity = prev_heat_conductivity

/obj/item/weapon/reagent_containers/pan/proc/pour_on_self(mob/user)
	drop_ingredients(target = user, dropper = null)
	container_splash_sub(reagents, target = user, amount = reagents.total_volume, user = user)

/obj/item/weapon/reagent_containers/pan/proc/is_on_someones_head()
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(C.get_item_by_slot(slot_head) == src)
			return C

/obj/item/weapon/reagent_containers/pan/is_open_container()
	if(is_on_someones_head())
		return open_container_override
	return ..()

/////////////////////Areas for to consider for further expansion/////////////////////

	//Plating directly to trays and robot trays.
	//Grill sprite dynamically responding to power.
	//Setting chef var on_reagents_change as well.
	//Edge cases like recooking the same warm donk pocket over and over.
	//Getting pans by crafting, cargo crates, and vending machines.
	//Food being ready making a steam sprite that turns to smoke and fire if left on too long.
	//Sizzling sound with hot reagents in the pan.
	//Body-part specific splash text and also when you dump it onto yourself upon equipping to the head.
	//Hot pans with glowing red sprite and extra damage.
	//Stuff dumping out of the pan when attacking a breakable object, window, camera, etc.
	//Generalize thermal transfer parameter.
	//Componentize cooking vessels.
	//Spilling when thrown impacting.
	//Different cook timings based on heat, or cooking with heat transfer (defined at the recipe level?) rather than a timer.
	//Frying stuff in oil (could use recipes for this).
	//Address cases with large ingredient sprites (see the note in update_icon()).
	//Consider generating and storing the pan front blood overlay in the same manner as general blood overlays.
	//Cooking automatically with high ambient heat.
	//Change order of messages with eg. splashing acid on onesself when equipping the pan to the head.
	//Splashing walls or objs with wielded or thrown frying pans.
