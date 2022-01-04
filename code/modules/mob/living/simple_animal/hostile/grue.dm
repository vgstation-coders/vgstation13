/mob/living/simple_animal/hostile/grue

	icon = 'icons/mob/grue.dmi'
	speed=1
	var/base_speed=1
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
	force_airlock_time=100 									//so that juvenile grues cant easily rush through a light area and quickly force open a door to escape back into the dark

	//VARS
	var/shadowpower = 0											 //shadow power absorbed
	var/maxshadowpower = 1000									   //max shadowpower
	var/moultcost = 0 											//shadow power needed to moult into next stage (irrelevant for adults)
	var/ismoulting = 0 //currently moulting (1=is a chrysalis)
	var/moulttime = 30 //time required to moult to a new form
	var/moulttimer = 30 //moulting timer
	var/current_brightness = 0									   //light level of current tile, range from 0 to 10
	var/hatched=0			//whether or not this grue hatched from an egg

	var/bright_limit_gain = 1											//maximum brightness on tile for health and power regen
	var/bright_limit_drain = 3											//maximum brightness on tile to not drain health and power
	var/regenbonus=1													//bonus to health regen based on sentient beings eaten
	var/burnmalus=1														//malus to life drain based on life stage to avoid grues becoming too tanky to light as they mature
	var/speed_m_dark=1/1.2		//speed multiplier in dark conditions
	var/speed_m_dim=1/1.1			//speed multiplier in dim conditions
	var/speed_m_light=1			//speed multiplier in light conditions
	var/speed_m=1				//active speed multiplier

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


	//eyesight related stuff
	see_in_dark = 8
	//keeping this here for later color matrix testing
	var/a_use_alpha=1
	var/a_blend_add_test=255

	var/a_matrix_testing_override = 0 //not used for now
	var/a_11 = 1
	var/a_12 = 0
	var/a_13 = 0
	var/a_14 = 1
	var/a_21 = -1
	var/a_22 = 0.2
	var/a_23 = 0.2
	var/a_24 = 1
	var/a_31 = -1
	var/a_32 = 0.2
	var/a_33 = 0.2
	var/a_34 = 1
	var/a_41 = 0
	var/a_42 = 0
	var/a_43 = 0
	var/a_44 = 1
	var/a_51 = 0
	var/a_52 = 0
	var/a_53 = 0
	var/a_54 = 0

//	var/b_matrix_testing_override=0 //not used for now
//	var/b_11 = 1
//	var/b_12 = 0
//	var/b_13 = 0
//	var/b_21 = 0
//	var/b_22 = 1
//	var/b_23 = 0
//	var/b_31 = 0
//	var/b_32 = 0
//	var/b_33 = 1
//	var/b_41 = 0
//	var/b_42 = 0
//	var/b_43 = 0

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
		if(current_brightness<=bright_limit_gain && !ismoulting) //moulting temporarily stops healing via darkness
			dark_dim_light=0
			apply_damage(-1*burnmalus*regenbonus*hg_mult*(bright_limit_gain-current_brightness),BURN) //boost juveniles and adults heal rates a bit also using burnmalus
		else if(current_brightness>bright_limit_drain) 														//lose health in light
			dark_dim_light=2

			to_chat(src, "<span class='warning'>The bright light scalds you!</span>")
			playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
			apply_damage(burnmalus*hd_mult*(current_brightness-bright_limit_drain),BURN)								//scale light damage by lifestage**(1/3) to avoid juveniles and adults from becoming too tanky to light
		else
			dark_dim_light=1
		if(current_brightness<=bright_limit_gain && !ismoulting)
			shadowpower = min(maxshadowpower,shadowpower+pg_mult*(bright_limit_gain-current_brightness))	   //gain power in dark
		else if(current_brightness>bright_limit_drain)
			shadowpower = max(0,shadowpower-pd_mult*(current_brightness-bright_limit_drain))				  //drain power in light

		//process speed modifiers
		if(dark_dim_light==0)
			speed=base_speed*speed_m_dark
		else if(dark_dim_light==1)
			speed=base_speed*speed_m_dim
		else if(dark_dim_light==2)
			speed=base_speed*speed_m_light

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
		moultcost=250
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
		environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_STRONG
		attack_sound = 'sound/weapons/cbar_hitbod1.ogg'
		size = SIZE_NORMAL
		pass_flags = 0
		force_airlock_time=100
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
		force_airlock_time=0
	health=tempHealth*maxHealth

//Grue vision
/mob/living/simple_animal/hostile/grue/update_perception()

	if(client)
		if(client.darkness_planemaster && a_use_alpha)
			client.darkness_planemaster.blend_mode = BLEND_ADD
			client.darkness_planemaster.alpha = a_blend_add_test
		client.color = list(
					1,0,0,1,
					-1,0.2,0.2,1,
	 				-1,0.2,0.2,1,
		 			0,0,0,1,
		 			0,0,0,0)

		if(a_matrix_testing_override)
			client.color = list(a_11,a_12,a_13,a_14,
								a_21,a_22,a_23,a_24,
		 						a_31,a_32,a_33,a_34,
			 					a_41,a_42,a_43,a_44,
			 					a_51,a_52,a_53,a_54)
//		else if(b_matrix_testing_override) //not used for now
//			colourmatrix = list(b_11, b_12, b_22,
//						 b_21,b_22, b_23,
//						 b_31, b_32, b_33,
//						 b_41, b_42, b_43)

/mob/living/simple_animal/hostile/grue/Stat()
	..()
	if(statpanel("Status"))
		if(ismoulting)
			stat(null, "Moulting progress: [round(100*(1-moulttimer/moulttime),0.1)]%")
		if(lifestage<3) //not needed for adults
			stat(null, "Shadow power: [round(shadowpower,0.1)]/[round(maxshadowpower,0.1)]")
		if(lifestage>=3)
			if(config.grue_egglaying)
				stat(null, "Reproductive energy: [eatencharge]")
			stat(null, "Sentient life forms eaten: [eatencount]")

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
			to_chat(src, "<span class='notice'>You need to bask in shadow more first. ([moultcost] shadow power required)</span>")
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
	if(stat==CONSCIOUS && shadowpower>=moultcost && !ismoulting && lifestage<3)
		shadowpower-=moultcost
		lifestage++
		to_chat(src, "<span class='notice'>You begin moulting.</span>")
		visible_message("<span class='warning'>\The [src] morphs into a chrysalis...</span>")
		stat=UNCONSCIOUS //go unconscious while moulting
		ismoulting=1
		moulttimer=moulttime//reset moulting timer
		plane = MOB_PLANE //In case grue moulted while hiding
		var/tempHealth=health/maxHealth //to scale health level
		if(lifestage==2)
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
	if(ismoulting && stat!=DEAD)
		var/tempHealth=health/maxHealth //to scale health level
		lifestage_updates()
		health=tempHealth*maxHealth //keep same health percent
		stat=CONSCIOUS //wake up
		ismoulting=0 //is no longer moulting
		visible_message("<span class='warning'>The chrysalis shifts as it morphs into a grue!</span>")
		if(lifestage==2)
			to_chat(src, "<span class='warning'>You finish moulting! You are now a juvenile, and are strong enough to force open doors./span>")
		else if(lifestage==3)
			to_chat(src, "<span class='warning'>You finish moulting! You are now fully-grown, and can eat sentient beings to gain their strength.</span>")
		playsound(src, 'sound/effects/lingextends.ogg', 50, 1)
	else
		return

/mob/living/simple_animal/hostile/grue/death(gibbed)
	if(ismoulting)
		desc="[desc] This one seems dead and lifeless."
	else
		playsound(src, 'sound/misc/grue_screech.ogg', 50, 1)
	..()

//Reproduction via egglaying.
/mob/living/simple_animal/hostile/grue/verb/reproduce()
	set name = "Reproduce"
	set desc = "Spawn offspring in the form of an egg."
	set category = "Grue"
	if (!config.grue_egglaying) //Check if egglaying is enabled.
		return
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
		if(do_after(src, src, 5 SECONDS))
			to_chat(src, "<span class='notice'>You lay an egg.</span>")
			visible_message("<span class='warning'>\The [src] pushes out an egg!</span>")
			eatencharge--
//			playsound(T, 'sound/effects/splat.ogg', 50, 1)
			new /mob/living/simple_animal/grue_egg(get_turf(src))
		busy=0

	else
		to_chat(src, "<span class='notice'>You need to feed more first.</span>")
		return

//Procs for grabbing players.
/mob/living/simple_animal/hostile/grue/proc/request_player()
	var/list/candidates=list()
	for(var/mob/dead/observer/G in get_active_candidates(ROLE_GRUE, poll="Would you like to become a grue?"))
		if(!G.client)
			continue
		if(isantagbanned(G))
			continue
		candidates += G
	if(!candidates.len)
		message_admins("Unable to find a mind for [src.name]")
		return 0
	shuffle(candidates)
	for(var/mob/i in candidates)
		if(!i || !i.client)
			continue //Dont bother removing them from the list since we only grab one grue
		return i

	return 0

/mob/living/simple_animal/hostile/grue/proc/transfer_personality(var/client/candidate)

	if(!candidate)
		return
	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.assigned_role = "Grue"
		to_chat(src, "<span class='warning'>You are a grue.</span>")
		to_chat(src, "<span class='warning'>Darkness is your ally; bright light is harmful to your kind. You hunger... specifically for sentient beings, but you are still young and cannot eat until you are fully mature.</span>")
		to_chat(src, "<span class='warning'>Bask in shadows to prepare to moult. The more sentient beings you eat, the more powerful you will become.</span>")


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

/mob/living/simple_animal/hostile/grue/proc/handle_feed(var/mob/living/E)
	to_chat(src, "<span class='danger'>You open your mouth wide, preparing to eat [E]!</span>")
	if(do_mob(src , E, 10 SECONDS, 100, 0))
		to_chat(src, "<span class='danger'>You have eaten [E]!</span>")
		to_chat(E, "<span class='danger'>You have been eaten by a grue.</span>")

		//Upgrade the grue's stats as it feeds
		if(E.mind) //eaten creature must have a mind to power up the grue
			playsound(src, 'sound/misc/grue_growl.ogg', 50, 1)
			eatencount++
			eatencharge++
			base_speed=max(0.2,base_speed*0.8) //speed cap of 0.2
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
					to_chat(src, "<span class='warning'>You feel power coursing through you! You feel strong enough to smash down most walls... but still hungry...</span>")
					environment_smash_flags = environment_smash_flags | SMASH_WALLS
				if(4)
					to_chat(src, "<span class='warning'>You feel power coursing through you! You feel strong enough to smash down even reinforced walls... but still hungry...</span>")
					environment_smash_flags = environment_smash_flags | SMASH_RWALLS
				else
					to_chat(src, "<span class='warning'>You feel power coursing through you! You feel stronger... but still hungry...</span>")

			//Create a clone-able glob of gore like a slime puddle. (unused for now)
////			E.dropBorers()
//			for(var/atom/movable/I in E.contents)
//				I.forceMove(E.loc)
////			anim(target = E, a_icon = 'icons/mob/mob.dmi', flick_anim = "liquify", sleeptime = 15)
//			var/mob/living/gore_pile/G = new(E.loc)
//			if(E.real_name)
//				G.real_name = E.real_name
//				G.name = "glob of [E.real_name] gore"
//				G.desc = "The gory remains of what used to be [G.real_name]. There's probably still enough genetic material in there for a cloning console to work its magic."
//			G.gored_person = E
//			E.forceMove(G)
//			//Transfer DNA and mind into the gore glob
//			G.dna=E.dna
//			G.mind=E.mind
		else
			to_chat(src, "<span class='notice'>That creature didn't quite satisfy your hunger...</span>")
		E.gib()

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
