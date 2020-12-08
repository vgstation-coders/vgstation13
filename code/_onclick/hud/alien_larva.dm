/datum/hud/proc/larva_hud()

	src.adding = list()
	src.other = list()

	var/obj/abstract/screen/using

	using = new /obj/abstract/screen
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.a_intent == I_HURT ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	src.adding += using
	action_intent = using

	using = new /obj/abstract/screen
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	src.adding += using
	move_intent = using

	mymob.healths = new /obj/abstract/screen
	mymob.healths.icon = 'icons/mob/screen1_alien.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	mymob.pullin = new /obj/abstract/screen
	mymob.pullin.icon = 'icons/mob/screen1_alien.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist

	mymob.zone_sel = new /obj/abstract/screen/zone_sel
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", mymob.zone_sel.selecting))

	mymob.client.reset_screen()

	mymob.client.screen += list( mymob.zone_sel, mymob.healths, mymob.pullin)
	mymob.client.screen += src.adding + src.other
