/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = W_CLASS_MEDIUM
	origin_tech = Tc_ENGINEERING + "=4;" + Tc_MATERIALS + "=4;" + Tc_BLUESPACE + "=2;" + Tc_PROGRAMMING + "=4"

	var/searching = 0
	//var/mob/living/carbon/brain/brainmob = null
	var/list/ghost_volunteers[0]
	req_access = list(access_robotics)
	locked = 2
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	var/ping_cooldown = 50
	var/list/ping_streaks = list()
	var/list/ping_times = list()
	var/loud_ping_streak = 10
	var/broadcast_ping_streak = 20
	var/datum/recruiter/recruiter = null

#ifdef DEBUG_ROLESELECT
/obj/item/device/mmi/posibrain/test/New()
	..()
	search_for_candidates()
#endif

/obj/item/device/mmi/posibrain/attack_self(mob/user as mob)
	if(brainmob && !brainmob.key && searching == 0)
		//Start the process of searching for a new user.
		to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start \the [src]'s boot process.</span>")
		search_for_candidates()

/obj/item/device/mmi/posibrain/proc/search_for_candidates()
	icon_state = "posibrain-searching"
	ghost_volunteers.len = 0
	src.searching = 1
	ping_streaks.len = 0
	ping_times.len = 0

	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = "posibrain"
		recruiter.role = ROLE_POSIBRAIN
		recruiter.jobban_roles = list(ROLE_POSIBRAIN)
		recruiter.logging = TRUE

		// A player has their role set to Yes or Always
		recruiter.player_volunteering = new /callback(src, nameof(src::recruiter_recruiting()))
		// ", but No or Never
		recruiter.player_not_volunteering = new /callback(src, nameof(src::recruiter_not_recruiting()))

		recruiter.recruited = new /callback(src, nameof(src::recruiter_recruited()))

	recruiter.request_player()


/obj/item/device/mmi/posibrain/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class=\"recruit\">You are a possible candidate for \a [src]. Get ready. ([controls])</span>")
	investigation_log(I_GHOST, "|| had a ghost automatically sign up to become its personality: [key_name(player)][player.locked_to ? ", who was haunting [player.locked_to]" : ""]")

/obj/item/device/mmi/posibrain/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	if(player.client && get_role_desire_str(player.client.prefs.roles[ROLE_POSIBRAIN]) != "Never")
		to_chat(player, "<span class=\"recruit\">Someone is requesting a personality for \a [src]. ([controls])</span>")

/obj/item/device/mmi/posibrain/proc/recruiter_recruited(mob/dead/observer/player)
	if(player)
		transfer_personality(player)

	reset_search()


/obj/item/device/mmi/posibrain/proc/transfer_personality(var/mob/candidate)

	src.searching = 0
	//src.brainmob.mind = candidate.mind Causes issues with traitor overlays and traitor specific chat.
	//src.brainmob.key = candidate.key
	src.brainmob.ckey = candidate.ckey
	src.brainmob.stat = 0
	src.name = "positronic brain ([src.brainmob.name])"

	to_chat(src.brainmob, "<b>You are \a [src], brought into existence on [station_name()].</b>")
	to_chat(src.brainmob, "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>")
	to_chat(src.brainmob, "<b>Remember, the purpose of your existence is to serve the crew and the station. <br/> <span class='userdanger'> Above all else, do no harm to the station or its crew.</span></b>")
	src.brainmob.mind.assigned_role = "Positronic Brain"

	var/turf/T = get_turf(src.loc)
	for (var/mob/M in viewers(T))
		M.show_message("<span class='notice'>\The [src] buzzes and beeps as it boots up.</span>")
	playsound(src, 'sound/misc/buzzbeep.ogg', 50, 1)
	icon_state = "posibrain-occupied"

	investigation_log(I_GHOST, "|| has been occupied by: [key_name(brainmob)]")

/obj/item/device/mmi/posibrain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.


	if(src.brainmob && src.brainmob.key)
		return

	src.searching = 0
	icon_state = "posibrain"

	var/turf/T = get_turf(src.loc)
	for (var/mob/M in viewers(T))
		M.show_message("<span class='notice'>\The [src] buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>")

/obj/item/device/mmi/posibrain/examine(mob/user)
//	to_chat(user, "<span class='info'>*---------</span>*")
	..()
	if(src.brainmob)
		if(src.brainmob.stat == DEAD)
			to_chat(user, "<span class='deadsay'>It appears to be completely inactive.</span>")//suicided

		else if(!src.brainmob.client)
			to_chat(user, "<span class='notice'>It appears to be in stand-by mode.</span>")//closed game window

		else if(!src.brainmob.key)
			to_chat(user, "<span class='warning'>It doesn't seem to be responsive.</span>")//ghosted

//	to_chat(user, "<span class='info'>*---------*</span>")

/obj/item/device/mmi/posibrain/emp_act(severity)
	if(!src.brainmob)
		return
	else
		switch(severity)
			if(1)
				src.brainmob.emp_damage += rand(20,30)
			if(2)
				src.brainmob.emp_damage += rand(10,20)
			if(3)
				src.brainmob.emp_damage += rand(0,10)
	..()

/obj/item/device/mmi/posibrain/New()

	src.brainmob = new(src)
	src.brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI"))]-[rand(100, 999)]"
	src.brainmob.real_name = src.brainmob.name
	src.brainmob.forceMove(src)
	src.brainmob.container = src
	src.brainmob.stat = 0
	src.brainmob.silent = 0
	dead_mob_list -= src.brainmob

	..()

/obj/item/device/mmi/posibrain/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(try_handling_mommi_construction(O,user))
		return
	..()

/obj/item/device/mmi/posibrain/attack_ghost(var/mob/dead/observer/O)
	if(searching)
		recruiter.volunteer(O)
		if(O in recruiter.currently_querying)
			to_chat(O, "<span class='notice'>Click again to unvolunteer.</span>")
		else
			to_chat(O, "<span class='notice'>Click again to volunteer.</span>")
	else
		if(!brainmob.ckey && ping_times[O.ckey] + ping_cooldown <= world.time)
			ping_times[O.ckey] = world.time
			var/streak = ping_streaks[O.ckey] + 1
			ping_streaks[O.ckey] = streak
			ghost_ping(streak)
			investigation_log(I_GHOST, "|| was pinged by [key_name(O)][O.locked_to ? ", who was haunting [O.locked_to]" : ""] (streak [streak])")
		else
			to_chat(O, "[src] is recharging. Try again in a few moments.")

/obj/item/device/mmi/posibrain/proc/ghost_ping(var/streak)
	if(streak >= loud_ping_streak)
		visible_message(message = "<span class='warning'><b>\The [src] pings insistently.</b></span>", blind_message = "<span class='danger'><b>You hear an insistent electronic chime.</b></span>")
		playsound(src, 'sound/machines/twobeep.ogg', 100, 0, 5)
	else
		visible_message(message = "<span class='notice'>\The [src] pings softly.</span>", blind_message = "<span class='danger'>You hear what you think is a microwave finishing.</span>")
		playsound(src, 'sound/machines/ping.ogg', 35, 0, -2)
	if(streak >= broadcast_ping_streak && !((streak - broadcast_ping_streak) % loud_ping_streak))
		radio_for_activation()

/obj/item/device/mmi/posibrain/proc/radio_for_activation()
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/area/A = get_area(src)
	var/datum/speech/speech = create_speech(message = "Dormant personality construct awaiting manual activation in [A ? A.name : "an unknown location"].", frequency = SCI_FREQ, transmitter = src)
	speech.name = "[src]"
	speech.job = "Positronic Brain"
	Broadcast_Message(speech, data = 0, compression = 0, level = list(T.z))
	qdel(speech)

/obj/item/device/mmi/posibrain/OnMobDeath(var/mob/living/carbon/brain/B)
	if(istype(B))
		visible_message(message = "<span class='danger'>[B] begins to go dark, having seemingly thought itself to death</span>", blind_message = "<span class='danger'>You hear the wistful sigh of a hopeful machine powering off with a tone of finality.</span>")
		icon_state = "posibrain"
		searching = 0
