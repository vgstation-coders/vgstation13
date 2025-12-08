/datum/story_theme/syndicate
	name = "syndicate"
	theme_flag = STORY_SYNDICATE
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/humanoid/syndicate/melee,
		/mob/living/simple_animal/hostile/humanoid/syndicate/ranged
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/syndicatesoldier,
		/obj/effect/landmark/corpse/syndicatecommando
	)

/datum/story_theme/syndicate/generate_character_name()
	if(first_names_male?.len && last_names?.len)
		var/first = pick(prob(50) ? first_names_male : first_names_female)
		character_name = "Agent [first] [pick(last_names)]"
	else
		character_name = "Agent Unknown"
	return character_name

/datum/story_theme/syndicate/get_log_info()
	return list("title" = "SYNDICATE FIELD REPORT", "subtitle" = "Agent: [character_name] - CLASSIFIED")

/datum/story_theme/syndicate/get_generic_entries()
	return list(
		"Agent [character_name], Syndicate Intelligence Division, commencing reconnaissance on '[planet_name]'. Nanotrasen presence minimal. Perfect conditions for asset acquisition.",
		"Located abandoned NT research facility. Corporate fools left everything behind. Their [tech_name] research will serve the Syndicate well.",
		"Establishing dead drop protocols. If this location is compromised, central command must know what we found here.",
		"NT security protocols are a joke. Bypassed their encryption in under a minute. Accessing [tech_name] project files now.",
		"Recovered significant intelligence on [tech_name]. This data alone is worth the risk of this deep cover operation.",
		"Perimeter check complete. No NT patrols. No automated defenses. Either they abandoned this place in a hurry, or it's a trap.",
		"Found personal logs from NT researchers. Seems they encountered something unexpected. Their loss, our gain.",
		"Uploading data packet to dead drop satellite. Syndicate Command will want to see this [tech_name] research immediately.",
		"Local wildlife is more dangerous than briefed. Lost some equipment to a predator attack. Adjusting patrol routes.",
		"Discovered evidence of prior Syndicate operations in this sector. Old gear, outdated codes. We weren't the first here.",
		"NT may have abandoned this facility, but their automated systems are still partially online. Proceeding with caution.",
		"Agent [character_name] reporting: mission objectives 80% complete. Awaiting extraction window.",
		"Something's wrong. Motion sensors triggered but nothing visible. Could be fauna. Could be something else.",
		"Final transmission. Data secured. If extraction fails, this terminal will contain everything the Syndicate needs to know about '[planet_name]'.",
		"Corporate dogs left their research unguarded. Typical NT arrogance. They'll regret this oversight.",
		"Intercepted old NT distress signals from this facility. Whatever happened here, it happened fast.",
		"The [tech_name] data is more valuable than initial estimates. Recommending increased priority for this sector.",
		"Shelter in place for now. Atmospheric conditions deteriorating. Will resume operations when weather clears.",
		"Found remnants of NT defensive positions. Bullet casings, blast marks. Someone put up a fight here.",
		"Asset acquisition successful. Multiple data cores recovered. The Syndicate's R&D division will have a field day.",
		"Cover identity compromised? Unknown. Taking precautions. Encrypted all local files, prepared evacuation routes.",
		"This planet has strategic value beyond the research data. Forwarding coordinates to Syndicate colonial division."
	)

/datum/story_theme/syndicate/get_weather_entries()
	var/list/entries = list()
	switch(planet_style)
		if("lava planet")
			entries += "Thermal conditions extreme. NT chose this location for natural security. Joke's on them - it also isolated their research."
			entries += "Volcanic activity provides cover for energy signatures. The Syndicate should consider similar locations."
		if("frozen planet")
			entries += "Arctic environment. Thermal signature management critical. Operating during blizzards for maximum concealment."
			entries += "Cold preserves evidence. Need thorough cleanup before extraction. Leave nothing for NT forensics."
		if("desert planet")
			entries += "Arid conditions. Water discipline essential. NT left survival caches - they're mine now."
			entries += "Sandstorms create excellent cover for movement. Adapting schedule to weather patterns."
		if("jungle planet")
			entries += "Dense vegetation provides natural concealment. Optimal environment for covert operations."
			entries += "Humidity affecting equipment. Implementing field maintenance protocols. The data must not be compromised."
		if("wasteland planet")
			entries += "Post-catastrophe environment. Radiation provides natural deterrent to casual visitors. Good for our purposes."
			entries += "Whatever destroyed this place, it wasn't us. But we'll gladly pick through the remains."
		if("beach planet")
			entries += "Coastal environment. Multiple approach and extraction vectors. The Syndicate should establish a safehouse here."
			entries += "Open terrain complicates daylight operations. Working primarily at night."
		if("grass planet")
			entries += "Temperate conditions. Standard operating procedures apply. Almost too easy."
			entries += "NT chose this world for colonization potential. They won't be colonizing it now."
		if("unknown planet")
			entries += "Environmental anomalies concerning. Sensors unreliable. Proceeding with manual observation protocols."
			entries += "Something about this planet isn't right. The data better be worth this assignment."
	return entries

/datum/story_theme/syndicate/get_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("bunker")
			entries += "Fortified position. NT built this for long-term occupation. They failed. We won't make their mistakes."
			entries += "The bunker's security was decent. Was. Syndicate training trumps corporate paranoia."
		if("cabin")
			entries += "Small structure, minimal footprint. Good for observation post. Establishing long-term surveillance capability."
			entries += "Cabin shows signs of hasty departure. They knew something was coming. Or thought they did."
		if("listening post")
			entries += "Communications facility. Jackpot. Accessing all stored transmissions. NT internal communications are laughably insecure."
			entries += "This listening post was monitoring Syndicate frequencies. Now it monitors NT. Poetic justice."
		if("camp")
			entries += "Field camp. Temporary but functional. NT expedition was underequipped for this environment. Amateurs."
			entries += "The camp tells a story. Professionals would have done better. Corporate researchers aren't soldiers."
		if("workshop")
			entries += "Technical facility. Tools for equipment modification. Could be useful for sabotage preparation."
			entries += "The workshop contains prototypes. NT was testing [tech_name] applications here. Now we'll test them."
		if("outpost")
			entries += "Defensive position. NT tried to secure this sector. Their failure is our opportunity."
			entries += "The outpost's communications logs reveal much about NT operations in this region. Intelligence goldmine."
	return entries

/datum/story_theme/syndicate/get_fauna_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Marine predators present. Avoiding water approach vectors. Land extraction preferred."
		if("desert planet")
			entries += "Large burrowing creatures. Seismic sensors detect approach. Useful for perimeter security."
		if("frozen planet")
			entries += "Pack predators tracking my movements. Eliminated the alpha. Pack dispersed. Problem solved."
		if("grass planet")
			entries += "Local fauna generally non-threatening. A few exceptions handled with prejudice."
		if("jungle planet")
			entries += "Apex predators everywhere. This jungle is a combat zone. Appropriate, really."
		if("lava planet")
			entries += "Heat-adapted creatures. Even the wildlife here is aggressive. NT researchers didn't stand a chance."
		if("wasteland planet")
			entries += "Mutated creatures. Radiation hasn't made them friendly. Lethal force authorized and applied."
		if("unknown planet")
			entries += "Unknown fauna displaying unusual behavior. Cannot predict threat patterns. Maintaining maximum alert."
	return entries

/datum/story_theme/syndicate/get_loot_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Recovered supplies include recreational items. NT sends their people to work in comfort. Soft."
		if("desert planet")
			entries += "Technical equipment recovered. Desert preservation kept everything functional. Excellent salvage."
		if("frozen planet")
			entries += "Cold storage preserved sensitive materials. Including biological samples. R&D will be interested."
		if("grass planet")
			entries += "Standard corporate supplies. Nothing unexpected. Everything catalogued for extraction."
		if("jungle planet")
			entries += "Environmental damage to supplies. Sealed containers yielded priority items. The rest is contaminated."
		if("lava planet")
			entries += "Heat-sealed containers protected high-value materials. NT's paranoia served us well."
		if("wasteland planet")
			entries += "Military-grade equipment recovered. NT was prepared for conflict. Just not the right conflict."
		if("unknown planet")
			entries += "Unusual artifacts present. Cannot identify all items. Sending samples to Syndicate labs for analysis."
	return entries

/datum/story_theme/syndicate/get_main_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("Geode")
			entries += "Natural crystal formation of significant size. Potential value for Syndicate R&D - certain crystals have weapons applications. Marking for extraction team."
			entries += "The geode structure isn't NT construction, but they probably surveyed it. Checking for any monitoring equipment they left behind."
			entries += "Crystal samples secured. Syndicate materials division will determine if these have military or economic value. Either works."
		if("Crashed Tradeship")
			entries += "Commercial vessel wreckage. Scanned for NT markings - negative. Independent trader. Cargo may contain useful supplies or intelligence."
			entries += "The tradeship's manifest suggests routine commerce. But independent traders sometimes carry things they shouldn't. Thorough search warranted."
			entries += "Salvaged the ship's communications logs. Even mundane traffic can reveal NT patrol routes, station schedules. Intelligence is where you find it."
		if("Crashed Pod")
			entries += "Escape pod, single occupant configuration. Could be NT personnel who escaped something. Could be evidence of something we should know about."
			entries += "The pod's transponder data is corrupted. Deliberate? Accidental? Either way, someone didn't want to be found. Interesting."
			entries += "Occupant deceased. Personal effects suggest civilian background, not corporate. Wrong place, wrong time. Happens in this line of work."
		if("Abandoned Digsite")
			entries += "Mining operation, abandoned. NT or independent? Equipment markings removed - someone wanted to hide their involvement. Red flag."
			entries += "The digsite's depth suggests they found something significant. Then left in a hurry. What did they dig up? What dug back?"
			entries += "Geological survey data recovered from the site. Whatever they were extracting, it wasn't standard ore. Flagging for Syndicate analysts."
		if("Alien Hive")
			entries += "Xenomorph presence confirmed. Useful information - NT won't colonize this sector with a hive nearby. Natural deterrent for corporate expansion."
			entries += "The hive changes our tactical situation. Syndicate bioweapons division has standing orders regarding xenomorph samples. Risk assessment: extreme."
			entries += "Maintaining distance from the infestation. Even Syndicate operatives have limits. This is a job for specialists with hazard pay."
		if("The Buried Bar")
			entries += "Underground recreational facility. Previous occupants knew how to live. Checked for hidden compartments - miners often stash contraband."
			entries += "The bar's patron records are partially intact. Cross-referencing with known NT personnel databases. You never know who might turn up."
			entries += "Useful location for a dead drop or safehouse. Filing coordinates for potential future operations. The Syndicate can always use more bolt holes."
		if("Cult Base")
			entries += "Occult activity detected. Syndicate has no official position on supernatural matters. Unofficially? Some things are useful. Others are dangerous."
			entries += "The cult's methodology is crude but their results suggest genuine anomalous phenomena. Artifacts secured for specialist evaluation."
			entries += "Ritual components catalogued. Some Syndicate departments have... unconventional research interests. This material may have value to the right people."
	return entries

/datum/story_theme/syndicate/get_stashed_loot_entries()
	var/list/entries = list()
	switch(stashed_loot_type)
		if(/datum/loot_table/weighted/bureaucracy)
			entries += "NT documentation secured. Administrative materials may contain access codes or personnel data."
			entries += "Corporate paperwork stashed. Intelligence analysis will determine value. Every detail matters."
		if(/datum/loot_table/weighted/combat)
			entries += "Weapons cache established per Syndicate field protocol. Always maintain secondary armament."
			entries += "Combat supplies secured. NT equipment can supplement our own. Their quality is adequate."
		if(/datum/loot_table/decoration)
			entries += "Personal effects catalogued. May be useful for deep cover operations. Know your enemy."
			entries += "Non-essential items secured. Cover identities sometimes require props. Planning ahead."
		if(/datum/loot_table/engineering)
			entries += "Technical supplies cached. Field repairs are inevitable. Self-sufficiency is doctrine."
			entries += "Engineering equipment secured. NT tools serve Syndicate purposes just as well."
		if(/datum/loot_table/entertainment)
			entries += "Recreational items secured. Extended deep cover requires stress management. Practical consideration."
			entries += "Entertainment stashed. Even agents need downtime. Burnout compromises operations."
		if(/datum/loot_table/weighted/exotic)
			entries += "Unusual materials secured for Syndicate R&D. Could be valuable. Could be dangerous. Both useful."
			entries += "Exotic artifacts cached. The corporation's scientists will determine their potential."
		if(/datum/loot_table/weighted/medical)
			entries += "Medical supplies secured. Operational casualties are unacceptable. Prevention is preferred."
			entries += "First aid cache established. Wounded agents are compromised agents. Stay healthy."
		if(/datum/loot_table/module)
			entries += "AI modules secured. Potential applications for intelligence or countermeasures. Flagged for tech division."
			entries += "Electronic components cached. Syndicate hackers can always use more hardware."
		if(/datum/loot_table/weighted/structure)
			entries += "Construction materials secured. May need to establish long-term presence."
			entries += "Building supplies stashed. Fortification options are worth preserving."
		if(/datum/loot_table/trash)
			entries += "Even NT garbage analyzed for intelligence value. Sorted and relevant materials cached."
			entries += "Refuse processed per standard protocol. Nothing escapes Syndicate attention."
	return entries

/datum/story_theme/syndicate/get_disease_entry(var/disease_form)
	var/list/entries = list()
	switch(disease_form)
		if("Virus")
			entries = list(
				"Viral infection detected. Syndicate field medicine deployed. Operational capacity reduced but mission continues.",
				"The virus is aggressive. NT biological research notes mention nothing about this strain. Natural or engineered?",
				"Fever compromising operational security. Reaction time degraded. Adjusting mission parameters to compensate.",
				"If this is a Nanotrasen bioweapon, it's effective. If it's natural, this planet is more dangerous than briefed."
			)
		if("Bacteria")
			entries = list(
				"Wound infection despite field treatment. Syndicate medical supplies insufficient for this strain.",
				"Bacterial contamination spreading. The corporation's abandoned research didn't mention local pathogens. Oversight or deliberate omission?",
				"Infection progressing. Pain is manageable. The mission is not. Requesting emergency extraction protocols.",
				"Sepsis risk increasing. Syndicate training covers operating wounded. This is... beyond that training."
			)
		if("Parasite")
			entries = list(
				"Parasitic organism contracted from local fauna or water supply. Intelligence failure on environmental hazards.",
				"The parasite is affecting combat readiness. Nutrient absorption compromised. This was not in the briefing materials.",
				"Internal scans confirm infestation. Syndicate medical protocols recommend surgical extraction. Equipment unavailable.",
				"The creature grows while I weaken. Poetic, perhaps. The corporation's research here suddenly seems more relevant."
			)
		if("Prion")
			entries = list(
				"Cognitive function deteriorating. Memory of mission parameters... fragmenting. This is wrong.",
				"Syndicate conditioning should protect against mental degradation. It's not. Something is attacking my mind directly.",
				"Mission... what was the mission? The data. Yes. Upload the data. Before... before I forget why.",
				"If this log reaches Command, know that the agent's mind failed before the agent did. The disease is in my thoughts."
			)
		if("Fungus")
			entries = list(
				"Fungal infection established despite decontamination protocols. Local strain shows unusual aggression.",
				"The spores have spread to respiratory system. Filtration mask inadequate. Syndicate R&D should note this strain.",
				"Mycelium visible on exposed skin. Attempted removal caused accelerated growth. Changing tactics to containment.",
				"The fungus is spreading faster than projected. This planet's ecology is more hostile than any NT security system."
			)
		else
			entries = list(
				"Unknown pathogen affecting system performance. Does not match any Syndicate medical database entries.",
				"Illness progressing. Etiology unknown. If this is NT's doing, they've created something new. If not, this planet did.",
				"Operational capacity at 60% and declining. The mission may need to be aborted. Or the operative may need to be.",
				"Syndicate does not leave agents behind. But Syndicate also does not tolerate mission failure. The math is simple."
			)
	return pick(entries)
