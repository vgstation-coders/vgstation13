/*
# What is this?
Datums that handle specific sub-sections of the preferences menu.
# How do I use it?
Define a /datum/preferences_subsection.
Specify the subsections your datum handles in `registered_paths`.
Handle your links by overriding /process_link() - return TRUE if you handled the link successfully.
*/

/datum/preferences/proc/init_subsections()
	subsections = list()
	for(var/subsection_path in subtypesof(/datum/preferences_subsection))
		var/datum/preferences_subsection/new_subsection = new subsection_path(src)
		for(var/registered_path in new_subsection.registered_paths)
			subsections[registered_path] = new_subsection

/datum/preferences_subsection
	var/datum/preferences/prefs
	var/list/registered_paths

/datum/preferences_subsection/New(var/datum/preferences/prefs)
	..()
	src.prefs = prefs

/datum/preferences_subsection/Destroy()
	prefs = null
	..()

/datum/preferences_subsection/proc/process_link(var/mob/user, var/list/href_list)
	return FALSE
