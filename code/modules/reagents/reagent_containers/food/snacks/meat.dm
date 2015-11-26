//The one and only meat, king of foods

/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/attack(mob/living/M, mob/user, def_zone, eat_override = 0)
	..(M,user,def_zone, "eat_override" = 1)

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
	name = " meat" //Griffon McDumbass meat
	var/subjectname = ""
	var/subjectjob = null

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
	name = "raw chicken"
	desc = "This better be delicious."
	icon_state = "raw_chicken"

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat"
	icon_state = "fishfillet"
	New()
		..()
		eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("carpotoxin", 3)
		bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	name = "xenomeat"
	desc = "A slab of xeno meat"
	icon_state = "xenomeat"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("toxin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	New()
		..()
		reagents.add_reagent("nutriment", 12)
		reagents.add_reagent("hyperzine", 5)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic
	name = "mimic meat"
	desc = "Woah! You were eating THIS all along?"
	icon_state = "rottenmeat"

	New()
		..()
		reagents.add_reagent("space_drugs", rand(0,8))
		reagents.add_reagent("mindbreaker", rand(0,2))
		reagents.add_reagent("nutriment", rand(0,8))
		bitesize = 5

		shapeshift()

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchen/rollingpin))
		user.visible_message("<span class='notice'>[user] starts smacking \the [src] with \the [W].</span>", "<span class='info'>You start reshaping \the [src] with \the [W].</span>")

		if(do_after(user, src, 10))
			if(prob(80))
				shapeshift() //Turn into a random foodstuff
			else
				src.appearance = initial(src.appearance) //Turn into "mimic meat"

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/bless()
	visible_message("<span class='info'>\The [src] starts fizzling!</span>")
	spawn(10)
		shapeshift(/obj/item/weapon/storage/bible) //Turn into a bible

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/spook()
	visible_message("<span class='info'>\The [src] transforms into a pile of bones!</span>")
	shapeshift(/obj/effect/decal/remains/human) //Turn into human remains

var/global/list/valid_random_food_types = typesof(/obj/item/weapon/reagent_containers/food/snacks) - typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable) - /obj/item/weapon/reagent_containers/food/snacks

/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/proc/shapeshift(atom/atom_to_copy = null)
	if(!atom_to_copy)
		atom_to_copy = pick(valid_random_food_types)

	src.appearance = initial(atom_to_copy.appearance) //This works!
