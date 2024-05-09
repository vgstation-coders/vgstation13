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

/obj/item/weapon/reagent_containers/food/snacks/New(loc, parent)
	if(parent)
		reagents_to_add = null
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
				var/obj/item/weapon/reagent_containers/food/snacks/slice = new slice_path(src.loc, src.type)
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

/obj/item/weapon/reagent_containers/food/snacks/multispawner/New()
	. = ..()
	if(isturf(loc)) // for testing and misc uses
		spawn_children()

// called when it leaves the microwave
/obj/item/weapon/reagent_containers/food/snacks/multispawner/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	. = ..()
	if(isnull(destination))
		return
	spawn_children()

/obj/item/weapon/reagent_containers/food/snacks/multispawner/proc/spawn_children()
	var/num_of_children = reagents.total_volume / child_volume
	// this is the BYOND ceil, say something nice about it
	num_of_children = (round(num_of_children) < num_of_children) ? round(num_of_children) + 1 : round(num_of_children)
	var/amount_to_transfer = reagents.total_volume / num_of_children
	for(var/i in 1 to num_of_children)
		var/obj/child = new child_type(parent = src.type)
		reagents.trans_to(child, amount_to_transfer)
		child.forceMove(loc)
		child.pixel_x = rand(-8, 8)
		child.pixel_y = rand(-8, 8)
	qdel(src)
