//Actual butchering code is handled in living.dm

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

/datum/butchering_product/skin/gondola
	result = /obj/item/stack/sheet/animalhide/gondola
	amount = 2

/datum/butchering_product/skin/human/spawn_result(location, mob/parent)
	if(!amount)
		return
	amount--
	if(ishuman(parent))
		var/mob/living/carbon/human/H = parent

		var/obj/item/stack/sheet/animalhide/A = new result(location)

		if(!isjusthuman(H) && H.species) //Grey skin, unathi skin, etc.
			A.name = H.species.name ? "[lowertext(H.species.name)] skin" : A.name
			A.source_string = H.species.name ? lowertext(H.species.name) : A.source_string
		else
			if(H.mind && H.mind.assigned_role && H.mind.assigned_role != "MODE") //CLOWN LEATHER, ASSISTANT LEATHER, CAPTAIN LEATHER
				A.name = "[lowertext(H.mind.assigned_role)] skin"
				A.source_string = lowertext(H.mind.assigned_role)

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

//--------------Spider legs-------

/datum/butchering_product/spider_legs
	result = /obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg
	verb_name = "remove legs from"
	verb_gerund = "removing legs from"
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

/datum/butchering_product/xeno_claw/desc_modifier()
	if(!amount)
		return "Its claws have been cut off. "

//======frog legs

/datum/butchering_product/frog_leg
	result = /obj/item/weapon/reagent_containers/food/snacks/frog_leg
	verb_name = "remove legs from"
	verb_gerund = "removing legs from"
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
	butcher_time = 2

/datum/butchering_product/hivelord_core/desc_modifier()
	if(!amount)
		return "Its core has been taken. "


//======deer head

/datum/butchering_product/deer_head
	result = /obj/item/deer_head
	verb_name = "remove head"
	verb_gerund = "removing the head from"
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


#define TEETH_FEW		/datum/butchering_product/teeth/few		//4-8
#define TEETH_BUNCH		/datum/butchering_product/teeth/bunch	//8-16
#define TEETH_LOTS		/datum/butchering_product/teeth/lots	//16-24
#define TEETH_HUMAN		/datum/butchering_product/teeth/human	//32

var/global/list/animal_butchering_products = list(
	/mob/living/simple_animal/cat						= list(/datum/butchering_product/skin/cat),
	/mob/living/simple_animal/corgi						= list(/datum/butchering_product/skin/corgi, TEETH_FEW),
	/mob/living/simple_animal/hostile/lizard			= list(/datum/butchering_product/skin/lizard),
	/mob/living/simple_animal/hostile/asteroid/goliath	= list(/datum/butchering_product/skin/goliath, TEETH_LOTS),
	/mob/living/simple_animal/hostile/asteroid/basilisk	= list(/datum/butchering_product/skin/basilisk),
	/mob/living/simple_animal/hostile/asteroid/hivelord	= list(/datum/butchering_product/hivelord_core),
	/mob/living/simple_animal/hostile/giant_spider		= list(/datum/butchering_product/spider_legs),
	/mob/living/simple_animal/hostile/bear				= list(/datum/butchering_product/skin/bear, TEETH_LOTS),
	/mob/living/simple_animal/hostile/bear/spare		= list(/datum/butchering_product/skin/bear/spare, TEETH_LOTS),
	/mob/living/carbon/alien/humanoid					= list(/datum/butchering_product/xeno_claw, /datum/butchering_product/skin/xeno, TEETH_BUNCH),
	/mob/living/simple_animal/hostile/alien				= list(/datum/butchering_product/xeno_claw, /datum/butchering_product/skin/xeno, TEETH_BUNCH), //Same as the player-controlled aliens
	/mob/living/simple_animal/hostile/retaliate/cluwne	= list(TEETH_BUNCH), //honk
	/mob/living/simple_animal/hostile/creature			= list(TEETH_LOTS),
	/mob/living/simple_animal/hostile/frog				= list(/datum/butchering_product/frog_leg),
	/mob/living/simple_animal/hostile/deer				= list(/datum/butchering_product/skin/deer, /datum/butchering_product/deer_head),
	/mob/living/simple_animal/hostile/deer/flesh		= list(/datum/butchering_product/skin/deer, /datum/butchering_product/deer_head),
	/mob/living/carbon/monkey							= list(/datum/butchering_product/skin/monkey, TEETH_FEW),
	/mob/living/simple_animal/rabbit					= list(/datum/butchering_product/rabbit_ears, /datum/butchering_product/rabbit_foot),

	/mob/living/carbon/human							= list(TEETH_HUMAN, /datum/butchering_product/skin/human),
	/mob/living/carbon/human/unathi						= list(TEETH_LOTS, /datum/butchering_product/skin/lizard/lots),
	/mob/living/carbon/human/skrell						= list(TEETH_LOTS),
	/mob/living/carbon/human/skellington				= list(TEETH_HUMAN),
	/mob/living/carbon/human/tajaran					= list(TEETH_HUMAN, /datum/butchering_product/skin/cat/lots),
	/mob/living/carbon/human/dummy						= list(TEETH_HUMAN),

	/mob/living/carbon/complex/gondola				= list(/datum/butchering_product/skin/gondola, TEETH_FEW),
)

#undef TEETH_FEW
#undef TEETH_BUNCH
#undef TEETH_LOTS
#undef TEETH_HUMAN
