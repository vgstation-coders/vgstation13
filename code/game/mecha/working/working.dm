/obj/mecha/working
	internal_damage_threshold = 60
	var/list/cargo = new
	var/cargo_capacity = 15
	var/obj/structure/ore_box/ore_box //to save on locate()
	var/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/hydraulic_clamp

/*
/obj/mecha/working/melee_action(atom/target as obj|mob|turf)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = pick(oview(1,src))
	if(selected_tool)
		selected_tool.action(target)
	return
*/

/obj/mecha/working/range_action(atom/target as obj|mob|turf)
	return

/*
/obj/mecha/working/get_stats_part()
	var/output = ..()
	output += "<b>[src.name] Tools:</b><div style=\"margin-left: 15px;\">"
	if(equipment.len)
		for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
			output += "[selected==MT?"<b>":"<a href='?src=\ref[src];select_equip=\ref[MT]'>"][MT.get_equip_info()][selected==MT?"</b>":"</a>"]<br>"
	else
		output += "None"
	output += "</div>"
	return output
*/

/obj/mecha/working/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && O in src.cargo)
			src.occupant_message("<span class='notice'>You unload [O].</span>")
			O.forceMove(get_turf(src))
			src.cargo -= O
			if (ore_box == O)
				ore_box = locate(/obj/structure/ore_box) in cargo //i'll fix this later
			src.log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]")
	return



/obj/mecha/working/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(src.cargo.len)
		for(var/obj/O in src.cargo)
			output += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/empty_bad_contents()
	for(var/obj/O in src)
		if(O in cargo) //mom's spaghetti
			continue
		if(!is_type_in_list(O,mech_parts))
			O.forceMove(src.loc)
	return

/obj/mecha/working/Destroy()
	for(var/mob/M in src)
		if(M==src.occupant)
			continue
		M.forceMove(get_turf(src))
		M.loc.Entered(M)
		step_rand(M)
	for(var/atom/movable/A in src.cargo)
		A.forceMove(get_turf(src))
		var/turf/T = get_turf(A)
		if(T)
			T.Entered(A)
		step_rand(A)
	..()
	return
