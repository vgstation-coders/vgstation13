/datum/objective/target/skulls
	name = "\[Syndicate\] steal skulls"
	var/amount

/datum/objective/target/skulls/format_explanation()
	return "Capture [amount] trophy skulls (decapitated heads). They must be from NT employees."

/datum/objective/target/skulls/find_target()
	var/living_player_amt = player_list.len
	if (ticker.current_state >= GAME_STATE_PLAYING && istype(ticker.mode, /datum/gamemode/dynamic))
		var/datum/gamemode/dynamic/D = ticker.mode
		living_player_amt = D.living_players.len
	else if(ticker.current_state < GAME_STATE_PLAYING)
		living_player_amt = 0
		for(var/mob/new_player/N in player_list)
			if(N.ready)
				living_player_amt++
	amount = clamp(rand(2,5),1,living_player_amt)
	explanation_text = format_explanation()
	return 1

/datum/objective/target/skulls/select_target()
	auto_target = FALSE
	var/new_target = input("How many skulls?:", "Objective target", null) as num
	if(!new_target)
		return FALSE
	amount = new_target
	explanation_text = format_explanation()
	return TRUE


/datum/objective/target/skulls/IsFulfilled()
	if (..())
		return TRUE
	var/collected = 0
	for(var/obj/item/organ/external/head/H in recursive_type_check(owner.current, /obj/item/organ/external/head))
		if(!H.organ_data)
			continue
		var/mob/living/carbon/brain/B = H.brainmob
		if(!B)
			continue
		if(!B.client)
			if(!B.mind)
				continue
			else
				for(var/mob/M in player_list)
					if(M.key == B.mind.key)
						collected++
						continue
		else
			collected++
	return collected >= amount

