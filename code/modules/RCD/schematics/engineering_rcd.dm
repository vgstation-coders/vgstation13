/datum/rcd_scematic_grouping/destroy
	name="deconstruct"
	headerimage="RCD_HEADER_DESTROY.png"
	
/datum/rcd_scematic_grouping/destroy/generate_html()
	return ..()

/datum/rcd_scematic_grouping/destroy/send_assets(var/client/client)
	register_asset("RCD_HEADER_DESTROY.png", new/icon('icons/effects/condecon.dmi', "decon" ))
	send_asset(client, "RCD_HEADER_DESTROY.png")	

/datum/rcd_scematic_grouping/destroy/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	linked_rcd.settings["decon_walls"]=1
	linked_rcd.settings["decon_floors"]=1
	linked_rcd.settings["decon_airlocks"]=1
	linked_rcd.settings["decon_windows"]=1
		


/datum/rcd_scematic_grouping/destroy/switch_to()
	var/found=FALSE
	
	for(var/datum/rcd_grouped_schematic/S in src.schematics)
		if(istype(S,/datum/rcd_grouped_schematic/destroy_all))
			linked_rcd.selected_schem=S
			found=TRUE
			break
	if(!found)
		linked_rcd.selected_schem=new /datum/rcd_grouped_schematic/destroy_all(linked_rcd)

/datum/rcd_grouped_schematic/destroy_all
	name="all"
	cost=5
	
/datum/rcd_grouped_schematic/destroy_all/generate_html()
	var/dat=""
	var/list/options=linked_rcd.settings
	
	
	dat+="Deconstruction settings:<br><ul style='line-height:150%;'>"
	dat+="<li><span class='[options["decon_walls"]?"schem_selected":"schem"]'><a href='?src=\ref[linked_rcd.interface];set_arg=decon_walls;value=[ options["decon_walls"] ? "0" : "1"];value_isnum=yes;'  >Walls</a></span><br></li>"
	
	dat+="<li><span class='[options["decon_floors"]?"schem_selected":"schem"]'><a href='?src=\ref[linked_rcd.interface];set_arg=decon_floors;value=[ options["decon_floors"] ? "0" : "1"];value_isnum=yes;' >Floors</a></span><br></li>"
	
	dat+="<li><span class='[options["decon_airlocks"]?"schem_selected":"schem"]'><a href='?src=\ref[linked_rcd.interface];set_arg=decon_airlocks;value=[ options["decon_airlocks"] ? "0" : "1"];value_isnum=yes;' >Airlocks</a></span><br></li>"
	
	dat+="<li><span class='[options["decon_windows"]?"schem_selected":"schem"]'><a href='?src=\ref[linked_rcd.interface];set_arg=decon_windows;value=[ options["decon_windows"] ? "0" : "1"];value_isnum=yes;' >Windows</a></span><br></li>"
	
	dat+="</ul>"
	return dat

/datum/rcd_grouped_schematic/destroy_all/build(var/atom/A, var/mob/user)
	var/list/options=linked_rcd.settings
	
	if(istype(A, /turf/simulated/wall) && options["decon_walls"])
		var/turf/simulated/wall/T = A
		if(istype(T, /turf/simulated/wall/r_wall)  || istype(T, /turf/simulated/wall/invulnerable))
			return "it cannot deconstruct reinforced walls!"

		to_chat(user, "Deconstructing \the [T]...")
		playsound(linked_rcd, 'sound/machines/click.ogg', 50, 1)

		if(linked_rcd.delay(user, T, 4 SECONDS))
			if(linked_rcd.get_energy(user) < cost)
				return 0

			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			T.ChangeTurf(/turf/simulated/floor/plating)
			return cost

	else if(istype(A, /turf/simulated/floor) && options["decon_floors"])
		var/turf/simulated/floor/T = A
		to_chat(user, "Deconstructing \the [T]...")
		if(linked_rcd.delay(user, T, 5 SECONDS))
			if(linked_rcd.get_energy(user) < cost)
				return 0

			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			add_gamelogs(user, "deconstructed \the [T] with \the [linked_rcd]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "danger")
			T.investigation_log(I_RCD,"was deconstructed by [user]")
			T.ChangeTurf(T.get_underlying_turf())
			return cost

	else if(istype(A, /obj/machinery/door/airlock) && options["decon_airlocks"])
		var/obj/machinery/door/airlock/D = A
		to_chat(user, "Deconstructing \the [D]...")
		if(linked_rcd.delay(user, D, 5 SECONDS))
			if(linked_rcd.get_energy(user) < cost)
				return 0

			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			D.investigation_log(I_RCD,"was deconstructed by [user]")
			qdel(D)
			return cost

	else if(istype(A,/obj/structure/window) && options["decon_windows"])
		var/obj/structure/window/W = A
		if(is_type_in_list(W, list(/obj/structure/window/plasma,/obj/structure/window/reinforced/plasma,/obj/structure/window/full/plasma,/obj/structure/window/full/reinforced/plasma)) )
			return "it cannot deconstruct plasma glass!"
		to_chat(user, "Deconstructing \the [W]...")
		if(linked_rcd.delay(user, W, 5 SECONDS))
			if(linked_rcd.get_energy(user) < cost)
				return 0

			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			for(var/obj/structure/grille/G in W.loc)
				if(!istype(G,/obj/structure/grille/invulnerable)) // No more breaking out in places like lamprey
					G.investigation_log(I_RCD,"was deconstructed by [user]")
					qdel(G)
			for(var/obj/structure/window/WI in W.loc)
				if(is_type_in_list(W, list(/obj/structure/window/plasma,/obj/structure/window/reinforced/plasma,/obj/structure/window/full/plasma,/obj/structure/window/full/reinforced/plasma)) )
					continue
				if(WI != W)
					WI.investigation_log(I_RCD,"was deconstructed by [user]")
					qdel(WI)
			W.investigation_log(I_RCD,"was deconstructed by [user]")
			qdel(W)
			return cost
	return 0
	



/datum/rcd_scematic_grouping/build_wall
	name="walls"
	headerimage="RCD_HEADER_WALLS.png"
	
/datum/rcd_scematic_grouping/build_wall/generate_html()
	var/dat=""
	dat+="<table class='clickabletable'><tr><th>wall</th><th>matter cost</th><th>construction time</th><th>upgradable from</th></tr>"
	for(var/datum/rcd_grouped_schematic/schem in schematics)
		dat+=schem.generate_html()
	dat+="</table>"
	return dat
	
/datum/rcd_scematic_grouping/build_wall/switch_to()
	linked_rcd.selected_schem = schematics[1]

/datum/rcd_scematic_grouping/build_wall/send_assets(var/client/client)
	register_asset("floor_RCD.png", new/icon('icons/turf/floors.dmi', "floor" ))
	send_asset(client, "floor_RCD.png")	
	
	register_asset("wall_RCD.png", new/icon('icons/turf/walls.dmi', "metal0" ))
	send_asset(client, "wall_RCD.png")	
	
	register_asset("rwall_RCD.png", new/icon('icons/turf/walls.dmi', "rwall0" ))
	send_asset(client, "rwall_RCD.png")	
	
	register_asset("woodwall_RCD.png", new/icon('icons/turf/walls.dmi', "wood0" ))
	send_asset(client, "woodwall_RCD.png")	
	
	register_asset("girder_RCD.png", new/icon('icons/obj/structures.dmi', "girder" ))
	send_asset(client, "girder_RCD.png")		
	
	
	register_asset("RCD_HEADER_WALLS.png", new/icon('icons/turf/walls.dmi', "metal0" ))
	send_asset(client, "RCD_HEADER_WALLS.png")	
	
	
/datum/rcd_grouped_schematic/normalwall
	name="wall"
	cost=3

/datum/rcd_grouped_schematic/normalwall/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/costtouse=0
	
	if(!linked_rcd)
		return 0
	
	if(istype(T,/turf/simulated/floor))
		costtouse=cost
	else
		if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor) )
			costtouse=cost+1 //add cost to make the floor
		else
			costtouse=0
	
	if(!costtouse)
		to_chat(user, "You cannot build a wall here!")
		return 0
		
	for(var/atom/A2 in T.contents)
		if(A2.type==/obj/structure/girder )
			costtouse-=1
			break
	
	
	playsound(linked_rcd, 'sound/machines/click.ogg', 50, 1)
	if(linked_rcd.delay(user, A, 2 SECONDS))
		if(linked_rcd.get_energy(user) < costtouse)
			to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
			return 0
		for(var/atom/A2 in T.contents)
			if(A2.type==/obj/structure/girder )
				qdel(A2)
		playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
		T.ChangeTurf(/turf/simulated/wall)
		return costtouse
	
	return 0

/datum/rcd_grouped_schematic/normalwall/generate_html()
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='wall_RCD.png'></a></td><td>[a][cost+1]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='girder_RCD.png'></a></td></tr>"




/datum/rcd_grouped_schematic/rwall
	name="reinforced wall"
	cost=5

/datum/rcd_grouped_schematic/rwall/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/costtouse=0
	var/timetaken= 2 SECONDS
	if(!linked_rcd)
		return 0
	
	if(istype(T,/turf/simulated/floor))
		costtouse=cost+3 //add cost to make a regular wall
		timetaken = 4 SECONDS
	else
		if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor))
			costtouse=cost+1+3 //add cost to make the floor and the wall
			timetaken = 4 SECONDS
		else
			if(istype(T,/turf/simulated/wall))
				costtouse=cost
			else
				costtouse=0
			
	if(costtouse)
		playsound(linked_rcd, 'sound/machines/click.ogg', 50, 1)
		if(linked_rcd.delay(user, A, timetaken))
			if(linked_rcd.get_energy(user) < costtouse)
				to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
				return 0
			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			T.ChangeTurf(/turf/simulated/wall/r_wall)
			return costtouse
	else
		to_chat(user, "You cannot build a wall here!")
	
	return 0

/datum/rcd_grouped_schematic/rwall/generate_html()
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='rwall_RCD.png'></a></td><td>[a][cost+1+3]</a></td><td>[a]4</a></td><td>[a]<img src='floor_RCD.png'><img src='wall_RCD.png'></a></td></tr>"


/datum/rcd_grouped_schematic/woodwall
	name="wooden wall"
	cost=2


/datum/rcd_grouped_schematic/woodwall/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/costtouse=0
	
	if(!linked_rcd)
		return 0
	
	if(istype(T,/turf/simulated/floor))
		costtouse=cost
	else
		if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor))
			costtouse=cost+1 //add cost to make the floor
		else
			costtouse=0
	if(!costtouse)
		to_chat(user, "You cannot build a wall here!")
		return 0
		
	for(var/atom/A2 in T.contents)
		if(A2.type==/obj/structure/girder )
			costtouse-=1
			break
			
	playsound(linked_rcd, 'sound/machines/click.ogg', 50, 1)
	if(linked_rcd.delay(user, A, 2 SECONDS))
		if(linked_rcd.get_energy(user) < costtouse)
			to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
			return 0
		for(var/atom/A2 in T.contents)
			if(A2.type==/obj/structure/girder )	
				qdel(A2)
		playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
		T.ChangeTurf(/turf/simulated/wall/mineral/wood)
		return costtouse
	else
		to_chat(user, "You cannot build a wall here!")
	
	return 0

/datum/rcd_grouped_schematic/woodwall/generate_html()
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='woodwall_RCD.png'></a></td><td>[a][cost+1]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='girder_RCD.png'></a></td></tr>"


/datum/rcd_grouped_schematic/girder
	name="girder"
	cost=1
	
/datum/rcd_grouped_schematic/girder/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/truecost=0
	if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor))
		truecost=cost+1
	else if(istype(T,/turf/simulated/floor) )
		truecost=cost
	else
		to_chat(user, "You cannot build a [name] here!")
		return 0
	
	for(var/atom/A2 in T.contents)
		if(A2.type==/obj/structure/girder )
			to_chat(user, "There's already a [name] here!")
			return 0
	playsound(linked_rcd, 'sound/machines/click.ogg', 50, 1)
	if(linked_rcd.delay(user, A, 1 SECONDS))
		if(linked_rcd.get_energy(user) < truecost)
			to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
			return 0
		playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
		new /obj/structure/girder(T)
		return truecost
	return 0

/datum/rcd_grouped_schematic/girder/generate_html()
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='girder_RCD.png'></a></td><td>[a][cost+1]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'></a></td></tr>"
	

/datum/rcd_scematic_grouping/build_floors
	name="floors"
	headerimage="RCD_HEADER_FLOORS.png"
	
	
/datum/rcd_scematic_grouping/build_floors/generate_html()
	var/dat=""
	dat+="<table class='clickabletable'><tr><th>floor</th><th>matter cost</th><th>construction time</th><th>upgradable from</th></tr>"
	for(var/datum/rcd_grouped_schematic/schem in schematics)
		dat+=schem.generate_html()
	dat+="</table>"
	return dat
	
/datum/rcd_scematic_grouping/build_floors/switch_to()
	linked_rcd.selected_schem = schematics[1]	

/datum/rcd_scematic_grouping/build_floors/send_assets(var/client/client)
	register_asset("floor_RCD.png", new/icon('icons/turf/floors.dmi', "floor" ))
	send_asset(client, "floor_RCD.png")	
	
	register_asset("plating_RCD.png", new/icon('icons/turf/floors.dmi', "plating" ))
	send_asset(client, "plating_RCD.png")	

	register_asset("rfloor_RCD.png", new/icon('icons/turf/floors.dmi', "engine" ))
	send_asset(client, "rfloor_RCD.png")	
	
	register_asset("glassfloor_RCD.png", new/icon('icons/turf/overlays.dmi', "glass_floor" ))
	send_asset(client, "glassfloor_RCD.png")	
	
	register_asset("plasglassfloor_RCD.png", new/icon('icons/turf/overlays.dmi', "plasma_glass_floor" ))
	send_asset(client, "plasglassfloor_RCD.png")	
	
	register_asset("lattice_RCD.png", new/icon('icons/obj/smoothlattice.dmi', "lattice15" ))
	send_asset(client, "lattice_RCD.png")	
	
	register_asset("catwalk_RCD.png", new/icon('icons/turf/catwalks.dmi', "catwalk0" ))
	send_asset(client, "catwalk_RCD.png")	
	
	register_asset("RCD_HEADER_FLOORS.png", new/icon('icons/turf/floors.dmi', "floor" ))
	send_asset(client, "RCD_HEADER_FLOORS.png")	
	
	
/datum/rcd_grouped_schematic/floor
	name="floor"
	cost=1
	
/datum/rcd_grouped_schematic/floor/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	if(!istype(T,/turf/space) && !istype(T,/turf/unsimulated/floor))
		to_chat(user, "You can only build this floor in space!")
		return 0
	if(linked_rcd.get_energy(user) < cost)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	T.ChangeTurf(/turf/simulated/floor)
	return cost

/datum/rcd_grouped_schematic/floor/generate_html()
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='floor_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		
	
	
/datum/rcd_grouped_schematic/plating
	name="plating"
	cost=1
	
/datum/rcd_grouped_schematic/plating/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	if(!istype(T,/turf/space) && !istype(T,/turf/unsimulated/floor))
		to_chat(user, "You can only build this floor in space!")
		return 0
	if(linked_rcd.get_energy(user) < cost)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	T.ChangeTurf(/turf/simulated/floor/plating)
	return cost

/datum/rcd_grouped_schematic/plating/generate_html()
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='plating_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		


/datum/rcd_grouped_schematic/rfloor
	name="reinforced floor"
	cost=1
	
/datum/rcd_grouped_schematic/rfloor/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/cc=0
	if(T.type==/turf/simulated/floor/engine)
		to_chat(user, "The floor is already a [name]!")
		return 0
	if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor))
		cc=cost+1
	else
		if(T.type==/turf/simulated/floor || T.type==/turf/simulated/floor/plating )
			cc=cost
		
	if(!cc)
		to_chat(user, "You connot build this floor here!")
		return 0
		
	if(linked_rcd.delay(user, A, 2 SECONDS))
		if(linked_rcd.get_energy(user) < cost)
			to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
			return 0
		playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
		T.ChangeTurf(/turf/simulated/floor/engine)
		return cc
	return 0

/datum/rcd_grouped_schematic/rfloor/generate_html()
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='rfloor_RCD.png'></a></td><td>[a][cost+1]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='plating_RCD.png'></a></td></tr>"		
	

/datum/rcd_grouped_schematic/glassfloor
	name="glass floor"
	cost=1
	
/datum/rcd_grouped_schematic/glassfloor/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	if(!istype(T,/turf/space))
		to_chat(user, "You can only build this floor in space!")
		return 0
	if(linked_rcd.get_energy(user) < cost)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	T.ChangeTurf(/turf/simulated/floor/glass/airless)
	return cost

/datum/rcd_grouped_schematic/glassfloor/generate_html()
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='glassfloor_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		


/datum/rcd_grouped_schematic/plasmaglassfloor
	name="plasma glass floor"
	cost=6

/datum/rcd_grouped_schematic/plasmaglassfloor/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/cc=0
	if(istype(T,/turf/space))
		cc=cost
	else if(istype(T,/turf/simulated/floor/glass) && !istype(T,/turf/simulated/floor/glass/plasma))
		cc=cost-1
	else
		to_chat(user, "You cannot build this here!")
		return 0
	if(linked_rcd.get_energy(user) < cost)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	T.ChangeTurf(/turf/simulated/floor/glass/plasma/airless)
	return cc

/datum/rcd_grouped_schematic/plasmaglassfloor/generate_html()
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='plasglassfloor_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]<img src='glassfloor_RCD.png'></a></td></tr>"		

	
/datum/rcd_grouped_schematic/lattice
	name="lattice"
	cost=1
	
/datum/rcd_grouped_schematic/lattice/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	if(!istype(T,/turf/space) && !istype(T,/turf/unsimulated/floor))
		to_chat(user, "You can only build this in space!")
		return 0
	if(linked_rcd.get_energy(user) < cost)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	if(locate(/obj/structure/lattice) in T.contents)
		to_chat(user, "There's already a [name] here!")
		return 0
	new /obj/structure/lattice(T)	
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	return cost
	
/datum/rcd_grouped_schematic/lattice/generate_html()
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='lattice_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		

/datum/rcd_grouped_schematic/catwalk
	name="catwalk"
	cost=2
	
/datum/rcd_grouped_schematic/catwalk/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	if(!istype(T,/turf/space) && !istype(T,/turf/unsimulated/floor))
		to_chat(user, "You can only build this in space!")
		return 0
	if(linked_rcd.get_energy(user) < cost)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	if(locate(/obj/structure/catwalk) in T.contents)
		to_chat(user, "There's already a [name] here!")
		return 0
	var/refund=0
	for(var/obj/structure/lattice/L in T.contents)
		qdel(L)
		refund=1
	new /obj/structure/catwalk(T)	
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	return cost-refund
	
/datum/rcd_grouped_schematic/catwalk/generate_html()
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[linked_rcd.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='catwalk_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]<img src='lattice_RCD.png'></a></td></tr>"	
	

/datum/rcd_scematic_grouping/build_windows
	name="windows"
	headerimage="RCD_HEADER_WINDOWS.png"
	
/datum/rcd_scematic_grouping/build_windows/generate_html()
	var/dat=""
	
	var/build_n=linked_rcd.settings["window_north"]
	var/build_s=linked_rcd.settings["window_south"]
	var/build_e=linked_rcd.settings["window_east"]
	var/build_w=linked_rcd.settings["window_west"]
	var/build_c=linked_rcd.settings["window_center"]
	var/skipgrile=linked_rcd.settings["window_nogrille"]
	
	dat+="<table><tr><td> <span class='[skipgrile ? "schem" : "schem_selected"]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_nogrille;value_toggle=yes;'>place grille</a></span></td>"
	
	dat+={"<td> <table class='clickabletable' >
	<tr><td></td><td style='width:3em;height:1em;' class='[build_n ? "schem_selected" : "schem" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_north;value_toggle=yes;'/></td><td></td></tr>
	<tr><td class='[build_w ? "schem_selected" : "schem" ]' style='width:1em;height:3em;'><a href='?src=\ref[linked_rcd.interface];set_arg=window_west;value_toggle=yes;'/></td><td style='width:3em;height:3em;' class='[build_c ? "schem_selected" : "schem" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_center;value_toggle=yes;'/></td><td style='width:1em;height:3em;' class='[build_e ? "schem_selected" : "schem" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_east;value_toggle=yes;'/></td></tr>
	<tr><td></td><td style='width:3em;height:1em;' class='[build_s ? "schem_selected" : "schem" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_south;value_toggle=yes;'/></td><td></td></tr>
	</table> </td>"}

	dat+="</tr></table>"
	
	dat+="<table class='clickabletable'><tr><th>material</th><th>matter cost</th><th>construction time</th><th>upgradable from</th></tr>"
	for(var/datum/rcd_grouped_schematic/schem in schematics)
		dat+=schem.generate_html()
	dat+="</table>"
	return dat
	
/datum/rcd_scematic_grouping/build_windows/switch_to()
	linked_rcd.selected_schem = schematics[2] //use rglass by default.		


/datum/rcd_scematic_grouping/build_windows/send_assets(var/client/client)
	register_asset("floor_RCD.png", new/icon('icons/turf/floors.dmi', "floor" ))
	send_asset(client, "floor_RCD.png")	
	
	register_asset("glass_RCD.png", new/icon('icons/obj/stacks_sheets.dmi', "sheet-glass" ))
	send_asset(client, "glass_RCD.png")	
	
	register_asset("rglass_RCD.png", new/icon('icons/obj/stacks_sheets.dmi', "sheet-rglass" ))
	send_asset(client, "rglass_RCD.png")	
	
	register_asset("pglass_RCD.png", new/icon('icons/obj/stacks_sheets.dmi', "sheet-plasmaglass" ))
	send_asset(client, "pglass_RCD.png")	
	
	register_asset("rpglass_RCD.png", new/icon('icons/obj/stacks_sheets.dmi', "sheet-plasmarglass" ))
	send_asset(client, "rpglass_RCD.png")	
	
	register_asset("RCD_HEADER_WINDOWS.png", new/icon('icons/obj/window_grille_spawner.dmi', "rwindowgrille" ))
	send_asset(client, "RCD_HEADER_WINDOWS.png")	
	
	

/datum/rcd_grouped_schematic/glass
	var/obj/structure/window/windowtype=null
	var/obj/structure/window/full/fullwindowtype=null
	var/list/canupgrade_windows=null
	var/list/canupgrade_fullwindows=null
	var/upgrade_refund=0
	var/construct_delay = 2 SECONDS

/datum/rcd_grouped_schematic/glass/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	canupgrade_windows=new()
	canupgrade_fullwindows=new()
	

/datum/rcd_grouped_schematic/glass/build(var/atom/A, var/mob/user)
	
	var/build_n=linked_rcd.settings["window_north"]
	var/build_s=linked_rcd.settings["window_south"]
	var/build_e=linked_rcd.settings["window_east"]
	var/build_w=linked_rcd.settings["window_west"]
	var/build_c=linked_rcd.settings["window_center"] //store window directions.
	var/skipgrile=linked_rcd.settings["window_nogrille"]
	
	var/nowindows=!(build_n || build_s || build_e || build_w || build_c)
	if(nowindows && skipgrile)
		return 0
	
	var/cc=0
	var/refund=0
	var/turf/T=get_turf(A)
	if(!T)
		return 0
	if(istype(T,/turf/simulated/floor))
		cc=(nowindows ? 1 : cost)
	if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor))
		cc=(nowindows ? 1 : cost)+1
	
	if(!cc)
		to_chat(user, "You can't place a [name] here!")
		return 0		
	if(linked_rcd.get_energy(user) < cc)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0			
	if(!linked_rcd.delay(user, A, construct_delay))
		return 0
		
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	
	if(istype(T,/turf/space)|| istype(T,/turf/unsimulated/floor))
		T.ChangeTurf(/turf/simulated/floor)
	if( (!locate(/obj/structure/grille) in T.contents) && !skipgrile)
		new /obj/structure/grille(T)
	if(build_n)
		var/shouldbuild=TRUE
		for(var/obj/structure/window/R in T.contents)
			if(R.dir == NORTH && R.type==windowtype)
				shouldbuild=FALSE
				break
		if(shouldbuild)
			for(var/obj/structure/window/R in T.contents) // "upgrade" windows by destroying the old one. not elegant, but it works.
				if(R.dir == NORTH && (R.type in canupgrade_windows))
					qdel(R)
					refund=upgrade_refund
					break
			var/obj/structure/window/nwin=new windowtype(T)
			nwin.change_dir(NORTH)
			nwin.update_nearby_tiles()
	if(build_s)
		var/shouldbuild=TRUE
		for(var/obj/structure/window/R in T.contents)
			if(R.dir == SOUTH && R.type==windowtype)
				shouldbuild=FALSE
				break
		if(shouldbuild)
			for(var/obj/structure/window/R in T.contents)
				if(R.dir == SOUTH && (R.type in canupgrade_windows))
					qdel(R)
					refund=upgrade_refund
					break
			var/obj/structure/window/nwin=new windowtype(T)
			nwin.change_dir(SOUTH)
			nwin.update_nearby_tiles()
	if(build_e)
		var/shouldbuild=TRUE
		for(var/obj/structure/window/R in T.contents)
			if(R.dir == EAST && R.type==windowtype)
				shouldbuild=FALSE
				break
		if(shouldbuild)
			for(var/obj/structure/window/R in T.contents)
				if(R.dir == EAST && (R.type in canupgrade_windows))
					qdel(R)
					refund=upgrade_refund
					break
			var/obj/structure/window/nwin=new windowtype(T)
			nwin.change_dir(EAST)
			nwin.update_nearby_tiles()
	if(build_w)
		var/shouldbuild=TRUE
		for(var/obj/structure/window/R in T.contents)
			if(R.dir == WEST && R.type==windowtype)
				shouldbuild=FALSE
				break
		if(shouldbuild)
			for(var/obj/structure/window/R in T.contents)
				if(R.dir == WEST && (R.type in canupgrade_windows))
					qdel(R)
					refund=upgrade_refund
					break
			var/obj/structure/window/nwin=new windowtype(T)
			nwin.change_dir(WEST)
			nwin.update_nearby_tiles()
	if(build_c)
		var/shouldbuild=TRUE
		for(var/obj/structure/window/full/R in T.contents)
			if(R.type==fullwindowtype)
				shouldbuild=FALSE
				break
		if(shouldbuild)
			for(var/obj/structure/window/R in T.contents)
				if( R.type in canupgrade_fullwindows)
					qdel(R)
					refund=upgrade_refund
					break
			var/obj/structure/window/nwin=new fullwindowtype(T)
			nwin.update_nearby_tiles()	
			
	return cc-refund


/datum/rcd_grouped_schematic/glass/generate_html()
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name]'>"
	return "<tr class='[linked_rcd.selected_schem==src? "schem_selected" : "schem"]'><td>[a]<img src='glass_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'></a></td></tr>"


/datum/rcd_grouped_schematic/glass/weak
	name="window"
	cost=1
	windowtype=/obj/structure/window
	fullwindowtype=/obj/structure/window/full


/datum/rcd_grouped_schematic/glass/reinforced
	name="reinforced window"
	cost=2
	windowtype=/obj/structure/window/reinforced
	fullwindowtype=/obj/structure/window/full/reinforced
	upgrade_refund=1
	
/datum/rcd_grouped_schematic/glass/reinforced/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	canupgrade_windows+=/obj/structure/window
	canupgrade_fullwindows+=/obj/structure/window/full

/datum/rcd_grouped_schematic/glass/reinforced/generate_html()
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name]'>"
	return "<tr class='[linked_rcd.selected_schem==src? "schem_selected" : "schem"]'><td>[a]<img src='rglass_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='glass_RCD.png'></a></td></tr>"
	
/datum/rcd_grouped_schematic/glass/plasma
	name="plasma glass window"
	cost=6
	windowtype=/obj/structure/window/plasma
	fullwindowtype=/obj/structure/window/full/plasma
	upgrade_refund=1
	construct_delay= 3 SECONDS

/datum/rcd_grouped_schematic/glass/plasma/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	canupgrade_windows+=/obj/structure/window
	canupgrade_fullwindows+=/obj/structure/window/full


/datum/rcd_grouped_schematic/glass/plasma/generate_html()
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name]'>"
	return "<tr class='[linked_rcd.selected_schem==src? "schem_selected" : "schem"]'><td>[a]<img src='pglass_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='glass_RCD.png'></a></td></tr>"
	

/datum/rcd_grouped_schematic/glass/rplas
	name="reinforced plasma glass window"
	cost=7
	windowtype=/obj/structure/window/reinforced/plasma
	fullwindowtype=/obj/structure/window/full/reinforced/plasma
	upgrade_refund=2 //probably explotable with regular windows in some way, but i don't think it's going to matter
	construct_delay= 4 SECONDS

/datum/rcd_grouped_schematic/glass/rplas/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	canupgrade_windows+=/obj/structure/window/reinforced
	canupgrade_fullwindows+=/obj/structure/window/full/reinforced

/datum/rcd_grouped_schematic/glass/rplas/generate_html()
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name]'>"
	return "<tr class='[linked_rcd.selected_schem==src? "schem_selected" : "schem"]'><td>[a]<img src='rpglass_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='rglass_RCD.png'></a></td></tr>"


/datum/rcd_scematic_grouping/build_airlock
	name="airlocks"
	headerimage="RCD_HEADER_AIRLOCKS.png"
	selectiondialogue="Enter the name of the airlock"

/datum/rcd_scematic_grouping/build_airlock/New(var/obj/item/device/rcd/rcdtouse=null)	
	..(rcdtouse)
	linked_rcd.settings["airlock_access"]= new /list()
	linked_rcd.settings["airlock_dir"]=NORTH

/datum/rcd_scematic_grouping/build_airlock/switch_to()
	if(schematics.len)
		linked_rcd.selected_schem = schematics[1]

/datum/rcd_scematic_grouping/build_airlock/send_assets(var/client/client)
	register_asset("RCD_HEADER_AIRLOCKS.png", new/icon('icons/obj/doors/door.dmi', "door_closed" ))
	send_asset(client, "RCD_HEADER_AIRLOCKS.png")	


/datum/rcd_scematic_grouping/build_airlock/generate_html()
	var/dat=""
	//set name
	dat+="Set Name: <span class='schem'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_name;value_input=yes'> [linked_rcd.settings["airlock_name"] || linked_rcd.selected_schem.name ]</a></span> <span class='schem'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_name;value=[linked_rcd.selected_schem.name]'> Reset </a></span>"
	
	
	if(istype(linked_rcd.selected_schem,/datum/rcd_grouped_schematic/airlock/windoor))
		dat+={"
	<table style='text-align:center;line-height:110%;'>
	<tr><td colspan=2> <span class='schem[linked_rcd.settings["airlock_dir"]==NORTH ? "_selected" :"" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_dir;value_isnum=yes;value=[NORTH]'>NORTH</a></span> </td></tr>
	<tr><td> <span class='schem[linked_rcd.settings["airlock_dir"]==WEST ? "_selected" :"" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_dir;value_isnum=yes;value=[WEST]'>WEST</a></span> </td><td> <span class='schem[linked_rcd.settings["airlock_dir"]==EAST ? "_selected" :"" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_dir;value_isnum=yes;value=[EAST]'>EAST</a></span> </td></tr>
	<tr><td colspan=2> <span class='schem[linked_rcd.settings["airlock_dir"]==SOUTH ? "_selected" :"" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_dir;value_isnum=yes;value=[SOUTH]'>SOUTH</a></span> </td></tr>
	</table>
	"}
	
	dat+="<hr>"
	
	//access settings
	dat+="<b>Set access</b>"
	
	dat+=" <span class='schem'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_access;value_resetlist=yes'>Reset</a></span> "
	
	dat+=" <span class='schem[ (!linked_rcd.settings["airlock_hideacc"]) ? "":"_selected"]'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_hideacc;value_toggle=yes'>Hide</a></span> "
	
	
	if(!linked_rcd.settings["airlock_hideacc"])
		dat+="<br><br><b>Mode:</b> "
		dat+="<span class='schem[linked_rcd.settings["airlock_acany"] ? "":"_selected"]'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_acany;value=0;value_isnum=yes'> All</a></span> "
		dat+="<span class='schem[linked_rcd.settings["airlock_acany"] ? "_selected" :""]'><a href='?src=\ref[linked_rcd.interface];set_arg=airlock_acany;value=1;value_isnum=yes'> Any</a></span>"
	
		dat+="<table class='clickabletable'><tr>"
		for(var/i = 1; i <= 7; i++)
			dat+="<th style='width:14%'>[get_region_accesses_name(i)]</th>"
		dat+="</tr>"
	
		var/drew=TRUE
		var/row=1
		while(drew)
			drew=FALSE
			dat += "<tr>"
			for(var/i = 1; i <= 7; i++)
				var/list/fuckyou=get_region_accesses(i)
				var/A = row>fuckyou.len ? -1 : fuckyou[row]
				var/access_name = get_access_desc(A)
				if(access_name)
					var/isin=FALSE
					for(var/n in linked_rcd.settings["airlock_access"])
						if(n==A)
							isin=TRUE
							break
					dat+="<td style='height:100%;width:14%' class='schem[isin?"_selected":""]'><a style='display:block;width:100%;height:100%;' href='?src=\ref[linked_rcd.interface];set_arg=airlock_access;value=[A];value_togglelist=yes;value_isnum=yes;'>[access_name]</a></td>"
					drew=TRUE
				else
					dat+="<td/>"
			dat += "</tr>"
			row++
		dat+="</table>"
	
	dat+="<hr>"
	//select door

	for(var/datum/rcd_grouped_schematic/schem in schematics)
		dat+=schem.generate_html()
	return dat



/datum/rcd_grouped_schematic/airlock
	name="airlock"
	cost=3
	var/icon='icons/obj/doors/door.dmi'
	var/path = /obj/machinery/door/airlock 
	var/has_direction=FALSE
		
/datum/rcd_grouped_schematic/airlock/send_assets(var/client/client)
	register_asset("airlock_[name]_RCD.png", new/icon(icon, "door_closed" ))
	send_asset(client, "airlock_[name]_RCD.png")	

/datum/rcd_grouped_schematic/airlock/generate_html()
	return "<span style='display:inline-block;padding:0px;' class='schem[linked_rcd.selected_schem==src ? "_selected" : "" ]'><a style='display:block;background:none;border:none;' href='?src=\ref[linked_rcd.interface];set_schematic=[name]'><img src='airlock_[name]_RCD.png' style='padding:4px;border:none;background:none;'></a></span>"

/datum/rcd_grouped_schematic/airlock/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/cc=0
	if(!T)
		return 0
	if(istype(T, /turf/space) || istype(T,/turf/unsimulated/floor))
		cc=cost+1
	else if (istype(T, /turf/simulated/floor) || istype(T,/turf/unsimulated/floor))
		cc=cost
	else
		to_chat(user, "You can't place a [name] here!")
		return 0
	for(var/atom/at in T.contents)
		if (istype(at, /obj/machinery/door/airlock))
			to_chat(user, "There's already an airlock here!")
			return 0
	
	if(linked_rcd.get_energy(user) < cc)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0			
	if(!linked_rcd.delay(user, A, 5 SECONDS))
		return 0
	if(linked_rcd.get_energy(user) < cc)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	
	if(istype(T, /turf/space))
		T.ChangeTurf(/turf/simulated/floor)
	
	var/obj/machinery/door/airlock/newairlock = new path(T)
		
	newairlock.name=linked_rcd.settings["airlock_name"] || name
		
	if(linked_rcd.settings["airlock_acany"])
		var/list/aa=linked_rcd.settings["airlock_access"]
		newairlock.req_one_access = aa?.Copy()
	else
		var/list/aa=linked_rcd.settings["airlock_access"]
		newairlock.req_access = aa?.Copy()
	newairlock.autoclose=1
	return cost
	
	
/datum/rcd_grouped_schematic/airlock/standard

/datum/rcd_grouped_schematic/airlock/glass
	name="Glass Airlock"
	icon='icons/obj/doors/Doorglass.dmi'
	path=/obj/machinery/door/airlock/glass

/datum/rcd_grouped_schematic/airlock/centcom
	name="Centcomm Airlock"
	icon='icons/obj/doors/Doorele.dmi'
	path=/obj/machinery/door/airlock/centcom

/datum/rcd_grouped_schematic/airlock/freezer
	name="Freezer Airlock"
	icon='icons/obj/doors/Doorfreezer.dmi'
	path=/obj/machinery/door/airlock/freezer	
	
/datum/rcd_grouped_schematic/airlock/hatch
	name="Airtight Hatch"
	icon='icons/obj/doors/Doorhatchele.dmi'
	path=/obj/machinery/door/airlock/hatch	

/datum/rcd_grouped_schematic/airlock/maintenance_hatch
	name="Maintenance Hatch"
	icon='icons/obj/doors/Doorhatchmaint2.dmi'
	path=/obj/machinery/door/airlock/maintenance_hatch	

/datum/rcd_grouped_schematic/airlock/glass_command
	name="Glass Command Airlock"
	icon='icons/obj/doors/Doorcomglass.dmi'
	path=/obj/machinery/door/airlock/glass_command	
	
/datum/rcd_grouped_schematic/airlock/glass_engineering
	name="Glass Engineering Airlock"
	icon='icons/obj/doors/Doorengglass.dmi'
	path=/obj/machinery/door/airlock/glass_engineering		
	
/datum/rcd_grouped_schematic/airlock/glass_security
	name="Glass Security Airlock"
	icon='icons/obj/doors/Doorsecglass.dmi'
	path=/obj/machinery/door/airlock/glass_security	
	
/datum/rcd_grouped_schematic/airlock/glass_medical
	name="Glass Medical Airlock"
	icon='icons/obj/doors/doormedglass.dmi'
	path=/obj/machinery/door/airlock/glass_medical	
	
/datum/rcd_grouped_schematic/airlock/mining
	name="Mining Airlock"
	icon='icons/obj/doors/Doormining.dmi'
	path=/obj/machinery/door/airlock/mining		
	
/datum/rcd_grouped_schematic/airlock/atmos
	name="Atmospherics Airlock"
	icon='icons/obj/doors/Dooratmo.dmi'
	path=/obj/machinery/door/airlock/atmos		
	
/datum/rcd_grouped_schematic/airlock/research
	name="Research Airlock"
	icon='icons/obj/doors/doorresearch.dmi'
	path=/obj/machinery/door/airlock/research	

/datum/rcd_grouped_schematic/airlock/glass_research
	name="Glass Research Airlock"
	icon='icons/obj/doors/doorresearchglass.dmi'
	path=/obj/machinery/door/airlock/glass_research	

/datum/rcd_grouped_schematic/airlock/glass_mining
	name="Glass Mining Airlock"
	icon='icons/obj/doors/Doorminingglass.dmi'
	path=/obj/machinery/door/airlock/glass_mining	

/datum/rcd_grouped_schematic/airlock/glass_atmos
	name="Glass Atmospherics Airlock"
	icon='icons/obj/doors/Dooratmoglass.dmi'
	path=/obj/machinery/door/airlock/glass_atmos	
	
/datum/rcd_grouped_schematic/airlock/science
	name="Science Airlock"
	icon='icons/obj/doors/Doorsci.dmi'
	path=/obj/machinery/door/airlock/science	
	
/datum/rcd_grouped_schematic/airlock/glass_science
	name="Glass Science Airlock"
	icon='icons/obj/doors/Doorsciglass.dmi'
	path=/obj/machinery/door/airlock/glass_science	
	
/datum/rcd_grouped_schematic/airlock/highsecurity
	name="High Tech Security Airlock"
	icon='icons/obj/doors/hightechsecurity.dmi'
	path=/obj/machinery/door/airlock/highsecurity
	cost=5	
	
/datum/rcd_grouped_schematic/airlock/vault
	name="Vault"
	icon='icons/obj/doors/hightechsecurity.dmi'
	path=/obj/machinery/door/airlock/vault
	cost=5		

/datum/rcd_grouped_schematic/airlock/command
	name="Command Airlock"
	icon='icons/obj/doors/Doorcom.dmi'
	path=/obj/machinery/door/airlock/command	

/datum/rcd_grouped_schematic/airlock/security
	name="Security Airlock"
	icon='icons/obj/doors/Doorsec.dmi'
	path=/obj/machinery/door/airlock/security	

/datum/rcd_grouped_schematic/airlock/engineering
	name="Engineering Airlock"
	icon='icons/obj/doors/Dooreng.dmi'
	path=/obj/machinery/door/airlock/engineering	

/datum/rcd_grouped_schematic/airlock/medical
	name="Medical Airlock"
	icon='icons/obj/doors/doormed.dmi'
	path=/obj/machinery/door/airlock/medical	

/datum/rcd_grouped_schematic/airlock/maintenance
	name="Maintenance Airlock"
	icon='icons/obj/doors/Doormaint.dmi'
	path=/obj/machinery/door/airlock/maintenance	

/datum/rcd_grouped_schematic/airlock/external
	name="External Airlock"
	icon='icons/obj/doors/Doorext.dmi'
	path=/obj/machinery/door/airlock/external	
		
/datum/rcd_grouped_schematic/airlock/windoor
	name="Windoor"
	icon='icons/obj/doors/windoor.dmi'
	path=/obj/machinery/door/window
	
/datum/rcd_grouped_schematic/airlock/windoor/send_assets(var/client/client)
	has_direction=TRUE
	register_asset("airlock_[name]_RCD.png", new/icon(icon, "left" ))
	send_asset(client, "airlock_[name]_RCD.png")	

/datum/rcd_grouped_schematic/airlock/windoor/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/cc=0
	var/dirtouse=linked_rcd.settings["airlock_dir"] || NORTH
	
	if(!T)
		return 0
	if(istype(T, /turf/space))
		cc=cost+1
	else if (istype(T, /turf/simulated/floor) || istype(T,/turf/unsimulated/floor))
		cc=cost
	else
		to_chat(user, "You can't place a [name] here!")
		return 0
	for(var/atom/at in T.contents)
		if (istype(at, /obj/machinery/door/window) && at.dir==dirtouse)
			to_chat(user, "There's already a windoor here!")
			return 0
	
	if(linked_rcd.get_energy(user) < cc)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0			
	if(!linked_rcd.delay(user, A, 5 SECONDS))
		return 0
	if(linked_rcd.get_energy(user) < cc)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	
	if(istype(T, /turf/space))
		T.ChangeTurf(/turf/simulated/floor)
	
	var/obj/machinery/door/airlock/newwindoor = new path(T)
		
	newwindoor.name=linked_rcd.settings["airlock_name"] || name
	newwindoor.change_dir(dirtouse)
		
	if(linked_rcd.settings["airlock_acany"])
		var/list/aa=linked_rcd.settings["airlock_access"]
		newwindoor.req_one_access = aa?.Copy()
	else
		var/list/aa=linked_rcd.settings["airlock_access"]
		newwindoor.req_access = aa?.Copy()
	newwindoor.autoclose=1
	return cost	






//prefab groups, so you don't have to change all 3 RCDs to add a shematic

/datum/rcd_scematic_grouping/build_wall/engi_std

/datum/rcd_scematic_grouping/build_wall/engi_std/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/normalwall(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/woodwall(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/girder(rcdtouse)


/datum/rcd_scematic_grouping/build_wall/engi_std/CE //for the ARCD

/datum/rcd_scematic_grouping/build_wall/engi_std/CE/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	schematics+=new /datum/rcd_grouped_schematic/rwall(rcdtouse)



/datum/rcd_scematic_grouping/build_floors/engi_std

/datum/rcd_scematic_grouping/build_floors/engi_std/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/floor(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/plating(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/glassfloor(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/lattice(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/catwalk(rcdtouse)

/datum/rcd_scematic_grouping/build_floors/engi_std/CE

/datum/rcd_scematic_grouping/build_floors/engi_std/CE/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	schematics += new/datum/rcd_grouped_schematic/rfloor(rcdtouse)
	


/datum/rcd_scematic_grouping/build_windows/engi_std

/datum/rcd_scematic_grouping/build_windows/engi_std/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/glass/weak(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/glass/reinforced(rcdtouse)


/datum/rcd_scematic_grouping/build_airlock/engi_std

/datum/rcd_scematic_grouping/build_airlock/engi_std/New(var/obj/item/device/rcd/rcdtouse=null)
	..(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/standard(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/glass(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/freezer(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/centcom(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/command(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/glass_command(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/hatch(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/maintenance_hatch(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/maintenance(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/engineering(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/glass_engineering(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/security(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/glass_security(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/medical(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/glass_medical(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/research(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/glass_research(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/mining(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/glass_mining(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/atmos(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/glass_atmos(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/science(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/glass_science(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/external(rcdtouse)
	schematics+= new /datum/rcd_grouped_schematic/airlock/windoor(rcdtouse)

/datum/rcd_scematic_grouping/build_airlock/engi_std/CE

/datum/rcd_scematic_grouping/build_airlock/engi_std/CE/New(var/obj/item/device/rcd/rcdtouse=null)	
	..(rcdtouse)
	schematics+= new/datum/rcd_grouped_schematic/airlock/vault(rcdtouse)
	schematics+= new/datum/rcd_grouped_schematic/airlock/highsecurity(rcdtouse)

