/spell/aoe_turf/conjure/pitbull
	name = "Summon Pitbulls"
	desc = "This spell summons a group of misunderstood pitbulls."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	summon_type = list(/mob/living/simple_animal/hostile/pitbull)
	summon_amt = 3

	price = Sp_BASE_PRICE / 2
	level_max = list(Sp_TOTAL = 2, Sp_SPEED = 2)
	charge_max = 300
	cooldown_reduc = 100
	cooldown_min = 100
	invocation = "GR'T W'TH K'DS"
	invocation_type = SpI_SHOUT
	spell_flags = NEEDSCLOTHES
	override_icon = 'icons/mob/animal.dmi'
	hud_state = "pitbull"  //TODO


var/list/pitbulls_count_by_wizards = list()
var/list/pitbulls = list()
#define MAX_PITBULLS 15

/spell/aoe_turf/conjure/pitbull/cast_check(skipcharge = 0,mob/user = usr)
	if (pitbulls_count_by_wizards[user] > MAX_PITBULLS) // We summoned too many pitbulls :(
		to_chat(user, "<span class = 'warning'>We've brought forth too many innocent pitbulls into this plane.</span>")
		return FALSE
	return ..()


/obj/testing

/obj/testing/New()
	to_chat(world,"<span class = 'warning'>number of pitbulls[pitbulls_count_by_wizards]</span>")

/spell/aoe_turf/conjure/pitbull/summon_object(var/type, var/location)
	..()
	pitbulls_count_by_wizards[holder]++


/spell/aoe_turf/conjure/pitbull/choose_targets(var/mob/user = usr)

	var/list/turf/locs = new

	for(var/direction in alldirs) //looking for pitbull spawns
		if(locs.len >= 3) //we found 3 locations and thats all we need
			break
		var/turf/T = get_step(user, direction) //getting a loc in that direction
		if(AStar(user.loc, T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 1)) // if a path exists, so no dense objects in the way its valid salid
			locs += T
		else

	if(locs.len < 3) //if we only found one location, spawn more on top of our tile so we dont get stacked pitbulls
		locs += user.loc

	return locs

/spell/aoe_turf/conjure/pitbull/before_cast(list/targets, user)
	return targets