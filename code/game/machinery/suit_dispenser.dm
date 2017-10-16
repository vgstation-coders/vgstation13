//////////////////////////////////////
// SUIT DISPENSER UNIT ///////////////
//////////////////////////////////////

var/list/dispenser_presets = list()

/obj/machinery/suit_dispenser
	name = "Suit Dispenser"
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of space suits.."
	icon = 'icons/obj/suitdispenser.dmi'
	icon_state = "suitdispenser"
	anchored = 1
	density = 1



/obj/machinery/suit_dispenser/ert
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of space suits. This one distribributes Emergency Responder space suits."

/obj/machinery/suit_dispenser/ert/attack_hand(var/mob/user)
	if(sentStrikeTeams(TEAM_ERT))
		var/datum/striketeam/ert/team = sent_strike_teams[TEAM_ERT]
		if (user in response_team_members)
			if (user in distributed_ert_suits)
				to_chat(user,"<span class='warning'>You've already picked up your suit.</span>")
			else
				if (user.key == team.leader_key)
					to_chat(user,"<span class='notice'>Identified as [user.real_name]. Here is your suit commander. Have a good day.</span>")

					flick("suitdispenser-flick",src)

					sleep(17)

					if (user in distributed_ert_suits)
						return

					distributed_ert_suits |= user

					var/turf/T = get_turf(src)

					new /obj/item/clothing/suit/space/ert/commander(T)
					new /obj/item/clothing/head/helmet/space/ert/commander(T)

				else
					to_chat(user,"<span class='notice'>Identified as [user.real_name]. Please choose your suit specialization.")

					var/list/suit_list = list(
						"Security",
						"Medical",
						"Engineer",
						"CANCEL"
						)

					var/choice = input("Choose your suit specialization.", "Suit Dispenser") in suit_list

					if(choice == "CANCEL")
						return

					flick("suitdispenser-flick",src)

					sleep(17)

					if (user in distributed_ert_suits)
						return

					distributed_ert_suits |= user

					var/turf/T = get_turf(src)

					switch(choice)
						if("Security")
							new /obj/item/clothing/suit/space/ert/security(T)
							new /obj/item/clothing/head/helmet/space/ert/security(T)
							to_chat(user,"<span class='notice'>Security specialization processed. Have a good day.</span>")
						if("Medical")
							new /obj/item/clothing/suit/space/ert/medical(T)
							new /obj/item/clothing/head/helmet/space/ert/medical(T)
							to_chat(user,"<span class='notice'>Medical specialization processed. Have a good day.</span>")
						if("Engineer")
							new /obj/item/clothing/suit/space/ert/engineer(T)
							new /obj/item/clothing/head/helmet/space/ert/engineer(T)
							to_chat(user,"<span class='notice'>Engineer specialization processed. Have a good day.</span>")

		else
			to_chat(user,"<span class='warning'>Access Denied. You aren't part of the Emergency Response Team.</span>")
	else
		to_chat(user,"<span class='warning'>Access Denied. No Emergency Response Team has been dispatched yet.</span>")


/obj/machinery/suit_dispenser/striketeam
	icon_state = "suitdispenser-empty"
	var/preset = null
	var/used = 0

/obj/machinery/suit_dispenser/striketeam/attack_hand(var/mob/user)
	if(!preset)
		to_chat(user,"<span class='warning'>Error. No presets have been set.</span>")
		return

	if(used)
		to_chat(user,"<span class='warning'>This dispenser must be reloaded by authorities in charge before you can use it again.</span>")
		return

	used = 1

	var/list/items_to_spawn = dispenser_presets[preset]

	icon_state = "suitdispenser-open"
	flick("suitdispenser-once",src)

	sleep(17)

	var/turf/T = get_turf(src)

	for(var/i = 1 to items_to_spawn.len)
		var/spawntype = items_to_spawn[i]
		new spawntype(T)


/obj/machinery/suit_dispenser/striketeam/attack_ghost(var/mob/user)
	if(isAdminGhost(user))
		var/list/choices = list(
			"Define Preset from items on top",
			"Choose a Preset",
			)

		if (used)
			choices |= "Resupply"

		choices |= "CANCEL"

		var/choice = input("Choose action.", "Suit Dispenser") in choices

		switch(choice)
			if("CANCEL")
				return
			if("Define Preset from items on top")
				var/list/items_on_top = list()
				for (var/obj/item/I in get_turf(src))
					items_on_top += I.type
				if (items_on_top.len <= 0)
					to_chat(user,"<span class='warning'>Error. No items on top of the dispenser. Place items on top of the dispenser to define them as presets.</span>")
					return
				else
					var/preset_name = input(user,"[items_on_top.len] items found. Name your Preset","Suit Dispenser", null) as text|null
					if (!preset_name)
						return
					dispenser_presets[preset_name] = items_on_top
			if("Choose a Preset")
				if (dispenser_presets.len <= 0)
					to_chat(user,"<span class='warning'>Error. No presets have been set. Place items on top of the dispenser to define them as presets.</span>")
					return
				var/no_preset = !preset
				preset = input(user,"Choose a Preset.", "Suit Dispenser") in dispenser_presets
				if (preset && no_preset)
					icon_state = "suitdispenser"
					flick("suitdispenser-fill",src)
			if("Resupply")
				used = 0
				icon_state = "suitdispenser"
				flick("suitdispenser-resupply",src)
