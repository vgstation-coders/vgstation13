/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	idtype = /obj/item/weapon/card/id/cmo
	req_admin_notify = 1
	access = list(access_medical, access_morgue, access_genetics, access_heads,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_paramedic)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_heads,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_paramedic)
	minimal_player_age = 7

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/heads/cmo

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/cmo(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/chief_medical_officer(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/heads/cmo(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/cmo(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/weapon/storage/firstaid/regular(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1



/////////////////////////////////////////I know this is out of place...its here on a temp basis to help roll out oncology////////////////////////////////////////

/obj/item/weapon/paper/oncpamphlet
	name = "oncology pamphlet"
	icon_state = "pamphlet"
	var/pcount = 0
	info = "<b>Thank you Doctor, you've got lots of work to do!</b><br>\
			Congratulations! If you're reading this, you have chosen a difficult path,\
			but with a bit of careful consideration you will be in a position to save \
			many lives from the deadly disease that is cancer.<br><br>\
			Cancer is an uncontrolled growth of malignant cells in the body which will\
			show up in a body scan. As the body's systems shut down from the cancerous\
			growths the patient will begin to cough.<br><br>\
			Cancer develops in the body as a systemic mutation of healthy cells from\
			prolonged exposure to high toxin levels. As it progresses, localized tumors\
			delevop in the body which can lead to rapid mortality if left untreated.<br><br>\
			The patient must be irratiated to a level of 50% while supressing the toxin\
			levels in the blood. The patient must be kept in this state until systemic\
			symptoms cease. This may seem like an impossible balancing act but it is\
			possible and your patients are depending on you.<br><br>\
			Once the patient has undergone radiation treatment you may proceed with\
			removal of the tumors, but it is possible for a patient to live with them\
			if surgery is deemed too risky or if patient is low risk for relapse.<br><br>\
			Phalanximine is the chemotherapy agent you will use to treat your patients.\
			30 units should be sufficient to raise your patient's rad level while keeping\
			their blood toxins low. A follow up treatment of anti-toxin may be required.<br><br>\
			There is a prescription tucked in this pamphlet to help assist your pharmacist."
/obj/item/weapon/paper/oncpamphlet/attack_self(mob/M as mob)
	if(pcount < 1)
		new /obj/item/weapon/paper/oncscript(M.loc)
		M << "<span class='notice'>A small piece of paper falls out of the pamphlet!</span>"
		pcount += 1
	..()

/obj/item/weapon/paper/oncpamphlet/update_icon()
	return

/obj/item/weapon/paper/oncscript
	name = "Phalanximine prescription"
	icon_state = "paper_words"
	info = "<b>Phalanximine</b><br>\
			A powerful chemotherapy agent <br><br>\
			1 part Arithrazine<br>\
			1 part Diethylamine<br>\
			1 part Unstable Mutagen"
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics)
	minimal_access = list(access_medical, access_morgue, access_surgery, access_virology)
	alt_titles = list("Surgeon","Emergency Physician","Nurse","Virologist","Oncologist")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/medical

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if (H.mind.role_alt_title)
			switch(H.mind.role_alt_title)
				if("Emergency Physician")
					H.equip_or_collect(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/fr_jacket(H), slot_wear_suit)
				if("Surgeon")
					H.equip_or_collect(new /obj/item/clothing/under/rank/medical/blue(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
					H.equip_or_collect(new /obj/item/clothing/head/surgery/blue(H), slot_head)
				if("Virologist")
					H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/virologist(H), slot_wear_suit)
					H.equip_or_collect(new /obj/item/clothing/under/rank/virologist(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/mask/surgical(H), slot_wear_mask)
				if("Medical Doctor")
					H.equip_or_collect(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
				if("Oncologist")
					H.equip_or_collect(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/oncologist(H), slot_wear_suit)
					H.equip_or_collect(new /obj/item/weapon/paper/oncpamphlet(H), slot_r_hand)

				if("Nurse")
					if(H.gender == FEMALE)
						if(prob(50))
							H.equip_or_collect(new /obj/item/clothing/under/rank/nursesuit(H), slot_w_uniform)
						else
							H.equip_or_collect(new /obj/item/clothing/under/rank/nurse(H), slot_w_uniform)
						H.equip_or_collect(new /obj/item/clothing/head/nursehat(H), slot_head)
					else
						H.equip_or_collect(new /obj/item/clothing/under/rank/medical/purple(H), slot_w_uniform)
		else
			H.equip_or_collect(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/medical(H), slot_belt)
		H.equip_or_collect(new /obj/item/weapon/storage/firstaid/regular(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1



//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro
/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics)
	minimal_access = list(access_medical, access_chemistry)
	alt_titles = list("Pharmacist")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/chemist

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_ears)
		H.equip_or_collect(new /obj/item/clothing/under/rank/chemist(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/chemist(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/chemist(H), slot_wear_suit)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1

/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_research)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_research)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/geneticist

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_medsci(H), slot_ears)
		H.equip_or_collect(new /obj/item/clothing/under/rank/geneticist(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/geneticist(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/genetics(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1

/*/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics)
	minimal_access = list(access_medical, access_virology)
	alt_titles = list("Pathologist","Microbiologist")


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/virologist(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/device/pda/viro(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/mask/surgical(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/virologist(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1

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
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
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