#define NEEDED_CHARGE_TO_RESTOCK_IMP 30

//Warden upgrade's implanter
/obj/item/weapon/implanter/cyborg
	name = "cyborg implanter"
	desc = "Can be refilled with a loyalty implant in about sixty seconds at any cyborg recharging station."
	implant_path = /obj/item/weapon/implant/loyalty
	var/charge = 0

/obj/item/weapon/implanter/cyborg/update_icon()
	..()
	name = "[initial(name)][held_implant ? " - [held_implant.name]" : ""]"

/obj/item/weapon/implanter/cyborg/restock()
	charge++
	if(charge >= NEEDED_CHARGE_TO_RESTOCK_IMP && !held_implant) //takes about 60 seconds.
		if(implant_path)
			held_implant = new implant_path(src)
			update_icon()
			charge = initial(charge)

#undef NEEDED_CHARGE_TO_RESTOCK_IMP