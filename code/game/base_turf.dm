//Returns the lowest turf available on a given Z-level, defaults to space.
var/global/list/base_turf_by_z = list()

proc/get_base_turf(var/z)
	if(!base_turf_by_z["[z]"])
		base_turf_by_z["[z]"] = /turf/space
	return base_turf_by_z["[z]"]

/client/verb/set_base_turf()
	set category = "Debug"
	set name = "Set Base Turf"
	set desc = "Set the base turf for a z-level. Defaults to space, does not replace existing tiles."

	if(check_rights(R_DEBUG, 0))

		if(!holder)
			return

		var/choice = input("Which Z-level do you wish to set the base turf for?") as num|null
		if(!choice)
			return

		var/new_base_path = input("Please select a turf path (cancel to reset to /turf/space).") as null|anything in typesof(/turf)
		if(!new_base_path)
			new_base_path = /turf/space
		base_turf_by_z["[choice]"] = new_base_path
		feedback_add_details("admin_verb","BTC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		message_admins("[key_name_admin(usr)] has set the base turf for Z-level [choice] to [get_base_turf(choice)]. This will affect all destroyed turfs from now on.")
		log_admin("[key_name(usr)] has set the base turf for Z-level [choice] to [get_base_turf(choice)]. This will affect all destroyed turfs from now on.")