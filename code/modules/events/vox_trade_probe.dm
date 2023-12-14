/*
 * Vox Trade Probe - if no trader, trade shuttle in dock, probe has not fired yet, wages are not below 100%, port is open
 * Fire weight can increase up to 90, which is very high for an event, if lot of players, money, and time
 */

 #define TRADEPROBE_BONUS_TIMER 120 //how many seconds need to pass to increase weight by 1

/datum/event/tradeprobe
	endWhen	= 270 //How many 2-second ticks should we stay? 9 minutes = 540 / 2 = 270
	oneShot = TRUE //one per shift

/datum/event/tradeprobe/can_start(var/list/active_with_role)
	//No probe if... there is a trader, the trade shuttle is at the station, or financial mismanagement
	if(SStrade.loyal_customers.len)
		return FALSE
	if(!istype(trade_shuttle.current_port,/obj/docking_port/destination/trade/start))
		return FALSE
	if(!ports_open)
		command_alert(/datum/command_alert/tradeaversion_closedport)
		return FALSE
	if(payroll_modifier < 1)
		command_alert(/datum/command_alert/tradeaversion_mismanagement)
		return FALSE

	//Gain 1 weight per 3% above normal wages players received last cycle, up to 30 weight at 190%
	var/wageboost = min((payroll_modifier-1)/0.03,30)
	//Gain 5 weight per player beyond 10, up to 30 weight at 20 players
	var/playerboost = min(max(0,active_with_role["Any"]-10) * 3, 30)
	//Gain 1 weight per 2 minutes after shieft start, up to 30 weight at 60 minutes
	var/timeboost = min(((world.time / (1 SECONDS)) - ticker.gamestart_time)/(TRADEPROBE_BONUS_TIMER),30) //gamestart_time is in seconds
	return wageboost + playerboost + timeboost

/datum/event/tradeprobe/setup()
	//Lock trade shuttle so that it can't crush the probe
	trade_shuttle.lockdown = "The trade shuttle has been temporarily locked while a pod is in port. The pod will depart after 10 minutes."
	load_dungeon(/datum/map_element/dungeon/tradeprobe)
	tradeprobe = new(starting_area = /area/shuttle/tradeprobe)
	tradeprobe.initialize()
	tradeprobe.move()
	/*tradeprobe.set_transit_dock(/obj/docking_port/destination/trade/station)
	tradeprobe.move_to_dock(tradeprobe.destination_port)*/

/datum/event/tradeprobe/announce()
	command_alert(/datum/command_alert/tradeprobe)

/datum/event/tradeprobe/end()
	command_alert(/datum/command_alert/tradeprobe_depart)
	spawn(1 MINUTES)
		trade_shuttle.lockdown = FALSE
		//Send shuttle to secondary dock at trade outpost
		tradeprobe.remove_dock(/obj/docking_port/destination/trade/station)
		tradeprobe.add_dock(/obj/docking_port/destination/salvage/trading_post)
		tradeprobe.destroy_everything = TRUE //One last trip
		tradeprobe.move()
		for(var/obj/structure/trade_window/TW in SStrade.all_twindows)
			TW.new_pending(tw_probe_return)

/obj/machinery/vending/sale/trader/probe
	anchored = TRUE

/obj/machinery/vending/sale/trader/probe/New()
	..()
	//Grab some items from variety packs...
	for(var/i = 1 to 6)
		var/datum/trade_product/TP = SStrade.stocked_variety_pack()
		TP.totalsold++
		var/pathtomake = TP.path
		var/obj/O = new pathtomake(src)
		for(var/obj/item/I in O.contents)
			I.price = round((rand(4,6)/10)*TP.baseprice) //Each item valued at 40-60% of crate cost
			loadCustomItem(I)

/obj/structure/airshield/voxprobe
	opacity = FALSE
	icon = 'icons/turf/voxprobe.dmi'
	icon_state = "voxairshield_on"

/turf/simulated/wall/shuttle/unsmoothed/vox
	name = "neogypsum wall"
	desc = "Ah, neogypsum. Just as flakey as the Earth stuff. How does it stay intact?"
	icon = 'icons/turf/voxprobe.dmi'
	icon_state = "voxwall"

/obj/structure/window/full/reinforced/plasma/vox
	name = "rhondite window"
	desc = "It is unclear what cultural purpose rhondite serves for the Vox. The window itself is clear, though."
	icon = 'icons/turf/voxprobe.dmi'
	icon_state = "voxwindow"

/obj/structure/window/full/reinforced/plasma/vox/relativewall()
	return //to prevent smoothing and replacing the icon

/turf/simulated/floor/shuttle/vox
	name = "neogypsum flooring"
	icon = 'icons/turf/floors.dmi'
	icon_state = "sandstonevault"

var/global/datum/shuttle/voxprobe/tradeprobe

/area/shuttle/tradeprobe

/datum/shuttle/voxprobe
	name = "trade probe"
	can_link_to_computer = LINK_PASSWORD_ONLY
	password = TRUE
	stable = TRUE
	can_rotate = TRUE

/datum/shuttle/voxprobe/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/trade/station)

/datum/map_element/dungeon/tradeprobe
	name = "Trade Probe"
	file_path = "maps/misc/tradeprobe.dmm"