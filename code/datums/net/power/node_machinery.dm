/datum/net_node/power/machinery

/datum/net_node/power/machinery/power_change()
    var/obj/machinery/power/papa = parent
    if(!istype(papa))
        CRASH("[src.type] has a parent that is not a power machinery!")
        return
    
    papa.power_change()
