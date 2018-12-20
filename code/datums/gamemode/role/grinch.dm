/datum/role/grinch
	name = GRINCH
	id = GRINCH
	required_pref = ROLE_GRINCH
	logo_state = "synd-logo"

    // -- Our bag
    var/obj/obj/item/weapon/storage/backpack/holding/grinch/our_bag = null

// -- Transforms us into the devlish Grinch
/datum/role/grinch/OnPostSetup()
    var/mob/old_mob = antag.current
    var/mob/living/simple_animal/hostile/gremlin/grinch/G = new
    G.forceMove(pick(grinchstart))
    antag.current.transfer_to(G)
    var/obj/obj/item/weapon/storage/backpack/holding/grinch/our_bag = new(G)
    src.our_bag = our_bag
    G.setBackpack(our_bag)
    qdel(old_mob)

// -- Clearing references in case of deletion.
/datum/role/grinch/Destroy()
    our_bag.our_grinch = null
    our_bag = null
    return ..()

/datum/role/grinch/Greet(var/greeting,var/custom)
    if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are the Grinch!</span><span class='warning'>You are here to ruin Christmas!</span>")
	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki)</span>")

/datum/role/grinch/ForgeObjectives()
    AppendObjective(/datum/objective/freeform/ruin_christmas)

// -- Scoreboard : how many items did we have in our backpack

/datum/role/grinch/GetScoreboard()
    var/bounty = 0
    . = ..()
    if (!our_bag)
        . += "<br/>"
        . += "The Grinch's bag has been destroyed!"
    else
        . += "<br/>"
        for (var/obj/item/I in get_contents_in_object(our_bag))
            bounty += shop_prices[I.type]
        . += "The Grinch managed to steal $[bounty] worth of items!"
