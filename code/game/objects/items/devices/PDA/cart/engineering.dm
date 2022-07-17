/obj/item/weapon/cartridge/engineering
    name = "\improper Power-ON Cartridge"
    icon_state = "cart-e"
    radio_type = /obj/item/radio/integrated/signal/bot/floorbot
    starting_apps = list(
        /datum/pda_app/cart/power_monitor,
        /datum/pda_app/cart/alert_monitor,
        /datum/pda_app/cart/scanner/engineer,
        /datum/pda_app/cart/floorbot,
    )

/datum/pda_app/cart/power_monitor
    name = "Power Monitor"
    desc = "Access any power monitoring computer on the station."
    category = "Engineering Functions"
    icon = "pda_power"
    var/obj/machinery/computer/powermonitor/powmonitor = null // Power Monitor
    var/list/powermonitors = list()

/datum/pda_app/cart/power_monitor/get_dat(var/mob/user)
    var/menu = ""
    switch(mode)
        if (0) //Muskets' and Rockdtben's power monitor :D
            menu = "<h4><span class='pda_icon pda_power'></span> Please select a Power Monitoring Computer</h4><BR>No Power Monitoring Computer detected in the vicinity.<BR>"
            var/powercount = 0
            var/found = 0

            for(var/datum/power_connection/C in power_machines)
                if(istype(C.parent, /obj/machinery/computer/powermonitor))
                    var/obj/machinery/computer/powermonitor/pMon = C.parent

                    if(!(pMon.stat & (NOPOWER|BROKEN)))
                        var/turf/T = get_turf(pda_device)
                        if(T.z == pMon.z)//the application may only detect power monitoring computers on its Z-level.
                            if(!found)
                                menu = "<h4><span class='pda_icon pda_power'></span> Please select a Power Monitoring Computer</h4><BR>"
                                found = 1
                                menu += "<FONT SIZE=-1>"
                            powercount++
                            menu += "<a href='byond://?src=\ref[src];target=[powercount]'> [pMon] </a><BR>"
                            powermonitors += "\ref[pMon]"
            if(found)
                menu += "</FONT>"

        if (1) //Muskets' and Rockdtben's power monitor :D
            if(!powmonitor)
                menu = "<h4><span class='pda_icon pda_power'></span> Power Monitor </h4><BR>"
                menu += "No connection<BR>"
            else
                var/datum/powernet/connected_powernet = powmonitor.power_connection.get_powernet()
                menu = "<h4><span class='pda_icon pda_power'></span> [powmonitor] </h4><BR>"
                var/list/L = list()
                for(var/obj/machinery/power/terminal/term in connected_powernet.nodes)
                    if(istype(term.master, /obj/machinery/power/apc))
                        var/obj/machinery/power/apc/A = term.master
                        L += A

                menu += "<PRE>Total power: [format_watts(connected_powernet.avail)]<BR>Total load:  [format_watts(connected_powernet.viewload)]<BR><FONT SIZE=-1>"
                if(L.len > 0)
                    menu += "             Area              Eqp./Lgt./Env.    Load    Cell<HR>"
                    var/list/S = list(" Off","AOff","  On", " AOn")
                    var/list/chg = list("N","C","F")

                    for(var/obj/machinery/power/apc/A in L)
                        var/area/APC_area = get_area(A)
                        menu += copytext(add_tspace(trim_left(APC_area.name), 30), 1, 31)
                        menu += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(format_watts(A.lastused_total), 9)] [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

                menu += "</FONT></PRE>"
    return menu

/datum/pda_app/cart/power_monitor/Topic(href, href_list)
    if(..())
        return
    if(href_list["target"])
        var/pnum = text2num(href_list["target"])
        powmonitor = locate(powermonitors[pnum])
        if(istype(powmonitor))
            mode = 1
    refresh_pda()

/datum/pda_app/cart/alert_monitor
    name = "Alert Monitor"
    desc = "Access any alert monitoring computer on the station."
    category = "Engineering Functions"
    icon = "pda_alert"
    var/obj/machinery/computer/station_alert/alertmonitor = null // Alert Monitor
    var/list/alertmonitors = list()

/datum/pda_app/cart/alert_monitor/get_dat(var/mob/user)
    var/menu = ""
    switch(mode)
        if (0)
            menu = "<h4><span class='pda_icon pda_alert'></span> Please select an Alert Computer</h4><BR>No Alert Computer detected in the vicinity.<BR>"
            alertmonitor = null
            alertmonitors = list()

            var/alertcount = 0
            var/found = 0

            for(var/obj/machinery/computer/station_alert/aMon in machines)
                if(!(aMon.stat & (NOPOWER|BROKEN)))
                    var/turf/T = get_turf(pda_device)
                    if(T.z == aMon.z)//the application may only detect station alert computers on its Z-level.
                        if(!found)
                            menu = "<h4><span class='pda_icon pda_alert'></span> Please select an Alert Computer</h4><BR>"
                            found = 1
                            menu += "<FONT SIZE=-1>"
                        alertcount++
                        menu += "<a href='byond://?src=\ref[src];Alert Select=[alertcount]'> [aMon] </a><BR>"
                        alertmonitors += "\ref[aMon]"
            if(found)
                menu += "</FONT>"

        if (1)
            if(!alertmonitor)
                menu = "<h4><span class='pda_icon pda_alert'></span> Alert Monitor </h4><BR>"
                menu += "No connection<BR>"
            else
                menu = "<h4><span class='pda_icon pda_alert'></span> [alertmonitor] </h4><BR>"
                for (var/cat in alertmonitor.alarms)
                    menu += text("<B>[]</B><BR>\n", cat)
                    var/list/L = alertmonitor.alarms[cat]
                    if (L.len)
                        for (var/alarm in L)
                            var/list/alm = L[alarm]
                            var/area/A = alm[1]
                            var/list/sources = alm[3]

                            menu += {"<NOBR>
                                &bull;
                                [A.name]"}

                            if (sources.len > 1)
                                menu += text(" - [] sources", sources.len)
                            menu += "</NOBR><BR>\n"
                    else
                        menu += "-- All Systems Nominal<BR>\n"
                    menu += "<BR>\n"

                menu += "</FONT></PRE>"
    return menu

/datum/pda_app/cart/alert_monitor/Topic(href, href_list)
    if(..())
        return
    if(href_list["Alert Select"])
        var/pnum = text2num(href_list["Alert Select"])
        alertmonitor = locate(alertmonitors[pnum])
        if(istype(alertmonitor))
            mode = 1
    refresh_pda()

/datum/pda_app/cart/floorbot
	name = "Floor Bot Access"
	desc = "Used to control a floorbot."
	category = "Engineering Functions"
	icon = "pda_atmos"

/datum/pda_app/cart/floorbot/get_dat(var/mob/user)
	var/dat = ""
	if (!cart_device)
		dat += {"<span class='pda_icon pda_atmos'></span> Could not find radio peripheral connection <br/>"}
		return
	if (!istype(cart_device.radio, /obj/item/radio/integrated/signal/bot/floorbot))
		dat += {"<span class='pda_icon pda_atmos'></span> Commlink bot error <br/>"}
		return
	dat += {"<span class='pda_icon pda_atmos'></span><b>F.L.O.O.R bot Interlink V1.0</b> <br/>"}
	dat += "<ul>"
	for (var/obj/machinery/bot/floorbot/floor in bots_list)
		if (floor.z != user.z)
			continue
		dat += {"<li>
				<i>[floor]</i>: [floor.return_status()] in [get_area_name(floor)] <br/>
				<a href='?src=\ref[cart_device.radio];bot=\ref[floor];command=summon;user=\ref[user]'>[floor.summoned ? "Halt" : "Summon"]</a> <br/>
				<a href='?src=\ref[cart_device.radio];bot=\ref[floor];command=switch_power;user=\ref[user]'>Turn [floor.on ? "off" : "on"]</a> <br/>
				Auto-patrol: <a href='?src=\ref[cart_device.radio];bot=\ref[floor];command=auto_patrol;user=\ref[user]'>[floor.auto_patrol ? "Enabled" : "Disabled"]</a><br/>
				</li>"}
	dat += "</ul>"
	return dat

/datum/pda_app/cart/scanner/engineer
    base_name = "Halogen counter"
    desc = "Used to measure rads in an area."
    category = "Utilities"
    icon = "pda_reagent"

/datum/pda_app/cart/scanner/engineer/attack(mob/living/carbon/C, mob/living/user as mob)
    if(istype(C))
        for (var/mob/O in viewers(C, null))
            O.show_message("<span class='warning'>[user] has analyzed [C]'s radiation levels!</span>", 1)

        user.show_message("<span class='notice'>Analyzing Results for [C]:</span>")
        if(C.radiation)
            user.show_message("<span class='good'>Radiation Level: </span>[C.radiation]")
        else
            user.show_message("<span class='notice'>No radiation detected.</span>")

/obj/item/weapon/cartridge/atmos
    name = "\improper BreatheDeep Cartridge"
    icon_state = "cart-a"
    starting_apps = list(
        /datum/pda_app/cart/power_monitor,
        /datum/pda_app/cart/alert_monitor,
        /datum/pda_app/cart/scanner/atmos,
    )

/datum/pda_app/cart/scanner/atmos
    base_name = "Gas Scanner"
    desc = "Used to scan gases in the air."
    category = "Utilities"
    icon = "pda_reagent"

/datum/pda_app/cart/scanner/atmos/afterattack(atom/A, mob/user, proximity_flag)
    if(!cart_device.atmos_analys || !proximity_flag)
        return
    cart_device.atmos_analys.cant_drop = 1
    if(!A.attackby(cart_device.atmos_analys, user))
        cart_device.atmos_analys.afterattack(A, user, 1)

/obj/item/weapon/cartridge/mechanic
    name = "\improper Screw-E Cartridge"
    icon_state = "cart-mech"
    starting_apps = list(
        /datum/pda_app/cart/power_monitor,
        /datum/pda_app/cart/scanner/mechanic
    )

/datum/pda_app/cart/scanner/mechanic
    base_name = "Device Analyzer"
    desc = "Use a built in device analyzer."
    category = "Mechanic Functions"
    icon = "pda_scanner"

/datum/pda_app/cart/scanner/mechanic/preattack(atom/A as mob|obj|turf|area, mob/user as mob)
    if(cart_device.dev_analys)
        cart_device.dev_analys.cant_drop = 1
        cart_device.dev_analys.max_designs = 5
        if(A.Adjacent(user))
            return cart_device.dev_analys.preattack(A, user, 1)
