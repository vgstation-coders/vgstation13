/datum/objective/target/skulls
	name = "\[Syndicate\] steal skulls"
	var/amount

/datum/objective/target/skulls/format_explanation()
	return "Capture [amount] trophy skulls (decapitated heads). They must be from NT employees."

/datum/objective/target/skulls/find_target()
	amount = rand(2,5)
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
	for(var/obj/item/organ/external/head/H in recursive_type_check(owner, /obj/item/organ/external/head))
		if(!H.organ_data)
			continue
		var/mob/living/carbon/brain/B = H.brainmob
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

