
/datum/preferences/proc/setup_character_options(var/dat, var/user)

	var/race_skin_tone_desc = skintone2racedescription(get_pref(/datum/preference_setting/numerical/s_tone), get_pref(/datum/preference_setting/string/species))
	dat += {"<center>
    <h2>Occupation Choices</h2>
    <a href='?_src_=prefs;preference=jobs;task=menu'>Set Occupation Preferences</a><br>
	</center>

	<h2>Identity</h2>
	<table width='100%'><tr><td width='75%' valign='top'>
		<a href='?_src_=prefs;preference=real_name;task=random'>Random Name</a>

		<a href='?_src_=prefs;preference=random_name;task=input'>Always Random Name: [get_pref(/datum/preference_setting/toggle/be_random_name) ? "Yes" : "No"]</a><br>

		<b>Name:</b> <a href='?_src_=prefs;preference=real_name;task=input'>[get_pref(/datum/preference_setting/string/real_name)]</a><BR>

		<b>Gender:</b> <a href='?_src_=prefs;preference=gender;task=input'>[get_pref(/datum/preference_setting/enum/gender) == MALE ? "Male" : "Female"]</a><BR>

		<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[get_pref(/datum/preference_setting/numerical/age)]</a>
	</td><td valign='center'>
		<div class='statusDisplay'style="height: 64px; width: 128px; padding:0px"><center><img src=previewicon.png class="charPreview"><img src=previewicon2.png class="charPreview"></center></div>
		<b>Background </b><a href='?_src_=prefs;preference=previous_preview_background;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_preview_background;task=input'>&gt;</a><BR>
	</td></tr></table>

	<h2>Body</h2>
	<a href='?_src_=prefs;preference=all;task=random_body'>Random Body</a>
	<a href='?_src_=prefs;preference=random_body;task=input'>
		Always Random Body: [get_pref(/datum/preference_setting/toggle/be_random_body) ? "Yes" : "No"]
	</a><br>

	<table width='100%'>
		<tr>
		<td width='37%' valign='top'>
			<br/>
			<b>Species:</b>
			<a href='?_src_=prefs;preference=species;task=input'>
			[get_pref(/datum/preference_setting/string/species)]
			</a><br>

			<b>Tertiary Language:</b>
			<a href='byond://?src=\ref[user];preference=language;task=input'>
			[get_pref(/datum/preference_setting/string/language)]
			</a><br>

			<b>Skin Tone:</b>
			<a href='?_src_=prefs;preference=skin_tone;task=input'>
			[get_pref(/datum/preference_setting/string/species) == "Human" ? "[-get_pref(/datum/preference_setting/numerical/s_tone) + 35]/220" : "[get_pref(/datum/preference_setting/numerical/s_tone)]"] - [race_skin_tone_desc]
			</a><br><br>
		</td>

		<td valign='top' width='21%'>
			<center>
			<h3>Hair Style</h3>
			<a href='?_src_=prefs;preference=hair_style_name;task=input'>
				[get_pref(/datum/preference_setting/string/h_style)]
			</a><br>
			<a href='?_src_=prefs;preference=hair_style_name;task=previous_hair_style'>&lt;</a>
			<a href='?_src_=prefs;preference=hair_style_name;task=next_hair_style'>&gt;</a><br>
			<span style='border:1px solid #161616; background-color: #[num2hex(get_pref(/datum/preference_setting/numerical/r_hair), 2)][num2hex(get_pref(/datum/preference_setting/numerical/g_hair), 2)][num2hex(get_pref(/datum/preference_setting/numerical/b_hair), 2)];'>&nbsp;&nbsp;&nbsp;</span>
			<a href='?_src_=prefs;preference=hair_style_name;task=input_hair_color'>Change</a><br>
			</center>
		</td>

		<td valign='top' width='21%'>
			<h3>Facial Hair Style</h3>
			<center>
			<a href='?_src_=prefs;preference=facial_style_name;task=input'>
				[get_pref(/datum/preference_setting/string/f_style)]
			</a><br>
			<a href='?_src_=prefs;preference=facial_style_name;task=previous_facehair_style'>&lt;</a>
			<a href='?_src_=prefs;preference=facial_style_name;task=next_facehair_style'>&gt;</a><br>
			<span style='border: 1px solid #161616; background-color: #[num2hex(get_pref(/datum/preference_setting/numerical/r_facial), 2)][num2hex(get_pref(/datum/preference_setting/numerical/g_facial), 2)][num2hex(get_pref(/datum/preference_setting/numerical/b_facial), 2)];'>&nbsp;&nbsp;&nbsp;</span>
			<a href='?_src_=prefs;preference=facial_style_name;task=input_facial_hair_color'>Change</a><br>
			</center>
		</td>

		<td valign='top' width='21%'>
			<h3>Eye Color</h3>
			<center>
			<span style='border: 1px solid #161616; background-color: #[num2hex(get_pref(/datum/preference_setting/numerical/r_eyes), 2)][num2hex(get_pref(/datum/preference_setting/numerical/g_eyes), 2)][num2hex(get_pref(/datum/preference_setting/numerical/b_eyes), 2)];'>&nbsp;&nbsp;&nbsp;</span>
			<a href='?_src_=prefs;preference=eyes_red;task=input'>Change</a><br>
			</center>
		</td>
		</tr>
	</table>

	<b>Handicaps:</b>
	<a href='?src=\ref[user];task=input;preference=disabilities'>Set</a><br>

	<b>Limbs:</b>
	<a href='?_src_=prefs;subsection=limbs;task=menu'>Set</a><br>

	<b>Organs:</b>
	<a href='?_src_=prefs;subsection=organs;task=menu'>Set</a><br>

	<b>Underwear:</b>
	<a href ='?_src_=prefs;preference=underwear;task=input'>[get_pref(/datum/preference_setting/enum/gender) == MALE ? "[underwear_m[get_pref(/datum/preference_setting/numerical/underwear)]]" : "[underwear_f[get_pref(/datum/preference_setting/numerical/underwear)]]"]
	</a>
	<br>

	<b>Backpack:</b>
	<a href='?_src_=prefs;preference=backbag;task=input'>
	[backbaglist[get_pref(/datum/preference_setting/numerical/backbag)]]
	</a><br>

	<b>Nanotrasen Relation:</b>
	<a href='?_src_=prefs;preference=nanotrasen_relation;task=input'>
	[get_pref(/datum/preference_setting/enum/string/nanotrasen_relation)]
	</a><br>

	<b>Flavor Text:</b>
	<a href='?src=\ref[user];preference=flavor_text;task=input'>Set</a><br>

	<b>Character records:</b>
	[jobban_isbanned(user, "Records") ? "Banned" : "<a href='?src=\ref[user];preference=records;record=1'>Set</a>"]<br>

	<b>Bank account security preference:</b>
	<a href='?_src_=prefs;preference=bank_security;task=input'>
	[bank_security_num2text(get_pref(/datum/preference_setting/enum/bank_security))]
	</a><br>

	<b>Percent of wages sent to ID virtual wallet:</b>
	<a href='?_src_=prefs;preference=wage_ratio;task=input'>
	[get_pref(/datum/preference_setting/numerical/wage_ratio)]
	</a><br>
	"}


	return dat

/datum/preferences/proc/setup_UI(var/dat, var/user)


	dat += {"<b>UI Style:</b> <a href='?_src_=prefs;preference=UI_style;task=input'><b>[get_pref(/datum/preference_setting/string/UI_style)]</b></a><br>
	<b>Custom UI</b>(recommended for White UI): <span style='border:1px solid #161616; background-color: #[get_pref(/datum/preference_setting/string/UI_style_color)];'>&nbsp;&nbsp;&nbsp;</span><br>Color: <a href='?_src_=prefs;preference=UIcolor'><b>[get_pref(/datum/preference_setting/string/UI_style_color)]</b></a><br>
	Alpha(transparency): <a href='?_src_=prefs;preference=UI_style_alpha;task=input'><b>[get_pref(/datum/preference_setting/numerical/UI_style_alpha)]</b></a><br>
	"}

	return dat

/datum/preferences/proc/setup_special(var/dat, var/mob/user)
	if(user.client.holder)
		dat += {"
		<h1><font color=red>Admin Only Settings</font></h1>

	<div id="container" style="border:1px solid #000; width:96%; padding-left:2%; padding-right:2%; overflow:auto; padding-top:5px; padding-bottom:5px;">
	  <div id="leftDiv" style="width:50%;height:100%;float:left;">
		<b>Toggle Adminhelp Sound</b>
		<a href='?_src_=prefs;preference=toggles;task=input;toggle=[SOUND_ADMINHELP]'><b>[get_pref(/datum/preference_setting/binary_flag/toggles) & SOUND_ADMINHELP ? "Enabled" : "Disabled"]</b></a><br>

		<b>Toggle Prayers</b>
		<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_PRAYER]'><b>[get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_PRAYER ? "Enabled" : "Disabled"]</b></a><br>

		<b>Toggle Hear Radio</b>
		<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_GHOSTRADIO]'><b>[get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_GHOSTRADIO ? "Enabled" : "Disabled"]</b></a><br>
	  </div>

	  <div id="rightDiv" style="width:50%;height:100%;float:right;">
		<b>Toggle Attack Logs</b>
		<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_ATTACKLOGS]'><b>[get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_ATTACKLOGS ? "Enabled" : "Disabled"]</b></a><br>

		<b>Toggle Debug Logs</b>
		<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_DEBUGLOGS]'><b>[get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_DEBUGLOGS ? "Enabled" : "Disabled"]</b></a><br>

		<b>De-admin on login</b>
		<a href='?_src_=prefs;preference=toggles;task=input;toggle=[AUTO_DEADMIN]'><b>[get_pref(/datum/preference_setting/binary_flag/toggles) & AUTO_DEADMIN ? "Enabled" : "Disabled"]</b></a><br>

	  </div>
	</div>"}

	dat += {"
	<h1>General Settings</h1>
<div id="container" style="border:1px solid #000; width:96; padding-left:2%; padding-right:2%; overflow:auto; padding-top:5px; padding-bottom:5px;">
  <div id="leftDiv" style="width:50%;height:100%;float:left;">

	<b>FPS:</b>
	<a href='?_src_=prefs;preference=fps;task=input'><b>[get_pref(/datum/preference_setting/numerical/fps)]</b></a><br>

	<b>Space Parallax:</b>
	<a href='?_src_=prefs;preference=space_parallax;task=input'><b>[get_pref(/datum/preference_setting/toggle/space_parallax) ? "Enabled" : "Disabled"]</b></a><br>

	<b>Parallax Speed:</b>
	<a href='?_src_=prefs;preference=parallax_speed;task=input'><b>[get_pref(/datum/preference_setting/numerical/parallax_speed) ]</b></a><br>

	<b>Space Dust:</b>
	<a href='?_src_=prefs;preference=space_dust;task=input'><b>[get_pref(/datum/preference_setting/toggle/space_dust) ? "Yes" : "No"]</b></a><br>

	<b>Play admin midis:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[SOUND_MIDI]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>

	<b>Play lobby music:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[SOUND_LOBBY]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>

	<b>Play Ambience:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[SOUND_AMBIENCE]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & SOUND_AMBIENCE) ? "Yes" : "No"]</b></a><br>
	[(get_pref(/datum/preference_setting/binary_flag/toggles) & SOUND_AMBIENCE)? \
	"<b>Ambience Volume:</b><a href='?_src_=prefs;preference=ambience_volume;task=input'><b>[get_pref(/datum/preference_setting/numerical/ambience_volume)]</b></a><br>":""]

	<b>Radio Headset Sounds:</b>
	<a href='?_src_=prefs;preference=headset_sound;task=input'><b>[headset_sound_text2num[get_pref(/datum/preference_setting/numerical/headset_sound)+1]]</b></a><br>

	<b>Hear streamed media:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[SOUND_STREAMING]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & SOUND_STREAMING) ? "Yes" : "No"]</b></a><br>

	<b>Streaming Program:</b>
	<a href='?_src_=prefs;preference=usewmp;task=input'><b>[get_pref(/datum/preference_setting/toggle/usewmp) ? "WMP (compatibility)" : "VLC (requires plugin)"]</b></a><br>

	<b>Streaming Volume</b>
	<a href='?_src_=prefs;preference=volume;task=input'><b>[get_pref(/datum/preference_setting/numerical/volume) ]</b></a><br>

	<b>Hear player voices</b>
	<a href='?_src_=prefs;preference=hear_voicesound;task=input'><b>[(get_pref(/datum/preference_setting/toggle/hear_voicesound)) ? "Yes" : "No"]</b></a><br>

	<b>Hear instruments</b>
	<a href='?_src_=prefs;preference=hear_instruments;task=input'><b>[(get_pref(/datum/preference_setting/toggle/hear_instruments)) ? "Yes":"No"]</b></a><br>

	<b>Progress Bars:</b>
	<a href='?_src_=prefs;preference=progress_bars;task=input'><b>[get_pref(/datum/preference_setting/toggle/progress_bars) ? "Yes" : "No"]</b></a><br>

	<b>Pause after first step:</b>
	<a href='?_src_=prefs;preference=stumble;task=input'><b>[get_pref(/datum/preference_setting/toggle/stumble) ? "Yes" : "No"]</b></a><br>

	<b>Pulling action:</b>
	<a href='?_src_=prefs;preference=pulltoggle;task=input'><b>[get_pref(/datum/preference_setting/toggle/pulltoggle) ? "Toggle Pulling" : "Always Pull"]</b></a><br>

	<b>Solo Antag Objectives:</b>
	<a href='?_src_=prefs;preference=antag_objectives;task=input'><b>[get_pref(/datum/preference_setting/toggle/antag_objectives) ? "Standard" : "Freeform"]</b></a><br>

	<b>Say bubbles:</b>
	<a href='?_src_=prefs;preference=typing_indicator;task=input'><b>[get_pref(/datum/preference_setting/toggle/typing_indicator) ? "Active" : "Inactive"]</b></a><br>
  </div>

  <div id="rightDiv" style="width:50%;height:100%;float:right;">

	<b>Randomized Character Slot:</b>
	<a href='?_src_=prefs;preference=randomslot;task=input'><b>[get_pref(/datum/preference_setting/toggle/randomslot) ? "Yes" : "No"]</b></a><br>

	<b>Show Deadchat:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_DEAD]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_DEAD) ? "On" : "Off"]</b></a><br>

	<b>Ghost Hearing:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_GHOSTEARS]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_GHOSTEARS) ? "All Speech" : "Nearby Speech"]</b></a><br>

	<b>Ghost Sight:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_GHOSTSIGHT]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearby Emotes"]</b></a><br>

	<b>Ghost Radio:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_GHOSTRADIO]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_GHOSTRADIO) ? "All Chatter" : "Nearby Speakers"]</b></a><br>

	<b>Ghost PDA:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_GHOSTPDA]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_GHOSTPDA) ? "All PDA Messages" : "No PDA Messages"]</b></a><br>

	<b>Show OOC:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_OOC]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_OOC) ? "Enabled" : "Disabled"]</b></a><br>

	<b>Show LOOC:</b>
	<a href='?_src_=prefs;preference=toggles;task=input;toggle=[CHAT_LOOC]'><b>[(get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_LOOC) ? "Enabled" : "Disabled"]</b></a><br>

	<b>Show Tooltips:</b>
	<a href='?_src_=prefs;preference=tooltips;task=input'><b>[get_pref(/datum/preference_setting/toggle/tooltips) ? "Yes" : "No"]</b></a><br>

	<b>Adminhelp Special Tab:</b>
	<a href='?_src_=prefs;preference=special;task=input'><b>[special_popup_text2num[get_pref(/datum/preference_setting/enum/special_popup)+1]]</b></a><br>

	<b>Attack Animations:<b>
	<a href='?_src_=prefs;preference=attack_animation;task=input'><b>[get_pref(/datum/preference_setting/enum/attack_animations) ? (get_pref(/datum/preference_setting/enum/attack_animations) == ITEM_ANIMATION? "Item Anim." : "Person Anim.") : "No"]</b></a><br>

	<b>Show Credits <span title='&#39;No Reruns&#39; will roll credits only if an admin customized something about this round&#39;s credits, or if a rare and exclusive episode name was selected thanks to something uncommon happening that round.'>(?):</span><b>
	<a href='?_src_=prefs;preference=credits;task=input'><b>[get_pref(/datum/preference_setting/enum/credits)]</b></a><br>

	<b>Server Shutdown Jingle <span title='These jingles will only play if credits don&#39;t roll for you that round. &#39;Classics&#39; will only play &#39;APC Destroyed&#39; and &#39;Banging Donk&#39;, &#39;All&#39; will play the previous plus retro videogame sounds.'>(?):</span><b>
	<a href='?_src_=prefs;preference=jingle;task=input'><b>[get_pref(/datum/preference_setting/enum/jingle)]</b></a><br>
	<b>Credits/Jingle Volume:</b>

	<a href='?_src_=prefs;preference=credits_volume;task=input'><b>[get_pref(/datum/preference_setting/numerical/credits_volume)]</b></a><br>

	<b>Window Flashing</b>
	<a href='?_src_=prefs;preference=window_flashing;task=input'><b>[get_pref(/datum/preference_setting/toggle/window_flashing) ? "Yes":"No"]</b></a><br>

	<b>Fancy tgui:</b>
	<a href='?_src_=prefs;preference=tgui_fancy;task=input'>[get_pref(/datum/preference_setting/toggle/tgui_fancy) ? "Enabled" : "Disabled"]</a><br>

	<center>Runechat prefererences</center>

	<b>Chat on map for mobs:</b>
	<a href='?_src_=prefs;preference=mob_chat_on_map;task=input'>[get_pref(/datum/preference_setting/toggle/mob_chat_on_map) ? "Enabled" : "Disabled"]</a><br>

	<b>Chat on map for objects:</b>
	<a href='?_src_=prefs;preference=obj_chat_on_map;task=input'>[get_pref(/datum/preference_setting/toggle/obj_chat_on_map)  ? "Enabled" : "Disabled"]</a><br>

	<b>No goonchat messages for objects:</b>
	<a href='?_src_=prefs;preference=no_goonchat_for_obj;task=input'>[get_pref(/datum/preference_setting/toggle/no_goonchat_for_obj) ? "Enabled" : "Disabled"]</a><br>

	<b>Runechat message char limit:</b>
	<a href='?_src_=prefs;preference=max_chat_length;task=input'>[get_pref(/datum/preference_setting/numerical/max_chat_length)]</a><br>
  </div>
</div>"}

	if(config.allow_Metadata)
		dat += "<b>OOC Notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'> Edit </a><br>"

	return dat

/datum/preferences/proc/getPrefLevelText(var/datum/job/job)
	var/list/jobs = get_pref(/datum/preference_setting/assoc_list_setting/jobs)
	switch(jobs[job.title])
		if(JOB_PREF_HIGH)
			return "High"
		if(JOB_PREF_MED)
			return "Medium"
		if(JOB_PREF_LOW)
			return "Low"
	return "NEVER"

/datum/preferences/proc/SetJobsChoice(mob/user, limit = 16, list/splitJobs = list("Chief Engineer", "Head of Security"), widthPerColumn = 295, height = 620)
	if(!job_master)
		return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.
	var/width = widthPerColumn


	var/HTML = "<link href='./common.css' rel='stylesheet' type='text/css'><body>"
	HTML += {"<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=jobs;task=input;level=' + level + ';text=' + encodeURIComponent(rank); return false; }
			function mouseDown(event,rank){
				return false;
				}

			function mouseUp(event,rank){
				if(event.button == 0 || event.button == 1)
					{
					setJobPrefRedirect(1, rank);
					return false;
					}
				if(event.button == 2)
					{
					setJobPrefRedirect(0, rank);
					return false;
					}

				return true;
				}
			</script>"} //the event.button == 1 check is brought to you by legacy IE running in wine


	HTML += {"<center>
		<b>Choose occupation chances</b><br>
		<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br><div>
		<a href='?_src_=prefs;preference=jobs;task=close'>Done</a></center><br>
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
				HTML += "<b><span class='dark'><a href=\"byond://?src=\ref[user];preference=jobs;task=alt_title;job=\ref[job]\">[GetPlayerAltTitle(job)]</a></span></b>"
			else
				HTML += "<b><span class='dark'>[rank]</span></b>"
		else
			if(job.alt_titles)
				HTML += "<span class='dark'><a href=\"byond://?src=\ref[user];preference=jobs;task=alt_title;job=\ref[job]\">[GetPlayerAltTitle(job)]</a></span>"
			else
				HTML += "<span class='dark'>[rank]</span>"


		HTML += "</td><td width='40%'>"

		var/prefLevelLabel = "NEVER"
		var/prefLevelColor = "red"
		var/species = get_pref(/datum/preference_setting/string/species)
		var/list/jobs = get_pref(/datum/preference_setting/assoc_list_setting/jobs)

		if(job.species_whitelist.len && !job.species_whitelist.Find(species))
			prefLevelLabel = "Unavailable"
			prefLevelColor = "gray"
		else if(job.species_blacklist.Find(species))
			prefLevelLabel = "Unavailable"
			prefLevelColor = "gray"
		else
			switch(jobs[job.title])
				if(JOB_PREF_HIGH)
					prefLevelLabel = "High"
					prefLevelColor = "slateblue"
				if(JOB_PREF_MED)
					prefLevelLabel = "Medium"
					prefLevelColor = "green"
				if(JOB_PREF_LOW)
					prefLevelLabel = "Low"
					prefLevelColor = "orange"

		HTML += "<a class='white' onmouseup='javascript:return mouseUp(event, \"[rank]\");' oncontextmenu='javascript:return mouseDown(event, \"[rank]\");'>"
		HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
		HTML += "</a></td></tr>"


	for(var/i = 1, i < (limit - index), i += 1)
		HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
	HTML += {"</td'></tr></table>
		</center></table>"}
	var/alternate_option = get_pref(/datum/preference_setting/enum/alternate_option)
	switch(alternate_option)
		if(GET_EMPTY_JOB)
			HTML += "<center><br><a href='?_src_=prefs;preference=jobs;task=random'>Get unique job</a></center><br>"
		if(GET_RANDOM_JOB)
			HTML += "<center><br><a href='?_src_=prefs;preference=jobs;task=random'>Get random job if preferences unavailable</a></center><br>"
		if(BE_ASSISTANT)
			HTML += "<center><br><a href='?_src_=prefs;preference=jobs;task=random'>Be assistant if preference unavailable</a></center><br>"
		if(RETURN_TO_LOBBY)
			HTML += "<center><br><a href='?_src_=prefs;preference=jobs;task=random'>Return to lobby if preference unavailable</a></center><br>"


	HTML += {"<center><a href='?_src_=prefs;preference=jobs;task=reset'>Reset</a></center>
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
			<a href=\"byond://?_src_=prefs;action=open_load_dialog\">Load slot</a> -
			<a href=\"byond://?_src_=prefs;action=save\">Save slot</a> -
			<a href=\"byond://?_src_=prefs;action=reload\">Reload slot</a>
			</center><hr>"}
	else
		dat += "Please create an account to save your preferences."

	dat += "<center><a href='?_src_=prefs;action=tab;tab=0' [current_tab == CHARACTER_SETUP ? "class='linkOn'" : ""]>Character Settings</a> | "
	dat += "<a href='?_src_=prefs;action=tab;tab=1' [current_tab == UI_SETUP ? "class='linkOn'" : ""]>UI Settings</a> | "
	dat += "<a href='?_src_=prefs;action=tab;tab=2' [current_tab == GENERAL_SETUP ? "class='linkOn'" : ""]>General Settings</a> | "
	dat += "<a href='?_src_=prefs;action=tab;tab=3' [current_tab == SPECIAL_ROLES_SETUP ? "class='linkOn'" : ""]>Special Roles</a></center><br>"

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

	dat += "<div style='float:none;'><br><hr><center>"

	if(!IsGuestKey(user.key))
		dat += {"<a href='?_src_=prefs;action=load'>Undo</a> |
			<a href='?_src_=prefs;action=save'>Save Setup</a> | "}

	dat += {"<a href='?_src_=prefs;action=reset_all'>Reset Setup</a>
		</center></div></body></html>"}

	//user << browse(HTML_SKELETON(dat), "window=preferences;size=560x580")
	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 680, 720)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/ShowDisabilityState(mob/user,flag,label)
	var/species = get_pref(/datum/preference_setting/string/species)
	var/disabilities = get_pref(/datum/preference_setting/binary_flag/disabilities)
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
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_LISP,       "Lisp")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_ANEMIA,       "Anemia")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_EHS,       "Electromagnetic Hypersensitivity")
	/*HTML += ShowDisabilityState(user,DISABILITY_FLAG_COUGHING,   "Coughing")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_TOURETTES,   "Tourettes") Still working on it! -Angelite*/


	HTML += {"</ul>
		<a href=\"?_src_=prefs;task=close;preference=disabilities\">\[Done\]</a>
		<a href=\"?_src_=prefs;task=reset;preference=disabilities\">\[Reset\]</a>
		</center></tt>"}
	user << browse(null, "window=preferences")
	user << browse(HTML_SKELETON(HTML), "window=disabil;size=350x300")
	return

/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = ""

	HTML += {"<tt><center>
		<b>Set Character Records</b><br>
		<a href=\"byond://?src=\ref[user];preference=records;task=med_record\">Medical Records</a><br>"}
	var/med_record = get_pref(/datum/preference_setting/string/med_record)
	if(length(med_record) <= 40)
		HTML += "[med_record]"
	else
		HTML += "[copytext(med_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">Employment Records</a><br>"

	var/gen_record = get_pref(/datum/preference_setting/string/gen_record)
	if(length(gen_record) <= 40)
		HTML += "[gen_record]"
	else
		HTML += "[copytext(gen_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">Security Records</a><br>"

	var/sec_record = get_pref(/datum/preference_setting/string/sec_record)
	if(length(sec_record) <= 40)
		HTML += "[sec_record]<br>"
	else
		HTML += "[copytext(sec_record, 1, 37)]...<br>"


	HTML += {"<br>
		<a href=\"byond://?src=\ref[user];preference=records;records=-1\">\[Done\]</a>
		</center></tt>"}
	user << browse(null, "window=preferences")
	user << browse(HTML_SKELETON(HTML), "window=records;size=350x300")
	return


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
		if(counter==get_pref(/datum/preference_setting/numerical/default_slot))
			dat += "<a href='?_src_=prefs;action=changeslot;num=[counter];'><b>[name_list[counter]]</b></a><br>"
		else
			if(!name_list[counter])
				dat += "<a href='?_src_=prefs;action=changeslot;num=[counter];'>Character[counter]</a><br>"
			else
				dat += "<a href='?_src_=prefs;action=changeslot;num=[counter];'>[name_list[counter]]</a><br>"
		counter++

	dat += "</center>"

	var/datum/browser/browser = new(user, "saves", null, 300, 340)
	browser.set_content(dat)
	browser.open(use_onclose=FALSE)

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")

/datum/preferences/proc/configure_special_roles(var/dat, var/mob/user)
	dat+={"
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
	<div id="container" style="overflow:auto;">
		"}

	for(var/list/table_type in list(antag_roles,nonantag_roles))
		dat += {"
			<div id="[table_type == antag_roles ? "left" : "right"]Div" style="width:50%;float:[table_type == antag_roles ? "left" : "right"];">
			<table border=\"0\" padding-left = 20px;>
			<tr><th colspan='6' height = '60px' valign='bottom'><h1>[table_type == nonantag_roles ? "Non-" : ""]Antagonist Roles</h1></th></tr>
			"}
		if(table_type == antag_roles && isantagbanned(user))
			dat += "<th colspan='6' text-align = 'center' height = '40px'><h1>You are banned from antagonist roles</h1></th>"
		else
			for(var/role_id in table_type)
				dat += "<tr><td>[capitalize(role_id)]</td>"
				if(table_type[role_id]) //if mode is available on the server
					if(jobban_isbanned(user, role_id) || (role_id == "pai candidate" && jobban_isbanned(user, "pAI")) || (role_id == MALF && jobban_isbanned(user, "AI")))
						dat += "<td class='bannedColumn' colspan='5'><b>\[BANNED]</b></td>"
					else
						var/wikiroute = role_wiki[role_id]
						var/desire = get_role_desire_str(roles[role_id])
						dat += {"<td>[wikiroute ? "<a HREF='?src=\ref[user];getwiki=[wikiroute]'>(Wiki)</a>" : "<s>(Wiki)</s>"]</td>
								<td><a class = 'fullsize clmNeverO[desire == "Never" ? "n" : "ff"]' href='?_src_=prefs;preference=set_roles;[role_id]=[ROLEPREF_NEVER|ROLEPREF_SAVE];'>Never</a></td>
								<td><a class = 'fullsize clmNoO[desire == "No" ? "n" : "ff"]' href='?_src_=prefs;preference=set_roles;[role_id]=[ROLEPREF_NO|ROLEPREF_SAVE];'>No</a></td>
								<td><a class = 'fullsize clmYesO[desire == "Yes" ? "n" : "ff"]' href='?_src_=prefs;preference=set_roles;[role_id]=[ROLEPREF_YES|ROLEPREF_SAVE];'>Yes</a></td>
								<td><a class = 'fullsize clmAlwaysO[desire == "Always" ? "n" : "ff"]' href='?_src_=prefs;preference=set_roles;[role_id]=[ROLEPREF_ALWAYS|ROLEPREF_SAVE];'>Always</a></td>
						</tr>"}
		dat += "</table></div>"
	dat += "</div><br>"

	return dat
