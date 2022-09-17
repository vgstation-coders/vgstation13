/**
	Time agent twin

	Take the other time agent's jump charge, erase them from the timeline, then extract via the temporal anomaly.

**/

/datum/role/time_agent/eviltwin
	name = TIMEAGENTTWIN
	id = TIMEAGENTTWIN
	var/datum/role/time_agent/erase_target = null
	is_twin = TRUE
	default_admin_voice = "The Agency"
	admin_voice_style = "notice"


/datum/role/time_agent/eviltwin/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>[custom]</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Time Agent.<br>Specifically you are a scientist by the name of John Beckett, having discovered a method to travel through time, and becoming lost to it. <br>\
			Unfortunately, you have been sucked into the vacuum of a destabilizing timeline, losing your jump charge in the process.<br>\
			And you know who caused the destabilization: John Beckett. Steal your doppelganger's jump charge, erase him from the timeline,<br>\
			and use the jump charge to escape through the temporal anomaly before it's too late.</span>")


/datum/role/time_agent/eviltwin/ForgeObjectives()
	var/datum/objective/target/assassinate/erase/kill_target = new(auto_target = FALSE)
	if(kill_target.set_target(erase_target.antag))
		AppendObjective(kill_target)


/datum/role/time_agent/eviltwin/timer_action(severity)
	if(severity == 1)
		var/mob/living/carbon/human/H = antag.current
		spawn_rand_maintenance(H) // Just so the teleporter itself works
