//move eat, ventcrawl, hide, moult, egglay, dark aura to spells

///spell/grue
//    name = "Grue Ability"
//    desc = "A template grue ability."
//    abbreviation = "GA"
//    still_recharging_msg = "<span class='warning'>Your body is still <span>"

//    user_type = USER_TYPE_GRUE
//    school = "grue"
//    spell_flags = 0
//    level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 3)

//    override_base = "grue"
//    hud_state = "grue_icon_base"
//    charge_max = 20 SECONDS
//    cooldown_min = 1 SECONDS
//    var/sp_cost = 0 //shadow power cost to use the spell
//    var/re_cost = 0 //reproductive power cost to use the spell

/spell/targeted/grue_eat
	name = "Eat"
	desc = "Eat someone."
	user_type = USER_TYPE_GRUE
	panel = "Grue"
	hud_state = "grue_eat"
	override_base = "grue"

	spell_flags = WAIT_FOR_CLICK
	charge_type = Sp_RECHARGE
	charge_max = 0 SECONDS
	range = 1
	compatible_mobs = list(/mob/living/carbon)

/spell/targeted/grue_eat/cast(var/list/targets, mob/living/simple_animal/hostile/grue/user)
	if (!isturf(user.loc))
		to_chat(user, "<span class='notice'>You need more room to eat.</span>")
		return
	else if (user.stat==UNCONSCIOUS)
		to_chat(user, "<span class='notice'>You must be awake to eat.</span>")
		return
	else if (user.busy)
		to_chat(user, "<span class='notice'>You are already doing something.</span>")
		return
	else
		user.handle_feed(targets[1])

/spell/aoe_turf/grue_ventcrawl
	name = "Crawl through Vent"
	desc = "Enter an air vent and crawl through the pipe system."
	user_type = USER_TYPE_GRUE
	panel = "Grue"
	hud_state = "grue_vent"
	override_base = "grue"
	range = 1
	charge_type = Sp_RECHARGE
	charge_max = 0

/spell/aoe_turf/grue_ventcrawl/cast(list/targets, mob/living/simple_animal/hostile/grue/user)
	user.ventcrawl()


/spell/aoe_turf/grue_hide
	name = "Hide"
	desc = "Allows you to hide beneath tables or items laid on the ground. Toggle."
	user_type = USER_TYPE_GRUE
	panel = "Grue"
	hud_state = "grue_hide"
	override_base = "grue"
	range = 0
	charge_type = Sp_RECHARGE
	charge_max = 0

/spell/aoe_turf/grue_hide/cast(list/targets, mob/living/simple_animal/hostile/grue/user)
	user.hide()

/spell/aoe_turf/grue_egg
	name = "Reproduce"
	desc = "Spawn offspring in the form of an egg."
	user_type = USER_TYPE_GRUE
	panel = "Grue"
	hud_state = "grue_egg"
	override_base = "grue"
	range = 0
	charge_type = Sp_RECHARGE
	charge_max = 0

/spell/aoe_turf/grue_egg/cast(list/targets, mob/living/simple_animal/hostile/grue/user)
	user.reproduce()

/spell/aoe_turf/grue_moult
	name = "Moult"
	desc = "Moult into a new form."
	user_type = USER_TYPE_GRUE
	panel = "Grue"
	hud_state = "grue_moult"
	override_base = "grue"
	range = 0
	charge_type = Sp_RECHARGE
	charge_max = 0

/spell/aoe_turf/grue_moult/cast(list/targets, mob/living/simple_animal/hostile/grue/user)
	user.moult()