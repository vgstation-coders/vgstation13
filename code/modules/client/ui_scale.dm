#define UI_SCALE_MIN 0.7
#define UI_SCALE_MAX 2
#define UI_SCALE_STEP 0.2

/client
	var/ui_scale = 1
	var/ui_scale_icon_base = 0
	var/ui_scale_map_font_base = 0
	var/ui_scale_info_font_base = 0
	var/ui_scale_tab_font_base = 0

	// base values of list(xpos,ypos,sizew,sizeh) keyed by id str
	var/list/ui_scale_rpane_base
	var/list/ui_scale_main_base
	var/list/ui_scale_input_base

/client/New()
	..()
	if (prefs)
		ui_scale = clamp(prefs.get_pref(/datum/preference_setting/numerical/ui_scale), UI_SCALE_MIN, UI_SCALE_MAX)
	apply_ui_scale()

/client/verb/increase_ui_scale()
	set name = "UI: Increase Scale"
	set category = "OOC"
	adjust_ui_scale(UI_SCALE_STEP)

/client/verb/decrease_ui_scale()
	set name = "UI: Decrease Scale"
	set category = "OOC"
	adjust_ui_scale(-UI_SCALE_STEP)

/client/proc/adjust_ui_scale(delta)
	var/old = ui_scale
	ui_scale = clamp(old + delta, UI_SCALE_MIN, UI_SCALE_MAX)
	if(ui_scale != old)
		apply_ui_scale()
		to_chat(src, "UI scale set to [ui_scale]x")

/client/proc/ui_scale_capture_defaults()
	// verbs + tabs
	if(!ui_scale_info_font_base || !ui_scale_tab_font_base)
		var/tmp_info = text2num(winget(src, "infowindow.info", "font-size"))
		if(!tmp_info)
			tmp_info = 7 // byond ref says "default value" without saying that that default is (winget returns 0). 7 seems right on my screen
		ui_scale_info_font_base = tmp_info

		var/tmp_tab = text2num(winget(src, "infowindow.info", "tab-font-size"))
		if(!tmp_tab)
			tmp_tab = tmp_info
		ui_scale_tab_font_base = tmp_tab

	// buttons in the top right of the window
	if(!ui_scale_rpane_base)
		ui_scale_rpane_base = list()
		var/list/rpane_ids = list(
			"textb","infob","wikib","forumb","rulesb","changelog",
			"mapb","github","special_button","browseb",
			"round_end","last_round_end"
		)
		for(var/id in rpane_ids)
			var/list/pos = ui_scale_read_pair(winget(src, "rpane.[id]", "pos"), ",")
			var/list/sz = ui_scale_read_pair(winget(src, "rpane.[id]", "size"), "x")
			ui_scale_rpane_base[id] = list(pos[1], pos[2], sz[1], sz[2])

	// TODO figure out if these are necessary, its annoying to get right
	//// buttons in the bottom right of the window by the input bar
	//if(!ui_scale_main_base)
	//	ui_scale_main_base = list()
	//	var/list/main_ids = list("oocbutton","mebutton","saybutton","hotkey_toggle")
	//	for(var/id in main_ids)
	//		var/list/pos = ui_scale_read_pair(winget(src, "mainwindow.[id]", "pos"), ",")
	//		var/list/sz = ui_scale_read_pair(winget(src, "mainwindow.[id]", "size"), "x")
	//		ui_scale_main_base[id] = list(pos[1], pos[2], sz[1], sz[2])
//
	//// pink input bar thingy at the bottom
	//if(!ui_scale_input_base)
	//	var/list/pos = ui_scale_read_pair(winget(src, "mainwindow.input", "pos"), ",")
	//	var/list/sz = ui_scale_read_pair(winget(src, "mainwindow.input", "size"), "x")
	//	ui_scale_input_base = list(pos[1], pos[2], sz[1], sz[2])

// return xy pairs from window properties
/client/proc/ui_scale_read_pair(str, sep)
	var/list/out = list(0,0)
	if (!str)
		return
	var/list/pair = splittext(str, sep)
	if (length(pair) >= 2)
		out[1] = text2num(pair[1])
		out[2] = text2num(pair[2])
	return out

/client/proc/apply_ui_scale()
	ui_scale_capture_defaults()
	var/scale = clamp(ui_scale, UI_SCALE_MIN, UI_SCALE_MAX)

	// pink input bar thing at the bottom
	//var/font_main = floor(9 * scale)
	//winset(src, "mainwindow.input", "font-size=[font_main]")

	var/font_rpane = floor(8 * scale)
	if (ui_scale_rpane_base)
		for (var/id in ui_scale_rpane_base)
			var/list/base = ui_scale_rpane_base[id]
			var/px = floor(base[1] * scale)
			var/py = floor(base[2] * scale)
			var/w = floor(base[3] * scale)
			var/h = floor(base[4] * scale)
			winset(src, "rpane.[id]", "pos=[px],[py];size=[w]x[h];font-size=[font_rpane]")

	// verbs + tabs
	var/info_font = floor(ui_scale_info_font_base * scale)
	var/tab_font = floor(ui_scale_tab_font_base * scale)
	winset(src, "infowindow.info", "font-size=[info_font];tab-font-size=[tab_font]")

/client/proc/ui_scale_save_pref()
	if (!prefs)
		return
	var/datum/preference_setting/numerical/ui_scale/p = prefs.get_pref_datum(/datum/preference_setting/numerical/ui_scale)
	p.setting = ui_scale
	prefs.save_preferences_sqlite(src, src.ckey)

#undef UI_SCALE_MIN
#undef UI_SCALE_MAX
#undef UI_SCALE_STEP
