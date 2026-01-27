#define RAIDERS_DEFAULT_RISK 		10
#define RAIDERS_DEFAULT_THREAT 		10

/datum/faction/vox_shoal
	name = "Vox Shoal"
	desc = "In short supply of money, organs, experts, and rubber duckies."
	ID = VOXSHOAL
	required_pref = VOXRAIDER
	initial_role = VOXRAIDER
	late_role = VOXRAIDER
	roletype = /datum/role/vox_raider
	initroletype = /datum/role/vox_raider
	logo_state = "vox-logo"
	hud_icons = list("vox-logo")
	default_admin_voice = "Vox Shoal"
	admin_voice_style = "vox"

	var/max_objectives = 5

/datum/faction/vox_shoal/New()
	..()

	new /datum/planet_type/shoal								// This creates the shoal planet.
	load_dungeon(/datum/map_element/dungeon/vox_shuttle)
	vox_shuttle.initialize() 									//As the area isn't loaded until the above call, its docking ports aren't populated until we call this


/datum/faction/vox_shoal/forgeObjectives()
	..()

	var/threat = GetThreatOrRisk()
	var/risk = GetThreatOrRisk()
	message_admins("------------------------------------------------------------------------")
	message_admins("DEBUG: Vox Raiders Objectives. Threat: [threat], Risk: [risk]. Starting time [world.time]")

	var/list/possible_objectives = list()
	for(var/jectie in subtypesof(/datum/objective/raider))
		possible_objectives += new jectie

 	while(possible_objectives.len > 1 && threat > 0 && risk > 0 && objective_holder.objectives.len < max_objectives)
		var/datum/objective/raider/obj = pick(possible_objectives)
		if(!obj.CanBePicked())
			possible_objectives -= obj
			qdel(obj)
			continue
		if(obj.threat > threat)
			message_admins("DEBUG: Ignoring [obj.name]. Threat level too high.")
			possible_objectives -= obj
			qdel(obj)
			continue
		if(obj.risk > risk)
			message_admins("DEBUG: Ignoring [obj.name]. Risk level too high.")
			possible_objectives -= obj
			qdel(obj)
			continue
		message_admins("DEBUG: Vox Raiders: Adding objective [obj.name]")
		AppendObjective(obj)
		threat -= obj.threat
		risk -= obj.risk
		possible_objectives -= obj

	AnnounceObjectives()
	message_admins("DEBUG: Vox Raiders: Completed objective generation. Time [world.time]")

/datum/faction/vox_shoal/proc/GetThreatOrRisk()

	// First, count how many "enemy" roles are on station and how many roles in total are on station.
	var/list/enemy_jobs = list("Security Officer", "Detective", "Warden", "Head of Security", "Captain", "AI", "Cyborg")
	var/enemies = 0
	var/crew = 0
	for (var/mob/living/M in player_list)
		if (M.stat == DEAD)
			continue // Dead players can't count.
		if (M.mind && M.mind.assigned_role && M.mind.assigned_role in enemy_jobs)
			enemies++
		var/turf/T = get_turf(M)
		if(T?.z == map.zMainStation)
			crew++
	message_admins("DEBUG: Vox Raiders, [enemies] enemy roles found, [crew] total crew.")

	// Next, count how many raiders we have.
	var/voxes = members.len
	message_admins("DEBUG: Vox Raiders, [members.len] vox raiders found.")

	// Next, find out what the midround threat level is.
	var/threat = 0
	var/datum/gamemode/dynamic/dyn = ticker.mode
	if(!istype(dyn))
		threat = 40			// If it's not dynamic mode, let's just say it's 40.
	else
		threat = dyn.midround_threat_level
	message_admins("DEBUG: Vox Raiders, [threat] threat level.")

	var/x = max(1, floor(crew/5) + enemies + floor(threat/10) + voxes)
	message_admins("DEBUG: Vox Raiders, center x = [x].")
	x = x*2 // Temp for now until I can think of some better math.
	return rand(x-3,x+3)

/datum/faction/vox_shoal/GetScoreboard()
	. = ..()

/datum/faction/vox_shoal/OnPostSetup()
	..()
	for(var/datum/role/vox_raider/V in members)
		V.SetupVox()
		V.SetupOutfit()

/datum/faction/vox_shoal/process()
	..()

/datum/faction/vox_shoal/proc/count_score(var/atom/O)
/datum/faction/vox_shoal/proc/count_human_score(var/mob/living/carbon/human/H)
/datum/faction/vox_shoal/proc/generate_string()

// -- Mobs procs --

/mob/living/proc/send_back_to_main_station(var/complete_failure = FALSE)
	if (complete_failure) // Non-vox somehow used the vox shuttle.
		to_chat(src, "<span class='danger'>After hours of aimlessly wandering through space in hostile Vox territory, the shuttle quickly ran out of fuel. You and your companions decided to abandon the ship and throw escape shelters in the general direction of the station.</span>")
		var/obj/structure/inflatable/shelter/S = new(get_turf(src))
		forceMove(S)
		S.ThrowAtStation()
		return
	to_chat(src, "<span class='warning'>You can't really remember the details, but somehow, you managed to escape. Your situation is still far from ideal, however.</span>")
	delete_all_equipped_items()
	if (ishuman(src))
		var/obj/item/clothing/under/color/grey/G = new(src)
		equip_to_appropriate_slot(G)
		var/obj/item/clothing/shoes/black/B = new(src)
		equip_to_appropriate_slot(B)
		var/obj/item/device/radio/R = new(src)
		put_in_hands(R)
	var/obj/structure/inflatable/shelter/S = new(get_turf(src))
	forceMove(S)
	S.ThrowAtStation()


/datum/map_element/dungeon/vox_shuttle
	file_path = "maps/misc/voxshuttle.dmm"
	unique = TRUE

/obj/effect/landmark/raiderstart
	name = "raiderstart"
