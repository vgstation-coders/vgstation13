var/list/grey_market_beacons = list()

/obj/item/device/grey_market_beacon
	name = "grey market beacon"
	desc = "You're really not sure how you managed to grab one of these without it melting."
	icon = 'icons/obj/device.dmi'
	icon_state = "implant_evil"
	w_class = W_CLASS_TINY
	item_state = ""
	throw_speed = 4
	throw_range = 20
	var/datum/grey_market_player_item/market_listing
	var/atom/attached_item

/obj/item/device/grey_market_beacon/proc/attach_to(var/atom/target, var/datum/grey_market_player_item/listing)
	src.forceMove(target)
	if(!target.market_beacon)
		target.market_beacon = src
	attached_item = target
	market_listing = listing
	listing.attached_beacon = src
	grey_market_beacons += src
	
/obj/item/device/grey_market_beacon/proc/on_unlist()
	market_listing = null
	qdel(src)
	
/obj/item/device/grey_market_beacon/emp_act(var/severity)
	visible_message("<span class='notice'>\The [src] deactivates, melting into nothing!</span>")
	qdel(src)
	
/obj/item/device/grey_market_beacon/Destroy()
	if(market_listing)
		market_listing.on_beacon_destroy()
	if(attached_item)
		attached_item.market_beacon = null
	grey_market_beacons -= src
	return ..()
	
	
/proc/grey_market_beacon_check(var/atom/target, var/mob/user)
	if(target.market_beacon)
		to_chat(user, "<span class='notice'>Upon closer inspection, you notice a tiny sapphire beacon. It matches the model used by the Grey Market to track goods.</span>")