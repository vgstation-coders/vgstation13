/datum/story_theme
	var/name = "base"
	var/theme_flag = STORY_NT
	var/list/hostile_mobs = list()
	var/list/corpse_types = list()
	var/character_name = ""

	var/list/generic_entries = list() // Random entries not tied to specific planet gen content
	var/list/weather_entries = list() // Responses to climate types
	var/list/ruin_entries = list() // Responses to the ruin this story is in
	var/list/fauna_entries = list() // Responses to local wildlife
	var/list/loot_entries = list() // Responses to loot/resource finds
	var/list/other_ruin_entries = list() // Responses to other ruins on the planet
	var/list/stashed_loot_entries = list() // Responses to stashed loot
	var/disease_log_entry = null // Disease-related log entry

	var/planet_name = ""
	var/planet_style = ""
	var/tech_name = ""
	var/tech_level = 0
	var/ruin_name = ""
	var/secondary_character_name = ""
	var/stashed_loot_type = null

/datum/story_theme/proc/generate_character_name()
	var/first = pick(prob(50) ? first_names_male : first_names_female)
	return "[first] [pick(last_names)]"

/datum/story_theme/proc/generate_secondary_character_name()
	return generate_character_name()

/datum/story_theme/proc/generate_log(var/p_name, var/p_style, var/t_name, var/t_level, var/r_name)
	planet_name = p_name
	planet_style = p_style
	tech_name = t_name
	tech_level = t_level
	ruin_name = r_name

	if(!character_name)
		character_name = generate_character_name()

	var/list/entry_pool = build_entry_pool()
	var/list/log_info = get_log_info()

	return build_log_from_pool(entry_pool, log_info["title"], log_info["subtitle"])


/datum/story_theme/proc/get_log_info()
	return list("title" = "RECOVERED LOG", "subtitle" = "Unknown Author")

/datum/story_theme/proc/build_entry_pool()
	var/list/entry_pool = list()

	entry_pool += get_generic_entries()

	entry_pool += get_weather_entries()
	entry_pool += get_ruin_entries()
	entry_pool += get_fauna_entries()
	entry_pool += get_loot_entries()
	entry_pool += get_main_ruin_entries()

	if(stashed_loot_type)
		entry_pool += get_stashed_loot_entries()

	if(disease_log_entry)
		entry_pool += disease_log_entry

	return entry_pool

/datum/story_theme/proc/get_generic_entries()
	return generic_entries.Copy()

/datum/story_theme/proc/get_weather_entries()
	var/list/entries = list()
	switch(planet_style)
		if("lava planet")
			entries += "The volcanic activity makes everything ten times harder. Heat shielding failures are a daily concern."
			entries += "Lava flows have cut off the northern section. Rerouting through the caves."
		if("frozen planet")
			entries += "The temperature dropped below -100C last night. Life support is struggling."
			entries += "Ice storms every few hours. Visibility goes to zero. We just hunker down and wait."
		if("desert planet")
			entries += "Water conservation is critical. Every drop counts out here."
			entries += "Sandstorms are relentless. The equipment is taking a beating from constant abrasion."
		if("jungle planet")
			entries += "The jungle never stops growing. I swear the vines move when you're not looking."
			entries += "Humidity is destroying our electronics. Everything needs constant maintenance."
		if("wasteland planet")
			entries += "Radiation levels are higher than projected. Had to adjust exposure schedules."
			entries += "The ruins here tell a story of catastrophe. Whatever happened, it was sudden and total."
		if("beach planet")
			entries += "The tropical climate is pleasant, but the salt air corrodes everything metal."
			entries += "Sacrificial anodes are a must in this environment. Replacing them weekly."
			entries += "High tide flooded the lower storage area. We've relocated supplies to higher ground."
		if("grass planet")
			entries += "The temperate weather is ideal for long-term habitation. Almost Earth-like conditions."
			entries += "Seasonal changes are more pronounced than expected. Preparing for what passes for winter here."
		if("unknown planet")
			entries += "Atmospheric readings fluctuate wildly. Our instruments can't make sense of the data."
			entries += "The environment here defies conventional understanding. Nothing behaves as it should."
	return entries

/datum/story_theme/proc/get_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("bunker")
			entries += "The bunker's defensive systems are holding up well. Reinforced construction was worth the extra expense."
			entries += "Weapons inventory complete. We're well-stocked for any contingency."
		if("cabin")
			entries += "The cabin provides adequate shelter. Basic, but it serves its purpose."
			entries += "Finally got the fireplace working properly. Small comforts matter out here."
		if("laboratory")
			entries += "Laboratory equipment calibrated and operational. Ready to begin primary research objectives."
			entries += "The lab setup here is exactly what we need for this work. Well-equipped facility."
		if("ufo")
			entries += "Ship systems nominal. All primary functions operating within parameters."
			entries += "Hull integrity holding. The vessel remains spaceworthy despite the landing."
		if("outpost")
			entries += "Outpost perimeter secure. All defensive systems armed and operational."
			entries += "Fortifications complete. This position is defensible against expected threat levels."
		if("workshop")
			entries += "Workshop tools and equipment inventory complete. Have everything needed for the job."
			entries += "Maintenance bay operational. Can handle repairs and fabrication as required."
		if("shrine")
			entries += "The sacred space is prepared. The rituals can proceed as planned."
			entries += "Consecration of the shrine is complete. This place resonates with the proper energies."
		if("greenhouse")
			entries += "Greenhouse environmental systems stable. Plants are thriving under current conditions."
			entries += "Agricultural yields exceeding projections. The hydroponic setup is working perfectly."
		if("camp")
			entries += "Base camp established. Not luxurious, but functional for our needs."
			entries += "Shelter construction complete. We're as settled as we're going to get out here."
		if("hoarder den")
			entries += "Organized my collection today. Everything has its place in my system."
			entries += "Salvage storage at capacity. Need to sort through and prioritize the valuable pieces."
		if("listening post")
			entries += "Communications array operational. Monitoring all designated frequencies as ordered."
			entries += "Signal intercepts logged and filed. The listening post is performing its function perfectly."
	return entries

/datum/story_theme/proc/get_fauna_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Observed several species of crabs along the shoreline. Mostly harmless as long as you do NOT snip them."
			entries += "The local wildlife includes some surprisingly intelligent capybaras. They seem curious about our presence."
			entries += "Encountered aggressive frogs near the wetlands. Their jumping reach is remarkable."
		if("desert planet")
			entries += "The desert lizards here are abundant. Most scatter when approached, but some hold their ground."
			entries += "Massive goliath-class creatures spotted in the distance. Avoiding direct contact."
			entries += "Strange insectoid life forms emerge at dusk. Classification pending."
		if("frozen planet")
			entries += "Pack of wolves spotted near the perimeter. They're watching us. Recommend staying inside after dark."
			entries += "Polar bears are active in this region. One investigated the camp last night. Security protocols updated."
			entries += "Encountered what the team is calling 'wendigos' - bipedal predators adapted to the cold. Extremely dangerous."
		if("grass planet")
			entries += "The grasslands support diverse herbivores - everything from cattle-like creatures to deer."
			entries += "Discovered aggressive cockatrice specimens. Their behavior suggests territorial nesting."
			entries += "Local fauna includes various domesticated species gone feral. The ecology here is fascinating."
		if("jungle planet")
			entries += "The jungle teems with life. Parrots, monkeys, and stranger things in the canopy."
			entries += "Poison dart frogs are common in the undergrowth. Specimens collected for study, with extreme caution."
			entries += "Spotted a large predatory cat - possibly a panther variant. It's been tracking us for two days."
		if("lava planet")
			entries += "Goliath-class megafauna dominate this hellscape. Their biology shouldn't work, but here they are."
			entries += "Basilisk creatures can somehow survive the heat. They burrow through rock like water."
			entries += "The local 'hivelords' are territorial and aggressive. Lost a drone to one yesterday."
		if("wasteland planet")
			entries += "The ruins are infested with roaches. Not the Earth variety - these are adapted to radiation."
			entries += "Reanimated corpses wander the wastes. Necromantic phenomenon or biological? Unclear."
			entries += "Whatever caused the apocalypse here, the survivors have mutated into something barely recognizable."
		if("unknown planet")
			entries += "Encountered autonomous drones of alien design. They ignore us unless we approach designated zones. They appear to be ancient."
			entries += "Strange polyp-like organisms dot the landscape. They react to movement with surprising hostility."
	return entries

/datum/story_theme/proc/get_loot_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Found crates of preserved food and beverages. Tropical rations, mostly. Better than nutrient paste."
			entries += "Salvaged entertainment equipment from storage - instruments, games, recreational items. Morale boost."
			entries += "Discovered clothing storage. Beach attire and linens. Impractical but clean."
		if("desert planet")
			entries += "Recovered engineering tools from the workshop. Standard maintenance equipment, well-preserved by the dry climate."
			entries += "Medical supplies found in sealed containers. The heat didn't compromise everything."
			entries += "Trash everywhere, but occasionally there's useful scrap metal in the debris."
		if("frozen planet")
			entries += "Found winter survival gear in the storage lockers. Insulated clothing, thermal equipment."
			entries += "Food stores are frozen solid. Perfectly preserved, ironically. We'll eat well."
			entries += "Salvaged cold-weather bedding and entertainment items. Small comforts in a frozen hell."
		if("grass planet")
			entries += "Storage areas contain standard colonist supplies - everything from bedding to paperwork."
			entries += "Found crates of clothing and personal effects. Someone was planning to stay long-term."
			entries += "Entertainment and food stores are intact. Games, instruments, preserved rations."
		if("jungle planet")
			entries += "Humidity ruined most paper goods, but sealed containers of food and supplies survived."
			entries += "Found entertainment equipment moldy but functional. Someone packed musical instruments."
			entries += "Salvaged clothing from sealed storage. Jungle-appropriate gear, thankfully."
		if("lava planet")
			entries += "Heat-resistant equipment caches located. Engineering tools, protective gear, specialized clothing."
			entries += "Found intact medical supplies in thermal containers. Someone knew what they were doing."
			entries += "AI modules discovered in shielded storage. Exotic tech, possibly valuable."
		if("wasteland planet")
			entries += "Scavenged bureaucratic records and combat equipment from the ruins. Mix of office supplies and weapons."
			entries += "Medical kits found in abandoned clinics. Some supplies still usable despite the decay."
			entries += "Structural salvage everywhere - broken vending machines, mystery tech. Junk with potential."
			if(prob(1)) //we do a little trolling
				for(var/obj/machinery/nuclearbomb/N in nuclear_bombs)
					if(N.z == 1)
						entries += "Discovered a paper with the numbers '[N.r_code]' scribbled on it. Might be important."
		if("unknown planet")
			entries += "Discovered ancient alien artifacts and exotic technology. Nothing in our databases matches this."
			entries += "Found caches of experimental equipment. Ancient technology, far beyond our understanding."
			entries += "Exotic loot scattered throughout. Crystals, strange devices, incomprehensible machinery from a distant past."
	return entries

/datum/story_theme/proc/get_main_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("Geode")
			entries += "Found a massive crystalline formation - a geode of incredible size. The crystals inside pulse with faint light."
			entries += "The geode structure is unlike anything in our databases. Natural formation or something else entirely?"
		if("Crashed Tradeship")
			entries += "Discovered a crashed trading vessel in the distance. Hull breached, cargo scattered. Someone had a very bad day."
			entries += "The tradeship wreckage might have salvageable goods. Marking location for potential investigation."
		if("Crashed Pod")
			entries += "Found an escape pod crash site. Small vessel, probably single occupant. No sign of survivors."
			entries += "The crashed pod's beacon is still transmitting weakly. Someone was trying to get rescued."
		if("Abandoned Digsite")
			entries += "An abandoned excavation site visible from here. Mining equipment left behind. They were looking for something."
			entries += "The digsite shows signs of hasty abandonment. Did they find what they were looking for, or find something else?"
		if("Alien Hive")
			entries += "WARNING: Detected what appears to be a xenomorph hive structure. Maintaining maximum distance."
			entries += "The alien hive is a death trap. Whatever lives there, we don't want to meet it."
		if("The Buried Bar")
			entries += "Spotted what looks like... a bar? Underground establishment, partially excavated. Someone had priorities."
			entries += "The buried bar must have been a miners' watering hole. Wonder if there's anything left to drink."
		if("Cult Base")
			entries += "Discovered a structure with disturbing iconography. Cult activity. Staying well clear of that place."
			entries += "The cult base radiates wrongness even from this distance. Whatever they were worshipping, I don't want to know."
	return entries

/datum/story_theme/proc/get_stashed_loot_entries()
	var/list/entries = list()
	switch(stashed_loot_type)
		if(/datum/loot_table/weighted/bureaucracy)
			entries += "Stashed some paperwork and office supplies against the wall. Never know when you'll need documentation out here."
			entries += "Put together a small cache of writing materials and folders. Organization keeps you sane."
		if(/datum/loot_table/weighted/combat)
			entries += "Hidden some weapons and defensive gear near the wall. Always have a backup plan."
			entries += "Stashed combat supplies in case things go south. Hope I never need them."
		if(/datum/loot_table/decoration)
			entries += "Set aside some decorative items to make this place feel more like home."
			entries += "Collected a few personal effects and stored them safely. Small comforts matter."
		if(/datum/loot_table/engineering)
			entries += "Put together an emergency tool kit and stashed it by the wall. Essential for repairs."
			entries += "Cached some engineering supplies. You can never have too many spare parts."
		if(/datum/loot_table/entertainment)
			entries += "Hid away some entertainment supplies for when the isolation gets to me."
			entries += "Stashed games and recreational items. Mental health is survival too."
		if(/datum/loot_table/weighted/exotic)
			entries += "Found some unusual items - stashed them safely for further study."
			entries += "Put aside some exotic materials I couldn't identify. Might be valuable."
		if(/datum/loot_table/weighted/medical)
			entries += "Set up a medical cache near the wall. First aid is always a priority."
			entries += "Stashed medical supplies for emergencies. Can't be too careful out here."
		if(/datum/loot_table/module)
			entries += "Secured some AI modules I found. Valuable tech worth protecting."
			entries += "Cached electronic modules for safekeeping. Delicate equipment."
		if(/datum/loot_table/weighted/structure)
			entries += "Stored some structural materials for future construction needs."
			entries += "Put aside building supplies. Might need to expand or reinforce."
		if(/datum/loot_table/trash)
			entries += "Even sorted through the garbage - you never know what's useful."
			entries += "Kept some salvageable items from the refuse pile. One person's trash..."
	return entries

/datum/story_theme/proc/get_disease_entry(var/disease_form)
	var/list/entries = list()
	switch(disease_form)
		if("Virus")
			entries = list(
				"Started feeling feverish today. Probably just the stress, but I should keep an eye on it.",
				"Came down with something nasty. Viral, most likely. Symptoms are getting worse.",
				"The sickness is spreading through my system. I don't have the right medicine here.",
				"Running a fever that won't break. This virus is tenacious."
			)
		if("Bacteria")
			entries = list(
				"Bacterial infection setting in. Should have been more careful with sanitation.",
				"The wound got infected. Bacteria spreading despite my best efforts to keep it clean.",
				"Fighting off some kind of bacterial bug. Need antibiotics, but supplies are limited.",
				"Infection is getting worse. The bacteria are winning this battle."
			)
		if("Parasite")
			entries = list(
				"Something's wrong inside me. I think I picked up a parasite from the local fauna.",
				"The parasitic infection is making it hard to keep food down. Getting weaker.",
				"Whatever's living inside me is getting stronger. I can feel it moving sometimes.",
				"Should have been more careful about what I ate. This parasite is draining me."
			)
		if("Prion")
			entries = list(
				"Memory lapses are getting more frequent. Something is very wrong.",
				"The confusion comes and goes. I write things down but forget why.",
				"Can't think straight anymore. The disease is in my brain, I'm sure of it.",
				"Neurological symptoms worsening. Prion disease, maybe. No cure for that."
			)
		if("Fungus")
			entries = list(
				"Fungal growth appearing on my skin. The spores must have gotten into my system.",
				"The fungal infection is spreading. It itches constantly and nothing helps.",
				"I can see the mycelium spreading under my skin. It's horrifying.",
				"The fungus is taking over. I've seen what happens to organic matter here."
			)
		else
			entries = list(
				"Contracted some kind of illness. Don't know what it is, but it's getting worse.",
				"Sickness is taking hold. Without proper medical facilities, prognosis isn't good.",
				"Whatever disease I've caught, it's not letting go easily.",
				"Health deteriorating. The pathogen is winning."
			)
	return pick(entries)

/datum/story_theme/proc/on_ruin_placed(var/turf/ruin_turf)
	return

/datum/story_theme/proc/get_planet_finding()
	switch(planet_style)
		if("grass planet")
			return pick("Soil samples indicate high nitrogen content conducive to agriculture.", "Native flora exhibits remarkable genetic diversity.", "Atmospheric composition nearly identical to Earth-standard.")
		if("jungle planet")
			return pick("Biodiversity index exceeds all previously catalogued worlds.", "Canopy layer contains unique photosynthetic compounds.", "Native fauna displays unusual aggression toward survey equipment.")
		if("lava planet")
			return pick("Geothermal activity provides abundant energy generation potential.", "Mineral deposits of unprecedented density detected.", "Thermal readings indicate unstable tectonic conditions.")
		if("frozen planet")
			return pick("Ice cores contain atmospheric data spanning millennia.", "Subterranean liquid water reservoirs confirmed.", "Native life adapted to extreme cold exhibits unique antifreeze proteins.")
		if("desert planet")
			return pick("Ancient riverbeds indicate significant climate change.", "Subsurface aquifers detected at significant depths.", "Solar radiation levels optimal for energy collection.")
		if("beach planet")
			return pick("Oceanic biodiversity rivals most catalogued water worlds.", "Tidal patterns indicate multiple lunar bodies.", "Water composition safe for human contact with filtration.")
		if("wasteland planet")
			return pick("Radiation levels elevated but within tolerable parameters.", "Urban ruins suggest catastrophic conflict or disaster.", "Scavenged technology indicates advanced pre-collapse civilization.")
		if("unknown planet")
			return pick("Sensor readings inconsistent with known physics.", "Native organisms defy standard biological classification.", "Discovered ancient structures of non-humanoid design.")
		else
			return pick("Standard geological surveys completed.", "Atmosphere within acceptable parameters.", "Resource deposits identified for potential extraction.")

// ============================================================================
// LOG BUILDING UTILITIES
// ============================================================================
/datum/story_theme/proc/get_log_dates()
	var/list/data = list()
	var/max_year = game_year + 1
	var/min_year = max_year - 200
	data["start_year"] = rand(min_year, max_year)
	data["start_month"] = rand(1, 12)
	data["start_day"] = rand(1, 28)
	data["years_old"] = max_year - data["start_year"]
	data["month_names"] = list("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
	return data

/datum/story_theme/proc/finalize_log(var/list/log_entries, var/years_old)
	log_entries += "<hr>"
	var/integrity = max(50, 99 - years_old / 4)
	log_entries += "<i>End of recovered journal. Data integrity: [integrity]%</i>"

	var/final_text = log_entries.Join("<br>")

	if(years_old > 20)
		final_text = corrupt_text(final_text, years_old)

	return final_text

/datum/story_theme/proc/build_log_from_pool(var/list/entry_pool, var/title, var/subtitle, var/num_entries = 0)
	if(!num_entries)
		num_entries = rand(4, 7)

	var/list/log_entries = list()
	var/list/dates = get_log_dates()

	log_entries += "<center><b>[title]</b></center>"
	log_entries += "<center><i>[subtitle]</i></center>"
	log_entries += "<hr>"

	var/current_day = dates["start_day"]
	var/current_month = dates["start_month"]
	var/current_year = dates["start_year"]
	var/list/month_names = dates["month_names"]

	var/list/available_entries = entry_pool.Copy()
	for(var/i in 1 to min(num_entries, available_entries.len))
		if(current_day > 28)
			current_day -= 28
			current_month++
		if(current_month > 12)
			current_month = 1
			current_year++

		log_entries += "<b>[month_names[current_month]] [current_day], [current_year]</b>"

		var/entry = pick_n_take(available_entries)
		log_entries += entry
		log_entries += ""

		current_day += rand(1, 31)

	return finalize_log(log_entries, dates["years_old"])

/datum/story_theme/proc/corrupt_text(var/text, var/years_old)
	var/effective_age = years_old - 20
	var/corruption_interval = max(50, 200 - effective_age)

	var/list/glitch_chars = list("^", "%", "&", "#", "@", "*", "~", "?", "!", "$")
	var/list/result = list()
	var/char_count = 0
	var/in_tag = FALSE

	for(var/i = 1 to length(text))
		var/char = copytext(text, i, i + 1)

		if(char == "<")
			in_tag = TRUE
		else if(char == ">")
			in_tag = FALSE

		if(!in_tag && char != " " && char != "\n" && char != "<" && char != ">")
			char_count++
			if(char_count % corruption_interval == 0)
				char = pick(glitch_chars)

		result += char

	return result.Join("")

// ============================================================================
// STORY THEMES
// ============================================================================

var/list/datum/story_theme/story_themes = list()

/proc/initialize_story_themes()
	if(story_themes.len)
		return
	for(var/theme_type in subtypesof(/datum/story_theme))
		var/datum/story_theme/ST = new theme_type()
		story_themes += ST

/proc/get_compatible_story_theme(var/ruin_theme_flags)
	initialize_story_themes()
	var/list/compatible = list()
	for(var/datum/story_theme/ST in story_themes)
		if(ruin_theme_flags & ST.theme_flag)
			compatible += ST
	if(!compatible.len)
		return null
	return pick(compatible)

/proc/get_ruins_for_theme(var/theme_flag)
	var/list/compatible = list()
	for(var/ruin_type in subtypesof(/datum/map_element/ruin/story))
		var/datum/map_element/ruin/story/R = ruin_type
		if(initial(R.theme) & theme_flag)
			compatible += ruin_type
	return compatible

// ============================================================================
// OLD DATABASE
// ============================================================================

/obj/machinery/old_database
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "blackbox_off"
	name = "Old Data Storage Unit"
	desc = "An ancient data storage unit from a forgotten era. It looks like it could still be operational with some effort."
	density = 1
	anchored = 1.0
	use_power = MACHINE_POWER_USE_NONE
	var/activated = FALSE
	var/activating = FALSE
	var/datum/story_theme/assigned_theme
	var/story_year = 0
	var/character_name = ""
	var/ruin_name = ""

/obj/machinery/old_database/examine(mob/user)
	..()
	if(activating)
		to_chat(user, "<span class='warning'>It is currently rebooting.</span>")
	else
		to_chat(user, "<span class='notice'>It is powered off. You can attempt to activate it to recover any stored data.</span>")

/obj/machinery/old_database/attack_hand(mob/user)
	if(..())
		return
	if(isobserver(user) && !isAdminGhost(user))
		to_chat(user, "<span class='warning'>Your ghostly limb passes right through \the [src].</span>")
		return

	if(activated)
		to_chat(user, "<span class='notice'>\The [src] has already been activated and its data retrieved.</span>")
		return
	if(activating)
		to_chat(user, "<span class='warning'>\The [src] is already in the process of rebooting!</span>")
		return

	activating = TRUE
	var/reboot_time = (map.nameShort == "odyssey") ? rand(2, 5) MINUTES : rand(5, 15) MINUTES

	visible_message("<span class='notice'>\The [src] begins to hum as [user] initiates the boot sequence...</span>")
	playsound(src, 'sound/machines/click.ogg', 50, 1)

	spawn(20)
		say("REBOOT SEQUENCE INITIATED. ESTIMATED TIME TO FULL SYSTEM RESTORATION: [round(reboot_time/10/60)] MINUTES.")
		say("PLEASE STAND BY...")

	spawn(reboot_time)
		complete_activation()

/obj/machinery/old_database/proc/complete_activation()
	if(activated)
		return

	activated = TRUE
	activating = FALSE
	icon_state = "blackbox"

	var/datum/virtual_z/vz = get_virtual_z()
	if(vz?.comms_relay.activate())
		say("PLANETARY RELAY LINK ESTABLISHED.")

	visible_message("<span class='notice'>\The [src] completes its boot sequence with a triumphant chime!</span>")
	playsound(src, 'sound/machines/ping.ogg', 50, 1)
	say("SYSTEM RESTORATION COMPLETE. GENERATING DATA ARCHIVE...")

	spawn(30)
		generate_data_disk()

/obj/machinery/old_database/proc/generate_data_disk()
	var/turf/T = get_turf(src)

	var/list/valid_techs = list(
		list("id" = Tc_MATERIALS, "name" = "Materials Research"),
		list("id" = Tc_ENGINEERING, "name" = "Engineering Research"),
		list("id" = Tc_PLASMATECH, "name" = "Plasma Research"),
		list("id" = Tc_POWERSTORAGE, "name" = "Power Storage Research"),
		list("id" = Tc_BLUESPACE, "name" = "Bluespace Research"),
		list("id" = Tc_BIOTECH, "name" = "Biological Research"),
		list("id" = Tc_COMBAT, "name" = "Combat Systems Research"),
		list("id" = Tc_MAGNETS, "name" = "Electromagnetic Research"),
		list("id" = Tc_PROGRAMMING, "name" = "Data Theory Research")
	)
	var/list/chosen_tech
	var/tech_level
	if(prob(50))
		chosen_tech = list("id" = Tc_EXPLORATION, "name" = "Exploration Research")
		tech_level = 1
	else
		chosen_tech = pick(valid_techs)
		tech_level = rand(2, 4)

	var/obj/item/weapon/disk/hdd/disk = new(T)
	disk.name = "Recovered Data Drive"
	disk.desc = "A hard disk drive recovered from an ancient planetary database. Contains valuable research data."
	disk.origin_tech = "[chosen_tech["id"]]=[tech_level]"

	var/planet_desc = "an unknown world"
	var/history_style = "standard"

	var/datum/virtual_z/vz = get_virtual_z()
	if(vz?.planet)
		var/datum/planet_type/ptype = vz.planet
		planet_desc = ptype.planet_name
		history_style = ptype.name

	var/obj/item/weapon/paper/journal = new(T)
	journal.name = "Recovered Research Journal"

	if(assigned_theme)
		assigned_theme.character_name = character_name
		assigned_theme.ruin_name = ruin_name
		journal.info = assigned_theme.generate_log(planet_desc, history_style, chosen_tech["name"], tech_level, ruin_name)
	else
		initialize_story_themes()
		var/datum/story_theme/random_theme = pick(story_themes)
		random_theme.generate_character_name()
		journal.info = random_theme.generate_log(planet_desc, history_style, chosen_tech["name"], tech_level, ruin_name)

	visible_message("<span class='notice'>\The [src] ejects a data drive and prints a journal!</span>")
	playsound(src, 'sound/machines/chime.ogg', 50, 1)
	say("DATA ARCHIVE GENERATED. [uppertext(chosen_tech["name"])] DATA RECOVERED.")

// ============================================================================
// STORY LANDMARK
// ============================================================================

/obj/effect/landmark/story
	name = "story character spawner"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	var/datum/story_theme/assigned_theme
	var/story_year = 0
	var/character_name = ""
	var/disease_type = null

/obj/effect/landmark/story/proc/spawn_story_entity()
	if(!assigned_theme)
		qdel(src)
		return

	if(prob(STORY_MISSING_CHANCE))
		qdel(src)
		return

	var/years_old = game_year - story_year
	var/turf/T = get_turf(src)
	var/mob/living/spawned_mob = null

	if(years_old <= STORY_RECENT_THRESHOLD)
		if(assigned_theme.hostile_mobs.len)
			var/mob_type = pick(assigned_theme.hostile_mobs)
			spawned_mob = new mob_type(T)
			if(character_name)
				spawned_mob.name = character_name
				spawned_mob.real_name = character_name
	else
		if(assigned_theme.corpse_types.len)
			var/corpse_type = pick(assigned_theme.corpse_types)
			new corpse_type(T)
			for(var/mob/living/M in T)
				if(character_name)
					M.name = character_name
					M.real_name = character_name
				spawned_mob = M
				break

	// Infect with disease if one was determined at setup time
	if(spawned_mob && disease_type)
		infect_story_character(spawned_mob)

	assigned_theme.on_ruin_placed(T)

	qdel(src)

/obj/effect/landmark/story/proc/infect_story_character(var/mob/living/M)
	if(!M || !assigned_theme || !disease_type)
		return

	var/datum/disease2/disease/D = new disease_type()

	var/list/strength_range = list(1, 100)
	var/list/robustness_range = list(1, 100)
	var/list/antigen_weights = list(
		ANTIGEN_BLOOD = 1,
		ANTIGEN_COMMON = 1,
		ANTIGEN_RARE = 1,
		ANTIGEN_ALIEN = (assigned_theme.planet_style == "unknown planet") ? 1 : 0
	)
	var/list/badness_weights = list(
		EFFECT_DANGER_HELPFUL = 1,
		EFFECT_DANGER_FLAVOR = 3,
		EFFECT_DANGER_ANNOYING = 3,
		EFFECT_DANGER_HINDRANCE = 2,
		EFFECT_DANGER_HARMFUL = 2,
		EFFECT_DANGER_DEADLY = 1
	)

	D.origin = "Story Generator"
	D.makerandom(strength_range, robustness_range, antigen_weights, badness_weights)

	var/disease_id = "[D.uniqueID]-[D.subID]"
	M.virus2[disease_id] = D
	D.log += "<br />[timestamp()] Infected [M.name] (Story Generator - spawned infected)"
