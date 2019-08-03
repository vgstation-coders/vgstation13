var/datum/blackbox/blackbox = new

/datum/blackbox
	var/list/messages = list()		//Stores messages of non-standard frequencies
	var/list/messages_admin = list()

	var/list/msg_common = list()
	var/list/msg_science = list()
	var/list/msg_command = list()
	var/list/msg_medical = list()
	var/list/msg_engineering = list()
	var/list/msg_security = list()
	var/list/msg_deathsquad = list()
	var/list/msg_ert = list()
	var/list/msg_syndicate = list()
	var/list/msg_service = list()
	var/list/msg_cargo = list()
	var/list/msg_raider = list()

	var/list/datum/feedback_variable/feedback = new()

/datum/blackbox/Destroy()
	stack_trace("[type] was deleted, why would you do this?")
	..()

/datum/blackbox/proc/find_feedback_datum(var/variable)
	for(var/datum/feedback_variable/FV in feedback)
		if(FV.get_variable() == variable)
			return FV
	var/datum/feedback_variable/FV = new(variable)
	feedback += FV
	return FV

/datum/blackbox/proc/round_end_data_gathering()
	var/pda_msg_amt = 0
	var/rc_msg_amt = 0

	for(var/obj/machinery/message_server/MS in machines)
		if(MS.pda_msgs.len > pda_msg_amt)
			pda_msg_amt = MS.pda_msgs.len
		if(MS.rc_msgs.len > rc_msg_amt)
			rc_msg_amt = MS.rc_msgs.len

	feedback_set_details("radio_usage","")

	feedback_add_details("radio_usage","COM-[msg_common.len]")
	feedback_add_details("radio_usage","SCI-[msg_science.len]")
	feedback_add_details("radio_usage","HEA-[msg_command.len]")
	feedback_add_details("radio_usage","MED-[msg_medical.len]")
	feedback_add_details("radio_usage","ENG-[msg_engineering.len]")
	feedback_add_details("radio_usage","SEC-[msg_security.len]")
	feedback_add_details("radio_usage","DTH-[msg_deathsquad.len]")
	feedback_add_details("radio_usage","ERT-[msg_ert.len]")
	feedback_add_details("radio_usage","SYN-[msg_syndicate.len]")
	feedback_add_details("radio_usage","SER-[msg_service.len]")
	feedback_add_details("radio_usage","CAR-[msg_cargo.len]")
	feedback_add_details("radio_usage","OTH-[messages.len]")
	feedback_add_details("radio_usage","PDA-[pda_msg_amt]")
	feedback_add_details("radio_usage","RC-[rc_msg_amt]")
	feedback_add_details("radio_usage","RDR-[msg_raider]")

	feedback_set_details("round_end","[time2text(world.realtime)]") //This one MUST be the last one that gets set.


//This proc is only to be called at round end.
/datum/blackbox/proc/save_all_data_to_sql()
	if(!feedback)
		return

	//#warn Blackbox recording disabled.  Please remove warning once this has been determined to be the problem.
	//return

	var/watch = start_watch()
	log_startup_progress("Storing Black Box data...")
	round_end_data_gathering() //round_end time logging and some other data processing
	establish_db_connection()
	if(!dbcon.IsConnected())
		return
	var/round_id

	var/nqueries = 0

	var/DBQuery/query = dbcon.NewQuery("SELECT MAX(round_id) AS round_id FROM erro_feedback")
	query.Execute()
	nqueries++
	while(query.NextRow())
		round_id = query.item[1]

	if(!isnum(round_id))
		round_id = text2num(round_id)
	round_id++

	/*
	for(var/datum/feedback_variable/FV in feedback)
		var/sql = "INSERT INTO erro_feedback VALUES (null, Now(), [round_id], \"[FV.get_variable()]\", [FV.get_value()], \"[FV.get_details()]\")"
		var/DBQuery/query_insert = dbcon.NewQuery(sql)
		query_insert.Execute()
		nqueries++
		sleep(1) // Let other shit do things
	*/
	// MySQL and MariaDB support compound inserts and this insert is slow as fuck.
	var/sql = "INSERT INTO erro_feedback VALUES "
	var/ninserts=0
	for(var/datum/feedback_variable/FV in feedback)
		if(ninserts>0)
			sql += ","
		ninserts++
		sql += "(null, Now(), [round_id], \"[FV.get_variable()]\", [FV.get_value()], \"[FV.get_details()]\")"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()
	nqueries++

	log_startup_progress("  Wrote Black Box data with [nqueries] queries in [stop_watch(watch)]s.")


/datum/feedback_variable
	var/variable
	var/value
	var/details

/datum/feedback_variable/New(var/param_variable,var/param_value = 0)
	variable = param_variable
	value = param_value

/datum/feedback_variable/proc/inc(var/num = 1)
	if(isnum(value))
		value += num
	else
		value = text2num(value)
		if(isnum(value))
			value += num
		else
			value = num

/datum/feedback_variable/proc/dec(var/num = 1)
	if(isnum(value))
		value -= num
	else
		value = text2num(value)
		if(isnum(value))
			value -= num
		else
			value = -num

/datum/feedback_variable/proc/set_value(var/num)
	if(isnum(num))
		value = num

/datum/feedback_variable/proc/get_value()
	return value

/datum/feedback_variable/proc/get_variable()
	return variable

/datum/feedback_variable/proc/set_details(var/text)
	if(istext(text))
		details = text

/datum/feedback_variable/proc/add_details(var/text)
	if(istext(text))
		if(!details)
			details = text
		else
			details += " [text]"

/datum/feedback_variable/proc/get_details()
	return details

/datum/feedback_variable/proc/get_parsed()
	return list(variable,value,details)


/proc/feedback_set(var/variable,var/value)
	if(!blackbox)
		return

	variable = sql_sanitize_text(variable)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.set_value(value)

/proc/feedback_inc(var/variable,var/value)
	if(!blackbox)
		return

	variable = sql_sanitize_text(variable)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.inc(value)

/proc/feedback_dec(var/variable,var/value)
	if(!blackbox)
		return

	variable = sql_sanitize_text(variable)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.dec(value)

/proc/feedback_set_details(var/variable,var/details)
	if(!blackbox)
		return

	variable = sql_sanitize_text(variable)
	details = sql_sanitize_text(details)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.set_details(details)

/proc/feedback_add_details(var/variable,var/details)
	if(!blackbox)
		return

	variable = sql_sanitize_text(variable)
	details = sql_sanitize_text(details)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV)
		return

	FV.add_details(details)
