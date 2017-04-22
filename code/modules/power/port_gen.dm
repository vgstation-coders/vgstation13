//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/* new portable generator - work in progress

/obj/machinery/power/port_gen
	name = "portable generator"
	desc = "A portable generator used for emergency backup power."
	icon = 'generator.dmi'
	icon_state = "off"
	density = 1
	anchored = 0
	var/t_status = 0
	var/t_per = 5000
	var/filter = 1
	var/tank = null
	var/turf/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/turf/outturf
	var/lastgen


/obj/machinery/power/port_gen/process()
ideally we're looking to generate 5000

/obj/machinery/power/port_gen/attackby(obj/item/weapon/W, mob/user)
tank [un]loading stuff

/obj/machinery/power/port_gen/attack_hand(mob/user)
turn on/off

/obj/machinery/power/port_gen/examine()
display round(lastgen) and plasmatank amount

*/

//Previous code been here forever, adding new framework for portable generators


//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "Portable Generator"
	desc = "A portable generator for emergency backup power"
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen1"
	density = 1
	anchored = 0
	use_power = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/active = 0
	var/power_gen = 5000
	var/recent_fault = 0
	var/power_output = 1

/obj/machinery/power/port_gen/proc/HasFuel() //Placeholder for fuel check.
	return 1

/obj/machinery/power/port_gen/proc/UseFuel() //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/DropFuel()
	return

/obj/machinery/power/port_gen/proc/handleInactive()
	return

/obj/machinery/power/port_gen/process()
	if(active && HasFuel() && !crit_fail && anchored && powernet)
		add_avail(power_gen * power_output)
		UseFuel()
		src.updateDialog()

	else
		active = 0
		update_icon()
		handleInactive()

/obj/machinery/power/port_gen/attack_hand(mob/user as mob)
	if(..())
		return
	if(!anchored)
		return

/obj/machinery/power/port_gen/examine(mob/user)
	..()
	if(active)
		to_chat(usr, "<span class='info'>The generator is on.</span>")
	else
		to_chat(usr, "<span class='info'>The generator is off.</span>")

/obj/machinery/power/port_gen/pacman
	name = "P.A.C.M.A.N.-type Portable Generator"
	var/sheets = 0
	var/max_sheets = 100
	var/sheet_name = ""
	var/sheet_path = /obj/item/stack/sheet/mineral/plasma
	var/board_path = "/obj/item/weapon/circuitboard/pacman"
	var/sheet_left = 0 // How much is left of the sheet
	var/time_per_sheet = 40
	var/heat = 0

/obj/machinery/power/port_gen/pacman/initialize()
	..()
	if(anchored)
		connect_to_network()

/obj/machinery/power/port_gen/pacman/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/stack/cable_coil,
		/obj/item/stack/cable_coil,
		/obj/item/weapon/stock_parts/capacitor,
		board_path
	)

	var/obj/sheet = new sheet_path(null)
	sheet_name = sheet.name
	RefreshParts()

/obj/machinery/power/port_gen/pacman/Destroy()
	DropFuel()
	..()

/obj/machinery/power/port_gen/pacman/RefreshParts()
	var/temp_rating = 0
	var/temp_reliability = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/matter_bin))
			max_sheets = SP.rating * SP.rating * 50
		else if(istype(SP, /obj/item/weapon/stock_parts/micro_laser) || istype(SP, /obj/item/weapon/stock_parts/capacitor))
			temp_rating += SP.rating
	for(var/obj/item/weapon/CP in component_parts)
		temp_reliability += CP.reliability
	reliability = min(round(temp_reliability / 4), 100)
	power_gen = round(initial(power_gen) * (max(2, temp_rating) / 2))

/obj/machinery/power/port_gen/pacman/examine(mob/user)
	..()
	if(crit_fail)
		to_chat(user, "<span class='warning'>The generator seems to have broken down.</span>")
	else
		to_chat(user, "<span class='info'>The generator has [sheets] units of [sheet_name] fuel left, producing [power_gen] per cycle.</span>")

/obj/machinery/power/port_gen/pacman/HasFuel()
	if(sheets >= 1 / (time_per_sheet / power_output) - sheet_left)
		return 1
	return 0

/obj/machinery/power/port_gen/pacman/DropFuel()
	if(sheets)
		var/fail_safe = 0
		while(sheets > 0 && fail_safe < 100)
			fail_safe += 1
			var/obj/item/stack/sheet/S = new sheet_path(loc)
			var/amount = min(sheets, S.max_amount)
			S.amount = amount
			sheets -= amount

/obj/machinery/power/port_gen/pacman/UseFuel()
	var/needed_sheets = 1 / (time_per_sheet / power_output)
	var/temp = min(needed_sheets, sheet_left)
	needed_sheets -= temp
	sheet_left -= temp
	sheets -= round(needed_sheets)
	needed_sheets -= round(needed_sheets)
	if (sheet_left <= 0 && sheets > 0)
		sheet_left = 1 - needed_sheets
		sheets--

	var/lower_limit = 56 + power_output * 10
	var/upper_limit = 76 + power_output * 10
	var/bias = 0
	if (power_output > 4)
		upper_limit = 400
		bias = power_output * 3
	if (heat < lower_limit)
		heat += 3
	else
		heat += rand(-7 + bias, 7 + bias)
		if (heat < lower_limit)
			heat = lower_limit
		if (heat > upper_limit)
			heat = upper_limit

	if (heat > 300)
		overheat()
		qdel(src)
	return

/obj/machinery/power/port_gen/pacman/handleInactive()

	if (heat > 0)
		heat = max(heat - 2, 0)
		src.updateDialog()

/obj/machinery/power/port_gen/pacman/proc/overheat()
	explosion(src.loc, 2, 5, 2, -1)

/obj/machinery/power/port_gen/pacman/emag(mob/user)
	emagged = 1
	emp_act(1)
	return 1

/obj/machinery/power/port_gen/pacman/crowbarDestroy(mob/user) //don't like the copy/paste, but the proc has special handling in the middle so we need it
	if(..())
		while ( sheets > 0 )
			var/obj/item/stack/sheet/G = new sheet_path(src.loc)
			if ( sheets > 50 )
				G.amount = 50
			else
				G.amount = sheets
			sheets -= G.amount
		return 1
	return -1

/obj/machinery/power/port_gen/pacman/wrenchAnchor(mob/user)
	if(..() == 1)
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
		return 1
	return -1

/obj/machinery/power/port_gen/pacman/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, sheet_path))
		var/obj/item/stack/addstack = O
		var/amount = min((max_sheets - sheets), addstack.amount)
		if(amount < 1)
			to_chat(user, "<span class='notice'>The [src.name] is full!</span>")
			return
		to_chat(user, "<span class='notice'>You add [amount] sheets to the [src.name].</span>")
		sheets += amount
		addstack.use(amount)
		updateUsrDialog()
		return
	else if(!active)
		if( ..() )
			return 1

/obj/machinery/power/port_gen/pacman/attack_hand(mob/user as mob)
	..()
	if (!anchored)
		return

	interact(user)

/obj/machinery/power/port_gen/pacman/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	interact(user)

/obj/machinery/power/port_gen/pacman/attack_paw(mob/user as mob)
	interact(user)

/obj/machinery/power/port_gen/pacman/interact(mob/user)
	if (get_dist(src, user) > 1 )
		if (!istype(user, /mob/living/silicon/ai))
			user.unset_machine()
			user << browse(null, "window=port_gen")
			return

	user.set_machine(src)

	var/dat = text("<b>[name]</b><br>")
	if (active)
		dat += text("Generator: <A href='?src=\ref[src];action=disable'>On</A><br>")
	else
		dat += text("Generator: <A href='?src=\ref[src];action=enable'>Off</A><br>")
	dat += text("[capitalize(sheet_name)]: [sheets] - <A href='?src=\ref[src];action=eject'>Eject</A><br>")
	var/stack_percent = round(sheet_left * 100, 1)
	dat += text("Current stack: [stack_percent]% <br>")
	dat += text("Power output: <A href='?src=\ref[src];action=lower_power'>-</A> [power_gen * power_output] <A href='?src=\ref[src];action=higher_power'>+</A><br>")
	dat += text("Power current: [(powernet == null ? "Unconnected" : "[avail()]")]<br>")
	dat += text("Heat: [heat]<br>")
	dat += "<br><A href='?src=\ref[src];action=close'>Close</A>"
	user << browse("[dat]", "window=port_gen")
	onclose(user, "port_gen")

/obj/machinery/power/port_gen/pacman/Topic(href, href_list)
	if(..())
		return

	src.add_fingerprint(usr)
	if(href_list["action"])
		if(href_list["action"] == "enable")
			if(!active && HasFuel() && !crit_fail)
				active = 1
				update_icon()
				src.updateUsrDialog()
		if(href_list["action"] == "disable")
			if (active)
				active = 0
				update_icon()
				src.updateUsrDialog()
		if(href_list["action"] == "eject")
			if(!active)
				DropFuel()
				src.updateUsrDialog()
		if(href_list["action"] == "lower_power")
			if (power_output > 1)
				power_output--
				src.updateUsrDialog()
		if (href_list["action"] == "higher_power")
			if (power_output < 4 || emagged)
				power_output++
				src.updateUsrDialog()
		if (href_list["action"] == "close")
			usr << browse(null, "window=port_gen")
			usr.unset_machine()

/obj/machinery/power/port_gen/npc_tamper_act(mob/living/L)
	active = !active
	update_icon()

/obj/machinery/power/port_gen/update_icon()
	..()

	if(!active)
		icon_state = "portgen0"
	else
		icon_state = initial(icon_state)

/obj/machinery/power/port_gen/pacman/super
	name = "S.U.P.E.R.P.A.C.M.A.N.-type Portable Generator"
	icon_state = "portgen1"
	sheet_path = /obj/item/stack/sheet/mineral/uranium
	power_gen = 15000
	time_per_sheet = 65
	board_path = "/obj/item/weapon/circuitboard/pacman/super"
	overheat()
		explosion(src.loc, 3, 3, 3, -1)

/obj/machinery/power/port_gen/pacman/mrs
	name = "M.R.S.P.A.C.M.A.N.-type Portable Generator"
	icon_state = "portgen2"
	sheet_path = /obj/item/stack/sheet/mineral/diamond
	power_gen = 40000
	time_per_sheet = 80
	board_path = "/obj/item/weapon/circuitboard/pacman/mrs"
	overheat()
		explosion(src.loc, 4, 4, 4, -1)
