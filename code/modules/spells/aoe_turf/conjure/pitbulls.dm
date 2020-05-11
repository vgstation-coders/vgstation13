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
	hud_state = null // handled via connected_button.overlays to prevent visual glitching on skin change
	cast_sound = 'sound/voice/pitbullbark.ogg'
	var/icon_index = 1
	var/static/list/icon_suffixes = list("", "-old")
	var/static/list/icon_change_messages = list(
		"You alter the spell to summon a man's best friend.",
		"You alter the spell to rouse sleeping dogs."	)
	var/image/current_image

/spell/aoe_turf/conjure/pitbull/on_added(mob/user)
	current_image = image('icons/mob/animal.dmi', "pitbull", layer = HUD_ITEM_LAYER)
	connected_button.overlays += current_image

var/list/pitbulls_exclude_kinlist = list() //all pitbulls go in here so pitbulls won't attack other pitbulls when feeling treacherous (and instead attack the wizard)

/spell/aoe_turf/conjure/pitbull/summon_object(var/type, var/location)
	var/mob/living/simple_animal/hostile/pitbull/summoned_pitbull/P = new type(location)
	P.friends.Add(holder)//summoner is my friend, but we have a tendency to turn on our friends
	P.icon_state = P.icon_state + icon_suffixes[icon_index]
	P.icon_living = P.icon_living + icon_suffixes[icon_index]
	P.icon_dead = P.icon_dead + icon_suffixes[icon_index]

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

/spell/aoe_turf/conjure/pitbull/before_cast(list/targets, user)
	return targets

/spell/aoe_turf/conjure/pitbull/on_right_click(mob/user)
	connected_button.overlays -= current_image
	icon_index = icon_index % icon_suffixes.len + 1
	current_image = image('icons/mob/animal.dmi', "pitbull" + icon_suffixes[icon_index], layer = HUD_ITEM_LAYER)
	connected_button.overlays += current_image
	to_chat(user, icon_change_messages[icon_index])
	return 1