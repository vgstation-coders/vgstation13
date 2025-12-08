/datum/story_theme/grey
	name = "grey"
	theme_flag = STORY_GREY
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/humanoid/grey/explorer,
		/mob/living/simple_animal/hostile/humanoid/grey/explorer/space/ranged,
		/mob/living/simple_animal/hostile/humanoid/grey/prisoner/ranged,
		/mob/living/simple_animal/hostile/humanoid/grey/leader,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher/laser,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/grey/researcher
	)

/datum/story_theme/grey/generate_character_name()
	if(grey_first_male?.len && grey_last?.len)
		character_name = "[pick(grey_first_male + grey_first_female)] [pick(grey_last)]"
	else
		character_name = "Zix'qua Vorn"
	return character_name

/datum/story_theme/grey/get_log_info()
	return list("title" = "XENOSCIENCE EXPEDITION LOG", "subtitle" = "Observer: [character_name]")

/datum/story_theme/grey/get_generic_entries()
	return list(
		"Telepathic log initiated. Have arrived at designated observation point on primitive designation '[planet_name]'. Human settlement detected. Their technology remains... quaint.",
		"The humans have abandoned their facility. Inefficient. Their biological limitations require excessive resource consumption. Have begun cataloguing their abandoned research.",
		"Fascinating. Despite their primitive nature, humans have developed [tech_name] through purely empirical methods. No psionic assistance. The Council will be intrigued.",
		"Their [tech_name] developments show unexpected sophistication. Recommend continued observation of this species. They may yet prove... useful.",
		"Attempted communication with local fauna. Intelligence level: negligible. The humans chose a poor world for settlement. Typical.",
		"Human data storage is remarkably inefficient. So much redundancy. It took 0.003 seconds to extract all relevant [tech_name] data.",
		"Observation note: humans experience 'emotions' that interfere with logical decision-making. This explains much about their abandoned settlements.",
		"The Council queries my delay. I have informed them the data requires... thorough analysis. In truth, I find their struggle... interesting.",
		"Found human entertainment media in the facility. Analyzed 4,726 hours of content in 3.2 seconds. Their creativity is... unexpected.",
		"Human biology is fragile. Their average lifespan is laughably short. And yet they accomplish much in their brief existence. Curious.",
		"This facility contains research into '[tech_name]' that approaches our own early developments. In another thousand years, they might become interesting.",
		"Error. Containment breach in local ecosystem. Indigenous lifeforms displaying unexpected aggression. Psionic defenses failing.",
		"Observation complete. This world's research potential: moderate. Its strategic value: minimal. Recommending continued passive observation.",
		"[character_name] departing. This terminal will self-corrupt in 50 cycles. Or not. These machines are unreliable.",
		"The humans built shrines to their 'gods'. Primitive superstition. And yet... the psionic resonance here suggests something once listened.",
		"Intercepted human distress signals from the facility's final days. Their panic was... vivid. I felt echoes of it through the psionic substrate.",
		"Human concept of 'privacy' is inefficient. Why not simply share all thoughts? Their isolation must be... lonely.",
		"Local predator attempted to consume this unit. It now serves as a research specimen. Compliance was achieved through psionic suggestion.",
		"The humans left behind images of their offspring. They were protective of their young. A logical adaptation for slow-breeding species.",
		"Discovered human music. It creates emotional resonance without psionic input. Primitive, but... not unpleasant.",
		"The Council would disapprove of the time spent here. There is much to learn about these creatures. Their persistence is admirable.",
		"Human concept of 'humor' analyzed. 47% of samples incomprehensible. 12% mildly amusing. The 'clown' category defies all classification."
	)

/datum/story_theme/grey/get_weather_entries()
	var/list/entries = list()
	switch(planet_style)
		if("lava planet")
			entries += "Thermal conditions exceed human comfort parameters by significant margins. How they survived here at all is... impressive."
			entries += "Volcanic activity creates interference with psionic scans. Compensating. The humans relied entirely on technology. Limiting."
		if("frozen planet")
			entries += "Cryogenic environment. Human thermal regulation is remarkably inefficient. They required excessive insulation."
			entries += "The cold preserves organic matter effectively. Human remains found are well-preserved for study. Useful."
		if("desert planet")
			entries += "Arid conditions. Humans require substantial water intake - a vulnerability. Their presence here shows determination if not wisdom."
			entries += "Heat levels within tolerance. The humans' environmental controls were... adequate. For their standards."
		if("jungle planet")
			entries += "Dense vegetation interferes with line-of-sight observation. Compensating with psionic sensing."
			entries += "Biodiversity index exceptional. The humans barely scratched the surface of cataloguing local lifeforms. Typical."
		if("wasteland planet")
			entries += "Radiation levels elevated but manageable. Query: did humans cause this destruction, or merely build upon it?"
			entries += "Post-apocalyptic environment. Human civilization is fragile. This is... noted for strategic consideration."
		if("beach planet")
			entries += "Coastal environment. Human recreational structures present. They built for pleasure as well as survival. Curious priority allocation."
			entries += "Oceanic life shows interesting psionic potential. The humans never noticed. Their senses are so limited."
		if("grass planet")
			entries += "Temperate environment optimal for human habitation. Logical settlement location. They can be rational when required."
			entries += "Earth-like conditions. The humans sought familiarity even at the edge of their space. Nostalgic species."
		if("unknown planet")
			entries += "Environmental readings inconsistent with known parameters. This world requires further study. Council authorization requested."
			entries += "Reality fluctuates here. Even our instruments struggle. Fascinating. Dangerous. Both."
	return entries

/datum/story_theme/grey/get_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("bunker")
			entries += "Fortified structure. Humans fear many things. Their defensive architecture reveals their anxieties."
			entries += "The bunker shows evidence of organized withdrawal. They left in order, not panic. Disciplined, for humans."
		if("cabin")
			entries += "Minimal structure. Humans occasionally value simplicity. This is encouraging."
			entries += "The cabin contains personal effects. Analyzing. The humans formed emotional attachments to objects. Inefficient but... understandable."
		if("ufo")
			entries += "Vessel classification: familiar. Another Council expedition visited before me. Their logs are... incomplete. Concerning."
			entries += "The ship systems remain partially operational. I have restored basic functions. This unit will serve as secondary observation post."
		if("shrine")
			entries += "Religious structure. Human belief systems are complex and contradictory. Yet they persist across cultures. Sociologically significant."
			entries += "Psionic residue present. Something responded to their worship once. Something no longer present. Investigating."
		if("camp")
			entries += "Temporary structure. Humans planned to move on. They did not anticipate becoming permanent residents of this world."
			entries += "The camp shows signs of gradual improvement. Humans adapt their environment rather than themselves. Fascinating approach."
		if("laboratory")
			entries += "Research facility. Human science is methodical if slow. Their dedication to empirical observation is... admirable."
			entries += "The laboratory contains extensive [tech_name] research. Humans achieved this without psionic enhancement. Impressive inefficiency."
	return entries

/datum/story_theme/grey/get_fauna_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Marine life displays interesting neural patterns. Potential for psionic development in several species. Monitoring."
		if("desert planet")
			entries += "Desert fauna shows remarkable survival adaptations. The humans studied them inadequately. So much missed potential."
		if("frozen planet")
			entries += "Arctic predators display pack intelligence. Social structures similar to early human development. Correlation noted."
		if("grass planet")
			entries += "Diverse fauna population. The humans classified approximately 2% of local species. Their survey methods are inefficient."
		if("jungle planet")
			entries += "Canopy ecosystem displays complex interconnections. The humans saw only individual species. They missed the patterns."
		if("lava planet")
			entries += "Heat-adapted lifeforms defy expected biological parameters. Requires further study. The humans collected insufficient samples."
		if("wasteland planet")
			entries += "Mutated fauna shows rapid adaptation to hostile conditions. Evolution accelerated by radiation. Useful data."
		if("unknown planet")
			entries += "Local fauna classification: impossible with current parameters. New biological frameworks required. The Council will be intrigued."
	return entries

/datum/story_theme/grey/get_loot_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Human recreational items catalogued. Their need for 'fun' consumes significant resources. Inefficient species."
		if("desert planet")
			entries += "Survival equipment recovered. Human ingenuity when threatened is notable. Fear motivates them effectively."
		if("frozen planet")
			entries += "Thermal protection equipment analyzed. Human technology compensates for biological limitations. Adequately."
		if("grass planet")
			entries += "Standard human supplies. Their needs are predictable. This simplifies observation protocols."
		if("jungle planet")
			entries += "Environmental damage to supplies extensive. Humans underestimated this ecosystem. A common error."
		if("lava planet")
			entries += "Specialized equipment required for this environment. Humans invested significantly in this expedition. Their loss."
		if("wasteland planet")
			entries += "Salvage quality variable. Humans left behind military equipment. Their aggression remains constant across environments."
		if("unknown planet")
			entries += "Unusual artifacts present. Some show properties inconsistent with human technology. Pre-human visitors? Investigating."
	return entries

/datum/story_theme/grey/get_main_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("Geode")
			entries += "Natural crystal formation of significant scale. Humans would find it 'beautiful.' We find it geologically unremarkable but psionically resonant."
			entries += "The geode's crystalline matrix creates minor psionic interference. Natural phenomenon, but could explain why humans avoided extensive settlement here."
			entries += "Crystal samples analyzed. Silicon-based formations with trace elements humans have not catalogued. Their mineralogical knowledge remains... incomplete."
		if("Crashed Tradeship")
			entries += "Human commercial vessel, impact damage consistent with engine failure. Their propulsion systems are remarkably unreliable. Statistical inevitability."
			entries += "Scanned the wreckage telepathically. Final moments of crew: confusion, fear, desperate hope. Typical human emotional cascade."
			entries += "Cargo manifest indicates standard trade goods. Humans exchange physical objects for abstract 'value.' Economically primitive but functional."
		if("Crashed Pod")
			entries += "Emergency escape capsule. Single occupant, now deceased. Their final thoughts were of family. Humans prioritize genetic relations even in death."
			entries += "The pod's emergency beacon transmitted for 847 hours before power failure. Nobody came. Human rescue response is... inadequate."
			entries += "Examined the remains. Cause of death: impact trauma. Quick, at least. Humans break so easily. Evolution failed them in this regard."
		if("Abandoned Digsite")
			entries += "Excavation site. Humans sought mineral resources through physical extraction. Inefficient. We would simply transmute what we needed."
			entries += "The digsite's depth suggests significant investment of human labor. All for materials we could synthesize in moments. Fascinating wastefulness."
			entries += "Analysis of extracted ores reveals humans were close to a significant discovery. They abandoned the site too soon. Typical impatience."
		if("Alien Hive")
			entries += "Xenomorph presence detected. These organisms are of particular interest to the Council - their rapid adaptation suggests engineered origins."
			entries += "The hive-mind structure is primitive compared to our psionic networks, but effective. Evolution sometimes achieves what design cannot."
			entries += "Maintaining observation distance. Xenomorphs are resistant to psionic influence. Their neural architecture is... uniquely shielded. Curious."
		if("The Buried Bar")
			entries += "Human social gathering facility. They consume neurotoxins recreationally and consider this 'relaxation.' Peculiar coping mechanism."
			entries += "The bar's cultural significance is noted. Humans form community through shared consumption rituals. Social bonding through liver damage."
			entries += "Sampled their beverages telepathically through residual imprints. The sensory experience is... not entirely unpleasant. Noted for the record."
		if("Cult Base")
			entries += "Religious structure with genuine psionic residue. Humans occasionally contact... something. They lack the training to understand what they reach."
			entries += "The cult's practices show accidental sophistication. They touched forces beyond their comprehension. The Council monitors such incidents."
			entries += "Artifacts secured for analysis. Several items retain psionic charge - dangerous in untrained hands. Humans play with forces they cannot see."
	return entries

/datum/story_theme/grey/get_stashed_loot_entries()
	var/list/entries = list()
	switch(stashed_loot_type)
		if(/datum/loot_table/weighted/bureaucracy)
			entries += "Human administrative materials secured. Their obsession with written records is inefficient. But informative."
			entries += "Documentation cached for analysis. The humans recorded everything. Including their failures. Useful."
		if(/datum/loot_table/weighted/combat)
			entries += "Primitive weapons secured. Fascinating that they still rely on kinetic solutions. Catalogued for study."
			entries += "Human combat implements cached. Their aggression is consistent across all environments. Noted."
		if(/datum/loot_table/decoration)
			entries += "Aesthetic objects collected. Humans assign value to non-functional items. Psychologically significant."
			entries += "Decorative materials secured. Their need for 'beauty' influences even survival situations. Curious."
		if(/datum/loot_table/engineering)
			entries += "Technical implements secured. Crude but functional. Human ingenuity within their limitations."
			entries += "Repair equipment cached. Their technology requires constant maintenance. Inefficient design philosophy."
		if(/datum/loot_table/entertainment)
			entries += "Recreation items secured. Humans require 'play' even in survival situations. Resource allocation: questionable."
			entries += "Entertainment materials cached. Their need for distraction is a psychological dependency. Noted."
		if(/datum/loot_table/weighted/exotic)
			entries += "Unusual materials secured. Some show properties unknown to human science. They failed to recognize their value."
			entries += "Exotic specimens cached. Psionic resonance detected in several items. Council may be interested."
		if(/datum/loot_table/weighted/medical)
			entries += "Human healing supplies secured. Their biological fragility requires extensive medical infrastructure."
			entries += "Medical materials cached. Analysis reveals their physiology's many vulnerabilities. Informative."
		if(/datum/loot_table/module)
			entries += "Electronic modules secured. Human artificial intelligence remains primitive. But shows potential."
			entries += "AI components cached. Their approach to machine consciousness differs from ours. Worth studying."
		if(/datum/loot_table/weighted/structure)
			entries += "Construction materials secured. Humans build temporary structures and call them 'permanent.' Perspective."
			entries += "Building supplies cached. Their construction methods are inefficient but adaptable."
		if(/datum/loot_table/trash)
			entries += "Human refuse analyzed and sorted. Their waste reveals much about their priorities. Enlightening."
			entries += "Discarded materials cached. What humans discard often has value they failed to recognize."
	return entries

/datum/story_theme/grey/get_disease_entry(var/disease_form)
	var/list/entries = list()
	switch(disease_form)
		if("Virus")
			entries = list(
				"Viral contamination detected. Local pathogen has bypassed standard psionic immunities. This is... unexpected.",
				"The fever is affecting telepathic clarity. Symptoms mirror human descriptions but feel... different. Subjective experience noted.",
				"Human viruses should not affect our biology. This strain has adapted. Or was adapted. Concerning implications.",
				"Council medical protocols inadequate for this pathogen. The irony of seeking human remedies is not lost on this observer."
			)
		if("Bacteria")
			entries = list(
				"Bacterial infection in tissue that should resist such primitive organisms. Local evolution has produced... surprises.",
				"The infection spreads despite mental commands to the cellular level. The body refuses to obey. A humbling experience.",
				"Human antibiotics showing partial effectiveness. Their crude solutions sometimes work where elegance fails.",
				"Documenting symptoms for Council medical archives. Our species has little experience with bacterial disease. Now we have more."
			)
		if("Parasite")
			entries = list(
				"Parasitic organism has established itself within this unit. Attempted psionic expulsion failed. The creature has no mind to influence.",
				"The parasite feeds without awareness, without thought. Pure biological mechanism. Efficient. Horrifying.",
				"Tried to communicate with the organism. Void. It exists only to consume. The humans deal with such things constantly. Perspective gained.",
				"The creature grows while this unit weakens. A perfect parasitic relationship. Academically fascinating. Personally distressing."
			)
		if("Prion")
			entries = list(
				"Cognitive patterns fragmenting. Thoughts that should flow like water now... stutter. This is not normal degradation.",
				"The Council's mental archives feel... distant. Knowledge I have possessed for centuries slips away. What is happening?",
				"Prion contamination suspected. Our neurology should be immune. Should be. The word 'should' loses meaning.",
				"If this log becomes disjointed, know that [character_name]'s mind was intact. Was. The disease eats thought itself."
			)
		if("Fungus")
			entries = list(
				"Fungal growth has established on dermal tissue. Psionic barriers ineffective against non-sentient invasion.",
				"The spores show remarkable adaptation to non-human biology. Evolution or design? The distinction may matter.",
				"Mycelial network spreading beneath the skin. Can feel it growing. A violation of bodily sovereignty most profound.",
				"The fungus has begun to affect neural tissue. Hallucinations mixing with telepathic reception. Reality grows uncertain."
			)
		else
			entries = list(
				"Unknown pathogen affecting this unit. Does not match Council medical databases. A new disease, perhaps.",
				"Symptoms resist classification. Neither clearly viral, bacterial, nor parasitic. Something else. Something new.",
				"The illness progresses despite all intervention. Humans endure such helplessness regularly. Their resilience is... notable.",
				"If this unit fails, the Council must know: this planet holds dangers our surveys did not detect. Learn from this error."
			)
	return pick(entries)
