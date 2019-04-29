
/datum/objective/target/anti_revolution/demote
	name = "\[Nanotrasen\] Demote <target>"

/datum/objective/target/anti_revolution/demote/format_explanation()
	return "[target.current.real_name], the [target.assigned_role]  has been classified as harmful to Nanotrasen's goals. Demote \him[target.current] to assistant."


/datum/objective/target/anti_revolution/demote/IsFulfilled()
	if (..())
		return TRUE
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
