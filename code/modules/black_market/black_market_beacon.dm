var/list/black_market_beacons = list()

/obj/item/device/black_market_beacon
	name = "black market beacon"
	desc = "You're really not sure how you managed to grab one of these without it melting."
	icon = 'icons/obj/device.dmi'
	icon_state = "implant_evil"
	w_class = W_CLASS_TINY
	item_state = ""
	throw_speed = 4
	throw_range = 20
	var/datum/black_market_player_item/market_listing
	var/atom/attached_item

/obj/item/device/black_market_beacon/proc/attach_to(var/atom/target, var/datum/black_market_player_item/listing)
	src.forceMove(target)
	attached_item = target
	market_listing = listing
	listing.attached_beacon = src
	black_market_beacons += src
	
/obj/item/device/black_market_beacon/proc/on_unlist()
	market_listing = null
	qdel(src) //No message, unneeded chat clutter
	
/obj/item/device/black_market_beacon/emp_act(var/severity)
	visible_message("<span class='notice'>\The [src] deactivates, melting into nothing!</span>")
	qdel(src)
	
/obj/item/device/black_market_beacon/Destroy()
	if(market_listing)
		market_listing.on_beacon_destroy()
	black_market_beacons -= src
	if(attached_item)
		attached_item.contents -= src
	
/proc/black_market_beacon_check(var/atom/target, var/mob/user)
	var/obj/item/device/black_market_beacon/beacon = locate() in target
	if(beacon)
		to_chat(user, "<span class='notice'>Upon closer inspection, you notice a tiny sapphire beacon. It matches the model used by the Black Market to track goods.</span>")