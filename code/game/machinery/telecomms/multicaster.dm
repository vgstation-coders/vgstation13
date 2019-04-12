var/list/pda_multicasters = list()

/obj/machinery/pda_multicaster
	name = "\improper PDA multicaster"
	desc = "Duplicates messages and sends copies to departments."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "pda_server-on"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 750
	var/obj/item/device/pda/camo/CAMO
	var/on = TRUE

/obj/machinery/pda_multicaster/New()
	..()
	CAMO = new(src)
	pda_multicasters.Add(src)

/obj/machinery/pda_multicaster/prebuilt/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/pda_multicaster,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/manipulator
	)

	RefreshParts()

/obj/machinery/pda_multicaster/Destroy()
	pda_multicasters.Remove(src)
	if(CAMO)
		qdel(CAMO)
		CAMO = null
	..()

/obj/machinery/pda_multicaster/update_icon()
	if(stat & (BROKEN|NOPOWER|EMPED))
		icon_state = "pda_server-nopower"
	else
		icon_state = "pda_server-[on ? "on" : "off"]"

/obj/machinery/pda_multicaster/attack_hand(mob/user)
	if(user.incapacitated() && !isAdminGhost(user))
		return
	toggle_power(user)

/obj/machinery/pda_multicaster/proc/toggle_power(mob/user)
	on = !on
	visible_message("\the [user] turns \the [src] [on ? "on" : "off"].")
	update_icon()

/obj/machinery/pda_multicaster/proc/check_status()
	return !(stat&(BROKEN|NOPOWER|EMPED))&&on

/obj/machinery/pda_multicaster/proc/update_PDAs(var/turn_off)
	for(var/obj/item/device/pda/pda in contents)
		pda.toff = turn_off

/obj/machinery/pda_multicaster/proc/multicast(var/target,var/obj/item/device/pda/sender,var/mob/living/U,var/message)
	var/list/redirection_list = list(
		"security" = list(/obj/item/device/pda/warden,/obj/item/device/pda/detective,/obj/item/device/pda/security,/obj/item/device/pda/heads/hos),
		"engineering" = list(/obj/item/device/pda/engineering,/obj/item/device/pda/atmos,/obj/item/device/pda/heads/ce),
		"medical" = list(/obj/item/device/pda/medical,/obj/item/device/pda/viro,/obj/item/device/pda/chemist,/obj/item/device/pda/geneticist,/obj/item/device/pda/heads/cmo),
		"research" = list(/obj/item/device/pda/toxins,/obj/item/device/pda/roboticist,/obj/item/device/pda/mechanic,/obj/item/device/pda/heads/rd),
		"cargo" = list(/obj/item/device/pda/cargo,/obj/item/device/pda/shaftminer,/obj/item/device/pda/quartermaster),
		"service" = list(/obj/item/device/pda/botanist,/obj/item/device/pda/chef,/obj/item/device/pda/bar)
	)

	var/list/available_pdas = CAMO.available_pdas() //Let's not recalculate this every time.
	for(var/element in available_pdas)
		var/obj/item/device/pda/P = available_pdas[element]
		if(is_type_in_list(P,redirection_list[target]))
			CAMO.ownjob = "[sender.owner]"
			CAMO.reply = sender
			CAMO.create_message(U,P,message)

/obj/item/device/pda/camo
	name = "Centralized Autonomous Messaging Operator"
	owner = "CAMO"
	ownjob = "CAMO"
	detonate = 0
	hidden = 1

/obj/item/device/pda/camo/create_message(var/mob/living/U,var/obj/item/device/pda/P,var/multicast_message = null)
	..()
	last_text = 0 //CAMO can text as much as it pleases
