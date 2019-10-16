
/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/ghost_hud()
	mymob.visible = getFromPool(/obj/abstract/screen)
	mymob.visible.icon = 'icons/mob/screen1_ghost.dmi'
	mymob.visible.icon_state = "visible0"
	mymob.visible.name = "visible"
	mymob.visible.screen_loc = ui_health

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.visible)

/datum/hud/proc/corgi_hud()
	mymob.fire = getFromPool(/obj/abstract/screen)
	mymob.fire.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.healths = getFromPool(/obj/abstract/screen)
	mymob.healths.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = getFromPool(/obj/abstract/screen)
	mymob.pullin.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull

	mymob.oxygen = getFromPool(/obj/abstract/screen)
	mymob.oxygen.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.toxin = getFromPool(/obj/abstract/screen)
	mymob.toxin.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.fire, mymob.healths, mymob.pullin, mymob.oxygen, mymob.toxin)

/datum/hud/proc/brain_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')

/datum/hud/proc/slime_hud()


	mymob.healths = getFromPool(/obj/abstract/screen)
	mymob.healths.icon = 'icons/mob/screen1_slime.dmi'
	mymob.healths.icon_state = "slime_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health

	mymob.pullin = getFromPool(/obj/abstract/screen)
	mymob.pullin.icon = 'icons/mob/screen1_slime.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull

	mymob.zone_sel = getFromPool(/obj/abstract/screen/zone_sel)
	mymob.zone_sel.icon = 'icons/mob/screen1_slime.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.healths, mymob.pullin, mymob.zone_sel)

/datum/hud/proc/shade_hud()


	mymob.healths = getFromPool(/obj/abstract/screen)
	mymob.healths.icon = 'icons/mob/screen1_shade.dmi'
	mymob.healths.icon_state = "shade_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health

	mymob.pullin = getFromPool(/obj/abstract/screen)
	mymob.pullin.icon = 'icons/mob/screen1_shade.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull

	mymob.purged = getFromPool(/obj/abstract/screen)
	mymob.purged.icon = 'icons/mob/screen1_shade.dmi'
	mymob.purged.icon_state = "purge0"
	mymob.purged.name = "purged"
	mymob.purged.screen_loc = ui_construct_purge

	mymob.zone_sel = getFromPool(/obj/abstract/screen/zone_sel)
	mymob.zone_sel.icon = 'icons/mob/screen1_shade.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")


	////////SOUL BLADE HUD ELEMENTS////////
	mymob.gui_icons.soulblade_bgLEFT = getFromPool(/obj/abstract/screen)
	mymob.gui_icons.soulblade_bgLEFT.icon = 'icons/mob/screen1_shade_fullscreen.dmi'
	mymob.gui_icons.soulblade_bgLEFT.icon_state = "backgroundLEFT"
	mymob.gui_icons.soulblade_bgLEFT.name = "Blood"
	mymob.gui_icons.soulblade_bgLEFT.layer = HUD_BASE_LAYER
	mymob.gui_icons.soulblade_bgLEFT.screen_loc = ui_blob_bgLEFT

	mymob.gui_icons.soulblade_coverLEFT = getFromPool(/obj/abstract/screen)
	mymob.gui_icons.soulblade_coverLEFT.icon = 'icons/mob/screen1_shade_fullscreen.dmi'
	mymob.gui_icons.soulblade_coverLEFT.icon_state = "coverLEFT"
	mymob.gui_icons.soulblade_coverLEFT.name = "Blood"
	mymob.gui_icons.soulblade_coverLEFT.layer = HUD_ABOVE_ITEM_LAYER
	mymob.gui_icons.soulblade_coverLEFT.screen_loc = ui_blob_bgLEFT
	mymob.gui_icons.soulblade_coverLEFT.maptext_x = 1
	mymob.gui_icons.soulblade_coverLEFT.maptext_y = 126*PIXEL_MULTIPLIER

	mymob.gui_icons.soulblade_bloodbar = getFromPool(/obj/abstract/screen)
	mymob.gui_icons.soulblade_bloodbar.icon = 'icons/mob/screen1_shade_bars.dmi'
	mymob.gui_icons.soulblade_bloodbar.icon_state = "blood"
	mymob.gui_icons.soulblade_bloodbar.name = "Blood"
	mymob.gui_icons.soulblade_bloodbar.screen_loc = ui_blob_powerbar

	mymob.fire = getFromPool(/obj/abstract/screen)
	mymob.fire.icon = 'icons/mob/screen1_shade.dmi'
	mymob.fire.icon_state = "blade_ok"
	mymob.fire.name = "blade integrity"
	mymob.fire.screen_loc = ui_construct_fire
	///////////////////////////////////////

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.healths, mymob.pullin, mymob.zone_sel, mymob.purged)

/datum/hud/proc/borer_hud()

	mymob.healths = getFromPool(/obj/abstract/screen)
	mymob.healths.icon = 'icons/mob/screen1_borer.dmi'
	mymob.healths.icon_state = "borer_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health

	mymob.zone_sel = getFromPool(/obj/abstract/screen/zone_sel)
	mymob.zone_sel.icon = 'icons/mob/screen1_borer.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.healths, mymob.zone_sel)

/datum/hud/proc/construct_hud()
	var/constructtype

	if(istype(mymob,/mob/living/simple_animal/construct/armoured))
		constructtype = "juggernaut"
	else if(istype(mymob,/mob/living/simple_animal/construct/builder))
		constructtype = "artificer"
	else if(istype(mymob,/mob/living/simple_animal/construct/wraith))
		constructtype = "wraith"
	else if(istype(mymob,/mob/living/simple_animal/construct/harvester))
		constructtype = "harvester"

	if(constructtype)
		mymob.fire = getFromPool(/obj/abstract/screen)
		mymob.fire.icon = 'icons/mob/screen1_construct.dmi'
		mymob.fire.icon_state = "fire0"
		mymob.fire.name = "fire"
		mymob.fire.screen_loc = ui_construct_fire

		mymob.healths = getFromPool(/obj/abstract/screen)
		mymob.healths.icon = 'icons/mob/screen1_construct.dmi'
		mymob.healths.icon_state = "[constructtype]_health0"
		mymob.healths.name = "health"
		mymob.healths.screen_loc = ui_construct_health

		mymob.pullin = getFromPool(/obj/abstract/screen)
		mymob.pullin.icon = 'icons/mob/screen1_construct.dmi'
		mymob.pullin.icon_state = "pull0"
		mymob.pullin.name = "pull"
		mymob.pullin.screen_loc = ui_construct_pull

		mymob.zone_sel = getFromPool(/obj/abstract/screen/zone_sel)
		mymob.zone_sel.icon = 'icons/mob/screen1_construct.dmi'
		mymob.zone_sel.overlays.len = 0
		mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

		mymob.purged = getFromPool(/obj/abstract/screen)
		mymob.purged.icon = 'icons/mob/screen1_construct.dmi'
		mymob.purged.icon_state = "purge0"
		mymob.purged.name = "purged"
		mymob.purged.screen_loc = ui_construct_purge

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.fire, mymob.healths, mymob.pullin, mymob.zone_sel, mymob.purged)

/datum/hud/proc/vampire_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')


	vampire_blood_display = getFromPool(/obj/abstract/screen)
	vampire_blood_display.name = "Vampire Blood"
	vampire_blood_display.icon_state = "dark128"
	vampire_blood_display.screen_loc = "EAST-1:[28*PIXEL_MULTIPLIER],CENTER+2:[15*PIXEL_MULTIPLIER]"

	mymob.client.screen += list(vampire_blood_display)

/datum/hud/proc/changeling_hud()
	vampire_blood_display = getFromPool(/obj/abstract/screen)
	vampire_blood_display.name = "Changeling Chems"
	vampire_blood_display.icon_state = "dark128"
	vampire_blood_display.screen_loc = "EAST-1:[28*PIXEL_MULTIPLIER],CENTER+2:[15*PIXEL_MULTIPLIER]"

	mymob.client.screen += list(vampire_blood_display)


/datum/hud/proc/countdown_hud()
	countdown_display = getFromPool(/obj/abstract/screen)
	countdown_display.name = "Burst Countdown"
	countdown_display.icon_state = "template"
	countdown_display.screen_loc = "EAST-1:[28*PIXEL_MULTIPLIER],CENTER+2:[15*PIXEL_MULTIPLIER]"

	mymob.client.screen += list(countdown_display)


/datum/hud/proc/cult_hud(ui_style = 'icons/mob/screen1_cult.dmi')

	cult_Act_display = getFromPool(/obj/abstract/screen)
	cult_Act_display.icon = ui_style
	cult_Act_display.name = "Prologue: The Reunion"
	cult_Act_display.icon_state = ""
	cult_Act_display.screen_loc = ui_cult_Act
	pulse_atom(cult_Act_display)

	cult_tattoo_display = getFromPool(/obj/abstract/screen)
	cult_tattoo_display.icon = ui_style
	cult_tattoo_display.name = "Arcane Tattoos: none"
	cult_tattoo_display.icon_state = ""
	cult_tattoo_display.screen_loc = ui_cult_tattoos
	//pulse_atom(cult_tattoo_display)

	if (mymob.client)
		mymob.client.screen += list(cult_Act_display,cult_tattoo_display)

/datum/hud/proc/pulse_atom(var/obj/abstract/screen/A)
	animate(A, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)
