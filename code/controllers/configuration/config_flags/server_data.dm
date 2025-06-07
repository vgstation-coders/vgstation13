/datum/config_flag/server
	text_name = "server"
	value = ""

/datum/config_flag/server_name
	text_name = "server_name"
	value = ""

/datum/config_flag/hostedby
	text_name = "hostedby"
	value = ""

/datum/config_flag/numerical/server_suffix
	text_name = "server_suffix"
	value = 0

/datum/config_flag/banappeals
	text_name = "banappeals"
	value = ""

// Kept at bay12 website for historical and nostaglic reasons.
/datum/config_flag/wikiurl
	text_name = "wikiurl"
	value = "http://baystation12.net/wiki/index.php?title=Main_Page"

/datum/config_flag/vgws_base_url
	text_name = "vgws_base_url"
	value = "http://ss13.moe"

/datum/config_flag/vgws_ip
	text_name = "vgws_ip"
	value = "198.245.63.50"

/datum/config_flag/forumurl
	text_name = "forumurl"
	value = "http://baystation12.net/forums/"

/datum/config_flag/poll_results_url
	text_name = "poll_results_url"
	value = ""

/datum/config_flag/list_string/ressource_urls
	text_name = "ressource_urls"
	value = null

// Whether the server will talk to other processes through socket_talk
// This is currently unused
/datum/config_flag/toggle/socket_talk
	text_name = "socket_talk"
	value = 0

/datum/config_flag/toggle/use_irc_bot
	text_name = "use_irc_bot"
	value = 0

/datum/config_flag/irc_bot_host
	text_name = "irc_bot_host"
	value = "localhost"

/datum/config_flag/numerical/irc_bot_port
	text_name = "irc_bot_port"
	value = 45678

/datum/config_flag/numerical/irc_bot_server_id
	text_name = "irc_bot_server_id"
	value = 45678

/datum/config_flag/python_path
	text_name = "python_path"
	value = ""

/datum/config_flag/python_path/load(var/raw_string)
	if(value)
		value = raw_string
	else
		if(world.system_type == UNIX)
			value = "/usr/bin/env python2"
		else //probably windows, if not this should work anyway
			value = "python"

/datum/config_flag/renders_url
	text_name = "renders_url"
	value = ""

/datum/config_flag/discord_url
	text_name = "discord_url"
	value = ""

/datum/config_flag/discord_password
	text_name = "discord_password"
	value = ""


/datum/config_flag/library_url
	text_name = "library_url"
	value = ""

/datum/config_flag/branch_head
	text_name = "branch_head"
	value = ""

/datum/config_flag/stats_addr
	text_name = "stats_addr"
	value = ""

/datum/config_flag/rsclist
	text_name = "rsclist"
	value = ""

/datum/config_flag/rscstring
	text_name = "rscstring"
	value = ""

/datum/config_flag/tts_server
	text_name = "tts_server"
	value = ""
