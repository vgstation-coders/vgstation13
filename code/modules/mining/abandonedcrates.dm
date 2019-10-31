var/global/list/valid_abandoned_crate_types = typesof(/obj/structure/closet/crate/secure/loot)-/obj/structure/closet/crate/secure/loot

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/code = null
	var/lastattempt = null
	var/attempts = 3
	locked = 1
	var/min = 1
	var/max = 10

/obj/structure/closet/crate/secure/loot/New()
	..()
	code = rand(min,max)

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user as mob)
	if(locked)
		to_chat(user, "<span class='notice'>The crate is locked with a Deca-code lock.</span>")
		var/input = input(usr, "Enter digit from [min] to [max].", "Deca-Code Lock", "") as num
		if(in_range(src, user))
			input = clamp(input, 0, 10)
			if (input == code)
				to_chat(user, "<span class='notice'>The crate unlocks!</span>")
				locked = 0
			else if (input == null || input > max || input < min)
				to_chat(user, "<span class='notice'>You leave the crate alone.</span>")
			else
				to_chat(user, "<span class='warning'>A red light flashes.</span>")
				lastattempt = input
				attempts--
				if (attempts == 0)
					to_chat(user, "<span class='danger'>The crate's anti-tamper system activates!</span>")
					var/turf/T = get_turf(src.loc)
					explosion(T, 0, 0, 0, 1)
					for(var/item in contents)
						qdel(item)
					qdel(src)
					return
		else
			to_chat(user, "<span class='notice'>You attempt to interact with the device using a hand gesture, but it appears this crate is from before the DECANECT came out.</span>")
			return
	else
		return ..()

/obj/structure/closet/crate/secure/loot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(locked)
		if (istype(W, /obj/item/weapon/card/emag))
			to_chat(user, "<span class='notice'>The crate unlocks!</span>")
			locked = 0
		if (istype(W, /obj/item/device/multitool))
			to_chat(user, "<span class='notice'>DECA-CODE LOCK REPORT:</span>")
			if (attempts == 1)
				to_chat(user, "<span class='warning'>* Anti-Tamper Bomb will activate on next failed access attempt.</span>")
			else
				to_chat(user, "<span class='notice'>* Anti-Tamper Bomb will activate after [src.attempts] failed access attempts.</span>")
			if (lastattempt == null)
				to_chat(user, "<span class='notice'> has been made to open the crate thus far.</span>")
				return
			// hot and cold
			if (code > lastattempt)
				to_chat(user, "<span class='notice'>* Last access attempt lower than expected code.</span>")
			else
				to_chat(user, "<span class='notice'>* Last access attempt higher than expected code.</span>")
		else
			..()
	else
		..()
