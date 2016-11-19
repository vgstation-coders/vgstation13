/obj/item/weapon/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos"
	name = "syndicate minibomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=4;" + Tc_SYNDICATE + "=3"


/obj/item/weapon/grenade/syndieminibomb/prime()
	update_mob()
	explosion(src.loc,1,2,4,flash_range = 2)
	qdel(src)