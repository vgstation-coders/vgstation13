/obj/item/device/nuclear_challenge
	name = "Syndicate Communications Device"
	icon = 'icons/obj/radio.dmi'
	item_state = "walkietalkie"
	icon_state = "walkietalkie"
	desc = "Use this to request reinforcements from the syndicate. This will delay your departure and the insecure line means neighbouring stations will hear your request."
	var/declaring_war = FALSE

/obj/item/device/nuclear_challenge/attack_self(mob/living/user)
	if(!check_allowed(user))
		return

	declaring_war = TRUE
	var/are_you_sure = alert(user, "Consult your team carefully before requesting reinforcements. This will alert the enemy crew?", "Request Reinforcments?", "Yes", "No")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(are_you_sure != "Yes")
		to_chat(user, "On second thought, the element of surprise isn't so bad after all.")
		return

	if(!check_allowed(user))
		return

	war_was_declared(user)


/obj/item/device/nuclear_challenge/proc/war_was_declared(mob/living/user)
	war_declared = TRUE
	war_declared_time = world.time / 10
	command_alert(/datum/command_alert/nuclear_operatives_war)
	new /datum/event/unlink_from_centcomm
	if(user)
		to_chat(user, "You've attracted the attention of powerful forces within the syndicate. \
			A bonus bundle of telecrystals has been granted to your team. Great things await you if you complete the mission.")
		var/obj/item/stack/telecrystal/R = new(get_turf(usr), 120)
		usr.put_in_hands(R)
		ticker.StartThematic("nukesquad")

	qdel(src)


/obj/item/device/nuclear_challenge/proc/check_allowed(mob/living/user)
	var/turf/device_turf = get_turf(usr)
	if(device_turf.z != map.zCentcomm)
		to_chat(user, "You have to be at your base to use this.")
		return FALSE
	if(!can_war_be_declared)
		to_chat(user, "Your Comrades have already gone to the station! You cannot request reinforcements now.")
		return FALSE
	return TRUE
