/* This is for any host that would like their server to appear on the main SS13 hub.
To use it, simply replace the password above, with the password found below, and it should work.
If not, let us know on the main tgstation IRC channel of irc.rizon.net #tgstation13 we can help you there.

	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "Space Station 13"
*/

#define OPEN_TO_HUB_PLAYERCOUNT_DEFAULT 15
#define DEFAULT_SERVER_NAME "/vg/station"
#define DEFAULT_SERVER_DESC " - Not dead yet!"

/world
	hub = "Exadv1.spacestation13"
	hub_password = "SORRYNOPASSWORD"
	name = "/vg/station"


var/global/byond_hub_open = FALSE
var/global/byond_server_name = DEFAULT_SERVER_NAME
var/global/byond_server_desc = DEFAULT_SERVER_DESC
var/global/byond_hub_playercount = OPEN_TO_HUB_PLAYERCOUNT_DEFAULT

/datum/admins/proc/HubPanel()
	if(!check_rights(R_SERVER))
		return

	var/dat = {"
		<center><B>Hub Panel</B></center><hr>\n
		<b><font color='red'>Changes persist between rounds!</font></b><br>
		<i>Changes may take a few minutes to take effect.</i><br><br>

		BYOND Hub availability is <A href='?src=\ref[src];edit_hub=toggle'>[byond_hub_open ? "ENABLED" : "DISABLED"]</A><br>
		Server is available on hub when playercount is less than: <A href='?src=\ref[src];edit_hub=playercount'>[byond_hub_playercount]</A><br><br>

		<b>Hub Entry</b> <A href='?src=\ref[src];edit_hub=name'>(Edit Name)</a> <A href='?src=\ref[src];edit_hub=desc'>(Edit Desc)</a><br>
		[byond_server_name]
		[byond_server_desc]<br><br>

		<i>\[station_name\], \[map_name\], \[roundtime\], \[playercount\] can all be used to substitute their respective values.</i>
	"}

	usr << browse(dat, "window=admin2;size=600x400")
	return

/world/proc/update_status()
	if(!byond_hub_open)
		hub_password = "SORRYNOPASSWORD"
		return

	var/players = 0
	for (var/mob/M in player_list)
		if (M.client)
			players++

	if(players > byond_hub_playercount)
		hub_password = "SORRYNOPASSWORD"
		return

	hub_password = "kMZy3U5jJHSiBQjr"  // Open the gates!

	var/s= ""

	s += "<b>[byond_server_name]</b>"
	s += "[byond_server_desc]"

	s = replacetext(s, "\[playercount\]", "[players]")
	s = replacetext(s, "\[station_name\]", "[station_name()]")
	s = replacetext(s, "\[map_name\]", "[map.nameLong]")
	if(!ticker || (ticker && !going))
		s += "<br><b>STARTING</b>"
	else if(ticker.current_state <= GAME_STATE_PREGAME && going && ticker.pregame_timeleft)
		s += "<br>Starting: <b>[round(ticker.pregame_timeleft - world.timeofday) / 10]</b>"
	else if(ticker.current_state == GAME_STATE_SETTING_UP)
		s += "<br>Starting: <b>Now</b>"
	else if(ticker.current_state == GAME_STATE_PLAYING)
		s += "<br>Time: <b>[game_start_elapsed_time()]</b>"
	else if(ticker.current_state == GAME_STATE_FINISHED)
		s += "<br><b>RESTARTING</b>"
	if(emergency_shuttle.online && emergency_shuttle.location != 2)
		s += " | Shuttle: <b>[emergency_shuttle.location == 1 ? "ETD" : "ETA"] [emergency_shuttle.get_shuttle_timer()]</b>"
	s += "<br>Map: <b>[map.nameLong]</b>"
	if(vote.winner && vote.map_paths)
		s += " | Next: <b>[vote.map_paths[vote.winner]]</b>"

	/* does this help? I do not know */ 	// neither do I!
	if (src.status != s)
		src.status = s
