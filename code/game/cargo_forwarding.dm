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
    var/manifest = ""
    var/cargo_contribution = 0.1
    var/atom/associated_crate = null // For ease of checking

/datum/cargo_forwarding/New()
    ..()
    if (acct_by_string)
        acct = department_accounts[acct_by_string]
    else
        acct = station_account
        acct_by_string = station_name()

    if(contains.len)
        manifest += "<ul>"
        for(var/path in contains)
            if(!path)
                continue
            var/atom/movable/AM = path
            manifest += "<li>[initial(AM.name)]</li>"
        manifest += "</ul>"
    
    cargo_forwards.Add(src)

/datum/cargo_forwarding/Destroy()
    cargo_forwards.Remove(src)
    acct = null
    ..()

/datum/cargo_forwarding/proc/Pay(var/crate_tampered = FALSE)
    if(crate_tampered)
        worth *= -0.5 //Deduct a penalty instead

    acct.charge(-worth,null,"Payment for cargo crate fowarding ([name])",dest_name = name)

    if (cargo_contribution > 0 && acct_by_string != "Cargo")//cargo gets some extra coin from everything shipped
        var/datum/money_account/cargo_acct = department_accounts["Cargo"]
        cargo_acct.charge(round(-worth/10),null,"Contribution for cargo crate fowarding ([name])",dest_name = name)
    
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
    manifest = ourpack.manifest
    qdel(ourpack)

/*/datum/cargo_forwarding/from_centcomm_order/New()
    ..()
    var/ordertype = pick(get_all_orders())
    var/datum/centcomm_order/ourorder = new ordertype
    name = ourorder.name
    worth = ourorder.worth*/