#define scp_delay rand(6000,9000)
#define mystery_delay rand(3000,6000)
#define first_dispatch_prepare rand(300,1200)
#define second_dispatch_prepare rand(3000,6000)
#define last_dispatch_prepare rand(6000,9000)
#define takeover_scp rand(300,600)

/datum/game_mode/containment_breach

	name = "containment breach"
	config_tag = "scp"
	required_players = 15
	required_players_secret = 25

	var/const/waittime_l = 600
	var/const/waittime_h = 1800
	var/containment_breached = 0
	var/adminControl = 0
	var/tStart //When the action started
	var/zMain = 1 //This is where the action occurs
	var/list/subjects = list() //The things that got out
	var/state = 0
	var/tickerPeriod = 30
	var/scpEventAreas = list()

	var/scp_spaced = 0
	var/scp_gone = 0
	var/scp_disabled = 0

	var/list/milestones = list(
		//"milestone" = list(
			//0,	//time to trigger (in deciseconds, from start of action), 0 after
			//list(),	//things to call once upon trigger
			//list(),	//things to start calling regularly after trigger
			//),
		"Intercept" = list(
			1000,
			list("send_intercept"),
			list(),
            ),
        "Early Game" = list(
            2000,
            list("spawnSubject"),
            list(
                "checkSubjectStatus" 	= 30,
                "randomEvent" 			= 1800
                ),
            ),
        "Announcement" = list(
            3000,
            list("announceSubject"),
            list(),
            ),
        "First Dispatch" = list(
            4000,
            list("firstDispatch"),
            list(),
            ),
        "Second Dispatch" = list(
            5000,
            list("secondDispatch"),
            list(),
            ),
        "Last Dispatch" = list(
            6000,
            list("lastDispatch"),
            list(),
            ),
		"Takeover" = list(
			7000,
			list("takeoverAndNuke"),
			list(),
			),
		)

	uplink_welcome = "SCP Containment Control Console"
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
	src.setMilestones()
	spawn() src.ticker()
	return

/datum/game_mode/containment_breach/proc/setMilestones()
	src.milestones["Intercept"][1] = rand(waittime_l, waittime_h)
	src.milestones["Early Game"][1] = scp_delay + src.milestones["Intercept"][1]
	src.milestones["Announcement"][1] = mystery_delay + src.milestones["Early Game"][1]
	src.milestones["First Dispatch"][1] = first_dispatch_prepare + src.milestones["Announcement"][1]
	src.milestones["Second Dispatch"][1] = second_dispatch_prepare + src.milestones["First Dispatch"][1]
	src.milestones["Last Dispatch"][1] = last_dispatch_prepare + src.milestones["Second Dispatch"][1]
	src.milestones["Takeover"][1] = takeover_scp + src.milestones["Last Dispatch"][1]
	return

/datum/game_mode/containment_breach/proc/ticker()
	src.tStart = world.timeofday //We're counting all times from this moment on.
	var/lastCycle
	var/milestone
	var/event
	while(src) //This is going to run forever or until manually killed
		for(milestone in src.milestones)
			milestone = milestones[milestone]
			if(milestone[1]) //If it hasn't passed yet
				if((world.timeofday - src.tStart) > milestone[1]) //If it just passed now
					milestone[1] = 0 //Set to zero so we know it's passed
					for(event in milestone[2])
						spawn() call(src,event)() //Call on-trigger events
						testing("Firing event")
			else //If it has passed, call after-trigger events
				for(event in milestone[3])
					if((world.timeofday - lastCycle) > milestone[3][event])
						spawn() call(src,event)()
		lastCycle = world.time
		sleep(src.tickerPeriod)
	return

/datum/game_mode/containment_breach/proc/takeoverAndNuke()
	world << "<span class='danger'>Illegal access to [station_name()]'s systems. Beginning emergency shutdown.</span>"
	sleep(100)
	world << "<span class='danger'>Shutdown cancelled. Access logged as SC*$^///?!-079^^^^*?. Writing to memory.</span>"
	sleep(50)
	world << "<span class='danger'>Mainframe ready. Please input a command.</span>"
	sleep(10)
	world << "access_onboard_nuke(securized_access=1, remote=1)"
	sleep(30)
	world << "<span class='danger'>Access refused. No remote access allowed unless Delta code is activated.</span>"
	sleep(10)
	world << "<span class='danger'>Please input a command.</span>"
	sleep(10)
	world << "delta_code(nt_auth_key=*************************)"
	spawn(50)
	set_security_level("delta")
	command_alert("Hostile runt/es detect?*^^ in all stat!on syste*%$$!-.", "Anomaly Alert")
	world << sound('sound/AI/aimalf.ogg')
	spawn(10)
	world << "<span class='danger'>Please input a command.</span>"
	sleep(10)
	world << "access_onboard_nuke(securized_access=1, remote=1)"
	sleep(10)
	world << "<span class='danger'>Interfacing with nuclear fission device... Ready.</span>"
	sleep(10)
	world << "arm(code=*****, time=100)"
	sleep(10)
	world << "<span class='danger'>Nuke armed. Current time : 10 seconds. Logging.</span>"
	world << 'sound/machines/Alarm.ogg'
	sleep(10)
	world << "deactivate_interface(nuke)"
	sleep(10)
	world << "<span class='danger'>Interface of nuke deactivated.</span>"
	sleep(10)
	world << "del(remote)"
	sleep(10)
	world << "<span class='danger'>WARNING: Runtime error (Invalid arg: remote in system.main.331). Report to Nanotrasen ? Y/N.</span>"
	sleep(50)
	world << "<span class='danger'>Crash log transmitted.</span>"
	sleep(10) //That's 10 seconds
	enter_allowed = 0
	if(ticker)
		ticker.station_explosion_cinematic(0,null)
		if(ticker.mode)
			ticker.mode:station_was_nuked = 1
	return

/datum/game_mode/containment_breach/proc/spawnSubject()
	biohazard_alert()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in machines)
		if(temp_vent.loc.z == src.zMain && !temp_vent.welded && temp_vent.network)
			vents += temp_vent
	var/mob/living/simple_animal/sculpture/scp = new(get_turf(pick(vents)))
	subjects += scp
	containment_breached = 1
	return

/datum/game_mode/containment_breach/proc/checkSubjectStatus()

	for(var/mob/living/simple_animal/sculpture/scp in subjects)
		if(!scp) //What spoopy ?
			scp_gone = 1
		if(scp.loc.z != zMain)
			scp_spaced = 1
		if(scp.hibernate == 1)
			message_admins("SCP-173 is hibernating during a Containment Breach round, please avoid that. Round will end if SCP-173 is still hibernating when checked in one minute.")
			spawn(600)
				if(scp.hibernate == 1)
					scp_disabled = 1

/datum/game_mode/containment_breach/proc/announceSubject()
	//world << sound('sound/AI/containment.ogg')
	command_alert("A containment breach has been detected abord [station_name()], this station is now on lockdown. Directives will be sent to this station's Command staff in short order.", "Anomaly Alert")
	return

/datum/game_mode/containment_breach/proc/firstDispatch()

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
			command_alert("Update downloaded and printed out at all communications consoles.", "Nanotrasen Official Instructions.")
			world << sound('sound/AI/commandreport.ogg')

/datum/game_mode/containment_breach/proc/secondDispatch()

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
		command_alert("Update downloaded and printed out at all communications consoles.", "Nanotrasen Official Instructions.")
		world << sound('sound/AI/commandreport.ogg')

/datum/game_mode/containment_breach/proc/lastDispatch()

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
		command_alert("Update downloaded and printed out at all communications consoles.", "Nanotrasen Official Instructions.")
		world << sound('sound/AI/commandreport.ogg')

/datum/game_mode/containment_breach/proc/randomEvent()
	switch(rand(1,5))
		if(1)
			new/datum/event/communications_blackout()
		if(2)
			command_alert("Illegal access to the station's powernet systems detected. Please repair any damage that may have occured", "Powernet Alert")
			//world << sound('sound/AI/illegalaccess.ogg')
			for(var/area/area in world)
				if(prob(5))
					scpEventAreas += area
				for(var/obj/machinery/light/L in scpEventAreas)
					L.flicker(10)
				if(prob(75))
					for(var/obj/machinery/door/airlock/temp_airlock in scpEventAreas)
						temp_airlock.prison_open() //This is effectively a 'open and bolt' routine

				if(prob(40))
					for(var/obj/machinery/power/apc/temp_apc in scpEventAreas)
						temp_apc.toggle_breaker()

				if(prob(25))
					for(var/obj/machinery/power/apc/temp_apc in scpEventAreas)
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
			for(var/mob/living/simple_animal/sculpture/scp in subjects)
				empulse(get_turf(scp), 2, 4, 0)
				//var/obj/item/weapon/grenade/flashbang/clusterbang/surprise = new /obj/item/weapon/grenade/flashbang/clusterbang(get_turf(scp))
				new /obj/item/weapon/grenade/flashbang/clusterbang(get_turf(scp))
 				//surprise.prime() //Have fun

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
		world << {"<FONT size = 3><B>Victory ! The SCP has been spaced!</B></FONT></br>
<B>A containment team will recover the anomaly which is now drifing in deep space.</B>"}

	else if(scp_gone)
		feedback_set_details("round_end_result","Win - SCP destroyed")
		world << {"<FONT size = 3><B>Victory ! The SCP has been neutralized!</B></FONT></br>
<B>Whatever happened, the anomaly is now gone forever. It's all better off this way.</B>"}

	else if(scp_disabled)
		feedback_set_details("round_end_result","Win - SCP disabled")
		world << {"<FONT size = 3><B>Victory ! The SCP has been disabled!</B></FONT></br>
<B>It appears the anomaly is no longer hostile. A recovery team will arrive shortly.</B>"}

	else if(station_was_nuked)
		feedback_set_details("round_end_result","Loss - Station nuked")
		world << {"<FONT size = 3><B>Defeat ! The station has been destroyed!</B></FONT></br>
<B>An unknown entity used the confusion to nuke the station, and SCP is still roaming in space.</B>"}

	world << "<span class='notice'>Rebooting in 30s</span>"
	..()
	return 1
