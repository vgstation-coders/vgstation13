/datum/job/cmo
	title = "Chief Medical Officer"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	wage_payout = 80
	selection_color = "#DFEDFD"
	req_admin_notify = 1
	access = list(access_medical, access_morgue, access_genetics, access_heads,
			access_chemistry, access_virology, access_biohazard, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_paramedic, access_eva)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_heads,
			access_chemistry, access_virology, access_biohazard, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_paramedic)
	minimal_player_age = 20
	outfit_datum = /datum/outfit/cmo

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/job/doctor
	title = "Medical Doctor"
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	wage_payout = 65
	selection_color = "#EFFDFE"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_eva)
	minimal_access = list(access_medical, access_morgue, access_surgery, access_virology)
	alt_titles = list("Emergency Physician", "Surgeon")
	outfit_datum = /datum/outfit/doctor

//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro //No, fuck science
/datum/job/chemist
	title = "Chemist"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	wage_payout = 65
	selection_color = "#EFFDFE"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_eva)
	minimal_access = list(access_medical, access_chemistry)
	alt_titles = list("Pharmacist")
	outfit_datum = /datum/outfit/chemist

/datum/job/geneticist
	title = "Geneticist"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer and research director"
	wage_payout = 55
	selection_color = "#EFFDFE"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_science, access_eva)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_science)
	outfit_datum = /datum/outfit/geneticist

/datum/job/virologist
	title = "Virologist"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	wage_payout = 55
	selection_color = "#EFFDFE"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_biohazard, access_genetics, access_eva)
	minimal_access = list(access_medical, access_virology, access_biohazard)
	alt_titles = list("Pathologist", "Microbiologist")
	outfit_datum = /datum/outfit/virologist

/datum/job/paramedic
	title = "Paramedic"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	wage_payout = 55
	selection_color = "#EFFDFE"
	access = list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_eva, access_morgue, access_surgery)
	minimal_access=list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_eva, access_morgue, access_surgery)
	alt_titles = list("Brig Medic")
	outfit_datum = /datum/outfit/paramedic

/datum/job/orderly
	title = "Orderly"
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the chief medical officer"
	wage_payout = 55
	selection_color = "#EFFDFE"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry)
	minimal_access = list(access_medical, access_morgue, access_surgery)
	alt_titles = list("Nurse")
	outfit_datum = /datum/outfit/orderly
