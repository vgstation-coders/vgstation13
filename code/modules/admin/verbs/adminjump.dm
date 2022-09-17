/client/proc/Jump()
	set name = "Jump to Area"
	set desc = "Area to jump to"
	set category = "Admin"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(config.allow_admin_jump)
		var/sortedAreas = areas.Copy()
		sortTim(sortedAreas, /proc/cmp_name_asc)
		var/area/A = input(usr, "Choose the jump area", "Area") as null|anything in sortedAreas
		if(!A)
			return

		var/list/turfs = list()
		for(var/turf/T in A)
			if(T.density)
				continue
			turfs.Add(T)

		var/turf/T = pick_n_take(turfs)
		if(!T)
			to_chat(src, "Nowhere to jump to!")
			return
		usr.unlock_from()
		usr.teleport_to(T)

		log_admin("[key_name(usr)] jumped to [A]")
		message_admins("[key_name_admin(usr)] jumped to [A]", 1)
		feedback_add_details("admin_verb","JA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")

/client/proc/jumptoturf(var/turf/T in world)
	set name = "Jump to Turf"
	set category = "Admin"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(config.allow_admin_jump)
		log_admin("[key_name(usr)] jumped to [T.x],[T.y],[T.z] in [T.loc]")
		message_admins("[key_name_admin(usr)] jumped to [T.x],[T.y],[T.z] in [T.loc]", 1)
		usr.unlock_from()
		usr.teleport_to(T)
		feedback_add_details("admin_verb","JT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")
	return

/client/proc/jumptomob(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Jump to Mob"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(config.allow_admin_jump)
		log_admin("[key_name(usr)] jumped to [key_name(M)]")
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]", 1)
		if(src.mob)
			var/mob/A = src.mob
			var/turf/T = get_turf(M)
			if(T && isturf(T))
				feedback_add_details("admin_verb","JM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
				A.unlock_from()
				A.teleport_to(T)
			else
				to_chat(A, "This mob is not located in the game world.")
	else
		alert("Admin jumping disabled")

/client/proc/jumptocoord(tx as num, ty as num, tz as num)
	set category = "Admin"
	set name = "Jump to Coordinate"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if (config.allow_admin_jump)
		if(src.mob)
			src.mob.unlock_from()
			var/mob/A = src.mob
			A.x = tx
			A.y = ty
			A.z = tz
			feedback_add_details("admin_verb","JC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		message_admins("[key_name_admin(usr)] jumped to coordinates [tx], [ty], [tz]")

	else
		alert("Admin jumping disabled")

/client/proc/jumptokey()
	set category = "Admin"
	set name = "Jump to Key"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(config.allow_admin_jump)
		var/list/keys = list()
		for(var/mob/M in player_list)
			if(M.ckey)
				keys["[M.ckey]"] = M //used to be M.client but GHOSTED PEOPLE WERE PUTTING NULL ENTRIES IN THE FUCKING LIST
		var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortList(keys)
		if(!selection)
			to_chat(src, "No keys found.")
			return
		var/mob/M = keys[selection]
		log_admin("[key_name(usr)] jumped to [key_name(M)]")
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]", 1)
		usr.unlock_from()
		usr.teleport_to(M)
		feedback_add_details("admin_verb","JK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")

/client/proc/jumptomapelement()
	set category = "Admin"
	set name = "Jump to Map Element"

	if(!check_rights())
		return

	if(config.allow_admin_jump)
		var/list/vaults = list()

		for(var/datum/map_element/V in map_elements)
			var/name = "[V.type_abbreviation] [V.name ? V.name : V.file_path] @ [V.location ? "[V.location.x],[V.location.y],[V.location.z][V.rotation ? " (rotated by [V.rotation] degrees)" : ""]" : "UNKNOWN"]"

			vaults[name] = V

		var/selection = input("Select a map element to teleport to. AM = Away Mission, V = Vault.", "Admin Jumping", null, null) as null|anything in sortList(vaults)
		if(!selection)
			return

		var/datum/map_element/V = vaults[selection]
		if(!V.location)
			to_chat(src, "[V.file_path || V.name] doesn't have a location! Report this")
			return

		usr.unlock_from()
		usr.teleport_to(V.location)
		feedback_add_details("admin_verb","JV")
	else
		alert("Admin jumping disabled")

/client/proc/Getmob(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Get Mob"
	set desc = "Mob to teleport"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(config.allow_admin_jump)
		log_admin("[key_name(usr)] teleported [key_name(M)]")
		message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)]", 1)
		M.unlock_from()
		M.teleport_to(usr)
		feedback_add_details("admin_verb","GM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")

/client/proc/Getkey()
	set category = "Admin"
	set name = "Get Key"
	set desc = "Key to teleport"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(config.allow_admin_jump)
		var/list/keys = list()
		for(var/mob/M in player_list)
			if(M)
				keys += M //used to be M.key but it was putting FUCKING NULLS IN THE LIST
		var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
		if(!selection)
			return
		var/mob/M = selection

		if(!M)
			return
		log_admin("[key_name(usr)] teleported [key_name(M)]")
		message_admins("[key_name_admin(usr)] teleported [key_name(M)]", 1)
		if(M)
			M.unlock_from()
			M.teleport_to(usr)
			feedback_add_details("admin_verb","GK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")

/client/proc/sendmob(var/mob/M in sortmobs())
	set category = "Admin"
	set name = "Send Mob"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/sortedAreas = areas.Copy()
	sortTim(sortedAreas, /proc/cmp_name_asc)
	var/area/A = input(usr, "Pick an area.", "Pick an area") in sortedAreas
	if(A)
		if(config.allow_admin_jump)
			M.unlock_from()
			M.teleport_to(pick(get_area_turfs(A)))
			feedback_add_details("admin_verb","SMOB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

			log_admin("[key_name(usr)] teleported [key_name(M)] to [A]")
			message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)] to [A]", 1)
		else
			alert("Admin jumping disabled")
