/datum/job/captain
	title = "Captain"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space law"
	wage_payout = 105
	selection_color = "#ccccff"
	req_admin_notify = 1
	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()
	minimal_player_age = 30
	species_whitelist = list("Human")

	outfit_datum = /datum/outfit/captain

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/reject_new_slots()
	if(security_level == SEC_LEVEL_RED)
		return FALSE
	else
		return "Red Alert"

/datum/job/hop
	title = "Head of Personnel"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	wage_payout = 80
	selection_color = "#ddddff"
	req_admin_notify = 1
	minimal_player_age = 20

	species_whitelist = list("Human")

	access = list(access_security, access_sec_doors, access_brig, access_court, access_weapons, access_forensics_lockers,
			            access_medical, access_engine_major, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_science, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_weapons, access_forensics_lockers,
			            access_medical, access_engine_major, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_science, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway)

	outfit_datum = /datum/outfit/hop
