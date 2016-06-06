//Cybernetics upgrades

/obj/item/cybernetics/upgrade
	name = "A cybernetic enhancement."
	desc = "Delivered as asked."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/upgrade_type //Internal for internal functions, external for external functions, used when occupying module slots
	var/required_type //If the upgrade is only for a specific organ, if not then keep it empty

/obj/item/cybernetics/upgrade/afterattack(var/obj/item/O)
	..()

	if(!istype(O, /obj/item/robot_parts) && !istype(O, /obj/item/organ))
		to_chat(usr, "A cybernetic upgrade won't work on this.")
		return
	if(istype(O, /obj/item/organ))
		var/obj/item/organ/I = O
		if(!(I.robotic == 2))
			to_chat(usr, "\the [O] isn't robotic.")
			return