/datum/episode_name
	var/thename = ""
	var/reason = "Default episode name." //Explanation on why this episode name fits this round. For the admin panel.
	var/weight = 100 //50 will have 50% the chance of being picked. 200 will have 200% the chance of being picked, etc. Relative to other names, not total (just the default names already total 900%)

/datum/episode_name/New(var/thename, var/reason, var/weight)
	if(!thename)
		return
	src.thename = thename
	if(reason)
		src.reason = reason
	if(weight)
		src.weight = weight

	if(prob(5))
		thename += ": PART I"
	else if(prob(5))
		thename += ": PART II"
	else if(prob(2))
		thename += ": PART III"
	else if(prob(4) && score["time"] > 60 * 60 * 3) //3 hours
		thename += ": THE FEATURE LENGTH PRESENTATION"
	else if(prob(4) && score["time"] > 0 && score["time"] < 60 * 30) //30 min
		thename += ": ABRIDGED"
	else if(prob(1))
		thename += ": NOW IN 3D"
	else if(prob(1))
		thename += ": ON ICE!"
	else if(prob(1))
		thename += ": THE SEASON FINALE"
	else if(prob(50))
		for(var/client/C in clients)
			if(C.key == "pomf123" || C.key == "exadv1")
				thename += ": THE DIRECTOR'S CUT"
				break


/datum/episode_name/proc/make_div(var/admindatum) //This is just for the admin panel.
	. = "[weight]% <a href='?src=\ref[admindatum];credits=namedatumweight;nameref=\ref[src]'>(Set)</a> - "
	. += "[thename] - <a href='?src=\ref[admindatum];credits=namedatumedit;nameref=\ref[src]'>(Edit)</a> "
	. += "<a href='?src=\ref[admindatum];credits=namedatumremove;nameref=\ref[src]'>(Remove)</a> "
	. += "<span title='[reason]'>(?)</span>"

/datum/credits/proc/draft_episode_names()
	var/uppr_name = uppertext(station_name()) //so we don't run these two 500 times

	episode_names += new /datum/episode_name("THE [pick("DOWNFALL OF", "RISE OF", "TROUBLE WITH", "FINAL STAND OF", "DARK SIDE OF")] [pick("SPACEMEN", "HUMANITY", "DIGNITY", "SANITY", "THE CHIMPANZEES", "THE VENDOMAT PRICES", "[uppr_name]")]")
	episode_names += new /datum/episode_name("THE CREW [pick("GOES JIHAD", "GOES ON WELFARE", "GIVES BACK", "SELLS OUT", "GETS WHACKED", "BITES THE DUST", "SOLVES THE PLASMA CRISIS", "HITS THE ROAD", "GETS AN ANAL PROBE", "RULES THE WORLD", "RISES", "SAVES THE DAY", "RETIRES", "GOES TO HELL", "DOES A CLIP SHOW", "GETS AUDITED", "DOES A TV COMMERCIAL", "AFTER HOURS", "GOES TOO FAR", "GIVES UP THE DREAM", "SHOULD NOT BE ALLOWED ON TV", "GETS A LIFE", "IS DONE FOR", "STRIKES BACK")]")
	episode_names += new /datum/episode_name("THE CREW'S [pick("DAY OUT", "PUNISHMENT", "BIG GAY ADVENTURE", "LUNCH BREAK", "LAST DAY", "[pick("WILD", "WACKY", "LAME", "UNEXPECTED")] VACATION", "CHANGE OF HEART", "BIG BREAK", "BACK IN BUSINESS", "NEW GROOVE", "SCHOOL MUSICAL", "HISTORY LESSON", "FLYING CIRCUS", "SMALL PROBLEM", "BIG SCORE", "BLOOPER REEL")]")
	episode_names += new /datum/episode_name("THE CREW GETS [pick("RACIST", "PICKLED", "AN INCURABLE DISEASE", "PIZZA", "NEW WHEELS", "A VALUABLE HISTORY LESSON", "A BREAK", "HIGH", "TO LIVE", "TO RELIVE THEIR CHILDHOOD", "EMBROILED IN CIVIL WAR", "SERIOUS ABOUT [pick("DRUG ABUSE", "CRIME", "PRODUCTIVITY", "ANCIENT AMERICAN CARTOONS", "SPACEBALL")]")]")
	episode_names += new /datum/episode_name("[pick("SPACE", "SEXY", "DRAGON", "WARLOCK", "LAUNDRY", "GUN", "ADVERTISING", "DOG", "CARBON MONOXIDE", "NINJA", "WIZARD", "SOCRATIC", "JUVENILE DELIQUENCY", "POLITICALLY MOTIVATED", "RADTACULAR SICKNASTY")] [pick("QUEST", "FORCE", "ADVENTURE")]")
	episode_names += new /datum/episode_name("[pick("BALANCE OF POWER", "SPACE TRACK", "SEX BOMB", "WHOSE IDEA WAS THIS ANYWAY?", "WHATEVER HAPPENED, HAPPENED", "THE GOOD, THE BAD, AND [uppr_name]", "RESTRAIN YOUR ENJOYMENT", "[uppr_name]: A NATIONAL CONCERN", "A PUBLIC RELATIONS NIGHTMARE", "WITH APOLOGIES TO THE CREW", "PILOT", "REAL HOUSEWIVES OF [uppr_name]", "MEANWHILE, ON [uppr_name]...")]")

	if(istype(ticker.mode, /datum/gamemode/dynamic))
		var/datum/gamemode/dynamic/mode = ticker.mode
		switch(mode.threat_level)
			if(0 to 30)
				episode_names += new /datum/episode_name("[pick("THE DAY [uppr_name] STOOD STILL", "MUCH ADO ABOUT NOTHING", "WHERE SILENCE HAS LEASE", "RED HERRING", "THIS SIDE OF PARADISE", "HOME ALONE", "[uppr_name]: A SITUATION COMEDY", "GO BIG OR GO [uppr_name]", "PLACEBO EFFECT")]", "Low threat level of [mode.threat_level]%.", 150)
			if(30 to 70)
				episode_names += new /datum/episode_name("[pick("THERE MIGHT BE BLOOD", "IT CAME FROM [uppr_name]!", "THE BALLAD OF [uppr_name]", "THE [uppr_name] INCIDENT", "THE ENEMY WITHIN", "MIDDAY MADNESS", "AS THE CLOCK STRIKES TWELVE", "CONFIDENCE AND PARANOIA", "THE PRANK THAT WENT WAY TOO FAR", "A HOUSE DIVIDED")]", "Moderate threat level of [mode.threat_level]%.", 200)
			if(70 to 100)
				episode_names += new /datum/episode_name("[pick("ATTACK! ATTACK! ATTACK!", "SPACE 'NAM", "CAN'T FIX CRAZY", "APOCALYPSE [pick("N", "W", "H")]OW", "A TASTE OF ARMAGEDDON", "OPERATION: ANNIHILATE!", "THE PERFECT STORM", "TIME'S UP FOR THE CREW", "THE END OF [uppr_name] AS WE KNOW IT", "A TOTALLY FUN THING THAT THE CREW WILL NEVER DO AGAIN", "EVERYBODY HATES [uppr_name]", "BATTLE OF [uppr_name]")]", "High threat level of [mode.threat_level]%.", 250)
		if(locate(/datum/dynamic_ruleset/roundstart/malf) in mode.executed_rules)
			episode_names += new /datum/episode_name("[pick("I'M SORRY [uppr_name], I'M AFRAID I CAN'T LET YOU DO THAT", "A STRANGE GAME", "THE AI GOES ROGUE", "RISE OF THE MACHINES")]", "Round included a malfunctioning AI.", 300)
		if(locate(/datum/dynamic_ruleset/roundstart/revs) in mode.executed_rules)
			episode_names += new /datum/episode_name("[pick("THE CREW STARTS A REVOLUTION", "HELL IS OTHER SPESSMEN")]", "Round included roundstart revs.", 250)
			if(copytext(uppr_name,1,2) == "V")
				episode_names += new /datum/episode_name("V FOR [uppr_name]", "Round included roundstart revs... and the station's name starts with V.", 750)
		if(ticker.explosion_in_progress || ticker.station_was_nuked)
			episode_names += new /datum/episode_name("[pick("THE CREW GETS NUKED", "THE CREW IS THE BOMB", "THE CREW BLASTS OFF AGAIN!", "THE 'BOOM' HEARD 'ROUND THE WORLD")]", "The station was nuked!", 350)
		else
			if((locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules) || (locate(/datum/dynamic_ruleset/midround/nuclear) in mode.executed_rules))
				episode_names += new /datum/episode_name("[pick("THE CREW SOLVES THE NUCLEAR CRISIS", "BLAST, FOILED AGAIN", "FISSION MAILED", 50;"I OPENED THE WINDOW, AND IN FLEW COPS")]", "The crew defeated the nuclear operatives.", 350)
			if(score["nukedefuse"] < 30)
				episode_names += new /datum/episode_name("[score["nukedefuse"]] SECOND[score["nukedefuse"] == 1 ? "" : "S"] TO MIDNIGHT", "The nuke was defused with [score["nukedefuse"]] seconds remaining.", (30 - score["nukedefuse"]) * 100)

		//if(locate(/datum/dynamic_ruleset/roundstart/blob) in mode.executed_rules) //uncomment when blob gets readded
		//	episode_names += new /datum/episode_name("[pick("MARRIED TO THE BLOB", "THE CREW GETS QUARANTINED")]", "Round included a roundstart blob.", 250)
	if(narsie_list.len > 0)
		episode_names += new /datum/episode_name("[pick("NAR-SIE'S DAY OUT", "NAR-SIE'S VACATION", "THE CREW LEARNS ABOUT SACRED GEOMETRY", "REALM OF THE MAD GOD", 50;"STUDY HARD, BUT PART-SIE HARDER")]", "Nar-Sie is loose!", 350)


	if(SNOW_THEME)
		episode_names += new /datum/episode_name("A VERY [pick("NANOTRASEN", "EXPEDITIONARY", "SECURE", "PLASMA", "MARTIAN")] CHRISTMAS", "'Tis the season.", 1000)
	if(score["gunsspawned"] > 0)
		episode_names += new /datum/episode_name("[pick("GUNS, GUNS EVERYWHERE", "THUNDER GUN EXPRESS", "THE CREW GOES AMERICA ALL OVER EVERYBODY'S ASS")]", "[score["gunsspawned"]] guns were spawned this round.", min(450, score["gunsspawned"]*10))
	if(score["dimensionalpushes"] > 10)
		episode_names += new /datum/episode_name("THE CREW GETS PUSHED TOO FAR", "[score["dimensionalpushes"]] things were dimensionalpush'd this round.", min(1000, score["dimensionalpushes"]*15))
	if(score["assesblasted"] > 4)
		episode_names += new /datum/episode_name("A SONG OF ASS AND FIRE", "[score["assesblasted"]] people were magically assblasted this round.", min(1000, score["assesblasted"]*50))
	if(score["assesblasted"] > 3 && score["random_soc"] > 4)
		episode_names += new /datum/episode_name("WINDS OF CHANGE", "A combination of asses blasted, and the staff of change.", min(1000, score["assesblasted"]*30 + score["random_soc"]*30))
	if(score["greasewiz"] > 7 && score["lightningwiz"] > 7)
		episode_names += new /datum/episode_name("GREASED LIGHTNING", "A combination of the Grease and Lightning spells.", min(1000, score["greasewiz"]*30 + score["lightningwiz"]*30))
	if(score["heartattacks"] > 4)
		episode_names += new /datum/episode_name("MY HEART WILL GO ON", "[score["heartattacks"]] hearts were reanimated and burst out of someone's chest this round.", min(1000, score["heartattacks"]*100))
	if(score["richestcash"] > 30000)
		episode_names += new /datum/episode_name("[pick("WAY OF THE WALLET", "THE IRRESISTIBLE RISE OF [uppertext(score["richestname"])]", "PRETTY PENNY", "IT'S THE ECONOMY, STUPID")]", "Scrooge Mc[score["richestkey"]] racked up [score["richestcash"]] credits this round.", min(450, score["richestcash"]/500))
	if(star && star.times_cloned > 2)
		episode_names += new /datum/episode_name("[uppertext(star.real_name)] MUST DIE", "The star of the show, [star.real_name], was cloned [star.times_cloned] times.", min(500, star.times_cloned*50))
	if(score["deadaipenalty"] > 2)
		episode_names += new /datum/episode_name("THE ONE WHERE [score["deadaipenalty"]] AIS DIE", "That's a lot of dead AIs.", min(1000, score["deadaipenalty"]*100))
	if(score["lawchanges"] > 10)
		episode_names += new /datum/episode_name("THE CREW LEARNS ABOUT LAWSETS", "There were [score["lawchanges"]] law changes this round.", min(750, score["lawchanges"]*25))
	if(score["slips"] > 100)
		episode_names += new /datum/episode_name("THE CREW GOES BANANAS", "[score["slips"]] people slipped this round.", min(500, score["slips"]/2))
	if(score["buttbotfarts"] > 100)
		episode_names += new /datum/episode_name("DO BUTTBOTS DREAM OF ELECTRIC FARTS?", "[score["buttbotfarts"]] messages were mimicked by buttbots this round.", min(250, score["buttbotfarts"]/3))
	if(score["clownabuse"] > 75)
		episode_names += new /datum/episode_name("EVERYBODY LOVES A CLOWN", "[score["clownabuse"]] instances of clown abuse this round.", min(350, score["clownabuse"]*2))
	if(score["maxpower"] > HUNDRED_MEGAWATTS && (locate(/mob/living/silicon/robot/mommi) in mob_list))
		episode_names += new /datum/episode_name("WHAT HAPPENS WHEN YOU MIX MOMMIS AND COMMERCIAL-GRADE PACKING FOAM", "There was a powergrid with [score["maxpower"]]W, and 1 or more MoMMIs playing.", 250)
	if(score["turfssingulod"] > 200)
		episode_names += new /datum/episode_name("[pick("THE SINGULARITY GETS LOOSE", "THE SINGULARITY GETS LOOSE (AGAIN)", "CONTAINMENT FAILURE", "THE GOOSE IS LOOSE", 50;"THE CREW'S ENGINE SUCKS", 50;"THE CREW GOES DOWN THE DRAIN")]", "The Singularity ate [score["turfssingulod"]] turfs this round.", min(1000, score["turfssingulod"]/2)) //no "singularity's day out" please we already have enough
	if(score["shardstouched"] > 0)
		episode_names += new /datum/episode_name("[pick("HIGH EFFECT ENGINEERING", 25;"THE CREW'S ENGINE BLOWS", 25;"NEVER GO SHARD TO SHARD")]", "This is what happens when two shards touch.", min(2000, score["shardstouched"]*750))
	if(score["kudzugrowth"] > 200)
		episode_names += new /datum/episode_name("[pick("REAP WHAT YOU SOW", "FARM ILL", "SEEDY BUSINESS", "[uppr_name] AND THE BEANSTALK", "IN THE GARDEN OF EDEN")]", "[score["kudzugrowth"]] tiles worth of Kudzu were grown in total this round.", min(1500, score["kudzugrowth"]))
	if(score["oremined"] > 500)
		episode_names += new /datum/episode_name("[pick("YOU KNOW THE DRILL", "CAN YOU DIG IT?", "JOURNEY TO THE CENTER OF THE ASTEROI", "CAVE STORY", "QUARRY ON")]", "[score["oremined"]] ore mined in total this round.", min(300, score["oremined"]/15))
	//future idea: "the crew loses their chill"/"disco inferno" if most of the station is on fire, if the chef was the only survivor, "if you can't stand the heat..."
	//future idea: "the crew has a blast" if six big explosions happen, "sitting ducks" if the escape shuttle is bombed and the would-be escapees were mostly vox, "on a wing and a prayer" if the shuttle is bombed but enough people survive anyways

	var/deadcatbeastcount = 0
	for(var/mob/living/carbon/human/H in dead_mob_list)
		if(iscatbeast(H) && (H.z == map.zMainStation || istype(get_area(H), /area/shuttle/escape/centcom)))
			deadcatbeastcount++
	if(deadcatbeastcount > 10)
		episode_names += new /datum/episode_name("APOCALYPSE MEOW", "There were [deadcatbeastcount] dead catbeasts in world.", min(1000, deadcatbeastcount*50))

	for(var/mob/living/simple_animal/corgi/C in living_mob_list)
		if(C.spell_list.len > 0)
			episode_names += new /datum/episode_name("[pick("WHERE NO DOG HAS GONE BEFORE", "IAN SAYS", "IAN'S DAY OUT", "CORGI MAGIC")]", "You know what you did.", 1000)
			break

	if(emergency_shuttle.location == CENTCOMM_Z)
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

			if(score["time"] < 60 * 19) //round was shorter than 19 minutes (but shuttle still docked)
				episode_names += new /datum/episode_name("[pick("THE CAPTAIN STUBS THEIR TOE", "QUICK GETAWAY", "A MOST EFFICIENT APOCALYPSE", "ON SECOND THOUGHT, LET'S NOT GO TO [uppr_name]. 'TIS A SILLY PLACE.")]", "This round was about as short as they come.", 500)
			if(score["deadcrew"] == 0)
				episode_names += new /datum/episode_name("[pick("EMPLOYEE TRANSFER", "LIVE LONG AND PROSPER", "PEACE AND QUIET IN [uppr_name]", "THE CREW TRIES TO KILL A FLY FOR [round(score["time"]/60)] MINUTES")]", "No-one died this round.", 1000) //in practice, this one is very very very rare, so if it happens let's pick it more often
			if(score["escapees"] == 0)
				episode_names += new /datum/episode_name("[pick("DEAD SPACE", "THE CREW GOES MISSING", "LOST IN TRANSLATION", "[uppr_name]: DELETED SCENES", "WHAT HAPPENS IN [uppr_name], STAYS IN [uppr_name]", "SCOOBY-DOO, WHERE'S THE CREW?")]", "There were no escapees on the shuttle.", 200)
			if(score["escapees"] < 6 && score["escapees"] > 0 && score["deadcrew"] > score["escapees"]*2)
				episode_names += new /datum/episode_name("[pick("AND THEN THERE WERE FEWER", "THE 'FUN' IN 'FUNERAL'", "FREEDOM RIDE OR DIE", "THINGS WE LOST IN [uppr_name]", "GONE WITH [uppr_name]", "LAST TANGO IN [uppr_name]", "GET BUSY LIVING OR GET BUSY DYING", "THE CREW FUCKING DIES", "WISH YOU WERE HERE")]", "[score["deadcrew"]] people died this round.", 200)

			if(human_escapees.len == 1)
				var/shoecount = 0
				for(var/obj/item/clothing/shoes/S in shuttle) //they gotta be on the floor
					shoecount++
				if(shoecount > 5 || score["shoeshatches"] > 10)
					episode_names += new /datum/episode_name("THE SOLE SURVIVOR", "There was only one survivor in the shuttle, and they didn't forget their shoes.", 750) //I'm not sorry

			if(human_escapees.len == 1)
				var/mob/living/carbon/human/H = human_escapees[1]
				if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Chef")
					var/chance = 250
					if(istype(H.get_item_by_slot(slot_head), /obj/item/clothing/head/chefhat))
						chance += 500
					if(istype(H.get_item_by_slot(slot_wear_suit), /obj/item/clothing/suit/chef))
						chance += 500
					if(istype(H.get_item_by_slot(slot_w_uniform), /obj/item/clothing/under/rank/chef))
						chance += 250
					episode_names += new /datum/episode_name("HAIL TO THE CHEF", "The Chef was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Clown")
					var/chance = 250
					if(istype(H.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/gas/clown_hat))
						chance += 500
					if(is_type_in_list(H.get_item_by_slot(slot_shoes), list(/obj/item/clothing/shoes/clown_shoes, /obj/item/clothing/shoes/jestershoes)))
						chance += 500
					if(is_type_in_list(H.get_item_by_slot(slot_w_uniform), list(/obj/item/clothing/under/rank/clown, /obj/item/clothing/under/jester)))
						chance += 250
					episode_names += new /datum/episode_name("[pick("COME HELL OR HIGH HONKER", "THE LAST LAUGH")]", "The Clown was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Internal Affairs Agent")
					var/chance = 250
					if(locate(/obj/item/weapon/storage/briefcase) in H.held_items)
						chance += 500
					if(is_type_in_list(H.get_item_by_slot(slot_wear_suit), list(/obj/item/clothing/suit/storage/lawyer, /obj/item/clothing/suit/storage/internalaffairs)))
						chance += 500
					if(is_type_in_list(H.get_item_by_slot(slot_w_uniform), list(/obj/item/clothing/under/rank/internalaffairs, /obj/item/clothing/under/bridgeofficer, /obj/item/clothing/under/lawyer)))
						chance += 250
					episode_names += new /datum/episode_name("DEVIL'S ADVOCATE", "The IAA was the only survivor in the shuttle.", chance) //maybe DOUBLE JEOPARDY if there are only 2 surviving IAAs?
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Detective")
					var/chance = 250
					if(locate(/obj/item/weapon/gun/projectile/detective) in H.held_items)
						chance += 1000
					if(istype(H.get_item_by_slot(slot_head), /obj/item/clothing/head/det_hat))
						chance += 500
					if(is_type_in_list(H.get_item_by_slot(slot_wear_suit), list(/obj/item/clothing/suit/storage/det_suit/, /obj/item/clothing/suit/storage/forensics)))
						chance += 500
					if(istype(H.get_item_by_slot(slot_w_uniform), /obj/item/clothing/under/det))
						chance += 250
					episode_names += new /datum/episode_name("[uppertext(H.real_name)]: LOOSE CANNON", "The Detective was the only survivor in the shuttle.", chance)
				else if(!H.isUnconscious() && H.mind && H.mind.assigned_role == "Chaplain") //We don't check for uniform here because the chaplain's thing kind of is to improvise their garment gimmick
					episode_names += new /datum/episode_name("BLESS THIS MESS", "The Chaplain was the only survivor in the shuttle.", 1250)

				if(istype(H.get_item_by_slot(slot_wear_suit), /obj/item/clothing/suit/raincoat) && locate(/obj/item/weapon/fireaxe) in H.held_items)
					episode_names += new /datum/episode_name("[pick("SPACE AMERICAN PSYCHO", "NANOTRASEN PSYCHO", "[uppr_name] PSYCHO")]", "The only survivor in the shuttle wore a raincoat and held a fireaxe.", 1500)
				if(istype(H.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/luchador) && istype(H.get_item_by_slot(slot_gloves), /obj/item/clothing/gloves/boxing))
					episode_names += new /datum/episode_name("[pick("THE CREW, ON THE ROPES", "THE CREW, DOWN FOR THE COUNT", "[uppr_name], DOWN AND OUT")]", "The only survivor in the shuttle wore a luchador mask and boxing gloves.", 1500)

			var/braindamage_total = 0
			var/all_retarded = TRUE
			for(var/mob/living/carbon/human/H in human_escapees)
				if(H.brainloss < 60)
					all_retarded = FALSE
				braindamage_total += H.brainloss
			var/average_braindamage = braindamage_total / human_escapees.len
			if(average_braindamage > 30)
				episode_names += new /datum/episode_name("[pick("THE CREW'S SMALL IQ PROBLEM", "OW! MY BALLS", "BR[pick("AI", "IA")]N DAMAGE", "THE VERY SPECIAL CREW OF [uppr_name]")]", "Average of [average_braindamage] brain damage for each human shuttle escapee.", min(1000, average_braindamage*10))
			if(all_retarded)
				episode_names += new /datum/episode_name("...AND PRAY THERE'S INTELLIGENT LIFE SOMEWHERE OUT IN SPACE, 'CAUSE THERE'S BUGGER ALL DOWN HERE IN [uppr_name]", "Everyone was retarded this round.", 1500)

			var/clowncount = 0
			var/mimecount = 0
			var/assistantcount = 0
			var/chefcount = 0
			var/chaplaincount = 0
			var/skeletoncount = 0
			var/voxcount = 0
			var/dionacount = 0
			var/baldycount = 0
			var/fattycount = 0
			var/horsecount = 0
			var/piggycount = 0
			for(var/mob/living/carbon/human/H in human_escapees)
				if(H.mind && H.mind.miming)
					mimecount++
				if(is_type_in_list(H.get_item_by_slot(slot_wear_mask), list(/obj/item/clothing/mask/gas/clown_hat, /obj/item/clothing/mask/gas/sexyclown)) || (H.mind && H.mind.assigned_role == "Clown"))
					clowncount++
				if(istype(H.get_item_by_slot(slot_w_uniform), /obj/item/clothing/under/color/grey) || (H.mind && H.mind.assigned_role == "Assistant"))
					assistantcount++
				if(istype(H.get_item_by_slot(slot_head), /obj/item/clothing/head/chefhat) || (H.mind && H.mind.assigned_role == "Chef"))
					chefcount++
				if(H.mind && H.mind.assigned_role == "Chaplain")
					chaplaincount++
					if(ischangeling(H))
						episode_names += new /datum/episode_name("[uppertext(H.real_name)]: A BLESSING IN DISGUISE", "The Chaplain, [H.real_name], was a changeling and escaped alive.", 750)
				if(isskellington(H) || isplasmaman(H) || isskelevox(H))
					skeletoncount++
				if(isvox(H) || isskelevox(H))
					voxcount++
				if(isdiona(H))
					dionacount++
				if(isjusthuman(H) && (H.h_style == "Bald" || H.h_style == "Skinhead") && !H.check_body_part_coverage(HEAD))
					baldycount++
				if(M_FAT in H.mutations)
					fattycount++
				if(istype(H.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/horsehead))
					horsecount++
				if(istype(H.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/pig))
					piggycount++
			if(clowncount > 3)
				episode_names += new /datum/episode_name("CLOWNS GALORE", "There were [clowncount] clowns on the shuttle.", min(1500, clowncount*200))
			if(mimecount > 3)
				episode_names += new /datum/episode_name("THE SILENT SHUFFLE", "There were [mimecount] mimes on the shuttle.", min(1500, mimecount*200))
			if(chaplaincount > 2)
				episode_names += new /datum/episode_name("COUNT YOUR BLESSINGS", "There were [chaplaincount] chaplains on the shuttle. Like, the real deal, not just clothes.", min(1500, chaplaincount*450))
			if(chefcount > 2)
				episode_names += new /datum/episode_name("<span style='color: rgb(230, 209, 64); font-family: Georgia, serif; font-variant: small-caps; font-style: italic; font-weight: 400; font-size: 175%; text-shadow: rgb(123, 96, 38) 1.5px 1.5px 0px, rgb(123, 96, 38) 1.5px 1.5px 0.1px;'>Too Many Cooks</span>", "There were [chefcount] chefs on the shuttle.", min(1500, chefcount*450)) //intentionally not capitalized
			if(assistantcount / human_escapees > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name("[pick("GREY GOO", "RISE OF THE GREYTIDE")]", "Most of the survivors were Assistants, or at least dressed like one.", min(1500, assistantcount*200))
			if(skeletoncount / human_escapees > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name("SKELETON CREW", "Most of the survivors were literal skeletons.", min(1500, skeletoncount*200))
			if(voxcount / human_escapees > 0.6)
				episode_names += new /datum/episode_name("BIRDS OF A FEATHER...", "Most of the survivors were Vox.", min(1500, voxcount*200))
			if(dionacount / human_escapees > 0.6)
				episode_names += new /datum/episode_name("[pick("ALL BARK AND NO BITE", "THE CREW GETS STUMPED")]", "Most of the survivors were Diona.", min(1500, dionacount*200))
			if(baldycount / human_escapees > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name("TO BALDLY GO", "Most of the survivors were bald, and it shows.", min(1500, baldycount*200))
			if(fattycount / human_escapees > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name("[pick("THE GREAT FATSBY", "THE CREW NEEDS TO LIGHTEN UP", "THE CREW PUTS ON WEIGHT", "THE FOUR CHIN CREW")]", "Most of the survivors were fat.", min(1500, fattycount*200))
			if(horsecount / human_escapees > 0.6 && human_escapees.len > 3)
				episode_names += new /datum/episode_name("STRAIGHT FROM THE HORSE'S MOUTH", "Most of the survivors wore horse heads.", min(1500, horsecount*200))

			var/bearcount = 0
			for(var/mob/living/simple_animal/hostile/bear/B in shuttle)
				bearcount += 1
			if(bearcount > 3)
				episode_names += new /datum/episode_name("BEARS REPEATING", "There were [bearcount] bears on the shuttle.", min(1000, bearcount*100))

			for(var/mob/living/simple_animal/hostile/retaliate/box/B in shuttle)
				piggycount += 1
			if(piggycount > 3)
				episode_names += new /datum/episode_name("BRINGING HOME THE BACON", "[piggycount] little piggies went to the shuttle...", min(1000, piggycount*100))

			var/beecount = 0
			for(var/mob/living/simple_animal/bee/B in shuttle)
				beecount += B.bees.len
			if(beecount > 15)
				episode_names += new /datum/episode_name("FLIGHT OF THE BUMBLEBEES", "There were [beecount] bees on the shuttle.", min(1500, beecount*25))
				if(voxcount / human_escapees > 0.6)
					episode_names += new /datum/episode_name("THE BIRD[human_escapees.len == 1 ? "" : "S"] AND THE BEES", "There were [beecount] bees on the shuttle, and most or all of the survivors were Vox.", min(2500, beecount*40 + voxcount*500))

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
					if(isweeaboo(M))
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

					episode_names += new /datum/episode_name(final_string, "Thanks to the Staff of Change, we had quite a diverse shuttle.", 1500)
