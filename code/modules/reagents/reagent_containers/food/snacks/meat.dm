//The one and only meat, king of foods

/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	food_flags = FOOD_MEAT | FOOD_SKELETON_FRIENDLY
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 3
	var/subjectname = ""
	var/meatword = "meat"

	var/obj/item/poisonsacs = null //This is what will contain the poison
	var/sactype

	var/meatcolor //If set, the meat will be colored accordingly (hex string). This can be used to add colored meats for various species without making a new sprite.

/obj/item/weapon/reagent_containers/food/snacks/meat/New(atom/A, var/mob/M)
	..()
	if(M)
		if(uppertext(M.name) != "UNKNOWN")
			name = "[M.name] [meatword]"
		subjectname = M.name

	if(meatcolor) //If meatcolor is set, set the icon_state to meat_colorless and modify the tone.
		icon_state = "meat_colorless"
		var/icon/original = icon(icon, icon_state)
		original.ColorTone(meatcolor)
		icon = original

	if(sactype)
		poisonsacs = new sactype

/obj/item/weapon/reagent_containers/food/snacks/meat/Destroy()
	..()
	if(poisonsacs)
		QDEL_NULL(poisonsacs)

/obj/item/weapon/reagent_containers/food/snacks/meat/animal //This meat spawns when an animal is butchered, and its name is set to '[animal.species_name] meat' (like "cat meat")
	var/animal_name = "animal"
	desc = "A slab of animal meat."

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/monkey
	name = "monkey meat"

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/monkey/New(atom/A, var/mob/M)
	..()

	if(M)
		name = "[initial(M.name)] [meatword]"

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi
	desc = "Tastes like the tears of the station. Gives off the faint aroma of a valid salad. Just like mom used to make. This revelation horrifies you greatly."

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/lizard
	reagents_to_add = list(NUTRIMENT = 3, ACIDSPIT = 2)
	//ACIDSPIT is an alcoholic drink that also cures cockatrice petrification (lizard meat curing petrification is a nethack reference)

/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = "human meat"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/New(atom/A, var/mob/M)
	..()
	if(ishuman(M))
		if(uppertext(M.name) == "UNKNOWN")
			var/mob/living/carbon/human/H = M
			name = "[lowertext(H.species.name)] [meatword]"


/obj/item/weapon/reagent_containers/food/snacks/meat/human/after_consume(var/mob/user, var/datum/reagents/reagentreference)
	if(!user)
		return
	..()

/obj/item/weapon/reagent_containers/food/snacks/meat/human/on_vending_machine_spawn()
	reagents.chem_temp = FRIDGETEMP_FROZEN

/obj/item/weapon/reagent_containers/food/snacks/meat/diona
	name = "leafy meat"
	desc = "It's got an awful lot of protein for a vegetable."
	icon_state = "diona_meat"

/obj/item/weapon/reagent_containers/food/snacks/meat/nymphmeat // Can also be used to make veggie burgers like normal diona meat.
	name = "nymph meat"
	desc = "A chunk of meat from a diona nymph. It looks dense and fibrous."
	icon_state = "nymphmeat"

/obj/item/weapon/reagent_containers/food/snacks/meat/grey
	name = "grey meat"
	desc = "A slab of greyish meat, slightly acidic in taste."
	icon_state = "greymeat"
	reagents_to_add = list(NUTRIMENT = 3, SACID = 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/polyp
	name = "polyp meat"
	desc = "A lump of meat from the top of a polyp's bell. Somewhat salty in taste, but quite nutritious."
	icon_state = "raw_jellyfish"
	reagents_to_add = list(NUTRIMENT = 5, POLYPGELATIN = 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meat/insectoid
	name = "insectoid meat"
	desc = "A slab of gooey, white meat. It's still got traces of hardened chitin."
	icon_state = "insectoidmeat"
	reagents_to_add = list(NUTRIMENT = 3, LITHOTORCRAZINE = 5)

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox
	name = "vox meat"
	desc = "Considering its Avian origin, tastes unsurprisingly like chicken."
	icon_state = "meat_vox"

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
	name = "chicken meat"
	desc = "This better be delicious."
	icon_state = "raw_chicken"
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/raw_vox_chicken
	name = "vox chicken meat"
	desc = "Vox, man. No discussion."
	icon_state = "raw_vox_chicken"
	reagents_to_add = list(NUTRIMENT = 9)

/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat
	name = "crab meat"
	desc = "Something killed the crab, and this is the result."
	icon_state = "raw_crab"
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
	name = "carp fillet"
	desc = "A fillet of space carp meat."
	icon_state = "fishfillet"
	sactype = /obj/item/weapon/reagent_containers/food/snacks/carppoisongland
	reagents_to_add = list(NUTRIMENT = 6, CARPOTOXIN = 3)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/New()
	..()
	eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/imitation/on_vending_machine_spawn()
	reagents.chem_temp = FRIDGETEMP_FROZEN

/obj/item/weapon/reagent_containers/food/snacks/carppoisongland
	name = "venomous spines"
	desc = "The toxin-filled spines of a space carp."
	icon_state = "toxicspine"
	reagents_to_add = list(CARPOTOXIN = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	name = "xenomeat"
	desc = "A slab of xeno meat."
	icon_state = "xenomeat"
	bitesize = 6
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	bitesize = 3
	reagents_to_add = list(NUTRIMENT = 6, TOXIN = 3)
	sactype = /obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland

/obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland
	name = "venomous spittle sac"
	desc = "The toxin-filled poison sac of a giant spider."
	icon_state = "toxicsac"
	bitesize = 3
	reagents_to_add = list(TOXIN = 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	reagents_to_add = list(NUTRIMENT = 15, HYPERZINE = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/roach
	name = "cockroach meat"
	desc = "A cockroach's severed abdomen, small but nonetheless nutritious."
	icon_state = "roachmeat"
	reagents_to_add = list(NUTRIMENT = 3.5)
	bitesize = 5
	var/smolbitofextraroachie = TRUE

/obj/item/weapon/reagent_containers/food/snacks/meat/roach/set_reagents_to_add()
	if(smolbitofextraroachie)
		reagents_to_add[ROACHSHELL] = rand(2,6)

/obj/item/weapon/reagent_containers/food/snacks/meat/roach/on_vending_machine_spawn()
	reagents.chem_temp = FRIDGETEMP_FROZEN

/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big
	name = "mutated cockroach meat"
	desc = "A chunk of meat from an above-average sized cockroach."
	icon_state = "bigroachmeat"
	reagents_to_add = list(NUTRIMENT = 8.5, ROACHSHELL = 16)
	smolbitofextraroachie = FALSE

/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big/isopod
	name = "Isopod meat"
	desc = "A chunk of meat from an isopod."

/obj/item/weapon/reagent_containers/food/snacks/meat/cricket
	name = "cricket meat"
	desc = "Tastes a bit like nuts, very earthy. Not much of a serving, though."
	icon_state = "roachmeat"
	bitesize = 5
	var/smolbitofextrafleur = TRUE

/obj/item/weapon/reagent_containers/food/snacks/meat/cricket/set_reagents_to_add()
	if(smolbitofextrafleur)
		reagents_to_add[FLOUR] = rand(4,10)

/obj/item/weapon/reagent_containers/food/snacks/meat/cricket/big
	name = "creatine cricket meat"
	desc = "An oddly large slab of cricket meat. Tastes like nuts and protein. Very earthy and chewy."
	icon_state = "bigroachmeat"
	reagents_to_add = list(NUTRIMENT = 8, FLOUR = 32)
	smolbitofextrafleur = FALSE

/obj/item/weapon/reagent_containers/food/snacks/meat/cricket/big/king
	name = "cricket king meat"
	desc = "A royal bloodline was felled to make this. Tastes like regicide."
	reagents_to_add = list(NUTRIMENT = 28, FLOUR = 72)

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic
	name = "mimic meat"
	desc = "Woah! You were eating THIS all along?"
	icon_state = "rottenmeat"
	bitesize = 5
	var/transformed = FALSE

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/set_reagents_to_add()
	reagents_to_add = list(NUTRIMENT = 3, SPACE_DRUGS = rand(0,4), MINDBREAKER = rand(0,2), NUTRIMENT = rand(0,4), TOXIN = rand(0,2))

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/refill()
	..()
	shapeshift()

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/bless()
	..()
	visible_message("<span class='info'>\The [src] starts fizzling!</span>")
	spawn(10)
		shapeshift(/obj/item/weapon/storage/bible) //Turn into a bible

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/spook(mob/dead/observer/ghost)
	if(..(ghost, TRUE))
		visible_message("<span class='info'>\The [src] transforms into a pile of bones!</span>")
		shapeshift(/obj/effect/decal/remains/human) //Turn into human remains

var/global/list/valid_random_food_types = existing_typesof(/obj/item/weapon/reagent_containers/food/snacks) - typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/before_consume(mob/target)
	if(transformed)
		//Reference to that winnie pooh comic
		to_chat(target, "<span class='danger'>Sweet Jesus[target.hallucinating() ? ", Pooh" : ""]! That's not [name]!</span>")
		revert()

		spawn(10)
			to_chat(target, "<span class='danger'>You're eating [name]!</span>")

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/preattack(atom/movable/target, mob/user, proximity_flag)
	if(!proximity_flag)
		return

	//Forbid creation of custom foods with mimic meat
	if(transformed)
		if(istype(target, /obj/item/trash/plate) || istype(target, /obj/item/weapon/reagent_containers/food/snacks))
			to_chat(user, "<span class='danger'>\The [name] shapeshifts as it touches \the [target]!</span>")
			revert()

	return ..()

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	if(transformed && istype(destination, /obj/machinery/cooking))
		revert()

	return ..()

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/proc/shapeshift(atom/atom_to_copy = null)
	if(!atom_to_copy)
		atom_to_copy = pick(valid_random_food_types)

	//Prevent layering issues when items are held in hands
	var/prev_layer = src.layer
	var/prev_plane = src.plane

	appearance = initial(atom_to_copy.appearance)

	layer = prev_layer
	plane = prev_plane

	transformed = TRUE

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/proc/revert()
	shapeshift(/obj/item/weapon/reagent_containers/food/snacks/meat/mimic)
	transformed = FALSE

/obj/item/weapon/reagent_containers/food/snacks/meat/box
	name = "box meat"
	desc = "I know what you're thinking, but this isn't from a mimic."
	icon_state = "rottenmeat"
	var/amount_cloned = 0

/obj/item/weapon/reagent_containers/food/snacks/meat/box/pig
	name = "pork"
	desc = "A slab of pig meat."
	icon_state = "meat"
	gender = PLURAL

/obj/item/weapon/reagent_containers/food/snacks/meat/hive
	name = "alien tissue"
	desc = "A long piece of rough, black tissue."
	icon_state = "hivemeat"

/obj/item/weapon/reagent_containers/food/snacks/meat/hive/set_reagents_to_add()
	reagents_to_add = list(NUTRIMENT = 3, CARBON = 5, pick(IRON, GOLD, SILVER, URANIUM) = rand(0,5))

/obj/item/weapon/reagent_containers/food/snacks/meat/hive/turret/set_reagents_to_add()
	..()
	reagents_to_add += list(OXYGEN = rand(1,5), ETHANOL = rand(1,5))

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/cockatrice
	name = "cockatrice meat"
	desc = "A slab of cockatrice meat. It may still contain traces of a cockatrice's venom, making it very unsafe to eat."
	reagents_to_add = list(NUTRIMENT = 3, PETRITRICIN = 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/wendigo
	name = "strange meat"
	desc = "Doesn't look very appetizing, but if you're considerably hungry..."
	icon_state = "wendigo_meat"
	bitesize = 30

/obj/item/weapon/reagent_containers/food/snacks/meat/wendigo/set_reagents_to_add()
	reagents_to_add = list(NUTRIMENT = rand(13,28))

/obj/item/weapon/reagent_containers/food/snacks/meat/wendigo/consume(mob/living/carbon/eater, messages = 0)
	. = ..()
	if(ishuman(eater))
		var/mob/living/carbon/human/H = eater
		H.infect_disease2_predefined(DISEASE_WENDIGO, 1, "Wendigo Meat")

/obj/item/weapon/reagent_containers/food/snacks/meat/slime
	name = "gelatin"
	desc = "A slab of gelatin. It has a similar composition to regular meat but with a bit more jelly."
	icon_state = "slime_meat"
	meatword = "gelatin"
	reagents_to_add = list(NUTRIMENT = 3, SLIMEJELLY = 10)

/obj/item/weapon/reagent_containers/food/snacks/meat/snail
	icon_state = "snail_meat"
	name = "snail meat"
	desc = "How uncivilised! You cannot be expected to eat that without cooking it, mon Dieu!"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/meat/gingerbroodmother
	name = "Royal Gingjelly"
	icon_state = "royal_gingjelly"
	desc = "The sickly sweet smell wafting from this sticky glob triggers some primal fear. You absolutely should not eat this."
	reagents_to_add = list(NUTRIMENT = 13, CARAMEL = 10)

/obj/item/weapon/reagent_containers/food/snacks/meat/gingerbroodmother/consume(mob/living/carbon/eater, messages = 0)

	if(ishuman(eater))

		var/mob/living/carbon/C = eater

		if(C.monkeyizing)
			return
		to_chat(eater, "<span class='warning'>Your flesh hardens and your blood turns to frosting. This is agony!</span>")
		sleep (30)
		C.monkeyizing = 1
		C.canmove = 0
		C.icon = null
		C.overlays.len = 0
		C.invisibility = 101
		for(var/obj/item/W in C)
			if(istype(W, /obj/item/weapon/implant))
				var/obj/item/weapon/implant/I = W
				if(I.imp_in == C)
					qdel(W)
					continue
			W.reset_plane_and_layer()
			W.forceMove(C.loc)
			W.dropped(C)
		var/mob/living/simple_animal/hostile/ginger/gingerbomination/new_mob = new /mob/living/simple_animal/hostile/ginger/gingerbomination(C.loc)
		new_mob.a_intent = I_HURT
		if(C.mind)
			C.mind.transfer_to(new_mob)
		else
			new_mob.key = C.key
		C.transferBorers(new_mob)
		qdel(C)
		playsound(src, 'sound/effects/evolve.ogg', 100, 1)

/obj/item/weapon/reagent_containers/food/snacks/meat/plasmaman
	name = "plasmaman meat"
	desc = "A charred, dry piece of what you think is meant to be meat. It smells burnt."
	icon_state = "plasmaman_meat"
	reagents_to_add = list(NUTRIMENT = 5.5, PLASMA = 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/grue/
	name = "grue meat"
	desc = "Considered a delicacy by some, the edibility of this meat has long been a subject of debate amongst discerning gourmands."
	meatcolor = GRUE_BLOOD
	reagents_to_add = list(NUTRIMENT = 3, GRUE_BILE = 5)

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/dan
	name = "meat"
	desc = "A slab of \"meat\". Something's a little strange about this one."

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/dan/set_reagents_to_add()
	//A new blend of meat in every slab! Can be better than or worse than normal meat.
	reagents_to_add = list()
	//No room for normal meat chems in here. We're going full DAN
	for(var/blendedmeat = 1 to 3)
		switch(rand(1,3))
			if(1)
				reagents_to_add[NUTRIMENT] += 1 //15 nutrition
			if(2)
				reagents_to_add[BEFF] += rand(3,8) //6-16
			if(3)
				reagents_to_add[HORSEMEAT] += rand(3,6) //9-18
	if(prob(75))
		reagents_to_add[BONEMARROW] = rand(1,3) //0-3
	if(prob(5))
		reagents_to_add[ROACHSHELL] = 1 //Sometimes a roach gets in. No nutritional value
	//Total ranging from 18 to 57 nutrition. Normal meat provides 45.

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/dan/on_vending_machine_spawn()
	reagents.chem_temp = FRIDGETEMP_FROZEN

/obj/item/weapon/reagent_containers/food/snacks/meat/blob
	name = "blob meat"
	desc = "A slab of glowing meat hacked off of a greater part. It has a spongy feel to it."
	icon_state = "blob_meat"
	origin_tech = Tc_BIOTECH + "=2"
	throw_impact_sound = 'sound/effects/attackblob.ogg'
	reagents_to_add = list(NUTRIMENT = 8, BLOBANINE = 5)

/obj/item/weapon/reagent_containers/food/snacks/meat/blob/blob_act()
	// Blobs ignore their own parts

/obj/item/weapon/reagent_containers/food/snacks/meat/blob/core
	name = "blob core meat"
	desc = "A piece of a blob's core. It pulsates wildly."
	icon_state = "blob_core_meat"
	origin_tech = Tc_BIOTECH + "=6"
	reagents_to_add = list(NUTRIMENT = 18, BLOBANINE = 5, BLOB_ESSENCE = 1)

/obj/item/weapon/reagent_containers/food/snacks/meat/scraps
	name = "meat scraps"
	desc = "Some leftover scraps of meat, probably trimmed off a bigger slab."
	icon_state = "meat_scraps"
	reagents_to_add = list(NUTRIMENT = 2) // A bit less nutriment

/obj/item/weapon/reagent_containers/food/snacks/meat/borer
	name = "borer"
	desc = "It's still twitching slightly."
	icon_state = "slug0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/mob_holders.dmi', "right_hand" = 'icons/mob/in-hand/right/mob_holders.dmi')
	item_state = "borer"
	crumb_icon = "dribbles"
	reagents_to_add = list(NUTRIMENT = 3, GREYGOO = 1, PERIDAXON = 1) //yes you will eat the slugs for their valuable nutrients
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meat/borer/after_consume(mob/user, datum/reagents/reagentreference)
	..()
	icon_state = "slug[min(bitecount,2)]"
	if(bitecount == 1)
		desc = pick("Whichever nerves were keeping it wriggling have been ripped off by now.", "It's a lot more foul smelling once you bite into it.", "There's some slimy substance leaking out of it.", "Was this really a good idea?")
	else
		desc = pick("There's barely anything left of it.", "It could have lived happily in your brain, you know.", "It was only here to help.", "Poor thing.", "You monster.", "At least it's nutritious.")

/obj/item/weapon/reagent_containers/food/snacks/meat/bullmeat
	name = "carne de lidia"
	desc = "En algunos lugares, la tauromaquia es incruenta. Aqui no."
	icon_state = "bearmeat"
	reagents_to_add = list(NUTRIMENT = 15, BICARIDINE = 5)
	bitesize = 3
