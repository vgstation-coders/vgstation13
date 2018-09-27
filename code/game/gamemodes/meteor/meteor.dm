/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"

	var/const/waittime_l = 600 //Lower interval on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //Upper interval on time before intercept arrives (in tenths of seconds)

	var/const/meteor_announce_delay_l = 2100 //Lower interval on announcement, here 3 minutes and 30 seconds
	var/const/meteor_announce_delay_h = 3000 //Upper interval on announcement, here 5 minutes
	var/meteor_announce_delay = 2400 //Default final announcement delay

	required_players = 0
	required_players_secret = 20

	uplink_welcome = "EVIL METEOR Uplink Console:"
	uplink_uses = 20

/datum/game_mode/meteor/announce()
	to_chat(world, "<B>The current game mode is - Meteor!</B>")
	to_chat(world, "<B>The space station is about to be struck by a major meteor shower. You must hold out until the escape shuttle arrives.</B>")

/datum/game_mode/meteor/pre_setup()
	log_admin("Starting a round of meteor.")
	message_admins("Starting a round of meteor.")
	return 1

/datum/game_mode/meteor/post_setup()

	//Let's set up the announcement and meteor delay immediatly to send to the admins and use later
	meteor_announce_delay = rand((meteor_announce_delay_l/600), (meteor_announce_delay_h/600)) * 600 //Minute interval for simplicity

	spawn(300) //Give everything 30 seconds to initialize, this does not delay the rest of post_setup() nor the game and ensures deadmins aren't aware in advance and the admins are
		message_admins("Meteor storm confirmed by Space Weather Incorporated. Announcement arrives in approximately [round((meteor_announce_delay-200)/600)] minutes, further information will be given then.")

	spawn(rand(waittime_l, waittime_h))
		if(!mixed)
			send_intercept()

	spawn(meteor_announce_delay)

		SetUniversalState(/datum/universal_state/meteor_storm, 1, 1)

//Important note : This will only fire if the Meteors gamemode was fired
/datum/game_mode/meteor/declare_completion()
	var/text
	var/escapees = 0
	var/survivors = 0
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)
				continue
			switch(location.loc.type)
				if(/area/shuttle/escape/centcom)
					text += "<br><b><font size=2>[player.real_name] escaped on the emergency shuttle</font></b>"
					escapees++
					survivors++
				if(/area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
					text += "<br><font size=2>[player.real_name] escaped in a life pod.</font>"
					escapees++
					survivors++
				else
					text += "<br><font size=1>[player.real_name] is stranded in outer space without any hope of rescue.</font>"
					survivors++

	if(escapees)
		to_chat(world, "<span class='info'><B>The following escaped from the meteor storm</B>:[text]</span>")
	else if(survivors)
		to_chat(world, "<span class='info'><B>No-one escaped the meteor storm. The following are still alive for now</B>:[text]</span>")
	else
		to_chat(world, "<span class='info'><B>The meteor storm crashed this station with no survivors!</B></span>")

	feedback_set_details("round_end_result", "end - evacuation")
	feedback_set("round_end_result", survivors)

	..()
	return 1
