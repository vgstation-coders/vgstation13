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
	attacktext = list("gnashes","slashes")
	attack_sound = 'sound/weapons/cbar_hitbod1.ogg'
	speed = 1
	can_butcher = FALSE
//	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/grue
	held_items = list()

	//VARS
	var/shadowpower = 0											 //shadow power absorbed
	var/maxshadowpower = 1000									   //max shadowpower
	var/moultcost = -1 											//shadow power needed to moult into next stage (irrelevant for adults)

	var/current_brightness = 0									   //light level of current tile, range from 0 to 10
	var/bright_limit_health_gain = 1									//maximum brightness on tile for health regen
	var/bright_limit_health_drain = 3								   //maximum brightness on tile to not drain health
	var/bright_limit_power_gain	= 1								 //maximum brightness on tile to absorb shadow power
	var/bright_limit_power_drain = 11									//maximum brightness on tile to not drain shadow power (11=disabled)

	var/pg_mult = 3										 //multiplier for power gained per tick when in dark tile
	var/pd_mult = 1									  //multiplier for shadow power drained per tick on bright tile
	var/hg_mult = 2										//multiplier for health gained per tick when on dark tile
	var/hd_mult = 3									 //multiplier for health drained per tick on bright tile
	var/show_desc = FALSE										   //For the ability menu

	var/lifestage=3												 //1=baby grue, 2=grueling, 3=(mature) grue
	var/eatencount=0												//number of sentient carbons eaten, makes the grue more powerful
	var/dark_dim_light=0 //darkness level currently the grue is currently exposed to, 0=nice and dark, 1=passably dim, 2=too bright


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
		if(current_brightness<=bright_limit_health_gain)
			dark_dim_light=0
			health = min(maxHealth,health+hg_mult*(bright_limit_health_gain-current_brightness))					 //heal in dark
		else if(current_brightness>bright_limit_health_drain) 														//lose health in light
			dark_dim_light=2
			to_chat(src, "<span class='warning'>The bright light scalds you!</span>")
			playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
			health -= hd_mult*(current_brightness-bright_limit_health_drain)
		else
			dark_dim_light=1
		if(current_brightness<=bright_limit_power_gain)
			shadowpower = min(maxshadowpower,shadowpower+pg_mult*(bright_limit_power_gain-current_brightness))	   //gain power in dark
		else if(current_brightness>bright_limit_power_drain)
			shadowpower = max(0,shadowpower-pd_mult*(current_brightness-bright_limit_power_drain))				  //drain power in light

	regular_hud_updates()
	//standard_damage_overlay_updates()

//Cast darkness onto a tile that gradually dissipates
/mob/living/simple_animal/hostile/grue/proc/nullify_light()
	set name = "Nullify light"
	set desc = "Darken the surrounding space."
	set category = "Grue"
	var/turf/T = get_turf(src)
	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot do that while unconscious.</span>")
		return

	if(stat)
		to_chat(src, "You cannot do that in your current state.")
		return

	to_chat(src,"<span class='notice'>You darken the area.</span>")
	playsound(T, 'sound/effects/nulllight.ogg', 50, 1)
//	var/obj/item/weapon/reagent_containers/food/snacks/grue_antilight/E = new (T) //create invisible object that emits darkness


//todo:
//damage via damage proc instead of directly?
//evolve logic?
//egg/chrysalis with natural armor? harmed by light or can only hatch in the light?
//health-scaling light damage calculation?
//pulling/holding?
//force open doors
//stop burning after death
//change burning sound
//consume darkpower to block light?
//get ventcrawl to work
//revoke ventcrawl on higher life stages and try to remove icon?
//UI
//nightvision
//dark field?
//animations
//ability to destroy desk lamps etc?
//melee abilities change with life stage
//lay eggs
//sound effects for egglaying, evolving, etc
//grue goo, blood, gibs, moulting goo, egg casing, meat, etc. (including effects)
//remove size descriptor
//darkpower indicator?
//eatencount indicator?

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

/mob/living/simple_animal/hostile/grue/verb/moult() //moult into next life stage
	set name = "Moult"
	set desc = "Moult into a new form."
	set category = "Grue"
	if (lifestage<3)
		if (shadowpower<moultcost)
			return
		else
			shadowpower-=moultcost
			lifestage++
			to_chat(src, "<span class='notice'>You moult into a new form!</span>")
			var/tempHealth=health/maxHealth //to scale health level
			if (lifestage==2)
				desc = "A creeping thing that lives in the dark. It is still a juvenile."
				name = "grueling"
				icon_state = "grueling_living"
				icon_living = "grueling_living"
				icon_dead = "grueling_dead"
				maxHealth=100
				moultcost=500
			else if(lifestage==3)
				desc = "A dangerous thing that lives in the dark."
				name = "grue"
				icon_state = "grue_living"
				icon_living = "grue_living"
				icon_dead = "grue_dead"
				maxHealth=200
				moultcost=-1
			health=maxHealth*tempHealth //keep same health percentage post-evolution
	else
		to_chat(src, "<span class='notice'>You are already fully mature.</span>")



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

	if (locked_to && istype(locked_to, /obj/item/critter_cage))
		return

	if (plane != HIDING_MOB_PLANE)
		plane = HIDING_MOB_PLANE
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		plane = MOB_PLANE
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

