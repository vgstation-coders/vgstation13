/datum/next_map
	var/name = "Name" // MUST be the same as /datum/map/var/nameLong
	var/path = "Folder name" // MUST be the name of the folder inside maps/voting that contains the dmb
	var/min_players = 0
	var/max_players = 999
	var/is_enabled = TRUE // If FALSE, it doesn't show up during the vote but can be rigged

/datum/next_map/proc/is_compiled()
	return fexists("maps/voting/"+path+"/vgstation13.dmb")

/datum/next_map/proc/is_votable()
	if(!is_compiled())
		var/msg = "Skipping map [name] because it has not been compiled."
		message_admins(msg)
		warning(msg)
		return FALSE
	if(clients.len < min_players)
		var/msg = "Skipping map [name] due to not enough players. min = [min_players] || max = [max_players]"
		message_admins(msg)
		warning(msg)
		return FALSE
	if(clients.len > max_players)
		var/msg = "Skipping map [name] due to too many players. min = [min_players] || max = [max_players]"
		message_admins(msg)
		warning(msg)
		return FALSE
	return TRUE

/datum/next_map/bagel
	name = "Bagelstation"
	path = "Bagelstation"
	var/bagel_requirement = 17
	is_enabled = FALSE

/datum/next_map/bagel/is_votable()
	if(score.bagelscooked < bagel_requirement)
		var/msg = "Skipping map [name], fewer than [bagel_requirement] bagels made."
		message_admins(msg)
		warning(msg)
		return FALSE
	return ..()

/datum/next_map/box
	name = "Box Station"
	path = "Box Station"

/datum/next_map/castle
	name = "Castle Station"
	path = "Castle Station"

/datum/next_map/castle/is_votable()
	if(!ticker.revolutionary_victory)
		var/msg = "Skipping map [name], revolutionaries have not won."
		message_admins(msg)
		warning(msg)
		return FALSE
	return ..()

/datum/next_map/deff
	name = "Defficiency"
	path = "Defficiency"
	min_players = 25

/datum/next_map/dorf
	name = "DorfStation"
	path = "Dorf"

/datum/next_map/dorf/is_votable()
	var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) // get the current date
	if(!(MM == 8 && DD == 8)) // Dwarf fortress release date
		var/msg = "Skipping map [name] as this is not the release date of Dwarf Fortress."
		message_admins(msg)
		warning(msg)
		return FALSE
	return ..()

/datum/next_map/line
	name = "Frankenline Station"
	path = "line"
	min_players = 25

/datum/next_map/line/is_votable()
	var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
	if (MM != 10)
		var/msg = "Skipping map [name] as this is no longer the Halloween season."
		message_admins(msg)
		warning(msg)
		return FALSE
	return ..()

/datum/next_map/lamprey
	name = "Lamprey Station"
	path = "Lamprey"
	is_enabled = FALSE

/datum/next_map/lamprey/is_votable()
	if(score.crewscore > -20000)
		var/msg = "Skipping map [name], station requires lower than -20000 score (is [score.crewscore])."
		message_admins(msg)
		warning(msg)
		return FALSE
	return ..()

/datum/next_map/lowfat_bagel
	name = "Lowfat Bagel"
	path = "lowfatbagel"
	min_players = 25

/datum/next_map/horizon
	name = "NRV Horizon"
	path = "horizon"
	min_players = 5
	max_players = 25

/datum/next_map/metaclub
	name = "Meta Club"
	path = "Metaclub"
	min_players = 20

/datum/next_map/packed
	name = "Packed Station"
	path = "Packed Station"
	max_players = 10

/datum/next_map/roid
	name = "Asteroid Station"
	path = "RoidStation"
	min_players = 25

/datum/next_map/snaxi
	name = "Snow Station"
	path = "Snow Taxi"
	min_players = 30

/datum/next_map/snaxi/is_votable()
	var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
	var/allowed_months = list(1, 2, 7, 12)
	if (!(MM in allowed_months))
		var/msg = "Skipping map [name] as this is no longer the Christmas season."
		message_admins(msg)
		warning(msg)
		return FALSE
	return ..()

/datum/next_map/synergy
	name = "Synergy Station"
	path = "Synergy"
	min_players = 15

/datum/next_map/waystation
	name = "Waystation"
	path = "Waystation"
	max_players = 25

/datum/next_map/xoq
	name = "noitatS xoq"
	path = "xoq"
	is_enabled = FALSE

/datum/next_map/snowbox
	name = "Snowbox Station"
	path = "snowstation"

/datum/next_map/snowbox/is_votable()
	var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
	var/allowed_months = list(1, 2, 7, 12)
	if (!(MM in allowed_months))
		var/msg = "Skipping map [name] as this is no longer the Christmas season."
		message_admins(msg)
		warning(msg)
		return FALSE

	if(get_station_avg_temp() >= T0C)
		var/msg = "Skipping map [name] as station average temperature is above 0C."
		message_admins(msg)
		warning(msg)
		return FALSE
	return ..()

/datum/next_map/nerve
	name = "Nerve Station"
	path = "nervestation"
	min_players = 20

/datum/next_map/wheelstation
	name = "Wheelstation"
	path = "wheelstation"
	min_players = 30

/proc/get_votable_maps()
	var/list/votable_maps = list()
	for(var/map_path in subtypesof(/datum/next_map))
		var/datum/next_map/candidate = new map_path
		if(candidate.is_enabled && candidate.is_votable())
			votable_maps += candidate.name
			votable_maps[candidate.name] = candidate.path
	return votable_maps

/proc/get_all_maps()
	var/list/all_maps = list()
	for(var/map_path in subtypesof(/datum/next_map))
		var/datum/next_map/map = new map_path
		if(map.is_compiled())
			all_maps += map.name
			all_maps[map.name] = map.path
	return all_maps
