/datum/story_theme/commando
	name = "commando"
	theme_flag = STORY_COMMANDO
	hostile_mobs = list()
	corpse_types = list(
		/obj/effect/landmark/corpse/ertleader
	)

/datum/story_theme/commando/generate_character_name()
	if(commando_names?.len)
		character_name = "Commander [pick(commando_names)]"
	else
		character_name = "Commander Unknown"
	return character_name

/datum/story_theme/commando/generate_secondary_character_name()
	if(commando_names?.len)
		secondary_character_name = pick(commando_names)
	else
		secondary_character_name = "Bravo"
	return secondary_character_name

/datum/story_theme/commando/get_log_info()
	return list("title" = "NT SQUAD RECONNAISSANCE", "subtitle" = "Mission: SILENT HORIZON")

/datum/story_theme/commando/get_generic_entries()
	if(!secondary_character_name)
		generate_secondary_character_name()

	return list(
		"Commander [character_name] reporting. Squad deployed to [planet_name] for colonization viability assessment. Perimeter secured. [secondary_character_name] establishing forward observation post.",
		"Hostile fauna neutralized in sectors 4 through 7. Acceptable losses: zero. This planet has teeth, but nothing our equipment can't handle.",
		"Located pre-existing research installation. Previous occupants: unknown, presumed dead. Recovered [tech_name] data. Could provide significant advantage for NT's expansion efforts.",
		"Fortified position established. Standard defensive protocols in effect. [secondary_character_name] reports all clear on eastern approach.",
		"Resource survey complete. Mineral deposits exceed projections. Recommend priority classification for extraction operations.",
		"Encountered resistance from indigenous lifeforms. Threat level: moderate. Eliminated with extreme prejudice. Area secured.",
		"Communications relay established. Signal strength nominal. Central Command acknowledges receipt of preliminary data.",
		"[secondary_character_name] identified potential colony site in grid reference 7-Alpha. Defensible position with water access. Marking for Phase 2 assessment.",
		"Weather patterns on this rock are brutal. Equipment holding up. Personnel maintaining combat readiness despite conditions.",
		"Discovered [tech_name] research facility. Corporate will want this data. Archiving for transport.",
		"Sweep complete. No surviving hostiles. This sector is clear. Recommend immediate colonist deployment.",
		"Contact lost with [secondary_character_name]. Search and rescue operation failed. Whatever took them wasn't wildlife. Uploading final assessment: DO NOT COLONIZE.",
		"Mission complete. Planet [planet_name] approved for Phase 2 colonization assessment. Recommending armed escort for civilian teams.",
		"This is Commander [character_name], signing off. Job done. Ready for extraction. Send the civvies - we've done the hard work.",
		"Ammunition expenditure within acceptable parameters. [secondary_character_name] is maintaining a kill count. Current tally: 47 hostiles.",
		"Established defensive killzones at all approach vectors. If anything gets through, it'll be walking into a wall of lead.",
		"Intel suggests previous team went dark here. Found their camp. Whatever hit them, hit hard and fast. We're ready for it.",
		"[secondary_character_name] wanted to name the largest hostile we killed. I reminded them we're professionals, not trophy hunters. Mostly.",
		"Night vision capabilities tested against local conditions. Visibility optimal. Nothing moves here without us knowing.",
		"Extracted samples of local toxins for R&D. Could have military applications. Corporate loves their chemical weapons research.",
		"Secondary objective complete. [tech_name] data secured. Primary objective: establish beachhead. Status: GREEN.",
		"The silence after a firefight never gets old. [secondary_character_name] is running diagnostics. I'm writing this. The work continues."
	)

/datum/story_theme/commando/get_weather_entries()
	var/list/entries = list()
	switch(planet_style)
		if("lava planet")
			entries += "Heat is relentless. [secondary_character_name] is monitoring suit integrity. Combat effectiveness maintained despite conditions."
			entries += "Volcanic activity provides natural barriers. Updating tactical maps to reflect terrain changes."
		if("frozen planet")
			entries += "Arctic conditions. Equipment performing within specifications. [secondary_character_name] established heated shelters at checkpoint bravo."
			entries += "Ice storms limiting visibility. Holding position until weather clears. Not a problem - we're patient."
		if("desert planet")
			entries += "Sand getting into everything. [secondary_character_name] is field-stripping weapons twice daily. Operational efficiency maintained."
			entries += "Water rationing in effect. This rock is trying to kill us slowly. It'll have to try harder."
		if("jungle planet")
			entries += "Jungle provides natural concealment. Working in our favor. [secondary_character_name] established observation posts in the canopy."
			entries += "Humidity is brutal. Equipment maintenance schedule doubled. We adapt and overcome."
		if("wasteland planet")
			entries += "Radiation levels elevated but manageable. Dosimeters distributed to all personnel."
			entries += "This place died hard. Good defensive terrain in the ruins though. [secondary_character_name] approves."
		if("beach planet")
			entries += "Coastal environment complicating logistics. [secondary_character_name] established supply routes inland."
			entries += "Tides creating scheduling challenges. Adapting patrol patterns accordingly."
		if("grass planet")
			entries += "Open terrain. Good sightlines but limited cover. Establishing camouflaged positions."
			entries += "Climate favorable for extended operations. [secondary_character_name] calls it 'vacation duty'. I reminded them we're working."
		if("unknown planet")
			entries += "Environmental readings inconsistent. [secondary_character_name] suggests equipment malfunction. I think this planet is wrong."
			entries += "Proceeding with standard protocols despite anomalous conditions. We've handled worse."
	return entries

/datum/story_theme/commando/get_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("bunker")
			entries += "Fortified position. [secondary_character_name] approves of the construction. Making this our forward operating base."
			entries += "Bunker secure. Defensive capabilities exceed requirements. This is where we make our stand if needed."
		if("cabin")
			entries += "Basic structure. Not ideal for defensive purposes but adequate shelter. [secondary_character_name] reinforcing weak points."
			entries += "Cabin secured. Establishing rotating watch. Nobody gets the drop on us."
		if("listening post")
			entries += "Communications equipment operational. [secondary_character_name] monitoring all frequencies. Intel value: high."
			entries += "This position gives us ears on the entire sector. Exactly what we needed."
		if("outpost")
			entries += "Outpost defensible with modifications. [secondary_character_name] implementing standard security protocols."
			entries += "Fortifications complete. This position can hold against significant hostile force."
		if("camp")
			entries += "Field camp established. Not pretty but functional. [secondary_character_name] has perimeter security locked down."
			entries += "Camp operational. All approaches covered. Let them come."
		if("workshop")
			entries += "Workshop provides maintenance capabilities. [secondary_character_name] inventorying available resources."
			entries += "Repair bay operational. Can keep our gear running indefinitely with what's here."
	return entries

/datum/story_theme/commando/get_fauna_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Aquatic predators identified. [secondary_character_name] establishing water approach defenses. Threat: moderate."
		if("desert planet")
			entries += "Large burrowing creatures detected on seismic. [secondary_character_name] recommends anti-armor rounds. Agreed."
		if("frozen planet")
			entries += "Pack predators hunting in coordinated groups. [secondary_character_name] studying their tactics. Know your enemy."
		if("grass planet")
			entries += "Hostile fauna sporadic. Nothing we can't handle. [secondary_character_name] maintaining kill ratio."
		if("jungle planet")
			entries += "Apex predators present. [secondary_character_name] eliminated two specimens. The jungle learned to respect us."
		if("lava planet")
			entries += "Heat-resistant megafauna. Heavy weapons required. [secondary_character_name] and I took down a big one together."
		if("wasteland planet")
			entries += "Mutated creatures everywhere. Aggressive but disorganized. Systematic extermination proceeding."
		if("unknown planet")
			entries += "Unknown creature classifications. [secondary_character_name] cataloguing for combat analysis. Shoot first, classify later."
	return entries

/datum/story_theme/commando/get_loot_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Supplies recovered. [secondary_character_name] inventorying for operational value. Rations are... creative."
		if("desert planet")
			entries += "Technical equipment salvaged. [secondary_character_name] field-testing for reliability."
		if("frozen planet")
			entries += "Cold weather supplies acquired. [secondary_character_name] distributing to team. Good kit."
		if("grass planet")
			entries += "Standard supplies. Nothing exciting but [secondary_character_name] isn't complaining. Much."
		if("jungle planet")
			entries += "Most supplies compromised by environment. [secondary_character_name] salvaging what's viable."
		if("lava planet")
			entries += "Heat-resistant containers yielded useful tech. [secondary_character_name] impressed. That's rare."
		if("wasteland planet")
			entries += "Military salvage present. [secondary_character_name] evaluating compatibility with our gear."
		if("unknown planet")
			entries += "Unusual artifacts recovered. [secondary_character_name] handling with caution. Could be weapons. Could be junk."
	return entries

/datum/story_theme/commando/get_main_ruin_entries()
	if(!secondary_character_name)
		generate_secondary_character_name()

	var/list/entries = list()
	switch(ruin_name)
		if("Geode")
			entries += "Natural crystal formation. [secondary_character_name] sees no tactical value. Pretty rocks don't stop bullets. Marking as non-priority."
			entries += "The geode provides potential defensive position - good cover, limited approaches. [secondary_character_name] noted fallback coordinates."
			entries += "Crystal samples collected for NT geological survey. [secondary_character_name] says they might be valuable. Not our department."
		if("Crashed Tradeship")
			entries += "Vessel wreckage, civilian configuration. [secondary_character_name] cleared the site. No survivors, no hostiles. Salvage potential assessed."
			entries += "The tradeship went down hard. [secondary_character_name] recovered the flight recorder. Intel division can determine what happened."
			entries += "Cargo containers breached. [secondary_character_name] inventoried recoverable supplies. Mostly commercial goods. Some ammunition. We'll take the ammunition."
		if("Crashed Pod")
			entries += "Emergency escape pod. [secondary_character_name] confirmed single casualty, civilian. Logged for NT records. Moving on."
			entries += "The pod's beacon was still active. [secondary_character_name] disabled it. Don't need it attracting attention to our operation."
			entries += "Personal effects recovered, tagged for return to NT. [secondary_character_name] says it's protocol. We follow protocol."
		if("Abandoned Digsite")
			entries += "Mining operation, abandoned. [secondary_character_name] swept for booby traps - negative. Whoever left didn't expect anyone to follow."
			entries += "Tunnels provide potential underground movement routes. [secondary_character_name] is mapping the network. Could be tactically useful."
			entries += "Heavy equipment left behind. [secondary_character_name] assessed for conversion to defensive emplacements. Some potential."
		if("Alien Hive")
			entries += "XENO PRESENCE CONFIRMED. [secondary_character_name] and I agree - recommend orbital strike on this sector. Colony assessment: NEGATIVE."
			entries += "The hive is dug in deep. Full eradication would require resources beyond our squad's capability. Flagging for Central Command."
			entries += "[secondary_character_name] lost a scout drone to the perimeter. Those things are fast. And smart. And hungry. Adjusting patrol routes."
		if("The Buried Bar")
			entries += "Subterranean structure, recreational purpose. [secondary_character_name] cleared it. Abandoned, but well-preserved. Potential R&R location."
			entries += "The bar's layout offers good defensive angles. [secondary_character_name] noted it as potential backup rally point if primary position is compromised."
			entries += "[secondary_character_name] found the liquor cabinet intact. I reminded them we're on duty. They reminded me there's nobody to report us. ...one drink."
		if("Cult Base")
			entries += "Structure shows signs of cult activity. [secondary_character_name] and I breached and cleared. Site is now secure. Contents are... disturbing."
			entries += "Whatever was practiced here, it wasn't sanctioned. [secondary_character_name] documented everything. Leaving recommendations for sterilization protocols."
			entries += "Recovered ritual objects for NT analysis. [secondary_character_name] handled them with gloves. Smart. Some things you don't want touching skin."
	return entries

/datum/story_theme/commando/get_stashed_loot_entries()
	var/list/entries = list()
	switch(stashed_loot_type)
		if(/datum/loot_table/weighted/bureaucracy)
			entries += "[secondary_character_name] secured documentation for intel review. Could contain useful operational data."
			entries += "Administrative supplies cached. Even commandos need to file reports. Unfortunately."
		if(/datum/loot_table/weighted/combat)
			entries += "Weapons cache established. [secondary_character_name] approved the selection. We're ready for anything."
			entries += "Combat supplies secured at secondary position. Standard operational protocol. Always have backup."
		if(/datum/loot_table/decoration)
			entries += "[secondary_character_name] stashed some personal items. Said something about morale. Fair enough."
			entries += "Non-essential supplies cached. [secondary_character_name] insisted. We might be here a while."
		if(/datum/loot_table/engineering)
			entries += "Technical supplies secured. [secondary_character_name] can fix anything with this kit."
			entries += "Maintenance equipment cached. Can't complete the mission with broken gear."
		if(/datum/loot_table/entertainment)
			entries += "[secondary_character_name] found rec supplies. Cards, games, time-killers. Good for watch rotation downtime."
			entries += "Entertainment cached for off-duty hours. Even Death Squad needs to decompress."
		if(/datum/loot_table/weighted/exotic)
			entries += "Unusual materials secured for Central Command review. [secondary_character_name] doesn't know what half of it is."
			entries += "Exotic items cached. Could be valuable intel. Could be worthless alien junk. Above our pay grade."
		if(/datum/loot_table/weighted/medical)
			entries += "Medical supplies secured. [secondary_character_name] verified the contents. Combat-ready first aid."
			entries += "Casualty treatment supplies cached. Plan for the worst. [secondary_character_name] knows the drill."
		if(/datum/loot_table/module)
			entries += "Electronic systems secured. [secondary_character_name] thinks they have tactical applications."
			entries += "AI modules cached for tech division. Above our expertise, but clearly valuable."
		if(/datum/loot_table/weighted/structure)
			entries += "[secondary_character_name] organized construction supplies. Could fortify this position further."
			entries += "Building materials secured. Might need to establish a more permanent base."
		if(/datum/loot_table/trash)
			entries += "[secondary_character_name] sorted the salvage. Some of it might be useful. Most of it won't."
			entries += "Even the junk pile got processed. Death Squad doesn't leave resources behind."
	return entries

/datum/story_theme/commando/get_disease_entry(var/disease_form)
	if(!secondary_character_name)
		generate_secondary_character_name()

	var/list/entries = list()
	switch(disease_form)
		if("Virus")
			entries = list(
				"Viral infection confirmed. [secondary_character_name] administered field treatment. Maintaining combat readiness despite fever.",
				"The virus is hitting the squad hard. [secondary_character_name] and I are both symptomatic. Mission continues regardless.",
				"Central Command didn't warn us about local pathogens. Noted for after-action report. If we survive to file one.",
				"[secondary_character_name] says the virus matches nothing in our medical database. First contact situation. Just our luck."
			)
		if("Bacteria")
			entries = list(
				"Wound infection from hostile contact. [secondary_character_name] cleaned it, but the bacteria here are aggressive.",
				"Bacterial infection spreading despite treatment. [secondary_character_name] is rationing antibiotics. We may not have enough.",
				"The infection is slowing me down. [secondary_character_name] offered to take point. Denied. Commanders lead from the front.",
				"Sepsis risk elevated. [secondary_character_name] knows field surgery. Hoping it won't come to that."
			)
		if("Parasite")
			entries = list(
				"Contracted a parasite from local fauna. [secondary_character_name] is monitoring symptoms. Combat effectiveness maintained. For now.",
				"The parasite is affecting appetite and energy levels. [secondary_character_name] adjusted ration distribution accordingly.",
				"Internal hostile confirmed. [secondary_character_name] says extraction requires equipment we don't have. Fighting on two fronts now.",
				"[secondary_character_name] offered to attempt field surgery. The cure might be worse than the disease. Declined for now."
			)
		if("Prion")
			entries = list(
				"Something's wrong with my head. Forgetting protocols. [secondary_character_name] noticed before I did. Bad sign.",
				"[secondary_character_name] is running operations now. I can't... can't trust my own judgment anymore. The disease is in my brain.",
				"Briefing [secondary_character_name] on everything I remember. While I still remember it. Mission must continue.",
				"Tell Central Command that Commander [character_name] served to the end. [secondary_character_name] has command. I... where was I?"
			)
		if("Fungus")
			entries = list(
				"Fungal infection established on exposed skin. [secondary_character_name] applied antifungal treatment. Spreading anyway.",
				"The spores are in my lungs. [secondary_character_name] hears it in my breathing. Filtration came too late.",
				"[secondary_character_name] is documenting the infection's progression. For medical intelligence. And my service record.",
				"The fungus is spreading despite everything. [secondary_character_name] is maintaining distance. Smart. Following protocols."
			)
		else
			entries = list(
				"Unknown illness affecting squad performance. [secondary_character_name] is holding up better than I am.",
				"Can't identify the pathogen. [secondary_character_name] treating symptoms as best we can. Mission continues.",
				"Getting worse. [secondary_character_name] may need to complete objectives alone. Briefing them on contingencies.",
				"Death Squad doesn't quit. We complete the mission or we die trying. [secondary_character_name] understands."
			)
	return pick(entries)
