/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/waittime_l = 600 //Lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //Upper bound on time before intercept arrives (in tenths of seconds)
	var/const/meteorannouncedelay_l = 6000 //Lower bound on announcement, here 10 minutes
	var/const/meteorannouncedelay_h = 9000 //Upper bound on announcement, here 15 minutes
	var/meteorannouncedelay = 7500 //Final announcement delay, this is a failsafe value
	var/const/supplydelay = 300 //Delay before meteor supplies are spawned in tenth of seconds
	var/const/meteordelay_l = 1800 //Lower bound to meteor arrival, here 3 minutes
	var/const/meteordelay_h = 3000 //Higher bound to meteor arrival, here 5 minutes
	var/const/meteorshuttlemultiplier = 4.5 //How much more will we need to hold out ? Here 45 minutes until the shuttle arrives. 1 is 10 minutes
	var/meteordelay = 2400 //Final meteor delay, failsafe as above
	var/nometeors = 1 //Can we send the meteors ?
	required_players_secret = 20

	/var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread

	uplink_welcome = "EVIL METEOR Uplink Console:"
	uplink_uses = 10

/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"

/datum/universal_state/meteor_storm
 	name = "Meteor Storm"
 	desc = "Meteors are currently running havoc around this sector. Better get out of here as fast as humanly possible."

 	decay_rate = 0 // Just to make sure

/datum/universal_state/meteor_storm/OnEnter()

 	meteor_wave_infodump(4) //See meteors.dm
 	meteor_state_confirmation = 1 //Used as a failsafe

/datum/universal_state/meteor_storm/OnExit()

 	meteor_state_confirmation = 0 //If this somehow happens

/datum/universal_state/meteor_storm/OnShuttleCall(var/mob/user)
	if(user)
		user << "<span class='notice'>You hear an automatic dispatch from Nanotrasen. It states that Centcomm is being shielded due to the incoming meteor storm and that regular shuttle service has been interrupted.</span>"
	return 0

/datum/game_mode/meteor/post_setup()
	defer_powernet_rebuild = 2//Might help with the lag

		//Let's set up the announcement and meteor delay immediatly to send to admins and use later
	meteorannouncedelay = rand((meteorannouncedelay_l/600), (meteorannouncedelay_h/600))*600 //Minute interval for simplicity
	meteordelay = rand((meteordelay_l/600), (meteordelay_h/600))*600 //Ditto above

	spawn(450) //Give everything 45 seconds to initialize, this does not delay the rest of post_setup() nor the game and ensures deadmins aren't aware in advance and the admins are
		message_admins("Meteor storm confirmed by Space Weather Incorporated. Announcement arrives in [round((meteorannouncedelay-450)/600)] minutes, actual meteors in [round((meteordelay+meteorannouncedelay-450)/600)] minutes. Shuttle will take [10*meteorshuttlemultiplier] minutes to arrive and supplies will be dispatched in the Bar.")

	spawn(rand(waittime_l, waittime_h))
		send_intercept()

	spawn(meteorannouncedelay)
		if(prob(70)) //Slighty off-scale
			command_alert("A meteor storm has been detected in proximity of [station_name()] and is expected to strike within [round((rand(meteordelay - 600, meteordelay + 600))/600)] minutes. A backup emergency shuttle is being dispatched and emergency gear should be teleported into your station's Bar area in [supplydelay/10] seconds. Make good use of these supplies to build a safe zone and good luck.", "Space Weather Automated Announcements")
		else //Oh boy
			command_alert("A meteor storm has been detected in proximity of [station_name()] and is expected to strike within [round((rand(meteordelay - 1200, meteordelay + 3000))/600)] minutes. A backup emergency shuttle is being dispatched and emergency gear should be teleported into your station's Bar area in [supplydelay/10] seconds. Make good use of these supplies to build a safe zone and good luck.", "Space Weather Automated Announcements")
		world << sound('sound/AI/meteorround.ogg')
		for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world) //Borg RCDs are fairly cheap, so disabling those
			rcd.disabled = 1

		spawn(100) //Panic interval
			emergency_shuttle.incall(meteorshuttlemultiplier)
			captain_announce("A backup emergency shuttle has been called. It will arrive in [round((emergency_shuttle.timeleft())/60)] minutes. Justification : 'Major meteor storm inbound in this sector. Evacuation procedures deferred to Space Weather Inc. THIS IS NOT A DRILL'")
			world << sound('sound/AI/shuttlecalled.ogg')
			SetUniversalState(/datum/universal_state/meteor_storm)

		spawn(supplydelay)

		meteorsupplyspawning()

		spawn(meteordelay)
			nometeors = 0

/datum/game_mode/meteor/process()
	if(!nometeors)
		meteors_in_wave = rand(200,500) //Between 200 and 500 meteors per wave. Now you may think 'OH SHIT NIGGER WHAT ARE YOU DOING', but waves are supposed to be massive like that
		meteor_wave(meteors_in_wave)
		//meteor_subevent(pick(1,2)) //I sure hope this won't cause lag you guise //Has to be finished, and most likely balanced, so not in this PR
	if(prob(0.02)) //The entire sector is meteors, so a stray meteor can strike before or during the main wave. Gotta spot those booms ! 1 out of a 5000 chance, but luck is a hard mistress and a few will likely hit
		spawn_meteor(pick(1,2,4,8))

/datum/game_mode/meteor/declare_completion()
	var/text
	var/survivors = 0
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)	continue
			switch(location.loc.type)
				if(/area/shuttle/escape/centcom)
					text += "<br><b><font size=2>[player.real_name] escaped on the emergency shuttle</font></b>"
				if(/area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
					text += "<br><font size=2>[player.real_name] escaped in a life pod.</font>"
				else
					text += "<br><font size=1>[player.real_name] survived but is stranded without any hope of rescue.</font>"
			survivors++

	if(survivors)
		world << "\blue <B>The following survived the meteor storm</B>:[text]"
	else
		world << "\blue <B>Nobody survived the meteor storm!</B>"

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1
