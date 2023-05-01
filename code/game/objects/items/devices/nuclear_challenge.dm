#define CHALLENGE_TELECRYSTALS 280
#define CHALLENGE_SHUTTLE_DELAY 1800
#define CHALLENGE_TC_PER_OP 60


/obj/item/device/nuclear_challenge
	name = "Declaration of War (Challenge Mode)"
	icon_state = "multitool"
	desc = "Use to send a declaration of hostilities to the target, delaying your shuttle departure for 20 minutes while they prepare for your assault.  \
			Such a brazen move will attract the attention of powerful benefactors within the Syndicate, who will supply your team with a massive amount of bonus telecrystals.  \
			Must be used within five minutes, or your benefactors will lose interest."
	var/declaring_war = FALSE

/obj/item/device/nuclear_challenge/attack_self(mob/living/user)
	if(!check_allowed(user))
		return

	declaring_war = TRUE
	var/are_you_sure = alert(user, "Consult your team carefully before you declare war on [station_name()]. Are you sure you want to alert the enemy crew?", "Declare war?", "Yes", "No")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(are_you_sure != "Yes")
		to_chat(user, "On second thought, the element of surprise isn't so bad after all.")
		return

	declaring_war = TRUE
	var/custom_threat = alert(user, "Do you want to customize your declaration?", "Customize?", "Yes", "No")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(custom_threat == "Yes")
		declaring_war = TRUE
		war_declaration = input(user, "Insert your custom declaration", "Declaration")
		declaring_war = FALSE

	if(!check_allowed(user) || !war_declaration)
		return

	war_was_declared(user)


/obj/item/device/nuclear_challenge/proc/war_was_declared(mob/living/user)
	war_declared = TRUE
	war_declared_time = world.time / 10
	command_alert(/datum/command_alert/nuclear_operatives_war)
	new /datum/event/nuclear_war
	if(user)
		to_chat(user, "You've attracted the attention of powerful forces within the syndicate. \
			A bonus bundle of telecrystals has been granted to your team. Great things await you if you complete the mission.")
		var/datum/faction/syndicate/nuke_op = find_active_faction_by_type(/datum/faction/syndicate/nuke_op)
		var/obj/item/stack/telecrystal/R = new(get_turf(usr), CHALLENGE_TC_PER_OP * nuke_op.members.len)
		usr.put_in_hands(R)

	qdel(src)


/obj/item/device/nuclear_challenge/proc/check_allowed(mob/living/user)
	if(declaring_war)
		to_chat(user, "You are already in the process of declaring war! Make your mind up.")
		return FALSE
	var/turf/device_turf = get_turf(usr)
	if(device_turf.z != map.zCentcomm)
		to_chat(user, "You have to be at your base to use this.")
		return FALSE
	if(syndicate_shuttle.moved)
		to_chat(user, "Your Comrades have already gone to the station! You have forfeit the right to declare war.")
		return FALSE
	return TRUE

#undef CHALLENGE_TELECRYSTALS
#undef CHALLENGE_SHUTTLE_DELAY
#undef CHALLENGE_TC_PER_OP
