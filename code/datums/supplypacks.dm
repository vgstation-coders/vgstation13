//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been emagged.
//ANOTER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

var/list/all_supply_groups = list("Supplies","Clothing","Security","Hospitality","Engineering","Cargo","Medical","Science","Hydroponics","Vending Machine packs")

/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/list/selection_from = list()//list of lists, system picks one & adds contents to container on creation
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/containertype = null
	var/containername = null
	var/access = null // See code/game/jobs/access.dm
	var/one_access = null // See above
	var/hidden = 0 //Emaggable
	var/contraband = 0 //Hackable via tools
	var/group = "Supplies"
	var/require_holiday = null
	var/containsicon = null // An object whose icon will be shown in the cargo computers
	var/containsdesc = "No description of the contents is available." // Description of the pack for the cargo computers

/datum/supply_packs/New()
	if(!containsicon)
		containsicon = bicon(pick(contains))
	else if (ispath(containsicon))
		containsicon = bicon(containsicon)
	else
		containsicon = bicon(icon('icons/misc/cargo_icons_override.dmi',containsicon))
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)
			continue
		var/atom/movable/AM = path
		manifest += "<li>[initial(AM.name)]</li>"
	manifest += "</ul>"

// Called after a crate containing the items specified by this datum is created
/datum/supply_packs/proc/post_creation(var/atom/movable/container)
	return

/datum/supply_packs/proc/OnConfirmed(var/mob/user)
	return // Blank proc

/datum/supply_packs/randomised
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/kitty/collectable,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/HoS,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat,)
	name = "Collectable hats!"
	cost = 200
	containertype = /obj/structure/closet/crate/basic
	containername = "collectable hat crate"
	containsicon = null
	containsdesc = "A random assortment of highly collectable hats! Always contains exactly three random hats."
	group = "Clothing"

/datum/supply_packs/randomised/New()
	manifest += "Contains any [num_contained] of:"
	..()
