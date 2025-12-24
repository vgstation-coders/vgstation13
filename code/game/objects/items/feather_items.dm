//Alot of stuff from alot of places. Color inheritance is handled in stack_recipes.dm

//Clothing
/obj/item/clothing/suit/feathercoat
	name = "feather coat"
	desc = "A coat made from locally-sourced feathers."
	icon_state = "feathercoat"
	item_state = "feathercoat"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	body_parts_covered = FULL_TORSO|ARMS
	species_fit = list(VOX_SHAPED)
	clothing_flags = COLORS_OVERLAY | ONESIZEFITSALL

/obj/item/clothing/suit/feathervest
	name = "feather vest"
	desc = "A vest made from locally-sourced feathers."
	icon_state = "feathervest"
	item_state = "feathervest"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	body_parts_covered = FULL_TORSO|ARMS
	species_fit = list(VOX_SHAPED)
	clothing_flags = COLORS_OVERLAY

/obj/item/clothing/head/headdress
	name = "feather headdress"
	desc = "A ceremonial headdress adorned with colorful feathers."
	icon_state = "headdress"
	item_state = "headdress"
	w_class = W_CLASS_TINY
	body_parts_covered = HEAD | UPPER_TORSO
	species_fit = list(VOX_SHAPED)
	clothing_flags = COLORS_OVERLAY

//Decorations
/obj/item/mounted/frame/wreath/featherwreath
	name = "feather wreath"
	desc = "A decorative wreath made of locally-sourced feathers."
	icon = 'icons/obj/christmas.dmi'
	icon_state = "wreath_feather"
	w_type = RECYK_BIOLOGICAL

/obj/structure/wreath/featherwreath
	name = "feather wreath"
	desc = "A decorative wreath made of locally-sourced feathers."
	icon = 'icons/obj/christmas.dmi'
	icon_state = "wreath_feather"

/obj/structure/wreath/featherwreath/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		to_chat(user, "You begin prying \the [src] off the wall.")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src,10))
			to_chat(user, "<span class='notice'>You pry \the [src] off of the wall.</span>")
			var/obj/item/mounted/frame/wreath/featherwreath/F = new /obj/item/mounted/frame/wreath/featherwreath(get_turf(user))
			F.color = src.color
			F.name = src.name
			qdel(src)
		return
	return ..()

/obj/item/mounted/frame/wreath/featherwreath/do_build(turf/on_wall, mob/user)
	var/obj/structure/wreath/featherwreath/W = new /obj/structure/wreath/featherwreath(get_turf(src), get_dir(on_wall, user), 1)
	W.color = src.color
	W.name = src.name
	qdel(src)

/obj/item/mounted/frame/wreath/dreamcatcher
	name = "dreamcatcher"
	desc = "A decorative dreamcatcher made of locally-sourced feathers."
	icon = 'icons/obj/christmas.dmi'
	icon_state = "dreamcatcher"
	w_type = RECYK_BIOLOGICAL

/obj/structure/wreath/dreamcatcher
	name = "dreamcatcher"
	desc = "A decorative dreamcatcher made of locally-sourced feathers."
	icon = 'icons/obj/christmas.dmi'
	icon_state = "dreamcatcher"

/obj/structure/wreath/dreamcatcher/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		to_chat(user, "You begin prying \the [src] off the wall.")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src,10))
			to_chat(user, "<span class='notice'>You pry \the [src] off of the wall.</span>")
			var/obj/item/mounted/frame/wreath/dreamcatcher/F = new /obj/item/mounted/frame/wreath/dreamcatcher(get_turf(user))
			F.color = src.color
			F.name = src.name
			qdel(src)
		return
	return ..()

/obj/item/mounted/frame/wreath/dreamcatcher/do_build(turf/on_wall, mob/user)
	var/obj/structure/wreath/dreamcatcher/W = new /obj/structure/wreath/dreamcatcher(get_turf(src), get_dir(on_wall, user), 1)
	W.color = src.color
	W.name = src.name
	qdel(src)

//Tools & Miscellaneous
/obj/item/weapon/pillow
	name = "pillow"
	desc = "A handmade pillow, perfect for resting your head."
	icon = 'icons/obj/items.dmi'
	icon_state = "pillow"
	item_state = "pillow"

/obj/item/weapon/featherduster
	name = "feather duster"
	desc = "A fluffy duster made from colored feathers. Only good for light cleaning."
	icon = 'icons/obj/items.dmi'
	icon_state = "featherduster"
	item_state = "featherduster"
	w_class = W_CLASS_TINY

/obj/item/weapon/featherduster/proc/clean(turf/simulated/A as turf)
	for(var/obj/effect/O in A)
		if(iscleanaway(O))
			qdel(O)
	playsound(src, get_sfx("mop"), 25, 1)

/obj/item/weapon/featherduster/afterattack(atom/A, mob/user as mob)
	if(!user.Adjacent(A))
		return
	if(istype(A, /turf/simulated) || iscleanaway(A))
		user.visible_message("<span class='notice'>[user] dusts \the [get_turf(A)] with the feather duster.</span>", "<span class='notice'>You dust \the [get_turf(A)].</span>")
		user.delayNextAttack(5)
		clean(get_turf(A))
		return

/obj/item/weapon/pen/quill
	name = "quill"
	desc = "A writing instrument made from a colored feather."
	icon = 'icons/obj/items.dmi'
	icon_state = "quill"
	item_state = "pen"
	w_class = W_CLASS_TINY
