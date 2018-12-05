var/global/datum/credits/end_credits = new

/datum/credits
	var/generated = FALSE
	var/starting_delay = 8 SECONDS
	var/post_delay = 5 SECONDS //time that the server stays up after the credits start rolling (to prevent serb shutting down before all the clients receive the credits, or that's the idea at least)
	var/control = "mapwindow.credits"
	var/file = 'code/modules/credits/credits.html'

	var/director = "Pomf Chicken Productions"
	var/list/producers = list()
	var/mob/living/carbon/human/star
	var/list/disclaimers = list()
	var/list/datum/episode_name/episode_names = list()
	var/episode_name = ""

	var/producers_string = ""
	var/episode_string = ""
	var/cast_string = ""
	var/disclaimers_string = ""

/datum/credits/proc/on_roundend()
	generate_caststring() //roundend grief not included in the credits
	generate_producerstring() //so that we show admins who have logged out before the credits roll
	draft_disclaimers()
	draft_episode_names() //only selects the possibilities, doesn't pick one yet
	generated = TRUE

/datum/credits/proc/rollem()
	log_debug("Playing credits song...")
	world << sound('sound/music/Frolic_Luciano_Michelini_Short.ogg')

	finalize_disclaimerstring() //finalize it after the admins have had time to edit them
	if(episode_name == "") //admin might've already set one
		pick_name()
	finalize_episodestring()

	var/scrollytext = episode_string + cast_string + disclaimers_string

	var/list/js_args = list(scrollytext, producers_string, 20, 2000) //arguments for the makeCredits function back in the javascript

	log_debug("Sending credit info to all clients...")
	for(var/client/C in clients)
		C.show_credits(js_args)

/client/proc/show_credits(var/list/js_args)
	set waitfor = FALSE

 	verbs += /client/proc/clear_credits

	src << output(end_credits.file, end_credits.control)
	log_debug("[src] received credits info correctly.")
	sleep(end_credits.starting_delay)
	src << output(list2params(js_args), "[end_credits.control]:makeCredits")
	winset(src, end_credits.control, "is-visible=true")
	log_debug("[src] is showing credits correctly.")

/client/proc/clear_credits()
	set name = "Skip Credits"
	set category = "OOC"
	verbs -= /client/proc/clear_credits
	winset(src, end_credits.control, "is-visible=false")




/datum/credits/proc/pick_name()
	var/list/drafted_names = list()
	for(var/datum/episode_name/N in episode_names)
		drafted_names["[N.thename]"] = N.weight
	episode_name = pickweight(drafted_names)

/datum/credits/proc/finalize_episodestring(var/thename)
	episode_string = "<h1>SEASON [rand(1,22)] EPISODE [rand(1,17)]<br>[uppertext(episode_name)]</h1><br><div style='padding-bottom: 75px;'></div>"

/datum/credits/proc/finalize_disclaimerstring()
	disclaimers_string = "<div class='disclaimers'>"
	for(var/disclaimer in disclaimers)
		disclaimers_string += "[disclaimer]<br>"
	disclaimers_string += "</div>"

/datum/credits/proc/generate_producerstring()
	var/list/staff = list("<h1>PRODUCTION STAFF</h1><br>")
	var/list/staffjobs = list("Coffee Fetcher", "Cameraman", "Angry Yeller", "Chair Operator", "Choreographer", "Historical Consultant", "Costume Designer", "Chief Editor", "Executive Assistant", "Key Grip")
	if(!admins.len)
		staff += "<h2>PRODUCER - Alan Smithee</h2><br>"
	for(var/client/C in admins)
		if(!C.holder)
			continue
		if(C.holder.rights & (R_DEBUG|R_ADMIN))
			var/observername = ""
			if(C.mob && istype(C.mob,/mob/dead/observer))
				var/mob/dead/observer/O = C.mob
				if(O.started_as_observer)
					observername = "[O.real_name] a.k.a. "
			staff += "<h2>[uppertext(pick(staffjobs))] - [observername]'[C.key]'</h2><br>"

	producers = list("<h1>Directed by</br>[uppertext(director)]</h1>","[jointext(staff,"")]")
	for(var/head in data_core.get_manifest_json()["heads"])
		producers += "<h1>[head["rank"]]<br>[uppertext(head["name"])]</h1><br>"
	if(star)
		producers += "<h1>Starring<br>[thebigstar(star)]</h1><br>"

	producers_string = ""
	for(var/producer in end_credits.producers)
		producers_string += "[producer]%n" //%n being an arbitrary "new producer" char we use to split this string back in the javascript

/datum/credits/proc/generate_caststring()
	cast_string = "<h1>CAST:</h1><br><h2>(in order of appearance)</h2><br>"
	cast_string += "<table class='crewtable'>"
	for(var/mob/living/carbon/human/H in living_mob_list|dead_mob_list)
		if(H.iscorpse || (H.timeofdeath && H.timeofdeath < 5 MINUTES)) //don't mention these losers (prespawned corpses mostly)
			continue
		if(!star || H.talkcount > star.talkcount)
			star = H

		cast_string += "[gender_credits(H)]"

	cast_string += "</table><br>"
	cast_string += "<div class='disclaimers'>"
	var/list/corpses = list()
	for(var/mob/living/carbon/human/H in dead_mob_list)
		if(H.iscorpse || (H.timeofdeath && H.timeofdeath < 5 MINUTES)) //no prespawned corpses
			continue
		else if(H.real_name)
			corpses += H.real_name
	if(corpses.len)
		var/true_story_bro = "<br>[pick("BASED ON","INSPIRED BY","A RE-ENACTMENT OF")] [pick("A TRUE STORY","REAL EVENTS","THE EVENTS ABOARD [uppertext(station_name())]")]"
		cast_string += "<h3>[true_story_bro]</h3><br>In memory of those that did not make it.<br>[english_list(corpses)].<br>"
	cast_string += "</div><br>"

/proc/gender_credits(var/mob/living/carbon/human/H)
	if(H.mind && H.mind.key)
		return "<tr><td class='actorname'>[uppertext(H.mind.key)]</td><td class='actorsegue'> as </td><td class='actorrole'>[H.real_name], [H.get_assignment()]</td></tr>"
	else
		var/t_him = "Them"
		if(H.gender == MALE)
			t_him = "Him"
		else if(H.gender == FEMALE)
			t_him = "Her"
		return "<tr><td class='actorname'>[uppertext(H.real_name)]</td><td class='actorsegue'> as </td><td class='actorrole'>[t_him]self</td></tr>"

/proc/thebigstar(var/mob/living/carbon/human/H)
	if(H.mind && H.mind.key)
		return "[uppertext(H.mind.key)] as [H.real_name]"
	else
		var/t_him = "Them"
		if(H.gender == MALE)
			t_him = "Him"
		else if(H.gender == FEMALE)
			t_him = "Her"
		return "[uppertext(H.real_name)] as [t_him]self"
