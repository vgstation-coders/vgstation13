//Handles how much the temperature changes on power use. (Joules/Kelvin)
//Equates to as much heat energy per kelvin as a quarter tile of air.
#define XENOARCH_HEAT_CAPACITY 5000

//Handles heat transfer to the air. (In watts)
//Can heat a single tile 2 degrees per tick.
#define XENOARCH_MAX_ENERGY_TRANSFER 4000

//How many joules of electrical energy produce how many joules of heat energy?
#define XENOARCH_HEAT_COEFFICIENT 3


/obj/machinery/anomaly
	name = "Analysis machine"
	desc = "A specialised, complex analysis machine."
	anchored = 1
	density = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"

	idle_power_usage = 20 //watts
	active_power_usage = 300 //Because  I need to make up numbers~

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/obj/item/weapon/reagent_containers/glass/held_container
	var/obj/item/weapon/tank/fuel_container
	var/target_scan_ticks = 30
	var/report_num = 0
	var/scan_process = 0
	var/temperature = 273	//measured in kelvin, if this exceeds 1200, the machine is damaged and requires repairs
							//if this exceeds 600 and safety is enabled it will shutdown
							//temp greater than 600 also requires a safety prompt to initiate scanning
	var/max_temp = 450

/obj/machinery/anomaly/New()
	..()

	//for analysis debugging
	/*var/obj/item/weapon/reagent_containers/glass/solution_tray/S = new(src.loc)
	var/turf/unsimulated/mineral/diamond/D
	for(var/turf/unsimulated/mineral/diamond/M in world)
		D = M
		break
	S.reagents.add_reagent(ANALYSIS_SAMPLE, 1, D.geological_data)
	S.reagents.add_reagent(CHLORINE, 1, null)*/

/obj/machinery/anomaly/RefreshParts()
	var/scancount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module)) scancount += SP.rating-1
	target_scan_ticks = initial(target_scan_ticks) - scancount*4

/obj/machinery/anomaly/process()
	//not sure if everything needs to heat up, or just the GLPC
	var/datum/gas_mixture/env = loc.return_air()
	var/environmental_temp = env.temperature
	if(scan_process)
		if(scan_process++ > target_scan_ticks)
			FinishScan()
		else if(temperature > 400)
			src.visible_message("<span class='notice'>[bicon(src)] shuts down from the heat!</span>", 2)
			scan_process = 0
		else if(temperature > 350 && prob(10))
			src.visible_message("<span class='notice'>[bicon(src)] bleets plaintively.</span>", 2)
			if(temperature > 400)
				scan_process = 0

		//show we're busy
		if(prob(5))
			src.visible_message("<span class='notice'>[bicon(src)] [pick("whirrs","chuffs","clicks")][pick(" quietly"," softly"," sadly"," excitedly"," energetically"," angrily"," plaintively")].</span>", 2)

		use_power = 2

		icon_state = "analyser_processing"
	else
		use_power = 1
		icon_state = "analyser"
		if(prob(10))
			flick(src, "analyser_processing")

	//Add 3000 joules when active.  This is about 0.6 degrees per tick.
	//May need adjustment
	if(use_power == 1)
		var/heat_added = active_power_usage *XENOARCH_HEAT_COEFFICIENT

		if(temperature < max_temp)
			temperature += heat_added/XENOARCH_HEAT_CAPACITY

		var/temperature_difference = abs(environmental_temp-temperature)
		var/datum/gas_mixture/removed = loc.remove_air(env.total_moles*0.25)
		var/heat_capacity = removed.heat_capacity()

		heat_added = max(temperature_difference*heat_capacity, XENOARCH_MAX_ENERGY_TRANSFER)

		if(temperature > environmental_temp)
			//cool down to match the air
			temperature = max(TCMB, temperature - heat_added/XENOARCH_HEAT_CAPACITY)
			removed.temperature = max(TCMB, removed.temperature + heat_added/heat_capacity)

			if(temperature_difference > 10 && prob(5))
				src.visible_message("<span class='notice'>[bicon(src)] hisses softly.</span>", 2)

		else
			//heat up to match the air
			temperature = max(TCMB, temperature + heat_added/XENOARCH_HEAT_CAPACITY)
			removed.temperature = max(TCMB, removed.temperature - heat_added/heat_capacity)

			if(temperature_difference > 10 && prob(5))
				src.visible_message("<span class='notice'>[bicon(src)] plinks quietly.</span>", 2)

		env.merge(removed)


//this proc should be overriden by each individual machine
/obj/machinery/anomaly/attack_hand(var/mob/user as mob)
	if(..()) return
	if(stat & (NOPOWER|BROKEN))
		return
	user.machine = src
	var/dat = "<B>[src.name]</B><BR>"

	dat += {"Module heat level: [temperature] kelvin<br>
		Safeties set at 350k, shielding failure at 400k. Failure to maintain safe heat levels may result in equipment damage.<br>
		<hr>"}
	if(scan_process)
		dat += "Scan in progress<br><br><br>"
	else
		dat += "[held_container ? "<A href='?src=\ref[src];eject_beaker=1'>Eject beaker</a>" : "No beaker inserted."]<br>"
		//dat += "[fuel_container ? "<A href='?src=\ref[src];eject_fuel=1'>Eject fuel tank</a>" : "No fuel tank inserted."]<br>"
		dat += "[held_container ? "<A href='?src=\ref[src];begin=1'>Begin scanning</a>" : ""]"

	dat += {"<hr>
		<A href='?src=\ref[src];refresh=1'>Refresh</a><BR>
		<A href='?src=\ref[src];close=1'>Close</a><BR>"}
	user << browse(dat, "window=anomaly;size=450x500")
	onclose(user, "anomaly")

obj/machinery/anomaly/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/weapon/reagent_containers/glass))
		//var/obj/item/weapon/reagent_containers/glass/G = W
		if(held_container)
			to_chat(user, "<span class='warning'>You must remove the [held_container] first.</span>")
		else
			if(user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You put the [W] into the [src].</span>")

				held_container = W
				updateDialog()

		return 1 // avoid afterattack() being called
	/*else if(istype(W, /obj/item/weapon/tank))
		//var/obj/item/weapon/reagent_containers/glass/G = W
		if(fuel_container)
			to_chat(user, "<span class='warning'>You must remove the [fuel_container] first.</span>")
		else
			to_chat(user, "<span class='notice'>You put the [fuel_container] into the [src].</span>")
			user.drop_item(W, src)
			fuel_container.loc = src
			fuel_container = W
			updateDialog()*/
	else
		return ..()

obj/machinery/anomaly/proc/ScanResults()
	//instantiate in children to produce unique scan behaviour
	return "<span class='warning'>Error initialising scanning components.</span>"

obj/machinery/anomaly/proc/FinishScan()
	scan_process = 0
	updateDialog()

	//determine the results and print a report
	if(held_container)
		src.visible_message("<span class='notice'>[bicon(src)] makes an insistent chime.</span>", 2)
		var/obj/item/weapon/paper/P = new(src.loc)
		P.name = "[src] report #[++report_num]"
		P.info = "<b>[src] analysis report #[report_num]</b><br><br>" + ScanResults()
		P.stamped = list(/obj/item/weapon/stamp)
		P.overlays = list("paper_stamped")
	else
		src.visible_message("<span class='notice'>[bicon(src)] makes a low buzzing noise.</span>", 2)

obj/machinery/anomaly/Topic(href, href_list)
	if(..()) return
	usr.set_machine(src)
	if(href_list["close"])
		usr << browse(null, "window=anomaly")
		usr.machine = null
	if(href_list["eject_beaker"])
		held_container.loc = src.loc
		held_container = null
	if(href_list["eject_fuel"])
		fuel_container.loc = src.loc
		fuel_container = null
	if(href_list["begin"])
		if(temperature >= 350)
			var/proceed = input("Unsafe internal temperature detected, enter YES below to continue.","Warning")
			if(proceed == "YES" && !..()) //call parent again to run distance and power checks again.
				scan_process = 1
		else
			scan_process = 1

	updateUsrDialog()

//whether the carrier sample matches the possible finds
//results greater than a threshold of 0.6 means a positive result
obj/machinery/anomaly/proc/GetResultSpecifity(var/datum/geosample/scanned_sample, var/carrier_name)
	var/specifity = 0
	if(scanned_sample && carrier_name)

		if(scanned_sample.find_presence.Find(carrier_name))
			specifity = 0.75 * (scanned_sample.find_presence[carrier_name] / scanned_sample.total_spread) + 0.25
		else
			specifity = rand(0, 0.5)

	return specifity
