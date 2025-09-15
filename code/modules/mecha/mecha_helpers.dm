////////////////////////
////// Helpers /////////
////////////////////////

/obj/mecha/proc/removeVerb(verb_path)
	verbs -= verb_path

/obj/mecha/proc/addVerb(verb_path)
	verbs += verb_path

/obj/mecha/proc/add_airtank()
	if(!enclosed)
		return
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	mech_parts.Add(internal_tank)
	return internal_tank

/obj/mecha/proc/add_cell()
	for(var/obj/item/weapon/cell/cell in contents)
		cell_type = cell
		qdel(cell)
	cell = new cell_type(src)
	mech_parts.Add(cell)

/obj/mecha/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.adjust_multi(
		GAS_OXYGEN, O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature),
		GAS_NITROGEN, N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature))
	mech_parts.Add(cabin_air)
	return cabin_air

/obj/mecha/proc/add_fist()
	fist = new
	fist.name = "[src]'s fist"
	fist.force = src.force

/obj/mecha/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state
	radio.subspace_transmission = 1
	mech_parts.Add(radio)

/obj/mecha/proc/add_tracking_beacon()
	tracking = new(src)
	mech_parts.Add(tracking)
	return tracking

/obj/mecha/proc/add_iterators()
	pr_int_temp_processor = new /datum/global_iterator/mecha_preserve_temp(list(src))
	pr_inertial_movement = new /datum/global_iterator/mecha_intertial_movement(null,0)
	pr_give_air = new /datum/global_iterator/mecha_tank_give_air(list(src))
	pr_internal_damage = new /datum/global_iterator/mecha_internal_damage(list(src),0)

/obj/mecha/proc/check_for_support()
	if(locate(/obj/structure/grille, orange(1, src)) || locate(/obj/structure/lattice, orange(1, src)) || locate(/turf/simulated, orange(1, src)) || locate(/turf/unsimulated, orange(1, src)))
		return 1
	else
		return 0

////////////////////////////////////////
////// Open-topped Visual Handlers /////
////////////////////////////////////////
//Creates a visholder atom that can be transformed so you can visually display a strange sized mob without touching the mob directly!
//Override/make a child to set specific sizes/pixel offsets
/obj/mecha/proc/create_visholder()
	if(visholder)
		return FALSE
	//Gotta make them in this order due to vis_contents underlaying shenanigans
	//Back most layer, holds the seat behind the pilot
	seat = new(src)
	seat.name = "mecha.dm vis_contents backseat-holder"
	seat.vis_flags = (VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_UNDERLAY | VIS_INHERIT_ID)
	seat.icon = 'icons/mecha/mecha.dmi'
	seat.icon_state = "[initial_icon]_underlay"
	vis_contents += seat
	//Next layer up, holds The Little Man
	visholder = new(src)
	visholder.name = "mecha.dm visual open-topped pilot-holder"
	visholder.vis_flags = (VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_UNDERLAY | VIS_INHERIT_ID)
	visholder.appearance_flags |= PIXEL_SCALE
	vis_contents += visholder
	return TRUE

//Handles open topped visual man offsets based on direction faced. Override with pix offsets for visholder
/obj/mecha/proc/handle_vis_offset()
	return

//Handles visholder interactions when a human mob enters an open-topped mech
/obj/mecha/proc/handle_vis_enter()
	occupant_vis_cache = occupant.vis_flags
	occupant.vis_flags = (VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_UNDERLAY | VIS_INHERIT_ID)
	occupant.appearance_flags |= PIXEL_SCALE
	visholder.vis_contents += occupant

//Handles visholder interactions when a human mob exits an open-topped mech
/obj/mecha/proc/handle_vis_exit()
	if(occupant)
		occupant.vis_flags = occupant_vis_cache
		visholder.vis_contents -= occupant
