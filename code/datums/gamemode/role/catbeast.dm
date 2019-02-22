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
	H.dna.ResetUI()
	equip_catbeast(H)
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
