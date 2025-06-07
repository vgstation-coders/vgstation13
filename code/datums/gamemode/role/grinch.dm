/datum/role/grinch
	name = GRINCH
	id = GRINCH
	required_pref = GRINCH
	logo_state = "grinch-logo"
	disallow_job = TRUE
	default_admin_voice = "Santa Claus"
	admin_voice_style = "danger"

	// -- Our bag
	var/obj/item/weapon/storage/backpack/santabag/grinch/our_bag = null

/datum/role/grinch/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id)
	..()
	wikiroute = role_wiki[GRINCH]

// -- Transforms us into the devlish Grinch
/datum/role/grinch/OnPostSetup(var/laterole = FALSE)
	. = ..()
	our_bag = new(antag.current)
	antag.current.equip_to_slot(our_bag, slot_back)

// -- Clearing references in case of deletion.
/datum/role/grinch/Destroy()
	our_bag = null
	return ..()

/datum/role/grinch/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are the Grinch!</span> <span class='warning'>You are here to ruin Christmas! Your bag can hold a ludicrous amount of items. You can crawl through vents and mess with electronic panels and computers, but your pitiful punches don't deal any damage.</span>")
	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki)</span>")

/datum/role/grinch/ForgeObjectives()
	AppendObjective(/datum/objective/freeform/christmas)

// -- Scoreboard : how many items did we have in our backpack

/datum/role/grinch/GetScoreboard()
	var/bounty = 0
	. = ..()
	if (!our_bag)
		. += "<br/>"
		. += "The Grinch's bag has been destroyed!<br/>"
	else
		. += "<br/>"
		for (var/obj/item/I in get_contents_in_object(our_bag))
			bounty += shop_prices[I.type]
		. += "The Grinch managed to steal $[bounty] worth of items!<br/>"
