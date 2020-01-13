#define TRADE_SHUTTLE_TRANSIT_DELAY 240
#define TRADE_SHUTTLE_COOLDOWN 200

var/global/datum/shuttle/trade/trade_shuttle = new(starting_area = /area/shuttle/trade/start)

/datum/shuttle/trade
	name = "trade shuttle"
	can_link_to_computer = LINK_FREE
	req_access = list(access_trade)
	cooldown = TRADE_SHUTTLE_COOLDOWN
	transit_delay = TRADE_SHUTTLE_TRANSIT_DELAY - 30 //Once somebody sends the shuttle, it waits for 3 seconds before leaving. Transit delay is reduced to compensate for that
	pre_flight_delay = 30
	cooldown = 200
	stable = 0 //Don't stun everyone and don't throw anything when moving
	can_rotate = 0 //Sleepers, body scanners and multi-tile airlocks aren't rotated properly

/datum/shuttle/trade/proc/notify_port_toggled(var/reason)
	for(var/obj/machinery/computer/shuttle_control/trade/T in control_consoles)
		T.notify_port_toggled(reason)

/datum/shuttle/trade/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/trade/start)
	add_dock(/obj/docking_port/destination/trade/station)

	set_transit_dock(/obj/docking_port/destination/trade/transit)

/obj/machinery/computer/shuttle_control/trade
	icon_state = "syndishuttle"

	light_color = LIGHT_COLOR_RED
	machine_flags = EMAGGABLE //No screwtoggle because this computer can't be built

/obj/machinery/computer/shuttle_control/trade/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(trade_shuttle)
	.=..()

/obj/machinery/computer/shuttle_control/trade/initialize()
	. = ..()
	new /obj/item/weapon/card/debit/trader(src.loc)

/obj/machinery/computer/shuttle_control/trade/proc/notify_port_toggled(var/reason)
	if(!reason)
		//Port opened
		var/obj/item/weapon/paper/P = new(get_turf(src))
		P.name = "NT Port Opened - [worldtime2text()]"
		P.info = "This is official notification that sanctioned arrival of Vox trading vessels has resumed as normal."
		P.update_icon()
		playsound(get_turf(src), "sound/effects/fax.ogg", 50, 1)
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-cent"
		P.stamped += /obj/item/weapon/stamp
		P.overlays += stampoverlay
		P.stamps += "<HR><i>This paper has been stamped by the Central Command Quantum Relay.</i>"
	if(reason)
		var/obj/item/weapon/paper/P = new(get_turf(src))
		P.name = "NT Port Closure - [worldtime2text()]"
		P.info = "This is official notification that sanctioned arrival of Vox trading vessels has been indefinitely suspended with no guarantee of appeal. The provided justification was:<BR><BR>[reason]"
		P.update_icon()
		playsound(get_turf(src), "sound/effects/fax.ogg", 50, 1)
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-cent"
		P.stamped += /obj/item/weapon/stamp
		P.overlays += stampoverlay
		P.stamps += "<HR><i>This paper has been stamped by the Central Command Quantum Relay.</i>"

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/trade/start
	areaname = "Trade Outpost"

/obj/docking_port/destination/trade/station
	areaname = "NanoTrasen Station"

/obj/docking_port/destination/trade/transit
	areaname = "hyperspace (trade shuttle)"

/obj/docking_port/destination/trade/extra
	areaname = "Casino"