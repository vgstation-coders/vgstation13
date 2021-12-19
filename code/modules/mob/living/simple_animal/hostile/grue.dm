/mob/living/simple_animal/hostile/grue
	name = "grue"
	desc = "A dangerous thing that lives in the dark."
	icon = 'icons/mob/grue.dmi'
	icon_state = "grue_living"
	icon_living = "grue_living"
	icon_dead = "grue_dead"

	maxHealth = 200											 	//max health
	health = 200
//	var/mdl_base=10 //base lower limit for melee damage (used in darkness strength calculations)
//	var/mdu_base=15 //base upper limit for melee damage (used in darkness strength calculations)
	melee_damage_lower = 20
	melee_damage_upper = 30
	melee_damage_type = BRUTE
	response_help  = "touches"
	response_disarm = "pushes"
	response_harm   = "punches"
//	attacktext = pick("gnashes","slashes")
	attacktext = "gnashes"
	attack_sound = 'sound/weapons/cbar_hitbod1.ogg'
	speed = 1
	can_butcher = FALSE
//	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/grue
	held_items = list()
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_STRONG
	force_airlock_time=100 //so that grues cant easily rush through a light area and quickly force open a door to escape back into the dark

	a_intent=I_HURT //Initialize these
	m_intent=I_HURT

	//eyesight related stuff
	see_in_dark = 8






	//VARS
	var/isgrue=1
	var/shadowpower = 0											 //shadow power absorbed
	var/maxshadowpower = 1000									   //max shadowpower
	var/moultcost = 0 											//shadow power needed to moult into next stage (irrelevant for adults)
	var/ismoulting = 0, //currently moulting (1=is a pupa)
	var/moulttime = 60 //time required to moult to a new form
	var/moulttimer = 100 //moulting timer
	var/current_brightness = 0									   //light level of current tile, range from 0 to 10

	var/bright_limit_gain = 1											//maximum brightness on tile for health and power regen
	var/bright_limit_drain = 3											//maximum brightness on tile to not drain health and power
	var/regenbonus=1													//bonus to health regen based on sentient beings eaten


	var/pg_mult = 3										 //multiplier for power gained per tick when in dark tile
	var/pd_mult = 1									  //multiplier for shadow power drained per tick on bright tile (0=disabled)
	var/hg_mult = 2										//multiplier for health gained per tick when on dark tile
	var/hd_mult = 3									 //multiplier for health drained per tick on bright tile
	var/show_desc = TRUE										   //For the ability menu

	var/lifestage=3												 //1=baby grue, 2=grueling, 3=(mature) grue
	var/eatencount=0												//number of sentient carbons eaten, makes the grue more powerful
	var/eatencharge=0												//power charged by eating sentient carbons, increments with eatencount but is spent on upgrades
	var/dark_dim_light=0 //darkness level currently the grue is currently exposed to, 0=nice and dark, 1=passably dim, 2=too bright
	var/busy=0 //busy laying an egg

/mob/living/simple_animal/hostile/grue/regular_hud_updates()
	..()
	if(client && hud_used)
		hud_used.grue_hud()

//health indicator
		if (health >= maxHealth)
			healths.icon_state = "health0"
		else if (health >= 4*maxHealth/5)
			healths.icon_state = "health1"
		else if (health >= 3*maxHealth/5)
			healths.icon_state = "health2"
		else if (health >= 2*maxHealth/5)
			healths.icon_state = "health3"
		else if (health >= 1*maxHealth/5)
			healths.icon_state = "health4"
		else if (health > 0)
			healths.icon_state = "health5"
		else
			healths.icon_state = "health6"
//darkness level indicator
		if (dark_dim_light==0)
			healths2.icon_state= "lightlevel_dark"
			healths2.name="Nice and dark."
		else if (dark_dim_light==1)
			healths2.icon_state= "lightlevel_dim"
			healths2.name="Adequately dim."
		else if (dark_dim_light==2)
			healths2.icon_state= "lightlevel_bright"
			healths2.name="Painfully bright."




/mob/living/simple_animal/hostile/grue/Life()
	..()

	//process shadow power and health according to current tile brightness level
	if (stat!=DEAD)
		if(isturf(loc))
			var/turf/T = loc
			current_brightness=10*T.get_lumcount()
		else												//else, there's considered to be no light
			current_brightness=0;
		visible_message("<span class='warning'>\The [src] is in brightness level [current_brightness] with [health] health and [shadowpower] shadowpower.</span>") //debug
		if(current_brightness<=bright_limit_gain&&!ismoulting) //moulting temporarily stops healing via darkness
			dark_dim_light=0
			apply_damage(-1*(lifestage**(1/3))*regenbonus*hg_mult*(bright_limit_gain-current_brightness),BURN) //scale light healing by lifestage**(1/3) boost juveniles and adults heal rates a bit
		else if(current_brightness>bright_limit_drain) 														//lose health in light
			dark_dim_light=2

			to_chat(src, "<span class='warning'>The bright light scalds you!</span>")
			playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
			apply_damage((lifestage**(1/3))*hd_mult*(current_brightness-bright_limit_drain),BURN)								//scale light damage by lifestage**(1/3) to avoid juveniles and adults from becoming too tanky to light
		else
			dark_dim_light=1
		if(current_brightness<=bright_limit_gain&&!ismoulting)
			shadowpower = min(maxshadowpower,shadowpower+pg_mult*(bright_limit_gain-current_brightness))	   //gain power in dark
		else if(current_brightness>bright_limit_drain)
			shadowpower = max(0,shadowpower-pd_mult*(current_brightness-bright_limit_drain))				  //drain power in light

	if(ismoulting)
		moulttimer--
		if(moulttimer<=0)
			complete_moult()



	regular_hud_updates()



/mob/living/simple_animal/hostile/grue/Stat()
	..()
	if(statpanel("Status"))
//		stat(null, "Intent: [a_intent]")
//		stat(null, "Move Mode: [m_intent]")
		stat(null, "Shadow Power: [shadowpower]/[maxshadowpower]")
		if (lifestage>=3)
			stat(null,"Reproductive Energy: [eatencharge]")
			stat(null, "Sentient Life Forms Eaten: [eatencount]")










//todo:

//remove shadowpower when adult?
//change burning sound for both hatched and egg
//animations
//sprite additions while powering up via death essence

//chg+add sound effects for egglaying, evolving, etc
//remove size descriptor
//darkpower indicator?
//eatencount indicator?
//generalize power, powers costs, costs, power menu
//egg spills open/hatches text?
//chat messages for moulting and such

//take longer to smash open reinforced tables and stuff
//tweak values (moult cost, moult time, health stuff, shadowpower stuff)
//add antag role code ROLE_GRUE
//flesh out everything in setup.dm ala borers (but antag)
//spawns only in dark/maintenance?



//message of egglaying etc only visible to others, not self?
//basic instructive messages about being a grue, and also the life stages

//ability to smash stuff away like flares (kick code?/harm intent?) kick_act in code/game/objects/items.dm
//greyscale filter or color effects or something?
//infrared/night-vision

//dynamic rulesets?



//speaking/not/speaking/only being able to speak to other grues

//unconscious while moulting/reduce view while moulting
//moulting progress bar, etc warning about vulnerability/immobility
//blind messages while moulting

//change sound effects
//jumpscare and other sound effects



//UI:

//render abilities invisible with life stage?
//special names only visible for grues (and grue language)


//rearrange code block
//remove comments

//[TEST]check for sentient/had mind flag to give power after eating
//[TEST]message to target when eaten "You have been eaten by a grue."
//[TEST] egg laying
//[TEST] melee abilities and strength change with life stage
//[TEST] egg recruit ala borer

//[DONE]egg hatch sprite
//[DONE]health gain scaling with eatencount
//[DONE]avoid being able to hit self?
//[DONE] smash walls and such with increased power?
//[DONE] egg sensitivity to light/smashing
//[DONE] relevant upgrades from absorbing power
//[DONE] dont have grueling/gruespawn names visible (just "grue")?
//[DONE]set harm intent/clean up status panel
//[DONE] rename death essence?
//[DONE]egg killed by light sprite
//[DONE] generalize door forcing code to add timer
//[DONE] change to timer for pulling open door
//[DONE]eating sentients by gibbing their corpse and absorbing power
//[DONE]light damage via damage proc instead of directly?
//[DONE]fix attack verbs on smashing stuff/self
//[DONE]pull open doors in mature form ("You start forcing the airlock open.")
//[DONE] lay eggs
//[DONE]remove nullifier code
//[DONE]evolve logic?
//[DONE]cant move while moulting
//[DONE]add moult state stuff and sprite changes,
//[DONE]chrysalis sprite
//[DONE]avoid moulting while in pipe (check for being out in the open)
//[DONE]can't moult message
//[DONE]get ventcrawl to work
//[DONE]revoke ventcrawl on higher life stages
//[OBS]dont anchor egg,
//[OBS] grue crumbles to ash?
//[OBS] fix or remove hiding code (can't go under tables like a mouse)
//[OBS] resistant to other types of damage, or
//[OBS]add increased health/shadowpower gain/drain with lifestage as well
//[OBS]health-scaling light damage calculation?
//[OBS]egg/chrysalis with natural armor? harmed by light or can only hatch in the dark?
//[OBS]need to breathe or no?
//[OBS]ability to destroy or eat objects? and it goes into the stomach,desk lamps etc?
//[OBS]multiple attack verbs/pick?
//[OBS] toggle light verb (does this work on light switches?)
//[OBS] or should not be able to push buttons
//[OBS]damaged by fire?
//[OBS]faction grues to avoid them killing each other etc?
//[OBS]grue crumbles to ash?
//[OBS]speed up death by light is proc necessary?
//[OBS]pulling/holding?
//[OBS] cant or can be pulled while moulting

//[NEXT VERSION]basic AI to avoid light and smash things and moult for npc grues
//[NEXT VERSION]sprites for dead pupae (need blood color)?
//[NEXT VERSION]add body part targeting etc for more focused attacks, and relevant text
//[NEXT VERSION]ability UI+mirrored with panel like pulsedemon
//[NEXT VERSION]more detailed messages about being a grue, and also the life stages, or maybe a menu
//[NEXT VERSION]ui button to eat someone
//[NEXT VERSION]eggs layable indicator
//[NEXT VERSION] grue goo, blood, (color of) gibs, moulting goo, egg casing, meat, etc. (including effects)
//[NEXT VERSION]add harm intents and such?

//[NEED FEEDBACK]dark field?
//[NEED FEEDBACK]consume darkpower to block light?
//[NEED FEEDBACK]smash machiney monitors and such?
//[NEED FEEDBACK]weaker in light/stronger in dark?
//[NEED FEEDBACK]invis in full dark?
//[NEED FEEDBACK]able to push other mobs aside?
//[NEED FEEDBACK]ability to pick up grue eggs. leaving behind casing/skin on the floor (or not)
//[NEED FEEDBACK]turn off lamps etc?
//[NEED FEEDBACK]can activate certain things like morgue tray and push light buttons

/mob/living/simple_animal/hostile/grue/gruespawn
	name = "grue larva"
	desc = "A scurrying thing that lives in the dark. It is still a larva."
	icon_state = "gruespawn_living"
	icon_living = "gruespawn_living"
	icon_dead = "gruespawn_dead"
	melee_damage_lower = 1
	melee_damage_upper = 5
	attacktext = "bites"
	maxHealth=50
	moultcost=100
	health = 50
	lifestage=1
	environment_smash_flags = 0

/mob/living/simple_animal/hostile/grue/grueling
	name = "grue"
	desc = "A creeping thing that lives in the dark. It is still a juvenile."
	icon_state = "grueling_living"
	icon_living = "grueling_living"
	icon_dead = "grueling_dead"
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "chomps"
	maxHealth=100
	moultcost=500
	health = 100
	lifestage=2
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK


mob/living/grue_egg
	name = "grue egg"
	desc = "A large egg laid by a grue"
	icon = 'icons/mob/grue.dmi'
	icon_state = "egg_living"
	icon_living = "egg_living"
	icon_dead= "egg dead"
	maxHealth=25
	health=25
	var/bright_limit_gain = 1											//maximum brightness on tile for health regen
	var/bright_limit_drain = 3											//maximum brightness on tile to not drain health
	var/hg_mult = 2										//multiplier for health gained per tick when on dark tile
	var/hd_mult = 3									 //multiplier for health drained per tick on bright tile

/mob/living/grue_egg/Life()
	..()
	//process health according to current tile brightness level (as with hatched grues)
	if (stat!=DEAD)
		if(isturf(loc))
			var/turf/T = loc
			current_brightness=10*T.get_lumcount()
		else												//else, there's considered to be no light
			current_brightness=0;
		if(current_brightness<=bright_limit_gain)
			apply_damage(-1*hg_mult*(bright_limit_gain-current_brightness),BURN) //scale light healing by lifestage**(1/3) boost juveniles and adults heal rates a bit
		else if(current_brightness>bright_limit_drain) 														//lose health in light
			playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
			apply_damage(hd_mult*(current_brightness-bright_limit_drain),BURN)								//scale light damage by lifestage**(1/3) to avoid juveniles and adults from becoming too tanky to light

//Moulting into more mature forms.
/mob/living/simple_animal/hostile/grue/verb/moult()
	set name = "Moult"
	set desc = "Moult into a new form." //hide if an adult?
	set category = "Grue"
	if (lifestage<3)
		if (shadowpower<moultcost)
			to_chat(src, "<span class='notice'>You need to bask in shadow more first.</span>")
			return
		else if (!isturf(loc))
			to_chat(src, "<span class='notice'>You need more room to moult.</span>")
			return
		else if (stat==UNCONSCIOUS)
			to_chat(src, "<span class='notice'>You must be awake to moult.</span>")
			return
		else if (busy)
			to_chat(src, "<span class='notice'>You are already doing something.</span>")
			return
		else
			start_moult()

	else
		to_chat(src, "<span class='notice'>You are already fully mature.</span>")

/mob/living/simple_animal/hostile/grue/proc/start_moult()
	if(stat==CONSCIOUS&&shadowpower>=moultcost&&!ismoulting&&lifestage<3)
		shadowpower-=moultcost
		lifestage++
		to_chat(src, "<span class='notice'>You begin moulting.</span>")
		stat=UNCONSCIOUS //go unconscious while moulting
		ismoulting=1
		moulttimer=moulttime//reset moulting timer
		var/tempHealth=health/maxHealth //to scale health level
		if (lifestage==2)
			desc = "A small grue chrysalis."
			name = "grue chrysalis"
			icon_state = "moult1"
			icon_living = "moult1"
			icon_dead = "moult1"
			maxHealth=25 //vulnerable while moulting
		else if(lifestage==3)
			desc = "A grue chrysalis."
			name = "grue chrysalis"
			icon_state = "moult2"
			icon_living = "moult2"
			icon_dead = "moult2"
			maxHealth=50 //vulnerable while moulting
		health=maxHealth*tempHealth //keep same health percentage
	else
		return

/mob/living/simple_animal/hostile/grue/proc/complete_moult()
	if(ismoulting&&stat!=DEAD)
		var/tempHealth=health/maxHealth //to scale health level
		if (lifestage==2)
			desc = "A creeping thing that lives in the dark. It is still a juvenile."
			name = "grue"
			icon_state = "grueling_living"
			icon_living = "grueling_living"
			icon_dead = "grueling_dead"
			maxHealth=100
			moultcost=500
			melee_damage_lower = 10
			melee_damage_upper = 15
			environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK
		else if(lifestage==3)
			desc = "A dangerous thing that lives in the dark."
			name = "grue"
			icon_state = "grue_living"
			icon_living = "grue_living"
			icon_dead = "grue_dead"
			maxHealth=200
			moultcost=0 //not needed for adults
			melee_damage_lower = 20
			melee_damage_upper = 30
			environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_STRONG
		health=maxHealth*tempHealth //keep same health percent
		stat=CONSCIOUS //wake up
		ismoulting=0 //is no longer moulting
	else
		return


/mob/living/simple_animal/hostile/grue/death(gibbed)
	playsound(src, 'sound/misc/grue_screech.ogg', 50, 1)
	if(ismoulting)
		desc="[desc] This one seems dead and lifeless."
	..()

/mob/living/simple_animal/hostile/grue/attack_animal(mob/living/simple_animal/M)
	if(M==src) //prevent the grue from attacking itself
		return
	else
		if(prob(20)&&lifestage>1)
			playsound(src, 'sound/misc/grue_growl.ogg', 50, 1) //occasionally growl while attacking
		M.unarmed_attack_mob(src)


//Reproduction via egglaying.
/mob/living/simple_animal/hostile/grue/verb/reproduce()
	set name = "Reproduce"
	set desc = "Spawn offspring in the form of an egg."
	set category = "Grue"
	if (lifestage==3) //must be adult
		if (eatencharge<=0)
			to_chat(src, "<span class='notice'>You need to feed more first.</span>")
			return
		else if (!isturf(loc))
			to_chat(src, "<span class='notice'>You need more room to reproduce.</span>")
			return
		else if (stat==UNCONSCIOUS)
			to_chat(src, "<span class='notice'>You must be awake to reproduce.</span>")
			return
		else if (busy)
			to_chat(src, "<span class='notice'>You are already doing something.</span>")
			return
		else
			handle_reproduce()

	else
		to_chat(src, "<span class='notice'>You haven't grown enough to reproduce yet.</span>")

/mob/living/simple_animal/hostile/grue/proc/handle_reproduce()

	if(eatencharge>=1)
		busy=1
		to_chat(src, "<span class='notice'>You start to push out an egg...</span>")
		visible_message("<span class='warning'>\The [src] tightens up...</span>")
		var/turf/T = get_turf(src)
		if(do_after(src, T, 5 SECONDS))
			to_chat(src, "<span class='notice'>You lay an egg.</span>")
			visible_message("<span class='warning'>\The [src] pushes out an egg!</span>")
			eatencharge--

//			playsound(T, 'sound/effects/splat.ogg', 50, 1)


			var/mob/living/grue_egg/E = new (T)
			busy=0

	else
		to_chat(src, "You need to feed more first.")
		return






//Eating sentient beings.
/mob/living/simple_animal/hostile/grue/verb/eat_sentient()
	set name = "Eat"
	set desc = "Eat someone."
	set category = "Grue"
	if (lifestage==3) //must be adult
		if (!isturf(loc))
			to_chat(src, "<span class='notice'>You need more room to eat.</span>")
			return
		else if (stat==UNCONSCIOUS)
			to_chat(src, "<span class='notice'>You must be awake to eat.</span>")
			return
		else if (busy)
			to_chat(src, "<span class='notice'>You are already doing something.</span>")
			return
		else

			var/toeat=start_feed()
			if(toeat)
				handle_feed(toeat)
	else
		to_chat(src, "<span class='notice'>You haven't grown enough to do that yet.</span>")


/mob/living/simple_animal/hostile/grue/proc/start_feed()
	var/atom/feed_target
	var/list/feed_targets = list()
	for(var/mob/living/carbon/U in range(1))
		if(Adjacent(U))
			feed_targets |= U
	if(!feed_targets || !feed_targets.len)
		to_chat(src, "<span class='notice'>There is nothing suitable to eat.</span>")
		return
	if(feed_targets.len == 1)
		feed_target = feed_targets[1]
	else
		feed_target = input("Eat", "Pick someone to eat.") as null|anything in feed_targets
	if(feed_target)
//		feed_target.gib()
		return feed_target

/mob/living/simple_animal/hostile/grue/proc/handle_feed(var/mob/living/clicked_on)
	to_chat(src, "<span class='danger'>You open your mouth wide, preparing to eat [clicked_on]!</span>")
	if(do_mob(src , clicked_on, 10 SECONDS, 100, 0))
		to_chat(src, "<span class='danger'>You have eaten [clicked_on]!</span>")
		to_chat(clicked_on, "<span class='danger'>You have been eaten by a grue.</span>")
		clicked_on.gib()

		playsound(src, 'sound/misc/grue_growl.ogg', 50, 1)

		//Upgrade the grue's stats as it feeds
		if(clicked_on.mind) //must have a mind to power up the grue
			eatencount++
			eatencharge++
			speed=max(0.2,speed*0.8) //speed cap of 0.2
			var/tempHealth=health/maxHealth
			maxHealth=round(min(1000,maxHealth+50)) //50 more health with a cap of 1000
			health=tempHealth*maxHealth

			melee_damage_lower = melee_damage_lower+7
			melee_damage_upper = melee_damage_upper+7

			regenbonus=min(100,regenbonus+1) //increased health regen in darkness

			force_airlock_time=max(0,force_airlock_time-40)
			src.set_light(8,-1*eatencount) //gains shadow aura opon eating someone
			switch(eatencount)
				if(3)
					to_chat(src, "<span class='notice'>You feel power coursing through you! You feel strong enough to smash down most walls... but still hungry</span>")
					environment_smash_flags = environment_smash_flags | SMASH_WALLS
				if(4)
					to_chat(src, "<span class='notice'>You feel power coursing through you! You feel strong enough to smash down even reinforced walls... but still hungry</span>")
					environment_smash_flags = environment_smash_flags | SMASH_RWALLS
				else
					to_chat(src, "<span class='notice'>You feel power coursing through you! You feel stronger... but still hungry...</span>")


		else
			to_chat(src, "<span class='notice'>That creature didn't quite satisfy your hunger.</span>")

	else
		return



//Procs for grabbing players.
/mob/living/simple_animal/hostile/grue/proc/request_player()
	var/list/candidates=list()
	for(var/mob/dead/observer/G in get_active_candidates(ROLE_GRUE, poll="Would you like to become a grue?"))
		if(!G.client)
			//testing("Client of [G] inexistent")
			continue

		//#warn Uncomment me.
		/*if(G.client.holder)
			//testing("Client of [G] is admin.")
			continue*/

		if(isantagbanned(G))
			//testing("[G] is jobbanned.")
			continue

		candidates += G

	if(!candidates.len)
		//message_admins("Unable to find a mind for [src.name]")
		return 0

	shuffle(candidates)
	for(var/mob/i in candidates)
		if(!i || !i.client)
			continue //Dont bother removing them from the list since we only grab one grue at a time
		return i

	return 0




//Ventcrawling, only for gruespawn
/mob/living/simple_animal/hostile/grue/gruespawn/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

