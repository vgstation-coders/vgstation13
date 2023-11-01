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
	blood_color2=GRUE_BLOOD
//flesh_color2="#272728"
	see_in_dark = 8

	//VARS
	var/nutrienergy = 0											 //nutritive energy absorbed
	var/maxnutrienergy = 200									   //max nutrienergy
	var/moultcost = 0 											//nutritive energy needed to moult into next stage (irrelevant for adults)
	var/ismoulting = FALSE //currently moulting (TRUE=is a chrysalis)
	var/moulttime = 15 //time required to moult to a new form (life ticks)
	var/moulttimer = 15 //moulting timer
	var/hatched = FALSE			//whether or not this grue hatched from an egg
	var/channeling_flags = 0 // channeling the drain light ability or not

	var/base_melee_dam_up = 5				//base melee damage upper
	var/base_melee_dam_lw = 3				//base melee damage lower

	var/lifestage=GRUE_ADULT												 //1=baby grue, 2=grueling, 3=(mature) grue
	var/eatencount=0												//number of sentient carbons eaten, makes the grue more powerful
	var/eatencharge=0												//power charged by eating sentient carbons, increments with eatencount but is spent on upgrades
	var/spawncount=0												//how many eggs laid by this grue have successfully hatched

	var/number = 1 //Appends a number to the grue to keep it distinguishable, the compiler doesn't play nicely with putting rand(1, 1000) here so it goes in New()

	var/busy=FALSE //busy attempting to lay an egg or eat

	var/eattime= 3.5 SECONDS //how long it takes to eat someone
	var/digest = 0 //how many life ticks of healing left after feeding
	var/digest_heal = -7.5 //how much health restored per life tick after feeding (negative heals)
	var/digest_sp = 10 //how much nutritive energy gained per life tick after feeding

	var/datum/grue_calc/grue/lightparams = new /datum/grue_calc/grue //used for light-related calculations

	//AI related:
	stop_automated_movement = TRUE //has custom light-related wander movement
	wander = FALSE

/datum/grue_calc //used for light-related calculations
	var/bright_limit_gain = 1											//maximum brightness on tile for health and power regen
	var/bright_limit_drain = 3											//maximum brightness on tile to not drain health and power
	var/hg_mult = 3										//base multiplier for health gained per tick when on dark tile
	var/hd_mult = 3									 //base multiplier for health drained per tick on bright tile (subject to further modification by how long the grue is exposed via accum_light_expos_mult)
	var/dark_dim_light = GRUE_DARK //darkness level currently the grue is currently exposed to, GRUE_DARK=nice and dark (heals the grue), GRUE_DIM=passably dim, GRUE_LIGHT=too bright (burns the grue)
	var/current_brightness = 0									   //light level of current tile, range from 0 to 10
	var/accum_light_expos_mult= 1 //used to scale light damage the longer the grue is exposed to light
	var/list/accum_light_expos_gain_dark_dim_light=list(-3,-1,1) //light damage rate increases the longer the grue is exposed to light, but this effect dissipates after going back into darkness

/datum/grue_calc/proc/ddl_update(var/mob/living/G)
	if(isturf(G.loc))
		var/turf/T = G.loc
		current_brightness=10*T.get_lumcount()
	else												//else, there's considered to be no light (vents, lockers, etc.)
		current_brightness=0
	if(current_brightness<=bright_limit_gain)
		dark_dim_light=GRUE_DARK
	else if(current_brightness>bright_limit_drain)
		dark_dim_light=GRUE_LIGHT
	else
		dark_dim_light=GRUE_DIM


////Procs for light-related burning and healing, and nutrienergy updates:

////Shared by both grues and grue eggs:
/datum/grue_calc/proc/alem_adjust() //update multiplier for exposure-scaling light damage
	accum_light_expos_mult=max(1,accum_light_expos_mult+accum_light_expos_gain_dark_dim_light[dark_dim_light+1]) //modify light damage multiplier based on how long the grue's been in light recently

////Grue specific:
/datum/grue_calc/grue/proc/get_light_damage(var/mob/living/simple_animal/hostile/grue/G) //specific to grues and not grue eggs
	return (current_brightness-bright_limit_drain) * accum_light_expos_mult * hd_mult * lightresist * (G.maxHealth/250) 	//scale light damage by: how bright the light is, amount of recent light exposure, the base multiplier, lifestage-dependent resistance, and normalize by max health,

/datum/grue_calc/grue/proc/get_dark_heal(var/mob/living/simple_animal/hostile/grue/G) //specific to grues and not grue eggs
	return -1 * (bright_limit_gain-current_brightness) * hg_mult * regenbonus * !(G.channeling_flags & GRUE_DRAINLIGHT) * (G.maxHealth/250)							//scale dark healing by: how dark it is, the base multiplier, the bonus based on sentient beings eaten, disable if draining light, and normalize by max health.

/datum/grue_calc/grue //specific to grues and not their eggs
	var/pg_mult = 0										 //multiplier for nutrienergy gained per tick when on dark tile (0=disabled)
	var/pd_mult = 0									  //multiplier for nutrienergy drained per tick on bright tile (0=disabled)
	var/list/speed_m_dark_dim_light=list(1/1.2,1/1.1,1) //speed modifiers based on light condition
	var/list/base_speed_m_dark_dim_light=list(1/1.2,1/1.1,1) //base speed modifiers based on light condition
	var/regenbonus=1													//bonus to health regen based on sentient beings eaten
	var/base_regenbonus=1.5
	var/lightresist=1													//scales light damage depending on life stage to make grues slightly more resistant to light as they mature. multiplicative (lower is more resistant).

/datum/grue_calc/grue/proc/nutri_adjust(var/mob/living/simple_animal/hostile/grue/G)
	switch(dark_dim_light)
		if(GRUE_DARK)
			if(!G.ismoulting && !(G.channeling_flags & GRUE_DRAINLIGHT)) //Don't gain power in the dark if the grue is moulting or channeling drain light.
				G.nutrienergy = min(G.maxnutrienergy,G.nutrienergy+pg_mult*(bright_limit_gain-current_brightness))	   //gain power in dark (disabled while pd_mult = 0)
		if(GRUE_LIGHT)
			G.nutrienergy = max(0,G.nutrienergy-pd_mult*(current_brightness-bright_limit_drain))				  //drain power in light (disabled while pd_mult = 0)

/datum/grue_calc/grue/proc/speed_adjust(var/mob/living/simple_animal/hostile/grue/G)
	G.speed=G.base_speed*speed_m_dark_dim_light[dark_dim_light+1]

////Egg specific:
/datum/grue_calc/egg
	hd_mult = 5		//eggs are more sensitive to light than hatched grues


//eggs have slightly simpler light damage and healing calculations due to having less multipliers
/datum/grue_calc/egg/proc/get_light_damage(var/mob/living/E)
	return (current_brightness-bright_limit_drain) * accum_light_expos_mult * hd_mult * (E.maxHealth/250) 	//scale light damage by: how bright the light is, amount of recent light exposure, the base multiplier, and normalize by max health,

/datum/grue_calc/egg/proc/get_dark_heal(var/mob/living/E)
	return -1 * (bright_limit_gain-current_brightness) * hg_mult * (E.maxHealth/250)							//scale dark healing by: how dark it is, the base multiplier, and normalize by max health.

/mob/living/simple_animal/hostile/grue/has_hand_check()
	return TRUE //Skip checking for hands so that grues can pull things.

/mob/living/simple_animal/hostile/grue/modMeat(mob/user, var/obj/theMeat)
	theMeat.name="grue meat"

/mob/living/simple_animal/hostile/grue/regular_hud_updates()
	..()
	if(client && hud_used)
		hud_used.grue_hud()

//health indicator
		if(health >= maxHealth)
			healths.icon_state = "health0"
		else if(health >= 4*maxHealth/5)
			healths.icon_state = "health1"
		else if(health >= 3*maxHealth/5)
			healths.icon_state = "health2"
		else if(health >= 2*maxHealth/5)
			healths.icon_state = "health3"
		else if(health >= 1*maxHealth/5)
			healths.icon_state = "health4"
		else if(health > 0)
			healths.icon_state = "health5"
		else
			healths.icon_state = "health6"
//darkness level indicator
		if(lightparams.dark_dim_light==GRUE_DARK)
			healths2.icon_state= "lightlevel_dark"
			healths2.name="nice and dark"
		else if(lightparams.dark_dim_light==GRUE_DIM)
			healths2.icon_state= "lightlevel_dim"
			healths2.name="adequately dim"
		else if(lightparams.dark_dim_light==GRUE_LIGHT)
			healths2.icon_state= "lightlevel_bright"
			healths2.name="painfully bright"

/mob/living/simple_animal/hostile/grue/Life()
	..()

	//process nutrienergy and health according to current tile brightness level
	if(stat!=DEAD)

		lightparams.ddl_update(src)

		//apply eating-based healing before processing light-based damage or healing
		if(digest)
			apply_damage(digest_heal,BRUTE)
			nutrienergy=min(maxnutrienergy,nutrienergy+digest_sp)
			digest--

		switch(lightparams.dark_dim_light)
			if(GRUE_DARK) //dark
				if(!ismoulting) //moulting temporarily stops healing via darkness
					apply_damage(lightparams.get_dark_heal(src),BURN) //heal in dark
			if(GRUE_LIGHT) //light
				var/thisdmg=lightparams.get_light_damage(src)
				apply_damage(thisdmg,BURN) //burn in light
				if(thisdmg>(maxHealth/7))
					to_chat(src, "<span class='danger'>The burning light sears your flesh!</span>")
				else
					to_chat(src, "<span class='warning'>The bright light scalds you!</span>")
				playsound(src, 'sound/effects/grue_burn.ogg', 50, 1)

		//update accum_light_expos_mult for light damage
		lightparams.alem_adjust()

		//handle light-based nutrienergy gain or drain
		lightparams.nutri_adjust(src)

		//update speed modifier based on light condition
		lightparams.speed_adjust(src)

		if(ismoulting)
			moulttimer--
			if(moulttimer<=0)
				complete_moult()

	regular_hud_updates()
	standard_damage_overlay_updates()

	if((stat==CONSCIOUS) && !busy && !ismoulting && !client && !mind && !ckey) //Checks for AI
		grue_ai()

//Grues already have a way to check their own health and the damage indicator doesn't mesh well with the vision.
/mob/living/simple_animal/hostile/grue/standard_damage_overlay_updates()
	return

//AI stuff:
/mob/living/simple_animal/hostile/grue/proc/grue_ai()

	//Moulting
	if(lifestage!=GRUE_ADULT && (nutrienergy>=moultcost) && lightparams.dark_dim_light==GRUE_DARK)
		start_moult()

	//Eating
	if(lifestage>=GRUE_JUVENILE && stance==HOSTILE_STANCE_IDLE && lightparams.dark_dim_light<GRUE_LIGHT)
		var/list/feed_targets = list()
		for(var/mob/living/carbon/C in range(1,get_turf(src)))
			feed_targets += C
		if(feed_targets.len)
			handle_feed(pick(feed_targets))

	//Egglaying
	if(lifestage==GRUE_ADULT && eatencharge>0 && lightparams.dark_dim_light==GRUE_DARK)
		reproduce()

	//Movement
	//
	//Wandering behavior
	if((!client||deny_client_move) && !busy && !ismoulting && !anchored && (ckey == null) && !(flags & INVULNERABLE))
		if(canmove)
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby))
					var/list/potential_dests=list() //any potential wander destinations
					var/list/respite_dests=list() //any potential wander destinations leading out of the light into dark/dim
					for(var/direction in cardinal)
						var/potential_dest = get_step(src, direction)
						if(lightparams.dark_dim_light==GRUE_LIGHT)//always prioritize wandering to a dark/dim tile if in light
							if(get_ddl(potential_dest)<GRUE_LIGHT)
								respite_dests+=potential_dest
							else
								potential_dests+=potential_dest
						else //never wander from a dark/dim tile into light
							if(get_ddl(potential_dest)<GRUE_LIGHT)
								potential_dests+=potential_dest
					var/ourdest
					if(respite_dests.len)
						ourdest=pick(respite_dests)
					else if(potential_dests.len)
						ourdest=pick(potential_dests)
					if(ourdest)
						wander_move(ourdest)
						turns_since_move = 0

/mob/living/simple_animal/hostile/grue/New()
	..()
	add_language(LANGUAGE_GRUE)
	default_language = all_languages[LANGUAGE_GRUE]
	number = rand(1, 1000)
	init_language = default_language
	lifestage_updates() //update the grue's sprite and stats according to the current lifestage

/mob/living/simple_animal/hostile/grue/Login()
	..()
	//client.images += light_source_images

/mob/living/simple_animal/hostile/grue/UnarmedAttack(atom/A)
	if(isturf(A))
		var/turf/T = A
		for(var/atom/B in T)
			if(istype(B, /obj/machinery/light))
				var/obj/machinery/light/L = B
				if(!L.current_bulb || L.current_bulb.status == LIGHT_BROKEN)
					continue
				UnarmedAttack(B)
	..()

/mob/living/simple_animal/hostile/grue/unarmed_attack_mob(target)
	if(isgrue(target))
		playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		visible_message("<span class='notice'>[src] nuzzles \the [target].</span>", "<span class='notice'>You nuzzle \the [target].</span>")
		return
	return ..()


/mob/living/simple_animal/hostile/grue/proc/get_ddl(var/turf/thisturf) //get the dark_dim_light status of a given turf
	var/thisturf_brightness=10*thisturf.get_lumcount()
	if(thisturf_brightness<=lightparams.bright_limit_gain)
		return GRUE_DARK
	else if(thisturf_brightness>lightparams.bright_limit_drain)
		return GRUE_LIGHT
	else
		return GRUE_DIM

/mob/living/simple_animal/hostile/grue/proc/lifestage_updates() //Initialize or update lifestage-dependent stats
	if(lifestage==GRUE_LARVA)
		name = "grue larva"
		desc = "A scurrying thing that lives in the dark. It is still a larva."
		icon_state = "gruespawn_living"
		icon_living = "gruespawn_living"
		icon_dead = "gruespawn_dead"
		base_melee_dam_up = 5				//base melee damage upper
		base_melee_dam_lw = 3				//base melee damage lower
		attacktext = "bites"
		rescaleHealth(50)
		nutrienergy=50 //starts out ready to moult
		maxnutrienergy = 50
		moultcost=50
		lightparams.lightresist=1
		environment_smash_flags = 0
		attack_sound = 'sound/weapons/bite.ogg'
		size = SIZE_SMALL
		pass_flags = PASSTABLE
		reagents.maximum_volume = 500
		//Larval grue spells: moult, ventcrawl, and hide
		add_spell(new /spell/aoe_turf/grue_hide, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/aoe_turf/grue_ventcrawl, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/aoe_turf/grue_moult, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)

	else if(lifestage==GRUE_JUVENILE)
		name = "grue"
		desc = "A creeping thing that lives in the dark. It is still a juvenile."
		icon_state = "grueling_living"
		icon_living = "grueling_living"
		icon_dead = "grueling_dead"
		base_melee_dam_up = 20				//base melee damage upper
		base_melee_dam_lw = 15				//base melee damage lower
		attacktext = "chomps"
		rescaleHealth(150)
		nutrienergy=0 //starts out hungry
		maxnutrienergy = 500
		moultcost = 100
		lightparams.lightresist=0.85
		environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_STRONG
		attack_sound = 'sound/weapons/cbar_hitbod1.ogg'
		size = SIZE_BIG
		pass_flags = 0
		reagents.maximum_volume = 1000
		//Juvenile grue spells: eat, moult, and shadow shunt
		add_spell(new /spell/aoe_turf/grue_moult, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/aoe_turf/grue_blink, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/targeted/grue_eat, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)

	else
		name = "grue"
		desc = "A dangerous thing that lives in the dark."
		icon_state = "grue_living"
		icon_living = "grue_living"
		icon_dead = "grue_dead"
		attacktext = "gnashes"
		rescaleHealth(250)
		maxnutrienergy = 1000
		moultcost=0 //not needed for adults
		base_melee_dam_up = 30				//base melee damage upper
		base_melee_dam_lw = 20				//base melee damage lower
		melee_damage_type = BRUTE
		held_items = list()
		lightparams.lightresist=0.7
		environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_STRONG
		attack_sound = 'sound/weapons/cbar_hitbod1.ogg'
		size = SIZE_BIG
		pass_flags = 0
		reagents.maximum_volume = 1500
		//Adult grue spells: eat, lay eggs, shadow shunt, and drain light
		if(config.grue_egglaying)
			add_spell(new /spell/aoe_turf/grue_egg, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/aoe_turf/grue_blink, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/aoe_turf/grue_drainlight/, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)
		add_spell(new /spell/targeted/grue_eat, "grue_spell_ready", /obj/abstract/screen/movable/spell_master/grue)

	name = "[name] ([number])"
	real_name = name
	grue_stat_updates()

//Grue vision
/mob/living/simple_animal/hostile/grue/update_perception()
	if(!client)
		return
	if(dark_plane)
		if(master_plane)
			master_plane.blend_mode = BLEND_ADD
		dark_plane.alphas["grue"] = 15 // with the master_plane at BLEND_ADD, shadows appear well lit while actually well lit places appear blinding.
		client.color = list(
				1,0,0,0,
				-1,0.2,0.2,0,
				-1,0.2,0.2,0,
				0,0,0,1,
				0,0,0,0)

	check_dark_vision()

/mob/living/simple_animal/hostile/grue/Stat()
	..()
	if(statpanel("Status"))
		if(ismoulting)
			stat(null, "Moulting progress: [round(100*(1-moulttimer/moulttime),0.1)]%")
		stat(null, "Nutritive energy: [round(nutrienergy,0.1)]/[round(maxnutrienergy,0.1)]")
		if(lifestage>=GRUE_JUVENILE)
			stat(null, "Sentient organisms eaten: [eatencount]")
		if(config.grue_egglaying && lifestage==GRUE_ADULT)
			stat(null, "Reproductive energy: [eatencharge]")

/mob/living/simple_animal/hostile/grue/gruespawn
	lifestage=GRUE_LARVA

/mob/living/simple_animal/hostile/grue/grueling
	lifestage=GRUE_JUVENILE

//Moulting into more mature forms.
/mob/living/simple_animal/hostile/grue/proc/moult()
	if(alert(src,"Would you like to moult? You will become a vulnerable and immobile chrysalis during the process.",,"Moult","Cancel") == "Moult")
		if(lifestage<GRUE_ADULT)
			if(nutrienergy<moultcost && (digest*digest_sp<(moultcost-nutrienergy)))
				to_chat(src, "<span class='notice'>You need to feed more first.</span>")
				return
			if(nutrienergy<moultcost && digest)
				to_chat(src, "<span class='notice'>You are still digesting.</span>")
				return
			else if(!isturf(loc))
				to_chat(src, "<span class='notice'>You need more room to moult.</span>")
				return
			else if(stat==UNCONSCIOUS)
				to_chat(src, "<span class='notice'>You must be awake to moult.</span>")
				return
			else if(busy)
				to_chat(src, "<span class='notice'>You are already doing something.</span>")
				return
			else
				start_moult()

		else
			to_chat(src, "<span class='notice'>You are already fully mature.</span>")
	else
		return

/mob/living/simple_animal/hostile/grue/proc/start_moult()
	if(stat==CONSCIOUS && nutrienergy>=moultcost && !ismoulting && lifestage<GRUE_ADULT)
		nutrienergy-=moultcost
		visible_message("<span class='warning'>\The [src] morphs into a chrysalis...</span>","<span class='notice'>You begin moulting.</span>")
		stat=UNCONSCIOUS //go unconscious while moulting
		ismoulting=TRUE
		moulttimer=moulttime//reset moulting timer
		plane = MOB_PLANE //In case grue somehow moulted while hiding
		if(lifestage==GRUE_LARVA)
			lifestage=GRUE_JUVENILE
			desc = "A small grue chrysalis."
			name = "grue chrysalis"
			icon_state = "moult1"
			icon_living = "moult1"
			icon_dead = "moult1"
			rescaleHealth(25) //vulnerable while moulting
		else if(lifestage==GRUE_JUVENILE)
			lifestage=GRUE_ADULT
			desc = "A grue chrysalis."
			name = "grue chrysalis"
			icon_state = "moult2"
			icon_living = "moult2"
			icon_dead = "moult2"
			rescaleHealth(50) //vulnerable while moulting
		//Remove spells to prepare for new lifestage spell list
		var/list/current_spells = src.spell_list.Copy()
		for(var/spell/S in current_spells)
			src.remove_spell(S)
	else
		return

/mob/living/simple_animal/hostile/grue/proc/complete_moult()
	if(ismoulting && stat!=DEAD)
		lifestage_updates()
		stat=CONSCIOUS //wake up
		ismoulting=FALSE //is no longer moulting
		var/hintstring=""
		if(lifestage==GRUE_JUVENILE)
			hintstring="a juvenile, and can eat sentient beings to gain their strength"
		else if(lifestage==GRUE_ADULT)
			hintstring="fully-grown[config.grue_egglaying ? ", and can lay eggs to spawn offspring" : ""]"
		visible_message("<span class='warning'>The chrysalis shifts and morphs into a grue!</span>","<span class='warning'>You finish moulting! You are now [hintstring].</span>")
		playsound(src, 'sound/effects/grue_moult.ogg', 50, 1)
	else
		return

/mob/living/simple_animal/hostile/grue/death(gibbed)
	if(!gibbed)
		playsound(src, 'sound/misc/grue_screech.ogg', 50, 1)
	if(ismoulting)
		desc="[desc] This one seems dead and lifeless."
	for(var/spell/aoe_turf/grue_drainlight/S in spell_list)
		S.stop_casting(null, src, TRUE)
	..()

//Reproduction via egglaying.
/mob/living/simple_animal/hostile/grue/proc/reproduce()

	if(lifestage==GRUE_ADULT) //must be adult
		if(eatencharge<=0)
			to_chat(src, "<span class='notice'>You need to feed more first.</span>")
			return
		else if(!isturf(loc))
			to_chat(src, "<span class='notice'>You need more room to reproduce.</span>")
			return
		else if(stat==UNCONSCIOUS)
			to_chat(src, "<span class='notice'>You must be awake to reproduce.</span>")
			return
		else if(busy)
			to_chat(src, "<span class='notice'>You are already doing something.</span>")
			return
		else
			handle_reproduce()

	else
		to_chat(src, "<span class='notice'>You haven't grown enough to reproduce yet.</span>")

/mob/living/simple_animal/hostile/grue/proc/handle_reproduce()

	if(eatencharge>=1)
		busy=TRUE
		visible_message("<span class='warning'>\The [src] tightens up...</span>","<span class='notice'>You start to push out an egg...</span>")
		if(do_after(src, src, 5 SECONDS))
			visible_message("<span class='warning'>\The [src] pushes out an egg!</span>","<span class='notice'>You lay an egg.</span>")
			eatencharge--
			var/mob/living/simple_animal/grue_egg/E = new /mob/living/simple_animal/grue_egg(get_turf(src))
			E.parent_grue=src //mark this grue as the parent of the egg
		busy=FALSE

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
	visible_message("<span class='danger'>\The [src] opens its mouth wide...</span>","<span class='danger'>You open your mouth wide, preparing to eat \the [E]!</span>")
	busy=TRUE
	if(do_mob(src , E, eattime, eattime, 0)) //check on every tick
		to_chat(src, "<span class='danger'>You have eaten \the [E]!</span>")
		to_chat(E, "<span class='danger'>You have been eaten by a grue.</span>")

		digest+=10 //add 10 life ticks (20 seconds) of increased healing + nutrition gain

		//Transfer any reagents inside the creature to the grue
		E.reagents.trans_to(src, E.reagents.total_volume)

		//Upgrade the grue's stats as it feeds
		if(E.mind) //eaten creature must have a mind to power up the grue
			playsound(src, 'sound/misc/grue_growl.ogg', 50, 1)
			eatencount++					//makes the grue stronger
			if(mind && mind.GetRole(GRUE)) //also increment the counter for objectives
				var/datum/role/grue/G = mind.GetRole(GRUE)
				if(G)
					G.eatencount++
			eatencharge++ //can be spent on egg laying
			grue_stat_updates(TRUE)
		else
			to_chat(src, "<span class='warning'>That creature didn't quite satisfy your hunger...</span>")
		E.death(1)
		E.drop_all()
		E.gib()
	busy=FALSE

/mob/living/simple_animal/hostile/grue/proc/grue_stat_updates(var/feed_verbose = FALSE) //update stats, called by lifestage_updates() as well as handle_feed()

	//health regen in darkness
	lightparams.regenbonus = lightparams.base_regenbonus * (1.5 ** eatencount) //increased health regen in darkness

	//melee damage, 50 damage limit
	melee_damage_lower = min(50, base_melee_dam_lw + (5 * eatencount))
	melee_damage_upper = min(50, base_melee_dam_up + (5 * eatencount))
	//How much armor they ignore on hit, +10% armor penetration for every target consumed up to 50% of armor ignored, meaning 80% damage reduction becomes 40%.
	armor_modifier = max(0.5, 1 - (0.1 * eatencount))

	//speed bonus in dark and dim conditions
	lightparams.speed_m_dark_dim_light[1]=max(1/2,lightparams.base_speed_m_dark_dim_light[1]/(1.2 ** eatencount))//faster in darkness
	lightparams.speed_m_dark_dim_light[2]=max(5/8,lightparams.base_speed_m_dark_dim_light[2]/(1.2 ** eatencount))//faster in dim light

	//update light drain power in case the grue fed while channeling it
	if(channeling_flags & GRUE_DRAINLIGHT)
		drainlight_set()

	if(lifestage==GRUE_ADULT)
		if(eatencount>=GRUE_WALLBREAK)
			environment_smash_flags |= SMASH_WALLS
		if(eatencount>=GRUE_RWALLBREAK)
			environment_smash_flags |= SMASH_RWALLS

	if(feed_verbose)
		var/wallhintstring="er"
		if(lifestage==GRUE_ADULT) //juveniles that feed up to at least GRUE_WALLBREAK will still gain the ability to smash walls once they moult into adults, but they wont get the hint message
			if(eatencount==GRUE_WALLBREAK)
				wallhintstring=" enough to smash down most walls"
			if(eatencount==GRUE_RWALLBREAK)
				wallhintstring=" enough to smash down even reinforced walls"
		to_chat(src, "<span class='warning'>You feel power coursing through you! You feel strong[wallhintstring]... but still hungry...</span>")

	if(lifestage==GRUE_JUVENILE)
		force_airlock_time=30 * (eatencount==0) //takes 3 seconds if they haven't eaten, but is instant if they have
	else
		force_airlock_time=0

	//shadow shunt cooldown
	for(var/spell/aoe_turf/grue_blink/thisspell in spell_list)
		var/newcooldown = max(45 SECONDS - eatencount * 2 SECONDS, 8 SECONDS)
		thisspell.charge_max = newcooldown
		thisspell.charge_counter = min(newcooldown, thisspell.charge_counter)

//Drain the light from the surrounding area.

/mob/living/simple_animal/hostile/grue/proc/drainlight(var/activating = TRUE, var/mute = FALSE)
	if(activating)
		if(nutrienergy)
			channeling_flags |= GRUE_DRAINLIGHT
			drainlight_set()
			if(!mute)
				to_chat(src, "<span class='notice'>You focus on draining the light from the surrounding space.</span>")
			return TRUE
		else
			if(!mute)
				to_chat(src, "<span class='notice'>You need to feed more first.</span>")
	else
		channeling_flags &= !GRUE_DRAINLIGHT
		set_light(0)
		if(nutrienergy)
			if(!mute)
				to_chat(src, "<span class='notice'>You stop draining light.</span>")
		else
			if(!mute)
				to_chat(src, "<span class='warning'>You are too hungry to keep draining light...")
	return FALSE

/mob/living/simple_animal/hostile/grue/proc/drainlight_set()	//Set the strength of light drain.
	set_light(max(10, 7 + eatencount), max(-15, -3 * eatencount - 3), GRUE_BLOOD)	//Eating sentients makes the drain more powerful.

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

		if(locked_to && istype(locked_to, /obj/item/critter_cage))
			return

		if(plane != HIDING_MOB_PLANE)
			plane = HIDING_MOB_PLANE
			to_chat(src, "<span class='notice'>You are now hiding.</span>")
		else
			plane = MOB_PLANE
			to_chat(src, "<span class='notice'>You have stopped hiding.</span>")
	else
		to_chat(src, "<span class='notice'>You are too big to do that.</span>")

//Shadow shunt, blinks to another nearby dark location.
/mob/living/simple_animal/hostile/grue/proc/grueblink()
	var/list/blinkcandidates = list()
	//get all sufficiently dark spots in range
	finding_blink_spots:
		for(var/turf/thisfloor in orange(25))
			if(thisfloor.density)
				continue
			if(get_ddl(thisfloor) > GRUE_DARK)
				continue
			for(var/atom/thiscontent in thisfloor.contents)
				if(thiscontent.density)
					continue finding_blink_spots
				if(ismob(thiscontent))
					continue finding_blink_spots
				if(istable(thiscontent))
					continue finding_blink_spots
			blinkcandidates += thisfloor
	if(blinkcandidates.len)
		//check up to 50 random valid locations and pick the furthest one
		var/turf/blinktarget
		var/btdist = -1
		var/oxy_lower_bound = min_oxy / CELL_VOLUME
		for(var/bc_index in 1 to min(blinkcandidates.len, 50))
			var/random_bc_index = rand(1, blinkcandidates.len)
			var/turf/random_bc = blinkcandidates[random_bc_index]
			var/thisdist = get_dist(random_bc, src)
			//weight away from low oxygen spots
			var/o2content = random_bc.air ? random_bc.air.molar_density(GAS_OXYGEN): 0
			if(o2content < oxy_lower_bound)
				thisdist *= o2content
			else
				thisdist *= oxy_lower_bound
			if(thisdist > btdist)
				btdist = thisdist
				blinktarget = random_bc
		playsound(src, 'sound/effects/grue_shadowshunt.ogg', 20, 1)
		playsound(blinktarget, 'sound/effects/grue_shadowshunt.ogg', 20, 1)
		to_chat(src, "<span class='notice'>You [pick("shift", "step", "slide", "glide", "push")] [pick("comfortably", "easily", "effortlessly", "readily", "gracefully")] through the [pick("darkness", "dark", "shadows", "shade", "blackness")].</span>")
		new /obj/effect/gruesparkles (loc)
		forceMove(blinktarget)
		new /obj/effect/gruesparkles (loc)
		return TRUE
	else
		to_chat(src, "<span class='warning'>You reach into the darkness, but can't seem to find a way.</span>")
		//set the remaining cooldown to one second if no valid location was found
		for(var/spell/aoe_turf/grue_blink/thisspell in spell_list)
			thisspell.charge_counter = thisspell.charge_max - 1 SECONDS
		return

// Dark sparkles when a grue uses shadow shunt.
/obj/effect/gruesparkles
	name = "dark glimmers"
	icon_state = "gruesparkles"
	anchored = 1

/obj/effect/gruesparkles/New()
	..()
	spawn(1.5 SECONDS)
		fade()

/obj/effect/gruesparkles/proc/fade()
	if(!src)
		return
	if(alpha <= 0)
		qdel(src)
		return
	spawn(0.5 SECONDS)
		alpha -= 55
		fade()
