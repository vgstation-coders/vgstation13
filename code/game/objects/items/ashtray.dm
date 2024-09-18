/obj/item/ashtray
	name = "ashtray"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cigs_lighters.dmi', "right_hand" = 'icons/mob/in-hand/right/cigs_lighters.dmi')
	icon = 'icons/ashtray.dmi'
	icon_state = "ashtray_bl"
	item_state = "ashtray"
	w_class = W_CLASS_TINY

	var/trash_type = /obj/item/trash/broken_ashtray
	var/max_butts = 0
	var/impact_sound = 'sound/effects/pop.ogg'
	var/ash_suffix = "bl"

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
		if (istype(W,/obj/item/clothing/mask/cigarette/pipe) && (user.a_intent != I_HURT)) // angry spessmen can still crush their pipe inside the ashtray if they really want to
			var/obj/item/clothing/mask/cigarette/pipe/P = W
			P.lit = 0
			P.smoketime = 0
			to_chat(user, "<span class='notice'>You tap your [P] over the [src], emptying the remaining tobbaco and ashes into it.</span>")
			P.update_brightness()
			add_fingerprint(user)
			return
		if(!user.drop_item(W, src, failmsg = TRUE))
			return
		var/obj/item/clothing/mask/cigarette/cig = W
		if(istype(cig, /obj/item/trash/cigbutt))
			to_chat(user, "<span class='notice'>You drop the [cig] into [src].</span>")
		else if (istype(W,/obj/item/clothing/mask/cigarette) || istype(W, /obj/item/weapon/match))
			if (cig.lit == 1)
				visible_message("<span class='notice'>[user] crushes [cig] in [src], putting it out.</span>")
			else if (cig.lit == 0)
				to_chat(user, "<span class='notice'>You place [cig] in [src] without even lighting it. Why would you do that?</span>")
			else if (cig.lit == -1)
				visible_message("<span class='notice'>[user] places [cig] in [src].</span>")
		add_fingerprint(user)
		update_icon()
		return
	health = max(0,health - W.force)
	playsound(src, impact_sound, 30, TRUE)
	to_chat(user, "<span class='danger'>You hit [src] with [W].</span>")
	if (health < 1)
		die()

/obj/item/ashtray/update_icon()
	if (contents.len >= max_butts)
		icon_state = "ashtray_full_[ash_suffix]"
	else if (contents.len > max_butts/2)
		icon_state = "ashtray_half_[ash_suffix]"
	else if (contents.len > 0)
		icon_state = "ashtray_one_[ash_suffix]"
	else
		icon_state = "ashtray_[ash_suffix]"

/obj/item/ashtray/examine(var/mob/user)
	..()
	if (contents.len >= max_butts)
		to_chat(user, "<span class='info'>It's stuffed full.</span>")
	else if (contents.len > max_butts/2)
		to_chat(user, "<span class='info'>It's half-filled.</span>")
	else if (contents.len == 1)
		to_chat(user, "<span class='info'>There's a [pick(contents)] in there.</span>")
	else if (contents.len > 0)
		to_chat(user, "<span class='info'>There's a couple cigarettes in there.</span>")
	else
		to_chat(user, "<span class='info'>It's empty.</span>")

/obj/item/ashtray/throw_impact(atom/hit_atom)
	playsound(src, impact_sound, 30, TRUE)
	if (health > 0)
		health = max(0,health - 3)
		if (health < 1)
			die()
			return
		if (contents.len)
			visible_message("<span class='warning'>[src] slams into [hit_atom] spilling its contents!</span>")
		for (var/obj/item/O in contents)
			O.forceMove(loc)
		update_icon()
	return ..()

/obj/item/ashtray/proc/die()
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>[src] shatters spilling its contents!</span>")
	for (var/obj/item/O in contents)
		O.forceMove(T)
	new trash_type(T)
	qdel(src)

/obj/item/ashtray/plastic
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon_state = "ashtray_bl"
	item_state = "ashtray"
	ash_suffix = "bl"
	max_butts = 14
	health = 24
	starting_materials = list(MAT_PLASTIC = 50)
	w_type = RECYK_PLASTIC
	throwforce = 3
	flammable = TRUE
	trash_type = /obj/item/trash/broken_ashtray
	impact_sound = 'sound/effects/pop.ogg'

/obj/item/ashtray/bronze
	name = "bronze ashtray"
	desc = "A large ashtray made of bronze."
	icon_state = "ashtray_br"
	item_state = "ashtray_br"
	ash_suffix = "br"
	max_butts = 10
	health = 72
	starting_materials = list(MAT_IRON = 80)
	w_type = RECYK_METAL
	throwforce = 10
	trash_type = /obj/item/trash/broken_ashtray/bronze
	impact_sound = 'sound/items/Crowbar.ogg'

/obj/item/ashtray/glass
	name = "glass ashtray"
	desc = "An ashtray made of glass."
	icon_state = "ashtray_gl"
	item_state = "ashtray_gl"
	ash_suffix = "gl"
	max_butts = 12
	health = 12
	starting_materials = list(MAT_GLASS = 60)
	throwforce = 6
	trash_type = /obj/item/trash/broken_ashtray/glass
	impact_sound = 'sound/effects/Glasshit.ogg'

/obj/item/ashtray/glass/die()
	playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 30, TRUE)
	..()
