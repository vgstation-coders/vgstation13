/datum/event/communications_blackout/can_start()
	return 25

/datum/event/communications_blackout/announce()
	var/alert = pick(	"Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you*%fj00)`5vc-BZZT", \
						"Ionospheric anomalies detected. Temporary telecommunication failu*3mga;b4;'1v¬-BZZZT", \
						"Ionospheric anomalies detected. Temporary telec#MCi46:5.;@63-BZZZZT", \
						"Ionospheric anomalies dete'fZ\\kg5_0-BZZZZZT", \
						"Ionospheri:%£ MCayj^j<.3-BZZZZZZT", \
						"#4nd%;f4y6,>£%-BZZZZZZZT")

	for(var/mob/living/silicon/ai/A in player_list)	//AIs are always aware of communication blackouts.
		to_chat(A, "<br>")
		to_chat(A, "<span class='danger'>[alert]</span>")
		to_chat(A, "<br>")

	if(prob(30))	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.
		command_alert(/datum/command_alert/comms_blackout)

/datum/event/communications_blackout/start()
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emp_act(1)

/proc/communications_blackout(var/silent = 1)
	if(!silent)
		command_alert(/datum/command_alert/comms_blackout)
	else // AIs will always know if there's a comm blackout, rogue AIs could then lie about comm blackouts in the future while they shutdown comms
		for(var/mob/living/silicon/ai/A in player_list)
			to_chat(A, "<br>")
			to_chat(A, "<span class='danger'><b>Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you-BZZT</span>")
			to_chat(A, "<br>")
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emp_act(1)
