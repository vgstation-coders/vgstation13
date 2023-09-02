///////////////Butcher Datums////////////////////////////////////////////////////////////////

//When giving a mob a special butcher product, like goliath plates, the mob must be given its own get_butchering_products() proc which returns a list of /datum/butchering_product.
//The mob's butchering_drops list is made from get_butchering_products() when it dies. Humans however get it when they're created.

/datum/butchering_product
	var/obj/item/result
	//What item this is for

	var/verb_name
	//Something like "skin", don't name this "Butcher" please

	var/verb_gerund
	//Something like "skinning"

	var/amount = 1
	var/initial_amount = 1
	//How much results you can spawn before this datum disappears

	var/stored_in_organ
	//Example value: LIMB_HEAD or "arm". When an organ with the same type is cut off, this object will be transferred to it.

	var/butcher_time = 20

	var/radial_icon = "radial_butcher"
	//Icon in the radial menu

/datum/butchering_product/New()
	..()

	initial_amount = amount

/datum/butchering_product/proc/spawn_result(location, mob/parent)
	if(amount > 0)
		amount--
		return new result(location)

//This is added to the description of dead mobs! It's important to add a space at the end (like this: "It has been skinned. ").
/datum/butchering_product/proc/desc_modifier(mob/parent, mob/user) //User - the guy who is looking at Parent
	return

//==============Teeth============

/datum/butchering_product/teeth
	result = /obj/item/stack/teeth
	verb_name = "harvest teeth"
	verb_gerund = "removing teeth from"
	radial_icon = "radial_teeth"

	stored_in_organ = LIMB_HEAD //Cutting a LIMB_HEAD off will transfer teeth to the head object

/datum/butchering_product/teeth/desc_modifier(mob/parent, mob/user)
	if(amount == initial_amount)
		return
	if(!isliving(parent))
		return

	var/mob/living/L = parent

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/datum/organ/external/head = H.get_organ(LIMB_HEAD)
		if((head.status & ORGAN_DESTROYED) || !head)
			return //If he has no head, you can't see whether he has teeth or not!

		var/obj/item/clothing/mask/M = H.wear_mask
		if(istype(M) && is_slot_hidden(M.body_parts_covered,MOUTH))
			return //If his mouth is covered, we can't see his teeth

	var/pronoun = "Its"
	if(L.gender == MALE)
		pronoun = "His"
	if(L.gender == FEMALE)
		pronoun = "Her"

	if(amount == 0)
		return "[pronoun] teeth are gone. "
	else
		if(parent.Adjacent(user))
			return "[(initial_amount - amount)] of [lowertext(pronoun)] teeth are missing."
		else
			return "Some of [lowertext(pronoun)] teeth are missing. "

#define ALL_TEETH -1
/datum/butchering_product/teeth/spawn_result(location, mob/parent, drop_amount = ALL_TEETH)
	if(amount <= 0)
		return

	var/obj/item/stack/teeth/T = new(location)
	T.update_name(parent) //Change name of the teeth - from the default "teeth" to "corgi teeth", for example

	if(drop_amount == ALL_TEETH) //Drop ALL teeth
		T.amount = amount
		amount = 0
	else //Drop a random amount
		var/actual_amount = min(src.amount, drop_amount)
		T.amount = actual_amount
		src.amount -= actual_amount

	return T

/datum/butchering_product/teeth/few/New()
	amount = rand(4,8)
	..()

/datum/butchering_product/teeth/bunch/New()
	amount = rand(8,16)
	..()

/datum/butchering_product/teeth/lots/New()
	amount = rand(16,24)
	..()

/datum/butchering_product/teeth/human/New()
	amount = 32
	..()

#undef ALL_TEETH

//===============Skin=============

/datum/butchering_product/skin
	result = /obj/item/stack/sheet/animalhide
	verb_name = "skin"
	verb_gerund = "skinning"
	radial_icon = "radial_skin"

/datum/butchering_product/skin/desc_modifier(mob/parent)
	if(!amount)
		var/pronoun = "It"
		if(parent.gender == MALE)
			pronoun = "He"
		if(parent.gender == FEMALE)
			pronoun = "She"
		return "[pronoun] has been skinned. "

/datum/butchering_product/skin/cat
	result = /obj/item/stack/sheet/animalhide/cat

/datum/butchering_product/skin/cat/lots
	amount = 3

/datum/butchering_product/skin/corgi
	result = /obj/item/stack/sheet/animalhide/corgi

/datum/butchering_product/skin/lizard
	result = /obj/item/stack/sheet/animalhide/lizard

/datum/butchering_product/skin/lizard/lots
	amount = 3

/datum/butchering_product/skin/human
	result = /obj/item/stack/sheet/animalhide/human
	amount = 3

/datum/butchering_product/skin/human/spawn_result(location, mob/parent)
	if(!amount)
		return
	amount--
	if(ishuman(parent))
		var/mob/living/carbon/human/H = parent

		var/obj/item/stack/sheet/animalhide/human/A = new result(location)

		if(!isjusthuman(H) && H.species) //Grey skin, unathi skin, etc.
			A.name = H.species.name ? "[lowertext(H.species.name)] skin" : A.name
			A.source_string = H.species.name ? lowertext(H.species.name) : A.source_string
		else
			if(H.mind && H.mind.assigned_role && H.mind.assigned_role != "MODE") //CLOWN LEATHER, ASSISTANT LEATHER, CAPTAIN LEATHER
				A.name = "[lowertext(H.mind.assigned_role)] skin"
				A.source_string = lowertext(H.mind.assigned_role)

		if (H.species)
			A.skin_color = H.species.flesh_color
			A.color = A.skin_color

/datum/butchering_product/skin/gondola
	result = /obj/item/stack/sheet/animalhide/gondola
	amount = 2

/datum/butchering_product/skin/deer
	result = /obj/item/stack/sheet/animalhide/deer
	amount = 3
	initial_amount = 3

/datum/butchering_product/skin/goliath
	result = /obj/item/asteroid/goliath_hide

/datum/butchering_product/skin/basilisk
	result = /obj/item/asteroid/basilisk_hide
	verb_name = "break crystals off"
	verb_gerund = "breaking crystals off"

/datum/butchering_product/skin/bear
	result = /obj/item/clothing/head/bearpelt/real

/datum/butchering_product/skin/bear/spare
	result = /obj/item/clothing/head/bearpelt/real/spare

/datum/butchering_product/skin/bear/spare/spawn_result(location, mob/parent)
	..()
	parent.dust()

/datum/butchering_product/skin/bear/brownbear
	result = /obj/item/clothing/head/bearpelt/brown/real

/datum/butchering_product/skin/bear/panda
	result = /obj/item/clothing/head/bearpelt/panda

/datum/butchering_product/skin/bear/polarbear
	result = /obj/item/clothing/head/bearpelt/polar

/datum/butchering_product/skin/xeno
	result = /obj/item/stack/sheet/xenochitin
	verb_name = "remove chitin"
	verb_gerund = "removing chitin"

/datum/butchering_product/skin/xeno/New()
	amount = rand(1,3)

/datum/butchering_product/skin/xeno/spawn_result(location)
	..()
	if(!amount) //If all chitin was removed
		new /obj/item/stack/sheet/animalhide/xeno(location)

/datum/butchering_product/skin/monkey
	result = /obj/item/stack/sheet/animalhide/monkey

/datum/butchering_product/skin/wolf
	result = /obj/item/clothing/head/wolfpelt
//--------------Spider legs-------

/datum/butchering_product/spider_legs
	result = /obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg
	verb_name = "remove legs from"
	verb_gerund = "removing legs from"
	radial_icon = "radial_sleg"
	amount = 8 //Amount of legs that all normal spiders have
	butcher_time = 10

/datum/butchering_product/spider_legs/desc_modifier()
	if(amount < 8)
		return "It only has [amount] [amount==1 ? "leg" : "legs"]. "

//=============Alien claws========

/datum/butchering_product/xeno_claw
	result = /obj/item/xenos_claw
	verb_name = "declaw"
	verb_gerund = "declawing"
	radial_icon = "radial_xclaw"

/datum/butchering_product/xeno_claw/desc_modifier()
	if(!amount)
		return "Its claws have been cut off. "

//======frog legs

/datum/butchering_product/frog_leg
	result = /obj/item/weapon/reagent_containers/food/snacks/frog_leg
	verb_name = "remove legs from"
	verb_gerund = "removing legs from"
	radial_icon = "radial_fleg"
	amount = 2 //not a magic number, frogs have 2 legs
	butcher_time = 10

/datum/butchering_product/frog_leg/desc_modifier()
	if(amount < 2)
		return "It only has [amount] [amount==1 ? "leg" : "legs"]. "

//======hivelord core

/datum/butchering_product/hivelord_core
	result = /obj/item/asteroid/hivelord_core
	verb_name = "remove the core from"
	verb_gerund = "removing the core from"
	radial_icon = "radial_core"
	butcher_time = 2

/datum/butchering_product/hivelord_core/desc_modifier()
	if(!amount)
		return "Its core has been taken. "

/datum/butchering_product/hivelord_core/guardian
	result = /obj/item/asteroid/hivelord_core/guardian

/datum/butchering_product/hivelord_core/heart
	result = /obj/item/organ/internal/heart/hivelord

//======deer head

/datum/butchering_product/deer_head
	result = /obj/item/deer_head
	verb_name = "remove head"
	verb_gerund = "removing the head from"
	radial_icon = "radial_dhead"
	amount = 1
	butcher_time = 15

/datum/butchering_product/deer_head/desc_modifier()
	if(!amount)
		return "Its head has been taken. "

/datum/butchering_product/deer_head/spawn_result(location, mob/parent)
	if(isliving(parent))
		var/mob/living/L = parent
		L.update_icons()
		L.mob_property_flags |= MOB_NO_LAZ

	if(amount > 0)
		amount--
		var/obj/I = new result(location)

		if(istype(parent, /mob/living/simple_animal/hostile/deer))
			var/mob/living/simple_animal/hostile/deer/D = parent

			if(D.icon_living == "deer_flower")
				I.icon_state = "deer-head-flower"
			else if(istype(D, /mob/living/simple_animal/hostile/deer/flesh))
				I.icon_state = "deer-head-flesh"

//======Rabbits

/datum/butchering_product/rabbit_ears
	result = /obj/item/clothing/head/rabbitears
	verb_name = "remove ears"
	verb_gerund = "removing the ears from"
	amount = 1
	butcher_time = 10

/datum/butchering_product/rabbit_foot
	result = /obj/item/clothing/accessory/rabbit_foot
	verb_name = "remove foot"
	verb_gerund = "removing the foot from"
	amount = 1 //Only the back left foot is considered lucky.
	butcher_time = 10

/datum/butchering_product/snail_carapace
	result = /obj/item/clothing/head/helmet/snail_helm
	verb_name = "remove carapace"
	verb_gerund = "removing the carapace from"
	butcher_time = 10

/////////////////////////////////Butcher procs/////////////////////////////////////////////////

//butcherCarveStep() can be used to change how long meat takes to butcher from individual mobs
//butcherMeat() and butcherProduct() are able to be called without the rest of the process.
//Call butcherProduct() with mod = TRUE to have it search for children of the butcher_product you passed to it in the mob's product list.
//modMeat() and modProduct() can be easily used to add properties to butcher results based off the mob it came from.

#define BUTCHER_MEAT 1
#define BUTCHER_SPEED "bSpeed"
#define BUTCHER_TOOL "bTool"
#define BUTCHER_TNAME "bTName"

/mob/living/proc/butcher()
	set category = "Object"
	set name = "Butcher"
	set src in oview(1)

	var/mob/living/user = usr
	if(!butcherCheck(user))
		return
	var/butcherTool = null
	var/toolName = null
	var/speed_mod = 0
	var/list/butchValues = butcherValueStep(user)
	if(!length(butchValues))
		return
	if(butchValues[BUTCHER_SPEED])
		speed_mod = butchValues[BUTCHER_SPEED]
	if(butchValues[BUTCHER_TOOL])
		butcherTool = butchValues[BUTCHER_TOOL]
	if(butchValues[BUTCHER_TNAME])
		toolName = butchValues[BUTCHER_TNAME]
	var/list/butcherOptions = butcherMenuStep(user)
	if(!length(butcherOptions))
		return
	var/datum/butchering_product/typeOfCarve = butcherChooseStep(user, butcherOptions, butcherTool)
	if(!typeOfCarve)
		return
	if(butcherCarveStep(user, speed_mod, typeOfCarve, toolName))
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
	var/obj/item/theTool = null
	var/toolName = null
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		theTool = H.get_active_hand()
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
	else
		butchSpeed = 0.5
	if(!butchSpeed)
		return
	return list(BUTCHER_SPEED = butchSpeed, BUTCHER_TOOL = theTool, BUTCHER_TNAME = toolName)


/mob/living/proc/butcherMenuStep(mob/user)
	var/list/butcherType = list()
	if(meat_type && meat_amount > meat_taken)
		butcherType += list(list("Butcher","radial_butcher"))
	for(var/datum/butchering_product/BP in butchering_drops)
		if(BP.amount)
			butcherType += list(list(BP.verb_name,BP.radial_icon))
	if(!butcherType.len)
		to_chat(user, "<span class='notice'>There's nothing to butcher.</span>")
		return
	return butcherType


/mob/living/proc/butcherChooseStep(mob/user, var/list/butcherOptions, butcherTool)
	var/choice = show_radial_menu(user,loc,butcherOptions,custom_check = new /callback(src, nameof(src::radial_check()), user))
	if(!radial_check(user))
		return
	if(!butcherCheck(user, butcherTool))
		return 0
	if(choice == "Butcher")
		return BUTCHER_MEAT
	if(!choice || !butchering_drops.len)
		return 0
	var/theProduct = getProduct(choice)
	return theProduct

/mob/living/proc/radial_check(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/mob/living/proc/getProduct(choice)
	for(var/datum/butchering_product/BP in butchering_drops)
		if(BP.verb_name == choice)
			return BP


/mob/living/proc/butcherCarveStep(mob/user, speed_mod, datum/butchering_product/typeOfCarve, toolName, var/butcherTime = 20)
	var/butcherWord = null
	if(typeOfCarve == BUTCHER_MEAT)
		butcherWord = "butchering"
		butcherTime *= size
		if(meat_taken >= meat_amount)
			to_chat(user, "<span class='info'>There's no meat left!.</span>")
			return
	else
		butcherWord = typeOfCarve.verb_gerund
		butcherTime = typeOfCarve.butcher_time
	if(!butcherWord)
		return FALSE
	user.visible_message("<span class='notice'>[user] starts [butcherWord] \the [src][toolName ? " with \the [toolName]" : ""].</span>",\
		"<span class='info'>You start [butcherWord] \the [src].</span>")
	being_butchered = TRUE
	if(!do_after(user, src, butcherTime / speed_mod))
		to_chat(user, "<span class='warning'>You stop [butcherWord] \the [src].</span>")
		being_butchered = FALSE
		return FALSE
	being_butchered = FALSE
	to_chat(user, "<span class='info'>You finish [butcherWord] \the [src].</span>")
	return TRUE


/mob/living/proc/butcherMeat(mob/user, var/tool_name)
	var/theMeat = drop_meat(loc)
	if(theMeat)
		if(tool_name)
			if(!advanced_butchery)
				advanced_butchery = new()
			advanced_butchery.Add(tool_name)
		modMeat(user, theMeat)
	meatEndStep(user)


/mob/living/proc/drop_meat(location)
	if(!meat_type)
		return
	if(meat_taken >= meat_amount)
		return
	meat_taken++
	if(!ispath(meat_type, /obj/item/weapon/reagent_containers/food/snacks/meat))	//For 2 years sheet/bone thought "skeleton" was a number
		var/NM = new meat_type(location)
		return NM
	var/obj/item/weapon/reagent_containers/food/snacks/meat/M = null
	M = make_meat(location)
	if(length(virus2))
		for(var/ID in virus2)
			var/datum/disease2/disease/D = virus2[ID]
			if(D.spread & SPREAD_BLOOD)
				M.infect_disease2(D,1,"(Butchered, from [src])",0)
	if(reagents)
		reagents.trans_to(M, round(reagents.total_volume * (meat_amount/meat_taken), 1))
	return M


/mob/living/proc/make_meat(location)
	var/ourMeat = new meat_type(location)
	return ourMeat


/mob/living/proc/meatEndStep(mob/user)	//Exists for simple_animals
	to_chat(user, "<span class='info'>You cut a chunk of meat out of \the [src].</span>")


/mob/living/proc/butcherProduct(mob/user, var/datum/butchering_product/theCarve, var/mod = FALSE)
	var/datum/butchering_product/toCarve = null
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
	modProduct(user, toCarve)


/mob/living/proc/modProduct(mob/user, theProduct)	//These procs can easily be used to give features to meat/products based on the animal
	return

/mob/living/proc/modMeat(mob/user, theMeat)
	return


#undef BUTCHER_MEAT
#undef BUTCHER_SPEED
#undef BUTCHER_TOOL
#undef BUTCHER_TNAME

///////////////////////END PROCS///////////////////////////////////////////////////
