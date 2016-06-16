//Cybernetics upgrades

/obj/item/cybernetics/upgrade
	name = "A cybernetic enhancement"
	desc = "Delivered as asked."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/upgrade_type //"internal" for internal module, "external" for external module, used when occupying module slots

/*/obj/item/cybernetics/upgrade/apply(var/obj/item/O, mob/user)
	//Apply the upgrades, be moved into the organ
	if(istype(O, /obj/item/organ) && required_type != "external_organ")
		var/obj/item/organ/affected_organ = O
		var/datum/organ/organ = affected_organ.organ_type
		if(affected_organ && organ)
			if(upgrade_type)
				if(upgrade_type == "internal")
					if(affected_organ.internal_module_slots == 0)
						to_chat(user, "\The [affected_organ] does not have an empty internal module slot to fit the [src].")
						return
					else
						affected_organ.internal_module_slots -= 1
				if(upgrade_type == "external")
					if(affected_organ.external_module_slots == 0)
						to_chat(user, "\The [affected_organ] does not have an empty external module slot to fit the [src].")
						return
					else
						affected_organ.external_module_slots -= 1
				affected_organ.contained_modules += src
			else
				to_chat(user, "\The [src] doesn't have a defined module to take up so can't be used. Shout at coders.")
				return
	else if(istype(O, /obj/item/robot_parts && required_type != "internal_organ"))
		var/obj/item/robot_parts/affected_organ = O
		//Oh god, limbs aren't put into datums, SOMETHING TO DO
		/*var/datum/organ/organ = affected_organ.organ_type
		if(upgrade_type)
			if(upgrade_type == "internal")
				if(affected_organ.internal_module_slots == 0)
					to_chat(user, "\The [affected_organ] does not have an empty internal module slot to fit the [src].")
					return
				else
					affected_organ.internal_module_slots -= 1
			if(upgrade_type == "external")
				if(affected_organ.external_module_slots == 0)
					to_chat(user, "\The [affected_organ] does not have an empty external module slot to fit the [src].")
					return
				else
					affected_organ.external_module_slots -= 1
			affected_organ.contained_modules += src
		else
			to_chat(user, "\The [src] doesn't have a defined module to take up so can't be used. Shout at coders.")
			return*/
	else
		to_chat(user, "We don't know how, but something went seriously wrong. [O] is apparently not an organ.")
		return*/

obj/item/cybernetics/upgrade/apply(var/obj/item/organ/affected_organ, var/datum/organ, mob/user)
	if(!(affected_organ.organ_type))
		return
	if(upgrade_type)
		if(upgrade_type == "internal")
			if(affected_organ.internal_module_slots == 0)
				to_chat(user, "\The [affected_organ] does not have an empty internal module slot to fit the [src].")
				return
			else
				affected_organ.internal_module_slots -= 1
		if(upgrade_type == "external")
			if(affected_organ.external_module_slots == 0)
				to_chat(user, "\The [affected_organ] does not have an empty external module slot to fit the [src].")
				return
			else
				affected_organ.external_module_slots -= 1
		affected_organ.contained_modules += src
	else
		to_chat(user, "\The [src] doesn't have a defined module to take up so can't be used. Shout at coders.")
		return

/obj/item/cybernetics/upgrade/proc/unmount(var/obj/item/O)
	//Undo the upgrades, drop to the floor


/obj/item/cybernetics/upgrade/emp_resist/

/obj/item/cybernetics/upgrade/emp_resist/external
	name = "electro retardation plating"
	desc = "Developed by SHB-AR co. Takes the edge off of any EMP damage a cybernetic organ may take."
	upgrade_type = "External"

/obj/item/cybernetics/upgrade/emp_resist/internal
	name = "redundant threading"
	desc = "A similar technology to how pAIs can maintain information integrity during an EMP, this helps keep electrical functions grounded."
	upgrade_type = "Internal"

/obj/item/cybernetics/upgrade/emp_resist/apply(var/obj/item/organ/affected_organ, var/datum/organ/organ, mob/user)
	..()
	organ.emp_resist -= 0.25