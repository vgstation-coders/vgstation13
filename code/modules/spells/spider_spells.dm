
///////////////////////////////////SPIDERLING///////////////////////////////////////

/spell/spiderling_evolution
	name = "Evolve"
	desc = "Choose which type of adult spider to grow up into."
	user_type = USER_TYPE_SPIDER
	hud_state = "spiderling_evolution"
	override_base = "spider"
	charge_max = 0
	spell_flags = 0
	range = 0

/spell/spiderling_evolution/choose_targets(var/mob/user = usr)
	return list(user)

/spell/spiderling_evolution/cast(var/list/targets, var/mob/user)
	var/mob/living/simple_animal/hostile/giant_spider/spiderling/spiderling = user
	spiderling.manual_evolution()

/////////////////////////////////////NURSE//////////////////////////////////////////

/spell/aoe_turf/conjure/web
	name = "Spin Web"
	desc = "Weave a spider web over the floor, potentially blocking non-spiders walking through them."
	user_type = USER_TYPE_SPIDER

	charge_max = 0
	spell_flags = 0
	invocation_type = SpI_NONE
	summon_type = list(/obj/effect/spider/stickyweb)
	range = 0

	override_base = "spider"
	hud_state = "spider_web"

/spell/aoe_turf/conjure/web/choose_targets(mob/user = usr)
	return list(get_turf(user))


/spell/aoe_turf/conjure/web/cast_check(skipcharge = FALSE, mob/living/carbon/alien/user)
	var/turf/T = get_turf(user)
	if(locate(/obj/effect/spider/stickyweb) in T)
		return FALSE
	return ..()

/spell/spin_cocoon
	name = "Spin Cocoon"
	desc = "Wrap creatures and items on your tile inside a cocoon for later. You will also take a bite out of the creatures trapped this way."
	user_type = USER_TYPE_SPIDER

	charge_max = 0
	spell_flags = 0
	range = 0

	override_base = "spider"
	hud_state = "spider_cocoon"
	var/atom/movable/cocoon_target = null


/spell/spin_cocoon/choose_targets(var/mob/user = usr)
	return list(user)

/spell/spin_cocoon/cast_check(skipcharge = FALSE, mob/living/user)
	var/turf/T = get_turf(user)
	for (var/atom/movable/AM in T)
		if (!AM.anchored && !istype(AM,/mob/living/simple_animal/hostile/giant_spider))
			cocoon_target = AM
			return ..()
	to_chat(user, "<span class='warning'>There has to be at least one loose item or creature on the floor for you to spin a cocoon around!</span>")
	return FALSE

/spell/spin_cocoon/cast(var/list/targets, var/mob/user)
	var/mob/living/simple_animal/hostile/giant_spider/nurse/nurse = user
	nurse.spin_cocoon(cocoon_target)

/spell/spider_eggs
	name = "Lay Eggs"
	desc = "Lay some eggs that will give birth to more spiderlings after a few minutes.."
	user_type = USER_TYPE_SPIDER

	charge_max = 0
	spell_flags = 0
	range = 0

	override_base = "spider"
	hud_state = "spider_eggs"

/spell/spider_eggs/choose_targets(var/mob/user = usr)
	return list(user)

/spell/spider_eggs/cast(var/list/targets, var/mob/user)
	var/mob/living/simple_animal/hostile/giant_spider/nurse/nurse = user
	nurse.lay_eggs()


/spell/spider_nurse_evolution
	name = "Become Queen"
	desc = "Evolve into a strong queen, able to spit sticky webs at a range on top of being a sturdier nurse."
	user_type = USER_TYPE_SPIDER
	hud_state = "spider_queen"
	override_base = "spider"
	charge_max = 0
	spell_flags = 0
	range = 0

/spell/spider_nurse_evolution/choose_targets(var/mob/user = usr)
	return list(user)

/spell/spider_nurse_evolution/cast(var/list/targets, var/mob/user)
	var/mob/living/simple_animal/hostile/giant_spider/nurse/nurse = user
	nurse.manual_evolution()
