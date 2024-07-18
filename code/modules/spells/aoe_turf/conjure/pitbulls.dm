/spell/aoe_turf/conjure/pitbull
	name = "Summon Pitbulls"
	desc = "This spell summons a group of misunderstood pitbulls. You can maintain up to 60 living pitbulls at a time. They won't attack wizards or apprentices, in general."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	summon_type = list(/mob/living/simple_animal/hostile/pitbull/summoned_pitbull)
	summon_amt = 3

	price = Sp_BASE_PRICE
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 2, Sp_POWER = 1) //empower makes them SMASHED and SLAMMED
	charge_max = 300
	cooldown_reduc = 100
	cooldown_min = 100
	invocation = "GR'T W'TH K'DS"
	invocation_type = SpI_SHOUT
	spell_flags = NEEDSCLOTHES
	hud_state = "pitbull"
	cast_sound = 'sound/voice/pitbullbark.ogg'
	quicken_price = Sp_BASE_PRICE
	var/empowered

/spell/aoe_turf/conjure/pitbull/empower_spell()
	..()
	empowered += 1
	spell_levels[Sp_POWER]++
	. = "You have perfected the SMASHED and SLAMMED summon."

/spell/aoe_turf/conjure/pitbull/invocation(mob/user, list/targets)
	if(empowered)
		invocation = pick("P'MPY S'N 'PP", "P'MPY S'N 'PP", "R'V'R'D' K'NN'LS", "BL'DSK'LL") 
	..()

var/list/pitbulls_exclude_kinlist = list() //all pitbulls go in here so pitbulls won't attack other pitbulls when feeling treacherous (and instead attack the wizard)

/spell/aoe_turf/conjure/pitbull/perform()
	if(empowered)
		summon_type = list(/mob/living/simple_animal/hostile/pitbull/smashednslammed/summoned_pitbull)
	..()

/spell/aoe_turf/conjure/pitbull/summon_object(var/type, var/location)
	if(empowered)
		var/mob/living/simple_animal/hostile/pitbull/smashednslammed/summoned_pitbull/P = new type(location)
		P.friends.Add(holder)
	else
		var/mob/living/simple_animal/hostile/pitbull/summoned_pitbull/P = new type(location)
		P.friends.Add(holder)//summoner is my friend, but we have a tendency to turn on our friends

/spell/aoe_turf/conjure/pitbull/choose_targets(var/mob/user = usr)
	var/list/turf/locs = new
	for(var/direction in alldirs) //looking for pitbull spawns
		if(locs.len >= 3) //we found 3 locations and thats all we need
			break
		var/turf/T = get_step(user, direction) //getting a loc in that direction
		if(quick_AStar(get_turf(user), T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 1, reference="\ref[src]")) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	if(locs.len < 3) //if we only found one location, spawn more on top of our tile so we dont get stacked pitbulls
		locs += user.loc
	return locs

/spell/aoe_turf/conjure/pitbull/before_cast(list/targets, user, bypass_range = 0)
	return targets
