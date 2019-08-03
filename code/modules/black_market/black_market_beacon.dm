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

/obj/item/device/black_market_beacon/proc/attach_to(var/atom/target, var/datum/black_market_player_item/listing)
	src.forceMove(target)
	market_listing = listing
	listing.attached_beacon = src
	black_market_beacons += src
	
/obj/item/device/black_market_beacon/proc/on_unlist()
	market_listing = null
	qdel(src) //No message, unneeded chat clutter
	
/obj/item/device/black_market_beacon/emp_act(var/severity)
	deattach()
	
/obj/item/device/black_market_beacon/proc/deattach()
	visible_message("<span class='notice'>\The [src] deactivates, melting into nothing!</span>")
	qdel(src)
	
/obj/item/device/black_market_beacon/Destroy()
	if(market_listing)
		market_listing.on_beacon_destroy()
	black_market_beacons -= src