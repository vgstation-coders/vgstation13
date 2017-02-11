/obj/structure/headpole
	name = "pole"
	icon = 'icons/obj/structures.dmi'
	icon_state = "metal_pike"
	desc = "How did this get here?"
	density = 0
	anchored = 1
	var/obj/item/weapon/spear/spear = null
	var/obj/item/weapon/organ/head/head = null
	var/image/display_head = null

/obj/structure/headpole/New(atom/A, var/obj/item/weapon/organ/head/H, var/obj/item/weapon/spear/S)
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
	var/obj/item/weapon/organ/head/H = new (src)
	H.name = "severed head"
	spear = new (src)
	..(A, H)

/obj/structure/bed/guillotine
	name = "guillotine"
	icon = 'icons/obj/structures.dmi'
	icon_state = "guillotine_open"
	desc = "The most efficient way to remove one's head from one's shoulders."
	density = 1
	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER
	lock_type = /datum/locking_category/buckle/guillotine
	var/open = TRUE
	var/bladedown = FALSE
	var/mob/living/carbon/human/victim
	var/image/victim_head = null

/obj/structure/bed/guillotine/cultify()
	return

/obj/structure/bed/guillotine/New()
	..()
	victim_head = new

/obj/structure/bed/guillotine/Destroy()
	if(victim_head)
		qdel(victim_head)
		victim_head = null
	if(victim)
		qdel(victim)
		victim = null
	..()

/obj/structure/bed/guillotine/update_icon()
	if(open)
		icon_state = "guillotine_open"
	else
		icon_state = "guillotine_closed"
	if(bladedown)
		icon_state = "[icon_state]_bladedown"
	update_victim()

/obj/structure/bed/guillotine/proc/update_victim()
	overlays.len = 0
	if(!victim || bladedown)
		return
	if(victim.organs_by_name)
		var/datum/organ/external/head/HD = victim.get_organ(LIMB_HEAD)
		if(istype(HD) && ~HD.status & ORGAN_DESTROYED)
			var/obj/item/weapon/organ/head/H = copy_head(victim)
			victim_head.appearance = H.appearance
			victim_head.layer = layer+1
			victim_head.plane = plane+1
			qdel(H)
			victim_head.transform = matrix()
			victim_head.pixel_y = -18 * PIXEL_MULTIPLIER
			overlays += victim_head.appearance

/obj/structure/bed/guillotine/proc/copy_head(mob/living/carbon/human/H)
	var/obj/item/weapon/organ/head/head = new(src)
	head.species = H.species
	head.update_icon(H)

	if(istype(H))
		head.icon_state = H.gender == MALE? "head_m" : "head_f"

	//Add (facial) hair.
	if(H && H.f_style &&  !H.check_hidden_head_flags(HIDEBEARDHAIR))
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.f_style]
		if(facial_hair_style)
			var/icon/facial = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial.Blend(rgb(H.r_facial, H.g_facial, H.b_facial), ICON_ADD)

			head.overlays.Add(facial) // icon.Blend(facial, ICON_OVERLAY)

	if(H && H.h_style && !H.check_hidden_head_flags(HIDEHEADHAIR))
		var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
		if(hair_style)
			var/icon/hair = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair.Blend(rgb(H.r_hair, H.g_hair, H.b_hair), ICON_ADD)
			if(hair_style.additional_accessories)
				hair.Blend(icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_acc"), ICON_OVERLAY)

			head.overlays.Add(hair) //icon.Blend(hair, ICON_OVERLAY)

	head.name = "[H.real_name]'s head"
	return head

/datum/locking_category/buckle/guillotine
	pixel_x_offset = -1 * PIXEL_MULTIPLIER
	pixel_y_offset = -8 * PIXEL_MULTIPLIER
	flags = CANT_BE_MOVED_BY_LOCKED_MOBS

/obj/structure/bed/guillotine/manual_unbuckle(mob/user)
	if(!is_locking(lock_type))
		return

	if(user.size <= SIZE_TINY)
		to_chat(user, "<span class='warning'>You are too small to do that.</span>")
		return

	var/mob/M = get_locked(lock_type)[1]
	if(M != user)
		M.visible_message(\
			"<span class='notice'>\The [user] pulls [M] out of \the [src]!</span>",\
			"[user] pulls you out of \the [src].")
	else
		M.visible_message(\
			"<span class='notice'>\The [M] climbs out of \the [src].</span>",\
			"You climb out of \the [src].")
	unlock_atom(M)

	add_fingerprint(user)

/obj/structure/bed/guillotine/buckle_mob(mob/M, mob/user)
	if(!Adjacent(user) || user.incapacitated() || istype(user, /mob/living/silicon/pai))
		return

	if(!ismob(M) || !M.Adjacent(user)  || M.locked_to)
		return

	if(bladedown)
		to_chat(user, "<span class='warning'>You can't fit \the [M] into \the [src] while the blade is down.</span>")
		return

	if(!open)
		to_chat(user, "<span class='warning'>You can't place \the [M] into \the [src] while its stocks are closed.</span>")
		return

	for(var/mob/living/L in get_locked(lock_type))
		if(L.stat)
			to_chat(user, "<span class='warning'>There is still a body inside \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>There is already someone inside \the [src].</span>")
		return

	if(user.size <= SIZE_TINY) //Fuck off mice
		to_chat(user, "<span class='warning'>You are too small to do that.</span>")
		return

	if(!ishuman(M))
		return

	if(M == user)
		M.visible_message(\
			"<span class='notice'>\The [M] climbs into \the [src]!</span>",\
			"You climb into \the [src].")
	else
		M.visible_message(\
			"<span class='warning'>\The [M] is placed in \the [src] by \the [user]!</span>",\
			"<span class='danger'>You are placed in \the [src] by \the [user].</span>")
	add_fingerprint(user)

	lock_atom(M, lock_type)

/obj/structure/bed/guillotine/lock_atom(var/atom/movable/AM, var/datum/locking_category/category = /datum/locking_category)
	. = ..()
	if(.)
		victim = AM
		AM.dir = NORTH
		var/matrix/M = matrix()
		M.Turn(180)
		M.Scale(1,0.5)
		AM.transform = M
		update_icon()

/obj/structure/bed/guillotine/unlock_atom(var/atom/movable/AM)
	. = ..()
	if(.)
		AM.dir = SOUTH
		var/matrix/M = AM.transform
		M.Turn(180)
		if(!victim.lying)
			M.Scale(1,2)
		AM.transform = M
		victim = null
		update_icon()

/obj/structure/bed/guillotine/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			to_chat(user, "You unsecure \the [src] from the floor.")
		else
			to_chat(user, "You secure \the [src] to the floor.")
		anchored = !anchored

/obj/structure/bed/guillotine/AltClick(var/mob/user)
	if(bladedown)
		tie_blade(user)
	else
		untie_blade(user)

/obj/structure/bed/guillotine/proc/tie_blade(mob/user)
	user.visible_message(\
			"<span class='notice'>\The [user] ties \the [src]'s blade back into place.</span>",\
			"You tie \the [src]'s blade back into place.")
	bladedown = FALSE
	update_icon()

/obj/structure/bed/guillotine/proc/untie_blade(mob/user)
	user.visible_message(\
			"<span class='danger'>\The [user] begins untying the rope holding \the [src]'s blade!</span>",\
			"You begin untying the rope holding \the [src]'s blade.")
	if(do_after(user, src, 100))
		if(victim)
			if(victim.organs_by_name)
				var/datum/organ/external/head/H = victim.get_organ(LIMB_HEAD)
				if(istype(H) && ~H.status & ORGAN_DESTROYED)
					H.droplimb(1)
					playsound(get_turf(src), 'sound/weapons/bloodyslice.ogg', 100, 1)
		bladedown = TRUE
		update_icon()