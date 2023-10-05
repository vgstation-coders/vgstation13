//#define DISABLE_AWAYMISSIONS_ON_ROUNDSTART

var/list/datum/map_element/away_mission/existing_away_missions = list()

var/list/awaydestinations = list() //List of landmarks
/obj/effect/landmark/awaystart
	name = "awaystart"
/*
There are two ways to add an away mission to the game

 A) Add the map file's location to maps/RandomZLevels/fileList.txt
 B) Create a subtype of /datum/map_element/away_mission and set its file_path to the map file's location (see below)

First method sucks

Second method lets you use the initialize() proc to interact with the away mission after it has loaded (for example generate map elements, create shuttles, etc).
It also lets you write a description for the away mission, as well as many other things

Example of the second method:

/datum/map_element/away_mission/my_shit
	file_path = "maps/RandomZLevels/fresh_dump.dmm"
	desc = "This stinks."

****READ THIS****
  Because a z-level is 500x500 in size, loading an away mission creates 250,000 new turfs - in addition to any additonal mobs and objects.

  If your away mission is smaller than 500x500, its northern and eastern borders will be surrounded with space turfs. Unless you're fine with this, you
 should secure these borders with an indestructible wall (insert a trump meme here) so that nobody can get out


*/

/datum/map_element/away_mission
	type_abbreviation = "AM"
	load_at_once = FALSE

	var/generate_randomly = 1 //If 0, don't generate this away mission randomly

	var/datum/zLevel/zLevel

/datum/map_element/away_mission/initialize(list/objects) //objects: list of all atoms in the away mission. This proc is called after the away mission is loaded
	..()

	existing_away_missions.Add(src)

	var/z = location ? location.z : world.maxz //z coordinate

	if(accessable_z_levels.len >= z)
		zLevel = accessable_z_levels[z]

	for(var/obj/effect/landmark/L in landmarks_list) //Add all landmarks to away destinations. Also set the away mission's location for admins to jump to
		if(L.name != "awaystart")
			continue

		awaydestinations.Add(L)

		if(!location)
			location = get_turf(L)

	for(var/obj/machinery/gateway/G in gateways)
		G.initialize()

/datum/map_element/away_mission/proc/onArrive(mob/user)
	return

/datum/map_element/away_mission/empty_space
	name = "empty space"
	file_path = "maps/RandomZLevels/space.dmm" //1x1 space tile. It changes its size according to the map's dimensions
	generate_randomly = 0

/datum/map_element/away_mission/empty_space/New()
	..()
	desc = "[world.maxx]x[world.maxy] tiles of pure space. No structures, no humans, absolutely nothing. Not even a gateway - you'll have to spawn one yourself."

/datum/map_element/away_mission/arcticwasteland
	name = "arctic wasteland"
	file_path = "maps/RandomZLevels/arcticwaste.dmm"
	desc = "A 200x200  frozen wasteland with some trees, some wolves, and a bunker in a cave. Features a gateway."

/datum/map_element/away_mission/assistantchamber
	name = "assistant chamber"
	file_path = "maps/RandomZLevels/assistantChamber.dmm"
	desc = "A tiny unbreachable room full of angry turrets and loot."
	generate_randomly = 0

/datum/map_element/away_mission/challenge
	name = "emitter hell"
	file_path = "maps/RandomZLevels/challenge.dmm"
	desc = "A long hallway featuring emitters, turrets and syndicate agents. Features loot and a gateway."

/datum/map_element/away_mission/spacebattle
	name = "space battle"
	file_path = "maps/RandomZLevels/spacebattle.dmm"
	desc = "A large ship being attacked by smaller syndicate ones in an asteroid field, featuring a bluespace artillery gun on the main ship."

/datum/map_element/away_mission/spaceship
	name = "stranded spaceship"
	file_path = "maps/RandomZLevels/blackmarketpackers.dmm"
	desc = "A mysteriously empty shuttle crashed into the asteroid."

/datum/map_element/away_mission/academy
	name = "academy"
	file_path = "maps/RandomZLevels/Academy.dmm"

/datum/map_element/away_mission/beach
	name = "beach"
	file_path = "maps/RandomZLevels/beach.dmm"
	desc = "A small, comfy seaside area with a bar."
	generate_randomly = 0

/datum/map_element/away_mission/listeningpost
	name = "listening post"
	file_path = "maps/RandomZLevels/listeningpost.dmm"
	desc = "A large asteroid with a hidden syndicate listening post. Don't forget to bring pickaxes!"

/datum/map_element/away_mission/leviathan
	name = "leviathan"
	file_path = "maps/RandomZLevels/leviathan.dmm"
	desc = "A large asteroid in the shape of a mythical creature with an abandoned mining outpost, functional research outpost and hidden rare minerals in the center."

/datum/map_element/away_mission/stationcollision
	name = "station collision"
	file_path = "maps/RandomZLevels/stationCollision.dmm"
	desc = "A shuttlecraft crashed into a small space station, bringing aboard aliens and cultists. Features the Lord Nar-Sie himself."

/datum/map_element/away_mission/wildwest
	name = "wild west"
	file_path = "maps/RandomZLevels/wildwest.dmm"
	desc = "An exciting adventure for the toughest adventures your station can offer. Those who defeat all of the final area's guardians will find a wish granter."

/datum/map_element/away_mission/tomb
	name = "tomb of Rafid"
	file_path = "maps/RandomZLevels/tomb.dmm"
	desc = "On a distant planet, an ancient civilization built a great pyramid to bury their leader. After a team of archaeologists disappeared while attempting to unlock the tomb, a gateway was set up and a rescue team requested."

/datum/map_element/away_mission/snowplanet
	name = "Snow Planet"
	file_path = "maps/RandomZLevels/snowplanet.dmm"
	desc = "A small little planetoid with a cold atmosphere and a wooden cabin with a gateway. Be sure to pack some sweaters!"

var/static/list/away_mission_subtypes = subtypesof(/datum/map_element/away_mission)

#if UNIT_TESTS_ENABLED
/datum/unit_test/away_missions/start()
	for(var/M in away_mission_subtypes)
		var/datum/map_element/away_mission/mission = M
		var/file_path = initial(mission.file_path)
		if(!fexists(file_path))
			fail("[mission] points to an invalid file_path: [file_path]")
#endif

//Returns a list containing /datum/map_element/away_mission objects.
/proc/getRandomZlevels(include_unrandom = 0)
	var/list/potentialRandomZlevels = away_mission_subtypes.Copy()
	for(var/T in potentialRandomZlevels) //Fill the list with away mission datums (because currently it only contains paths)
		potentialRandomZlevels.Add(new T)
		potentialRandomZlevels.Remove(T)

	if(!include_unrandom)
		for(var/datum/map_element/away_mission/AM in potentialRandomZlevels)
			if(!AM.generate_randomly)
				potentialRandomZlevels.Remove(AM)

	return potentialRandomZlevels

/proc/createRandomZlevel(override = 0, var/datum/map_element/away_mission/AM, var/messages = null)
	if(!messages)
		messages = world

	if(existing_away_missions.len && !override)	//crude, but it saves another var!
		return

	if(!AM) //If we were provided an away mission datum, don't generate the list of away missions
		to_chat(messages, "<span class='danger'>Searching for away missions...</span>")
		var/list/potentialRandomZlevels = getRandomZlevels()

		if(!potentialRandomZlevels.len)
			return

		AM = pick(potentialRandomZlevels)
		to_chat(messages, "<span class='danger'>[potentialRandomZlevels.len] away missions found. Loading...</span>")
	else
		to_chat(messages, "<span class='danger'>Loading an away mission...</span>")

	log_game("Loading away mission [AM.file_path]")

	if(AM.load())
		to_chat(messages, "<span class='danger'>Away mission loaded.</span>")
		return

	to_chat(messages, "<span class='danger'>Failed to load away mission [AM.file_path] (file doesn't exist).</span>")

//Helper procs

//Finds an active away mission with a matching name, or returns null
/proc/get_away_mission(var/id)
	for(var/datum/map_element/away_mission/AD in existing_away_missions)
		if(id == AD.name)
			return AD

/proc/get_mission_by_z(var/num)
	for(var/datum/map_element/away_mission/AD in existing_away_missions)
		if(AD.zLevel.z == num)
			return AD


//Away defines
#define WESTERN "Wild West"