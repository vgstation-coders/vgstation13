#define FILE_ANTAG_REP "data/AntagReputation.json"

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE
	var/list/satchel_blacklist 		= list() //this is a typecache
	var/list/new_secret_satchels 	= list() //these are objects
	var/list/old_secret_satchels 	= list()

	var/list/obj/structure/chisel_message/chisel_messages = list()
	var/list/saved_messages = list()
	var/list/saved_modes = list(1,2,3)
	var/list/saved_trophies = list()
	var/list/spawned_objects = list()
	var/list/antag_rep = list()
	var/list/antag_rep_change = list()

/datum/controller/subsystem/persistence/Initialize()
	LoadSatchels()
	LoadPoly()
	LoadChiselMessages()
	LoadTrophies()
	LoadRecentModes()
	if(CONFIG_GET(flag/use_antag_rep))
		LoadAntagReputation()
	..()

/datum/controller/subsystem/persistence/proc/LoadSatchels()
	var/placed_satchel = 0
	var/path
	if(fexists("data/npc_saves/SecretSatchels.sav")) //legacy conversion. Will only ever run once.
		var/savefile/secret_satchels = new /savefile("data/npc_saves/SecretSatchels.sav")
		for(var/map in secret_satchels)
			var/json_file = file("data/npc_saves/SecretSatchels[map].json")
			var/list/legacy_secret_satchels = splittext(secret_satchels[map],"#")
			var/list/satchels = list()
			for(var/i=1,i<=legacy_secret_satchels.len,i++)
				var/satchel_string = legacy_secret_satchels[i]
				var/list/chosen_satchel = splittext(satchel_string,"|")
				if(chosen_satchel.len == 3)
					var/list/data = list()
					data["x"] = text2num(chosen_satchel[1])
					data["y"] = text2num(chosen_satchel[2])
					data["saved_obj"] = chosen_satchel[3]
					satchels += list(data)
			var/list/file_data = list()
			file_data["data"] = satchels
			WRITE_FILE(json_file, json_encode(file_data))
		fdel("data/npc_saves/SecretSatchels.sav")

	var/json_file = file("data/npc_saves/SecretSatchels[SSmapping.config.map_name].json")
	var/list/json = list()
	if(fexists(json_file))
		json = json_decode(file2text(json_file))

	old_secret_satchels = json["data"]
	var/obj/item/storage/backpack/satchel/flat/F
	if(old_secret_satchels && old_secret_satchels.len >= 10) //guards against low drop pools assuring that one player cannot reliably find his own gear.
		var/pos = rand(1, old_secret_satchels.len)
		F = new()
		old_secret_satchels.Cut(pos, pos+1 % old_secret_satchels.len)
		F.x = old_secret_satchels[pos]["x"]
		F.y = old_secret_satchels[pos]["y"]
		F.z = SSmapping.station_start
		path = text2path(old_secret_satchels[pos]["saved_obj"])

	if(F)
		if(isfloorturf(F.loc) && !isplatingturf(F.loc))
			F.hide(1)
		if(ispath(path))
			var/spawned_item = new path(F)
			spawned_objects[spawned_item] = TRUE
		placed_satchel++
	var/free_satchels = 0
	for(var/turf/T in shuffle(block(locate(TRANSITIONEDGE,TRANSITIONEDGE,SSmapping.station_start), locate(world.maxx-TRANSITIONEDGE,world.maxy-TRANSITIONEDGE,SSmapping.station_start)))) //Nontrivially expensive but it's roundstart only
		if(isfloorturf(T) && !isplatingturf(T))
			new /obj/item/storage/backpack/satchel/flat/secret(T)
			free_satchels++
			if((free_satchels + placed_satchel) == 10) //ten tiles, more than enough to kill anything that moves
				break

/datum/controller/subsystem/persistence/proc/LoadPoly()
	for(var/mob/living/simple_animal/parrot/Poly/P in GLOB.alive_mob_list)
		twitterize(P.speech_buffer, "polytalk")
		break //Who's been duping the bird?!

/datum/controller/subsystem/persistence/proc/LoadChiselMessages()
	var/list/saved_messages = list()
	if(fexists("data/npc_saves/ChiselMessages.sav")) //legacy compatability to convert old format to new
		var/savefile/chisel_messages_sav = new /savefile("data/npc_saves/ChiselMessages.sav")
		var/saved_json
		chisel_messages_sav[SSmapping.config.map_name] >> saved_json
		if(!saved_json)
			return
		saved_messages = json_decode(saved_json)
		fdel("data/npc_saves/ChiselMessages.sav")
	else
		var/json_file = file("data/npc_saves/ChiselMessages[SSmapping.config.map_name].json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))

		if(!json)
			return
		saved_messages = json["data"]

	for(var/item in saved_messages)
		if(!islist(item))
			continue

		var/xvar = item["x"]
		var/yvar = item["y"]
		var/zvar = item["z"]

		if(!xvar || !yvar || !zvar)
			continue

		var/turf/T = locate(xvar, yvar, zvar)
		if(!isturf(T))
			continue

		if(locate(/obj/structure/chisel_message) in T)
			continue

		var/obj/structure/chisel_message/M = new(T)

		if(!QDELETED(M))
			M.unpack(item)

	log_world("Loaded [saved_messages.len] engraved messages on map [SSmapping.config.map_name]")

/datum/controller/subsystem/persistence/proc/LoadTrophies()
	if(fexists("data/npc_saves/TrophyItems.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/TrophyItems.sav")
		var/saved_json
		S >> saved_json
		if(!saved_json)
			return
		saved_trophies = json_decode(saved_json)
		fdel("data/npc_saves/TrophyItems.sav")
	else
		var/json_file = file("data/npc_saves/TrophyItems.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		if(!json)
			return
		saved_trophies = json["data"]
	SetUpTrophies(saved_trophies.Copy())

/datum/controller/subsystem/persistence/proc/LoadRecentModes()
	var/json_file = file("data/RecentModes.json")
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return
	saved_modes = json["data"]

/datum/controller/subsystem/persistence/proc/LoadAntagReputation()
	var/json = file2text(FILE_ANTAG_REP)
	if(!json)
		var/json_file = file(FILE_ANTAG_REP)
		if(!fexists(json_file))
			WARNING("Failed to load antag reputation. File likely corrupt.")
			return
		return
	antag_rep = json_decode(json)

/datum/controller/subsystem/persistence/proc/SetUpTrophies(list/trophy_items)
	for(var/A in GLOB.trophy_cases)
		var/obj/structure/displaycase/trophy/T = A
		if (T.showpiece)
			continue
		T.added_roundstart = TRUE

		var/trophy_data = pick_n_take(trophy_items)

		if(!islist(trophy_data))
			continue

		var/list/chosen_trophy = trophy_data

		if(!chosen_trophy || isemptylist(chosen_trophy)) //Malformed
			continue

		var/path = text2path(chosen_trophy["path"]) //If the item no longer exist, this returns null
		if(!path)
			continue

		T.showpiece = new /obj/item/showpiece_dummy(T, path)
		T.trophy_message = chosen_trophy["message"]
		T.placer_key = chosen_trophy["placer_key"]
		T.update_icon()


/datum/controller/subsystem/persistence/proc/CollectData()
	CollectChiselMessages()
	CollectSecretSatchels()
	CollectTrophies()
	CollectRoundtype()
	if(CONFIG_GET(flag/use_antag_rep))
		CollectAntagReputation()

/datum/controller/subsystem/persistence/proc/CollectSecretSatchels()
	satchel_blacklist = typecacheof(list(/obj/item/stack/tile/plasteel, /obj/item/crowbar))
	var/list/satchels_to_add = list()
	for(var/A in new_secret_satchels)
		var/obj/item/storage/backpack/satchel/flat/F = A
		if(QDELETED(F) || F.z != SSmapping.station_start || F.invisibility != INVISIBILITY_MAXIMUM)
			continue
		var/list/savable_obj = list()
		for(var/obj/O in F)
			if(is_type_in_typecache(O, satchel_blacklist) || O.admin_spawned)
				continue
			if(O.persistence_replacement)
				savable_obj += O.persistence_replacement
			else
				savable_obj += O.type
		if(isemptylist(savable_obj))
			continue
		var/list/data = list()
		data["x"] = F.x
		data["y"] = F.y
		data["saved_obj"] = pick(savable_obj)
		satchels_to_add += list(data)

	var/json_file = file("data/npc_saves/SecretSatchels[SSmapping.config.map_name].json")
	var/list/file_data = list()
	fdel(json_file)
	file_data["data"] = old_secret_satchels + satchels_to_add
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/CollectChiselMessages()
	var/json_file = file("data/npc_saves/ChiselMessages[SSmapping.config.map_name].json")

	for(var/obj/structure/chisel_message/M in chisel_messages)
		saved_messages += list(M.pack())

	log_world("Saved [saved_messages.len] engraved messages on map [SSmapping.config.map_name]")
	var/list/file_data = list()
	file_data["data"] = saved_messages
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/SaveChiselMessage(obj/structure/chisel_message/M)
	saved_messages += list(M.pack()) // dm eats one list


/datum/controller/subsystem/persistence/proc/CollectTrophies()
	var/json_file = file("data/npc_saves/TrophyItems.json")
	var/list/file_data = list()
	file_data["data"] = saved_trophies
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/SaveTrophy(obj/structure/displaycase/trophy/T)
	if(!T.added_roundstart && T.showpiece)
		var/list/data = list()
		data["path"] = T.showpiece.type
		data["message"] = T.trophy_message
		data["placer_key"] = T.placer_key
		saved_trophies += list(data)

/datum/controller/subsystem/persistence/proc/CollectRoundtype()
	saved_modes[3] = saved_modes[2]
	saved_modes[2] = saved_modes[1]
	saved_modes[1] = SSticker.mode.config_tag
	var/json_file = file("data/RecentModes.json")
	var/list/file_data = list()
	file_data["data"] = saved_modes
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/CollectAntagReputation()
	var/ANTAG_REP_MAXIMUM = CONFIG_GET(number/antag_rep_maximum)

	for(var/p_ckey in antag_rep_change)
//		var/start = antag_rep[p_ckey]
		antag_rep[p_ckey] = max(0, min(antag_rep[p_ckey]+antag_rep_change[p_ckey], ANTAG_REP_MAXIMUM))

//		WARNING("AR_DEBUG: [p_ckey]: Committed [antag_rep_change[p_ckey]] reputation, going from [start] to [antag_rep[p_ckey]]")

	antag_rep_change = list()

	fdel(FILE_ANTAG_REP)
	text2file(json_encode(antag_rep), FILE_ANTAG_REP)

