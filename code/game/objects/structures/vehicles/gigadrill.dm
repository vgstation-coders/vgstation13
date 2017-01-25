/obj/item/key/gigadrill
	name = "gigadrill key"
	desc = "A dusty and old key."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/gigadrill
	name = "gigadrill"
	icon_state = "gigadrill"
 	keytype = /obj/item/key/gigadrill

/obj/structure/bed/chair/vehicle/gigadrill/buckle_mob(mob/M, mob/user)
  ..()
  update_icon()

/obj/structure/bed/chair/vehicle/gigadrill/update_icon()
  if(occupant)
    icon_state = "gigadrill_mov"
  else
    icon_state = "gigadrill"
