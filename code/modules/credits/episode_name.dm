/datum/episode_name
	var/thename = ""
	var/reason = "Default episode name." //Explanation on why this episode name fits this round. For the admin panel.
	var/weight = 100 //50 will have 50% the chance of being picked. 200 will have 200% the chance of being picked. etc

/datum/episode_name/New(var/thename, var/reason, var/weight)
	if(!thename)
		return
	src.thename = thename
	if(reason)
		src.reason = reason
	if(weight)
		src.weight = weight

/datum/episode_name/proc/make_div(var/admindatum) //This is just for the admin panel.
	. = "[weight]% <a href='?src=\ref[admindatum];credits=namedatumweight;nameref=\ref[src]'>(Set)</a> - "
	. += "[thename] - <a href='?src=\ref[admindatum];credits=namedatumedit;nameref=\ref[src]'>(Edit)</a> "
	. += "<a href='?src=\ref[admindatum];credits=namedatumremove;nameref=\ref[src]'>(Remove)</a> "
	. += "<span title='[reason]'>(?)</span>"

/datum/credits/proc/draft_episode_names()
	episode_names += new /datum/episode_name("THE [pick("DOWNFALL OF", "RISE OF", "TROUBLE WITH", "FINAL STAND OF", "DARK SIDE OF")] [pick("SPACEMEN", "HUMANITY", "DIGNITY", "SANITY", "THE CHIMPANZEES", "THE VENDOMAT PRICES","[uppertext(station_name())]")]")
	episode_names += new /datum/episode_name("THE CREW GETS [pick("RACIST", "PICKLED", "AN INCURABLE DISEASE", "PIZZA", "A VALUABLE HISTORY LESSON", "A BREAK", "HIGH", "TO LIVE", "TO RELIVE THEIR CHILDHOOD", "EMBROILED IN CIVIL WAR", "SERIOUS ABOUT [pick("DRUG ABUSE", "CRIME", "PRODUCTIVITY", "ANCIENT AMERICAN CARTOONS", "SPACEBALL")]")]")
	episode_names += new /datum/episode_name("THE CREW LEARNS ABOUT [pick("LOVE", "DRUGS", "THE DANGERS OF MONEY LAUNDERING", "SPACE 'NAM", "INVESTMENT FRAUD", "KELOTANE ABUSE", "RADIATION PROTECTION", "SACRED GEOMETRY", "STRING THEORY", "ABSTRACT MATHEMATICS", "[pick("CATBEAST", "DIONAN", "PLASMAMAN", "VOX", "GREY")] MATING RITUALS", "ANCIENT CHINESE MEDICINE","LAWSETS")]")
	episode_names += new /datum/episode_name("[pick("MUCH ADO ABOUT NOTHING", "WHAT HAPPENS WHEN YOU MIX MOMMIS AND COMMERCIAL-GRADE PACKING FOAM", "ATTACK! ATTACK! ATTACK!", "SEX BOMB", "THE BALLAD OF [uppertext(station_name())]")]")
	episode_names += new /datum/episode_name("[pick("SPACE", "SEXY", "DRAGON", "WARLOCK", "LAUNDRY", "GUN", "ADVERTISING", "DOG", "CARBON MONOXIDE", "NINJA", "WIZARD", "SOCRATIC", "JUVENILE DELIQUENCY", "POLITICALLY MOTIVATED", "RADTACULAR SICKNASTY")] [pick("QUEST", "FORCE", "ADVENTURE")]")
	episode_names += new /datum/episode_name("[pick("THE DAY [uppertext(station_name())] STOOD STILL", "HUNT FOR THE GREEN WEENIE", "ALIEN VS VENDOMAT", "SPACE TRACK")]")
	if(SNOW_THEME)
		episode_names += new /datum/episode_name("A VERY [pick("NANOTRASEN", "EXPEDITIONARY", "SECURE", "PLASMA", "MARTIAN")] CHRISTMAS", "'Tis the season.", 500)
	if(score["gunsspawned"] > 0)
		episode_names += new /datum/episode_name("GUNS, GUNS EVERYWHERE", "[score["gunsspawned"]] guns were spawned this round.", max(100, score["gunsspawned"]*10))
	if(score["richestcash"] > 30000)
		episode_names += new /datum/episode_name("THE IRRESISTIBLE RISE OF [uppertext(score["richestname"])]", "Scrooge Mc[score["richestkey"]] racked up [score["richestcash"]] credits this round.", max(100, score["richestcash"]/300))
	if(score["deadaipenalty"] > 2)
		episode_names += new /datum/episode_name("THE ONE WHERE [score["deadaipenalty"]] AIS DIE", "That's a lot of dead AIs.", max(100, score["deadaipenalty"]*50))
	if(score["deadcrew"] == 0)
		episode_names += new /datum/episode_name("[pick("EMPLOYEE TRANSFER", "PEACE AND QUIET IN [uppertext(station_name())]", "THE CREW TRIES TO KILL A FLY FOR [round(score["time"]/60)] MINUTES")]", "No-one died this round.", 200)
	if(score["escapees"] == 0 && emergency_shuttle.location == CENTCOMM_Z)
		episode_names += new /datum/episode_name("[pick("DEAD SPACE", "THE CREW GOES MISSING", "A ONE-WAY TICKET TO FLAVORTOWN")]", "There were no escapees on the shuttle.", 200)
	if(score["slips"] > 100)
		episode_names += new /datum/episode_name("THE CREW GOES BANANAS", "[score["slips"]] people slipped this round.", min(200, score["slips"]/2))
	for(var/mob/living/simple_animal/corgi/C in living_mob_list)
		if(C.spell_list.len > 0)
			episode_names += new /datum/episode_name("[pick("A VERY MAGICAL DAY", "IAN SAYS", "IAN'S DAY OUT", "CORGI MAGIC")]", "You know what you did.", 300)
			break
