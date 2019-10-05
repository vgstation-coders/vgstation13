//THE HIVE: THE AWAY MISSION

//A chaotic spaceship built by something VERY scary from VERY far away (but now it's VERY close to the station so you gotta go there and kick some alien ass)
//Very rough and spiky on the outside
//Interior is full of corridors with dead ends and many branches. There are also supermatter lakes that don't spread because they're kept in place by advanced alien technology!
//You'll also find the following inside:

//Alien wall: indestructible wall that looks spoopy
//Alien floor: indestructible floor

//Hive pylon: structure that emits very powerful radiation
//Living floor: a special floor that slows down YOU and speeds up the aliens
//Supermatter lake:  instantly kills you if you touch it or walk into it, no matter your armour, race, gender or admin flags. Thankfully the aliens have been so kind that they've built catwalks over some of it

//Alien Denizen: basic alien, fairly robust and has a 15% chance to stun on attack

//Alien Defender: highly mobile enemy. when it comes adjacent to the enemy, it will switch into 'attack mode' and start attacking very fast. When the target moves away, it will switch back into 'movement mode' and start chasing again
//                   Can't attack while in 'movement mode'. 30% chance to stun on attack

//Alien Turret: very slow tank enemy that shoots napalm bombs
//

//Alien Constructor: alien that permanently turns alien floors below it into living floors. They don't wander around and only start moving
//  when they see a target. When their target is attacked by a different alien, they'll remotely build walls behind the victim, blocking off escape

///////////////////////////////////////////****THE MISSION****////////////////////////////////////////////
#define DIFF_HARDCORE  "HARDCORE"
#define DIFF_HARDCORE_SCORE_MULTIPLIER 3
#define DIFF_HARDCORE_DESC "Monster respawns normal. Pylons emit 100% radiation."

#define DIFF_CASUAL   "CASUAL"
#define DIFF_CASUAL_SCORE_MULTIPLIER 1
#define DIFF_CASUAL_DESC "Monster respawns reduced by 66%. Pylons emit 15% radiation."

#define DIFF_BABY     "BABY'S DAY OUT"
#define DIFF_BABY_SCORE_MULTIPLIER 0.5
#define DIFF_BABY_DESC "Monster respawns disabled. Pylons deal temporary oxyloss damage instead of radiation."

/datum/map_element/away_mission/hive
	name = "The Hive"
	file_path = "maps/RandomZLevels/hive.dmm"
	desc = "A hideous space structure full of mindless monsters, death and devastation lurking around every corner. No, this isn't Space Station 13 - this is The Hive."

	var/obj/item/hive/cpu/CPU
	var/obj/structure/hive/communicator/communicator
	var/obj/structure/hive/cloner/replicator

	var/bluespace_deaths = 0
	var/bluespace_alien_kills = 0

	var/list/rewards = list()
	var/start_reward_amount = 0

	var/difficulty = DIFF_HARDCORE

	var/static/reward_types = list(\
	/obj/item/weapon/gun/energy/pulse_rifle,
	/obj/item/weapon/gun/stickybomb,
	/obj/item/weapon/gun/projectile/rocketlauncher/nikita,
	/obj/item/weapon/cloakingcloak/hive,
	/obj/item/weapon/invisible_spray,
	/obj/item/clothing/gloves/powerfist,
	/obj/item/clothing/glasses/thermal/eyepatch
	)

/datum/map_element/away_mission/hive/pre_load()
	..()

	to_chat(usr, "<span class='danger'>Pleaes select the difficulty level for this away mission. The difficulty level will be visible on round-end screen. It will also affect the final score.</span>")
	to_chat(usr, "<span class='sinister'>HARDCORE</span>: [DIFF_HARDCORE_DESC] [DIFF_HARDCORE_SCORE_MULTIPLIER]x score multiplier")
	to_chat(usr, "<span class='sinister'>CASUAL</span>: [DIFF_CASUAL_DESC] [DIFF_CASUAL_SCORE_MULTIPLIER]x score multiplier")
	to_chat(usr, "<span class='sinister'>BABY'S DAY OUT</span>: [DIFF_BABY_DESC] [DIFF_BABY_SCORE_MULTIPLIER]x score multiplier")

	difficulty = alert(usr, "Select the difficulty level for the away mission. You can't change it later!", "Adventure awaits", DIFF_HARDCORE, DIFF_CASUAL, DIFF_BABY)
	to_chat(usr, "<span class='notice'>You've selected the <b>[difficulty]</b> difficulty level!</span>")

/datum/map_element/away_mission/hive/initialize(list/objects)
	..()

	CPU = track_atom(locate(/obj/item/hive/cpu) in objects)
	communicator = track_atom(locate(/obj/structure/hive/communicator) in objects)
	replicator = track_atom(locate(/obj/structure/hive/cloner) in objects)

	for(var/obj/item/I in objects)
		if(is_type_in_list(I, reward_types))
			var/tracked = track_atom(I)

			rewards[tracked] = get_turf(tracked) //Associate the reward with the turf.

	start_reward_amount = rewards.len
	//Rewards may get destroyed, in which case they'll be removed from the rewards list.
	//Rewards list's len will be subtracted from this value to find the amount of destroyed rewards. It will then be added to the amount of found rewards

	if(!CPU)
		message_admins("<span class='warning'>Unable to find the alien CPU in the away mission!</span>")

	if(!communicator)
		message_admins("<span class='warning'>Unable to find the alien communicator in the away mission!</span>")

	if(!replicator)
		message_admins("<span class='warning'>Unable to find the alien replicator in the away mission!</span>")

	if(usr)
		if(alert(usr, "Create a command report containing a briefing?", "Adventure awaits", "Yes", "No") == "Yes")
			command_alert(/datum/command_alert/awaymission/hive)

	switch(difficulty)
		if(DIFF_CASUAL)
			//66% respawn points inactive
			//Pylons 15% effective
			for(var/obj/effect/landmark/hive/monster_spawner/MS in objects)
				if(prob(66))
					MS.inactive = TRUE
			for(var/obj/structure/hive/pylon/P in objects)
				P.radiation_multiplier = 0.15

		if(DIFF_BABY)
			//100% respawn points inactive
			//Pylons emit oxyloss
			for(var/obj/effect/landmark/hive/monster_spawner/MS in objects)
				MS.inactive = TRUE
			for(var/obj/structure/hive/pylon/P in objects)
				P.emit_oxyloss = TRUE
				P.radiation_multiplier = 0.25 //Wouldn't want it to be too deadly


/datum/map_element/away_mission/hive/process_scoreboard()
	var/list/L = list()

	//Difficulty level information
	var/difficulty_desc
	switch(difficulty)
		if(DIFF_HARDCORE)
			difficulty_desc = DIFF_HARDCORE_DESC
		if(DIFF_CASUAL)
			difficulty_desc = DIFF_CASUAL_DESC
		if(DIFF_BABY)
			difficulty_desc = DIFF_BABY_DESC

	L["Difficulty level: <u>[difficulty]</u> - [difficulty_desc]<br>"] = 0

	//Accomplishments
	var/CPU_rescued = FALSE

	if(!CPU)
		L["The Hive CPU has been destroyed!"] = 5000 //Destroying it is fine, too
	else if(istype(get_area(CPU), /area/shuttle/escape))
		L["You have retreived the Hive CPU. Fantastic job!"] = 15000 //Add 15000 points for potentially advancing research hundreds of years into the future
		CPU_rescued = TRUE
	else
		L["You have left the Hive CPU behind."] = 0 //Whatever, we'll send somebody to pick it up

	if(!communicator)
		L["The Hive Communicator has been destroyed!"] = 5000

	if(!replicator)
		L["The Hive Replicator has been destroyed"] = 5000

	if(!bluespace_deaths)
		L["No supermatter lake-related casualties."] = 1000
	else
		L += "[bluespace_deaths] [bluespace_deaths == 1 ? "man was" : "people were"] annihilated in the supermatter lakes."

	var/found_secrets = 0
	for(var/obj/item/I in rewards)
		if(I.loc != rewards[I]) //If the reward has been moved, count it as found. Seeing it is not enough
			found_secrets++
	found_secrets += start_reward_amount - rewards.len //Destroyed rewards count as 'found' too

	if(bluespace_alien_kills)
		L["[bluespace_alien_kills] alien\s [bluespace_alien_kills == 1 ? "was" : "were"] annihilated in the supermatter lakes."] = 25 * bluespace_alien_kills

	L["Secrets found: [found_secrets] / [start_reward_amount]! "] = found_secrets * 200

	if(CPU_rescued && !communicator && !replicator && (found_secrets == start_reward_amount))
		L["<br>100% completion! Outstanding!"] = 50000

	//Apply score multiplier
	var/score_multiplier
	switch(difficulty)
		if(DIFF_HARDCORE)
			score_multiplier = DIFF_HARDCORE_SCORE_MULTIPLIER
		if(DIFF_CASUAL)
			score_multiplier = DIFF_CASUAL_SCORE_MULTIPLIER
		if(DIFF_BABY)
			score_multiplier = DIFF_BABY_SCORE_MULTIPLIER

	for(var/score_category in L)
		L[score_category] *= score_multiplier

	return L

///////////////////////////////////////////****NARRATIONS****/////////////////////////////////////////////
//Briefing

/obj/item/weapon/photo/hive_map/New()
	..()

	img = icon('icons/effects/224x224.dmi', "hive_map")

/datum/command_alert/awaymission/hive
	name = "Hostile Alien Spaceship Detected"
	alert_title = "Hostile Spaceship Detected"
	message = "Summary downloaded and printed out at all communications consoles."

	var/summary_text = {"
	<b>Situation Summary</b><br><br>
	A hostile alien spacecraft, codename "The Hive", was detected in orbit above your station, preparing for an attack. Usually at this point it's too late to do anything, as even nuclear weapons are powerless against it.<br>
	But today, there is hope for you. We have just managed to get a first ever partial scan of the Hive, revealing possible points of entry and the ship's important areas. This information should help you assemble a strike team and destroy the Hive before it destroys you.<br>
	You are to complete the following objectives:<br>
	<ul>
	<li>Destroy the Hive Mind to impair the ship's communication abilities</li>
	<li>Destroy the Hive Replicator that mass-produces alien troops</li>
	<li>Disarm the Hive CPU and bring it to Central Command on the escape shuttle. If that is not possible, destroy it</li>
	</ul>
	<br>
	A gateway drone has been crashed into one of the entrances into the ship. Your station's gateway will be linked to it shortly.<br><br>
	We have also attached an image with the approximate locations of your targets. The entry point is marked with an arrow. Number 1 is the suspected location of the Hive Mind. Number 2 is the suspected location of the control room. Number 3 is the suspected location of the Hive Replicator.<br>
	The scans have shown signs of dangerous levels of background radiation, ambient magnetic fields, a hostile atmosphere and presence of alien life forms. Prepare for the assault thoroughly, as no living man before has ever entered the Hive, and nobody knows what might await you inside.<br>"}

/datum/command_alert/awaymission/hive/announce()
	..()

	for (var/obj/machinery/computer/communications/comm in machines)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Hostile Spaceship Summary'"
			intercept.info = summary_text
			intercept.img = new /obj/item/weapon/photo/hive_map(src)

			comm.messagetitle.Add("[command_name()] Status Summary")
			comm.messagetext.Add(summary_text)

/obj/effect/narration/hive/intro
	msg = "In front of you there is the most bizarre and alien structure that you've ever seen. Its surface constantly shifts and distorts, and the exterior is covered in massive spikes. That's not at all what you'd expect a spaceship to look like."

/obj/effect/narration/hive/entrance
	msg = "The interior is as chaotic as you'd expect. Thin passageways spread out in all directions, constantly intertwining and intersecting with each other. Even the walls around you appear to be moving."
	play_sound = 'sound/ambience/spookymaint2.ogg'

/obj/effect/narration/hive/lake
	msg = {"The first thing you see as you enter this room is the massive supermatter lake on its bottom. It constantly sizzles and sparks as dust specks collide with it. If you're going to walk on these catwalks hanging from the ceiling, you better be careful - a single misstep, and you'll be pulled down into the lake faster than you'd be able to do anything.<br>
	<i>Switch to <b>"walk"</b> intent to move carefully.</i><br>"}

/obj/effect/narration/hive/cloning_hallway
	msg = "You notice that the surface of the floors and walls around you becomes more and more porous, and more... alive. You must be approaching the cloning chamber."

/obj/effect/narration/hive/cloning
	msg = "A large alien machine hangs down from the ceiling, surrounded by thick, purple matter. It looks like a human heart, and it pulsates like one as well. You feel like it's reacting to your presence by beating faster and faster, but that might just be your imagination."
	play_sound = 'sound/effects/heart_beat_loop.ogg'

/obj/effect/narration/hive/control
	msg = "You enter what must've once been a cockpit of a space shuttle. Now it's barely recognizable - most of the floors and the walls here have been replaced with alien materials. A nearby computer seems to recognize you as a friendly lifeform, and greets you to the best of its abilities."
	play_sound = 'sound/effects/static/static4.ogg'

/obj/effect/narration/hive/comms
	msg = "What looks like a massive blob of flesh lies the corner of the room. A glowing substance regularly passes through the tubes under its skin."
	play_sound = 'sound/ambience/shipambience.ogg' //background noise

////////PAPERWORKS///////
/obj/item/weapon/paper/hive/birthday_note
	name = "paper- 'Happy Birthday, Chechen'"
	info = {"You only care about two things in your life - eating cakes and perving at Russian chicks, so we got you an appropriate present. Never change, you fat piece of shit.<br><br>

	<i>Dan</i><br>
	<i>Parok</i><br>
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
	<b>Chassis</b>: Kitchen in meat fridge<br>
	<b>Torso</b>: Aux tool storage (near Dan's """workshop""")<br>
	<b>Left Arm</b>: Inside the sauna<br>
	<b>Right Arm</b>: Atmospherics - Nitrogen chamber<br>
	<b>Left Leg</b>: Maintenance between research and PersonalQuarters<br>
	<b>Right Leg</b>: Biomed (near the bridge), body scanner 2<br>
	<b>Plating</b>: Hallway near the supermatter engine<br>
	<b>Head</b>: Vending machine in the same hallway (in place of the $60 chips)<br>
	<b>CCM</b>: Maintenance next to the theatre<br>
	<b>PCM</b>: Engineering tool storage<br>
	<b>WCM</b>: Under the radio transmitter<br>
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

/obj/item/weapon/paper/hive/shielding
	name = "paper- 'Are you a clumsy ass? Don't forget to grab a SASS'"
	info = {"The supermatter power generator has claimed two engineer lives last week: Margat and Ivan. To prevent any further deaths, we have ordered
	ten Spherical Anti-Supermatter Safeguard units from TianGong-5.<br>
	This ridicilously expensive ball must be carried in your pocket or backpack when working anywhere near the supermatter shard. Then, when you inevitably
	touch the shard, the SASS will protect you from disintegration - once.<br><br>
	<i>Cunningham</i> <b>ID: 2E/2</b>"}

/obj/item/weapon/paper/hive/powerfist
	name = "paper- 'Powerfists forbidden on board HangTianBao 1'"
	info = {"Quanfen gloves, also known as "Powerfists" are now considered class 1 weaponry. Crewmembers have until <b>1-44-122-4</b> to give up their powerfists to classified security personnel. After that date, possession of a powerfist will be considered a major A-level offense, and will be prosecuted accordingly.<br>

	<i>Parok</i> <b>ID: 1E/1</b>"}

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
	flags = 0

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

/obj/effect/hidden_door/hive
	door_typepath = /turf/unsimulated/wall/evil
	floor_typepath = /turf/unsimulated/floor/evil

#define EVIL_FLOOR_CO2 (44.8 * CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION)) //44.8 kPa

/turf/unsimulated/floor/evil
	icon_state = "evilfloor"

	carbon_dioxide = EVIL_FLOOR_CO2
	oxygen = 0
	nitrogen = 0
	temperature = T0C-10 //-10 degrees C

/turf/unsimulated/floor/evil/breathing
	name = "living floor"
	desc = "This surface is constantly twisting and contracting, as if it were alive. It looks like it would take a lot of effort to just walk on it."
	icon_state = "breathingfloor_1"

	var/additional_slowdown = 5

/turf/unsimulated/floor/evil/breathing/New()
	..()

	icon_state = "breathingfloor_[rand(1,6)]"
	additional_slowdown = rand(3,7)

/turf/unsimulated/floor/evil/breathing/adjust_slowdown(mob/living/L, current_slowdown)
	if(istype(L, /mob/living/simple_animal/hostile/hive_alien)) //Hive aliens are sped up
		current_slowdown *= 0.01
	else
		//Everybody else is slowed down
		current_slowdown *= 4
	..()

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

	//Dimmer light
	light_range = 3
	light_power = 1

/turf/unsimulated/wall/supermatter/no_spread/lake/Bumped(atom/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		//Being on walk intent prevents you from instant death

		//Exceptions: you're blind, you're getting thrown, or you're incapacitated (stunned)
		if(!L.incapacitated() && !L.throwing && !L.is_blind() && (L.m_intent == M_INTENT_WALK))
			to_chat(L, "<span class='notice'>You avoid stepping into \the [src].</span>")
			return

	return ..()

/turf/unsimulated/wall/supermatter/no_spread/lake/Consume(atom/A)
	var/datum/map_element/away_mission/hive/hive
	if(istype(map_element, /datum/map_element/away_mission/hive))
		hive = map_element

	if(issilicon(A) || ishuman(A))
		var/mob/living/L = A
		if(L.ckey)
			if(..())
				hive.bluespace_deaths++
			log_game("[key_name(L)] consumed by a supermatter lake [formatJumpTo(src)]")
			return

	else if(istype(A, /mob/living/simple_animal/hostile/hive_alien))
		hive.bluespace_alien_kills++

	return ..()

///////////////////////////////////////////****STRUCTURES****//////////////////////////////////////////////////

/obj/structure/hive
	anchored = TRUE
	density = TRUE

	var/health = 10
	var/gibtype = /obj/effect/gibspawner/robot

/obj/structure/hive/proc/healthcheck()
	if(health <= 0)
		death()

/obj/structure/hive/proc/death()
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
var/list/hive_pylons = list()

/obj/structure/hive/pylon
	name = "hive pylon"
	desc = "An alien machine that releases large amounts of radiation into its surroundings."

	icon_state = "hive_pylon"
	health = 20

	var/radiation_cooldown = 40 SECONDS
	var/last_pulse

	var/emit_oxyloss = FALSE //For babymode

	var/radiation_range = 12
	var/radiation_power = 20

	var/radiation_multiplier = 1.0

	var/active = TRUE

/obj/structure/hive/pylon/New()
	..()

	hive_pylons.Add(src)
	processing_objects.Add(src)

/obj/structure/hive/pylon/Destroy()
	processing_objects.Remove(src)
	hive_pylons.Remove(src)

	..()

/obj/structure/hive/pylon/death()
	//One last pulse before dying
	if(active)
		emit_radiation(radiation_range, radiation_power)

	..()

/obj/structure/hive/pylon/proc/turn_offline()
	health = 1
	icon_state = "hive_pylon_inactive"
	processing_objects.Remove(src)
	desc = initial(desc) + " It is inactive."
	active = FALSE

/obj/structure/hive/pylon/process()
	if((last_pulse + radiation_cooldown < world.time) && prob(25)) //To make the radiation pulses irregular, it has a 25% chance of pulsing every process
		last_pulse = world.time

		emit_radiation(radiation_range, radiation_power)
		radiation_range = rand(10,15)
		radiation_power = rand(6,20) * radiation_multiplier

/obj/structure/hive/pylon/proc/emit_radiation(rad_range, rad_power )
	// Radiation
	for(var/mob/living/carbon/M in range(src, rad_range))
		//Babymode deals temporary oxygen damage
		if(emit_oxyloss)
			if(prob(10))
				to_chat(M, "<span class='warning'>You feel [pick("mildly", "a bit", "somewhat")] [pick("irritated", "inconvenienced", "bothered")].</span>")
			M.adjustOxyLoss(radiation_power * radiation_multiplier)
			continue

		var/mob/living/carbon/human/H = M
		var/msg
		if(istype(H) && H.species && H.species.flags & RAD_ABSORB)
			msg = pick(\
			"You feel mildly irradiated.",\
			"You receive a small dose of radiation.",\
			"You feel the ambient radiation affecting you.")
		else
			msg = pick(\
			"You hear a slow clicking.",\
			"Your head begins to hurt.",\
			"You feel tired.",\
			"You feel mildly nauseated.",
			"You feel radiation burns appearing on your body.")

		to_chat(M, "<span class='warning'>[msg]</span>")
		M.apply_radiation(rad_power, RAD_EXTERNAL)

//Cloner
/obj/structure/hive/cloner
	name = "hive replicator"
	desc = "This seemingly organic structure resembling a human heart hangs down from the ceiling, beating at a steady rate."

	icon_state = "hive_heart"
	health = 500

	var/create_cooldown = 90 SECONDS
	var/last_create

/obj/structure/hive/cloner/New()
	..()

	processing_objects.Add(src)

/obj/structure/hive/cloner/Destroy()
	processing_objects.Remove(src)

	for(var/obj/effect/narration/hive/cloning/C in range(7, src)) //The narration effect mentions the replicator when you enter the room. Once you destroy the replicator, silence the narration
		qdel(C)

	to_chat(get_area(src), 'sound/effects/blobkill.ogg')

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
		if(MS.inactive)
			continue
		if(prob(30)) //30% chance to skip a monster spawner
			continue

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
		/mob/living/simple_animal/hostile/hive_alien/constructor,\
		30; /mob/living/simple_animal/hostile/hive_alien/defender,\
		10; /mob/living/simple_animal/hostile/hive_alien/turret) //Turrets and defenders are rare

		spawn(rand(2 SECONDS,15 SECONDS))
			var/mob/living/simple_animal/hostile/hive_alien/HA = new spawned_type(T)
			HA.visible_message("<span class='danger'>\The [HA] crawls down from an opening in the ceiling!</span>")

			var/played_sound = pick(\
			'sound/effects/wind/wind_2_1.ogg',\
			'sound/effects/wind/wind_2_2.ogg',\
			'sound/effects/wind/wind_3_1.ogg',\
			)
			playsound(HA, played_sound, 60, 1)

/obj/effect/landmark/hive/monster_spawner
	name = "alien spawner"
	desc = "Periodically spawns monsters if the hive replicator isn't destroyed."
	icon_state = "x"

	var/inactive = FALSE

//Communication unit
/obj/structure/hive/communicator
	name = "hive mind"
	desc = "This massive blob of flesh constantly pulsates, and a glowing fluid passes through the tubes under its thin skin. The organic growths on top of it occasionally twist and turn, as if surveying their surroundings."
	icon_state = "hive_comms"
	health = 150
	gibtype = /obj/effect/gibspawner/human

/obj/structure/hive/communicator/death()
	..()

	for(var/obj/structure/hive/pylon/P in hive_pylons)
		P.turn_offline()

	for(var/obj/effect/narration/hive/comms/C in range(7, src)) //The narration effect mentions the hive mind lying in the corner when you enter the room. Once you destroy the communicator, silence the narration
		C.msg = null
		//Don't delete it, because it also activates a soundtrack

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

/obj/structure/hive/husk/death()
	visible_message("<span class='notice'>\The [src] crumbles into dust!</span>")

	return ..()

/obj/structure/hive/husk/martian //never
	icon = 'icons/mob/martian.dmi'
	icon_state = "martian"

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

/obj/effect/trap/frog_trap/hive/constructor //same but constructors
	frog_type = /mob/living/simple_animal/hostile/hive_alien/constructor

/obj/effect/trap/frog_trap/hive/defender //same but defenders. VERY dangerous
	frog_type = /mob/living/simple_animal/hostile/hive_alien/defender

///////////////////////////////////////////****ITEMS****//////////////////////////////////////////////////

/obj/item/hive/cpu
	name = "alien processing unit"
	desc = "This massive piece of machinery appears to play a large part in the Hive's function. If you retreived it from here, our research could advance a few hundred years into the future."

	icon_state = "hive_cpu"

	w_class = W_CLASS_LARGE
	throw_range = 0
	anchored = TRUE //Forces people to carry it by hand, no pulling!
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND


//SASS - spherical anti-supermatter safeguard. Saves you from touching bluespace/supermatter
//SASS sphere - spherical anti-supermatter safeguard sphere
/obj/item/supermatter_shielding
	name = "\improper S.A.S.S. sphere"
	desc = "A small sphere that, in theory, should prevent you from getting annihilated by supermatter. It looks like a brown marble floating in a strange liquid inside a glass orb."
	w_class = W_CLASS_SMALL

	icon_state = "supermatter_shield"

	var/stunforce = 10
	var/infinite = 0

/obj/item/supermatter_shielding/supermatter_act(atom/source)
	var/turf/T = get_turf(src)

	if(T)
		explosion(T, -1, -1, 1)

	if(istype(loc, /mob/living))
		var/mob/living/L = loc
		L.Stun(stunforce)
		L.Knockdown(stunforce)
		L.apply_effect(STUTTER, stunforce)

		if(L)
			to_chat(L, "<span class='userdanger'>As you approach \the [source], your [src] explodes in a burst of energy, knocking you back. Phew, that was close.</span>")

	if(!infinite)
		.=..()

//Rewards
/obj/item/weapon/cloakingcloak/hive
	name = "alien cloak"
	desc = "Soft to the tough."

