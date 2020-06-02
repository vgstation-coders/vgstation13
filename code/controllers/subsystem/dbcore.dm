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

	var/datum/BSQL_Connection/connection
	var/datum/BSQL_Operation/connectOperation

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
	connectOperation = SSdbcore.connectOperation

/datum/subsystem/dbcore/Shutdown()
	//This is as close as we can get to the true round end before Disconnect() without changing where it's called, defeating the reason this is a subsystem
	if(SSdbcore.Connect())
		ShutdownQuery()
	if(IsConnected())
		Disconnect()
	world.BSQL_Shutdown()

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

	connection = new /datum/BSQL_Connection(BSQL_CONNECTION_TYPE_MARIADB, config.async_query_timeout, config.blocking_query_timeout, config.bsql_thread_limit)
	var/error
	if(!connection || connection.gcDestroyed)
		connection = null
		error = last_error
	else
		SSdbcore.last_error = null
		connectOperation = connection.BeginConnect(address, port, user, pass, db)
		// This is a bit of a hack. It sets initialized to be true BEFORE 'UNTIL', which sleeps. All the code done before is done synchronously.
		// This ensures that the server establishes a connection and a connection operation before any call to IsBanned(), for instance, is made.
		// Now IsBanned() calls will patiently wait on a DB connection to exist to be resolved, preventing queries to be queued up before an actual connection is made.
		initialized = TRUE
		if(SSdbcore.last_error)
			CRASH(SSdbcore.last_error)
		UNTIL(connectOperation.IsComplete())
		error = connectOperation.GetError()
	. = !error
	if (!.)
		last_error = error
		log_sql("Connect() failed | [error]")
		++failed_connections
		qdel(connection)
		qdel(connectOperation)
		connection = null
		connectOperation = null

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
	var/datum/DBQuery/query_round_initialize = SSdbcore.NewQuery("INSERT INTO [format_table_name("round")] (initialize_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]')")
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
	var/datum/DBQuery/query_round_start = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET start_datetime = Now() WHERE id = [GLOB.round_id]")
	query_round_start.Execute()
	qdel(query_round_start)

/datum/subsystem/dbcore/proc/SetRoundEnd()
	if(!Connect())
		return
	var/sql_station_name = sanitizeSQL(station_name())
	//var/datum/DBQuery/query_round_end = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET end_datetime = Now(), game_mode_result = '[sanitizeSQL(SSticker.mode_result)]', station_name = '[sql_station_name]' WHERE id = [GLOB.round_id]")
	query_round_end.Execute()
	qdel(query_round_end)

/datum/subsystem/dbcore/proc/ShutdownQuery()
	var/datum/DBQuery/query_round_shutdown = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET shutdown_datetime = Now(), end_state = '[sanitizeSQL(SSticker.end_state)]' WHERE id = [GLOB.round_id]")
	query_round_shutdown.Execute()
	qdel(query_round_shutdown)
*/

/datum/subsystem/dbcore/proc/Disconnect()
	failed_connections = 0
	qdel(connectOperation)
	qdel(connection)
	connectOperation = null
	connection = null

/datum/subsystem/dbcore/proc/IsConnected()
	if(!config.sql_enabled)
		return FALSE
	//block until any connect operations finish
	var/datum/BSQL_Connection/_connection = connection
	var/datum/BSQL_Operation/op = connectOperation
	while ( (!_connection || _connection.gcDestroyed) || !op.IsComplete() ) // Waiting we have a real connection and that it's complete
		stoplag()
	return connection && !(connection.gcDestroyed && !op.GetError()) // Connect

/datum/subsystem/dbcore/proc/Quote(str)
	if(connection)
		return connection.Quote(str)

/datum/subsystem/dbcore/proc/ErrorMsg()
	if(!config.sql_enabled)
		return "Database disabled by configuration"
	return last_error

/datum/subsystem/dbcore/proc/ReportError(error)
	last_error = error

//
/datum/subsystem/dbcore/proc/NewQuery(sql_query)
	return new /datum/DBQuery(sql_query, connection)

/datum/subsystem/dbcore/proc/QuerySelect(list/querys, warn = FALSE, qdel = FALSE)
	if (!islist(querys))
		if (!istype(querys, /datum/DBQuery))
			CRASH("Invalid query passed to QuerySelect: [querys]")
		querys = list(querys)

	for (var/thing in querys)
		var/datum/DBQuery/query = thing
		if (warn)
			call(query, /datum/DBQuery.proc/warn_execute)()
		else
			call(query, /datum/DBQuery.proc/Execute)()

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
/datum/subsystem/dbcore/proc/MassInsert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, delayed = FALSE, warn = FALSE, async = TRUE)
	if (!table || !rows || !istype(rows))
		return
	var/list/columns = list()
	var/list/sorted_rows = list()

	for (var/list/row in rows)
		var/list/sorted_row = list()
		sorted_row.len = columns.len
		for (var/column in row)
			var/idx = columns[column]
			if (!idx)
				idx = columns.len + 1
				columns[column] = idx
				sorted_row.len = columns.len

			sorted_row[idx] = row[column]
		sorted_rows[++sorted_rows.len] = sorted_row

	if (duplicate_key == TRUE)
		var/list/column_list = list()
		for (var/column in columns)
			column_list += "[column] = VALUES([column])"
		duplicate_key = "ON DUPLICATE KEY UPDATE [column_list.Join(", ")]\n"
	else if (duplicate_key == FALSE)
		duplicate_key = null

	if (ignore_errors)
		ignore_errors = " IGNORE"
	else
		ignore_errors = null

	if (delayed)
		delayed = " DELAYED"
	else
		delayed = null

	var/list/sqlrowlist = list()
	var/len = columns.len
	for (var/list/row in sorted_rows)
		if (length(row) != len)
			row.len = len
		for (var/value in row)
			if (value == null)
				value = "NULL"
		sqlrowlist += "([row.Join(", ")])"

	sqlrowlist = "	[sqlrowlist.Join(",\n	")]"
	var/datum/DBQuery/Query = NewQuery("INSERT[delayed][ignore_errors] INTO [table]\n([columns.Join(", ")])\nVALUES\n[sqlrowlist]\n[duplicate_key]")
	if (warn)
		. = Query.warn_execute(async)
	else
		. = Query.Execute(async)
	qdel(Query)

/datum/DBQuery
	var/sql // The sql query being executed.
	var/list/item  //list of data values populated by NextRow()

	var/last_activity
	var/last_activity_time

	var/last_error
	var/skip_next_is_complete
	var/in_progress
	var/datum/BSQL_Connection/connection
	var/datum/BSQL_Operation/Query/query

/datum/DBQuery/New(sql_query, datum/BSQL_Connection/connection)
	log_query_debug("new query with SQL : {[sql_query]} \n on [SSdbcore.name]")
	SSdbcore.active_queries[src] = TRUE
	Activity("Created")
	item = list()
	src.connection = connection
	sql = sql_query

/datum/DBQuery/Destroy()
	log_query_debug("query with [sql] being qdeleted. Will die any second now.")
	Close()
	SSdbcore.active_queries -= src
	return ..()

/datum/DBQuery/Del()
	log_query_debug("query with [sql] died.")
	return ..()

/datum/DBQuery/proc/SetQuery(new_sql)
	if(in_progress)
		CRASH("Attempted to set new sql while waiting on active query")
	Close()
	sql = new_sql

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

	if(!connection || connection.gcDestroyed)
		last_error = "No connection!"
		return FALSE

	var/start_time
	var/timed_out
	if(!async)
		start_time = REALTIMEOFDAY
	Close()
	timed_out = run_query(async)
	if(query.GetErrorCode() == 2006) //2006 is the return code for "MySQL server has gone away" time-out error, meaning the connection has been lost to the server (if it's still alive)
		log_sql("Executing query encountered returned a lost database connection (2006).")
		SSdbcore.Disconnect()
		if(SSdbcore.Connect()) //connection was restablished, reattempt the query
			log_sql("Connection restablished")
			timed_out = run_query(async)
		else
			log_sql("Executing query failed to restablish database connection.")
	skip_next_is_complete = TRUE
	var/error = (!query || query.gcDestroyed) ? "Query object deleted!" : query.GetError()
	last_error = error
	. = !error
	if(!. && log_error)
		log_sql("[error] | Query used: [sql]")
	if(!async && timed_out)
		log_query_debug("Query execution started at [start_time]")
		log_query_debug("Query execution ended at [REALTIMEOFDAY]")
		log_query_debug("Slow query timeout detected.")
		log_query_debug("Query used: [sql]")
		slow_query_check()

/datum/DBQuery/proc/run_query(async)
	query = connection.BeginQuery(sql)
	if(!async)
		. = !query.WaitForCompletion()
	else
		in_progress = TRUE
		UNTIL(query.IsComplete())
		in_progress = FALSE

/datum/DBQuery/proc/slow_query_check()
	message_admins("HEY! A database query timed out. Tell coders or Pomf what happened, please.")

/datum/DBQuery/proc/NextRow(async = TRUE)
	Activity("NextRow")
	UNTIL(!in_progress)
	if(!skip_next_is_complete)
		if(!async)
			query.WaitForCompletion()
		else
			in_progress = TRUE
			UNTIL(query.IsComplete())
			in_progress = FALSE
	else
		skip_next_is_complete = FALSE

	last_error = query.GetError()
	var/list/results = query.CurrentRow()
	. = results != null

	item.Cut()
	//populate item array
	for(var/I in results)
		item += results[I]

/datum/DBQuery/proc/ErrorMsg()
	return last_error

/datum/DBQuery/proc/Close()
	item.Cut()
	qdel(query)
	query = null

/world/BSQL_Debug(message)
	if(!config.bsql_debug)
		return

	//strip sensitive stuff
	if(findtext(message, ": OpenConnection("))
		message = "OpenConnection CENSORED"

	log_sql("BSQL_DEBUG: [message]")
