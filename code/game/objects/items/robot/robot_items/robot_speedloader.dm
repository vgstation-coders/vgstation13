#define NEEDED_CHARGE_TO_RESTOCK_AMMO 5

//Noir upgrade's speedloader
/obj/item/ammo_storage/speedloader/c38/cyborg
	desc = "The echo of the first shot, like the first sip of whiskey, burning..."
	var/charge = 0

/obj/item/ammo_storage/speedloader/c38/cyborg/restock()
	charge++
	if(charge >= NEEDED_CHARGE_TO_RESTOCK_AMMO && stored_ammo.len < max_ammo) //takes about 10 seconds.
		stored_ammo += new ammo_type(src)
		playsound(src, 'sound/machines/info.ogg',20)
		update_icon()
		charge = initial(charge)

#undef NEEDED_CHARGE_TO_RESTOCK_AMMO