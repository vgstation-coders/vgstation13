/obj/structure/mann_co_crate
	name = "locked crate"
	desc = "There's a comically large padlock on it, with a comically large key-shaped hole."
	anchored = 0
	density = 1
	icon = 'icons/obj/april_fools.dmi'
	icon_state = "mannco_crate"
	var/opening = 0
	var/looted = 0

/obj/structure/mann_co_crate/New()
	..()
	playsound(src, 'sound/items/mann_co_crate_spawn.ogg', 100, 1, 1)
	flick("mannco_crate_spawn", src)

/obj/structure/mann_co_crate/attackby(var/obj/item/weapon/W, var/mob/user)
	if (looted)
		to_chat("<span class='warning'>This crate has already been looted!</span>")
		return
	if (istype(W,/obj/item/mann_co_key) && !opening)
		opening = 1//preventing key spamming
		playsound(src, 'sound/items/mann_co_crate_open.ogg', 100, 0, 1)
		icon_state = "mannco_crate_lockless"
		if(do_after(user, src, 5 SECONDS))
			open_crate(W)
			opening = 0
			icon_state = "mannco_crate_open"
		else
			opening = 0
			icon_state = "mannco_crate"

/obj/structure/mann_co_crate/proc/open_crate(var/obj/item/weapon/W)
	looted = 1
	playsound(src, 'sound/misc/achievement.ogg', 100, 0, 1)
	var/item_type = pick(
		10;/obj/item/weapon/gun/energy/bison,
		10;/obj/item/weapon/gun/stickybomb,
		1;/obj/item/clothing/head/bteamcaptain
		)
	new item_type(get_turf(src))
	qdel(W)

/obj/item/mann_co_key
	name = "golden key"
	desc = "A comically large key. These used to be highly sought after a few centuries ago."
	icon = 'icons/obj/april_fools.dmi'
	icon_state = "mannco_key"
	force = 0
