/obj/structure/bed/chair/vehicle/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	keytype = /obj/item/key/security
	can_have_carts = FALSE
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/secway
	var/clumsy_check = 1

/obj/item/key/security
	name = "secway key"
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"

/obj/structure/bed/chair/vehicle/secway/set_keys() //doesn't spawn with keys, mapped in

/obj/structure/bed/chair/vehicle/secway/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 3 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 2 * PIXEL_MULTIPLIER, "y" = 3 * PIXEL_MULTIPLIER),
		"[NORTH]" = list("x" = 0, "y" = 3 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = -2 * PIXEL_MULTIPLIER, "y" = 3 * PIXEL_MULTIPLIER)
		)

/obj/structure/bed/chair/vehicle/secway/handle_layer()
	if(dir == WEST || dir == EAST || dir == SOUTH)
		layer = VEHICLE_LAYER
		plane = ABOVE_HUMAN_PLANE
	else
		layer = OBJ_LAYER
		plane = OBJ_PLANE


/obj/structure/bed/chair/vehicle/secway/to_bump(var/atom/obstacle)
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
	playsound(src, "sound/effects/meteorimpact.ogg", 25, 1)
	occupant.visible_message("<span class='danger'>[occupant] crashes into \the [obstacle]!</span>", "<span class='danger'>You crash into \the [obstacle]!</span>")

	if(istype(obstacle, /mob/living))
		var/mob/living/idiot = obstacle
		idiot.Knockdown(2)
		idiot.Stun(2)

/obj/effect/decal/mecha_wreckage/vehicle/secway
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gokart_wreck"
	name = "secway wreckage"
	desc = "Nothing to see here!"
