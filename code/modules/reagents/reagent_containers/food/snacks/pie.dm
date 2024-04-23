
/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET
	reagents_to_add = list(NUTRIMENT = 4, BANANA = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom)
	set waitfor = FALSE
	if(..())
		return
	if(ismob(hit_atom))
		var/mob/M = hit_atom
		src.visible_message("<span class='warning'>\The [src] splats in [M]'s face!</span>")

		var/race_prefix = ""
		if (isvox(M))
			race_prefix = "vox"
		else if (isgrey(M))
			race_prefix = "grey"
		else if (isinsectoid(M))
			race_prefix = "insect"

		M.eye_blind = 2
		M.overlays += image('icons/mob/messiness.dmi',icon_state = "[race_prefix]pied")
		sleep(55)
		M.overlays -= image('icons/mob/messiness.dmi',icon_state = "[race_prefix]pied")
		M.overlays += image('icons/mob/messiness.dmi',icon_state = "[race_prefix]pied-2")
		sleep(120)
		M.overlays -= image('icons/mob/messiness.dmi',icon_state = "[race_prefix]pied-2")

		if(luckiness)
			M.luck_adjust(luckiness, temporary = TRUE)

	if(isturf(hit_atom))
		new/obj/effect/decal/cleanable/pie_smudge(src.loc)
		if(trash)
			new trash(src.loc)
		playsound(src, pick('sound/effects/splat_pie1.ogg','sound/effects/splat_pie2.ogg'), 100, 1)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/pie/empty //so the H.O.N.K. cream pie mortar can't generate free nutriment
	trash = null
/obj/item/weapon/reagent_containers/food/snacks/pie/empty/New()
	..()
	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/pie/clovercreampie
	name = "whipped clover pie"
	desc = "Traditional dish in the Clownplanet's Irish exclusion zone."
	icon_state = "clovercreampie"
	reagents_to_add = list(NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/pie/clovercreampie/New()
	if(prob(25))
		reagents_to_add = list(NUTRIMENT = 8) //Lucky pie is more nutritious
		desc = "The pie was blessed by Saint Honktrick!"
	..()

/obj/item/weapon/reagent_containers/food/snacks/pie/caramelpie
	name = "caramel pie"
	desc = "A sweet pie made with caramel."
	icon_state = "pie"
	reagents_to_add = list(NUTRIMENT = 4, CARAMEL = 3)

/obj/item/weapon/reagent_containers/food/snacks/explosive_pie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	reagents_to_add = list(NUTRIMENT = 2, BANANA = 3)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/explosive_pie/examine(mob/user)
	..()
	if(is_holder_of(user,src))
		to_chat(user, "<span class='info'><b>When inspected hands-on,</b> the [src] feels heavier than normal and seems to be ticking.</span>")

/obj/item/weapon/reagent_containers/food/snacks/explosive_pie/after_consume(mob/user)
	explosion(get_turf(user), -1, 0, 0, 3)
	user.gib()
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/explosive_pie/throw_impact(atom/hit_atom)
	set waitfor = FALSE
	if(ismob(hit_atom))
		var/mob/M = hit_atom
		src.visible_message("<span class='warning'>\The [src] explodes in [M]'s face!</span>")
		explosion(get_turf(M), -1, 0, 1, 3)
		qdel(src)

	if(isturf(hit_atom))
		explosion(get_turf(hit_atom), -1, 0, 1, 3)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/pie/meatpie
	name = "Meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/tofupie
	name = "Tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	reagents_to_add = list(NUTRIMENT = 5, AMATOXIN = 3, PSILOCYBIN = 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie/New()
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		reagents_to_add += list(TRICORDRAZINE = 5)
	..()

/obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie
	name = "Xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"
	food_flags = FOOD_SWEET
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	food_flags = FOOD_SWEET
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/mincepie
	name = "mincepie"
	desc = "Contains no children."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "mincepie"
	food_flags = FOOD_SWEET | FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie //You can't throw this pie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 15)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cloverpie
	name = "clover cream pie"
	desc = "A creamy, sweet dessert with herbal notes that recall open fields and verdant pastures."
	icon_state = "cloverpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cloverpieslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 15)

/obj/item/weapon/reagent_containers/food/snacks/cloverpieslice
	name = "clover cream pie slice"
	desc = "Nothing says springtime like a slice of clover cream pie... maybe."
	icon_state = "cloverpieslice"
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/pie/asspie
	name = "asspie"
	desc = "Please remember to check your privilege, pie eating scum."
	icon_state = "asspie"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 4, MINDBREAKER = 10, MERCURY = 10) // Screaming // Idiot
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cinnamonpie
	name = "cinnamon pie"
	desc = "Guarranted snail-free!"
	icon_state = "cinnamon_pie"
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 6, CINNAMON = 5)
	bitesize = 3
