/proc/send2maindiscord(var/msg)
	send2discord(msg, FALSE)

/proc/send2admindiscord(var/msg)
	send2discord(msg, TRUE)

/proc/send2discord(var/msg, var/admin = FALSE)
	if (!global.config.discord_url || !global.config.discord_password)
		return

	var/url = "[global.config.discord_url]?pass=[url_encode(global.config.discord_password)]&admin=[admin ? "true" : "false"]&content=[url_encode(msg)]"
	world.Export(url)
