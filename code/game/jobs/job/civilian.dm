//Food
/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue, access_weapons)
	minimal_access = list(access_bar,access_weapons)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/bar

/datum/job/bartender/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_ears)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
	H.equip_or_collect(new /obj/item/clothing/under/rank/bartender(H), slot_w_uniform)
	H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))
	//H.equip_or_collect(new /obj/item/device/pda/bar(H), slot_belt)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/shaker(H), slot_l_store)//each bartender brings their own

	if(H.backbag == 1)
		var/obj/item/weapon/storage/box/survival/Barpack = new H.species.survival_gear(H)
		H.put_in_hand(GRASP_RIGHT_HAND, Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
	else
		H.equip_or_collect(new H.species.survival_gear(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)

	H.dna.SetSEState(SOBERBLOCK,1)
	H.mutations += M_SOBER
	H.check_mutations = 1
	H.mind.store_memory("Frequencies list: <br/> <b>Service:</b> [SER_FREQ]<br/>")

	return 1

/datum/job/bartender/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/weapon/circuitboard/chem_dispenser/soda_dispenser(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/circuitboard/chem_dispenser/booze_dispenser(H.back), slot_in_backpack)


/datum/job/chef
	title = "Chef"
	flag = CHEF
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue)
	minimal_access = list(access_kitchen, access_morgue, access_bar)
	alt_titles = list("Cook")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/chef

/datum/job/chef/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_ears)
	H.equip_or_collect(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/suit/chef(H), slot_wear_suit)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/head/chefhat(H), slot_head)
	H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))
	//H.equip_or_collect(new /obj/item/device/pda/chef(H), slot_belt)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	H.mind.store_memory("Frequencies list: <br/> <b>Service:</b> [SER_FREQ]<br/>")
	return 1

/datum/job/chef/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/flour(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/flour(H.back), slot_in_backpack)


/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	minimal_access = list(access_hydroponics, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	alt_titles = list("Hydroponicist", "Beekeeper", "Gardener")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/botanist

/datum/job/hydro/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_ears)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_hyd(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger/hyd(H), slot_back)
	switch(H.mind.role_alt_title)
		if("Hydroponicist")
			H.equip_or_collect(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)
		if("Botanist")
			H.equip_or_collect(new /obj/item/clothing/under/rank/botany(H), slot_w_uniform)
		if("Beekeeper")
			H.equip_or_collect(new /obj/item/clothing/under/rank/beekeeper(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/queen_bee(H), slot_l_store)
		if("Gardener")
			H.equip_or_collect(new /obj/item/clothing/under/rank/gardener(H), slot_w_uniform)

	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/gloves/botanic_leather(H), slot_gloves)
	H.equip_or_collect(new /obj/item/clothing/suit/apron(H), slot_wear_suit)
	H.equip_or_collect(new /obj/item/device/analyzer/plant_analyzer(H), slot_s_store)
	H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))
	//H.equip_or_collect(new /obj/item/device/pda/botanist(H), slot_belt)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	H.mind.store_memory("Frequencies list: <br/> <b>Service:</b> [SER_FREQ]<br/>")
	return 1

/datum/job/hydro/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/glass/bottle/diethylamine(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/glass/bottle/diethylamine(H.back), slot_in_backpack)


//Cargo
/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/quartermaster

/datum/job/qm/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_ears)
	H.equip_or_collect(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	//H.equip_or_collect(new /obj/item/device/pda/quartermaster(H), slot_belt)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
	H.put_in_hands(new /obj/item/weapon/storage/bag/clipboard(H))
	if(H.backbag == 1)
		H.put_in_hands(new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	H.mind.store_memory("Frequencies list: <br/> <b>Cargo:</b> [SUP_FREQ]<br/>")
	return 1



/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/cargo

/datum/job/cargo_tech/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_ears)
	H.equip_or_collect(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))
	//H.equip_or_collect(new /obj/item/device/pda/cargo(H), slot_belt)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	H.mind.store_memory("Frequencies list: <br/> <b>Cargo:</b> [SUP_FREQ]<br/>")
	return 1



/datum/job/mining
	title = "Shaft Miner"
	flag = MINER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_mining, access_mint, access_mining_station, access_mailsorting)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/shaftminer

/datum/job/mining/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	H.equip_or_collect(new /obj/item/device/radio/headset/headset_mining(H), slot_ears)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger/engi(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
	//H.equip_or_collect(new /obj/item/device/pda/shaftminer(H), slot_belt)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new /obj/item/weapon/storage/box/survival/engineer(H))
		H.put_in_hands(new /obj/item/weapon/crowbar(H))
		H.equip_or_collect(new /obj/item/weapon/storage/bag/ore(H), slot_l_store)
	else
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival/engineer(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/crowbar(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/bag/ore(H), slot_in_backpack)
	H.mind.store_memory("Frequencies list: <br/> <b>Cargo:</b> [SUP_FREQ]<br/> <b>Science:</b> [SCI_FREQ] <br/>")
	return 1

/datum/job/mining/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.put_in_hands(new /obj/item/weapon/pickaxe/drill(get_turf(H)))


/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/clown
	access = list(access_clown, access_theatre, access_maint_tunnels)
	minimal_access = list(access_clown, access_theatre)
	alt_titles = list("Jester")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/clown

/datum/job/clown/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	H.equip_or_collect(new /obj/item/weapon/storage/backpack/clown(H), slot_back)
	H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	//H.equip_or_collect(new /obj/item/device/pda/clown(H), slot_belt)
	H.equip_or_collect(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/bikehorn(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/stamp/clown(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/toy/crayon/rainbow(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/storage/fancy/crayons(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/toy/waterflower(H), slot_in_backpack)
	H.mutations.Add(M_CLUMSY)
	if (H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Jester")
				H.equip_or_collect(new /obj/item/clothing/under/jester(H), slot_w_uniform)
				H.equip_or_collect(new /obj/item/clothing/shoes/jestershoes(H), slot_shoes)
				H.equip_or_collect(new /obj/item/clothing/head/jesterhat(H), slot_head)
			else
				H.equip_or_collect(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
				H.equip_or_collect(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
	H.fully_replace_character_name(H.real_name,pick(clown_names))
	H.dna.real_name = H.real_name
	H.rename_self("clown")
	return 1

/datum/job/clown/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/weapon/coin/clown(H.back), slot_in_backpack)

/datum/job/clown/reject_new_slots()
	if(Holiday == APRIL_FOOLS_DAY)
		return FALSE
	if(!xtra_positions)
		return FALSE
	if(security_level == SEC_LEVEL_RAINBOW)
		return FALSE
	else
		return "Rainbow Alert"

/datum/job/clown/get_total_positions()
	if(Holiday == APRIL_FOOLS_DAY)
		spawn_positions = -1
		return 99
	else
		return ..()

/datum/job/mime
	title = "Mime"
	flag = MIME
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/mime
	access = list(access_mime, access_theatre, access_maint_tunnels)
	minimal_access = list(access_mime, access_theatre)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/mime

/datum/job/mime/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/under/mime(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/mime(H), slot_shoes)
	//H.equip_or_collect(new /obj/item/device/pda/mime(H), slot_belt)
	H.equip_or_collect(new /obj/item/clothing/gloves/white(H), slot_gloves)
	H.equip_or_collect(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
	H.equip_or_collect(new /obj/item/clothing/head/beret(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/suit/suspenders(H), slot_wear_suit)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
		H.equip_or_collect(new /obj/item/toy/crayon/mime(H), slot_l_store)
		H.put_in_hands(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/toy/crayon/mime(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_in_backpack)
	H.add_spell(new /spell/aoe_turf/conjure/forcewall/mime, "grey_spell_ready")
	H.add_spell(new /spell/targeted/oathbreak/)
	H.mind.miming = MIMING_OUT_OF_CHOICE
	H.rename_self("mime")
	return 1

/datum/job/mime/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/baguette(H.back), slot_in_backpack)

/datum/job/mime/reject_new_slots()
	if(!xtra_positions)
		return FALSE
	if(security_level == SEC_LEVEL_RAINBOW)
		return FALSE
	else
		return "Rainbow Alert"

//Mime's break vow spell, couldn't think of anywhere else to put this

/spell/targeted/oathbreak
	name = "Break Oath of Silence"
	desc = "Break your oath of silence."
	school = "mime"
	panel = "Mime"
	charge_max = 10
	spell_flags = INCLUDEUSER
	range = 0
	max_targets = 1

	hud_state = "mime_oath"
	override_base = "const"

/spell/targeted/oathbreak/cast(list/targets)
	for(var/mob/living/carbon/human/M in targets)
		var/response = alert(M, "Are you -sure- you want to break your oath of silence?\n(This removes your ability to create invisible walls and cannot be undone!)","Are you sure you want to break your oath?","Yes","No")
		if(response != "Yes")
			return
		M.mind.miming=0
		for(var/spell/aoe_turf/conjure/forcewall/mime/spell in M.spell_list)
			M.remove_spell(spell)
		for(var/spell/targeted/oathbreak/spell in M.spell_list)
			M.remove_spell(spell)
		message_admins("[M.name] ([M.ckey]) has broken their oath of silence. (<A HREF='?_src_=holder;adminplayerobservejump=\ref[M]'>JMP</a>)")
		to_chat(M, "<span class = 'notice'>An unsettling feeling surrounds you...</span>")
		return

/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_janitor, access_maint_tunnels)
	minimal_access = list(access_janitor, access_maint_tunnels)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/janitor

/datum/job/janitor/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/under/rank/janitor(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))
	//H.equip_or_collect(new /obj/item/device/pda/janitor(H), slot_belt)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	// Now spawns on the janikart.  H.equip_or_collect(new /obj/item/key(H), slot_l_store)

	H.add_language(LANGUAGE_MOUSE)
	to_chat(H, "<span class = 'notice'>Decades of roaming maintenance tunnels and interacting with its denizens have granted you the ability to understand the speech of mice and rats.</span>")

	return 1

/datum/job/janitor/priority_reward_equip(var/mob/living/carbon/human/H)
	. = ..()
	H.equip_or_collect(new /obj/item/weapon/grenade/chem_grenade/cleaner(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/spray/cleaner(H.back), slot_in_backpack)


//More or less assistants
/datum/job/librarian
	title = "Librarian"
	flag = LIBRARIAN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_library, access_maint_tunnels)
	minimal_access = list(access_library)
	alt_titles = list("Journalist", "Game Master")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/librarian

/datum/job/librarian/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/under/suit_jacket/red(H), slot_w_uniform)
	//H.equip_or_collect(new /obj/item/device/pda/librarian(H), slot_belt)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	var/obj/item/weapon/storage/bag/plasticbag/P = new /obj/item/weapon/storage/bag/plasticbag(H)
	H.put_in_hands(P)
	new /obj/item/weapon/barcodescanner(P)
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	var/list/new_languages = list()
	for(var/L in all_languages)
		var/datum/language/lang = all_languages[L]
		if(~lang.flags & RESTRICTED && !(lang in H.languages))
			new_languages += lang.name

	var/picked_lang = pick(new_languages)
	H.add_language(picked_lang)
	to_chat(H, "<span class = 'notice'>Due to your well read nature, you find yourself versed in the language of [picked_lang]. Check-Known-Languages under the IC tab to use it.</span>")
	return 1



//var/global/lawyer = 0//Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds.
/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_flag = CIVILIAN
	faction = "Station"
	idtype = /obj/item/weapon/card/id/centcom
	total_positions = 2
	spawn_positions = 2
	supervisors = "Nanotrasen Law, CentComm Officals, and the station's captain."
	selection_color = "#dddddd"
	access = list(access_lawyer, access_court, access_heads, access_RC_announce, access_sec_doors, access_cargo, access_medical, access_bar, access_kitchen, access_hydroponics)
	minimal_access = list(access_lawyer, access_court, access_heads, access_RC_announce, access_sec_doors, access_cargo,  access_bar, access_kitchen)
	alt_titles = list("Lawyer", "Bridge Officer")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/lawyer

/datum/job/lawyer/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	if (H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Lawyer")
				H.equip_or_collect(new /obj/item/clothing/under/lawyer/bluesuit(H), slot_w_uniform)
				H.equip_or_collect(new /obj/item/clothing/suit/storage/lawyer/bluejacket(H), slot_wear_suit)
				H.equip_or_collect(new /obj/item/clothing/shoes/leather(H), slot_shoes)
			if("Bridge Officer")
				H.equip_or_collect (new /obj/item/clothing/shoes/centcom(H), slot_shoes)
				H.equip_or_collect(new /obj/item/clothing/suit/storage/lawyer/bridgeofficer(H), slot_wear_suit)
				H.equip_or_collect(new /obj/item/clothing/under/bridgeofficer, slot_w_uniform)
				H.equip_or_collect(new /obj/item/device/radio/headset/headset_com, slot_ears)
				H.equip_or_collect(new /obj/item/clothing/head/soft/bridgeofficer(H), slot_head)
				H.equip_or_collect(new /obj/item/clothing/gloves/white(H), slot_gloves)
	H.equip_or_collect(new /obj/item/clothing/under/rank/internalaffairs(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/suit/storage/internalaffairs(H), slot_wear_suit)
	H.equip_or_collect(new /obj/item/clothing/shoes/centcom(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
	//H.equip_or_collect(new /obj/item/device/pda/lawyer(H), slot_belt)
	H.put_in_hands(new /obj/item/weapon/storage/briefcase/centcomm(H))
	if(H.backbag == 1)
		H.put_in_hand(GRASP_RIGHT_HAND, new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1
	H.mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Security:</b> [SEC_FREQ] <br/>")
	return 1
