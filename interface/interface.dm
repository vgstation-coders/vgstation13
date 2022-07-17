//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/MapRender()
	set name = "MapRender"
	set desc = "Shows a high scale rendering of the current map in your browser."
	set hidden = 1

	if(!config.renders_url || config.renders_url == "")
		to_chat(src, "<span class='danger'>The Map Renders url has not been set in the server configuration.</span>")
		return
	if(alert("This will open the map render(s) in your browser. Are you sure?",,"Yes","No")=="No")
		return
	var/mapname = replacetext(map.nameLong, " ", "")
	src << link("[config.renders_url]/images/maps/[mapname]")

/client/verb/wiki()
	set name = "wiki"
	set desc = "Visit the wiki."
	set hidden = 1
	if( config.wikiurl )
		if(alert("This will open the wiki in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.wikiurl)
	else
		to_chat(src, "<span class='danger'>The wiki URL is not set in the server configuration.</span>")
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	if( config.forumurl )
		if(alert("This will open the forum in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.forumurl)
	else
		to_chat(src, "<span class='danger'>The forum URL is not set in the server configuration.</span>")
	return

#define RULES_FILE "config/rules.html"
/client/verb/rules()
	set name = "Rules"
	set desc = "Show Server Rules."
	set hidden = 1
	src << browse(file(RULES_FILE), "window=rules;size=480x320")
#undef RULES_FILE

/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = drop
\te = equip
\tr = throw
\tm = me
\tt = say
\tx = swap-hand
\tz = activate held object (or y)
\tf = cycle-intents-left
\tg = cycle-intents-right
\tu = cycle-target-zone-up
\tj = cycle-target-zone-down
\t h = cycle-target-zone-left
\tk = cycle-target-zone-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
\t5 = kick
\t6 = bite
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+x = swap-hand
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+u = cycle-target-zone-up
\tCtrl+j = cycle-target-zone-down
\tCtrl+h = cycle-target-zone-left
\tCtrl+k = cycle-target-zone-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tCtrl+5 = kick
\tCtrl+6 = bite
\tDEL = pull
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
\tSHIFT+MMB = point-at
\tAlt+NUMPAD8 = target head
\tAlt+NUMPAD7 = target mouth
\tAlt+NUMPAD9 = target eyes
\tAlt+NUMPAD5 = target chest
\tAlt+NUMPAD2 = target groin
\tAlt+NUMPAD4 = target left arm
\tAlt+NUMPAD6 = target right arm
\tAlt+NUMPAD1 = target left leg
\tAlt+NUMPAD3 = target right leg
\tCtrl+NUMPAD4 = target left hand
\tCtrl+NUMPAD6 = target right hand
\tCtrl+NUMPAD1 = target left foot
\tCtrl+NUMPAD3 = target right foot

For an exhaustive list please visit http://ss13.moe/wiki/index.php/Shortcuts
</font>"}

	var/admin = {"<font color='purple'>
Admin:
\tF6 = player-panel-new
\tF7 = admin-pm
\tF8 = Invisimin
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)
	if(holder)
		to_chat(src, admin)

// Needed to circumvent a bug where .winset does not work when used on the window.on-size event in skins.
// Used by /datum/html_interface/nanotrasen (code/modules/html_interface/nanotrasen/nanotrasen.dm)
/client/verb/_swinset(var/x as text)
	set name = ".swinset"
	set hidden = 1
	winset(src, null, x)

/client/verb/roundendinfo()
	set name = "RoundEndInformation"
	set desc = "Open the Round End Information window."
	set hidden = 1

	if (round_end_info)
		var/datum/browser/popup = new(src, "roundstats", "Round End Summary", 1000, 600)
		popup.set_content(round_end_info)
		popup.open()
	else if (last_round_end_info)
		var/datum/browser/popup = new(src, "roundstats", "Last Round Summary", 1000, 600)
		popup.set_content(last_round_end_info)
		popup.open()
	else
		to_chat(usr, "<span class='warning'>no Round End Summary found.</span>")
