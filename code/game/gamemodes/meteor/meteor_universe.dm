/datum/universal_state/meteor_storm
	name = "Meteor Storm"
	desc = "A meteor storm is currently wrecking havoc around this sector. Duck and cover."

	decay_rate = 0 //Just to make sure

	var/meteor_extra_announce_delay = 0 //Independent from the gamemode delay. Delay from firing universal state before stuff happens

	var/supply_delay = 100 //Delay before meteor supplies are spawned in tenth of seconds

	var/meteor_shuttle_multiplier = 3 //How much more will we need to hold out ? Here 30 minutes until the shuttle arrives. Multiplies by 10

	var/const/meteor_delay_l = 4500 //Lower interval to meteor wave arrival, here 7.5 minutes
	var/const/meteor_delay_h = 6000 //Higher interval to meteor wave arrival, here 10 minutes
	var/meteor_delay = 0 //Final meteor delay, must be defined as 0 to automatically generate

	var/meteors_allowed = 0 //Can we send the meteors ?

	var/meteor_wave_size_l = 150 //Lower interval to meteor wave size
	var/meteor_wave_size_h = 200 //Higher interval to meteor wave size

/datum/universal_state/meteor_storm/OnShuttleCall(var/mob/user)
	if(user)
		to_chat(user, "<span class='sinister'>You hear an automatic dispatch from Nanotrasen. It states that Centcomm is being shielded due to an incoming meteor storm and that regular shuttle service has been interrupted.</span>")
	return 0

/datum/universal_state/meteor_storm/OnEnter()

	sleep(meteor_extra_announce_delay) //Pause everything as according to the extra delay

	world << sound('sound/machines/warning.ogg') //The same chime as the Delta countdown, just twice

	if(!meteor_delay)
		meteor_delay = rand((meteor_delay_l/600), (meteor_delay_h/600))*600 //Let's set up the meteor delay in here

	sleep(20) //Two seconds for warning to play

	var/datum/command_alert/meteor_round/CA = new()
	CA.meteor_delay = meteor_delay
	CA.supply_delay = supply_delay
	command_alert(CA)

	message_admins("Meteor Storm announcement given. Meteors will arrive in approximately [round(meteor_delay/600)] minutes. Shuttle will take [10*meteor_shuttle_multiplier] minutes to arrive and supplies are about to be dispatched in the Bar.")

	spawn(100) //Time for the announcement to spell out)

		emergency_shuttle.incall(meteor_shuttle_multiplier)
		captain_announce("A backup emergency shuttle has been called. It will arrive in [round((emergency_shuttle.timeleft())/60)] minutes. Justification : 'Major meteor storm inbound. Evacuation procedures deferred to Space Weather Inc. THIS IS NOT A DRILL'")
		world << sound('sound/AI/shuttlecalled.ogg')

	spawn(supply_delay) //Panic inverval

		meteor_initial_supply() //Handled in meteor_supply.dm

		ticker.StartThematic("endgame") //We can start building up now and then. If someone feels like this gamemode deserves a unique music playlist, they can go ahead and do that

		spawn(meteor_delay)
			meteors_allowed = 1
			check_meteor_storm()

//This proc needs to be called every time meteors_allowed is set to 1, aka when starting the mayhem. Obviously, do not call it in repeating procs
/datum/universal_state/meteor_storm/proc/check_meteor_storm()

	if(!meteors_allowed)
		return

	spawn()
		while(meteors_allowed && src == global.universe)
			var/meteors_in_wave = rand(meteor_wave_size_l, meteor_wave_size_h)
			meteor_wave(meteors_in_wave, 3, offset_origin = 150, offset_dest = 230)
			sleep(10)