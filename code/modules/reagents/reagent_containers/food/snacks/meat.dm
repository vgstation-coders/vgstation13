//The one and only meat, king of foods

/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	food_flags = FOOD_MEAT | FOOD_SKELETON_FRIENDLY
	var/subjectname = ""
	var/meatword = "meat"

	var/obj/item/poisonsacs = null //This is what will contain the poison

/obj/item/weapon/reagent_containers/food/snacks/meat/New(atom/A, var/mob/M)
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 3
	if(M)
		if(uppertext(M.name) != "UNKNOWN")
			name = "[M.name] [meatword]"
		subjectname = M.name

/obj/item/weapon/reagent_containers/food/snacks/meat/Destroy()
	..()
	if(poisonsacs)
		qdel(poisonsacs)
		poisonsacs = null

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

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/lizard/New()
	..()

	//ACIDSPIT is an alcoholic drink that also cures cockatrice petrification (lizard meat curing petrification is a nethack reference)
	reagents.add_reagent(ACIDSPIT, 2)

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
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(isgrue(H))
			H.adjustOxyLoss(-50)
			H.heal_organ_damage(50, 0)
			H.heal_organ_damage(0, 50)
			H.adjustToxLoss(-50)
	..()

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

/obj/item/weapon/reagent_containers/food/snacks/meat/grey/New()
	..()
	reagents.add_reagent(SACID, 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/insectoid
	name = "insectoid meat"
	desc = "A slab of gooey, white meat. It's still got traces of hardened chitin."
	icon_state = "insectoidmeat"

/obj/item/weapon/reagent_containers/food/snacks/meat/insectoid/New()
	..()
	reagents.add_reagent(LITHOTORCRAZINE, 5)

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox
	name = "vox meat"
	desc = "Considering its Avian origin, tastes unsurprisingly like chicken."
	icon_state = "meat_vox"

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
	name = "chicken meat"
	desc = "This better be delicious."
	icon_state = "raw_chicken"

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat
	name = "crab meat"
	desc = "Something killed the crab, and this is the result."
	icon_state = "raw_crab"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
	name = "carp fillet"
	desc = "A fillet of space carp meat."
	icon_state = "fishfillet"

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/New()
	..()
	poisonsacs = new /obj/item/weapon/reagent_containers/food/snacks/carppoisongland
	eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(CARPOTOXIN, 3)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

/obj/item/weapon/reagent_containers/food/snacks/carppoisongland
	name = "venomous spines"
	desc = "The toxin-filled spines of a space carp."
	icon_state = "toxicspine"
/obj/item/weapon/reagent_containers/food/snacks/carppoisongland/New()
	..()
	reagents.add_reagent(CARPOTOXIN, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	name = "xenomeat"
	desc = "A slab of xeno meat."
	icon_state = "xenomeat"
/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	src.bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"

/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat/New()
	..()
	poisonsacs = new /obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland
	reagents.add_reagent(NUTRIMENT, 3)
	reagents.add_reagent(TOXIN, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland
	name = "venomous spittle sac"
	desc = "The toxin-filled poison sac of a giant spider."
	icon_state = "toxicsac"

/obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland/New()
	..()
	reagents.add_reagent(TOXIN, 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"

/obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat/New()
	..()
	reagents.add_reagent(NUTRIMENT, 12)
	reagents.add_reagent(HYPERZINE, 5)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/roach
	name = "cockroach meat"
	desc = "A cockroach's severed abdomen, small but nonetheless nutritious."
	icon_state = "roachmeat"

/obj/item/weapon/reagent_containers/food/snacks/meat/roach/New()
	..()
	reagents.add_reagent(NUTRIMENT, 0.5)
	reagents.add_reagent(ROACHSHELL, rand(2,6))
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big
	desc = "A chunk of meat from an above-average sized cockroach."
	icon_state = "bigroachmeat"

/obj/item/weapon/reagent_containers/food/snacks/meat/roach/big/New()
	..()
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(ROACHSHELL, 16)

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic
	name = "mimic meat"
	desc = "Woah! You were eating THIS all along?"
	icon_state = "rottenmeat"
	var/transformed = FALSE

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/New()
	..()
	reagents.add_reagent(SPACE_DRUGS, rand(0,4))
	reagents.add_reagent(MINDBREAKER, rand(0,2))
	reagents.add_reagent(NUTRIMENT, rand(0,4))
	reagents.add_reagent(TOXIN, rand(0,2))
	bitesize = 5

	shapeshift()

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/bless()
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

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/forceMove(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0, from_tp = 0)
	if(transformed && istype(NewLoc, /obj/machinery/cooking))
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

/obj/item/weapon/reagent_containers/food/snacks/meat/hive/New()
	..()

	reagents.add_reagent(CARBON, 5)
	reagents.add_reagent(pick(IRON, GOLD, SILVER, URANIUM), rand(0,5))

/obj/item/weapon/reagent_containers/food/snacks/meat/hive/turret/New()
	..()

	reagents.add_reagent(OXYGEN, rand(1,5))
	reagents.add_reagent(ETHANOL, rand(1,5))

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/cockatrice
	name = "cockatrice meat"
	desc = "A slab of cockatrice meat. It may still contain traces of a cockatrice's venom, making it very unsafe to eat."

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/cockatrice/New()
	..()

	reagents.add_reagent(PETRITRICIN, 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/wendigo
	name = "strange meat"
	desc = "Doesn't look very appetizing, but if you're considerably hungry..."
	icon_state = "wendigo_meat"
	bitesize = 30

/obj/item/weapon/reagent_containers/food/snacks/meat/wendigo/New()
	..()
	reagents.add_reagent(NUTRIMENT, rand(10,25))


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

/obj/item/weapon/reagent_containers/food/snacks/meat/slime/New()
	..()
	reagents.add_reagent(SLIMEJELLY, 10)


/obj/item/weapon/reagent_containers/food/snacks/meat/snail
	icon_state = "snail_meat"
	name = "snail meat"
	desc = "How uncivilised ! You cannot be expected to eat that without cooking it, mon Dieu !"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')

/obj/item/weapon/reagent_containers/food/snacks/meat/snail/New()
	. = ..()
	reagents.add_reagent(NUTRIMENT,5)

/obj/item/weapon/reagent_containers/food/snacks/meat/gingerbroodmother
	name = "Royal Gingjelly"
	icon_state = "royal_gingjelly"
	desc = "The sickly sweet smell wafting from this sticky glob triggers some primal fear. You absolutely should not eat this."

/obj/item/weapon/reagent_containers/food/snacks/meat/gingerbroodmother/New()
	..()
	reagents.add_reagent(NUTRIMENT, 10)
	reagents.add_reagent (CARAMEL, 10)

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

/obj/item/weapon/reagent_containers/food/snacks/meat/plasmaman/New()
	..()
	reagents.remove_reagent(NUTRIMENT, 2.5)
	reagents.add_reagent(PLASMA, 5)
	bitesize = 1
