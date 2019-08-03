//Basic thought processes
/datum/component/ai/human_brain
	var/life_tick=0
	var/wander = TRUE	//Whether the mob will walk around searching for goals, or wait for them to become visible
	var/lastdir = null

	var/list/desired_items = list()	//Specific items
	var/list/personal_desires = list()	//General desires for events/situations/types of items

	var/list/friendly_factions = list()
	var/list/enemy_factions = list()
	var/list/enemy_types = list()
	var/list/enemy_species = list("Tajaran")
	var/list/friends = list()
	var/list/enemies = list()

	var/datum/component/ai/target_holder/target_holder = null
	var/atom/current_target

/datum/component/ai/human_brain/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_LIFE) // no arguments
			OnLife()

/datum/component/ai/human_brain/proc/OnLife()
	life_tick++
	if(!target_holder)
		target_holder = GetComponent(/datum/component/ai/target_holder)
	if(!controller)
		controller = GetComponent(/datum/component/controller)
	if(controller.getBusy())
		return
	if(!ishuman(container.holder))
		return
	var/mob/living/carbon/human/H = container.holder

	if(H.stat != CONSCIOUS || !H.canmove || !isturf(H.loc))
		SendSignal(COMSIG_MOVE, list("dir" = 0))
		return

	current_target = target_holder.GetBestTarget(src, "target_evaluator")
	if(!isnull(current_target))
		personal_desires.Add(DESIRE_CONFLICT)
		SendSignal(COMSIG_TARGET, list("target"=current_target))
		if(IsBetterWeapon(H))
			personal_desires.Add(DESIRE_HAVE_WEAPON)
		if(IsBetterWeapon(H, H.contents))
			if(WieldBestWeapon(H))
				personal_desires.Remove(DESIRE_HAVE_WEAPON)

	AssessNeeds(H)
	var/obj/item/I = AttainExternalItemGoal(H)
	if(I)
		if(H.Adjacent(I))
			AcquireItem(H, I)
			SendSignal(COMSIG_MOVE, list("dir" = 0))
		else
			if(H.stat == CONSCIOUS && H.canmove && isturf(H.loc))
				SendSignal(COMSIG_MOVE, list("loc" = get_turf(I)))
		return

	if(!isnull(current_target))
		SendSignal(COMSIG_ATTACKING, list("target"=current_target))
		var/turf/T = get_turf(current_target)
		if(T)
			if(H.stat == CONSCIOUS && H.canmove && isturf(H.loc))
				SendSignal(COMSIG_MOVE, list("loc" = T))
		return
	else
		personal_desires.Remove(DESIRE_CONFLICT)

	if(wander && prob(70))
		var/dir = pick(NORTH,SOUTH,EAST,WEST)
		if(lastdir)
			var/roll = rand(1,100)
			if(roll <= 50)
				dir = lastdir
			else if(roll <= 90)
				dir = pick(turn(lastdir,90),turn(lastdir,270))
			else
				dir = turn(lastdir, 180)
		if(H.stat == CONSCIOUS && H.canmove && isturf(H.loc))
			SendSignal(COMSIG_STEP, list("dir" = dir))
			lastdir = dir

/datum/component/ai/human_brain/proc/AssessNeeds(mob/living/carbon/human/H)
	personal_desires = list()
	if(H.nutrition < 250)
		personal_desires.Add(DESIRE_FOOD)
	if(!H.get_item_by_slot(slot_w_uniform))
		personal_desires.Add(DESIRE_UNDERCLOTHING)
	if(!H.get_item_by_slot(slot_shoes))
		personal_desires.Add(DESIRE_SHOES)
	if(!H.get_item_by_slot(slot_back))
		personal_desires.Add(DESIRE_BACK)
	if(!H.get_item_by_slot(slot_gloves))
		personal_desires.Add(DESIRE_GLOVES)
	if(!H.get_item_by_slot(slot_head))
		personal_desires.Add(DESIRE_HAT)
	if(!H.get_item_by_slot(slot_belt))
		personal_desires.Add(DESIRE_BELT)
	if(!H.get_item_by_slot(slot_wear_suit))
		personal_desires.Add(DESIRE_EXOSUIT)
	if(!H.get_item_by_slot(slot_glasses))
		personal_desires.Add(DESIRE_GLASSES)
	if(!H.get_item_by_slot(slot_wear_mask))
		personal_desires.Add(DESIRE_MASK)
	if(!H.get_item_by_slot(slot_wear_id))
		personal_desires.Add(DESIRE_ID)

/datum/component/ai/human_brain/proc/AttainExternalItemGoal(mob/living/carbon/human/H)
	var/obj/item/goal = null
	if(H.get_active_hand())
		return //Hand is full
	processing_desires:
		for(var/D in desire_ranks)
			if(D in personal_desires)
				for(var/obj/item/I in view(H))
					if(I in H.contents)
						continue
					if(I.anchored) //Odd cases such as intercoms
						continue
					switch(D)
						if(DESIRE_HAVE_WEAPON)
							if(IsBetterWeapon(comparison = I))
								goal = I
						if(DESIRE_CONFLICT)
							break processing_desires
						if(DESIRE_FOOD)
							if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
								goal = I
						if(DESIRE_UNDERCLOTHING)
							if((I.slot_flags & SLOT_ICLOTHING) && I.mob_can_equip(H, slot_w_uniform))
								goal = I
						if(DESIRE_SHOES)
							if((I.slot_flags & SLOT_FEET) && I.mob_can_equip(H, slot_shoes))
								goal = I
						if(DESIRE_BACK)
							if((I.slot_flags & SLOT_BACK) && I.mob_can_equip(H, slot_back))
								goal = I
						if(DESIRE_GLOVES)
							if((I.slot_flags & SLOT_GLOVES) && I.mob_can_equip(H, slot_gloves))
								goal = I
						if(DESIRE_HAT)
							if((I.slot_flags & SLOT_HEAD) && I.mob_can_equip(H, slot_head))
								goal = I
						if(DESIRE_BELT)
							if((I.slot_flags & SLOT_BELT) && I.mob_can_equip(H, slot_belt))
								goal = I
						if(DESIRE_EXOSUIT)
							if((I.slot_flags & SLOT_OCLOTHING) && I.mob_can_equip(H, slot_wear_suit))
								goal = I
						if(DESIRE_GLASSES)
							if((I.slot_flags & SLOT_EYES) && I.mob_can_equip(H, slot_glasses))
								goal = I
						if(DESIRE_MASK)
							if((I.slot_flags & SLOT_MASK) && I.mob_can_equip(H, slot_wear_mask))
								goal = I
						if(DESIRE_ID)
							if((I.slot_flags & SLOT_ID) && I.mob_can_equip(H, slot_wear_id))
								goal = I
					if(goal)
						break processing_desires
	return goal

/datum/component/ai/human_brain/proc/AcquireItem(mob/living/carbon/human/H, obj/item/I)
	SendSignal(COMSIG_ACTVEMPTYHAND, list())
	SendSignal(COMSIG_CLICKON, list("target" = I))
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
		ConsumeFood(H, I)
	else
		SendSignal(COMSIG_EQUIPACTVHAND, list())

/datum/component/ai/human_brain/proc/ConsumeFood(mob/living/carbon/human/H, obj/item/I)
	while(H.nutrition < 250 && !I.gcDestroyed)
		SendSignal(COMSIG_ITMATKSELF, list())
		sleep(1)
	SendSignal(COMSIG_DROP, list())

/datum/component/ai/human_brain/proc/target_evaluator(var/atom/target)
	return TRUE

/datum/component/ai/human_brain/proc/WieldBestWeapon(mob/living/carbon/human/H, var/list/excluded)
	if(H.isStunned()) //We're on the floor, nothing we can do
		return 0
	SendSignal(COMSIG_ACTVEMPTYHAND, list())
	if(H.get_active_hand())
		SendSignal(COMSIG_DROP, list())
		if(H.get_active_hand())
			return 1
	if(!excluded)
		excluded = list()
	var/obj/item/current_candidate = null
	for(var/obj/item/I in H.contents)
		if(!current_candidate)
			if(I.force > 2)
				current_candidate = I
		else
			if(I.force > current_candidate.force || (I.force == current_candidate.force && I.sharpness > current_candidate.sharpness))
				current_candidate = I
	if(current_candidate)
		SendSignal(COMSIG_CLICKON, list("target" = current_candidate))
		if(current_candidate != H.get_active_hand())
			excluded.Add(current_candidate)
			.(H, excluded)
		else
			return 1
	else
		return 0

/datum/component/ai/human_brain/proc/IsBetterWeapon(mob/living/carbon/human/H, var/list/search_location, var/obj/item/comparison)
	var/obj/item/O = H.get_active_hand()
	if(!search_location && !comparison)
		search_location = view(H)
	else if (comparison)
		if((!O && comparison.force > 2) || (O && (comparison.force > O.force || (comparison.force == O.force && comparison.sharpness > O.sharpness))))
			return 1
		return 0
	for(var/obj/item/I in search_location)
		if((!O && I.force > 2) || (O && (I.force > O.force || (I.force == O.force && I.sharpness > O.sharpness))))
			return 1