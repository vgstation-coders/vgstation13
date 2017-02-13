/obj/structure/bed/chair/vehicle/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	keytype = /obj/item/key/security
	can_have_carts = FALSE
	var/clumsy_check = 1

/obj/item/key/security
	name = "secway key"
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"

/obj/structure/bed/chair/vehicle/secway/check_key(var/mob/user)
	return user.find_held_item_by_type(keytype) //any secway key works with any other secway

/obj/structure/bed/chair/vehicle/secway/set_keys() //doesn't spawn with keys, mapped in

/obj/structure/bed/chair/vehicle/secway/update_mob()
	if(!occupant)
		return

	switch(dir)
		if(SOUTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 3
		if(WEST)
			occupant.pixel_x = 2
			occupant.pixel_y = 3
		if(NORTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 3
		if(EAST)
			occupant.pixel_x = -2
			occupant.pixel_y = 3


/obj/structure/bed/chair/vehicle/secway/handle_layer()
	if(dir == WEST || dir == EAST || dir == SOUTH)
		layer = VEHICLE_LAYER
		plane = ABOVE_HUMAN_PLANE
	else
		layer = OBJ_LAYER
		plane = OBJ_PLANE


/obj/structure/bed/chair/vehicle/secway/Bump(var/atom/obstacle)
	..()

	if(!occupant)
		return

	if(clumsy_check)
		if(istype(occupant, /mob/living))
			var/mob/living/M = occupant
			if(!clumsy_check(M) && M.dizziness < 450)
				return
	occupant.Knockdown(2)
	occupant.Stun(2)
	playsound(get_turf(src), "sound/effects/meteorimpact.ogg", 25, 1)
	occupant.visible_message("<span class='danger'>[occupant] crashes into \the [obstacle]!</span>", "<span class='danger'>You crash into \the [obstacle]!</span>")

	if(istype(obstacle, /mob/living))
		var/mob/living/idiot = obstacle
		idiot.Knockdown(2)
		idiot.Stun(2)
