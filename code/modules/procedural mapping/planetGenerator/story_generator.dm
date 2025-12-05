#define STORY_NT		(1<<1)
#define STORY_WIZARD 	(1<<2)
#define STORY_NINJA 	(1<<3)
#define STORY_COMMANDO	(1<<4)
#define STORY_CLOWN		(1<<5)
#define STORY_MUSHROOM	(1<<6)
#define STORY_GREY		(1<<7)
#define STORY_VOX		(1<<8)
#define STORY_SYNDICATE	(1<<9)

/// Threshold in years - stories younger than this spawn hostile mobs, older spawn corpses
#define STORY_RECENT_THRESHOLD 50
/// Chance that a story landmark spawns nothing (body is missing)
#define STORY_MISSING_CHANCE 25

/**
 * # Story Theme Datum
 *
 * Contains all the data for a specific story theme including compatible ruins,
 * hostile mob types to spawn for recent stories, and corpse types for old stories.
 */
/datum/story_theme
	/// Name identifier matching one of the STORY_* flags
	var/name = "nanotrasen"
	/// The STORY_* flag for this theme
	var/theme_flag = STORY_NT
	/// List of hostile mob types that can spawn for recent stories
	var/list/hostile_mobs = list()
	/// List of corpse landmark types for old stories
	var/list/corpse_types = list()
	/// The generated character name for this story instance
	var/character_name = ""

/// Generate a character name appropriate for this theme
/datum/story_theme/proc/generate_character_name()
	if(first_names_male?.len && last_names?.len)
		var/first = pick(prob(50) ? first_names_male : first_names_female)
		character_name = "[first] [pick(last_names)]"
	else
		character_name = "Unknown"
	return character_name

/datum/story_theme/nanotrasen
	name = "nanotrasen"
	theme_flag = STORY_NT
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/humanoid/syndicate/melee,
		/mob/living/simple_animal/hostile/humanoid/syndicate/ranged
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

/datum/story_theme/ninja
	name = "ninja"
	theme_flag = STORY_NINJA
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/humanoid/syndicate/melee/space
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/syndicatecommando
	)

/datum/story_theme/ninja/generate_character_name()
	if(ninja_titles?.len && ninja_names?.len)
		character_name = "[pick(ninja_titles)] [pick(ninja_names)]"
	else
		character_name = "Shadow Warrior"
	return character_name

/datum/story_theme/commando
	name = "commando"
	theme_flag = STORY_COMMANDO
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/humanoid/syndicate/melee/space,
		/mob/living/simple_animal/hostile/humanoid/syndicate/ranged/space
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/syndicatecommando
	)

/datum/story_theme/commando/generate_character_name()
	if(commando_names?.len)
		character_name = "Commander [pick(commando_names)]"
	else
		character_name = "Commander Unknown"
	return character_name

/datum/story_theme/clown
	name = "clown"
	theme_flag = STORY_CLOWN
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/retaliate/clown
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/clown
	)

/datum/story_theme/clown/generate_character_name()
	if(clown_names?.len)
		character_name = pick(clown_names)
	else
		character_name = "Honkers McHonkface"
	return character_name

/datum/story_theme/mushroom
	name = "mushroom"
	theme_flag = STORY_MUSHROOM
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/mushroom
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/assistant  // No mushroom corpse exists, use generic
	)

/datum/story_theme/mushroom/generate_character_name()
	if(mush_first?.len && mush_last?.len)
		character_name = "[pick(mush_first)] [pick(mush_last)]"
	else
		character_name = "Sporeling Capsworth"
	return character_name

/datum/story_theme/grey
	name = "grey"
	theme_flag = STORY_GREY
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/humanoid/grey,
		/mob/living/simple_animal/hostile/humanoid/grey/prisoner/ranged,
		/mob/living/simple_animal/hostile/humanoid/grey/prisoner/melee
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/grey,
		/obj/effect/landmark/corpse/grey/researcher
	)

/datum/story_theme/grey/generate_character_name()
	if(grey_first_male?.len && grey_last?.len)
		character_name = "[pick(grey_first_male + grey_first_female)] [pick(grey_last)]"
	else
		character_name = "Zix'qua Vorn"
	return character_name

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

/// Global list of all story themes, populated at runtime
var/list/datum/story_theme/story_themes = list()

/proc/initialize_story_themes()
	if(story_themes.len)
		return
	for(var/theme_type in subtypesof(/datum/story_theme))
		var/datum/story_theme/ST = new theme_type()
		story_themes += ST

/**
 * Gets a random story theme that's compatible with a given ruin's theme flags
 *
 * Arguments:
 * * ruin_theme_flags - Bitfield of STORY_* flags the ruin supports
 *
 * Returns:
 * * A story_theme datum, or null if none compatible
 */
/proc/get_compatible_story_theme(var/ruin_theme_flags)
	initialize_story_themes()
	var/list/compatible = list()
	for(var/datum/story_theme/ST in story_themes)
		if(ruin_theme_flags & ST.theme_flag)
			compatible += ST
	if(!compatible.len)
		return null
	return pick(compatible)

/**
 * Gets all story ruins compatible with a given theme flag
 *
 * Arguments:
 * * theme_flag - A single STORY_* flag to match against
 *
 * Returns:
 * * A list of compatible /datum/map_element/ruin/story types
 */
/proc/get_ruins_for_theme(var/theme_flag)
	var/list/compatible = list()
	for(var/ruin_type in subtypesof(/datum/map_element/ruin/story))
		var/datum/map_element/ruin/story/R = ruin_type
		if(initial(R.theme) & theme_flag)
			compatible += ruin_type
	return compatible

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
	/// The assigned story theme datum (set by place_story_ruins)
	var/datum/story_theme/assigned_theme
	/// The year the story took place
	var/story_year = 0
	/// The character name from the story
	var/character_name = ""

/obj/machinery/old_database/attack_hand(mob/user)
	if(activated)
		to_chat(user, "<span class='notice'>\The [src] has already been activated and its data retrieved.</span>")
		return

	if(activating)
		to_chat(user, "<span class='warning'>\The [src] is already in the process of rebooting!</span>")
		return

	activating = TRUE
	// var/reboot_time = rand(5, 15) MINUTES
	var/reboot_time = 10 SECONDS

	visible_message("<span class='notice'>\The [src] begins to hum as [user] initiates the boot sequence...</span>")
	playsound(src, 'sound/machines/click.ogg', 50, 1)

	spawn(20)
		say("REBOOT SEQUENCE INITIATED. ESTIMATED TIME TO FULL SYSTEM RESTORATION: [reboot_time].")
		say("PLEASE STAND BY...")

	spawn(reboot_time)
		complete_activation()

/obj/machinery/old_database/proc/complete_activation()
	if(activated)
		return

	activated = TRUE
	activating = FALSE
	icon_state = "blackbox"

	var/turf/T = get_turf(src)
	var/datum/allocation/alloc = SSmapping.get_allocation(trf = T)

	// Find and activate the planetary relay
	if(istype(alloc))
		if(alloc.comms_relay.activate())
			say("PLANETARY RELAY LINK ESTABLISHED.")

	visible_message("<span class='notice'>\The [src] completes its boot sequence with a triumphant chime!</span>")
	playsound(src, 'sound/machines/ping.ogg', 50, 1)
	say("SYSTEM RESTORATION COMPLETE. GENERATING DATA ARCHIVE...")

	spawn(30)
		generate_data_disk()

/obj/machinery/old_database/proc/generate_data_disk()
	var/turf/T = get_turf(src)
	var/datum/allocation/alloc = SSmapping.get_allocation(trf = T)

	// Pick a random valid tech (excluding hidden/special techs)
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
	var/list/chosen_tech = pick(valid_techs)
	var/tech_level = rand(2, 4)

	// Generate the HDD with origin_tech
	var/obj/item/weapon/disk/hdd/disk = new(T)
	disk.name = "Recovered Data Drive"
	disk.desc = "A hard disk drive recovered from an ancient planetary database. Contains valuable research data."
	disk.origin_tech = "[chosen_tech["id"]]=[tech_level]"

	// Generate procedural description based on planet type
	var/planet_desc = "an unknown world"
	var/history_style = "standard"

	if(istype(alloc) && alloc.ptype)
		var/datum/planet_type/ptype = alloc.ptype
		planet_desc = ptype.planet_name
		history_style = ptype.name

	// Generate journal on paper
	var/obj/item/weapon/paper/journal = new(T)
	journal.name = "Recovered Research Journal"
	journal.info = generate_exploration_log(planet_desc, history_style, chosen_tech["name"], tech_level)

	visible_message("<span class='notice'>\The [src] ejects a data drive and prints a journal!</span>")
	playsound(src, 'sound/machines/chime.ogg', 50, 1)
	say("DATA ARCHIVE GENERATED. [uppertext(chosen_tech["name"])] DATA RECOVERED.")

/obj/machinery/old_database/proc/generate_exploration_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	// Use the assigned theme if available, otherwise pick a random one
	var/theme = "nanotrasen"
	if(assigned_theme)
		theme = assigned_theme.name
	else
		theme = pick("nanotrasen", "wizard", "ninja", "commando", "clown", "mushroom", "grey", "vox", "syndicate")

	switch(theme)
		if("wizard")
			return generate_wizard_log(planet_name, planet_style, tech_name, tech_level)
		if("ninja")
			return generate_ninja_log(planet_name, planet_style, tech_name, tech_level)
		if("commando")
			return generate_commando_log(planet_name, planet_style, tech_name, tech_level)
		if("clown")
			return generate_clown_log(planet_name, planet_style, tech_name, tech_level)
		if("mushroom")
			return generate_mushroom_log(planet_name, planet_style, tech_name, tech_level)
		if("grey")
			return generate_grey_log(planet_name, planet_style, tech_name, tech_level)
		if("vox")
			return generate_vox_log(planet_name, planet_style, tech_name, tech_level)
		if("syndicate")
			return generate_syndicate_log(planet_name, planet_style, tech_name, tech_level)
		else
			return generate_nanotrasen_log(planet_name, planet_style, tech_name, tech_level)

/// Generate a wizard name from the name lists (or use assigned name)
/obj/machinery/old_database/proc/get_wizard_name()
	if(character_name)
		return character_name
	if(wizard_first?.len && wizard_second?.len)
		return "[pick(wizard_first)] [pick(wizard_second)]"
	return "Merlin the Confused"

/// Generate a ninja name from the name lists (or use assigned name)
/obj/machinery/old_database/proc/get_ninja_name()
	if(character_name)
		return character_name
	if(ninja_titles?.len && ninja_names?.len)
		return "[pick(ninja_titles)] [pick(ninja_names)]"
	return "Shadow Warrior"

/// Generate a commando name from the name lists (or use assigned name)
/obj/machinery/old_database/proc/get_commando_name()
	if(character_name)
		return character_name
	if(commando_names?.len)
		return pick(commando_names)
	return "Agent Smith"

/// Generate a clown name from the name lists (or use assigned name)
/obj/machinery/old_database/proc/get_clown_name()
	if(character_name)
		return character_name
	if(clown_names?.len)
		return pick(clown_names)
	return "Honkers McHonkface"

/// Generate a mushroom name from the name lists (or use assigned name)
/obj/machinery/old_database/proc/get_mushroom_name()
	if(character_name)
		return character_name
	if(mush_first?.len && mush_last?.len)
		return "[pick(mush_first)] [pick(mush_last)]"
	return "Sporeling Capsworth"

/// Generate a grey name from the name lists (or use assigned name)
/obj/machinery/old_database/proc/get_grey_name()
	if(character_name)
		return character_name
	if(grey_first_male?.len && grey_last?.len)
		return "[pick(grey_first_male + grey_first_female)] [pick(grey_last)]"
	return "Zix'qua Vorn"

/// Generate a vox name from syllables (or use assigned name)
/obj/machinery/old_database/proc/get_vox_name()
	if(character_name)
		return character_name
	if(vox_name_syllables?.len)
		var/name = ""
		for(var/i in 1 to rand(2, 4))
			name += pick(vox_name_syllables)
		return capitalize(name)
	return "Kititaki"

/// Generate a standard NT researcher name (or use assigned name)
/obj/machinery/old_database/proc/get_researcher_name()
	if(character_name)
		return character_name
	if(first_names_male?.len && last_names?.len)
		var/first = pick(prob(50) ? first_names_male : first_names_female)
		return "[first] [pick(last_names)]"
	return "John Smith"

/// Helper to get date-related variables and corruption
/obj/machinery/old_database/proc/get_log_dates()
	var/list/data = list()
	var/max_year = game_year + 1
	var/min_year = max_year - 200
	data["start_year"] = rand(min_year, max_year)
	data["start_month"] = rand(1, 12)
	data["start_day"] = rand(1, 28)
	data["years_old"] = max_year - data["start_year"]
	data["month_names"] = list("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
	return data

/// Finalize log with corruption and footer
/obj/machinery/old_database/proc/finalize_log(var/list/log_entries, var/years_old)
	log_entries += "<hr>"
	var/integrity = max(50, 99 - years_old / 4)
	log_entries += "<i>End of recovered journal. Data integrity: [integrity]%</i>"

	var/final_text = log_entries.Join("<br>")

	// Only corrupt text for very old logs (20+ years)
	if(years_old > 20)
		final_text = corrupt_text(final_text, years_old)

	return final_text

/// Build a log from an entry pool - the core modular function
/obj/machinery/old_database/proc/build_log_from_pool(var/list/entry_pool, var/title, var/subtitle, var/years_old, var/num_entries = 0)
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

	// Shuffle and pick entries
	var/list/available_entries = entry_pool.Copy()
	for(var/i in 1 to min(num_entries, available_entries.len))
		// Add date
		if(current_day > 28)
			current_day -= 28
			current_month++
		if(current_month > 12)
			current_month = 1
			current_year++

		log_entries += "<b>[month_names[current_month]] [current_day], [current_year]</b>"

		// Pick and remove a random entry
		var/entry = pick_n_take(available_entries)
		log_entries += entry
		log_entries += ""

		current_day += rand(1, 5)

	return finalize_log(log_entries, years_old)

/// Standard Nanotrasen research log
/obj/machinery/old_database/proc/generate_nanotrasen_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	var/list/dates = get_log_dates()
	var/researcher_name = get_researcher_name()
	var/second_researcher = get_researcher_name()

	var/list/entry_pool = list(
		"Dr. [researcher_name], xenobiologist, reporting. This is my third deep-space survey mission. Nanotrasen assigned our team to this sector. Initial scans look promising.",
		"Established base camp in sector 7. [second_researcher] has begun geological surveys. The company expects results within the quarter.",
		"[get_planet_finding(planet_style)]",
		"Major breakthrough. We've recovered significant data relating to [tech_name]. Central Command will be pleased. This alone justifies the expedition budget.",
		"Equipment malfunction in Lab 2. [second_researcher] thinks it's the humidity. I think it's this planet fighting back. Either way, we're behind schedule.",
		"Received transmission from Central Command. They want preliminary results by end of week. Corporate never understands field conditions.",
		"Local fauna specimen captured for study. Fascinating biology - completely unlike anything in our databases. [second_researcher] is ecstatic.",
		"Power grid fluctuations again. The backup generators are holding but I'm concerned about long-term stability out here.",
		"Found evidence of previous expedition. Their camp was abandoned in a hurry. No bodies, no explanation. Concerning.",
		"The night cycle here is 47 hours. Sleep schedules are completely disrupted. [second_researcher] has started talking to the equipment.",
		"Atmospheric readings nominal. This planet could support a colony with minimal terraforming investment.",
		"Something triggered the motion sensors last night. Probably wildlife. Probably.",
		"Mission objectives complete. Recommending this planet for further Nanotrasen investment. Preparing data for upload to Central Command.",
		"Something is wrong. [second_researcher] hasn't reported in for 48 hours. The perimeter sensors keep triggering but we find nothing. I'm archiving everything to the database, just in case.",
		"Final log. Whatever is out there, it's smart. It's patient. Don't send rescue. Send exterminators. Dr. [researcher_name], signing off.",
		"Budget review from Central. They want to know why we're 'over-consuming' emergency rations. We're on an alien planet! What do they expect?",
		"[second_researcher] found unusual mineral deposits in cave system delta. Could be significant for [tech_name] research.",
		"Morale is low. The isolation is getting to everyone. I've started mandatory recreational hours. It's helping. Somewhat.",
		"Comms array took damage in the storm last night. Running on backup communications. Central won't be happy about the delay.",
		"Specimen from Lab 3 escaped containment. Non-hostile, thankfully, but embarrassing. [second_researcher] is reviewing our protocols.",
		"Found ancient ruins two clicks north. Definitely not natural formations. Requesting archaeological team for follow-up mission.",
		"The stars look different here. I've been cataloguing constellations in my downtime. It's oddly calming.",
		"Supply drop arrived. Half the equipment was damaged in transit. Filed complaint with logistics. Again."
	)

	return build_log_from_pool(entry_pool, "NANOTRASEN PLANETARY SURVEY", "[planet_name] - Research Division", dates["years_old"])

/// Wizard teleportation accident log
/obj/machinery/old_database/proc/generate_wizard_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	var/list/dates = get_log_dates()
	var/wizard_name = get_wizard_name()

	var/list/entry_pool = list(
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
		"If anyone finds this journal, tell the Federation that [wizard_name] died with dignity. And style. Mostly style.",
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

	return build_log_from_pool(entry_pool, "ARCANE JOURNAL", "Property of [wizard_name]", dates["years_old"])

/// Ninja technology hunting log
/obj/machinery/old_database/proc/generate_ninja_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	var/list/dates = get_log_dates()
	var/ninja_name = get_ninja_name()

	var/list/entry_pool = list(
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
		"If this reaches the Clan - the mission was successful. Tell them [ninja_name] completed the objective. Honor to the Spider Clan.",
		"Maintaining radio silence. The Clan's protocols are clear: no transmissions until extraction window opens.",
		"Local fauna proves more resilient than expected. Eliminated three specimens attempting to breach the perimeter. Suit integrity at 89%.",
		"Discovered encrypted personal logs from NT staff. Decrypting for intelligence value. Their security officer suspected our presence.",
		"The [tech_name] data contains weapons applications NT never pursued. The Clan will find these... enlightening.",
		"Rations depleted. Surviving on local flora. Training prepared me for worse. The mission continues.",
		"Observed NT patrol vessel in orbit. Did not land. Either they lack resources for full investigation, or they fear what's here.",
		"Created secondary cache of stolen data. If primary extraction fails, future agents can recover the intelligence.",
		"The silence here is complete. No wildlife near the facility anymore. Something has driven them away. Investigating."
	)

	return build_log_from_pool(entry_pool, "SPIDER CLAN MISSION REPORT", "Agent: [ninja_name]", dates["years_old"])

/// Commando colonization scouting log
/obj/machinery/old_database/proc/generate_commando_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	var/list/dates = get_log_dates()
	var/commando_name = get_commando_name()
	var/second_commando = get_commando_name()

	var/list/entry_pool = list(
		"Commander [commando_name] reporting. Squad deployed to [planet_name] for colonization viability assessment. Perimeter secured. [second_commando] establishing forward observation post.",
		"Hostile fauna neutralized in sectors 4 through 7. Acceptable losses: zero. This planet has teeth, but nothing our equipment can't handle.",
		"Located pre-existing research installation. Previous occupants: unknown, presumed dead. Recovered [tech_name] data. Could provide significant advantage for NT's expansion efforts.",
		"Fortified position established. Standard defensive protocols in effect. [second_commando] reports all clear on eastern approach.",
		"Resource survey complete. Mineral deposits exceed projections. Recommend priority classification for extraction operations.",
		"Encountered resistance from indigenous lifeforms. Threat level: moderate. Eliminated with extreme prejudice. Area secured.",
		"Communications relay established. Signal strength nominal. Central Command acknowledges receipt of preliminary data.",
		"[second_commando] identified potential colony site in grid reference 7-Alpha. Defensible position with water access. Marking for Phase 2 assessment.",
		"Weather patterns on this rock are brutal. Equipment holding up. Personnel maintaining combat readiness despite conditions.",
		"Discovered [tech_name] research facility. Corporate will want this data. Archiving for transport.",
		"Sweep complete. No surviving hostiles. This sector is clear. Recommend immediate colonist deployment.",
		"Contact lost with [second_commando]. Search and rescue operation failed. Whatever took them wasn't wildlife. Uploading final assessment: DO NOT COLONIZE.",
		"Mission complete. Planet [planet_name] approved for Phase 2 colonization assessment. Recommending armed escort for civilian teams.",
		"This is Commander [commando_name], signing off. Job done. Ready for extraction. Send the civvies - we've done the hard work.",
		"Ammunition expenditure within acceptable parameters. [second_commando] is maintaining a kill count. Current tally: 47 hostiles.",
		"Established defensive killzones at all approach vectors. If anything gets through, it'll be walking into a wall of lead.",
		"Intel suggests previous team went dark here. Found their camp. Whatever hit them, hit hard and fast. We're ready for it.",
		"[second_commando] wanted to name the largest hostile we killed. I reminded them we're professionals, not trophy hunters. Mostly.",
		"Night vision capabilities tested against local conditions. Visibility optimal. Nothing moves here without us knowing.",
		"Extracted samples of local toxins for R&D. Could have military applications. Corporate loves their chemical weapons research.",
		"Secondary objective complete. [tech_name] data secured. Primary objective: establish beachhead. Status: GREEN.",
		"The silence after a firefight never gets old. [second_commando] is running diagnostics. I'm writing this. The work continues."
	)

	return build_log_from_pool(entry_pool, "DEATH SQUAD RECONNAISSANCE", "Mission: SILENT HORIZON", dates["years_old"])

/// Stranded clown log
/obj/machinery/old_database/proc/generate_clown_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	var/list/dates = get_log_dates()
	var/clown_name = get_clown_name()

	var/list/entry_pool = list(
		"HONK! So there I was, hiding in the escape pod to surprise the Captain, when SOMEONE jettisoned it! Now I'm stuck on '[planet_name]' with nothing but my oversized shoes and a single banana peel.",
		"Found an abandoned building! It's not as funny as the station but at least there's a roof. The local wildlife keeps staring at me. I honked at them but they didn't laugh. Tough crowd.",
		"Discovered some nerdy science stuff about [tech_name]. I don't understand any of it but it looked important so I pressed all the buttons. Something beeped! Maybe it was applause?",
		"Made a new friend today! It's a rock. I drew a face on it. Named it Chuckles. Chuckles doesn't laugh at my jokes either but at least Chuckles doesn't try to eat me.",
		"Tried to make a pie from local plants. It was not a pie. It was a war crime. Even Chuckles judged me.",
		"GOOD NEWS! Found a whoopee cushion in my pocket! Bad news: nobody to use it on. Used it on Chuckles. Chuckles was not amused.",
		"The building has a computer! It keeps talking about '[tech_name]' and 'research data'. I taught it to play circus music. MUCH better.",
		"Banana peel trap caught something! It was a weird bug thing. We stared at each other for a while. Then it left. Rude.",
		"Drew a clown face on the wall with berry juice. Finally, some proper decoration around here! This place was way too serious.",
		"Found more of that [tech_name] stuff. Still don't get it. Drew honk symbols on everything. Scientists love honk symbols, right?",
		"It's been [rand(5,50)] days. I've started doing stand-up for the local wildlife. They're heckling me. WITH THEIR EYES.",
		"The creatures are getting closer every night. I've set up banana peel traps everywhere but they just... step over them. WHO STEPS OVER A BANANA PEEL?!",
		"A ship spotted my emergency disco ball signal! They're sending a shuttle. [clown_name] OUT! *bike horn noise*",
		"If anyone finds this, tell the galaxy that [clown_name] died as they lived: confused and wearing big shoes. HONK...",
		"Tried juggling rocks to pass the time. Dropped one on my foot. Classic [clown_name] comedy! ...ow.",
		"Found a mirror in the facility! Finally someone who appreciates my makeup. We did a routine together. Standing ovation (from me).",
		"The computer keeps asking for 'credentials'. I typed in 'HONK' 47 times. It eventually gave up and let me in. Persistence!",
		"Made a balloon animal from... something I found. It's either a dog or a giraffe. Or a very confused snake. Art is subjective!",
		"Tried to teach the local creatures the art of slapstick. They just stared. Everyone's a critic these days.",
		"Found the scientists' food supplies! It's all very serious. No space Twinkies anywhere. What kind of expedition doesn't bring space Twinkies?!",
		"Built a tiny circus tent out of lab coats. Chuckles is the main attraction. Ticket price: one (1) laugh. Business is slow.",
		"The night is scariest part. No audience, no laughter, just me and Chuckles and the weird noises outside. ...HONK."
	)

	return build_log_from_pool(entry_pool, "THE HONKENING CONTINUES", "A Clown's Tale by [clown_name]", dates["years_old"])

/// Mushroom person native log
/obj/machinery/old_database/proc/generate_mushroom_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	var/list/dates = get_log_dates()
	var/mushroom_name = get_mushroom_name()

	var/list/entry_pool = list(
		"The mycelium network whispers of strange visitors. Metal creatures fell from the sky many cycles ago, leaving behind their hollow shells. I have taken residence in one such shell to study their ways.",
		"The soil here on [planet_name] is rich with nutrients. My sporelings grow strong. The metal beings left strange glowing rectangles that show pictures.",
		"Discovered knowledge the metal beings called '[tech_name]'. Fascinating. Their understanding of the universe is so... limited. They cannot feel the song of decomposition.",
		"I have learned to make the glowing rectangles display my thoughts. The metal beings' language is strange but learnable. So many words for 'death', so few for 'rebirth'.",
		"The network grows. My consciousness expands through the soil, touching memories of those who came before. This world has known many visitors.",
		"Found more of their '[tech_name]' knowledge. They sought to understand through cutting and measuring. We understand through growing and becoming.",
		"A new sporeling emerges! I teach it of the metal beings and their ways. It is confused by their need to 'own' things. We share all through the network.",
		"The hollow shells contain many wonders. Metal that never rusts. Light that needs no sun. The metal beings were clever, in their way.",
		"The metal beings feared the dark. They made lights everywhere. We embrace the dark - it is where we grow strongest.",
		"I have archived what I learned of '[tech_name]' to their machines. Perhaps future metal beings will find it and understand us better.",
		"The seasons turn. My cap changes color with the changing light. The metal beings never stayed long enough to see the beauty of the slow cycles.",
		"The great drought comes. My cap withers. I commit these memories to the metal shell, hoping the mycelium network will carry them forward.",
		"The rains have returned. The network grows strong once more. I leave this chronicle for future spore-keepers.",
		"[mushroom_name] spreads to new gardens. Life continues. This is the way of all things. May my spores find fertile ground.",
		"The metal beings' bodies return to the soil. In death, they finally join the network. We remember them now, their strange thoughts becoming our thoughts.",
		"Found their 'food storage'. Dead matter, sealed in containers. They did not understand - all things should return to the earth, not be trapped.",
		"A predator creature investigates the hollow shell. It does not see me. I am still. I am patient. I am mushroom.",
		"The sporelings question why I study the metal beings. Because they were here, I explain. Because they tried. That is enough reason.",
		"Their machines hum with captured lightning. We cannot do this. But they could not feel the whisper of roots. Both are valid ways.",
		"Temperature drops. The cap pulls inward. This is the season of waiting. The season of dreaming beneath the frozen soil.",
		"A metal being's recording device shows images of their 'family'. Small metal beings. They treasured connection too. We are not so different.",
		"The network has grown to touch the far corners of this hollow shell. Every room now speaks to every other. The metal beings would call this 'efficiency'."
	)

	return build_log_from_pool(entry_pool, "SPORE-KEEPER'S CHRONICLE", "Written by [mushroom_name]", dates["years_old"])

/// Grey alien research log
/obj/machinery/old_database/proc/generate_grey_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	var/list/dates = get_log_dates()
	var/grey_name = get_grey_name()

	var/list/entry_pool = list(
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
		"[grey_name] departing. This terminal will self-corrupt in 50 cycles. Or not. These machines are unreliable.",
		"The humans built shrines to their 'gods'. Primitive superstition. And yet... the psionic resonance here suggests something once listened.",
		"Intercepted human distress signals from the facility's final days. Their panic was... vivid. I felt echoes of it through the psionic substrate.",
		"Human concept of 'privacy' is inefficient. Why not simply share all thoughts? Their isolation must be... lonely.",
		"Local predator attempted to consume this unit. It now serves as a research specimen. Compliance was achieved through psionic suggestion.",
		"The humans left behind images of their offspring. They were protective of their young. A logical adaptation for slow-breeding species.",
		"Discovered human music. It creates emotional resonance without psionic input. Primitive, but... not unpleasant.",
		"The Council would disapprove of the time spent here. There is much to learn about these creatures. Their persistence is admirable.",
		"Human concept of 'humor' analyzed. 47% of samples incomprehensible. 12% mildly amusing. The 'clown' category defies all classification."
	)

	return build_log_from_pool(entry_pool, "XENOSCIENCE EXPEDITION LOG", "Observer: [grey_name]", dates["years_old"])

/// Vox trader log
/obj/machinery/old_database/proc/generate_vox_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	var/list/dates = get_log_dates()
	var/vox_name = get_vox_name()

	var/list/entry_pool = list(
		"SKREE! Ship damaged in asteroid field. Emergency landing on '[planet_name]'. Cargo intact - most important! Found abandoned softskin facility. Good shelter for repairs.",
		"Softskins leave much behind! Silly creatures, not understanding value. Found data on '[tech_name]' - very valuable! Arkships will pay many shiny things!",
		"Planet has many resources. Cataloguing for future trade expeditions. Softskin technology crude but functional. SKREE!",
		"[vox_name] is clever trader, yes yes! Found more '[tech_name]' data. Will fetch good price from the right buyer.",
		"Ship repairs progressing. Found useful parts in softskin garbage. What they throw away! [vox_name] finds treasure in trash!",
		"Local creatures are annoying. Keep trying to eat [vox_name]'s supplies. Have set traps. Will eat THEM instead. Fair trade!",
		"Discovered softskin personal items. Shiny metals, pretty rocks. Good trade goods! Softskins love their shinies almost as much as Vox.",
		"The Arkships would approve of this salvage operation. Nothing wasted! Everything has value to clever Vox eyes.",
		"More '[tech_name]' equipment found. Some broken, some working. All valuable to right buyer. SKREE SKREE!",
		"Softskin facility has good air. Good water. Could make trading post here. [vox_name] claims this territory for future trade!",
		"Found softskin medicine. Tastes terrible but might be valuable. Packing everything. Take all, sort later!",
		"Big problem! Local predators found [vox_name]'s nest. Many teeth, very aggressive. Ship repairs incomplete.",
		"Ship repaired! Loading salvage now. This planet good for future trading post maybe. [vox_name] returns to the stars!",
		"If other Vox find this - take the data, sell it well, tell tales of [vox_name] the Brave! Profit awaits! SKREEEEE!",
		"Softskin corpses found in back room. Old, dried out. [vox_name] takes their boots - no longer need them, yes?",
		"Strange noises at night. Local beasts circling camp. [vox_name] sleeps with talons ready. Good Vox always prepared!",
		"Found softskin 'entertainment' devices. Moving pictures! Very distracting. Must focus on salvage, not silly stories.",
		"Weather on this rock is unpredictable. Rain, then sun, then more rain. Softskins built well - roof holds!",
		"Discovered cache of nitrogen! Perfect for Vox breathing. This planet more valuable than first thought!",
		"Other Vox would laugh at [vox_name]'s situation. Crashed, alone, surrounded by junk. But junk is VALUABLE junk!",
		"Softskin security systems still partially active. Had to disable several. Their passwords are laughably simple.",
		"Found a functioning communication array! Tried to contact Arkships but too far. Signal too weak. Will try again."
	)

	return build_log_from_pool(entry_pool, "TRADE MANIFEST AND NOTES", "Trader: [vox_name]", dates["years_old"])

/// Syndicate recon agent log
/obj/machinery/old_database/proc/generate_syndicate_log(var/planet_name, var/planet_style, var/tech_name, var/tech_level)
	var/list/dates = get_log_dates()
	var/agent_name = get_researcher_name()

	var/list/entry_pool = list(
		"Agent [agent_name], Syndicate Intelligence Division, commencing reconnaissance on '[planet_name]'. Nanotrasen presence minimal. Perfect conditions for asset acquisition.",
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
		"Agent [agent_name] reporting: mission objectives 80% complete. Awaiting extraction window.",
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

	return build_log_from_pool(entry_pool, "SYNDICATE FIELD REPORT", "Agent: [agent_name] - CLASSIFIED", dates["years_old"])

/// Get a planet-specific finding
/obj/machinery/old_database/proc/get_planet_finding(var/planet_style)
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
			return pick("Sensor readings inconsistent with known physics.", "Native organisms defy standard biological classification.", "Discovered structures of non-humanoid design.")
		else
			return pick("Standard geological surveys completed.", "Atmosphere within acceptable parameters.", "Resource deposits identified for potential extraction.")

/// Corrupts text by replacing characters with glitch symbols based on age
/obj/machinery/old_database/proc/corrupt_text(var/text, var/years_old)
	// Calculate corruption rate: older = more corruption, but much gentler
	// Corruption only starts at 20 years, so years_old will be at least 20 here
	// At 20 years: every 200th char, at 100 years: every 100th, at 200 years: every 50th
	var/effective_age = years_old - 20 // Subtract threshold
	var/corruption_interval = max(50, 200 - effective_age)

	var/list/glitch_chars = list("^", "%", "&", "#", "@", "*", "~", "?", "!", "$")
	var/list/result = list()
	var/char_count = 0
	var/in_tag = FALSE

	for(var/i = 1 to length(text))
		var/char = copytext(text, i, i + 1)

		// Don't corrupt HTML tags
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

// Story generator ruins

/**
 * # Story Landmark
 *
 * A landmark that gets processed after a story ruin is placed.
 * Depending on the story's age, it will spawn:
 * - A hostile mob (if within STORY_RECENT_THRESHOLD years)
 * - A corpse (if older than STORY_RECENT_THRESHOLD years)
 * - Nothing (STORY_MISSING_CHANCE% of the time - body is missing)
 *
 * The specific mob/corpse type depends on the story theme assigned to the ruin.
 */
/obj/effect/landmark/story
	name = "story character spawner"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	/// The story theme datum assigned to this landmark
	var/datum/story_theme/assigned_theme
	/// The year the story took place (used to determine if recent or old)
	var/story_year = 0
	/// The character name to apply to spawned mobs/corpses
	var/character_name = ""

/**
 * Spawns the appropriate entity based on story age
 *
 * Called after the ruin is placed and the theme/year have been assigned.
 * Will spawn a hostile mob for recent stories, a corpse for old stories,
 * or nothing if the body is "missing".
 */
/obj/effect/landmark/story/proc/spawn_story_entity()
	if(!assigned_theme)
		qdel(src)
		return

	// Chance for the body/mob to be missing entirely
	if(prob(STORY_MISSING_CHANCE))
		qdel(src)
		return

	var/years_old = game_year - story_year
	var/turf/T = get_turf(src)
	var/is_clown = (assigned_theme.name == "clown")

	if(years_old <= STORY_RECENT_THRESHOLD)
		// Recent story - spawn a hostile mob
		if(assigned_theme.hostile_mobs.len)
			var/mob_type = pick(assigned_theme.hostile_mobs)
			var/mob/M = new mob_type(T)
			if(character_name)
				M.name = character_name
				M.real_name = character_name
	else
		// Old story - spawn a corpse
		if(assigned_theme.corpse_types.len)
			var/corpse_type = pick(assigned_theme.corpse_types)
			// Create the corpse landmark (which will spawn the corpse and delete itself)
			new corpse_type(T)
			// If we have a custom name, find the spawned corpse and rename it
			if(character_name)
				for(var/mob/living/M in T)
					M.name = character_name
					M.real_name = character_name
					break

	// If this is a clown story, spawn banana peels throughout the ruin
	if(is_clown)
		spawn_clown_banana_peels()

	qdel(src)

/**
 * Spawns banana peels throughout the ruin area for clown stories
 */
/obj/effect/landmark/story/proc/spawn_clown_banana_peels()
	var/area/ruin_area = get_area(src)
	if(!ruin_area)
		return

	// Get all turfs in the ruin area
	var/list/valid_turfs = list()
	for(var/turf/simulated/floor/F in ruin_area)
		// Don't spawn on dense turfs or turfs with dense objects
		var/blocked = FALSE
		for(var/atom/A in F)
			if(A.density)
				blocked = TRUE
				break
		if(!blocked)
			valid_turfs += F

	// Spawn 3-8 banana peels randomly throughout the ruin
	var/num_peels = rand(3, 8)
	for(var/i in 1 to min(num_peels, valid_turfs.len))
		var/turf/spawn_turf = pick_n_take(valid_turfs)
		new /obj/item/weapon/bananapeel(spawn_turf)

/**
 * # Story Ruin
 *
 * A map element/ruin that supports story theming.
 * The 'theme' var is a bitfield of STORY_* flags indicating which themes
 * are compatible with this ruin.
 */
/datum/map_element/ruin/story
	/// Bitfield of compatible STORY_* theme flags
	var/theme = STORY_NT
	/// The assigned story theme datum (set when placed)
	var/datum/story_theme/assigned_theme
	/// The year the story took place
	var/story_year = 0

/datum/map_element/ruin/story/bunker
	name = "bunker"
	file_path = "maps/ruins/story/bunker.dmm"
	theme = STORY_COMMANDO|STORY_SYNDICATE|STORY_NINJA|STORY_GREY|STORY_VOX

/datum/map_element/ruin/story/cabin
	name = "cabin"
	file_path = "maps/ruins/story/cabin.dmm"
	theme = STORY_NT|STORY_WIZARD|STORY_NINJA|STORY_CLOWN|STORY_MUSHROOM|STORY_GREY

/datum/map_element/ruin/story/camp
	name = "camp"
	file_path = "maps/ruins/story/camp.dmm"
	theme = STORY_NT|STORY_WIZARD|STORY_NINJA|STORY_CLOWN|STORY_MUSHROOM|STORY_GREY|STORY_VOX|STORY_SYNDICATE

/datum/map_element/ruin/story/hoarder
	name = "hoarder den"
	file_path = "maps/ruins/story/hoarder.dmm"
	theme = STORY_VOX

/datum/map_element/ruin/story/listening_post
	name = "listening post"
	file_path = "maps/ruins/story/listening_post.dmm"
	theme = STORY_COMMANDO|STORY_SYNDICATE

/datum/map_element/ruin/story/ufo
	name = "ufo"
	file_path = "maps/ruins/story/ufo.dmm"
	theme = STORY_GREY

#undef STORY_NT
#undef STORY_WIZARD
#undef STORY_NINJA
#undef STORY_COMMANDO
#undef STORY_CLOWN
#undef STORY_MUSHROOM
#undef STORY_GREY
#undef STORY_VOX
#undef STORY_SYNDICATE
#undef STORY_RECENT_THRESHOLD
#undef STORY_MISSING_CHANCE
