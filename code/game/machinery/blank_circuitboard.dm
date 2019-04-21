/obj/item/weapon/circuitboard/blank
	name = "unprinted circuitboard"
	desc = "A blank circuitboard ready for design."
	icon = 'icons/obj/module.dmi'
	icon_state = "blank_mod"
	board_type = OTHER
	var/datum/circuits/local_fuses = null
	var/circuits_tier = /datum/circuits
	var/soldering = 0 //Busy check

/obj/item/weapon/circuitboard/blank/New()
	..()
	if(circuits_tier)
		local_fuses = new circuits_tier(src)

/obj/item/weapon/circuitboard/blank/attackby(obj/item/O as obj, mob/user as mob)
	if(ismultitool(O))
		var/boardType = local_fuses.assigned_boards["[local_fuses.localbit]"] //Localbit is an int, but this is an associative list organized by strings
		if(boardType)
			if(ispath(boardType))
				to_chat(user, "<span class='notice'>The multitool pings softly as it finishes configuring the board.</span>")
				new boardType(get_turf(src))
				qdel(src)
				return
			else
				to_chat(user, "<span class='warning'>A fatal error with the board type occurred. Report this message.</span>")
		else
			to_chat(user, "<span class='warning'>The multitool flashes red briefly.</span>")
	else if(iswelder(O))
		var/obj/item/weapon/weldingtool/WT = O
		if(WT.remove_fuel(1,user))
			drop_stack(/obj/item/stack/sheet/glass, get_turf(src), 1)
			returnToPool(src)
			return
	else
		return ..()

/obj/item/weapon/circuitboard/blank/solder_improve(var/mob/user)
	local_fuses.Interact(user)

/obj/item/weapon/circuitboard/blank/base
	name = "blank construction circuitboard"
	desc = "A blank circuitboard ready for design. It has some preset functions that are toggleable via soldering outlined sections."
	var/list/allowed_boards = list(
	"autolathe"=/obj/item/weapon/circuitboard/autolathe,
	"intercom"=/obj/item/weapon/intercom_electronics,
	"air alarm"=/obj/item/weapon/circuitboard/air_alarm,
	"fire alarm"=/obj/item/weapon/circuitboard/fire_alarm,
	"airlock"=/obj/item/weapon/circuitboard/airlock,
	"APC"=/obj/item/weapon/circuitboard/power_control,
	"vendomat"=/obj/item/weapon/circuitboard/vendomat,
	"microwave"=/obj/item/weapon/circuitboard/microwave,
	"station map"=/obj/item/weapon/circuitboard/station_map,
	"cell charger"=/obj/item/weapon/circuitboard/cell_charger,
	"recharger"=/obj/item/weapon/circuitboard/recharger,
	"fishtank filter"=/obj/item/weapon/circuitboard/fishtank,
	"large fishtank filter"=/obj/item/weapon/circuitboard/fishwall,
	"electric oven"=/obj/item/weapon/circuitboard/oven,)
	circuits_tier = null

/obj/item/weapon/circuitboard/blank/base/solder_improve(var/mob/user)
	if(!soldering)
		soldering = 1
		var/t = input(user, "Which board should be designed?") as null|anything in allowed_boards
		if(!t)
			soldering = 0
			return
		playsound(loc, 'sound/items/Welder.ogg', 50, 1)
		if(do_after(user, src,40))
			var/boardType = allowed_boards[t]
			var/obj/item/I = new boardType(get_turf(user))
			to_chat(user, "<span class='notice'>You set \the [src]'s preset. it will now act as \an [I].</span>")
			qdel(src)
			user.put_in_hands(I)
		soldering = 0