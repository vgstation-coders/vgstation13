/datum/faction/syndicate/nuke_op
	name = "Syndicate nuclear operatives"
	ID = SYNDIOPS
	required_pref = ROLE_OPERATIVE
	initial_role = NUKE_OP
	late_role = NUKE_OP
	desc = "The culmination of succesful NT traitors, who have managed to steal a nuclear device.\
	Load up, grab the nuke, don't forget where you've parked, find the nuclear auth disk, and give them hell."
	logo_state = "nuke-logo"
	hud_icons = list("nuke-logo")

/datum/faction/syndicate/nuke_op/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<br><h2>Nuclear disk</h2>"
	if(!nukedisk)
		dat += "There's no nuke disk. Panic?<br>"
	else if(isnull(nukedisk.loc))
		dat += "The nuke disk is in nullspace. Panic."
	else
		dat += "[nukedisk.name]"
		var/atom/disk_loc = nukedisk.loc
		while(!istype(disk_loc, /turf))
			if(istype(disk_loc, /mob))
				var/mob/M = disk_loc
				dat += "carried by <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a> "
			if(istype(disk_loc, /obj))
				var/obj/O = disk_loc
				dat += "in \a [O.name] "
			disk_loc = disk_loc.loc
		dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z]) [formatJumpTo(nukedisk, "Jump")]"
	return dat