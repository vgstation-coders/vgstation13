//15+2+7 = 27
var/global/list/chef_stuff = list(
	//two of a kind
	/obj/item/fish_eggs/seadevil,/obj/item/fish_eggs/seadevil, //fish_items.dm
	//one of a kind
	/obj/item/weapon/vinyl/echoes) //media/jukebox.dm

/obj/structure/closet/crate/freezer/zincsaucier
	name = "Zinc Saucier's crate"
	desc = "Experimental service equipment from the famous gameshow 'Zinc Saucier'. Considered a lesser title by some, but it has double prize money."

/obj/structure/closet/crate/freezer/zincsaucier/New()
	..()
	for(var/i = 1 to 3)
		if(!chef_stuff.len)
			return
		var/path = pick_n_take(chef_stuff)
		new path(src)

var/list/sushi_recipes = list()
var/list/acceptible_sushi_inputs = list()
/obj/item/sushimat
	name = "bottomless sushi mat"
	desc = "Since the 1800s, top researchers, clowns, and magicians have known that there are alternate dimensions full of one object repeated forever. Previously this was thought to be limited to just dimensions of colorful handkerchiefs, doves, etc. -- but this mat connects to limitless rice to feed your sushi addiction."
	w_class = W_CLASS_LARGE
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "sushimat"
	var/lastroll = 0

/obj/item/sushimat/New()
	..()
	if (!sushi_recipes.len)
		for (var/type in subtypesof(/datum/recipe))
			var/validrecipe = new type
			if(validrecipe.items != 2)
				qdel(validrecipe)
				continue //More than just boiled rice + something
			if(!(/obj/item/weapon/reagent_containers/food/snacks/boiledrice in validrecipe.items))
				qdel(validrecipe)
				continue //Boiled rice is not in recipe
			//Edit the recipe for the mat to no longer require rice
			validrecipe.items -= /obj/item/weapon/reagent_containers/food/snacks/boiledrice
			sushi_recipes += validrecipe
	for (var/datum/recipe/recipe in sushi_recipes)
		for (var/item in recipe.items)
			acceptible_sushi_inputs += item

#define FLICKFRAMES 11
/obj/item/sushimat/attackby(obj/item/I, mob/user)
	if(!(I.type in acceptable_items))
		return ..()
	else
		if(lastroll + FLICKFRAMES < world.time)
			return
		for(var/datum/recipe/R in sushi_recipes)
			if(istype(I, R.items[1])) //Compare to the only remaining item in the recipe
				flick("sushimat-flickfast")
				playsound(loc, 'sound/effects/bamboo_rattle.ogg', 75, 1, -1)
				visible_message("<span class='notice'>[user] rolls the sushi!</span>")
				qdel(I)
				spawn(FLICKFRAMES)
					new R.result(loc)
#undef FLICKFRAMES

/obj/item/cricketfarm
	name = "cricket farm"
	desc = "Contains space crickets. Feeder, terrarium, and grinder all in one. Just don't tip it over."
	w_class = W_CLASS_HUGE
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "cricketfarm"
	var/population = 0
	var/eggs = 2

/obj/item/cricketfarm/New()
	processing_objects += src

/obj/item/cricketfarm/Destroy()
	processing_objects -= src

/obj/item/cricketfarm/examine(mob/user)
	to_chat(user,"<span class='info'>Use help intent to pick up. Use disarm or grab intent to swap modes. Use harm intent or alt-click to grind crickets.</span>")

/obj/item/cricketfarm/update_icon()
	var/adj
	switch(population)
		if(17 to 20)
			adj = "-high"
		if(12 to 16)
			adj = "-mid"
		if(7 to 11)
			adj = "-low"
	icon = "cricketfarm[adj]"

/obj/item/cricketfarm/attack_hand(mob/user)
	if(isturf(loc) && user.a_intent != I_HELP)
		if(!usr.Adjacent(src) || usr.incapacitated())
			return
		if(user.a_intent == I_HURT)
			makefood(user)
		else
			flourmode = !flourmode
			to_chat(user,"<span class='notice'>You set \the [src] to make [flourmode : "flour" ? "meat"].</span>")
	else
		..()

/obj/item/cricketfarm/AltClick(mob/user)
	if((!usr.Adjacent(src) || usr.incapacitated()) && !isAdminGhost(usr))
		makefood(user)

/obj/item/cricketfarm/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = I
		if(istype(H.stored_mob,/mob/living/simple_animal/cricket))
			qdel(H.stored_mob)
			qdel(H)
			population++
			update_icon()
			return
	else if(istype(/obj/item/weapon))
		escape()
	else
		..()

/obj/item/cricketfarm/process()
	if(population < 2)
		processing_objects -= src
		return
	if(prob(population*4))
		playsound(src, 'sound/effects/cricket_chirp.ogg', 10, 1)
	if(eggs) //Hatch one egg
		eggs--
		population++
		update_icon()
	if(eggs<100)
		for(var/i = 1 to round(population/2)) //For each complete breeding pair, 15% chance per tick to lay 1-5 eggs
			if(prob(15))
				eggs += rand(1,5)

/obj/item/cricketfarm/throw_at(var/atom/targ, var/range, var/speed, var/override = 1, var/fly_speed = 0)
	..()
	escape()

/obj/item/cricketfarm/throw_impact(atom/hit_atom, var/speed, mob/user)
	..()
	escape()

/obj/item/cricketfarm/kick_act(mob/user)
	..()
	escape()

/obj/item/cricketfarm/SlipDropped(var/mob/living/user, var/slip_dir, var/slipperiness = TURF_WET_WATER)
	..()
	escape()

/obj/item/cricketfarm/proc/escape()
	playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
	visible_message("<span class='warning'>The lid on \the [src] clatters unevenly!</span>")
	if(animal_count[/mob/living/simple_animal/cricket] < 20) && population>0)
		for(var/i = 1 to max(rand(2,4),round(population/3)+rand(-1,1)))
			new /mob/living/simple_animal/cricket(loc)
			population--
	update_icon()

/obj/item/cricketfarm/proc/makefood(mob/user)
	if(population+eggs<7 || !population)
		if(user)
			to_chat(user,"<span class='notice'>The crickets need more time to populate.</span>")
		return
	playsound(src, 'sound/machines/blenderfast.ogg', 50, 1)
	if(flourmode == FALSE)
		for(var/i= 1 to min(5,population))
			new /obj/item/weapon/reagent_containers/food/snacks/meat/cricket(loc)
			population--
	else
		population -= 5
		var/obj/item/weapon/reagent_containers/food/condiment/C = new(loc)
		C.reagents.add_reagent(FLOUR,10*min(5,population))
