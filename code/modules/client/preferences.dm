#define CHARACTER_SETUP 0
#define UI_SETUP 1
#define GENERAL_SETUP 2
#define SPECIAL_ROLES_SETUP 3

var/list/preferences_datums = list()
var/global/list/special_roles = list(
	ROLE_ALIEN     	= 1,
	BLOBOVERMIND   	= 1,
	ROLE_BORER     	= 1,
	CHANGELING   	= 1,
	CULTIST      	= 1,
	ROLE_PLANT     	= 1,
	MALF         	= 1,
	NUKE_OP	    	= 1,
	ROLE_PAI        = 1,
	ROLE_POSIBRAIN  = 1,
	REV          	= 1,
	TRAITOR      	= 1,
	VAMPIRE      	= 1,
	VOXRAIDER    	= 1,
	WIZARD       	= 1,
	ROLE_STRIKE	  	= 1,
	GRINCH			= 1,
	NINJA			= 1,
	ROLE_MINOR		= 1,
)

/var/list/antag_roles = list(
	ROLE_ALIEN      = 1,
	BLOBOVERMIND   	= 1,
	CHANGELING   	= 1,
	CULTIST      	= 1,
	MALF         	= 1,
	NUKE_OP	    	= 1,
	REV          	= 1,
	TRAITOR      	= 1,
	VAMPIRE      	= 1,
	VOXRAIDER    	= 1,
	WIZARD       	= 1,
	ROLE_STRIKE	  	= 1,
	GRINCH			= 1,
	NINJA			= 1,
	ROLE_MINOR		= 1,
)

var/list/nonantag_roles = list(
	ROLE_BORER        = 1,
	ROLE_PLANT        = 1,
	ROLE_PAI          = 1,
	ROLE_POSIBRAIN    = 1,
)

var/list/role_wiki=list(
	ROLE_ALIEN				= "Xenomorph",
	BLOBOVERMIND			= "Blob",
	ROLE_BORER				= "Cortical_Borer",
	CHANGELING				= "Changeling",
	CULTIST					= "Cult",
	ROLE_PLANT				= "Dionaea",
	MALF					= "Guide_to_Malfunction",
	NUKE_OP					= "Nuclear_Agent",
	ROLE_PAI				= "Personal_AI",
	ROLE_POSIBRAIN			= "Guide_to_Silicon_Laws",
	REV						= "Revolution",
	TRAITOR					= "Traitor",
	VAMPIRE					= "Vampire",
	VOXRAIDER				= "Vox_Raider",
	WIZARD					= "Wizard",
	GRINCH					= "Grinch",
	NINJA					= "Space_Ninja",
	ROLE_MINOR				= "Minor_Roles",
)

var/list/special_popup_text2num = list(
	"Only use chat" = SPECIAL_POPUP_DISABLED,
	"Only use special" = SPECIAL_POPUP_EXCLUSIVE,
	"Use both chat and special" = SPECIAL_POPUP_USE_BOTH,
)

var/const/MAX_SAVE_SLOTS = 8

#define POLLED_LIMIT	100

/datum/preferences
	var/list/subsections
	//doohickeys for savefiles
	var/database/db = ("players2.sqlite")
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/slot = 1
	var/list/slot_names = new
	var/lastPolled = 0

	var/savefile_version = 0

	//non-preference stuff
	var/warns = 0
	var/warnbans = 0
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#b82e00"
	var/UI_style = "Midnight"
	var/toggles = TOGGLES_DEFAULT
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255
	var/space_parallax = 1
	var/space_dust = 1
	var/parallax_speed = 2
	var/special_popup = SPECIAL_POPUP_DISABLED
	var/tooltips = 1
	var/stumble = 0						//whether the player pauses after their first step
	var/hear_voicesound = 0				//Whether the player hears noises when somebody speaks.
	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/be_random_body = 0				//whether we'll have a random body every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/underwear = 1					//underwear type
	var/backbag = 2						//backpack type
	var/h_style = "Bald"				//Hair type
	var/r_hair = 0						//Hair color
	var/g_hair = 0						//Hair color
	var/b_hair = 0						//Hair color
	var/f_style = "Shaved"				//Face hair type
	var/r_facial = 0					//Face hair color
	var/g_facial = 0					//Face hair color
	var/b_facial = 0					//Face hair color
	var/s_tone = 0						//Skin color
	var/r_eyes = 0						//Eye color
	var/g_eyes = 0						//Eye color
	var/b_eyes = 0						//Eye color
	var/species = "Human"
	var/language = "None"				//Secondary language
	var/hear_instruments = 1
	var/ambience_volume = 25
	var/credits_volume = 75
	var/window_flashing = 1
	var/antag_objectives = 0 //If set to 1, solo antag roles will get the standard objectives. If set to 0, will give them a freeform objective instead.

		//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null

		//Jobs, uses bitflags
	var/job_civilian_high = 0
	var/job_civilian_med = 0
	var/job_civilian_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engsec_high = 0
	var/job_engsec_med = 0
	var/job_engsec_low = 0

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = RETURN_TO_LOBBY

	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = list() // skills can range from 0 to 3

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()

	var/list/player_alt_titles = new()		// the default name of a job like "Medical Doctor"

	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/disabilities = 0 // NOW A BITFIELD, SEE ABOVE

	var/nanotrasen_relation = "Neutral"
	var/bank_security = 1			//for bank accounts, 0-2, no-pin,pin,pin&card


	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

		// OOC Metadata:
	var/metadata = ""
	var/slot_name = ""

	// Whether or not to use randomized character slots
	var/randomslot = 0

	// jukebox volume
	var/volume = 100
	var/usewmp = 0 //whether to use WMP or VLC

	var/list/roles=list() // "role" => ROLEPREF_*

	//attack animation type
	var/attack_animation = NO_ANIMATION

	var/usenanoui = 1 //Whether or not this client will use nanoUI, this doesn't do anything other than objects being able to check this.

	var/progress_bars = 1 //Whether to show progress bars when doing delayed actions.

	var/pulltoggle = 1 //If 1, the "pull" verb toggles between pulling/not pulling. If 0, the "pull" verb will always try to pull, and do nothing if already pulling.

	var/credits = CREDITS_ALWAYS
	var/jingle = JINGLE_CLASSIC

	var/client/client
	var/saveloaded = 0

/datum/preferences/New(client/C)
	client=C
	if(istype(C))
		init_subsections()
		var/theckey = C.ckey
		var/thekey = C.key
		spawn()
			if(!IsGuestKey(thekey))
				var/load_pref = load_preferences_sqlite(theckey)
				if(load_pref)
					while(!SS_READY(SShumans))
						sleep(1)
					try_load_save_sqlite(theckey, C, default_slot)
					return

			while(!SS_READY(SShumans))
				sleep(1)
			randomize_appearance_for()
			real_name = random_name(gender, species)
			save_character_sqlite(theckey, C, default_slot)
			saveloaded = 1

/datum/preferences/Destroy()
	for(var/entry in subsections)
		var/datum/preferences_subsection/prefs_ss = subsections[entry]
		if(prefs_ss && !prefs_ss.gcDestroyed)
			qdel(prefs_ss)
	subsections = null
	..()

/datum/preferences/proc/try_load_save_sqlite(var/theckey, var/theclient, var/theslot)
	var/attempts = 0
	while(!load_save_sqlite(theckey, theclient, theslot) && attempts < 5)
		sleep(15)
		attempts++
	if(attempts >= 5)//failsafe so people don't get locked out of the round forever
		randomize_appearance_for()
		real_name = random_name(gender, species)
		log_debug("Player [theckey] FAILED to load save 5 times and has been randomized.")
		log_admin("Player [theckey] FAILED to load save 5 times and has been randomized.")
		if(theclient)
			alert(theclient, "For some reason you've failed to load your save slot 5 times now, so you've been generated a random character. Don't worry, it didn't overwrite your old one.","Randomized Character", "OK")
	saveloaded = 1
	theclient << 'sound/misc/prefsready.wav'

/datum/preferences/proc/setup_character_options(var/dat, var/user)


	dat += {"<center><h2>Occupation Choices</h2>
	<a href='?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br></center>
	<h2>Identity</h2>
	<table width='100%'><tr><td width='75%' valign='top'>
	<a href='?_src_=prefs;preference=name;task=random'>Random Name</a>
	<a href='?_src_=prefs;preference=name'>Always Random Name: [be_random_name ? "Yes" : "No"]</a><br>
	<b>Name:</b> <a href='?_src_=prefs;preference=name;task=input'>[real_name]</a><BR>
	<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[gender == MALE ? "Male" : "Female"]</a><BR>
	<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[age]</a>
	</td><td valign='center'>
	<div class='statusDisplay'><center><img src=previewicon.png class="charPreview"><img src=previewicon2.png class="charPreview"></center></div>
	</td></tr></table>
	<h2>Body</h2>
	<a href='?_src_=prefs;preference=all;task=random'>Random Body</A>
	<a href='?_src_=prefs;preference=all'>Always Random Body: [be_random_body ? "Yes" : "No"]</A><br>
	<table width='100%'><tr><td width='24%' valign='top'>
	<b>Species:</b> <a href='?_src_=prefs;preference=species;task=input'>[species]</a><BR>
	<b>Tertiary Language:</b> <a href='byond://?src=\ref[user];preference=language;task=input'>[language]</a><br>
	<b>Skin Tone:</b> <a href='?_src_=prefs;preference=s_tone;task=input'>[species == "Human" ? "[-s_tone + 35]/220" : "[s_tone]"] - [skintone2racedescription(s_tone, species)]</a><br><BR>
	<b>Handicaps:</b> <a href='byond://?src=\ref[user];task=input;preference=disabilities'>Set</a><br>
	<b>Limbs:</b> <a href='byond://?_src_=prefs;subsection=limbs;task=menu'>Set</a><br>
	<b>Organs:</b> <a href='byond://?_src_=prefs;subsection=organs;task=menu'>Set</a><br>
	<b>Underwear:</b> [gender == MALE ? "<a href ='?_src_=prefs;preference=underwear;task=input'>[underwear_m[underwear]]</a>" : "<a href ='?_src_=prefs;preference=underwear;task=input'>[underwear_f[underwear]]</a>"]<br>
	<b>Backpack:</b> <a href ='?_src_=prefs;preference=bag;task=input'>[backbaglist[backbag]]</a><br>
	<b>Nanotrasen Relation</b>:<br><a href ='?_src_=prefs;preference=nt_relation;task=input'>[nanotrasen_relation]</a><br>
	<b>Flavor Text:</b><a href='byond://?src=\ref[user];preference=flavor_text;task=input'>Set</a><br>
	<b>Character records:</b>
	[jobban_isbanned(user, "Records") ? "Banned" : "<a href=\"byond://?src=\ref[user];preference=records;record=1\">Set</a>"]<br>
	<b>Bank account security preference:</b><a href ='?_src_=prefs;preference=bank_security;task=input'>[bank_security_num2text(bank_security)]</a> <br>
	</td><td valign='top' width='21%'>
	<h3>Hair Style</h3>
	<a href='?_src_=prefs;preference=h_style;task=input'>[h_style]</a><BR>
	<a href='?_src_=prefs;preference=previous_hair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_hair_style;task=input'>&gt;</a><BR>
	<span style='border:1px solid #161616; background-color: #[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair;task=input'>Change</a><BR>
	</td><td valign='top' width='21%'>
	<h3>Facial Hair Style</h3>
	<a href='?_src_=prefs;preference=f_style;task=input'>[f_style]</a><BR>
	<a href='?_src_=prefs;preference=previous_facehair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_facehair_style;task=input'>&gt;</a><BR>
	<span style='border: 1px solid #161616; background-color: #[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=facial;task=input'>Change</a><BR>
	</td><td valign='top' width='21%'>
	<h3>Eye Color</h3>
	<span style='border: 1px solid #161616; background-color: #[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=eyes;task=input'>Change</a><BR>
	</tr></td></table>
	"}

	return dat

/datum/preferences/proc/setup_UI(var/dat, var/user)


	dat += {"<b>UI Style:</b> <a href='?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>
	<b>Custom UI</b>(recommended for White UI): <span style='border:1px solid #161616; background-color: #[UI_style_color];'>&nbsp;&nbsp;&nbsp;</span><br>Color: <a href='?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a><br>
	Alpha(transparency): <a href='?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>
	"}

	return dat

/datum/preferences/proc/setup_special(var/dat, var/mob/user)
	if(user.client.holder)
		dat += {"
		<h1><font color=red>Admin Only Settings</font></h1>
	<div id="container" style="border:1px solid #000; width:96%; padding-left:2%; padding-right:2%; overflow:auto; padding-top:5px; padding-bottom:5px;">
	  <div id="leftDiv" style="width:50%;height:100%;float:left;">
		<b>Toggle Adminhelp Sound</b>
		<a href='?_src_=prefs;preference=hear_ahelp'><b>[toggles & SOUND_ADMINHELP ? "Enabled" : "Disabled"]</b></a><br>
		<b>Toggle Prayers</b>
		<a href='?_src_=prefs;preference=hear_prayer'><b>[toggles & CHAT_PRAYER ? "Enabled" : "Disabled"]</b></a><br>
		<b>Toggle Hear Radio</b>
		<a href='?_src_=prefs;preference=hear_radio'><b>[toggles & CHAT_GHOSTRADIO ? "Enabled" : "Disabled"]</b></a><br>
	  </div>
	  <div id="rightDiv" style="width:50%;height:100%;float:right;">
		<b>Toggle Attack Logs</b>
		<a href='?_src_=prefs;preference=hear_attack'><b>[toggles & CHAT_ATTACKLOGS ? "Enabled" : "Disabled"]</b></a><br>
		<b>Toggle Debug Logs</b>
		<a href='?_src_=prefs;preference=hear_debug'><b>[toggles & CHAT_DEBUGLOGS ? "Enabled" : "Disabled"]</b></a><br>
	  </div>
	</div>"}

	dat += {"
	<h1>General Settings</h1>
<div id="container" style="border:1px solid #000; width:96; padding-left:2%; padding-right:2%; overflow:auto; padding-top:5px; padding-bottom:5px;">
  <div id="leftDiv" style="width:50%;height:100%;float:left;">
	<b>Space Parallax:</b>
	<a href='?_src_=prefs;preference=parallax'><b>[space_parallax ? "Enabled" : "Disabled"]</b></a><br>
	<b>Parallax Speed:</b>
	<a href='?_src_=prefs;preference=p_speed'><b>[parallax_speed]</b></a><br>
	<b>Space Dust:</b>
	<a href='?_src_=prefs;preference=dust'><b>[space_dust ? "Yes" : "No"]</b></a><br>
	<b>Play admin midis:</b>
	<a href='?_src_=prefs;preference=hear_midis'><b>[(toggles & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>
	<b>Play lobby music:</b>
	<a href='?_src_=prefs;preference=lobby_music'><b>[(toggles & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>
	<b>Play Ambience:</b>
	<a href='?_src_=prefs;preference=ambience'><b>[(toggles & SOUND_AMBIENCE) ? "Yes" : "No"]</b></a><br>
	[(toggles & SOUND_AMBIENCE)? \
	"<b>Ambience Volume:</b><a href='?_src_=prefs;preference=ambience_volume'><b>[ambience_volume]</b></a><br>":""]
	<b>Hear streamed media:</b>
	<a href='?_src_=prefs;preference=jukebox'><b>[(toggles & SOUND_STREAMING) ? "Yes" : "No"]</b></a><br>
	<b>Streaming Program:</b>
	<a href='?_src_=prefs;preference=wmp'><b>[(usewmp) ? "WMP (compatibility)" : "VLC (requires plugin)"]</b></a><br>
	<b>Streaming Volume</b>
	<a href='?_src_=prefs;preference=volume'><b>[volume]</b></a><br>
	<b>Hear player voices</b>
	<a href='?_src_=prefs;preference=hear_voicesound'><b>[(hear_voicesound) ? "Yes" : "No"]</b></a><br>
	<b>Hear instruments</b>
	<a href='?_src_=prefs;preference=hear_instruments'><b>[(hear_instruments) ? "Yes":"No"]</b></a><br>
	<b>Progress Bars:</b>
	<a href='?_src_=prefs;preference=progbar'><b>[(progress_bars) ? "Yes" : "No"]</b></a><br>
	<b>Pause after first step:</b>
	<a href='?_src_=prefs;preference=stumble'><b>[(stumble) ? "Yes" : "No"]</b></a><br>
	<b>Pulling action:</b>
	<a href='?_src_=prefs;preference=pulltoggle'><b>[(pulltoggle) ? "Toggle Pulling" : "Always Pull"]</b></a><br>
	<b>Solo Antag Objectives:</b>
	<a href='?_src_=prefs;preference=antag_objectives'><b>[(antag_objectives) ? "Standard" : "Freeform"]</b></a><br>
  </div>
  <div id="rightDiv" style="width:50%;height:100%;float:right;">
	<b>Randomized Character Slot:</b>
	<a href='?_src_=prefs;preference=randomslot'><b>[randomslot ? "Yes" : "No"]</b></a><br>
	<b>Show Deadchat:</b>
	<a href='?_src_=prefs;preference=ghost_deadchat'><b>[(toggles & CHAT_DEAD) ? "On" : "Off"]</b></a><br>
	<b>Ghost Hearing:</b>
	<a href='?_src_=prefs;preference=ghost_ears'><b>[(toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearby Speech"]</b></a><br>
	<b>Ghost Sight:</b>
	<a href='?_src_=prefs;preference=ghost_sight'><b>[(toggles & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearby Emotes"]</b></a><br>
	<b>Ghost Radio:</b>
	<a href='?_src_=prefs;preference=ghost_radio'><b>[(toggles & CHAT_GHOSTRADIO) ? "All Chatter" : "Nearby Speakers"]</b></a><br>
	<b>Ghost PDA:</b>
	<a href='?_src_=prefs;preference=ghost_pda'><b>[(toggles & CHAT_GHOSTPDA) ? "All PDA Messages" : "No PDA Messages"]</b></a><br>
	<b>Show OOC:</b>
	<a href='?_src_=prefs;preference=show_ooc'><b>[(toggles & CHAT_OOC) ? "Enabled" : "Disabled"]</b></a><br>
	<b>Show LOOC:</b>
	<a href='?_src_=prefs;preference=show_looc'><b>[(toggles & CHAT_LOOC) ? "Enabled" : "Disabled"]</b></a><br>
	<b>Show Tooltips:</b>
	<a href='?_src_=prefs;preference=tooltips'><b>[(tooltips) ? "Yes" : "No"]</b></a><br>
	<b>Adminhelp Special Tab:</b>
	<a href='?_src_=prefs;preference=special_popup'><b>[special_popup_text2num[special_popup+1]]</b></a><br>
	<b>Attack Animations:<b>
	<a href='?_src_=prefs;preference=attack_animation'><b>[attack_animation ? (attack_animation == ITEM_ANIMATION? "Item Anim." : "Person Anim.") : "No"]</b></a><br>
	<b>Show Credits <span title='&#39;No Reruns&#39; will roll credits only if an admin customized something about this round&#39;s credits, or if a rare and exclusive episode name was selected thanks to something uncommon happening that round.'>(?):</span><b>
	<a href='?_src_=prefs;preference=credits'><b>[credits]</b></a><br>
	<b>Server Shutdown Jingle <span title='These jingles will only play if credits don&#39;t roll for you that round. &#39;Classics&#39; will only play &#39;APC Destroyed&#39; and &#39;Banging Donk&#39;, &#39;All&#39; will play the previous plus retro videogame sounds.'>(?):</span><b>
	<a href='?_src_=prefs;preference=jingle'><b>[jingle]</b></a><br>
	<b>Credits/Jingle Volume:</b>
	<a href='?_src_=prefs;preference=credits_volume'><b>[credits_volume]</b></a><br>
	<b>Window Flashing</b>
	<a href='?_src_=prefs;preference=window_flashing'><b>[(window_flashing) ? "Yes":"No"]</b></a><br>
  </div>
</div>"}

	if(config.allow_Metadata)
		dat += "<b>OOC Notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'> Edit </a><br>"

	return dat

/datum/preferences/proc/getPrefLevelText(var/datum/job/job)
	if(GetJobDepartment(job, 1) & job.flag)
		return "High"
	else if(GetJobDepartment(job, 2) & job.flag)
		return "Medium"
	else if(GetJobDepartment(job, 3) & job.flag)
		return "Low"
	else
		return "NEVER"

/datum/preferences/proc/getPrefLevelUpOrDown(var/datum/job/job, var/inc)
	if(GetJobDepartment(job, 1) & job.flag)
		if(inc)
			return "NEVER"
		else
			return "Medium"
	else if(GetJobDepartment(job, 2) & job.flag)
		if(inc)
			return "High"
		else
			return "Low"
	else if(GetJobDepartment(job, 3) & job.flag)
		if(inc)
			return "Medium"
		else
			return "NEVER"
	else
		if(inc)
			return "Low"
		else
			return "High"

/datum/preferences/proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Chief Engineer", "AI"), widthPerColumn = 295, height = 620)
	if(!job_master)
		return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.
	var/width = widthPerColumn


	var/HTML = "<link href='./common.css' rel='stylesheet' type='text/css'><body>"
	HTML += {"<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=input;level=' + level + ';text=' + encodeURIComponent(rank); return false; }
			function mouseDown(event,levelup,leveldown,rank){
				return false;
				}

			function mouseUp(event,levelup,leveldown,rank){
				if(event.button == 0 || event.button == 1)
					{
					//alert("left click " + levelup + " " + rank);
					setJobPrefRedirect(1, rank);
					return false;
					}
				if(event.button == 2)
					{
					//alert("right click " + leveldown + " " + rank);
					setJobPrefRedirect(0, rank);
					return false;
					}

				return true;
				}
			</script>"} //the event.button == 1 check is brought to you by legacy IE running in wine


	HTML += {"<center>
		<b>Choose occupation chances</b><br>
		<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br><div>
		<a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>
		<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>
		<table width='100%' cellpadding='1' cellspacing='0'>"}


	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	if (!job_master)
		return
	for(var/datum/job/job in job_master.occupations)
		index += 1
		if((index >= limit) || (job.title in splitJobs))
			width += widthPerColumn
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/i = 0, i < (limit - index), i += 1)
					HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
			HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
		var/rank = job.title
		lastJob = job
		if(jobban_isbanned(user, rank))
			HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[BANNED]</b></font></td></tr>"
			continue
		if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS]</font></td></tr>"
			continue
		if((rank in command_positions) || (rank == "AI"))//Bold head jobs
			if(job.alt_titles)
				HTML += "<b><span class='dark'><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">[GetPlayerAltTitle(job)]</a></span></b>"
			else
				HTML += "<b><span class='dark'>[rank]</span></b>"
		else
			if(job.alt_titles)
				HTML += "<span class='dark'><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">[GetPlayerAltTitle(job)]</a></span>"
			else
				HTML += "<span class='dark'>[rank]</span>"


		HTML += "</td><td width='40%'>"



		var/prefLevelLabel = "ERROR"
		var/prefLevelColor = "pink"
		var/prefUpperLevel = -1
		var/prefLowerLevel = -1

		if(GetJobDepartment(job, 1) & job.flag)
			prefLevelLabel = "High"
			prefLevelColor = "slateblue"
			prefUpperLevel = 4
			prefLowerLevel = 2
		else if(GetJobDepartment(job, 2) & job.flag)
			prefLevelLabel = "Medium"
			prefLevelColor = "green"
			prefUpperLevel = 1
			prefLowerLevel = 3
		else if(GetJobDepartment(job, 3) & job.flag)
			prefLevelLabel = "Low"
			prefLevelColor = "orange"
			prefUpperLevel = 2
			prefLowerLevel = 4
		else
			prefLevelLabel = "NEVER"
			prefLevelColor = "red"
			prefUpperLevel = 3
			prefLowerLevel = 1

		if(job.species_whitelist.len)
			if(!job.species_whitelist.Find(src.species))
				prefLevelLabel = "Unavailable"
				prefLevelColor = "gray"
				prefUpperLevel = 0
				prefLowerLevel = 0
		else if(job.species_blacklist.len)
			if(job.species_blacklist.Find(src.species))
				prefLevelLabel = "Unavailable"
				prefLevelColor = "gray"
				prefUpperLevel = 0
				prefLowerLevel = 0

		HTML += "<a class='white' onmouseup='javascript:return mouseUp(event,[prefUpperLevel],[prefLowerLevel], \"[rank]\");' oncontextmenu='javascript:return mouseDown(event,[prefUpperLevel],[prefLowerLevel], \"[rank]\");'>"


		//if(job.alt_titles)
			//HTML += "</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'><a>&nbsp</a></td><td><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></td></tr>"
		HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
		HTML += "</a></td></tr>"


	for(var/i = 1, i < (limit - index), i += 1)
		HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
	HTML += {"</td'></tr></table>
		</center></table>"}
	switch(alternate_option)
		if(GET_RANDOM_JOB)
			HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>Get random job if preferences unavailable</a></center><br>"
		if(BE_ASSISTANT)
			HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>Be assistant if preference unavailable</a></center><br>"
		if(RETURN_TO_LOBBY)
			HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>Return to lobby if preference unavailable</a></center><br>"


	HTML += {"<center><a href='?_src_=prefs;preference=job;task=reset'>Reset</a></center>
		</tt>"}
	user << browse(null, "window=preferences")
	//user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_content(HTML)
	popup.open(0)
	return

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	update_preview_icon()
	var/preview_front = fcopy_rsc(preview_icon_front)
	var/preview_side = fcopy_rsc(preview_icon_side)
	user << browse_rsc(preview_front, "previewicon.png")
	user << browse_rsc(preview_side, "previewicon2.png")
	var/dat = "<html><link href='./common.css' rel='stylesheet' type='text/css'><body>"

	if(!IsGuestKey(user.key))

		dat += {"<center>
			Slot <b>[slot_name]</b> -
			<a href=\"byond://?src=\ref[user];preference=open_load_dialog\">Load slot</a> -
			<a href=\"byond://?src=\ref[user];preference=save\">Save slot</a> -
			<a href=\"byond://?src=\ref[user];preference=reload\">Reload slot</a>
			</center><hr>"}
	else
		dat += "Please create an account to save your preferences."

	dat += "<center><a href='?_src_=prefs;preference=tab;tab=0' [current_tab == CHARACTER_SETUP ? "class='linkOn'" : ""]>Character Settings</a> | "
	dat += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == UI_SETUP ? "class='linkOn'" : ""]>UI Settings</a> | "
	dat += "<a href='?_src_=prefs;preference=tab;tab=2' [current_tab == GENERAL_SETUP ? "class='linkOn'" : ""]>General Settings</a> | "
	dat += "<a href='?_src_=prefs;preference=tab;tab=3' [current_tab == SPECIAL_ROLES_SETUP ? "class='linkOn'" : ""]>Special Roles</a></center><br>"

	if(appearance_isbanned(user))
		dat += "<b>You are banned from using custom names and appearances. You can continue to adjust your characters, but you will be randomised once you join the game.</b><br>"

	switch(current_tab)
		if(CHARACTER_SETUP)
			dat = setup_character_options(dat, user)
		if(UI_SETUP)
			dat = setup_UI(dat, user)
		if(GENERAL_SETUP)
			dat = setup_special(dat, user)
		if(SPECIAL_ROLES_SETUP)
			dat = configure_special_roles(dat, user)

	dat += "<br><hr>"

	if(!IsGuestKey(user.key))
		dat += {"<center><a href='?_src_=prefs;preference=load'>Undo</a> |
			<a href='?_src_=prefs;preference=save'>Save Setup</a> | "}

	dat += {"<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>
		</center></body></html>"}

	//user << browse(dat, "window=preferences;size=560x580")
	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 680, 640)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/ShowDisabilityState(mob/user,flag,label)
	if(flag==DISABILITY_FLAG_FAT && species!="Human")
		return "<li><i>[species] cannot be fat.</i></li>"
	return "<li><b>[label]:</b> <a href=\"?_src_=prefs;task=input;preference=disabilities;disability=[flag]\">[disabilities & flag ? "Yes" : "No"]</a></li>"

/datum/preferences/proc/SetDisabilities(mob/user)
	var/HTML = "<body>"

	HTML += {"<tt><center>
		<b>Choose disabilities</b><ul>"}
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_NEARSIGHTED,"Needs Glasses")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_FAT,        "Obese")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_EPILEPTIC,  "Seizures")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_DEAF,       "Deaf")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_BLIND,      "Blind")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_MUTE,       "Mute")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_VEGAN,      "Vegan")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_ASTHMA,      "Asthma")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_LACTOSE,     "Lactose Intolerant")
	/*HTML += ShowDisabilityState(user,DISABILITY_FLAG_COUGHING,   "Coughing")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_TOURETTES,   "Tourettes") Still working on it! -Angelite*/


	HTML += {"</ul>
		<a href=\"?_src_=prefs;task=close;preference=disabilities\">\[Done\]</a>
		<a href=\"?_src_=prefs;task=reset;preference=disabilities\">\[Reset\]</a>
		</center></tt>"}
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=disabil;size=350x300")
	return

/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"

	HTML += {"<tt><center>
		<b>Set Character Records</b><br>
		<a href=\"byond://?src=\ref[user];preference=records;task=med_record\">Medical Records</a><br>"}
	if(length(med_record) <= 40)
		HTML += "[med_record]"
	else
		HTML += "[copytext(med_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">Employment Records</a><br>"

	if(length(gen_record) <= 40)
		HTML += "[gen_record]"
	else
		HTML += "[copytext(gen_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">Security Records</a><br>"

	if(length(sec_record) <= 40)
		HTML += "[sec_record]<br>"
	else
		HTML += "[copytext(sec_record, 1, 37)]...<br>"


	HTML += {"<br>
		<a href=\"byond://?src=\ref[user];preference=records;records=-1\">\[Done\]</a>
		</center></tt>"}
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=records;size=350x300")
	return


/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/SetJob(mob/user, role, inc)
	var/datum/job/job = job_master.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(job.species_blacklist.Find(src.species)) //Check if our species is in the blacklist
		to_chat(user, "<span class='notice'>Your species ("+src.species+") can't have this job!</span>")
		return

	if(job.species_whitelist.len) //Whitelist isn't empty - check if our species is in the whitelist
		if(!job.species_whitelist.Find(src.species))
			var/allowed_species = ""
			for(var/S in job.species_whitelist)
				allowed_species += "[S]"

				if(job.species_whitelist.Find(S) != job.species_whitelist.len)
					allowed_species += ", "

			to_chat(user, "<span class='notice'>Only the following species can have this job: [allowed_species]. Your species is ([src.species]).</span>")
			return

	if(inc == null)
		if(GetJobDepartment(job, 1) & job.flag)
			SetJobDepartment(job, 1)
		else if(GetJobDepartment(job, 2) & job.flag)
			SetJobDepartment(job, 2)
		else if(GetJobDepartment(job, 3) & job.flag)
			SetJobDepartment(job, 3)
		else//job = Never
			SetJobDepartment(job, 4)
	else
		inc = text2num(inc)
		var/desiredLevel = getPrefLevelUpOrDown(job,inc)
		while(getPrefLevelText(job) != desiredLevel)
			if(GetJobDepartment(job, 1) & job.flag)
				SetJobDepartment(job, 1)
			else if(GetJobDepartment(job, 2) & job.flag)
				SetJobDepartment(job, 2)
			else if(GetJobDepartment(job, 3) & job.flag)
				SetJobDepartment(job, 3)
			else//job = Never
				SetJobDepartment(job, 4)

		/*if(level < 4)
			to_chat(world,"setting [job] to [level+1]")
			SetJobDepartment(job,level+1)
		else
			to_chat(world,"setting [job] to 1");SetJobDepartment(job,1)
*/
	SetChoices(user)
	return 1
/datum/preferences/proc/ResetJobs()
	job_civilian_high = 0
	job_civilian_med = 0
	job_civilian_low = 0

	job_medsci_high = 0
	job_medsci_med = 0
	job_medsci_low = 0

	job_engsec_high = 0
	job_engsec_med = 0
	job_engsec_low = 0

/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)
		return 0
	switch(job.department_flag)
		if(CIVILIAN)
			switch(level)
				if(1)
					return job_civilian_high
				if(2)
					return job_civilian_med
				if(3)
					return job_civilian_low
		if(MEDSCI)
			switch(level)
				if(1)
					return job_medsci_high
				if(2)
					return job_medsci_med
				if(3)
					return job_medsci_low
		if(ENGSEC)
			switch(level)
				if(1)
					return job_engsec_high
				if(2)
					return job_engsec_med
				if(3)
					return job_engsec_low
	return 0

/datum/preferences/proc/SetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)
		return 0
	switch(level)
		if(1)//Only one of these should ever be active at once so clear them all here
			job_civilian_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			return 1
		if(2)//Set current highs to med, then reset them
			job_civilian_med |= job_civilian_high
			job_medsci_med |= job_medsci_high
			job_engsec_med |= job_engsec_high

			job_civilian_high = 0
			job_medsci_high = 0
			job_engsec_high = 0

	switch(job.department_flag)
		if(CIVILIAN)
			switch(level)
				if(2)
					job_civilian_high = job.flag
					job_civilian_med &= ~job.flag
				if(3)
					job_civilian_med |= job.flag
					job_civilian_low &= ~job.flag
				else
					job_civilian_low |= job.flag
		if(MEDSCI)
			switch(level)
				if(2)
					job_medsci_high = job.flag
					job_medsci_med &= ~job.flag
				if(3)
					job_medsci_med |= job.flag
					job_medsci_low &= ~job.flag
				else
					job_medsci_low |= job.flag
		if(ENGSEC)
			switch(level)
				if(2)
					job_engsec_high = job.flag
					job_engsec_med &= ~job.flag
				if(3)
					job_engsec_med |= job.flag
					job_engsec_low &= ~job.flag
				else
					job_engsec_low |= job.flag
	return 1


/datum/preferences/proc/SetDepartmentFlags(datum/job/job, level, new_flags)	//Sets a department's preference flags (job_medsci_high, job_engsec_med - those variables) to 'new_flags'.
																		//First argument can either be a job, or the department's flag (ENGSEC, MISC, ...)
																		//Second argument can be either text ("high", "MEDIUM", "LoW") or number (1-high, 2-med, 3-low)

																		//NOTE: If you're not sure what you're doing, be careful when using this proc.

	//Determine department flag
	var/d_flag
	if(istype(job))
		d_flag = job.department_flag
	else
		d_flag = job

	//Determine department level
	var/d_level
	if(istext(level))
		switch(lowertext(level))
			if("high")
				d_level = 1
			if("med", "medium")
				d_level = 2
			if("low")
				d_level = 3
	else
		d_level = level

	switch(d_flag)
		if(CIVILIAN)
			switch(d_level)
				if(1) //high
					job_civilian_high = new_flags
				if(2) //med
					job_civilian_med = new_flags
				if(3) //low
					job_civilian_low = new_flags
		if(MEDSCI)
			switch(d_level)
				if(1) //high
					job_medsci_high = new_flags
				if(2) //med
					job_medsci_med = new_flags
				if(3) //low
					job_medsci_low = new_flags
		if(ENGSEC)
			switch(d_level)
				if(1) //high
					job_engsec_high = new_flags
				if(2) //med
					job_engsec_med = new_flags
				if(3) //low
					job_engsec_low = new_flags

/datum/preferences/proc/SetRole(var/mob/user, var/list/href_list)
	var/role_id = href_list["role_id"]
//	to_chat(user, "<span class='info'>Toggling role [role_id] (currently at [roles[role_id]])...</span>")
	if(!(role_id in special_roles))
		to_chat(user, "<span class='danger'>BUG: Unable to find role [role_id].</span>")
		return 0

	if(roles[role_id] == null || roles[role_id] == "")
		roles[role_id] = 0

	var/question={"Would you like to be \a [role_id] this round?

No/Yes:  Only affects this round.
Never/Always: Saved for later rounds.

NOTE:  The change will take effect AFTER any current recruiting periods."}
	var/answer = alert(question,"Role Preference", "Never", "No", "Yes", "Always")
	var/newval=0
	switch(answer)
		if("Never")
			newval = ROLEPREF_NEVER|ROLEPREF_SAVE
		if("No")
			newval = ROLEPREF_NO
		if("Yes")
			newval = ROLEPREF_YES
		if("Always")
			newval = ROLEPREF_ALWAYS|ROLEPREF_SAVE
	roles[role_id] = (roles[role_id] & ~ROLEPREF_VALMASK) | newval // We only set the lower 2 bits, leaving polled and friends untouched.

	save_preferences_sqlite(user, user.ckey)
	save_character_sqlite(user.ckey, user, default_slot)

	return 1

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!user)
		return
	var/datum/preferences_subsection/subsection = subsections[href_list["subsection"]]
	if(subsection)
		var/result = subsection.process_link(user, href_list)
		if(result)
			return result
	//testing("preference=[href_list["preference"]]")
	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
					alternate_option += 1
				else if(alternate_option == RETURN_TO_LOBBY)
					alternate_option = 0
				else
					return 0
				SetChoices(user)
			if ("alt_title")
				var/datum/job/job = locate(href_list["job"])
				if (job)
					var/choices = list(job.title) + job.alt_titles
					var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
					if(choice)
						SetPlayerAltTitle(job, choice)
						SetChoices(user)
			if("input")
				SetJob(user, href_list["text"], href_list["level"])
			else
				SetChoices(user)
		return 1
	else if(href_list["preference"] == "disabilities")

		switch(href_list["task"])
			if("close")
				user << browse(null, "window=disabil")
				ShowChoices(user)
			if("reset")
				disabilities=0
				SetDisabilities(user)
			if("input")
				var/dflag=text2num(href_list["disability"])
				if(dflag >= 0)
					if(!(dflag==DISABILITY_FLAG_FAT && species!="Human"))
						disabilities ^= text2num(href_list["disability"]) //MAGIC
				SetDisabilities(user)
			else
				SetDisabilities(user)
		return 1

	else if(href_list["preference"] == "records")
		if(text2num(href_list["record"]) >= 1)
			SetRecords(user)
			return
		else
			user << browse(null, "window=records")
		if(href_list["task"] == "med_record")
			var/medmsg = input(usr,"Set your medical notes here.","Medical Records",html_decode(med_record)) as message

			if(medmsg != null)
				medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
				medmsg = html_encode(medmsg)

				med_record = medmsg
				SetRecords(user)

		if(href_list["task"] == "sec_record")
			var/secmsg = input(usr,"Set your security notes here.","Security Records",html_decode(sec_record)) as message

			if(secmsg != null)
				secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
				secmsg = html_encode(secmsg)

				sec_record = secmsg
				SetRecords(user)
		if(href_list["task"] == "gen_record")
			var/genmsg = input(usr,"Set your employment notes here.","Employment Records",html_decode(gen_record)) as message

			if(genmsg != null)
				genmsg = copytext(genmsg, 1, MAX_PAPER_MESSAGE_LEN)
				genmsg = html_encode(genmsg)

				gen_record = genmsg
				SetRecords(user)

	else if(href_list["preference"] == "set_roles")
		return SetRoles(user,href_list)

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = random_name(gender,species)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					r_hair = rand(0,255)
					g_hair = rand(0,255)
					b_hair = rand(0,255)
				if("h_style")
					h_style = random_hair_style(gender, species)
				if("facial")
					r_facial = rand(0,255)
					g_facial = rand(0,255)
					b_facial = rand(0,255)
				if("f_style")
					f_style = random_facial_hair_style(gender, species)
				if("underwear")
					underwear = rand(1,underwear_m.len)
					ShowChoices(user)
				if("eyes")
					r_eyes = rand(0,255)
					g_eyes = rand(0,255)
					b_eyes = rand(0,255)
				if("s_tone")
					s_tone = random_skin_tone(species)
				if("bag")
					backbag = rand(1,5)
				/*if("skin_style")
					h_style = random_skin_style(gender)*/
				if("all")
					randomize_appearance_for()	//no params needed
		if("input")
			switch(href_list["preference"])
				if("name")
					var/new_name = reject_bad_name( input(user, "Choose your character's name:", "Character Preference")  as text|null )
					if(new_name)
						real_name = new_name
					else
						to_chat(user, "<span class='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</span>")
				if("next_hair_style")
					h_style = next_list_item(h_style, valid_sprite_accessories(hair_styles_list, null, species)) //gender intentionally left null so speshul snowflakes can cross-hairdress
				if("previous_hair_style")
					h_style = previous_list_item(h_style, valid_sprite_accessories(hair_styles_list, null, species)) //gender intentionally left null so speshul snowflakes can cross-hairdress
				if("next_facehair_style")
					f_style = next_list_item(f_style, valid_sprite_accessories(facial_hair_styles_list, gender, species))
				if("previous_facehair_style")
					f_style = previous_list_item(f_style, valid_sprite_accessories(facial_hair_styles_list, gender, species))
				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)
				if("species")

					var/list/new_species = list("Human")
					var/prev_species = species
					var/whitelisted = 0

					if(config.usealienwhitelist) //If we're using the whitelist, make sure to check it!
						for(var/S in whitelisted_species)
							if(is_alien_whitelisted(user,S))
								new_species += S
								whitelisted = 1
						if(!whitelisted)
							alert(user, "You cannot change your species as you need to be whitelisted. If you wish to be whitelisted contact an admin in-game, on the forums, or on IRC.")
					else //Not using the whitelist? Aliens for everyone!
						new_species = whitelisted_species

					species = input("Please select a species", "Character Generation", null) in new_species

					if(prev_species != species)
						//grab one of the valid hair styles for the newly chosen species
						var/list/valid_hairstyles = valid_sprite_accessories(hair_styles_list, gender, species, HAIRSTYLE_CANTRIP)
						if(valid_hairstyles.len)
							h_style = pick(valid_hairstyles)
						else
							//this shouldn't happen
							h_style = hair_styles_list["Bald"]

						//grab one of the valid facial hair styles for the newly chosen species
						var/list/valid_facialhairstyles = valid_sprite_accessories(facial_hair_styles_list, gender, species)
						if(valid_facialhairstyles.len)
							f_style = pick(valid_facialhairstyles)
						else
							//this shouldn't happen
							f_style = facial_hair_styles_list["Shaved"]

						//reset hair colour and skin colour
						r_hair = 0//hex2num(copytext(new_hair, 2, 4))
						g_hair = 0//hex2num(copytext(new_hair, 4, 6))
						b_hair = 0//hex2num(copytext(new_hair, 6, 8))

						s_tone = 0

					for(var/datum/job/job in job_master.occupations)
						if(job.species_blacklist.Find(species)) //If new species is in a job's blacklist
							for(var/i = 1 to 3)
								var/F = GetJobDepartment(job, i)

								F &= ~job.flag //Disable that job in our preferences
								SetDepartmentFlags(job, i, F)

							to_chat(usr, "<span class='info'>Your new species ([species]) is blacklisted from [job.title].</span>")

						if(job.species_whitelist.len) //If the job has a species whitelist
							if(!job.species_whitelist.Find(species)) //And it doesn't include our new species
								for(var/i = 1 to 3)
									var/F = GetJobDepartment(job, i)

									if(F & job.flag)
										to_chat(usr, "<span class='info'>Your new species ([species]) can't be [job.title]. Your preferences have been adjusted.</span>")

									F &= ~job.flag //Disable that job in our preferences
									SetDepartmentFlags(job, i, F)

				if("language")
					var/list/new_languages = list("None")

					for(var/L in all_languages)
						var/datum/language/lang = all_languages[L]
						if(lang.flags & CAN_BE_SECONDARY_LANGUAGE)
							new_languages += lang.name

					language = input("Please select a secondary language", "Character Generation", null) in new_languages

				if("metadata")
					var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , metadata)  as message|null
					if(new_metadata)
						metadata = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

				if("hair")
					if(species == "Human" || species == "Unathi")
						var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference", rgb(r_hair, g_hair, b_hair)) as color|null
						if(new_hair)
							r_hair = hex2num(copytext(new_hair, 2, 4))
							g_hair = hex2num(copytext(new_hair, 4, 6))
							b_hair = hex2num(copytext(new_hair, 6, 8))

				if("h_style")
					var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in valid_sprite_accessories(hair_styles_list, null, species) //gender intentionally left null so speshul snowflakes can cross-hairdress
					if(new_h_style)
						h_style = new_h_style

				if("facial")
					if(species == "Human" || species == "Unathi")
						var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", rgb(r_facial, g_facial, b_facial)) as color|null
						if(new_facial)
							r_facial = hex2num(copytext(new_facial, 2, 4))
							g_facial = hex2num(copytext(new_facial, 4, 6))
							b_facial = hex2num(copytext(new_facial, 6, 8))

				if("f_style")
					var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_sprite_accessories(facial_hair_styles_list, gender, species)
					if(new_f_style)
						f_style = new_f_style

				if("underwear")
					var/list/underwear_options
					if(gender == MALE)
						underwear_options = underwear_m
					else
						underwear_options = underwear_f

					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
					if(new_underwear)
						underwear = underwear_options.Find(new_underwear)
					ShowChoices(user)

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", rgb(r_eyes, g_eyes, b_eyes)) as color|null
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))

				if("s_tone")
					if(species == "Human")
						var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
						if(new_s_tone)
							s_tone = 35 - max(min(round(new_s_tone),220),1)
							to_chat(user,"You're now [skintone2racedescription(s_tone, species)].")
					else if(species == "Vox")//Can't reference species flags here, sorry.
						var/skin_c = input(user, "Choose your Vox's skin color:\n(1 = Green, 2 = Brown, 3 = Gray, 4 = Light Green, 5 = Azure, 6 = Emerald)", "Character Preference") as num|null
						if(skin_c)
							s_tone = max(min(round(skin_c),6),1)
							to_chat(user,"You will now be [skintone2racedescription(s_tone,species)] in color.")
					else
						to_chat(user,"Your species doesn't have different skin tones. Yet?")
						return

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference") as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
					if(new_backbag)
						backbag = backbaglist.Find(new_backbag)

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						nanotrasen_relation = new_relation

				if("bank_security")
					var/new_bank_security = input(user, BANK_SECURITY_EXPLANATION, "Character Preference")  as null|anything in bank_security_text2num_associative
					if(!isnull(new_bank_security))
						bank_security = bank_security_text2num_associative[new_bank_security]

				if("flavor_text")
					flavor_text = input(user,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(flavor_text)) as message

				if("skin_style")
					var/skin_style_name = input(user, "Select a new skin style") as null|anything in list("default1", "default2", "default3")
					if(!skin_style_name)
						return

		else
			switch(href_list["preference"])
				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE
					f_style = random_facial_hair_style(gender, species)
					h_style = random_hair_style(gender, species)

				if("hear_adminhelps")
					toggles ^= SOUND_ADMINHELP

				if("ui")
					switch(UI_style)
						if("Midnight")
							UI_style = "Orange"
						if("Orange")
							UI_style = "old"
						if("old")
							UI_style = "White"
						else
							UI_style = "Midnight"

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI colour, dark colours are not recommended!") as color|null
					if(!UI_style_color_new)
						return
					UI_style_color = UI_style_color_new

				if("UIalpha")
					var/UI_style_alpha_new = input(user, "Select a new alpha(transparency) parameter for UI, between 50 and 255") as num
					if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50))
						return
					UI_style_alpha = UI_style_alpha_new

				if("parallax")
					space_parallax = !space_parallax
					if(user && user.hud_used)
						user.hud_used.update_parallax_existence()

				if("dust")
					space_dust = !space_dust
					if(user && user.hud_used)
						user.hud_used.update_parallax_existence()

				if("p_speed")
					parallax_speed = min(max(input(user, "Enter a number between 0 and 5 included (default=2)","Parallax Speed Preferences",parallax_speed),0),5)

				if("name")
					be_random_name = !be_random_name

				if("all")
					be_random_body = !be_random_body

				if("special_popup")
					var/choice = input(user, "Set your special tab preferences:", "Settings") as null|anything in special_popup_text2num
					if(!isnull(choice))
						special_popup = special_popup_text2num[choice]

				if("randomslot")
					randomslot = !randomslot

				if("hear_midis")
					toggles ^= SOUND_MIDI
					if(!(toggles & SOUND_MIDI))
						user << sound(null, repeat = 0, wait = 0, volume = 0, channel = CHANNEL_ADMINMUSIC)

				if("lobby_music")
					if(config.no_lobby_music)
						to_chat(user, "DEBUG: Lobby music is globally disabled via server config.")
					toggles ^= SOUND_LOBBY
					if(toggles & SOUND_LOBBY)
						if(istype(user,/mob/new_player))
							user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBY)
					else
						user << sound(null, repeat = 0, wait = 0, volume = 0, channel = CHANNEL_LOBBY)

				if("volume")
					user.client.set_new_volume()

				if("ambience")
					if(config.no_ambience)
						to_chat(user, "DEBUG: Ambience is globally disabled via server config.")
					toggles ^= SOUND_AMBIENCE
					if(!(toggles & SOUND_AMBIENCE))
						user << sound(null, repeat = 0, wait = 0, volume = 0, channel = CHANNEL_AMBIENCE)
				if("ambience_volume")
					ambience_volume = min(max(input(user, "Enter the new volume you wish to use. (0-100)","Ambience Volume Preferences", ambience_volume), 0), 100)
				if("jukebox")
					toggles ^= SOUND_STREAMING

				if("wmp")
					usewmp = !usewmp
					if(!user.client.media)
						return
					user.client.media.stop_music()
					user.client.media.playerstyle = (usewmp ? PLAYER_OLD_HTML : PLAYER_HTML)
					if(toggles & SOUND_STREAMING)
						user.client.media.open()
						user.client.media.update_music()

				if("tooltips")
					tooltips = !tooltips
				if("progbar")
					progress_bars = !progress_bars
				if("stumble")
					stumble = !stumble
				if("hear_voicesound")
					hear_voicesound = !hear_voicesound
				if("hear_instruments")
					hear_instruments = !hear_instruments
				if("pulltoggle")
					pulltoggle = !pulltoggle

				if("ghost_deadchat")
					toggles ^= CHAT_DEAD

				if("ghost_ears")
					toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					toggles ^= CHAT_GHOSTSIGHT

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO

				if("ghost_pda")
					toggles ^= CHAT_GHOSTPDA

				if("show_ooc")
					toggles ^= CHAT_OOC

				if("show_looc")
					toggles ^= CHAT_LOOC

				if("save")
					if(world.timeofday >= (lastPolled + POLLED_LIMIT) || user.client.holder)
						SetRoles(user,href_list)
						save_preferences_sqlite(user, user.ckey)
						save_character_sqlite(user.ckey, user, default_slot)
						lastPolled = world.timeofday
					else
						to_chat(user, "You need to wait [round((((lastPolled + POLLED_LIMIT) - world.timeofday) / 10))] seconds before you can save again.")
					//random_character_sqlite(user, user.ckey)

				if("reload")
					load_preferences_sqlite(user.ckey)
					load_save_sqlite(user.ckey, user, default_slot)

				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)
						// DO NOT update window as it'd steal focus.
						return

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					var/num = text2num(href_list["num"])
					load_save_sqlite(user.ckey, user, num)
					default_slot = num
					close_load_dialog(user)

				if("tab")
					if(href_list["tab"])
						current_tab = text2num(href_list["tab"])

				if("attack_animation")
					if(attack_animation == NO_ANIMATION)
						item_animation_viewers |= client
						attack_animation = ITEM_ANIMATION

					else if(attack_animation == ITEM_ANIMATION)
						attack_animation = PERSON_ANIMATION
						person_animation_viewers |= client
						item_animation_viewers -= client

					else if(attack_animation == PERSON_ANIMATION)
						attack_animation = NO_ANIMATION
						person_animation_viewers -= client

				if("credits")
					switch(credits)
						if(CREDITS_NEVER)
							credits = CREDITS_ALWAYS
						if(CREDITS_ALWAYS)
							credits = CREDITS_NO_RERUNS
						if(CREDITS_NO_RERUNS)
							credits = CREDITS_NEVER

				if("jingle")
					switch(jingle)
						if(JINGLE_NEVER)
							jingle = JINGLE_CLASSIC
						if(JINGLE_CLASSIC)
							jingle = JINGLE_ALL
						if(JINGLE_ALL)
							jingle = JINGLE_NEVER

				if("credits_volume")
					credits_volume = min(max(input(user, "Enter the new volume you wish to use. (0-100, default is 75)","Credits/Jingle Volume", credits_volume), 0), 100)

				if("window_flashing")
					window_flashing = !window_flashing
				
				if("antag_objectives")
					antag_objectives = !antag_objectives
				
			if(user.client.holder)
				switch(href_list["preference"])
					if("hear_ahelp")
						toggles ^= SOUND_ADMINHELP

					if("hear_prayer")
						toggles ^= CHAT_PRAYER

					if("hear_radio")
						toggles ^= CHAT_GHOSTRADIO

					if("hear_attack")
						toggles ^= CHAT_ATTACKLOGS

					if("hear_debug")
						toggles ^= CHAT_DEBUGLOGS

	ShowChoices(user)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, safety = 0)
	if(be_random_name)
		real_name = random_name(gender,species)
	if(config.humans_need_surnames && species == "Human")
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(last_names)]"

	character.real_name = real_name
	character.name = character.real_name
	character.flavor_text = flavor_text
	if(character.dna)
		character.dna.real_name = character.real_name
		character.dna.flavor_text = character.flavor_text

	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record


	if(be_random_body)
		//random_character(gender) - This just selects a random character from the OLD character database.
		randomize_appearance_for() // Correct.

	character.setGender(gender)
	character.age = age

	character.my_appearance.r_eyes = r_eyes
	character.my_appearance.g_eyes = g_eyes
	character.my_appearance.b_eyes = b_eyes

	character.my_appearance.r_hair = r_hair
	character.my_appearance.g_hair = g_hair
	character.my_appearance.b_hair = b_hair

	character.my_appearance.r_facial = r_facial
	character.my_appearance.g_facial = g_facial
	character.my_appearance.b_facial = b_facial

	character.my_appearance.s_tone = s_tone

	character.my_appearance.h_style = h_style
	character.my_appearance.f_style = f_style


	character.skills = skills

	// Destroy/cyborgize organs

	for(var/name in organ_data)
		var/datum/organ/external/O = character.organs_by_name[name]
		var/datum/organ/internal/I = character.internal_organs_by_name[name]
		var/status = organ_data[name]

		if(status == "amputated")
			O.status &= ~ORGAN_ROBOT
			O.status &= ~ORGAN_PEG
			O.amputated = 1
			O.status |= ORGAN_DESTROYED
			O.destspawn = 1
		else if(status == "cyborg")
			O.status &= ~ORGAN_PEG
			O.status |= ORGAN_ROBOT
		else if(status == "peg")
			O.status &= ~ORGAN_ROBOT
			O.status |= ORGAN_PEG
		else if(status == "assisted")
			I.mechassist()
		else if(status == "mechanical")
			I.mechanize()
		else
			continue
	var/datum/species/chosen_species = all_species[species]
	if( (disabilities & DISABILITY_FLAG_FAT) && (chosen_species.anatomy_flags & CAN_BE_FAT) )
		character.mutations += M_FAT
		character.mutations += M_OBESITY
	if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
		character.disabilities|=NEARSIGHTED
	if(disabilities & DISABILITY_FLAG_EPILEPTIC)
		character.disabilities|=EPILEPSY
	if(disabilities & DISABILITY_FLAG_DEAF)
		character.sdisabilities|=DEAF
	if(disabilities & DISABILITY_FLAG_BLIND)
		character.sdisabilities|=BLIND
	/*if(disabilities & DISABILITY_FLAG_COUGHING)
		character.sdisabilities|=COUGHING
	if(disabilities & DISABILITY_FLAG_TOURETTES)
		character.sdisabilities|=TOURETTES Still working on it. - Angelite */

	if(underwear > underwear_m.len || underwear < 1)
		underwear = 0 //I'm sure this is 100% unnecessary, but I'm paranoid... sue me. //HAH NOW NO MORE MAGIC CLONING UNDIES
	character.underwear = underwear

	if(backbag > 5 || backbag < 1)
		backbag = 1 //Same as above
	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(character)) //Ghosts get neuter by default
			message_admins("[character] ([character.ckey]) has spawned with their gender as plural or neuter. Please notify coders.")
			character.setGender(MALE)

/datum/preferences/proc/open_load_dialog(mob/user)
	var/database/query/q = new
	var/list/name_list[MAX_SAVE_SLOTS]

	q.Add("select real_name, player_slot from players where player_ckey=?", user.ckey)
	if(q.Execute(db))
		while(q.NextRow())
			name_list[q.GetColumn(2)] = q.GetColumn(1)
	else
		message_admins("Error in open_load_dialog [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
		warning("Error in open_load_dialog [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0
	var/dat = "<center><b>Select a character slot to load</b><hr>"
	var/counter = 1
	while(counter <= MAX_SAVE_SLOTS)
		if(counter==default_slot)
			dat += "<a href='?_src_=prefs;preference=changeslot;num=[counter];'><b>[name_list[counter]]</b></a><br>"
		else
			if(!name_list[counter])
				dat += "<a href='?_src_=prefs;preference=changeslot;num=[counter];'>Character[counter]</a><br>"
			else
				dat += "<a href='?_src_=prefs;preference=changeslot;num=[counter];'>[name_list[counter]]</a><br>"
		counter++

	dat += "</center>"

	var/datum/browser/browser = new(user, "saves", null, 300, 340)
	browser.set_content(dat)
	browser.open(use_onclose=FALSE)

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")

/datum/preferences/proc/configure_special_roles(var/dat, var/mob/user)
	dat+={"<form method="get">
	<input type="hidden" name="src" value="\ref[src]" />
	<input type="hidden" name="preference" value="set_roles" />
	<h1>Special Role Preferences</h1>
	<p>Please note that this also handles in-round polling for things like Raging Mages and Borers.</p>
	<fieldset>
		<legend>Legend</legend>
		<dl>
			<dt>Never:</dt>
			<dd>Decline this role for this round and all future rounds. You will not be polled again.</dd>
			<dt>No:</dt>
			<dd>Default. Decline this role for this round only.</dd>
			<dt>Yes:</dt>
			<dd>Accept this role for this round only.</dd>
			<dt>Always:</dt>
			<dd>Accept this role for this round and all future rounds. You will not be polled again.</dd>
		</dl>
	</fieldset>
	<h2>TO SAVE YOUR SPECIAL ROLE PREFERENCES, PRESS SUBMIT, NOT SAVE SETUP.</h2>

	<table border=\"0\" padding-left = 20px;>
		<thead>
			<tr>
				<th colspan='6' height = '40px' valign='bottom'><h1>Antagonist Roles</h1></th>
			</tr>
		</thead>
		<tbody>"}


	dat += {"<tr>
				<th><u>Role</u></th>
				<th>Instructions</th>
				<th class="clmNever">Never</th>
				<th class="clmNo">No</th>
				<th class="clmYes">Yes</th>
				<th class="clmAlways">Always</th>
			</tr>"}

	if(isantagbanned(user))
		dat += "<th colspan='6' text-align = 'center' height = '40px'><h1>You are banned from antagonist roles</h1></th>"
	else
		for(var/role_id in antag_roles)
			dat += "<tr>"
			dat += "<td>[capitalize(role_id)]</td>"
			if(antag_roles[role_id]) //if mode is available on the server
				if(jobban_isbanned(user, role_id))
					dat += "<td class='column clmNever' colspan='5'><font color=red><b>\[BANNED]</b></font></td>"
				else if(role_id == "pai candidate")
					if(jobban_isbanned(user, "pAI"))
						dat += "<td class='column clmNever' colspan='5'><font color=red><b>\[BANNED]</b></font></td>"
				else
					var/wikiroute = role_wiki[role_id]
					var/desire = get_role_desire_str(roles[role_id])
					dat += {"<td class='column'>[wikiroute ? "<a HREF='?src=\ref[user];getwiki=[wikiroute]'>Role Wiki</a>" : "None"]</td>
							<td class='column clmNever'><label class="fullsize"><input type="radio" name="[role_id]" value="[ROLEPREF_NEVER|ROLEPREF_SAVE]" title="Never"[desire=="Never"?" checked='checked'":""]/></label></td>
							<td class='column clmNo'><label class="fullsize"><input type="radio" name="[role_id]" value="[ROLEPREF_NO|ROLEPREF_SAVE]" title="No"[desire=="No"?" checked='checked'":""] /></label></td>
							<td class='column clmYes'><label class="fullsize"><input type="radio" name="[role_id]" value="[ROLEPREF_YES|ROLEPREF_SAVE]" title="Yes"[desire=="Yes"?" checked='checked'":""] /></label></td>
							<td class='column clmAlways'><label class="fullsize"><input type="radio" name="[role_id]" value="[ROLEPREF_ALWAYS|ROLEPREF_SAVE]" title="Always"[desire=="Always"?" checked='checked'":""] /></label></td>
					</tr>"}

	dat += "<th colspan='6' height = '60px' valign='bottom'><h1>Non-Antagonist Roles</h1></th>"

	dat += {"<tr>
				<th><u>Role</u></th>
				<th>Instructions</th>
				<th class="clmNever">Never</th>
				<th class="clmNo">No</th>
				<th class="clmYes">Yes</th>
				<th class="clmAlways">Always</th>
			</tr>"}

	for(var/role_id in nonantag_roles)
		dat += "<tr>"
		dat += "<td>[capitalize(role_id)]</td>"
		if(nonantag_roles[role_id]) //if mode is available on the server
			if(jobban_isbanned(user, role_id))
				dat += "<td class='column clmNever' colspan='5'><font color=red><b>\[BANNED]</b></font></td>"
			else if(role_id == "pai candidate")
				if(jobban_isbanned(user, "pAI"))
					dat += "<td class='column clmNever' colspan='5'><font color=red><b>\[BANNED]</b></font></td>"
			else
				var/wikiroute = role_wiki[role_id]
				var/desire = get_role_desire_str(roles[role_id])
				dat += {"<td class='column'>[wikiroute ? "<a HREF='?src=\ref[user];getwiki=[wikiroute]'>Role Wiki</a>" : ""]</td>
						<td class='column clmNever'><label class="fullsize"><input type="radio" name="[role_id]" value="[ROLEPREF_NEVER|ROLEPREF_SAVE]" title="Never"[desire=="Never"?" checked='checked'":""]/></label></td>
						<td class='column clmNo'><label class="fullsize"><input type="radio" name="[role_id]" value="[ROLEPREF_NO|ROLEPREF_SAVE]" title="No"[desire=="No"?" checked='checked'":""] /></label></td>
						<td class='column clmYes'><label class="fullsize"><input type="radio" name="[role_id]" value="[ROLEPREF_YES|ROLEPREF_SAVE]" title="Yes"[desire=="Yes"?" checked='checked'":""] /></label></td>
						<td class='column clmAlways'><label class="fullsize"><input type="radio" name="[role_id]" value="[ROLEPREF_ALWAYS|ROLEPREF_SAVE]" title="Always"[desire=="Always"?" checked='checked'":""] /></label></td>
				</tr>"}

	dat += {"</tbody>
		</table>
		<br>
		<input type="submit" value="Submit" />
		<input type="reset" value="Reset" />
		</form>
		<br>"}
	return dat

/datum/preferences/proc/SetRoles(var/mob/user, var/list/href_list)
	// We just grab the role from the POST(?) data.
	var/updated = 0
	for(var/role_id in special_roles)
		if(!(role_id in href_list))
			continue
		var/oldval=text2num(roles[role_id])
		roles[role_id] = text2num(href_list[role_id])
		if(oldval!=roles[role_id])
			updated = 1
			to_chat(user, "<span class='info'>Set role [role_id] to [get_role_desire_str(user.client.prefs.roles[role_id])]!</span>")

	if(!updated)
		to_chat(user, "<span class='warning'>No changes to role preferences found!</span>")
		return 0

	save_preferences_sqlite(user, user.ckey)
	save_character_sqlite(user.ckey, user, default_slot)
	return 1

/datum/preferences/Topic(href, href_list)
	if(!client)
		return
	if(!usr)
		WARNING("No usr on Topic for [client] with href [href]!")
		return
	if(client.mob!=usr)
		to_chat(usr, "YOU AREN'T ME GO AWAY")
		return
	switch(href_list["preference"])
		if("set_roles")
			return SetRoles(usr, href_list)
		if("set_role")
			return SetRole(usr, href_list)

/client/verb/modify_preferences(page as num)
	set name = "modifypreferences"
	set hidden = 1
	if(!prefs.saveloaded)
		to_chat(src, "<span class='warning'>Your character preferences have not yet loaded.</span>")
		return
	switch(page)
		if(1)
			prefs.current_tab = GENERAL_SETUP
		if(2)
			prefs.current_tab = SPECIAL_ROLES_SETUP
	prefs.ShowChoices(usr)
