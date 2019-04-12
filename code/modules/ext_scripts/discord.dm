// Sends to the SERVER STATUS channels.
// This sends to the "server_status" gamenudge route.
/proc/send2maindiscord(var/msg)
	send2discord(msg, "server_status")

// Sends to the adminbus ahelp channels.
// This sends to the "adminhelp" gamenudge route.
/proc/send2admindiscord(var/msg, var/ping = FALSE)
	send2discord(msg, "adminhelp", ping)

// Meta argument here is the MoMMI meta argument to send to the gamenudge route.
// AKA the MoMMI config file chooses where to send it based on this key.
/proc/send2discord(var/msg, var/meta, var/ping = FALSE)
	if (!global.config.discord_url || !global.config.discord_password)
		return

	var/url = "[global.config.discord_url]?pass=[url_encode(global.config.discord_password)]&meta=[url_encode(meta)]&content=[url_encode(msg)]&ping=[ping ? "true" : "false"]"
	world.Export(url)
