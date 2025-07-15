// Ported from /tg/

/datum/hud/proc/ai_hud()
	adding = list()
	other = list()

	adding = map.give_AI_jumps(adding) //gives AI core button, or more based on map

	var/obj/abstract/screen/using

//Camera list
	using = new /obj/abstract/screen/nocontext
	using.name = "Show Camera List"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera"
	using.screen_loc = ui_ai_camera_list
	adding += using
	using.pointer_to_list = &adding

//Track
	using = new /obj/abstract/screen/nocontext
	using.name = "Track With Camera"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "track"
	using.screen_loc = ui_ai_track_with_camera
	adding += using
	using.pointer_to_list = &adding

//Camera light
	using = new /obj/abstract/screen/nocontext
	using.name = "Toggle Camera Light"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera_light"
	using.screen_loc = ui_ai_camera_light
	adding += using
	using.pointer_to_list = &adding

//Crew Manifest
	using = new /obj/abstract/screen/nocontext
	using.name = "Show Crew Manifest"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "manifest"
	using.screen_loc = ui_ai_crew_manifest
	adding += using
	using.pointer_to_list = &adding

//Alerts
	using = new /obj/abstract/screen/nocontext
	using.name = "Show Alerts"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "alerts"
	using.screen_loc = ui_ai_alerts
	adding += using
	using.pointer_to_list = &adding

//Announcement
	using = new /obj/abstract/screen/nocontext
	using.name = "Announcement"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	adding += using
	using.pointer_to_list = &adding

//Shuttle
	using = new /obj/abstract/screen/nocontext
	using.name = "(Re)Call Emergency Shuttle"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	adding += using
	using.pointer_to_list = &adding

//Laws
	using = new /obj/abstract/screen/nocontext
	using.name = "State Laws"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	adding += using
	using.pointer_to_list = &adding

//PDA message
	using = new /obj/abstract/screen/nocontext
	using.name = "PDA - Send Message"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	adding += using
	using.pointer_to_list = &adding

//PDA log
	using = new /obj/abstract/screen/nocontext
	using.name = "PDA - Show Message Log"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_log
	adding += using
	using.pointer_to_list = &adding

//Take image
	using = new /obj/abstract/screen/nocontext
	using.name = "Take Image"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	adding += using
	using.pointer_to_list = &adding

//View images
	using = new /obj/abstract/screen/nocontext
	using.name = "View Images"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	adding += using
	using.pointer_to_list = &adding

//Radio Configuration
	using = new /obj/abstract/screen/nocontext
	using.name = "Configure Radio"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "change_radio"
	using.screen_loc = ui_ai_config_radio
	adding += using
	using.pointer_to_list = &adding

	mymob.client.screen += adding
