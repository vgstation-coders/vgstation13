/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

var/datum/subsystem/tgui/SStgui

/datum/subsystem/tgui
	name     = "tgui"
	flags    = SS_FIRE_IN_LOBBY
	wait     = 2 SECONDS
	priority = SS_PRIORITY_TGUI

	var/list/currentrun
	var/list/open_uis = list() // A list of open UIs, grouped by src_object and ui_key.
	var/list/processing_uis = list()
	var/basehtml

/datum/subsystem/tgui/New()
	NEW_SS_GLOBAL(SStgui)

/datum/subsystem/tgui/Initialize(timeofday)
	basehtml = file2text('tgui/packages/tgui/public/tgui.html')
	..()

/datum/subsystem/tgui/stat_entry()
	..("P:[processing_uis.len]")

/datum/subsystem/tgui/fire(resumed = FALSE)
	if (!resumed)
		currentrun = processing_uis.Copy()

	while (currentrun.len)
		var/datum/tgui/ui = currentrun[currentrun.len]
		currentrun.len--

		if (ui && ui.user && ui.src_object)
			ui.process()
		else
			processing_uis -= ui
		if (MC_TICK_CHECK)
			return
