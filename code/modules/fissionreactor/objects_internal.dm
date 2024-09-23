/*
IN THIS FILE:
objects that make up the interior (inside) of the reactor.
included:
	control rods
	fuel rods (machine)
*/

/obj/machinery/fissionreactor
	anchored=1
	density=1
	var/datum/fission_reactor_holder/associated_reactor=null
	name="fission reactor part"
	
/obj/machinery/fissionreactor/New() //update surrounding so that they are colored
	..()
	for(var/obj/machinery/fissionreactor/part in range(src,1) )
		part.update_icon()
		
/obj/machinery/fissionreactor/Destroy()
	for(var/obj/machinery/fissionreactor/part in range(src,1) )
		loc=null
		part.update_icon()
	if(associated_reactor)
		associated_reactor.handledestruction(src)
	..()

/obj/machinery/fissionreactor/fissionreactor_controlrod
	name="fission reactor control rod assembly"
	desc="Monitors a nuclear reactor and can slow or halt the fission process if needed."
	icon='icons/obj/fissionreactor/controlrod.dmi'
	icon_state="controlrod"
	
	var/image/overlay_N 
	var/image/overlay_S 
	var/image/overlay_E   //"see vending.dm and dmi for some examples" said dilt
	var/image/overlay_W   //oh i did, and this looks like a horrible mess.
	var/image/overlay_NE  //totally not my fault :clueless:
	var/image/overlay_SE  //i'm going to keep this code because it's going to make people really mad :)
	var/image/overlay_NW  //the alternative is to re-compute the images when determining appearance (worse performance)
	var/image/overlay_SW  //or store them in a list (more memory usage (like 4 bytes))
	
/obj/machinery/fissionreactor/fissionreactor_controlrod/examine()
	..()
	to_chat(usr,"The lights indicate that there are [overlays.len] adjacent fuel rod assemblies")
	switch(icon_state)
		if("controlrod_0") 
			to_chat(usr,"The rod is hardly inserted.") //haha that's what she said
		if("controlrod_1")
			to_chat(usr,"The rod is partially inserted.")
		if("controlrod_2")
			to_chat(usr,"The rod is just under halfway inserted.")
		if("controlrod_3")
			to_chat(usr,"The rod is just over halfway inserted.")
		if("controlrod_4")
			to_chat(usr,"The rod is mostly inserted.")
		if("controlrod_5")
			to_chat(usr,"The rod is nearly fully inserted.") 
	to_chat(usr,"The structure is held together firmly, it'll have to be cut in order to part it.")

/obj/machinery/fissionreactor/fissionreactor_controlrod/New()
	overlay_N = image(icon, src,"cr_overlay_N")
	overlay_S = image(icon, src,"cr_overlay_S")
	overlay_E = image(icon, src,"cr_overlay_E")
	overlay_W = image(icon, src,"cr_overlay_W")
	overlay_NE = image(icon, src,"cr_overlay_NE")
	overlay_SE = image(icon, src,"cr_overlay_SE")
	overlay_NW = image(icon, src,"cr_overlay_NW")
	overlay_SW = image(icon, src,"cr_overlay_SW")
	..()

/obj/machinery/fissionreactor/fissionreactor_controlrod/attackby(var/obj/item/O,var/mob/user)	
	if(iswelder(O))
		if(associated_reactor && associated_reactor.considered_on())
			if(user.a_intent==I_HELP)
				to_chat(usr,"<span class='danger'>this seems like a really bad idea.</span>")
				return
		user.visible_message("<span class='notice'>[user] starts welding \the [src]'s external plating off its frame.</span>", "<span class='notice'>You start welding \the [src]'s external plating off its frame.</span>")
		var/obj/item/tool/weldingtool/WT = O
		if(WT.do_weld(user,src,60,0))
			var/obj/machinery/constructable_frame/machine_frame/reinforced/newframe= new /obj/machinery/constructable_frame/machine_frame/reinforced(loc)
			newframe.forceMove(loc)
			newframe.set_build_state(3)
			newframe.circuit= new /obj/item/weapon/circuitboard/fission_control_rod
			newframe.components=list()
			newframe.components+= new /obj/item/stack/rods(null,2)
			newframe.components+=new /obj/item/weapon/stock_parts/manipulator
			newframe.components+=new /obj/item/weapon/stock_parts/matter_bin
			qdel(src)
	
/obj/machinery/fissionreactor/fissionreactor_controlrod/update_icon()
	icon_state="controlrod"
	if(associated_reactor)
		var/statetouse=floor(associated_reactor.control_rod_insertion*5+0.5)
		icon_state="controlrod_[statetouse]"
	overlays=null
	if(  locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, NORTH) )
		overlays+=overlay_N
	if( locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, SOUTH) )
		overlays+=overlay_S
	if( locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, EAST) )
		overlays+=overlay_E
	if( locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, WEST) )
		overlays+=overlay_W
	if( locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, NORTHEAST) )
		overlays+=overlay_NE
	if( locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, SOUTHEAST) )
		overlays+=overlay_SE
	if( locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, NORTHWEST) )
		overlays+=overlay_NW
	if( locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, SOUTHWEST) )
		overlays+=overlay_SW
		
		
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod
	icon='icons/obj/fissionreactor/fuelrod.dmi'
	desc="Monitors and stores a fuel rod for nuclear reactions."
	icon_state="fuelrod"
	name="fission reactor fuel rod assembly"
	var/adjacencybonus=1.0
	var/hatchopen=FALSE
	
	var/image/overlay_N
	var/image/overlay_S
	var/image/overlay_E
	var/image/overlay_W
	


/obj/machinery/fissionreactor/fissionreactor_fuelrod/New()
	overlay_N = image(icon, src,"fuelrod_overlay_N")
	overlay_S = image(icon, src,"fuelrod_overlay_S")
	overlay_E = image(icon, src,"fuelrod_overlay_E") 
	overlay_W = image(icon, src,"fuelrod_overlay_W") 
	..()

/obj/machinery/fissionreactor/fissionreactor_fuelrod/examine()
	..()
	to_chat(usr,"The lights indicate that there are [overlays.len] adjacent fuel rod assemblies")
	if(icon_state=="fuelrod_active")
		to_chat(usr,"The center emits a blue glow.")
	to_chat(usr,"The structure is held together firmly, it'll have to be cut in order to part it.")
	to_chat(usr,"There is a maitinance hatch at the top, it is [hatchopen?"open":"screwed shut"].")
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod/update_icon()
	icon_state="fuelrod"
	if(associated_reactor && associated_reactor.considered_on())
		icon_state="fuelrod_active"
	overlays=null
	var/obj/machinery/fissionreactor/fissionreactor_fuelrod/CFR= locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, NORTH)
	if( CFR?.adjacencybonus>0 )
		overlays+=overlay_N
	CFR= locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, SOUTH)
	if( CFR?.adjacencybonus>0 )
		overlays+=overlay_S
	CFR= locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, EAST)
	if( CFR?.adjacencybonus>0 )
		overlays+=overlay_E
	CFR= locate(/obj/machinery/fissionreactor/fissionreactor_fuelrod) in get_step(src, WEST)
	if( CFR?.adjacencybonus>0 )
		overlays+=overlay_W


/obj/machinery/fissionreactor/fissionreactor_fuelrod/proc/get_reactivity()
	var/currentbonus=0.0
	var/list/lofrds=associated_reactor.fuel_rods 
	for (var/obj/machinery/fissionreactor/fissionreactor_fuelrod/fuel_rod in lofrds) //probably not the most efficent way... but it works well enough
		if (fuel_rod.loc.y==src.loc.y)
			if (fuel_rod.loc.x==src.loc.x+1 || fuel_rod.loc.x==src.loc.x-1)
				currentbonus+=fuel_rod.adjacencybonus
		if (fuel_rod.loc.x==src.loc.x)
			if (fuel_rod.loc.y==src.loc.y+1 || fuel_rod.loc.y==src.loc.y-1)
				currentbonus+=fuel_rod.adjacencybonus
	return 1.0+currentbonus

/obj/machinery/fissionreactor/fissionreactor_fuelrod/proc/get_iscontrolled()
	var/list/lofrds=associated_reactor.control_rods
	for (var/obj/machinery/fissionreactor/fissionreactor_controlrod/control_rod in  lofrds)
		if ((control_rod.loc.x-src.loc.x)**2<=1 &&  (control_rod.loc.y-src.loc.y)**2<=1  ) //ensure it's within 1 tile
			return TRUE
	return FALSE
	
	
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod/attackby(var/obj/item/O,var/mob/user)	
	if(iswelder(O))
		if(associated_reactor && associated_reactor.considered_on())
			if(user.a_intent==I_HELP)
				to_chat(usr,"<span class='danger'>this seems like a really bad idea.</span>")
				return
		user.visible_message("<span class='notice'>[user] starts welding \the [src]'s external plating off its frame.</span>", "<span class='notice'>You start welding \the [src]'s external plating off its frame.</span>")
		var/obj/item/tool/weldingtool/WT = O
		if(WT.do_weld(user,src,60,0))
			var/obj/machinery/constructable_frame/machine_frame/reinforced/newframe= new /obj/machinery/constructable_frame/machine_frame/reinforced(loc)
			newframe.forceMove(loc)
			newframe.set_build_state(3)
			newframe.circuit= new /obj/item/weapon/circuitboard/fission_fuel_rod
			newframe.components=list()
			newframe.components+= new /obj/item/stack/rods(null,2)
			newframe.components+=new /obj/item/weapon/stock_parts/scanning_module
			newframe.components+=new /obj/item/weapon/stock_parts/matter_bin
			qdel(src)
	if(O.is_screwdriver(user))
		O.playtoolsound(src, 100)
		user.visible_message("<span class='notice'>[user] [hatchopen ? "closes" : "opens"] the maintenance hatch of the [src].</span>", "<span class='notice'>You [hatchopen ? "close" : "open"] the maintenance hatch of the [src].</span>")	
		hatchopen=!hatchopen
	if(hatchopen && istype(O, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/mmmmmetal=O
		if(mmmmmetal.amount<4)
			to_chat(usr,"you don't have enough sheets to do this!")
			return
		mmmmmetal.use(4)
		var/obj/machinery/fissionreactor/fissionreactor_fuelrod/inert/newfrd=new /obj/machinery/fissionreactor/fissionreactor_fuelrod/inert(src.loc)
		playsound(src,'sound/items/crowbar.ogg',50)
		newfrd.hatchopen=TRUE
		qdel(src)
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod/inert
	adjacencybonus=0.0
	desc="Monitors and stores a fuel rod for nuclear reactions. This unit has been modified with metal plating to remove the influence of nearby fuel rods."
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod/inert/examine()
	to_chat(usr,"The adjacency lights are covered up.")
	if(icon_state=="fuelrod_active")
		to_chat(usr,"The center emits a blue glow.")
	to_chat(usr,"The structure is held together firmly, it'll have to be cut in order to part it.")
	to_chat(usr,"There is a maitinance hatch at the top, it is [hatchopen?"open":"screwed shut"].")
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod/inert/update_icon()
	icon_state="fuelrod-inert"
	if(associated_reactor && associated_reactor.considered_on())
		icon_state="fuelrod-inert_active"
	
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod/inert/attackby(var/obj/item/O,var/mob/user)	
	if(iswelder(O))
		if(associated_reactor && associated_reactor.considered_on())
			if(user.a_intent==I_HELP)
				to_chat(usr,"<span class='danger'>this seems like a really bad idea.</span>")
				return
		user.visible_message("<span class='notice'>[user] starts welding \the [src]'s external plating off its frame.</span>", "<span class='notice'>You start welding \the [src]'s external plating off its frame.</span>")
		var/obj/item/tool/weldingtool/WT = O
		if(WT.do_weld(user,src,60,0))
			var/obj/machinery/constructable_frame/machine_frame/reinforced/newframe= new /obj/machinery/constructable_frame/machine_frame/reinforced(loc)
			newframe.forceMove(loc)
			newframe.set_build_state(3)
			newframe.circuit= new /obj/item/weapon/circuitboard/fission_fuel_rod
			newframe.components=list()
			newframe.components+= new /obj/item/stack/rods(null,2)
			newframe.components+=new /obj/item/weapon/stock_parts/scanning_module
			newframe.components+=new /obj/item/weapon/stock_parts/matter_bin
			new /obj/item/stack/sheet/metal(src.loc,4)
			qdel(src)
	if(O.is_screwdriver(user))
		O.playtoolsound(src, 100)
		user.visible_message("<span class='notice'>[user] [hatchopen ? "closes" : "opens"] the maintenance hatch of the [src].</span>", "<span class='notice'>You [hatchopen ? "close" : "open"] the maintenance hatch of the [src].</span>")	
		hatchopen=!hatchopen
	if(hatchopen && iscrowbar(O))
		new /obj/item/stack/sheet/metal(src.loc,4)
		var/obj/machinery/fissionreactor/fissionreactor_fuelrod/newfrd=new /obj/machinery/fissionreactor/fissionreactor_fuelrod(src.loc)
		playsound(src,'sound/items/crowbar.ogg',50)
		newfrd.hatchopen=TRUE
		qdel(src)	
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod/inert/get_reactivity()	
	return 1.0
	
	
	
/obj/item/weapon/circuitboard/fission_control_rod
	name = "Circuit board (Control Rod)"
	desc = "A circuit board used in control rods for safer fission reactors."
	build_path = /obj/machinery/fissionreactor/fissionreactor_controlrod
	board_type = MACHINE_REINFORCED
	origin_tech = Tc_ENGINEERING + "=4;" + Tc_PROGRAMMING + "=2;" + Tc_POWERSTORAGE + "=3"
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/stack/rods = 2,
	)

/obj/item/weapon/circuitboard/fission_fuel_rod
	name = "Circuit board (Fuel Rod)"
	desc = "A circuit board used in fuel rod assemblies for heat generation in fission reactors."
	build_path = /obj/machinery/fissionreactor/fissionreactor_fuelrod
	board_type = MACHINE_REINFORCED
	origin_tech = Tc_ENGINEERING + "=4;" + Tc_PROGRAMMING + "=2;" + Tc_POWERSTORAGE + "=3"
	req_components = list(
		/obj/item/weapon/stock_parts/scanning_module = 1,
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/stack/rods = 2,
	)

	