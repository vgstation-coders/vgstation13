/datum/gamemode/sandbox
	name = "sandbox"
	var/last_time_of_players = 0


/datum/gamemode/sandbox/Setup()
	log_admin("Starting a round of sandbox.")
	message_admins("Starting a round of sandbox.")
	return 1

/datum/gamemode/sandbox/PostSetup()
	..()
	for(var/mob/M in player_list)
		M.CanBuild()

/datum/gamemode/sandbox/latespawn(var/mob/mob)
	mob.CanBuild()
	to_chat(mob, "<B>Build your own station with the sandbox-panel command!</B>")

/datum/gamemode/sandbox/process()
	. = ..()
	if(player_list.len) //if anybody is in the current round
		last_time_of_players = world.time
	if(last_time_of_players && world.time - last_time_of_players > 1 HOURS) //if enough time has passed without them
		CallHook("Reboot",list())
		world.Reboot()