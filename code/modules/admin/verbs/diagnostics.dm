/client/proc/air_report()
	set category = "Debug"
	set name = "Show Air Report"

	/*(!master_controller || !SSair)
		alert(usr,"Master_controller or SSair not found.","Air Report")
		return 0

	var/active_groups = 0
	var/inactive_groups = 0
	var/active_tiles = 0
	for(var/datum/air_group/group in SSair.air_groups)
		if(group.group_processing)
			active_groups++
		else
			inactive_groups++
			active_tiles += group.members.len

	var/hotspots = 0
	for(var/obj/effect/hotspot/hotspot in world)
		hotspots++

	var/output = {"<B>AIR SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
<B># of Groups:</B> [SSair.air_groups.len]<BR>
---- <I>Active:</I> [active_groups]<BR>
---- <I>Inactive:</I> [inactive_groups]<BR>
-------- <I>Tiles:</I> [active_tiles]<BR>
<B># of Active Singletons:</B> [SSair.active_singletons.len]<BR>
<BR>
<B>Special Processing Data</B><BR>
<B>Hotspot Processing:</B> [hotspots]<BR>
<B>High Temperature Processing:</B> [SSair.active_super_conductivity.len]<BR>
<B>High Pressure Processing:</B> [SSair.high_pressure_delta.len] (not yet implemented)<BR>
<BR>
<B>Geometry Processing Data</B><BR>
<B>Group Rebuild:</B> [SSair.groups_to_rebuild.len]<BR>
<B>Tile Update:</B> [SSair.tiles_to_update.len]<BR>
"}

	usr << browse(output,"window=airreport")
	feedback_add_details("admin_verb","SAR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
*/
/client/proc/air_status(turf/target as turf)
	set category = "Debug"
	set name = "Display Air Status"

	/*(!isturf(target))
		return

	var/datum/gas_mixture/GM = target.return_air()
	var/burning = 0
	if(istype(target, /turf/simulated))
		var/turf/simulated/T = target
		if(T.active_hotspot)
			burning = 1

	to_chat(usr, "<span class='notice'>@[target.x],[target.y] ([GM.group_multiplier]): O:[GM.oxygen] T:[GM.toxins] N:[GM.nitrogen] C:[GM.carbon_dioxide] w [GM.temperature] Kelvin, [GM.return_pressure()] kPa [(burning)?("<span class='warning'>BURNING</span>"):(null)]</span>")
	for(var/datum/gas/trace_gas in GM.trace_gases)
		to_chat(usr, "[trace_gas.type]: [trace_gas.moles]")
	feedback_add_details("admin_verb","DAST") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	*/

/client/proc/_fix_delayers(var/dtype)
	var/largest_delay = 0
	var/mob/most_delayed_mob = null
	var/delay=0
	for(var/mob/M in mob_list)
		if(!M.client)
			continue
		// Get stats
		var/datum/delay_controller/delayer = M.vars["[dtype]_delayer"]
		if(delayer.blocked())
			delay = delayer.next_allowed - world.time
			if(delay > largest_delay)
				most_delayed_mob=M
				largest_delay=delay

		// Unfreeze
		delayer.next_allowed = 0
	message_admins("[key_name_admin(most_delayed_mob)] had the largest [dtype] delay with [largest_delay] frames / [largest_delay/10] seconds!", 1)

/client/proc/fix_next_move()
	set category = "Debug"
	set name = "Unfreeze Everyone"
	if(!usr.client.holder)
		return

	_fix_delayers("move")
	_fix_delayers("click")
	_fix_delayers("attack")
	_fix_delayers("special")

	message_admins("world.time = [world.time]", 1)
	feedback_add_details("admin_verb","UFE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

#undef GATHER_DELAYER_LOCKUPS

/client/proc/radio_report()
	set category = "Debug"
	set name = "Radio report"

	var/filters = list(
		"1" = "RADIO_TO_AIRALARM",
		"2" = "RADIO_FROM_AIRALARM",
		"3" = "RADIO_CHAT",
		"4" = "RADIO_ATMOSIA",
		"5" = "RADIO_NAVBEACONS",
		"6" = "RADIO_AIRLOCK",
		"7" = "RADIO_SECBOT",
		"8" = "RADIO_MULEBOT",
		"_default" = "NO_FILTER"
		)
	var/output = "<b>Radio Report</b><hr>"
	for (var/fq in radio_controller.frequencies)
		output += "<b>Freq: [fq]</b><br>"
		var/list/datum/radio_frequency/fqs = radio_controller.frequencies[fq]
		if (!fqs)
			output += "&nbsp;&nbsp;<b>ERROR</b><br>"
			continue
		for (var/filter in fqs.devices)
			var/list/f = fqs.devices[filter]
			if (!f)
				output += "&nbsp;&nbsp;[filters[filter]]: ERROR<br>"
				continue
			output += "&nbsp;&nbsp;[filters[filter]]: [f.len]<br>"
			for (var/device in f)
				if (isobj(device))
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([device:x],[device:y],[device:z] in area [get_area(device:loc)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	usr << browse(output,"window=radioreport")
	feedback_add_details("admin_verb","RR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Debug"

	if(!check_rights(R_SERVER))
		return

	message_admins("[usr] manually reloaded admins")
	load_admins()
	feedback_add_details("admin_verb","RLDA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//todo:
/client/proc/jump_to_dead_group()
	set name = "Jump to dead group"
	set category = "Debug"

		/*
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(!SSair)
		to_chat(usr, "Cannot find air_system")
		return
	var/datum/air_group/dead_groups = list()
	for(var/datum/air_group/group in SSair.air_groups)
		if (!group.group_processing)
			dead_groups += group
	var/datum/air_group/dest_group = pick(dead_groups)
	usr.forceMove(pick(dest_group.members))
	feedback_add_details("admin_verb","JDAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
	*/

/client/proc/kill_airgroup()
	set name = "Kill Local Airgroup"
	set desc = "Use this to allow manual manupliation of atmospherics."
	set category = "Debug"

	/*
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(!SSair)
		to_chat(usr, "Cannot find air_system")
		return

	var/turf/T = get_turf(usr)
	if(istype(T, /turf/simulated))
		var/datum/air_group/AG = T:parent
		AG.next_check = 30
		AG.group_processing = 0
	else
		to_chat(usr, "Local airgroup is unsimulated!")
	feedback_add_details("admin_verb","KLAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	*/

/client/proc/print_jobban_old()
	set name = "Print Jobban Log"
	set desc = "This spams all the active jobban entries for the current round to standard output."
	set category = "Debug"

	to_chat(usr, "<b>Jobbans active in this round.</b>")
	for(var/t in jobban_keylist)
		to_chat(usr, "[t]")

/client/proc/print_jobban_old_filter()
	set name = "Search Jobban Log"
	set desc = "This searches all the active jobban entries for the current round and outputs the results to standard output."
	set category = "Debug"

	var/filter = input("Contains what?","Filter") as text|null
	if(!filter)
		return

	to_chat(usr, "<b>Jobbans active in this round.</b>")
	for(var/t in jobban_keylist)
		if(findtext(t, filter))
			to_chat(usr, "[t]")

// For /vg/ Wiki docs
/client/proc/dump_chemreactions()
	set category = "Debug"
	set name = "Dump Chemical Reactions"

	var/paths = typesof(/datum/chemical_reaction) - /datum/chemical_reaction

	var/str = {"
{| class="wikitable"
|-
! Name
! Reactants
! Result"}
	for(var/path in paths)
		var/datum/chemical_reaction/R = new path()
		str += {"
|-
! [R.name]"}
		if(R.required_reagents)
			str += "\n|<ul>"
			for(var/r_id in R.required_reagents)
				str += "<li>{{reagent|[R.required_reagents[r_id]]|[r_id]}}</li>"
			for(var/r_id in R.required_catalysts)
				str += "<li>{{reagent|[R.required_catalysts[r_id]]|[r_id]}}</li>"
			str += "</ul>"
		else
			str += "\n|''None!''"
		if(R.result)
			str += "\n|{{reagent|[R.result_amount]|[R.result]}}"
		else
			str += "\n|''(Check [R.type]/on_reaction()!)''"
	text2file(str+"\n|}","chemistry-recipes.wiki")

/*
// For ~~/vg/ Wiki docs~~ another day.
/client/proc/dump_chems()
	set category = "Debug"
	set name = "Dump Chemicals"

	var/paths = typesof(/datum/reagent) - /datum/reagent
	var/num = 0
	var/subtypes = 0
	var/normal_shc = 0
	var/normal_density = 0
	var/str = {"
{| class="wikitable"
|-
! Name
! Reactants
! Result"}
	for(var/path in paths)
		var/datum/reagent/R = new path()
		num++
		str += {"
|-
! [num]: [R.name]"}
		if(R.id)
			str += "\n|<ul>"
			str += "\n|<li>{{ID = [R.id]}}</li>"
			if(R.parent_type != /datum/reagent)
				subtypes++
				str += "\n|<li>{{Child of [R.parent_type]}}</li>"
			if(R.density == 1 && !istype(R, /datum/reagent/water))
				normal_density++
			if(R.specheatcap == 1)
				normal_shc++
			str += "\n|<li>{{Density = [R.density]}}</li>"
			str += "\n|<li>{{Specific Heat Capacity = [R.specheatcap]}}</li>"
			if(R.overdose_am)
				str += "\n|<li>{{Overdose amount = [R.overdose_am]}}</li>"
			if(R.overdose_tick)
				str += "\n|<li>{{Time in system to overdose = [R.overdose_tick/10] seconds}}</li>"
			str += "</ul>"
	if(subtypes)
		str += "\n|Number of subtypes = [subtypes]"
	if(normal_density)
		str += "\n|Number of non-unique densities = [normal_density]"
	if(normal_shc)
		str += "\n|Number of non-unique SHCs = [normal_shc]"
	text2file(str+"\n|}","chemistry-reagents.wiki")
*/