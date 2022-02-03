/datum/gamemode/sandbox
	name = "sandbox"


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
	if(!living_players.len && world.time > 15 MINUTES) //if nobody is around and alive in the current round and enough time has passed
		ticker.station_nolife_cinematic()