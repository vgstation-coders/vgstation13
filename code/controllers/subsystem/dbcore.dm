// Original code from /tg/station at https://github.com/tgstation/tgstation

var/datum/subsystem/dbcore/SSdbcore

#define DB_MAJOR_VERSION 0
#define DB_MINOR_VERSION 1

/datum/subsystem/dbcore
	name = "feedback Database"
	wait = 1 MINUTES
	flags = SS_NO_INIT
	priority = SS_PRIORITY_DBCORE
	display_order = SS_DISPLAY_DBCORE
	var/const/FAILED_DB_CONNECTION_CUTOFF = 5
	var/failed_connection_timeout = 0

	var/schema_mismatch = 0
	var/db_minor = 0
	var/db_major = 0
	var/failed_connections = 0

	var/last_error
	var/list/active_queries = list()

	var/connection  // Arbitrary handle returned from rust_g.

/datum/subsystem/dbcore/New()
	NEW_SS_GLOBAL(SSdbcore)

/datum/subsystem/dbcore/proc/get_db_ids()
	var/list/ids = list()
	ids["user"] = sqlfdbklogin
	ids["pass"] = sqlfdbkpass
	ids["db"] = sqlfdbkdb
	ids["address"] = sqladdress
	ids["port"] = sqlport
	return ids

/datum/subsystem/dbcore/Initialize()
	//We send warnings to the admins during subsystem init, as the clients will be New'd and messages
	//will queue properly with goonchat
	if(!Connect())
		world.log << "Your server failed to establish a connection with the [name]."
	else
		world.log << "[name] connection established."

	migration_controller_sqlite = new ("players2.sqlite", "players2_empty.sqlite")

	switch(schema_mismatch)
		if(1)
			message_admins("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
		if(2)
			message_admins("Could not get schema version from database")

	. = ..()

	// All connections established, migrations can start.
	migration_controller_mysql = new

/datum/subsystem/dbcore/fire()
	for(var/I in active_queries)
		var/datum/DBQuery/Q = I
		if(world.time - Q.last_activity_time > (5 MINUTES))
			message_admins("Found undeleted query, please check the server logs and notify coders.")
			log_sql("Undeleted query: \"[Q.sql]\" LA: [Q.last_activity] LAT: [Q.last_activity_time]")
			qdel(Q)
		if(MC_TICK_CHECK)
			return

/datum/subsystem/dbcore/Recover()
	connection = SSdbcore.connection

/datum/subsystem/dbcore/Shutdown()
	//This is as close as we can get to the true round end before Disconnect() without changing where it's called, defeating the reason this is a subsystem
	if(SSdbcore.Connect())
		ShutdownQuery()
	if(IsConnected())
		Disconnect()

/datum/subsystem/dbcore/proc/Connect()
	if(initialized && IsConnected())
		return TRUE

	if(failed_connection_timeout <= world.time) //it's been more than 5 seconds since we failed to connect, reset the counter
		failed_connections = 0

	if(failed_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect for 5 seconds.
		failed_connection_timeout = world.time + 5 SECONDS
		return FALSE

	if(!config.sql_enabled)
		return FALSE

	var/list/ids = get_db_ids()

	var/user = ids["user"]
	var/pass = ids["pass"]
	var/db = ids["db"]
	var/address = ids["address"]
	var/port = ids["port"]
	var/timeout = max(config.async_query_timeout, config.blocking_query_timeout)
	var/thread_limit = config.bsql_thread_limit

	var/result = json_decode(rustg_sql_connect_pool(json_encode(list(
		"host" = address,
		"port" = port,
		"user" = user,
		"pass" = pass,
		"db_name" = db,
		"max_threads" = 5,
		"read_timeout" = timeout,
		"write_timeout" = timeout,
		"max_threads" = thread_limit,
	))))

	. = (result["status"] == "ok")
	if (.)
		connection = result["handle"]
	else
		connection = null
		last_error = result["data"]
		log_sql("Connect() failed | [last_error]")
		++failed_connections

/datum/subsystem/dbcore/proc/Disconnect()
	failed_connections = 0
	if (connection)
		rustg_sql_disconnect_pool(connection)
	connection = null

/datum/subsystem/dbcore/proc/CheckSchemaVersion()
	if(config.sql_enabled)
		if(Connect())
			log_world("Database connection established.")
			/*
			var/datum/DBQuery/query_db_version = NewQuery("SELECT major, minor FROM schema_revision ORDER BY date DESC LIMIT 1")
			query_db_version.Execute()
			if(query_db_version.NextRow())
				db_major = text2num(query_db_version.item[1])
				db_minor = text2num(query_db_version.item[2])
				if(db_major != DB_MAJOR_VERSION || db_minor != DB_MINOR_VERSION)
					schema_mismatch = 1 // flag admin message about mismatch
					log_sql("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
			else
				schema_mismatch = 2 //flag admin message about no schema version
				log_sql("Could not get schema version from database")
			qdel(query_db_version)
			*/
		else
			log_sql("Your server failed to establish a connection with the [name].")
	else
		log_sql("Database is not enabled in configuration.")

/datum/subsystem/dbcore/proc/SetRoundID()
	return

/datum/subsystem/dbcore/proc/SetRoundStart()
	return

/datum/subsystem/dbcore/proc/SetRoundEnd()
	return

/datum/subsystem/dbcore/proc/ShutdownQuery()
	return

/*
/datum/subsystem/dbcore/proc/SetRoundID()
	if(!Connect())
		return
	var/datum/DBQuery/query_round_initialize = SSdbcore.NewQuery("")
	query_round_initialize.Execute(async = FALSE)
	qdel(query_round_initialize)
	var/datum/DBQuery/query_round_last_id = SSdbcore.NewQuery("SELECT LAST_INSERT_ID()")
	query_round_last_id.Execute(async = FALSE)
	if(query_round_last_id.NextRow(async = FALSE))
		GLOB.round_id = query_round_last_id.item[1]
	qdel(query_round_last_id)

/datum/subsystem/dbcore/proc/SetRoundStart()
	if(!Connect())
		return
	var/datum/DBQuery/query_round_start = SSdbcore.NewQuery()
	query_round_start.Execute()
	qdel(query_round_start)

/datum/subsystem/dbcore/proc/SetRoundEnd()
	if(!Connect())
		return
	//var/datum/DBQuery/query_round_end = SSdbcore.NewQuery()
	query_round_end.Execute()
	qdel(query_round_end)

/datum/subsystem/dbcore/proc/ShutdownQuery()
	var/datum/DBQuery/query_round_shutdown = SSdbcore.NewQuery()
	query_round_shutdown.Execute()
	qdel(query_round_shutdown)
*/

/datum/subsystem/dbcore/proc/IsConnected()
	if(!config.sql_enabled)
		return FALSE
	if (!connection)
		return FALSE
	return json_decode(rustg_sql_connected(connection))["status"] == "online"

/datum/subsystem/dbcore/proc/ErrorMsg()
	if(!config.sql_enabled)
		return "Database disabled by configuration"
	return last_error

/datum/subsystem/dbcore/proc/ReportError(error)
	last_error = error

//
/datum/subsystem/dbcore/proc/NewQuery(sql_query, arguments)
	return new /datum/DBQuery(connection, sql_query, arguments)

/datum/subsystem/dbcore/proc/QuerySelect(list/querys, warn = FALSE, qdel = FALSE)
	if (!islist(querys))
		if (!istype(querys, /datum/DBQuery))
			CRASH("Invalid query passed to QuerySelect: [querys]")
		querys = list(querys)

	for (var/thing in querys)
		var/datum/DBQuery/query = thing
		if (warn)
			call(query, /datum/DBQuery::warn_execute())()
		else
			call(query, /datum/DBQuery::Execute())()

	for (var/thing in querys)
		var/datum/DBQuery/query = thing
		UNTIL(!query.in_progress)
		if (qdel)
			qdel(query)

/*
Takes a list of rows (each row being an associated list of column => value) and inserts them via a single mass query.
Rows missing columns present in other rows will resolve to SQL NULL
You are expected to do your own escaping of the data, and expected to provide your own quotes for strings.
The duplicate_key arg can be true to automatically generate this part of the query
	or set to a string that is appended to the end of the query
Ignore_errors instructes mysql to continue inserting rows if some of them have errors.
	 the erroneous row(s) aren't inserted and there isn't really any way to know why or why errored
Delayed insert mode was removed in mysql 7 and only works with MyISAM type tables,
	It was included because it is still supported in mariadb.
	It does not work with duplicate_key and the mysql server ignores it in those cases
*/
/datum/subsystem/dbcore/proc/MassInsert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, delayed = FALSE, warn = FALSE, async = TRUE, special_columns = null)
	if (!table || !rows || !istype(rows))
		return

	// Prepare column list
	var/list/columns = list()
	var/list/has_question_mark = list()
	for (var/list/row in rows)
		for (var/column in row)
			columns[column] = "?"
			has_question_mark[column] = TRUE
	for (var/column in special_columns)
		columns[column] = special_columns[column]
		has_question_mark[column] = findtext(special_columns[column], "?")

	// Prepare SQL query full of placeholders
	var/list/query_parts = list("INSERT")
	if (delayed)
		query_parts += " DELAYED"
	if (ignore_errors)
		query_parts += " IGNORE"
	query_parts += " INTO "
	query_parts += table
	query_parts += "\n([columns.Join(", ")])\nVALUES"

	var/list/arguments = list()
	var/has_row = FALSE
	for (var/list/row in rows)
		if (has_row)
			query_parts += ","
		query_parts += "\n  ("
		var/has_col = FALSE
		for (var/column in columns)
			if (has_col)
				query_parts += ", "
			if (has_question_mark[column])
				var/name = "p[arguments.len]"
				query_parts += replacetext(columns[column], "?", ":[name]")
				arguments[name] = row[column]
			else
				query_parts += columns[column]
			has_col = TRUE
		query_parts += ")"
		has_row = TRUE

	if (duplicate_key == TRUE)
		var/list/column_list = list()
		for (var/column in columns)
			column_list += "[column] = VALUES([column])"
		query_parts += "\nON DUPLICATE KEY UPDATE [column_list.Join(", ")]"
	else if (duplicate_key != FALSE)
		query_parts += duplicate_key

	var/datum/DBQuery/Query = NewQuery(query_parts.Join(), arguments)
	if (warn)
		. = Query.warn_execute(async)
	else
		. = Query.Execute(async)
	qdel(Query)

/datum/DBQuery
	// Inputs
	var/connection
	var/sql
	var/arguments

	// Status information
	var/in_progress
	var/last_error
	var/last_activity
	var/last_activity_time

	// Output
	var/list/list/rows
	var/next_row_to_take = 1
	var/affected
	var/last_insert_id

	var/list/item  //list of data values populated by NextRow()

/datum/DBQuery/New(connection, sql, arguments)
	SSdbcore.active_queries[src] = TRUE
	Activity("Created")
	item = list()
	src.connection = connection
	src.sql = sql
	src.arguments = arguments

/datum/DBQuery/Destroy()
	log_query_debug("query with [sql] being qdeleted. Will die any second now.")
	Close()
	SSdbcore.active_queries -= src
	return ..()

/datum/DBQuery/Del()
	log_query_debug("query with [sql] died.")
	return ..()

/datum/DBQuery/proc/Activity(activity)
	last_activity = activity
	last_activity_time = world.time

/datum/DBQuery/proc/warn_execute(async = TRUE)
	. = Execute(async)
	if(!.)
		to_chat(usr, "<span class='danger'>A SQL error occurred during this operation, check the server logs.</span>")

/datum/DBQuery/proc/Execute(async = TRUE, log_error = TRUE)
	Activity("Execute")
	if(in_progress)
		CRASH("Attempted to start a new query while waiting on the old one")

	if(!SSdbcore.IsConnected())
		last_error = "No connection!"
		return FALSE

	var/start_time
	if(!async)
		start_time = REALTIMEOFDAY
	Close()
	. = run_query(async)
	var/timed_out = !. && findtext(last_error, "Operation timed out")
	if(!. && log_error)
		log_sql("[last_error] | Query used: [sql]")
	if(!async && timed_out)
		log_query_debug("Query execution started at [start_time]")
		log_query_debug("Query execution ended at [REALTIMEOFDAY]")
		log_query_debug("Slow query timeout detected.")
		log_query_debug("Query used: [sql]")
		slow_query_check()

/datum/DBQuery/proc/run_query(async)
	var/job_result_str

	if (async)
		var/job_id = rustg_sql_query_async(connection, sql, json_encode(arguments))
		in_progress = TRUE
		UNTIL((job_result_str = rustg_sql_check_query(job_id)) != RUSTG_JOB_NO_RESULTS_YET)
		in_progress = FALSE

		if (job_result_str == RUSTG_JOB_ERROR)
			last_error = job_result_str
			return FALSE
	else
		job_result_str = rustg_sql_query_blocking(connection, sql, json_encode(arguments))

	var/result = json_decode(job_result_str)
	switch (result["status"])
		if ("ok")
			rows = result["rows"]
			affected = result["affected"]
			last_insert_id = result["last_insert_id"]
			return TRUE
		if ("err")
			last_error = result["data"]
			return FALSE
		if ("offline")
			last_error = "offline"
			return FALSE

/datum/DBQuery/proc/slow_query_check()
	message_admins("HEY! A database query timed out. Tell coders or Pomf what happened, please.")

/datum/DBQuery/proc/NextRow(async = TRUE)
	Activity("NextRow")

	if (rows && next_row_to_take <= rows.len)
		item = rows[next_row_to_take]
		next_row_to_take++
		return !!item
	else
		return FALSE

/datum/DBQuery/proc/ErrorMsg()
	return last_error

/datum/DBQuery/proc/Close()
	rows = null
	item = null
