/obj/item/weapon/cartridge/engineering
    name = "\improper Power-ON Cartridge"
    icon_state = "cart-e"
    access_engine = 1
    radio_type = /obj/item/radio/integrated/signal/bot/floorbot
    starting_apps = list(
        /datum/pda_app/cart/power_monitor,
        /datum/pda_app/cart/alert_monitor,
    )

/datum/pda_app/cart/power_monitor
    name = "Power Monitor"
    desc = "Access any power monitoring computer on the station."
    category = "Engineering Functions"
    icon = "pda_power"
    var/mode = 0
    var/obj/machinery/computer/powermonitor/powmonitor = null // Power Monitor
    var/list/powermonitors = list()

/datum/pda_app/cart/power_monitor/get_dat(var/mob/user)
    var/menu = ""
    switch(mode)
        if (0) //Muskets' and Rockdtben's power monitor :D
            menu = "<h4><span class='pda_icon pda_power'></span> Please select a Power Monitoring Computer</h4><BR>No Power Monitoring Computer detected in the vicinity.<BR>"
            var/powercount = 0
            var/found = 0

            for(var/obj/machinery/computer/powermonitor/pMon in power_machines)
                if(!(pMon.stat & (NOPOWER|BROKEN)))
                    var/turf/T = get_turf(src)
                    if(T.z == pMon.z)//the application may only detect power monitoring computers on its Z-level.
                        if(!found)
                            menu = "<h4><span class='pda_icon pda_power'></span> Please select a Power Monitoring Computer</h4><BR>"
                            found = 1
                            menu += "<FONT SIZE=-1>"
                        powercount++
                        menu += "<a href='byond://?src=\ref[src];choice=Power Select;target=[powercount]'> [pMon] </a><BR>"
                        powermonitors += "\ref[pMon]"
            if(found)
                menu += "</FONT>"

        if (1) //Muskets' and Rockdtben's power monitor :D
            if(!powmonitor)
                menu = "<h4><span class='pda_icon pda_power'></span> Power Monitor </h4><BR>"
                menu += "No connection<BR>"
            else
                menu = "<h4><span class='pda_icon pda_power'></span> [powmonitor] </h4><BR>"
                var/list/L = list()
                for(var/obj/machinery/power/terminal/term in powmonitor.connected_powernet.nodes)
                    if(istype(term.master, /obj/machinery/power/apc))
                        var/obj/machinery/power/apc/A = term.master
                        L += A


                menu += {"<PRE>Total power: [powmonitor.connected_powernet.avail] W<BR>Total load:  [num2text(powmonitor.connected_powernet.viewload,10)] W<BR>
                    <FONT SIZE=-1>"}
                if(L.len > 0)
                    menu += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

                    var/list/S = list(" Off","AOff","  On", " AOn")
                    var/list/chg = list("N","C","F")

                    for(var/obj/machinery/power/apc/A in L)
                        var/area/APC_area = get_area(A)
                        menu += copytext(add_tspace(APC_area.name, 30), 1, 30)
                        menu += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

                menu += "</FONT></PRE>"
    return menu

/datum/pda_app/cart/power_monitor/Topic(href, href_list)
    if(..())
        return
    if(href_list["Power Select"])
        var/pnum = text2num(href_list["Power Select"])
        powmonitor = locate(powermonitors[pnum])
        if(istype(powmonitor))
            mode = 1
    refresh_pda()

/datum/pda_app/cart/alert_monitor
    name = "Alert Monitor"
    desc = "Access any alert monitoring computer on the station."
    category = "Engineering Functions"
    icon = "pda_alert"
    var/mode = 0
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
                    var/turf/T = get_turf(src)
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

/obj/item/weapon/cartridge/atmos
    name = "\improper BreatheDeep Cartridge"
    icon_state = "cart-a"
    access_atmos = 1
    starting_apps = list(
        /datum/pda_app/cart/power_monitor,
        /datum/pda_app/cart/alert_monitor,
        /datum/pda_app/cart/scanner/atmos
    )

/datum/pda_app/cart/scanner/atmos
    base_name = "Gas Scanner"
    desc = "Used to scan gases in the air."
    category = "Utilities"
    icon = "pda_reagent"
    app_scanmode = SCANMODE_ATMOS

/obj/item/weapon/cartridge/mechanic
    name = "\improper Screw-E Cartridge"
    icon_state = "cart-mech"
    access_engine = 1 //for the power monitor, but may remove later
    starting_apps = list(
        /datum/pda_app/cart/power_monitor,
        /datum/pda_app/cart/alert_monitor,
        /datum/pda_app/cart/scanner/mechanic
    )

/datum/pda_app/cart/scanner/mechanic
    base_name = "Device Analyzer"
    desc = "Use a built in device analyzer."
    category = "Mechanic Functions"
    icon = "pda_scanner"
    app_scanmode = SCANMODE_DEVICE