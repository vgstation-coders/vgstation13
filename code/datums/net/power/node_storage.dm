/datum/net_node/power/storage
    var/maxPowerStored
    var/powerStored
    var/maxPowerOut
    var/maxPowerIn

//tries to store power and returns the remaining amount
/datum/net_node/power/storage/proc/try_add_power(var/power)
    if(power >= maxPowerIn)
        power -= maxPowerIn
        powerStored += maxPowerIn
    else if(power > 0)
        powerStored += power
        power = 0

    parent.update_icon()

    return power