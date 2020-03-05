/spell/aoe_turf/conjure/pitbull
	name = "Summon Pitbulls"
	desc = "This spell summons a group of misunderstood pitbulls. You can maintain up to 60 living pitbulls at a time."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	summon_type = list(/mob/living/simple_animal/hostile/pitbull/summoned_pitbull)
	summon_amt = 3

	price = Sp_BASE_PRICE
	level_max = list(Sp_TOTAL = 2, Sp_SPEED = 2)
	charge_max = 300
	cooldown_reduc = 100
	cooldown_min = 100
	invocation = "GR'T W'TH K'DS"
	invocation_type = SpI_SHOUT
	spell_flags = NEEDSCLOTHES
	override_icon = 'icons/mob/animal.dmi'
	hud_state = "pitbull"
	cast_sound = 'sound/voice/pitbullbark.ogg'

	var/summon_from_existing = FALSE
	var/mob/living/simple_animal/hostile/pitbull/yoinked

var/list/pitbull_refs_per_wizard = list() //for testings
var/list/wizards_pitbulls = list()

var/list/pitbulls_count_by_wizard = list()
#define MAX_PITBULLS 3//testing, revert to 30

/spell/aoe_turf/conjure/pitbull/cast_check(skipcharge = 0,mob/user = usr)
	summon_from_existing = FALSE //I'm a fucking genius
	if (pitbulls_count_by_wizard[user] > MAX_PITBULLS) // We summoned too many pitbulls. I'm just copying this over from doppelganger code.
	//	to_chat(user, "<span class = 'warning'>We've brought forth too many innocent pitbulls into this plane.</span>")
	//	return FALSE
		//instead of cockblocking the caster we'll pull from his list of 60 pitbulls and yoink some here
		summon_from_existing = TRUE
		to_chat(user, "<span class = 'warning'>Being that there are too many pitbulls currently materialized, You call forth some of your already summoned pitbulls</span>")
	return ..()

/spell/aoe_turf/conjure/pitbull/summon_object(var/type, var/location)
	if(summon_from_existing)
		//for values in user.summons check for pitbulls. if found then break, yoink, and move them to back of the list. this gets done amt times per cast
		/*iffor (/mob/living/simple_animal/hostile/pitbull in summons)
			  //ispitbull
				summons += summons[1]  //summons[i]
				summons.Cut(1,2)   // cut(i,i+1)
				break
		*/
		//pick(/mob/living/simple_animal/hostile/pitbull in usr.mind.summons).forceMove(location)
		yoinked = pick(/mob/living/simple_animal/hostile/pitbull in usr.mind.summons)
		yoinked.forceMove(location) //

		//var/yoinked = (usr.mind.summons)//TODO  3/2/20  realestestate - change it to take the first value in the summons list, then move it to the back and move all other values up.

		//summons += summons[1]
	//	summons.Cut(1,2)


		//yoinked.forceMove(location)

	else
		var/mob/living/simple_animal/hostile/pitbull/summoned_pitbull/P = new type(location)
		P.friends.Add(holder)//summoner is my friend, but we have a tendency to turn on our friends
		pitbulls_count_by_wizard[holder]++
		usr.mind.summons.Add(P) //add

/spell/aoe_turf/conjure/pitbull/choose_targets(var/mob/user = usr)
	var/list/turf/locs = new

	for(var/direction in alldirs) //looking for pitbull spawns
		if(locs.len >= 3) //we found 3 locations and thats all we need
			break
		var/turf/T = get_step(user, direction) //getting a loc in that direction
		if(AStar(user.loc, T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 1)) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	if(locs.len < 3) //if we only found one location, spawn more on top of our tile so we dont get stacked pitbulls
		locs += user.loc
	return locs

/spell/aoe_turf/conjure/pitbull/before_cast(list/targets, user)
	return targets
