#define IRC_FLAG_GENERAL "nudges"
#define IRC_FLAG_ADMINHELP "ahelps"

/proc/send2irc(var/flag, var/msg)
	set waitfor = FALSE
	if(CONFIG_GET(toggle/use_irc_bot))
		var/a=" --key=\"[CONFIG_GET(comms_password)]\""
		a += " --id=\"[CONFIG_GET(numerical/irc_bot_server_id)]\""
		a += " --channel=\"[flag]\""
		if(CONFIG_GET(irc_bot_host))
			a+=" --host=\"[CONFIG_GET(irc_bot_host)]\""
		if(CONFIG_GET(numerical/irc_bot_port))
			a+=" --port=\"[CONFIG_GET(numerical/irc_bot_port)]\""
			msg=replacetext(msg,"\"","\\\"")
		ext_python("ircbot_message.py", "[a] [escape_shell_arg(msg)]")

/proc/send2mainirc(var/msg)
	send2irc(IRC_FLAG_GENERAL,msg)

/proc/send2adminirc(var/msg)
	send2irc(IRC_FLAG_ADMINHELP,msg)
