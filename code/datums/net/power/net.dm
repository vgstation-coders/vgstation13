/datum/net/power
    note_types = list(/datum/net_node/power)
    var/load = 0				// the current load on the powernet, increased by each machine at processing
    var/newavail = 0			// what available power was gathered last tick, then becomes...
    var/avail = 0				// ...the current available power in the powernet
    var/viewload = 0			// the load as it appears on the power console (gradually updated)
    var/netexcess = 0			// excess power on the powernet (typically avail-load)

//merges with another net
/datum/net/power/absorb_net(var/datum/net/power/other_net)
    if(!..())
        return 0
    
    load += other_net.load
    newavail += other_net.newavail
    avail += other_net.avail
    viewload += other_net.viewload
    netexcess += other_net.netexcess