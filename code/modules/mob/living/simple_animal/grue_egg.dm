/mob/living/simple_animal/grue_egg
//	var/isgrue=1
	name = "grue egg"
	size = SIZE_SMALL
	desc = "An egg laid by a grue. An embyro hasn't developed yet."
	icon = 'icons/mob/grue.dmi'
	icon_state = "egg_new"
	icon_living= "egg_new"
	icon_dead= "egg_dead"
	maxHealth=25
	health=25
	faction = "grue" //Keep grues and grue eggs friendly to each other.

	//keep it immobile
	stop_automated_movement = 1
	wander = 0
	canmove=0

	//allow other mobs to walk onto the same tile
	density = 0
	plane=LYING_MOB_PLANE


	var/mob/living/simple_animal/parent_grue														//which grue laid this egg, if any
	var/bright_limit_gain = 1											//maximum brightness on tile for health regen
	var/bright_limit_drain = 3											//maximum brightness on tile to not drain health
	var/hg_mult = 2										//multiplier for health gained per tick when on dark tile
	var/hd_mult = 3									 //multiplier for health drained per tick on bright tile
	var/current_brightness=0

	var/grown = 0
	var/hatching = 0 // So we don't spam ghosts.
	var/datum/recruiter/recruiter = null
	var/child_prefix_index = 1
	var/last_ping_time = 0
	var/ping_cooldown = 50

/mob/living/simple_animal/grue_egg/Life()
	..()
	//process health according to current tile brightness level (as with hatched grues)
	if (stat!=DEAD)
		if(isturf(loc))
			var/turf/T = loc
			current_brightness=10*T.get_lumcount()
		else												//else, there's considered to be no light
			current_brightness=0
		if(current_brightness<=bright_limit_gain)
			apply_damage(-1*hg_mult*(bright_limit_gain-current_brightness),BURN) //boost juveniles and adults heal rates a bit
		else if(current_brightness>bright_limit_drain) 														//lose health in light
			playsound(src, 'sound/effects/grue_burn.ogg', 50, 1)
			apply_damage(hd_mult*(current_brightness-bright_limit_drain),BURN)								//scale light damage a bit to avoid juveniles and adults from becoming too tanky to light
		if(grown)
			src.Hatch()

/mob/living/simple_animal/grue_egg/death()
	name = "grue egg remnants"
	desc = "The remnants of a grue egg."
	gender = "plural"
	qdel(recruiter)
	recruiter = null
	..()

// Amount of time between retries for recruits. As to not spam ghosts every minute.
#define GRUE_EGG_RERECRUIT_DELAY 5.0 MINUTES

/mob/living/simple_animal/grue_egg/New()
	..()
	last_ping_time = world.time
	spawn(rand(300,450))//the egg takes a while to be ready to hatch
		Grow()

/mob/living/simple_animal/grue_egg/proc/Grow()
	if(stat==DEAD)
		return
	grown = 1
	icon_state = "egg_living"
	icon_living= "egg_living"
	desc = "An egg laid by a grue. An embryo floats inside."

	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = "grue"
		recruiter.role = ROLE_GRUE
//		recruiter.jobban_roles = list("pAI")

		// A player has their role set to Yes or Always
		recruiter.player_volunteering = new /callback(src, .proc/recruiter_recruiting)
		// ", but No or Never
		recruiter.player_not_volunteering = new /callback(src, .proc/recruiter_not_recruiting)

		recruiter.recruited = new /callback(src, .proc/recruiter_recruited)

/mob/living/simple_animal/grue_egg/proc/Hatch()
	if(hatching)
		return
	if(stat==DEAD)
		return
//	icon_state="egg_triggered"
	hatching=1
	recruiter.request_player()

/mob/living/simple_animal/grue_egg/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\The [src] is starting to hatch. You have been added to the list of potential ghosts. ([controls])</span>")

/mob/living/simple_animal/grue_egg/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\The [src] is starting to hatch. ([controls])</span>")

/mob/living/simple_animal/grue_egg/proc/recruiter_recruited(mob/dead/observer/player)
	if(player)
		src.visible_message("<span class='notice'>\The [name] bursts open!</span>")

		if(parent_grue) //if the egg hatches successfully, increment the objective spawncount of the parent grue
			if(parent_grue.mind && parent_grue.mind.GetRole(GRUE))
				var/datum/role/grue/G1 = parent_grue.mind.GetRole(GRUE)
				if(G1)
					G1.spawncount++

		var/mob/living/simple_animal/hostile/grue/gruespawn/G = new(get_turf(src))
		G.hatched = 1 //this grue hatched from an egg
		G.transfer_personality(player.client)
		// Play hatching noise here.
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		src.death()
	else
		hatching = 0
		spawn (GRUE_EGG_RERECRUIT_DELAY)
			Grow() // Reset egg, check for hatchability.

#undef GRUE_EGG_RERECRUIT_DELAY