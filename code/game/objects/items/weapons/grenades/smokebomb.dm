/obj/item/weapon/grenade/smokebomb
	desc = "Generates a cloud of harmless, vision-obscuring smoke upon detonation."
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "smokebomb"
	det_time = 20
	item_state = "flashbang"
	flags = FPRINT
	slot_flags = SLOT_BELT
	var/datum/effect/system/smoke_spread/bad/smoke
	mech_flags = null

/obj/item/weapon/grenade/smokebomb/New()
	..()
	smoke = new /datum/effect/system/smoke_spread/bad
	smoke.attach(src)

/obj/item/weapon/grenade/smokebomb/Destroy()
	if(smoke)
		QDEL_NULL(smoke)
	..()

/obj/item/weapon/grenade/smokebomb/prime()
	playsound(src, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.set_up(10, 0, usr.loc)
	spawn(0)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()

	for(var/obj/effect/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.health -= damage
		B.update_icon()
	sleep(80)
	qdel(src)
