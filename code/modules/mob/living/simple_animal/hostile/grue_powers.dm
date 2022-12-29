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

/spell/aoe_turf/grue_drainlight
	name = "Drain Light"
	desc = "Drain the light from the surrounding area. Darkness will not heal you while you do this, though you can stop at will."
	hud_state = "grue_drainlight"
	user_type = USER_TYPE_GRUE
	panel = "Grue"
	override_base = "grue"
	range = 0
	charge_type = Sp_GRADUAL | Sp_HOLDVAR
	holder_var_type = "nutrienergy"
	holder_var_amount = 0.1 //Around 1 nutrienergy per second.
	holder_var_name = "nutritive energy"
	still_recharging_msg = "<span class='notice'>You need to feed more first.</span>"


/spell/aoe_turf/grue_drainlight/cast(list/targets, mob/living/simple_animal/hostile/grue/user)
	playsound(user, 'sound/effects/grue_drainlight.ogg', 50, 1)
	user.drainlight(TRUE)
	playsound(user, 'sound/misc/grue_ambience.ogg', 50, channel = CHANNEL_GRUE)

/spell/aoe_turf/grue_drainlight/stop_casting(list/targets, mob/living/simple_animal/hostile/grue/user, var/mute=FALSE)
	user.drainlight(FALSE, mute)
	playsound(user, null, 50, channel = CHANNEL_GRUE)
	..()

/spell/aoe_turf/grue_blink
	name = "Shadow Shunt"
	desc = "Tunnel through the darkness to a nearby location."
	user_type = USER_TYPE_GRUE
	panel = "Grue"
	hud_state = "grue_blink"
	override_base = "grue"
	range = 0
	charge_type = Sp_RECHARGE
	charge_max = 45 SECONDS
	still_recharging_msg = "<span class='notice'>You need to reorient yourself before doing that again.</span>"

/spell/aoe_turf/grue_blink/cast(list/targets, mob/living/simple_animal/hostile/grue/user)
	user.grueblink(TRUE)

/spell/aoe_turf/grue_blink/cast_check(skipcharge = 0, mob/user = usr)
	if(user)
		var/mob/living/simple_animal/hostile/grue/G = user
		if(G.stat == UNCONSCIOUS)
			to_chat(G, "<span class='notice'>You must be awake to do that.</span>")
			return FALSE
		else if(G.busy)
			to_chat(G, "<span class='notice'>You are already doing something.</span>")
			return FALSE
		else if(G.get_ddl(get_turf(G)) != GRUE_DARK)
			to_chat(G, "<span class='warning'>It's too bright here.</span>")
			return FALSE
	else
		return FALSE
	. = ..()