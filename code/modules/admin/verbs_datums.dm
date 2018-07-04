var/list/admins_verbs = list(
    /client/proc/set_base_turf,
    /client/proc/SendCentcommFax,		/*sends a fax to all fax machines*/
    /client/proc/player_panel,			/*shows an interface for all players, with links to various panels (old style)*/
    /datum/admins/proc/toggleenter,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
    /client/proc/colorooc,				/*allows us to set a custom colour for everythign we say in ooc*/
    /client/proc/toggle_view_range,		/*changes how far we can see*/
    /datum/admins/proc/view_txt_log,	/*shows the server log (diary) for today*/
    /datum/admins/proc/view_atk_log,	/*shows the server combat-log, doesn't do anything presently*/
    /client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
    /datum/admins/proc/access_news_network,	/*allows access of newscasters*/
    /client/proc/giveruntimelog,		/*allows us to give access to runtime logs to somebody*/
	/client/proc/getruntimelog,			/*allows us to access runtime logs to somebody*/
	/client/proc/getserverlog,			/*allows us to fetch server logs (diary) for other days*/
	/client/proc/jumptocoord,			/*we ghost and jump to a coordinate*/
	/client/proc/Getmob,				/*teleports a mob to our location*/
	/client/proc/Getkey,				/*teleports a mob with a certain ckey to our location*/
//	/client/proc/sendmob,				/*sends a mob somewhere*/ -Removed due to it needing two sorting procs to work, which were executed every time an admin right-clicked. ~Errorage
	/client/proc/Jump,
	/client/proc/jumptokey,				/*allows us to jump to the location of a mob with a certain ckey*/
	/client/proc/jumptomob,				/*allows us to jump to a specific mob*/
	/client/proc/jumptoturf,			/*allows us to jump to a specific turf*/
	/client/proc/jumptomapelement,			/*allows us to jump to a specific vault*/
	/client/proc/admin_call_shuttle,	/*allows us to call the emergency shuttle*/
	/client/proc/admin_cancel_shuttle,	/*allows us to cancel the emergency shuttle, sending it back to centcomm*/
	/client/proc/cmd_admin_local_narrate,	/*send text locally to all players in view, similar to direct narrate*/
	/client/proc/cmd_admin_world_narrate,	/*sends text to all players with no padding*/
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/check_words,			/*displays cult-words*/
	/client/proc/check_ai_laws,			/*shows AI and borg laws*/
	/client/proc/admin_memo,			/*admin memo system. show/delete/write. +SERVER needed to delete admin memos of others*/
	/client/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/secrets,
	/client/proc/shuttle_magic,
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/togglelooc, /*toggles looc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/client/proc/game_panel,			/*game panel, allows to change game-mode etc*/
	/client/proc/cmd_admin_say,			/*admin-only ooc chat*/
    /datum/admins/proc/PlayerNotes,
    /client/proc/player_panel_new,		/*shows an interface for all players, with links to various panels*/
    /client/proc/free_slot,			/*frees slot for chosen job*/
	/client/proc/cmd_admin_change_custom_event,
    /client/proc/toggle_antagHUD_use,
    /client/proc/toggle_antagHUD_restrictions,
	/client/proc/allow_character_respawn,    /* Allows a ghost to respawn */
	/client/proc/watchdog_force_restart,	/*forces restart using watchdog feature*/
	/client/proc/manage_religions,
    /client/proc/check_customitem_activity,
)

/client/proc/call_admin_verb(var/proc_path)
    if (proc_path in admins_verbs)
        call(src, proc_path)()

/datum/admins/proc/call_admin_verb(var/proc_path)
    if(proc_path in admins_verbs)
        call(src, proc_path)()

/proc/sort_verbs_out()
    for(var/verb_ in typesof(/datum/admin_verbs/))
        var/datum/admin_verbs/V = verb_
        switch (initial(V.category))
            if ("ADMIN")
                verbs_admin += V
            if ("DEBUG")
                verbs_debug += V

var/list/datum/admin_verbs/verbs_admin = list()
var/list/datum/admin_verbs/verbs_debug= list()

/datum/admins/proc/other_admins_verbs()
    set category = "Admin"
    set name = "Other admin verbs/commands."

    if (!verbs_admin.len)
        sort_verbs_out()
        
    var/dat = "<h3>Admin verbs:</h3>"
    dat += "<h4><i>ADMIN</i> category:</h4>"
    dat += "<ul>"
    for (var/verb_ in verbs_admin)
        var/datum/admin_verbs/V = new verb_
        dat += "<li><b>[V.name]</b> - [V.desc] (<a href='?src=\ref[usr.client.holder];verb=[V.type]'>Use</a>)"
    dat += "<ul/>"

    usr << browse(dat, "window=powers;size=500x480")

// -- Admin verbs datums --

/datum/admin_verbs/
    var/name = "Placeholder proc"
    var/desc = "You should not be able to see this."
    var/proc_path = null

    var/category = ""

/datum/admin_verbs/proc/execute(var/datum/admins/holder)
    // Void

/datum/admin_verbs/admin_parent/execute(var/datum/admins/holder)
    holder.call_admin_verb(proc_path)

/datum/admin_verbs/client_parent/execute(var/datum/admins/holder)
    holder.owner.call_admin_verb(proc_path)

// -- List of admins verbs start here --
/* ADMIN PANEL */

/datum/admin_verbs/client_parent/set_base_turf
    name = "Set Base Turf"
    desc = "Change the base turf for the Z-level (warning : causes lag)"
    proc_path = /client/proc/set_base_turf
    category = "ADMIN"

/datum/admin_verbs/client_parent/SendCentcommFax
    name = "Send Centcomm Fax"
    desc = "Send a centcomm fax to all machines."
    proc_path = /client/proc/SendCentcommFax
    category = "ADMIN"

/datum/admin_verbs/client_parent/player_panel
    name = "Player Panel (Old)"
    desc = "Uses the old player panel."
    proc_path = /client/proc/player_panel
    category = "ADMIN"

/datum/admin_verbs/admin_parent/toggleenter
    name = "Toggle new player entering"
    desc = "Prevents new people from joining the game."
    proc_path = /datum/admins/proc/toggleenter
    category = "ADMIN"

/datum/admin_verbs/admin_parent/announce
    name = "Announce (OOC)"
    desc = "Make an announcement (OOC, shows your ckey)."
    proc_path = /datum/admins/proc/announce
    category = "ADMIN"

/datum/admin_verbs/client_parent/colorooc
    name = "Colour OOC"
    desc = "Allows you to choose a custom colour for OOC."
    proc_path = /client/proc/colorooc
    category = "ADMIN"

/datum/admin_verbs/client_parent/toggle_view_range
    name = "Toggle view range"
    desc = "Change our view distance."
    proc_path = /client/proc/toggle_view_range
    category = "ADMIN"

/datum/admin_verbs/admin_parent/view_txt_log
    name = "Show server log"
    desc = "Show the server logs for the day (.txt)"
    proc_path = /datum/admins/proc/view_txt_log
    category = "ADMIN"

/datum/admin_verbs/admin_parent/view_txt_log
    name = "Show server attack log"
    desc = "Show the server attack logs for the day (.txt)"
    proc_path = /datum/admins/proc/view_atk_log
    category = "ADMIN"

/datum/admin_verbs/client_parent/cmd_admin_pm_panel
    name = "Admin PM list"
    desc = "List of players to whom you can send a message."
    proc_path = /client/proc/cmd_admin_pm_panel
    category = "ADMIN"

/datum/admin_verbs/admin_parent/access_news_network
    name = "Access news network"
    desc = "Allows you to post stories on the station's newsfeed."
    proc_path = /datum/admins/proc/access_news_network
    category = "ADMIN"

/datum/admin_verbs/client_parent/giveruntimelog
    name = "Give runtime logs"
    desc = "Give a ckey access to the runtime log (for the round only)"
    proc_path = /client/proc/giveruntimelog
    category = "ADMIN"

/datum/admin_verbs/client_parent/getruntimelog
    name = "Get runtime logs (deprecated)"
    desc = "Allows us to access runtime logs to somebody"
    proc_path = /client/proc/getruntimelog
    category = "ADMIN"

/datum/admin_verbs/client_parent/getserverlog
    name = "Get server logs"
    desc = "Gives us the logs for today"
    proc_path = /client/proc/getserverlog
    category = "ADMIN"

/datum/admin_verbs/client_parent/jumptocoord
    name = "Jump to coordinate"
    desc = "Let you ghost and jump to chosen coordinates."
    proc_path = /client/proc/jumptocoord
    category = "ADMIN"

/datum/admin_verbs/client_parent/Getmob
    name = "Get Mob"
    desc = "Instantly get a mob to your location."
    proc_path = /client/proc/Getmob
    category = "ADMIN"

/datum/admin_verbs/client_parent/Getkey
    name = "Get key"
    desc = "Instantly get a mob with a chosen ckey to your location."
    proc_path = /client/proc/Getmob
    category = "ADMIN"

/datum/admin_verbs/client_parent/Jump
    name = "Jump"
    desc = "Jump to a location (given via coordinates)"
    proc_path = /client/proc/Jump
    category = "ADMIN"

/datum/admin_verbs/client_parent/jumptokey
    name = "Jump to ckey"
    desc = "Jump to a mob, identified by ckey."
    proc_path = /client/proc/jumptokey
    category = "ADMIN"

/datum/admin_verbs/client_parent/jumptomob
    name = "Jump to mob"
    desc = "Jump to a mob in the mob list."
    proc_path = /client/proc/jumptomob
    category = "ADMIN"

/datum/admin_verbs/client_parent/jumptoturf
    name = "Jump to turf"
    desc = "Jump to a turf in the world."
    proc_path = /client/proc/jumptoturf
    category = "ADMIN"
    
/datum/admin_verbs/client_parent/jumptomapelement
    name = "Jump to a map element"
    desc = "Jump to a map element (area)."
    proc_path = /client/proc/jumptomapelement
    category = "ADMIN"

/datum/admin_verbs/client_parent/admin_call_shuttle
    name = "Call the emergency shuttle"
    desc = "Call the shuttle and let you specify a reason."
    proc_path = /client/proc/admin_call_shuttle
    category = "ADMIN"

/datum/admin_verbs/client_parent/admin_cancel_shuttle
    name = "Recall the emergency shuttle"
    desc = "Cancel a called emergency shuttle."
    proc_path = /client/proc/admin_cancel_shuttle
    category = "ADMIN"

/datum/admin_verbs/client_parent/cmd_admin_local_narrate
    name = "Local narrate"
    desc = "Sends a fluff message to players in view."
    proc_path = /client/proc/cmd_admin_local_narrate
    category = "ADMIN"

/datum/admin_verbs/client_parent/cmd_admin_world_narrate
    name = "World narrate"
    desc = "Sends a fluff message to all players in the world."
    proc_path = /client/proc/cmd_admin_world_narrate
    category = "ADMIN"

/datum/admin_verbs/client_parent/cmd_admin_create_centcom_report
    name = "Create Command Report"
    desc = "Let you choose if the report is to be announced to the general population or not."
    proc_path = /client/proc/cmd_admin_create_centcom_report
    category = "ADMIN"

/datum/admin_verbs/client_parent/check_words
    name = "Check cult words"
    desc = "Let you see what are the randomised words for the active cult (if any)"
    proc_path = /client/proc/check_words
    category = "ADMIN"

/datum/admin_verbs/client_parent/check_ai_laws
    name = "Check AI laws"
    desc = "Let you see what are the randomised words for the active cult (if any)"
    proc_path = /client/proc/check_ai_laws
    category = "ADMIN"

/datum/admin_verbs/client_parent/admin_memo
    name = "Admin memo"
    desc = "Let you see/edit admin memos (requires +SERV for edit)"
    proc_path = /client/proc/admin_memo
    category = "ADMIN"

/datum/admin_verbs/client_parent/investigate_show
    name = "Investigate"
    desc = "See details about atmos, singularity, explosions, and hrefs."
    proc_path = /client/proc/investigate_show
    category = "ADMIN"

/datum/admin_verbs/client_parent/secrets
    name = "Secrets"
    desc = "Various way to dispense FUN to the station."
    proc_path = /client/proc/secrets
    category = "ADMIN"

/datum/admin_verbs/client_parent/shuttle_magic
    name = "Shuttle Magic"
    desc = "Let you play with shuttles in the world."
    proc_path = /client/proc/shuttle_magic
    category = "ADMIN"

/datum/admin_verbs/admin_parent/toggleooc
    name = "Toggle OOC"
    desc = "Toggle OOC on/off for everyone"
    proc_path = /datum/admins/proc/toggleooc
    category = "ADMIN"

/datum/admin_verbs/admin_parent/togglelooc
    name = "Toggle LOOC"
    desc = "Toggle LOOC on/off for everyone"
    proc_path = /datum/admins/proc/togglelooc
    category = "ADMIN"

/datum/admin_verbs/admin_parent/toggleooc
    name = "Toggle OOC (dead people)"
    desc = "Toggle OOC on/off for the dead"
    proc_path = /datum/admins/proc/toggleoocdead
    category = "ADMIN"

/datum/admin_verbs/client_parent/game_panel
    name = "Game Panel"
    desc = "Let edit the gamemode, wages, and other game-related variables."
    proc_path = /client/proc/game_panel
    category = "ADMIN"

/datum/admin_verbs/client_parent/cmd_admin_say
    name = "ASAY"
    desc = "Admin-only channel (deprecated)"
    proc_path = /client/proc/cmd_admin_say
    category = "ADMIN"

/datum/admin_verbs/admin_parent/PlayerNotes
    name = "Show Player Notes"
    desc = "Let you see a player's notes"
    proc_path = /datum/admins/proc/PlayerNotes
    category = "ADMIN"

/datum/admin_verbs/client_parent/player_panel_new
    name = "Player Panel (new interface)"
    desc = "Show the new player panel (with access to VV and other menus)"
    proc_path = /client/proc/player_panel_new
    category = "ADMIN"

/datum/admin_verbs/client_parent/free_slot
    name = "Free a slot for a job"
    desc = "Let you open 50 clown slots."
    proc_path = /client/proc/free_slot
    category = "ADMIN"

/datum/admin_verbs/client_parent/cmd_admin_change_custom_event
    name = "Create a custom event"
    desc = "The information will be displayed to players joining."
    proc_path = /client/proc/cmd_admin_change_custom_event
    category = "ADMIN"

/datum/admin_verbs/client_parent/toggle_antagHUD_use
    name = "Toggle antagHUD"
    desc = "Let you see who is an antag, and who is not."
    proc_path = /client/proc/toggle_antagHUD_use
    category = "ADMIN"

/datum/admin_verbs/client_parent/toggle_antagHUD_restrictions
    name = "Toggle antagHUD usage (for ghosts)"
    desc = "Let ghosts use the antagHUD."
    proc_path = /client/proc/toggle_antagHUD_restrictions
    category = "ADMIN"

/datum/admin_verbs/client_parent/check_customitem_activity
    name = "Check activity for custom items (obsolete)"
    desc = "Check if people with custom items have logged on in the past months."
    proc_path = /client/proc/check_customitem_activity
    category = "ADMIN"

/datum/admin_verbs/client_parent/manage_religions
    name = "Manage religions"
    desc = "Let see which religions are currently active, and bus others."
    proc_path = /client/proc/manage_religions
    category = "ADMIN"

/datum/admin_verbs/client_parent/watchdog_force_restart
    name = "Force restart (via watchdog)"
    desc = "Use this if the server does not shutdown properly."
    proc_path = /client/proc/watchdog_force_restart
    category = "ADMIN"

/datum/admin_verbs/client_parent/allow_character_respawn
    name = "Allow ghost respawn"
    desc = "Allow people to respawn after a 30 minutes delay."
    proc_path = /client/proc/allow_character_respawn
    category = "ADMIN"
