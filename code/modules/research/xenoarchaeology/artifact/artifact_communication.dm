/obj/machinery/communication
	name = "Ancient Device"
	desc = "There seems to be six slots capable of holding small crystals placed along its side"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "communication"
	stat = NOPOWER //Niggers you will wrench this shit down or else
	density = 1
	use_power = 1
	active_power_usage = 4000
	idle_power_usage = 1000
	var/list/obj/item/commstone/allstones = list()
	var/remaining = 6
	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/communication/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/commstone))
		if((W in allstones) && remaining < 6)
			if(user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You place one of the strange stones back onto the ancient device, it snaps into place.</span>")
				remaining++
	..()

/obj/machinery/communication/attack_ghost(mob/user as mob)
	return //Dont want even adminghosts touching this

/obj/machinery/communication/attack_ai(mob/user as mob)
	return //Robots HA

/obj/machinery/communication/attack_hand(mob/user as mob)
	if(..())
		return 1
	if(contents.len)
		var/obj/item/commstone/stone = contents[1]
		user.put_in_hands(stone)
		to_chat(user, "<span class='notice'>You delicately remove one of the strange stones from the ancient device.</span>")
		remaining--
		return
	if(remaining)
		var/obj/item/commstone/stone = new(remaining)
		user.put_in_hands(stone)
		stone.commdevice = src
		allstones += stone
		remaining--
		to_chat(user, "<span class='notice'>You delicately remove one of the strange stones from the ancient device.</span>")
		return

/obj/machinery/communication/examine(mob/user as mob)
	..()
	if(remaining)
		to_chat(user, "<span class='info'>The device's slots still apears to hold [remaining] stone\s.")
	else
		to_chat(user, "<span class='info'>The device no longer has any stones in any of its holders.")
	if(stat & NOPOWER)
		to_chat(user, "<span class='info'>It seems the machine is currently dark, perhaps it would activate when anchored into a powered area.")

/obj/machinery/communication/Destroy()
	for(var/stone in contents)
		qdel(stone)
	..()

/obj/machinery/communication/proc/get_active_stones()
	if((stat & NOPOWER) && !anchored)
		return list()
	var/list/obj/item/commstone/thestones = allstones.Copy()
	for(var/obj/item/commstone/check in thestones)
		if(check.loc == src)
			thestones -= check
	return thestones

/obj/item/commstone
	name = "Strange Stone"
	desc = "You can hear small voices coming from within, they whisper through to you a soft but persistent message - 'use .y'"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "crystal1"
	w_class = W_CLASS_SMALL
	var/obj/machinery/communication/commdevice = null
	var/number = null

/obj/item/commstone/New(remaining)
	..()
	number = remaining
	update_icon()

/obj/item/commstone/examine(mob/user as mob)
	..()
	if(!commdevice || (commdevice.stat & NOPOWER))
		to_chat(user, "<span class='info'>It seems to have lost its luster, perhaps the device it is connected to isn't functional.")


/obj/item/commstone/update_icon()
	icon_state = "crystal[number]"