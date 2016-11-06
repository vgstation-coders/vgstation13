/obj/item/weapon/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	flags = FPRINT
	w_class = W_CLASS_TINY
	var/colour = "red"
	var/open = 0


/obj/item/weapon/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/weapon/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/weapon/lipstick/black
	name = "black lipstick"
	colour = "black"


/obj/item/weapon/lipstick/random
	name = "lipstick"

/obj/item/weapon/lipstick/random/New()
	colour = pick("red","purple","jade","black")
	name = "[colour] lipstick"
	..()


/obj/item/weapon/lipstick/attack_self(mob/user as mob)
	to_chat(user, "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>")
	open = !open
	if(open)
		icon_state = "[initial(icon_state)]_[colour]"
	else
		icon_state = initial(icon_state)

/obj/item/weapon/lipstick/attack(mob/M as mob, mob/user as mob)
	if(!open)
		return

	if(!istype(M, /mob))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	//if they already have lipstick on
			to_chat(user, "<span class='notice'>You need to wipe off the old lipstick first!</span>")
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
								 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			H.lip_style = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user,H, 20))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.lip_style = colour
				H.update_body()
	else
		to_chat(user, "<span class='notice'>Where are the lips on that?</span>")

//you can wipe off lipstick with paper!
/obj/item/weapon/paper/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_sel.selecting == "mouth")
		if(!istype(M, /mob))
			return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, "<span class='notice'>You wipe off the lipstick with [src].</span>")
				H.lip_style = null
				H.update_body()
			else
				user.visible_message("<span class='warning'>[user] begins to wipe [H]'s lipstick off with \the [src].</span>", \
								 	 "<span class='notice'>You begin to wipe off [H]'s lipstick.</span>")
				if(do_after(user, H, 10) && do_after(H, null, 10, 5, 0))	//user needs to keep their active hand, H does not.
					user.visible_message("<span class='notice'>[user] wipes [H]'s lipstick off with \the [src].</span>", \
										 "<span class='notice'>You wipe off [H]'s lipstick.</span>")
					H.lip_style = null
					H.update_body()
	else
		..()

/obj/item/weapon/hair_dye
	name = "can of hair dye"
	desc = "A can of sprayable hair dye. There is a dial on the top for color selection."
	icon = 'icons/obj/items.dmi'
	icon_state = "hair_dye"
	flags = FPRINT
	w_class = W_CLASS_SMALL
	var/color_r = 255
	var/color_g = 255
	var/color_b = 255

/obj/item/weapon/hair_dye/New()
	..()
	color_r = rand(0,255)
	color_g = rand(0,255)
	color_b = rand(0,255)
	update_icon()

/obj/item/weapon/hair_dye/update_icon()
	overlays.len = 0
	var/icon/dye_color = new/icon("icon" = 'icons/obj/items.dmi', "icon_state" = "dye_color_overlay")
	dye_color.Blend(rgb(color_r, color_g, color_b), ICON_ADD)
	overlays += dye_color

/obj/item/weapon/hair_dye/attack_self(mob/user as mob)
	var/new_color = input(user, "Choose the dye's color:", "Color Select") as color|null
	if(new_color)
		color_r = hex2num(copytext(new_color, 2, 4))
		color_g = hex2num(copytext(new_color, 4, 6))
		color_b = hex2num(copytext(new_color, 6, 8))
	update_icon()

/obj/item/weapon/hair_dye/attack(mob/M as mob, mob/user as mob)
	if(!istype(M, /mob))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/area = user.zone_sel.selecting
		var/area_string = "hair"
		if(area == "mouth")
			var/obj/item/clothing/cover = H.get_body_part_coverage(MOUTH)
			if(cover)
				to_chat(user, "<span class='notice'>You can't color [H == user ? "your" : "\the [H]'s"] facial hair through that [cover.name]!</span>")
				return
			if(!H.f_style || H.f_style == "Shaved")	//if they have no facial hair
				to_chat(user, "<span class='notice'>[H == user ? "You don't" : "\The [H] doesn't"] seem to have any facial hair!</span>")
				return
			else
				var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.f_style]
				if(!facial_hair_style.do_colouration)
					to_chat(user, "<span class='notice'>[H == user ? "You don't" : "\The [H] doesn't"] seem to have any colorable facial hair!</span>")
					return
			area_string = "facial hair"
		else
			var/obj/item/clothing/cover = H.get_body_part_coverage(HEAD)
			if(cover)
				to_chat(user, "<span class='notice'>You can't color [H == user ? "your" : "\the [H]'s"] hair through that [cover.name]!</span>")
				return
			if(!H.h_style || H.h_style == "Bald")	//if they have no hair
				to_chat(user, "<span class='notice'>[H == user ? "You don't" : "\The [H] doesn't"] seem to have any hair!</span>")
				return
			else
				var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
				if(!hair_style.do_colouration)
					to_chat(user, "<span class='notice'>[H == user ? "You don't" : "\The [H] doesn't"] seem to have any colorable hair!</span>")
					return
		if(H == user)
			user.visible_message("<span class='notice'>[user] colors their [area_string] with \the [src].</span>", \
								 "<span class='notice'>You color your [area_string] with \the [src].</span>")
			if(area == "mouth")
				color_hair(H,1)
			else
				color_hair(H)
		else
			user.visible_message("<span class='warning'>[user] begins to color \the [H]'s [area_string] with \the [src].</span>", \
								 "<span class='notice'>You begin to color \the [H]'s [area_string] with \the [src].</span>")
			if(do_after(user,H, 20))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] colors [H]'s [area_string] with \the [src].</span>", \
									 "<span class='notice'>You color [H]'s [area_string] with \the [src].</span>")
				if(area == "mouth")
					color_hair(H,1)
				else
					color_hair(H)
	else
		to_chat(user, "<span class='notice'>\The [M] doesn't seem to have any hair!</span>")

/obj/item/weapon/hair_dye/proc/color_hair(mob/living/carbon/human/H, var/facial = 0)
	if(!H)
		return
	if(facial)
		H.r_facial = color_r
		H.g_facial = color_g
		H.b_facial = color_b
	else
		H.r_hair = color_r
		H.g_hair = color_g
		H.b_hair = color_b
	H.update_hair()
	playsound(get_turf(src), 'sound/effects/spray2.ogg', 50, 1, -6)
