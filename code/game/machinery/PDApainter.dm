/*
!!STOLED!! from TGstation.
Feel free to do whatever with this if you think it lacks.

-Heredth
*/

/obj/machinery/pdapainter
	name = "\improper PDA painter"
	desc = "A PDA painting machine. To use, simply insert a PDA and choose the desired preset paint scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = 1
	anchored = 1
	var/obj/item/device/pda/storedpda = null
	var/list/colorlist = list()
	opened = 0
	
	var/last_print = 0 //No spamming PDA printing 


/obj/machinery/pdapainter/update_icon()
	overlays.Cut()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(storedpda)
		overlays += "[initial(icon_state)]-closed"

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/pdapainter/New()
	..()
	var/blocked = list(/obj/item/device/pda/ai/pai, /obj/item/device/pda/ai, /obj/item/device/pda/heads,
						/obj/item/device/pda/clear, /obj/item/device/pda/syndicate)

	for(var/P in typesof(/obj/item/device/pda)-blocked)
		var/obj/item/device/pda/D = new P

		//D.name = "PDA Style [colorlist.len+1]" //Gotta set the name, otherwise it all comes up as "PDA"
		D.name = D.icon_state //PDAs don't have unique names, but using the sprite names works.

		src.colorlist += D


/obj/machinery/pdapainter/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/device/pda))
		if(storedpda)
			user << "There is already a PDA inside."
			return
		else
			var/obj/item/device/pda/P = usr.get_active_hand()
			if(istype(P))
				user.drop_item()
				storedpda = P
				P.loc = src
				P.add_fingerprint(usr)
				update_icon()
	
	if(istype(O, /obj/item/weapon/screwdriver))
		opened = !opened
		user << "You [opened ? "open" : "close"] the maintenance hatch of [src]."
		updateUsrDialog()
		return
	
	if(istype(O, /obj/item/weapon/crowbar))
		if(opened)
			dismantle()
			return

/obj/machinery/pdapainter/attack_hand(mob/user as mob)
	..()

	src.add_fingerprint(user)

	if(storedpda)
		var/obj/item/device/pda/P
		P = input(user, "Select your color.", "PDA Painting") as null|anything in colorlist
		if(!P)
			return
		if(!in_range(src, user))
			return

		storedpda.icon_state = P.icon_state
		storedpda.desc = P.desc

	else
		user << "<span class='notice'>The [src] is empty.</span>"


/obj/machinery/pdapainter/verb/ejectpda()
	set name = "Eject PDA"
	set category = "Object"
	set src in oview(1)

	if(storedpda)
		storedpda.loc = get_turf(src.loc)
		storedpda = null
		update_icon()
	else
		usr << "<span class='notice'>The [src] is empty.</span>"
		
/obj/machinery/pdapainter/verb/ejectpda()
	set name = "Print PDA"
	set category = "Object"
	set src in oview(1)

	if(spam_flag + 300 < world.timeofday)
		usr << "<span class='notice'>The [src] begins to hum lightly.</span>"
		sleep(200)
		usr << "<span class='notice'>The [src] rattles and shakes, spitting out a new PDA.</span>"
		var/turf/T = get_turf(src.loc)
		var/obj/item/device/pda/A = new /obj/item/device/pda(T)
	else
		usr << "The [src] is not ready to print again."
	


/obj/machinery/pdapainter/power_change()
	..()
	update_icon()
