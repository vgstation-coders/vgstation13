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
	var/list/fish_list = list()	// Tracks the current types of fish in the tank
	var/list/egg_list = list()	// Tracks the current types of harvestable eggs in the tank

	var/has_lid = FALSE			// FALSE if the tank doesn't have a lid/light, TRUE if it does
	var/max_health = 0			// Can handle a couple hits
	var/cur_health = 0			// Current health, starts at max_health
	var/leaking = NO_LEAK
	var/shard_count = 0			// Number of glass shards to salvage when broken (1 less than the number of sheets to build the tank)
	var/automated = 0			// Cleans the aquarium on its own

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
	max_health = 15				// Not very sturdy
	cur_health = 15
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
	max_health = 50				// Average strength, will take a couple hits from a toolbox.
	cur_health = 50
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
	max_health = 100			// This thing is a freaking wall, it can handle abuse.
	cur_health = 100
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
		kill_light()

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
	if(has_lid)											//Skip the alert lights for aquariums that don't have lids (fishbowls)
		if(egg_list.len)								//There is at least 1 egg to harvest
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

	switch (water_level/water_capacity)
		if (0.01 to 0.85) // Lest there can be fish in waterless environements
			overlays += icon('icons/obj/fish_items.dmi', "over_[tank_type]_half_[water_type]", WATER_LAYER)
		if (0.85 to 1)
			overlays += icon('icons/obj/fish_items.dmi', "over_[tank_type]_full_[water_type]", WATER_LAYER)

//////////////////////////////
//		PROCESS PROC		//
//////////////////////////////


/obj/machinery/fishtank/process()

	//Check if the water level can support the current number of fish
	if((fish_list.len * 50) > water_level)
		if(prob(50))								//Not enough water for all the fish, chance to kill one
			kill_fish()								//Chance passed, kill a random fish
			add_filth(2)							//Dead fish raise the filth level quite a bit, reflect this

	//Check filth_level
	if(filth_level == MAX_FILTH && fish_list.len > 0)			//This tank is nasty and possibly unsuitable for fish if any are in it
		if(prob(30))								//Chance for a fish to die each cycle while the tank is this nasty
			kill_fish()								//Kill a random fish, don't raise filth level since we're at cap already

	//Check breeding conditions
	if(fish_list.len >=2 && egg_list.len < max_fish)		//Need at least 2 fish to breed, but won't breed if there are as many eggs as max_fish
		if(food_level > 2 && filth_level <=5)		//Breeding is going to use extra food, and the filth_level shouldn't be too high
			if(prob(((fish_list.len - 2) * 5)+10))		//Chances increase with each additional fish, 10% base + 5% per additional fish
				egg_list.Add(select_egg_type())		//Add the new egg to the egg_list for storage
				remove_food(2)						//Remove extra food for the breeding process

	//Handle standard food and filth adjustments
	var/ate_food = FALSE
	if(food_level > 0 && prob(50))					//Chance for the fish to eat some food
		if(food_level >= (fish_list.len * 0.01))		//If there is at least enough food to go around, feed all the fish
			remove_food(fish_list.len * 0.01)
		else										//Use up the last of the food
			food_level = 0
		ate_food = TRUE

	if(water_level > 0)								//Don't dirty the tank if it has no water
		if(fish_list.len == 0)							//If the tank has no fish, algae growth can occur
			if(filth_level < ALGAE_THRESHOLD && prob(15))		//Algae growth is a low chance and cannot exceed filth_level of 7.5
				add_filth(0.05)					//Algae growth is slower than fish filth build-up
		else if(filth_level < MAX_FILTH && prob(10))		//Chance for the tank to get dirtier if the filth_level isn't 10
			if(ate_food && prob(25))				//If they ate this cycle, there is an additional chance they make a bigger mess
				add_filth(fish_list.len * 0.1)
			else									//If they didn't make the big mess, make a little one
				add_filth(0.1)

	//Handle special interactions
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


//////////////////////////////
//		SUPPORT PROCS		//
//////////////////////////////

/obj/machinery/fishtank/proc/handle_special_interactions()
	var/glo_light = 0
	for(var/fish in fish_list)
		switch(fish)
			if("catfish")							//Catfish have a small chance of cleaning some filth since they are a bottom-feeder
				if(filth_level > 0 && prob(30))
					remove_filth(0.1)
			if("feederfish")						//Feeder fish have a small chance of sacrificing themselves to produce some food
				if(fish_list.len < 2)					//Don't sacrifice the last fish, there's nothing to eat it
					continue
				if(food_level <= FOOD_OK && prob(25))
					kill_fish("feederfish")			//Kill the fish to reflect it's sacrifice, but don't increase the filth_level
					add_food(1)					//The corpse became food for the other fish, ecology at it's finest
			if("glofish")
				glo_light++
			if("clownfish")
				if(prob(10))
					playsound(src,'sound/items/bikehorn.ogg', 80, 1)
			if("sea devil")
				if(fish_list.len > 1 && prob(5))
					//Small chance to eat a random fish that isn't itself.
					seadevil_eat()

				if(fish_list.len < max_fish && egg_list.len)
					add_fish(get_key_by_element(fish_eggs_list,egg_list[1])) //add_fish takes a string. egg_list gives a path. fish_eggs_list is an associative list keyed with strings. get_key_by_index returns that string key by matching the path
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

/obj/machinery/fishtank/proc/check_health()
	//Max value check
	if(cur_health > max_health)						//Cur_health cannot exceed max_health, set it to max_health if it does
		cur_health = max_health
	//Leaking status check
	if(cur_health <= (max_health * 0.25))			//Major leak at or below 25% health (-10 water/cycle)
		leaking = MAJOR_LEAK
	else if(cur_health <= (max_health * 0.5))		//Minor leak at or below 50% health (-1 water/cycle)
		leaking = MINOR_LEAK
	else											//Not leaking above 50% health
		leaking = NO_LEAK
	//Destruction check
	if(cur_health <= 0)								//The tank is broken, destroy it
		destroy()

/obj/machinery/fishtank/proc/kill_fish(var/type = null)
	//Check if we were passed a fish to kill, otherwise kill a random one
	if(type)
		fish_list.Remove(type)						//Kill a fish of the specified type
	else
		fish_list.Remove(pick(fish_list))			//Kill a random fish
	update_icon()

/obj/machinery/fishtank/proc/seadevil_eat()
	var/list/fish_to_eat = fish_list.Copy()
	fish_to_eat.Remove("sea devil")
	var/eat_target = pick(fish_to_eat)
	visible_message("<span class='notice'>The sea devil devours \an [eat_target].</span>")
	kill_fish(eat_target)

/obj/machinery/fishtank/proc/add_fish(var/type)
	if(!type || type == "dud")
		return
	//Check if we were passed a fish type
	fish_list.Add("[type]")						//Add a fish of the specified type
	//Announce the new fish
	update_icon()
	if(nonhatching_types.Find(type))
		visible_message("The [type] has been placed in \the [src]!")
	else
		visible_message("A new [type] has hatched in \the [src]!")

/obj/machinery/fishtank/proc/select_egg_type()
	var/fish = null
	if(prob(10)) //Small chance for infertility
		fish = "dud"
	else
		fish = recursive_valid_egg(fish_list)
	var/obj/item/fish_eggs/egg_path	= fish_eggs_list[fish]					//Locate the corresponding path from fish_eggs_list that matches the fish
	return egg_path

/obj/machinery/fishtank/proc/recursive_valid_egg(var/list/pick_egg_from)
	var/fish = pick(pick_egg_from)
	if(!fish || nonhatching_types.Find(fish))
		var/list/new_list = pick_egg_from.Copy()
		return recursive_valid_egg(new_list.Remove(fish))
		//If it's a nonvalid type, let's try again without it.
	else
		return fish
		//If it's valid, return this.

/obj/machinery/fishtank/proc/harvest_eggs(var/mob/user)
	if(!egg_list.len)									//Can't harvest non-existant eggs
		return

	for(var/i = 1 to egg_list.len)						//Loop until you've harvested all the eggs
		var/obj/item/fish_eggs/egg = egg_list[i]	//Go through the eggs
		new egg(get_turf(user))						//Spawn the egg at the user's feet

	egg_list = list()								//Destroy any excess eggs, clearing the egg_list

/obj/machinery/fishtank/proc/harvest_fish(var/mob/user)
	if(!fish_list.len)									//Can't catch non-existant fish!
		to_chat(user, "There are no fish in \the [src] to catch!")
		return

	var/caught_fish = input("Select a fish to catch.", "Fishing") as null|anything in fish_list		//Select a fish from the tank
	if(caught_fish)
		var/dead_fish = fish_items_list[caught_fish] //Locate the appropriate fish_item for the caught fish
		if(!dead_fish)								 //No fish_item found, possibly due to typo or not being listed. Do nothing.
			return
		kill_fish(caught_fish)						//Kill the caught fish from the tank
		user.visible_message("[user.name] harvests \a [caught_fish] from \the [src].", "You scoop \a [caught_fish] out of \the [src].")
		new dead_fish(get_turf(user))				//Spawn the appropriate fish_item at the user's feet.

/obj/machinery/fishtank/proc/destroy(var/deconstruct = FALSE)
	if(!deconstruct)															//Check if we are deconstructing or breaking the tank
		for(var/i = 0 to shard_count)											//Produce the appropriate number of glass shards
			new /obj/item/weapon/shard(get_turf(src))
		if(water_level)															//Spill any water that was left in the tank when it broke
			spill_water()
	else																//We are deconstructing, make glass sheets instead of shards
		var/sheets = shard_count + 1									//Deconstructing it salvages all the glass used to build the tank
		var/cur_turf = get_turf(src)
		new /obj/item/stack/sheet/glass/glass(cur_turf, sheets)			//Produce the appropriate number of glass sheets, in a single stack (/glass/glass)
		if(circuitboard)
			new circuitboard(cur_turf)									//Eject the circuitboard
	qdel(src)															//qdel the tank and it's contents


/obj/machinery/fishtank/proc/spill_water()
	switch(tank_type)
		if(FISH_BOWL)										//Fishbowl: Wets it's own tile
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


//////////////////////////////			Note from FalseIncarnate:
//		EXAMINE PROC		//			This proc is massive, messy, and probably could be handled better.
//////////////////////////////			Feel free to try cleaning it up if you think of a better way to do it.

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

	//Finally, report the full examine_message constructed from the above reports
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
	cur_health = max(0, cur_health - O.force)
	check_health()

/obj/machinery/fishtank/proc/attack_generic(var/mob/living/user, var/damage = 0)	//used by attack_alien, attack_animal, and attack_slime
	cur_health = max(0, cur_health - damage)
	if(cur_health <= 0)
		user.visible_message("<span class='danger'>\The [user] smashes through \the [src]!</span>")
		destroy()
	else	//for nicer text
		user.visible_message("<span class='danger'>\The [user] smashes into \the [src]!</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
		check_health()

/obj/machinery/fishtank/attackby(var/obj/item/O, var/mob/user as mob)
	//Silicate sprayers repair damaged tanks on help intent
	if(issilicatesprayer(O))
		var/obj/item/device/silicate_sprayer/S = O
		if(user.a_intent == I_HELP)
			if (S.get_amount() >= 2)
				if(cur_health < max_health)
					to_chat(user, "<span class='notice'>You repair some of the cracks on \the [src].</span>")
					cur_health += 20
					S.remove_silicate(2)
					check_health()
				else
					to_chat(user, "<span class='warning'>There is no damage to fix!</span>")
			else if (cur_health < max_health)
				to_chat(user, "<span class='notice'>You require more silicate to fix the damage on \the [src].</span>")
		return TRUE
	//Open reagent containers add and remove water
	if(O.is_open_container())
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			if(lid_switch)
				to_chat(user, "<span class='notice'>Open the lid on \the [src] first!</span>")
				return TRUE
			var/obj/item/weapon/reagent_containers/glass/C = O
			//Containers with any reagents will get dumped in
			if(C.reagents.total_volume)
				var/water_value = 0
				water_value += C.reagents.get_reagent_amount(WATER)					//Water is full value
				water_value += C.reagents.get_reagent_amount(HOLYWATER) *1.1		//Holywater is (somehow) better. Who said religion had to make sense?

				water_value += C.reagents.get_reagent_amount(ICE) * 0.80			//Ice is 80% value
				var/message = ""
				if(!water_value)													//The container has no water value, clear everything in it
					message = "<span class='warning'>The filtration process removes everything, leaving the water level unchanged.</span>"
					C.reagents.clear_reagents()
				else
					if(water_level == water_capacity)
						to_chat(user, "<span class='warning'>\The [src] is already full!</span>")
						return TRUE
					else
						message = "The filtration process purifies the water, raising the water level."
						add_water(water_value)
						if(water_level == water_capacity)
							message += "You filled \the [src] to the brim!"
						if(water_level > water_capacity)
							message += "You overfilled \the [src] and some water runs down the side, wasted."
						C.reagents.clear_reagents()
				user.visible_message("\The [user] pours the contents of \the [C] into \the [src].", "<span class = 'notice'>[message]</span>")
				return TRUE
			//Empty containers will scoop out water, filling the container as much as possible from the water_level
			else
				if(water_level == 0)
					to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
				else
					C.reagents.add_reagent(WATER, water_level)
					remove_water(C.volume)
					if(water_level >= C.volume)										//Enough to fill the container completely
						user.visible_message("\The [user] scoops out some water from \the [src].", "<span class = 'notice'>You completely fill [C.name] from \the [src].</span>")
					else															//Fill the container as much as possible with the water_level
						user.visible_message("\The [user] scoops out some water from \the [src].", "<span class = 'notice'>You fill [C.name] with the last of the water in \the [src].</span>")

			return TRUE
	//Wrenches can deconstruct empty tanks, but not tanks with any water. Kills any fish left inside and destroys any unharvested eggs in the process
	if(O.is_wrench(user))
		if (water_level == 0)
			to_chat(user, "<span class='notice'>Now disassembling \the [src].</span>")
			O.playtoolsound(loc, 50)
			if(do_after(user,50, target = src))
				destroy(1)
		else
			to_chat(user, "<span class='warning'>\The [src] must be empty before you disassemble it!</span>")
		return TRUE
	//Fish eggs
	else if(istype(O, /obj/item/fish_eggs))
		var/obj/item/fish_eggs/egg = O
		//Don't add eggs if there is no water (they kinda need that to live)
		if(water_level == 0)
			to_chat(user, "<span class='warning'>\The [src] has no water; [egg.name] won't hatch without water!</span>")
			return FALSE
		//Don't add eggs if the tank already has the max number of fish
		if(fish_list.len >= max_fish)
			to_chat(user, "<span class='warning'>\The [src] can't hold any more fish.</span>")
			return FALSE
		if (egg.fish_type == "dud") // Fugging duds
			to_chat(user, "<span class='warning'>The eggs didn't hatch. They were duds!</span>")
			qdel(egg)
			return FALSE
		add_fish(egg.fish_type)
		qdel(egg)
		return TRUE
	//Fish food
	else if(istype(O, /obj/item/weapon/fishtools/fish_food))
		//Only add food if there is water and it isn't already full of food
		if(!water_level)
			to_chat(user, "<span class='warning'>\The [src] doesn't have any water in it. You should fill it with water first.</span>")
			return FALSE
		if(food_level >= MAX_FOOD)
			to_chat(user, "<span class='notice'>\The [src] already has plenty of food in it. You decide to not add more.<span>")
			return FALSE

		if(fish_list.len == 0)
			user.visible_message("\The [user] shakes some fish food into the empty [src]... How sad.", "<span class='notice'>You shake some fish food into the empty [src]... If only it had fish.</span>")
		else
			user.visible_message("\The [user] feeds the fish in \the [src]. The fish look excited!", "<span class='notice'>You feed the fish in \the [src]. They look excited!</span>")
		add_food(MAX_FOOD)

		return TRUE
	//Fish egg scoop
	else if(istype(O, /obj/item/weapon/fishtools/fish_egg_scoop))
		if(egg_list.len)
			user.visible_message("\The [user] harvests some fish eggs from \the [src].", "<span class='notice'>You scoop the fish eggs out of \the [src].</span>")
			harvest_eggs(user)
		else
			user.visible_message("\The [user] fails to harvest any fish eggs from \the [src].", "<span class='notice'>There are no fish eggs in \the [src] to scoop out.</span>")
		return TRUE
	//Fish net
	if(istype(O, /obj/item/weapon/fishtools/fish_net))
		harvest_fish(user)
		return TRUE
	//Tank brush
	if(istype(O, /obj/item/weapon/fishtools/fish_tank_brush))
		if(filth_level == 0)
			to_chat(user, "\The [src] is already spotless!")
			return TRUE
		filth_level = 0
		user.visible_message("\The [user] scrubs the inside of \the [src], cleaning the filth.", "<span class='notice'>You scrub the inside of \the [src], cleaning the filth.</span>")
		return TRUE
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
	if(check_tank())
		var/power = 0
		for(var/fish in attached_tank.fish_list)
			if(fish == "electric eel")
				power += ARBITRARILY_LARGE_NUMBER * multiplier //10000
		add_avail(power)

/obj/machinery/power/conduction_plate/proc/check_tank()
	//Are we anchored?
	if(!anchored)
		return 0

	//Is our old tank is still valid?
	if(attached_tank && attached_tank.loc == loc)
		return 1

	//No? Let's look for a new one.
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
