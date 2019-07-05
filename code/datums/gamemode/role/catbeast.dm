/datum/role/catbeast
	name = CATBEAST
	id = CATBEAST
	special_role = CATBEAST
	required_pref = ROLE_MINOR
	wikiroute = ROLE_MINOR
	logo_state = "catbeast-logo"
	var/ticks_survived = 0
	var/threat_generated = 0
	var/threat_level_inflated = 0
	var/list/areas_defiled = list()

/datum/role/catbeast/Greet()
	to_chat(antag.current, "<B><span class='warning'>You are a mangy catbeast!</span></B>")
	to_chat(antag.current, "The longer you avoid the crew, the greater danger the station will attract! You will generate threat for each new room you enter and for being alive (up to 5 minutes).")

/datum/role/catbeast/OnPostSetup()
	var/mob/living/carbon/human/H = antag.current
	H.set_species("Tajaran", force_organs=1)
	H.my_appearance.s_tone = CATBEASTBLACK
	H.dna.ResetUI()
	equip_catbeast(H)
	infect_catbeast(H)
	H.regenerate_icons()
	var/datum/gamemode/dynamic/D = ticker.mode
	if(istype(D))
		D.threat_log += "[worldtime2text()]: Loose catbeast created."
		D.threat_log += src //The actual reporting on threat it made comes from this entry
	spawn(1.5 MINUTES)
		if(antag.current.stat!=DEAD && OnStation())
			command_alert("An escaped catbeast has been detected aboard your station. Crew should cooperate with security staff in its extermination or removal from the main station.", "Catbeast Detected",1)
	return TRUE

var/list/catbeast_names = list("Meowth","Fluffy","Subject 246","Experiment 35a","Nyanners","Thing From Below","Airlock Scratcher","Flees-Like-Fleas",
						"Lurks-In-Shadows","Eartha Kitt","Target Practice","Fresh Meat","Ca'thulu","Furry Fury","Vore-Strikes-Back","Killing Machine","Uncle Tom",
						"Nine Lives", "Bad Luck", "Siamese Sam", "Tom Tabby", "Hairball", "Throws-Dice-Poorly", "Wizard Apprentice", "Lynch Lynx", "Felix")

/datum/role/catbeast/proc/infect_catbeast(var/mob/living/carbon/human/H)
	var/list/anti = list(
		ANTIGEN_BLOOD	= 0,
		ANTIGEN_COMMON	= 1,
		ANTIGEN_RARE	= 2,
		ANTIGEN_ALIEN	= 0,
		)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 0,
		EFFECT_DANGER_FLAVOR	= 1,
		EFFECT_DANGER_ANNOYING	= 2,
		EFFECT_DANGER_HINDRANCE	= 3,
		EFFECT_DANGER_HARMFUL	= 3,
		EFFECT_DANGER_DEADLY	= 1,
		)

	var/first_virus_choice = pick(subtypesof(/datum/disease2/disease))
	var/datum/disease2/disease/D1 = new first_virus_choice
	D1.origin = "Loose Catbeast"
	D1.makerandom(list(60,90),list(50,90),anti,bad,null)
	H.infect_disease2(D1,1, "Loose Catbeast")
	var/second_virus_choice = pick(subtypesof(/datum/disease2/disease))
	var/datum/disease2/disease/D2 = new second_virus_choice
	D2.origin = "Loose Catbeast"
	D2.makerandom(list(60,90),list(50,90),anti,bad,null)
	H.infect_disease2(D2,1, "Loose Catbeast")

	to_chat(H, "<span class='warning'>You are also carrying some diseases. Check your notes to see their specs.</span>")

	to_chat(H, "<span class='warning'>You can accelerate their progression by drinking some milk along with some water, so go find some.</span>")

	antag.store_memory("<hr>")
	antag.store_memory(D1.get_info())
	antag.store_memory("<hr>")
	antag.store_memory(D2.get_info())
	antag.store_memory("<hr>")

/proc/equip_catbeast(var/mob/living/carbon/human/H)
	var/list/shirts = list(/obj/item/clothing/under/overalls,/obj/item/clothing/under/schoolgirl,/obj/item/clothing/under/darkholme,/obj/item/clothing/under/maid,
							/obj/item/clothing/under/rottensuit,/obj/item/clothing/under/rank/mailman,/obj/item/clothing/under/color/prisoner,/obj/item/clothing/under/psyche,
							/obj/item/clothing/under/rank/clown,/obj/item/clothing/under/rank/xenoarch)
	var/chosen_shirt = pick(shirts)
	H.equip_to_slot_or_del(new chosen_shirt, slot_w_uniform)
	disable_suit_sensors(H)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/catbeast, slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/messenger, slot_back)
	//Null old name because we're from ghosts
	H.fully_replace_character_name(null,pick(catbeast_names))

/obj/item/clothing/shoes/sandal/catbeast
	desc = "Strange sandals designed with claws in mind. They look uncomfortable if you're not a cat."
	species_restricted = list("Tajaran")
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/catbeast

/datum/role/catbeast/ForgeObjectives()
	AppendObjective(/datum/objective/catbeast/survive5)
	AppendObjective(/datum/objective/catbeast/defile)

#define SURVIVAL_THREAT 1
#define DEFILE_THREAT 0.75

/datum/role/catbeast/process()
	..()
	if(!iscatbeast(antag.current))
		return
	var/area/A = OnStation()
	if(antag.current.stat!=DEAD && A) //Not dead or unconscious or offstation
		ticks_survived++
		if(!(ticks_survived % 10) && ticks_survived < 150) //every 20 seconds, for 5 minutes
			increment_threat(SURVIVAL_THREAT)
		if(!(A in areas_defiled))
			increment_threat(DEFILE_THREAT)
			areas_defiled.Add(A)
			to_chat(antag.current,"<span class='notice'>You have defiled [A.name] with your presence.")

/datum/role/catbeast/proc/OnStation()
	if(antag.current.z != STATION_Z)
		return FALSE
	var/area/A = get_area(antag.current)
	if (isspace(A))
		return FALSE
	return A

/datum/role/catbeast/proc/increment_threat(var/amount)
	var/datum/gamemode/dynamic/D = ticker.mode
	if(!istype(D))
		return //It's not dynamic!
	threat_generated += amount
	if(D.threat >= D.threat_level)
		D.create_threat(amount)
		if(!threat_level_inflated) //Our first time raising the cap
			D.threat_log += "[worldtime2text()]: A catbeast started increasing the threat cap."
		threat_level_inflated += amount
	else
		D.refund_threat(amount)

/datum/role/catbeast/GetScoreboard()
	. = ..()
	. += "The catbeast survived on station for [ticks_survived*2] seconds, defiled [areas_defiled.len] rooms, and generated [threat_generated] threat!<BR>"
