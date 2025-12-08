/datum/story_theme/nanotrasen
	name = "nanotrasen"
	theme_flag = STORY_NT
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/humanoid/surgeon
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/scientist,
		/obj/effect/landmark/corpse/engineer,
		/obj/effect/landmark/corpse/assistant
	)

/datum/story_theme/nanotrasen/generate_character_name()
	if(first_names_male?.len && last_names?.len)
		var/first = pick(prob(50) ? first_names_male : first_names_female)
		character_name = "Dr. [first] [pick(last_names)]"
	else
		character_name = "Dr. Unknown"
	return character_name

/datum/story_theme/nanotrasen/generate_secondary_character_name()
	if(first_names_male?.len && last_names?.len)
		var/first = pick(prob(50) ? first_names_male : first_names_female)
		secondary_character_name = "[first] [pick(last_names)]"
	else
		secondary_character_name = "J. Smith"
	return secondary_character_name

/datum/story_theme/nanotrasen/get_log_info()
	return list("title" = "NANOTRASEN PLANETARY SURVEY", "subtitle" = "[planet_name] - Research Division")

/datum/story_theme/nanotrasen/get_generic_entries()
	if(!secondary_character_name)
		generate_secondary_character_name()

	return list(
		"Dr. [character_name], xenobiologist, reporting. This is my third deep-space survey mission. Nanotrasen assigned our team to this sector. Initial scans look promising.",
		"Established base camp in sector 7. [secondary_character_name] has begun geological surveys. The company expects results within the quarter.",
		"[get_planet_finding()]",
		"Major breakthrough. We've recovered significant data relating to [tech_name]. Central Command will be pleased. This alone justifies the expedition budget.",
		"Equipment malfunction in Lab 2. [secondary_character_name] thinks it's the humidity. I think it's this planet fighting back. Either way, we're behind schedule.",
		"Received transmission from Central Command. They want preliminary results by end of week. Corporate never understands field conditions.",
		"Local fauna specimen captured for study. Fascinating biology - completely unlike anything in our databases. [secondary_character_name] is ecstatic.",
		"Power grid fluctuations again. The backup generators are holding but I'm concerned about long-term stability out here.",
		"Found evidence of previous expedition. Their camp was abandoned in a hurry. No bodies, no explanation. Concerning.",
		"The night cycle here is 47 hours. Sleep schedules are completely disrupted. [secondary_character_name] has started talking to the equipment.",
		"Atmospheric readings nominal. This planet could support a colony with minimal terraforming investment.",
		"Something triggered the motion sensors last night. Probably wildlife. Probably.",
		"Mission objectives complete. Recommending this planet for further Nanotrasen investment. Preparing data for upload to Central Command.",
		"Something is wrong. [secondary_character_name] hasn't reported in for 48 hours. The perimeter sensors keep triggering but we find nothing. I'm archiving everything to the database, just in case.",
		"Final log. Whatever is out there, it's smart. It's patient. Don't send rescue. Send exterminators. Dr. [character_name], signing off.",
		"Budget review from Central. They want to know why we're 'over-consuming' emergency rations. We're on an alien planet! What do they expect?",
		"[secondary_character_name] found unusual mineral deposits in cave system delta. Could be significant for [tech_name] research.",
		"Morale is low. The isolation is getting to everyone. I've started mandatory recreational hours. It's helping. Somewhat.",
		"Comms array took damage in the storm last night. Running on backup communications. Central won't be happy about the delay.",
		"Specimen from Lab 3 escaped containment. Non-hostile, thankfully, but embarrassing. [secondary_character_name] is reviewing our protocols.",
		"Found ancient ruins two clicks north. Definitely not natural formations. Requesting archaeological team for follow-up mission.",
		"The stars look different here. I've been cataloguing constellations in my downtime. It's oddly calming.",
		"Supply drop arrived. Half the equipment was damaged in transit. Filed complaint with logistics. Again."
	)

/datum/story_theme/nanotrasen/get_weather_entries()
	var/list/entries = list()
	switch(planet_style)
		if("lava planet")
			entries += "The volcanic activity makes everything ten times harder. [secondary_character_name] nearly lost an arm to a sudden eruption yesterday."
			entries += "Heat shielding failures are a daily concern. Central keeps sending us gear rated for temperate climates. Typical."
		if("frozen planet")
			entries += "The temperature dropped below -100C last night. [secondary_character_name] is worried about the power cells."
			entries += "Ice storms every few hours. We've lost two remote sensors this week alone."
		if("desert planet")
			entries += "Water reclamation is at 94% efficiency. [secondary_character_name] says we need to push it to 98% or we're in trouble."
			entries += "Sandstorms are relentless. Had to recalibrate all the external sensors again."
		if("jungle planet")
			entries += "The humidity is destroying our sensitive equipment. [secondary_character_name] is rigging up makeshift dehumidifiers."
			entries += "Vines grew through the wall panel overnight. This planet doesn't want us here."
		if("wasteland planet")
			entries += "Radiation levels are higher than projected. [secondary_character_name] is adjusting everyone's dosimeters."
			entries += "The decay here is comprehensive. Whatever civilization existed, it's long gone."
		if("beach planet")
			entries += "Salt corrosion on the equipment is worse than expected. [secondary_character_name] is applying protective coatings daily."
			entries += "The tides here are extreme. Had to relocate the lower camp twice already."
		if("grass planet")
			entries += "Almost Earth-like conditions. [secondary_character_name] thinks this could be a prime colony candidate."
			entries += "The temperate weather is a relief after the last assignment. Actual seasons!"
		if("unknown planet")
			entries += "[secondary_character_name]'s instruments are giving contradictory readings. The physics here don't match our models."
			entries += "Something about the environment is affecting our equipment in ways I can't explain."
	return entries

/datum/story_theme/nanotrasen/get_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("bunker")
			entries += "The bunker construction is solid. [secondary_character_name] approves of the defensive positioning."
			entries += "Security protocols established. This facility was built to last."
		if("cabin")
			entries += "Basic accommodations, but adequate for research purposes. [secondary_character_name] has claimed the corner with the best lighting."
			entries += "The cabin is surprisingly well-insulated. Someone knew what they were doing."
		if("laboratory")
			entries += "The lab equipment is mostly intact. [secondary_character_name] is running diagnostics now."
			entries += "This facility has everything we need for [tech_name] research. Corporate outdid themselves."
		if("workshop")
			entries += "The workshop has tools [secondary_character_name] hasn't seen since university. Old but functional."
			entries += "Maintenance capabilities here exceed requirements. We can handle most repairs in-house."
		if("greenhouse")
			entries += "The greenhouse systems are fascinating. [secondary_character_name] is documenting the hydroponics setup."
			entries += "Agricultural potential here is significant. Recommending botanical research team for follow-up."
		if("camp")
			entries += "Field camp established per NT regulations. [secondary_character_name] is complaining about the accommodations. Again."
			entries += "Not the most comfortable setup, but it meets operational requirements."
	return entries

/datum/story_theme/nanotrasen/get_fauna_entries()
	var/list/entries = ..()
	entries += "[secondary_character_name] has started a specimen catalog. Corporate will want detailed reports."
	entries += "The local fauna shows no fear of our equipment. Either they've never seen humans, or they have and don't consider us threats."
	return entries

/datum/story_theme/nanotrasen/get_loot_entries()
	var/list/entries = ..()
	entries += "Inventory logged and catalogued per NT Standard Procedure 7-Alpha. [secondary_character_name] is meticulous about documentation."
	entries += "All recovered assets tagged for corporate review. Some of this equipment predates current NT models."
	return entries

/datum/story_theme/nanotrasen/get_main_ruin_entries()
	if(!secondary_character_name)
		generate_secondary_character_name()

	var/list/entries = list()
	switch(ruin_name)
		if("Geode")
			entries += "Massive crystal formation detected - a natural geode of unprecedented scale. [secondary_character_name] is pushing for a geological survey. The mineral composition could be significant."
			entries += "The geode's crystals exhibit unusual luminescence. [secondary_character_name] theorizes piezoelectric properties. Recommending mineralogical analysis team for Phase 2."
			entries += "Crystal samples from the geode structure catalogued. Market value: substantial. Scientific value: potentially revolutionary. NT will be very interested."
		if("Crashed Tradeship")
			entries += "Identified wreckage of a commercial transport vessel. [secondary_character_name] ran the hull markings - not in NT registry. Independent trader, or competitor assets?"
			entries += "The crashed tradeship's cargo manifest is partially recoverable. Mixed goods, standard trade route supplies. Nothing explains why they came here."
			entries += "[secondary_character_name] found the ship's black box. Encrypted, but NT cryptography should crack it. Might explain what brought them here. And what brought them down."
		if("Crashed Pod")
			entries += "Emergency escape pod detected. [secondary_character_name] confirmed single occupant, deceased. Cause: impact trauma. Pod beacon was still transmitting - nobody came."
			entries += "The pod's registration traces to a vessel not in current databases. Old? Classified? [secondary_character_name] is flagging this for Central Command review."
			entries += "Recovered personal effects from the crashed pod. Standard emergency kit, personal items, a journal. [secondary_character_name] is cataloguing everything per NT protocol."
		if("Abandoned Digsite")
			entries += "Mining operation, abandoned mid-excavation. [secondary_character_name] estimates the site was active for at least six months before shutdown. Equipment left behind."
			entries += "The digsite's extraction logs are intact. They were pulling out rare earth elements, good yields too. Why stop? [secondary_character_name] found no answers."
			entries += "Abandoned mining equipment assessed for salvage value. [secondary_character_name] recommends recovery operation. Some of this hardware is still functional."
		if("Alien Hive")
			entries += "XENOMORPH INFESTATION CONFIRMED. [secondary_character_name] strongly advises maintaining quarantine distance. Recommending orbital sterilization for this sector."
			entries += "The hive structure is extensive - this infestation is well-established. How did NT surveys miss this? [secondary_character_name] is updating threat assessment protocols."
			entries += "Lost a survey drone to the hive perimeter. [secondary_character_name] is NOT happy. Adjusting our patrol routes to maximum safe distance."
		if("The Buried Bar")
			entries += "Subterranean establishment discovered - appears to be a recreational facility. [secondary_character_name] calls it 'a bar.' Previous mining operations, perhaps?"
			entries += "[secondary_character_name] did a sweep of the buried bar. Remarkably well-preserved. Someone maintained this place with care. Wonder what happened to them."
			entries += "The bar's inventory includes some... interesting substances. [secondary_character_name] is documenting everything. Some of it may require hazmat disposal. Some of it may require 'further testing.'"
		if("Cult Base")
			entries += "Discovered structure with non-standard religious iconography. [secondary_character_name] advises extreme caution - cult activity falls under NT Security Protocol 7."
			entries += "The cult facility shows evidence of organized ritual practice. [secondary_character_name] is photographing everything. Central Command's occult division will want this."
			entries += "Personal recommendation: glass this site from orbit. [secondary_character_name] agrees. Whatever they were doing here, it wasn't NT-sanctioned research."
	return entries

/datum/story_theme/nanotrasen/get_stashed_loot_entries()
	var/list/entries = list()
	switch(stashed_loot_type)
		if(/datum/loot_table/weighted/bureaucracy)
			entries += "Secured research documentation and administrative supplies per NT protocol. [secondary_character_name] filed the requisite forms."
			entries += "Stashed backup copies of our findings. Corporate requires redundant documentation."
		if(/datum/loot_table/weighted/combat)
			entries += "[secondary_character_name] insisted on caching defensive equipment. Given recent events, I didn't argue."
			entries += "Emergency defense supplies secured per NT Safety Regulation 12-C. Hope we won't need them."
		if(/datum/loot_table/decoration)
			entries += "Personal effects and comfort items stored safely. [secondary_character_name] says morale is a resource too."
			entries += "Set aside some items to make quarters more livable. Long-term expeditions require creature comforts."
		if(/datum/loot_table/engineering)
			entries += "[secondary_character_name] assembled an emergency repair kit. Standard NT field procedure."
			entries += "Maintenance supplies cached for equipment failures. Can't afford downtime out here."
		if(/datum/loot_table/entertainment)
			entries += "Recreational supplies secured for morale purposes. [secondary_character_name] already claimed the card deck."
			entries += "NT recommends scheduled leisure time. We've got the supplies to support that now."
		if(/datum/loot_table/weighted/exotic)
			entries += "Unusual specimens secured for further analysis. [secondary_character_name] is already writing the research proposal."
			entries += "Exotic materials catalogued and stored. Corporate R&D will want first look at these."
		if(/datum/loot_table/weighted/medical)
			entries += "Medical supplies secured per NT Health Protocol 7. [secondary_character_name] verified the expiration dates."
			entries += "Emergency medical cache established. [secondary_character_name] has basic field training, thankfully."
		if(/datum/loot_table/module)
			entries += "AI modules secured and documented. Potentially valuable tech - flagged for R&D review."
			entries += "[secondary_character_name] catalogued the electronic components. Some of these are cutting-edge."
		if(/datum/loot_table/weighted/structure)
			entries += "Construction materials secured for facility expansion. [secondary_character_name] is planning upgrades."
			entries += "Building supplies cached. May need to fortify our position depending on what we find."
		if(/datum/loot_table/trash)
			entries += "[secondary_character_name] insists on sorting through the debris. 'Reclamation efficiency', they call it."
			entries += "Even the refuse has been catalogued. Nothing escapes NT documentation requirements."
	return entries

/datum/story_theme/nanotrasen/get_disease_entry(var/disease_form)
	if(!secondary_character_name)
		generate_secondary_character_name()

	var/list/entries = list()
	switch(disease_form)
		if("Virus")
			entries = list(
				"Viral infection confirmed. [secondary_character_name] is running tests. Quarantine protocols in effect.",
				"The fever keeps climbing. [secondary_character_name] says the medical supplies are insufficient. Central Command has been notified.",
				"NT Health Protocol 12-B initiated. Viral contamination from unknown source. Symptoms worsening.",
				"[secondary_character_name] caught it too. We're both symptomatic now. Isolation is pointless. Focusing on treatment."
			)
		if("Bacteria")
			entries = list(
				"Bacterial infection in the wound from last week. [secondary_character_name] is administering antibiotics.",
				"Sepsis risk elevated. [secondary_character_name] is monitoring vitals. Medical evac may be necessary.",
				"The infection isn't responding to standard treatment. [secondary_character_name] suggests we try the experimental protocols.",
				"NT medical supplies running low. [secondary_character_name] is rationing the antibiotics. This is serious."
			)
		if("Parasite")
			entries = list(
				"Parasitology report: local fauna carried something we didn't screen for. [secondary_character_name] is researching treatment.",
				"The parasite is wreaking havoc on my digestive system. [secondary_character_name] found similar cases in the medical database.",
				"Appetite is insatiable but nutrition is failing. [secondary_character_name] suspects the organism is competing for resources.",
				"[secondary_character_name] extracted a sample. It's worse than we thought. Recommending xenobiological hazard classification."
			)
		if("Prion")
			entries = list(
				"Cognitive assessment shows concerning results. [secondary_character_name] is worried. I'm... having trouble with that report.",
				"Memory is fragmenting. [secondary_character_name]'s name took me too long to recall. This isn't normal.",
				"Prion disease suspected. [secondary_character_name] found the likely contamination source. Too late for me. Warning others.",
				"[secondary_character_name] keeps explaining things I should know. The knowledge is there, then it's... not. Documenting while I can."
			)
		if("Fungus")
			entries = list(
				"Fungal infection spreading despite treatment. [secondary_character_name] says the local strain is resistant to standard antifungals.",
				"The mycelium is visible now. [secondary_character_name] is documenting for NT xenobiological records. Clinically fascinating. Personally terrifying.",
				"[secondary_character_name] tried surgical removal. It grew back within hours. This organism is... aggressive.",
				"Spore count in my lungs is rising. [secondary_character_name] has isolated me from the main facility. Standard containment."
			)
		else
			entries = list(
				"Unknown pathogen detected. [secondary_character_name] is running every test we have. Symptoms don't match NT medical databases.",
				"Getting worse. [secondary_character_name] is doing everything possible. Corporate needs to know about this biological hazard.",
				"This illness isn't in any of our files. [secondary_character_name] thinks it might be native to this planet. First contact of the wrong kind.",
				"If we don't make it, [secondary_character_name] and I have documented everything. NT will know what killed us, at least."
			)
	return pick(entries)
