/client/proc/remove_broken_polls()
	set name = "Remove Broken Polls"
	set category = "Special Verbs"

	if(!check_rights(R_POLLING))
		return
	if(!dbcon.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return

	var/information = alert(src, "Please be aware that this may freeze up your game for a few seconds depending on how many broken polls there are. Don't do this unless neccessary, and MAKE SURE NOBODY IS IN THE PROCESS OF CURRENTLY MAKING A POLL!","READ THIS FIRST","Cancel","I Understand")
	if(information == "Cancel")
		return

	var/DBQuery/get_broken_poll_ids = dbcon.NewQuery("SELECT id FROM erro_poll_question WHERE polltype != 'TEXT' AND id NOT IN (SELECT pollid FROM erro_poll_option)")
	get_broken_poll_ids.Execute()

	var/list/poll_ids = list()
	while(get_broken_poll_ids.NextRow())
		var/theid = get_broken_poll_ids.item[1]
		poll_ids += theid

	for(var/myid in poll_ids)
		var/newq = "BROKEN POLL"
		var/DBQuery/end_this_poll = dbcon.NewQuery("UPDATE erro_poll_question SET question = [newq], endtime = NOW() WHERE id = [myid]")
		end_this_poll.Execute()
		sleep(1)