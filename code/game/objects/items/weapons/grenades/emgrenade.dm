/obj/item/weapon/grenade/empgrenade
	name = "emp grenade"
	icon_state = "emp"
	item_state = "emp"
	origin_tech = Tc_MATERIALS + "=2;" + Tc_MAGNETS + "=3"

/obj/item/weapon/grenade/empgrenade/prime()
	..()
	empulse(src, 4, 10)
	spawn(5)
		qdel(src)

