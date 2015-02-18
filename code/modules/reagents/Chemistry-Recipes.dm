///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/results = null // List of resulting reagents. id => amount

	var/requires_heating = 0
	var/min_temperature = 0    // Minimum temperature at which the reaction starts.
	var/max_temperature = 1000 // Maximum temperature

	var/mix_message = "The solution begins to bubble."

	// Documentation stuff
	var/document = TRUE             // Set FALSE to hide this reaction from recipe dumps.
	var/reaction_description = null // Description of what comes out of the reaction (used only for on_reaction reagents)

// /vg/: Send admin alerts with standardized code.
/datum/chemical_reaction/proc/send_admin_alert(var/datum/reagents/holder, var/reaction_name=src.name)
	var/message_prefix = "\A [reaction_name] reaction has occured"
	var/message="[message_prefix]"
	var/atom/A = holder.my_atom
	if(A)
		var/turf/T = get_turf(A)
		var/area/my_area = get_area(T)

		message += " in [formatJumpTo(T)]. (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>)"
		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [M.real_name] ([M.key]) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"
			log_game("[message_prefix] in [my_area.name] ([T.x],[T.y],[T.z]) - Carried by [M.real_name] ([M.key])")
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"
			log_game("[message_prefix] in [my_area.name] ([T.x],[T.y],[T.z]) - last fingerprint  [(A.fingerprintslast ? A.fingerprintslast : "N/A")]")
	else
		message += "."
	message_admins(message, 0, 1)

/datum/chemical_reaction/proc/on_reaction(var/datum/reagents/holder, var/created_volume)
	return

	//I recommend you set the result amount to the total volume of all components.
