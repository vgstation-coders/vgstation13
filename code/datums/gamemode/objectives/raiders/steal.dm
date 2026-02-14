
/datum/objective/raider/steal
	name = "\[Vox Raider\] Steal <target>"

	var/atom/movable/target_type = null					// The theft objective.
	var/other_valid_types = list()			// These types are valid for completion, but won't be checked to ensure they're on the station.
	var/skip_locate = FALSE					// If TRUE, this will skip the check that ensures that target_type is on station.

	var/extracted_with_target = FALSE		// This is set when the raiding team extracts with the target item.



/datum/objective/raider/steal/format_explanation()
	return "Steal [initial(target_type.name)] and bring it to the rendezvous location."

/datum/objective/raider/steal/IsFulfilled()
	if (..())
		return TRUE

	return extracted_with_target


/datum/objective/raider/steal/CanBePicked()
	. = ..()
	if(!.)
		return FALSE
	if(!skip_locate || LocateObjective())
		return TRUE
	return FALSE

////////////////////

//////// TODO: FIX THIS RETURNING TRUE FOR SUBTYPES

/datum/objective/raider/steal/proc/LocateObjective()
	if(!locate(target_type))
		message_admins("VOX RAIDERS: [name] couldn't be picked as its objective wasn't located in the world.")
		return FALSE
	return TRUE

// This proc is called once the raiders leave to extract, and finalizes the objective.
/datum/objective/raider/steal/proc/OnExtraction()
	if(!vox_shuttle || !vox_shuttle.linked_area)
		message_admins("The Vox Skipjack couldn't be found for a Vox Raider's theft objective! The objective will automatically fail unless force-completed.")
		return FALSE

	var/list/found = CheckShuttleForObjectives()
	for(var/atom/movable/AM in found)
		if(AdditionalChecks(AM))
			return TRUE

	return FALSE

/datum/objective/raider/steal/proc/CheckShuttleForObjectives()
	var/list/found_objs = list()
	for(var/atom/movable/AM in vox_shuttle.linked_area)
		if(istype(AM, target_type) || is_type_in_list(AM,other_valid_types))
			found_objs += AM
	if(!found_objs.len)
		return FALSE
	return found_objs



// Override this with any additional checks you want to make on the theft target. (i.e. charge, count, etc)
/datum/objective/raider/steal/proc/AdditionalChecks(var/atom/movable/AM)
	return TRUE

/////////////////////////////////////////////////
//		BEGIN BIG LONG LIST OF OBJECTIVES
/////////////////////////////////////////////////


/datum/objective/raider/steal/nukedisk
	name = "\[Vox Raider\] Steal Nuclear Disk"
	target_type = /obj/item/weapon/disk/nuclear

	required_jobs = list("Captain", "Head of Personnel", "Head of Security", "Chief Medical Officer", "Chief Engineer", "Research Director")
	required_job_count = 1

	risk = RAIDERS_RISK_MAXIMUM
	threat = RAIDERS_THREAT_MAXIMUM

	skip_locate = TRUE 		// Because the nuke disk will always exist.

/datum/objective/raider/steal/nukebomb
	name = "\[Vox Raider\] Steal Nuclear Bomb."
	target_type = /obj/machinery/nuclearbomb

	required_jobs = list("Captain", "Head of Personnel", "Head of Security", "Chief Medical Officer", "Chief Engineer", "Research Director")
	required_job_count = 1

	risk = RAIDERS_RISK_HIGH
	threat = RAIDERS_THREAT_HIGH

/datum/objective/raider/steal/handtele
	name = "\[Vox Raider\] Steal Hand Teleporter."
	target_type = /obj/item/weapon/hand_tele

	risk = RAIDERS_RISK_LOW
	threat = RAIDERS_THREAT_LOW

/datum/objective/raider/steal/caplaser
	name = "\[Vox Raider\] Steal Captain's Laser."
	target_type = /obj/item/weapon/gun/energy/laser/captain

	required_jobs = list("Captain", "Head of Security")
	required_job_count = 1

	risk = RAIDERS_RISK_HIGH
	threat = RAIDERS_THREAT_HIGH


/datum/objective/raider/steal/holotool
	name = "\[Vox Raider\] Steal Holo Switchtool."
	target_type = /obj/item/weapon/switchtool/holo

	required_jobs = list("Research Director")
	required_job_count = 1

	risk = RAIDERS_RISK_MEDIUM
	threat = RAIDERS_THREAT_MEDIUM

/datum/objective/raider/steal/advancedmagboots
	name = "\[Vox Raider\] Steal Advanced Magboots."
	target_type = /obj/item/clothing/shoes/magboots/elite

	required_jobs = list("Chief Engineer")
	required_job_count = 1

	risk = RAIDERS_RISK_MEDIUM
	threat = RAIDERS_THREAT_MEDIUM


/datum/objective/raider/steal/blueprints
	name = "\[Vox Raider\] Steal Station Blueprints."
	target_type = /obj/item/blueprints/primary

	required_jobs = list("Chief Engineer")
	required_job_count = 1

	risk = RAIDERS_RISK_LOW
	threat = RAIDERS_THREAT_LOW


/datum/objective/raider/steal/ian
	name = "\[Vox Raider\] Steal Ian (or Corgi Meat)."
	target_type = /mob/living/simple_animal/corgi/Ian
	other_valid_types = list(/obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi)

	required_jobs = list("Head of Personnel")
	required_job_count = 1

	risk = RAIDERS_RISK_LOW
	threat = RAIDERS_THREAT_MINIMUM

// TODO - ENSURE THAT THIS RULESET IS MUTUALLY EXCLUSIVE WITH OTHER SUPERMATTER ONES
/datum/objective/raider/steal/supermatter_crystal
	name = "\[Vox Raider\] Steal Supermatter Crystal."
	target_type = /obj/machinery/power/supermatter

	risk = RAIDERS_RISK_HIGH
	threat = RAIDERS_THREAT_MAXIMUM

/datum/objective/raider/steal/supermatter_shard
	name = "\[Vox Raider\] Steal Supermatter Shard."
	target_type = /obj/machinery/power/supermatter/shard

	required_jobs = list("Station Engineer", "Atmospheric Technician", "Chief Engineer")
	required_job_count = 1

	risk = RAIDERS_RISK_MEDIUM
	threat = RAIDERS_THREAT_MEDIUM

	skip_locate = TRUE			// Can be reasonably sure that there will always be one of these.

// TODO - Sample of Supermatter

/datum/objective/raider/steal/research
	name = "\[Vox Raider\] Steal Nanotrasen Research."
	target_type = /obj/item/weapon/disk/tech_disk
	other_valid_types = list(/obj/item/device/techsiphon, /obj/machinery/r_n_d/server) // Fuck it, just steal the server itself. Why not?

	risk = RAIDERS_RISK_MEDIUM
	threat = RAIDERS_THREAT_MEDIUM

	skip_locate = FALSE 						// We're checking for research this time instead of a specific object.

	var/required_research = list()				// See CanBePicked() comment.

/datum/objective/raider/steal/research/format_explanation()
	return "Steal Nanotrasen's Research and bring the saved data to the rendezvous location. The data can be stored on disks, on your tech siphon, or on data servers themselves."

/datum/objective/raider/steal/research/CanBePicked()
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/machinery/r_n_d/server/core/server in machines)
		var/turf/turf = get_turf(server)
		if(turf.z != map.zMainStation)
			continue
		if(CheckCompletedResearch(server.files))

			// Once we know that a server exists on station that has completed research, we set our research requirements to match the servers.
			for(var/ID in server.files.known_tech)
				var/datum/tech/T = server.files.known_tech[ID]
				required_research[ID] = T.level
			return TRUE

	return FALSE

/datum/objective/raider/steal/research/proc/CheckCompletedResearch(var/datum/research/R)
	for(var/ID in R.known_tech)
		var/datum/tech/T = R.known_tech[ID]
		if(T.id in list("syndicate", "Nanotrasen", "anomaly"))
			continue
		if(T.level < min(6,T.goal_level))
			return FALSE

// For every disk/siphon/server that gets stolen, we'll knock down the tech levels in our required_research
// If everything is 0 or below, then we'll finally return TRUE.
/datum/objective/raider/steal/research/AdditionalChecks(var/obj/O)
	if(istype(O, /obj/item/weapon/disk/tech_disk))
		var/obj/item/weapon/disk/tech_disk/disk = O
		if(disk.stored)
			var/datum/tech/T = disk.stored
			required_research[T.id] = required_research[T.id] - T.level
	if(istype(O, /obj/item/device/techsiphon))
		var/obj/item/device/techsiphon/siphon = O
		for(var/ID in siphon.our_files.known_tech)
			var/datum/tech/T = siphon.our_files.known_tech[ID]
			required_research[ID] = required_research[ID] - T.level
	if(istype(O, /obj/machinery/r_n_d/server))
		var/obj/machinery/r_n_d/server/server = O
		for(var/ID in server.files.known_tech)
			var/datum/tech/T = server.files.known_tech[ID]
			required_research[ID] = required_research[ID] - T.level

	// Loop through all our required research, checking to see if we've yet to complete any.
	for(var/ID in required_research)
		if(required_research[ID] > 0)
			return FALSE

	// All good? Mark as complete.
	return TRUE


/datum/objective/raider/steal/power
	name = "\[Vox Raider\] Steal Power."
	target_type = /obj/machinery/ghettopowersink

	// You can steal the SMES too I guess, but they won't have nearly as much capacity.
	// If you can get a real powersink and not have it explode, that works too!
	other_valid_types = list(/obj/machinery/power/battery, /obj/item/device/powersink)

	required_jobs = list("Station Engineer", "Atmospheric Technician", "Chief Engineer")
	required_job_count = 1

	risk = RAIDERS_RISK_HIGH
	threat = RAIDERS_THREAT_MEDIUM

	skip_locate = FALSE 						// Nothing to check for, we bring our own equipment.

	var/required_power = 1e8


/datum/objective/raider/steal/power/format_explanation()
	return "Siphon at least [format_watts(required_power)] of power using your equipment and bring the stored power to the rendezvous location."


// Knock down the required power for each ghetto powersink / SMES / real powersink they extracted with.
/datum/objective/raider/steal/power/AdditionalChecks(var/obj/O)
	if(istype(O, /obj/machinery/ghettopowersink))
		var/obj/machinery/ghettopowersink/G = O
		required_power -= G.power_drained
	if(istype(O, /obj/item/device/powersink))
		var/obj/item/device/powersink/P = O
		required_power -= P.power_drained
	if(istype(O, /obj/machinery/power/battery))
		var/obj/machinery/power/batter/B = O
		required_power -= B.charge

	// If we have enough charge, mark the objective as complete.
	if(required_power > 0)
		return FALSE
	return TRUE
