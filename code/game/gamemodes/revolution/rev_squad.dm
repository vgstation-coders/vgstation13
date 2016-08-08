/datum/game_mode/rev_squad
  name = "Revolution Squad"
  config_tag = "revsquad"
  restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Mobile MMI","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")
  desc = "A variant of revolution, with an emphasis on a small group with co-ordinated efforts instead of greytiding"

  required_players = 4
  required_players_secret = 25
  required_enemies = 3
  recommended_enemies = 3
  var/finished = 0
  var/checkwin_counter = 0
  var/max_headrevs = 3
  var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
  var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

  var/possible_items = list(/obj/item/weapon/card/emag,
                            /obj/item/clothing/gloves/yellow,
                            /obj/item/weapon/gun/projectile/automatic,
                            /obj/item/device/flash/revsquad,
                            /obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawnoff
                            )
  var/flash_uses = 1 // Number of times a specially spawned flash can convert normal crew members.


/datum/game_mode/rev_squad/announce()
	to_chat(world, "<B>The current game mode is - Revolution Squad!</B>")
	to_chat(world, "<B>Some crewmembers are members of an organized group attempting to assassinate the heads of this station!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. \nPersonnel - Protect the heads of staff. Kill the revolutionaries.</B>")


/datum/game_mode/revsquad/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_revs = get_players_for_role(ROLE_REV)

	var/head_check = 0
	for(var/mob/new_player/player in player_list)
		if(player.mind.assigned_role in command_positions)
			head_check++

	for(var/datum/mind/player in possible_revs)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				possible_revs -= player

	for (var/i=1 to max_headrevs)
		if (possible_revs.len==0)
			break
		var/datum/mind/lenin = pick(possible_revs)
		possible_revs -= lenin
		head_revolutionaries += lenin

	if((revolutionaries.len==0)||(!head_check))
		log_admin("Failed to set-up a round of revsquad. Couldn't find any heads of staffs or any volunteers to be revolutionaries.")
		message_admins("Failed to set-up a round of revsquad. Couldn't find any heads of staffs or any volunteers to be revolutionaries.")
		return 0

	log_admin("Starting a round of revsquad with [head_revolutionaries.len] revolutionaries and [head_check] heads of staff.")
	message_admins("Starting a round of revsquad with [head_revolutionaries.len] revolutionaries and [head_check] heads of staff.")
	return 1

/datum/game_mode/revolution/post_setup()
	var/list/heads = get_living_heads()

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj

		equip_revsquad(rev_mind.current)
		update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revsquad(rev_mind)
	modePlayer += head_revolutionaries
	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1
	spawn (rand(waittime_l, waittime_h))
		if(!mixed) send_intercept()
	..()

/datum/game_mode/revsquad/process()
	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0

/datum/game_mode/proc/greet_revsquad(var/datum/mind/rev_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		to_chat(rev_mind.current, "<span class='notice'>You are a member of the organized revolutionary organization that has infiltrated this station!</span>")
	for(var/datum/objective/objective in rev_mind.objectives)
		to_chat(rev_mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		rev_mind.special_role = "Revolutionary Squad Member"
		obj_count++

  to_chat(rev_mind.current, "<br/><b>Your fellow revolutionaries are:</b>")
  rev_mind.store_memory("<br/><b>Your fellow revolutionaries are:</b>")
  for(var/datum/mind/M in head_revolutionaries)
    rev_mind.store_memory("[M.assigned_role] the [assigned_job.title]")
    to_chat(rev_mind.current, "[M.assigned_role] the [assigned_job.title]")

/datum/game_mode/revsquad/proc/get_squaddie_item(/mob/living/carbon/human/mob)
  var/obj/item/requisitioned = pick(possible_items)
  if(istype(requisitioned, /obj/item/device/flash/revsquad))
    requsitioned = new requsitioned(mob, uses = flash_uses)
  else
    requisitioned = new requisitioned(mob)
  return requisitioned

/datum/game_mode/proc/equip_revsquad(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(M_CLUMSY)

  var/obj/item/T = get_squaddie_item(mob)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
	)
	var/where = mob.equip_in_one_of_slots(T, slots, put_in_hand_if_fail = 0)

	if (!where)
		to_chat(mob, "The Syndicate were unfortunately unable to get you any special equipment.")
	else
		to_chat(mob, "The [T] in your [where] will help you to persuade the crew to join your cause.")
    if(istype(T, /obj/item/weapon/flash/revsquad))
      to_chat(mob, "<span class = 'warning'>Your [T] has [T.limited_conversions] uses for conversions, and not all of your comrades have one like it. Use it wisely.</span>")
		mob.update_icons()
		return 1
