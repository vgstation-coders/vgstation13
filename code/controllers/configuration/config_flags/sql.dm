/datum/config_flag/numerical/async_query_timeout
	text_name = "async_query_timeout"
	value = 10
	protected = 1

/datum/config_flag/numerical/blocking_query_timeout
	text_name = "blocking_query_timeout"
	value = 5
	protected = 1

/datum/config_flag/numerical/bsql_thread_limit
	text_name = "bsql_thread_limit"
	value = 50
	protected = 1

//Defines whether the server uses the legacy admin system with admins.txt or the SQL system. Config option in config.txt
/datum/config_flag/toggle/admin_legacy_system
	text_name = "admin_legacy_system"
	value = 0
	protected = 1

//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt
/datum/config_flag/toggle/ban_legacy_system
	text_name = "ban_legacy_system"
	value = 0
	protected = 1
