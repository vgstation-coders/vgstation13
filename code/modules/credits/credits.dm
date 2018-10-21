/mob/verb/creditstest()
	set category = "IC"
	set name = "credits test"

	end_credits.generate_credits()
	end_credits.rollem()

var/global/datum/credits/end_credits = new

/datum/credits
	var/director = "Pomf Chicken Productions"
	var/mob/living/carbon/human/star
	var/starting_delay = 8 SECONDS
	var/scrollingtext = ""
	var/episode_name = ""
	var/list/producers = list()
	var/control = "mapwindow.credits"
	var/file = 'code/modules/credits/credits.html'

/datum/credits/proc/rollem()
	world << sound('sound/music/Frolic_Luciano_Michelini.ogg')


	var/producers_string = "" //the only reason why I do this is because I couldn't find a way of passing a nested list in a JS call via byond output
	for(var/producer in end_credits.producers)
		producers_string += "[producer]%n" //%n being an arbitrary "new producer" char we use to split this string back in the javascript
	var/list/js_args = list(scrollingtext, producers_string, 25, 2000)

	for(var/client/C in clients)
		C.show_credits(js_args)

/client/proc/show_credits(var/list/js_args)
	set waitfor = FALSE

  verbs += /client/proc/clear_credits

	src << output(end_credits.file, end_credits.control)
	sleep(end_credits.starting_delay)
	src << output(list2params(js_args), "[end_credits.control]:makeCredits")
	winset(src, end_credits.control, "is-visible=true")

/client/proc/clear_credits()
	set name = "Skip Credits"
	set category = "OOC"
	verbs -= /client/proc/clear_credits
	winset(src, end_credits.control, "is-visible=false")



/datum/credits/proc/generate_credits()
	generate_episode_name()
	generate_scrolling_text()
	generate_producers()

/datum/credits/proc/generate_producers()
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

	producers = list("<h1>Directed by</br>[uppertext(director)]","[jointext(staff,"")]")
	for(var/head in data_core.get_manifest_json()["heads"])
		producers += "<h1>[head["rank"]]<br>[uppertext(head["name"])]</h1><br>"
	if(star)
		producers += "<h1>Starring<br>[thebigstar(star)]</h1><br>"

/datum/credits/proc/generate_episode_name()
  var/list/possible_episode_names = list()

  /* Establish a big-ass list of potential titles for the "episode". */
  possible_episode_names += "THE [pick("DOWNFALL OF", "RISE OF", "TROUBLE WITH", "FINAL STAND OF", "DARK SIDE OF")] [pick("SPACEMEN", "HUMANITY", "DIGNITY", "SANITY", "THE CHIMPANZEES", "THE VENDOMAT PRICES","[uppertext(station_name())]")]"
  possible_episode_names += "THE CREW GETS [pick("RACIST", "PICKLED", "AN INCURABLE DISEASE", "PIZZA", "A VALUABLE HISTORY LESSON", "A BREAK", "HIGH", "TO LIVE", "TO RELIVE THEIR CHILDHOOD", "EMBROILED IN CIVIL WAR", "SERIOUS ABOUT [pick("DRUG ABUSE", "CRIME", "PRODUCTIVITY", "ANCIENT AMERICAN CARTOONS", "SPACEBALL")]")]"
  possible_episode_names += "THE CREW LEARNS ABOUT [pick("LOVE", "DRUGS", "THE DANGERS OF MONEY LAUNDERING", "SPACE 'NAM", "INVESTMENT FRAUD", "KELOTANE ABUSE", "RADIATION PROTECTION", "SACRED GEOMETRY", "STRING THEORY", "ABSTRACT MATHEMATICS", "[pick("CATBEAST", "DIONAN", "PLASMAMAN", "VOX", "GREY")] MATING RITUALS", "ANCIENT CHINESE MEDICINE","LAWSETS")]"
  if(SNOW_THEME)
    possible_episode_names += "A VERY [pick("NANOTRASEN", "EXPEDITIONARY", "SECURE", "PLASMA", "MARTIAN")] CHRISTMAS"
  possible_episode_names += "[pick("GUNS, GUNS EVERYWHERE", "MUCH ADO ABOUT NOTHING", "WHAT HAPPENS WHEN YOU MIX MOMMIS AND COMMERCIAL-GRADE PACKING FOAM", "ATTACK! ATTACK! ATTACK!", "SEX BOMB", "THE BALLAD OF [uppertext(station_name())]")]"
  possible_episode_names += "[pick("SPACE", "SEXY", "DRAGON", "WARLOCK", "LAUNDRY", "GUN", "ADVERTISING", "DOG", "CARBON MONOXIDE", "NINJA", "WIZARD", "SOCRATIC", "JUVENILE DELIQUENCY", "POLITICALLY MOTIVATED", "RADTACULAR SICKNASTY")] [pick("QUEST", "FORCE", "ADVENTURE")]"
  possible_episode_names += "[pick("THE DAY [uppertext(station_name())] STOOD STILL", "HUNT FOR THE GREEN WEENIE", "ALIEN VS VENDOMAT", "SPACE TRACK")]"

  episode_name = pick(possible_episode_names)

/datum/credits/proc/generate_scrolling_text()
	scrollingtext = ""
	scrollingtext += "<h1>SEASON [rand(1,22)] EPISODE [rand(1,17)]<br>[episode_name]</h1><br><div style='padding-bottom: 75px;'></div>"
	scrollingtext += "<h1>CAST:</h1><br><h2>(in order of appearance)</h2><br>"
	scrollingtext += "<table class='crewtable'>"
	for(var/mob/living/carbon/human/H in living_mob_list|dead_mob_list)
		if(H.timeofdeath && H.timeofdeath < 5 MINUTES) //don't mention these losers (prespawned corpses mostly)
			continue
		if(!star || H.talkcount > star.talkcount)
			star = H

		scrollingtext += "[gender_credits(H)]"

	scrollingtext += "</table><br>"
	scrollingtext += "<div class='disclaimers'>"
	var/list/corpses = list()
	for(var/mob/living/carbon/human/H in dead_mob_list)
		if(H.timeofdeath < 5 MINUTES) //no prespawned corpses
			continue
		else if(H.real_name)
			corpses += H.real_name
	if(corpses.len)
		var/true_story_bro = "<br>[pick("BASED ON","INSPIRED BY","A RE-ENACTMENT OF")] [pick("A TRUE STORY","REAL EVENTS","THE EVENTS ABOARD [uppertext(station_name())]")]"
		scrollingtext += "<h3>[true_story_bro]</h3><br>In memory of those that did not make it.<br>[english_list(corpses)].<br>"

	scrollingtext += {"<br><br>Unofficially Sponsored by The United States Navy.<br>All rights reserved.<br><br>
			[pick("All stunts were performed by underpaid and expendable interns. Do NOT try at home.", "[director] do not endorse behaviour depicted. Attempt at your own risk.")]<br>"}
	scrollingtext += {"This motion picture is (not) protected under the copyright laws of the United States and other countries throughout the world. Country of first publication:
				United States of America. Any unauthorized exhibition, distribution, or copying of this film or any part thereof (including soundtrack) may result in civil liability
				and criminal prosecution. The story, all names, characters, and incidents portrayed in this production are fictitious. No identification with actual persons (living or
				deceased), places, buildings, and products is intended or should be inferred. No person or entity associated with this film received payment or anything of value,
				or entered into any agreement, in connection with the depiction of tobacco products. No animals were harmed in the making of this motion picture,
				though many clowns were."}
	scrollingtext += "</div>"

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
