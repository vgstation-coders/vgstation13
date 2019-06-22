/obj/item/weapon/grenade/syndigrenade
	name = "C28E pipe bomb"
	desc = "A syndicate pipe bomb with a nitroglycerin charge. Simple, efficient, explosive."
	icon_state = "syndicate"
	item_state = "syndicate"
	origin_tech = Tc_SYNDICATE + "=2" + Tc_COMBAT + "=3"

/obj/item/weapon/grenade/syndigrenade/prime()
	..()
	explosion(loc, 0, 2, 4, 6) //Explosive grenades pack a decent punch and are perfectly capable of breaking the hull, so beware
	spawn()
		qdel(src)

/obj/item/weapon/grenade/syndigrenade/ex_act(severity)
	switch(severity)
		if(1)
			prime()
		if(2)
			if(prob(80))
				prime()
		if(3)
			if(prob(50))
				prime()
