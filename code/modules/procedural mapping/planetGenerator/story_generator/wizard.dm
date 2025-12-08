/datum/story_theme/wizard
	name = "wizard"
	theme_flag = STORY_WIZARD
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/humanoid/wizard
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/wizard
	)

/datum/story_theme/wizard/generate_character_name()
	if(wizard_first?.len && wizard_second?.len)
		character_name = "[pick(wizard_first)] [pick(wizard_second)]"
	else
		character_name = "Merlin the Confused"
	return character_name

/datum/story_theme/wizard/get_log_info()
	return list("title" = "ARCANE JOURNAL", "subtitle" = "Property of [character_name]")

/datum/story_theme/wizard/get_generic_entries()
	return list(
		"By the Federation's forgotten tomes! That teleportation scroll was CLEARLY mislabeled. I was aiming for the Grand Library, not... wherever this is. My robes are covered in [planet_style == "jungle planet" ? "jungle muck" : "alien dust"]. Absolutely unacceptable.",
		"Have determined I'm on a planet called '[planet_name]' according to this strange device I found. The magical interference here is tremendous - my scrying attempts keep showing me visions of honking and spacemen. Most disturbing.",
		"Found an abandoned facility. These 'scientists' were researching [tech_name] through purely mundane means. Laughable! Though I admit their data storage is impressively resilient.",
		"Attempted to summon a familiar for company. Got a space carp. It immediately tried to eat me. I have banished it to the shadow realm (the supply closet).",
		"My wand is running low on charges. The leyline convergence on this planet is all wrong. It's like trying to cast spells through pudding.",
		"Found some of their 'technology'. Crude, but effective. I suppose when you can't bend reality to your will, you make do with buttons and levers.",
		"The local wildlife seems drawn to my magical aura. Had to fireball three separate creatures today. My spell components are running dangerously low.",
		"Discovered that '[tech_name]' is remarkably similar to certain arcane principles. These mundanes stumbled onto something without even realizing it.",
		"Drew a summoning circle in the dirt. Summoned a cheese sandwich. I'll call that a partial success.",
		"The stars here are wrong. My astral navigation is completely useless. The Federation will hear about this planet's non-standard celestial arrangement.",
		"Attempted to enchant one of their machines. It exploded. Violently. Note to self: technology and magic don't mix.",
		"Finally managed to attune to the local leylines! I should be able to teleport out within the week. Leaving this journal as a warning to any wizard foolish enough to use discount teleportation scrolls.",
		"If anyone finds this journal, tell the Federation that [character_name] died with dignity. And style. Mostly style.",
		"Success! The portal is stabilizing. Before I go, I'm leaving my notes on '[tech_name]' - the mundanes were onto something interesting here.",
		"The mundanes left behind what they call 'instant noodles'. Surprisingly edible. Magic cannot replicate that specific flavor of sadness and salt.",
		"Tried scrying for other Federation members. Saw only static and what appeared to be a clown. I'm choosing to ignore that vision.",
		"My beard has grown unkempt. A wizard's appearance reflects their power, and right now I look like a hedge mage at best.",
		"Found their 'coffee' substance. It provides alertness without the need for Focus potions. Intriguing. The mundanes have some useful tricks.",
		"The facility has a 'break room'. I have converted it into a meditation chamber. The vending machine makes acceptable ambient noise.",
		"Attempted astral projection to contact the Federation. Ended up watching the dreams of a local creature. It dreams of eating. A lot.",
		"Their [tech_name] research uses principles that would take my colleagues centuries to derive through pure magic. Perhaps there is merit in their methods.",
		"A creature attempted to eat my hat. MY HAT. It has been turned into a small pile of ash. The hat is irreplaceable."
	)

/datum/story_theme/wizard/get_weather_entries()
	var/list/entries = list()
	switch(planet_style)
		if("lava planet")
			entries += "This infernal heat is interfering with my frost spells. Had to improvise a cooling enchantment using local materials. Suboptimal."
			entries += "The volcanic activity creates fascinating magical resonance. If I weren't stranded, I'd recommend this location for geomantic research."
		if("frozen planet")
			entries += "My warming charms are working overtime. The mundanes' heating systems are crude but surprisingly effective as backup."
			entries += "Ice elementals would thrive here. Note to self: do NOT attempt any summoning until leylines stabilize."
		if("desert planet")
			entries += "Water creation spells depleting faster than expected. The desert seems to absorb moisture from reality itself."
			entries += "Found ancient magical residue in the sand. Someone practiced the Art here long ago. Their protection wards have long since faded."
		if("jungle planet")
			entries += "The overgrowth interferes with my ritual circles. Plants keep growing INTO my carefully drawn sigils."
			entries += "Natural magic is strong here - the jungle itself seems semi-sentient. I've started asking permission before harvesting reagents."
		if("wasteland planet")
			entries += "The residual energies here are... wrong. Whatever destroyed this place left magical scars that haven't healed."
			entries += "Necromantic potential is disturbingly high. The veil between life and death is thin on this cursed ground."
		if("beach planet")
			entries += "Salt water is interfering with my sea-scrying attempts. The ocean here doesn't follow normal magical currents."
			entries += "The tides respond to something other than moons. There's old magic in these waters. Older than the Federation."
		if("grass planet")
			entries += "Pleasant environment for spellwork. The natural mana flow is harmonious, if weak."
			entries += "This would make an acceptable retreat for meditation. If only it weren't so far from civilization."
		if("unknown planet")
			entries += "The magical laws here don't follow standard planar conventions. My spells produce... unexpected results."
			entries += "Reality itself seems uncertain in this place. Even simple cantrips require extra concentration."
	return entries

/datum/story_theme/wizard/get_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("bunker")
			entries += "The mundanes built this fortress against physical threats. Useless against a determined wizard, but I appreciate their effort."
			entries += "Converted the armory into a reagent storage. Guns are barbaric anyway."
		if("cabin")
			entries += "Quaint shelter. I've warded the entrance against unwanted visitors. The ward may have been overkill - nothing can approach without turning inside out."
			entries += "The fireplace makes an acceptable focus for fire-scrying. Almost cozy."
		if("shrine")
			entries += "Found a shrine to... something. The magical residue suggests genuine divine connection, not mere superstition. Concerning."
			entries += "I've consecrated the space to the Federation's patron principles. The previous deity didn't object. Or couldn't."
		if("camp")
			entries += "Rough accommodations. I've transmuted the bedding into something more civilized. Silk from burlap - basic, but satisfying."
			entries += "Set up defensive wards around the perimeter. Anything hostile will regret approaching."
		if("greenhouse")
			entries += "The plants here show potential for alchemical applications. I've begun cultivating useful reagents."
			entries += "Whoever built this had good instincts. Several of these species have genuine magical properties."
	return entries

/datum/story_theme/wizard/get_fauna_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "The crustaceans here are resistant to transformation magic. Tried to turn one into a messenger bird. Got a very angry, slightly feathered crab."
		if("desert planet")
			entries += "The lizards gather near my meditation circle. Either they're drawn to magical energy, or they're plotting something."
		if("frozen planet")
			entries += "Something large and white has been circling the camp. My detection spells suggest it's more intelligent than a beast should be."
		if("grass planet")
			entries += "Attempted to befriend local fauna with a charm spell. They're now TOO friendly. I can't prepare spells with a deer watching my every move."
		if("jungle planet")
			entries += "The parrots have learned to mimic my incantations. One of them accidentally cast Minor Levitation. I've moved my spellbook."
		if("lava planet")
			entries += "The creatures here survive through what can only be magical adaptation. Even the mundanes' 'science' can't explain their heat resistance."
		if("wasteland planet")
			entries += "The mutated beasts here carry echoes of the magical catastrophe that destroyed this place. Their flesh is unsuitable for reagent harvesting."
		if("unknown planet")
			entries += "The 'wildlife' defies magical classification. Some register as multiple creature types simultaneously. Reality is broken here."
	return entries

/datum/story_theme/wizard/get_loot_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Found storage containers of 'sunscreen'. Analyzed it magically - it's just paste. Mundanes are strange."
		if("desert planet")
			entries += "Recovered tools that could serve as improvised foci. Not elegant, but functional in an emergency."
		if("frozen planet")
			entries += "The preserved supplies include something called 'hot cocoa mix'. Acceptable substitute for warming potions."
		if("grass planet")
			entries += "Standard mundane supplies. I've enchanted several items for my convenience. The stapler now never jams."
		if("jungle planet")
			entries += "Most supplies ruined by moisture, but I found sealed containers of acceptable quality. Preservation charms would have helped them."
		if("lava planet")
			entries += "Heat-resistant containers yielded useful materials. The mundanes were prepared for the environment, at least."
		if("wasteland planet")
			entries += "Scavenged various objects of questionable origin. Some register as magically inert; others... don't."
		if("unknown planet")
			entries += "The artifacts here defy analysis. They're not magical, not technological, but something else entirely."
	return entries

/datum/story_theme/wizard/get_main_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("Geode")
			entries += "The crystal formation - this 'geode' - resonates with arcane frequencies. The mundanes would call it 'pretty.' I call it a potential focus nexus."
			entries += "Examined the geode from a distance. The crystals contain trace amounts of solidified mana. Natural, but valuable for reagent harvesting."
			entries += "These crystal caves predate mundane settlement. The leylines flow through them like blood through veins. Sacred ground, in its way."
		if("Crashed Tradeship")
			entries += "A mundane vessel lies broken in the distance. No magical defenses - typical. Their 'technology' failed them, as it always will."
			entries += "Scried the tradeship wreckage for useful components. Found mundane supplies but also... curious. Some items register faintly on magical sensors."
			entries += "The crashed vessel's crew are long gone. Their spirits have moved on - I checked. Whatever cargo remains is fair salvage for a resourceful wizard."
		if("Crashed Pod")
			entries += "An escape capsule. Someone fled something in great haste. The fear-residue is palpable even to mundane senses."
			entries += "The pod's occupant escaped something. Or tried to. Divination shows only panic and darkness. Best left alone."
			entries += "Small vessel, desperate flight. The mundanes' survival instincts are admirable, even if their execution is lacking."
		if("Abandoned Digsite")
			entries += "An excavation site. The mundanes were digging for... something. Mineral wealth, most likely. Blind to the magical significance of what lies beneath."
			entries += "The digsite sits atop a minor leyline intersection. Did they sense it somehow? Or pure coincidence? With mundanes, one never knows."
			entries += "Archaeologists or miners - the distinction matters little. They disturbed old ground and awakened older things. Foolish."
		if("Alien Hive")
			entries += "Xenomorph nest detected. These creatures are resistant to most magic - their biology is inherently anti-thaumaturgic. The Federation has... theories."
			entries += "The hive structure pulses with a kind of proto-consciousness. Not true intelligence, but something the mundanes' science cannot explain. We can."
			entries += "AVOID. The creatures within are immune to charm, resistant to fire, and entirely hostile. Even my defensive wards may not hold against a swarm."
		if("The Buried Bar")
			entries += "A tavern, buried beneath the earth. The mundanes' need for intoxicants persists even at the edge of known space. Consistent, at least."
			entries += "The bar's cellar contains surprisingly potent spirits. Alchemically speaking, some of these could substitute for proper reagents. In an emergency."
			entries += "Spent an hour in the buried tavern. The silence was meditative. Also, their whiskey selection was... acceptable. For mundane production."
		if("Cult Base")
			entries += "A place of worship - but not to any deity the Federation recognizes. The residual energies are chaotic, dangerous. Amateur ritualists at best."
			entries += "The cult structure shows evidence of blood magic. Crude but effective. Whoever practiced here touched something real. And paid for it."
			entries += "I've cleansed the cult site's most dangerous artifacts. The Federation would not approve of what they were summoning. Neither do I."
	return entries

/datum/story_theme/wizard/get_stashed_loot_entries()
	var/list/entries = list()
	switch(stashed_loot_type)
		if(/datum/loot_table/weighted/bureaucracy)
			entries += "Gathered the mundanes' papers and writing implements. Their record-keeping is obsessive but occasionally useful."
			entries += "Stashed documentation materials. If I must communicate in writing rather than telepathy, these will serve."
		if(/datum/loot_table/weighted/combat)
			entries += "Secured some of their primitive weapons. When magic fails, even a wizard must improvise."
			entries += "Hidden combat supplies nearby. The Art is powerful, but sometimes a mundane solution has its merits."
		if(/datum/loot_table/decoration)
			entries += "Collected items for my meditation space. Aesthetics influence magical focus more than mundanes realize."
			entries += "Secured decorative pieces. A wizard's sanctum should reflect their power and taste."
		if(/datum/loot_table/engineering)
			entries += "Their tools are crude but functional. Cached them in case the equipment fails and magic cannot substitute."
			entries += "Mundane repair supplies secured. Even my enchantments sometimes require... mechanical assistance."
		if(/datum/loot_table/entertainment)
			entries += "Found the mundanes' amusements. Their concept of 'fun' is peculiar but occasionally diverting."
			entries += "Secured recreational materials. Even a wizard needs respite from the demands of the Art."
		if(/datum/loot_table/weighted/exotic)
			entries += "Most interesting! Exotic materials that resonate with arcane frequencies. Secured for detailed study."
			entries += "Unusual artifacts cached safely. These show magical potential the mundanes never recognized."
		if(/datum/loot_table/weighted/medical)
			entries += "Healing supplies secured. Potions are preferable, but mundane medicine will do in emergencies."
			entries += "Medical cache established. Even my constitution spells cannot heal everything."
		if(/datum/loot_table/module)
			entries += "Electronic matrices that almost function like spell components. Secured for experimentation."
			entries += "Their 'AI modules' bear curious similarity to binding circles. Fascinating. Cached for study."
		if(/datum/loot_table/weighted/structure)
			entries += "Building materials set aside. Manual construction is tedious, but sometimes transmutation isn't worth the spell slots."
			entries += "Structural supplies cached. Reinforcing this shelter is prudent, magical or otherwise."
		if(/datum/loot_table/trash)
			entries += "Even refuse can have value. Certain components work surprisingly well as improvised spell foci."
			entries += "Sorted through the debris. The mundanes discard things that a resourceful wizard can still use."
	return entries

/datum/story_theme/wizard/get_disease_entry(var/disease_form)
	var/list/entries = list()
	switch(disease_form)
		if("Virus")
			entries = list(
				"A mundane ailment has somehow bypassed my arcane defenses. The fever interferes with spellcasting. Unacceptable.",
				"Viral infection. My immune enhancement charms have failed. The Art requires a clear mind - this illness denies me that.",
				"The virus spreads through my system faster than my restoration cantrips can contain it. Most vexing.",
				"Attempted to transmute the virus into something harmless. Partial success. I am now host to a very confused pathogen."
			)
		if("Bacteria")
			entries = list(
				"Bacterial contamination in a minor wound. My healing magic keeps it contained but cannot eliminate it. The infection persists.",
				"The mundane world has its own forms of corruption. This bacterial invasion is proving... stubbornly resistant to magical treatment.",
				"Infection spreading despite my best purification rituals. Perhaps the bacteria here are simply too alien for standard cleansing magic.",
				"The wound festers. Even a wizard's flesh is merely flesh. A humbling reminder."
			)
		if("Parasite")
			entries = list(
				"Something has taken residence within me. Not a familiar - far less pleasant. A parasitic entity defying magical expulsion.",
				"The creature feeds on my magical essence as well as my physical nutrients. This is... professionally embarrassing.",
				"Attempted to communicate with the parasite telepathically. It does not think. It only hungers. Concerning.",
				"The parasite is immune to transformation magic. I tried to turn it into something beneficial. It turned my spell inward. Clever, for a worm."
			)
		if("Prion")
			entries = list(
				"My thoughts... scatter like startled birds. The mental disciplines of the Federation are failing me.",
				"Something is wrong with my mind. Spells I've known for decades slip away mid-casting. This is not natural forgetting.",
				"The disease attacks thought itself. Magic requires will and focus. Both are... fragmenting.",
				"If this journal becomes incoherent, know that [character_name] fought to the last. The mind... the mind is the wizard. Without it..."
			)
		if("Fungus")
			entries = list(
				"Fungal growth has taken root despite my wards. The spores must have been magically inert until germination. Clever adaptation.",
				"The mycelium spreads beneath my skin like roots seeking water. Nature magic might commune with it. I dare not try.",
				"Attempted to burn it away with controlled fire magic. It absorbed the energy. The fungus is now slightly luminescent. Not helpful.",
				"The mushrooms have a faint magical aura now. They're learning from me. When I die, this planet may have its first magical fungal colony. Small consolation."
			)
		else
			entries = list(
				"An illness has taken hold that defies magical classification. Neither curse nor hex nor mundane disease. Something new.",
				"My body fails while my magic remains strong. The irony is not lost on me. I could level mountains but cannot cure a cough.",
				"The Federation's healing arts are meant for magical afflictions. This... this is something else entirely.",
				"Sick. Weakening. The portal home remains incomplete. Perhaps this is fitting - a wizard's hubris undone by a simple pathogen."
			)
	return pick(entries)
