//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/var/const/access_security = 1 // Security equipment
/var/const/access_brig = 2 // Brig timers and permabrig
/var/const/access_armory = 3
/var/const/access_forensics_lockers= 4
/var/const/access_medical = 5
/var/const/access_morgue = 6
/var/const/access_rnd = 7			// Research and Development
/var/const/access_tox_storage = 8	// Toxins mixing and storage
/var/const/access_genetics = 9
/var/const/access_engine_major = 10		// Power Engines
/var/const/access_engine_minor = 11	// Engineering Foyer
/var/const/access_maint_tunnels = 12
/var/const/access_external_airlocks = 13
/var/const/access_emergency_storage = 14
/var/const/access_change_ids = 15
/var/const/access_ai_upload = 16
/var/const/access_teleporter = 17
/var/const/access_eva = 18
/var/const/access_heads = 19
/var/const/access_captain = 20
/var/const/access_all_personal_lockers = 21
/var/const/access_chapel_office = 22
/var/const/access_tech_storage = 23
/var/const/access_atmospherics = 24
/var/const/access_bar = 25
/var/const/access_janitor = 26
/var/const/access_crematorium = 27
/var/const/access_kitchen = 28
/var/const/access_robotics = 29
/var/const/access_rd = 30
/var/const/access_cargo = 31		// Cargo Bay
/var/const/access_construction = 32	// Vacant office, etc
/var/const/access_chemistry = 33
/var/const/access_cargo_bot = 34
/var/const/access_hydroponics = 35
/var/const/access_manufacturing = 36
/var/const/access_library = 37
/var/const/access_lawyer = 38
/var/const/access_virology = 39
/var/const/access_cmo = 40
/var/const/access_qm = 41
/var/const/access_court = 42
/var/const/access_clown = 43
/var/const/access_mime = 44
/var/const/access_surgery = 45
/var/const/access_theatre = 46
/var/const/access_science = 47		// Research Division hallway
/var/const/access_mining = 48
/var/const/access_mining_office = 49 //not in use
/var/const/access_mailsorting = 50	// Cargo Office
/var/const/access_mint = 51
/var/const/access_mint_vault = 52
/var/const/access_heads_vault = 53
/var/const/access_mining_station = 54
/var/const/access_xenobiology = 55
/var/const/access_ce = 56
/var/const/access_hop = 57
/var/const/access_hos = 58
/var/const/access_RC_announce = 59 //Request console announcements
/var/const/access_keycard_auth = 60 //Used for events which require at least two people to confirm them
/var/const/access_tcomsat = 61 // has access to the entire telecomms satellite / machinery
/var/const/access_gateway = 62
/var/const/access_sec_doors = 63 // Security front doors
// 64 was used by access_psychiatrist. Feel free to repurpose.
/var/const/access_salvage_captain = 65 // Salvage ship captain's quarters
/var/const/access_weapons = 66 //Weapon authorization for secbots

/var/const/access_shop = 68
/var/const/access_biohazard = 69 // Virology crates
	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
/var/const/Mostly for admin fun times.*/
/var/const/access_cent_general = 101//General facilities.
/var/const/access_cent_thunder = 102//Thunderdome.
/var/const/access_cent_specops = 103//Deathsquad.
/var/const/access_cent_medical = 104//Medical/Research
/var/const/access_cent_living = 105//Living quarters.
/var/const/access_cent_storage = 106//Generic storage areas.
/var/const/access_cent_teleporter = 107//Teleporter.
/var/const/access_cent_creed = 108//Creed's office/ID comp
/var/const/access_cent_captain = 109//Captain's office/ID comp/AI.
/var/const/access_cent_ert = 110//ERT.

	//The Syndicate
/var/const/access_syndicate = 150//General Syndicate Access

	//The Mothership (ayy lmao)
/var/const/access_mothership_general = 160//General Mothership Access
/var/const/access_mothership_maintenance = 161//Laborer Access
/var/const/access_mothership_military = 162//Military Access
/var/const/access_mothership_research = 163//Research Access
/var/const/access_mothership_leader = 164//Administrator Access

	//Vox are Pox
/var/const/access_trade = 140//Vox Trader Access

	//MONEY
/var/const/access_crate_cash = 200

// /VG/ SPECIFIC SHIT
/var/const/access_paramedic = 500
/var/const/access_mechanic = 501

/obj/var/list/req_access = null
/obj/var/list/backup_access = null
/obj/var/req_access_txt = "0"			// A user must have ALL of these accesses to use the object
/obj/var/list/req_one_access = null
/obj/var/req_one_access_txt = "0"		// If this list is populated, a user must have at least ONE of these accesses to use the object
/obj/var/req_access_dir = 0				// The dir the user must be facing to do access checks on
/obj/var/access_not_dir = TRUE			// Behaviour if the user is not in the access dir

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(var/mob/M)
	set_up_access()
	if(!M || !istype(M))
		return 0 // I guess?  This seems to happen when AIs use something.
	if(M.hasFullAccess()) // AI, adminghosts, etc.
		return 1
	var/list/ACL = M.GetAccess()
	if(req_access_dir)
		// A special check that combines dirs specified in this number by chaining the conditions below, for example NORTHEAST would add the north and east conditions together.
		var/condition = FALSE
		if((flow_flags & ON_BORDER) && opposite_dirs[req_access_dir] & dir) // For windoors and etc.
			condition |= M.y == src.y && M.x == src.x
		if(req_access_dir & NORTH)
			condition |= M.y > src.y
		if(req_access_dir & SOUTH)
			condition |= M.y < src.y
		if(req_access_dir & EAST)
			condition |= M.x > src.x
		if(req_access_dir & WEST)
			condition |= M.x < src.x
		if(HasAbove(z) && (req_access_dir & UP))
			condition |= M.z > src.z
		if(HasBelow(z) && (req_access_dir & DOWN))
			condition |= M.z < src.z
		if(condition)
			return can_access(ACL,req_access,req_one_access)
		else
			return access_not_dir
	return can_access(ACL,req_access,req_one_access)

/obj/item/var/time_since_last_random_access = 0
/obj/item/var/list/arcane_access = list()

/obj/item/arcane_act(mob/user, recursive)
	arcane_access.Cut()
	for(var/i in 1 to rand(1,5))
		arcane_access.Add(pick(get_all_accesses()))
	return ..()

/obj/item/bless()
	..()
	arcane_access.Cut()

/obj/item/proc/GetAccess()
	if(arcanetampered)
		if(!arcane_access || !arcane_access.len || (time_since_last_random_access + (30 SECONDS) < world.time))
			for(var/i in 1 to rand(1,5))
				arcane_access.Add(pick(get_all_accesses()))
		if(time_since_last_random_access + (30 SECONDS) < world.time)
			time_since_last_random_access = world.time
		return arcane_access
	return list()

/obj/item/proc/GetID()
	return null

/obj/item/proc/get_owner_name_from_ID()
	return null

/obj/proc/set_up_access()
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!src.req_access)
		src.req_access = list()
		if(src.req_access_txt)
			var/list/req_access_str = splittext(req_access_txt,";")
			for(var/x in req_access_str)
				var/n = text2num(x)
				if(n)
					req_access += n

	if(!src.req_one_access)
		src.req_one_access = list()
		if(src.req_one_access_txt)
			var/list/req_one_access_str = splittext(req_one_access_txt,";")
			for(var/x in req_one_access_str)
				var/n = text2num(x)
				if(n)
					req_one_access += n

/obj/proc/check_access(obj/item/I)
	set_up_access()
	var/list/ACL = list()
	if(I)
		ACL=I.GetAccess()
	return can_access(ACL,req_access,req_one_access)


/obj/proc/check_access_list(var/list/L)
	set_up_access()
	if(!src.req_access  && !src.req_one_access)
		return 1
	if(!istype(src.req_access, /list))
		return 1
	if(!src.req_access.len && (!src.req_one_access || !src.req_one_access.len))
		return 1
	if(!L)
		return 0
	if(!istype(L, /list))
		return 0
	for(var/req in src.req_access)
		if(!(req in L)) //doesn't have this access
			return 0
	if(src.req_one_access && src.req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in L) //has an access from the single access list
				return 1
		return 0
	return 1

// /vg/ - Generic Access Checks.
// Allows more flexible access checks.
/proc/can_access(var/list/L, var/list/req_access=null,var/list/req_one_access=null)
	// No perms set?  He's in.
	if(!req_access  && !req_one_access)
		return 1
	// Fucked permissions set?  He's in.
	if(!istype(req_access, /list))
		return 1
	// Blank permissions set?  He's in.
	if(!req_access.len && (!req_one_access || !req_one_access.len))
		return 1

	// User doesn't have any accesses?  Fuck off.
	if(!L)
		return 0
	if(!istype(L, /list))
		return 0

	// Doesn't have a req_access
	for(var/req in req_access)
		if(!(req in L)) //doesn't have this access
			return 0

	// If he has at least one req_one access, he's in.
	if(req_one_access && req_one_access.len)
		for(var/req in req_one_access)
			if(req in L) //has an access from the single access list
				return 1
		return 0
	return 1

/proc/wpermit(var/mob/M) //weapons permit checking
	var/list/L = M.GetAccess()
	if(access_weapons in L)
		return 1
	return 0

/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(access_cent_general, access_cent_living)
		if("Thunderdome Overseer")
			return list(access_cent_general, access_cent_thunder)
		if("Emergency Responder")
			return (get_ert_access() | list(access_cent_general, access_cent_ert, access_cent_specops))
		if("Emergency Responders Leader")
			return (get_ert_access() | list(access_cent_general, access_cent_ert, access_change_ids, access_heads, access_captain, access_cent_specops))
		if("Death Commando")
			return (get_all_accesses() | list(access_cent_general, access_cent_specops))
		if("Creed Commander")
			return (get_all_accesses() | list(access_cent_general, access_cent_specops, access_cent_ert, access_cent_creed))
		if("Supreme Commander")
			return (get_all_accesses() | get_all_centcom_access())//Mr.Centcom gets station all access as well

/proc/get_all_accesses()
	return list(access_shop, access_security, access_sec_doors, access_brig, access_armory, access_forensics_lockers, access_court,
	            access_medical, access_genetics, access_morgue, access_rd,
	            access_rnd, access_tox_storage, access_chemistry, access_engine_major, access_engine_minor, access_maint_tunnels,
	            access_external_airlocks, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers,
	            access_tech_storage, access_chapel_office, access_atmospherics, access_kitchen,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_construction,
	            access_hydroponics, access_library, access_lawyer, access_virology, access_cmo, access_qm, access_clown, access_mime, access_surgery,
	            access_theatre, access_science, access_mining, access_mailsorting,access_weapons,
	            access_heads_vault, access_mining_station, access_xenobiology, access_ce, access_hop, access_hos, access_RC_announce,
	            access_keycard_auth, access_tcomsat, access_gateway, /*vg paramedic*/, access_paramedic, access_mechanic, access_biohazard)

/proc/get_absolutely_all_accesses()
	return ((get_all_accesses() | get_all_centcom_access() | get_all_syndicate_access()) + access_salvage_captain + access_trade)

/proc/get_all_centcom_access()
	return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_medical, access_cent_living, access_cent_storage, access_cent_teleporter, access_cent_creed, access_cent_captain)

/proc/get_all_syndicate_access()
	return list(access_syndicate)

/proc/get_ert_access()
	return list(
		access_security, access_sec_doors, access_brig, access_armory,		//sec
		access_medical, access_genetics, access_surgery, access_paramedic,	//med
		access_atmospherics, access_engine_major,	access_tech_storage,			//engi
		access_robotics, access_science,									//sci
		access_external_airlocks, access_teleporter, access_eva,			//entering/leaving the station
		access_maint_tunnels,
		access_tcomsat, access_gateway,										//why not
		)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //security
			return list(access_sec_doors, access_weapons, access_security, access_brig, access_armory, access_forensics_lockers, access_court, access_hos)
		if(2) //medbay
			return list(access_medical, access_genetics, access_morgue, access_chemistry, access_paramedic, access_virology, access_surgery, access_biohazard, access_cmo)
		if(3) //research
			return list(access_science, access_rnd, access_tox_storage, access_robotics, access_mechanic, access_xenobiology, access_rd)
		if(4) //engineering and maintenance
			return list(access_construction, access_maint_tunnels, access_engine_major, access_engine_minor, access_external_airlocks, access_tech_storage, access_mechanic, access_atmospherics, access_ce)
		if(5) //command
			return list(access_heads, access_RC_announce, access_keycard_auth, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_tcomsat, access_gateway, access_all_personal_lockers, access_heads_vault, access_hop, access_captain)
		if(6) //station general
			return list(access_shop, access_kitchen,access_bar, access_hydroponics, access_janitor, access_chapel_office, access_crematorium, access_library, access_theatre, access_lawyer, access_clown, access_mime)
		if(7) //supply
			return list(access_mailsorting, access_mining, access_mining_station, access_cargo, access_qm)

/proc/get_region_accesses_name(var/code)
	switch(code)
		if(0)
			return "All"
		if(1) //security
			return "Security"
		if(2) //medbay
			return "Medbay"
		if(3) //research
			return "Research"
		if(4) //engineering and maintenance
			return "Engineering"
		if(5) //command
			return "Command"
		if(6) //station general
			return "Station General"
		if(7) //supply
			return "Supply"

/proc/get_region_accesses_positions(var/code)
	switch(code)
		if(0)
			return all_jobs_txt
		if(1) //security
			return security_positions
		if(2) //medbay
			return medical_positions
		if(3) //research
			return science_positions
		if(4) //engineering and maintenance
			return engineering_positions
		if(5) //command
			return command_positions
		if(6) //station general
			return civilian_positions
		if(7) //supply
			return cargo_positions

/proc/get_access_desc_list(var/list/L)
	var/list/names = list()
	for(var/access in L)
		names.Add(get_access_desc(access))
	return english_list(names)

/proc/get_access_desc(A)
	switch(A)
		if(access_shop)
			return "Shop"
		if(access_cargo)
			return "Cargo Bay"
		if(access_cargo_bot)
			return "Cargo Bot Delivery"
		if(access_security)
			return "Security"
		if(access_brig)
			return "Holding Cells"
		if(access_court)
			return "Courtroom"
		if(access_forensics_lockers)
			return "Forensics"
		if(access_medical)
			return "Medical"
		if(access_genetics)
			return "Genetics Lab"
		if(access_morgue)
			return "Morgue"
		if(access_rnd)
			return "R&D Lab"
		if(access_tox_storage)
			return "Toxins Lab"
		if(access_chemistry)
			return "Chemistry Lab"
		if(access_rd)
			return "Research Director"
		if(access_bar)
			return "Bar"
		if(access_janitor)
			return "Custodial Closet"
		if(access_engine_major)
			return "Advanced Engineering"
		if(access_engine_minor)
			return "Basic Engineering"
		if(access_maint_tunnels)
			return "Maintenance"
		if(access_external_airlocks)
			return "External Airlocks"
		if(access_emergency_storage)
			return "Emergency Storage"
		if(access_change_ids)
			return "ID Computer"
		if(access_ai_upload)
			return "AI Upload"
		if(access_teleporter)
			return "Teleporter"
		if(access_eva)
			return "EVA"
		if(access_heads)
			return "Bridge"
		if(access_captain)
			return "Captain"
		if(access_all_personal_lockers)
			return "Personal Lockers"
		if(access_chapel_office)
			return "Chapel Office"
		if(access_tech_storage)
			return "Technical Storage"
		if(access_atmospherics)
			return "Atmospherics"
		if(access_crematorium)
			return "Crematorium"
		if(access_armory)
			return "Armory"
		if(access_construction)
			return "Construction Areas"
		if(access_kitchen)
			return "Kitchen"
		if(access_hydroponics)
			return "Hydroponics"
		if(access_library)
			return "Library"
		if(access_lawyer)
			return "Law Office"
		if(access_robotics)
			return "Robotics"
		if(access_virology)
			return "Virology"
		if(access_biohazard)
			return "Biohazard"
		if(access_cmo)
			return "Chief Medical Officer"
		if(access_qm)
			return "Quartermaster"
		if(access_clown)
			return "HONK! Access"
		if(access_mime)
			return "Silent Access"
		if(access_surgery)
			return "Surgery"
		if(access_theatre)
			return "Theatre"
		if(access_manufacturing)
			return "Manufacturing"
		if(access_science)
			return "Science"
		if(access_mining)
			return "Mining"
		if(access_mining_office)
			return "Mining Office"
		if(access_mailsorting)
			return "Cargo Office"
		if(access_mint)
			return "Mint"
		if(access_mint_vault)
			return "Mint Vault"
		if(access_heads_vault)
			return "Main Vault"
		if(access_mining_station)
			return "Mining EVA"
		if(access_xenobiology)
			return "Xenobiology Lab"
		if(access_hop)
			return "Head of Personnel"
		if(access_hos)
			return "Head of Security"
		if(access_ce)
			return "Chief Engineer"
		if(access_RC_announce)
			return "RC Announcements"
		if(access_keycard_auth)
			return "Keycode Auth. Device"
		if(access_tcomsat)
			return "Telecommunications"
		if(access_gateway)
			return "Gateway"
		if(access_sec_doors)
			return "Brig"
// /vg/ shit
		if(access_paramedic)
			return "Paramedic Station"
		if(access_weapons)
			return "Weapon Permit"
		if(access_mechanic)
			return "Mechanics Workshop"


/proc/get_centcom_access_desc(A)
	switch(A)
		if(access_cent_general)
			return "Centcom Common Areas"
		if(access_cent_thunder)
			return "Thunderdome"
		if(access_cent_storage)
			return "Centcom Storage"
		if(access_cent_living)
			return "Centcom Living Areas"
		if(access_cent_medical)
			return "Centcom Medbay"
		if(access_cent_teleporter)
			return "Centcom Teleporter"
		if(access_cent_specops)
			return "Special Ops"
		if(access_cent_ert)
			return "Emergency Response Team"
		if(access_cent_creed)
			return "Creed Officer"
		if(access_cent_captain)
			return "Centcom Captain"

// Cache - N3X
var/global/list/all_jobs
/proc/get_all_jobs()
	// Have cache?  Use cache.
	if(all_jobs)
		return all_jobs

	// Rebuild cache.
	all_jobs=list()
	for(var/jobtype in typesof(/datum/job) - /datum/job)
		var/datum/job/jobdatum = new jobtype
		if(jobdatum.info_flag & JINFO_SILICON)
			continue
		all_jobs.Add(jobdatum.title)
	return all_jobs

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer","BlackOps Commander","Supreme Commander")


/proc/FindNameFromID(var/mob/living/carbon/human/H)
	ASSERT(istype(H))
	var/obj/item/weapon/card/id/C = H.get_active_hand()
	if( istype(C) || istype(C, /obj/item/device/pda) )
		var/obj/item/weapon/card/id/ID = C

		if( istype(C, /obj/item/device/pda) )
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			return ID.registered_name

	C = H.wear_id

	if( istype(C) || istype(C, /obj/item/device/pda) )
		var/obj/item/weapon/card/id/ID = C

		if( istype(C, /obj/item/device/pda) )
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			return ID.registered_name

/proc/get_all_job_icons() //For all existing HUD icons
	return get_all_jobs() + list("Prisoner", "visitor", "Nanotrasen")
