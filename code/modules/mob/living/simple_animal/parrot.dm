/* Parrots!
 * Contains
 * 		Defines
 *		Inventory (headset stuff)
 *		Attack responces
 *		AI
 *		Procs / Verbs (usable by players)
 *		Sub-types
 *		Hear & say (the things we do for gimmicks)
 */

/*
 * Defines
 */

//Only a maximum of one action and one intent should be active at any given time.
//Actions
#define PARROT_PERCH 1		//Sitting/sleeping, not moving
#define PARROT_SWOOP 2		//Moving towards or away from a target
#define PARROT_WANDER 4		//Moving without a specific target in mind

//Intents
#define PARROT_STEAL 8		//Flying towards a target to steal it/from it
#define PARROT_ATTACK 16	//Flying towards a target to attack it
#define PARROT_RETURN 32	//Flying towards its perch
#define PARROT_FLEE 64		//Flying away from its attacker


/mob/living/simple_animal/parrot
	name = "parrot"
	desc = "The parrot squaks, \"It's a Parrot! BAWWK!\""
	icon = 'icons/mob/animal.dmi'
	icon_state = "parrot_fly"
	icon_living = "parrot_fly"
	icon_dead = "parrot_dead"
	pass_flags = PASSTABLE | PASSRAILING
	flags = HEAR | PROXMOVE | HEAR_ALWAYS

	speak = list("Hi","Hello!","Cracker?","BAWWWWK george mellons griffing me")
	speak_emote = list("squawks","says","yells")
	emote_hear = list("squawks","bawks")
	emote_see = list("flutters its wings")

	speak_override = FALSE

	speak_chance = 1 //1% (1 in 100) chance every tick; So about once per 150 seconds, assuming an average tick is 1.5s
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/cracker/
	melee_damage_upper = 10
	melee_damage_lower = 5

	response_help  = "pets"
	response_disarm = "gently moves aside"
	response_harm   = "swats"
	stop_automated_movement = 1
	//NO a_intent = I_HURT //parrots now start "aggressive" since only player parrots will nuzzle.
	attacktext = "chomps"
	friendly = "grooms"

	size = SIZE_TINY

	var/parrot_damage_upper = 10
	var/parrot_state = PARROT_WANDER //Hunt for a perch when created
	var/parrot_sleep_max = 25 //The time the parrot sits while perched before looking around. Mosly a way to avoid the parrot's AI in life() being run every single tick.
	var/parrot_sleep_dur = 25 //Same as above, this is the var that physically counts down

	var/parrot_speed = 5 //"Delay in world ticks between movement." according to byond. Yeah, that's BS but it does directly affect movement. Higher number = slower.
	//var/parrot_been_shot = 0 this wasn't working right, and parrots don't survive bullets.((Parrots get a speed bonus after being shot. This will deincrement every Life() and at 0 the parrot will return to regular speed.))

	var/parrot_lastmove = null //Updates/Stores position of the parrot while it's moving
	var/parrot_stuck = 0	//If parrot_lastmove hasnt changed, this will increment until it reaches parrot_stuck_threshold
	var/parrot_stuck_threshold = 10 //if this == parrot_stuck, it'll force the parrot back to wandering

	var/list/speech_buffer = list()
	var/list/available_channels = list()

	//Headset for Poly to yell at engineers :)
	var/obj/item/device/radio/headset/ears = null

	//The thing the parrot is currently interested in. This gets used for items the parrot wants to pick up, mobs it wants to steal from,
	//mobs it wants to attack or mobs that have attacked it
	var/atom/movable/parrot_interest = null

	//Parrots will generally sit on their perch unless something catches their eye.
	//These vars store their preffered perch and if they dont have one, what they can use as a perch
	var/obj/parrot_perch = null
	var/obj/desired_perches = list(/obj/structure/computerframe, 		/obj/structure/displaycase, \
									/obj/structure/filingcabinet,		/obj/machinery/teleport, \
									/obj/machinery/computer,			/obj/machinery/cloning/clonepod, \
									/obj/machinery/dna_scannernew,		/obj/machinery/telecomms, \
									/obj/machinery/nuclearbomb,			/obj/machinery/particle_accelerator, \
									/obj/machinery/recharge_station,	/obj/machinery/smartfridge, \
									/obj/machinery/suit_storage_unit)

	//Parrots are kleptomaniacs. This variable ... stores the item a parrot is holding.
	var/obj/item/held_item = null

	var/times_examined_while_dead = 0
	var/list/dead_lines = list("That parrot is definitely deceased.", \
		"You know a dead parrot when you see one, and you're looking at one right now.", \
		"It's dead, that's what's wrong with it.", \
		"It's bleeding demised.", \
		"It's passed on.", \
		"This parrot is no more.", \
		"It has ceased to be.", \
		"It's expired and gone to meet its maker.", \
		"This is a late parrot.", \
		"It's a stiff.", \
		"Bereft of life, it rests in peace.", \
		"It's rung down the curtain and joined the choir invisible.", \
		"This is an ex-parrot.")
	var/list/not_dead_lines = list("It's just resting.", \
		"It's stunned.", \
		"It's just tired and shagged out after a long squawk.", \
		"It's prolly pining for the fjords.", \
		"It prefers kippin' on it's back.", \
		"It's a beautiful bird, lovely plumage, innit?")

	var/has_headset = 1 //excluding parrotmorph parrots from gaining headsets when a mob is transformed into a parrot via wizard.

/mob/living/simple_animal/parrot/New()
	..()
	if(!ears && has_headset)
		var/headset = pick(/obj/item/device/radio/headset/headset_sec, \
						/obj/item/device/radio/headset/headset_eng, \
						/obj/item/device/radio/headset/headset_med, \
						/obj/item/device/radio/headset/headset_sci, \
						/obj/item/device/radio/headset/headset_cargo)
		ears = new headset(src)

	parrot_sleep_dur = parrot_sleep_max //In case someone decides to change the max without changing the duration var

	// WIP: the behavior tree controller drives the parrot AI.
	use_idle_tree(bt_parrot_tree())

	verbs.Add(/mob/living/simple_animal/parrot/proc/steal_from_ground, \
			  /mob/living/simple_animal/parrot/proc/steal_from_mob, \
			  /mob/living/simple_animal/parrot/verb/drop_held_item_player, \
			  /mob/living/simple_animal/parrot/proc/perch_player, \
			  /mob/living/simple_animal/parrot/proc/toggle_mode)


/mob/living/simple_animal/parrot/examine(mob/user)
	if(stat == DEAD)
		if(times_examined_while_dead < dead_lines.len)
			times_examined_while_dead++
			desc = dead_lines[times_examined_while_dead]
		else
			desc = pick(not_dead_lines)
	else
		desc = initial(desc)
		if(times_examined_while_dead)
			times_examined_while_dead = 0
		if(held_item)
			desc += "<br>It is holding [bicon(held_item)] \a [held_item]"
	..()

/mob/living/simple_animal/parrot/death(var/gibbed = FALSE)
	if(held_item)
		held_item.forceMove(src.loc)
		held_item = null
	walk(src,0)
	..(gibbed)

/mob/living/simple_animal/parrot/Stat()
	..()
	if(statpanel("Status"))
		stat("Held Item", held_item)
		stat("Mode",a_intent)

/mob/living/simple_animal/parrot/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker && speech.speaker != src && prob(20)) //Don't imitate outselves
		if(speech_buffer.len >= 20)
			speech_buffer -= pick(speech_buffer)
		speech_buffer |= speech.message
	..()

/mob/living/simple_animal/parrot/radio(var/datum/speech/speech, var/message_mode)
	. = ..()
	if(. != 0)
		return .

	switch(message_mode)
		if(MODE_HEADSET)
			if (ears)
				ears.talk_into(speech)
				return ITALICS | REDUCE_RANGE

		if(MODE_SECURE_HEADSET)
			if(ears)
				ears.talk_into(speech, 1) // No fucking clue why message_mode is 1.
			return ITALICS | REDUCE_RANGE
		if(MODE_DEPARTMENT)
			if(ears)
				ears.talk_into(speech, message_mode)
			return ITALICS | REDUCE_RANGE

	if(message_mode in radiochannels)
		if(ears)
			ears.talk_into(speech, message_mode)
			return ITALICS | REDUCE_RANGE

	return 0

/*
 * Inventory
 */
/mob/living/simple_animal/parrot/show_inv(mob/user)
	user.set_machine(src)
	if(user.stat)
		return

	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	if(ears)
		dat +=	"<br><b>Headset:</b> [ears] (<a href='?src=\ref[src];remove_inv=ears'>Remove</a>)"
	else
		dat +=	"<br><b>Headset:</b> <a href='?src=\ref[src];add_inv=ears'>Nothing</a>"

	user << browse(HTML_SKELETON(dat), "window=mob[real_name];size=325x500")
	onclose(user, "mob[real_name]")


/mob/living/simple_animal/parrot/Topic(href, href_list)

	//Can the usr physically do this?
	if(usr.incapacitated() || !usr.Adjacent(loc))
		return

	//Is the usr's mob type able to do this? (lolaliens)
	if(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr))

		//Removing from inventory
		if(href_list["remove_inv"])
			var/remove_from = href_list["remove_inv"]
			switch(remove_from)
				if("ears")
					if(ears)
						if(!stat)
							if(available_channels.len)
								src.say("[pick(available_channels)] BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
							else
								src.say("BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
						ears.forceMove(src.loc)
						ears = null
						for(var/possible_phrase in speak)
							if(copytext(possible_phrase,1,3) in department_radio_keys)
								possible_phrase = copytext(possible_phrase,3)
					else
						to_chat(usr, "<span class='warning'>There is nothing to remove from its [remove_from].</span>")
						return

		//Adding things to inventory
		else if(href_list["add_inv"])
			var/add_to = href_list["add_inv"]
			if(!usr.get_active_hand())
				to_chat(usr, "<span class='warning'>You have nothing in your hand to put on its [add_to].</span>")
				return
			switch(add_to)
				if("ears")
					if(ears)
						to_chat(usr, "<span class='warning'>It's already wearing something.</span>")
						return
					else
						var/obj/item/item_to_add = usr.get_active_hand()
						if(!item_to_add)
							return

						if( !istype(item_to_add,  /obj/item/device/radio/headset) )
							to_chat(usr, "<span class='warning'>This object won't fit.</span>")
							return

						var/obj/item/device/radio/headset/headset_to_add = item_to_add

						usr.drop_item(headset_to_add, src)
						src.ears = headset_to_add
						to_chat(usr, "You fit the headset onto [src].")

						clearlist(available_channels)
						for(var/ch in headset_to_add.channels)
							switch(ch)
								if("Engineering")
									available_channels.Add(":e")
								if("Command")
									available_channels.Add(":c")
								if("Security")
									available_channels.Add(":s")
								if("Science")
									available_channels.Add(":n")
								if("Medical")
									available_channels.Add(":m")
								if("Mining")
									available_channels.Add(":d")
								if("Cargo")
									available_channels.Add(":q")

						if(headset_to_add.translate_binary)
							available_channels.Add(":b")
		else
			..()


/*
 * Attack responces
 */
//Humans, monkeys, aliens
/mob/living/simple_animal/parrot/attack_hand(mob/living/carbon/M as mob)
	..()
	if(client)
		return
	if(!stat)
		switch(M.a_intent)
			if(I_DISARM)
				icon_state = "parrot_fly" //It is going to be flying regardless

				if(parrot_state == PARROT_PERCH)
					parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

				parrot_interest = M
				parrot_state = PARROT_SWOOP //The parrot just got a disarm, it WILL move, now to pick a direction..

				parrot_state |= PARROT_FLEE	//Don't let the item be caught
				playsound(M, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				if(prob(50))
					drop_held_item(pick(0,1)) // May or may not prime grenades
			if(I_HURT)
				icon_state = "parrot_fly" //It is going to be flying regardless of whether it flees or attacks

				if(parrot_state == PARROT_PERCH)
					parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

				parrot_interest = M
				parrot_state = PARROT_SWOOP //The parrot just got hit, it WILL move, now to pick a direction..

				if(M.health < 50) //Weakened mob? Fight back!
					parrot_state |= PARROT_ATTACK
				else
					parrot_state |= PARROT_FLEE	//Otherwise, fly like a bat out of hell!
					drop_held_item(0)

/mob/living/simple_animal/parrot/attack_paw(mob/living/carbon/monkey/M as mob)
	attack_hand(M)

/mob/living/simple_animal/parrot/attack_alien(mob/living/carbon/monkey/M as mob)
	attack_hand(M)

//Simple animals
/mob/living/simple_animal/parrot/attack_animal(mob/living/simple_animal/M as mob)
	. = ..() //goodbye immortal parrots

	if(client)
		return


	if(parrot_state == PARROT_PERCH)
		parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

	if(M.melee_damage_upper > 0 && !stat)
		parrot_interest = M
		parrot_state = PARROT_SWOOP | PARROT_ATTACK //Attack other animals regardless
		icon_state = "parrot_fly"

//Mobs with objects
/mob/living/simple_animal/parrot/attackby(var/obj/item/O as obj, var/mob/living/user as mob)
	if(!stat && !client && !istype(O, /obj/item/stack/medical) && !istype(O,/obj/item/weapon/reagent_containers/food/snacks/cracker))
		if(O.force)
			if(parrot_state == PARROT_PERCH)
				parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

			parrot_interest = user
			parrot_state = PARROT_SWOOP
			if (user.health < 50)
				parrot_state |= PARROT_ATTACK //weakened mob? fight back!
			else
				parrot_state |= PARROT_FLEE
			icon_state = "parrot_fly"
			drop_held_item(0)
	else if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/cracker)) //Poly wants a cracker.
		user.drop_item(O)
		qdel(O)
		if(health < maxHealth)
			adjustBruteLoss(-10)
		to_chat(user, "<span class='notice'>[src] eagerly devours the cracker.</span>")
		playsound(src.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
	..()
	return

//Bullets
/mob/living/simple_animal/parrot/bullet_act(var/obj/item/projectile/Proj)
	. = ..()
	if(!stat && !client)
		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = null
		parrot_state = PARROT_WANDER | PARROT_FLEE //Been shot and survived! RUN LIKE HELL!
		//parrot_been_shot += 5
		icon_state = "parrot_fly"
		drop_held_item(0)
	return


/*
 * AI - Not really intelligent, but I'm calling it AI anyway.
 */
/mob/living/simple_animal/parrot/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()

	//Sprite and AI update for when a parrot gets pulled
	if(pulledby && stat == CONSCIOUS)
		icon_state = "parrot_fly"
		if(!client)
			parrot_state = PARROT_WANDER
		return
	// The behavior tree controller drives the parrot AI (bt_parrot_tree()).

/*
 * Behavior tree leaves. The damage/attack handlers still set the legacy
 * parrot_state bits and parrot_interest; the tree re-evaluates them every
 * controller tick instead of Life() walking a state machine.
 */

/datum/bt_node/ai_behavior/parrot_action
/datum/bt_node/ai_behavior/parrot_action/proc/get_parrot(datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = controller.pawn
	return istype(parrot, /mob/living/simple_animal/parrot) ? parrot : null

/datum/bt_node/ai_behavior/parrot_action/proc/stop_flying(mob/living/simple_animal/parrot/parrot)
	walk(parrot, 0)

/// Flee from whatever hurt the parrot.
/datum/bt_node/ai_behavior/parrot_action/parrot_flee
/datum/bt_node/ai_behavior/parrot_action/parrot_flee/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot || !(parrot.parrot_state & PARROT_FLEE))
		return FALSE
	return isliving(parrot.parrot_interest)

/datum/bt_node/ai_behavior/parrot_action/parrot_flee/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot)
		return AI_BEHAVIOR_FAILED
	var/mob/living/threat = parrot.parrot_interest
	if(!threat || !isliving(threat) || QDELETED(threat) || get_dist(parrot, threat) > 7)
		parrot.parrot_interest = null
		parrot.parrot_state = PARROT_WANDER
		return AI_BEHAVIOR_SUCCEEDED
	stop_flying(parrot)
	walk_away(parrot, threat, 1, parrot.parrot_speed)
	parrot.isStuck()
	return AI_BEHAVIOR_SUCCEEDED

/// Fight back against a weakened attacker or another simple animal.
/datum/bt_node/ai_behavior/parrot_action/parrot_attack
/datum/bt_node/ai_behavior/parrot_action/parrot_attack/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot || !(parrot.parrot_state & PARROT_ATTACK))
		return FALSE
	return isliving(parrot.parrot_interest)

/datum/bt_node/ai_behavior/parrot_action/parrot_attack/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot)
		return AI_BEHAVIOR_FAILED
	var/mob/living/victim = parrot.parrot_interest
	if(!victim || !isliving(victim) || QDELETED(victim) || !(victim in view(parrot)))
		parrot.parrot_interest = null
		parrot.parrot_state = PARROT_WANDER
		return AI_BEHAVIOR_SUCCEEDED

	if(parrot.melee_damage_upper == 0)
		parrot.melee_damage_upper = parrot.parrot_damage_upper
		parrot.a_intent = I_HURT

	stop_flying(parrot)
	if(get_dist(parrot, victim) <= 1)
		if(victim.stat)
			parrot.parrot_interest = null
			if(!parrot.held_item)
				parrot.held_item = parrot.steal_from_ground()
				if(!parrot.held_item)
					parrot.held_item = parrot.steal_from_mob()
			if(parrot.parrot_perch && (parrot.parrot_perch in view(parrot)))
				parrot.parrot_state = PARROT_SWOOP | PARROT_RETURN
			else
				parrot.parrot_state = PARROT_WANDER
			return AI_BEHAVIOR_SUCCEEDED
		parrot.attacktext = pick("claws at", "chomps")
		victim.attack_animal(parrot)
		return AI_BEHAVIOR_SUCCEEDED

	parrot.start_walk_to(victim, 1, parrot.parrot_speed)
	parrot.isStuck()
	return AI_BEHAVIOR_SUCCEEDED

/// Fly to parrot_interest and steal a small item.
/datum/bt_node/ai_behavior/parrot_action/parrot_steal
/datum/bt_node/ai_behavior/parrot_action/parrot_steal/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot || !(parrot.parrot_state & PARROT_STEAL))
		return FALSE
	return parrot.parrot_interest && !parrot.held_item

/datum/bt_node/ai_behavior/parrot_action/parrot_steal/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot)
		return AI_BEHAVIOR_FAILED
	var/atom/movable/interest = parrot.parrot_interest
	if(!interest || parrot.held_item || QDELETED(interest) || !(interest in view(parrot)))
		parrot.parrot_state = PARROT_SWOOP | PARROT_RETURN
		return AI_BEHAVIOR_SUCCEEDED

	stop_flying(parrot)
	if(get_dist(parrot, interest) <= 1)
		if(isliving(interest))
			parrot.steal_from_mob()
		else if(!parrot.parrot_perch || interest.loc != parrot.parrot_perch.loc)
			parrot.held_item = interest
			interest.forceMove(parrot)
			parrot.response_disarm = "tries to remove \the [parrot.held_item] from"
			parrot.visible_message("[parrot] grabs [parrot.held_item]!", "<span class='notice'>You grab [parrot.held_item]!</span>", "You hear the sounds of wings flapping furiously.")
		parrot.parrot_interest = null
		parrot.parrot_state = PARROT_SWOOP | PARROT_RETURN
		return AI_BEHAVIOR_SUCCEEDED

	parrot.start_walk_to(interest, 1, parrot.parrot_speed)
	parrot.isStuck()
	return AI_BEHAVIOR_SUCCEEDED

/// Fly back to the perch and settle on it.
/datum/bt_node/ai_behavior/parrot_action/parrot_return
/datum/bt_node/ai_behavior/parrot_action/parrot_return/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot || !parrot.parrot_perch || !isturf(parrot.parrot_perch.loc))
		return FALSE
	return parrot.loc != parrot.parrot_perch.loc

/datum/bt_node/ai_behavior/parrot_action/parrot_return/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot)
		return AI_BEHAVIOR_FAILED
	stop_flying(parrot)
	if(!parrot.parrot_perch || !isturf(parrot.parrot_perch.loc))
		parrot.parrot_perch = null
		parrot.parrot_state = PARROT_WANDER
		return AI_BEHAVIOR_SUCCEEDED
	if(get_dist(parrot, parrot.parrot_perch) <= 1)
		parrot.forceMove(parrot.parrot_perch.loc)
		parrot.drop_held_item()
		parrot.parrot_state = PARROT_PERCH
		parrot.icon_state = "parrot_sit"
		return AI_BEHAVIOR_SUCCEEDED
	parrot.start_walk_to(parrot.parrot_perch, 1, parrot.parrot_speed)
	parrot.isStuck()
	return AI_BEHAVIOR_SUCCEEDED

/// Sit on the perch, count down, and every parrot_sleep_max ticks look for loot.
/datum/bt_node/ai_behavior/parrot_action/parrot_perch
/datum/bt_node/ai_behavior/parrot_action/parrot_perch/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot || !parrot.parrot_perch || !isturf(parrot.parrot_perch.loc))
		return FALSE
	return parrot.loc == parrot.parrot_perch.loc

/datum/bt_node/ai_behavior/parrot_action/parrot_perch/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot)
		return AI_BEHAVIOR_FAILED
	parrot.icon_state = "parrot_sit"
	if(--parrot.parrot_sleep_dur)
		return AI_BEHAVIOR_SUCCEEDED
	parrot.parrot_sleep_dur = parrot.parrot_sleep_max
	parrot.parrot_cycle_radio_speech()
	var/atom/movable/interest = parrot.search_for_item()
	if(interest)
		parrot.parrot_interest = interest
		parrot.parrot_state = PARROT_SWOOP | PARROT_STEAL
		parrot.icon_state = "parrot_fly"
		parrot.emote("me",,"looks in [interest]'s direction and takes flight.")
	return AI_BEHAVIOR_SUCCEEDED

/// Random flight, occasionally finding a perch or something to steal.
/datum/bt_node/ai_behavior/parrot_action/parrot_wander
/datum/bt_node/ai_behavior/parrot_action/parrot_wander/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/parrot/parrot = get_parrot(controller)
	if(!parrot)
		return AI_BEHAVIOR_FAILED
	stop_flying(parrot)
	parrot.parrot_interest = null
	if(prob(90))
		step(parrot, pick(cardinal))
		return AI_BEHAVIOR_SUCCEEDED

	if(!parrot.held_item && !parrot.parrot_perch)
		var/atom/movable/AM = parrot.search_for_perch_and_item()
		if(AM)
			if(istype(AM, /obj/item) || isliving(AM))
				parrot.parrot_interest = AM
				parrot.emote("me",,"turns and flies towards [AM].")
				parrot.parrot_state = PARROT_SWOOP | PARROT_STEAL
			else
				parrot.parrot_perch = AM
				parrot.parrot_state = PARROT_SWOOP | PARROT_RETURN
		return AI_BEHAVIOR_SUCCEEDED

	if(parrot.parrot_interest && (parrot.parrot_interest in view(parrot)))
		parrot.parrot_state = PARROT_SWOOP | PARROT_STEAL
		return AI_BEHAVIOR_SUCCEEDED
	if(parrot.parrot_perch && (parrot.parrot_perch in view(parrot)))
		parrot.parrot_state = PARROT_SWOOP | PARROT_RETURN
		return AI_BEHAVIOR_SUCCEEDED

	parrot.parrot_perch = parrot.search_for_perch()
	if(parrot.parrot_perch)
		parrot.parrot_state = PARROT_SWOOP | PARROT_RETURN
	return AI_BEHAVIOR_SUCCEEDED

/// The legacy headset speech cycling, run once per perch look-around.
/mob/living/simple_animal/parrot/proc/parrot_cycle_radio_speech()
	if(!speak.len)
		return
	var/list/newspeak = list()
	if(available_channels.len && src.ears)
		for(var/possible_phrase in speak)
			//50/50 chance to not use the radio at all
			var/useradio = 0
			if(prob(50))
				useradio = 1
			if(copytext(possible_phrase,1,3) in department_radio_keys)
				possible_phrase = "[useradio ? pick(available_channels) : ""][copytext(possible_phrase,3)]" //crop out the channel prefix
			else
				possible_phrase = "[useradio ? pick(available_channels) : ""][possible_phrase]"
			newspeak.Add(possible_phrase)
	else //If we have no headset or channels to use, dont try to use any!
		for(var/possible_phrase in speak)
			if(copytext(possible_phrase,1,3) in department_radio_keys)
				possible_phrase = "[copytext(possible_phrase,3,length(possible_phrase)+1)]" //crop out the channel prefix
			newspeak.Add(possible_phrase)
	speak = newspeak

/// Parrot tree: reactions first, then perch/steal/return, then wander.
/proc/bt_parrot_tree()
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/parrot_action/parrot_flee),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/parrot_action/parrot_attack),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/parrot_action/parrot_steal),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/parrot_action/parrot_return),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/parrot_action/parrot_perch),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/parrot_action/parrot_wander),
		),
	)

/*
 * Procs
 */

/mob/living/simple_animal/parrot/movement_delay()
	if(client && stat == CONSCIOUS && parrot_state != "parrot_fly")
		icon_state = "parrot_fly"
	return ..()

/mob/living/simple_animal/parrot/proc/isStuck()
	//Check to see if the parrot is stuck due to things like windows or doors or windowdoors
	if(parrot_lastmove)
		if(parrot_lastmove == src.loc)
			if(parrot_stuck_threshold >= ++parrot_stuck) //If it has been stuck for a while, go back to wander.
				parrot_state = PARROT_WANDER
				parrot_stuck = 0
				parrot_lastmove = null
				return 1
		else
			parrot_lastmove = null
	else
		parrot_lastmove = src.loc
	return 0

/mob/living/simple_animal/parrot/proc/search_for_item()
	for(var/atom/movable/AM in view(src))
		//Skip items we already stole or are wearing or are too big
		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue

		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			if(I.w_class < W_CLASS_SMALL)
				return I

		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			for(var/obj/item/I in C.held_items)
				if(I.w_class <= W_CLASS_SMALL)
					return C

	return null

/mob/living/simple_animal/parrot/proc/search_for_perch()
	for(var/obj/O in view(src))
		for(var/path in desired_perches)
			if(istype(O, path))
				return O
	return null

//This proc was made to save on doing two 'in view' loops seperatly
/mob/living/simple_animal/parrot/proc/search_for_perch_and_item()
	for(var/atom/movable/AM in view(src))
		for(var/perch_path in desired_perches)
			if(istype(AM, perch_path))
				return AM

		//Skip items we already stole or are wearing or are too big
		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue

		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			if(I.w_class <= W_CLASS_SMALL)
				return I

		if(iscarbon(AM))
			var/mob/living/carbon/C = AM

			for(var/obj/item/I in C.held_items)
				if(I.w_class <= W_CLASS_SMALL)
					return C
	return null


/*
 * Verbs - These are actually procs, but can be used as verbs by player-controlled parrots.
 */
/mob/living/simple_animal/parrot/proc/steal_from_ground()
	set name = "Steal from ground"
	set category = "Parrot"
	set desc = "Grabs a nearby item."

	if(stat)
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding [held_item]</span>")
		return 1

	for(var/obj/item/I in view(1,src))
		if(!Adjacent(I))
			continue
		//Make sure we're not already holding it and it's small enough
		if(I.loc != src && I.w_class <= W_CLASS_SMALL)

			//If we have a perch and the item is sitting on it, continue
			if(!client && parrot_perch && I.loc == parrot_perch.loc)
				continue

			held_item = I
			I.forceMove(src)
			response_disarm = "tries to remove \the [held_item] from"
			visible_message("[src] grabs [held_item]!", "<span class='notice'>You grab [held_item]!</span>", "You hear the sounds of wings flapping furiously.")
			return held_item

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return 0

/mob/living/simple_animal/parrot/proc/steal_from_mob()
	set name = "Steal from mob"
	set category = "Parrot"
	set desc = "Steals an item right out of a person's hand!"

	if(stat)
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding [held_item]</span>")
		return 1

	var/obj/item/stolen_item = null

	for(var/mob/living/carbon/C in view(1,src))
		if(!Adjacent(C))
			continue

		for(var/obj/item/I in C.held_items)
			if(I.w_class > W_CLASS_SMALL)
				continue

			stolen_item = I

		if(stolen_item)
			C.u_equip(stolen_item)
			held_item = stolen_item
			stolen_item.forceMove(src)
			response_disarm = "tries to remove \the [held_item] from"
			visible_message("[src] grabs [held_item] out of [C]'s hand!", "<span class='notice'>You snag [held_item] out of [C]'s hand!</span>", "You hear the sounds of wings flapping furiously.")
			return held_item

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return 0

/mob/living/simple_animal/parrot/verb/drop_held_item_player()
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	src.drop_held_item()

	return

/mob/living/simple_animal/parrot/proc/drop_held_item(var/drop_gently = 1)
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(stat)
		return -1

	if(!held_item)
		if(src == usr) //So that other mobs wont make this message appear when they're bludgeoning you.
			to_chat(src, "<span class='warning'>You have nothing to drop!</span>")
		return 0


//parrots will eat crackers instead of dropping them
	if(istype(held_item,/obj/item/weapon/reagent_containers/food/snacks/cracker) && (drop_gently))
		QDEL_NULL(held_item)
		if(health < maxHealth)
			adjustBruteLoss(-10)
		emote("me",,"eagerly downs the cracker.")
		playsound(src.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
		return 1


	if(!drop_gently)
		if(istype(held_item, /obj/item/weapon/grenade))
			var/obj/item/weapon/grenade/G = held_item
			G.forceMove(src.loc)
			G.prime(src)
			to_chat(src, "You let go of [held_item]!")
			held_item = null
			return 1

	visible_message("[src] drops \the [held_item].", "You drop \the [held_item].")
	response_disarm = "gently pushes aside"
	held_item.forceMove(src.loc)
	held_item = null
	return 1

/mob/living/simple_animal/parrot/proc/perch_player()
	set name = "Sit"
	set category = "Parrot"
	set desc = "Sit on a nice comfy perch."

	if(stat || !client)
		return

	if(icon_state == "parrot_fly")
		for(var/atom/movable/AM in view(src,1))
			if(!Adjacent(AM))
				continue
			for(var/perch_path in desired_perches)
				if(istype(AM, perch_path))
					forceMove(AM.loc)
					icon_state = "parrot_sit"
					return
	to_chat(src, "<span class='warning'>There is no perch nearby to sit on.</span>")
	return

/mob/living/simple_animal/parrot/proc/toggle_mode()
	set name = "Toggle mode"
	set category = "Parrot"
	set desc = "Time to bear those claws!"

	if(stat || !client)
		return

	if(melee_damage_upper)
		melee_damage_upper = 0
		a_intent = I_HELP
	else
		melee_damage_upper = parrot_damage_upper
		a_intent = I_HURT
	return

/*
 * Sub-types
 */
/mob/living/simple_animal/parrot/Poly
	name = "Poly"
	desc = "Poly the Parrot. An expert on quantum cracker theory."
	speak = list("Poly wanna cracker!", ":e Check the singulo, you chucklefucks!",":e Wire the solars, you lazy bums!",":e WHO TOOK THE DAMN HARDSUITS?",":e OH GOD IT'S LOOSE CALL THE SHUTTLE",":e How do I set up the. SHow do I set u p the Singu how do I set up the SCo I do I set up. how I the scrungulartiy????")
	is_pet = TRUE

/mob/living/simple_animal/parrot/Poly/New()
	ears = new /obj/item/device/radio/headset/headset_eng(src)
	available_channels = list(":e")
	..()
