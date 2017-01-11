/obj/item/weapon/grenade/chronogrenade
	name = "chrono grenade"
	desc = "This experimental weapon will halt the progression of time in the local area for ten seconds."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "chrono_grenade"
	item_state = "flashbang"
	flags = FPRINT | TIMELESS
	var/duration = 10 SECONDS
	var/radius = 5		//in tiles

/obj/item/weapon/grenade/chronogrenade/prime()
	timestop(src, duration, radius)
	qdel(src)