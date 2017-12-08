#define FOOD_OK 5
#define BREEDING_THRESHOLD 2
#define FILTH_THRESHOLD 5
#define ALGAE_THRESHOLD 7.5
#define MAX_FOOD 10
#define MAX_FILTH 10

#define NO_LEAK 0
#define MINOR_LEAK 1
#define MAJOR_LEAK 2

//////////////////////////////
//		Fish Tanks!			//
//////////////////////////////

// Made by FalseIncarnate on Paradise
// Ported to /vg/ by Shifty and jakmak(s)


/obj/machinery/fishtank
	name = "placeholder tank"
	desc = "So generic, it might as well have no description at all."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "tank1"
	density = FALSE
	anchored = FALSE
	throwpass = FALSE

	var/tank_type = ""			// Type of aquarium, used for icon updating
	var/water_capacity = 0		// Number of units the tank holds (varies with tank type)
	var/water_level = 0			// Number of units currently in the tank (new tanks start empty)
	var/light_switch = FALSE	// FALSE = off, TRUE = on (off by default)
	var/filth_level = 0.0		// How dirty the tank is (max 10)
	var/lid_switch = FALSE		// FALSE = open, TRUE = closed (open by default)
	var/max_fish = 0			// How many fish the tank can support (varies with tank type, 1 fish per 50 units sounds reasonable)
	var/food_level = 0			// Amount of fishfood floating in the tank (max 10)
	var/fish_list.len = 0		// Number of fish in the tank
	var/list/fish_list = list()	// Tracks the current types of fish in the tank
	var/list/egg_list = list()	// Tracks the current types of harvestable eggs in the tank

	var/has_lid = FALSE			// FALSE if the tank doesn't have a lid/light, TRUE if it does
	var/max_health = 0			// Can handle a couple hits
	var/cur_health = 0			// Current health, starts at max_health
	var/leaking = NO_LEAK
	var/shard_count = 0			// Number of glass shards to salvage when broken (1 less than the number of sheets to build the tank)

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

	has_lid = TRUE
	max_health = 15				// Not very sturdy
	cur_health = 15
	shard_count = 0				// No salvageable shards

/obj/machinery/fishtank/tank
	name = "fish tank"
	desc = "A large glass tank designed to house aquatic creatures. Contains an integrated water circulation system."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "tank1"
	density = TRUE
	anchored = TRUE
	throwpass = TRUE				// You can throw objects over this, despite it's density, because it's short enough.

	tank_type = "tank"
	water_capacity = 200		// Decent sized, holds 2 full large beakers worth
	max_fish = 4				// Room for a few fish

	has_lid = TRUE
	max_health = 50				// Average strength, will take a couple hits from a toolbox.
	cur_health = 50
	shard_count = 2


/obj/machinery/fishtank/wall
	name = "wall aquarium"
	desc = "This aquarium is massive! It completely occupies the same space as a wall, and looks very sturdy too!"
	icon_state = "wall1"
	density = TRUE
	anchored = TRUE
	throwpass = FALSE				// This thing is the size of a wall, you can't throw past it.

	tank_type = "wall"
	water_capacity = 500		// This thing fills an entire tile,5 large beakers worth
	max_fish = 10				// Plenty of room for a lot of fish

	has_lid = TRUE
	max_health = 100			// This thing is a freaking wall, it can handle abuse.
	cur_health = 100
	shard_count = 3

/obj/machinery/fishtank/wall/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	to_chat(world, "Cross")
	return FALSE

/obj/machinery/fishtank/wall/Uncross(atom/movable/O as mob|obj, target as turf)
	return TRUE

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
	if(!user.incapacitated() && user.Adjacent(src))
		return
	else
		light_switch = !light_switch
	if(light_switch)
		set_light(2,2,"#a0a080")
	else
		set_light(0)

//////////////////////////////
//		NEW() PROCS			//
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
		if(egg_list.len > 0)								//There is at least 1 egg to harvest
			overlays += "over_egg"
		if(lid_switch == TRUE)							//Lid is closed, lid status light is red
			overlays += "over_lid_1"
		else											//Lid is open, lid status light is green
			overlays += "over_lid_0"
		if(food_level > FOOD_OK)						//Food_level is high and isn't a concern yet
			overlays += "over_food_0"
		else if(food_level > BREEDING_THRESHOLD)		//Food_level is starting to get low, but still above the breeding threshold
			overlays += "over_food_1"
		else											//Food_level is below breeding threshold, or fully consumed, feed the fish!
			overlays += "over_food_2"
		overlays += "over_leak_[leaking]"				//Green if we aren't leaking, light blue and slow blink if minor link, dark blue and rapid flashing for major leak

	//Update water overlay
	if(water_level == 0)
		return							//Skip the rest of this if there is no water in the aquarium
	var/water_type = "clean"							//Default to clean water
	if(filth_level > FILTH_THRESHOLD)
		water_type = "dirty"			//Show dirty water above filth_level 5 (breeding threshold)
	if(water_level > (water_capacity * 0.85))			//Show full if the water_level is over 85% of water_capacity
		overlays += "over_[tank_type]_full_[water_type]"
	else if(water_level > (water_capacity * 0.35))		//Show half-full if the water_level is over 35% of water_capacity
		overlays += "over_[tank_type]_half_[water_type]"


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
	if(filth_level == 10 && fish_list.len > 0)			//This tank is nasty and possibly unsuitable for fish if any are in it
		if(prob(30))								//Chance for a fish to die each cycle while the tank is this nasty
			kill_fish()								//Kill a random fish, don't raise filth level since we're at cap already

	//Check breeding conditions
	if(fish_list.len >=2 && egg_list.len < max_fish)		//Need at least 2 fish to breed, but won't breed if there are as many eggs as max_fish
		if(food_level > 2 && filth_level <=5)		//Breeding is going to use extra food, and the filth_level shouldn't be too high
			if(prob(((fish_list.len - 2) * 5)+10))		//Chances increase with each additional fish, 10% base + 5% per additional fish
				egg_list.len++						//A new set of eggs were laid, increase egg_list.len
				egg_list.Add(select_egg_type())		//Add the new egg to the egg_list for storage
				remove_food(2)						//Remove extra food for the breeding process

	//Handle standard food and filth adjustments
	var/ate_food = FALSE
	if(food_level > 0 && prob(50))					//Chance for the fish to eat some food
		if(food_level >= (fish_list.len * 0.1))		//If there is at least enough food to go around, feed all the fish
			remove_food(fish_list.len * 0.1)
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
	if(leaking && leaking)
		switch(leaking)							//Can't leak water if there is no water in the tank
			if(MAJOR_LEAK)							//At or below 25% health, the tank will lose 10 water_level per cycle (major leak)
				remove_water(10)
			if(MINOR_LEAK)						//At or below 50% health, the tank will lose 1 water_level per cycle (minor leak)
				add_water(1)

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
				if(food_level <= 5 && prob(25))
					kill_fish("feederfish")			//Kill the fish to reflect it's sacrifice, but don't increase the filth_level
					add_food(1)					//The corpse became food for the other fish, ecology at it's finest
			if("glofish")
				glo_light++
	if(!light_switch && (glo_light > 0))
		set_light(2,glo_light,"#99FF66")

/obj/machinery/fishtank/proc/remove_water(var/amount)
	water_level = max(0, water_level - amount)

/obj/machinery/fishtank/proc/add_water(var/amount)
	water_level = min(water_capacity, filth_level + amount)

/obj/machinery/fishtank/proc/remove_filth(var/amount)
	filth_level = max(0, filth_level - amount)

/obj/machinery/fishtank/proc/add_filth(var/amount)
	filth_level = min(MAX_FILTH, filth_level + amount)

/obj/machinery/fishtank/proc/remove_food(var/amount)
	food_level = max(0, food_level - amount)

/obj/machinery/fishtank/proc/add_food(var/amount)
	food_level = min(MAX_FOOD, food_level + amount)

/obj/machinery/fishtank/proc/check_health()
	//Max value check
	if(cur_health > max_health)						//Cur_health cannot exceed max_health, set it to max_health if it does
		cur_health = max_health
	//Leaking status check
	if(cur_health <= (max_health * 0.25))			//Major leak at or below 25% health (-10 water/cycle)
		leaking = 2
	else if(cur_health <= (max_health * 0.5))		//Minor leak at or below 50% health (-1 water/cycle)
		leaking = 1
	else											//Not leaking above 50% health
		leaking = 0
	//Destruction check
	if(cur_health <= 0)								//The tank is broken, destroy it
		destroy()

/obj/machinery/fishtank/proc/kill_fish(var/type = null)
	//Check if we were passed a fish to kill, otherwise kill a random one
	if(type)
		fish_list.Remove(type)						//Kill a fish of the specified type
	else
		fish_list.Remove(pick(fish_list))			//Kill a random fish

/obj/machinery/fishtank/proc/add_fish(var/type)
	//Check if we were passed a fish type
	fish_list.Add("[type]")						//Add a fish of the specified type
	//Announce the new fish
	visible_message("A new [type] has hatched in \the [src]!")

/obj/machinery/fishtank/proc/select_egg_type()
	var/fish = pick(fish_list)						//Select a fish from the fish in the tank
	if(prob(25))									//25% chance to be a dud (blank) egg
		fish = "dud"
	var/obj/item/fish_eggs/egg_path	= null			//Create empty variable to receive the egg_path
	egg_path = fish_eggs_list[fish]					//Locate the corresponding path from fish_eggs_list that matches the fish
	if(!egg_path)									//The fish wasn't located in the fish_eggs_list, potentially due to a typo, so return a dud egg
		return /obj/item/fish_eggs
	else											//The fish was located in the fish_eggs_list, so return the proper egg
		return egg_path

/obj/machinery/fishtank/proc/harvest_eggs(var/mob/user)
	if(!egg_list.len)									//Can't harvest non-existant eggs
		return

	for(var/i in egg_list.len)						//Loop until you've harvested all the eggs
		var/obj/item/fish_eggs/egg = pick(egg_list)	//Select an egg at random
		egg = new egg(get_turf(user))				//Spawn the egg at the user's feet
		egg_list.Remove(egg)						//Remove the egg from the egg_list

	egg_list.Cut()									//Destroy any excess eggs, clearing the egg_list

/obj/machinery/fishtank/proc/harvest_fish(var/mob/user)
	if(!fish_list.len)									//Can't catch non-existant fish!
		to_chat(user, "There are no fish in \the [src] to catch!")
		return

	var/caught_fish = input("Select a fish to catch.", "Fishing") as null|anything in fish_list		//Select a fish from the tank
	if(caught_fish)
		var/dead_fish = null
		dead_fish = fish_items_list[caught_fish]	//Locate the appropriate fish_item for the caught fish
		if(!dead_fish)								//No fish_item found, possibly due to typo or not being listed. Do nothing.
			return
		kill_fish(caught_fish)						//Kill the caught fish from the tank
		user.visible_message("[user.name] harvests \a [caught_fish] from \the [src].", "You scoop \a [caught_fish] out of \the [src].")
		new dead_fish(get_turf(user))				//Spawn the appropriate fish_item at the user's feet.

/obj/machinery/fishtank/proc/destroy(var/deconstruct = FALSE)
//	var/turf/T = get_turf(src)										//Store the tank's turf for atmos updating after deletion of tank
	if(!deconstruct)												//Check if we are deconstructing or breaking the tank
		for(var/i in  shard_count)									//Produce the appropriate number of glass shards
			new /obj/item/weapon/shard(get_turf(src))
		if(water_level)												//Spill any water that was left in the tank when it broke
			spill_water()
	else															//We are deconstructing, make glass sheets instead of shards
		var/sheets = shard_count + 1								//Deconstructing it salvages all the glass used to build the tank
		new /obj/item/stack/sheet/glass(get_turf(src), sheets)		//Produce the appropriate number of glass sheets, in a single stack
	qdel(src)														//qdel the tank and it's contents
//	T.air_update_turf(1)											//Update the air for the turf, to avoid permanent atmos sealing with wall tanks

/obj/machinery/fishtank/proc/spill_water()
	switch(tank_type)
		if("bowl")										//Fishbowl: Wets it's own tile
			var/turf/T = get_turf(src)
			if(!istype(T, /turf/simulated)) return
//			var/turf/simulated/S = T
	//		S.MakeSlippery()
		if("tank")										//Fishtank: Wets it's own tile and the 4 adjacent tiles (cardinal directions)
			var/turf/ST = get_turf(src)
//			if(istype(ST, /turf/simulated))
//				var/turf/simulated/ST2 = ST
//				ST2.MakeSlippery()
			var/list/L = ST.CardinalTurfs()
			for(var/turf/T in L)
				if(!istype(T, /turf/simulated)) continue
//				var/turf/simulated/S = T
			//	S.MakeSlippery()
	//	if("wall")							help me god			//Wall-tank: Wets it's own tile and the surrounding 8 tiles (3x3 square)
		//	for(var/turf/T in spiral_range_turfs(1, src.loc))  weird ass paradise code yo
		//	if(!istype(T, /turf/simulated)) continue
		//	var/turf/simulated/S = T
	//			S.MakeSlippery()

//////////////////////////////		Note from FalseIncarnate:
//		EXAMINE PROC		//			This proc is massive, messy, and probably could be handled better.
//////////////////////////////			Feel free to try cleaning it up if you think of a better way to do it.

/obj/machinery/fishtank/examine(mob/user)
	..()
	var/examine_message = list()
	//Approximate water level

	examine_message += "Water level: "

	if(water_level == 0)
		examine_message += "\The [src] is empty! "
	else if(water_level < water_capacity * 0.1)
		examine_message += "\The [src] is nearly empty! "
	else if(water_level <= water_capacity * 0.25)
		examine_message += "\The [src] is about one-quarter filled. "
	else if(water_level <= water_capacity * 0.5)
		examine_message += "\The [src] is about half filled. "
	else if(water_level <= water_capacity * 0.75)
		examine_message += "\The [src] is about three-quarters filled. "
	else if(water_level < water_capacity)
		examine_message += "\The [src] is nearly full! "
	else if(water_level == water_capacity)
		examine_message += "\The [src] is full! "

	examine_message += "<br>Cleanliness level: "

	//Approximate filth level
	if(filth_level == 0)
		examine_message += "\The [src] is spotless! "
	else if(filth_level <= 0.25*MAX_FILTH)
		examine_message += "\The [src] looks like the glass has been smudged. "
	else if(filth_level <= 0.5*MAX_FILTH)					//This is the breeding threshold
		examine_message += "\The [src] has some algae growth in it. "
	else if(filth_level <= 0.75*MAX_FILTH)
		examine_message += "\The [src] has a lot of algae growth in it. "
	else if(filth_level < MAX_FILTH)
		examine_message += "\The [src] is getting hard to see into! Someone should clean it soon! "
	else if(filth_level >= MAX_FILTH)
		examine_message += "\The [src] is absolutely disgusting! Someone should clean it NOW! "

	examine_message += "<br>Food level: "

	//Approximate food level
	if(!fish_list.len)								//Check if there are fish in the tank
		if(food_level > 0)						//Don't report a tank that has neither fish nor food in it
			examine_message += "There's some food in [src], but no fish! "
	else										//We've got fish, report the food level
		if(food_level == 0)
			examine_message += "The fish look very hungry! "
		else if(food_level < 0.2*MAX_FOOD)
			examine_message += "The fish are nibbling on the last of their food. "
		else if(food_level < MAX_FOOD)				//Breeding is possible
			examine_message += "The fish seem happy! "
		else if(food_level >= MAX_FOOD)
			examine_message += "There is a solid layer of fish food at the top. "

	//Report the number of harvestable eggs
	if(egg_list.len)								//Don't bother if there isn't any eggs
		examine_message += "<br>There are [egg_list.len] eggs able to be harvested! "

	examine_message += "<br>"

	//Report the number and types of live fish if there is water in the tank
	if(!fish_list.len)
		examine_message += "\The [src] doesn't contain any live fish. "
	else
		//Build a message reporting the types of fish
		var/fish_num = fish_list.len
		var/message = "You spot "
		while(fish_num > 0)
			if(fish_list.len > 1 && fish_num == 1)	//If there were at least 2 fish, and this is the last one, add "and" to the message
				message += "and "
			message += "a [fish_list[fish_num]]"
			fish_num --
			if(fish_num > 0)					//There's more fish, add a comma to the message
				message +=", "
		message +="."							//No more fish, end the message with a period
		//Display the number of fish and previously constructed message
		examine_message += "\The [src] contains [fish_list.len] live fish. [message] "

	examine_message += "<br>"

	//Report lid state for tanks and wall-tanks
	if(has_lid)									//Only report if the tank actually has a lid
		//Report lid state
		if(lid_switch)
			examine_message += "The lid is closed. "
		else
			examine_message += "The lid is open. "

	examine_message += "<br>"

	//Report if the tank is leaking/cracked
	if(water_level > 0)							//Tank has water, so it's actually leaking
		if(leaking == MINOR_LEAK)
			examine_message += "\The [src] is leaking."
		if(leaking == MAJOR_LEAK)
			examine_message += "\The [src] is leaking profusely!"
	else										//No water, report the cracks instead
		if(leaking == MINOR_LEAK)
			examine_message += "\The [src] is cracked."
		if(leaking == MAJOR_LEAK)
			examine_message += "\The [src] is nearly shattered!"


	//Finally, report the full examine_message constructed from the above reports
	to_chat(user, "[jointext(examine_message, "<br />")]")
	return examine_message

//////////////////////////////
//		ATACK PROCS			//
//////////////////////////////

/obj/machinery/fishtank/attack_alien(mob/living/user as mob)
	if(islarva(user))
		return
	attack_generic(user, 15)


/obj/machinery/fishtank/attack_hand(mob/user as mob)

	if(user.a_intent == I_HURT)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("<span class='danger'>[user.name] bangs against the [src]!</span>", \
							"<span class='danger'>You bang against the [src]!</span>", \
							"You hear a banging sound.")
	else
		playsound(src.loc, 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("[user] taps on the [src].", \
							"You tap on the [src].", \
							"You hear a knocking sound.")


/obj/machinery/fishtank/proc/hit(var/damage, var/sound_effect = 1)
	cur_health = max(0, cur_health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	check_health()

/obj/machinery/fishtank/proc/attack_generic(mob/living/user as mob, damage = 0)	//used by attack_alien, attack_animal, and attack_slime
	cur_health -= damage
	if(cur_health <= 0)
		user.visible_message("<span class='danger'>\The [user] smashes through \the [src]!</span>")
		destroy()
	else	//for nicer text
		user.visible_message("<span class='danger'>\The [user] smashes into \the [src]!</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
		check_health()

/obj/machinery/fishtank/attackby(var/obj/item/O, var/mob/user as mob)
	//Welders repair damaged tanks on help intent, damage on all others
	if(iswelder(O))
		var/obj/item/weapon/weldingtool/W = O
		if(user.a_intent == I_HELP)
			if(W.isOn())
				if(cur_health < max_health)
					to_chat(user, "You repair some of the cracks on \the [src].")
					cur_health += 20
					check_health()
				else
					to_chat(user, "There is no damage to fix!")
			else if(cur_health < max_health)
				to_chat(user, "[W.name] must on to repair this damage.")
		else
		//	user.changeNext_move(CLICK_CD_MELEE)
			hit(W.force)
		return TRUE
	//Open reagent containers add and remove water
	if(O.is_open_container())
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			if(lid_switch)
				to_chat(user, "Open the lid on \the [src] first!")
				return TRUE
			var/obj/item/weapon/reagent_containers/glass/C = O
			//Containers with any reagents will get dumped in
			if(C.reagents.total_volume)
				var/water_value = 0
				water_value += C.reagents.get_reagent_amount(WATER)				//Water is full value
				water_value += C.reagents.get_reagent_amount(HOLYWATER) *1.1		//Holywater is (somehow) better. Who said religion had to make sense?

				water_value += C.reagents.get_reagent_amount(ICE) * 0.80			//Ice is 80% value
				var/message = ""
				if(!water_value)													//The container has no water value, clear everything in it
					message = "The filtration process removes everything, leaving the water level unchanged."
					C.reagents.clear_reagents()
				else
					if(water_level == water_capacity)
						to_chat(user, "\the [src] is already full!")
						return TRUE
					else
						message = "The filtration process purifies the water, raising the water level."
						add_water(water_value)
						if(water_level == water_capacity)
							message += " You filled \the [src] to the brim!"
						if(water_level > water_capacity)
							message += " You overfilled \the [src] and some water runs down the side, wasted."
						C.reagents.clear_reagents()
				user.visible_message("[user] pours the contents of \the [C] into \the [src].", "[message]")
				return TRUE
			//Empty containers will scoop out water, filling the container as much as possible from the water_level
			else
				to_chat(world, "ENTERING THE 'ELSE' BLOCK")
				if(water_level == 0)
					to_chat(user, "\the [src] is empty!")
				else
					if(water_level >= C.volume)										//Enough to fill the container completely
						C.reagents.add_reagent(WATER, C.volume)
						remove_water(C.volume)
						user.visible_message("[user.name] scoops out some water from \the [src].", "You completely fill [C.name] from \the [src].")
					else															//Fill the container as much as possible with the water_level
						C.reagents.add_reagent("water", water_level)
						water_level = 0
						user.visible_message("[user.name] scoops out some water from \the [src].", "You fill [C.name] with the last of the water in \the [src].")
			return TRUE
	//Wrenches can deconstruct empty tanks, but not tanks with any water. Kills any fish left inside and destroys any unharvested eggs in the process
	if(iswrench(O))
		if (water_level == 0)
			to_chat(user, "<span class='notice'>Now disassembling \the [src].</span>")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user,50, target = src))
				destroy(1)
		else
			to_chat(user, "\The [src] must be empty before you disassemble it!")
		return
	//Fish eggs
	else if(istype(O, /obj/item/fish_eggs))
		var/obj/item/fish_eggs/egg = O
		//Don't add eggs if there is no water (they kinda need that to live)
		if(water_level == 0)
			to_chat(user, "\The [src] has no water; [egg.name] won't hatch without water!")
			return FALSE
		//Don't add eggs if the tank already has the max number of fish
		if(fish_list.len >= max_fish)
			to_chat(user, "\The [src] can't hold any more fish.")
			return FALSE
		add_fish(egg.fish_type)
		qdel(egg)
		return TRUE
	//Fish food
	else if(istype(O, /obj/item/weapon/fishtools/fish_food))
		//Only add food if there is water and it isn't already full of food
		if(!water_level)
			to_chat(user, "\the [src] doesn't have any water in it. You should fill it with water first.")
			return FALSE
		if(!food_level < MAX_FOOD)
			to_chat(user, "[src] already has plenty of food in it. You decide to not add more.")
			return FALSE

		if(fish_list.len == 0)
			user.visible_message("[user.name] shakes some fish food into the empty [src]... How sad.", "You shake some fish food into the empty [src]... If only it had fish.")
		else
			user.visible_message("[user.name] feeds the fish in \the [src]. The fish look excited!", "You feed the fish in \the [src]. They look excited!")
		add_food(10)

		return TRUE
	//Fish egg scoop
	else if(istype(O, /obj/item/weapon/fishtools/fish_egg_scoop))
		if(egg_list.len)
			user.visible_message("[user.name] harvests some fish eggs from \the [src].", "You scoop the fish eggs out of \the [src].")
			harvest_eggs(user)
		else
			user.visible_message("[user.name] fails to harvest any fish eggs from \the [src].", "There are no fish eggs in \the [src] to scoop out.")
		return TRUE
	//Fish net
	if(istype(O, /obj/item/weapon/fishtools/fish_net))
		harvest_fish(user)
		return TRUE
	//Tank brush
	if(istype(O, /obj/item/weapon/fishtools/fish_tank_brush))
		if(filth_level == 0)
			to_chat(user, "[src] is already spotless!")
			return TRUE
		filth_level = 0
		user.visible_message("\The [user] scrubs the inside of \the [src], cleaning the filth.", "You scrub the inside of \the [src], cleaning the filth.")

	else if(O && O.force)
		user.visible_message("<span class='danger'>\The [src] has been attacked by [user.name] with \the [O]!</span>")
		hit(O.force)
	return TRUE

/* tank construction */




/obj/structure/displaycase_frame/attackby(var/obj/item/weapon/F as obj, mob/user as mob) // FISH BOWL
	if (iswelder(F))
		to_chat(user, "You use the machine frame as a vice and shape the glass with the welder into a fish bowl")
		getFromPool(/obj/item/stack/sheet/metal, get_turf(src), 5)
		new /obj/machinery/fishtank/bowl(get_turf(src))
		qdel(src)

