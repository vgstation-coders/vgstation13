/datum/game_mode/sandbox
	name = "sandbox"
	config_tag = "sandbox"
	required_players = 0

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

/datum/game_mode/sandbox/announce()
	world << "<B>The current game mode is - Sandbox!</B>"
	world << "<B>Build your own station with the sandbox-panel command!</B>"

/datum/game_mode/sandbox/pre_setup()
	return 1

/datum/game_mode/sandbox/post_setup()
	..()
	for(var/mob/M in player_list)
		M.CanBuild()
	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1

/datum/game_mode/sandbox/latespawn(var/mob/mob)
	mob.CanBuild()
	mob << "<B>Build your own station with the sandbox-panel command!</B>"