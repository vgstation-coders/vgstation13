#define BUTCHER_MEAT 1

#define BUTCHER_SPEED "bSpeed"
#define BUTCHER_TOOL "bTool"
#define BUTCHER_TNAME "bTName"

//Unlike the previous butchering version the butcher_product datums no longer need to be in a global list to work.
//Instead you place them directly in the mob's butcher_products list.
//speed_mod can be directly decided when calling butcher(), this will ignore other alterations like tool sharpness and mutations
//butcherCarveStep() can be used to change how long meat takes to butcher from individual mobs
//butcherMeat() and butcherProduct() are able to be called without the rest of the process.
//Call butcherProduct() with mod = TRUE to have it search for children of the butcher_product you passed to it in the mob's product list.
//modMeat() and modProduct() can be easily used to add properties to butcher results based off the mob it came from.


/mob/living/proc/butcher(var/speed_mod = 0)
	set category = "Object"
	set name = "Butcher"
	set src in oview(1)

	var/mob/living/user = usr
	if(!butcherCheck(user))
		return
	var/butcherTool = null
	var/toolName = null
	var/list/butchValues = butcherValueStep(user)
	if(!speed_mod && butchValues[BUTCHER_SPEED])
		speed_mod = butchValues[BUTCHER_SPEED]
	if(butchValues[BUTCHER_TOOL])
		butcherTool = butchValues[BUTCHER_TOOL]
	if(butchValues[BUTCHER_TNAME])
		toolName = butchValues[BUTCHER_TNAME]
	if(!speed_mod)
		return
	var/list/butchOptions = butcherMenuStep()
	if(!butchOptions.len)
		return
	var/typeOfCarve = butcherChooseStep(user, butcherOptions, butcherTool)
	if(!typeOfCarve)
		return
	if(butcherCarveStep(user, speed_mod, typeOfCarve, toolName)
		if(typeOfCarve != BUTCHER_MEAT)
			butcherProduct(user, typeOfCarve)
		else
			butcherMeat(user, toolName)


/mob/living/proc/butcherCheck(mob/user, var/ourTool = null)
	if(!istype(user))
		return FALSE
	if(user.isUnconscious() || user.restrained())
		return FALSE
	if(!Adjacent(user))
		return FALSE
	if(being_butchered)
		to_chat(user, "<span class='notice'>[src] is already being butchered.</span>")
		return FALSE
	if(!can_butcher)
		to_chat(user, "<span class='notice'>You can't butcher [src]!")
		return FALSE
	if(ourTool && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(ourTool != H.get_active_hand())
			return FALSE
	return TRUE


/mob/living/proc/butcherValueStep(mob/user)
	var/butchSpeed = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/theTool = H.get_active_hand()
		var/toolName = null
		if(theTool)
			butchSpeed = theTool.is_sharp()
			toolName = theTool.name
			if(!butchSpeed)
				to_chat(user, "<span class='notice'>You can't butcher \the [src] with this!</span>")
				return
		if(H.organ_has_mutation(LIMB_HEAD, M_BEAK))
			var/obj/item/mask = H.get_item_by_slot(slot_wear_mask)
			if(!mask || !(mask.body_parts_covered & MOUTH)) //If our mask doesn't cover mouth, we can use our beak to help us while butchering
				butchSpeed += 0.25
				if(!toolName)
					toolName = "beak"
		if(H.organ_has_mutation(H.get_active_hand_organ(), M_CLAWS))
			if(!istype(H.gloves))
				butchSpeed += 0.25
				if(!toolName)
					toolName = "claws"
		if(isgrue(H))
			toolName = "grue"
			butchSpeed += 0.5
	else
		butchSpeed = 0.5
	if(!butchSpeed)
		return list(BUTCHER_TOOL = theTool, BUTCHER_TNAME = toolName)
	return list(BUTCHER_SPEED = butchSpeed, BUTCHER_TOOL = theTool, BUTCHER_TNAME = toolName)


/mob/living/proc/butcherMenuStep()
	var/list/butcherType = list()
	if(meat_type && meat_amount > meat_taken)
		butcherType += "Butcher"
	for(var/datum/butchering_product/BP in butchering_drops)
		if(BP.amount)
			butcheryType += BP.verb_name
	if(!butcherType.len)
		to_chat(user, "<span class='notice'>There's nothing to butcher.</span>")
		return
	butcherType += "Cancel"
	return butcherType


/mob/living/proc/butcherChooseStep(mob/user, butcherOptions, butcherTool)
	var/choice = input(user,"What would you like to do with \the [src]?","Butchering") in butcherType
	if(!butcherCheck(user, butcherTool))
		return 0
	if(choice == "Cancel")
		return 0
	if(choice == "Butcher")
		return BUTCHER_MEAT
	if(!choice || butchering_drops.len)
		return 0
	var/theProduct = getProduct(choice)
	return theProduct


/mob/living/proc/getProduct(choice)
	for(var/datum/butchering_product/BP in butchering_drops)
		if(BP.verb_name == choice)
			return BP


/mob/living/proc/butcherCarveStep(mob/user, speed_mod, typeOfCarve, var/butcherTime = 20)
	var/butcherWord = null
	if(typeOfCarve == BUTCHER_MEAT)
		butcherWord = "butchering"
		butcherTime *= size
	else if(istype(typeOfCarve, /datum/butchering_product))
		butcherWord = typeOfCarve.verb_gerund
		butcherTime = typeOfCarve.butcher_time
	if(!butcherWord)
		return FALSE
	user.visible_message("<span class='notice'>[user] starts [butcherWord] \the [src][toolName ? " with \the [toolName]" : ""].</span>",\
		"<span class='info'>You start [butcherWord] \the [src].</span>")
	being_butchered = TRUE
	if(!do_after(user, src, butcherTime / speed_mod))
		to_chat(user, "<span class='warning'>You stop [butcherWord] \the [src].</span>")
		return FALSE
	being_butchered = FALSE
	to_chat(user, "<span class='info'>You finish [butcherWord] \the [src].</span>")
	return TRUE


/mob/living/proc/butcherMeat(mob/user, var/tool_name)
	var/theMeat = null
	if(istype(meat_type, /obj/item/weapon/reagent_containers/food/snacks/meat)
		theMeat = drop_meat(loc)
	else
		theMeat = new meat_type(loc)
	if(tool_name)
		if(!advanced_butchery)
			advanced_butchery = new()
		advanced_butchery.Add(tool_name)
	modMeat(user, theMeat)
	meatEndStep(user)


/mob/living/proc/drop_meat(location)
	if(!meat_type)
		return
	if(!istype(meat_type, /obj/item/weapon/reagent_containers/food/snacks/meat))
		return
	var/obj/item/weapon/reagent_containers/food/snacks/meat/M
	if(ishuman(src))
		M = new meat_type(location, src)
	else
		M = new meat_type(location)
	meat_taken++
	if(virus2?.len)
		for(var/ID in virus2)
			var/datum/disease2/disease/D = virus2[ID]
			if(D.spread & SPREAD_BLOOD)
				M.infect_disease2(D,1,"(Butchered, from [src])",0)
	var/obj/item/weapon/reagent_containers/food/snacks/meat/animal/A = M
	if(istype(A))
		var/mob/living/simple_animal/source_animal = src
		if(istype(source_animal) && source_animal.species_type)
			var/mob/living/specimen = source_animal.species_type
			A.name = "[initial(specimen.name)] meat"
			A.animal_name = initial(specimen.name)
		else
			A.name = "[initial(src.name)] meat"
			A.animal_name = initial(src.name)
	if(reagents)
		reagents.trans_to(A,round (reagents.total_volume * (meat_amount/meat_taken), 1))
	return M


/mob/living/proc/meatEndStep(mob/user)
	if(meat_taken < meat_amount)
		to_chat(user, "<span class='info'>You cut a chunk of meat out of \the [src].</span>")
		return
	to_chat(user, "<span class='info'>You butcher \the [src].</span>")
	if(istype(src, /mob/living/simple_animal)) //Animals can be butchered completely, humans - not so
		if(size > SIZE_TINY) //Tiny animals don't produce gibs
			gib(meat = 0) //"meat" argument only exists for mob/living/simple_animal/gib()
		else
			qdel(src)


/mob/living/proc/butcherProduct(mob/user, var/theCarve var/mod = FALSE)
	var/toCarve = null
	if(mod)	//This is here so things can directly call this proc without needing to be overly specific
		for(var/datum/butchering_product/BP in butchering_drops)
			if(istype(BP, theCarve) && BP.amount)
				toCarve = BP
		if(!toCarve)
			return FALSE
	else
		toCarve = theCarve
	toCarve.spawn_result(loc, src)
	update_icons()
	modProduct(mob/user, theProduct)


/mob/living/proc/modProduct(mob/user, theProduct)	//These procs can easily be used to give features to meat/products based on the animal
	return

/mob/living/proc/modMeat(mob/user, theMeat)
	return
