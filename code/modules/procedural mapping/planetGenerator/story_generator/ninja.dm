/datum/story_theme/ninja
	name = "ninja"
	theme_flag = STORY_NINJA
	hostile_mobs = list()
	corpse_types = list(
		/obj/effect/landmark/corpse/ninja
	)

/datum/story_theme/ninja/generate_character_name()
	if(ninja_titles?.len && ninja_names?.len)
		character_name = "[pick(ninja_titles)] [pick(ninja_names)]"
	else
		character_name = "Shadow Warrior"
	return character_name

/datum/story_theme/ninja/get_log_info()
	return list("title" = "SPIDER CLAN MISSION REPORT", "subtitle" = "Agent: [character_name]")

/datum/story_theme/ninja/get_generic_entries()
	return list(
		"Arrived at designated coordinates. Planet '[planet_name]' matches intelligence reports. Nanotrasen presence confirmed but minimal. Beginning reconnaissance operations.",
		"Located abandoned research facility. Security systems offline. Corporate incompetence works in our favor. Infiltrating under cover of darkness.",
		"Retrieved valuable data on [tech_name]. The Clan will be pleased. This technology could be... repurposed for our objectives.",
		"Perimeter sweep complete. No active threats detected. The previous occupants left in haste. Their loss is our gain.",
		"Energy reserves at 67%. Must conserve suit power for extraction. Operating in low-power mode.",
		"Discovered secondary data cache. [tech_name] research more extensive than anticipated. Downloading everything.",
		"Motion detected in sector 4. Investigation revealed local fauna. Non-hostile. Continuing mission.",
		"Corporate security protocols are laughable. Their encryption took 4.7 seconds to bypass. The Clan trains better.",
		"Found personal effects of researchers. They feared something. Their final logs mention 'shadows that move wrong.' Superstitious nonsense.",
		"Suit stealth systems functioning optimally. Moved through three security zones undetected. The shadows are my ally.",
		"Data extraction 94% complete. This [tech_name] information will advance Clan interests significantly.",
		"Compromised. Unknown hostile entities detected my presence. Energy katana depleted. Uploading all data to backup systems.",
		"Extraction complete. All evidence of Clan presence eliminated. Leaving this terminal active as a decoy for future NT investigators.",
		"If this reaches the Clan - the mission was successful. Tell them [character_name] completed the objective. Honor to the Spider Clan.",
		"Maintaining radio silence. The Clan's protocols are clear: no transmissions until extraction window opens.",
		"Local fauna proves more resilient than expected. Eliminated three specimens attempting to breach the perimeter. Suit integrity at 89%.",
		"Discovered encrypted personal logs from NT staff. Decrypting for intelligence value. Their security officer suspected our presence.",
		"The [tech_name] data contains weapons applications NT never pursued. The Clan will find these... enlightening.",
		"Rations depleted. Surviving on local flora. Training prepared me for worse. The mission continues.",
		"Observed NT patrol vessel in orbit. Did not land. Either they lack resources for full investigation, or they fear what's here.",
		"Created secondary cache of stolen data. If primary extraction fails, future agents can recover the intelligence.",
		"The silence here is complete. No wildlife near the facility anymore. Something has driven them away. Investigating."
	)

/datum/story_theme/ninja/get_weather_entries()
	var/list/entries = list()
	switch(planet_style)
		if("lava planet")
			entries += "Thermal management critical. Suit cooling systems at maximum. The heat provides natural cover - thermal sensors are useless here."
			entries += "Volcanic vents create useful smoke cover. Adapting infiltration routes accordingly."
		if("frozen planet")
			entries += "Cold does not affect my focus. Suit heating systems adequate. The snow reveals footprints - adjusting movement patterns."
			entries += "Ice storms provide acoustic cover for operations. Continuing data extraction during weather events."
		if("desert planet")
			entries += "Sand interferes with optical camouflage. Switching to thermal dampening protocols."
			entries += "Water reserves sufficient for extended operation. The Clan trains for worse conditions."
		if("jungle planet")
			entries += "Dense vegetation provides excellent concealment. Natural environment for shadow operations."
			entries += "Humidity affects equipment performance. Implementing countermeasures from field manual section 7."
		if("wasteland planet")
			entries += "Radiation levels within suit tolerance. The decay here provides unexpected advantages - fewer witnesses."
			entries += "Ruins offer multiple infiltration vectors. This environment suits our methods."
		if("beach planet")
			entries += "Open terrain presents challenges. Operating primarily during low-light conditions."
			entries += "Salt corrosion on equipment noted. Maintenance schedule adjusted."
		if("grass planet")
			entries += "Open grasslands require careful movement. Using natural depressions for concealment."
			entries += "Temperate conditions ideal for extended surveillance operations."
		if("unknown planet")
			entries += "Environmental anomalies interfering with suit sensors. Operating on manual protocols."
			entries += "This planet does not conform to standard parameters. Adapting tactics as required."
	return entries

/datum/story_theme/ninja/get_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("bunker")
			entries += "Fortified position with multiple entry points. Identified three infiltration vectors and two emergency exits."
			entries += "The bunker's defenses are oriented outward. Interior security is minimal. Typical corporate oversight."
		if("cabin")
			entries += "Small structure. Limited concealment options but minimal security. Low-priority but useful as temporary shelter."
			entries += "Found hidden compartment in floor panels. Previous occupants had secrets. Now I have them."
		if("shrine")
			entries += "Religious structure. The faithful leave offerings - and information. Useful intelligence gathered from personal effects."
			entries += "Spiritual locations often hold unexpected value. The Clan teaches us to overlook nothing."
		if("camp")
			entries += "Field encampment. Poor security, multiple blind spots. Easy infiltration and exfiltration."
			entries += "Temporary structures indicate short-term occupation. They were not planning to stay."
		if("listening post")
			entries += "Communications facility. Priority target for intelligence gathering. Encryption surprisingly robust."
			entries += "Monitoring equipment operational. Redirecting select transmissions to Clan frequencies."
		if("workshop")
			entries += "Fabrication equipment present. Could be useful for emergency repairs. Cataloguing available resources."
			entries += "Tools here are standard corporate issue. Nothing exceptional, but functional."
	return entries

/datum/story_theme/ninja/get_fauna_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Crustacean lifeforms pose no threat. Their movement patterns are predictable. Avoiding disturbing their nests."
		if("desert planet")
			entries += "Large predators patrol the perimeter. Have established their movement patterns. Timing operations around their cycles."
		if("frozen planet")
			entries += "Pack hunters observed. Intelligent enough to recognize threat, not intelligent enough to be useful. Keeping distance."
		if("grass planet")
			entries += "Herbivores provide useful early warning system. Their behavior indicates approaching threats."
		if("jungle planet")
			entries += "Canopy provides excellent vantage points. The wildlife ignores my presence when I remain still."
		if("lava planet")
			entries += "Heat-adapted predators present unique challenges. Their thermal signatures are difficult to distinguish from environment."
		if("wasteland planet")
			entries += "Mutated creatures patrol the ruins. Aggressive but predictable. Have mapped safe routes through their territory."
		if("unknown planet")
			entries += "Unknown lifeforms displaying unusual behavioral patterns. Cannot predict their movements. Proceeding with maximum caution."
	return entries

/datum/story_theme/ninja/get_loot_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Supplies catalogued. Nothing of strategic value beyond basic provisions."
		if("desert planet")
			entries += "Engineering equipment recovered. Could be useful for Clan operations with modifications."
		if("frozen planet")
			entries += "Cold-weather gear acquired. Supplementing suit capabilities for extended operations."
		if("grass planet")
			entries += "Standard supplies. Have requisitioned what's useful, left what isn't."
		if("jungle planet")
			entries += "Sealed containers yielded viable provisions. Humidity destroyed the rest."
		if("lava planet")
			entries += "Heat-shielded storage contained valuable technical components. Marking for extraction."
		if("wasteland planet")
			entries += "Salvage quality variable. Some items show promise for reverse engineering."
		if("unknown planet")
			entries += "Unusual artifacts present. Cannot determine origin or function. Collecting samples for Clan analysis."
	return entries

/datum/story_theme/ninja/get_main_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("Geode")
			entries += "Crystal formation detected. Natural structure, but crystals of this composition have applications in energy focusing. The Clan may find them useful."
			entries += "The geode's interior provides excellent acoustic cover. Sound does not travel well through crystal matrices. Noted for potential safehouse usage."
			entries += "Harvested several crystal samples. The Spider Clan's artificers can assess their worth for suit enhancement or weapon modification."
		if("Crashed Tradeship")
			entries += "Commercial vessel wreckage. Scanned for security systems - none active. Cargo scattered but some containers remain sealed. Investigating."
			entries += "The tradeship's navigation logs reveal common shipping routes. Intelligence on civilian traffic patterns has operational value."
			entries += "Ship's manifest indicates standard trade goods. However, one cargo container was reinforced beyond commercial standards. Contents removed. By whom?"
		if("Crashed Pod")
			entries += "Emergency escape pod. Single occupant, status: deceased. Examined for intelligence value - personal effects suggest corporate employee, mid-level."
			entries += "The pod's trajectory data indicates panic-driven escape. Something pursued this vessel. Something the occupant feared more than an emergency landing."
			entries += "Minimal intelligence value. Recorded biometric data for Clan databases regardless. Every piece of information has potential use."
		if("Abandoned Digsite")
			entries += "Excavation site, abandoned. Checked for surveillance equipment - negative. The corporations left in haste, no time for sensor deployment."
			entries += "The mining operation was substantial. Whatever they extracted required specialized equipment. The Clan should investigate what resource warranted such investment."
			entries += "Underground tunnels provide potential infiltration routes. Mapping the digsite's layout for future tactical reference."
		if("Alien Hive")
			entries += "Xenomorph hive detected. Suit sensors confirm biological threat signatures. The Clan has protocols for such encounters: avoidance unless mission-critical."
			entries += "The hive structure blocks most scanning methods. Natural sensor countermeasure. Interesting adaptation. Dangerous, but interesting."
			entries += "Maintaining observation distance. The creatures are territorial but predictable. Their patrol patterns have been logged for route planning."
		if("The Buried Bar")
			entries += "Subterranean establishment. Social gathering point for previous inhabitants. Such locations often contain useful intelligence in casual records."
			entries += "The bar's guest registry provides names and potentially identities for cross-reference. Even recreational facilities yield operational data."
			entries += "Secured position offers good sightlines and multiple exits. Acceptable temporary shelter if primary location is compromised."
		if("Cult Base")
			entries += "Religious structure with anomalous energy signatures. The Clan has encountered such phenomena before. Caution advised but investigation warranted."
			entries += "The cult's practices show sophistication beyond typical superstition. Genuine power was accessed here. The source remains unclear."
			entries += "Collected ritual texts and artifacts for Clan analysts. The Spider Clan does not dismiss any potential advantage, however unconventional."
	return entries

/datum/story_theme/ninja/get_stashed_loot_entries()
	var/list/entries = list()
	switch(stashed_loot_type)
		if(/datum/loot_table/weighted/bureaucracy)
			entries += "Documentation secured. Intelligence value: moderate. May contain access codes or personnel data."
			entries += "Administrative materials cached. The Clan can analyze for useful information."
		if(/datum/loot_table/weighted/combat)
			entries += "Weapons cache established per Clan protocol. Secondary armament in case of suit failure."
			entries += "Combat supplies secured in concealed location. The shadows hold many secrets."
		if(/datum/loot_table/decoration)
			entries += "Personal effects catalogued and secured. May provide insight into previous occupants' psychology."
			entries += "Non-essential items cached. Low priority but useful for cover stories if needed."
		if(/datum/loot_table/engineering)
			entries += "Technical supplies secured. Essential for suit maintenance and emergency repairs."
			entries += "Engineering equipment cached. Self-sufficiency is a Clan requirement."
		if(/datum/loot_table/entertainment)
			entries += "Recreational items secured. Extended operations require mental discipline maintenance."
			entries += "Entertainment supplies cached. Long surveillance requires patience... and distraction."
		if(/datum/loot_table/weighted/exotic)
			entries += "Unusual materials secured for Clan analysis. Origin unknown. Potential value: significant."
			entries += "Exotic artifacts cached. The Clan's researchers will determine their true worth."
		if(/datum/loot_table/weighted/medical)
			entries += "Medical supplies secured per standard infiltration protocol. Injuries compromise missions."
			entries += "First aid cache established. A wounded operative is a compromised operative."
		if(/datum/loot_table/module)
			entries += "Electronic modules secured. Potential applications for surveillance or countermeasures."
			entries += "AI components cached. The Clan may find alternative uses for these systems."
		if(/datum/loot_table/weighted/structure)
			entries += "Construction materials secured. May be useful for establishing permanent Clan presence."
			entries += "Structural supplies cached. Future operations may require fortification."
		if(/datum/loot_table/trash)
			entries += "Even debris can contain useful intelligence. Sorted and relevant items cached."
			entries += "Refuse analyzed and selectively retained. Nothing escapes a trained operative's notice."
	return entries

/datum/story_theme/ninja/get_disease_entry(var/disease_form)
	var/list/entries = list()
	switch(disease_form)
		if("Virus")
			entries = list(
				"Viral contamination detected. Suit medical systems compensating. Mission continues.",
				"Fever compromising operational efficiency. The Clan trained us to operate through worse. Adapting.",
				"The virus spreads despite suit countermeasures. Biological warfare? Or environmental hazard? Investigating origin.",
				"System alert: elevated temperature, reduced reaction time. Adjusting combat protocols to compensate."
			)
		if("Bacteria")
			entries = list(
				"Wound infection detected. Suit administering antibiotics. Field treatment insufficient.",
				"Bacterial contamination from local environment. The Clan's medical training is being tested.",
				"Infection spreading. Pain is a distraction; the mission is focus. But the body has limits.",
				"Medical alert: systemic bacterial infection. Require extraction for proper treatment. Mission timeline compressed."
			)
		if("Parasite")
			entries = list(
				"Parasitic lifeform detected in digestive system. Contracted from local fauna. Unacceptable oversight.",
				"The parasite is affecting nutrient absorption. Energy reserves depleting faster than projected.",
				"Internal sensors confirm parasitic infection. The creature must have entered through contaminated water.",
				"Symbiotic or parasitic - irrelevant. It compromises operational capacity. Seeking treatment options."
			)
		if("Prion")
			entries = list(
				"Cognitive function... fluctuating. Difficulty maintaining mission focus. This is... concerning.",
				"The Clan's mental disciplines failing. Something wrong with neural pathways. Cannot identify cause.",
				"Memory gaps appearing. Training routines incomplete in recall. What is happening to me?",
				"Neurological degradation detected. If this continues, mission data must be uploaded before... before..."
			)
		if("Fungus")
			entries = list(
				"Fungal growth detected on suit exterior. Now spreading to exposed tissue. Containment failed.",
				"The spores have taken root. Suit integrity compromised at joint seals. Mycological hazard underestimated.",
				"Fungal infection spreading beneath the skin. The Clan has protocols, but not the resources here.",
				"Mycelium network visible on forearm. Fascinating if it weren't killing me. Documenting for Clan medical archives."
			)
		else
			entries = list(
				"Unknown pathogen affecting system efficiency. Symptoms do not match Clan medical databases.",
				"Illness compromising mission parameters. The body fails where the will remains strong.",
				"Disease progression accelerating. Must complete objectives before becoming fully incapacitated.",
				"Sick. Weak. But still a Spider Clan operative. The mission continues until it cannot."
			)
	return pick(entries)
