
//stores map votes for code/modules/html_interface/voting/voting.dm
/datum/persistence_task/vote
	execute = TRUE
	name = "Persistent votes"
	file_path = "data/persistence/votes.json"

/datum/persistence_task/vote/on_init()
	var/list/to_read = read_file()
	if(!to_read)
		log_debug("[name] task found an empty file on [file_path]")
		return
	for(var/i = 1; i <= to_read.len; i++)
		data[to_read[i]] = to_read[to_read[i]]

/datum/persistence_task/vote/on_shutdown()
	write_file(data)

/datum/persistence_task/vote/proc/insert_counts(var/list/tally)
	sortTim(tally, /proc/cmp_numeric_dsc,1)
	//reset the winner
	data[tally[1]] = 0
	for(var/i = 2; i <= tally.len; i++)
		data[tally[i]] = tally[tally[i]]

/datum/persistence_task/vote/proc/clear_counts()
	data = list()
	fdel(file(file_path))
