/mob/living/simple_animal/hostile/grue
	name = "grue"
	desc = "A dangerous thing that lives in the dark."
	icon = 'icons/mob/grue.dmi'
	icon_state = "grue_living"
	icon_living = "grue_living"
	icon_dead = "grue_dead"
	maxHealth = 200											 	//max health
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	melee_damage_type = BRUTE
	response_help  = "touches"
	response_disarm = "pushes"
	response_harm   = "punches"
//	attacktext = pick("gnashes","slashes")
	attacktext = "tears at"
	attack_sound = 'sound/weapons/cbar_hitbod1.ogg'
	speed = 1
	can_butcher = FALSE
//	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/grue
	held_items = list()
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG

	//eyesight related stuff
	see_in_dark = 8






	//VARS
	var/shadowpower = 0											 //shadow power absorbed
	var/maxshadowpower = 1000									   //max shadowpower
	var/moultcost = -1 											//shadow power needed to moult into next stage (irrelevant for adults)
	var/ismoulting = 0, //currently moulting (1=is a pupa)
	var/moulttime = 60 //time required to moult to a new form
	var/moulttimer = 100 //moulting timer
//	var/reproduce_juice=0 //used to reproduce, charged like eatencount, but only spent on reproducing
//	var/reproducecost=1

	var/current_brightness = 0									   //light level of current tile, range from 0 to 10
//	var/bright_limit_health_gain = 1									//maximum brightness on tile for health regen
//	var/bright_limit_health_drain = 3								   //maximum brightness on tile to not drain health
//	var/bright_limit_power_gain	= 1								 //maximum brightness on tile to absorb shadow power
//	var/bright_limit_power_drain = 11									//maximum brightness on tile to not drain shadow power (11=disabled)
	var/bright_limit_gain = 1											//maximum brightness on tile for health and power regen
	var/bright_limit_drain = 3											//maximum brightness on tile to not drain health and power


	var/pg_mult = 3										 //multiplier for power gained per tick when in dark tile
	var/pd_mult = 0									  //multiplier for shadow power drained per tick on bright tile (0=disabled)
	var/hg_mult = 2										//multiplier for health gained per tick when on dark tile
	var/hd_mult = 3									 //multiplier for health drained per tick on bright tile
	var/show_desc = TRUE										   //For the ability menu

	var/lifestage=3												 //1=baby grue, 2=grueling, 3=(mature) grue
	var/eatencount=0												//number of sentient carbons eaten, makes the grue more powerful
	var/eatencharge=1												//power charged by eating sentient carbons, increments with eatencount but is spent on upgrades
	var/dark_dim_light=0 //darkness level currently the grue is currently exposed to, 0=nice and dark, 1=passably dim, 2=too bright
	var/busy=0 //busy laying an egg

/mob/living/simple_animal/hostile/grue/regular_hud_updates()
	..()
	if(client && hud_used)
//		if(!hud_used.vampire_blood_display)
		hud_used.grue_hud()
//		hud_used.vampire_blood_display.maptext_width = WORLD_ICON_SIZE
//		hud_used.vampire_blood_display.maptext_height = WORLD_ICON_SIZE
//		hud_used.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:2px'>C:<br><font color='#FFFF00'>[shadowpower]</font></div>"


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
        //if (darkdimlight==0)




/mob/living/simple_animal/hostile/grue/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()

	//process shadow power and health according to current tile brightness level
	if (stat!=DEAD)
		if(isturf(loc))
			var/turf/T = loc
			current_brightness=10*T.get_lumcount()
		else												//else, there's considered to be no light
			current_brightness=0;
		visible_message("<span class='warning'>\The [src] is in brightness level [current_brightness] with [health] health and [shadowpower] shadowpower.</span>") //debug
		if(current_brightness<=bright_limit_gain&&!ismoulting)
			dark_dim_light=0
			health = min(maxHealth,health+hg_mult*(bright_limit_gain-current_brightness))					 //heal in dark
		else if(current_brightness>bright_limit_drain) 														//lose health in light
			dark_dim_light=2
			to_chat(src, "<span class='warning'>The bright light scalds you!</span>")
			playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
			health -= hd_mult*(current_brightness-bright_limit_drain)
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
	//standard_damage_overlay_updates()



/mob/living/simple_animal/hostile/grue/Stat()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")
	..()
	if(statpanel("Status"))
		stat(null, "Shadow Power: [shadowpower]/[maxshadowpower]")
		if (lifestage>=3)
			stat(null,"Death Essence: [eatencharge]")
			stat(null, "Sentient Life Forms Eaten: [eatencount]")











/mob/living/simple_animal/hostile/grue/proc/eat_creature()//eat a creature and absorb essence if its sapient
//todo
	return


//todo:
//light damage via damage proc instead of directly?
//resistant to other types of damage

//pulling/holding?

//change burning sound

//smash machiney monitors and such?

//animations
//melee abilities and strength change with life stage
//speed up death by light is proc necessary?

//egg sensitivity to light (should egg be mob?)
//egg hatch sprite
//egg killed by light sprite/deal with all that
//chg+add sound effects for egglaying, evolving, etc
//grue goo, blood, gibs, moulting goo, egg casing, meat, etc. (including effects)
//remove size descriptor
//darkpower indicator?
//eatencount indicator?
//generalize power, powers costs, costs, power menu

//chat messages for moulting and such
//avoid being able to hit self?
//take longer to smash open reinforced tables and stuff
//basic AI to avoid light and smash things and moult
//tweak values (moult cost, moultt time, health stuff, shadowpower stuff)
//revert eatencharge to 0
//add antag role code ROLE_GRUE
//flesh out everything in setup.dm ala borers (but antag)
//spawns only in dark/maintenance?
//eating sentients by gibbing their corpse and absorbing power
//relevant upgrades from absorbing power
//add powers obtained by eating sentients
//sprite additions while powering up
//fix or remove hiding code (can't go under tables like a mouse)
//faction grues to avoid them killing each other etc?
//message of egglaying etc only visible to others, not self?
//eggs layable indicator
//instructive messages about being a grue, and also the life stages, or maybe a menu

//toggle light verb (does this work on light switches?)
//or should not be able to push buttons
//ability to smash stuff away like flares (kick code?/harm intent?)
//greyscale filter or color effects or something?
//infrared/night-vision
//rename death essence?


//add body part targeting etc for more focused attacks, and relevant text
//add harm intents and such?
//message to target when eaten "You have been eaten by a grue."
//speaking/only being able to speak to other grues
//dont have grueling/gruespawn names visible (just "grue")?
//moulting progress bar, etc warning about vulnerability
//blind messages while moulting

//invis in full dark?
//jumpscare and other sound effects
//sprites for dead pupa (need blood color)?
//cant or can be pulled while moulting
//unconscious while moulting/reduce view while moulting

//ability UI+mirrored with panel like pulsedemon
//ui button to eat someone

//render abilities invisible with life stage?
//special names only visible for grues (and grue language)
//rearrange code block
//remove comments



//[TEST] egg recruit ala borer

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
//[OBS]dark field?
//[OBS]consume darkpower to block light?
//[OBS]health-scaling light damage calculation?
//[OBS]egg/chrysalis with natural armor? harmed by light or can only hatch in the dark?
//[OBS]need to breathe or no?
//[OBS]ability to destroy or eat objects? and it goes into the stomach,desk lamps etc?
//[OBS]multiple attack verbs/pick?

//[NEED FEEDBACK]able to push other mobs aside?
//[NEED FEEDBACK]ability to pick up grue eggs. leaving behind casing/skin on the floor (or not)
//[NEED FEEDBACK]turn off lamps etc?
//[NEED FEEDBACK]can activate certain things like morgue tray and push light buttons
//[NEED FEEDBACK]generalize door forcing code
//[NEED FEEDBACK]change to timer for pulling open door

/mob/living/simple_animal/hostile/grue/gruespawn
	name = "gruespawn"
	desc = "A scurrying thing that lives in the dark. It is still a larva."
	icon_state = "gruespawn_living"
	icon_living = "gruespawn_living"
	icon_dead = "gruespawn_dead"
	maxHealth=50
	moultcost=100
	health = 50
	lifestage=1
	environment_smash_flags = 0

/mob/living/simple_animal/hostile/grue/grueling
	name = "grueling"
	desc = "A creeping thing that lives in the dark. It is still a juvenile."
	icon_state = "grueling_living"
	icon_living = "grueling_living"
	icon_dead = "grueling_dead"
	maxHealth=100
	moultcost=500
	health = 100
	lifestage=2
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK










//Moulting into more mature forms.
/mob/living/simple_animal/hostile/grue/verb/moult()
	set name = "Moult"
	set desc = "Moult into a new form."
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
			plane = MOB_PLANE //in case gruespawn evolved while hiding
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
			environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK
		else if(lifestage==3)
			desc = "A dangerous thing that lives in the dark."
			name = "grue"
			icon_state = "grue_living"
			icon_living = "grue_living"
			icon_dead = "grue_dead"
			maxHealth=200
			moultcost=-1 //not needed for adults
			environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG
		health=maxHealth*tempHealth //keep same health percent
		stat=CONSCIOUS //wake up
		ismoulting=0 //is no longer moulting
	else
		return









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


			var/obj/structure/grue_egg/E = new (T)
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
			to_chat(src, "<span class='notice'>You need more room to feed.</span>")
			return
		else if (stat==UNCONSCIOUS)
			to_chat(src, "<span class='notice'>You must be awake to feed.</span>")
			return
		else if (busy)
			to_chat(src, "<span class='notice'>You are already doing something.</span>")
			return
		else
			handle_feed()
	else
		to_chat(src, "<span class='notice'>You haven't grown enough to do that yet.</span>")


//todo: /mob/living/simple_animal/hostile/grue/verb/eat_sentient()





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




//copy paste from alien/larva, if that func is updated please update this one also
//only for gruespawn

/mob/living/simple_animal/hostile/grue/gruespawn/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)


//copy paste from alien/larva, if that func is updated please update this one also
//only for gruespawn
/mob/living/simple_animal/hostile/grue/gruespawn/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Object"

	if(isUnconscious())
		return
	if(lifestage>1)
		to_chat(src, text("<span class='notice'>You are too big to hide.</span>"))
		return

	if (locked_to && istype(locked_to, /obj/item/critter_cage))
		return

	if (plane != HIDING_MOB_PLANE)
		plane = HIDING_MOB_PLANE
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		plane = MOB_PLANE
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

