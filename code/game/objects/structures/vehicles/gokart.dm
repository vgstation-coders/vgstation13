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
	can_have_carts = FALSE
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/gokart

/obj/structure/bed/chair/vehicle/gokart/unlock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/chair/vehicle/gokart/lock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/chair/vehicle/gokart/update_icon()
	icon_state="gokart[!occupant]"

/obj/structure/bed/chair/vehicle/gokart/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 7 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 4 * PIXEL_MULTIPLIER, "y" = 7 * PIXEL_MULTIPLIER),
		"[NORTH]" = list("x" = 0, "y" = 4 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = -4 * PIXEL_MULTIPLIER, "y" = 7 * PIXEL_MULTIPLIER)
		)

/obj/effect/decal/mecha_wreckage/vehicle/gokart
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gokart_wreck"
	name = "\improper Go-Kart wreckage"
	desc = "You don't think AAA will cover this."
