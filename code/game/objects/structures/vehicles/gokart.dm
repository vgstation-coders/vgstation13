/obj/item/key/gokart
	name = "\improper Go-Kart key"
	desc = "A keyring with a small steel key, with a picture of Saint Mario as a fob."
	icon_state = "gokart_keys"

/obj/structure/bed/chair/vehicle/gokart
	name = "\improper Go-Kart"
	desc = "Tiny car for tiny people."
	icon_state = "gokart0"
	//nick = "TRUE POWER"
	keytype = /obj/item/key/gokart
	noghostspin = 0

/obj/structure/bed/chair/vehicle/gokart/unlock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/chair/vehicle/gokart/lock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/chair/vehicle/gokart/update_icon()
	icon_state="gokart[!occupant]"

/obj/structure/bed/chair/vehicle/gokart/update_mob()
	if(!occupant)
		return

	switch(dir)
		if(SOUTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 7 * PIXEL_MULTIPLIER
		if(WEST)
			occupant.pixel_x = 4 * PIXEL_MULTIPLIER
			occupant.pixel_y = 7 * PIXEL_MULTIPLIER
		if(NORTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 4 * PIXEL_MULTIPLIER
		if(EAST)
			occupant.pixel_x = -4 * PIXEL_MULTIPLIER
			occupant.pixel_y = 7 * PIXEL_MULTIPLIER
