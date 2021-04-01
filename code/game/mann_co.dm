/obj/structure/mann_co_crate
	name = "locked crate"
	desc = "There's a comically large padlock on it, with a comically large key-shaped hole"
	anchored = 0
	icon = 'icons/obj/april_fools.dmi'
	icon_state = "mannco_crate"
	var/opening = 0

/obj/structure/mann_co_crate/New()
	..()
	playsound(src, 'sound/items/mann_co_crate_spawn.ogg', 100, 1, 1)

/obj/structure/mann_co_crate/attackby(var/obj/item/weapon/W, var/mob/user)
	if (istype(W,/obj/item/mann_co_key) && !opening)
		opening = 1//preventing key spamming
		playsound(src, 'sound/items/mann_co_crate_open.ogg', 100, 1, 1)
		if(do_after(user, src, 4 SECONDS))
			open_crate(W)
			opening = 0
		else
			opening = 0

/obj/structure/mann_co_crate/proc/open_crate(var/obj/item/weapon/W)
	playsound(src, 'sound/misc/achievement.ogg', 100, 1, 1)
	var/item_type = pick(
		10;/obj/item/weapon/gun/energy/bison,
		10;/obj/item/weapon/gun/stickybomb,
		1;/obj/item/clothing/head/bteamcaptain
		)
	new item_type(get_turf(src))
	qdel(W)
	icon_state = "mannco_crate_lockless"

/obj/item/mann_co_key
	name = "golden key"
	desc = "A comically large key. These used to be highly sought after a few centuries ago."
	icon = 'icons/obj/april_fools.dmi'
	icon_state = "mannco_key"
	force = 0
