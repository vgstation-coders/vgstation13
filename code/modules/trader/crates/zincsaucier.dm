//6+4+8 = 18
var/global/list/chef_stuff = list(
	//three of a kind
	/obj/item/clothing/glasses/hud/hydro,/obj/item/clothing/glasses/hud/hydro,/obj/item/clothing/glasses/hud/hydro,
	/obj/item/weapon/storage/bag/plants/reaper,/obj/item/weapon/storage/bag/plants/reaper,/obj/item/weapon/storage/bag/plants/reaper,
	//two of a kind
	/obj/item/fish_eggs/seadevil,/obj/item/fish_eggs/seadevil, //fish_items.dm
	/obj/item/apiary/langstroth,/obj/item/apiary/langstroth,
	//one of a kind
	/obj/item/weapon/vinyl/echoes, //media/jukebox.dm
	/obj/item/sushimat,
	/obj/structure/dishwasher,
	/obj/item/cricketfarm,
	/obj/structure/bed/chair/vehicle/mower,
	//teppanyaki
	//dartboard
	/obj/item/weapon/reagent_containers/glass/mantinivessel
	)

/obj/structure/closet/crate/freezer/zincsaucier
	name = "Zinc Saucier's crate"
	desc = "Experimental service equipment from the famous gameshow 'Zinc Saucier'. Considered a lesser title by some, but it has double prize money."

/obj/structure/closet/crate/freezer/zincsaucier/New()
	..()
	for(var/i = 1 to 6)
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

/obj/structure/dishwasher
	name = "vacuum dishwasher"
	desc = "It washes and repairs dishes, drawing them in from a distance. You can fit it on a table."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "dishwasher"
	pass_flags = PASSTABLE
	anchored = FALSE
	var/effective_range = 7
	var/active = FALSE

/obj/structure/dishwasher/New()
	..()
	processing_objects += src

/obj/structure/dishwasher/Destroy()
	processing_objects -= src
	..()

/obj/structure/dishwasher/attackby(obj/item/I, mob/user)
	if(iswrench(I))
		wrenchAnchor(user,I, 4 SECONDS)
	else if(istype(O, /obj/item/trash/plate) || istype(O, /obj/effect/decal/cleanable/broken_plate))
		handle(I)
	else
		..()

/obj/structure/dishwasher/attack_hand(mob/user)
	if(!usr.Adjacent(src) || usr.incapacitated())
		return
	if(!anchored)
		to_chat(user,"<span class='warning'>\The [src] needs to be anchored first!<span>")
		return
	active = !active
	to_chat(user,"<span class='notice'>You toggle \the [src] [active ? "on" : "off"].</span>")

/obj/structure/dishwasher/process()
	var/pulled = FALSE
	for(var/obj/effect/decal/cleanable/broken_plate/BP in oview(effective_range, src))
		pull(BP)
		pulled = TRUE
	for(var/obj/item/trash/plate/P in oview(effective_range,src))
		if(P.clean)
			continue
		pull(P)
		pulled = TRUE
	if(pulled)
		playsound(src, 'sound/effects/vacuum.ogg', 25, 1)

/obj/structure/dishwasher/PreImpact(atom/movable/mover, speed)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/O = mover
		if(!istype(O, /obj/item/trash/plate) && !istype(O, /obj/effect/decal/cleanable/broken_plate))
			return
		O.throwing = FALSE
		handle(O)
		return TRUE //This halts the object without smashing it
	else
		return FALSE

/obj/structure/dishwasher/proc/pull(atom/movable/AM)
	AM.throw_at(src,7,3)

/obj/structure/dishwasher/proc/handle(obj/O)
	var/obj/item/trash/plate/potential_stack = pref_stack()
	var/obj/item/trash/plate/P
	if(istype(O, /obj/item/trash/plate)
		P = O
	else if(istype(O, /obj/effect/decal/cleanable/broken_plate))
		qdel(O)
		P = new(src)
	else
		return
	if(potential_stack)
		P.forceMove(potential_stack)
		potential_stack += P
	else
		P.forceMove(loc)

/obj/structure/dishwasher/proc/pref_stack()
	for(var/obj/item/trash/plate/P in loc)
		if(P.plates.len >= 9)
			continue
		return P //return any plate with less than 9 plates stacked in it
	//otherwise return null

/obj/item/clothing/glasses/hud/hydro
	name = "hydroHUD"
	icon_state = "hydrohud"
	//species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	desc = "A heads-up display that displays information on plants and farm animals."
	perscription = TRUE

/obj/item/clothing/glasses/hud/hydro/process_hud(var/mob/M)
	if(harm_labeled < min_harm_label)
		process_hydro_hud(M)

/obj/item/weapon/storage/bag/plants/reaper
	name = "reaper bag"
	desc = "A plantbag with a built in miniscythe. It's farmerific!"
	sharpness_flags = SHARP_BLADE|SERRATED_BLADE
	sharpness = 1

/obj/structure/bed/chair/vehicle/mower
	name = "ride mower"
	desc = "A precision mower. It can make quick work of vine outbreaks, but its blades have the accuracy for weed removal from trays, too."
	icon_state = "tractor"
	can_have_carts = TRUE
	headlights = TRUE

/obj/machinery/portable_atmospherics/hydroponics/Crossed(var/atom/movable/AM)
	if(istype(AM,/obj/structure/bed/chair/vehicle/mower))
		weedlevel = 0

/obj/effect/plantsegment/Crossed(var/atom/movable/AM)
	if(istype(AM,/obj/structure/bed/chair/vehicle/mower))
		die_off()

/obj/item/weapon/reagent_containers/glass/mantinivessel
	name = "enchanted vessel"
	desc = "Now that's a fancy cup - is that a scratched off Wizard Federation sigil? It really calls out for a martini, though."
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "mantinivessel"

/obj/item/weapon/reagent_containers/glass/mantinivessel/on_reagent_change()
	if(reagents.has_any_reagents(list(MARTINI,VODKAMARTINI,SAKEMARTINI,ESPRESSOMARTINI,DRIESTMARTINI)))
		playsound(src,'sound/items/butterflyknife.ogg', 50, 1)
		var/turf/T = get_turf(src)
		T.turf_animation('icons/effects/effects.dmi',"butterfly_out")
		visible_message("<span class='notice'>\The [src] stands up!</span>")
		new /mob/living/simple_animal/hostile/mantini(T)
		qdel(src)
	..()

/mob/living/simple_animal/hostile/mantini
	name = "mantini"
	desc = "Your ever-loyal magical barmans' aide."
	icon = 'icons/mob/hostile_humanoid.dmi'
	faction = "neutral"
	stop_automated_movement_when_pulled = TRUE
	environment_smash_flags = FALSE
	icon_state = "mantini"
	icon_living = "mantini"
	speak_emote = list("clinks")
	speak_chance = 2
	turns_per_move = 5
	response_help  = "shakes the hand of"
	response_disarm = "shoves"
	response_harm   = "kicks"
	min_oxy = 0
	minbodytemp = 0
	maxbodytemp = MELTPOINT_STEEL
	search_objects = 3 //ignore mobs entirely

/mob/living/simple_animal/hostile/mantini/CanAttack(var/atom/the_target)
	if(see_invisible < the_target.invisibility)
		return FALSE
	if(istype(the_target, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass)
		var/obj/item/weapon/reagent_containers/D = the_target
		if(isturf(D.loc) && D.is_empty())
			return TRUE
	return FALSE

/mob/living/simple_animal/hostile/mantini/AttackingTarget()
	if(istype(target,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/weapon/reagent_containers/D = target
		D.reagents.add_reagent(MARTINI,30)
	else
		..()

/mob/living/simple_animal/hostile/mantini/FindHidden(var/atom/hidden_target)
	return FALSE



/obj/item/apiary/langstroth
	name = "\improper Langstroth hive"
	desc = "A vertically-modular tray-based apiary. You can simply reach in with your hand and smokers will protect you while you harvest honeycombs."
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "langstroth_item"
	buildtype = /obj/machinery/apiary/langstroth
