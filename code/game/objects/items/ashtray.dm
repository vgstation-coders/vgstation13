/obj/item/ashtray
	icon = 'icons/ashtray.dmi'
	w_class = W_CLASS_TINY

	var/max_butts 	= 0
	var/empty_desc 	= ""
	var/icon_empty 	= ""
	var/icon_half  	= ""
	var/icon_full  	= ""
	var/icon_broken	= ""

/obj/item/ashtray/New()
	..()
	pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER
	pixel_x = rand(-6, 6) * PIXEL_MULTIPLIER

/obj/item/ashtray/attackby(obj/item/weapon/W, mob/user)
	if (health < 1)
		return
	if (istype(W,/obj/item/clothing/mask/cigarette) || istype(W, /obj/item/weapon/match) || istype(W, /obj/item/trash/cigbutt))
		if(!user)
			return
		if (contents.len >= max_butts)
			to_chat(user, "<span class='warning'>This ashtray is full.</span>")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return
		var/obj/item/clothing/mask/cigarette/cig = W
		if(istype(cig, /obj/item/trash/cigbutt))
			to_chat(user, "<span class='notice'>You drop the [cig] into [src].</span>")
		if (istype(W,/obj/item/clothing/mask/cigarette) || istype(W, /obj/item/weapon/match))
			if (cig.lit == 1)
				visible_message("<span class='notice'>[user] crushes [cig] in [src], putting it out.</span>")
			else if (cig.lit == 0)
				to_chat(user, "<span class='notice'>You place [cig] in [src] without even lighting it. Why would you do that?</span>")
			else if (cig.lit == -1)
				visible_message("<span class='notice'>[user] places [cig] in [src].</span>")
		add_fingerprint(user)
		if (contents.len == max_butts)
			icon_state = icon_full
			desc = empty_desc + " It's stuffed full."
		else if (contents.len > max_butts/2)
			icon_state = icon_half
			desc = empty_desc + " It's half-filled."
		return
	health = max(0,health - W.force)
	to_chat(user, "<span class='danger'>You hit [src] with [W].</span>")
	if (health < 1)
		die()

/obj/item/ashtray/throw_impact(atom/hit_atom)
	if (health > 0)
		health = max(0,health - 3)
		if (health < 1)
			die()
			return
		if (contents.len)
			visible_message("<span class='warning'>[src] slams into [hit_atom] spilling its contents!</span>")
		for (var/obj/item/O in contents)
			O.forceMove(loc)
		icon_state = icon_empty
	return ..()

/obj/item/ashtray/proc/die()
	visible_message("<span class='warning'>[src] shatters spilling its contents!</span>")
	for (var/obj/item/O in contents)
		O.forceMove(loc)
	icon_state = icon_broken

/obj/item/ashtray/plastic
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon_state = "ashtray_bl"
	icon_empty = "ashtray_bl"
	icon_half  = "ashtray_half_bl"
	icon_full  = "ashtray_full_bl"
	icon_broken  = "ashtray_bork_bl"
	max_butts = 14
	health = 24
	starting_materials = list(MAT_PLASTIC = 50)
	w_type = RECYK_MISC
	empty_desc = "Cheap plastic ashtray."
	throwforce = 3

/obj/item/ashtray/plastic/die()
	..()
	name = "pieces of plastic"
	desc = "Pieces of plastic with ash on them."

/obj/item/ashtray/bronze
	name = "bronze ashtray"
	desc = "A large ashtray made of bronze."
	icon_state = "ashtray_br"
	icon_empty = "ashtray_br"
	icon_half  = "ashtray_half_br"
	icon_full  = "ashtray_full_br"
	icon_broken  = "ashtray_bork_br"
	max_butts = 10
	health = 72
	starting_materials = list(MAT_IRON = 80)
	w_type = RECYK_METAL
	empty_desc = "A large ashtray made of bronze."
	throwforce = 10

/obj/item/ashtray/bronze/die()
	..()
	name = "pieces of bronze"
	desc = "Pieces of bronze with ash on them."


/obj/item/ashtray/glass
	name = "glass ashtray"
	desc = "An ashtray made of glass."
	icon_state = "ashtray_gl"
	icon_empty = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	icon_broken  = "ashtray_bork_gl"
	max_butts = 12
	health = 12
	starting_materials = list(MAT_GLASS = 60)
	empty_desc = "Glass ashtray. Looks fragile."
	throwforce = 6

/obj/item/ashtray/glass/die()
	..()
	name = "shards of glass"
	desc = "Shards of glass with ash on them."
	playsound(src, "shatter", 30, TRUE)
