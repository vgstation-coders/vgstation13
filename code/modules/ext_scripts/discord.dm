/proc/send2maindiscord(var/msg)
	send2discord(msg, FALSE)

/proc/send2admindiscord(var/msg, var/ping = FALSE)
	send2discord(msg, TRUE, ping)

/proc/send2discord(var/msg, var/admin = FALSE, var/ping = FALSE)
	if (!global.config.discord_url || !global.config.discord_password)
		return

	var/url = "[global.config.discord_url]?pass=[url_encode(global.config.discord_password)]&admin=[admin ? "true" : "false"]&content=[url_encode(msg)]&ping=[ping ? "true" : "false"]"
	world.Export(url)
