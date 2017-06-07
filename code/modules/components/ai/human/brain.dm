//Basic thought processes
/datum/component/ai/human_brain
	var/life_tick=0
	var/wander = TRUE	//Whether the mob will walk around searching for goals, or wait for them to become visible
	var/lastdir = null

	var/list/desired_items = list()	//Specific items
	var/list/personal_desires = list()	//General desires for events/situations/types of items

	var/list/friendly_factions = list()
	var/list/enemy_factions = list()
	var/list/friends = list()
	var/list/true_friends = list()
	var/list/enemies = list()

/datum/component/ai/human_brain/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_LIFE) // no arguments
			OnLife()

/datum/component/ai/human_brain/proc/OnLife()
	life_tick++
	//testing("HUNT LIFE, controller=[!isnull(controller)], busy=[controller && controller.getBusy()], state=[controller && controller.getState()]")
	if(!controller)
		controller = GetComponent(/datum/component/controller)
	if(controller.getBusy())
		return
	if(!ishuman(container.holder))
		return
	var/mob/living/carbon/human/H = container.holder
	if(H.stat != CONSCIOUS || !H.canmove || !isturf(H.loc))
		SendSignal(COMSIG_MOVE, list("dir" = 0))
	AssessNeeds(H)
	var/obj/item/I = AttainExternalGoal(H)
	if(I)
		if(H.Adjacent(I))
			AcquireItem(H, I)
			SendSignal(COMSIG_MOVE, list("dir" = 0))
		else
			if(H.stat == CONSCIOUS && H.canmove && isturf(H.loc))
				SendSignal(COMSIG_MOVE, list("loc" = get_turf(I)))
	else if(wander && prob(60))
		var/dir = pick(NORTH,SOUTH,EAST,WEST)
		if(lastdir)
			var/roll = rand(1,100)
			if(roll <= 40)
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

/datum/component/ai/human_brain/proc/AttainExternalGoal(mob/living/carbon/human/H)
	var/obj/item/goal = null
	for(var/D in personal_desires)
		for(var/obj/item/I in view(H))
			switch(D)
				if(DESIRE_HAVE_WEAPON)
					if(!goal || I.force > goal.force || (I.force == goal.force && I.sharpness > goal.sharpness))
						goal = I
				if(DESIRE_FOOD)
					if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
						goal = I
				if(DESIRE_UNDERCLOTHING)
					if(I.slot_flags & SLOT_ICLOTHING)
						goal = I
				if(DESIRE_SHOES)
					if(I.slot_flags & SLOT_FEET)
						goal = I
				if(DESIRE_BACK)
					if(I.slot_flags & SLOT_BACK)
						goal = I
				if(DESIRE_GLOVES)
					if(I.slot_flags & SLOT_GLOVES)
						goal = I
				if(DESIRE_HAT)
					if(I.slot_flags & SLOT_HEAD)
						goal = I
				if(DESIRE_BELT)
					if(I.slot_flags & SLOT_BELT)
						goal = I
				if(DESIRE_EXOSUIT)
					if(I.slot_flags & SLOT_OCLOTHING)
						goal = I
				if(DESIRE_GLASSES)
					if(I.slot_flags & SLOT_EYES)
						goal = I
				if(DESIRE_MASK)
					if(I.slot_flags & SLOT_MASK)
						goal = I
				if(DESIRE_ID)
					if(I.slot_flags & SLOT_ID)
						goal = I
		if(goal)
			break
	return goal

//datum/component/ai/human_brain/proc/EquipBestWeapon(mob/living/carbon/human/H)

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