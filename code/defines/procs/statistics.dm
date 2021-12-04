/proc/sql_poll_players()
	if(!sqllogging)
		return
	var/playercount = 0
	for(var/mob/M in player_list)
		if(M.client)
			playercount += 1
	if(!SSdbcore.Connect())
		log_game("SQL ERROR during player polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/datum/DBQuery/query = SSdbcore.NewQuery("INSERT INTO population (playercount, time) VALUES (:playercount, :time)",
			list(
				"playercount" = playercount,
				"time" = sqltime,
		))
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during player polling. Error : \[[err]\]\n")
		qdel(query)

/proc/sql_poll_admins()
	if(!sqllogging)
		return
	var/admincount = admins.len
	if(!SSdbcore.Connect())
		log_game("SQL ERROR during admin polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/datum/DBQuery/query = SSdbcore.NewQuery("INSERT INTO population (admincount, time) VALUES (:admincount, :time)",
			list(
				"admincount" = admincount,
				"time" = sqltime,
		))
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during admin polling. Error : \[[err]\]\n")
		qdel(query)

/proc/sql_report_death(var/mob/living/carbon/human/H)
	if(!sqllogging)
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/turf/T = H.loc
	var/area/placeofdeath = get_area(T.loc)
	var/podname = placeofdeath.name
	var/laname
	var/lakey
	if(H.lastattacker)
		laname = H.lastattacker:real_name
		lakey = H.lastattacker:key
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[H.x], [H.y], [H.z]"
//	to_chat(world, "INSERT INTO death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[H.gender]', [H.bruteloss], [H.getFireLoss()], [H.brainloss], [H.getOxyLoss()])")
	if(!SSdbcore.Connect())
		log_game("SQL ERROR during death reporting. Failed to connect.")
	else
		var/datum/DBQuery/query = SSdbcore.NewQuery("INSERT INTO death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord) VALUES (:name, :key, :job, :special, :pod, :time, :laname, :lakey, :gender, :bruteloss, :fireloss, :brainloss, :oxyloss, :coord)",
		list("name" = H.name, "key" = H.key, "job" = H.mind.assigned_role, "special" = (H.mind.assigned_role || "no role"), "pod" = podname, "time" = sqltime, "laname" = laname, "lakey" = lakey, "gender" = "[H.gender]", "bruteloss" = "[H.getBruteLoss()]", "fireloss" = "[H.getFireLoss()]", "brainloss" = "[H.brainloss]", "oxyloss" = "[H.getOxyLoss()]", "coord" = "[coord]"))
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during death reporting. Error : \[[err]\]\n")
		qdel(query)

/proc/sql_report_cyborg_death(var/mob/living/silicon/robot/H)
	if(!sqllogging)
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/turf/T = H.loc
	var/area/placeofdeath = get_area(T.loc)
	var/podname = placeofdeath.name

	var/laname
	var/lakey
	if(H.lastattacker)
		laname = H.lastattacker:real_name
		lakey = H.lastattacker:key
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[H.x], [H.y], [H.z]"
	if(!SSdbcore.Connect())
		log_game("SQL ERROR during death reporting. Failed to connect.")
	else
		var/datum/DBQuery/query = SSdbcore.NewQuery("INSERT INTO death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord) VALUES (:name, :key, :job, :special, :pod, :time, :laname, :lakey, :gender, :bruteloss, :fireloss, :brainloss, :oxyloss, :coord)",
			list("name" = H.name, "key" = H.key, "job" = H.mind.assigned_role, "special" = H.mind.assigned_role, "pod" = podname, "time" = sqltime, "laname" = laname, "lakey" = lakey, "gender" = "[H.gender]", "bruteloss" = "[H.getBruteLoss()]", "fireloss" = "[H.getFireLoss()]", "brainloss" = "[H.brainloss]", "oxyloss" = "[H.getOxyLoss()]", "coord" = "[coord]")
		)
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during death reporting. Error : \[[err]\]\n")
		qdel(query)

/proc/statistic_cycle()
	if(!sqllogging)
		return
	while(1)
		sql_poll_players()
		sleep(600)
		sql_poll_admins()
		sleep(6000) // Poll every ten minutes

//This proc is used for feedback. It is executed at round end.
/proc/sql_commit_feedback()
	if(!blackbox)
		log_game("Round ended without a blackbox recorder. No feedback was sent to the database.")
		return

	//content is a list of lists. Each item in the list is a list with two fields, a variable name and a value. Items MUST only have these two values.
	var/list/datum/feedback_variable/content = blackbox.feedback

	if(!content)
		log_game("Round ended without any feedback being generated. No feedback was sent to the database.")
		return

	if(!SSdbcore.Connect())
		log_game("SQL ERROR during feedback reporting. Failed to connect.")
	else

		var/datum/DBQuery/max_query = SSdbcore.NewQuery("SELECT MAX(roundid) AS max_round_id FROM erro_feedback")
		if(!max_query.Execute())
			log_sql("Error: [max_query.ErrorMsg()]")
			qdel(max_query)

		var/newroundid

		while(max_query.NextRow())
			newroundid = max_query.item[1]

		if(!(isnum(newroundid)))
			newroundid = text2num(newroundid)

		if(isnum(newroundid))
			newroundid++
		else
			newroundid = 1

		for(var/datum/feedback_variable/item in content)
			var/variable = item.get_variable()
			var/value = item.get_value()

			var/datum/DBQuery/query = SSdbcore.NewQuery("INSERT INTO erro_feedback (id, roundid, time, variable, value) VALUES (:id, :newroundid, Now(), :variable, :value)",
				list(
					"id" = null,
					"newroundid" = newroundid,
					"variable" = variable,
					"value" = value,
				))
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during death reporting. Error : \[[err]\]\n")
			qdel(query)
