/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	wage_payout = 80
	selection_color = "#ffddf0"
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
	flag = DOCTOR
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	wage_payout = 65
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_eva)
	minimal_access = list(access_medical, access_morgue, access_surgery, access_virology)
	alt_titles = list("Emergency Physician", "Nurse", "Surgeon")
	outfit_datum = /datum/outfit/doctor

//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro //No, fuck science
/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	wage_payout = 65
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_eva)
	minimal_access = list(access_medical, access_chemistry)
	alt_titles = list("Pharmacist")
	outfit_datum = /datum/outfit/chemist

/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer and research director"
	wage_payout = 55
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_science, access_eva)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_science)
	outfit_datum = /datum/outfit/geneticist

/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	wage_payout = 55
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_biohazard, access_genetics, access_eva)
	minimal_access = list(access_medical, access_virology, access_biohazard)
	alt_titles = list("Pathologist", "Microbiologist")
	outfit_datum = /datum/outfit/virologist

/datum/job/paramedic
	title = "Paramedic"
	flag = PARAMEDIC
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 4
	spawn_positions = 2
	supervisors = "the chief medical officer"
	wage_payout = 55
	selection_color = "#ffeef0"
	access = list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_eva, access_morgue, access_surgery)
	minimal_access=list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_eva, access_morgue, access_surgery)
	outfit_datum = /datum/outfit/paramedic

/*
/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = PSYCHIATRIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_psychiatrist)
	minimal_access = list(access_medical, access_psychiatrist)
	alt_titles = list("Psychologist")

	equip(var/mob/living/carbon/human/H)
		if(!H)
			return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_ears)
		switch(H.backbag)
			if(2)
				H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3)
				H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4)
				H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/device/pda/medical(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1
*/
