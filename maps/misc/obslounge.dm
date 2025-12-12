/datum/map_element/dungeon/obslounge
	file_path = "maps/misc/obslounge.dmm"
	unique = TRUE
	var/obj/effect/landmark/obs_spawn/obs_spawner

/obj/effect/step_trigger/ghostizer
	var/joins_obsgang = FALSE

/obj/effect/step_trigger/ghostizer/Trigger(var/atom/movable/A)
	if(isliving(A))
		var/mob/living/L = A
		var/mob/dead/observer/obsganger = L.ghostize()
		obsganger.started_as_observer = joins_obsgang
		qdel(L)

/obj/effect/step_trigger/ghostizer/obsgang
	joins_obsgang = TRUE

/obj/effect/landmark/obs_spawn
	name = "obsgang spawner"

/obj/effect/landmark/obs_spawn/spawned_by_map_element(datum/map_element/ME, list/objects)
	if(ME.type == /datum/map_element/dungeon/obslounge)
		var/datum/map_element/dungeon/obslounge/OBS = ME
		OBS.obs_spawner = src

/obj/effect/landmark/obs_spawn/Crossed(H as mob|obj)
	..()
	if(istype(H, /mob/dead/observer))
		spawn_mob(H)

/obj/effect/landmark/obs_spawn/proc/spawn_mob(mob/M) //Stripped down character creation without disabilities or language
	var/datum/preferences/prefs = M.client.prefs
	var/datum/species/chosen_species

	var/species = prefs.get_pref(/datum/preference_setting/string/species)
	var/datum/preference_setting/name_pref = prefs.get_pref_datum(/datum/preference_setting/string/real_name)

	if(species)
		chosen_species = all_species[species]

	// Determine mob type based on species. This means every player is no longer a human
	var/mob_type = /mob/living/carbon/human
	if(chosen_species)
		switch(chosen_species.name)
			if("Vox") mob_type = /mob/living/carbon/human/vox
			if("Unathi") mob_type = /mob/living/carbon/human/unathi
			if("Skrell") mob_type = /mob/living/carbon/human/skrell
			if("Tajaran") mob_type = /mob/living/carbon/human/tajaran
			if("Diona") mob_type = /mob/living/carbon/human/diona
			if("Plasmaman") mob_type = /mob/living/carbon/human/plasmaman

	var/mob/living/carbon/human/new_character = new mob_type(loc)
	new_character.status_flags = GODMODE|CANPUSH|UNPACIFIABLE

	if(species)
		chosen_species = all_species[species]
	new_character.set_species(species)

	if(ticker.random_players || appearance_isbanned(src)) //disabling ident bans for now
		var/datum/preference_setting/flavor_text = prefs.get_pref_datum(/datum/preference_setting/string/flavor_text)
		new_character.setGender(pick(MALE, FEMALE))
		name_pref.setting = random_name(new_character.gender, new_character.species.name)
		prefs.randomize_appearance_for(new_character)
		flavor_text.setting = ""
	else
		prefs.copy_to(new_character)

	new_character.equip_to_slot_or_del(new /obj/item/clothing/under/color/white(new_character), slot_w_uniform)
	new_character.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(new_character), slot_shoes)
	new_character.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(new_character), slot_back)

	if (M.mind)
		M.mind.active = 0 // we wish to transfer the key manually
		M.mind.transfer_to(new_character) // won't transfer key since the mind is not active

	new_character.name = name_pref.setting
	new_character.dna.ready_dna(new_character)

	new_character.key = M.key

/area/obslounge
	name = "Unknown"
	requires_power = 0
	dynamic_lighting = 0
	icon_state = "firingrange"

/obj/machinery/computer/security/telescreen/entertainment/wooden_tv/obsgang
	network = list(CAMERANET_SS13, CAMERANET_OBS)

/obj/machinery/computer/security/telescreen/entertainment/wooden_tv/obsgang/get_available_cameras()
	for(var/mob/living/L in player_list) //sets it here
		if(!L.obs_camera)
			L.obs_camera = new(L)
			L.obs_camera.network = list(CAMERANET_OBS)
	. = ..()
