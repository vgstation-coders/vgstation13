var/global/list/valid_abandoned_crate_types = typesof(/obj/structure/closet/crate/secure/loot)-/obj/structure/closet/crate/secure/loot

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "rustysecurecrate"
	icon_opened = "rustysecurecrateopen"
	icon_closed = "rustysecurecrate"
	req_access = list(access_salvage_captain)
	var/code = null
	var/lastattempt = null
	var/attempts = 3
	locked = 1
	var/min = 1
	var/max = 10

/obj/structure/closet/crate/secure/loot/New()
	var/chest_icon = pickweight(list(
						"rustysecurecrate" = 5,
						"chestsecure" = 1,
						"ayysecurecrate2" = 1,
						"plasmacrate" = 1,))
	icon_state = chest_icon
	icon_opened = chest_icon + "open"
	icon_closed = chest_icon
	..()
	code = rand(min,max)

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user as mob)
	if(locked)
		if (src.allowed(user))
			return ..()
		if (user.stat || user.incapacitated())
			return
		to_chat(user, "<span class='notice'>The crate is locked with a Deca-code lock.</span>")
		if (!user.dexterity_check())
			to_chat(user, "<span class='warning'>You don't have the dexterity to enter a keycode!</span>")
			return
		var/input = input(user, "Enter digit from [min] to [max].", "Deca-Code Lock", "") as null|num
		if(in_range(src, user))
			input = clamp(input, 0, 10)
			if (input == code)
				to_chat(user, "<span class='notice'>The crate unlocks!</span>")
				locked = 0
				attempts = initial(attempts) //in case you relock it with the salvage captain ID
				update_icon()
			else if (input == null || input > max || input < min)
				to_chat(user, "<span class='notice'>You leave the crate alone.</span>")
			else
				to_chat(user, "<span class='warning'>A red light flashes.</span>")
				lastattempt = input
				attempts--
				if (attempts == 0)
					detonate(user)
					qdel(src)
					return
		else
			to_chat(user, "<span class='notice'>You attempt to interact with the device using a hand gesture, but it appears this crate is from before the DECANECT came out.</span>")
			return
	else
		return ..()

//Handles most of an abandoned crate exploding. Does not qdel the crate due to Destroy() calling this.
/obj/structure/closet/crate/secure/loot/proc/detonate(var/mob/user)
	visible_message("<span class='red'><b>\The [src]'s anti-tampering device explodes!</b></span>", "You hear an explosion.")
	for(var/item in contents)
		qdel(item)
	var/turf/T = get_turf(src.loc)
	locked = 0 //Prevents recursive explosions
	broken = TRUE
	explosion(T, 0, 0, 1, 1, whitelist = list(src))
	//Trying to input the code directly is very dangerous!
	if(user && istype(user, /mob/living))
		var/mob/living/subject = user
		var/armor = subject.run_armor_check(attack_flag = "bomb")
		if(armor >= 100)
			return
		subject.apply_damage(20, armor)

/obj/structure/closet/crate/secure/loot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(locked)
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

/obj/structure/closet/crate/secure/loot/Destroy()
	if(locked && !broken && prob(30))
		detonate()
	..()

/obj/structure/closet/crate/secure/loot/emp_act(severity)
	if(locked && !broken && prob(30/severity))
		detonate()
		qdel(src)
		return
	..()

/obj/structure/closet/crate/secure/loot/mech_drill_act(severity)
	if(prob(30))
		detonate()
		qdel(src)
		return
	..()
