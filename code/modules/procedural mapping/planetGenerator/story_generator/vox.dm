/datum/story_theme/vox
	name = "vox"
	theme_flag = STORY_VOX
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/humanoid/vox,
		/mob/living/simple_animal/hostile/humanoid/vox/spaceraider
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/vox,
		/obj/effect/landmark/corpse/vox/spaceraider
	)

/datum/story_theme/vox/generate_character_name()
	if(vox_name_syllables?.len)
		var/vox_name = ""
		for(var/i in 1 to rand(2, 4))
			vox_name += pick(vox_name_syllables)
		character_name = capitalize(vox_name)
	else
		character_name = "Kititaki"
	return character_name

/datum/story_theme/vox/get_log_info()
	return list("title" = "TRADE MANIFEST AND NOTES", "subtitle" = "Trader: [character_name]")

/datum/story_theme/vox/get_generic_entries()
	return list(
		"SKREE! Ship damaged in asteroid field. Emergency landing on '[planet_name]'. Cargo intact - most important! Found abandoned softskin facility. Good shelter for repairs.",
		"Softskins leave much behind! Silly creatures, not understanding value. Found data on '[tech_name]' - very valuable! Arkships will pay many shiny things!",
		"Planet has many resources. Cataloguing for future trade expeditions. Softskin technology crude but functional. SKREE!",
		"[character_name] is clever trader, yes yes! Found more '[tech_name]' data. Will fetch good price from the right buyer.",
		"Ship repairs progressing. Found useful parts in softskin garbage. What they throw away! [character_name] finds treasure in trash!",
		"Local creatures are annoying. Keep trying to eat [character_name]'s supplies. Have set traps. Will eat THEM instead. Fair trade!",
		"Discovered softskin personal items. Shiny metals, pretty rocks. Good trade goods! Softskins love their shinies almost as much as Vox.",
		"The Arkships would approve of this salvage operation. Nothing wasted! Everything has value to clever Vox eyes.",
		"More '[tech_name]' equipment found. Some broken, some working. All valuable to right buyer. SKREE SKREE!",
		"Softskin facility has good air. Good water. Could make trading post here. [character_name] claims this territory for future trade!",
		"Found softskin medicine. Tastes terrible but might be valuable. Packing everything. Take all, sort later!",
		"Big problem! Local predators found [character_name]'s nest. Many teeth, very aggressive. Ship repairs incomplete.",
		"Ship repaired! Loading salvage now. This planet good for future trading post maybe. [character_name] returns to the stars!",
		"If other Vox find this - take the data, sell it well, tell tales of [character_name] the Brave! Profit awaits! SKREEEEE!",
		"Softskin corpses found in back room. Old, dried out. [character_name] takes their boots - no longer need them, yes?",
		"Strange noises at night. Local beasts circling camp. [character_name] sleeps with talons ready. Good Vox always prepared!",
		"Found softskin 'entertainment' devices. Moving pictures! Very distracting. Must focus on salvage, not silly stories.",
		"Weather on this rock is unpredictable. Rain, then sun, then more rain. Softskins built well - roof holds!",
		"Discovered cache of nitrogen! Perfect for Vox breathing. This planet more valuable than first thought!",
		"Other Vox would laugh at [character_name]'s situation. Crashed, alone, surrounded by junk. But junk is VALUABLE junk!",
		"Softskin security systems still partially active. Had to disable several. Their passwords are laughably simple.",
		"Found a functioning communication array! Tried to contact Arkships but too far. Signal too weak. Will try again."
	)

/datum/story_theme/vox/get_weather_entries()
	var/list/entries = list()
	switch(planet_style)
		if("lava planet")
			entries += "TOO HOT! Feathers singed! Softskins were crazy to build here. But [character_name] is crazier - good salvage worth burnt feathers!"
			entries += "The fire-rock flows make travel dangerous. Must plan routes carefully. Time is money, but death is expensive!"
		if("frozen planet")
			entries += "COLD! [character_name]'s crest is frostbitten. Need better insulation. Softskins left warm clothes - wearing ALL of them!"
			entries += "Ice everywhere. Pretty but annoying. Makes carrying salvage slippery. [character_name] has fallen many times. Dignity is temporary!"
		if("desert planet")
			entries += "Sand in EVERYTHING. In feathers, in food, in ship parts. Sand is worst trade good. Cannot sell sand!"
			entries += "Water scarce. Softskins left bottles - drinking their leftovers. Disgusting but necessary. SKREE."
		if("jungle planet")
			entries += "Wet wet WET. Feathers waterlogged. Hard to fly. Hard to climb. Everything grows too fast here!"
			entries += "Plants eating the facility! Nature wants softskin stuff back. [character_name] wants it MORE. Racing plants for salvage!"
		if("wasteland planet")
			entries += "Radiation bad for feathers. Molting in strange patterns. Will grow back. Probably. SKREE of concern."
			entries += "Dead world, but not dead salvage! Softskins leave things behind even in apocalypse. Predictable creatures."
		if("beach planet")
			entries += "Salt water bad for equipment! Everything rusts. [character_name] coating salvage in grease. Messy but necessary!"
			entries += "Waves take things! Lost three crates to tide. Ocean is bad trader. No negotiation. Very unfair. SKREE!"
		if("grass planet")
			entries += "Nice planet! Good weather, easy travel. Softskins picked well. Now [character_name] picks their pockets! Fair exchange!"
			entries += "Open spaces make [character_name] nervous. Prefer tight spaces. But salvage must be collected. Courage for profit!"
		if("unknown planet")
			entries += "This planet is WEIRD. Strange lights, strange sounds. Even strange smells. But strange means rare. Rare means valuable!"
			entries += "Nothing makes sense here. [character_name] does not need to understand - only needs to TAKE. SKREE!"
	return entries

/datum/story_theme/vox/get_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("bunker")
			entries += "Strong walls! Softskins built to last. Now [character_name] has fortress. And everything inside fortress is [character_name]'s!"
			entries += "Many weapons here. Softskins were paranoid. Good for [character_name] - weapons sell well. SKREE of greed!"
		if("cabin")
			entries += "Small nest, but cozy. [character_name] has decorated with shinies. Home away from Arkship!"
			entries += "Softskin lived simply here. Simple softskin, simple salvage. But every bit of salvage adds up!"
		if("hoarder den")
			entries += "ANOTHER HOARDER! Softskin after [character_name]'s own heart! So much STUFF! Beautiful chaos of junk!"
			entries += "This softskin understood value! Everything saved, nothing wasted. [character_name] respects this. Takes everything in their memory!"
		if("camp")
			entries += "Basic nest. Softskins lived rough here. [character_name] has lived rougher. This is almost comfortable!"
			entries += "Temporary shelter, permanent salvage! Softskins moved on but left goods behind. Their loss, [character_name]'s gain!"
		if("workshop")
			entries += "TOOLS! Beautiful tools! Can fix ship properly now! Softskins had good taste in equipment!"
			entries += "Workshop is best find! [character_name] can repair, rebuild, re-purpose. Everything becomes more valuable!"
		if("listening post")
			entries += "Communications equipment! Can boost signal to Arkships! Will trade this location for rescue fee!"
			entries += "Softskins listened to space chatter here. Now [character_name] listens. Hear interesting things. Profitable things!"
	return entries

/datum/story_theme/vox/get_fauna_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Shell-creatures taste good! Finally, decent food on this rock! [character_name] is adequate cook. Survival skill!"
		if("desert planet")
			entries += "Scaly things watch from rocks. [character_name] watches back. We have understanding. They don't eat me, I don't eat them. Yet."
		if("frozen planet")
			entries += "Furry predators circle camp at night. [character_name] has set traps. Fur sells well, yes yes!"
		if("grass planet")
			entries += "Many creatures here! Some dangerous, some delicious, some both! [character_name] learning which is which. Painfully sometimes."
		if("jungle planet")
			entries += "Jungle FULL of things! Half want to eat [character_name], half [character_name] wants to eat! Fair distribution!"
		if("lava planet")
			entries += "How do things LIVE here?! [character_name] is impressed and horrified. Everything here is survivor. Respect."
		if("wasteland planet")
			entries += "Twisted creatures roam the wastes. Ugly but persistent. Like [character_name]! We have solidarity in ugliness!"
		if("unknown planet")
			entries += "Cannot identify ANY of these creatures! New species? New trade goods! The Arkships will pay for samples! SKREE!"
	return entries

/datum/story_theme/vox/get_loot_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Softskins brought fun stuff to beach! Useless to them now. [character_name] will find buyers. Fun sells!"
		if("desert planet")
			entries += "Tools and equipment! Dry climate preserved well. Quality salvage! SKREE of satisfaction!"
		if("frozen planet")
			entries += "Everything frozen but intact! Like natural preservation! Softskins' loss is perfect salvage for [character_name]!"
		if("grass planet")
			entries += "Standard softskin junk. But standard junk is reliable income! Cannot complain about reliable profit!"
		if("jungle planet")
			entries += "Humidity ruined much. But sealed containers saved best stuff! Softskins knew to protect valuables!"
		if("lava planet")
			entries += "Heat-proof containers full of goodies! Softskins prepared for environment! Now [character_name] benefits!"
		if("wasteland planet")
			entries += "War supplies! Softskins love their weapons. [character_name] loves their weapons too. Love is sharing! SKREE!"
		if("unknown planet")
			entries += "Strange artifacts! Unknown value! Could be worthless, could be PRICELESS! [character_name] takes ALL. Sort later!"
	return entries

/datum/story_theme/vox/get_main_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("Geode")
			entries += "SHINY ROCKS! Big cave of SHINY ROCKS! [character_name] must have them! Softskins pay STUPID prices for pretty crystals! SKREE of greed!"
			entries += "The crystal cave is BEAUTIFUL! Almost as beautiful as profit! [character_name] filled pockets with samples! Heavy pockets, happy trader!"
			entries += "Crystals this size are RARE! The Arkships will trade MUCH for these! [character_name] claims this geode for Vox commerce! SKREE SKREE!"
		if("Crashed Tradeship")
			entries += "Another trader's misfortune! Sad for them, GOOD for [character_name]! Cargo is cargo, yes yes! Finders keepers!"
			entries += "The crashed ship has LOTS of stuff! Softskin trade goods scattered everywhere! Free merchandise! Best kind of merchandise!"
			entries += "Salvage rights claimed! [character_name] was here FIRST! Other Vox can find their own crashed ships! This one is MINE!"
		if("Crashed Pod")
			entries += "Tiny crashed ship! Not much salvage, but [character_name] takes EVERYTHING! Small salvage adds up! Mathematics of trade!"
			entries += "Escape pod means bigger ship somewhere! [character_name] must find bigger ship! More salvage potential! SKREE of excitement!"
			entries += "Poor softskin in tiny pod. Didn't make it. [character_name] takes their boots. They don't need boots anymore, yes?"
		if("Abandoned Digsite")
			entries += "Softskins were DIGGING! For treasure maybe? [character_name] will finish digging! Whatever they found belongs to [character_name] now!"
			entries += "Mining equipment! VALUABLE mining equipment! Left behind like garbage! Softskins are WASTEFUL! [character_name] is GRATEFUL! SKREE!"
			entries += "The dig site has tools, materials, maybe ore! [character_name] will take EVERYTHING! Strip it clean! Nothing left for other traders!"
		if("Alien Hive")
			entries += "SCARY NEST THING! [character_name] stays AWAY! Far away! No trade with bug-monsters! Only death with bug-monsters! SKREE of fear!"
			entries += "The hive is BAD BUSINESS! Vox know when to trade and when to RUN! This is running time! Very fast running time!"
			entries += "Bug-creature territory marked on [character_name]'s maps! Will warn other Vox! Bad trade zone! AVOID! AVOID!"
		if("The Buried Bar")
			entries += "Underground drinking place! Softskins love their poison-water! [character_name] investigates for trade goods! Bottles sell well!"
			entries += "The buried bar has MANY bottles! Some full! Very valuable! Softskins pay MUCH for their favorite poisons! [character_name] takes ALL!"
			entries += "Spent time in softskin bar. Strange place. Good for hiding salvage! Secret stash location found! [character_name] is clever!"
		if("Cult Base")
			entries += "Spooky softskin place! Bad energy! But [character_name] checks anyway - cult people have WEIRD stuff! Weird stuff sells!"
			entries += "The cult building has strange objects! [character_name] doesn't understand them! But SOMEONE will buy them! Everything has buyer!"
			entries += "Creepy drawings and robes and things. [character_name] takes the shiny bits, leaves the creepy bits. Good trade sense!"
	return entries

/datum/story_theme/vox/get_stashed_loot_entries()
	var/list/entries = list()
	switch(stashed_loot_type)
		if(/datum/loot_table/weighted/bureaucracy)
			entries += "Papers and writing things! Not valuable but softskins LOVE paperwork! Good trade goods! Stashed! SKREE!"
			entries += "[character_name] keeps documents organized! Proof of salvage rights! Very official! Very legal!"
		if(/datum/loot_table/weighted/combat)
			entries += "WEAPONS! Very valuable! [character_name] hides them well! Softskins pay TOP PRICE for weapons! SKREE of joy!"
			entries += "Combat gear stashed in secret spot! Self-defense AND trade goods! [character_name] is clever!"
		if(/datum/loot_table/decoration)
			entries += "Shiny pretty things! [character_name] LOVES shinies! Stashed the best ones! Mine mine MINE!"
			entries += "Decorations cached! Softskins pay stupid prices for decorative things! [character_name] will profit!"
		if(/datum/loot_table/engineering)
			entries += "TOOLS! Beautiful tools! [character_name] stashes for ship repairs! And for selling extras! Win-win!"
			entries += "Engineering supplies hoarded carefully! Every tool is valuable! Every part has price!"
		if(/datum/loot_table/entertainment)
			entries += "Fun things! Games! Toys! Good for long space trips! [character_name] keeps the best ones! SKREE!"
			entries += "Entertainment stashed! Morale is important! Also: children pay for toys! Parents pay MORE!"
		if(/datum/loot_table/weighted/exotic)
			entries += "MYSTERIOUS THINGS! Could be very valuable! Could be worthless! Gambling is exciting! All stashed!"
			entries += "Exotic goods cached! The Arkships will know what these are worth! [character_name] patient! (Not really!)"
		if(/datum/loot_table/weighted/medical)
			entries += "Medicine! Very valuable in space! [character_name] stashes carefully! Health is wealth! SKREE!"
			entries += "Medical supplies hoarded! Vox traders always need medicine! Sell to stations! Good profit!"
		if(/datum/loot_table/module)
			entries += "Electronic brain-things! [character_name] doesn't understand them! But softskins pay well! STASHED!"
			entries += "AI modules cached! Very technical! Very confusing! Very PROFITABLE! [character_name] trusts market!"
		if(/datum/loot_table/weighted/structure)
			entries += "Building stuff! Could use for ship repairs! Could use for trading post! Could just sell! Options!"
			entries += "Construction materials hoarded! Always useful! Never worthless! [character_name] knows value!"
		if(/datum/loot_table/trash)
			entries += "Even garbage has value! Scrap metal! Spare parts! Softskins wasteful! [character_name] resourceful!"
			entries += "Sorted through junk! Found GOOD junk! Stashed GOOD junk! Bad junk thrown away! Efficiency!"
	return entries

/datum/story_theme/vox/get_disease_entry(var/disease_form)
	var/list/entries = list()
	switch(disease_form)
		if("Virus")
			entries = list(
				"SKREE! [character_name] has the sicks! Fever making feathers droop! Bad trade! Did not sign up for virus!",
				"Softskin virus got into [character_name]! Vox immune system fighting! SKREE of anger at tiny invaders!",
				"Sneezing on the salvage! Unprofessional! [character_name] quarantines self. Virus bad for business!",
				"The Arkships have medicine for this. The Arkships are FAR AWAY. [character_name] must wait. And sneeze. SKREE."
			)
		if("Bacteria")
			entries = list(
				"Wound got infected! Bacteria from this stupid planet! [character_name] should have been more careful with sharp salvage!",
				"Green stuff coming from cut. Not good green. Bad green. Infection green. SKREE of medical concern!",
				"Bacterial infection spreading! Vox bodies fight hard but need proper medicine! This planet has NO proper medicine!",
				"[character_name] tried softskin antibiotics. Taste TERRIBLE. Work... maybe? Feathers still falling out though!"
			)
		if("Parasite")
			entries = list(
				"Something LIVING in [character_name]'s stomach! Not food! INVADER! How dare! SKREE of violated digestion!",
				"Ate wrong thing. Now wrong thing living in [character_name]. Parasites are THIEVES! Stealing MY nutrients!",
				"Parasite getting bigger! [character_name] getting thinner! This is NOT fair trade! EVICTION NOTICE to belly creature!",
				"The worm thinks it owns [character_name]'s insides. WRONG. [character_name] will outlast stupid worm! Probably! SKREE!"
			)
		if("Prion")
			entries = list(
				"[character_name] forgot... forgot what [character_name] forgot. Bad sign. Brain not working right. SKREE?",
				"Words hard to find. Trade math getting wrong. [character_name] is GOOD at trade math. Something broken in head.",
				"The Arkships... what are... no, [character_name] remembers. The Arkships. Home. Memory slipping like bad grip on salvage.",
				"If other Vox find this... [character_name] was good trader. Brain going bad now. Remember [character_name] kindly. SKREE... of sad."
			)
		if("Fungus")
			entries = list(
				"MUSHROOMS ON FEATHERS! [character_name] is not a garden! OFF! OFF OFF! SKREE of fungal horror!",
				"Spores got under scales. Itchy! Burny! Growing! [character_name] tried to pluck them. BAD IDEA. More grew back!",
				"[character_name] becoming fuzzy in wrong places. Fungus spreading. Not cute fuzzy. Scary fuzzy. Medical emergency!",
				"The fungus glows at night now. [character_name] is a nightlight. WORST UPGRADE. Did not want! SKREE!"
			)
		else
			entries = list(
				"[character_name] sick with mystery illness! Softskin diseases make no sense! Vox bodies NOT designed for this planet!",
				"Bad sicks. Very bad sicks. [character_name] needs real Vox medicine, not softskin garbage remedies!",
				"Getting weaker. Salvage piling up but [character_name] too sick to move it. WASTE! Being sick is EXPENSIVE!",
				"If [character_name] dies here, other Vox take the salvage. Fair is fair. But [character_name] would rather NOT DIE! SKREE!"
			)
	return pick(entries)
