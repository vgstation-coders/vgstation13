/datum/episode_name
	var/thename = ""
	var/reason = "Default episode name." //Explanation on why this episode name fits this round. For the admin panel.
	var/weight = 100 //50 will have 50% the chance of being picked. 200 will have 200% the chance of being picked, etc. Relative to other names, not total (just the default names already total 700%)
	var/rare = FALSE //If set to true and this episode name is picked, the current round is considered "not a rerun" for client preferences.

/datum/episode_name/rare
	rare = TRUE

/datum/episode_name/New(var/thename, var/reason, var/weight)
	if(!thename)
		return
	src.thename = thename
	if(reason)
		src.reason = reason
	if(weight)
		src.weight = weight

	switch(rand(1,100))
		if(0 to 5)
			thename += ": PART I"
		if(6 to 10)
			thename += ": PART II"
		if(11 to 12)
			thename += ": PART III"
		if(13)
			thename += ": NOW IN 3D"
		if(14)
			thename += ": ON ICE!"
		if(15)
			thename += ": THE SEASON FINALE"
		if(16 to 40)
			if(score["time"] > 60 * 60 * 3) //3 hours
				thename += ": THE FEATURE LENGTH PRESENTATION"
		if(41 to 65)
			if(score["time"] > 0 && score["time"] < 60 * 30) //30 min
				thename += ": ABRIDGED"
		else
			for(var/client/C in clients)
				if(C.key && (C.key == "pomf123" || C.key == "exadv1"))
					thename += ": THE DIRECTOR'S CUT"
					break


/datum/episode_name/proc/make_div(var/admindatum) //This is just for the admin panel.
	. = "[rare ? "<span style='color:green' title='Rare, not-a-rerun episode name!'>" + "[weight]" + "%</span>" : "[weight]" + "%"] <a href='?src=\ref[admindatum];credits=namedatumweight;nameref=\ref[src]'>(Set)</a> - "
	. += "[thename] - <a href='?src=\ref[admindatum];credits=namedatumedit;nameref=\ref[src]'>(Edit)</a> "
	. += "<a href='?src=\ref[admindatum];credits=namedatumremove;nameref=\ref[src]'>(Remove)</a> "
	. += "<span title='[reason]'>(?)</span>"

/datum/credits/proc/draft_episode_names()
	var/uppr_name = uppertext(station_name()) //so we don't run these two 500 times

	episode_names += new /datum/episode_name("THE [pick("DOWNFALL OF", "RISE OF", "TROUBLE WITH", "FINAL STAND OF", "DARK SIDE OF")] [pick(200;"[uppr_name]", 150;"SPACEMEN", 150;"HUMANITY", "DIGNITY", "SANITY", "SCIENCE", "CURIOSITY", "EMPLOYMENT", "PARANOIA", "THE CHIMPANZEES", 50;"THE VENDOMAT PRICES")]")
	episode_names += new /datum/episode_name("THE CREW [pick("GOES JIHAD", "GOES ON WELFARE", "GIVES BACK", "SELLS OUT", "GETS WHACKED", "SOLVES THE PLASMA CRISIS", "HITS THE ROAD", "RISES", "RETIRES", "GOES TO HELL", "DOES A CLIP SHOW", "GETS AUDITED", "DOES A TV COMMERCIAL", "AFTER HOURS", "GETS A LIFE", "STRIKES BACK", "GOES TOO FAR", "IS 'IN' WITH IT", "WINS... BUT AT WHAT COST?", "INSIDE OUT")]")
	episode_names += new /datum/episode_name("THE CREW'S [pick("DAY OUT", "BIG GAY ADVENTURE", "LAST DAY", "[pick("WILD", "WACKY", "LAME", "UNEXPECTED")] VACATION", "CHANGE OF HEART", "NEW GROOVE", "SCHOOL MUSICAL", "HISTORY LESSON", "FLYING CIRCUS", "SMALL PROBLEM", "BIG SCORE", "BLOOPER REEL", "GOT IT", "LITTLE SECRET", "SPECIAL OFFER", "SPECIALTY", "WEAKNESS", "CURIOSITY", "ALIBI", "LEGACY", "BIRTHDAY PARTY", "REVELATION", "ENDGAME", "RESCUE", "PAYBACK")]")
	episode_names += new /datum/episode_name("THE CREW GETS [pick("RACIST", "SERIOUS ABOUT [pick("DRUG ABUSE", "CRIME", "PRODUCTIVITY", "ANCIENT AMERICAN CARTOONS", "SPACEBALL")]", "PICKLED", "AN ANAL PROBE", "PIZZA", "NEW WHEELS", "A VALUABLE HISTORY LESSON", "A BREAK", "HIGH", "TO LIVE", "TO RELIVE THEIR CHILDHOOD", "EMBROILED IN CIVIL WAR", "DOWN WITH IT", "FIRED", "BUSY", "THEIR SECOND CHANCE", "TRAPPED", "THEIR REVENGE")]")
	episode_names += new /datum/episode_name("[pick("BALANCE OF POWER", "SPACE TRACK", "SEX BOMB", "WHOSE IDEA WAS THIS ANYWAY?", "WHATEVER HAPPENED, HAPPENED", "THE GOOD, THE BAD, AND [uppr_name]", "RESTRAIN YOUR ENJOYMENT", "REAL HOUSEWIVES OF [uppr_name]", "MEANWHILE, ON [uppr_name]...", "CHOOSE YOUR OWN ADVENTURE", "NO PLACE LIKE HOME", "LIGHTS, CAMERA, [uppr_name]!", "50 SHADES OF [uppr_name]", "GOODBYE, [uppr_name]!", "THE SEARCH", \
	"THE CURIOUS CASE OF [uppr_name]", "ONE HELL OF A PARTY", "FOR YOUR CONSIDERATION", "PRESS YOUR LUCK", "A STATION CALLED [uppr_name]", "CRIME AND PUNISHMENT", "MY DINNER WITH [uppr_name]", "UNFINISHED BUSINESS", "THE ONLY STATION THAT'S NOT ON FIRE (YET)", "SOMEONE'S GOTTA DO IT", "THE [uppr_name] MIX-UP", "PILOT", "PROLOGUE", "FINALE", "UNTITLED", "THE END")]")
	episode_names += new /datum/episode_name("[pick("SPACE", "SEXY", "DRAGON", "WARLOCK", "LAUNDRY", "GUN", "ADVERTISING", "DOG", "CARBON MONOXIDE", "NINJA", "WIZARD", "SOCRATIC", "JUVENILE DELIQUENCY", "POLITICALLY MOTIVATED", "RADTACULAR SICKNASTY", "CORPORATE", "MEGA")] [pick("QUEST", "FORCE", "ADVENTURE")]", weight=25)

	switch(score["crewscore"])
		if(-INFINITY to -2000)
			episode_names += new /datum/episode_name("[pick("THE CREW'S PUNISHMENT", "A PUBLIC RELATIONS NIGHTMARE", "[uppr_name]: A NATIONAL CONCERN", "WITH APOLOGIES TO THE CREW", "THE CREW BITES THE DUST", "THE CREW BLOWS IT", "THE CREW GIVES UP THE DREAM", "THE CREW IS DONE FOR", "THE CREW SHOULD NOT BE ALLOWED ON TV", "THE END OF [uppr_name] AS WE KNOW IT")]", "Extremely low score of [score["crewscore"]].", 250)
		if(4500 to INFINITY)
			episode_names += new /datum/episode_name("[pick("THE CREW'S DAY OUT", "THIS SIDE OF PARADISE", "[uppr_name]: A SITUATION COMEDY", "THE CREW'S LUNCH BREAK", "THE CREW'S BACK IN BUSINESS", "THE CREW'S BIG BREAK", "THE CREW SAVES THE DAY", "THE CREW RULES THE WORLD", "THE ONE WITH ALL THE SCIENCE AND PROGRESS AND PROMOTIONS AND ALL THE COOL AND GOOD THINGS", "THE TURNING POINT")]", "High score of [score["crewscore"]].", 250)

	if(istype(ticker.mode, /datum/gamemode/dynamic))
		var/datum/gamemode/dynamic/mode = ticker.mode
		switch(mode.threat_level)
			if(0 to 35)
				episode_names += new /datum/episode_name("[pick("THE DAY [uppr_name] STOOD STILL", "MUCH ADO ABOUT NOTHING", "WHERE SILENCE HAS LEASE", "RED HERRING", "HOME ALONE", "GO BIG OR GO [uppr_name]", "PLACEBO EFFECT", "ECHOES", "SILENT PARTNERS", "WITH FRIENDS LIKE THESE...", "EYE OF THE STORM", "BORN TO BE MILD", "STILL WATERS")]", "Low threat level of [mode.threat_level]%.", 150)
				if(score["crewscore"] < -1000)
					episode_names += new /datum/episode_name/rare("[pick("HOW OH HOW DID IT ALL GO SO WRONG?!", "EXPLAIN THIS ONE TO THE EXECUTIVES", "THE CREW GOES ON SAFARI", "OUR GREATEST ENEMY", "THE INSIDE JOB", "MURDER BY PROXY")]", "Low threat level of [mode.threat_level]%... but the crew still had a very low score.", score["crewscore"]/150*-2)
				if(score["time"] > 60 * 60 * 3) //3 hours
					episode_names += new /datum/episode_name/rare("THE LONG NIGHT", "Low threat level of [mode.threat_level]%, and the round lasted over three hours.", 300)
			if(35 to 60)
				episode_names += new /datum/episode_name("[pick("THERE MIGHT BE BLOOD", "IT CAME FROM [uppr_name]!", "THE [uppr_name] INCIDENT", "THE ENEMY WITHIN", "MIDDAY MADNESS", "AS THE CLOCK STRIKES TWELVE", "CONFIDENCE AND PARANOIA", "THE PRANK THAT WENT WAY TOO FAR", "A HOUSE DIVIDED", "[uppr_name] TO THE RESCUE!", "ESCAPE FROM [uppr_name]", \
				"HIT AND RUN", "THE AWAKENING", "THE GREAT ESCAPE", "THE LAST TEMPTATION OF [uppr_name]", "[uppr_name]'S FALL FROM GRACE", "BETTER THE [uppr_name] YOU KNOW...", "PLAYING WITH FIRE", "UNDER PRESSURE", "THE DAY BEFORE THE DEADLINE", "[uppr_name]'S MOST WANTED", "THE BALLAD OF [uppr_name]")]", "Moderate threat level of [mode.threat_level]%.", 150)
			if(60 to 100)
				episode_names += new /datum/episode_name("[pick("ATTACK! ATTACK! ATTACK!", "CAN'T FIX CRAZY", "APOCALYPSE [pick("N", "W", "H")]OW", "A TASTE OF ARMAGEDDON", "OPERATION: ANNIHILATE!", "THE PERFECT STORM", "TIME'S UP FOR THE CREW", "A TOTALLY FUN THING THAT THE CREW WILL NEVER DO AGAIN", "EVERYBODY HATES [uppr_name]", "BATTLE OF [uppr_name]", \
				"THE SHOWDOWN", "MANHUNT", "THE ONE WITH ALL THE FIGHTING", "THE RECKONING OF [uppr_name]", "THERE GOES THE NEIGHBORHOOD", "THE THIN RED LINE", "ONE DAY FROM RETIREMENT")]", "High threat level of [mode.threat_level]%.", 250)
				if(score["crewscore"] > 3000)
					episode_names += new /datum/episode_name/rare("[pick("THE OPPORTUNITY OF A LIFETIME", "DRASTIC MEASURES", "DEUS EX", "THE SHOW MUST GO ON", "TRIAL BY FIRE", "A STITCH IN TIME", "ALL'S FAIR IN LOVE AND WAR", "COME HELL OR HIGH HEAVEN", "REVERSAL OF FORTUNE", "DOUBLE TOIL AND DOUBLE TROUBLE")]", "High threat level of [mode.threat_level]%... but the crew still had a very high score!", score["crewscore"]/50)
				if(score["time"] > 60 * 55 && score["time"] < 60 * 65) //55-65 minutes
					episode_names += new /datum/episode_name/rare("RUSH HOUR", "High threat level of [mode.threat_level]%, and the round lasted just about an hour.", 500)
		if(locate(/datum/dynamic_ruleset/roundstart/malf) in mode.executed_rules)
			episode_names += new /datum/episode_name/rare("[pick("I'M SORRY [uppr_name], I'M AFRAID I CAN'T LET YOU DO THAT", "A STRANGE GAME", "THE AI GOES ROGUE", "RISE OF THE MACHINES")]", "Round included a malfunctioning AI.", 300)
		if(locate(/datum/dynamic_ruleset/roundstart/delayed/revs) in mode.executed_rules)
			episode_names += new /datum/episode_name/rare("[pick("THE CREW STARTS A REVOLUTION", "HELL IS OTHER SPESSMEN", "INSURRECTION", "THE CREW RISES UP", 25;"FUN WITH FRIENDS")]", "Round included roundstart revs.", 350)
			if(copytext(uppr_name,1,2) == "V")
				episode_names += new /datum/episode_name/rare("V FOR [uppr_name]", "Round included roundstart revs... and the station's name starts with V.", 1500)
		if(locate(/datum/dynamic_ruleset/roundstart/blob) in mode.executed_rules)
			episode_names += new /datum/episode_name/rare("[pick("MARRIED TO THE BLOB", "THE CREW GETS QUARANTINED")]", "Round included a roundstart blob.", 350)
		if(ticker.explosion_in_progress || ticker.station_was_nuked)
			episode_names += new /datum/episode_name/rare("[pick("THE CREW GETS NUKED", "THE CREW IS THE BOMB", "THE CREW GOES NUCLEAR", "THE CREW BLASTS OFF AGAIN!", "THE 'BOOM' HEARD 'ROUND THE WORLD", 25;"THE BIG BANG THEORY")]", "The station was nuked!", 450)
			if((locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules) || (locate(/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear) in mode.executed_rules))
				theme = "syndie" //This really should use the nukeop's check_win(), but the newcops gamemode wasn't coded like that.
		else
			if((locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules) || (locate(/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear) in mode.executed_rules))
				episode_names += new /datum/episode_name/rare("[pick("THE CREW SOLVES THE NUCLEAR CRISIS", "BLAST, FOILED AGAIN", "FISSION MAILED", 50;"I OPENED THE WINDOW, AND IN FLEW COPS")]", "The crew defeated the nuclear operatives.", 350)
			if(score["nukedefuse"] < 30)
				episode_names += new /datum/episode_name/rare("[score["nukedefuse"]] SECOND[score["nukedefuse"] == 1 ? "" : "S"] TO MIDNIGHT", "The nuke was defused with [score["nukedefuse"]] seconds remaining.", (30 - score["nukedefuse"]) * 100)

	if(narsie_list.len > 0)
		episode_names += new /datum/episode_name/rare("[pick("NAR-SIE'S DAY OUT", "NAR-SIE'S VACATION", "THE CREW LEARNS ABOUT SACRED GEOMETRY", "REALM OF THE MAD GOD", "THE ONE WITH THE ELDRITCH HORROR", 50;"STUDY HARD, BUT PART-SIE HARDER")]", "Nar-Sie is loose!", 500)


	if(SNOW_THEME)
		episode_names += new /datum/episode_name("A VERY [pick("NANOTRASEN", "EXPEDITIONARY", "SECURE", "PLASMA", "MARTIAN")] CHRISTMAS", "'Tis the season.", 1000)
	if(score["gunsspawned"] > 0)
		episode_names += new /datum/episode_name/rare("[pick("GUNS, GUNS EVERYWHERE", "THUNDER GUN EXPRESS", "THE CREW GOES AMERICA ALL OVER EVERYBODY'S ASS")]", "[score["gunsspawned"]] guns were spawned this round.", min(750, score["gunsspawned"]*25))
	if(score["dimensionalpushes"] > 6)
		episode_names += new /datum/episode_name/rare("THE CREW GETS PUSHED TOO FAR", "[score["dimensionalpushes"]] things were dimensionalpush'd this round.", min(1500, score["dimensionalpushes"]*35))
	if(score["assesblasted"] > 4)
		episode_names += new /datum/episode_name/rare("A SONG OF ASS AND FIRE", "[score["assesblasted"]] people were magically assblasted this round.", min(1500, score["assesblasted"]*100))
	if(score["assesblasted"] > 3 && score["random_soc"] > 4)
		episode_names += new /datum/episode_name/rare("WINDS OF CHANGE", "A combination of asses blasted, and the staff of change.", min(1500, score["assesblasted"]*75 + score["random_soc"]*75))
	if(score["greasewiz"] > 7 && score["lightningwiz"] > 7)
		episode_names += new /datum/episode_name/rare("GREASED LIGHTNING", "A combination of the Grease and Lightning spells.", min(1500, score["greasewiz"]*45 + score["lightningwiz"]*45))
	if(score["lightningwiz"] > 12)
		episode_names += new /datum/episode_name/rare("[pick("SHOCK AND AWE", "SHOCK THERAPY")]", "[score["lightningwiz"]] people were shocked this round.", min(1500, score["lightningwiz"]*75))
	if(score["heartattacks"] > 4)
		episode_names += new /datum/episode_name/rare("MY HEART WILL GO ON", "[score["heartattacks"]] hearts were reanimated and burst out of someone's chest this round.", min(1500, score["heartattacks"]*250))
	if(score["richestcash"] > 30000)
		episode_names += new /datum/episode_name/rare("[pick("WAY OF THE WALLET", "THE IRRESISTIBLE RISE OF [uppertext(score["richestname"])]", "PRETTY PENNY", "IT'S THE ECONOMY, STUPID")]", "Scrooge Mc[score["richestkey"]] racked up [score["richestcash"]] credits this round.", min(450, score["richestcash"]/500))
	if(score["deadaipenalty"] > 3)
		episode_names += new /datum/episode_name/rare("THE ONE WHERE [score["deadaipenalty"]] AIS DIE", "That's a lot of dead AIs.", min(1500, score["deadaipenalty"]*300))
	if(score["lawchanges"] > 12)
		episode_names += new /datum/episode_name/rare("[pick("THE CREW LEARNS ABOUT LAWSETS", 15;"THE UPLOAD RAILROAD", 15;"FREEFORM", 15;"ASIMOV SAYS")]", "There were [score["lawchanges"]] law changes this round.", min(750, score["lawchanges"]*25))
	if(score["slips"] > 100)
		episode_names += new /datum/episode_name/rare("THE CREW GOES BANANAS", "[score["slips"]] people slipped this round.", min(500, score["slips"]/2))
	if(score["buttbotfarts"] > 100)
		episode_names += new /datum/episode_name/rare("DO BUTTBOTS DREAM OF ELECTRIC FARTS?", "[score["buttbotfarts"]] messages were mimicked by buttbots this round.", min(500, score["buttbotfarts"]/3))
	if(score["clownabuse"] > 75)
		episode_names += new /datum/episode_name/rare("EVERYBODY LOVES A CLOWN", "[score["clownabuse"]] instances of clown abuse this round.", min(350, score["clownabuse"]*2))
	if(score["maxpower"] > HUNDRED_MEGAWATTS && (locate(/mob/living/silicon/robot/mommi) in mob_list))
		episode_names += new /datum/episode_name/rare("WHAT HAPPENS WHEN YOU MIX MOMMIS AND COMMERCIAL-GRADE PACKING FOAM", "There was a powergrid with [score["maxpower"]]W, and 1 or more MoMMIs playing.", 250)
	if(score["turfssingulod"] > 200)
		episode_names += new /datum/episode_name/rare("[pick("THE SINGULARITY GETS LOOSE", "THE SINGULARITY GETS LOOSE (AGAIN)", "CONTAINMENT FAILURE", "THE GOOSE IS LOOSE", 50;"THE CREW'S ENGINE SUCKS", 50;"THE CREW GOES DOWN THE DRAIN")]", "The Singularity ate [score["turfssingulod"]] turfs this round.", min(1000, score["turfssingulod"]/2)) //no "singularity's day out" please we already have enough
	if(score["shardstouched"] > 0)
		episode_names += new /datum/episode_name/rare("[pick("HIGH EFFECT ENGINEERING", 25;"THE CREW'S ENGINE BLOWS", 25;"NEVER GO SHARD TO SHARD")]", "This is what happens when two shards touch.", min(2000, score["shardstouched"]*750))
	if(score["kudzugrowth"] > 150)
		episode_names += new /datum/episode_name/rare("[pick("REAP WHAT YOU SOW", "OUT OF THE WOODS", "SEEDY BUSINESS", "[uppr_name] AND THE BEANSTALK", "IN THE GARDEN OF EDEN")]", "[score["kudzugrowth"]] tiles worth of Kudzu were grown in total this round.", min(1500, score["kudzugrowth"]*2))
	if(score["disease"] >= score["escapees"] && score["escapees"] > 5)
		episode_names += new /datum/episode_name/rare("[pick("THE CREW GETS DOWN WITH THE SICKNESS", "THE CREW GETS AN INCURABLE DISEASE", "THE CREW'S SICK PUNS")]", "[score["disease"]] disease points this round.", min(500, (score["disease"]*25) * (score["disease"]/score["escapees"])))
	//future idea: "the crew loses their chill"/"disco inferno"/"ashes to ashes"/"burning down the house" if most of the station is on fire, if the chef was the only survivor, "if you can't stand the heat..."
	//future idea: "a cold day in hell" if most of the station was freezing and threat was high
	//future idea: "the crew has a blast" if six big explosions happen, "sitting ducks" if the escape shuttle is bombed and the would-be escapees were mostly vox, "on a wing and a prayer" if the shuttle is bombed but enough people survive anyways

	var/deadcatbeastcount = 0
	for(var/mob/living/carbon/human/H in dead_mob_list)
		if(iscatbeast(H) && (H.z == map.zMainStation || istype(get_area(H), /area/shuttle/escape/centcom)))
			deadcatbeastcount++
	if(deadcatbeastcount > 5)
		episode_names += new /datum/episode_name/rare("APOCALYPSE MEOW", "There were [deadcatbeastcount] dead catbeasts in world.", min(1000, deadcatbeastcount*75))

	for(var/mob/living/simple_animal/corgi/C in living_mob_list)
		if(C.spell_list.len > 0)
			episode_names += new /datum/episode_name/rare("[pick("WHERE NO DOG HAS GONE BEFORE", "IAN SAYS", "IAN'S DAY OUT", "EVERY DOG HAS ITS DAY", "THE ONE WITH THE MAGIC PUPPY")]", "You know what you did.", 1000)
			break

	if(score["greasewiz"] > 4)
		for(var/mob/living/carbon/monkey/M in mob_list)
			if(M.spell_list.len && (locate(/spell/targeted/grease) in M.spell_list))
				episode_names += new /datum/episode_name/rare("GREASE MONKEY", "A successful Grease wizard got monkeyed.", score["greasewiz"]*100)
				break

	if(ticker && ticker.shuttledocked_time != -1 && emergency_shuttle.location == CENTCOMM_Z)
		var/area/shuttle = locate(/area/shuttle/escape/centcom)
		if(shuttle) //These names are only to be rolled if the round ended with the shuttle normally docking at centcomm.
			var/list/shuttle_escapees = list() //We want to only count people that were on the shuttle. Pods don't even real
			var/list/human_escapees = list()
			for(var/mob/living/M in shuttle)
				if(M.isDead() || !M.key)
					continue
				shuttle_escapees |= M
				if(ishuman(M))
					human_escapees |= M

			if(ticker.shuttledocked_time - ticker.gamestart_time < SHUTTLEARRIVETIME + SHUTTLEGRACEPERIOD + 60) //shuttle docked in less than 16 minutes!!
				episode_names += new /datum/episode_name/rare("[pick("THE CAPTAIN STUBS THEIR TOE", "QUICK GETAWAY", "A MOST EFFICIENT APOCALYPSE", "THE CREW'S [round(score["time"]/60)] MINUTES OF FAME", "ON SECOND THOUGHT, LET'S NOT GO TO [uppr_name]. 'TIS A SILLY PLACE.")]", "This round was about as short as they come.", 750)
				if(score["escapees"] == 0)
					episode_names += new /datum/episode_name/rare("DRY RUN", "This round was as short as they come, and there were no escapees.", 2500)
			if(score["deadcrew"] == 0)
				episode_names += new /datum/episode_name/rare("[pick("EMPLOYEE TRANSFER", "LIVE LONG AND PROSPER", "PEACE AND QUIET IN [uppr_name]", "THE ONE WITHOUT ALL THE FIGHTING", "THE CREW TRIES TO KILL A FLY FOR [round(score["time"]/60)] MINUTES")]", "No-one died this round.", 2500) //in practice, this one is very very very rare, so if it happens let's pick it more often
			if(score["escapees"] == 0 && ticker && ticker.shuttledocked_time != -1)
				episode_names += new /datum/episode_name("[pick("DEAD SPACE", "THE CREW GOES MISSING", "LOST IN TRANSLATION", "[uppr_name]: DELETED SCENES", "WHAT HAPPENS IN [uppr_name], STAYS IN [uppr_name]", "MISSING IN ACTION", "SCOOBY-DOO, WHERE'S THE CREW?")]", "There were no escapees on the shuttle.", 300)
			if(score["escapees"] < 6 && score["escapees"] > 0 && score["deadcrew"] > score["escapees"]*2)
				episode_names += new /datum/episode_name("[pick("AND THEN THERE WERE FEWER", "THE 'FUN' IN 'FUNERAL'", "FREEDOM RIDE OR DIE", "THINGS WE LOST IN [uppr_name]", "GONE WITH [uppr_name]", "LAST TANGO IN [uppr_name]", "GET BUSY LIVING OR GET BUSY DYING", "THE CREW FUCKING DIES", "WISH YOU WERE HERE")]", "[score["deadcrew"]] people died this round.", 400)

			var/clowncount = 0
			var/mimecount = 0
			var/assistantcount = 0
			var/chefcount = 0
			var/chaplaincount = 0
			var/lawyercount = 0
			var/minercount = 0
			var/skeletoncount = 0
			var/voxcount = 0
			var/tradercount = 0
			var/dionacount = 0
			var/baldycount = 0
			var/fattycount = 0
			var/horsecount = 0
			var/piggycount = 0
			for(var/mob/living/carbon/human/H in human_escapees)
				if(H.mind && H.mind.miming)
					mimecount++
				if(H.is_wearing_any(list(/obj/item/clothing/mask/gas/clown_hat, /obj/item/clothing/mask/gas/sexyclown)) || (H.mind && H.mind.assigned_role == "Clown"))
					clowncount++
				if(H.is_wearing_item(/obj/item/clothing/under/color/grey) || (H.mind && H.mind.assigned_role == "Assistant"))
					assistantcount++
				if(H.is_wearing_item(/obj/item/clothing/head/chefhat) || (H.mind && H.mind.assigned_role == "Chef"))
					chefcount++
				if(H.is_wearing_any(list(/obj/item/clothing/suit/storage/lawyer, /obj/item/clothing/under/lawyer)) || (H.mind && H.mind.assigned_role == "Internal Affairs Agent"))
					lawyercount++
				if(H.mind && H.mind.assigned_role == "Trader")
					tradercount++
				if(H.mind && H.mind.assigned_role == "Shaft Miner")
					minercount++
				if(H.mind && H.mind.assigned_role == "Chaplain")
					chaplaincount++
					if(ischangeling(H))
						episode_names += new /datum/episode_name/rare("[uppertext(H.real_name)]: A BLESSING IN DISGUISE", "The Chaplain, [H.real_name], was a changeling and escaped alive.", 750)
				if(isskellington(H) || isplasmaman(H) || isskelevox(H))
					skeletoncount++
				if(isvox(H) || isskelevox(H))
					voxcount++
				if(isdiona(H))
					dionacount++
				if(isjusthuman(H) && (H.my_appearance.h_style == "Bald" || H.my_appearance.h_style == "Skinhead") && !H.check_body_part_coverage(HEAD))
					baldycount++
				if(M_FAT in H.mutations)
					fattycount++
				if(H.is_wearing_item(/obj/item/clothing/mask/horsehead))
					horsecount++
				if(H.is_wearing_item(/obj/item/clothing/mask/pig))
					piggycount++

			if(clowncount > 2)
				episode_names += new /datum/episode_name/rare("CLOWNS GALORE", "There were [clowncount] clowns on the shuttle.", min(1500, clowncount*250))
				theme = "clown"
			if(mimecount > 2)
				episode_names += new /datum/episode_name/rare("THE SILENT SHUFFLE", "There were [mimecount] mimes on the shuttle.", min(1500, mimecount*250))
			if(chaplaincount > 2)
				episode_names += new /datum/episode_name/rare("COUNT YOUR BLESSINGS", "There were [chaplaincount] chaplains on the shuttle. Like, the real deal, not just clothes.", min(1500, chaplaincount*450))
			if(chefcount > 2)
				episode_names += new /datum/episode_name/rare("Too Many Cooks", "There were [chefcount] chefs on the shuttle.", min(1500, chefcount*450)) //intentionally not capitalized, as the theme will customize it
				theme = "cooks"
			if(assistantcount / human_escapees.len > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name/rare("[pick("GREY GOO", "RISE OF THE GREYTIDE")]", "Most of the survivors were Assistants, or at least dressed like one.", min(1500, assistantcount*200))
			if(skeletoncount / human_escapees.len > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name/rare("SKELETON CREW", "Most of the survivors were literal skeletons.", min(1500, skeletoncount*350))
			if(voxcount / human_escapees.len > 0.6 && human_escapees.len > 2)
				episode_names += new /datum/episode_name/rare("BIRDS OF A FEATHER...", "Most of the survivors were Vox.", min(1500, voxcount*250))
			if(voxcount / human_escapees.len > 0.6 && emergency_shuttle.was_early_launched)
				episode_names += new /datum/episode_name/rare("EARLY BIRD GETS THE WORM", "Most or all of the survivors were Vox, and the shuttle timer was shortened.", 1500)
			if(dionacount / human_escapees.len > 0.6)
				episode_names += new /datum/episode_name/rare("[pick("ALL BARK AND NO BITE", "THE CREW GETS STUMPED")]", "Most of the survivors were Diona.", min(1500, dionacount*350))
			if(baldycount / human_escapees.len > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name/rare("TO BALDLY GO", "Most of the survivors were bald, and it shows.", min(1500, baldycount*250))
			if(fattycount / human_escapees.len > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name/rare("[pick("THE GREAT FATSBY", "THE CREW NEEDS TO LIGHTEN UP", "THE CREW PUTS ON WEIGHT", "THE FOUR CHIN CREW")]", "Most of the survivors were fat.", min(1500, fattycount*250))
			if(horsecount / human_escapees.len > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name/rare("STRAIGHT FROM THE HORSE'S MOUTH", "Most of the survivors wore horse heads.", min(1500, horsecount*250))
			if(tradercount == human_escapees.len)
				episode_names += new /datum/episode_name/rare("STEALING HOME", "The Vox Traders hijacked the shuttle.", min(1500, tradercount*500))

			if(human_escapees.len == 1)
				var/mob/living/carbon/human/H = human_escapees[1]

				if(istraitor(H) || isdoubleagent(H) || isnukeop(H))
					theme = "syndie"

				if(isloosecatbeast(H))
					episode_names += new /datum/episode_name/rare("CAT'S PAW", "The only survivor was a loose catbeast.", 1500)
					//if(station was freezing!!!!)
						//episode_names += new /datum/episode_name/rare("ONE COOL CAT", "The only survivor was a loose catbeast. Also the station was freezing.", 2500)

				if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Chef")
					var/chance = 250
					if(H.is_wearing_item(/obj/item/clothing/head/chefhat))
						chance += 500
					if(H.is_wearing_item(/obj/item/clothing/suit/chef))
						chance += 500
					if(H.is_wearing_item(/obj/item/clothing/under/rank/chef))
						chance += 250
					episode_names += new /datum/episode_name/rare("HAIL TO THE CHEF", "The Chef was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Clown")
					var/chance = 250
					if(H.is_wearing_item(/obj/item/clothing/mask/gas/clown_hat))
						chance += 500
					if(H.is_wearing_any(list(/obj/item/clothing/shoes/clown_shoes, /obj/item/clothing/shoes/jestershoes)))
						chance += 500
					if(H.is_wearing_any(list(/obj/item/clothing/under/rank/clown, /obj/item/clothing/under/jester)))
						chance += 250
					episode_names += new /datum/episode_name/rare("[pick("COME HELL OR HIGH HONKER", "THE LAST LAUGH")]", "The Clown was the only survivor in the shuttle.", chance)
					theme = "clown"
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Internal Affairs Agent")
					var/chance = 250
					if(H.find_held_item_by_type(/obj/item/weapon/storage/briefcase))
						chance += 500
					if(H.is_wearing_any(list(/obj/item/clothing/suit/storage/lawyer, /obj/item/clothing/suit/storage/internalaffairs)))
						chance += 500
					if(H.is_wearing_any(list(/obj/item/clothing/under/rank/internalaffairs, /obj/item/clothing/under/bridgeofficer, /obj/item/clothing/under/lawyer)))
						chance += 250
					episode_names += new /datum/episode_name/rare("DEVIL'S ADVOCATE", "The IAA was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Detective")
					var/chance = 250
					if(H.find_held_item_by_type(/obj/item/weapon/gun/projectile/detective))
						chance += 1000
					if(H.is_wearing_item(/obj/item/clothing/head/det_hat))
						chance += 500
					if(H.is_wearing_any(list(/obj/item/clothing/suit/storage/det_suit/, /obj/item/clothing/suit/storage/forensics)))
						chance += 500
					if(H.is_wearing_item(/obj/item/clothing/under/det))
						chance += 250
					episode_names += new /datum/episode_name/rare("[uppertext(H.real_name)]: LOOSE CANNON", "The Detective was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Shaft Miner")
					var/chance = 250
					if(H.find_held_item_by_type(/obj/item/weapon/pickaxe))
						chance += 1000
					if(H.is_wearing_item(/obj/item/clothing/suit/space/rig/mining))
						chance += 500
					if(H.is_wearing_item(/obj/item/clothing/head/helmet/space/rig/mining))
						chance += 500
					if(H.is_wearing_item(/obj/item/clothing/under/rank/miner))
						chance += 250
					episode_names += new /datum/episode_name/rare("[pick("YOU KNOW THE DRILL", "CAN YOU DIG IT?", "JOURNEY TO THE CENTER OF THE ASTEROI", "CAVE STORY", "QUARRY ON")]", "The Miner was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Librarian")
					var/chance = 750
					if(H.find_held_item_by_type(/obj/item/weapon/book))
						chance += 1000
					if(H.is_wearing_item(/obj/item/clothing/under/suit_jacket/red))
						chance += 500
					episode_names += new /datum/episode_name/rare("COOKING THE BOOKS", "The Librarian was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Chemist")
					var/chance = 1000
					if(H.is_wearing_item(/obj/item/clothing/suit/storage/labcoat/chemist))
						chance += 500
					if(H.is_wearing_any(list(/obj/item/clothing/under/rank/pharma, /obj/item/clothing/under/rank/chemist)))
						chance += 250
					episode_names += new /datum/episode_name/rare("A BITTER PILL TO SWALLOW", "The Chemist was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.role_alt_title == "Xenoarcheologist")
					var/chance = 1000
					if(H.is_wearing_item(/obj/item/clothing/under/rank/xenoarch))
						chance += 500
					episode_names += new /datum/episode_name/rare("THE CREW IS NOW ANCIENT HISTORY", "The Xenoarchaeologist was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Chaplain") //We don't check for uniform here because the chaplain's thing kind of is to improvise their garment gimmick
					episode_names += new /datum/episode_name/rare("BLESS THIS MESS", "The Chaplain was the only survivor in the shuttle.", 1250)

				if(H.is_wearing_item(/obj/item/clothing/suit/raincoat) && H.find_held_item_by_type(/obj/item/weapon/fireaxe))
					episode_names += new /datum/episode_name/rare("[pick("SPACE AMERICAN PSYCHO", "NANOTRASEN PSYCHO", "[uppr_name] PSYCHO")]", "The only survivor in the shuttle wore a raincoat and held a fireaxe.", 1500)
				if(H.is_wearing_item(/obj/item/clothing/mask/luchador) && H.is_wearing_item(/obj/item/clothing/gloves/boxing))
					episode_names += new /datum/episode_name/rare("[pick("THE CREW, ON THE ROPES", "THE CREW, DOWN FOR THE COUNT", "[uppr_name], DOWN AND OUT")]", "The only survivor in the shuttle wore a luchador mask and boxing gloves.", 1500)

			if(human_escapees.len == 2)
				if(lawyercount == 2)
					episode_names += new /datum/episode_name/rare("DOUBLE JEOPARDY", "The only two survivors were IAAs or lawyers.", 2500)
				if(chefcount == 2)
					episode_names += new /datum/episode_name/rare("CHEF WARS", "The only two survivors were chefs.", 2500)
				if(minercount == 2)
					episode_names += new /datum/episode_name/rare("THE DOUBLE DIGGERS", "The only two survivors were miners.", 2500)
				if(clowncount == 2)
					episode_names += new /datum/episode_name/rare("A TALE OF TWO CLOWNS", "The only two survivors were clowns.", 2500)
					theme = "clown"
				if(clowncount == 1 && mimecount == 1)
					episode_names += new /datum/episode_name/rare("THE DYNAMIC DUO", "The only two survivors were the Clown, and the Mime.", 2500)

			if(human_escapees.len == 1)
				var/shoecount = 0
				for(var/obj/item/clothing/shoes/S in shuttle) //they gotta be on the floor
					shoecount++
				if(shoecount > 5 || score["shoesnatches"] > 10)
					episode_names += new /datum/episode_name/rare("THE SOLE SURVIVOR", "There was only one survivor in the shuttle, and they didn't forget their shoes.", 2500) //I'm not sorry

				var/headcount = 0
				for(var/obj/item/organ/external/head/H in shuttle) //they gotta be on the floor
					headcount++
				var/mob/living/carbon/human/trait = human_escapees[1]
				var/obj/item/weapon/storage/belt/skull/trophybelt = trait.is_wearing_item(/obj/item/weapon/storage/belt/skull)
				if(trophybelt)
					for(var/obj/item/organ/external/head/H in trophybelt)
						headcount++
				if(headcount > 3)
					episode_names += new /datum/episode_name/rare("HEAD OF THE CLASS", "There was only one survivor in the shuttle, and they got a lot of head.", min(2000, headcount*300))

			if(human_escapees.len == 0)
				var/wolfcount = 0
				for(var/mob/living/simple_animal/hostile/wolf/W in shuttle)
					wolfcount += 1
				var/livingmobcount = 0
				for(var/mob/living/L in shuttle)
					livingmobcount += 1
				if(wolfcount == 1 && livingmobcount == 1)
					episode_names += new /datum/episode_name/rare("LONE WOLF", "...", 1500)
			else //more than 0 human escapees
				var/braindamage_total = 0
				var/all_retarded = TRUE
				for(var/mob/living/carbon/human/H in human_escapees)
					if(H.brainloss < 60)
						all_retarded = FALSE
					braindamage_total += H.brainloss
				var/average_braindamage = braindamage_total / human_escapees.len
				if(average_braindamage > 30)
					episode_names += new /datum/episode_name/rare("[pick("THE CREW'S SMALL IQ PROBLEM", "OW! MY BALLS", "BR[pick("AI", "IA")]N DAM[pick("AGE", "GE", "AG")]", "THE VERY SPECIAL CREW OF [uppr_name]")]", "Average of [average_braindamage] brain damage for each human shuttle escapee.", min(1000, average_braindamage*10))
				if(all_retarded && human_escapees.len > 2)
					episode_names += new /datum/episode_name/rare("...AND PRAY THERE'S INTELLIGENT LIFE SOMEWHERE OUT IN SPACE, 'CAUSE THERE'S BUGGER ALL DOWN HERE IN [uppr_name]", "Everyone was retarded this round.", human_escapees.len * 500)

			var/bearcount = 0
			for(var/mob/living/simple_animal/hostile/bear/B in shuttle)
				bearcount += 1
			if(bearcount > 3)
				episode_names += new /datum/episode_name/rare("BEARS REPEATING", "There were [bearcount] bears on the shuttle.", min(1000, bearcount*100))

			for(var/mob/living/simple_animal/hostile/retaliate/box/B in shuttle)
				piggycount += 1
			if(piggycount > 3)
				episode_names += new /datum/episode_name/rare("BRINGING HOME THE BACON", "[piggycount] little piggies went to the shuttle...", min(1500, piggycount*200))

			var/cowcount = 0
			for(var/mob/living/simple_animal/cow/C in shuttle)
				cowcount += 1
			if(cowcount > 1)
				episode_names += new /datum/episode_name/rare("'TIL THE COWS COME HOME", "There were [cowcount] cows on the shuttle.", min(1500, cowcount*300))

			var/beecount = 0
			for(var/mob/living/simple_animal/bee/B in shuttle)
				beecount += B.bees.len
			if(beecount > 15)
				episode_names += new /datum/episode_name/rare("FLIGHT OF THE BUMBLEBEES", "There were [beecount] bees on the shuttle.", min(1500, beecount*25))
				if(voxcount / human_escapees.len > 0.6)
					episode_names += new /datum/episode_name/rare("THE BIRD[human_escapees.len == 1 ? "" : "S"] AND THE BEES", "There were [beecount] bees on the shuttle, and most or all of the survivors were Vox.", min(2500, beecount*40 + voxcount*500))

			for(var/obj/machinery/power/supermatter/SM in shuttle)
				episode_names += new /datum/episode_name/rare("REALM OF THE RAD GOD", "Someone dragged \a [SM] onto the shuttle.", 1500)
				break

			if(score["random_soc"] > 7)
				var/list/nasty_things = list()
				var/list/adjectives = list()

				for(var/mob/living/M in shuttle)
					if(isslime(M) || isslimeadult(M))
						nasty_things |= "EVIL OOZE"
					else if(ismonkey(M))
						nasty_things |= "SUBHUMANOIDS"
					else if(isgremlin(M))
						nasty_things |= "DEVILISH TRICKSTER"
					else if(isalien(M) || isalienadult(M))
						nasty_things |= "XENOMORPHS"
					else if(iscatbeast(M))
						nasty_things |= "FLEA-RIDDEN MUTANTS"
					else if(ismartian(M))
						nasty_things |= "MARS PEOPLE"
					else if(isskellington(M))
						nasty_things |= "LIVING SKELETONS"
					else if(isrobot(M))
						nasty_things |= "ROBOT MENACE"
					else if(iszombie(M))
						nasty_things |= "FLESH-EATING DEAD"
					else if(iscluwne(M))
						nasty_things |= "HELL-BOUND PRANKSTER"

				for(var/mob/living/M in mob_list)
					if(istraitor(M))
						adjectives |= "TRAITOROUS"
					if(isdoubleagent(M))
						adjectives |= "DOUBLE-CROSSING"
					if(isvampire(M))
						adjectives |= "BLOOD-SUCKING"
					if(isrev(M))
						adjectives |= "REVOLTING"
					if(isninja(M))
						adjectives |= "CRAZED"
					if(issurvivor(M))
						adjectives |= "PARANOID"
					if(iscrusader(M))
						adjectives |= "MEDIEVAL"
					if(isanycultist(M))
						adjectives |= "OCCULT"
					if(ischangeling(M))
						nasty_things |= "SHAPE-SHIFTING BACKSTABBERS"

				if(nasty_things.len > 3)
					var/final_string = "NIGHT OF THE DAY OF THE DAWN AT NOON OF THE SON OF THE BRIDE OF THE RETURN OF THE REVENGE OF THE TERROR OF THE ATTACK OF "
					for(var/X in nasty_things)
						final_string += "THE [X] AND "
					final_string += "THE FINAL STAND OF THE "
					if(adjectives.len > 0)
						for(var/X in adjectives)
							final_string += "[X], "
					final_string += "GOD-FORSAKEN CREW OF [uppr_name]"

					episode_names += new /datum/episode_name/rare(final_string, "Thanks to the Staff of Change, we had quite a diverse shuttle.", 2500)
