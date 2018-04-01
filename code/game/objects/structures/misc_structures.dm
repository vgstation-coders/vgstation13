/obj/structure/headpole
	name = "pole"
	icon = 'icons/obj/structures.dmi'
	icon_state = "metal_pike"
	desc = "How did this get here?"
	density = 0
	anchored = 1
	var/obj/item/weapon/spear/spear = null
	var/obj/item/organ/external/head/head = null
	var/image/display_head = null

/obj/structure/headpole/New(atom/A, var/obj/item/organ/external/head/H, var/obj/item/weapon/spear/S)
	..(A)
	if(istype(H))
		head = H
		name = "[H.name]"
		if(H.origin_body)
			desc = "The severed head of [H.origin_body.real_name], crudely shoved onto the tip of a spear."
		else
			desc = "A severed head, crudely shoved onto the tip of a spear."
		display_head = new (src)
		display_head.appearance = H.appearance
		display_head.transform = matrix()
		display_head.dir = SOUTH
		display_head.pixel_y = -3 * PIXEL_MULTIPLIER
		display_head.pixel_x = 1 * PIXEL_MULTIPLIER
		overlays += display_head.appearance
	if(S)
		spear = S
		S.forceMove(src)
		if(istype(S, /obj/item/weapon/spear/wooden))
			icon_state = "wooden_pike"
	pixel_x = rand(-12,12)
	pixel_y = rand(0,20)
	var/matrix/M = matrix()
	M.Turn(rand(-20,20))
	transform = M

/obj/structure/headpole/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/crowbar))
		to_chat(user, "You pry \the [head] off \the [spear].")
		if(head)
			head.forceMove(get_turf(src))
			head = null
		if(spear)
			spear.forceMove(get_turf(src))
			spear = null
		else
			new /obj/item/weapon/spear(get_turf(src))
		qdel(src)

/obj/structure/headpole/Destroy()
	if(head)
		qdel(head)
		head = null
	if(spear)
		qdel(spear)
		spear = null
	if(display_head)
		qdel(display_head)
		display_head = null
	..()

/obj/structure/headpole/with_head/New(atom/A)
	var/obj/item/organ/external/head/H = new (src)
	H.name = "severed head"
	spear = new (src)
	..(A, H)