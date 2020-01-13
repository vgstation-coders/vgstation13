/datum/data
	var/name = "data"
	var/size = 1.0


/datum/data/function
	name = "function"
	size = 2.0


/datum/data/function/data_control
	name = "data control"


/datum/data/function/id_changer
	name = "id changer"


/datum/data/record
	name = "record"
	size = 5.0
	var/list/fields = list(  )

/datum/data/record/proc/add_comment(var/comment)
	var/counter = 1
	while(fields["com_[counter]"])
		counter++
	fields["com_[counter]"] = "Made by [usr.identification_string()] on [time2text(world.realtime, "DDD MMM DD")] [worldtime2text(give_seconds = TRUE)], [game_year]<br>[comment]"

/datum/data/text
	name = "text"
	var/data = null


/datum/debug
	var/list/debuglist
