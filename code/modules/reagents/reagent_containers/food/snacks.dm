//Food items that are eaten normally and don't leave anything behind.
#define ANIMALBITECOUNT 4


/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon_state = null
	log_reagents = 1
	autoignition_temperature = AUTOIGNITION_ORGANIC

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
	update_blood_overlay()//re-applying blood stains
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
				"<span class='userdanger'>[user] attempts to feed you \the [src].</span>")
			else //The mob is overfed and will refuse
				target.visible_message("<span class='danger'>[user] cannot force anymore of \the [src] down [target]'s throat!</span>", \
				"<span class='userdanger'>[user] cannot force anymore of \the [src] down your throat!</span>")
				return 0

			if(!do_mob(user, target))
				return

			if(!can_consume(target, user))
				return

			add_logs(user, target, "fed", object="[reagentlist(src)]")
			target.visible_message("<span class='danger'>[user] feeds [target] \the [src].</span>", \
			"<span class='userdanger'>[user] feeds you \the [src].</span>")

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
				var/obj/item/weapon/reagent_containers/food/snacks/slice = new slice_path(src.loc)
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
			to_chat(user, "<span class='warning'>\the [src] is already too full to fit \the [W].</span>")
			return 0

		if(user.drop_item(W, src))
			to_chat(user, "<span class='notice'>You slip \the [W] inside [src].</span>")

		add_fingerprint(user)
		contents += W
		return 1 //No afterattack here

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
///obj/item/weapon/reagent_containers/food/snacks/burger/xeno			//Identification path for the object.
//	name = "Xenoburger"													//Name that displays in the UI.
//	desc = "Smells caustic. Tastes like heresy."						//Duh
//	icon_state = "xburger"												//Refers to an icon in food.dmi
//	food_flags = FOOD_MEAT												//For flavour, not that important. Flags are: FOOD_MEAT, FOOD_ANIMAL (for things that vegans don't eat), FOOD_SWEET, FOOD_LIQUID (soups). You can have multiple flags in here by doing this: food_flags = FOOD_MEAT | FOOD_SWEET
//	reagents_to_add = list(XENOMICROBES = 10, NUTRIMENT = 2)			//This is what is in the food item.
//	bitesize = 3														//This is the amount each bite consumes.

// Eggs

/obj/item/weapon/reagent_containers/food/snacks/organ
	name		=	"organ"
	desc		=	"It's good for you."
	icon		=	'icons/obj/surgery.dmi'
	icon_state	=	"appendix"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/organ/New()
	reagents_to_add = list(NUTRIMENT = rand(3,5), TOXIN = rand(1,3))
	..()

/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	reagents_to_add = list(NUTRIMENT = 12, STOXIN = 3)
	bitesize = 3
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 4, CARPPHEROMONES = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3, PSILOCYBIN = 3)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/hugemushroomslice/mushroom_man/refill()
	reagents_to_add = list(NUTRIMENT = 3, PSILOCYBIN = 3, TRICORDRAZINE = rand(1,5))
	..()

/obj/item/weapon/reagent_containers/food/snacks/meat/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	bitesize = 6
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	sactype = /obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 2, TOXIN = 2)

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round. Not a cord of wood."
	icon_state = "faggot"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/faggot/processed/New()
	..()
	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/sausage/New()
	..()
	eatverb = pick("bite","chew","nibble","deep throat","gobble","chomp")

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	food_flags = FOOD_MEAT | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 4)
	var/warm = 0

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

/obj/item/weapon/reagent_containers/food/snacks/human
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/blobpudding
	name = "blob à l'impératrice"
	desc = "An extremely thick \"pudding\" that requires a tough jaw."
	icon_state = "blobpudding"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_MEAT
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK | UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 8, BLOBANINE = 5)

/obj/item/weapon/reagent_containers/food/snacks/blobsoup
	name = "blobisque"
	desc = "A thick, creamy soup containing a spongy surprise with a tough bite."
	icon_state = "blobsoup"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_ANIMAL | FOOD_MEAT
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK | UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 15, BLOBANINE = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	food_flags = FOOD_SWEET
	reagents_to_add = list(NUTRIMENT = 4, BERRYJUICE = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles!"
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 6, CARPPHEROMONES = 3, CAPSAICIN = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/popcorn
	name = "popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#EFE5D4"
	valid_utensils = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/New()
		..()
		eatverb = pick("bite","crunch","nibble","gnaw","gobble","chomp")
		unpopped = rand(1,10)

/obj/item/weapon/reagent_containers/food/snacks/popcorn/after_consume()
	if(prob(unpopped))	//lol ...what's the point? << AINT SO POINTLESS NO MORE
		to_chat(usr, "<span class='warning'>You bite down on an un-popped kernel, and it hurts your teeth!</span>")
		unpopped = max(0, unpopped-1)
		reagents.add_reagent(SACID, 0.1) //only a little tingle.

/obj/item/weapon/reagent_containers/food/snacks/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
	food_flags = FOOD_MEAT
	filling_color = "#733000"
	valid_utensils = 0
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/no_raisin
	name = "4no raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. They've been FORtified with a number (no.) of nutrients, hence the name."
	trash = /obj/item/trash/raisins
	base_crumb_chance = 30
	valid_utensils = 0
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/bustanuts
	name = "Busta-Nuts"
	icon_state = "busta_nut"
	desc = "2hard4u"
	trash = /obj/item/trash/bustanuts
	base_crumb_chance = 30
	valid_utensils = 0
	base_crumb_chance = 5
	reagents_to_add = list(NUTRIMENT = 6, BUSTANUT = 6, SODIUMCHLORIDE = 6)

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/chips/cheesie
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	filling_color = "#FFCC33"
	base_crumb_chance = 30
	valid_utensils = 0
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	trash = /obj/item/trash/syndi_cakes
	base_crumb_chance = 30
	valid_utensils = 0
	reagents_to_add = list(NUTRIMENT = 4, DOCTORSDELIGHT = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -5
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
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
	reagents_to_add = list(LIQUIDBUTTER = 10)
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
	reagents_to_add = list(NUTRIMENT = 5)
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
	reagents_to_add = list(NUTRIMENT = 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	reagents_to_add = list(TOXIN = 1, CARBON = 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4, SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/synth
	name = "Synthmeat steak"
	desc = "It's still a delicious steak, but it has no soul."
	icon_state = "meatsteak"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0

/* No more of this
/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "Tele Bacon"
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon"
	var/obj/item/beacon/bacon/baconbeacon
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 2
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/telebacon/New()
	..()
	baconbeacon = new /obj/item/beacon/bacon(src)

/obj/item/weapon/reagent_containers/food/snacks/telebacon/after_consume()
	if(!reagents.total_volume)
		baconbeacon.forceMove(usr)
		baconbeacon.digest_delay()
*/

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, CAPSAICIN = 6)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 10, BANANA = 5, BLACKPEPPER = 1, SODIUMCHLORIDE = 1)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "Baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	base_crumb_chance = 20
	reagents_to_add = list(NUTRIMENT = 6, BLACKPEPPER = 1, SODIUMCHLORIDE = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself, chap."
	icon_state = "fishandchips"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20
	reagents_to_add = list(NUTRIMENT = 6, CARPPHEROMONES = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/crab_sticks
	name = "\improper Not-Actually-Imitation Crab sticks"
	desc = "Made from actual crab meat."
	icon_state = "crab_sticks"
	food_flags = FOOD_MEAT
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 4, SUGAR = 1, SODIUMCHLORIDE = 1)
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/crabcake
	name = "Crab Cake"
	desc = "A New Space England favorite!"
	icon_state = "crabcake"
	food_flags = FOOD_MEAT
	bitesize = 2
	base_crumb_chance = 3
	reagents_to_add = list(NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE //eggs, can be dipped
	reagents_to_add = list(NUTRIMENT = 8, PSILOCYBIN = 8)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	food_flags = FOOD_LIQUID | FOOD_MEAT
	filling_color = "#EB7C28"
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 10, TOMATOJUICE = 5, IMIDAZOLINE = 5, WATER = 5)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/stew/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale",DRINK)

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mommispaghetti
	name = "bowl of MoMMi spaghetti"
	desc = "You can feel the autism in this one."
	icon_state = "mommispaghetti"
	base_crumb_chance = 0
	reagents_to_add = list(AUTISTNANITES = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spaghettiboiled"
	restraint_resist_time = 1 SECONDS
	toolsounds = list('sound/weapons/cablecuff.ogg')
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "Spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, TOMATOJUICE = 10)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 12, TOMATOJUICE = 20)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti
	name = "Spaghetti & Meatballs"
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspaghetti"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/crabspaghetti
	name = "Crab Spaghetti"
	desc = "Goes well with Coffee."
	icon_state = "crabspaghetti"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	desc = "A lawyer's favorite."
	icon_state = "spesslaw"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "A large, soft, all-twisted-up pretzel full of POP!"
	icon_state = "poppypretzel"
	food_flags = FOOD_DIPPABLE
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 5)

/*
/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"
	base_crumb_chance = 0
	reagents_to_add = list(SLIMEJELLY = 5)
	bitesize = 3
*/

/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "It is only wafer thin."
	icon_state = "mint"
	base_crumb_chance = 0
	var/safeforfat = FALSE
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mint/refill()
	if(!safeforfat)
		reagents_to_add = list(MINTTOXIN = 1)
	else
		reagents_to_add = list(MINTESSENCE = 2)
	..()

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

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/New()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		reagents_to_add = list(NUTRIMENT = 8, TRICORDRAZINE = 5)
	..()

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 1)

////////////////////////////////FOOD ADDITIONS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/beans
	name = "tin of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	filling_color = "#982424"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon_state = "hotdog"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 3, KETCHUP = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in it's own packaging."
	icon_state = "icecreamsandwich"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, ICE = list(2, T0C))
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	food_flags = FOOD_MEAT
	plate_offset_y = -5
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon_state = "spidereggs"
	food_flags = FOOD_ANIMAL //eggs are eggs
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, TOXIN = 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	food_flags = FOOD_MEAT | FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, SODIUMCHLORIDE = 1)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, CARPPHEROMONES = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cereal
	name = "box of cereal"
	desc = "A box of cereal."
	icon = 'icons/obj/food_custom.dmi'
	icon_state = "cereal_box"
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 3)

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
	reagents_to_add = list(NUTRIMENT = 3)

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
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "burger bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 4)

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
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/chicken_drumstick
	name = "chicken drumstick"
	desc = "We can fry further..."
	icon_state = "chicken_drumstick"
	food_flags = FOOD_MEAT
	filling_color = "#D8753E"
	base_crumb_chance = 0
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/chicken_tenders
	name = "Chicken Tenders"
	desc = "A very special meal for a very good boy."
	icon_state = "tendies"
	food_flags = FOOD_MEAT
	base_crumb_chance = 3
	bitesize = 2
	reagents_to_add = list(CORNOIL = 3, TENDIES = 3)


//////////////////VOX CHICKEN//////////////////

/obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets/vox
	name = "Vox Nuggets"
	desc = "Looks awful and off-colour, you wish you'd gone to Cluckin' Bell instead."
	icon_state = "vox_nuggets"
	item_state = "kfc_bucket"
	filling_color = "#4A75F4"

/obj/item/weapon/reagent_containers/food/snacks/chicken_drumstick/vox
	name = "Vox drumstick"
	desc = "I can't stand cold food. Unlike you, I ain't never ate from a trash can."
	icon_state = "vox_drumstick"
	filling_color = "#4A75F4"

/obj/item/weapon/reagent_containers/food/snacks/chicken_tenders/vox
	name = "Vox Tenders"
	desc = "Respect has to be earned, Sweet - just like money."
	icon_state = "vox_tendies"

/obj/item/weapon/reagent_containers/food/snacks/flan
	name = "Flan"
	desc = "A small crème caramel."
	icon_state = "flan"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = 1
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	filling_color = "#FFEC4D"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/honeyflan
	name = "Honey Flan"
	desc = "The systematic slavery of an entire society of insects, elegantly sized to fit in your mouth."
	icon_state = "honeyflan"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = 1
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, CINNAMON = 5, HONEY = 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/corndog
	name = "Corndog"
	desc = "Battered hotdog on a stick!"
	icon_state = "corndog"
	food_flags = FOOD_MEAT | FOOD_ANIMAL //eggs
	base_crumb_chance = 1
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/cornydog
	name = "CORNY DOG"
	desc = "This is just ridiculous."
	icon_state = "cornydog"
	trash = /obj/item/stack/rods  //no fun allowed
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 15)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/coleslaw
	name = "Coleslaw"
	desc = "You fought the 'slaw, and the 'slaw won."
	icon_state = "coleslaw"
	plate_offset_y = 1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/risotto
	name = "Risotto"
	desc = "For the gentleman's wino, this is an offer one cannot refuse."
	icon_state = "risotto"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4, WINE = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/potentham
	name = "potent ham"
	desc = "I'm sorry Dave, but I'm afraid I can't let you eat that."
	icon_state = "potentham"
	volume = 1
	base_crumb_chance = 0
	reagents_to_add = list(HAMSERUM = 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/eucharist
	name = "\improper Eucharist Wafer"
	icon_state = "eucharist"
	desc = "For the kingdom, the power, and the glory are yours, now and forever."
	bitesize = 5
	base_crumb_chance = 0
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(HOLYWATER = 5)

/obj/item/weapon/reagent_containers/food/snacks/frog_leg
	name = "frog leg"
	desc = "A thick, delicious legionnaire frog leg, its taste and texture resemble chicken."
	icon_state = "frog_leg"
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/reclaimed
	name = "reclaimed nutrition cube"
	desc = "This food represents a highly efficient use of station resources. The Corporate AI's favorite!"
	icon_state = "monkeycubewrap"
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/threebeanburrito
	name = "three bean burrito"
	desc = "Beans, beans a magical fruit."
	icon_state = "danburrito"
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/midnightsnack
	name = "midnight snack"
	desc = "Perfect for those occasions when engineering doesn't set up power."
	icon_state = "midnightsnack"
	bitesize = 2
	trash = /obj/item/trash/snack_bowl
	random_filling_colors = list("#0683FF","#00CC28","#FF8306","#8600C6","#306900","#9F5F2D")
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/midnightsnack/New()
	..()
	set_light(2)

/obj/item/weapon/reagent_containers/food/snacks/honeycitruschicken
	name = "honey citrus chicken"
	desc = "The strong, tangy flavor of the orange and soy sauce highlights the smooth, thick taste of the honey. This fusion dish is one of the highlights of Terran cuisine."
	icon_state = "honeycitruschicken"
	bitesize = 4
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, HONEY = 4, SUGAR = 4)

/obj/item/weapon/reagent_containers/food/snacks/pimiento
	name = "pimiento"
	desc = "A vital component in the caviar of the South."
	icon_state = "pimiento"
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(SUGAR = 1)

/obj/item/weapon/reagent_containers/food/snacks/confederatespirit
	name = "confederate spirit"
	desc = "Even in space, where a north/south orientation is meaningless, the South will rise again."
	icon_state = "confederatespirit"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/fishtacosupreme
	name = "fish taco supreme"
	desc = "There may be more fish in the sea, but there's only one kind of fish in the stars."
	icon_state = "fishtacosupreme"
	bitesize = 3
	food_flags = FOOD_MEAT
	base_crumb_chance = 1
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/chiliconcarne
	name = "chili con carne"
	desc = "This dish became exceedingly rare after Space Texas seceeded from our plane of reality."
	icon_state = "chiliconcarne"
	bitesize = 3
	food_flags = FOOD_LIQUID | FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, CAPSAICIN = 2)

/obj/item/weapon/reagent_containers/food/snacks/cloverconcarne
	name = "clover con carne"
	desc = "Hearty, yet delightfully refreshing. The savory taste of the steak is complemented by the herbal je ne sais quoi of the clover."
	icon_state = "cloverconcarne"
	bitesize = 3
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/chilaquiles
	name = "chilaquiles"
	desc = "The salsa-equivalent of nachos."
	icon_state = "chilaquiles"
	bitesize = 1
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/quiche
	name = "quiche"
	desc = "The queechay has a long history of being mispronounced. Just a taste makes you feel more cerebral and cultured!"
	icon_state = "quiche"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	bitesize = 4
	plate_offset_y = -1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, METHYLIN = 5)

/obj/item/weapon/reagent_containers/food/snacks/minestrone
	name = "minestrone"
	desc = "It's a me, minestrone."
	icon_state = "minestrone"
	bitesize = 4
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, IMIDAZOLINE = 2)

/obj/item/weapon/reagent_containers/food/snacks/poissoncru
	name = "poisson cru"
	desc = "The national dish of Tonga, a country that you had previously never heard about."
	icon_state = "poissoncru"
	bitesize = 2
	plate_offset_y = 1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/gazpacho
	name = "gazpacho"
	desc = "A cool, refreshing soup originating in Space Spain's desert homeworld."
	icon_state = "gazpacho"
	bitesize = 4
	crumb_icon = "dribbles"
	filling_color = "#FF3300"
	valid_utensils = UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 12, FROSTOIL = 6)

/obj/item/weapon/reagent_containers/food/snacks/bruschetta
	name = "bruschetta"
	desc = "This dish's name probably originates from 'to roast over coals'. You can blame the hippies for banning coal use when the crew complains it isn't authentic."
	icon_state = "bruschetta"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/bleachkipper
	name = "bleach kipper"
	desc = "Baby blue and very fishy."
	icon_state = "bleachkipper"
	food_flags = FOOD_MEAT
	volume = 1
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(FISHBLEACH = 1)

/obj/item/weapon/reagent_containers/food/snacks/magbites
	name = "mag-bites"
	desc = "Tiny boot-shaped cheese puffs. Made with real magnets!\
	<br>Warning: not suitable for those with heart conditions or on medication, consult your doctor before consuming this product. Cheese dust may stain or dissolve fabrics."
	icon_state = "magbites"
	reagents_to_add = list(MEDCORES = 6, SODIUMCHLORIDE = 6, NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/lasagna
	name = "lasagna"
	desc = "A carefully stacked trayful of meat, tomato, cheese, and pasta. Favorite of cats."
	icon_state = "lasagna"
	bitesize = 3
	storage_slots = 1
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, TOMATOJUICE = 15)

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
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/butterstick
	name = "butter on a stick"
	desc = "The clown told you to make this."
	icon_state = "butter_stick"
	bitesize = 3
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/butterstick/Crossed(atom/movable/O)
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.Slip(4, 3, slipped_on = src))
			new/obj/effect/decal/cleanable/smashed_butter(src.loc)
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_l
	name = "butter fingers"
	desc = "It's a microwaved hand slathered in butter!"
	icon_state = "butterfingers_l"
	food_flags = FOOD_ANIMAL | FOOD_MEAT
	plate_offset_y = -3
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_l/Crossed(atom/movable/O)
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		C.Slip(4, 3, slipped_on = src)

/obj/item/weapon/reagent_containers/food/snacks/butterfingers_l/r
	icon_state = "butterfingers_r"

/obj/item/weapon/reagent_containers/food/snacks/pierogi
	name = "pierogi"
	desc = "Dumplings with potatoes and curd inside."
	icon_state = "pierogi"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 2)


/obj/item/weapon/reagent_containers/food/snacks/sauerkraut
	name = "sauerkraut"
	desc = "Cabbage that has fermented in salty brine."
	icon_state = "sauerkraut"
	trash = /obj/item/trash/snack_bowl
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/pickledpears
	name = "pickled pears"
	desc = "A jar filled with pickled pears."
	icon_state = "pickledpears"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/pickledbeets
	name = "pickled beets"
	desc = "A jar of pickled whitebeets. How did they become so red, then?"
	icon_state = "pickledbeets"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/bulgogi
	name = "bulgogi"
	desc = "Thin grilled beef marinated with grated pear juice."
	icon_state = "bulgogi"
	food_flags = FOOD_SWEET | FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/bakedpears
	name = "baked pears"
	desc = "Baked pears cooked with cinnamon, sugar and some cream."
	icon_state = "bakedpears"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/winepear
	name = "wine pear"
	desc = "This pear has been laced with wine, some cinnamon and a touch of cream."
	icon_state = "winepear"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/grapejelly
	name = "jelly"
	desc = "The choice of choosy moms."
	icon = 'icons/obj/food2.dmi'
	icon_state = "grapejelly"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, SUGAR = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/peanutbutter
	name = "peanut butter"
	desc = "A jar of smashed peanuts, contains no actual butter."
	icon = 'icons/obj/food2.dmi'
	icon_state = "peanutbutter"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/saltednuts
	name = "salted peanuts"
	desc = "Popular in saloons."
	icon = 'icons/obj/food2.dmi'
	icon_state = "saltednuts"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, SODIUMCHLORIDE = 2)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/pbj
	name = "peanut butter and jelly sandwich"
	desc = "A classic treat of childhood."
	icon = 'icons/obj/food2.dmi'
	icon_state = "pbj"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/escargot
	icon_state = "escargot"
	name = "cooked escargot"
	desc = "A fine treat and an exquisite cuisine."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	bitesize = 1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, SODIUMCHLORIDE = 2, HOLYWATER = 2)

/obj/item/weapon/reagent_containers/food/snacks/es_cargo
	icon_state = "es_cargo_closed"
	name = "es-cargo"
	desc = "Je-ne-veux-pas-travailler!"
	bitesize = 1
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	var/open = FALSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, SODIUMCHLORIDE = 2, HOLYWATER = 2)

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

/obj/item/weapon/reagent_containers/food/snacks/sweetroll
	name = "sweetroll"
	desc = "While on the station, the chef gives you a sweetroll. Delighted, you take it into maintenance to enjoy, only to be intercepted by a gang of three assistants your age."
	icon = 'icons/obj/food.dmi'
	icon_state = "sweetroll"
	food_flags = FOOD_ANIMAL | FOOD_SWEET | FOOD_LACTOSE | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 2, SUGAR = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/dorfbiscuit
	name = "special plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. Aside from the usual ingredients of minced plump helmet and well-minced dwarven wheat flour, this particular serving includes a chemical that sticks whoever eats it to the floor, much like magboots."
	icon_state = "phelmbiscuit"
	bitesize = 1
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(SOFTCORES = 3, NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/dionaroast
	name = "Diona Roast"
	desc = "A slow cooked diona nymph. Very nutritious, and surprisingly tasty!"
	icon_state = "dionaroast"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, BLACKPEPPER = 1, SODIUMCHLORIDE = 1, CORNOIL = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge_scraps
	name = "half-eaten cheese wedge"
	desc = "Looks like someone already got to this one, but there's still quite a bit of cheese left."
	icon_state = "halfeaten_wedge"
	filling_color = "#FFCC33"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 3

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

/obj/item/weapon/reagent_containers/food/snacks/roachesonstick
	name = "Roaches on a stick"
	desc = "Literally two roaches a stick, man. Don't know what you were expecting."
	icon_state = "roachesonastick"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5, ROACHSHELL = 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/grandpatiks
	name = "Grandpa Tik's Roasted 'Peanuts'"
	icon_state = "nutsnbugs"
	desc = "The unborn children of the insectoid colonies; processed, treated and mixed with love (and nuts!) for your enjoyment."
	base_crumb_chance = 30
	valid_utensils = 0
	base_crumb_chance = 0
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 5, ROACHSHELL = 1)

/obj/item/weapon/reagent_containers/food/snacks/multispawner/saltcube
	name = "salt cubes"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/saltcube
	child_volume = 3
	reagents_to_add = list(SODIUMCHLORIDE = 15) //spawns 5

/obj/item/weapon/reagent_containers/food/snacks/saltcube
	name = "salt cubes"
	desc = "You wish you had a salt rhombicosidodecahedron, but a cube will do."
	icon_state = "sugarsaltcube"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/multispawner/sugarcube
	name = "sugar cube"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/sugarcube
	child_volume = 3
	reagents_to_add = list(SUGAR = 15) //spawns 5

/obj/item/weapon/reagent_containers/food/snacks/sugarcube
	name = "sugar cube"
	desc = "The superior sugar delivery method. How will sugar sphere babies ever compare?"
	icon_state = "sugarsaltcube"
	bitesize = 3
