//THE HIVE: THE AWAY MISSION

//A chaotic spaceship built by something VERY scary from VERY far away (but now it's VERY close to the station so you gotta go there and kick some alien ass)
//Very rough and spiky on the outside
//Interior is full of corridors with dead ends and many branches. There are also supermatter lakes that don't spread because they're kept in place by advanced alien technology!
//You'll also find the following inside:

//Alien wall: indestructible wall that looks spoopy
//Alien floor: indestructible floor

//Hive pylon: structure that emits very powerful radiation
//Breathing floor: an alien floor that slows you down when you're walking on it
//Supermatter lake:  instantly kills you if you touch it or walk into it, no matter your armour, race, gender or admin flags. Thankfully the aliens have been so kind that they've built catwalks over some of it

//Alien Denizen: basic alien, behaves much like a simple space carp

//Alien Executioner: highly mobile enemy. when it comes adjacent to the enemy, it will switch into 'attack mode' and start attacking very fast. When the target moves away, it will switch back into 'movement mode' and start chasing again
//                   Can't attack while in 'movement mode'. Unaffected by breathing floors.

//Alien Arsonist: very slow tank enemy that shoots napalm bombs
//

//Alien Artificer: alien that PERMANENTLY turns alien floors below it into breathing floors. They don't wander around and only start moving
//                 when they see a target

///////////////////////////////////////////****THE MISSION****////////////////////////////////////////////
/datum/map_element/away_mission/hive
	name = "The Hive"
	file_path = "maps/RandomZLevels/hive.dmm"
	desc = "A hideous space structure full of mindless monsters, death and devastation lurking around every corner. No, this isn't Space Station 13 - this is The Hive."

	var/obj/item/hive/cpu/CPU
	var/obj/structure/hive/communicator/communicator
	var/obj/structure/hive/cloner/replicator

	var/bluespace_deaths = 0
	var/bluespace_alien_kills = 0

/datum/map_element/away_mission/hive/initialize(list/objects)
	..()

	CPU = locate(/obj/item/hive/cpu) in objects
	communicator = locate(/obj/structure/hive/communicator) in objects
	replicator = locate(/obj/structure/hive/cloner) in objects

	if(CPU)
		CPU.map_element = src
	else
		message_admins("<span class='warning'>Unable to find the alien CPU in the away mission!</span>")

	if(!communicator)
		message_admins("<span class='warning'>Unable to find the alien communicator in the away mission!</span>")

	if(!replicator)
		message_admins("<span class='warning'>Unable to find the alien replicator in the away mission!</span>")

/datum/map_element/away_mission/hive/process_scoreboard()
	var/list/L = list()

	if(!CPU)
		L["Hive CPU destroyed!"] = -10000 //Subtract 10000 points for being nuclear fuck-ups and destroying a valuable alien technology
	else if(istype(get_area(CPU), /area/shuttle/escape))
		L["Hive CPU retreived!"] = 25000 //Add 25000 points for doing your jobs
	else
		L["Hive CPU left behind."] = 0 //Whatever, we'll send somebody to pick it up

	if(!communicator)
		L["Hive communicator destroyed!"] = 5000

	if(!replicator)
		L["Hive replicator destroyed!"] = 5000

	if(!bluespace_deaths)
		L["No supermatter lake-related casualties."] = 1000
	else
		L += "[bluespace_deaths] people fell into the supermatter lakes." //Don't subtact points, they had it hard enough

	if(bluespace_alien_kills)
		L["[bluespace_alien_kills] aliens killed by the supermatter lakes."] = 25 * bluespace_alien_kills

	return L

///////////////////////////////////////////****NARRATIONS****/////////////////////////////////////////////
/obj/effect/narration/hive/intro
	msg = "From the window you can see a chaotic structure larger than anything you've ever seen in your life. Its surface constantly shifts and distorts, and the exterior is covered in massive spikes. That's not at all what you'd expect a spaceship to look like."

/obj/effect/narration/hive/entrance
	msg = "As you enter the thin passageway, you begin to feel very uneasy. Despite all the movement around you, your surroundings are dead quiet, except for a very faint heartbeat in the distance. Or could it be yours?"

/obj/effect/narration/hive/lake
	msg = "A supermatter lake takes up most of this room's floor. It constantly sizzles and sparks as dust specks collide with it. If you're going to walk on these catwalks, you better not make a misstep."

/obj/effect/narration/hive/cloning_hallway
	msg = "You notice that the surface of the floors and walls around you becomes more and more porous, and more... alive. You must be approaching the cloning chamber."

/obj/effect/narration/hive/cloning
	msg = "A large alien machine hangs down from the ceiling. It looks like a human heart, and it pulsates like one as well. You feel like it's reacting to your presence by beating faster and faster, but that might just be your imagination."
	play_sound = 'sound/effects/heart_beat_loop.ogg'

/obj/effect/narration/hive/control
	msg = "You enter what must've once been a cockpit of a space shuttle. Now it's barely recognizable - most of the floors and the walls here have been replaced with alien materials. A nearby computer seems to recognize you as a friendly lifeform, and greets you to the best of its abilities."
	play_sound = 'sound/ambience/ambimalf.ogg' //same sound as the AI upload

/obj/effect/narration/hive/comms
	msg = "What looks like a massive blob of flesh lies the middle of the room. A glowing substance regularly passes through the tubes under its skin."
	play_sound = 'sound/ambience/shipambience.ogg' //background noise

////////PAPERWORKS///////
/obj/item/weapon/paper/hive/birthday_note
	name = "paper- 'Happy Birthday, Chechen'"
	info = {"You only care about two things in your life - eating cakes and perving at Russian chicks, so we got you an appropriate present. Never change, you fat piece of shit.<br><br>

	<i>Dan</i><br>
	<i>Parek</i><br>
	<i>Szpindel</i><br>
	<i>Amara</i><br>"}

//all info you need to find the marauder parts. if you ctrl+F the map for them you'll have 7 days of bad luck
//lueduozhe = marauder in google-translate-mandarin

/obj/item/weapon/paper/hive/marauder_lost
	name = "paper- 'HOW THE HELL DID YOU LOSE AN ENTIRE LUEDUOZHE'"
	info = {"Give me a single reason not to stick all of your retarded asses in the deprotonizer. Lueduozhe 1 is gone and there's a toy in its place. I demand answers.<br>
	<i>Omar</i> <b>ID: 1C/1</b>"}

/obj/item/weapon/paper/hive/marauder_rescue
	name = "paper- 'Re:Re:Re: The blueblood mech disappeared and Commander wants to deprotonize our asses'"
	info = {"After concluding an investigation, I found out that the Lueduozhe was disassembled in Mech Bay, and its parts were shipped all over the station. I have an access to the mail trackers and got their location:<br><br>
	Chassis: Kitchen in meat fridge<br>
	Left Arm: Inside the sauna<br>
	Right Arm: Atmospherics - Nitrogen chamber<br>
	Left Leg: Maintenance between research and PersonalQuarters<br>
	Right Leg: Biomed (near the bridge), body scanner 2<br>
	Plating: Hallway near the supermatter engine<br>
	Head: Vending machine in the same hallway (in place of the $60 chips)<br>
	CCM: Outside of Atmospherics<br>
	PCM: Engineering tool storage<br>
	WCM: Under the radio transmitter<br>
	<br>
	Let's do the exact same thing to the clown before the commander \"deprotonizes our asses\" (does this mean what I think this means?).<br>
	<i>Amara</i> <b>ID: 222F/4</b>
	"}

/obj/item/weapon/paper/hive/fluff/unisex
	name = "paper- 'Re: Bathroom C is now unisex'"
	info = {"Does this mean that we at DET no longer have a safe place to hide from Barb? Just do me a favor and fucking kill me.<br>
	<i>Qun Lee</i>"}

/obj/item/weapon/paper/hive/fluff/chain_letter
	name = "paper- 'Re:Fwd: Forward this to 5 people or DEMONS will invade your station and kill you'"
	info = {"I'll see that your mail permissions are revoked, Todd. You're the laughing stock of the division. Do you seriously believe in that crap?<br>
	<i>Szpindel</i>"}

/obj/item/weapon/paper/hive/stickybomb
	name = "paper- 'Re:Re:Re:Re:Re:Re:Re:Re:Re: Minor adjustments to the stickybomb launcher'"
	info = {"Again, I'm working in a tiny shed with shit for tools!! I'm not going to do anything until you move me to R&D-15.<br>
	<i>Dan</i>"}

/obj/item/weapon/paper/hive/nikita
	name = "paper- 'Is Nikita a male or female name?'"
	info = {"Just got an email from ChanDE saying that apparently I ordered a \"Nikita\" 2 weeks ago (on New Years when we got shitfaced) and the shuttle is arriving tomorrow. The Consensus gives me mixed results and I really want to know the gender of this mail whore before it arrives<br>
	<i>Yi Cheng</i> <b>ID: 12C/3"}

////////SOUNDWORKS///////

/obj/effect/narration/hive/ambience_sound_1
	play_sound = 'sound/ambience/ambigen3.ogg' //background noise

/obj/effect/narration/hive/ambience_sound_2
	play_sound = 'sound/ambience/ambimo2.ogg' //creepy noises + faint screams

/obj/effect/narration/hive/ambience_sound_3
	play_sound = 'sound/ambience/ambisin2.ogg' //background noise - machines, rhytm

/obj/effect/narration/hive/ambience_sound_4
	play_sound = 'sound/ambience/ambimine.ogg' //background noise - something that sounds like hissing + soundtrack

/obj/effect/narration/hive/ambience_sound_5
	play_sound = 'sound/ambience/ambimo1.ogg' //morgue intro (creepy stuff)

/obj/effect/trap/sound/hive/alarm //alarm sound (jumpscare xd)
	sound_to_play = 'sound/ambience/alarm4.ogg'

/obj/effect/trap/sound/hive/static_noise //white noise + voices in the background (another jumpscare)
	sound_to_play = 'sound/effects/static/static5.ogg'

/obj/effect/trap/sound/hive/hallucination/turn_around
	sound_to_play = 'sound/hallucinations/turn_around1.ogg'

/obj/effect/trap/sound/hive/hallucination/wail
	sound_to_play = 'sound/hallucinations/wail.ogg'
	volume = 100

/obj/effect/trap/sound/hive/hallucination/over_here1
	sound_to_play = 'sound/hallucinations/over_here1.ogg'

/obj/effect/trap/sound/hive/hallucination/over_here2
	sound_to_play = 'sound/hallucinations/over_here2.ogg'



/obj/effect/trap/sound/hive/birthday //birthday party for a guy who never came back to his quarters (featuring a dead stripper in a cake)
	sound_to_play = 'sound/ambience/fire_alarm.ogg' //Two sounds making a repetitive ""melody"". Kinda reminded me of the sounds that toys that play music play when they're broken

/obj/effect/trap/sound/hive/birthday/activate()
	.=..()

	//Eject the dead stripper
	for(var/obj/structure/popout_cake/corpse_grabber/CG in range(7))
		CG.release_object(drop = TRUE)

/obj/effect/landmark/corpse/stripper/russian/hive
	brute_dmg = 100
	toxin_dmg = 100
	burn_dmg = 70

///////////////////////////////////////////****AREAS & LADDERS****/////////////////////////////////////

/area/awaymission/hive
	name = "hive"

/area/awaymission/hive/secure
	icon_state = "armory"
	flags = NO_PORTALS | NO_TELEPORT

/*
/area/awaymission/hive/cloning_chamber
	name = "hive cloning chamber"

/area/awaymission/hive/engine_room
	name = "hive engine room"

/area/awaymission/hive/control_room
	name = "hive control room"
*/

/obj/structure/ladder/hive/hive
	id = "hive"
	height = 1

/obj/structure/ladder/hive/spaceship
	id = "hive"
	height = 0

///////////////////////////////////////////****TURFS****//////////////////////////////////////////////////

#define EVIL_FLOOR_CO2 (44.8 * CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION)) //44.8 kPa

/turf/unsimulated/floor/evil
	icon_state = "evilfloor"

	carbon_dioxide = EVIL_FLOOR_CO2
	oxygen = 0
	nitrogen = 0
	temperature = T0C-10 //-10 degrees C

/turf/unsimulated/floor/evil/breathing
	name = "breathing floor"
	desc = "This surface is constantly twisting and moving. It looks like it would take a lot of effort to just walk on it."
	icon_state = "breathingfloor_1"

	var/additional_slowdown = 8

/turf/unsimulated/floor/evil/breathing/New()
	..()

	icon_state = "breathingfloor_[rand(1,6)]"
	additional_slowdown = rand(6,10)

/turf/unsimulated/floor/evil/breathing/adjust_slowdown(mob/living/L, current_slowdown)
	if(istype(L, /mob/living/simple_animal/hostile/hive_alien)) //Hive aliens are immune to this
		return current_slowdown

	return current_slowdown + additional_slowdown

/turf/unsimulated/floor/fake_supermatter/hive
	carbon_dioxide = EVIL_FLOOR_CO2
	oxygen = 0
	nitrogen = 0
	temperature = T0C-10 //-10 degrees C

#undef EVIL_FLOOR_CO2

/turf/unsimulated/wall/supermatter/no_spread/lake
	name = "Supermatter Lake"
	desc = "It appears to be somewhat contained. It emits a great gravitational pull, making flying or shooting over it impossible."
	opacity = 0

/turf/unsimulated/wall/supermatter/no_spread/lake/Consume(atom/A)
	var/datum/map_element/away_mission/hive/hive
	if(istype(map_element, /datum/map_element/away_mission/hive))
		hive = map_element

	if(issilicon(A) || ishuman(A))
		var/mob/living/L = A
		if(L.ckey)
			hive.bluespace_deaths++
			log_game("[key_name(L)] consumed by a supermatter lake [formatJumpTo(src)]")
	else if(istype(A, /mob/living/simple_animal/hostile/hive_alien))
		hive.bluespace_alien_kills++

	return ..()

///////////////////////////////////////////****STRUCTURES****//////////////////////////////////////////////////

/obj/structure/hive
	anchored = TRUE
	density = TRUE

	var/health = 10
	var/gibtype = /obj/effect/gibspawner/robot

	var/datum/map_element/away_mission/hive/away_mission

/obj/structure/hive/spawned_by_map_element(datum/map_element/away_mission/hive/ME)
	..()

	if(istype(ME))
		away_mission = ME

/obj/structure/hive/Destroy()
	..()

	if(away_mission)
		//Clear references
		if(away_mission.communicator == src)
			away_mission.communicator = null
		else if(away_mission.replicator == src)
			away_mission.replicator = null

/obj/structure/hive/proc/healthcheck()
	if(health <= 0)
		Die()

/obj/structure/hive/proc/Die()
	if(gibtype)
		new gibtype(get_turf(src))

	qdel(src)

/obj/structure/hive/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	.=..()
	healthcheck()

/obj/structure/hive/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= rand(150, 250)
		if(2.0)
			health -= rand(30, 60)
		if(3.0)
			health -= rand(20, 30)

	healthcheck()

/obj/structure/hive/attack_hand(mob/user)
	if(M_HULK in user.mutations)
		user.visible_message("<span class='danger'>[user] smashes \the [src]!</span>")
		health -= 10
		healthcheck()
		return 1

	to_chat(user, "<span class='notice'>You're not sure what to do with \the [src], and your punches wouldn't do much damage to it.</span>")

/obj/structure/hive/attackby(obj/item/W, mob/user)
	if(W.damtype == BRUTE || W.damtype == BURN)
		health -= W.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>", \
		"<span class='warning'>You hit \the [src] with \the [W].</span>")
		healthcheck()
		return 1

//Pylon
/obj/structure/hive/pylon
	name = "hive pylon"
	desc = "An alien machine that appears to release large amounts of radiation into its surroundings."

	icon_state = "hive_pylon"
	health = 20

	var/radiation_cooldown = 40 SECONDS
	var/last_pulse

	var/radiation_range = 10
	var/radiation_power = 40

/obj/structure/hive/pylon/New()
	..()

	processing_objects.Add(src)

/obj/structure/hive/pylon/Destroy()
	processing_objects.Remove(src)

	..()

/obj/structure/hive/pylon/process()
	if((last_pulse + radiation_cooldown < world.time) && prob(25)) //To make the radiation pulses irregular, it has a 25% chance of pulsing every process
		last_pulse = world.time

		emit_radiation(radiation_range, radiation_power)
		radiation_range = rand(7,15)
		radiation_power = rand(10,70)

/obj/structure/hive/pylon/proc/emit_radiation(rad_range, rad_power )
	// Radiation
	for(var/mob/living/carbon/M in range(src, rad_range))
		var/msg = pick(\
		"You hear a slow clicking.",\
		"Your head begins to hurt.",\
		"You feel tired for some reason.",\
		"You feel odd and out of place.",\
		"You feel mildly nauseated.")

		to_chat(M, "<span class='warning'>[msg]</span>")
		if(istype(M,/mob/living/carbon/human))
			M.apply_effect(rad_power, IRRADIATE)
		else
			M.radiation += rad_power

//Cloner
/obj/structure/hive/cloner
	name = "hive replicator"
	desc = "This seemingly organic structure resembling a human heart hangs down from the ceiling, beating at a steady rate."

	icon_state = "hive_heart"
	health = 300

	var/create_cooldown = 75 SECONDS
	var/last_create

/obj/structure/hive/cloner/New()
	..()

	processing_objects.Add(src)

/obj/structure/hive/cloner/Destroy()
	processing_objects.Remove(src)

	..()

/obj/structure/hive/cloner/process()
	if((last_create + create_cooldown < world.time))
		last_create = world.time

		spawn_aliens()

/obj/structure/hive/cloner/proc/spawn_aliens()
	var/area/A = get_area(src)

	if(A)
		to_chat(A, 'sound/effects/heart_beat_loop.ogg') //Play the sound globally across the entire away mission

	for(var/obj/effect/landmark/hive/monster_spawner/MS in landmarks_list)

		var/valid_spawn = TRUE
		var/turf/T = get_turf(MS)
		//Make sure there's no alien in that location
		for(var/mob/living/simple_animal/hostile/hive_alien/HA in T)
			if(!HA.isDead()) //Dead aliens don't count
				valid_spawn = FALSE
				break

		if(!valid_spawn)
			continue

		var/spawned_type = pick(\
		/mob/living/simple_animal/hostile/hive_alien,\
		/mob/living/simple_animal/hostile/hive_alien/executioner,\
		/mob/living/simple_animal/hostile/hive_alien/artificer)//,\
		///mob/living/simple_animal/hostile/hive_alien/arsonist)

		spawn(rand(2 SECONDS,40 SECONDS))
			var/mob/living/simple_animal/hostile/hive_alien/HA = new spawned_type(T)
			HA.visible_message("<span class='danger'>\The [HA] crawls down from an opening in the ceiling!</span>")

			var/played_sound = pick(\
			'sound/effects/wind/wind_2_1.ogg',\
			'sound/effects/wind/wind_2_2.ogg',\
			'sound/effects/wind/wind_3_1.ogg',\
			)
			playsound(get_turf(HA), played_sound, 40, 1)

/obj/effect/landmark/hive/monster_spawner
	name = "alien spawner"
	desc = "Periodically spawns monsters if the hive replicator isn't destroyed."
	icon_state = "x"

//Communication unit
/obj/structure/hive/communicator
	name = "hive mind"
	desc = "This must be the main relay that allows different parts of the Hive to communicate with each other through alien pylons."
	icon_state = "hive_comms"
	health = 150
	gibtype = /obj/effect/gibspawner/human

//Husked mob
/obj/structure/hive/husk
	name = "hollow husk"
	desc = "What was once a living creature, now dehydrated and fully mummified by alien technology. Looks very real and alive from a distance."
	gibtype = /obj/effect/decal/cleanable/scattered_sand
	health = 1

	//In subtypes, either set the icon and icon state, or set this variable to the mob's path (e.g. /mob/living/simple_animal/hostile/creature)
	var/mob_type = null

/obj/structure/hive/husk/New()
	..()

	if(mob_type)
		var/atom/A = mob_type

		appearance = initial(A.appearance)

		//Because changing the appearance also changes description and name
		name = initial(name)
		desc = initial(desc)

	dir = pick(cardinal)

/obj/structure/hive/husk/Die()
	visible_message("<span class='notice'>\The [src] crumbles into dust!</span>")

	return ..()

/obj/structure/hive/husk/martian //never
	icon = 'icons/mob/martian.dmi'
	icon_state = "fuggle"

/obj/structure/hive/husk/martian/New()
	..()

	icon_state = pick("fuggle", "martian")

/obj/structure/hive/husk/vox
	icon = 'icons/mob/vox.dmi'
	icon_state = "armalis"

/obj/structure/hive/husk/creature
	icon = 'icons/mob/critter.dmi'
	icon_state = "otherthing_static"

/obj/structure/hive/husk/wolf
	mob_type = /mob/living/simple_animal/hostile/wolf

/obj/structure/hive/husk/diona
	mob_type = /mob/living/simple_animal/hostile/humanoid/diona

/obj/structure/hive/husk/human
	icon = 'icons/mob/human.dmi'
	icon_state = "husk_s"
	desc = "What was once a living creature, now dehydrated and fully mummified by alien technology."

//////TRAPS/////////
/obj/effect/trap/fire_trap //When triggered, spawns a fire blast nearby
	name = "fire trap"
	var/fire_type = /obj/effect/fire_blast

	var/fire_damage = 5
	var/pressure = ONE_ATMOSPHERE * 4.5
	var/temperature = T0C + 175
	var/fire_duration

/obj/effect/trap/fire_trap/activate(atom/movable/AM)
	new /obj/effect/fire_blast/blue(get_step(get_turf(AM), pick(cardinal)), fire_damage, 0, 1, pressure, temperature, fire_duration)

/obj/effect/trap/frog_trap/hive //When triggered, surrounds you with hive denizens
	name = "monster trap"
	frog_type = /mob/living/simple_animal/hostile/hive_alien

/obj/effect/trap/frog_trap/hive/artificer //same but artificers
	frog_type = /mob/living/simple_animal/hostile/hive_alien/artificer

/obj/effect/trap/frog_trap/hive/executioner //same but executioners. VERY dangerous
	frog_type = /mob/living/simple_animal/hostile/hive_alien/executioner

///////////////////////////////////////////****ITEMS****//////////////////////////////////////////////////

/obj/item/hive/cpu
	name = "alien processing unit"
	desc = "This massive piece of machinery appears to be communicating with the hive, giving orders and controlling the aliens. It appears to be more complex that anything we've ever seen. If you retreived it from here, our research could advance a few hundred years into the future."

	icon_state = "hive_cpu"

	w_class = W_CLASS_LARGE
	throw_range = 0
	anchored = TRUE //Forces people to carry it by hand, no pulling!
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND

	var/datum/map_element/away_mission/hive/map_element

/obj/item/hive/cpu/Destroy()
	if(map_element.CPU == src)
		map_element.CPU = null

	..()

//WASPS - weighted anti-supermatter personal safeguard. Saves you from touching bluespace/supermatter
//Lore: the sphere emits a special energy field that violently reacts to supermatter. When close to organic matter, the field will surround it as well.
//The energy field's reaction triggers a paralyzing explosion
//The explosion will not only
/obj/item/supermatter_shielding
	name = "\improper W.A.S.P.S."
	desc = "A small sphere that saves you from getting annihilated by supermatter by violently exploding. Works when stored inside a backpack or a pocket."
	w_class = W_CLASS_SMALL

//Rewards
/obj/item/weapon/cloakingcloak/hive
	name = "alien cloak"
	desc = "Very light and soft to the tough, it's hard to believe that you would find something so delicate inside the Hive."

