/datum/objective/target/anti_revolution/demote/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [target.assigned_role]  has been classified as harmful to Nanotrasen's goals. Demote \him[target.current] to assistant."
	return target

/datum/objective/target/anti_revolution/demote/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has been classified as harmful to Nanotrasen's goals. Demote \him[target.current] to assistant."
	return target

/datum/objective/target/anti_revolution/demote/IsFulfilled()
	..()
	if(target && target.current && istype(target,/mob/living/carbon/human))
		var/obj/item/weapon/card/id/I = target.current:wear_id
		if(istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/P = I
			I = P.id

		if(!istype(I))
			return TRUE

		if(I.assignment == "Assistant")
			return TRUE
		else
			return FALSE
	return TRUE
