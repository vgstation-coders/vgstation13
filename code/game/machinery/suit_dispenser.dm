//////////////////////////////////////
// SUIT DISPENSER UNIT ///////////////
//////////////////////////////////////

#define SD_BUSY			1		// the dispenser is busy.
#define SD_ONESUIT		2		// only one type of suit comes out of this dispenser.
#define SD_NOGREED		4		// no-one is allowed more than one suit from this TYPE of dispenser unless emagged
#define SD_UNLIMITED	8		// will not deplete amount when armour is taken

var/list/dispenser_presets = list()

/datum/suit
	var/name = "suit"
	var/list/to_spawn = list()
	var/amount = 0

/datum/suit/custom
	name = "custom"

/obj/machinery/suit_dispenser
	name = "Suit Dispenser"
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of space suits.."
	icon = 'icons/obj/suitdispenser.dmi'
	icon_state = "suitdispenser"
	anchored = 1
	density = 1
	var/list/suits = list() // put your suit datums here!
	var/datum/suit/one_suit
	var/global/list/suit_distributed_to = list()
	var/dispenser_flags = SD_NOGREED|SD_UNLIMITED
	machine_flags = EMAGGABLE

/obj/machinery/suit_dispenser/New()
	if(!suit_distributed_to["[type]"] && (dispenser_flags & SD_NOGREED))
		suit_distributed_to["[type]"] = list()
	var/list/real_suits_list = list()
	for(var/suit in suits)
		var/datum/suit/S = new suit
		real_suits_list[S.name] = S
	if(one_suit)
		one_suit = new one_suit
	suits = real_suits_list
	..()

/obj/machinery/suit_dispenser/attack_hand(var/mob/living/carbon/human/user)
	if(!can_use(user))
		return
	dispenser_flags |= SD_BUSY
	if(!(dispenser_flags & SD_ONESUIT))
		var/suit_list = get_suit_list(user)
		suit_list["CANCEL"] = "CANCEL"
		var/choice = input("Choose your suit specialisation.", "Suit Dispenser") in suit_list
		if(choice == "CANCEL")
			return
		dispense(suit_list[choice],user)
	else
		dispense(one_suit,user)


/obj/machinery/suit_dispenser/proc/can_use(var/mob/living/carbon/human/user)
	var/list/used_by = suit_distributed_to["[type]"]
	if(!istype(user))
		to_chat(user,"<span class='warning'>You can't use this!</span>")
		return 0
	if((dispenser_flags & SD_BUSY))
		to_chat(user,"<span class='warning'>Someone else is using this!</span>")
		return 0
	if((dispenser_flags & SD_ONESUIT) && !one_suit.amount)
		to_chat(user,"<span class='warning'>There's nothing in here!</span>")
		return 0
	if ((dispenser_flags & SD_NOGREED) && (user in used_by) && !emagged)
		to_chat(user,"<span class='warning'>You've already picked up your suit!</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return 0
	else if(emagged)
		say("!'^&YouVE alreaDY pIC&$!Ked UP yOU%r Su^!it.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 100, 0)
		return 1
	return 1

/obj/machinery/suit_dispenser/proc/get_suit_list(var/mob/living/carbon/human/user)
	return suits

/obj/machinery/suit_dispenser/proc/dispense(var/datum/suit/S,var/mob/living/carbon/human/user,var/greet=TRUE)
	if(!S.amount && !(dispenser_flags & SD_UNLIMITED))
		to_chat(user,"<span class='warning'>There are no more [S.name] suits left!</span>")
		dispenser_flags &= ~SD_BUSY
		return 1
	else if(!(dispenser_flags & SD_UNLIMITED))
		S.amount--
	if((dispenser_flags & SD_NOGREED) && !emagged)
		suit_distributed_to["[type]"] |= user
	flick("suitdispenser-flick",src)
	dispenser_flags |= SD_BUSY
	sleep(17)
	dispenser_flags &= ~SD_BUSY

	var/turf/T = get_turf(src)
	if(!(S && T)) // in case we got destroyed while we slept
		return 1
	for(var/O in S.to_spawn)
		new O(T)
	if(emagged)
		emagged = FALSE
	if(greet && user && !user.stat) // in case we got destroyed while we slept
		to_chat(user,"<span class='notice'>[S.name] specialisation processed. Have a good day.</span>")


/obj/machinery/suit_dispenser/emag(var/mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			user.visible_message("<span class='warning'>\The [user] slides a weird looking ID into \the [src], and sparks come flying out!</span>","<span class='warning'>You temporarily short the safety mechanisms.</span>")
		playsound(src, pick(spark_sound), 75, 1)
		spark(src,4)

/obj/machinery/suit_dispenser/proc/promptfornum(var/mob/user)
	var/num = input(user,"How many supplies would you like to add? (Set to -1 for infinite)","Suit Dispenser", null) as num|null
	if(num == -1)
		dispenser_flags |= SD_UNLIMITED
	else return num

////////////////////////////// ERT SUIT DISPENSERS ///////////////////////////


/datum/suit/ert/security
	name = "Security"
	to_spawn = list(/obj/item/clothing/suit/space/ert/security,/obj/item/clothing/head/helmet/space/ert/security)

/datum/suit/ert/medical
	name = "Medical"
	to_spawn = list(/obj/item/clothing/suit/space/ert/medical,/obj/item/clothing/head/helmet/space/ert/medical)

/datum/suit/ert/engineer
	name = "Engineering"
	to_spawn = list(/obj/item/clothing/suit/space/ert/engineer,/obj/item/clothing/head/helmet/space/ert/engineer)

/datum/suit/ert/commander
	name = "Commander"
	to_spawn = list(/obj/item/clothing/suit/space/ert/commander,/obj/item/clothing/head/helmet/space/ert/commander)

/obj/machinery/suit_dispenser/ert
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of space suits. This one distribributes Emergency Responder space suits."
	suits = list(/datum/suit/ert/security,/datum/suit/ert/medical,/datum/suit/ert/engineer)

/obj/machinery/suit_dispenser/ert/can_use(var/mob/living/carbon/human/user)
	if(!..())
		return
	if(sentStrikeTeams(TEAM_ERT))
		if(user in response_team_members)
			return 1
		else
			to_chat(user,"<span class='warning'>Access Denied. You aren't part of the Emergency Response Team.</span>")
	else
		to_chat(user,"<span class='warning'>Access Denied. No Emergency Response Team has been dispatched yet.</span>")

/obj/machinery/suit_dispenser/ert/attack_hand(var/mob/living/carbon/human/user)
	var/list/used_by = suit_distributed_to["[type]"]
	var/datum/striketeam/ert/team = sent_strike_teams[TEAM_ERT]
	if (user.key == team.leader_key && !(user in used_by))
		if(!can_use(user))
			return
		to_chat(user,"<span class='notice'>Identified as [user.real_name]. Have a good day, Commander!</span>")
		dispense(new /datum/suit/ert/commander,user,greet=FALSE)
	else ..()

/obj/machinery/suit_dispenser/striketeam
	icon_state = "suitdispenser-empty"
	dispenser_flags = SD_ONESUIT

/obj/machinery/suit_dispenser/striketeam/can_use(var/mob/living/carbon/human/user)
	if(!..())
		return
	if(!one_suit)
		to_chat(user,"<span class='warning'>Error. No presets have been set.</span>")
		return
	return 1

/obj/machinery/suit_dispenser/striketeam/attack_ghost(var/mob/user)
	if(isAdminGhost(user))
		var/list/choices = list(
			"Define Preset from items on top",
			"Choose a Preset",
			)

		if (one_suit && !one_suit.amount)
			choices |= "Resupply"

		choices |= "CANCEL"

		var/choice = input("Choose action.", "Suit Dispenser") in choices

		switch(choice)
			if("CANCEL")
				return
			if("Define Preset from items on top")
				var/datum/suit/custom/preset = new
				for (var/obj/item/I in get_turf(src))
					preset.to_spawn += I.type
				if (!preset.to_spawn.len)
					to_chat(user,"<span class='warning'>Error. No items on top of the dispenser. Place items on top of the dispenser to define them as presets.</span>")
					return
				else
					var/preset_name = input(user,"[preset.to_spawn.len] items found. Name your Preset","Suit Dispenser", null) as text|null
					if (!preset_name)
						qdel(preset)
						return
					preset.name = preset_name
					dispenser_presets[preset_name] = preset
					to_chat(user,"<span class='notice'>Preset saved!</span>")

			if("Choose a Preset")
				if (!dispenser_presets.len)
					to_chat(user,"<span class='warning'>Error. No presets have been set. Place items on top of the dispenser to define them as presets.</span>")
					return
				var/chosen = input(user,"Choose a Preset.", "Suit Dispenser") in dispenser_presets
				var/datum/suit/custom/preset = dispenser_presets[chosen]
				one_suit = new /datum/suit/custom
				one_suit.name = preset.name
				one_suit.to_spawn = preset.to_spawn
				one_suit.amount = promptfornum(user)
				icon_state = "suitdispenser"
				flick("suitdispenser-fill",src)


			if("Resupply")
				one_suit.amount = promptfornum(user)
				icon_state = "suitdispenser"
				flick("suitdispenser-resupply",src)


////////////////// DORF FORT DISPENSER //////////////////
// do NOT spawn this on the main map or I will SCREAM //

/datum/suit/dorf/standard
	name = "Standard"
	to_spawn = list(/obj/item/clothing/head/helmet/space,/obj/item/clothing/suit/space)

/datum/suit/dorf/security
	name = "Security"
	to_spawn = list(/obj/item/clothing/head/helmet/space/rig/security,/obj/item/clothing/suit/space/rig/security)

/datum/suit/dorf/engineering
	name = "Engineering"
	to_spawn = list(/obj/item/clothing/head/helmet/space/rig,/obj/item/clothing/suit/space/rig)

/datum/suit/dorf/medical
	name = "Medical"
	to_spawn = list(/obj/item/clothing/head/helmet/space/rig/medical,/obj/item/clothing/suit/space/rig/medical)

/datum/suit/dorf/atmos
	name = "Atmospherics Technician"
	to_spawn = list(/obj/item/clothing/head/helmet/space/rig/atmos,/obj/item/clothing/suit/space/rig/atmos)

/datum/suit/dorf/paramedic
	name = "Paramedic"
	to_spawn = list(/obj/item/clothing/head/helmet/space/paramedic,/obj/item/clothing/suit/space/paramedic)

/datum/suit/dorf/mining
	name = "Mining"
	to_spawn = list(/obj/item/clothing/suit/space/rig/mining, /obj/item/clothing/head/helmet/space/rig/mining)

/*/datum/suit/dorf/head
	amount = 1

/datum/suit/dorf/head/captain
	name = "Captain"
	to_spawn = (/obj/item/clothing/suit/armor/captain,/obj/item/clothing/head/helmet/space/capspace)

/datum/suit/dorf/head/chiefengie
	name = "Chief Engineer"
	to_spawn = (/obj/item/clothing/suit/space/rig/elite,/obj/item/clothing/head/helmet/space/rig/elite,/obj/item/clothing/shoes/magboots/elite)*/


/obj/machinery/suit_dispenser/dorf
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of space suits. This one is specialised towards asteroid reclamation teams."
	suits = list(/datum/suit/dorf/standard,/datum/suit/dorf/security,/datum/suit/dorf/engineering,/datum/suit/dorf/medical,/datum/suit/dorf/atmos,/datum/suit/dorf/paramedic)

/obj/machinery/suit_dispenser/dorf/get_suit_list(var/mob/living/carbon/human/user)
	if(emagged)
		return suits
	var/list/suit_list = list()
	suit_list["Standard"] = suits["Standard"]
	var/obj/item/weapon/card/id/card = user.get_id_card()
	if(!card)
		return suit_list
	for(var/job in card.access)
		switch(job)
			if(access_brig)
				suit_list["Security"] = suits["Security"]
			if(access_medical)
				suit_list["Medical"] = suits["Medical"]
			if(access_mining)
				suit_list["Mining"] = suits["Mining"]
			if(access_paramedic)
				suit_list["Paramedic"] = suits["Paramedic"]
			if(access_atmospherics)
				suit_list["Atmospherics Technician"] = suits["Atmospherics Technician"]
			if(access_engine)
				suit_list["Engineering"] = suits["Engineering"]
	return suit_list

/obj/machinery/suit_dispenser/standard
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch a specific mass produced suit."
	dispenser_flags = SD_ONESUIT|SD_NOGREED|SD_UNLIMITED
	one_suit = /datum/suit/dorf/standard