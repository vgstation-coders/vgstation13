var/global/datum/credits/end_credits = new

/datum/credits
	var/generated = FALSE
	var/starting_delay = 12 SECONDS //Audio will start playing this many seconds before server shutdown. Takes maybe 2 seconds to start playing while it buffers!
	var/scroll_speed = 20 //Lower is faster.
	var/splash_time = 2000 //Time in miliseconds that each head of staff/star/production staff etc splash screen gets before displaying the next one.

	var/audio_link = "http://ss13.moe:3000/Pomf/vgstation-media/raw/master/roundend/credits/Frolic_Luciano_Michelini.ogg"
	var/control = "mapwindow.credits" //if updating this, update in credits.html as well
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

/datum/credits/proc/prepare_assets(var/playaudio = TRUE)
	finalize_disclaimerstring() //finalize it after the admins have had time to edit them
	if(episode_name == "") //admin might've already set one
		pick_name()
	finalize_episodestring()

	var/scrollytext = episode_string + cast_string + disclaimers_string

	var/list/js_args = list(scrollytext, producers_string, scroll_speed, splash_time) //arguments for the makeCredits function back in the javascript

	for(var/client/C in clients)
		C.verbs += /client/proc/clear_credits
		C << output(file, control)
		spawn(1 SECONDS) //@todo find a better way to do this
			C << output(list2params(js_args), "[control]:setupCredits")
			if(playaudio)
				C << output(list2params(list(audio_link)), "[control]:setAudio")


/datum/credits/proc/play_to_clients()
	for(var/client/C in clients)
		C << output("", "[control]:startCredits") //Execute the startCredits() function in credits.html with no parameters.

/client/proc/clear_credits()
	set name = "Skip Credits"
	set category = "OOC"
	verbs -= /client/proc/clear_credits
	src << output(null, end_credits.control)
	winset(src, end_credits.control, "is-visible=false")




/datum/credits/proc/pick_name()
	var/list/drafted_names = list()
	for(var/datum/episode_name/N in episode_names)
		drafted_names["[N.thename]"] = N.weight
	episode_name = pickweight(drafted_names)

/datum/credits/proc/finalize_episodestring(var/thename)
	var/season = rand(1,22)
	var/episodenum = rand(1,17) //Maybe we could do this cumulatively so that the round after 670 becomes 671 etc and the season is just the last 2 numbers of the current IRL year?
	episode_string = "<h1>SEASON [season] EPISODE [episodenum]<br>[episode_name]</h1><br><div style='padding-bottom: 75px;'></div>"
	log_game("So ends SEASON [season] EPISODE [episodenum] - [episode_name]")

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
	for(var/producer in producers)
		producers_string += "[producer]%n" //%n being an arbitrary "new producer" char we use to split this string back in the javascript

/datum/credits/proc/generate_caststring()
	cast_string = "<h1>CAST:</h1><br><h2>(in order of appearance)</h2><br>"
	cast_string += "<table class='crewtable'>"
	for(var/mob/living/carbon/human/H in mob_list)
		if(!H.key || H.iscorpse)
			continue
		if(!star || H.talkcount > star.talkcount)
			star = H

		cast_string += "[gender_credits(H)]"

	for(var/mob/living/silicon/S in mob_list)
		if(!S.key)
			continue
		cast_string += "[silicon_credits(S)]"

	cast_string += "</table><br>"
	cast_string += "<div class='disclaimers'>"
	var/list/corpses = list()
	for(var/mob/living/carbon/human/H in dead_mob_list)
		if(!H.key || H.iscorpse)
			continue
		else if(H.real_name)
			corpses += H.real_name
	if(corpses.len)
		var/true_story_bro = "<br>[pick("BASED ON","INSPIRED BY","A RE-ENACTMENT OF")] [pick("A TRUE STORY","REAL EVENTS","THE EVENTS ABOARD [uppertext(station_name())]")]"
		cast_string += "<h3>[true_story_bro]</h3><br>In memory of those that did not make it.<br>[english_list(corpses)].<br>"
	cast_string += "</div><br>"

/proc/gender_credits(var/mob/living/carbon/human/H)
	if(H.mind && H.mind.key)
		var/assignment = H.get_assignment(if_no_id = "", if_no_job = "")
		return "<tr><td class='actorname'>[uppertext(H.mind.key)]</td><td class='actorsegue'> as </td><td class='actorrole'>[H.real_name][assignment == "" ? "" : ", [assignment]"]</td></tr>"
	else
		var/t_him = "Them"
		if(H.gender == MALE)
			t_him = "Him"
		else if(H.gender == FEMALE)
			t_him = "Her"
		return "<tr><td class='actorname'>[uppertext(H.real_name)]</td><td class='actorsegue'> as </td><td class='actorrole'>[t_him == "Them" ? "Themselves" : "[t_him]self"]</td></tr>"

/proc/silicon_credits(var/mob/living/silicon/S)
	if(S.mind && S.mind.key)
		return "<tr><td class='actorname'>[uppertext(S.mind.key)]</td><td class='actorsegue'> as </td><td class='actorrole'>[S.name]</td></tr>"
	else
		return "<tr><td class='actorname'>[uppertext(S.name)]</td><td class='actorsegue'> as </td><td class='actorrole'>Itself</td></tr>"

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
