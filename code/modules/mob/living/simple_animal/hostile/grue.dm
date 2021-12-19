/mob/living/simple_animal/hostile/grue

	icon = 'icons/mob/grue.dmi'
	speed = 1
	can_butcher = FALSE
//	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/grue

	a_intent=I_HURT //Initialize these
	m_intent=I_HURT

	universal_speak = 0
	universal_understand = 0

	response_help  = "touches"
	response_disarm = "pushes"
	response_harm   = "punches"

	faction = "grue" //Keep grues and grue eggs friendly to each other.
	force_airlock_time=100 									//so that grues cant easily rush through a light area and quickly force open a door to escape back into the dark

	//eyesight related stuff
	see_in_dark = 8

	//VARS
	var/isgrue=1
	var/shadowpower = 0											 //shadow power absorbed
	var/maxshadowpower = 1000									   //max shadowpower
	var/moultcost = 0 											//shadow power needed to moult into next stage (irrelevant for adults)
	var/ismoulting = 0, //currently moulting (1=is a chrysalis)
	var/moulttime = 60 //time required to moult to a new form
	var/moulttimer = 100 //moulting timer
	var/current_brightness = 0									   //light level of current tile, range from 0 to 10

	var/bright_limit_gain = 1											//maximum brightness on tile for health and power regen
	var/bright_limit_drain = 3											//maximum brightness on tile to not drain health and power
	var/regenbonus=1													//bonus to health regen based on sentient beings eaten
	var/burnmalus=1														//malus to life drain based on life stage to avoid grues becoming too tanky to light as they mature

	var/pg_mult = 3										 //multiplier for power gained per tick when in dark tile
	var/pd_mult = 0									  //multiplier for shadow power drained per tick on bright tile (0=disabled)
	var/hg_mult = 1										//multiplier for health gained per tick when on dark tile
	var/hd_mult = 3									 //multiplier for health drained per tick on bright tile
//	var/show_desc = TRUE										   //For the ability menu

	var/lifestage=3												 //1=baby grue, 2=grueling, 3=(mature) grue
	var/eatencount=0												//number of sentient carbons eaten, makes the grue more powerful
	var/eatencharge=0												//power charged by eating sentient carbons, increments with eatencount but is spent on upgrades
	var/dark_dim_light=0 //darkness level currently the grue is currently exposed to, 0=nice and dark, 1=passably dim, 2=too bright
	var/busy=0 //busy laying an egg

	//keeping this here for later color matrix testing
	var/a_blend_add_test=0
	var/a_matrix_testing_override = TRUE
	var/a_11 = 1
	var/a_12 = 0
	var/a_13 = 0
	var/a_14 = 0
	var/a_21 = 0
	var/a_22 = 1
	var/a_23 = 0
	var/a_24 = 0
	var/a_31 = 0
	var/a_32 = 0
	var/a_33 = 1
	var/a_34 = 0
	var/a_41 = 0
	var/a_42 = 0
	var/a_43 = 0
	var/a_44 = 1
	var/a_51 = 0
	var/a_52 = 0
	var/a_53 = 0
	var/a_54 = 0

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
			healths2.name="nice and dark"
		else if (dark_dim_light==1)
			healths2.icon_state= "lightlevel_dim"
			healths2.name="adequately dim"
		else if (dark_dim_light==2)
			healths2.icon_state= "lightlevel_bright"
			healths2.name="painfully bright"

/mob/living/simple_animal/hostile/grue/Life()
	..()

	//process shadow power and health according to current tile brightness level
	if (stat!=DEAD)
		if(isturf(loc))
			var/turf/T = loc
			current_brightness=10*T.get_lumcount()
		else												//else, there's considered to be no light
			current_brightness=0
//		visible_message("<span class='warning'>\The [src] is in brightness level [current_brightness] with [health] health and [shadowpower] shadowpower.</span>") //debug
		if(current_brightness<=bright_limit_gain&&!ismoulting) //moulting temporarily stops healing via darkness
			dark_dim_light=0
			apply_damage(-1*burnmalus*regenbonus*hg_mult*(bright_limit_gain-current_brightness),BURN) //boost juveniles and adults heal rates a bit also using burnmalus
		else if(current_brightness>bright_limit_drain) 														//lose health in light
			dark_dim_light=2

			to_chat(src, "<span class='warning'>The bright light scalds you!</span>")
			playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
			apply_damage(burnmalus*hd_mult*(current_brightness-bright_limit_drain),BURN)								//scale light damage by lifestage**(1/3) to avoid juveniles and adults from becoming too tanky to light
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
	standard_damage_overlay_updates()

/mob/living/simple_animal/hostile/grue/New()
	..()
	add_language(LANGUAGE_GRUE)
	default_language = all_languages[LANGUAGE_GRUE]
	init_language = default_language
//	if(thislifestage)
//		lifestage=thislifestage
//	else
//		lifestage=3 //default to adult
	lifestage_updates() //update the grue's sprite and stats according to the current lifestage

/mob/living/simple_animal/hostile/grue/proc/lifestage_updates() //Initialize or update lifestage-dependent stats
	var/tempHealth=health/maxHealth
	if(lifestage==1)
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
		burnmalus=1
		environment_smash_flags = 0
		attack_sound = 'sound/weapons/bite.ogg'
		size = SIZE_SMALL
		pass_flags = PASSTABLE
	else if (lifestage==2)
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
		burnmalus=2**(1/3)
		environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK
		attack_sound = 'sound/weapons/cbar_hitbod1.ogg'
		size = SIZE_NORMAL
		pass_flags = 0
	else if (lifestage>=3)
		name = "grue"
		desc = "A dangerous thing that lives in the dark."
		icon_state = "grue_living"
		icon_living = "grue_living"
		icon_dead = "grue_dead"
		attacktext = "gnashes"
		maxHealth = 200
		moultcost=0 //not needed for adults
		melee_damage_lower = 20
		melee_damage_upper = 30
		melee_damage_type = BRUTE
		held_items = list()
		burnmalus=3**(1/3)
		environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_STRONG
		attack_sound = 'sound/weapons/cbar_hitbod1.ogg'
		size = SIZE_BIG
		pass_flags = 0
	health=tempHealth*maxHealth


//Grue vision
/mob/living/simple_animal/hostile/grue/update_perception()

	if(client)
		if(client.darkness_planemaster)
			client.darkness_planemaster.blend_mode = BLEND_ADD
			client.darkness_planemaster.alpha = a_blend_add_test
		client.color = list(
					1,0.25,0.25,0.25,
					0,0,0,0,
	 				0,0,0,0,
		 			0,0,0,1,
		 			0,0,0,0)

		if(a_matrix_testing_override)
			client.color = list(a_11,a_12,a_13,a_14,
								a_21,a_22,a_23,a_24,
		 						a_31,a_32,a_33,a_34,
			 					a_41,a_42,a_43,a_44,
			 					a_51,a_52,a_53,a_54)



/mob/living/simple_animal/hostile/grue/Stat()
	..()
	if(statpanel("Status"))
//		stat(null, "Intent: [a_intent]")
//		stat(null, "Move Mode: [m_intent]")
		if(lifestage<3) //not needed for adults
			stat(null, "Shadow power: [shadowpower]/[maxshadowpower]")
		if (lifestage>=3)
			stat(null,"Reproductive energy: [eatencharge]")
			stat(null, "Sentient life forms eaten: [eatencount]")










//todo:


//chg+add sound effects for egglaying, evolving, attacking, eating, light scalding (for both hatched and egg), etc

//modify gruevision colors/bloom(no need alpha blend thing?, maybe less red?)
//remove color testing code


//add sound to general table smash
//ability to smash stuff away like flares (kick code?/harm intent?) kick_act in code/game/objects/items.dm

//tweak values (moult cost, moult time, health stuff, shadowpower stuff)
//eating objectives

//antag banned code?

//deathgasp for chrysalis and for egg

//directional sprites
//ensure antag objectives even in midround spawn
//fix/remove new_grueegg variable
//admin make grue command
//chrysalis death
//unconscious while moulting/reduce view while moulting
//moulting progress bar, etc
//make moulting take less time but need more shadowpoer/balance this
//progress messages while moulting

//rearrange code block
//remove comments
//check oxygen/heat levels in antag spawn code

//[TEST]make so egg cant move even when controlled
//[TEST]moulting/chrysalis text
//[TEST]warning about vulnerability/immobility
//[TEST]spawns only in dark/maintenance?
//[TEST]flesh out everything in setup.dm ala borers (but antag)
//[TEST]dynamic rulesets?
//[TEST] add antag role code ROLE_GRUE
//[TEST] egg spills open/hatches text?
//[TEST] egg hatching text
//[TEST] egg hatching
//[TEST] add living checks for egg recruiting/hatching
//[TEST] kill egg after hatching
//[TEST]basic instructive messages about being a grue, and also the life stages

//[TEST] egg recruit ala borer

//[DONE]change egg desc on death
//[DONE] passtable/hiding as grue larva only?
//[DONE]change attacksounds for lifestage
//[DONE]move lifestage updates into new proc
//[DONE] prevent AI grues from attacking grue eggs (faction?)
//[DONE]make egg plane lower than humans so people can visually walk over it
//[DONE]set grue size and such
//[DONE]ability to walk on same tile as grue eggs without pushing them
//[DONE] egglaying busy thing
//[DONE] speaking/not/speaking/only being able to speak to other grues
//[DONE] melee abilities and strength change with life stage
//[DONE]greyscale filter or color effects or something?
//[DONE]infrared/night-vision
//[DONE]change capitalization on panel and elsewhere (UI light indicatior)
//[DONE]remove shadowpower visuals when adult?
//[DONE] egg sensitivity to light/smashing
//[DONE] egg laying
//[DONE]message to target when eaten "You have been eaten by a grue."
//[DONE]check for sentient/had mind flag to give power after eating
//[DONE]egg hatch sprite
//[DONE]health gain scaling with eatencount
//[DONE]avoid being able to hit self?
//[DONE] smash walls and such with increased power?
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

//[OBS]announce grue spawn centcomm role?
//[OBS]add lifestage initialization code on new/add to both dynamic rulsets code stuff

//[NEXT VERSION]"cant moult under a table"
//[NEXT VERSION]generalize grue light sensitivity params (and apply to role spawning code)
//[NEXT VERSION]no growl/different sound on unsatisfying meal?
//[NEXT VERSION] move eating updates into new proc
//[NEXT VERSION] move new moult stat param procs into an update that's also called on New()
//[NEXT VERSION] progressbars in different color
//[NEXT VERSION]add butchery products/etc
//[NEXT VERSION] change drones/screeches/syllables, not when juvenile, etc?
//[NEXT VERSION]jumpscare and other sound effects
//[NEXT VERSION]sprite additions while powering up via death essence
//[NEXT VERSION]special names only visible for grues
//[NEXT VERSION]render abilities invisible with life stage?
//[NEXT VERSION]darkpower indicator?
//[NEXT VERSION]eatencount indicator?
//[NEXT VERSION]generalize power, powers costs, costs, power menu
//[NEXT VERSION]animations, incl. egg_trigger
//[NEXT VERSION]basic AI to avoid light and smash things and moult for npc grues
//[NEXT VERSION]sprites for dead pupae (need blood color)?
//[NEXT VERSION]add body part targeting etc for more focused attacks, and relevant text
//[NEXT VERSION]ability UI+mirrored with panel like pulsedemon
//[NEXT VERSION]more detailed messages about being a grue, and also the life stages, or maybe a menu
//[NEXT VERSION]ui button to eat someone
//[NEXT VERSION]eggs layable indicator
//[NEXT VERSION] grue goo, blood, (color of) gibs, moulting goo, egg casing, meat, etc. (including effects)
//[NEXT VERSION]add harm intents and such?

//[NEED FEEDBACK]unable to hit grille/window as grue larva
//[NEED FEEDBACK]dark field?
//	but prevents shadowpower and health gain while using it?
//[NEED FEEDBACK]not affected by atmos?
//[NEED FEEDBACK]consume darkpower to block light?
//[NEED FEEDBACK]smash machiney monitors and such?
//[NEED FEEDBACK]weaker in light/stronger in dark?
//[NEED FEEDBACK]invis in full dark?
//[NEED FEEDBACK]able to push other mobs aside?
//[NEED FEEDBACK]ability to pick up grue eggs. leaving behind casing/skin on the floor (or not)
//[NEED FEEDBACK]turn off lamps etc?
//[NEED FEEDBACK]can activate certain things like morgue tray and push light buttons

/mob/living/simple_animal/hostile/grue/gruespawn
	lifestage=1

/mob/living/simple_animal/hostile/grue/grueling
	lifestage=2




//Moulting into more mature forms.
/mob/living/simple_animal/hostile/grue/verb/moult()
	set name = "Moult"
	set desc = "Moult into a new form." //hide if an adult?
	set category = "Grue"
	if(!alert(src,"Would you like to moult? You will become a vulnerable and immobile chrysalis during the process.",,"Moult","Cancel") == "Moult")
		return
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
		visible_message("<span class='warning'>\The [src] morphs into a chrysalis...</span>")
		stat=UNCONSCIOUS //go unconscious while moulting
		ismoulting=1
		moulttimer=moulttime//reset moulting timer
		plane = MOB_PLANE //In case grue moulted while hiding
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
		health=tempHealth*maxHealth //keep same health percentage
	else
		return

/mob/living/simple_animal/hostile/grue/proc/complete_moult()
	if(ismoulting&&stat!=DEAD)
		var/tempHealth=health/maxHealth //to scale health level
		lifestage_updates()
		health=tempHealth*maxHealth //keep same health percent
		stat=CONSCIOUS //wake up
		ismoulting=0 //is no longer moulting
		to_chat(src, "<span class='warning'>You finish moulting!</span>")
		visible_message("<span class='warning'>The [src] shifts as it morphs into new form!</span>")
	else
		return


/mob/living/simple_animal/hostile/grue/death(gibbed)
	if(ismoulting)
		desc="[desc] This one seems dead and lifeless."
	else
		playsound(src, 'sound/misc/grue_screech.ogg', 50, 1)
	..()

/mob/living/simple_animal/hostile/grue/attack_animal(mob/living/simple_animal/M)
	if(M==src) //Prevent the grue from attacking itself, might help avoid misclicks while attempting to smash lights.
		return
	else
//		if(prob(20)&&lifestage>1)
//			playsound(src, 'sound/misc/grue_growl.ogg', 50, 1) //occasionally growl while attacking
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
		visible_message("<span class='warning'>The [src] tightens up...</span>")
		if(do_after(src, src, 5 SECONDS))
			to_chat(src, "<span class='notice'>You lay an egg.</span>")
			visible_message("<span class='warning'>The [src] pushes out an egg!</span>")
			eatencharge--

//			playsound(T, 'sound/effects/splat.ogg', 50, 1)


			var/mob/living/simple_animal/grue_egg/new_grueegg = new(get_turf(src))
			busy=0

	else
		to_chat(src, "You need to feed more first.")
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
			continue //Dont bother removing them from the list since we only grab one wizard
		return i

	return 0

/mob/living/simple_animal/hostile/grue/proc/transfer_personality(var/client/candidate)


	if(!candidate)
		return

	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.assigned_role = "Grue"

		to_chat(src, "<span class='danger'>You are a grue.</span>")
		to_chat(src, "<span class='info'>Darkness is your ally, bright light is harmful to your kind. You hunger... specifically for sentient beings, but you are still young and cannot eat until you are fully mature.</span>")
		to_chat(src, "<span class='info'>Bask in shadows to prepare to moult. The more sentient beings you eat, the more powerful you will become.</span>")


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

//		playsound(src, 'sound/misc/grue_growl.ogg', 50, 1)

		//Upgrade the grue's stats as it feeds
		if(clicked_on.mind) //must have a mind to power up the grue
			playsound(src, 'sound/misc/grue_growl.ogg', 50, 1)
			eatencount++
			eatencharge++
			speed=max(0.2,speed*0.8) //speed cap of 0.2
			var/tempHealth=health/maxHealth
			maxHealth=round(min(1000,maxHealth+50)) //50 more health with a cap of 1000
			health=tempHealth*maxHealth

			melee_damage_lower = melee_damage_lower+7
			melee_damage_upper = melee_damage_upper+7

			regenbonus=min(100,regenbonus+0.5) //increased health regen in darkness

			force_airlock_time=max(0,force_airlock_time-40)
//			src.set_light(8,-1*eatencount) //gains shadow aura opon eating someone
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






//Ventcrawling and hiding, only for gruespawn
/mob/living/simple_animal/hostile/grue/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	if(lifestage==1)
		var/pipe = start_ventcrawl()
		if(pipe)
			handle_ventcrawl(pipe)
	else
		to_chat(src, "<span class='notice'>You are too big to do that.</span>")

/mob/living/simple_animal/hostile/grue/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Object"

	if(lifestage==1)
		if(isUnconscious())
			return

		if (locked_to && istype(locked_to, /obj/item/critter_cage))
			return

		if (plane != HIDING_MOB_PLANE)
			plane = HIDING_MOB_PLANE
			to_chat(src, "<span class='notice'>You are now hiding.</span>")
		else
			plane = MOB_PLANE
			to_chat(src, "<span class='notice'>You have stopped hiding.</span>")
	else
		to_chat(src, "<span class='notice'>You are too big to do that.</span>")