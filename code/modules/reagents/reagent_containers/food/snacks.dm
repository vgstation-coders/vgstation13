//Food items that are eaten normally and don't leave anything behind.
#define ANIMALBITECOUNT 4


/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon_state = null
	log_reagents = 1
	w_type = RECYK_BIOLOGICAL
	flammable = TRUE //<--- clueless

	var/food_flags	//Possible flags: FOOD_LIQUID, FOOD_MEAT, FOOD_ANIMAL, FOOD_SWEET
					//FOOD_LIQUID	- for stuff like soups
					//FOOD_MEAT		- stuff that is made from (or contains) meat. Anything that vegetarians won't eat!
					//FOOD_ANIMAL	- stuff that is made from (or contains) animal products other than meat (eggs, honey, ...). Anything that vegans won't eat!
					//FOOD_SWEET	- sweet stuff like chocolate and candy
					//FOOD_LACTOSE  - contains milk
					//FOOD_DIPPABLE - can be dipped once per bite in an open reagent container, adding 1u of its content to the next bite

					//Example: food_flags = FOOD_SWEET | FOOD_ANIMAL
					//Unfortunately, food created by cooking doesn't inherit food_flags!

	var/bitesize = 1 //How much reagents per bite (and thus how fast is the food consumed ?)
	var/bitecount = 0 //How much times was the item bitten ?
	var/trash = null //What left-over should we spawn, if any ?
	var/slice_path //What can we slice this item into, if anything ?
	var/slices_num //How much slices should we expect ?
	var/storage_slots //How many different items can we hide inside us from having them be slipped inside?
	var/eatverb //How do I eat thing ? (Note : Used for message, "bite", "chew", etc...)
	var/wrapped = 0 //Is the food wrapped (preventing one from eating until unwrapped)
	var/dried_type = null //What can we dry the food into
	var/deepfried = 0 //Is the food deep-fried ?
	var/harmfultocorgis = 0 //Is it harmful for corgis to eat?
	var/filling_color = "#FFFFFF" //What color would a filling of this item be ?
	var/list/random_filling_colors = list()
	var/plate_offset_y = 0
	var/plate_icon = "fullycustom"
	var/visible_condiments = list()

	var/crumb_icon = "crumbs"
	var/base_crumb_chance = 10
	var/time_last_eaten

	var/candles_state = CANDLES_NONE
	var/list/candles = list()
	var/always_candles = ""
	var/candle_offset_x = 0
	var/candle_offset_y = 0

	var/valid_utensils = UTENSILE_FORK	//| UTENSILE_SPOON

	volume = 100 //Double amount snacks can carry, so that food prepared from excellent items can contain all the nutriments it deserves

	var/timer = 0 //currently only used on skittering food
	var/datum/reagents/dip

	var/image/extra_food_overlay

/obj/item/weapon/reagent_containers/food/snacks/Destroy()
	QDEL_NULL(dip)
	var/turf/T = get_turf(src)
	if(contents.len)
		for(var/atom/movable/A in src)
			A.forceMove(T)
		visible_message("<span class='warning'>The items sloppily placed within fall out of \the [src]!</span>")
	..()

//Proc for effects that trigger on eating that aren't directly tied to the reagents.
/obj/item/weapon/reagent_containers/food/snacks/proc/after_consume(var/mob/user, var/datum/reagents/reagentreference)
	if(!user)
		return
	if(reagents)
		reagentreference = reagents
	if(!reagentreference || !reagentreference.total_volume) //Are we done eating (determined by the amount of reagents left, here 0)
		user.visible_message("<span class='notice'>[user] finishes eating \the [src].</span>", \
		"<span class='notice'>You finish eating \the [src].</span>")
		score.foodeaten++ //For post-round score

		if(luckiness)
			user.luck_adjust(luckiness, temporary = TRUE)

		//Drop our item before we delete it, to clear any references of ourselves in people's hands or whatever.
		var/old_loc = loc
		if(loc == user)
			user.drop_from_inventory(src)
		else if(ismob(loc))
			var/mob/holder = loc
			holder.drop_from_inventory(src)
		else if(istype(loc, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = loc
			S.remove_from_storage(src)

		if(trash) //Do we have somehing defined as trash for our snack item ?
			//Note : This makes sense in some way, or at least this works, just don't mess with it

			//If trash is a path (like /obj/item/banana_peel), create a new object
			//If trash is an object, use the object

			//If the food item was in somebody's hands when it was eaten, put the trash item into their hands
			//Otherwise, put the trash item in the same place where the food item was
			if(ispath(trash, /obj/item))
				var/obj/item/TrashItem = new trash(old_loc)
				if (virus2?.len)
					for (var/ID in virus2)
						var/datum/disease2/disease/D = virus2[ID]
						TrashItem.infect_disease2(D, 1, "(leftovers on a plate)",1)

				if (istype(TrashItem, /obj/item/trash/plate))
					var/obj/item/trash/plate/P = TrashItem
					P.trash_color = filling_color != "#FFFFFF" ? filling_color : AverageColor(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(src)), override_dir = dir	), 1, 1)
					P.update_icon()

				if(ismob(old_loc))
					var/mob/M = old_loc
					M.put_in_hands(TrashItem)

			else if(istype(trash, /obj/item))
				if(ismob(old_loc))
					var/mob/M = old_loc
					M.put_in_hands(trash)
				else
					var/obj/item/I = trash
					I.forceMove(old_loc)

		qdel(src) //Remove the item, we consumed it

	return

/obj/item/weapon/reagent_containers/food/snacks/proc/make_poisonous(var/list/additional_poisons)
	var/original_total_volume = reagents.total_volume
	reagents.clear_reagents()
	var/static/list/possible_poisons = list(
		BLEACH,
		PLASMA,
		TOXIN,
		SOLANINE,
		PLASTICIDE,
		RADIUM,
		CRYPTOBIOLIN,
		IMPEDREZENE,
		SOYSAUCE,
		MINDBREAKER,
		SPIRITBREAKER,
		MUTAGEN,
		BLOOD,
	)
	if(additional_poisons && additional_poisons.len)
		possible_poisons += additional_poisons.Copy()
	while(reagents.total_volume < original_total_volume)
		var/ourpoison = pick(possible_poisons)
		if(ourpoison == BLOOD)
			var/virus_choice = pick(subtypesof(/datum/disease2/disease) - typesof(/datum/disease2/disease/predefined))
			var/datum/disease2/disease/new_virus = new virus_choice

			var/list/anti = list(
				ANTIGEN_BLOOD	= 0,
				ANTIGEN_COMMON	= 1,
				ANTIGEN_RARE	= 2,
				ANTIGEN_ALIEN	= 0,
				)
			var/list/bad = list(
				EFFECT_DANGER_HELPFUL	= 0,
				EFFECT_DANGER_FLAVOR	= 0,
				EFFECT_DANGER_ANNOYING	= 1,
				EFFECT_DANGER_HINDRANCE	= 2,
				EFFECT_DANGER_HARMFUL	= 4,
				EFFECT_DANGER_DEADLY	= 0,
				)

			new_virus.origin = "Poisoned [name]"

			new_virus.makerandom(list(40,60),list(20,90),anti,bad,src)

			var/list/blood_data = list(
				"viruses" = null,
				"blood_DNA" = null,
				"blood_type" = "O-",
				"resistances" = null,
				"trace_chem" = null,
				"virus2" = list()
			)
			blood_data["virus2"]["[new_virus.uniqueID]-[new_virus.subID]"] = new_virus
			reagents.add_reagent(ourpoison, rand(5, 10), blood_data)
		else
			reagents.add_reagent(ourpoison, rand(5, 10))

/obj/item/weapon/reagent_containers/food/snacks/should_qdel_if_empty()
	return TRUE

/obj/item/weapon/reagent_containers/food/snacks/attack_self(mob/user)
	if(can_consume(user, user))
		consume(user, 1)

/obj/item/weapon/reagent_containers/food/snacks/bite_act(mob/user) //nom nom
	if(can_consume(user, user))
		consume(user, 1)

/obj/item/weapon/reagent_containers/food/snacks/ashtype()
	return /obj/item/weapon/reagent_containers/food/snacks/badrecipe

/obj/item/weapon/reagent_containers/food/snacks/ashify()
	if(!on_fire)
		return
	var/ashtype = ashtype()
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/BR = new ashtype(src.loc)
	BR.reagents.chem_temp = reagents.chem_temp
	BR.update_icon()//so the burned mess remains steaming
	extinguish()
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ashtype()
	return /obj/effect/decal/cleanable/ash

/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ashify()
	if(!on_fire)
		return
	var/ashtype = ashtype()
	new ashtype(src.loc)
	extinguish()
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/New()
	..()
	dip = new/datum/reagents(1)
	dip.my_atom = src
	extra_food_overlay = image('icons/effects/32x32.dmi',null,"blank")
	if (random_filling_colors?.len > 0)
		filling_color = pick(random_filling_colors)

/obj/item/weapon/reagent_containers/food/snacks/proc/light(var/flavor_text = "<span class='notice'>[usr] lights [src].</span>", var/quiet = 0)
	if(candles_state == CANDLES_UNLIT)
		candles_state = CANDLES_LIT
		visible_message(flavor_text)
		set_light(CANDLE_LUM,1,LIGHT_COLOR_FIRE)
		update_icon()

/obj/item/weapon/reagent_containers/food/snacks/blow_act(var/mob/living/user)
	if(candles_state == CANDLES_LIT)
		candles_state = CANDLES_UNLIT
		visible_message("<span  class='rose'>The candle[(candles.len > 1) ? "s" : ""] on \the [name] go[(candles.len > 1) ? "" : "es"] out.</span>")
		set_light(0)
		update_icon()

/obj/item/weapon/reagent_containers/food/snacks/clean_act(var/cleanliness)
	..()
	if(candles_state == CANDLES_LIT)
		candles_state = CANDLES_UNLIT
		visible_message("<span  class='rose'>The candle[(candles.len > 1) ? "s" : ""] on \the [name] go[(candles.len > 1) ? "" : "es"] out.</span>")
		set_light(0)
		update_icon()

/obj/item/weapon/reagent_containers/food/snacks/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/snacks/update_icon()
	overlays.len = 0//no choice here but to redraw everything in the correct order so condiments etc don't appear over ice and fire.
	overlays += extra_food_overlay

	if (candles_state != CANDLES_NONE)
		for (var/image/I in candles)
			overlays += I
	if (candles_state == CANDLES_LIT)
		for (var/image/I in candles)
			var/image/M = image(I)
			M.appearance = I.appearance
			M.color = null
			M.icon_state = "[M.icon_state]_lit"
			M.appearance_flags = RESET_COLOR
			M.blend_mode = BLEND_ADD
			if (isturf(loc))
				M.plane = ABOVE_LIGHTING_PLANE
			else
				M.plane = ABOVE_HUD_PLANE // inventory
			overlays += M

		if (always_candles)//birthday cake and its slices
			var/image/I = image('icons/obj/food.dmi',src,"[always_candles]_lit")
			I.appearance_flags = RESET_COLOR
			I.blend_mode = BLEND_ADD
			I.pixel_y = candle_offset_y
			if (isturf(loc))
				I.plane = ABOVE_LIGHTING_PLANE
			else
				I.plane = ABOVE_HUD_PLANE // inventory
			overlays += I

	update_temperature_overlays()
	set_blood_overlay()//re-applying blood stains
	if (on_fire && fire_overlay)
		overlays += fire_overlay

/obj/item/weapon/reagent_containers/food/snacks/attack(mob/living/M, mob/user, def_zone, eat_override = 0)	//M is target of attack action, user is the one initiating it
	if(restraint_resist_time > 0)
		if(restraint_apply_check(M, user))
			return attempt_apply_restraints(M, user)
	if(!eatverb)
		eatverb = pick("bite", "chew", "nibble", "gnaw", "gobble", "chomp")
	if(!reagents.total_volume)	//Are we done eating (determined by the amount of reagents left, here 0)
		//This is mostly caused either by "persistent" food items or spamming
		to_chat(user, "<span class='notice'>There's nothing left of \the [src]!</span>")
		qdel(src)
		return 0

	if(istype(M, /mob/living/carbon)) //Avoid messing with simple mobs
		var/mob/living/carbon/target = M //First definition to avoid colons
		if(target == user)	//If you're eating it yourself
			if(!can_consume(M, user))
				return 0

			var/fullness = target.nutrition + (target.reagents.get_reagent_amount(NUTRIMENT) * 25) //This reminds me how unlogical mob nutrition is

			if(fullness <= 50)
				target.visible_message("<span class='notice'>[target] hungrily [eatverb]s some of \the [src] and gobbles it down!</span>", \
				"<span class='notice'>You hungrily [eatverb] some of \the [src] and gobble it down!</span>")
			else if(fullness > 50 && fullness < 150)
				target.visible_message("<span class='notice'>[target] hungrily [eatverb]s \the [src].</span>", \
				"<span class='notice'>You hungrily [eatverb] \the [src].</span>")
			else if(fullness > 150 && fullness < 350)
				target.visible_message("<span class='notice'>[target] [eatverb]s \the [src].</span>", \
				"<span class='notice'>You [eatverb] \the [src].</span>")
			else if(fullness > 350 && fullness < 550)
				target.visible_message("<span class='notice'>[target] unwillingly [eatverb]s some of \the [src].</span>", \
				"<span class='notice'>You unwillingly [eatverb] some of \the [src].</span>")

		else //Feeding someone else, target is eating, user is feeding

			var/fullness = target.nutrition + (target.reagents.get_reagent_amount(NUTRIMENT) * 25)

			if(fullness <= (550 * (1 + M.overeatduration / 1000))) //The mob will accept
				target.visible_message("<span class='danger'>[user] attempts to feed [target] \the [src].</span>", \
				"<span class='userdanger'>[user] attempts to feed you \the [src].</span>", \
				"<span class='userdanger'>You feel \a [src] being pushed into your mouth.</span>")
			else //The mob is overfed and will refuse
				target.visible_message("<span class='danger'>[user] cannot force anymore of \the [src] down [target]'s throat!</span>", \
				"<span class='userdanger'>[user] cannot force anymore of \the [src] down your throat!</span>", \
				"<span class='userdanger'>[src] cannot be forced down your throat any more!</span>")
				return 0

			if(!do_mob(user, target))
				return

			if(!can_consume(target, user))
				return

			add_logs(user, target, "fed", object="[reagentlist(src)]")
			target.visible_message("<span class='danger'>[user] feeds [target] \the [src].</span>", \
			"<span class='userdanger'>[user] feeds you \the [src].</span>", \
			"<span class='userdanger'>You have been fed \a [src].</span>")

		return consume(target)

	return 0

/obj/item/weapon/reagent_containers/food/snacks/proc/before_consume(mob/living/carbon/eater)
	return

//Bitesizemod to multiply how much of a bite should be taken out. 1 is default bitesize.
/obj/item/weapon/reagent_containers/food/snacks/proc/consume(mob/living/eater, messages = 0, sounds = TRUE, bitesizemod = 1)
	if(!istype(eater))
		return
	if(arcanetampered)
		eater.visible_message("<span class='sinister'>[eater]'s mouth goes right through \the [src] </span><span class='danger'>and bites \his hand! Ouch!</span>", \
		"<span class='sinister'>Your mouth goes right through \the [src] </span><span class='danger'>and bites your hand! Ouch!</span>")
		var/oldselect = eater.zone_sel.selecting
		eater.zone_sel.selecting = eater.active_hand == GRASP_RIGHT_HAND ? LIMB_RIGHT_HAND : LIMB_LEFT_HAND
		eater.bite_act(eater,TRUE)
		eater.zone_sel.selecting = oldselect
		return
	if(!eatverb)
		eatverb = pick("bite", "chew", "nibble", "gnaw", "gobble", "chomp")

	before_consume(eater)

	if(messages)
		var/fullness = eater.nutrition + (eater.reagents.get_reagent_amount(NUTRIMENT) * 25)
		if(fullness <= 50)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s some of \the [src] and gobbles it down!</span>", \
			"<span class='notice'>You hungrily [eatverb] some of \the [src] and gobble it down!</span>")
		else if(fullness > 50 && fullness < 150)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s \the [src].</span>", \
			"<span class='notice'>You hungrily [eatverb] \the [src].</span>")
		else if(fullness > 150 && fullness < 350)
			eater.visible_message("<span class='notice'>[eater] [eatverb]s \the [src].</span>", \
			"<span class='notice'>You [eatverb] \the [src].</span>")
		else if(fullness > 350 && fullness < 550)
			eater.visible_message("<span class='notice'>[eater] unwillingly [eatverb]s some of \the [src].</span>", \
			"<span class='notice'>You unwillingly [eatverb] some of \the [src].</span>")

	var/datum/reagents/reagentreference = reagents //Even when the object is qdeleted, the reagents exist until this ref gets removed
	var/datum/reagents/dipreference = dip

	if(reagentreference)	//Handle ingestion of any reagents (Note : Foods always have reagents)
		if(sounds)
			playsound(eater, 'sound/items/eatfood.ogg', rand(10,50), 1)
		var/chance_of_crumbs = base_crumb_chance
		var/time_since_last_eaten = world.time - time_last_eaten
		if (time_since_last_eaten < 10)
			chance_of_crumbs *= 2 // speed eating should be messy
		else if (time_since_last_eaten < 20)
			chance_of_crumbs *= 1.2
		if (eater.a_intent == I_HURT)
			chance_of_crumbs *= 1.5 // I guess angry eating is meant to be an explicit display of bad table manners
		time_last_eaten = world.time
		if (istype(src,/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom))
			chance_of_crumbs *= 0.3	// Plates help a lot to prevent crumbs
		chance_of_crumbs = clamp(chance_of_crumbs, 0, 100)
		if (prob(chance_of_crumbs))
			var/turf/T = get_turf(eater)
			var/list/crumbs_on_floor = list()
			var/crumbs_to_del = 0
			for (var/obj/effect/decal/cleanable/crumbs/old_crumb in T)
				crumbs_on_floor += old_crumb
				if (crumbs_on_floor.len >= 4)
					crumbs_to_del++
			for (var/obj/effect/decal/cleanable/crumbs/old_crumb in crumbs_on_floor)
				if (!crumbs_to_del)
					break
				qdel(old_crumb)	// This way the oldest ones are deleted first
				crumbs_to_del--
			var/obj/effect/decal/cleanable/crumbs/C = new (T)
			C.icon_state = crumb_icon
			C.name = crumb_icon
			C.dir = pick(cardinal)
			C.color = filling_color != "#FFFFFF" ? filling_color : AverageColor(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(src)), override_dir = dir), 1, 1)
			if (random_filling_colors?.len > 0)
				filling_color = pick(random_filling_colors)
		if (virus2?.len)
			for (var/ID in virus2)
				var/datum/disease2/disease/D = virus2[ID]
				eater.infect_disease2(D, 1, notes="(Ate an infected [src])")//eating infected food means 100% chance of infection.
		if (dipreference && dipreference.total_volume)
			dipreference.reaction(eater, INGEST, amount_override = 1)
			dipreference.trans_to(eater, 1)
		if(reagentreference.total_volume)
			reagentreference.reaction(eater, INGEST, amount_override = min(reagentreference.total_volume,bitesize*bitesizemod)/(reagentreference.reagent_list.len))
			spawn() //WHY IS THIS SPAWN() HERE
				if(gcDestroyed)
					return
				reagentreference.adjust_consumed_reagents_temp()
				reagentreference.trans_to(eater, min(reagentreference.total_volume,bitesize*bitesizemod))
				reagentreference.reset_consumed_reagents_temp()
				bitecount++
				after_consume(eater, reagentreference)
		return 1

/obj/item/weapon/reagent_containers/food/snacks/proc/can_consume(mob/living/carbon/eater, mob/user)
	if(!istype(eater))
		return
	if(!eater.hasmouth())
		return
	if(is_empty())	//Are we done eating (determined by the amount of reagents left, here 0)
		//This is mostly caused either by "persistent" food items or spamming
		to_chat(user, "<span class='notice'>There's nothing left of \the [src].</span>")
		if(should_qdel_if_empty())
			qdel(src)
		return
	if(wrapped)
		to_chat(user, "<span class='notice'>\The [src] is still wrapped.</span>")
		return

	var/fullness = eater.nutrition + (eater.reagents.get_reagent_amount(NUTRIMENT) * 25) //This reminds me how unlogical mob nutrition is

	if(fullness > (550 * (1 + eater.overeatduration / 2000)))	// The more you eat - the more you can eat
		to_chat(user, "<span class='notice'>You cannot force any more of \the [src] to go down [(user==eater) ? "your" : "\the [eater]'s"] throat.</span>")
		return

	if(ishuman(eater))
		var/mob/living/carbon/human/H = eater
		if((H.species.chem_flags & NO_EAT) && !(src.food_flags & FOOD_SKELETON_FRIENDLY))
			if(ismob(loc))
				var/mob/M = loc
				M.drop_from_inventory(src)
			src.forceMove(get_turf(H))
			H.visible_message("<span class='warning'>\The [src] falls through \the [eater] and onto the ground, completely untouched.</span>",\
			"<span class='notice'>As [user] attempts to feed you \the [src], \he falls through your body and onto the ground, completely untouched.</span>")
			return
		if(H.mutations.Find(M_VEGAN))
			if(food_flags & (FOOD_MEAT | FOOD_ANIMAL))
			//if(prob(66))
				H.visible_message("<span class='warning'>[H] winces at the taste of \the [src], finding it absolutely disgusting.</span>",\
				"<span class='warning'>\The [src] is disgusting! Your vegan digestive system rejects \him.</span>")

				if(H.lastpuke) //If already puking, add some toxins
					H.adjustToxLoss(2.5)
				else
					H.vomit()

		if(H.mutations.Find(M_LACTOSE))
			if(food_flags & (FOOD_LACTOSE))
				H.visible_message("<span class='warning'>[H] winces at the taste of \the [src], finding it absolutely disgusting.</span>",\
				"<span class='warning'>\The [src] is disgusting! Your stomach rejects \him.</span>")

				if(H.lastpuke) //If already puking, add some toxins
					H.adjustToxLoss(2.5)
				else
					H.vomit()

				if(isskellington(H))
					H.adjustBruteLoss(rand(1,3))

	return 1

/obj/item/weapon/reagent_containers/food/snacks/proc/splat_reagent_reaction(turf/T, mob/user)
	if(reagents.total_volume > 0)
		reagents.reaction(T)
		for(var/atom/A in T)
			if (A == src)
				continue
			if(iscarbon(A))
				var/mob/living/carbon/C = A
				if(C.check_shields(throwforce, src))
					continue
			var/list/hit_zone = user && user.zone_sel ? list(user.zone_sel.selecting) : ALL_LIMBS
			reagents.reaction(A, zone_sels = hit_zone)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/snacks/examine(mob/user)
	..()
	if (dip && dip.total_volume)
		to_chat(user, "<span class='info'>\The [src] appears to have been dipped in [dip.get_master_reagent_name()].</span>")
	if (bitecount)
		if(bitecount == 1)
			to_chat(user, "<span class='info'>\The [src] was bitten by someone!</span>")
		else if(bitecount > 1 && bitecount <= 3)
			to_chat(user, "<span class='info'>\The [src] was bitten [bitecount] times!</span>")
		else
			to_chat(user, "<span class='info'>\The [src] was bitten multiple times!</span>")

/obj/item/weapon/reagent_containers/food/snacks/proc/is_compatible_utensil(var/obj/item/W,var/mob/user)
	if(!istype(W, /obj/item/weapon/kitchen/utensil/fork) && !istype(W, /obj/item/weapon/kitchen/utensil/spoon) && !istype(W, /obj/item/weapon/kitchen/utensil/spork))
		return 0

	if (valid_utensils == 0) // Snacks in packets such as chips and candy bars mainly
		to_chat(user, "<span class='warning'>You're not quite sure how you could eat that with utensils, just eat it barehanded.</span>")
		return 1

	if (istype(W, /obj/item/weapon/kitchen/utensil/fork))
		if (valid_utensils & UTENSILE_FORK)
			return 2

		else if (valid_utensils & UTENSILE_SPOON)
			to_chat(user, "<span class='warning'>You need a spoon to eat that properly.</span>")
			return 1

	if (istype(W, /obj/item/weapon/kitchen/utensil/spoon))
		if (valid_utensils & UTENSILE_SPOON)
			var/obj/item/weapon/kitchen/utensil/spoon/spoon = W
			if (spoon.bent)
				to_chat(user, "<span class='warning'>Can't eat properly with a broken spoon.</span>")
				return 1
			return 2

		else if (valid_utensils & UTENSILE_FORK)
			to_chat(user, "<span class='warning'>You need a fork to eat that properly.</span>")
			return 1

	if (istype(W, /obj/item/weapon/kitchen/utensil/spork))
		var/obj/item/weapon/kitchen/utensil/spork/spork = W
		if (valid_utensils & UTENSILE_SPOON)
			spork.liquid_content = TRUE
			return 2

		else if (valid_utensils & UTENSILE_FORK)
			spork.liquid_content = FALSE
			return 2


/obj/item/weapon/reagent_containers/food/snacks/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/pen)) //Renaming food
		var/n_name = copytext(sanitize(input(user, "What would you like to name this dish?", "Food Renaming", null) as text|null), 1, MAX_NAME_LEN*3)
		if(n_name && Adjacent(user) && !user.stat)
			name = "[n_name]"
		return
	var/utensil_check = is_compatible_utensil(W,user)
	if(utensil_check)
		if (utensil_check == 1)
			return
		var/obj/item/weapon/kitchen/utensil/utensil = W
		if(slices_num || slice_path)
			to_chat(user, "<span class='warning'>You can't take the whole [src] at once! Slice it with a knife first.</span>")
			return
		else
			if (random_filling_colors?.len > 0)
				filling_color = pick(random_filling_colors)
			return utensil.load_food(src, user)

	if (..())
		return

	//Food slicing
	if(W.sharpness_flags & (SHARP_BLADE|CHOPWOOD|SERRATED_BLADE))
		if(!isturf(src.loc) || !(locate(/obj/structure/table) in src.loc) && !(locate(/obj/item/weapon/tray) in src.loc))
			to_chat(user, "<span class='notice'>You cannot slice \the [src] here! You need a table or at least a tray.</span>")
			return 1
		if(slice_act(user,W))
			return 1
		
	if (istype(W, /obj/item/candle)) //candles added on afterattack
		return 0

	if((candles_state == CANDLES_UNLIT) && (W.is_hot() || W.sharpness_flags & (HOT_EDGE)))
		light("<span class='notice'>[user] lights \the [src] with \the [W].</span>")
		return 1

	//Slipping items into food. Because this is below slicing, sharp items can't go into food. No knife-bread, sorry.
	if(can_hold(W))
		if(!iscarbon(user)) //Presumably so robots can't put their modules inside?
			return 0

		if(contents.len >= storage_slots) //There's a rational limit to this madness people
			to_chat(user, "<span class='warning'>\The [src] is already too full to fit \the [W].</span>")
			return 0

		if(user.drop_item(W, src))
			to_chat(user, "<span class='notice'>You slip \the [W] inside [src].</span>")

		add_fingerprint(user)
		contents += W
		return 1 //No afterattack here

/obj/item/weapon/reagent_containers/food/snacks/proc/slice_act(mob/user,obj/item/W)
	if(slice_path && slices_num && slices_num > 0)
		var/slices_lost = 0
		if(W.is_sharp() >= 1.2)
			user.visible_message("<span class='notice'>[user] slices \the [src].</span>", \
			"<span class='notice'>You slice \the [src].</span>")
		else
			user.visible_message("<span class='notice'>[user] inaccurately slices \the [src] with \the [W]!</span>", \
			"<span class='notice'>You inaccurately slice \the [src] with \the [W]!</span>")
			slices_lost = rand(1, min(1, round(slices_num/2))) //Randomly lose a few slices along the way, but at least one and up to half
		var/reagents_per_slice = reagents.total_volume/slices_num //Figure out how much reagents each slice inherits (losing slices loses reagents)
		for(var/i = 1 to (slices_num - slices_lost)) //Transfer those reagents
			var/obj/item/weapon/reagent_containers/food/snacks/slice = new slice_path(get_turf(src))
			if(istype(src, /obj/item/weapon/reagent_containers/food/snacks/customizable)) //custom sliceable foods have overlays we need to apply
				var/obj/item/weapon/reagent_containers/food/snacks/customizable/C = src
				var/obj/item/weapon/reagent_containers/food/snacks/customizable/S = slice
				S.name = "[C.name][S.name]"
				S.filling.color = C.filling.color
				S.extra_food_overlay.overlays += S.filling
				S.overlays += S.filling
			if(luckiness && isitem(slice))
				var/obj/item/sliceItem = slice
				sliceItem.luckiness += luckiness / slices_num
			reagents.trans_to(slice, reagents_per_slice)
			for (var/C in visible_condiments)
				var/image/I = image('icons/obj/condiment_overlays.dmi',slice,C)
				I.color = visible_condiments[C]
				slice.extra_food_overlay.overlays += I
				slice.overlays += I
			if (candles.len > 0)
				var/image/candle = pick(candles)
				candles.Remove(candle)
				candle.pixel_x = 0
				candle.pixel_y = 0
				slice.candles += candle
				slice.candles_state = candles_state
				if (slice.candles_state == CANDLES_LIT)
					slice.set_light(CANDLE_LUM,0.5,LIGHT_COLOR_FIRE)
			else if (always_candles)
				slice.candles_state = candles_state
				if (slice.candles_state == CANDLES_LIT)
					slice.set_light(CANDLE_LUM,0.5,LIGHT_COLOR_FIRE)
			slice.update_icon() //So hot slices start steaming right away
		qdel(src) //So long and thanks for all the fish
		return 1
	if(contents.len) //Food item is not sliceable but still has items hidden inside. Using a knife on it should be an easy way to get them out.
		for(var/atom/movable/A in src)
			A.forceMove(get_turf(src))
		visible_message("<span class='warning'>The items sloppily placed within fall out of \the [src]!</span>")
		return 1

/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom/slice_act(mob/user,obj/item/W) // to stop plate duplication memes
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in src)
		. |= S.slice_act(user,W)
	if(!contents.len) // get rid of this if we're done here (ie the item we hold got baleeeeted)
		new trash(loc)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if (food_flags & FOOD_DIPPABLE)
		if (target.is_open_container() && user.Adjacent(target))
			var/obj/item/weapon/reagent_containers/container = target
			if(!istype(container))
				return
			if (dip && dip.total_volume)
				to_chat(user, "<span class='warning'>\The [src] is already dipped in [dip.get_master_reagent_name()]. Take a bite before you can dip it further.</span>")
				return
			if (container.is_empty())
				to_chat(user, "<span class='warning'>\The [container] is empty.</span>")
				return
			container.reagents.trans_to(dip, 1)
			to_chat(user, "<span class='notice'>You dip \the [src] in [dip.get_master_reagent_name()] from \the [container].</span>")

//For slipping solid junk inside food items, like hiding a PDA inside a loaf of bread or something.
/obj/item/weapon/reagent_containers/food/snacks/proc/can_hold(obj/item/weapon/W)
	if(storage_slots < 1)
		return FALSE
	if(W.w_class > W_CLASS_SMALL)
		return FALSE
	if(W.w_class >= src.w_class)
		return FALSE
	if(istype(W, /obj/item/device/analyzer/plant_analyzer)) //ugly hack but what can you do
		return FALSE
	if(istype(W, /obj/item/weapon/reagent_containers/food/condiment))
		return FALSE
	return TRUE

/obj/item/weapon/reagent_containers/food/snacks/attack_animal(mob/M)
	if(isanimal(M))
		if(iscorgi(M)) //Feeding food to a corgi
			var/bamount = min(reagents.total_volume,bitesize)/(reagents.reagent_list.len)
			reagents.reaction(M, INGEST, amount_override = bamount)
			reagents.trans_to(M, bamount)
			bitecount++
			after_consume(M, reagents)
			playsound(M,'sound/items/eatfood.ogg', rand(10,50), 1)
			M.delayNextAttack(10)
			if(harmfultocorgis)
				var/mob/living/simple_animal/corgi/C = M
				C.atepoison()
			if(!reagents || !reagents.total_volume)
				M.visible_message("[M] [pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where \the [src] was")].", "<span class='notice'>You swallow up the last of \the [src].")
				qdel(src)
			else
				M.visible_message("[M] takes a bite of \the [src].", "<span class='notice'>You take a bite of \the [src].</span>")


		else if(ismouse(M)) //Mouse eating shit
			M.delayNextAttack(10)
			var/mob/living/simple_animal/mouse/N = M
			flick(N.icon_eat, N)
			if(prob(25)) //We are noticed
				N.visible_message("[N] nibbles away at \the [src].", "<span class='notice'>You nibble away at \the [src].</span>")
			else
				to_chat(N, ("<span class='notice'>You nibble away at \the [src].</span>"))
			N.health = min(N.health + 1, N.maxHealth)
			N.nutrition += 10
			if (virus2?.len)
				for (var/ID in virus2)
					var/datum/disease2/disease/D = virus2[ID]
					N.infect_disease2(D, 1, notes="(Ate an infected [src])")//eating infected food means 100% chance of infection.
			reagents.trans_to(N, 0.25)
			bitecount+= 0.25
			after_consume(M,src.reagents)

/obj/item/weapon/reagent_containers/food/snacks/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"bitecount",
		"eatverb",
		"wrapped",
		"deepfried")

	reset_vars_after_duration(resettable_vars, duration)

/obj/item/weapon/reagent_containers/food/snacks/spook()
	if(reagents.has_reagent(ECTOPLASM))
		visible_message("<span class='warning'>A specter takes a bite of \the [src] from beyond the grave!</span>")
		playsound(src,'sound/items/eatfood.ogg', rand(10,50), 1)
		bitecount++
		reagents.remove_any(bitesize)
		if(!reagents.total_volume)
			qdel(src)

////////////////////////////////////////////////////////////////////////////////
/// FOOD END
////////////////////////////////////////////////////////////////////////////////


//	multispawner: class for recipes that spawn more than one food item
//	To use, inherit your spawner from it and adjust child_type and child_volume
//	and set your recipe's result to your spawner.
//	reagents.add_reagent() should take place in your spawner's New() proc, not in its children's.
//	Consult sushi types below for examples of usage.

// Multispawners take the total amount of reagents, both the ones added by the recipe and the ingredients's ones, divides the number by the child volume and spawns that many of items.
// For example: If the child volume is 1 and the total reagents, both from the ingredients and the extra upon cooking, add to 10u, then it would spawn 10 items.
// This means that "stronger" ingredients spawn more items.
// If you have child volume 5, the recipe adds 10u reagents and the ingredients' reagents add 10 more, the multispawner would spawn 4 items, since (10+10):5=4.
// Only the fooditem ingredient reagents get tallied, any "raw" reagents the recipe calls for, such as flour, don't get counted for multispawner purposes.

/obj/item/weapon/reagent_containers/food/snacks/multispawner
	name = "food spawner"
	var/child_type = /obj/item/weapon/reagent_containers/food/snacks
	var/child_volume = 3 // every spawned child will have this much or less reagent transferred to it. Small number = a lot of small items spawn

// called when it leaves the microwave
/obj/item/weapon/reagent_containers/food/snacks/multispawner/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	. = ..()
	if(isnull(destination))
		return
	spawn_children()
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/multispawner/proc/spawn_children()
	var/num_of_children = reagents.total_volume / child_volume
	// this is the BYOND ceil, say something nice about it
	num_of_children = (round(num_of_children) < num_of_children) ? round(num_of_children) + 1 : round(num_of_children)
	var/amount_to_transfer = reagents.total_volume / num_of_children
	for(var/i in 1 to num_of_children)
		var/obj/child = new child_type()
		reagents.trans_to(child, amount_to_transfer)
		child.forceMove(loc)
		child.pixel_x = rand(-8, 8)
		child.pixel_y = rand(-8, 8)


//////////////////////////////////////////////////
////////////////////////////////////////////Snacks
//////////////////////////////////////////////////
//Items in the "Snacks" subcategory are food items that people actually eat. The key points are that they are created
//	already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

//Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units Generally speaking, you don't want to go over 40
//	total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
//	it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use Tricordrazine). On use
//	effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

//The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
//	2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
//	bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
//	the bites. No more contained reagents = no more bites.

//Here is an example of the new formatting for anyone who wants to add more food items.
///obj/item/weapon/reagent_containers/food/snacks/xenoburger			//Identification path for the object.
//	name = "Xenoburger"													//Name that displays in the UI.
//	desc = "Smells caustic. Tastes like heresy."						//Duh
//	icon_state = "xburger"												//Refers to an icon in food.dmi
//	food_flags = FOOD_MEAT												//For flavour, not that important. Flags are: FOOD_MEAT, FOOD_ANIMAL (for things that vegans don't eat), FOOD_SWEET, FOOD_LIQUID (soups). You can have multiple flags in here by doing this: food_flags = FOOD_MEAT | FOOD_SWEET
//
///obj/item/weapon/reagent_containers/food/snacks/xenoburger/New()																//Don't mess with this.
//	..()															//Same here.
//	reagents.add_reagent(XENOMICROBES, 10)						//This is what is in the food item. you may copy/paste
//	reagents.add_reagent(NUTRIMENT, 2)							//	this line of code for all the contents.
//	bitesize = 3													//This is the amount each bite consumes.




/obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	name = "Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#005369"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/aesirsalad/New()
	..()
	eatverb = pick("crunch", "devour", "nibble", "gnaw", "gobble", "chomp")
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(TRICORDRAZINE, 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	food_flags = FOOD_SWEET
	filling_color = "#603000"

/obj/item/weapon/reagent_containers/food/snacks/candy/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)
	reagents.add_reagent(SUGAR, 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/candy/donor/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	reagents.add_reagent(SUGAR, 3)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Can be stored in a detective's hat."
	icon_state = "candy_corn"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/candy_corn/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(SUGAR, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy_cane
	name = "candy cane"
	desc = "It's a classic striped candy cane."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "candycane"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/candy_cane/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(SUGAR, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	base_crumb_chance = 20
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/cookie/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/multispawner/holidaycookie
	name = "Seasonal Cookies"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/cookie/holiday

/obj/item/weapon/reagent_containers/food/snacks/multispawner/holidaycookie/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(SUGAR, 6)

/obj/item/weapon/reagent_containers/food/snacks/cookie/holiday
	name = "seasonal cookie"
	desc = "Charming holiday sugar cookies, just like Mom used to make."
	icon = 'icons/obj/food_seasonal.dmi'
	base_crumb_chance = 5
	food_flags = FOOD_SWEET | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/cookie/holiday/New()
	..()

	var/NM = time2text(world.realtime,"Month")
	var/cookiecutter

	switch(NM)
		if("February")
			cookiecutter = pick( list("heart","jamheart","frostingheartpink","frostingheartwhite","frostingheartred") )
		if("December")
			cookiecutter = pick( list("stocking","tree","snowman","mitt","angel","deer") )
		if("October")
			cookiecutter = pick( list("spider","cat","pumpkin","bat","ghost","hat","frank") )
		else
			cookiecutter = pick( list("spider","cat","pumpkin","bat","ghost","hat","frank","stocking","tree","snowman","mitt","angel","deer","heart","jamheart","frostingheartpink","frostingheartwhite","frostingheartred") )
	icon_state = "[cookiecutter]"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/candyheart
	name = "Candy Hearts"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/candyheart

/obj/item/weapon/reagent_containers/food/snacks/multispawner/candyheart/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(SUGAR, 15)

/obj/item/weapon/reagent_containers/food/snacks/candyheart
	name = "candy heart"
	icon = 'icons/obj/food.dmi'

/obj/item/weapon/reagent_containers/food/snacks/candyheart/New()
	..()

	var/heartphrase = pick( list("SO FINE","B TRU","U ROCK","HELLO","SOUL MATE","ME + U","2 CUTE","SWEET LUV","IM URS","XOXO","B MINE","LUV BUG","I &lt;3 U","PDA ME","U LEAVE ME BREATHLESS") )

	var/heartcolor = pick( list("p","b","w","y","g") )

	icon_state = "conversationheart_[heartcolor]"
	desc = "Chalky sugar in the form of a heart.<br/>This one says, <span class='valentines'>\"[heartphrase]\"</span>."

/obj/item/weapon/reagent_containers/food/snacks/chocostrawberry
	name = "chocolate strawberry"
	desc = "A fresh strawberry dipped in melted chocolate."
	icon_state = "chocostrawberry"
	food_flags = FOOD_SWEET
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/chocostrawberry/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(SUGAR, 5)
	reagents.add_reagent(COCO, 5)

/obj/item/weapon/reagent_containers/food/snacks/gingerbread_man
	name = "gingerbread man"
	desc = "A holiday treat made with sugar and love."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "gingerbread"
	food_flags = FOOD_DIPPABLE
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/gingerbread_man/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(SUGAR, 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolatebarunwrapped"
	wrapped = 0
	bitesize = 2
	food_flags = FOOD_SWEET
	base_crumb_chance = 5

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(SUGAR, 5)
	reagents.add_reagent(COCO, 5)

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/proc/Unwrap(mob/user)
		icon_state = "chocolatebarunwrapped"
		desc = "It won't make you all sticky."
		to_chat(user, "<span class='notice'>You remove the foil.</span>")
		wrapped = 0


/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped
	desc = "It's wrapped in some foil."
	icon_state = "chocolatebar"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine
	name = "Valentine's Day chocolate bar"
	desc = "Made (or bought) with love!"
	icon_state = "valentinebar"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine/New()
	..()
	if(Holiday != VALENTINES_DAY)
		new /obj/item/weapon/reagent_containers/food/snacks/badrecipe(get_turf(src))
		qdel(src)
		return FALSE
	return TRUE

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine/syndicate
	desc = "Bought (or made) with love!"

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine/syndicate/New()
	if(..())
		reagents.add_reagent(BICARODYNE, 3)

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolateegg"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //eggs are used
	base_crumb_chance = 3

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(SUGAR, 2)
	reagents.add_reagent(COCO, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_DIPPABLE //eggs are used
	var/soggy = 0
	var/frostchance = 30
	base_crumb_chance = 30

//Called in drinks.dm attackby
/obj/item/weapon/reagent_containers/food/snacks/donut/proc/dip(var/obj/item/weapon/reagent_containers/R, mob/user)
	var/probability = 15*soggy
	to_chat(user, "<span class='notice'>You dip \the [src] into \the [R]</span>")
	if(prob(probability))
		to_chat(user, "<span class='danger'>\The [src] breaks off into \the [R]!</span>")
		src.reagents.trans_to(R,reagents.maximum_volume)
		qdel(src)
		return
	R.reagents.trans_to(src, rand(3,12))
	if(!soggy)
		name = "soggy [name]"
	soggy += 1

/obj/item/weapon/reagent_containers/food/snacks/donut/normal
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
/obj/item/weapon/reagent_containers/food/snacks/donut/normal/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(SPRINKLES, 1)
	src.bitesize = 3
	if(prob(frostchance))
		src.icon_state = "donut2"
		src.name = "frosted donut"
		reagents.add_reagent(SPRINKLES, 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/normal/frosted
	frostchance = 100

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
/obj/item/weapon/reagent_containers/food/snacks/donut/chaos/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(SPRINKLES, 1)
	bitesize = 10
	switch(rand(1,10))
		if(1)
			reagents.add_reagent(NUTRIMENT, 3)
		if(2)
			reagents.add_reagent(CAPSAICIN, 3)
		if(3)
			reagents.add_reagent(FROSTOIL, 3)
		if(4)
			reagents.add_reagent(SPRINKLES, 3)
		if(5)
			reagents.add_reagent(PLASMA, 3)
		if(6)
			reagents.add_reagent(COCO, 3)
		if(7)
			reagents.add_reagent(SLIMEJELLY, 3)
		if(8)
			reagents.add_reagent(BANANA, 3)
		if(9)
			reagents.add_reagent(BERRYJUICE, 3)
		if(10)
			reagents.add_reagent(TRICORDRAZINE, 3)
	if(prob(frostchance))
		icon_state = "donut2"
		name = "frosted chaos donut"
		reagents.add_reagent(SPRINKLES, 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos/frosted
	frostchance = 100

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(SPRINKLES, 1)
	reagents.add_reagent(BERRYJUICE, 5)
	if(prob(frostchance))
		icon_state = "jdonut2"
		name = "Frosted Jelly Donut"
		reagents.add_reagent(SPRINKLES, 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/frosted
	frostchance = 100

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5
/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(SPRINKLES, 1)
	reagents.add_reagent(SLIMEJELLY, 5)
	bitesize = 5
	if(prob(frostchance))
		icon_state = "jdonut2"
		name = "Frosted Jelly Donut"
		reagents.add_reagent(SPRINKLES, 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly/frosted
	frostchance = 100

/obj/item/weapon/reagent_containers/food/snacks/donutiron //not a subtype of donuts to avoid inheritance
	name = "ironman donut"
	icon_state = "irondonut"
	desc = "An ironman donut will keep you cool when things heat up."
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/donutiron/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(LEPORAZINE, 6)
	reagents.add_reagent(IRON, 6)

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5
/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(SPRINKLES, 1)
	reagents.add_reagent(CHERRYJELLY, 5)
	if(prob(frostchance))
		icon_state = "jdonut2"
		name = "Frosted Jelly Donut"
		reagents.add_reagent(SPRINKLES, 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly/frosted
	frostchance = 100

/obj/item/weapon/reagent_containers/food/snacks/bagel
	name = "bagel"
	desc = "You can almost imagine the center is a black hole."
	icon_state = "bagel"
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/bagel/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

// Eggs

/obj/item/weapon/reagent_containers/food/snacks/friedegg
	name = "fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/friedegg/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(SODIUMCHLORIDE, 1)
	reagents.add_reagent(BLACKPEPPER, 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/boiledegg/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/organ
	name		=	"organ"
	desc		=	"It's good for you."
	icon		=	'icons/obj/surgery.dmi'
	icon_state	=	"appendix"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/organ/New()
	..()
	reagents.add_reagent(NUTRIMENT, rand(3,5))
	reagents.add_reagent(TOXIN,	rand(1,3))
	src.bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
/obj/item/weapon/reagent_containers/food/snacks/tofu/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	src.bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
/obj/item/weapon/reagent_containers/food/snacks/tofurkey/New()
	..()
	reagents.add_reagent(NUTRIMENT, 12)
	reagents.add_reagent(STOXIN, 3)
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
/obj/item/weapon/reagent_containers/food/snacks/stuffing/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/fishfingers/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(CARPPHEROMONES, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	base_crumb_chance = 0
	food_flags = FOOD_SKELETON_FRIENDLY

/obj/item/weapon/reagent_containers/food/snacks/meat/hugemushroomslice/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(PSILOCYBIN, 3)
	src.bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/hugemushroomslice/mushroom_man/New()
	..()
	reagents.add_reagent(TRICORDRAZINE, rand(1,5))

/obj/item/weapon/reagent_containers/food/snacks/meat/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	base_crumb_chance = 0
	food_flags = 0

/obj/item/weapon/reagent_containers/food/snacks/meat/tomatomeat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(KILLERPHEROMONES, 3)
	src.bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg/New()
	..()
	poisonsacs = new /obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(TOXIN, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round. Not a cord of wood."
	icon_state = "faggot"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/faggot/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/faggot/processed/New()
	..()
	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sausage/New()
	..()
	eatverb = pick("bite","chew","nibble","deep throat","gobble","chomp")
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sausage/dan
	name = "premium sausage"
	desc = "A piece of premium, mixed meat. Very mixed..."
	icon_state = "sausage"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sausage/dan/New()
	..()
	reagents.clear_reagents()
	for(var/blendedmeat = 1 to 6)
		switch(rand(1,3))
			if(1)
				reagents.add_reagent(NUTRIMENT, 1) //15 nutrition
			if(2)
				reagents.add_reagent(BEFF,rand(3,8)) //6-16
			if(3)
				reagents.add_reagent(HORSEMEAT,rand(3,6)) //9-18
	reagents.add_reagent(BONEMARROW,rand(0,3)) //0-3
	if(prob(50))
		reagents.add_reagent(ROACHSHELL,rand(0,8)) //0
	//36 to 111 nutrition. 4noraisins has 90...
	bitesize = 7 //Three bites on average to finish

/obj/item/weapon/reagent_containers/food/snacks/sausage/dan/on_vending_machine_spawn()
	reagents.chem_temp = FRIDGETEMP_FROZEN

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	food_flags = FOOD_MEAT | FOOD_DIPPABLE

	var/warm = 0

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/process()
	if(warm <= 0)
		warm = 0
		name = initial(name)
		reagents.del_reagent(TRICORDRAZINE)
		processing_objects.Remove(src)
		return

	warm--

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/Destroy()
	processing_objects.Remove(src)

	..()

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/proc/warm_up()
	warm = 80
	reagents.add_reagent(TRICORDRAZINE, 5)
	bitesize = 6
	name = "warm [name]"
	processing_objects.Add(src)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating
	name = "self-heating Donk-pocket"
	icon_state = "donkpocket_wrapped"
	desc = "Individually wrapped, frozen, unfrozen, desiccated, resiccated, twice recalled, and still edible. Infamously so."
	wrapped = TRUE
	var/unwrapping = FALSE

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating/proc/Unwrap(mob/user)
	if(unwrapping)
		return
	playsound(src, 'sound/misc/donkselfheat.ogg', 35, 0, -4)
	to_chat(user, "<span class='notice'>Following the instructions, you shake the packaging firmly and rip it open with an unsatisfying wet crunch.</span>")
	unwrapping = TRUE
	spawn(2 SECONDS)
		name = "\improper Donk-pocket"
		desc = "Freshly warmed and probably not toxic."
		icon_state = "donkpocket"
		reagents.add_reagent(CALCIUMOXIDE, 0.2)
		warm_up()
		wrapped = 0
		unwrapping = FALSE

/obj/item/weapon/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/brainburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(ALKYSINE, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/ghostburger
	name = "ghost burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/ghostburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/human
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/human/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger/on_vending_machine_spawn()//Fast-Food Menu
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger/synth
	name = "synthetic burger"
	desc = "It tastes like a normal burger, but it's just not the same."
	icon_state = "hburger"
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/appendixburger
	name = "appendix burger"
	desc = "Tastes like appendicitis."
	icon_state = "hburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/appendixburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fishburger
	name = "fillet -o- carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/fishburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(CARPPHEROMONES, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/tofuburger
	name = "tofu burger"
	desc = "What... is that meat?"
	icon_state = "tofuburger"
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/tofuburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chickenburger
	name = "chicken burger"
	desc = "Tastes like chi... oh wait!"
	icon_state = "mc_chicken"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/chickenburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/veggieburger
	name = "veggie burger"
	desc = "Technically vegetarian."
	icon_state = "veggieburger"
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/veggieburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/veggieburgernymph // Alternate recipe using nymph meat
	name = "veggie burger"
	desc = "Technically vegetarian."
	icon_state = "veggieburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/veggieburgernymph/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"

/obj/item/weapon/reagent_containers/food/snacks/roburger/New()
	..()
	reagents.add_reagent(NANITES, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	volume = 100

/obj/item/weapon/reagent_containers/food/snacks/roburgerbig/New()
	..()
	reagents.add_reagent(NANITES, 100)
	bitesize = 0.1

/obj/item/weapon/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/xenoburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/clownburger
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/clownburger/New()
	..()
/*
		var/datum/disease/F = new /datum/disease/pierrot_throat(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent(BLOOD, 4, data)
*/

	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(HONKSERUM, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mimeburger
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/mimeburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(SILENCER, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/donutburger
	name = "donut burger"
	desc = "Illegal to have out on code green."
	icon_state = "donutburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/donutburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(SPRINKLES, 6)
	bitesize = 2
	base_crumb_chance = 30

/obj/item/weapon/reagent_containers/food/snacks/avocadoburger
	name = "avocado burger"
	desc = "Blurring the line between ingredient and condiment."
	icon_state = "avocadoburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20
	harmfultocorgis = TRUE

/obj/item/weapon/reagent_containers/food/snacks/avocadoburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/caramelburger
	name = "caramel burger"
	desc = "Too sweet to be any good."
	icon_state = "caramelburger"
	food_flags = FOOD_MEAT | FOOD_SWEET
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/caramelburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(CARAMEL, 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bearburger
	name = "bear burger"
	desc = "Fits perfectly in any pic-a-nic basket. Oh bothering to grizzle into this won't be a boo-boo. Honey, it would be beary foolish to hibernate on such a unbearably, ursa majorly good treat!"
	icon_state = "bearburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/bearburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	reagents.add_reagent(HYPERZINE, 8)
	src.bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/glassburger
	name = "glass burger"
	desc = "Goes down surprisingly easily considering the ingredients."
	icon_state = "glassburger"
	filling_color = "#92CEE9"
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/glassburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(DIAMONDDUST, 4) //It's the closest we have to eating raw glass, causes some brute and screaming
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/polypburger
	name = "polyp burger"
	desc = "Millions of burgers like these are cooked and sold by McZargalds every year."
	icon_state = "polypburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/polypburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/blobburger
	name = "bloburger"
	desc = "Careful, has a tendency to spill sauce in every direction when squeezed too hard."
	icon_state = "blobburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/blobburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(BLOBANINE, 5)

/obj/item/weapon/reagent_containers/food/snacks/blobburger/consume(mob/living/carbon/eater, messages = 0, sounds = TRUE, bitesizemod = 1)
	if(prob(50))
		src.crumb_icon = "dribbles"
	else
		src.crumb_icon = "crumbs"
	..()

/obj/item/weapon/reagent_containers/food/snacks/blobkabob
	name = "keblob"
	desc = "Blob meat, on a stick."
	icon_state = "blobkabob"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/blobkabob/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(BLOBANINE, 5)

/obj/item/weapon/reagent_containers/food/snacks/blobpudding
	name = "blob à l'impératrice"
	desc = "An extremely thick \"pudding\" that requires a tough jaw."
	icon_state = "blobpudding"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_MEAT
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK | UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/blobpudding/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(BLOBANINE, 5)

/obj/item/weapon/reagent_containers/food/snacks/blobegg
	name = "oeufs en blob"
	desc = "Baked egg in a delicious, sticky broth. Bón appetit!"
	icon_state = "blobegg"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_ANIMAL | FOOD_MEAT
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK | UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/blobegg/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	reagents.add_reagent(BLOBANINE, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/blobsoup
	name = "blobisque"
	desc = "A thick, creamy soup containing a spongy surprise with a tough bite."
	icon_state = "blobsoup"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_ANIMAL | FOOD_MEAT
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK | UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/blobsoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 15)
	reagents.add_reagent(BLOBANINE, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/omelette	//FUCK THIS
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	food_flags = FOOD_ANIMAL //made from eggs
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/omelette/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/muffin/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/muffin/berry
	name = "berry muffin"
	icon_state = "berrymuffin"
	desc = "A delicious and spongy little cake, with berries."

/obj/item/weapon/reagent_containers/food/snacks/muffin/booberry
	name = "booberry muffin"
	icon_state = "booberrymuffin"
	desc = "My stomach is a graveyard! No living being can quench my bloodthirst!"

/obj/item/weapon/reagent_containers/food/snacks/muffin/dindumuffin
	name = "Dindu Muffin"
	desc = "This muffin didn't do anything."
	icon_state = "dindumuffins"

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/pie/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(BANANA,5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom)
	set waitfor = FALSE
	if(..())
		return
	if(ismob(hit_atom))
		var/mob/M = hit_atom
		src.visible_message("<span class='warning'>\The [src] splats in [M]'s face!</span>")

		var/race_prefix = ""
		if (isvox(M))
			race_prefix = "vox"
		else if (isgrey(M))
			race_prefix = "grey"
		else if (isinsectoid(M))
			race_prefix = "insect"

		M.eye_blind = 2
		M.overlays += image('icons/mob/messiness.dmi',icon_state = "[race_prefix]pied")
		sleep(55)
		M.overlays -= image('icons/mob/messiness.dmi',icon_state = "[race_prefix]pied")
		M.overlays += image('icons/mob/messiness.dmi',icon_state = "[race_prefix]pied-2")
		sleep(120)
		M.overlays -= image('icons/mob/messiness.dmi',icon_state = "[race_prefix]pied-2")

		if(luckiness)
			M.luck_adjust(luckiness, temporary = TRUE)

	if(isturf(hit_atom))
		new/obj/effect/decal/cleanable/pie_smudge(src.loc)
		if(trash)
			new trash(src.loc)
		playsound(src, pick('sound/effects/splat_pie1.ogg','sound/effects/splat_pie2.ogg'), 100, 1)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/pie/empty //so the H.O.N.K. cream pie mortar can't generate free nutriment
	trash = null
/obj/item/weapon/reagent_containers/food/snacks/pie/empty/New()
	..()
	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/pie/empty/no_throwforce
	throwforce = 0

/obj/item/weapon/reagent_containers/food/snacks/pie/clovercreampie
	name = "whipped clover pie"
	desc = "Traditional dish in the Clownplanet's Irish exclusion zone."
	icon_state = "clovercreampie"
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/pie/clovercreampie/New()
	..()
	bitesize = 3
	if(prob(25))
		reagents.add_reagent(NUTRIMENT, 8) //Lucky pie is more nutritious
		desc = "The pie was blessed by Saint Honktrick!"
	else
		reagents.add_reagent(NUTRIMENT, 5)

/obj/item/weapon/reagent_containers/food/snacks/pie/caramelpie
	name = "caramel pie"
	desc = "A sweet pie made with caramel."
	icon_state = "pie"
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/pie/caramelpie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(CARAMEL, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/explosive_pie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/explosive_pie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(BANANA,3)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/explosive_pie/examine(mob/user)
	..()
	if(is_holder_of(user,src))
		to_chat(user, "<span class='info'><b>When inspected hands-on,</b> the [src] feels heavier than normal and seems to be ticking.</span>")

/obj/item/weapon/reagent_containers/food/snacks/explosive_pie/after_consume(mob/user)
	explosion(get_turf(user), -1, 0, 0, 3)
	user.gib()
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/explosive_pie/throw_impact(atom/hit_atom)
	set waitfor = FALSE
	if(ismob(hit_atom))
		var/mob/M = hit_atom
		src.visible_message("<span class='warning'>\The [src] explodes in [M]'s face!</span>")
		explosion(get_turf(M), -1, 0, 1, 3)
		qdel(src)

	if(isturf(hit_atom))
		explosion(get_turf(hit_atom), -1, 0, 1, 3)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(BERRYJUICE, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles!"
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE
/obj/item/weapon/reagent_containers/food/snacks/waffles/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/discount
	name = "Discount Pie"
	icon_state = "meatpie"
	desc = "Regulatory laws prevent us from lying to you in the technical sense, so you know this has to contain at least some meat!"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/pie/discount/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT,2)
	reagents.add_reagent(DISCOUNT,2)
	reagents.add_reagent(TOXIN,2)
	reagents.add_reagent(CORNSYRUP,4)

/obj/item/weapon/reagent_containers/food/snacks/pie/meatpie
	name = "Meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/pie/meatpie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/tofupie
	name = "Tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."

/obj/item/weapon/reagent_containers/food/snacks/pie/tofupie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"

/obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(AMATOXIN, 3)
	reagents.add_reagent(PSILOCYBIN, 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	var/exceptionalprob = 10

/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie/New()
	..()
	reagents.clear_reagents()
	if(prob(exceptionalprob))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		reagents.add_reagent(NUTRIMENT, 8)
		reagents.add_reagent(TRICORDRAZINE, 5)
		bitesize = 2
	else
		reagents.add_reagent(NUTRIMENT, 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie/perfect
	exceptionalprob = 100

/obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie
	name = "Xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/human/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/human/kabob/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob/synth
	name = "Synth-kabob"
	icon_state = "kabob"
	desc = "Synthetic meat, on a stick."
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/corgikabob
	name = "Corgi-kabob"
	icon_state = "kabob"
	desc = "Only someone without a heart could make this."
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/corgikabob/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/tofukabob/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/cubancarp/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(CARPPHEROMONES, 3)
	reagents.add_reagent(CAPSAICIN, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/popcorn
	name = "popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	var/unpopped_min = 1
	var/unpopped_max = 10
	filling_color = "#EFE5D4"
	valid_utensils = 0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/New()
		..()
		eatverb = pick("bite","crunch","nibble","gnaw","gobble","chomp")
		unpopped = rand(unpopped_min,unpopped_max)
		reagents.add_reagent(NUTRIMENT, 2)
		bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/after_consume()
	if(prob(unpopped))	//lol ...what's the point? << AINT SO POINTLESS NO MORE
		to_chat(usr, "<span class='warning'>You bite down on an un-popped kernel, and it hurts your teeth!</span>")
		unpopped = max(0, unpopped-1)
		reagents.add_reagent(SACID, 0.1) //only a little tingle.

/obj/item/weapon/reagent_containers/food/snacks/popcorn/allpopped
	desc = "Now let's find some pure kino. These ones seem evenly cooked to perfection."
	unpopped_min = 0
	unpopped_max = 0

/obj/item/weapon/reagent_containers/food/snacks/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
	food_flags = FOOD_MEAT
	filling_color = "#733000"
	valid_utensils = 0
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sosjerky/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/no_raisin
	name = "4no raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. They've been FORtified with a number (no.) of nutrients, hence the name."
	trash = /obj/item/trash/raisins
	base_crumb_chance = 30
	valid_utensils = 0
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/no_raisin/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)

/obj/item/weapon/reagent_containers/food/snacks/cheap_raisins
	name = "economy-class raisins"
	icon_state = "cheap_raisins"
	desc = "Entire galactic economies have been brought to their knees over raisins just like these. The raisins must flow. He who controls the raisins, controls the universe."
	//You don't even get trash back!
	base_crumb_chance = 30
	valid_utensils = 0
	base_crumb_chance = 3

/obj/item/weapon/reagent_containers/food/snacks/cheap_raisins/New()
	..()
	reagents.add_reagent(GRAPEJUICE, 2) //Overall, these are 9x less nutritious than 4no raisins
	reagents.add_reagent(WATER, 2)
	reagents.add_reagent(DISCOUNT, 2)

/obj/item/weapon/reagent_containers/food/snacks/bustanuts
	name = "Busta-Nuts"
	icon_state = "busta_nut"
	desc = "2hard4u"
	trash = /obj/item/trash/bustanuts
	base_crumb_chance = 30
	valid_utensils = 0
	base_crumb_chance = 5

/obj/item/weapon/reagent_containers/food/snacks/bustanuts/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(BUSTANUT, 6)
	reagents.add_reagent(SODIUMCHLORIDE, 6)

/obj/item/weapon/reagent_containers/food/snacks/oldempirebar
	name = "Old Empire Bar"
	icon_state = "old_empire_bar"
	desc = "You can see a villager from a long lost old empire on the wrap."
	trash = /obj/item/trash/oldempirebar
	base_crumb_chance = 30
	valid_utensils = 0

/obj/item/weapon/reagent_containers/food/snacks/oldempirebar/New()
	..()
	reagents.add_reagent(NUTRIMENT, rand(2,6))
	reagents.add_reagent(ROGAN, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "space twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer than you will."
	valid_utensils = 0
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie/New()
	..()
	reagents.add_reagent(SUGAR, 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/chips/cheesie
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	filling_color = "#FFCC33"
	base_crumb_chance = 30
	valid_utensils = 0

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	trash = /obj/item/trash/syndi_cakes
	base_crumb_chance = 30
	valid_utensils = 0

/obj/item/weapon/reagent_containers/food/snacks/syndicake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(DOCTORSDELIGHT, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/discountchocolate
	name = "\improper Discount Dan's Chocolate Bar"
	desc = "Something tells you that the glowing green filling inside isn't healthy."
	icon_state = "danbar"
	trash = /obj/item/trash/discountchocolate
	food_flags = FOOD_SWEET
	filling_color = "#7D390D"
	base_crumb_chance = 20
	valid_utensils = 0

/obj/item/weapon/reagent_containers/food/snacks/discountchocolate/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(DISCOUNT, 4)
	reagents.add_reagent(MOONROCKS, 4)
	reagents.add_reagent(TOXICWASTE, 8)
	reagents.add_reagent(URANIUM, 8)
	reagents.add_reagent(CORNSYRUP, 2)
	reagents.add_reagent(CHEMICAL_WASTE, 2) //Does nothing, but it's pretty fucking funny.
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/discountburger
	name = "\improper Discount Dan's On The Go Burger"
	desc = "It's still warm..."
	icon_state = "goburger" //Someone make a better sprite for this.
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/discountburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(DISCOUNT, 4)
	reagents.add_reagent(BEFF, 4)
	reagents.add_reagent(HORSEMEAT, 4)
	reagents.add_reagent(OFFCOLORCHEESE, 4)
	reagents.add_reagent(CHEMICAL_WASTE, 2) //Does nothing, but it's pretty fucking funny.
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/donitos
	name = "Donitos"
	desc = "Ranch or cool ranch?"
	icon_state = "donitos"
	trash = /obj/item/trash/chips/donitos
	filling_color = "#C06800"
	base_crumb_chance = 30

/obj/item/weapon/reagent_containers/food/snacks/donitos/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)
	reagents.add_reagent(SPRINKLES, 10)

/obj/item/weapon/reagent_containers/food/snacks/donitos/coolranch
	name = "Donitos Cool Ranch"
	desc = "Cool ranch."
	icon_state = "donitos_coolranch"
	trash = /obj/item/trash/chips/donitos_coolranch

/obj/item/weapon/reagent_containers/food/snacks/donitos/coolranch/New()
	..()
	reagents.add_reagent(SPRINKLES, 5)

/obj/item/weapon/reagent_containers/food/snacks/danitos
	name = "Danitos"
	desc = "For only the most MLG hardcore robust spessmen."
	icon_state = "danitos"
	trash = /obj/item/trash/chips/danitos
	filling_color = "#FF9933"
	base_crumb_chance = 30

/obj/item/weapon/reagent_containers/food/snacks/danitos/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(DISCOUNT, 4)
	reagents.add_reagent(BONEMARROW, 4)
	reagents.add_reagent(TOXICWASTE, 8)
	reagents.add_reagent(BUSTANUT, 2) //YOU FEELIN HARDCORE BRAH?
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/dangles
	name = "Dangles"
	desc = "Once you pop, you'll wish you stopped."
	icon_state = "dangles"
	trash = /obj/item/trash/dangles
	filling_color = "#FF9933"
	base_crumb_chance = 30
	var/image/lid_overlay
	var/popped

/obj/item/weapon/reagent_containers/food/snacks/dangles/New()
	..()
	lid_overlay = image(icon, null, "dangles_lid")

/obj/item/weapon/reagent_containers/food/snacks/dangles/can_consume(mob/user)
	return popped

/obj/item/weapon/reagent_containers/food/snacks/dangles/attack_self(var/mob/user)
	if(!popped)
		return pop_open(user)
	..()

/obj/item/weapon/reagent_containers/food/snacks/dangles/proc/pop_open(var/mob/user)
	to_chat(user, "You pop the top off \the [src].")
	playsound(user, 'sound/effects/opening_snack_tube.ogg', 50, 1)
	popped = TRUE
	update_icon()

/obj/item/weapon/reagent_containers/food/snacks/dangles/update_icon()
	extra_food_overlay.overlays -= lid_overlay
	if (!popped)
		extra_food_overlay.overlays += lid_overlay
	..()

/obj/item/weapon/reagent_containers/food/snacks/dangles/New()
	..()
	update_icon()
	switch(pick(1,2,3,4))
		if(1)
			name = "Dangles: Arguably A Potato Flavor"
			icon_state += "_red"
			reagents.add_reagent(ENZYME, 5)
			reagents.add_reagent(KETCHUP, 5) //tomatos are actually closely related to potatos
			reagents.add_reagent(ICE, 5, reagtemp = T0C) //frozen potato juice
			reagents.add_reagent(POTATO, 5, reagtemp = T0C)

		if(2)
			name = "Dangles: Cheddar Craving Concussion Flavor"
			icon_state += "_blue"
			reagents.add_reagent(MANNITOL, 5)
			reagents.add_reagent(OFFCOLORCHEESE, 5)
			reagents.add_reagent(ICE, 10, reagtemp = T0C) //brainfreeze
		if(3)
			name = "Dangles: Iodine & Industrial Vinegar Flavor"
			icon_state += "_green"
			reagents.add_reagent(TOXICWASTE, 5)
			reagents.add_reagent(STERILIZINE, 5)
			reagents.add_reagent(ETHANOL, 5)
			reagents.add_reagent(SACID, 5) //acetic acid but we don't have that
		if(4)
			name = "Dangles: South of the Border Jalepeno Flavor"
			icon_state += "_purple"
			reagents.add_reagent(HORSEMEAT, 5)
			reagents.add_reagent(BEFF, 5)
			reagents.add_reagent(CAPSAICIN, 5)
			reagents.add_reagent(CONDENSEDCAPSAICIN, 5)
	reagents.add_reagent(DISCOUNT, 10)
	reagents.add_reagent(SODIUMCHLORIDE, 5)
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 4


/obj/item/weapon/reagent_containers/food/snacks/discountburrito
	name = "Discount Dan's Burritos"
	desc = "The perfect blend of cheap processing and cheap materials."
	icon_state = "danburrito"
	var/list/ddname = list("Spooky Dan's BOO-ritos - Texas Toast Chainsaw Massacre Flavor","Sconto Danilo's Burritos - 50% Real Mozzarella Pepperoni Pizza Party Flavor","Descuento Danito's Burritos - Pancake Sausage Brunch Flavor","Descuento Danito's Burritos - Homestyle Comfort Flavor","Spooky Dan's BOO-ritos - Nightmare on Elm Meat Flavor","Descuento Danito's Burritos - Strawberrito Churro Flavor","Descuento Danito's Burritos - Beff and Bean Flavor")
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/discountburrito/New()
	..()
	name = pick(ddname)
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(DISCOUNT, 6)
	reagents.add_reagent(IRRADIATEDBEANS, 4)
	reagents.add_reagent(REFRIEDBEANS, 4)
	reagents.add_reagent(MUTATEDBEANS, 4)
	reagents.add_reagent(BEFF, 4)
	reagents.add_reagent(CHEMICAL_WASTE, 2) //Does nothing, but it's pretty fucking funny.
	bitesize = 2



/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -5
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	plate_offset_y = -2
	filling_color = "#FFCF62"

/obj/item/weapon/reagent_containers/food/snacks/fries/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fries/processed/New()
	..()
	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/fries/cone
	name = "cone of Space Fries"
	icon_state = "fries_cone"
	trash = /obj/item/trash/fries_cone

/obj/item/weapon/reagent_containers/food/snacks/fries/cone/on_vending_machine_spawn()//Fast-Food Menu
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/soydope/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soydope/processed/New()
	..()
	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/butter
	name = "butter"
	desc = "Today we feast."
	icon_state = "butter"
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/butter/New()
	..()
	reagents.add_reagent(LIQUIDBUTTER, 10)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/butter/Crossed(atom/movable/O)
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.Slip(4, 3, slipped_on = src))
			new/obj/effect/decal/cleanable/smashed_butter(src.loc)
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/pancake
	name = "pancake"
	desc = "You'll never guess what's for breakfast!"
	icon_state = "pancake"
	food_flags = FOOD_ANIMAL
	var/pancakes = 1
	var/max_pancakes = 10 // leaving badmins a way to raise it if they're ready to assume the consequences
	base_crumb_chance = 1

/obj/item/weapon/reagent_containers/food/snacks/pancake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pancake/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/pancake))
		var/obj/item/weapon/reagent_containers/food/snacks/pancake/I = O
		if (pancakes + I.pancakes > max_pancakes)
			to_chat(user, "<span class='warning'>sorry, can't go any higher!</span>")
			return
		to_chat(user, "<span class='notice'>...and another one!</span>")
		var/amount = I.reagents.total_volume
		I.reagents.trans_to(src, amount)
		var/image/img = image(I.icon, src, I.icon_state)
		img.appearance = I.appearance
		img.pixel_x = 0
		img.pixel_y = 2 * pancakes
		img.plane = FLOAT_PLANE
		img.layer = FLOAT_LAYER
		extra_food_overlay.overlays += img
		overlays += img
		pancakes += I.pancakes
		qdel(I)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/spaghetti
	name = "Spaghetti"
	desc = "Now thats a nice pasta!"
	icon_state = "spaghetti"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/spaghetti/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	plate_offset_y = -3
	filling_color = "#FFEB3B"

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/punnet
	name = "punnet of Cheesy Fries"
	icon_state = "cheesyfries_punnet"
	trash = /obj/item/trash/fries_punet

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/punnet/on_vending_machine_spawn()//Fast-Food Menu XL
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"

/obj/item/weapon/reagent_containers/food/snacks/badrecipe/New()
	..()
	reagents.add_reagent(TOXIN, 1)
	reagents.add_reagent(CARBON, 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(SODIUMCHLORIDE, 1)
	reagents.add_reagent(BLACKPEPPER, 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/synth
	name = "Synthmeat steak"
	desc = "It's still a delicious steak, but it has no soul."
	icon_state = "meatsteak"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook"
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	random_filling_colors = list("#FFB2AE","#FFB2E4","#EDB2FB","#BBB2FB","#B2D3FB","#B2FFF8","#BDF6B7","#D9E37F","#FBD365")
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(PSILOCYBIN, 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(AMATOXIN, 6)
	reagents.add_reagent(PSILOCYBIN, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jectie
	name = "jectie"
	desc = "<font color='red'><B>The jectie has failed!</B></font color>"
	icon_state = "jectie_red"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/jectie/New()
	..()
	if(prob(40)) //approximate solo antag winrate
		icon_state = "jectie_green"
		desc = "<font color='green'><B>The jectie was successful!</B></font color>"
		reagents.add_reagent(GREENTEA, 18)
		reagents.add_reagent(NUTRIMENT, 6)
		bitesize = 4
	else
		reagents.add_reagent(REDTEA, 9)
		reagents.add_reagent(NUTRIMENT, 3)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/meatballsoup
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#F4BC77"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/meatballsoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(WATER, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#B2B2B2"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/slimesoup/New()
	..()
	reagents.add_reagent(SLIMEJELLY, 5)
	reagents.add_reagent(WATER, 10)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/bloodsoup
	name = "Tomato soup"
	desc = "Smells like iron."
	icon_state = "tomatosoup"
	food_flags = FOOD_LIQUID | FOOD_ANIMAL //blood
	crumb_icon = "dribbles"
	filling_color = "#FF3300"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/bloodsoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(BLOOD, 10)
	reagents.add_reagent(WATER, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	food_flags = FOOD_LIQUID | FOOD_SWEET
	crumb_icon = "dribbles"
	random_filling_colors = list("#FF0000","#FFFF00","#00CCFF","#33CC00")
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/clownstears/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(BANANA, 5)
	reagents.add_reagent(WATER, 10)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/roboticiststears
	name = "Roboticist's Tears"
	desc = "Absolutely hilarious."
	icon_state = "roboticiststears"
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	random_filling_colors = list("#5A01EF", "#4B2A7F", "#826BA7", "#573D80")
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/roboticiststears/New()
	..()
	reagents.add_reagent(NUTRIMENT, 60) //You're using phazon here, that's the good shit.
	reagents.add_reagent(PHAZON, 1)
	reagents.add_reagent(WATER, 5) //water turned into nutriment via phazon magic fuckery
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup
	name = "Vegetable soup"
	desc = "A true vegan meal." //TODO
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#FAA810"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(WATER, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/nettlesoup
	name = "Nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#C1E212"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/nettlesoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(WATER, 5)
	reagents.add_reagent(TRICORDRAZINE, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/mysterysoup
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID | FOOD_ANIMAL | FOOD_LACTOSE
	crumb_icon = "dribbles"
	filling_color = "#97479B"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/mysterysoup/New()
	..()
	var/mysteryselect = pick(1,2,3,4,5,6,7,8,9,10)
	switch(mysteryselect)
		if(1)
			reagents.add_reagent(NUTRIMENT, 6)
			reagents.add_reagent(CAPSAICIN, 3)
			reagents.add_reagent(TOMATOJUICE, 2)
		if(2)
			reagents.add_reagent(NUTRIMENT, 6)
			reagents.add_reagent(FROSTOIL, 3)
			reagents.add_reagent(TOMATOJUICE, 2)
		if(3)
			reagents.add_reagent(NUTRIMENT, 5)
			reagents.add_reagent(WATER, 5)
			reagents.add_reagent(TRICORDRAZINE, 5)
		if(4)
			reagents.add_reagent(NUTRIMENT, 5)
			reagents.add_reagent(WATER, 10)
		if(5)
			reagents.add_reagent(NUTRIMENT, 2)
			reagents.add_reagent(BANANA, 10)
		if(6)
			reagents.add_reagent(NUTRIMENT, 6)
			reagents.add_reagent(BLOOD, 10)
			food_flags |= FOOD_MEAT
		if(7)
			reagents.add_reagent(SLIMEJELLY, 10)
			reagents.add_reagent(WATER, 10)
		if(8)
			reagents.add_reagent(CARBON, 10)
			reagents.add_reagent(TOXIN, 10)
		if(9)
			reagents.add_reagent(NUTRIMENT, 5)
			reagents.add_reagent(TOMATOJUICE, 10)
		if(10)
			reagents.add_reagent(NUTRIMENT, 6)
			reagents.add_reagent(TOMATOJUICE, 5)
			reagents.add_reagent(IMIDAZOLINE, 5)
	bitesize = 5


/obj/item/weapon/reagent_containers/food/snacks/monkeysoup
	name = "Monkey Soup"
	desc = "Uma delicia."
	icon_state = "monkeysoup"
	trash = /obj/item/trash/monkey_bowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#D7DE77"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/monkeysoup/New()
	..()
	reagents.add_reagent(WATER, 5)
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(VINEGAR, 4)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/wishsoup
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#DEF7F5"
	valid_utensils = UTENSILE_SPOON
	var/wishprob = 25

/obj/item/weapon/reagent_containers/food/snacks/wishsoup/New()
	..()
	reagents.add_reagent(WATER, 10)
	bitesize = 5
	if(prob(wishprob))
		src.desc = "A wish come true!"
		reagents.add_reagent(NUTRIMENT, 8)

/obj/item/weapon/reagent_containers/food/snacks/wishsoup/perfect
	wishprob = 100

/obj/item/weapon/reagent_containers/food/snacks/avocadosoup
	name = "Avocado Soup"
	desc = "May be served either hot or cold."
	icon_state = "avocadosoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#CBD15B"
	valid_utensils = UTENSILE_SPOON
	harmfultocorgis = TRUE

/obj/item/weapon/reagent_containers/food/snacks/avocadosoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(LIMEJUICE, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/silicatesoup
	name = "silicate soup"
	desc = "It's like eating sand in liquid form."
	icon_state = "silicatesoup"
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#C5C5FF"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/silicatesoup/New()
	..()
	reagents.add_reagent(WATER, 10)
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(SILICATE, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/hotchili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	crumb_icon = "dribbles"
	filling_color = "#E23D12"
	food_flags = FOOD_LIQUID | FOOD_MEAT
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/hotchili/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(CAPSAICIN, 3)
	reagents.add_reagent(TOMATOJUICE, 2)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/coldchili
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	trash = /obj/item/trash/snack_bowl
	crumb_icon = "dribbles"
	filling_color = "#4375E8"
	food_flags = FOOD_LIQUID | FOOD_MEAT
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/coldchili/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(FROSTOIL, 3)
	reagents.add_reagent(TOMATOJUICE, 2)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/plasmastew
	name = "Plasma Stew"
	desc = "Plasma free and flavour full."
	icon_state = "plasmastew"
	trash = /obj/item/trash/snack_bowl
	crumb_icon = "dribbles"
	filling_color = "#CE37BA"
	food_flags = FOOD_LIQUID | FOOD_MEAT
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/plasmastew/New()
	..()
	reagents.add_reagent(NUTRIMENT, 12)
	reagents.add_reagent(TOMATOJUICE, 2)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "Tracking Bacon"
	desc = "Bacon used by a teleporter."
	icon_state = "telebacon"
	var/obj/item/beacon/bacon/baconbeacon
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/telebacon/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	baconbeacon = new /obj/item/beacon/bacon(src)

/obj/item/weapon/reagent_containers/food/snacks/telebacon/after_consume()
	if(!reagents.total_volume)
		baconbeacon.forceMove(usr)
	..()

/obj/item/weapon/reagent_containers/food/snacks/spellburger
	name = "Spell Burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"

/obj/item/weapon/reagent_containers/food/snacks/spellburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 14)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger/on_vending_machine_spawn()//Fast-Food Menu XL
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/enchiladas/New()
	..()
	reagents.add_reagent(NUTRIMENT,8)
	reagents.add_reagent(CAPSAICIN, 6)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	reagents.add_reagent(BANANA, 5)
	reagents.add_reagent(BLACKPEPPER, 1)
	reagents.add_reagent(SODIUMCHLORIDE, 1)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "Baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/baguette/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(BLACKPEPPER, 1)
	reagents.add_reagent(SODIUMCHLORIDE, 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself, chap."
	icon_state = "fishandchips"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/fishandchips/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(CARPPHEROMONES, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/crab_sticks
	name = "\improper Not-Actually-Imitation Crab sticks"
	desc = "Made from actual crab meat."
	icon_state = "crab_sticks"
	food_flags = FOOD_MEAT
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/crab_sticks/New()
		..()
		reagents.add_reagent(NUTRIMENT, 4)
		reagents.add_reagent(SUGAR, 1)
		reagents.add_reagent(SODIUMCHLORIDE, 1)
		base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/crabcake
	name = "Crab Cake"
	desc = "A New Space England favorite!"
	icon_state = "crabcake"
	food_flags = FOOD_MEAT
	bitesize = 2
	base_crumb_chance = 3

/obj/item/weapon/reagent_containers/food/snacks/crabcake/New()
		..()
		reagents.add_reagent(NUTRIMENT, 4)

/obj/item/weapon/reagent_containers/food/snacks/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	food_flags = FOOD_MEAT | FOOD_LACTOSE | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sandwich/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	food_flags = FOOD_MEAT | FOOD_LACTOSE | FOOD_ANIMAL //This is made from a sandwich, which contains meat!

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(CARBON, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese
	name = "Grilled Cheese Sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	food_flags = FOOD_MEAT | FOOD_LACTOSE | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese/New()
	..()
	reagents.add_reagent(NUTRIMENT, 7)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/polypwich
	name = "Polypwich"
	desc = "Polyp meat and gelatin between two slices of bread makes for a nutritious sandwich. Unfortunately it has a soggy and unpleasant texture. These are commonly served to mothership prisoners who misbehave."
	icon_state = "polypwich"
	food_flags = FOOD_MEAT | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/polypwich/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/polypwich/after_consume(mob/user)
	if(prob(10))	//Eating this is just an unpleasant experience, so a player might get a negative flavor message. Has no effect besides rp value. I hope ayy wardens feed these to prisoners as a punishment :)
		to_chat(user, "<span class='warning'>The sandwich is soggy and tastes too salty to be appetizing...</span>")

/obj/item/weapon/reagent_containers/food/snacks/tomatosoup
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/tomatosoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(TOMATO_SOUP, 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE //eggs, can be dipped

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(PSILOCYBIN, 8)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	food_flags = FOOD_LIQUID | FOOD_MEAT
	filling_color = "#EB7C28"
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/stew/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale",DRINK)
	reagents.add_reagent(NUTRIMENT, 10)
	reagents.add_reagent(TOMATOJUICE, 5)
	reagents.add_reagent(IMIDAZOLINE, 5)
	reagents.add_reagent(WATER, 5)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast
	name = "Jellied Toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	food_flags = FOOD_SWEET | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry/New()
	..()
	reagents.add_reagent(CHERRYJELLY, 5)

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime/New()
	..()
	reagents.add_reagent(SLIMEJELLY, 5)

/obj/item/weapon/reagent_containers/food/snacks/avocadotoast
	name = "avocado toast"
	desc = "Salted avocado on a slice of toast. For the authentic experience, make sure you pay an exorbitant price for it."
	icon_state = "avocadotoast"
	food_flags = FOOD_DIPPABLE
	harmfultocorgis = TRUE

/obj/item/weapon/reagent_containers/food/snacks/avocadotoast/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellyburger
	name = "Jelly Burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime/New()
	..()
	reagents.add_reagent(SLIMEJELLY, 5)

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/gelatin
	name = "Gelatin Burger"
	desc = "It's a bit soggy."
	food_flags = FOOD_MEAT | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/gelatin/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry/New()
	..()
	reagents.add_reagent(CHERRYJELLY, 5)

/obj/item/weapon/reagent_containers/food/snacks/milosoup
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/milosoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(WATER, 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mommispaghetti
	name = "bowl of MoMMi spaghetti"
	desc = "You can feel the autism in this one."
	icon_state = "mommispaghetti"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/mommispaghetti/New()
	..()
	reagents.add_reagent(AUTISTNANITES, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spaghettiboiled"
	restraint_resist_time = 1 SECONDS
	toolsounds = list('sound/weapons/cablecuff.ogg')
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	name = "Boiled Rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/boiledrice/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/ricepudding
	name = "Rice Pudding"
	desc = "Where's the Jam!"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/ricepudding/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/riceball
	name = "Rice Ball"
	desc = "In mining culture, this is also known as a donut."
	icon_state = "riceball"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/riceball/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/eggplantsushi
	name = "Spicy Eggplant Sushi Rolls"
	desc = "Eggplant rolls are an example of Asian Fusion as eggplants were introduced from mainland Asia to Japan. This dish is Earth Fusion, originating after the introduction of the chili from the Americas to Japan. Fusion HA!"
	icon_state = "eggplantsushi"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/eggplantsushi/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(CAPSAICIN, 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "Spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/pastatomato/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(TOMATOJUICE, 10)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/copypasta/New()
	..()
	reagents.add_reagent(NUTRIMENT, 12)
	reagents.add_reagent(TOMATOJUICE, 20)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti
	name = "Spaghetti & Meatballs"
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspaghetti"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/crabspaghetti
	name = "Crab Spaghetti"
	desc = "Goes well with Coffee."
	icon_state = "crabspaghetti"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/crabspaghetti/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	desc = "A lawyer's favorite."
	icon_state = "spesslaw"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/spesslaw/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "A large, soft, all-twisted-up pretzel full of POP!"
	icon_state = "poppypretzel"
	food_flags = FOOD_DIPPABLE
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)

/obj/item/weapon/reagent_containers/food/snacks/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh carrots."
	icon_state = "carrotfries"
	plate_offset_y = -2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/carrotfries/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(IMIDAZOLINE, 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotfries/processed/New()
	..()
	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/diamondfries
	name = "Diamond Fries"
	desc = "Surprisingly juicy and crunchy."
	icon_state = "diamondfries"
	filling_color = "#95FFFF"
	plate_offset_y = -2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/diamondfries/processed/New()
	..()
	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/diamondfries/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/superbiteburger
	name = "Super Bite Burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	food_flags = FOOD_MEAT | FOOD_LACTOSE | FOOD_ANIMAL
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/superbiteburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 40)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/candiedapple/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/pie/applepie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/caramelapple
	name = "Caramel Apple"
	desc = "An apple coated in caramel goodness."
	icon_state = "caramelapple"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/caramelapple/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(CARAMEL, 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/mincepie
	name = "mincepie"
	desc = "Contains no children."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "mincepie"
	food_flags = FOOD_SWEET | FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/pie/mincepie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"

/obj/item/weapon/reagent_containers/food/snacks/twobread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich
	name = "Jelly Sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime/New()
	..()
	reagents.add_reagent(SLIMEJELLY, 5)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry/New()
	..()
	reagents.add_reagent(CHERRYJELLY, 5)

/*
/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore/New()
	..()
	reagents.add_reagent(SLIMEJELLY, 5)
	bitesize = 3
*/
/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "It is only wafer thin."
	icon_state = "mint"
	base_crumb_chance = 0
	var/safeforfat = FALSE
/obj/item/weapon/reagent_containers/food/snacks/mint/New()
	..()
	if(!safeforfat)
		reagents.add_reagent(MINTTOXIN, 1)
		bitesize = 1
	else
		reagents.add_reagent(MINTESSENCE, 2)
		bitesize = 2

//the syndie version for muh tators
/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint
	name = "mint candy"

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/nano
	desc = "It's not just a mint!"
	icon_state = "nanomint"

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/syndie
	desc = "Made with care, love, and the blood of Nanotrasen executives kept in eternal torment."
	icon_state = "syndiemint"

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/discount
	desc = "Yeah, I wouldn't eat these if I were yo- Wait, you're still recording?"
	icon_state = "discountmint"

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/homemade
	desc = "Made with love with the finest maintenance gunk I could find, trust me. I promise there's only trace amounts of bleach."
	icon_state = "homemademint"

//The candy version for the vendors
/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/nano/safe
	safeforfat = TRUE

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/syndie/safe
	safeforfat = TRUE

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/discount/safe
	safeforfat = TRUE

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/homemade/safe
	safeforfat = TRUE

/obj/item/weapon/reagent_containers/food/snacks/mushroomsoup
	name = "chanterelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/mushroomsoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	food_flags = FOOD_DIPPABLE
	var/exceptionalprob = 10

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/New()
	..()
	if(prob(exceptionalprob))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		reagents.add_reagent(NUTRIMENT, 8)
		reagents.add_reagent(TRICORDRAZINE, 5)
		bitesize = 2
	else
		reagents.add_reagent(NUTRIMENT, 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/perfect
	exceptionalprob = 100

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#E00000"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/beetsoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale",DRINK)
	name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#306900"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/herbsalad/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT
	filling_color = "#306900"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/validsalad/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(DOCTORSDELIGHT, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/appletart/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(GOLD, 5)
	bitesize = 3

/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

// sliceable is just an organization type path, it doesn't have any additional code or variables tied to it.

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	slices_num = 5
	storage_slots = 3
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -4

/obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	slices_num = 5
	storage_slots = 3
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -4

/obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 30) //If the meat is toxic, it will inherit that
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/synth
	name = "synthmeatbread loaf"
	desc = "A loaf of synthetic meatbread. You can just taste the mass-production."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice/synth
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/synth/New()
	..()
	reagents.add_reagent(NUTRIMENT, 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice/synth
	name = "synthmeatbread slice"
	desc = "A slice of synthetic meatbread."
	icon_state = "meatbreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread/New()
	..()
	reagents.add_reagent(BANANA, 20)
	reagents.add_reagent(NUTRIMENT, 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread
	name = "tofubread"
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	slices_num = 5
	storage_slots = 3
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	bitesize = 2
	plate_offset_y = -5
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/carrotcake
	name = "carrot cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/carrotcake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 25)
	reagents.add_reagent(IMIDAZOLINE, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	name = "carrot cake slice"
	desc = "Carrotty slice of carrot cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 25)
	reagents.add_reagent(ALKYSINE, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	name = "brain cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE //meat, milk, eggs

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE //cheese

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 25)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	name = "cheese cake slice"
	desc = "A slice of pure cheestisfaction."
	icon_state = "cheesecake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake
	name = "vanilla cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE //milk and eggs

/obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)

/obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	name = "vanilla cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/plaincakeslice/full/New()
	..()

	reagents.add_reagent(NUTRIMENT, 4)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)

/obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)

/obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)

/obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	name = "lemon cake slice"
	desc = "Just a slice of cake, enough for everyone."
	icon_state = "lemoncake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake
	name = "chocolate cake"
	desc = "A cake with added chocolate."
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)

/obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	name = "chocolate cake slice"
	desc = "Just a slice of cake, enough for everyone."
	icon_state = "chocolatecake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/sliceable/caramelcake
	name = "caramel cake"
	desc = "A cake with added caramel."
	icon_state = "caramelcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/caramelcakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/caramelcake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 15)
	reagents.add_reagent(CARAMEL, 5)

/obj/item/weapon/reagent_containers/food/snacks/caramelcakeslice
	name = "caramel cake slice"
	desc = "Just a slice of cake, enough for everyone."
	icon_state = "caramelcake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "cheese wheel"
	desc = "A big wheel of delicious cheddar."
	icon_state = "cheesewheel"
	filling_color = "#FFCC33"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "cheese wedge"
	desc = "A wedge of delicious cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#FFCC33"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake
	name = "Birthday Cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	candles_state = CANDLES_UNLIT
	always_candles = "birthdaycake"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	reagents.add_reagent(SPRINKLES, 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	name = "Birthday Cake slice"
	desc = "A slice of your birthday!"
	icon_state = "birthdaycakeslice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_icon = "bluecustom"
	candles_state = CANDLES_UNLIT
	always_candles = "birthdaycakeslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread
	name = "bread"
	desc = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/nova
	name = "nova bread"
	desc = "Some plain old destabilizing star bread."
	icon_state = "novabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/nova

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/nova/New()
	..()
	reagents.add_reagent(HELL_RAMEN, 3)
	reagents.add_reagent(NOVAFLOUR, 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/breadslice
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	bitesize = 2
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/breadslice/nova
	name = "nova bread slice"
	desc = "A slice of Sol."
	icon_state = "novabreadslice"
	plate_icon = "novacustom"
	food_flags = FOOD_DIPPABLE


/obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_LACTOSE | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	bitesize = 2
	food_flags = FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -5

/obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	bitesize = 2
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake
	name = "apple cake"
	desc = "A cake centred with apple."
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 15)

/obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	name = "apple cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie //You can't throw this pie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie/New()
	..()
	reagents.add_reagent(NUTRIMENT, 15)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cloverpie
	name = "clover cream pie"
	desc = "A creamy, sweet dessert with herbal notes that recall open fields and verdant pastures."
	icon_state = "cloverpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cloverpieslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cloverpie/New()
	..()
	reagents.add_reagent(NUTRIMENT, 15)

/obj/item/weapon/reagent_containers/food/snacks/cloverpieslice
	name = "clover cream pie slice"
	desc = "Nothing says springtime like a slice of clover cream pie... maybe."
	icon_state = "cloverpieslice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/cracker/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)

/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
	slices_num = 6
	storage_slots = 4
	w_class = W_CLASS_MEDIUM
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/on_vending_machine_spawn()
	reagents.chem_temp = FRIDGETEMP_FREEZER

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita
	name = "Margherita"
	desc = "The most cheesy pizza in galaxy!"
	icon_state = "pizzamargherita"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	storage_slots = 4
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita/New()
	..()
	reagents.add_reagent(NUTRIMENT, 40)
	reagents.add_reagent(TOMATOJUICE, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	name = "Margherita slice"
	desc = "A slice of the most cheesy pizza in galaxy."
	icon_state = "pizzamargheritaslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/margheritaslice/rocket
	name = "Margherita slice"
	desc = "A slice of the most cheesy pizza in galaxy. Seems covered in gunpowder."
	icon_state = "pizzamargheritaslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/margheritaslice/rocket/New()
	..()
	reagents.add_reagent(NUTRIMENT, 7)
	reagents.add_reagent(TOMATOJUICE, 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	name = "Meatpizza"
	desc = "A filling pizza laden with meat, perfect for the manliest of carnivores."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE //It has cheese!

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/New()
	..()
	reagents.add_reagent(NUTRIMENT, 50)
	reagents.add_reagent(TOMATOJUICE, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	name = "Meatpizza slice"
	desc = "A slice of pizza, packed with delicious meat."
	icon_state = "meatpizzaslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/synth
	name = "Synthmeatpizza"
	desc = "A synthetic pizza laden with artificial meat, perfect for the stingiest of chefs."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice/synth
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/synth/New()
	..()
	reagents.add_reagent(NUTRIMENT, 50)
	reagents.add_reagent(TOMATOJUICE, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice/synth
	name = "Synthmeatpizza slice"
	desc = "A slice of pizza, packed with synthetic meat."
	icon_state = "meatpizzaslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	name = "Mushroompizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza/New()
	..()
	reagents.add_reagent(NUTRIMENT, 35)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	name = "Mushroompizza slice"
	desc = "Maybe it's the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	name = "Vegetable pizza"
	desc = "No one of Tomatos Sapiens was harmed during the making of this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/vegetablepizzaslice
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza/New()
	..()
	reagents.add_reagent(NUTRIMENT, 30)
	reagents.add_reagent(TOMATOJUICE, 6)
	reagents.add_reagent(IMIDAZOLINE, 12)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/vegetablepizzaslice
	name = "Vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/blingpizza
	name = "Blingpizza"
	desc = "A pizza made with the most expensive ingredients this side of the galaxy. You feel filthy rich just by looking at it."
	icon_state = "blingpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/blingpizzaslice
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/blingpizza/New()
	..()
	reagents.add_reagent(NUTRIMENT, 50)
	reagents.add_reagent(HELL_RAMEN, 3) //the novaflour turns into hellramen like in novabread
	reagents.add_reagent(GOLD, 3)
	reagents.add_reagent(SILVER, 3)
	reagents.add_reagent(DIAMONDDUST, 3)
	reagents.add_reagent(TRICORDRAZINE, 8) //ambrosia's medical chems replacement
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/blingpizzaslice
	name = "Blingpizza slice"
	desc = "A slice of filthy rich blingpizza. How did you afford it?"
	icon_state = "blingpizzaslice"
	bitesize = 2

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food_container.dmi'
	icon_state = "pizzabox1"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/return_air()//keeping your pizza warms
	return

/obj/item/pizzabox/on_vending_machine_spawn()//well, it's from the supply shuttle rather but hey
	if (pizza)
		pizza.on_vending_machine_spawn()
		pizza.update_icon()

/obj/item/pizzabox/update_icon()

	overlays.Cut()

	// Set appropriate description
	if( open && pizza )
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if( boxes.len > 0 )
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."

		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if( toptag != "" )
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."

		if( boxtag != "" )
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

	// Icon states and overlays
	if( open )
		if( ismessy )
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"

		if(pizza)
			pizza.link_particles(src)
			var/image/pizzaimg = new()
			pizzaimg.appearance = pizza.appearance
			pizzaimg.pixel_y = -3 * PIXEL_MULTIPLIER
			pizzaimg.pixel_x = 0
			pizzaimg.plane = FLOAT_PLANE
			pizzaimg.layer = FLOAT_LAYER
			overlays += pizzaimg

		return
	else
		// Stupid code because byondcode sucks
		remove_particles()
		var/doimgtag = 0
		if( boxes.len > 0 )
			var/obj/item/pizzabox/topbox = boxes[boxes.len]
			if( topbox.boxtag != "" )
				doimgtag = 1
		else
			if( boxtag != "" )
				doimgtag = 1

		if( doimgtag )
			var/image/tagimg = image("food.dmi", icon_state = "pizzabox_tag")
			tagimg.pixel_y = boxes.len * 3 * PIXEL_MULTIPLIER
			overlays += tagimg

	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/attack_hand( mob/user as mob )

	if( open && pizza )
		user.put_in_hands( pizza )

		to_chat(user, "<span class='notice'>You take the [src.pizza] out of the [src].</span>")
		src.pizza = null
		remove_particles()
		update_icon()
		return

	if( boxes.len > 0 )
		if( user.get_inactive_hand() != src )
			..()
			return

		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box

		user.put_in_hands( box )
		to_chat(user, "<span class='warning'>You remove the topmost [src] from your hand.</span>")
		box.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attack_self( mob/user as mob )

	if( boxes.len > 0 )
		return

	open = !open

	if( open && pizza )
		ismessy = 1

	update_icon()

/obj/item/pizzabox/attackby( obj/item/I as obj, mob/user as mob )
	if( istype(I, /obj/item/pizzabox/) )
		var/obj/item/pizzabox/box = I

		if( !box.open && !src.open )
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i

			if( (boxes.len+1) + boxestoadd.len <= 5 )
				if(user.drop_item(I, src))

					box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
					src.boxes.Add( boxestoadd )

					box.update_icon()
					update_icon()

					to_chat(user, "<span class='notice'>You put the [box] ontop of the [src]!</span>")

			else
				to_chat(user, "<span class='warning'>The stack is too high!</span>")
		else
			to_chat(user, "<span class='warning'>Close the [box] first!</span>")

		return

	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/)||istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable/pizza/)) // Long ass fucking object name
		if(src.pizza)
			to_chat(user, "<span class='warning'>[src] already has a pizza in it.</span>")
		else if(src.open)
			if(user.drop_item(I, src))
				src.pizza = I
				src.update_icon()
				to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='warning'>Open [src] first.</span>")

		return

	if( istype(I, /obj/item/weapon/pen/) )

		if( src.open )
			return

		var/t = copytext(sanitize(input("Enter what you want to add to the tag:", "Write", null, null) as text|null), 1, MAX_MESSAGE_LEN)
		if (!Adjacent(user) || user.stat)
			return

		var/obj/item/pizzabox/boxtotagto = src
		if( boxes.len > 0 )
			boxtotagto = boxes[boxes.len]

		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)

		update_icon()
		return
	..()

/obj/item/pizzabox/margherita/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita(src)
	boxtag = "Margherita Deluxe"

/obj/item/pizzabox/vegetable/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza(src)
	boxtag = "Gourmet Vegetable"

/obj/item/pizzabox/mushroom/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza(src)
	boxtag = "Mushroom Special"

/obj/item/pizzabox/meat/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza(src)
	boxtag = "Meatlover's Supreme"

/obj/item/pizzabox/blingpizza/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/blingpizza(src)
	boxtag = "Centcomm Selects"

////////////////////////////////FOOD ADDITIONS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/wrap/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/beans
	name = "tin of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	filling_color = "#982424"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/beans/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/benedict/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon_state = "hotdog"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/hotdog/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(KETCHUP, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/meatbun/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in it's own packaging."
	icon_state = "icecreamsandwich"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(ICE, 2, reagtemp = T0C)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/notasandwich/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	food_flags = FOOD_SWEET | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(SUGAR, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/caramelcookie
	name = "caramel cookie"
	desc = "Just like your little sister used to make."
	icon_state = "caramelcookie"
	food_flags = FOOD_SWEET | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/caramelcookie/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(CARAMEL, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	food_flags = FOOD_MEAT
	plate_offset_y = -5
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon_state = "spidereggs"
	food_flags = FOOD_ANIMAL //eggs are eggs
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/spidereggs/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(TOXIN, 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	food_flags = FOOD_MEAT | FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(SODIUMCHLORIDE, 1)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sashimi/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(CARPPHEROMONES, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/assburger
	name = "assburger"
	desc = "You better be REALLY nice to this burger, or it'll report you to the police!"
	icon_state = "assburger"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/assburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(MINDBREAKER, 10) // Screaming
	reagents.add_reagent(MERCURY,       10) // Idiot
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/asspie
	name = "asspie"
	desc = "Please remember to check your privilege, pie eating scum."
	icon_state = "asspie"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/pie/asspie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(MINDBREAKER, 10) // Screaming
	reagents.add_reagent(MERCURY,       10) // Idiot
	bitesize = 3

////////////////////////////////ICE CREAM///////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/icecream
	name = "ice cream"
	desc = "Delicious ice cream."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_cone"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	var/image/filling

/obj/item/weapon/reagent_containers/food/snacks/icecream/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)
	reagents.add_reagent(SUGAR,1)
	bitesize = 1
	update_icon()

/obj/item/weapon/reagent_containers/food/snacks/icecream/update_icon()
	extra_food_overlay.overlays -= filling
	filling = image('icons/obj/kitchen.dmi', src, "icecream_color")
	filling.icon += mix_color_from_reagents(reagents.reagent_list)
	extra_food_overlay.overlays += filling
	..()

/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone
	name = "ice cream cone"
	desc = "Delicious ice cream."
	icon_state = "icecream_cone"
	volume = 500
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(SUGAR,6)
	reagents.add_reagent(ICE,2, reagtemp = T0C)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup
	name = "chocolate ice cream cone"
	desc = "Delicious ice cream."
	icon_state = "icecream_cup"
	volume = 500
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(SUGAR,8)
	reagents.add_reagent(ICE,2, reagtemp = T0C)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/cereal
	name = "box of cereal"
	desc = "A box of cereal."
	icon = 'icons/obj/food_custom.dmi'
	icon_state = "cereal_box"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cereal/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	icon = 'icons/obj/food_custom.dmi'
	icon_state = "deepfried_holder_icon"
	bitesize = 2
	deepfried = 1

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/New()
	..()
	if(deepFriedNutriment)
		reagents.add_reagent(NUTRIMENT,deepFriedNutriment)

///////////////////////////////////////////
// new old food stuff from bs12
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	bitesize = 2
	food_flags = FOOD_ANIMAL //eggs

/obj/item/weapon/reagent_containers/food/snacks/dough/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough(loc)
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to roll it out!</span>")
	else
		..()

// slicable into 3xdoughslices
/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3
	storage_slots = 2
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL //eggs

/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/doughslice/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "burger bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bun/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)

//////////////////CHRISTMAS AND WINTER FOOD//////////////////

/obj/item/weapon/reagent_containers/food/snacks/sliceable/buchedenoel
	name = "\improper Buche de Noel"
	desc = "Merry Christmas."
	icon_state = "buche"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/bucheslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	trash = /obj/item/trash/tray
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE //eggs

/obj/item/weapon/reagent_containers/food/snacks/sliceable/buchedenoel/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	reagents.add_reagent(SUGAR, 9)
	reagents.add_reagent(COCO, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/bucheslice
	name = "\improper Buche de Noel slice"
	desc = "A slice of winter magic."
	icon_state = "buche_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey
	name = "turkey"
	desc = "Tastes like chicken."
	icon_state = "turkey"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	slices_num = 2
	storage_slots = 2
	w_class = W_CLASS_MEDIUM
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	reagents.add_reagent(BLACKPEPPER, 1)
	reagents.add_reagent(SODIUMCHLORIDE, 1)
	reagents.add_reagent(CORNOIL, 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	name = "turkey drumstick"
	desc = "Guaranteed vox-free!"
	icon_state = "turkey_drumstick"
	bitesize = 2
	food_flags = FOOD_MEAT
	plate_offset_y = -1
	base_crumb_chance = 0

//////////////////CHICKEN//////////////////

/obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets
	name = "Chicken Nuggets"
	desc = "You'd rather not know how they were prepared."
	icon_state = "kfc_nuggets"
	item_state = "kfc_bucket"
	trash = /obj/item/trash/chicken_bucket
	food_flags = FOOD_MEAT
	filling_color = "#D8753E"
	base_crumb_chance = 3
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)

/obj/item/weapon/reagent_containers/food/snacks/chicken_drumstick
	name = "chicken drumstick"
	desc = "We can fry further..."
	icon_state = "chicken_drumstick"
	food_flags = FOOD_MEAT
	filling_color = "#D8753E"
	base_crumb_chance = 0
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chicken_drumstick/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

/obj/item/weapon/reagent_containers/food/snacks/chicken_tenders
	name = "Chicken Tenders"
	desc = "A very special meal for a very good boy."
	icon_state = "tendies"
	food_flags = FOOD_MEAT
	base_crumb_chance = 3
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chicken_tenders/New()
	..()
	reagents.add_reagent(CORNOIL, 3)
	reagents.add_reagent(TENDIES, 3)


//////////////////VOX CHICKEN//////////////////

/obj/item/weapon/reagent_containers/food/snacks/vox_nuggets
	name = "Vox Nuggets"
	desc = "Looks awful and off-colour, you wish you'd gone to Cluckin' Bell instead."
	icon_state = "vox_nuggets"
	item_state = "kfc_bucket"
	trash = /obj/item/trash/chicken_bucket
	food_flags = FOOD_MEAT
	filling_color = "#4A75F4"
	base_crumb_chance = 3
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/vox_nuggets/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)

/obj/item/weapon/reagent_containers/food/snacks/vox_chicken_drumstick
	name = "Vox drumstick"
	desc = "I can't stand cold food. Unlike you, I ain't never ate from a trash can."
	icon_state = "vox_drumstick"
	food_flags = FOOD_MEAT
	filling_color = "#4A75F4"
	base_crumb_chance = 0
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/vox_chicken_drumstick/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

/obj/item/weapon/reagent_containers/food/snacks/vox_chicken_tenders
	name = "Vox Tenders"
	desc = "Respect has to be earned, Sweet - just like money."
	icon_state = "vox_tendies"
	food_flags = FOOD_MEAT
	base_crumb_chance = 3
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/vox_chicken_tenders/New()
	..()
	reagents.add_reagent(CORNOIL, 3)
	reagents.add_reagent(TENDIES, 3)

//////////////////CURRY//////////////////

/obj/item/weapon/reagent_containers/food/snacks/curry
	name = "Chicken Balti"
	desc = "Finest Indian Cuisine, at least you think it is chicken."
	icon_state = "curry_balti"
	item_state = "curry_balti"
	food_flags = FOOD_MEAT
	valid_utensils = UTENSILE_SPOON
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/curry/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/curry/vindaloo
	name = "Chicken Vindaloo"
	desc = "Me and me Mum and me Dad and me Nan are off to Waterloo, me and me Mum and me Dad and me Nan and a bucket of Vindaloo!"
	icon_state = "curry_vindaloo"
	item_state = "curry_vindaloo"
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/curry/vindaloo/New()
	..()
	reagents.add_reagent(CAPSAICIN, 10)

/obj/item/weapon/reagent_containers/food/snacks/curry/crab
	name = "Crab Curry"
	desc = "An Indian dish with a snappy twist!"
	icon_state = "curry_crab"
	item_state = "curry_crab"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/curry/lemon
	name = "Lemon Curry"
	desc = "This actually exists?"
	icon_state = "curry_lemon"
	item_state = "curry_lemon"
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/curry/xeno
	name = "Xeno Balti"
	desc = "Waste not want not."
	icon_state = "curry_xeno"
	item_state = "curry_xeno"
	base_crumb_chance = 0


//////////////////CHIPS//////////////////


/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps."
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#FFB700"
	base_crumb_chance = 30
	valid_utensils = 0

/obj/item/weapon/reagent_containers/food/snacks/chips/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable
	name = "Plain Chips"
	desc = "Where did the bag come from?"
	icon_state = "plain_chips"
	item_state = "plain_chips"
	trash = null

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar
	name = "Salt and Vinegar Chips"
	desc = "The objectively best flavour."
	icon_state = "salt_vinegar_chips"
	item_state = "salt_vinegar_chips"

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar
	name = "Cheddar Chips"
	desc = "Dangerously cheesy."
	icon_state = "cheddar_chips"
	item_state = "cheddar_chips"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/clown
	name = "Banana Chips"
	desc = "A clown's favourite snack!"
	icon_state = "clown_chips"
	item_state = "clown_chips"

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/clown/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(HONKSERUM, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear
	name = "Nuclear Chips"
	desc = "Radioactive taste!"
	icon_state = "nuclear_chips"
	item_state = "nuclear_chips"

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(NUKA_COLA, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/communist
	name = "Communist Chips"
	desc = "A perfect snack to share with the party!"
	icon_state = "commie_chips"
	item_state = "commie_chips"

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/communist/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(VODKA, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno
	name = "Xeno Raiders"
	desc = "A great taste that is out of this world!"
	icon_state = "xeno_chips"
	item_state = "xeno_chips"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/hot
	name = "Hot Chips"
	desc = "Don't get the dust in your eyes!"
	icon_state = "hot_chips"
	item_state = "hot_chips"
	trash = null

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/hot/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(CAPSAICIN, 7)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nova
	name = "Nova Chips"
	desc = "Little disks of heat, like a bag full of tiny suns!"
	icon_state = "nova_chips"
	item_state = "nova_chips"
	trash = null

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nova/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(NOVAFLOUR, 4)
	reagents.add_reagent(HELL_RAMEN, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/zamitos
	name = "Zamitos: Original Flavor"
	desc = "An overly processed taste that reminds you of days past when you snacked on these as a small greyling."
	trash = /obj/item/trash/chips/zamitos_o
	icon_state = "zamitos_original"
	filling_color = "#F7CE7B"

/obj/item/weapon/reagent_containers/food/snacks/zamitos/New()
	..()
	if(prob(30))
		name = "Zamitos: Blue Goo Flavor"
		desc = "Not as filling as the original flavor, and the texture is strange."
		trash = /obj/item/trash/chips/zamitos_bg
		icon_state = "zamitos_bluegoo"
		filling_color = "#5BC9DD"
		reagents.add_reagent(NUTRIMENT, 1)
		reagents.add_reagent(BLUEGOO, 5)
		bitesize = 0.8 // Same number of bites but less nutriment because it's the worst
	else
		reagents.add_reagent(NUTRIMENT, 2)
		reagents.add_reagent(ZAMSPICES, 5)
		bitesize = 0.9 // It takes a little while to chew through a bag of chips!

/obj/item/weapon/reagent_containers/food/snacks/zamitos_stokjerky
	name = "Zamitos: Spicy Stok Jerky Flavor"
	desc = "Meat-flavored crisps with three different seasonings! Almost as good as real meat."
	trash = /obj/item/trash/chips/zamitos_sj
	icon_state = "zamitos_stokjerky"
	filling_color = "#A66626"

/obj/item/weapon/reagent_containers/food/snacks/zamitos_stokjerky/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(ZAMSPICES, 2)
	reagents.add_reagent(SOYSAUCE, 2)
	reagents.add_reagent(ZAMSPICYTOXIN, 6)
	bitesize = 2 // Takes a fair few bites to finish, because why would you want to rush this?

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi
	name = "Giga Puddi"
	desc = "A large crème caramel."
	icon_state = "gigapuddi"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_SWEET
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	filling_color = "#FFEC4D"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/happy
	desc = "A large crème caramel, made with extra love."
	icon_state = "happypuddi"

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/anger
	desc = "A large crème caramel, made with extra hate."
	icon_state = "angerpuddi"

/obj/item/weapon/reagent_containers/food/snacks/flan
	name = "Flan"
	desc = "A small crème caramel."
	icon_state = "flan"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = 1
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	filling_color = "#FFEC4D"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/flan/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/honeyflan
	name = "Honey Flan"
	desc = "The systematic slavery of an entire society of insects, elegantly sized to fit in your mouth."
	icon_state = "honeyflan"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = 1
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/honeyflan/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(CINNAMON, 5)
	reagents.add_reagent(HONEY, 6)
	bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/omurice
	name = "omelette rice"
	desc = "Just like your Japanese animes!"
	icon_state = "omurice"
	food_flags = FOOD_ANIMAL //egg
	plate_offset_y = 1
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/omurice/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/omurice/heart
	icon_state = "omuriceheart"
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/omurice/face
	icon_state = "omuriceface"

/obj/item/weapon/reagent_containers/food/snacks/muffin/bluespace
	name = "Bluespace-berry Muffin"
	desc = "Just like a normal blueberry muffin, except with completely unnecessary floaty things!"
	icon_state = "bluespace"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/yellowcake
	name = "Yellowcake"
	desc = "For Fat Men."
	icon_state = "yellowcake"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //egg
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/yellowcake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 40)
	reagents.add_reagent(RADIUM, 10)
	reagents.add_reagent(URANIUM, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/yellowcupcake
	name = "Yellowcupcake"
	desc = "For Little Boys."
	icon_state = "yellowcupcake"
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/yellowcupcake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 15)
	reagents.add_reagent(RADIUM, 5)
	reagents.add_reagent(URANIUM, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cookiebowl
	name = "Bowl of cookies"
	desc = "A bowl full of small cookies."
	icon_state = "cookiebowl"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/cookiebowl/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(SUGAR, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chococherrycake
	name = "chocolate-cherry cake"
	desc = "A chocolate cake with icing and cherries."
	icon_state = "chococherrycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/chococherrycakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chococherrycake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)

/obj/item/weapon/reagent_containers/food/snacks/chococherrycakeslice
	name = "chocolate-cherry cake slice"
	desc = "Just a slice of cake, enough for everyone."
	icon_state = "chococherrycake_slice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/sliceable/fruitcake
	name = "fruitcake"
	desc = "A hefty fruitcake that could double as a hammer in a pinch."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "fruitcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/fruitcakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sliceable/fruitcake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)

/obj/item/weapon/reagent_containers/food/snacks/fruitcakeslice
	name = "fruitcake slice"
	desc = "Delicious and fruity."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "fruitcakeslice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/sliceable/fruitcake/christmascake
	name = "\improper Christmas cake"
	desc = "A hefty fruitcake covered in royal icing."
	icon_state = "christmascake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/fruitcakeslice/christmascakeslice

/obj/item/weapon/reagent_containers/food/snacks/sliceable/fruitcake/christmascake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)

/obj/item/weapon/reagent_containers/food/snacks/fruitcakeslice/christmascakeslice
	name = "\improper Christmas cake slice"
	desc = "Sweet and fruity."
	icon_state = "christmascakeslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinbread
	name = "Pumpkin Bread"
	desc = "A loaf of pumpkin bread."
	icon_state = "pumpkinbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinbreadslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM



/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinbread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 15)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinbreadslice
	name = "Pumpkin Bread slice"
	desc = "A slice of pumpkin bread."
	icon_state = "pumpkinbreadslice"
	bitesize = 2
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/corndog
	name = "Corndog"
	desc = "Battered hotdog on a stick!"
	icon_state = "corndog"
	food_flags = FOOD_MEAT | FOOD_ANIMAL //eggs
	base_crumb_chance = 1

/obj/item/weapon/reagent_containers/food/snacks/corndog/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/cornydog
	name = "CORNY DOG"
	desc = "This is just ridiculous."
	icon_state = "cornydog"
	trash = /obj/item/stack/rods  //no fun allowed
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/cornydog/New()
	..()
	reagents.add_reagent(NUTRIMENT, 15)
	bitesize = 5

////////////////SLIDERS////////////////

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider
	name = "sliders"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider
	child_volume = 2.5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10) //spawns 4

/obj/item/weapon/reagent_containers/food/snacks/slider
	name = "slider"
	desc = "It's so tiny!"
	icon_state = "slider"
	food_flags = FOOD_MEAT
	bitesize = 1.5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/synth
	name = "synth sliders"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider/synth

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/synth/New()
	..()

/obj/item/weapon/reagent_containers/food/snacks/slider/synth
	name = "synth slider"
	desc = "It's made to be tiny!"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/xeno
	name = "xeno sliders"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider/xeno
	child_volume = 3.5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/xeno/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4) //spawns 4

/obj/item/weapon/reagent_containers/food/snacks/slider/xeno
	name = "xeno slider"
	desc = "It's green!"
	icon_state = "slider_xeno"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/chicken
	name = "chicken sliders"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider/chicken
	child_volume = 3.5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/chicken/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4) //spawns 4

/obj/item/weapon/reagent_containers/food/snacks/slider/chicken
	name = "chicken slider"
	desc = "Chicken sliders? That's new."
	icon_state = "slider_chicken"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/carp
	name = "carp sliders"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider/carp
	child_volume = 3.5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/carp/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4) //spawns 4

/obj/item/weapon/reagent_containers/food/snacks/slider/carp
	name = "carp slider"
	desc = "I wonder how it tastes!"
	icon_state = "slider_carp"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/toxiccarp
	name = "carp sliders"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider/toxiccarp
	child_volume = 5.5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/toxiccarp/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4) //spawns 4
	reagents.add_reagent(CARPOTOXIN, 8)

/obj/item/weapon/reagent_containers/food/snacks/slider/toxiccarp
	name = "carp slider"
	desc = "I wonder how it tastes!"
	icon_state = "slider_carp"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/spider
	name = "spidey slideys"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider/spider
	child_volume = 3.5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/spider/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4) //spawns 4

/obj/item/weapon/reagent_containers/food/snacks/slider/spider
	name = "spidey slidey"
	desc = "I think there's still a leg in there!"
	icon_state = "slider_spider"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/clown
	name = "honky sliders"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider/clown
	child_volume = 5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/clown/New()
	..()
	reagents.add_reagent(HONKSERUM, 10) //spawns 4

/obj/item/weapon/reagent_containers/food/snacks/slider/clown
	name = "honky slider"
	desc = "HONK!"
	icon_state = "slider_clown"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/mime
	name = "quiet sliders"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider/mime
	child_volume = 5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/mime/New()
	..()
	reagents.add_reagent(SILENCER, 10) //spawns 4

/obj/item/weapon/reagent_containers/food/snacks/slider/mime
	name = "quiet slider"
	desc = "..."
	icon_state = "slider_mime"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/slippery
	name = "slippery sliders"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/slider/slippery
	child_volume = 5

/obj/item/weapon/reagent_containers/food/snacks/multispawner/slider/slippery/New()
	..() //spawns 2

/obj/item/weapon/reagent_containers/food/snacks/slider/slippery
	name = "slippery slider"
	desc = "It's so slippery!"
	icon_state = "slider_slippery"

/obj/item/weapon/reagent_containers/food/snacks/slider/slippery/Crossed(atom/movable/O) //similar to soap
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		C.Slip(3, 2, slipped_on = src)

////////////////SLIDERS END////////////////

/obj/item/weapon/reagent_containers/food/snacks/higashikata
	name = "Higashikata Special"
	desc = "9 layer parfait, very expensive."
	icon_state = "higashikata"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/higashikata/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	reagents.add_reagent(SUGAR, 10)
	reagents.add_reagent(ICE, 10, reagtemp = T0C)
	reagents.add_reagent(WATERMELONJUICE, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sundae
	name = "Sundae"
	desc = "A colorful ice cream treat."
	icon_state = "sundae"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE //milk
	base_crumb_chance = 0
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/sundae/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(SUGAR, 5)
	reagents.add_reagent(ICE, 5, reagtemp = T0C)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/avocadomilkshake
	name = "avocado milkshake"
	desc = "Strange, but good."
	icon_state = "avocadomilkshake"
	food_flags = FOOD_LIQUID | FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE //milk
	trash = /obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	valid_utensils = 0
	base_crumb_chance = 0
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_SPOON
	harmfultocorgis = TRUE

/obj/item/weapon/reagent_containers/food/snacks/avocadomilkshake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	reagents.add_reagent(SUGAR, 5)
	reagents.add_reagent(ICE, 5, reagtemp = T0C)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/potatosalad
	name = "Potato Salad"
	desc = "With 21st century technology, it could take as long as three days to make this."
	icon_state = "potato_salad"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/potatosalad/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/coleslaw
	name = "Coleslaw"
	desc = "You fought the 'slaw, and the 'slaw won."
	icon_state = "coleslaw"
	plate_offset_y = 1
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/coleslaw/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/risotto
	name = "Risotto"
	desc = "For the gentleman's wino, this is an offer one cannot refuse."
	icon_state = "risotto"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/risotto/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(WINE, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cinnamonroll
	name = "cinnamon roll"
	desc = "Sweet and spicy!"
	icon_state = "cinnamon_roll"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = 1

/obj/item/weapon/reagent_containers/food/snacks/cinnamonroll/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(CINNAMON,5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cinnamonpie
	name = "cinnamon pie"
	desc = "Guarranted snail-free!"
	icon_state = "cinnamon_pie"
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/cinnamonpie/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(CINNAMON,5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sundaeramen
	name = "Sundae Ramen"
	desc = "This is... sundae (?) flavored (?) ramen (?). You just don't know."
	icon_state = "sundaeramen"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sundaeramen/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	reagents.add_reagent(DISCOUNT, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen
	name = "Sweet Sundae Ramen"
	desc = "A delicious ramen recipe that can soothe the soul of a savage spaceman."
	icon_state = "sweetsundaeramen"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //uses puddi in recipe
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen/New()
	..()
	bitesize = 4
	while(reagents.total_volume<70)
		generatecontents()

/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen/proc/generatecontents()
	switch(pick(1,2,3,4,5,6,7,8,9,10))
		if(1)
			desc += " It has peppermint flavoring! But just a few drops."
			reagents.add_reagent(ZOMBIEPOWDER, 10)
		if(2)
			desc += " This may not be everyone's cup of tea, but it's great, I promise."
			reagents.add_reagent(OXYCODONE, 10)
		if(3)
			desc += " This has the cook's favorite ingredient -- and a lot of it!"
			reagents.add_reagent(MINDBREAKER, 10)
		if(4)
			desc += " It has TONS of flavor!"
			reagents.add_reagent(MINTTOXIN, 10)
		if(5)
			desc += " The recipe for this thing got lost somewhere..."
			reagents.add_reagent(NUTRIMENT, 10)
		if(6)
			desc += " It has extra sweetness and a little bit of crumble!"
			reagents.add_reagent(TRICORDRAZINE, 10)
		if(7)
			desc += " It may be thick, but the noodles slip around easily."
			reagents.add_reagent(NUTRIMENT, 10)
		if(8)
			desc += " It has a nice crunch!"
			reagents.add_reagent(NUTRIMENT, 10)
		if(9)
			desc += " Yummy, but with all the sweets, your chest starts to hurt."
			reagents.add_reagent(NUTRIMENT, 10)
		if(10)
			desc += " Just a dollop of garnishes."
			reagents.add_reagent(NUTRIMENT, 10)

/obj/item/weapon/reagent_containers/food/snacks/chocofrog
	name = "chocolate frog"
	desc = "An exotic snack originating from the Space Wizard Federation. Very slippery!"
	icon = 'icons/obj/wiz_cards.dmi'
	icon_state = "frog"
	flags = PROXMOVE
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	var/jump_cd

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/New()
	..()
	reagents.add_reagent(NUTRIMENT,2)
	reagents.add_reagent(HYPERZINE,1)

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/HasProximity(atom/movable/AM as mob|obj)
	if(!jump_cd && isliving(AM))
		jump()
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/proc/jump()
	if(!istype(src.loc,/turf))
		return
	jump_cd=1
	spawn(50)
		jump_cd=0

	var/list/escape_paths=list()

	for(var/turf/T in view(7,src))
		escape_paths |= T

	var/turf/T = pick(escape_paths)
	src.throw_at(T, 10, 2)
	return 1

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/pickup(mob/living/user as mob)
	var/mob/living/carbon/human/H = user
	if(!H)
		return 1

	spawn(0)
		if((clumsy_check(H)) || prob(25))
			if(H.drop_item())
				user.visible_message("<span class='warning'>[src] escapes from [H]'s hands!</span>","<span class='warning'>[src] escapes from your grasp!</span>")

				jump()
	return 1

/obj/item/weapon/reagent_containers/food/snacks/potentham
	name = "potent ham"
	desc = "I'm sorry Dave, but I'm afraid I can't let you eat that."
	icon_state = "potentham"
	volume = 1
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/potentham/New()
	..()
	reagents.add_reagent(HAMSERUM, 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sweet
	name = "\improper Sweet"
	desc = "Comes in many different and unique flavours! One of the flagship products of the Getmore Chocolate Corp. Not suitable for children aged 0-3. Do not consume around open flames or expose to radiation. Flavors may not match the description. Expiration date: 2921."
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	icon = 'icons/obj/candymachine.dmi'
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/sweet/New()
	..()
	var/list/possible_reagents=list(NUTRIMENT=5, SUGAR=10, CORNOIL=5, BANANA=15, LIQUIDBUTTER=5, NUTRIMENT=10, CARAMEL=10, LEMONJUICE=10, APPLEJUICE=10, WATERMELONJUICE=10, GRAPEJUICE=10, ORANGEJUICE=10, TOMATOJUICE=10, LIMEJUICE=10, CARROTJUICE=10, BERRYJUICE=10, GGRAPEJUICE=10, POTATO=10, PLUMPHJUICE=10, COCO=10, SPRINKLES=10, NUTRIMENT=20)
	var/list/flavors = list("\improper strawberry","\improper lime","\improper blueberry","\improper banana","\improper grape","\improper lemonade","\improper bubblegum","\improper raspberry","\improper orange","\improper liquorice","\improper apple","\improper cranberry")
	var/reagent=pick(possible_reagents)
	reagents.add_reagent(reagent, possible_reagents[reagent])
	var/variety = rand(1,flavors.len) //MORE SWEETS MAYBE IF YOU SPRITE IT
	icon_state = "sweet[variety]"
	name = "[flavors[variety]] sweet"

/obj/item/weapon/reagent_containers/food/snacks/sweet/strange
	desc = "Something about this sweet doesn't seem right."

/obj/item/weapon/reagent_containers/food/snacks/sweet/strange/New()
	..()
	var/list/possible_reagents=list(ZOMBIEPOWDER=5, MINDBREAKER=5, PACID=5, HYPERZINE=5, CHLORALHYDRATE=5, TRICORDRAZINE=5, DOCTORSDELIGHT=5, MUTATIONTOXIN=5, MERCURY=5, ANTI_TOXIN=5, SPACE_DRUGS=5, HOLYWATER=5,  RYETALYN=5, CRYPTOBIOLIN=5, DEXALINP=5, HAMSERUM=1,
	LEXORIN=5, GRAVY=5, DETCOFFEE=5, AMUTATIONTOXIN=5, GYRO=5, SILENCER= 5, URANIUM=5, WATER=5, DIABEETUSOL =5, SACID=5, LITHIUM=5, CHILLWAX=5, OXYCODONE=5, VOMIT=5, BLEACH=5, HEARTBREAKER=5, NANITES=5, CORNOIL=5, NOVAFLOUR=5, DEGENERATECALCIUM = 5, COLORFUL_REAGENT = 5, LIQUIDBUTTER = 5)
	var/reagent=pick(possible_reagents)
	reagents.add_reagent(reagent, possible_reagents[reagent])

/obj/item/weapon/reagent_containers/food/snacks/lollipop
	name = "lollipop"
	desc = "Suck on this!"
	icon_state = "lollipop_stick"
	item_state = "lollipop_stick"
	food_flags = FOOD_SWEET
	icon = 'icons/obj/candymachine.dmi'
	bitesize = 5
	slot_flags = SLOT_MASK //No, really, suck on this.
	goes_in_mouth = TRUE
	attack_verb = list("taps", "pokes")
	eatverb = "crunch"
	valid_utensils = 0
	trash = /obj/item/trash/lollipopstick
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	var/candyness = 161 //how long this thing will last
	var/list/reagents_to_add = list(NUTRIMENT=2, SUGAR=8)
	volume = 20 //not a lotta room for poison
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/lollipop/New()
	..()
	eatverb = pick("bite","crunch","chomp")
	for (var/reagent in reagents_to_add)
		reagents.add_reagent(reagent, reagents_to_add[reagent])
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	var/image/colorpop = image('icons/obj/candymachine.dmi', icon_state = "lollipop_head")
	colorpop.color = pick(random_color_list)
	extra_food_overlay.overlays += colorpop
	overlays += colorpop
	filling_color = colorpop.color

/obj/item/weapon/reagent_containers/food/snacks/lollipop/consume()
	..()
	candyness -= bitesize*10 //taking a bite out reduces how long it'll last

/obj/item/weapon/reagent_containers/food/snacks/lollipop/proc/updateconsuming(var/consuming)
	if(consuming)
		processing_objects.Add(src)
	else
		processing_objects.Remove(src)

/obj/item/weapon/reagent_containers/food/snacks/lollipop/process()
	var/mob/living/carbon/human/H = get_holder_of_type(src,/mob/living/carbon/human)
	if(!H) //we ended up outside our human somehow
		updateconsuming(FALSE)
		return
	if(H.isDead()) //human isn't really consuming it
		return
	if(H.is_wearing_item(src,slot_wear_mask))
		candyness--
	if(candyness <= 0)
		to_chat(H, "<span class='notice'>You finish \the [src].</span>")
		var/atom/new_stick = new /obj/item/trash/lollipopstick(loc)
		transfer_fingerprints_to(new_stick)
		qdel(src)
		H.equip_to_slot(new_stick, slot_wear_mask, 1)
	else
		if(candyness%10 == 0) //every 10 ticks, ~15 times
			reagents.trans_to(H, 1, log_transfer = FALSE, whodunnit = null)
		if(candyness%50 == 0) //every 50 ticks, so ~3 times
			bitecount++ //we're arguably eating it

/obj/item/weapon/reagent_containers/food/snacks/lollipop/equipped(mob/living/carbon/human/H, equipped_slot)
	if(!H.isDead())
		updateconsuming(equipped_slot == slot_wear_mask)

/obj/item/weapon/reagent_containers/food/snacks/lollipop/medipop
	name = "medipop"
	reagents_to_add = list(NUTRIMENT=2, SUGAR=8, TRICORDRAZINE=10)

/obj/item/weapon/reagent_containers/food/snacks/lollipop/lollicheap
	name = "cheap medipop"
	reagents_to_add = list(NUTRIMENT=2, SUGAR=8, PICCOLYN=1, TRICORDRAZINE = 1)

/obj/item/weapon/reagent_containers/food/snacks/chococoin
	name = "\improper Choco-Coin"
	desc = "A thin wafer of milky, chocolatey, melt-in-your-mouth goodness. That alone is already worth a hoard."
	food_flags = FOOD_SWEET
	icon_state = "chococoin_unwrapped"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped
	desc = "Still covered in golden foil wrapper."
	icon_state = "chococoin_wrapped"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped/is_screwdriver(var/mob/user)
	return user.a_intent == I_HURT

/obj/item/weapon/reagent_containers/food/snacks/chococoin/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(SUGAR, 2)
	reagents.add_reagent(COCO, 3)
	add_component(/datum/component/coinflip)

/obj/item/weapon/reagent_containers/food/snacks/chococoin/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/chococoin/proc/Unwrap(mob/user)
	icon_state = "chococoin_unwrapped"
	desc = "A thin wafer of milky, chocolatey, melt-in-your-mouth goodness. That alone is already worth a hoard."
	to_chat(user, "<span class='notice'>You remove the golden foil from \the [src].</span>")
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/chococoin/is_screwdriver(var/mob/user)
	return user.a_intent == I_HURT

/obj/item/trash/lollipopstick
	name = "lollipop stick"
	desc = "A small plastic stick."
	icon = 'icons/obj/candymachine.dmi'
	icon_state = "lollipop_stick"
	w_class = W_CLASS_TINY
	slot_flags = SLOT_MASK
	goes_in_mouth = TRUE
	throwforce = 1
	w_type = RECYK_PLASTIC
	starting_materials = list(MAT_PLASTIC = 100)
	species_fit = list(INSECT_SHAPED)

/obj/item/weapon/reagent_containers/food/snacks/eucharist
	name = "\improper Eucharist Wafer"
	icon_state = "eucharist"
	desc = "For the kingdom, the power, and the glory are yours, now and forever."
	bitesize = 5
	base_crumb_chance = 0
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/eucharist/New()
	..()
	reagents.add_reagent(HOLYWATER, 5)

/obj/item/weapon/reagent_containers/food/snacks/eclair
	name = "\improper eclair"
	desc = "Plus doux que ses lèvres."
	icon_state = "eclair"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/eclair/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(CREAM, 2)

/obj/item/weapon/reagent_containers/food/snacks/eclair/big
	name = "massive eclair"
	desc = "Plus fort que ses hanches."
	icon_state = "big_eclair"
	bitesize = 30
	w_class = 5

/obj/item/weapon/reagent_containers/food/snacks/eclair/big/New()
	..()
	reagents.add_reagent(NUTRIMENT, 27)
	reagents.add_reagent(CREAM, 18)

/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje
	name = "IJzerkoekje"
	desc = "Bevat geen ijzer."
	icon_state = "ijzerkoekje"
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(IRON, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie
	name = "no-fruit pie"
	desc = "It doesn't really taste like anything."
	icon_state = "nofruitpie"
	trash = /obj/item/trash/pietin
	var/list/available_snacks = list()
	var/switching = 0
	var/current_path = null
	var/counter = 1

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/New()
	..()
	reagents.add_reagent(NOTHING, 20)
	bitesize = 10
	available_snacks = existing_typesof(/obj/item/weapon/reagent_containers/food/snacks) - typesof(/obj/item/weapon/reagent_containers/food/snacks/grown) - typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)
	available_snacks = shuffle(available_snacks)

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/verb/pick_leaf()
	set name = "Pick no-fruit pie leaf"
	set category = "Object"
	set src in range(1)

	var/mob/user = usr
	if(!user.Adjacent(src))
		return
	if(user.isUnconscious())
		to_chat(user, "You can't do that while unconscious.")
		return

	if(!switching)
		randomize()
	else
		getnofruit(user, user.get_active_hand())

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/AltClick(mob/user)
	pick_leaf()

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/attackby(obj/item/weapon/W, mob/user)
	pick_leaf()

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/proc/randomize()
	switching = 1
	mouse_opacity = 2
	spawn()
		while(switching)
			current_path = available_snacks[counter]
			var/obj/item/weapon/reagent_containers/food/snacks/S = current_path
			icon_state = initial(S.icon_state)
			sleep(4)
			if(counter == available_snacks.len)
				counter = 0
				available_snacks = shuffle(available_snacks)
			counter++

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/proc/getnofruit(mob/user, obj/item/weapon/W = null)
	if(!switching || !current_path)
		return
	verbs -= /obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/verb/pick_leaf
	switching = 0
	if(get_turf(user))
		playsound(user, "sound/weapons/genhit[rand(1,3)].ogg", 50, 1)
	if(W)
		user.visible_message("[user] smacks \the [src] with \the [W].","You smack \the [src] with \the [W].")
	else
		user.visible_message("[user] smacks \the [src].","You smack \the [src].")
	user.create_in_hands(src,current_path)

/obj/item/weapon/reagent_containers/food/snacks/sundayroast
	name = "Sunday roast"
	desc = "Everyday is Sunday when you orbit a sun."
	icon_state = "voxroast"
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sundayroast/New()
	..()
	reagents.add_reagent(NUTRIMENT, 20)
	reagents.add_reagent(CORNOIL, 4)
	reagents.add_reagent(GRAVY, 4)

/obj/item/weapon/reagent_containers/food/snacks/risenshiny
	name = "rise 'n' shiny"
	desc = "A biscuit: exactly what a Vox merchant or thief needs to start their day. (What's the difference?)"
	icon_state = "voxbiscuit"
	bitesize = 3
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/risenshiny/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(GRAVY, 2)

/obj/item/weapon/reagent_containers/food/snacks/mushnslush
	name = "mush 'n' slush"
	desc = "Mushroom gravy poured thickly over more mushrooms. Rich in flavor and in pocket."
	icon_state = "voxmush"
	bitesize = 2
	filling_color = "#A5782D"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/mushnslush/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(GRAVY, 4)

/obj/item/weapon/reagent_containers/food/snacks/woodapplejam
	name = "woodapple jam"
	desc = "Tastes like white lightning made from pure sugar. Wham!"
	icon_state = "voxjam"
	bitesize = 2
	crumb_icon = "dribbles"
	filling_color = "#70054E"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/woodapplejam/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale",DRINK)
	reagents.add_reagent(HYPERZINE, 4)
	reagents.add_reagent(NUTRIMENT, 1)

/obj/item/weapon/reagent_containers/food/snacks/pie/breadfruit
	name = "breadfruit pie"
	desc = "Tastes like chalk, but birds like it for some reason."
	icon_state = "voxpie"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/breadfruit/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 6)

/obj/item/weapon/reagent_containers/food/snacks/candiedwoodapple
	name = "candied woodapple"
	desc = "The sweet juices inside the woodapple quickferment under heat, producing this party favorite."
	icon_state = "candiedwoodapple"
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/candiedwoodapple/New()
	..()
	reagents.add_reagent(SUGAR, 4)
	reagents.add_reagent(WINE, 20)

/obj/item/weapon/reagent_containers/food/snacks/voxstew
	name = "Vox stew"
	desc = "The culinary culmination of all Vox culture: throwing all their plants into the same pot."
	icon_state = "voxstew"
	bitesize = 4
	filling_color = "#89441E"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/voxstew/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale",DRINK)
	reagents.add_reagent(NUTRIMENT, 15)
	reagents.add_reagent(IMIDAZOLINE, 5)

/obj/item/weapon/reagent_containers/food/snacks/garlicbread
	name = "garlic bread"
	desc = "Banned in Space Transylvania."
	icon_state = "garlicbread"
	bitesize = 3
	food_flags = FOOD_DIPPABLE
	harmfultocorgis = TRUE

/obj/item/weapon/reagent_containers/food/snacks/garlicbread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(HOLYWATER, 2)

/obj/item/weapon/reagent_containers/food/snacks/flammkuchen
	name = "flammkuchen"
	desc = "Also called tarte flambee, literally 'flame cake'. Ancient French and German people once tried not fighting and the result was a pie that is loaded with garlic, burned, and flat."
	icon_state = "flammkuchen"
	bitesize = 4
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/flammkuchen/New()
	..()
	reagents.add_reagent(NUTRIMENT, 30)
	reagents.add_reagent(HOLYWATER, 10)

/obj/item/weapon/reagent_containers/food/snacks/frog_leg
	name = "frog leg"
	desc = "A thick, delicious legionnaire frog leg, its taste and texture resemble chicken."
	icon_state = "frog_leg"
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/frog_leg/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)


/obj/item/weapon/reagent_containers/food/snacks/pie/welcomepie
	name = "friendship pie"
	desc = "Offered as a gesture of Vox goodwill." //"Goodwill"
	icon_state = "welcomepie"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/pie/welcomepie/New()
	..()
	reagents.add_reagent(SACID,6)
	reagents.add_reagent(NUTRIMENT,2)

/obj/item/weapon/reagent_containers/food/snacks/zhulongcaofan
	name = "zhu long cao fan"
	desc = "Literally meaning 'pitcher plant rice'. After carefully cleansing and steaming the pitcher plant, it is stuffed with steamed rice. The carnivorous plant is rich with minerals from fauna it has consumed."
	icon_state = "zhulongcaofan"
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/zhulongcaofan/New()
	..()
	reagents.add_reagent(NUTRIMENT,6)
	reagents.add_reagent(IRON,6)

/obj/item/weapon/reagent_containers/food/snacks/bacon
	name = "bacon strip"
	desc = "A heavenly aroma surrounds this meat."
	icon_state = "bacon"
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/bacon/New()
	..()
	reagents.add_reagent(NUTRIMENT,6)

/obj/item/weapon/reagent_containers/food/snacks/porktenderloin
	name = "pork tenderloin"
	desc = "Delicious, gravy-covered meat that will melt-in-your-beak. Or mouth."
	icon_state = "porktenderloin"
	bitesize = 4
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/porktenderloin/New()
	..()
	reagents.add_reagent(NUTRIMENT,10) //Competitive with chicken buckets
	reagents.add_reagent(GRAVY, 4)

/obj/item/weapon/reagent_containers/food/snacks/hoboburger
	name = "hoboburger"
	desc = "A burger which uses a sack-shaped plant as a 'bun'. Any sufficiently poor Vox is indistinguishable from a hobo."
	icon_state = "hoboburger"
	bitesize = 4
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/hoboburger/New()
	..()
	reagents.add_reagent(NUTRIMENT,14) //Competitive with big bite burger

/obj/item/weapon/reagent_containers/food/snacks/sweetandsourpork
	name = "sweet and sour pork"
	desc = "Makes your insides burn with flavor! With this in your stomach, you won't want to stop moving any time soon."
	icon_state = "sweetsourpork"
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sweetandsourpork/New()
	..()
	//3 nutriment inherited from the meat
	reagents.add_reagent(LITHIUM,2) //Random movement for a short period
	reagents.add_reagent(SYNAPTIZINE,1) //Stay on your feet, loads of toxins

/obj/item/weapon/reagent_containers/food/snacks/reclaimed
	name = "reclaimed nutrition cube"
	desc = "This food represents a highly efficient use of station resources. The Corporate AI's favorite!"
	icon_state = "monkeycubewrap"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/reclaimed/New()
	..()
	reagents.add_reagent(NUTRIMENT,3)

/obj/item/weapon/reagent_containers/food/snacks/poachedaloe
	name = "poached aloe"
	desc = "Extremely oily and slippery gel contained inside aloe."
	icon_state = "poachedaloe"
	bitesize = 1
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/poachedaloe/New()
	..()
	reagents.add_reagent(NUTRIMENT,2)

/obj/item/weapon/reagent_containers/food/snacks/vanishingstew
	name = "vapor stew"
	desc = "Most stews vanish, but this one does so before you eat it."
	icon_state = "vanishingstew"
	bitesize = 2
	crumb_icon = "dribbles"
	filling_color = "#FF9933"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/vanishingstew/New()
	..()
	reagents.add_reagent(NUTRIMENT,3)

/obj/item/weapon/reagent_containers/food/snacks/threebeanburrito
	name = "three bean burrito"
	desc = "Beans, beans a magical fruit."
	icon_state = "danburrito"
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/threebeanburrito/New()
	..()
	reagents.add_reagent(NUTRIMENT,5)

/obj/item/weapon/reagent_containers/food/snacks/midnightsnack
	name = "midnight snack"
	desc = "Perfect for those occasions when engineering doesn't set up power."
	icon_state = "midnightsnack"
	bitesize = 2
	trash = /obj/item/trash/snack_bowl
	random_filling_colors = list("#0683FF","#00CC28","#FF8306","#8600C6","#306900","#9F5F2D")
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/midnightsnack/New()
	..()
	reagents.add_reagent(NUTRIMENT,2)
	set_light(2)

/obj/item/weapon/reagent_containers/food/snacks/primordialsoup
	name = "primordial soup"
	desc = "From a soup just like this, a sentient race could one day emerge. Better eat it to be safe."
	icon_state = "primordialsoup"
	bitesize = 2
	food_flags = FOOD_LIQUID | FOOD_ANIMAL //blood is animal sourced
	crumb_icon = "dribbles"
	filling_color = "#720D00"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/primordialsoup/New()
	..()
	reagents.add_reagent(NUTRIMENT,8)

/obj/item/weapon/reagent_containers/food/snacks/starrynightsalad
	name = "starry night salad"
	desc = "Eating too much of this salad may cause you to want to cut off your own ear."
	icon_state = "starrynight"
	bitesize = 2
	trash = /obj/item/trash/snack_bowl
	random_filling_colors = list("#8600C6","#306900","#9F5F2D")
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/starrynightsalad/New()
	..()
	reagents.add_reagent(NUTRIMENT,4)
	reagents.add_reagent(INACUSIATE,1)

/obj/item/weapon/reagent_containers/food/snacks/rosolli
	name = "rosolli"
	desc = "A salad of root vegetables from Space Finland."
	icon_state = "rosolli"
	bitesize = 2
	trash = /obj/item/trash/snack_bowl
	filling_color = "#E00000"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/rosolli/New()
	..()
	reagents.add_reagent(NUTRIMENT,6)

/obj/item/weapon/reagent_containers/food/snacks/fruitsalad
	name = "fruit salad"
	desc = "Popular among cargo technicians who break into fruit crates."
	icon_state = "fruitsalad"
	bitesize = 2
	trash = /obj/item/trash/snack_bowl
	random_filling_colors = list("#FFFF00","#FF9933","#FF3366","#CC0000")
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/fruitsalad/New()
	..()
	reagents.add_reagent(NUTRIMENT,4)

/obj/item/weapon/reagent_containers/food/snacks/nofruitsalad
	name = "no-fruit salad"
	desc = "Attempting to make this meal cycle through other types of salad was prohibited by special council decision after six weeks of intensive debate at the central hub for Galatic International Trade."
	icon_state = "nofruitsalad"
	bitesize = 4
	trash = /obj/item/trash/snack_bowl
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/nofruitsalad/New()
	..()
	reagents.add_reagent(NOTHING,20)

/obj/item/weapon/reagent_containers/food/snacks/spicycoldnoodles
	name = "spicy cold noodles"
	desc = "A noodle dish in the style popular in Space China."
	icon_state = "spicycoldnoodles"
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/spicycoldnoodles/New()
	..()
	reagents.add_reagent(NUTRIMENT,5)

/obj/item/weapon/reagent_containers/food/snacks/chinesecoldsalad
	name = "chinese cold salad"
	desc = "A whirlwind of strong flavors, served chilled. Found its origins in the old Terran nation-state of China before the rise of Space China."
	icon_state = "chinesecoldsalad"
	bitesize = 2
	random_filling_colors = list("#009900","#0066FF","#F7D795")
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/chinesecoldsalad/New()
	..()
	reagents.add_reagent(NUTRIMENT,8)
	reagents.add_reagent(FROSTOIL,2)

/obj/item/weapon/reagent_containers/food/snacks/honeycitruschicken
	name = "honey citrus chicken"
	desc = "The strong, tangy flavor of the orange and soy sauce highlights the smooth, thick taste of the honey. This fusion dish is one of the highlights of Terran cuisine."
	icon_state = "honeycitruschicken"
	bitesize = 4
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/honeycitruschicken/New()
	..()
	reagents.add_reagent(NUTRIMENT,8)
	reagents.add_reagent(HONEY,4)
	reagents.add_reagent(SUGAR,4)

/obj/item/weapon/reagent_containers/food/snacks/pimiento
	name = "pimiento"
	desc = "A vital component in the caviar of the South."
	icon_state = "pimiento"
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/pimiento/New()
	..()
	reagents.add_reagent(SUGAR,1)

/obj/item/weapon/reagent_containers/food/snacks/confederatespirit
	name = "confederate spirit"
	desc = "Even in space, where a north/south orientation is meaningless, the South will rise again."
	icon_state = "confederatespirit"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/confederatespirit/New()
	..()
	reagents.add_reagent(NUTRIMENT,8)

/obj/item/weapon/reagent_containers/food/snacks/fishtacosupreme
	name = "fish taco supreme"
	desc = "There may be more fish in the sea, but there's only one kind of fish in the stars."
	icon_state = "fishtacosupreme"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 1

/obj/item/weapon/reagent_containers/food/snacks/fishtacosupreme/New()
	..()
	reagents.add_reagent(NUTRIMENT,6)

/obj/item/weapon/reagent_containers/food/snacks/chiliconcarne
	name = "chili con carne"
	desc = "This dish became exceedingly rare after Space Texas seceeded from our plane of reality."
	icon_state = "chiliconcarne"
	bitesize = 3
	food_flags = FOOD_LIQUID | FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/chiliconcarne/New()
	..()
	reagents.add_reagent(NUTRIMENT,10)
	reagents.add_reagent(CAPSAICIN,2)

/obj/item/weapon/reagent_containers/food/snacks/cloverconcarne
	name = "clover con carne"
	desc = "Hearty, yet delightfully refreshing. The savory taste of the steak is complemented by the herbal je ne sais quoi of the clover."
	icon_state = "cloverconcarne"
	bitesize = 3
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/cloverconcarne/New()
	..()
	reagents.add_reagent(NUTRIMENT,5)

/obj/item/weapon/reagent_containers/food/snacks/chilaquiles
	name = "chilaquiles"
	desc = "The salsa-equivalent of nachos."
	icon_state = "chilaquiles"
	bitesize = 1
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/chilaquiles/New()
	..()
	reagents.add_reagent(NUTRIMENT,8)

/obj/item/weapon/reagent_containers/food/snacks/quiche
	name = "quiche"
	desc = "The queechay has a long history of being mispronounced. Just a taste makes you feel more cerebral and cultured!"
	icon_state = "quiche"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	bitesize = 4
	plate_offset_y = -1
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/quiche/New()
	..()
	reagents.add_reagent(NUTRIMENT,8)
	reagents.add_reagent(METHYLIN,5)

/obj/item/weapon/reagent_containers/food/snacks/minestrone
	name = "minestrone"
	desc = "It's a me, minestrone."
	icon_state = "minestrone"
	bitesize = 4
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/minestrone/New()
	..()
	reagents.add_reagent(NUTRIMENT,8)
	reagents.add_reagent(IMIDAZOLINE,2)

/obj/item/weapon/reagent_containers/food/snacks/poissoncru
	name = "poisson cru"
	desc = "The national dish of Tonga, a country that you had previously never heard about."
	icon_state = "poissoncru"
	bitesize = 2
	plate_offset_y = 1
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/poissoncru/New()
	..()
	reagents.add_reagent(NUTRIMENT,4)

/obj/item/weapon/reagent_containers/food/snacks/chickensalad
	name = "chicken salad"
	desc = "Evokes the question: do you ruin chicken by putting it in a salad, or improve a salad by adding chicken?"
	icon_state = "chickensalad"
	bitesize = 4
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/chickensalad/New()
	..()
	reagents.add_reagent(NUTRIMENT,12)

/obj/item/weapon/reagent_containers/food/snacks/grapesalad
	name = "grape salad"
	desc = "Member Kingston? Member uncapped bombs? Member beardbeard? Member Goonleak? Member the vore raid? Member split departmental access? I member!"
	icon_state = "grapesalad"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/grapesalad/New()
	..()
	reagents.add_reagent(NUTRIMENT,4)

/obj/item/weapon/reagent_containers/food/snacks/orzosalad
	name = "orzo salad"
	desc = "A minty, exotic salad originating in Space Greece. Makes you feel slippery enough to escape denbts."
	icon_state = "orzosalad"
	bitesize = 4
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/orzosalad/New()
	..()
	reagents.add_reagent(NUTRIMENT,2)
	reagents.add_reagent(LUBE,14)

/obj/item/weapon/reagent_containers/food/snacks/mexicansalad
	name = "mexican salad"
	desc = "A favorite of the janitorial staff, who often consider this a native dish. Viva Space Mexico!"
	icon_state = "mexicansalad"
	bitesize = 3
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/mexicansalad/New()
	..()
	reagents.add_reagent(NUTRIMENT,6)

/obj/item/weapon/reagent_containers/food/snacks/gazpacho
	name = "gazpacho"
	desc = "A cool, refreshing soup originating in Space Spain's desert homeworld."
	icon_state = "gazpacho"
	bitesize = 4
	crumb_icon = "dribbles"
	filling_color = "#FF3300"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/gazpacho/New()
	..()
	reagents.add_reagent(NUTRIMENT,12)
	reagents.add_reagent(FROSTOIL,6)

/obj/item/weapon/reagent_containers/food/snacks/bruschetta
	name = "bruschetta"
	desc = "This dish's name probably originates from 'to roast over coals'. You can blame the hippies for banning coal use when the crew complains it isn't authentic."
	icon_state = "bruschetta"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/bruschetta/New()
	..()
	reagents.add_reagent(NUTRIMENT,3)

/obj/item/weapon/reagent_containers/food/snacks/gelatin
	name = "gelatin"
	desc = "Made from real teeth!"
	icon_state = "gelatin"
	bitesize = 1
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/gelatin/New()
	..()
	reagents.add_reagent(NUTRIMENT,1)
	reagents.add_reagent(WATER,9)

/obj/item/weapon/reagent_containers/food/snacks/yogurt
	name = "yogurt"
	desc = "Who knew bacteria could be so helpful?"
	icon_state = "yoghurt"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/yogurt/New()
	..()
	reagents.add_reagent(NUTRIMENT,2)
	reagents.add_reagent(SUGAR,2)
	reagents.add_reagent(MILK,2)

/obj/item/weapon/reagent_containers/food/snacks/pannacotta
	name = "panna cotta"
	desc = "Among the most fashionable of fine desserts. A dish fit for a captain."
	icon_state = "pannacotta"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/pannacotta/New()
	..()
	reagents.add_reagent(SUGAR,10)
	reagents.add_reagent(OXYCODONE,2)

/obj/item/weapon/reagent_containers/food/snacks/hauntedjam
	name = "haunted jam"
	desc = "I woke up one morning to find that the entire city had been covered in a three-foot layer of man-eating jam."
	icon_state = "ghostjam"
	bitesize = 2
	base_crumb_chance = 0
	filling_color = "#D60000"

/obj/item/weapon/reagent_containers/food/snacks/hauntedjam/New()
	..()
	reagents.add_reagent(HELL_RAMEN,8) //This should be enough to at least seriously wound, if not kill, someone.

/obj/item/weapon/reagent_containers/food/snacks/hauntedjam/spook(mob/dead/observer/O)
	if(!..()) //Check that they can spook
		return
	visible_message("<span class='warning'>\The [src] rattles maliciously!</span>")
	if(loc.Adjacent(get_turf(O))) //Two reasons. First, prevent distance spooking. Second, don't move through border objects (windows)
		Move(get_turf(O))

/obj/item/weapon/reagent_containers/food/snacks/croissant
	name = "croissant"
	desc = "True French cuisine."
	icon_state = "croissant"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	base_crumb_chance = 40 // Croissants are literal crumb-making machines

/obj/item/weapon/reagent_containers/food/snacks/croissant/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poutine
	name = "poutine"
	desc = "Fries, cheese & gravy. Your arteries will hate you for this."
	icon_state = "poutine"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	plate_offset_y = -3

/obj/item/weapon/reagent_containers/food/snacks/poutine/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poutinedangerous
	name = "dangerously cheesy poutine"
	desc = "Fries, cheese, gravy & more cheese. Be careful with this, it's dangerous!"
	icon_state = "poutinedangerous"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese

/obj/item/weapon/reagent_containers/food/snacks/poutinedangerous/New()
	..()
	reagents.add_reagent(CHEESYGLOOP, 3) //need 2+ wheels to reach overdose, which will stop the heart until all is removed
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel
	name = "dangerously cheesy poutine barrel"
	desc = "Four cheese wheels full of gravy, fries and cheese curds, arranged like a barrel. This is degeneracy, Canadian style."
	icon_state = "poutinebarrel"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese

/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel/New()
	..()
	reagents.add_reagent(CHEESYGLOOP, 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/mapleleaf
	name = "maple leaf"
	desc = "A large maple leaf."
	icon_state = "mapleleaf"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/mapleleaf/New()
	..()
	reagents.add_reagent(MAPLESYRUP, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poutinesyrup
	name = "maple syrup poutine"
	desc = "French fries lathered with Canadian maple syrup and cheese curds. Delightful, eh?"
	icon_state = "poutinesyrup"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	plate_offset_y = -3

/obj/item/weapon/reagent_containers/food/snacks/poutinesyrup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(MAPLESYRUP, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bleachkipper
	name = "bleach kipper"
	desc = "Baby blue and very fishy."
	icon_state = "bleachkipper"
	food_flags = FOOD_MEAT
	volume = 1
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/bleachkipper/New()
	..()
	reagents.add_reagent(FISHBLEACH, 1)

/obj/item/weapon/reagent_containers/food/snacks/pie/mudpie
	name = "mud pie"
	desc = "While not looking very appetizing, it at least looks like somebody had fun making it."
	icon_state = "mud_pie"
	filling_color = "#462B20"

/obj/item/weapon/reagent_containers/food/snacks/pie/mudpie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, rand(0,2))
	reagents.add_reagent(TOXIN, rand(1,5))
	if(prob(15))
		name = "exceptional " + initial(name)
		desc = "The crème de la pire of culinary arts."
		reagents.add_reagent(SUGAR, 2)
		reagents.add_reagent(TOXIN, rand(3,8))
		reagents.add_reagent(COCO, 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/magbites
	name = "mag-bites"
	desc = "Tiny boot-shaped cheese puffs. Made with real magnets!\
	<br>Warning: not suitable for those with heart conditions or on medication, consult your doctor before consuming this product. Cheese dust may stain or dissolve fabrics."
	icon_state = "magbites"

/obj/item/weapon/reagent_containers/food/snacks/magbites/New()
	..()
	reagents.add_reagent(MEDCORES, 6)
	reagents.add_reagent(SODIUMCHLORIDE, 6)
	reagents.add_reagent(NUTRIMENT, 4)


/obj/item/weapon/reagent_containers/food/snacks/lasagna
	name = "lasagna"
	desc = "A carefully stacked trayful of meat, tomato, cheese, and pasta. Favorite of cats."
	icon_state = "lasagna"
	bitesize = 3
	storage_slots = 1
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/lasagna/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(TOMATOJUICE, 15)

var/global/list/bomb_like_items = list(/obj/item/device/transfer_valve, /obj/item/toy/bomb, /obj/item/weapon/c4, /obj/item/cannonball/fuse_bomb, /obj/item/weapon/grenade, /obj/item/device/onetankbomb)

/obj/item/weapon/reagent_containers/food/snacks/lasagna/can_hold(obj/item/weapon/W) //GREAT SCOTT!
	if(is_type_in_list(W, bomb_like_items))
		return TRUE
	return ..(W)

/obj/item/weapon/reagent_containers/food/snacks/tontesdepelouse/
	name = "tontes de pelouse"
	desc = "A fashionable dish that some critics say engages the aesthetic sensibilities of even the most refined gastronome."
	icon_state = "tontesdepelouse"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/tontesdepelouse/New()
	..()
	reagents.add_reagent(NUTRIMENT,1)

// fishtank stuff

/obj/item/weapon/reagent_containers/food/snacks/salmonmeat
	name = "raw salmon"
	desc = "A fillet of raw salmon."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/salmonmeat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/salmonsteak
	name = "Salmon steak"
	desc = "A piece of freshly-grilled salmon meat."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "salmonsteak"
	filling_color = "#7A3D11"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/salmonsteak/New()
	..()
	reagents.add_reagent(NUTRIMENT, 7)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/catfishmeat
	name = "raw catfish"
	desc = "A fillet of raw catfish."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/catfishmeat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/shrimp
	name = "shrimp"
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimp_raw"
	filling_color = "#FF1C1C"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/shrimp/New()
	..()
	desc = pick("Anyway, like I was sayin', shrimp is the fruit of the sea.", "You can barbecue it, boil it, broil it, bake it, saute it.")
	reagents.add_reagent(NUTRIMENT, 1)

/obj/item/weapon/reagent_containers/food/snacks/glofishmeat
	name = "raw glofish"
	desc = "A fillet of raw glofish. The bioluminescence glands have been removed."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/glofishmeat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/goldfishmeat
	name = "raw goldfish"
	desc = "A fillet of raw goldfish, the golden carp."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/goldfishmeat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fried_shrimp
	name = "fried shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimp_fried"
	food_flags = FOOD_MEAT
	base_crumb_chance = 2

/obj/item/weapon/reagent_containers/food/snacks/fried_shrimp/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp
	name = "boiled shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimp_cooked"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 3

////////	SUSHI	////////

/obj/item/weapon/reagent_containers/food/snacks/sushi
	name = "generic sushi"
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Ebi
	name = "Ebi Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Ebi

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Ebi/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Ebi
	name = "Ebi Sushi"
	desc = "A simple sushi consisting of cooked shrimp and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Ebi"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Ikura
	name = "Ikura Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Ikura

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Ikura/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Ikura
	name = "Ikura Sushi"
	desc = "A simple sushi consisting of salmon roe."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Ikura"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Sake
	name = "Sake Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Sake

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Sake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Sake
	name = "Sake Sushi"
	desc = "A simple sushi consisting of raw salmon and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Sake"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_SmokedSalmon

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_SmokedSalmon/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	desc = "A simple sushi consisting of cooked salmon and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_SmokedSalmon"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tamago
	name = "Tamago Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tamago

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tamago/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tamago
	name = "Tamago Sushi"
	desc = "A simple sushi consisting of egg and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Tamago"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Inari
	name = "Inari Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Inari

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Inari/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Inari
	name = "Inari Sushi"
	desc = "A piece of fried tofu stuffed with rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Inari"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Masago
	name = "Masago Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Masago

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Masago/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Masago  																																			/*Every night I watch the skies from inside my bunker. They'll come back. If I watch they'll come. I can hear their voices from the sky. Calling out my name. There's the ridge. The guns in the jungle. Screaming. Smoke. The blood. All over my hands. */
	name = "Masago Sushi"
	desc = "A simple sushi consisting of goldfish roe."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Masago"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tobiko
	name = "Tobiko Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tobiko

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tobiko/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tobiko
	name = "Tobiko Sushi"
	desc = "A simple sushi consisting of shark roe."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Masago"
	food_flags = FOOD_MEAT

// this is an oddball because you make it using an existing sushi piece
/obj/item/weapon/reagent_containers/food/snacks/sushi_TobikoEgg
	name = "Tobiko and Egg Sushi"
	desc = "A sushi consisting of shark roe and an egg."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_TobikoEgg"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/sushi_TobikoEgg/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tai
	name = "Tai Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tai

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Tai/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Tai
	name = "Tai Sushi"
	desc = "A simple sushi consisting of catfish and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Tai"
	bitesize = 3
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Unagi
	name = "Unagi Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Unagi

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_Unagi/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_Unagi // i have seen the face of god and it was weeping
	name = "Unagi Sushi"
	desc = "A simple sushi consisting of eel and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_Hokki"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_avocado
	name = "Avocado Sushi"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_avocado

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sushi_avocado/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)

/obj/item/weapon/reagent_containers/food/snacks/sushi/sushi_avocado
	name = "Avocado Sushi"
	desc = "A simple sushi consisting of avocado and rice."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "sushi_avocado"
	harmfultocorgis = TRUE

////	END SUSHI	////

/obj/item/weapon/reagent_containers/food/snacks/friedshrimp
	name = "fried shrimp"
	desc = "For such a little dish, it's surprisingly high calorie."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimp_fried"
	bitesize = 3
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/friedshrimp/New()
	..()
	reagents.add_reagent(CORNOIL, 3)

/obj/item/weapon/reagent_containers/food/snacks/soyscampi
	name = "soy scampi"
	desc = "A simple shrimp dish presented bathed in soy sauce."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "soyscampi"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/soyscampi/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)
	reagents.add_reagent(SOYSAUCE, 2)

/obj/item/weapon/reagent_containers/food/snacks/shrimpcocktail
	name = "shrimp cocktail"
	desc = "An hors d'oeuvre which has traditionally swung like a pendulum between the height of fashion and ironically passe."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimpcocktail"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/shrimpcocktail/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	if(prob(50))
		desc += " This one is ironic."
		reagents.add_reagent(HONKSERUM, 1)
	else
		desc += " This one is high fashion."
		reagents.add_reagent(MINTTOXIN, 1)

/obj/item/weapon/reagent_containers/food/snacks/friedcatfish
	name = "fried catfish"
	desc = "A traditional catfish fry. It's positively coated in oils."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "friedcatfish"
	bitesize = 3
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/friedcatfish/New()
	..()
	reagents.add_reagent(CORNOIL, 3)

/obj/item/weapon/reagent_containers/food/snacks/catfishgumbo
	name = "catfish gumbo"
	desc = "A traditional, thick cajun broth. Made with bottom-feeders for bottom-feeders."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "catfishgumbo"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/catfishgumbo/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)

/obj/item/weapon/reagent_containers/food/snacks/catfishcourtbouillon
	name = "catfish courtbouillon"
	desc = "A lightly breaded catfish fillet poached in a spicy hot-sauce short broth."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "catfishcourtbouillon"
	bitesize = 3
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/catfishcourtbouillon/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(CAPSAICIN, 3)

/obj/item/weapon/reagent_containers/food/snacks/smokedsalmon
	name = "smoked salmon"
	desc = "Perhaps the best known method of preparing salmon, smoking has been used to preserve fish for most of recorded history. The subtleties of avoiding overpowering the fatty, rich flavor of the salmon with the smoke make this a difficult dish to master."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "smokedsalmon"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/smokedsalmon/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)

/obj/item/weapon/reagent_containers/food/snacks/planksalmon
	name = "plank-grilled salmon"
	desc = "A simple dish that grills the flavor of wood into the meat, leaving you with a charred but workable plate in the process."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "planksalmon"
	bitesize = 3
	food_flags = FOOD_MEAT
	trash = /obj/item/stack/sheet/wood
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/planksalmon/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)

/obj/item/weapon/reagent_containers/food/snacks/citrussalmon
	name = "citrus-baked salmon"
	desc = "The piquant, almost sour flavor of the citrus fruit is baked into the fish under dry heat, to give it powerful attaque to balance its rich aftertaste."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "citrussalmon"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/citrussalmon/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)

/obj/item/weapon/reagent_containers/food/snacks/salmonavocado
	name = "salmon avocado salad"
	desc = "The creamy, buttery taste of the avocado brings unity to the nutty, meaty taste of the mushrooms and the fatty, rich taste of the salmon."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "salmonavocado"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/salmonavocado/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)

/obj/item/weapon/reagent_containers/food/snacks/rumshark
	name = "spiced rum shark supreme"
	desc = "When you really need something to get this party started. A savory dish enriched by alcohol."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "rumshark"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/rumshark/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(RUM, 15)


/obj/item/weapon/reagent_containers/food/snacks/akutaq
	name = "glofish akutaq"
	desc = "This eskimo dish literally means 'something mixed'. The fat of glowish is rendered down and mixed with milk and glowberries to make a surprisingly tasty dessert dish."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "akutaq"
	bitesize = 3
	food_flags = FOOD_MEAT | FOOD_SWEET | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/akutaq/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)
	reagents.add_reagent(SUGAR, 6)

/obj/item/weapon/reagent_containers/food/snacks/carpcurry
	name = "golden carp curry"
	desc = "A simple traditional Space Japan curry with tangy golden carp meat."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "carpcurry"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/carpcurry/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)

/obj/item/weapon/reagent_containers/food/snacks/carpconsomme
	name = "golden carp consomme"
	desc = "A clear soup made from a concentrated broth of fish and egg whites. It's light on calories and makes you feel much more cultured."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "carpconsomme"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/carpconsomme/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(METHYLIN,5)

/obj/item/weapon/reagent_containers/food/snacks/butterstick
	name = "butter on a stick"
	desc = "The clown told you to make this."
	icon_state = "butter_stick"
	bitesize = 3
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/butterstick/Crossed(atom/movable/O)
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.Slip(4, 3, slipped_on = src))
			new/obj/effect/decal/cleanable/smashed_butter(src.loc)
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/butterstick/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/ambrosia_brownies
	name = "brownie sheet"
	desc = "Give them to your friends."
	icon_state = "ambrosia_brownies"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/ambrosia_brownie
	slices_num = 6
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/ambrosia_brownies/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/ambrosia_brownie
	name = "brownie"
	desc = "A brownie that may or may not get you sky high."
	icon_state = "ambrosia_brownie"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_r
	name = "butter fingers"
	desc = "It's a microwaved hand slathered in butter!"
	icon_state = "butterfingers_r"
	food_flags = FOOD_ANIMAL | FOOD_MEAT
	plate_offset_y = -3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_r/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_r/Crossed(atom/movable/O)
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		C.Slip(4, 3, slipped_on = src)

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_l
	name = "butter fingers"
	desc = "It's a microwaved hand slathered in butter!"
	icon_state = "butterfingers_l"
	food_flags = FOOD_ANIMAL | FOOD_MEAT
	plate_offset_y = -3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_l/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_l/Crossed(atom/movable/O)
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		C.Slip(4, 3, slipped_on = src)

/obj/item/weapon/reagent_containers/food/snacks/butteredtoast
	name = "buttered toast"
	desc = "Toasted bread with butter on it."
	icon_state = "butteredtoast"
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/butteredtoast/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)

/obj/item/weapon/reagent_containers/food/snacks/pierogi
	name = "pierogi"
	desc = "Dumplings with potatoes and curd inside."
	icon_state = "pierogi"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/pierogi/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)


/obj/item/weapon/reagent_containers/food/snacks/sauerkraut
	name = "sauerkraut"
	desc = "Cabbage that has fermented in salty brine."
	icon_state = "sauerkraut"
	trash = /obj/item/trash/snack_bowl
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sauerkraut/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)

/obj/item/weapon/reagent_containers/food/snacks/pickledpears
	name = "pickled pears"
	desc = "A jar filled with pickled pears."
	icon_state = "pickledpears"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/pickledpears/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/pickledbeets
	name = "pickled beets"
	desc = "A jar of pickled whitebeets. How did they become so red, then?"
	icon_state = "pickledbeets"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/pickledbeets/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/bulgogi
	name = "bulgogi"
	desc = "Thin grilled beef marinated with grated pear juice."
	icon_state = "bulgogi"
	food_flags = FOOD_SWEET | FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/bulgogi/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/candiedpear
	name = "candied pear"
	desc = "A pear covered with caramel. Quite sugary."
	icon_state = "candiedpear"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/candiedpear/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bakedpears
	name = "baked pears"
	desc = "Baked pears cooked with cinnamon, sugar and some cream."
	icon_state = "bakedpears"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/bakedpears/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/winepear
	name = "wine pear"
	desc = "This pear has been laced with wine, some cinnamon and a touch of cream."
	icon_state = "winepear"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/winepear/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/suppermatter
	name = "suppermatter"
	desc = "Extremely dense and powerful food."
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/suppermattershard
	storage_slots = 1
	slices_num = 4
	icon_state = "suppermatter"
	w_class = W_CLASS_MEDIUM
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sliceable/suppermatter/New()
	..()
	reagents.add_reagent(NUTRIMENT, 48)
	bitesize = 12
	set_light(1.4,2,"#FFFF00")

/obj/item/weapon/reagent_containers/food/snacks/suppermattershard
	name = "suppermatter shard"
	desc = "A single portion of power."
	icon_state = "suppermattershard"
	bitesize = 3
	trash = null
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/suppermattershard/New()
	..()
	set_light(1.4,1.4,"#FFFF00")

/obj/item/weapon/reagent_containers/food/snacks/sliceable/excitingsuppermatter
	name = "exciting suppermatter"
	desc = "Extremely dense, powerful and exciting food!"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/excitingsuppermattershard
	storage_slots = 1
	slices_num = 5
	icon_state = "excitingsuppermatter"
	w_class = W_CLASS_MEDIUM
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/sliceable/excitingsuppermatter/New()
	..()
	reagents.add_reagent(NUTRIMENT, 60)
	bitesize = 12
	set_light(1.4,2,"#FF0000")

/obj/item/weapon/reagent_containers/food/snacks/excitingsuppermattershard
	name = "exciting suppermatter shard"
	desc = "A single portion of exciting power!"
	icon_state = "excitingsuppermattershard"
	bitesize = 3
	trash = null
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/excitingsuppermattershard/New()
	..()
	set_light(1.4,1.4,"#FF0000")

/obj/item/weapon/reagent_containers/food/snacks/grapejelly
	name = "jelly"
	desc = "The choice of choosy moms."
	icon = 'icons/obj/food2.dmi'
	icon_state = "grapejelly"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/grapejelly/New()
	..()
	reagents.add_reagent (NUTRIMENT, 2)
	reagents.add_reagent (SUGAR, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/peanutbutter
	name = "peanut butter"
	desc = "A jar of smashed peanuts, contains no actual butter."
	icon = 'icons/obj/food2.dmi'
	icon_state = "peanutbutter"
	base_crumb_chance = 0
	harmfultocorgis = TRUE

/obj/item/weapon/reagent_containers/food/snacks/peanutbutter/New()
	..()
	reagents.add_reagent (NUTRIMENT, 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/saltednuts
	name = "salted peanuts"
	desc = "Popular in saloons."
	icon = 'icons/obj/food2.dmi'
	icon_state = "saltednuts"
	base_crumb_chance = 0
	harmfultocorgis = TRUE

/obj/item/weapon/reagent_containers/food/snacks/saltednuts/New()
	..()
	reagents.add_reagent (NUTRIMENT, 2)
	reagents.add_reagent (SODIUMCHLORIDE, 2)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/pbj
	name = "peanut butter and jelly sandwich"
	desc = "A classic treat of childhood."
	icon = 'icons/obj/food2.dmi'
	icon_state = "pbj"
	base_crumb_chance = 0
	harmfultocorgis = TRUE

/obj/item/weapon/reagent_containers/food/snacks/pbj/New()
	..()
	reagents.add_reagent (NUTRIMENT, 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/PAIcookie
	name = "cookie"
	desc = "Oh god, it's self-replicating!"
	icon = 'icons/obj/food2.dmi'
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/PAIcookie/New()
	..()
	icon_state = "paicookie[pick(1,2,3)]"
	reagents.add_reagent(NUTRIMENT,5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/breadslice/paibread
	icon = 'icons/obj/food2.dmi'
	icon_state = "paitoast"
	trash = 0
	desc = "A slice of bread. Browned onto it is the image of a familiar friend."
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/breadslice/paibread/New()
	..()
	reagents.add_reagent(NUTRIMENT,5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/breadslice/paibread/attackby(obj/item/I,mob/user,params)
	return ..() //sorry no custom pai sandwiches

/obj/item/weapon/reagent_containers/food/snacks/escargot
	icon_state = "escargot"
	name = "cooked escargot"
	desc = "A fine treat and an exquisite cuisine."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	bitesize = 1
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/escargot/New()
	. = ..()
	reagents.add_reagent(NUTRIMENT,10)
	reagents.add_reagent(SODIUMCHLORIDE, 2)
	reagents.add_reagent(HOLYWATER, 2)

/obj/item/weapon/reagent_containers/food/snacks/es_cargo
	icon_state = "es_cargo_closed"
	name = "es-cargo"
	desc = "Je-ne-veux-pas-travailler!"
	bitesize = 1
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	var/open = FALSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/es_cargo/New()
	. = ..()
	reagents.add_reagent(NUTRIMENT,10)
	reagents.add_reagent(SODIUMCHLORIDE, 2)
	reagents.add_reagent(HOLYWATER, 2)

/obj/item/weapon/reagent_containers/food/snacks/es_cargo/can_consume(mob/living/carbon/eater, mob/user)
	if (!open)
		visible_message("<span class='notice'>\The [eater] cannot eat from \the [src] if it's closed, imbecile!</span>","<span class='notice'>You must first open it!</span>", drugged_message = "<span class='danger'>Oh lalala, this is not it, not it at all !</span>")
		return FALSE
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/es_cargo/attack_self(var/mob/user)
	if (!open)
		open = TRUE
		icon_state = "es_cargo_opened"
		visible_message("<span class='notice'>\The [user] opens \the [src]!</span>", drugged_message = "<span class='notice'>This smells très bon !</span>")
		return
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/es_cargo/verb/toggle_open()
	set name = "Toggle open"
	set category = "Object"
	if (!open)
		open = TRUE
		icon_state = "es_cargo_opened"
		visible_message("<span class='notice'>\The [usr] opens \the [src]!</span>", drugged_message = "<span class='notice'>This smells très bon !</span>")
	else
		open = FALSE
		icon_state = "es_cargo_closed"
		visible_message("<span class='notice'>\The [usr] closes \the [src]!</span>", drugged_message = "<span class='notice'>Enough for today !</span>")

/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_tail
	name = "Raw Lobster Tail"
	desc = "The tail of a lobster, raw and uncooked."
	icon = 'icons/obj/food.dmi'
	icon_state = "raw_lobster_tail"
	bitesize = 1 //your eating a raw lobster tail, shell still attatched, you disgusting animal
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_tail/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)

/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat
	name = "Raw Lobster Meat"
	desc = "The delicious meat of a lobster. An impossible amount of suffering was inflicted to get this."
	icon = 'icons/obj/food.dmi'
	icon_state = "raw_lobster_meat"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)


/obj/item/weapon/reagent_containers/food/snacks/steamed_lobster_deluxe
	name = "Steamed Lobster"
	desc = "A steamed lobster, served with a side of melted butter and a slice of lemon. You can still feel its hatred"
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_steamed_deluxe"
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/plate
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/steamed_lobster_deluxe/New()
	..()
	reagents.add_reagent (NUTRIMENT, 6)
	reagents.add_reagent (LEMONJUICE, 1)
	reagents.add_reagent (LIQUIDBUTTER, 3)
	bitesize = 2 //lobster takes a long time to eat

/obj/item/weapon/reagent_containers/food/snacks/steamed_lobster_simple  // this one has no fancy butter or lemon
	name = "Steamed Lobster"
	desc = "A steamed lobster, served with no sides. Eat up, you barbarian."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_steamed_simple"
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/plate
	base_crumb_chance = 0


/obj/item/weapon/reagent_containers/food/snacks/steamed_lobster_simple/New()
	..()
	reagents.add_reagent (NUTRIMENT, 6)
	bitesize = 2 //lobster takes a long time to eat


/obj/item/weapon/reagent_containers/food/snacks/lobster_roll
	name = "Lobster Roll"
	desc = "A mishmash of mayo and lobster meat shoved onto a roll to make a lobster hot dog."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_roll" //it dont need trash, its a hot dog, lobster edition
	food_flags = FOOD_MEAT


/obj/item/weapon/reagent_containers/food/snacks/lobster_roll/New()
	..()
	reagents.add_reagent (NUTRIMENT, 1)
	reagents.add_reagent (MAYO, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/lobster_roll_butter  // instead of mayo it uses butter
	name = "Lobster Roll"
	desc = "A glob of lobster meat drenched in butter."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_roll" //it dont need trash, its a hot dog, lobster edition
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/lobster_roll_butter/New()
	..()
	reagents.add_reagent (NUTRIMENT, 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/lobster_tail_baked
	name = "Baked Lobster Tail"
	desc = "A Lobster tail, drenched in butter and a bit of lemon, you monster."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_tail_baked"
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/plate
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/lobster_tail_baked/New()
	..()
	reagents.add_reagent (NUTRIMENT, 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/lobster_dumplings
	name = "Lobster Dumplings"
	desc = "A mass of claw meat wrapped in dough."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_dumplings"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/lobster_dumplings/New()
	..()
	reagents.add_reagent (NUTRIMENT, 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/lobster_sushi
	name = "Lobster Dumplings"
	desc = "Lobster meat wrapped up with rice."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_sushi"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/lobster_sushi/New()
	..()
	reagents.add_reagent (NUTRIMENT, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sweetroll
	name = "sweetroll"
	desc = "While on the station, the chef gives you a sweetroll. Delighted, you take it into maintenance to enjoy, only to be intercepted by a gang of three assistants your age."
	icon = 'icons/obj/food.dmi'
	icon_state = "sweetroll"
	food_flags = FOOD_ANIMAL | FOOD_SWEET | FOOD_LACTOSE | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/sweetroll/New()
	..()
	reagents.add_reagent (NUTRIMENT, 2)
	reagents.add_reagent (SUGAR, 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/dorfbiscuit
	name = "special plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. Aside from the usual ingredients of minced plump helmet and well-minced dwarven wheat flour, this particular serving includes a chemical that sticks whoever eats it to the floor, much like magboots."
	icon_state = "phelmbiscuit"
	bitesize = 1
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/dorfbiscuit/New()
	..()
	reagents.add_reagent(SOFTCORES, 3)
	reagents.add_reagent(NUTRIMENT, 5)

//You have now entered the ayy food zone

/obj/item/weapon/zambiscuit_package
	name = "Zam Biscuit Package"
	desc = "A package of Zam biscuits, popular fare for hungry grey laborers. They go perfectly with a cup of Earl's Grey tea. "
	icon = 'icons/obj/food_container.dmi'
	icon_state = "zambiscuitbox"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	item_state = "zambiscuitbox"
	w_class = W_CLASS_SMALL

/obj/item/weapon/zambiscuit_package/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You start to tear open the biscuit package's seal.</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', 100, 1)
	if(do_after(user, src, 2 SECONDS))
		qdel(src)
		var/obj/item/weapon/storage/fancy/zam_biscuits/new_zam = new /obj/item/weapon/storage/fancy/zam_biscuits
		user.put_in_hands(new_zam)

/obj/item/weapon/storage/fancy/zam_biscuits
	icon = 'icons/obj/food_container.dmi'
	icon_state = "zambiscuitbox3"
	icon_type = "zambiscuit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	item_state = "zambiscuitbox"
	name = "Zam Biscuit Package"
	desc = "A package of Zam biscuits, popular fare for hungry grey laborers. They go perfectly with a cup of Earl's Grey tea. "
	storage_slots = 3
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks/zambiscuit","/obj/item/weapon/reagent_containers/food/snacks/zambiscuit_radical")

	w_class = W_CLASS_SMALL

/obj/item/weapon/storage/fancy/zam_biscuits/empty
	empty = 1
	icon_state = "zambiscuitbox0"

/obj/item/weapon/storage/fancy/zam_biscuits/New()
	..()
	if(empty)
		update_icon() //Make it look actually empty
		return
	for(var/i = 1; i <= storage_slots; i++)
		new /obj/item/weapon/reagent_containers/food/snacks/zambiscuit(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/zamdinnerclassic
	name = "Classic Steak and Nettles"
	icon_state	= "box_tvdinnerclassic"
	desc = "An old Zam dinner box! This one still has the mascot on it. The instructions say to microwave before eating."
	food_flags = FOOD_MEAT
	w_class = W_CLASS_MEDIUM
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/zamdinnerclassic/New()
	..()
	reagents.add_reagent(NUTRIMENT, 7)
	reagents.add_reagent(SACID, 4)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/greytvdinnerclassic
	name = "Classic Steak and Nettles"
	desc = "The original Zam steak and nettles. They don't make it like they used to..."
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_1"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/greytvdinnerclassic/New()
	..()
	reagents.add_reagent(NUTRIMENT, 11)
	reagents.add_reagent(DOCTORSDELIGHT, 5)
	reagents.add_reagent(SACID, 4)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1
	name = "Zam Steak and Nettles"
	desc = "The Zam research division still doesn't know where the steak's grill marks come from."
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_1"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1/New()
	..()
	reagents.add_reagent(NUTRIMENT, 18)
	reagents.add_reagent(SACID, 8)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1/wrapped
	name = "Zam Steak and Nettles"
	icon_state	= "box_tvdinner1"
	desc = "A packaged acidic ready-to-eat meal from the grey food company Zam Snax."
	w_class = W_CLASS_MEDIUM
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1/proc/Unwrap(mob/user)
	desc = "The Zam research division still doesn't know where the steak's grill marks come from."
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_1"
	to_chat(user, "<span class='notice'>You tear the packaging open and hear a nice hiss.") // Couldn't resist
	base_crumb_chance = 0
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2
	name = "Zam Mothership Stew"
	icon_state	= "tvdinner_2"
	desc = "This packaged version isn't quite as scrumptious as home cooking on the mothership, but it's palatable."
	trash = /obj/item/trash/used_tray
	base_crumb_chance = 0
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2/New()
	..()
	reagents.add_reagent(NUTRIMENT, 15)
	reagents.add_reagent(SACID, 7)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2/wrapped
	name = "Zam Mothership Stew"
	icon_state	= "box_tvdinner2"
	desc = "A packaged acidic ready-to-eat meal from the grey food company Zam Snax."
	w_class = W_CLASS_MEDIUM
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2/proc/Unwrap(mob/user)
	desc = "This packaged version isn't quite as scrumptious as home cooking on the mothership, but it's palatable."
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_2"
	to_chat(user, "<span class='notice'>You tear the packaging open and hear a little hiss.")
	base_crumb_chance = 0
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3
	name = "Zam Spider Slider Delight"
	icon_state	= "tvdinner_3"
	desc = "Despite extensive processing, there's definitely at least one spider hair still in it."
	trash = /obj/item/trash/used_tray
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3/New()
	..()
	reagents.add_reagent(NUTRIMENT, 12)
	reagents.add_reagent(SACID, 6)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3/wrapped
	name = "Zam Spider Slider Delight"
	icon_state	= "box_tvdinner3"
	desc = "A packaged acidic ready-to-eat meal from the grey food company Zam Snax."
	w_class = W_CLASS_MEDIUM
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3/proc/Unwrap(mob/user)
	desc = "Despite extensive processing, there's definitely at least one spider hair still in it."
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_3"
	to_chat(user, "<span class='notice'>You tear the packaging open.") // No hiss...
	base_crumb_chance = 0
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/greygreens
	name = "Grey Greens"
	desc = "A dish beloved by greys since first contact, acidic vegetables seasoned with soy sauce."
	trash = /obj/item/trash/used_tray/type2
	icon_state = "greygreens"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/greygreens/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(SOYSAUCE, 10)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stuffedpitcher
	name = "Stuffed Pitcher"
	desc = "A delicious grey alternative to a stuffed pepper. Very acidic."
	trash = /obj/item/trash/used_tray/type2
	icon_state = "stuffedpitcher"
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/stuffedpitcher/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/nymphsperil
	name = "Nymph's Peril"
	desc = "A diona nymph steamed in sulphuric acid then stuffed with fried rice. Ruthlessly delicious!"
	trash = /obj/item/trash/used_tray/type2
	icon_state = "yahireatsbugs"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/nymphsperil/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	reagents.add_reagent(SACID, 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/zambiscuit
	name = "Zam Biscuit"
	desc = "A sweet biscuit with an exquisite blend of chocolate and acid flavors. The recipe is a mothership secret."
	icon_state = "zambiscuit"
	food_flags = FOOD_SWEET | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/zambiscuit/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(HYRONALIN, 3)
	reagents.add_reagent(COCO, 2)
	reagents.add_reagent(SUGAR, 2)
	reagents.add_reagent(SACID, 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/zambiscuit_butter
	name = "Zam Buttery Biscuit"
	desc = "Butter and acid blend together to make a divine biscuit flavor. Administrator Zam's favorite!"
	icon_state = "zambiscuit_buttery"
	food_flags = FOOD_ANIMAL | FOOD_SWEET | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/zambiscuit_butter/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(HYRONALIN, 3)
	reagents.add_reagent(LIQUIDBUTTER, 2)
	reagents.add_reagent(SUGAR, 2)
	reagents.add_reagent(SACID, 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/zambiscuit_radical
	name = "Zam Radical Biscuit"
	desc = "This Zam biscuit is oddly warm to the touch and glows faintly. It's probably not safe for consumption..." // Despite the warning, I'm sure someone will eat it.
	icon_state = "zambiscuit_radical"
	food_flags = FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/zambiscuit_radical/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(MUTAGEN, 4)
	reagents.add_reagent(URANIUM, 3)
	reagents.add_reagent(SACID, 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/zam_notraisins
	name = "Zam NotRaisins"
	desc = "Dried blecher berries! A minimally processed bitter treat from the mothership's hydroponics labs." // Hopefully one day blecher berries will be a real thing in the code.
	trash = /obj/item/trash/zam_notraisins
	icon_state = "zam_notraisins"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/zam_notraisins/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese
	name = "Zam Moon Cheese"
	desc = "It gives off an artificial and bitter smell, but tastes much like a normal piece of sharp cheddar."
	food_flags = FOOD_ANIMAL
	icon_state = "zam_mooncheese"
	wrapped = 0
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(MOONROCKS, 2)

/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/wrapped
	name = "Zam Moon Cheese"
	desc = "Unfortunately the moon is not made of cheese, but this tasty snack is!"
	icon_state = "zam_mooncheese_wrapped"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/proc/Unwrap(mob/user)
	desc = "It gives off an artificial and bitter smell, but tastes much like a normal piece of sharp cheddar."
	food_flags = FOOD_ANIMAL
	icon_state = "zam_mooncheese"
	to_chat(user, "<span class='notice'>You peel the wrapping off the cheese.")
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider
	name = "Zam Spider Slider"
	desc = "A moderately processed acidic spider slider. Nutriment dense, despite its tiny size."
	food_flags = FOOD_MEAT
	icon_state = "zam_spiderslider"
	wrapped = 0
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(SACID, 3)

/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/wrapped
	name = "Zam Spider Slider"
	desc = "A self-heating acidic slider for grey laborers on salaries too humble to afford the full meal."
	icon_state = "zam_spiderslider_wrapped"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
		spawn()
			new /obj/item/trash/zam_sliderwrapper(get_turf(src))
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/proc/Unwrap(mob/user)
	desc = "A moderately processed acidic spider slider. Nutriment dense, despite its tiny size."
	food_flags = FOOD_MEAT
	icon_state = "zam_spiderslider"
	to_chat(user, "<span class='notice'>You tear the tab open and remove the slider from the packaging. Despite supposedly being self-heating, it's barely warm.")
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/mothershipbroth
	name = "Mothership Broth"
	desc = "A simple dish of mothership broth. Soothing, but not very nourishing. Could use more spice..."
	icon_state = "mothershipbroth"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#B38B26"
	valid_utensils = UTENSILE_SPOON
	var/abductionchance = 10

/obj/item/weapon/reagent_containers/food/snacks/mothershipbroth/New()
	..()
	reagents.clear_reagents()
	if(prob(abductionchance))
		name = "Abducted Mothership Broth"
		desc = "An unidentified microwave object has abducted your broth and made it slightly more nutritious!"
		icon_state = "mothershipbroth_ufo"
		trash = /obj/item/trash/emptybowl_ufo
		reagents.add_reagent(NUTRIMENT, 4)
		reagents.add_reagent(ZAMMILD, 5)
		bitesize = 2
	else
		reagents.add_reagent(NUTRIMENT, 2)
		reagents.add_reagent(ZAMMILD, 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mothershipbroth/abducted
	abductionchance = 100

/obj/item/weapon/reagent_containers/food/snacks/mothershipbroth_spicy
	name = "Mothership Spicy Broth"
	desc = "A simple dish of mothership broth. Soothing, but not very nourishing. At least it's spicy."
	icon_state = "mothershipbroth_spicy"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#D35A0D"
	valid_utensils = UTENSILE_SPOON
	var/abductionchance = 10

/obj/item/weapon/reagent_containers/food/snacks/mothershipbroth_spicy/New()
	..()
	reagents.clear_reagents()
	if(prob(abductionchance))
		name = "Abducted Mothership Spicy Broth"
		desc = "An unidentified microwave object has abducted your broth and made it slightly more nutritious!"
		icon_state = "mothershipbroth_spicyufo"
		trash = /obj/item/trash/emptybowl_ufo
		reagents.add_reagent(NUTRIMENT, 5)
		reagents.add_reagent(ZAMSPICYTOXIN, 5)
		bitesize = 2
	else
		reagents.add_reagent(NUTRIMENT, 3)
		reagents.add_reagent(ZAMSPICYTOXIN, 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mothershipbroth_spicy/abducted
	abductionchance = 100

/obj/item/weapon/reagent_containers/food/snacks/cheesybroth
	name = "Mothership Cheesy Broth"
	desc = "Traditional mothership broth with some cheese melted into it. Pairs well with a slice of gingi bread."
	icon_state = "cheesybroth"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_ANIMAL | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#FFEB3B"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/cheesybroth/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(ZAMMILD, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/swimmingcarp
	name = "Swimming Carp"
	desc = "A simple soup of tender carp meat cooked in mothership broth. Soothing and nourishing, but could use a little more spice."
	icon_state = "swimmingcarp"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_MEAT | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#B38B26"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/swimmingcarp/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(ZAMMILD, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/swimmingcarp_spicy
	name = "Spicy Swimming Carp"
	desc = "A soup of tender carp meat cooked in spicy mothership broth. Soothing, nourishing, and perfectly spicy."
	icon_state = "swimmingcarp_spicy"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_MEAT | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#D35A0D"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/swimmingcarp_spicy/New()
	..()
	reagents.add_reagent(NUTRIMENT, 9)
	reagents.add_reagent(ZAMSPICYTOXIN, 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup
	name = "Blether Noodle Soup"
	desc = "A hearty grey noodle soup. Great for teaching growing greylings new words! Not to be confused with human alphabet soup."
	icon_state = "blethernoodlesoup_open"
	trash = /obj/item/weapon/reagent_containers/glass/soupcan
	food_flags = FOOD_MEAT | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#FF9700"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	bitesize = 3
	wrapped = FALSE

/obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup/wrapped
	icon_state = "blethernoodlesoup_closed"
	wrapped = TRUE

/obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup/proc/Unwrap(mob/user)
	icon_state = "blethernoodlesoup_open"
	wrapped = FALSE
	playsound(user, 'sound/effects/can_open1.ogg', 50, 1)
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(SACID, 10)
	reagents.add_reagent(LOCUTOGEN, 5)
	if(user)
		to_chat(user, "<span class='notice'>You pull the tab on the soup can and pop the lid open. An inviting smell wafts out.")

/obj/item/weapon/reagent_containers/food/snacks/polyppudding
	name = "Polyp Pudding"
	desc = "A thick and sweet pudding, guaranteed to remind a mothership grey of their childhood whimsy."
	icon_state = "polyppudding"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_LIQUID | FOOD_SWEET | FOOD_ANIMAL
	crumb_icon = "dribbles"
	filling_color = "#00FFFF"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/polyppudding/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(POLYPGELATIN, 5)
	bitesize = 3

//You have now exited the ayy food zone. Thanks for visiting.

/obj/item/weapon/reagent_containers/food/snacks/dionaroast
	name = "Diona Roast"
	desc = "A slow cooked diona nymph. Very nutritious, and surprisingly tasty!"
	icon_state = "dionaroast"
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/dionaroast/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	reagents.add_reagent(BLACKPEPPER, 1)
	reagents.add_reagent(SODIUMCHLORIDE, 1)
	reagents.add_reagent(CORNOIL, 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge_scraps
	name = "half-eaten cheese wedge"
	desc = "Looks like someone already got to this one, but there's still quite a bit of cheese left."
	icon_state = "halfeaten_wedge"
	filling_color = "#FFCC33"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge_scraps/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/skitter/ //if ye dish is a child of skitter it will move around after 30 ticks
	name = "skittering burger"
	desc = "A burger-shaped cockroach."
	icon_state = "bugburger"
	var/skitterdelay = 30
	var/skitterchance = 50

/obj/item/weapon/reagent_containers/food/snacks/skitter/New()
	..()
	processing_objects += src

/obj/item/weapon/reagent_containers/food/snacks/skitter/pickup(mob/user)
	timer = 0

/obj/item/weapon/reagent_containers/food/snacks/skitter/process()
	timer += 1
	if(timer > skitterdelay && istype(loc, /turf) && prob(skitterchance))
		Move(get_step(loc, pick(cardinal)))

/obj/item/weapon/reagent_containers/food/snacks/skitter/Destroy()
	processing_objects -= src
	..()

////////////////////////////////
// YE ENTERING THE GUNK ZONE ///
///////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger
	name = "gunk burger"
	desc = "A GunkCo classic! You will eat the bugs and you will enjoy them."
	icon_state = "bugburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 6)
	reagents.add_reagent(ROACHSHELL, 5)
	if(prob(30))
		reagents.add_reagent(SALTWATER, 3) //the best non-karm emetic we have
		desc = "Legs wriggling, bug juices oozing out and that rotten smell... Oh god, you're gonna THR-"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/skitter/deluxegunkburger
	name = "deluxe gunk burger"
	desc = "GunkCo's latest innovation! You won't guess the special ingredient!"
	icon_state = "deluxebugburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20

/obj/item/weapon/reagent_containers/food/snacks/skitter/deluxegunkburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 12)
	reagents.add_reagent(ROACHSHELL, 10)
	if(prob(30))
		reagents.add_reagent(SALTWATER, 3)
		desc = "You can't comprehend how much I regret biting into this thing. The disgusting texture, burning juices and terrible taste will never leave my mind."
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/skitter/supergunkburger
	name = "Super Gunk Burger"
	desc = "The Cockroach King! Or matriarch actually. You can't even fathom eating that much cockroach."
	icon_state = "supergunkburger"
	food_flags = FOOD_MEAT | FOOD_LACTOSE | FOOD_ANIMAL
	base_crumb_chance = 20
	skitterchance = 40
	skitterdelay = 60 //takes longer for super gunkburgers to walk and they walk less, muh weight or something

/obj/item/weapon/reagent_containers/food/snacks/skitter/supergunkburger/New()
	..()
	reagents.add_reagent(NUTRIMENT, 40)
	reagents.add_reagent(ROACHSHELL, 15)
	if(prob(30))
		reagents.add_reagent(SALTWATER, 3)
		desc = "I have tasted upon all the universe has to hold of gunk, and even the ambrosias and blingpizzas must ever afterward be poison to me."
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/gunkkabob
	name = "Gunk-kabob"
	icon_state = "bugkabob"
	desc = "Not as disgusting as you'd expect!"
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/gunkkabob/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(ROACHSHELL, 5)
	reagents.add_reagent(SALINE, 0.5) //just a taste
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/popcorn/cricket
	name = "hopcorn"
	desc = "Surprisingly crunchy!"
	icon_state = "hoppers"
	trash = /obj/item/trash/popcorn/hoppers
	filling_color = "#610000"

/obj/item/weapon/reagent_containers/food/snacks/popcorn/cricket/after_consume()
	if(prob(unpopped))
		to_chat(usr, "<span class='warning'>Just as you were going to bite down on the cricket, it jumps away from your hand. It was alive!</span>")
		unpopped = max(0, unpopped-3) //max 3 crickets per bag
		new /mob/living/simple_animal/cricket(get_turf(src))

/obj/item/weapon/reagent_containers/food/snacks/popcorn/roachsalad
	name = "cockroach salad"
	desc = "You're gonna be sick..."
	icon_state = "cockroachsalad"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT
	random_filling_colors = list("#610000", "#32AE32")
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/roachsalad/after_consume()
	if(prob(unpopped))
		to_chat(usr, "<span class='warning'>A cockroach wriggles out of the bowl!</span>")
		unpopped = max(0, unpopped-3) //max 3 roaches per roach salad
		new /mob/living/simple_animal/cockroach(get_turf(src))

/obj/item/weapon/reagent_containers/food/snacks/gunksoup
	name = "Gunk Soup"
	desc = "Smells like a garbage can."
	icon_state = "gunksoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#6D4930"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/gunksoup/New()
	..()
	reagents.add_reagent(NUTRIMENT, 8)
	reagents.add_reagent(ROACHSHELL, 5)
	reagents.add_reagent(WATER, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/gunksoupembassy
	name = "Gunk Soup Embassy"
	desc = "Space Turkey's finest politicians are sent to this elite GunkCo facility."
	icon_state = "gunksoup_embassy_2" //here so it isn't invisible on nofruit pie rolls, gets overwritten on new()
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#6D4930"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/gunksoupembassy/New()
	..()
	if(prob(50))  //two flag waving styles
		icon_state = "gunksoup_embassy_1"
	else
		icon_state = "gunksoup_embassy_2"
	processing_objects += src
	reagents.add_reagent(NUTRIMENT, 10) //we lobbied for extra nutriment for you!
	reagents.add_reagent(ROACHSHELL, 8) //no roaches were harmed this time, it's all exoskeleton flakes
	reagents.add_reagent(WATER, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/gunksoupembassy/process()
	timer += 1
	if(prob(20) && timer >= 10)
		timer = 0
		if(prob(50))
			icon_state = "gunksoup_embassy_1"
		else
			icon_state = "gunksoup_embassy_2"

/obj/item/weapon/reagent_containers/food/snacks/gunksoupembassy/Destroy()
	processing_objects -= src
	new /mob/living/simple_animal/cockroach/turkish(get_turf(src))
	new /mob/living/simple_animal/cockroach/turkish(get_turf(src))
	..()

/obj/item/weapon/reagent_containers/food/snacks/sliceable/gunkbread
	name = "gunkbread loaf"
	desc = "At some point you have to wonder not if you COULD make bread with garbage, but rather if you SHOULD."
	icon_state = "gunkbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/gunkbreadslice
	slices_num = 5
	storage_slots = 3
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/reagent_containers/food/snacks/sliceable/gunkbread/New()
	..()
	reagents.add_reagent(NUTRIMENT, 30)
	reagents.add_reagent(ROACHSHELL, 5)
	reagents.add_reagent(CHEMICAL_WASTE, 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/gunkbreadslice
	name = "gunkbread slice"
	desc = "Ahh, the smell of the maintenance hallways in bread form."
	icon_state = "gunkbreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -4

/obj/item/weapon/reagent_containers/food/snacks/pie/gunkpie
	name = "gunk pie"
	desc = "Surprisingly free of toxins!"
	icon_state = "gunkpie"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/pie/gunk_pie/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(ROACHSHELL, 5)
	if(prob(30))
		reagents.add_reagent(CHEMICAL_WASTE, 5)
		reagents.add_reagent(SALINE, 1)
		desc = "The flavour of the maintenance halls in pie form."
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sliceable/gunkcake
	name = "gunk cake"
	desc = "The apex of garbage-based confectionary research."
	icon_state = "gunkcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/gunkcakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/gunkcake/New()
	..()
	reagents.add_reagent(NUTRIMENT, 25)
	reagents.add_reagent(ROACHSHELL, 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/gunkcakeslice
	name = "gunk cake slice"
	desc = "Your nose hairs recoil at the fumes coming out of this."
	icon_state = "gunkcakeslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1

/obj/item/weapon/reagent_containers/food/snacks/roachesonstick
	name = "Roaches on a stick"
	desc = "Literally two roaches a stick, man. Don't know what you were expecting."
	icon_state = "roachesonastick"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/roachesonstick/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(ROACHSHELL, 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/grandpatiks
	name = "Grandpa Tik's Roasted 'Peanuts'"
	icon_state = "nutsnbugs"
	desc = "The unborn children of the insectoid colonies; processed, treated and mixed with love (and nuts!) for your enjoyment."
	base_crumb_chance = 30
	valid_utensils = 0
	base_crumb_chance = 0
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/grandpatiks/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(ROACHSHELL, 1)

/obj/item/weapon/reagent_containers/food/snacks/multispawner/saltcube
	name = "salt cubes"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/saltcube
	child_volume = 3

/obj/item/weapon/reagent_containers/food/snacks/multispawner/saltcube/New()
	..()
	reagents.add_reagent(SODIUMCHLORIDE, 15) //spawns 5

/obj/item/weapon/reagent_containers/food/snacks/saltcube
	name = "salt cubes"
	desc = "You wish you had a salt rhombicosidodecahedron, but a cube will do."
	icon_state = "sugarsaltcube"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sugarcube
	name = "sugar cube"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sugarcube
	child_volume = 3

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sugarcube/New()
	..()
	reagents.add_reagent(SUGAR, 15) //spawns 5

/obj/item/weapon/reagent_containers/food/snacks/sugarcube
	name = "sugar cube"
	desc = "The superior sugar delivery method. How will sugar sphere babies ever compare?"
	icon_state = "sugarsaltcube"
	bitesize = 3
