/client
		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null
	var/buildmode		= 0

	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.

	var/teleport_here_pref = "Flashy"	//Flashy, teleports instantly; Stealthy, teleports with a discret fade-in
	var/flashy_level = 1	//0 = no additional effect, 1 = visual effect and sound, 2 = shake the fucking screen!, 3 = [atom] HAS RISEN!
	var/stealthy_level = 20	//how many tenth of seconds seconds do you want the fade-in to last?

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null
	var/moving			= null
	var/adminobs		= null
	var/area			= null
	var/time_died_as_mouse = null //when the client last died as a mouse
	var/datum/tooltip/tooltips //datum that controls the displaying and hiding of tooltips
	var/list/radial_menus = list() //keeping track of open menus so we're not gonna have several on top of each other.

		///////////////
		//SOUND STUFF//
		///////////////
	var/ambience_playing= null
	var/played			= 0

		////////////
		//SECURITY//
		////////////
	var/next_allowed_topic_time = 10
	// comment out the line below when debugging locally to enable the options & messages menu
	// CONTROL_FREAK_MACROS allows new macros to be made, but won't permit overriding skin-defined ones.  http://www.byond.com/forum/?post=2219001#comment22205313
	// control_freak = CONTROL_FREAK_ALL | CONTROL_FREAK_MACROS


		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = "Requires database"	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id

	//This breaks a lot of shit.  - N3X
	preload_rsc = 1 // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.

	// Used by html_interface module.
	var/hi_last_pos

	/////////////////////////////////////////////
	// /vg/: MEDIAAAAAAAA
	// Set on login.
	var/datum/media_manager/media = null

	var/filling = 0 //SOME STUPID SHIT POMF IS DOING
	var/haszoomed = 0

	// Their chat window, sort of important.
	// See /goon/code/datums/browserOutput.dm
	var/datum/chatOutput/chatOutput

		////////////
		//PARALLAX//
		////////////
	var/list/parallax = list()
	var/list/parallax_movable = list()
	var/list/parallax_offset = list()
	var/turf/previous_turf = null
	var/obj/abstract/screen/plane_master/parallax_master/parallax_master = null
	var/obj/abstract/screen/plane_master/parallax_dustmaster/parallax_dustmaster = null
	var/obj/abstract/screen/plane_master/parallax_spacemaster/parallax_spacemaster = null
	var/obj/abstract/screen/plane_master/ghost_planemaster/ghost_planemaster = null
	var/obj/abstract/screen/plane_master/ghost_planemaster_dummy/ghost_planemaster_dummy = null

	// This gets set by goonchat.
	var/encoding = "1252"

	//One-way windows
	var/list/ViewFilter = list()
	var/list/ObscuredTurfs = list()

	//ambience
	var/last_ambient_noise //no repeats.
	var/ambience_buffer // essentially world.time + the length of the ambience sound file. this is to prevent overlap.

	var/received_credits = FALSE
	var/received_roundend_audio = FALSE

	// Runechat messages
	var/list/seen_messages = list()
	var/toggle_runechat_outlines = TRUE

	// Voting & civic duty
	var/ivoted = FALSE

	// Last Round Scoreboard images have been sent
	var/received_last_round_images = FALSE

var/list/person_animation_viewers = list()
var/list/item_animation_viewers = list()
