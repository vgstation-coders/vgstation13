/*
in this file:
the machine which makes fuel rods have things in them.
*/

//because radon is a gas, we need to interface with gasses. yeah, this kind of sucks, but what are you gonna do? (inb4 make better code lol)
/obj/machinery/atmospherics/unary/fissionfuelmaker
	name="isotopic separational combiner." //just about the most technobable you could get.
	var/datum/reagents/held_elements=new /datum/reagents
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 200
	anchored=1
	density=1
	active_power_usage = 1000
	icon='icons/obj/fissionreactor/fuelmaker.dmi'
	icon_state="fuelmaker"
	var/obj/item/weapon/fuelrod/heldrod = null


/obj/machinery/atmospherics/unary/fissionfuelmaker/attackby(var/obj/I,var/mob/user)
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
			heldrod.loc=src.loc
			heldrod=null
			playsound(src,'sound/machines/door_unbolt.ogg',50)
		update_icon()
		return
	..()


/obj/machinery/atmospherics/unary/fissionfuelmaker/attack_hand(mob/user)
	if(..())
		return
		

/obj/machinery/atmospherics/unary/fissionfuelmaker/update_icon()
	..()
	if(!powered())
		icon_state="fuelmaker_off[heldrod?"_insert":""]"
		return
	if(stat & BROKEN)
		icon_state="fuelmaker_broken[heldrod?"_insert":""]"
		return
	icon_state="fuelmaker[heldrod?"_insert":""]"
	
	
/obj/machinery/atmospherics/unary/fissionfuelmaker/examine()
	..()
	if(heldrod)
		to_chat(usr,"There is a fuel rod inserted into it.")
	else
		to_chat(usr,"The fuel rod receptacle is empty.")