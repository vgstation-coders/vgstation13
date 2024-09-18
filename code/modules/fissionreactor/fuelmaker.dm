/*
in this file:
the machine which makes fuel rods have things in them.
*/

//because radon is a gas, we need to interface with gasses. yeah, this kind of sucks, but what are you gonna do? (inb4 make better code lol)
/obj/machinery/atmospherics/unary/fissionfuelmaker
	name="isotopic separational combiner" //just about the most technobable you could get.
	var/datum/reagents/held_elements=new /datum/reagents
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 200
	anchored=1
	density=1
	active_power_usage = 1000
	icon='icons/obj/fissionreactor/fuelmaker.dmi'
	icon_state="fuelmaker"
	var/hatchopen=FALSE
	var/obj/item/weapon/fuelrod/heldrod = null


/obj/machinery/atmospherics/unary/fissionfuelmaker/attackby(var/obj/item/I,var/mob/user)
	if(istype(I,/obj/item/weapon/fuelrod))
		if(heldrod)
			to_chat(user,"There's already a fuel rod inserted into \the [src].")
		else
			if(!user.drop_item(I))
				return
			to_chat(user,"You insert the fuel rod into \the [src].")
			I.loc=null
			heldrod=I
			playsound(src,'sound/items/crowbar.ogg',50)
			update_icon()
		return
	if(iscrowbar(I) && heldrod)
		user.visible_message("<span class='notice'>[user] starts prying the fuel rod out of \the [src].</span>", "<span class='notice'>You start prying the fuel rod out of \the [src].</span>")
		playsound(src,'sound/items/crowbar.ogg',50)
		if(do_after(user, src,20))
			heldrod.forceMove(loc)
			heldrod=null
			playsound(src,'sound/machines/door_unbolt.ogg',50)
		update_icon()
		return
		
	if(I.is_screwdriver(user))
		I.playtoolsound(src, 100)
		user.visible_message("<span class='notice'>[user] [hatchopen ? "closes" : "opens"] the maintenance hatch of the [src].</span>", "<span class='notice'>You [hatchopen ? "close" : "open"] the maintenance hatch of the [src].</span>")	
		hatchopen=!hatchopen
	if(iscrowbar(I))
		I.playtoolsound(src, 100)
		user.visible_message("<span class='warning'>[user] starts prying the electronics out of \the [src].</span>", "<span class='notice'>You start prying the electronics out of \the [src].</span>")
		if(do_after(user, src, 30 ))
			user.visible_message("<span class='warning'>[user] pries the electronics out of \the [src]</span>","<span class='notice'>You pry the electronics out of \the [src].</span>")
			qdel(src)
			var/obj/machinery/constructable_frame/machine_frame/newframe= new /obj/machinery/constructable_frame/machine_frame
			newframe.loc=src.loc
			newframe.build_state=3
			newframe.circuit=/obj/item/weapon/circuitboard/fission_fuelmaker
			newframe.components+=/obj/item/weapon/stock_parts/console_screen
			newframe.components+=/obj/item/weapon/stock_parts/manipulator
			newframe.components+=/obj/item/weapon/stock_parts/matter_bin
			newframe.components+=/obj/item/weapon/stock_parts/matter_bin
			newframe.components+=/obj/item/weapon/stock_parts/scanning_module
			newframe.components+=/obj/item/weapon/stock_parts/scanning_module

	//..()


/obj/machinery/atmospherics/unary/fissionfuelmaker/attack_hand(mob/user)
	if(..())
		return
		

/obj/machinery/atmospherics/unary/fissionfuelmaker/update_icon()
	..()
	if(!powered())
		icon_state="fuelmaker_off[heldrod?"_insert":""]"
	else if(stat & BROKEN)
		icon_state="fuelmaker_broken[heldrod?"_insert":""]"
	else
		icon_state="fuelmaker[heldrod?"_insert":""]"
	
	
	
	
	
	
/obj/machinery/atmospherics/unary/fissionfuelmaker/examine()
	..()
	to_chat(usr,"The maintenance hatch is [hatchopen ? "open" : "closed"]. It's affixed by some screws.")
	if(hatchopen)
		to_chat(usr,"It looks like you could pry out the electronics.")
	if(heldrod)
		to_chat(usr,"There is a fuel rod inserted into it.")
	else
		to_chat(usr,"The fuel rod receptacle is empty.")
		
		
		
		
/obj/item/weapon/circuitboard/fission_fuelmaker
	name = "Circuit board (isotopic separational combiner)"
	desc = "A circuit board for combining various isotopes together, as well as separating them."
	build_path = /obj/machinery/atmospherics/unary/fissionfuelmaker
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=4"
	var/safety_disabled=FALSE
	req_components = list(
		/obj/item/weapon/stock_parts/scanning_module = 2,
		/obj/item/weapon/stock_parts/matter_bin = 2,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/console_screen=1,
	)
	
	
