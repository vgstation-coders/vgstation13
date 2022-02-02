
/datum/faction/spider_infestation
	name = SPIDERINFESTATION
	ID = SPIDERINFESTATION
	default_admin_voice = "Your Spider Senses"
	admin_voice_style = "skeleton"
	logo_state = "spider-logo"
	hud_icons = list("spider-logo")

	initroletype = /datum/role/giant_spider
	initial_role = GIANTSPIDER

	roletype = /datum/role/giant_spider
	late_role = GIANTSPIDER

	var/turf/invasion // where the player controlled spiders spawn
	var/list/vents = list() // for additional NPC spiders
	var/extra_spiders = 12

/datum/faction/spider_infestation/New()
	..()
	forgeObjectives()

/datum/faction/spider_infestation/OnPostSetup()
	if (!invasion)
		SetupSpawn()

	if (invasion)
		for(var/datum/role/giant_spider/M in members)
			var/datum/mind/spider_mind = M.antag
			spider_mind.current.forceMove(invasion)
			extra_spiders--

	ExtraSpawns()

	spawn(rand(30 SECONDS, 60 SECONDS))//same delay and announcement as during the random event
		command_alert(/datum/command_alert/xenomorphs)

//unlike random events, we'll have player spiders all spawn together so they can chat and coordinate a bit if at all
/datum/faction/spider_infestation/proc/SetupSpawn()
	if (!invasion)
		var/list/found_vents = list()
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in atmos_machines)
			if(!v.welded && v.z == map.zMainStation && v.canSpawnMice==1) // No more spawning in atmos.  Assuming the mappers did their jobs, anyway.
				found_vents.Add(v)
		if(found_vents.len)
			while(found_vents.len > 0)
				var/obj/machinery/atmospherics/unary/vent_pump/v = pick(found_vents)
				found_vents -= v
				for (var/mob/M in player_list)
					if (isliving(M) && (get_dist(M,v) > 7))//trying to find just one vent that is far out of view of any player
						invasion = v
						return

		var/spawn_area_type = pick(
			/area/maintenance/incinerator,
			/area/storage/nuke_storage,
			/area/storage/tech,
			)
		var/area/spawn_area = locate(spawn_area_type)
		var/list/turf/simulated/floor/floors = list()
		for(var/turf/simulated/floor/F in spawn_area)
			floors += F
			if(!F.has_dense_content())
				invasion = F
				return
		invasion = pick(floors)//or any floor really.

//we'll always spawn 12 spiderlings total, both player and NPC
/datum/faction/spider_infestation/proc/ExtraSpawns()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in atmos_machines)
		if(temp_vent.loc.z == map.zMainStation && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 50)
				vents += temp_vent

	while((extra_spiders > 0) && vents.len)
		var/obj/vent = pick(vents)
		new /mob/living/simple_animal/hostile/giant_spider/spiderling(vent.loc)
		vents -= vent
		extra_spiders--

/datum/faction/spider_infestation/forgeObjectives()
	AppendObjective(/datum/objective/spider)
