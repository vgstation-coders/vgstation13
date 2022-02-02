/datum/subsystem/supply_shuttle
    var/list/datum/cargo_forwarding/cargo_forwards = list()
    var/forwarding_on = FALSE

/datum/cargo_forwarding
    var/name = ""
    var/datum/money_account/acct // account we pay to
    var/acct_by_string = ""
    var/list/contains = list()
    var/amount = 1
    var/containertype = null
    var/containername = ""
    var/access = null // See code/game/jobs/access.dm
    var/one_access = null // See above
    var/worth = 0 // Payed out for forwarding
    var/cargo_contribution = 0.1
    var/atom/associated_crate = null // For ease of checking
    var/obj/item/weapon/paper/manifest/associated_manifest = null // Same here
    var/origin_station_name = "" // Some fluff
    var/origin_sender_name = ""
    var/time_limit = 5 // In minutes
    var/time_created = 0 // To check time left
    var/weighed = FALSE // Crate weighed?
    var/list/atom/initial_contents = list() // for easier atom checking

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

    time_created = world.time
    time_limit = rand(7,17) //2 minutes is spent transiting it and it gets created at the start of that, so really 5-15

    var/list/player_names = list()
    for(var/mob/M in player_list)
        player_names += M.name
    do // Same as station check, but with names
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
    while(origin_sender_name in player_names)

    SSsupply_shuttle.cargo_forwards.Add(src)

    spawn(time_limit MINUTES) //Still an order after the time limit?
        if(src)
            Pay("Time ran out")

/datum/cargo_forwarding/Destroy()
    SSsupply_shuttle.cargo_forwards.Remove(src)
    acct = null
    ..()

/datum/cargo_forwarding/proc/Pay(var/reason) //Reason for crate denial
    if(reason)
        worth *= -0.5 //Deduct a penalty instead

    acct.charge(-worth,null,"Payment for cargo crate fowarding ([name])",dest_name = name)

    if (cargo_contribution > 0 && acct_by_string != "Cargo")//cargo gets some extra coin from everything shipped
        var/datum/money_account/cargo_acct = department_accounts["Cargo"]
        cargo_acct.charge(round(-worth/10),null,"Contribution for cargo crate fowarding ([name])",dest_name = name)
    
    for(var/obj/machinery/computer/supplycomp/S in SSsupply_shuttle.supply_consoles)
        S.say("[name] forwarded [reason ? "unsuccessfully! [reason]. Reward docked." : "successfully!"]")
        playsound(S, 'sound/machines/info.ogg', 50, 1)
    
    qdel(src)

/datum/cargo_forwarding/proc/post_creation() //Called after crate spawns in shuttle
    return

/obj/machinery/crate_weigher
    name = "crate weigher"
    desc = "Weighs crates, and adds relevant info to a shipping manifest."
    icon = 'icons/obj/machines/crate_weigher.dmi'
    icon_state = "up"
    layer = OPEN_DOOR_LAYER // Below the crates
    anchored = 0
    density = 0
    use_power = 1
    idle_power_usage = 0
    active_power_usage = 50
    power_channel = EQUIP
    machine_flags = 0
    ghost_read = 0 // Deactivate ghost touching.
    ghost_write = 0
    var/obj/item/weapon/paper/manifest/current_manifest = null
    var/next_sound = 0
    var/sound_delay = 20

/obj/machinery/crate_weigher/attackby(var/obj/item/W, mob/user)
    if(istype(W,/obj/item/weapon/paper/manifest) && !current_manifest)
        if (!user.drop_item(W, src))
            return
        current_manifest = W
        to_chat(user,"<span class='notice'>You add \the [W] to \the [src]</span>")
    else
        return ..()

/obj/machinery/crate_weigher/attack_hand(mob/user)
    if(..())
        return
    if(current_manifest)
        to_chat(user,"<span class='notice'>You remove \the [current_manifest] from \the [src]</span>")
        current_manifest.forceMove(get_turf(src))
        current_manifest = null

/obj/machinery/crate_weigher/Crossed(atom/movable/A)
    if(istype(A,/obj/structure)) //Ideally crate types stay these
        icon_state = "down"
        if (world.time > next_sound)
            playsound(get_turf(src), 'sound/effects/spring.ogg', 60, 1)
            next_sound = world.time + sound_delay
        sleep(10)
        if(current_manifest && get_turf(A) == get_turf(src))
            var/calculated_weight = 0
            for(var/atom/movable/thing in A)
                if(isitem(A))
                    var/obj/item/I = A
                    calculated_weight += I.w_class
                else if(ismob(A))
                    var/mob/M = A
                    calculated_weight += M.size
                else
                    calculated_weight += 5
            playsound(get_turf(src), 'sound/machines/chime.ogg', 50, 1)
            visible_message("<span class='notice'>\the [src] prints out the weighed [current_manifest]</span>")
            current_manifest.info += "<br>Total object weight: [calculated_weight]kg<br>CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"
            current_manifest.forceMove(get_turf(src))
            current_manifest = null
            for(var/datum/cargo_forwarding/CF in SSsupply_shuttle.cargo_forwards)
                if(A == CF.associated_crate)
                    CF.weighed = TRUE

/obj/machinery/crate_weigher/Uncrossed(atom/movable/A)
    if(istype(A,/obj/structure)) //Ideally crate types stay these
        icon_state = "up"
        if (world.time > next_sound)
            playsound(get_turf(src), 'sound/effects/spring.ogg', 60, 1)
            next_sound = world.time + sound_delay

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
    var/ordertype = get_weighted_order()
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

/datum/cargo_forwarding/misc/random_mob
    name = "Unknown creature"
    contains = list()
    amount = 1
    containertype = /obj/structure/cage/random_mob
    containername = "cage"
    worth = 50

/datum/cargo_forwarding/misc/random_mob/post_creation()
    if(istype(associated_crate,/obj/structure/cage/random_mob))
        var/obj/structure/cage/random_mob/RM = associated_crate
        for(var/mob/living/simple_animal/SM in RM)
            name = SM.name
            containername = SM.name
            worth = (SM.size * SM.size) * 10