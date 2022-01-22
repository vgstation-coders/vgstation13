/mob/living/simple_animal/hostile/grue

	//Instead of initializing them here, many values that vary with life stage are set via the lifestage_updates proc, which is called during New() and also after moulting.
	icon = 'icons/mob/grue.dmi'
	speed=1
	var/base_speed=1
	can_butcher = TRUE
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal/grue
	name = "grue"
	real_name = "grue"
	minbodytemp = 150 //resistant to cold

	a_intent=I_HURT //Initialize these
	m_intent=I_HURT

	universal_speak = 0
	universal_understand = 0

	response_help  = "touches"
	response_disarm = "pushes"
	response_harm   = "punches"

	faction = "grue" //Keep grues and grue eggs friendly to each other.
	force_airlock_time=50 									//so that grues cant easily rush through a light area and quickly force open a door to escape back into the dark
	blood_color2=GRUE_BLOOD
//flesh_color2="#272728"

	//VARS
	var/shadowpower = 0											 //shadow power absorbed
	var/maxshadowpower = 1000									   //max shadowpower
	var/moultcost = 0 											//shadow power needed to moult into next stage (irrelevant for adults)
	var/ismoulting = 0 //currently moulting (1=is a chrysalis)
	var/moulttime = 30 //time required to moult to a new form
	var/moulttimer = 30 //moulting timer
	var/current_brightness = 0									   //light level of current tile, range from 0 to 10
	var/hatched = 0			//whether or not this grue hatched from an egg
	var/channeling = 0 // channeling an ability that costs shadowpower or not

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

	var/lifestage=GRUE_ADULT												 //1=baby grue, 2=grueling, 3=(mature) grue
	var/eatencount=0												//number of sentient carbons eaten, makes the grue more powerful
	var/eatencharge=0												//power charged by eating sentient carbons, increments with eatencount but is spent on upgrades
	var/spawncount=0												//how many eggs laid by this grue have successfully hatched
	var/dark_dim_light=0 //darkness level currently the grue is currently exposed to, 0=nice and dark, 1=passably dim, 2=too bright
	var/busy=0 //busy laying an egg



	//eyesight related stuff
	see_in_dark = 8
	//keeping this here for later color matrix testing
	var/a_use_alpha=1
	var/a_blend_add_test=255

	var/a_matrix_testing_override = 0 //not used for now
	var/a_11_rr = 1
	var/a_12_rg = 0
	var/a_13_rb = 0
	var/a_14_ra = 1
	var/a_21_gr = -1
	var/a_22_gg = 0.2
	var/a_23_gb = 0.2
	var/a_24_ga = 1
	var/a_31_br = -1
	var/a_32_bg = 0.2
	var/a_33_bb = 0.2
	var/a_34_ba = 1
	var/a_41_ar = 0
	var/a_42_ag = 0
	var/a_43_ab = 0
	var/a_44_aa = 1
	var/a_51_cr = 0
	var/a_52_cg = 0
	var/a_53_cb = 0
	var/a_54_ca = 0

/mob/living/simple_animal/hostile/grue/modMeat(mob/user, var/obj/theMeat)
	theMeat.name="grue meat"

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
			apply_damage(-1*burnmalus*regenbonus*hg_mult*(bright_limit_gain-current_brightness),BURN) //scale darkness healing for juveniles and adults heal rates a bit
		else if(current_brightness>bright_limit_drain) 														//lose health in light
			dark_dim_light=2

			to_chat(src, "<span class='warning'>The bright light scalds you!</span>")
			playsound(src, 'sound/effects/grue_burn.ogg', 50, 1)
			apply_damage(burnmalus*hd_mult*(current_brightness-bright_limit_drain),BURN)								//scale light damage with lifestage to avoid juveniles and adults from becoming too tanky to light
		else
			dark_dim_light=1
		if(current_brightness<=bright_limit_gain && !ismoulting && !channeling)
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
	if(lifestage==GRUE_LARVA)
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
		//Larval grue spells: moult, ventcrawl, and hide
		add_spell(new /spell/aoe_turf/grue_hide, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/aoe_turf/grue_ventcrawl, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/aoe_turf/grue_moult, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)

	else if (lifestage==GRUE_JUVENILE)
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
		//Juvenile grue spells: moult
		add_spell(new /spell/aoe_turf/grue_moult, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
	else
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
		force_airlock_time=50
		//Adult grue spells: eat and lay eggs
		if(config.grue_egglaying)
			add_spell(new /spell/aoe_turf/grue_egg, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/targeted/grue_eat, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)


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
			client.color = list(a_11_rr,a_12_rg,a_13_rb,a_14_ra,
								a_21_gr,a_22_gg,a_23_gb,a_24_ga,
		 						a_31_br,a_32_bg,a_33_bb,a_34_ba,
			 					a_41_ar,a_42_ag,a_43_ab,a_44_aa,
			 					a_51_cr,a_52_cg,a_53_cb,a_54_ca)

/mob/living/simple_animal/hostile/grue/Stat()
	..()
	if(statpanel("Status"))
		if(ismoulting)
			stat(null, "Moulting progress: [round(100*(1-moulttimer/moulttime),0.1)]%")
		if(lifestage!=GRUE_ADULT) //not needed for adults
			stat(null, "Shadow power: [round(shadowpower,0.1)]/[round(maxshadowpower,0.1)]")
		if(lifestage==GRUE_ADULT)
			if(config.grue_egglaying)
				stat(null, "Reproductive energy: [eatencharge]")
			stat(null, "Sentient organisms eaten: [eatencount]")

/mob/living/simple_animal/hostile/grue/gruespawn
	lifestage=GRUE_LARVA

/mob/living/simple_animal/hostile/grue/grueling
	lifestage=GRUE_JUVENILE

//Moulting into more mature forms.
/mob/living/simple_animal/hostile/grue/proc/moult()
	if(alert(src,"Would you like to moult? You will become a vulnerable and immobile chrysalis during the process.",,"Moult","Cancel") == "Moult")
		if (lifestage<GRUE_ADULT)
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
	else
		return

/mob/living/simple_animal/hostile/grue/proc/start_moult()
	if(stat==CONSCIOUS && shadowpower>=moultcost && !ismoulting && lifestage<GRUE_ADULT)
		shadowpower-=moultcost
		to_chat(src, "<span class='notice'>You begin moulting.</span>")
		visible_message("<span class='warning'>\The [src] morphs into a chrysalis...</span>")
		stat=UNCONSCIOUS //go unconscious while moulting
		ismoulting=1
		moulttimer=moulttime//reset moulting timer
		plane = MOB_PLANE //In case grue somehow moulted while hiding
		var/tempHealth=health/maxHealth //to scale health level
		if(lifestage==GRUE_LARVA)
			lifestage=GRUE_JUVENILE
			desc = "A small grue chrysalis."
			name = "grue chrysalis"
			icon_state = "moult1"
			icon_living = "moult1"
			icon_dead = "moult1"
			maxHealth=25 //vulnerable while moulting
		else if(lifestage==GRUE_JUVENILE)
			lifestage=GRUE_ADULT
			desc = "A grue chrysalis."
			name = "grue chrysalis"
			icon_state = "moult2"
			icon_living = "moult2"
			icon_dead = "moult2"
			maxHealth=50 //vulnerable while moulting
		health=tempHealth*maxHealth //keep same health percentage
		//Remove spells to prepare for new lifestage spell list
		var/list/current_spells = src.spell_list.Copy()
		for(var/spell/S in current_spells)
			src.remove_spell(S)
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
		if(lifestage==GRUE_JUVENILE)
			to_chat(src, "<span class='warning'>You finish moulting! You are now a juvenile, and are strong enough to force open doors.</span>")
		else if(lifestage==GRUE_ADULT)
			to_chat(src, "<span class='warning'>You finish moulting! You are now fully-grown, and can eat sentient beings to gain their strength.</span>")
		playsound(src, 'sound/effects/grue_moult.ogg', 50, 1)
	else
		return

/mob/living/simple_animal/hostile/grue/death(gibbed)
	if(!gibbed)
		playsound(src, 'sound/misc/grue_screech.ogg', 50, 1)
	if(ismoulting)
		desc="[desc] This one seems dead and lifeless."
	..()

//Reproduction via egglaying.
/mob/living/simple_animal/hostile/grue/proc/reproduce()

	if (lifestage==GRUE_ADULT) //must be adult
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
			var/mob/living/simple_animal/grue_egg/E = new /mob/living/simple_animal/grue_egg(get_turf(src))
			E.parent_grue=src //mark this grue as the parent of the egg
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
	if(hatched && src.mind) //Assign it grue_basic objectives if its a hatched grue
		var/datum/role/grue/hatchRole = new /datum/role/grue
		mind.assigned_role = "Grue"
		hatchRole.AssignToRole(mind,1)
		hatchRole.Greet(GREET_DEFAULT)
		hatchRole.ForgeObjectives(hatched)
		hatchRole.AnnounceObjectives()

//Eating sentient beings.

/mob/living/simple_animal/hostile/grue/proc/handle_feed(var/mob/living/E)
	to_chat(src, "<span class='danger'>You open your mouth wide, preparing to eat [E]!</span>")
	busy=1
	if(do_mob(src , E, 5 SECONDS, 100, 0))
		to_chat(src, "<span class='danger'>You have eaten [E]!</span>")
		to_chat(E, "<span class='danger'>You have been eaten by a grue.</span>")

		//Upgrade the grue's stats as it feeds
		if(E.mind) //eaten creature must have a mind to power up the grue
			playsound(src, 'sound/misc/grue_growl.ogg', 50, 1)
			eatencount++					//for the status display

			if(mind && mind.GetRole(GRUE)) //also increment the counter for objectives
				var/datum/role/grue/G = mind.GetRole(GRUE)
				if(G)
					G.eatencount++

			eatencharge++

			//increase speed
			speed_m_dark=max(1/5,speed_m_dark/1.25)	// 20% faster in darkness
			speed_m_dim=max(1.1/5,speed_m_dim/1.25)	// 20% faster in dim light
			speed_m_light=max(4/5,speed_m_light/1.05) //slightly faster in bright light

			//increase damage
			melee_damage_lower = melee_damage_lower+7
			melee_damage_upper = melee_damage_upper+7

			regenbonus=regenbonus*1.5 //increased health regen in darkness

			force_airlock_time=max(0,force_airlock_time-20)
//			src.set_light(8,-1*eatencount) //gains shadow aura opon eating someone
			switch(eatencount)
				if(GRUE_WALLBREAK)
					to_chat(src, "<span class='warning'>You feel power coursing through you! You feel strong enough to smash down most walls... but still hungry...</span>")
					environment_smash_flags = environment_smash_flags | SMASH_WALLS
				if(GRUE_RWALLBREAK)
					to_chat(src, "<span class='warning'>You feel power coursing through you! You feel strong enough to smash down even reinforced walls... but still hungry...</span>")
					environment_smash_flags = environment_smash_flags | SMASH_RWALLS
				else
					to_chat(src, "<span class='warning'>You feel power coursing through you! You feel stronger... but still hungry...</span>")
		else
			to_chat(src, "<span class='warning'>That creature didn't quite satisfy your hunger...</span>")
		E.gib()
	busy=0
//Channel a dark aura
/mob/living/simple_animal/hostile/grue/verb/darkaura()
//todo
	return


//Ventcrawling and hiding, only for gruespawn
/mob/living/simple_animal/hostile/grue/proc/ventcrawl()
	if(lifestage==GRUE_LARVA)
		var/pipe = start_ventcrawl()
		if(pipe)
			handle_ventcrawl(pipe)
	else
		to_chat(src, "<span class='notice'>You are too big to do that.</span>")

/mob/living/simple_animal/hostile/grue/proc/hide()

	if(lifestage==GRUE_LARVA)
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
