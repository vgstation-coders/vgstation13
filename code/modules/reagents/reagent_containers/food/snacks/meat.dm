//The one and only meat, king of foods

/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	food_flags = FOOD_MEAT | FOOD_SKELETON_FRIENDLY
	var/subjectname = ""
	var/subjectjob = null

	var/obj/item/poisonsacs = null //This is what will contain the poison
	New()
		..()
		reagents.add_reagent(NUTRIMENT, 3)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/New(atom/A, var/mob/M)
	..(A)
	if(M)
		if(uppertext(M.name) != "UNKNOWN")
			name = "[M.name] meat"
		subjectname = M.name
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			subjectjob = H.job

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

/obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi
	desc = "Tastes like the tears of the station. Gives off the faint aroma of a valid salad. Just like mom used to make. This revelation horrifies you greatly."

/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = "human meat"

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
	desc = "A fillet of spess carp meat"
	icon_state = "fishfillet"
	New()
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
	New()
		..()
		reagents.add_reagent(CARPOTOXIN, 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	name = "xenomeat"
	desc = "A slab of xeno meat"
	icon_state = "xenomeat"
	New()
		..()
		reagents.add_reagent(NUTRIMENT, 3)
		src.bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	New()
		..()
		poisonsacs = new /obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland
		reagents.add_reagent(NUTRIMENT, 3)
		reagents.add_reagent(TOXIN, 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spiderpoisongland
	name = "venomous spittle sac"
	desc = "The toxin-filled poison sac of a giant spider."
	icon_state = "toxicsac"
	New()
		..()
		reagents.add_reagent(TOXIN, 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	New()
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
	reagents.add_reagent(NUTRIMENT, 5)
	reagents.add_reagent(ROACHSHELL, rand(5,12))
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic
	name = "mimic meat"
	desc = "Woah! You were eating THIS all along?"
	icon_state = "rottenmeat"

	New()
		..()
		reagents.add_reagent(SPACE_DRUGS, rand(0,8))
		reagents.add_reagent(MINDBREAKER, rand(0,2))
		reagents.add_reagent(NUTRIMENT, rand(0,8))
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

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/proc/shapeshift(atom/atom_to_copy = null)
	if(!atom_to_copy)
		atom_to_copy = pick(valid_random_food_types)

	src.appearance = initial(atom_to_copy.appearance) //This works!

/obj/item/weapon/reagent_containers/food/snacks/meat/box
	name = "box meat"
	desc = "I know what you're thinking, but this isn't from a mimic."
	icon_state = "rottenmeat"
	var/amount_cloned = 0

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
