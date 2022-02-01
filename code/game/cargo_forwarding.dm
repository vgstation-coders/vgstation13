/datum/subsystem/supply_shuttle
    var/list/datum/cargo_forwarding/cargo_forwards = list()
    var/forwarding_on = FALSE

/datum/cargo_forwarding
    var/name = null
    var/datum/money_account/acct // account we pay to
    var/acct_by_string = ""
    var/list/contains = list()
    var/amount = null
    var/containertype = null
    var/containername = null
    var/access = null // See code/game/jobs/access.dm
    var/one_access = null // See above
    var/worth = 0 // Payed out for forwarding
    var/cargo_contribution = 0.1
    var/atom/associated_crate = null // For ease of checking
    var/obj/item/weapon/paper/manifest/associated_manifest = null // Same here
    var/origin_station_name = "" // Some fluff
    var/origin_sender_name = ""
    var/time_limit = 5 // In minutes

/datum/cargo_forwarding/New()
    ..()
    if (acct_by_string)
        acct = department_accounts[acct_by_string]
    else
        acct = station_account
        acct_by_string = station_name()
    
    do // This check prevents the station name being our own, do while so that it runs once to generate a name in the first place.
        origin_station_name = new_station_name(TRUE)
    while(origin_station_name == station_name)

    time_limit = rand(5,15)

    var/male_name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
    var/female_name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
    var/vox_name = ""
    for(var/j = 1 to rand(3,8))
        vox_name += pick(vox_name_syllables)
    vox_name = capitalize(vox_name)
    var/insect_name
    for(var/k = 1 to rand(2,3))
        insect_name += pick(insectoid_name_syllables)
    insect_name = capitalize(insect_name)
    origin_sender_name = pick(male_name,female_name,vox_name,insect_name)

    SSsupply_shuttle.cargo_forwards.Add(src)

    spawn(time_limit MINUTES) //Still an order after the time limit?
        if(src)
            Pay(TRUE)

/datum/cargo_forwarding/Destroy()
    SSsupply_shuttle.cargo_forwards.Remove(src)
    acct = null
    ..()

/datum/cargo_forwarding/proc/Pay(var/crate_tampered = FALSE)
    if(crate_tampered)
        worth *= -0.5 //Deduct a penalty instead

    acct.charge(-worth,null,"Payment for cargo crate fowarding ([name])",dest_name = name)

    if (cargo_contribution > 0 && acct_by_string != "Cargo")//cargo gets some extra coin from everything shipped
        var/datum/money_account/cargo_acct = department_accounts["Cargo"]
        cargo_acct.charge(round(-worth/10),null,"Contribution for cargo crate fowarding ([name])",dest_name = name)
    
    for(var/obj/machinery/computer/supplycomp/S in SSsupply_shuttle.supply_consoles)
        S.say("Cargo crate forwarded [crate_tampered ? "unsuccessfully! Reward docked." : "successfully!"]")
        playsound(S, 'sound/machines/info.ogg', 50, 1)
    
    qdel(src)

/datum/cargo_forwarding/from_supplypack/New()
    ..()
    var/packtype = pick(subtypesof(/datum/supply_packs))
    var/datum/supply_packs/ourpack = new packtype
    name = ourpack.name
    contains = ourpack.contains.Copy()
    amount = ourpack.amount
    containertype = ourpack.containertype
    containername = ourpack.containername
    access = ourpack.access
    one_access = ourpack.one_access
    worth = ourpack.cost
    qdel(ourpack)

/datum/cargo_forwarding/from_centcomm_order/New()
    ..()
    var/ordertype = pick(get_all_orders())
    var/datum/centcomm_order/ourorder = new ordertype
    worth = ourorder.worth
    containertype = ourorder.must_be_in_crate ? /obj/structure/closet/crate : /obj/structure/largecrate
    for(var/i in ourorder.requested)
        amount = ourorder.requested[i]
        if(ourorder.name_override && ourorder.name_override.len)
            name = ourorder.name_override[i]
            containername = ourorder.name_override[i]
        else
            var/atom/thing = new i
            name = thing.name
            containername = thing.name
            qdel(thing)
        if(isnum(amount))
            var/our_amount = amount
            if(istype(i,/obj/item/stack))
                our_amount = 1
            for(var/j in 1 to our_amount)
                contains += i
    //Sadly cannot use switch here
    if(istype(ordertype,/datum/centcomm_order/department/engineering))
        containertype = ourorder.must_be_in_crate ? /obj/structure/closet/crate/secure/engisec : /obj/structure/largecrate
        access = list(access_engine)
    else if(istype(ordertype,/datum/centcomm_order/department/medical))
        containertype = ourorder.must_be_in_crate ? /obj/structure/closet/crate/secure/medsec : /obj/structure/largecrate
        access = list(access_medical)
    else if(istype(ordertype,/datum/centcomm_order/department/science))
        containertype = ourorder.must_be_in_crate ? /obj/structure/closet/crate/secure/scisec : /obj/structure/largecrate
        access = list(access_science)
    qdel(ourorder)

/datum/cargo_forwarding/misc/janicart
    name = "Janicart"
    contains = list(/obj/structure/bed/chair/vehicle/janicart,/obj/item/key/janicart)
    amount = 1
    containertype = /obj/structure/largecrate
    containername = "Janicart"
    worth = 100

/datum/cargo_forwarding/misc/gokart
    name = "Go-kart"
    contains = list(/obj/structure/bed/chair/vehicle/gokart,/obj/item/key/gokart)
    amount = 1
    containertype = /obj/structure/largecrate
    containername = "Go-kart"
    worth = 200