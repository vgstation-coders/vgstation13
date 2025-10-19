/obj/mecha/range_action(atom/target as obj|mob|turf)
	return

/obj/mecha/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && (O in src.cargo))
			src.occupant_message("<span class='notice'>You unload [O].</span>")
			O.forceMove(get_turf(src))
			src.cargo -= O
			if (ore_box == O)
				ore_box = locate(/obj/structure/ore_box) in cargo //i'll fix this later
			src.log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]")
	return

/obj/mecha/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(src.cargo.len)
		for(var/obj/O in src.cargo)
			output += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/empty_bad_contents()
	..(cargo) //mom's spaghetti 2.0

/obj/mecha/Destroy()
	for(var/mob/M in src)
		if(M==src.occupant)
			continue
		M.forceMove(get_turf(src))
		M.loc.Entered(M, src)
		step_rand(M)
	for(var/atom/movable/A in src.cargo)
		A.forceMove(get_turf(src))
		var/turf/T = get_turf(A)
		if(T)
			T.Entered(A, src)
		step_rand(A)
	..()
	return
