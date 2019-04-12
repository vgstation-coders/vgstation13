/obj/item/weapon/robot_spawner
	name = "portable robot teleporter"
	desc = "A teleporter used to deploy robots on the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	mech_flags = MECH_SCAN_ILLEGAL

	var/charge = 1
	var/autoqdel = FALSE //Do we delete ourselves after running out of juice?
	var/borg_type = /mob/living/silicon/robot

	var/datum/recruiter/recruiter = null
	var/role = ROLE_POSIBRAIN
	var/jobban_roles = list("AI", "Cyborg", "Mobile MMI")
	var/faction = null
	var/busy = FALSE
	var/last_ping_time = 0
	var/ping_cooldown = 5 SECONDS

/obj/item/weapon/robot_spawner/update_icon()
	if(has_icon(icon, "[initial(icon_state)]-searching"))
		icon_state = "[initial(icon_state)][busy ? "-searching" : ""]"

/obj/item/weapon/robot_spawner/attack_self(mob/user)
	request_borg(user)

/obj/item/weapon/robot_spawner/check_uplink_validity()
	return charge > 0 ? TRUE : FALSE

/obj/item/weapon/robot_spawner/attack_ghost(var/mob/dead/observer/O)
	if(last_ping_time + ping_cooldown <= world.time)
		last_ping_time = world.time
		request_borg(O)
	else
		to_chat(O, "\The [name]'s power is low. Try again in a few moments.")

/obj/item/weapon/robot_spawner/proc/request_borg(var/mob/user)
	if(!charge)
		to_chat(user, "\The [name] is out of power.")
		return
	if(busy)
		return

	busy = TRUE
	visible_message("[src] pings.")
	playsound(src, 'sound/machines/signal.ogg', 50, 0)
	update_icon()
	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = name
		recruiter.role = role
		recruiter.jobban_roles = jobban_roles

	recruiter.player_volunteering.Add(src, "recruiter_recruiting")
	recruiter.player_not_volunteering.Add(src, "recruiter_not_recruiting")
	recruiter.recruited.Add(src, "recruiter_recruited")
	recruiter.request_player()

/obj/item/weapon/robot_spawner/proc/recruiter_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	var/area/A = get_area(src)
	to_chat(O, "<span class='recruit'>\The [name] activated at \the [A.name]. Get ready. ([controls])</span>")

/obj/item/weapon/robot_spawner/proc/recruiter_not_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	var/area/A = get_area(src)
	to_chat(O, "<span class='recruit'>\The [name] activated at \the [A.name]. ([controls])</span>")

/obj/item/weapon/robot_spawner/proc/recruiter_recruited(var/list/args)
	var/mob/dead/observer/O = args["player"]
	if(O)
		qdel(recruiter)
		recruiter = null
		busy = FALSE
		charge--
		spark(src, 4)
		var/mob/living/silicon/robot/R = new borg_type(get_turf(loc))
		R.key = O.key
		post_recruited(R)
		if(!charge && autoqdel)
			qdel(src)
	else
		busy = FALSE
		visible_message("[src] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	update_icon()

/obj/item/weapon/robot_spawner/proc/post_recruited(var/mob/living/silicon/robot/R)
	if(!R) //Knock it off.
		return
	if(faction)
		R.faction = faction
	R.Namepick()

//Syndicate robot spawner
/obj/item/weapon/robot_spawner/syndicate
	name = "syndicate robot teleporter"
	desc = "A single-use teleporter used to deploy a syndicate robot on the field."
	borg_type = /mob/living/silicon/robot/syndie
	role = NUKE_OP
	jobban_roles = list("Syndicate", "AI", "Cyborg", "Mobile MMI")
	faction = "syndicate"

/obj/item/weapon/robot_spawner/syndicate/post_recruited(mob/living/silicon/robot/R)
	..()
	var/datum/faction/syndicate/nuke_op/nuclear = find_active_faction_by_type(/datum/faction/syndicate/nuke_op)
	if(nuclear)
		var/datum/role/nuclear_operative/newCop = new
		newCop.AssignToRole(R.mind,1)
		nuclear.HandleRecruitedRole(newCop)
		newCop.Greet(GREET_MIDROUND)


//Strange spawner, a xenoarchaeology find.
/obj/item/weapon/robot_spawner/strange
	icon = 'icons/obj/assemblies.dmi'
	autoqdel = TRUE

/obj/item/weapon/robot_spawner/strange/post_recruited(mob/living/silicon/robot/R)
	..()
	investigation_log(I_ARTIFACT, "|| [key_name(R)] spawned as [R.module.name].")

/obj/item/weapon/robot_spawner/strange/ball
	name = "strange ball"
	desc = "A complex metallic ball with \"TG17355\" carved on its surface."
	icon_state = "omoikaneball"
	borg_type = /mob/living/silicon/robot/hugborg/ball

/obj/item/weapon/robot_spawner/strange/egg
	name = "strange egg"
	desc = "A complex egg-like machine with \"TG17355\" carved on its surface."
	icon_state = "peaceegg"
	borg_type = /mob/living/silicon/robot/hugborg
	w_class = W_CLASS_GIANT
	density = TRUE

/obj/item/weapon/robot_spawner/strange/egg/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.incapacitated() || U.lying || busy)
			return
		if(U.gloves)
			to_chat(U, "<b>You touch \the [name]</b> with your gloved hands, [pick("but nothing of note happens","but nothing happens","but nothing interesting happens","but you notice nothing different","but nothing seems to have happened")].")
			return
		to_chat(U, "<span class='notice'>You touch \the [name].</span>")
		return attack_self(user)

/obj/item/weapon/robot_spawner/strange/egg/attack_paw(mob/user)
	return