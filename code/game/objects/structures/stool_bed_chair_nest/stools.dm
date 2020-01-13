/obj/item/weapon/stool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/stools-chairs-beds.dmi'
	icon_state = "stool"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	force = 10
	throwforce = 10
	w_class = W_CLASS_HUGE
	sheet_type = /obj/item/stack/sheet/metal

/obj/item/weapon/stool/bar
	name = "bar stool"
	desc = "Apply butt. Get drunk."
	icon_state = "bar-stool"

/obj/item/weapon/stool/hologram
	sheet_type = null

/obj/item/weapon/stool/piano
	name = "piano stool"
	desc = "Apply butt. Become Mozart."
	icon_state = "stool_piano"
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3
	sheet_type = /obj/item/stack/sheet/wood

/obj/item/weapon/stool/piano/initialize()
	..()
	handle_layer()

//So they don't get picked up.
/obj/item/weapon/stool/piano/attack_hand()
	return

/obj/item/weapon/stool/attackby(var/obj/item/weapon/W, var/mob/user)
	if(W.is_wrench(user) && sheet_type)
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		drop_stack(sheet_type, loc, 1, user)
		qdel(src)

	. = ..()

/obj/item/weapon/stool/cultify()
	var/obj/structure/bed/chair/wood/wings/I = new /obj/structure/bed/chair/wood/wings(loc)
	I.dir = dir
	. = ..()

/obj/item/weapon/stool/attack(mob/M as mob, mob/user as mob)
	if(prob(5) && istype(M, /mob/living) && sheet_type)
		user.visible_message("<span class='warning'>[user] breaks \the [src] over [M]'s back!.</span>")
		user.u_equip(src, 0)

		getFromPool(sheet_type, get_turf(src), 1)
		qdel(src)

		var/mob/living/T = M
		T.Knockdown(10)
		T.Stun(10)
		T.apply_damage(20)
		return

	. = ..()

/obj/item/weapon/stool/piano/update_dir()
	..()

	handle_layer()

/obj/item/weapon/stool/piano/proc/handle_layer()
	if(dir == NORTH)
		plane = ABOVE_HUMAN_PLANE
	else
		plane = OBJ_PLANE

