/datum/game_mode/containment_breach
	name = "containment breach"
	config_tag = "scp"
	required_players = 15
	required_players_secret = 25

	var/const/waittime_l = 600 //Lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //Upper bound on time before intercept arrives (in tenths of seconds)
	var/const/scp_delay_l = 6000 //Time before we get shit going, 10 to 15 minutes here
	var/const/scp_delay_h = 9000
	var/const/mystery_delay_l = 3000 //Let SCP have a bit of fun while Nanotrasen unfucks itself
	var/const/mystery_delay_h = 6000
	var/const/first_dispatch_prepare_l = 300 //Tell them what to expect
	var/const/first_dispatch_prepare_h = 1200
	var/const/second_dispatch_prepare_l = 3000 //Send precise guidelines
	var/const/second_dispatch_prepare_h = 6000
	var/const/last_dispatch_prepare_l = 6000 //Oh hey, did we tell you about this time limit ?
	var/const/last_dispatch_prepare_h = 9000
	var/const/takeover_l = 300
	var/const/takeover_h = 600
	var/containment_breached = 0 //Is SCP a go ?
	var/breach_event_running = 0 //Is an event happening in the meantime ?
	var/scp_spaced = 0 //Did we send SCP away for recovery ?
	var/scp_gone = 0 //Just gone, good luck figuring out why
	var/scp_disabled = 0 //SCP has been set to hibernate by admins, thanks admins
	var/list/area/scpEventAreas = list() //BYOND YOU PIECE OF SHIT
	var/list/mob/living/simple_animal/sculpture/theonlyone = list()

	uplink_welcome = "SCP Containment Control Console:"
	uplink_uses = 10

/datum/universal_state/scp
 	name = "Containment Breach"
 	desc = "Rogue anomalies have been detected on station. Exercise extreme caution"

 	decay_rate = 0 // Just to make sure

/datum/universal_state/scp/OnShuttleCall(var/mob/user)
	if(user)
		user << "<span class='notice'>You hear an extremely fuzzy broadcast. You can barely make out any of it, this can't be good.</span>"
	return 0

/datum/game_mode/containment_breach/announce()
	world << "<B>The current game mode is - Containment Breach!</B>"
	world << "<B>Something has went horribly wrong and strange monstrosities are flooding into the station. Follow Nanostraten's instructions as they arrive!</B>"

/datum/game_mode/containment_breach/pre_setup()
	return 1

/datum/game_mode/containment_breach/post_setup()

	spawn(rand(waittime_l, waittime_h))
		send_intercept()

	spawn(rand(scp_delay_l, scp_delay_h)) //Defined as 5 to 10 minutes

		biohazard_alert() //Ohmergad it's Blab let's check Maint guise

		//Ungraciously stolen from alien code

		var/list/vents = list()
		for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in machines)
			if(temp_vent.loc.z == 1 && !temp_vent.welded && temp_vent.network)
				vents += temp_vent

		var/obj/vent = pick(vents)

		spawn(5) //OH SHI-
			var/mob/living/simple_animal/sculpture/scp = new /mob/living/simple_animal/sculpture(get_turf(vent))
			theonlyone += scp
			containment_breached = 1

		spawn(rand(mystery_delay_l, mystery_delay_h))

			//world << sound('sound/AI/containment.ogg')
			command_alert("A containment breach has been detected abord [station_name()], this station is now on lockdown. Directives will be sent to this station's Command staff in short order.", "Anomaly Alert")

			//Lots of spam, but it works
			spawn(rand(first_dispatch_prepare_l, first_dispatch_prepare_h))
				for(var/obj/machinery/computer/communications/comm in machines)
					if(!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
						var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper(comm.loc)
						intercept.name = "paper- 'Containment Breach Instructions'"
						intercept.info = {"<FONT size = 3><B>Containment Breach Instructions:</B></FONT><HR>
<*> A rogue anomalistic creature has been detected on your station. Please ensure the following points are respected :</br>
<*> The anomaly, therefore known as SCP-173 or *REDACTED* must be kept in  direct sight at all times. While in direct sight, it cannot act.</br>
<*> The anomaly can move at tremendous speeds when left unchecked and can use vent connections. It is also <B>extremely hostile</B>.</br>
 Reports indicate that the containment breach was caused by external forces, exercise extreme caution at all times.</br>
<I> Another dispatch will be sent when containment protocols are ready.</I></br>"}

						comm.messagetitle.Add("Containment Breach Instructions")
						comm.messagetext.Add({"<FONT size = 3><B>Containment Breach Instructions:</B></FONT><HR>
<*> A rogue anomalistic creature has been detected on your station. Please ensure the following points are respected :</br>
<*> The anomaly, therefore known as SCP-173 or *REDACTED* must be kept in  direct sight at all times. While in direct sight, it cannot act.</br>
<*> The anomaly can move at tremendous speeds when left unchecked and can use vent connections. It is also extremely hostilee.</br>
 Reports indicate that the containment breach was caused by external forces, exercise extreme caution at all times.</br>
<I> Another dispatch will be sent when containment protocols are ready.</I></br>"})
				world << sound('sound/AI/commandreport.ogg')

				spawn(rand(second_dispatch_prepare_l, second_dispatch_prepare_h))
					for(var/obj/machinery/computer/communications/comm in machines)
						if(!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
							var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper(comm.loc)
							intercept.name = "paper- 'SCP Recovery Protocol'"
							intercept.info = {"<FONT size = 3><B>SCP Recovery Protocol:</B></FONT><HR>
<*> Encircle *REDACTED* with as much crewmen as possible. Anomaly must be kept in sight by carbon lifeforms at all times.</br>
<*> Carry the *REDACTED* towards any available bluespace teleportation unit. In a pinch, shuttles may also work.</br>
<*> Force the *REDACTED* into the field and send away off-station. A professional recovery team will arrive to contain the anomaly.</br>
 Note that we are now certain that an entity foreign to the station is using this breach to infiltrate the station's electronics.</br>
<I> No further instructions should be needed. Should new information be acquired, other dispatchs will be sent.</I></br>"}

							comm.messagetitle.Add("SCP Recovery Protocol")
							comm.messagetext.Add({"<FONT size = 3><B>SCP Recovery Protocol:</B></FONT><HR>
<*> Encircle *REDACTED* with as much crewmen as possible. Anomaly must be kept in sight by carbon lifeforms at all times.</br>
<*> Carry *REDACTED* towards any available bluespace teleportation unit. In a pinch, shuttles may also work.</br>
<*> Force *REDACTED* into the field and send away off-station. A professional recovery team will arrive to contain the anomaly.</br>
 Note that we are now certain that an entity foreign to the station is using this breach to infiltrate the station's electronics.</br>
<I> No further instructions should be needed. Should new information be acquired, other dispatchs will be sent.</I></br>"})
					world << sound('sound/AI/commandreport.ogg')

					//Last piece of muh lore. From there, shit is going down real quick
					spawn(rand(last_dispatch_prepare_l, last_dispatch_prepare_h))
						for(var/obj/machinery/computer/communications/comm in machines)
							if(!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
								var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper(comm.loc)
								intercept.name = "paper- 'SCP Emergency Update'"
								intercept.info = {"<FONT size = 3><B>SCP Emergency Update:</B></FONT><HR>
 <B>WARNING:</B> UNKNOWN ANOMALY ?$*KING OVER CONTROL O/ [station_name()]. ESTI~%*0/ E.T.///1-&* MIN/??</br>
 *RED//173/* APPEARS TO BE *B*ES!ENT.$%!! TAK?V?R$*^%%-</br>"}

								comm.messagetitle.Add("SCP Emergency Update")
								comm.messagetext.Add({"<FONT size = 3><B>SCP Emergency Update:</B></FONT><HR>
 <B>WARNING:</B> UNKNOWN ANOMALY ?$*KING OVER CONTROL O/ [station_name()]. ESTI~%*0/ E.T.///1-&* MIN/??</br>
 *RED//173/* APPEARS TO BE *B*ES!ENT.$%!! TAK?V?R$*^%%-</br>"})
						world << sound('sound/AI/commandreport.ogg')

						//Start takeover countdown
						spawn(rand(takeover_l, takeover_h))
							//Once this is finishd, the station loses, the end
							//This is mostly muh lore fluff, feel free to comment that out if it causes lag
							//Also, welcome to the spawn() staircase of DOOM. Enjoy your stay, mortal
							world << "<span class='danger'>Illegal access to [station_name()]'s systems. Beginning emergency shutdown.</span>"
							spawn(100)
								world << "<span class='danger'>Shutdown cancelled. Access logged as SC*$^///?!-079^^^^*?. Writing to memory.</span>"
								spawn(50)
									world << "<span class='danger'>Mainframe ready. Please input a command.</span>"
									spawn(10)
										world << "access_onboard_nuke(securized_access=1, remote=1)"
										spawn(10)
											world << "<span class='danger'>Access refused. No remote access unless Delta code is activated.</span>"
											spawn(10)
												world << "<span class='danger'>Please input a command.</span>"
												spawn(10)
													world << "delta_code(nt_auth_key=*************************)"
													spawn(50)
														set_security_level("delta")
														command_alert("Hostile runt/es detect?*^^ in all stat!on syste*%$$!-.", "Anomaly Alert")
														world << sound('sound/AI/aimalf.ogg')
														spawn(10)
															world << "<span class='danger'>Please input a command.</span>"
															spawn(10)
																world << "access_onboard_nuke(securized_access=1, remote=1)"
																spawn(10)
																	world << "<span class='danger'>Interfacing with nuclear fission device. Ready.</span>"
																	spawn(10)
																		world << "arm(code=*****, time=100)"
																		spawn
																			world << "<span class='danger'>Nuke armed. Current time : 10 seconds. Logging.</span>"
																			for(var/obj/machinery/nuclearbomb/nuke in world)
																				nuke.extended = 1
																				nuke.timeleft = 30
																				nuke.safety = 0
																				nuke.timing = 1
																			spawn(10)
																				world << "deactivate_interface(nuke)"
																				spawn(10)
																					world << "<span class='danger'>Interface of nuke deactivated.</span>"
																					spawn(10)
																						world << "del(remote)"
																						spawn(10)
																							world << "<span class='danger'>WARNING: Runtime error (Invalid arg: remote in system.main.331). Report to Nanotrasen ? Y/N.</span>"
																							spawn(50)
																								world << "<span class='danger'>Crash log transmitted.</span>"
																			world << 'sound/machines/Alarm.ogg'
																			spawn(100)
																				enter_allowed = 0
																				if(ticker)
																					ticker.station_explosion_cinematic(0,null)
																					if(ticker.mode)
																						ticker.mode:station_was_nuked = 1


/datum/game_mode/containment_breach/process()

	if(!containment_breached) //Gate off all SCP-related stuff until SCP actually appears
		return

	if(!breach_event_running)
		breach_event_running = 1
		run_breach_event()

	//Let's check SCP's whereabouts every single tick, not that expensive. RIGHT ?
	for(var/mob/living/simple_animal/sculpture/scp in theonlyone)
		if(null) //What spoopy ?
			scp_gone = 1
		if(scp.loc.z != 1)
			scp_spaced = 1
		if(scp.hibernate == 1)
			message_admins("SCP-173 is hibernating during a Containment Breach round, please avoid that. Round will end if SCP-173 is still hibernating when checked in one minute.")
			spawn(600)
				if(scp.hibernate == 1)
					scp_disabled = 1

/datum/game_mode/containment_breach/proc/run_breach_event()
	//The containment breach isn't just SCP-173. Notably, SCP-079 will get access to the station (and even the sector to a degree, budget firewalls oblige) and act as very rogue AI
	//Since it doesn't take lots of time to neutralize SCP and teleport it away, shit happens very quickly
	//Oh, and I sure hope it doesn't total your teleporter, otherwise you're going to have fun...
	spawn(300) //Very cheap way of having an initial delay on the first event
		switch(rand(1,5))
			if(1)
				new /datum/event/communications_blackout
			if(2)
				command_alert("Illegal access to the station's powernet systems detected. Please repair any damage that may have occured", "Powernet Alert")
				//world << sound('sound/AI/illegalaccess.ogg')
				for(var/area/area in world)
					if(prob(5))
						scpEventAreas += area
					for(var/area/A in scpEventAreas)
						for(var/obj/machinery/light/L in A)
							L.flicker(10)
						if(prob(75))
							for(var/obj/machinery/door/airlock/temp_airlock in A)
								temp_airlock.prison_open() //This is effectively a 'open and bolt' routine
						if(prob(40))
							for(var/obj/machinery/power/apc/temp_apc in A)
								temp_apc.toggle_breaker()
						if(prob(25))
							for(var/obj/machinery/power/apc/temp_apc in A)
								temp_apc.overload_lighting()
					scpEventAreas = list()
			if(3)
				command_alert("Bluespace artillery shelling detected. Brace for impact", "Nanotrasen Fleet Alert")
				//world << sound('sound/AI/bluespaceartillery.ogg')
				spawn(100)
					spawn(rand(10,30))
						explosion(locate(rand(1,world.maxx),rand(1,world.maxy),1), rand(0,1), rand(1,3), rand(2,4), 8, 0)
					spawn(rand(20,50))
						explosion(locate(rand(1,world.maxx),rand(1,world.maxy),1), rand(1,3), rand(2,4), rand(3,6), 8, 0) //The main shell
					spawn(rand(10,20))
						explosion(locate(rand(1,world.maxx),rand(1,world.maxy),1), rand(0,1), rand(1,3), rand(2,4), 8, 0)
					spawn(rand(50,100))
						explosion(locate(rand(1,world.maxx),rand(1,world.maxy),1), rand(1,3), rand(2,4), rand(3,6), 8, 0)
					spawn(rand(20,40))
						explosion(locate(rand(1,world.maxx),rand(1,world.maxy),1), rand(0,1), rand(1,3), rand(2,4), 8, 0)
					if(prob(25)) //Muh RNG-based gameplay
						spawn(rand(50,100))
							explosion(locate(rand(1,world.maxx),rand(1,world.maxy),1), rand(1,3), rand(2,4), rand(3,6), 8, 0)
			if(4)
				command_alert("Malignous trojan detected in the station's electronic systems. Please ensure all machinery is functioning properly", "Powernet Alert")
				//world << sound('sound/AI/trojan.ogg')
				for(var/obj/machinery/door/airlock/temp_airlock in world)
					if(prob(2))
						temp_airlock.prison_open()
					if(prob(1))
						temp_airlock.secondsElectrified = -1
			if(5)
				//If the crew has SCP locked down but are taking their sweet time, give them a nasty surprise
				for(var/mob/living/simple_animal/sculpture/scp in theonlyone)
					empulse(scp.loc, 2, 4, 0)
					var/obj/item/weapon/grenade/flashbang/clusterbang/surprise = new /obj/item/weapon/grenade/flashbang/clusterbang(scp.loc)
					spawn(1)
						surprise.prime() //Have fun
	spawn(rand(1200,3000)) //2 minutes to 5 minutes
		breach_event_running = 0

/datum/game_mode/containment_breach/check_finished()
	if(!containment_breached) //Did we spawn SCP yet ?
		return 0
	if(scp_spaced) //Was SCP launched/teleported off-station ?
		return 1
	if(scp_gone) //Whatever happened, was SCP removed ?
		return 1
	if(scp_disabled) //Was SCP forced to hibernate by the admins because they hate fun ?
		return 1
	if(station_was_nuked) //Did the nuke happen ?
		return 1
	return 0

/datum/game_mode/containment_breach/declare_completion()

	if(scp_spaced)
		feedback_set_details("round_end_result","Win - SCP recovered")
		world << {"<FONT size = 3><B>Victory ! The SCP has been spaced!</B></FONT>
<B>A containment team will recover the anomaly which is now drifing in deep space.</B>"}

	else if(scp_gone)
		feedback_set_details("round_end_result","Win - SCP destroyed")
		world << {"<FONT size = 3><B>Victory ! The SCP has been neutralized!</B></FONT>
<B>Whatever happened, the anomaly is now gone forever. It's all better off this way.</B>"}

	else if(scp_disabled)
		feedback_set_details("round_end_result","Win - SCP disabled")
		world << {"<FONT size = 3><B>Victory ! The SCP has been disabled!</B></FONT>
<B>It appears the anomaly is no longer hostile. A recovery team will arrive shortly.</B>"}

	else if(station_was_nuked)
		feedback_set_details("round_end_result","Loss - Station nuked")
		world << {"<FONT size = 3><B>Defeat! The station has been destroyed!</B></FONT>
<B>An unknown entity used the confusion to nuke the station, and SCP is still roaming in space.</B>"}

	world << "<span class='notice'>Rebooting in 30s</span>"
	..()
	return 1
