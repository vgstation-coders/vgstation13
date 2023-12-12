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
