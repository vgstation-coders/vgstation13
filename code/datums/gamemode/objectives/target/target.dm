/datum/objective/target
	var/datum/mind/target = null	//If they are focused on a particular person.
	var/target_amount = 0	//If they are focused on a particular number. Steal objectives have their own counter.
	var/list/bad_assassinate_targets = list("AI","Cyborg","Mobile MMI","Trader")

/datum/objective/target/proc/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in ticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.z != map.zCentcomm) && (possible_target.current.stat != DEAD) && !(possible_target.assigned_role in bad_assassinate_targets))
			possible_targets += possible_target
	if(possible_targets.len > 0)
		target = pick(possible_targets)

/datum/objective/target/proc/find_target_by_role(role, role_type = 0)//Option sets either to check assigned role or special role. Default to assigned.
	for(var/datum/mind/possible_target in ticker.minds)
		if((possible_target != owner) && ishuman(possible_target.current) && (possible_target.current.z != map.zCentcomm) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) && !(possible_target.assigned_role in bad_assassinate_targets))
			target = possible_target
			break

/datum/objective/target/IsFulfilled()
	if(!target) //BE YOURSELF
		return TRUE
