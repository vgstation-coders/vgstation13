/obj/item/key/segway
	name = "Segway key"
	desc = "A rubber keyring."
	icon_state = "segway_key"

/obj/structure/stool/bed/chair/vehicle/segway
	name = "Segway"
	desc = "An electric people transporter, used commonly by obese NanoTrasen security officers. This one has Paul Blart, legendary mall cop engraved on it."
	icon_state = "segway"
	//nick = "TRUE POWER"
	keytype = /obj/item/key/segway

/obj/structure/stool/bed/chair/vehicle/segway/buckle_mob(mob/M, mob/user)
	..(M,user)
	update_icon()

/obj/structure/stool/bed/chair/vehicle/segway/unbuckle()
	..()
	update_icon()

/obj/structure/stool/bed/chair/vehicle/segway/update_icon()
	icon_state="segway"

/obj/structure/stool/bed/chair/vehicle/segway/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 0
			if(WEST)
				buckled_mob.pixel_x = 9
				buckled_mob.pixel_y = 10
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 0
			if(EAST)
				buckled_mob.pixel_x = -10
				buckled_mob.pixel_y = 10