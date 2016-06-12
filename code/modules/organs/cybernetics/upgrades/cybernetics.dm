/obj/item/cybernetics
	//This thing doesn't actually exist, just something for inheritance
	var/required_type //If the upgrade is only for a specific organ, if not then keep it empty

/obj/item/cybernetics/afterattack(var/obj/item/O, mob/user, proximity_flag)
	if (!proximity_flag)
		return

	if(istype(O, /obj/item/organ))
		var/obj/item/organ/I = O
		if(I.robotic != 2)
			to_chat(usr, "\the [O] isn't robotic.")
			return
		to_chat(user, "DEBUG - Succesfull application of [src] to [I].")
		apply(I)
	else if (istype(O, /obj/item/robot_parts))
		var/obj/item/robot_parts/E = O
		//Narrowing it down to the actual limbs
		var/Coveredlimbs = list(/obj/item/robot_parts/l_arm,
									/obj/item/robot_parts/r_arm,
									/obj/item/robot_parts/l_leg,
									/obj/item/robot_parts/r_leg)
		if(is_type_in_list(E, Coveredlimbs))
			to_chat(user, "DEBUG - Succesfull application of [src] to [E].")
			apply(E)
		else
			to_chat(user, "\the [E] has no current surgical applications for carbon reconstruction, so is not supported for cybernetic enhancement.")
			return
	else
		to_chat(usr, "\The [src] won't work on \the [O].")
		return
		//Remember to delete this little chunk, right now it's just used for debug

/obj/item/cybernetics/proc/apply(var/obj/item/O, mob/user)
	to_chat(user, "Succesfully applied \the [src].")
	//Nothing to see here