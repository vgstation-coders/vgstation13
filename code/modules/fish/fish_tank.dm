#define FOOD_OK 5
#define BREEDING_THRESHOLD 2
#define FILTH_THRESHOLD 5
#define ALGAE_THRESHOLD 7.5
#define MAX_FOOD 10
#define MAX_FILTH 10

#define NO_LEAK 0
#define MINOR_LEAK 1
#define MAJOR_LEAK 2

// Layers
#define WATER_LAYER FLOAT_LAYER-1
#define FISH_LAYER FLOAT_LAYER-5

#define FISH_BOWL "bowl"
#define FISH_TANK "tank"
#define FISH_WALL "wall"

//////////////////////////////
//		Fish Tanks!			//
//////////////////////////////

// Made by FalseIncarnate on Paradise
// Ported to /vg/ by Shifty and jakmak(s)
// Fish Bowl construction moved to code/game/machinery/constructable_frame.dm

/obj/machinery/fishtank
	name = "placeholder tank"
	desc = "So generic, it might as well have no description at all."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "tank1"
	density = FALSE
	anchored = FALSE
	throwpass = FALSE
	var/circuitboard = null		// The circuitboard to eject when deconstructed

	var/tank_type = ""			// Type of aquarium, used for icon updating
	var/water_capacity = 0		// Number of units the tank holds (varies with tank type)
	var/water_level = 0			// Number of units currently in the tank (new tanks start empty)
	var/light_switch = FALSE	// FALSE = off, TRUE = on (off by default)
	var/filth_level = 0.0		// How dirty the tank is (max 10)
	var/lid_switch = FALSE		// FALSE = open, TRUE = closed (open by default)
	var/max_fish = 0			// How many fish the tank can support (varies with tank type, 1 fish per 50 units sounds reasonable)
	var/food_level = 0			// Amount of fishfood floating in the tank (max 10)
	var/list/fish_list_water = list()	// Tracks the current types of fish in the tank
	var/list/fish_list_acidic = list()
	var/list/fish_list = list()
	var/list/egg_list = list()	// Strings containing egg.fish_type

	var/has_lid = FALSE			// FALSE if the tank doesn't have a lid/light, TRUE if it does
	var/leaking = NO_LEAK
	var/shard_count = 0			// Number of glass shards to salvage when broken (1 less than the number of sheets to build the tank)
	var/automated = 0			// Cleans the aquarium on its own
	var/acidic = FALSE

/obj/machinery/fishtank/bowl
	name = "fish bowl"
	desc = "A small bowl capable of housing a single fish, commonly found on desks. This one has a tiny treasure chest in it!"
	icon_state = "bowl1"
	density = FALSE				// Small enough to not block stuff
	anchored = FALSE			// Small enough to move even when filled
	throwpass = TRUE			// Just like at the county fair, you can't seem to throw the ball in to win the goldfish
	pass_flags = PASSTABLE		// Small enough to pull onto a table

	tank_type = "bowl"
	water_capacity = 50			// Not very big, therefore it can't hold much
	max_fish = 1				// What a lonely fish

	has_lid = FALSE
	maxHealth = 15				// Not very sturdy
	health = 15
	shard_count = 0				// No salvageable shards

/obj/machinery/fishtank/bowl/full
	water_level = 50
	food_level = MAX_FOOD

/obj/machinery/fishtank/bowl/full/goldfish/New()
	. = ..()
	add_fish("goldfish")

/obj/machinery/fishtank/tank
	name = "fish tank"
	desc = "A large glass tank designed to house aquatic creatures. Contains an integrated water circulation system."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "tank1"
	density = TRUE
	anchored = TRUE
	throwpass = TRUE				// You can throw objects over this, despite it's density, because it's short enough.
	circuitboard = /obj/item/weapon/circuitboard/fishtank

	tank_type = "tank"
	water_capacity = 200		// Decent sized, holds 2 full large beakers worth
	max_fish = 4				// Room for a few fish

	has_lid = TRUE
	maxHealth = 50				// Average strength, will take a couple hits from a toolbox.
	health = 50
	shard_count = 4

/obj/machinery/fishtank/tank/full
	water_level = 200
	food_level = MAX_FOOD

/obj/machinery/fishtank/wall
	name = "wall aquarium"
	desc = "This aquarium is massive! It completely occupies the same space as a wall, and looks very sturdy too!"
	icon_state = "wall1"
	density = TRUE
	anchored = TRUE
	throwpass = FALSE				// This thing is the size of a wall, you can't throw past it.
	circuitboard = /obj/item/weapon/circuitboard/fishwall
	pass_flags_self = PASSGLASS
	tank_type = "wall"
	water_capacity = 500		// This thing fills an entire tile,5 large beakers worth
	max_fish = 10				// Plenty of room for a lot of fish

	has_lid = TRUE
	maxHealth = 100			// This thing is a freaking wall, it can handle abuse.
	health = 100
	shard_count = 9

/obj/machinery/fishtank/wall/full
	water_level = 500
	food_level = MAX_FOOD

/obj/machinery/fishtank/wall/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0) // Prevents airflow. Copied from windows.
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return TRUE
	return FALSE

//////////////////////////////
//		VERBS & PROCS		//
//////////////////////////////

/obj/machinery/fishtank/verb/toggle_lid_verb()
	set name = "Toggle Tank Lid"
	set category = "Object"
	set src in view(1)
	if (usr.incapacitated() || !usr.Adjacent(src))
		return FALSE
	toggle_lid(usr)

/obj/machinery/fishtank/proc/toggle_lid(var/mob/living/user)
	lid_switch = !lid_switch
	update_icon()

/obj/machinery/fishtank/verb/toggle_light_verb()
	set name = "Toggle Tank Light"
	set category = "Object"
	set src in view(1)
	if (usr.incapacitated() || !usr.Adjacent(src))
		return FALSE
	toggle_light(usr)

/obj/machinery/fishtank/proc/toggle_light(var/mob/living/user)
	light_switch = !light_switch
	if(light_switch)
		set_light(2,2,"#a0a080")
	else
		set_light(0)

//////////////////////////////
//		/NEW() PROCS			//
//////////////////////////////

/obj/machinery/fishtank/New()
	..()
	if(!has_lid)				//Tank doesn't have a lid/light, remove the verbs for then
		verbs -= /obj/machinery/fishtank/verb/toggle_lid_verb
		verbs -= /obj/machinery/fishtank/verb/toggle_light_verb

/obj/machinery/fishtank/tank/New()
	..()
	if(prob(5))					//5% chance to get the castle decoration
		icon_state = "tank2"

//////////////////////////////
//		ICON PROCS			//
//////////////////////////////

/obj/machinery/fishtank/update_icon()
	overlays.Cut()
	//Update Alert Lights
	if(has_lid)
		if(egg_list.len)
			overlays += "over_egg"
		if(lid_switch == TRUE)							//Lid is closed, lid status light is red
			overlays += "over_lid_1"
		else											//Lid is open, lid status light is green
			overlays += "over_lid_0"
		switch (food_level)
			if (0 to BREEDING_THRESHOLD)				//Food_level is high and isn't a concern yet
				overlays += "over_food_nofood"
			if (BREEDING_THRESHOLD to FOOD_OK)			//Food_level is starting to get low, but still above the breeding threshold
				overlays += "over_food_somefood"
			if (FOOD_OK to MAX_FOOD)					//Food_level is below breeding threshold, or fully consumed, feed the fish!
				overlays += "over_food_fullfood"
		overlays += "over_leak_[leaking]"				//Green if we aren't leaking, light blue and slow blink if minor link, dark blue and rapid flashing for major leak

	if (fish_list.len)
		if("shark" in fish_list) // Smaller fish hide when a shark's town
			switch(tank_type)
				if (FISH_BOWL)
					overlays += icon('icons/obj/fish.dmi', "shark_bowl", FISH_LAYER)
				if (FISH_TANK)
					overlays += icon('icons/obj/fish.dmi', "sharkspin", FISH_LAYER)
				if (FISH_WALL)
					overlays += icon('icons/obj/fish.dmi', "shrk", FISH_LAYER)

		else if("lobster" in fish_list) // the small sprites dont work well sharing a tank
			switch(tank_type)
				if (FISH_BOWL)
					overlays += icon('icons/obj/fish.dmi', "lobster_bowl", FISH_LAYER)
				if (FISH_TANK)
					overlays += icon('icons/obj/fish.dmi', "lobster_tank", FISH_LAYER)
				if (FISH_WALL)
					overlays += icon('icons/obj/fish.dmi', "lobster_wall", FISH_LAYER)
		else
			switch(tank_type)
				if (FISH_BOWL)
					overlays += icon('icons/obj/fish.dmi', "feesh_small", FISH_LAYER)
				if (FISH_TANK)
					overlays += icon('icons/obj/fish.dmi', "feesh_medium", FISH_LAYER)
				if (FISH_WALL)
					overlays += icon('icons/obj/fish.dmi', "feesh", FISH_LAYER)
	//Update water overlay
	if(water_level == 0)
		return							//Skip the rest of this if there is no water in the aquarium

	var/water_type
	switch(filth_level)
		if (0 to FILTH_THRESHOLD)
			water_type = "clean"
		if (FILTH_THRESHOLD to MAX_FILTH)
			water_type = "dirty"
 	// Lest there can be fish in waterless environments
	if(!acidic)
		if(water_level/water_capacity < 0.85 && water_level/water_capacity > 0.01)
			overlays += icon('icons/obj/fish_items.dmi', "over_[tank_type]_half_[water_type]", WATER_LAYER)
		else if(water_level/water_capacity > 0.85)
			overlays += icon('icons/obj/fish_items.dmi', "over_[tank_type]_full_[water_type]", WATER_LAYER)
	else
		if(water_level/water_capacity < 0.85 && water_level/water_capacity > 0.01)
			overlays += icon('icons/obj/fish_items.dmi', "over_[tank_type]_half_[water_type]_acidic", WATER_LAYER)
		else if(water_level/water_capacity > 0.85)
			overlays += icon('icons/obj/fish_items.dmi', "over_[tank_type]_full_[water_type]_acidic", WATER_LAYER)

/obj/machinery/fishtank/process()
	//Check if the water level can support the current number of fish
	if((fish_list.len * 50) > water_level)
		if(prob(50))
			remove_fish()
			add_filth(2)

	//Check filth_level
	if(filth_level == MAX_FILTH && fish_list.len > 0)
		if(prob(30))
			remove_fish()

	//Check breeding conditions
	if(fish_list.len >=2 && egg_list.len < max_fish)
		if(food_level > 2 && filth_level <=5)
			if(prob(((fish_list.len - 2) * 5)+8))
				egg_list.Add(pick(fish_list))
				remove_food(2)

	//Handle standard food and filth adjustments
	var/ate_food = FALSE
	if(food_level > 0 && prob(50))
		if(food_level >= (fish_list.len * 0.01))
			remove_food(fish_list.len * 0.01)
		else
			food_level = 0
		ate_food = TRUE

	if(water_level > 0)
		if(!fish_list.len)
			//If the tank has no fish, algae growth can occur
			if(filth_level < ALGAE_THRESHOLD && prob(15))
				add_filth(0.05)
		//Chance for the tank to get dirtier if the filth_level isn't max
		else
			if(acidic && fish_list_water.len)
				remove_fish(pick(fish_list_water))
			else if(!acidic && fish_list_acidic.len)
				remove_fish(pick(fish_list_acidic))
		if(filth_level < MAX_FILTH && prob(10))
			if(ate_food && prob(25))
				add_filth(fish_list.len * 0.1)
			else
				add_filth(0.1)

	handle_special_interactions()

	//Handle water leakage from damage
	if(leaking)
		switch(leaking)							//Can't leak water if there is no water in the tank
			if(MAJOR_LEAK)							//At or below 25% health, the tank will lose 10 water_level per cycle (major leak)
				remove_water(10)
			if(MINOR_LEAK)						//At or below 50% health, the tank will lose 1 water_level per cycle (minor leak)
				remove_water(1)

	if(automated)
		if(filth_level > 0)
			remove_filth(0.05)

/obj/machinery/fishtank/proc/handle_special_interactions()
	var/glo_light = 0
	for(var/fish in fish_list)
		switch(fish)
			//Catfish have a small chance of cleaning some filth since they are a bottom-feeder
			if("catfish")
				if(filth_level > 0 && prob(30))
					remove_filth(0.1)
			if("feederfish")
				//only feederfish left
				if(fish_list.len < 2)
					continue
				if(food_level <= FOOD_OK && prob(25))
					remove_fish("feederfish")
					add_food(1)
			if("glofish")
				glo_light++
			if("clownfish")
				if(prob(10))
					playsound(src,'sound/items/bikehorn.ogg', 80, 1)
			if("sea devil")
				if(filth_level > 2.5 && prob(5))
					//Small chance to clear some filth, originally ate fish
					seadevil_eat()
				if(fish_list.len < max_fish && egg_list.len)
					add_fish(egg_list[1])
					egg_list -= egg_list[1]

	if(!light_switch && (glo_light > 0))
		set_light(2,glo_light,"#99FF66")

/obj/machinery/fishtank/proc/remove_water(var/amount)
	water_level = max(0, water_level - amount)
	update_icon()

/obj/machinery/fishtank/proc/add_water(var/amount)
	water_level = min(water_capacity, water_level + amount)
	update_icon()

/obj/machinery/fishtank/proc/remove_filth(var/amount)
	filth_level = max(0, filth_level - amount)
	update_icon()

/obj/machinery/fishtank/proc/add_filth(var/amount)
	filth_level = min(MAX_FILTH, filth_level + amount)
	update_icon()

/obj/machinery/fishtank/proc/remove_food(var/amount)
	food_level = max(0, food_level - amount)
	update_icon()

/obj/machinery/fishtank/proc/add_food(var/amount)
	food_level = min(MAX_FOOD, food_level + amount)
	update_icon()

/obj/machinery/fishtank/proc/add_health(var/amount)
	if(amount > 0)
		health = min(health + amount, maxHealth)
	else
		health = max(0, health + amount)
		playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
	if(health <= (maxHealth * 0.25))
		leaking = MAJOR_LEAK
	else if(health <= (maxHealth * 0.5))
		leaking = MINOR_LEAK
	else
		leaking = NO_LEAK

	if(health < 1)
		playsound(loc, 'sound/effects/Glassbr2.ogg', 100, 1)
		destroy()

/obj/machinery/fishtank/proc/remove_fish(var/type = null)
	if(type)
		fish_list.Remove(type)
		fish_list_water.Remove(type)
		fish_list_acidic.Remove(type)
	else
		var/fish = pick(fish_list)
		fish_list.Remove(fish)
		fish_list_water.Remove(fish)
		fish_list_acidic.Remove(fish)
	update_icon()

/obj/machinery/fishtank/proc/seadevil_eat()
	remove_filth(1)
	visible_message("<span class='notice'>The sea devil devours some algae.</span>")

/obj/machinery/fishtank/proc/add_fish(var/fish_type)
	if(!fish_type || fish_type == "dud")
		return
	for (var/egg_path in subtypesof(/obj/item/fish_eggs/))
		var/obj/item/fish_eggs/egg = new egg_path
		if(egg.fish_type != fish_type)
			continue
		if(egg.acidic)
			fish_list_acidic.Add(egg.fish_type)
		else
			fish_list_water.Add(egg.fish_type)
		fish_list.Add(egg.fish_type)
		//Announce the new fish
		update_icon()
		if(egg.hatching)
			visible_message("A new [egg.fish_type] has hatched in \the [src]!")
		else
			visible_message("The [egg.fish_type] has been placed in \the [src]!")

/obj/machinery/fishtank/proc/harvest_eggs(var/mob/user)
	if(!egg_list.len)
		return
	for(var/fish_type in egg_list)
		for (var/egg_path in subtypesof(/obj/item/fish_eggs/))
			var/obj/item/fish_eggs/egg = new egg_path
			if(egg.fish_type == fish_type)
				egg = new egg_path(get_turf(user))
	egg_list.len = 0

/obj/machinery/fishtank/proc/harvest_fish(var/mob/user)
	if(fish_list.len)
		var/caught_fish = input("Select a fish to catch.", "Fishing") as null|anything in fish_list
		if(caught_fish)
			remove_fish(caught_fish)
			user.visible_message("[user.name] harvests \a [caught_fish] from \the [src].", "You scoop \a [caught_fish] out of \the [src].")
			for(var/fish_path in subtypesof(/obj/item/weapon/fish/))
				var/obj/item/weapon/fish = new fish_path
				if(fish.name == caught_fish)
					fish = new fish_path(get_turf(user))
	else
		to_chat(user, "There are no fish in \the [src] to catch!")

/obj/machinery/fishtank/proc/destroy(var/deconstruct = FALSE)
	if(!deconstruct)
		for(var/i = 0 to shard_count)
			new /obj/item/weapon/shard(get_turf(src))
		if(water_level)
			spill_water()
	else
		var/sheets = shard_count + 1
		var/cur_turf = get_turf(src)
		new /obj/item/stack/sheet/glass/glass(cur_turf, sheets)
		if(circuitboard)
			new circuitboard(cur_turf)
			new /obj/item/stack/sheet/metal(cur_turf, 5)
			new /obj/item/stack/cable_coil(cur_turf, 5)
	qdel(src)

/obj/machinery/fishtank/proc/spill_water()
	switch(tank_type)
		if(FISH_BOWL)
			var/turf/T = get_turf(src)
			if(!istype(T, /turf/simulated))
				return
			var/turf/simulated/S = T
			S.wet(10 SECONDS, TURF_WET_WATER)

		if(FISH_TANK)										//Fishtank: Wets it's own tile and the 4 adjacent tiles (cardinal directions)
			var/turf/ST = get_turf(src)
			var/list/L = ST.CardinalTurfs()
			for(var/turf/simulated/S in L)
				S.wet(10 SECONDS, TURF_WET_WATER)

		if (FISH_WALL)										//Wall-tank: Wets it's own tile and the surrounding 8 tiles (3x3 square)
			for(var/turf/simulated/S in view(src, 1))
				S.wet(10 SECONDS, TURF_WET_WATER)

/obj/machinery/fishtank/examine(var/mob/user)
	..()
	var/examine_message = list()
	//Approximate water level

	examine_message += "Water level: "

	switch (water_level/water_capacity)
		if (0     to 0.001)
			examine_message += "<span class='warning'>\The [src] is empty!</span>"
		if (0.001 to 0.100)
			examine_message += "<span class='warning'>\The [src] is nearly empty!</span>"
		if (0.100 to 0.250)
			examine_message += "<span class='notice'>\The [src] is about one-quarter filled.</span>"
		if (0.250 to 0.500)
			examine_message += "<span class='notice'>\The [src] is about half filled.</span>"
		if (0.500 to 0.750)
			examine_message += "<span class='notice'>\The [src] is about three-quarters filled.</span>"
		if (0.750 to 0.999)
			examine_message += "<span class='notice'>\The [src] is nearly full!</span>"
		if (0.999 to 1)
			examine_message += "<span class='notice'>\The [src] is full!</span>"

	examine_message += "<br>Cleanliness level: "

	//Approximate filth level
	switch (filth_level/MAX_FILTH)
		if (0     to 0.001)
			examine_message += "<span class='notice'>\The [src] is spotless!</span>"
		if (0.001 to 0.250)
			examine_message += "<span class='notice'>\The [src] looks like the glass has been smudged.</span>"
		if (0.250 to 0.500)				//This is the breeding threshold
			examine_message += "<span class='warning'>\The [src] has some algae growth in it.</span>"
		if (0.500 to 0.750)
			examine_message += "<span class='warning'>\The [src] has a lot of algae growth in it.</span>"
		if (0.750 to 0.999)
			examine_message += "<span class='warning'>\The [src] is getting hard to see into! Someone should clean it soon!</span>"
		if (0.999 to 1)
			examine_message += "<span class='warning'>\The [src] is absolutely <b>disgusting</b>! Someone should clean it NOW!</span>"

	examine_message += "<br>Food level: "

	//Approximate food level
	if(!fish_list.len)								//Check if there are fish in the tank
		if(food_level > 0)						//Don't report a tank that has neither fish nor food in it
			examine_message += "<span class='notice'>There's some food in [src], but no fish!</span>"
		else
			examine_message += "<span class='warning'>There is no food in \the [src].</span>"
	else										//We've got fish, report the food level
		switch (food_level/MAX_FOOD)
			if(0)
				examine_message += "<span class='warning'>The fish look very hungry!</span> "
			if(0.001 to 0.2)
				examine_message += "<span class='warning'>The fish are nibbling on the last of their food.</span>"
			if(0.2 to 0.999)				//Breeding is possible
				examine_message += "<span class='notice'>The fish seem happy!</span>"
			if(1)
				examine_message += "<span class='notice'>There is a solid layer of fish food at the top.</span>"

	//Report the number of harvestable eggs
	if(egg_list.len)								//Don't bother if there isn't any eggs
		examine_message += "<span class='notice'><br>There are [egg_list.len] eggs able to be harvested!</span>"

	examine_message += "<br>"

	//Report the number and types of live fish if there is water in the tank
	if(!fish_list.len)
		examine_message += "<span class = 'warning'>\The [src] doesn't contain any live fish. </span>"
	else
		//Build a message reporting the types of fish
		var/message = "You spot "
		for (var/i = 1 to fish_list.len)
			if(fish_list.len > 1 && i == fish_list.len)	//If there were at least 2 fish, and this is the last one, add "and" to the message
				message += "and "
			message += "\an [fish_list[i]]"
			if(i < fish_list.len)					//There's more fish, add a comma to the message
				message +=", "
		message +="."								//No more fish, end the message with a period
		//Display the number of fish and previously constructed message
		examine_message += "<span class = 'notice'>\The [src] contains [fish_list.len] live fish. [message]</span>"


	//Report lid state for tanks and wall-tanks
	if(has_lid)									//Only report if the tank actually has a lid
		examine_message += "<br>"
		//Report lid state
		if(lid_switch)
			examine_message += "<span class = 'notice'>The lid is closed.</span>"
		else
			examine_message += "<span class = 'notice'>The lid is open.</span>"

	if(automated)
		examine_message += "<br>"
		var/flavor_text = pick("burps and gulps", "cleans and tinks", "boops and beeps", "gloops and loops")
		examine_message += "<span class = 'notice'>The automated cleaning module [flavor_text].</span>"

	examine_message += "<br>"

	//Report if the tank is leaking/cracked
	if(water_level > 0)
		switch (leaking)					//Tank has water, so it's actually leaking
			if(MINOR_LEAK)
				examine_message += "<span class = 'warning'>\The [src] is leaking.</span>"
			if(MAJOR_LEAK)
				examine_message += "<span class = 'warning'>\The [src] is leaking profusely!</span>"
	else
		switch (leaking)									//No water, report the cracks instead
			if(MINOR_LEAK)
				examine_message += "<span class = 'warning'>\The [src] is cracked.</span>"
			if(MAJOR_LEAK)
				examine_message += "<span class = 'warning'>\The [src] is nearly shattered!</span>"

	to_chat(user, jointext(examine_message, ""))

//////////////////////////////
//		ATTACK PROCS			//
//////////////////////////////

/obj/machinery/fishtank/attack_alien(var/mob/living/user)
	if(islarva(user))
		return
	attack_generic(user, 15)

/obj/machinery/fishtank/attack_hand(var/mob/user)

	if (!Adjacent(user) || user.incapacitated())
		return FALSE

	playsound(src, 'sound/effects/glassknock.ogg', 80, 1)
	if(user.a_intent == I_HURT)
		user.visible_message("<span class='danger'>\The [user] bangs against \the [src]!</span>", \
							"<span class='danger'>You bang against the [src]!</span>", \
							"You hear a banging sound.")
	else
		user.visible_message("\The [user] taps on \the [src].", \
							"You tap on \the [src].", \
							"You hear a knocking sound.")
	user.delayNextAttack(0.8 SECONDS)

/obj/machinery/fishtank/proc/hit(var/obj/O, var/mob/user)
	user.delayNextAttack(0.8 SECONDS)
	user.do_attack_animation(src, O)
	playsound(src, 'sound/effects/glassknock.ogg', 80, 1)
	add_health(-O.force)

//used by attack_alien, attack_animal, and attack_slime
/obj/machinery/fishtank/proc/attack_generic(var/mob/living/user, var/damage = 0)
	add_health(-damage)

/obj/machinery/fishtank/attackby(var/obj/item/O, var/mob/user as mob)
	//Silicate sprayers repair damaged tanks on help intent
	if(issilicatesprayer(O))
		return handle_silicate_sprayer(O, user)
	//Open reagent containers add and remove water
	if(O.is_open_container())
		return handle_containers(O, user)
	//Wrenches can deconstruct empty tanks, but not tanks with any water
	if(O.is_wrench(user))
		return handle_wrench(O, user)
	//Fish eggs
	if(istype(O, /obj/item/fish_eggs))
		return handle_eggs(O, user)
	//Fish food
	if(istype(O, /obj/item/weapon/fishtools/fish_food))
		return handle_food(O, user)
	//Fish egg scoop
	if(istype(O, /obj/item/weapon/fishtools/fish_egg_scoop))
		return handle_fish_scoop(O, user)
	//Fish net
	if(istype(O, /obj/item/weapon/fishtools/fish_net))
		return harvest_fish(user)
	//Tank brush
	if(istype(O, /obj/item/weapon/fishtools/fish_tank_brush))
		return handle_brush(O, user)
	//Installing the automation module
	if(istype(O, /obj/item/weapon/fishtools/fishtank_helper))
		if(automated)
			to_chat(user, "<span class='warning'>\The [src] has this module already.</span>")
		else if(user.drop_item(O, src))
			automated = O
			playsound(src,'sound/effects/vacuum.ogg', 50, 1)
			user.visible_message("\The [user] installs a module inside \the [src].", "<span class='notice'>You install the module inside \the [src].</span>")
			return TRUE

	else if(O && O.force)
		user.visible_message("<span class='danger'>\The [src] has been attacked by \the [user] with \the [O]!</span>")
		hit(O, user)
	return TRUE

/obj/machinery/fishtank/proc/handle_silicate_sprayer(var/obj/item/O, var/mob/user as mob)
	var/obj/item/device/silicate_sprayer/S = O
	if(user.a_intent == I_HELP)
		if (S.get_amount() >= 2)
			add_health(20)
			S.remove_silicate(2)
	return TRUE

/obj/machinery/fishtank/proc/handle_containers(var/obj/item/O, var/mob/user as mob)
	if(!istype(O, /obj/item/weapon/reagent_containers/glass))
		return FALSE
	if(lid_switch)
		to_chat(user, "<span class='notice'>Open the lid on \the [src] first!</span>")
		return FALSE

	var/obj/item/weapon/reagent_containers/glass/C = O
	if(water_level && !C.reagents.total_volume)
		//Empty containers will scoop out water, filling the container as much as possible from the water_level
		if(acidic)
			C.reagents.add_reagent(SACID, water_level)
			remove_water(C.volume)
		else
			C.reagents.add_reagent(WATER, water_level)
			remove_water(C.volume)
		update_icon()
		return TRUE
	else if(water_level == water_capacity)
		to_chat(user, "<span class='warning'>\The [src] is already full!</span>")
		return TRUE

	var/water_value = 0
	if(!C.reagents.has_any_reagents(ACIDS) && C.reagents.has_any_reagents(WATERS))
		acidic = FALSE
		water_value += C.reagents.get_reagent_amount(WATER)
		water_value += C.reagents.get_reagent_amount(HOLYWATER) *1.1
		water_value += C.reagents.get_reagent_amount(ICE) * 0.80
	else if(C.reagents.has_any_reagents(ACIDS) &&  !C.reagents.has_any_reagents(WATERS))
		acidic = TRUE
		water_value += C.reagents.get_reagent_amount(PACID) * 2
		water_value += C.reagents.get_reagent_amount(SACID)
		water_value += C.reagents.get_reagent_amount(PHENOL)
		water_value += C.reagents.get_reagent_amount(FORMIC_ACID)
	else
		water_value += C.reagents.get_reagent_amount(WATER)
		water_value += C.reagents.get_reagent_amount(HOLYWATER) *1.1
		water_value += C.reagents.get_reagent_amount(ICE) * 0.80
	if(water_value)
		add_water(water_value)
		C.reagents.clear_reagents()
		to_chat(user, "<span class='notice'>You add the contents of the container to \the [src].</span>")
		if(water_level == water_capacity)
			to_chat(user, "<span class='notice'>You filled \the [src] to the brim!</span>")
		update_icon()
	return TRUE

/obj/machinery/fishtank/proc/handle_wrench(var/obj/item/O, var/mob/user as mob)
	if (water_level == 0)
		O.playtoolsound(loc, 50)
		if(do_after(user,50, target = src))
			destroy(1)
	else
		to_chat(user, "<span class='warning'>\The [src] must be empty before you disassemble it!</span>")
	return TRUE

/obj/machinery/fishtank/proc/handle_eggs(var/obj/item/O, var/mob/user as mob)
	var/obj/item/fish_eggs/egg = O
	if(water_level == 0)
		to_chat(user, "<span class='warning'>\The [src] has no water; [egg.name] won't hatch without water!</span>")
		return FALSE
	//Don't add eggs if the tank already has the max number of fish
	if(fish_list.len >= max_fish)
		to_chat(user, "<span class='warning'>\The [src] can't hold any more fish.</span>")
		return FALSE
	if (egg.fish_type == "dud")
		to_chat(user, "<span class='warning'>The eggs didn't hatch.</span>")
		qdel(egg)
		return FALSE
	add_fish(egg.fish_type)
	to_chat(user, "<span class='notice'>You add the fish eggs to \the [src].</span>")
	qdel(egg)
	return TRUE

/obj/machinery/fishtank/proc/handle_food(var/obj/item/O, var/mob/user as mob)
	//Only add food if there is water and it isn't already full of food
	if(!water_level)
		to_chat(user, "<span class='warning'>\The [src] doesn't have any water in it. You should fill it with water first.</span>")
		return FALSE
	if(food_level >= MAX_FOOD)
		to_chat(user, "<span class='notice'>\The [src] already has plenty of food in it. You decide to not add more.<span>")
		return FALSE
	add_food(MAX_FOOD)
	to_chat(user, "<span class='notice'>You add the fish food to \the [src].</span>")

	return TRUE

/obj/machinery/fishtank/proc/handle_fish_scoop(var/obj/item/O, var/mob/user as mob)
	harvest_eggs(user)

/obj/machinery/fishtank/proc/handle_brush(var/obj/item/O, var/mob/user as mob)
	if(filth_level == 0)
		to_chat(user, "<span class='notice'>\The [src] is already spotless!</span>")
		return TRUE
	filth_level = 0
	user.visible_message("\The [user] scrubs the inside of \the [src], cleaning the filth.", "<span class='notice'>You scrub the inside of \the [src], cleaning the filth.</span>")
	return TRUE

//Conduction plate for electric eels

/obj/machinery/power/conduction_plate
	name = "conduction plate"
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"
	layer = ABOVE_TILE_LAYER
	plane = ABOVE_TURF_PLANE
	anchored = 1
	density = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY | FIXED2WORK

	component_parts = newlist(
		/obj/item/weapon/circuitboard/conduction_plate,
		/obj/item/weapon/stock_parts/capacitor
	)

	var/obj/machinery/fishtank/attached_tank = null
	var/multiplier = 0.9

/obj/machinery/power/conduction_plate/New()
	..()
	if(anchored)
		connect_to_network()
	RefreshParts()

/obj/machinery/power/conduction_plate/RefreshParts()
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		multiplier = initial(multiplier) + (C.rating*0.1) //1 to 1.2

/obj/machinery/power/conduction_plate/process()
	if(!anchored)
		return
	var/power = 0
	if(check_tank())
		for(var/fish in attached_tank.fish_list)
			if(fish == "electric eel")
				power += ARBITRARILY_LARGE_NUMBER * multiplier //10000
		add_avail(power)
		return
	for(var/mob/living/carbon/human/H in loc)
		if(iswizard(H) && !H.stat)
			power += FIRE_CARBON_ENERGY_RELEASED*H.health/H.maxHealth
			H.adjustFireLoss(3)
			if(prob(10))
				H.audible_scream()
	add_avail(power)

/obj/machinery/power/conduction_plate/proc/check_tank()
	if(attached_tank && attached_tank.loc == loc)
		return 1
	attached_tank = locate(/obj/machinery/fishtank/) in loc
	if(attached_tank)
		return 1
	else
		return 0

/obj/machinery/power/conduction_plate/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	attached_tank = null
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()
