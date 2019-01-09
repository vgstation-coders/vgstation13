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
	episode_names += new /datum/episode_name("THE [pick("DOWNFALL OF", "RISE OF", "TROUBLE WITH", "FINAL STAND OF", "DARK SIDE OF")] [pick("SPACEMEN", "HUMANITY", "DIGNITY", "SANITY", "THE CHIMPANZEES", "THE VENDOMAT PRICES", "[uppertext(station_name())]")]")
	episode_names += new /datum/episode_name("THE CREW [pick("GOES JIHAD", "GOES ON WELFARE", "GIVES BACK", "SELLS OUT", "GETS WHACKED", "BITES THE DUST", "SOLVES THE PLASMA CRISIS", "HITS THE ROAD", "GETS AN ANAL PROBE", "RULES THE WORLD", "RISES", "SAVES THE DAY", "RETIRES", "GOES TO HELL", "DOES A CLIP SHOW", "GETS AUDITED", "DOES A TV COMMERCIAL", "AFTER HOURS", "GOES TOO FAR", "GIVES UP THE DREAM", "SHOULD NOT BE ALLOWED ON TV", "GETS A LIFE", "WHO CAME TO DINNER")]")
	episode_names += new /datum/episode_name("THE CREW'S [pick("DAY OUT", "PUNISHMENT", "BIG GAY ADVENTURE", "LUNCH BREAK", "LAST DAY", "[pick("WILD", "WACKY", "LAME")] VACATION", "CHANGE OF HEART", "BIG BREAK", "BACK IN BUSINESS", "NEW GROOVE", "DONE FOR", "SCHOOL MUSICAL", "HISTORY LESSON", "FLYING CIRCUS", "SMALL PROBLEM", "BIG SCORE")]")
	episode_names += new /datum/episode_name("THE CREW GETS [pick("RACIST", "PICKLED", "AN INCURABLE DISEASE", "PIZZA", "NEW WHEELS", "A VALUABLE HISTORY LESSON", "A BREAK", "HIGH", "TO LIVE", "TO RELIVE THEIR CHILDHOOD", "EMBROILED IN CIVIL WAR", "SERIOUS ABOUT [pick("DRUG ABUSE", "CRIME", "PRODUCTIVITY", "ANCIENT AMERICAN CARTOONS", "SPACEBALL")]")]")
	episode_names += new /datum/episode_name("THE CREW LEARNS ABOUT [pick("LOVE", "DRUGS", "THE DANGERS OF MONEY LAUNDERING", "INVESTMENT FRAUD", "KELOTANE ABUSE", "RADIATION PROTECTION", "SACRED GEOMETRY", "STRING THEORY", "ABSTRACT MATHEMATICS", "[pick("CATBEAST", "DIONAN", "PLASMAMAN", "VOX", "GREY")] MATING RITUALS", "ANCIENT CHINESE MEDICINE", "LAWSETS")]")
	episode_names += new /datum/episode_name("[pick("SPACE", "SEXY", "DRAGON", "WARLOCK", "LAUNDRY", "GUN", "ADVERTISING", "DOG", "CARBON MONOXIDE", "NINJA", "WIZARD", "SOCRATIC", "JUVENILE DELIQUENCY", "POLITICALLY MOTIVATED", "RADTACULAR SICKNASTY")] [pick("QUEST", "FORCE", "ADVENTURE")]")
	episode_names += new /datum/episode_name("[pick("BALANCE OF POWER", "SPACE TRACK", "SEX BOMB", "WHOSE IDEA WAS THIS ANYWAY?", "WHATEVER HAPPENED, HAPPENED", "THE GOOD, THE BAD, AND [uppertext(station_name())]", "RESTRAIN YOUR ENJOYMENT", "[uppertext(station_name())]: A NATIONAL CONCERN", "A PUBLIC RELATIONS NIGHTMARE", "WITH APOLOGIES TO THE CREW", "PILOT", "REAL HOUSEWIVES OF [uppertext(station_name())]", "MEANWHILE, ON [uppertext(station_name())]...")]")

	if(istype(ticker.mode, /datum/gamemode/dynamic))
		var/datum/gamemode/dynamic/mode = ticker.mode
		switch(mode.threat_level)
			if(0 to 30)
				episode_names += new /datum/episode_name("[pick("THE DAY [uppertext(station_name())] STOOD STILL", "MUCH ADO ABOUT NOTHING", "WHERE SILENCE HAS LEASE", "RED HERRING", "THIS SIDE OF PARADISE", "HOME ALONE", "[uppertext(station_name())]: A SITUATION COMEDY", "THE SILENT SHUFFLE", "GO BIG OR GO [uppertext(station_name())]", "PLACEBO EFFECT")]", "Low threat level of [mode.threat_level]%.", 200)
			if(30 to 70)
				episode_names += new /datum/episode_name("[pick("THERE MIGHT BE BLOOD", "IT CAME FROM [uppertext(station_name())]!", "THE BALLAD OF [uppertext(station_name())]", "THE [uppertext(station_name())] INCIDENT", "THE ENEMY WITHIN", "MIDDAY MADNESS", "AS THE CLOCK STRIKES TWELVE", "CONFIDENCE AND PARANOIA")]", "Moderate threat level of [mode.threat_level]%.", 200)
			if(70 to 100)
				episode_names += new /datum/episode_name("[pick("ATTACK! ATTACK! ATTACK!", "SPACE 'NAM", "CAN'T FIX CRAZY", "APOCALYPSE [pick("N", "W", "H")]OW", "A TASTE OF ARMAGEDDON", "OPERATION: ANNIHILATE!", "THE PERFECT STORM", "TIME'S UP FOR THE CREW", "THE END OF [uppertext(station_name())] AS WE KNOW IT", "A TOTALLY FUN THING THAT THE CREW WILL NEVER DO AGAIN", "EVERYBODY HATES [uppertext(station_name())]")]", "High threat level of [mode.threat_level]%.", 200)
		if(locate(/datum/dynamic_ruleset/roundstart/malf) in mode.executed_rules)
			episode_names += new /datum/episode_name("[pick("I'M SORRY [uppertext(station_name())], I'M AFRAID I CAN'T LET YOU DO THAT", "A STRANGE GAME")]", "Round included a malfunctioning AI.", 200)
		if(locate(/datum/dynamic_ruleset/roundstart/revs) in mode.executed_rules)
			episode_names += new /datum/episode_name("[pick("THE CREW STARTS A REVOLUTION", "HELL IS OTHER SPESSMEN")]", "Round included roundstart revs.", 200)
			if(copytext(uppertext(station_name()),1,2) == "V")
				episode_names += new /datum/episode_name("V FOR [uppertext(station_name())]", "Round included roundstart revs... and the station's name starts with V.", 500)
		if(ticker.station_was_nuked)
			episode_names += new /datum/episode_name("[pick("THE CREW GETS NUKED", "THE CREW IS THE BOMB", "THE CREW BLASTS OFF AGAIN!", "THE 'BOOM' HEARD 'ROUND THE WORLD")]", "The station was nuked!", 250)
		//if(locate(/datum/dynamic_ruleset/roundstart/blob) in mode.executed_rules) //uncomment when blob gets readded
		//	episode_names += new /datum/episode_name("[pick("MARRIED TO THE BLOB", "THE CREW GETS QUARANTINED")]", "Round included a roundstart blob.", 200)



	if(SNOW_THEME)
		episode_names += new /datum/episode_name("A VERY [pick("NANOTRASEN", "EXPEDITIONARY", "SECURE", "PLASMA", "MARTIAN")] CHRISTMAS", "'Tis the season.", 750)
	if(score["gunsspawned"] > 0)
		episode_names += new /datum/episode_name("[pick("GUNS, GUNS EVERYWHERE", "THUNDER GUN EXPRESS", "THE CREW GOES AMERICA ALL OVER EVERYBODY'S ASS")]", "[score["gunsspawned"]] guns were spawned this round.", max(450, score["gunsspawned"]*15))
	if(score["dimensionalpushes"] > 10)
		episode_names += new /datum/episode_name("THE CREW GETS PUSHED TOO FAR", "[score["dimensionalpushes"]] things were dimensionalpush'd this round.", max(450, score["dimensionalpushes"]*15))
	if(score["assesblasted"] > 4)
		episode_names += new /datum/episode_name("A SONG OF ASS AND FIRE", "[score["assesblasted"]] people were magically assblasted this round.", max(450, score["assesblasted"]*30))
	if(score["heartattacks"] > 4)
		episode_names += new /datum/episode_name("MY HEART WILL GO ON", "[score["heartattacks"]] hearts were reanimated and burst out of someone's chest this round.", max(450, score["heartattacks"]*50))
	if(score["richestcash"] > 30000)
		episode_names += new /datum/episode_name("THE IRRESISTIBLE RISE OF [uppertext(score["richestname"])]", "Scrooge Mc[score["richestkey"]] racked up [score["richestcash"]] credits this round.", min(200, score["richestcash"]/500))
	if(end_credits.star && star.times_cloned > 2)
		episode_names += new /datum/episode_name("[uppertext(star.real_name)] MUST DIE", "The star of the show, [star.real_name], was cloned [star.times_cloned] times.", min(350, star.times_cloned*50))
	if(score["deadaipenalty"] > 2)
		episode_names += new /datum/episode_name("THE ONE WHERE [score["deadaipenalty"]] AIS DIE", "That's a lot of dead AIs.", max(400, score["deadaipenalty"]*75))
	if(score["deadcrew"] == 0)
		episode_names += new /datum/episode_name("[pick("EMPLOYEE TRANSFER", "LIVE LONG AND PROSPER", "PEACE AND QUIET IN [uppertext(station_name())]", "THE CREW TRIES TO KILL A FLY FOR [round(score["time"]/60)] MINUTES")]", "No-one died this round.", 750) //in practice, this one is very very very rare, so if it happens let's pick it more often
	if(score["deadcrew"] > score["escapees"]*2 && score["escapees"] < 6)
		episode_names += new /datum/episode_name("[pick("AND THEN THERE WERE FEWER", "THE 'FUN' IN 'FUNERAL'", "FREEDOM RIDE OR DIE", "THINGS WE LOST IN [uppertext(station_name())]", "GONE WITH [uppertext(station_name())]", "LAST TANGO IN [uppertext(station_name())]", "GET BUSY LIVING OR GET BUSY DYING")]", "[score["deadcrew"]] people died this round.", 250)
	if(score["escapees"] == 0 && emergency_shuttle.location == CENTCOMM_Z)
		episode_names += new /datum/episode_name("[pick("DEAD SPACE", "THE CREW GOES MISSING", "LOST IN TRANSLATION")]", "There were no escapees on the shuttle.", 100)
	if(score["slips"] > 100)
		episode_names += new /datum/episode_name("THE CREW GOES BANANAS", "[score["slips"]] people slipped this round.", min(200, score["slips"]/2))
	if(score["buttbotfarts"] > 100)
		episode_names += new /datum/episode_name("DO BUTTBOTS DREAM OF ELECTRIC FARTS?", "[score["buttbotfarts"]] messages were mimicked by buttbots this round.", min(100, score["buttbotfarts"]/2))
	if(score["clownabuse"] > 50)
		episode_names += new /datum/episode_name("EVERYBODY LOVES A CLOWN", "[score["clownabuse"]] instances of clown abuse this round.", min(350, score["clownabuse"]))
	if(score["maxpower"] > HUNDRED_MEGAWATTS && (locate(/mob/living/silicon/robot/mommi) in mob_list))
		episode_names += new /datum/episode_name("WHAT HAPPENS WHEN YOU MIX MOMMIS AND COMMERCIAL-GRADE PACKING FOAM", "There was a powergrid with [score["maxpower"]]W, and 1 or more MoMMIs playing.", 100)
	if(score["escapees"] == 1 && emergency_shuttle.location == CENTCOMM_Z)
		var/shoecount = 0
		var/area/shuttle = locate(/area/shuttle/escape/centcom)
		if(shuttle)
			for(var/obj/item/clothing/shoes/S in shuttle) //they gotta be on the floor
				shoecount++
			if(shoecount > 5 || score["shoeshatches"] > 10)
				episode_names += new /datum/episode_name("THE SOLE SURVIVOR", "[score["dmgestkey"]] was the only survivor in the shuttle, and they didn't forget their shoes.", 500) //I'm not sorry
	for(var/mob/living/simple_animal/corgi/C in living_mob_list)
		if(C.spell_list.len > 0)
			episode_names += new /datum/episode_name("[pick("WHERE NO DOG HAS GONE BEFORE", "IAN SAYS", "IAN'S DAY OUT", "CORGI MAGIC")]", "You know what you did.", 750)
			break
