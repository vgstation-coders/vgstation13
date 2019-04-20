/obj/item/weapon/circuitboard/blank
	name = "unprinted circuitboard"
	desc = "A blank circuitboard ready for design."
	icon = 'icons/obj/module.dmi'
	icon_state = "blank_mod"
	board_type = OTHER
	var/datum/circuits/local_fuses = null
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
	var/soldering = 0 //Busy check

/obj/item/weapon/circuitboard/blank/New()
	..()
	local_fuses = new(src)

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
			var/obj/item/stack/sheet/glass/glass/new_item = new()
			new_item.forceMove(src.loc) //This is because new() doesn't call forceMove, so we're forcemoving the new sheet to make it stack with other sheets on the ground.
			returnToPool(src)
			return
	else
		return ..()

/obj/item/weapon/circuitboard/blank/solder_improve(var/mob/user)
	local_fuses.Interact(user)