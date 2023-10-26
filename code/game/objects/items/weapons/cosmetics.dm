/obj/item/weapon/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	flags = FPRINT
	w_class = W_CLASS_TINY
	var/colour = "red"
	var/open = 0
	autoignition_temperature = AUTOIGNITION_ORGANIC


/obj/item/weapon/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/weapon/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/weapon/lipstick/black
	name = "black lipstick"
	colour = "black"


/obj/item/weapon/lipstick/blue
	name = "blue lipstick"
	colour = "blue"


/obj/item/weapon/lipstick/random
	name = "lipstick"

/obj/item/weapon/lipstick/random/New()
	colour = pick("red","purple","jade","black","blue")
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
		if(H.species.flags & SPECIES_NO_MOUTH)
			to_chat(user, "<span class='warning'>You try to apply the lipstick, but alas, you have no mouth.</span>")
			return
		if(H.check_body_part_coverage(MOUTH))
			to_chat(user, "<span class='warning'>Remove the equipment covering your mouth, first.</span>")
			return
		if(H == user)
			if(H.species.anatomy_flags & HAS_LIPS)
				user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
									 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			else
				user.visible_message("<span class='notice'>[user] applies \the [src] onto the place where their lips should be, looking quite silly.</span>", \
									 "<span class='notice'>You take a moment to apply \the [src] onto your lipless face. Perfect!</span>")
			H.lip_style = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to apply \the [src] onto [H].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user,H, 20))	//user needs to keep their active hand, H does not.
				if(H.species.anatomy_flags & HAS_LIPS)
					user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									 	"<span class='notice'>You apply \the [src].</span>")
				else
					user.visible_message("<span class='notice'>[user] applied some of \the [src] onto [H]'s lipless face.</span>", \
									 	"<span class='notice'>You apply \the [src] onto [H]'s lipless face.</span>")
				H.lip_style = colour
				H.update_body()
	else
		to_chat(user, "<span class='notice'>That would look stupid.</span>")

/obj/item/weapon/eyeshadow
	name = "black eyeshadow"
	desc = "A generic brand of eyeshadow."
	icon = 'icons/obj/items.dmi'
	icon_state = "eyeshadow_brush"
	flags = FPRINT
	w_class = W_CLASS_TINY
	var/colour = "black"
	var/open = 0


/obj/item/weapon/eyeshadow/purple
	name = "purple eyeshadow"
	colour = "purple"

/obj/item/weapon/eyeshadow/jade
	name = "jade eyeshadow"
	colour = "jade"

/obj/item/weapon/eyeshadow/random
	name = "eyeshadow"

/obj/item/weapon/eyeshadow/random/New()
	colour = pick("purple","jade","black")
	name = "[colour] eyeshadow"
	..()

/obj/item/weapon/eyeshadow/attack(mob/M, mob/user)
	if(!istype(M, /mob))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.eye_style)	//if they already have eyeshadow on
			to_chat(user, "<span class='notice'>You need to wipe off the old eyeshadow first!</span>")
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] does their eyes with \the [src].</span>", \
								 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			H.eye_style = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to do [H]'s eyes with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user,H, 20))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] does [H]'s eyes with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.eye_style = colour
				H.update_body()
	else
		to_chat(user, "<span class='notice'>Where are the eyes on that?</span>")

/obj/item/weapon/facepaint_spray
	name = "face paint spray"
	desc = "A can of Dr. Frankenstein's instant facepaint. There is a dial on the top for pattern selection."
	icon = 'icons/obj/items.dmi'
	icon_state = "face_paint"
	flags = FPRINT
	w_class = W_CLASS_TINY

	var/selected_pattern = 1
	var/list/pattern_list = list(
		"Deathly Pallor" = "pallor",
		"Zombie Fever" = "zombie",
		"Martian Menace" = "alien",
		"Impish Visage" = "devil"
	)

/obj/item/weapon/facepaint_spray/attack(mob/M, mob/user)
	if(!istype(M, /mob))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.face_style)	//if they already have facepaint on
			to_chat(user, "<span class='notice'>You need to wipe off the old facepaint first!</span>")
			return

		var/pattern = pattern_list[pattern_list[selected_pattern]]

		if(H == user)
			user.visible_message("<span class='notice'>[user] sprays their face with \the [src].</span>", \
								 "<span class='notice'>You shut your eyes and spray your face with \the [src], trying not to inhale any paint.</span>")
			H.face_style = pattern
			H.update_body()

		else
			user.visible_message("<span class='warning'>[user] begins to spray [H]'s face with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user,H, 20))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] does [H]'s eyes with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.face_style = pattern
				H.update_body()

	else
		to_chat(user, "<span class='notice'>Where are the eyes on that?</span>")

/obj/item/weapon/facepaint_spray/attack_self(mob/user as mob)
	selected_pattern += 1
	selected_pattern = selected_pattern > pattern_list.len ? 1 : selected_pattern
	to_chat(user, "<span class='notice'>You set the spray to \"[pattern_list[selected_pattern]]\" mode</span>")

/obj/item/weapon/facepaint_spray/examine(mob/user, size, show_name)
	. = ..()
	to_chat(user, "<span class='notice'>It is set to \"[pattern_list[selected_pattern]]\" mode</span>")

//you can wipe off makeup with paper!
/obj/item/weapon/paper/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M

	if(user.zone_sel.selecting == "head")
		if(H == user)
			to_chat(user, "<span class='notice'>You wipe off the face paint with [src].</span>")
			H.face_style = null
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to wipe [H]'s face paint  off with \the [src].</span>", \
									"<span class='notice'>You begin to wipe off [H]'s face paint .</span>")
			if(do_after(user, H, 10) && do_after(H, null, 10, 5, 0))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] wipes [H]'s face paint  off with \the [src].</span>", \
										"<span class='notice'>You wipe off [H]'s face paint .</span>")
				H.face_style = null
				H.update_body()

	else if(user.zone_sel.selecting == "eyes")
		if(H == user)
			to_chat(user, "<span class='notice'>You wipe off the eyeshadow with [src].</span>")
			H.eye_style = null
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to wipe [H]'s eyeshadow off with \the [src].</span>", \
									"<span class='notice'>You begin to wipe off [H]'s eyeshadow.</span>")
			if(do_after(user, H, 10) && do_after(H, null, 10, 5, 0))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] wipes [H]'s eyeshadow off with \the [src].</span>", \
										"<span class='notice'>You wipe off [H]'s eyeshadow.</span>")
				H.eye_style = null
				H.update_body()

	else if(user.zone_sel.selecting == "mouth")
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
	var/new_color = input(user, "Choose the dye's color:", "Color Select", rgb(color_r, color_g, color_b)) as color|null
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
			if(!H.my_appearance.f_style || H.my_appearance.f_style == "Shaved")	//if they have no facial hair
				to_chat(user, "<span class='notice'>[H == user ? "You don't" : "\The [H] doesn't"] seem to have any facial hair!</span>")
				return
			else
				var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.my_appearance.f_style]
				if(!facial_hair_style.do_colouration)
					to_chat(user, "<span class='notice'>[H == user ? "You don't" : "\The [H] doesn't"] seem to have any colorable facial hair!</span>")
					return
			area_string = "facial hair"
		else
			var/obj/item/clothing/cover = H.get_body_part_coverage(HEAD)
			if(cover)
				to_chat(user, "<span class='notice'>You can't color [H == user ? "your" : "\the [H]'s"] hair through that [cover.name]!</span>")
				return
			if(!H.my_appearance.h_style || H.my_appearance.h_style == "Bald")	//if they have no hair
				to_chat(user, "<span class='notice'>[H == user ? "You don't" : "\The [H] doesn't"] seem to have any hair!</span>")
				return
			else
				var/datum/sprite_accessory/hair_style = hair_styles_list[H.my_appearance.h_style]
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
	if(isvox(H))
		var/list/voxhaircolorlist = list()
		voxhaircolorlist["green"] = list(87, 123, 119)
		voxhaircolorlist["brown"] = list(162,107,56)
		voxhaircolorlist["grey"] = list(192, 192, 192)
		voxhaircolorlist["lightgreen"] = list(132, 138, 64)
		voxhaircolorlist["azure"] = list(112, 126, 93)
		voxhaircolorlist["emerald"] = list(65, 136, 98)
		voxhaircolorlist["greenbrown"] = list(147, 126, 61)

		var/list/closest = ARBITRARILY_LARGE_NUMBER
		var/voxcolor = 0
		for(var/rgbcolorset in voxhaircolorlist)
			var/rgb = voxhaircolorlist[rgbcolorset]
			var/diff = (max(color_r,rgb[1]) - min(color_r,rgb[1])) + (max(color_r,rgb[2]) - min(color_r,rgb[2])) + (max(color_r,rgb[3]) - min(color_r,rgb[3]))
			if(diff < closest)
				closest = diff
				var/haircolor = get_key_by_element(voxhaircolorlist, rgb)
				voxcolor = voxhaircolorlist.Find(haircolor)
		H.my_appearance.r_hair = voxcolor
	else
		if(facial)
			H.my_appearance.r_facial = color_r
			H.my_appearance.g_facial = color_g
			H.my_appearance.b_facial = color_b
		else
			H.my_appearance.r_hair = color_r
			H.my_appearance.g_hair = color_g
			H.my_appearance.b_hair = color_b
	H.update_hair()
	if(H.species.anatomy_flags & RGBSKINTONE)
		H.update_body()
	playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)

/obj/item/weapon/hair_dye/skin_dye
	name = "magic skin dye"
	desc = "Bubble, bubble, toil and trouble!"
	var/uses = 3

/obj/item/weapon/hair_dye/skin_dye/examine(mob/user)
	..()
	to_chat(user,"<span class='info'>It has [uses] uses left.</span>")

/obj/item/weapon/hair_dye/skin_dye/attack(mob/M, mob/user)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(H.w_uniform && (H.w_uniform.body_parts_covered & UPPER_TORSO))
		to_chat(user,"<span class='warning'>[H] needs to have an uncovered chest to really let the dye sink in.</span>")
		return
	if(H != user)
		visible_message(user,"<span class='danger'>[user] is trying to spray down [H] with skin dye!</span>")
		if(do_after(user,H, 10 SECONDS))
			visible_message(user,"<span class='info'>[user] dyed [H].</span>")
			dye(H)
	else
		dye(H)

/obj/item/weapon/hair_dye/skin_dye/proc/dye(mob/living/carbon/human/H)
	H.species.anatomy_flags |= MULTICOLOR
	H.multicolor_skin_r = color_r
	H.multicolor_skin_g = color_g
	H.multicolor_skin_b = color_b
	H.update_body()
	if(H.species.anatomy_flags & RGBSKINTONE)
		H.my_appearance.r_hair = color_r
		H.my_appearance.g_hair = color_g
		H.my_appearance.b_hair = color_b
		H.update_hair()
	uses--
	if(!uses)
		qdel(src)

/obj/item/weapon/hair_dye/skin_dye/discount
	name = "discount skin dye"
	desc = "This is... probably no more unhealthy than a spray-on tan, right?"

/obj/item/weapon/hair_dye/skin_dye/discount/dye(mob/living/carbon/human/H)
	..()
	H.reagents.add_reagent(TOXIN,1)

/obj/item/weapon/invisible_spray
	name = "can of invisible spray"
	desc = "A can of... invisibility? The label reads: \"Wears off after five minutes.\""
	icon = 'icons/obj/items.dmi'
	icon_state = "invisible_spray"
	flags = FPRINT
	w_class = W_CLASS_SMALL
	var/permanent = 0
	var/invisible_time = 5 MINUTES
	var/sprays_left = 1
	var/static/list/prohibited_objects = list( //For fun removal
		)

/obj/item/weapon/invisible_spray/examine(var/mob/user)
	..()
	if(loc != user)
		return
	if(sprays_left)
		to_chat(user, "<span class='notice'>The can still has some spray left!</span>")
	else
		to_chat(user, "<span class='notice'>The can feels empty.</span>")


/obj/item/weapon/invisible_spray/preattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return 0
	if(!istype(target))
		return
	if(!sprays_left)
		to_chat(user, "\The [src] is empty.")
		return
	if(target.invisibility || target.alpha <= 1)
		to_chat(user, "\The [target] is already invisible!")
		return
	if(is_type_in_list(target,prohibited_objects))
		to_chat(user, "<span class='notice'>For some reason, you don't think that would work.</span>")
		return
	if(!do_after(user, target, 2 SECONDS))
		return 1
	if(!sprays_left)   // le do_after check
		to_chat(user, "\The [src] is empty.")
		return
	if(permanent)
		invisible_time = 0
	var/mob/M = target
	if(M == user)
		to_chat(user, "You spray yourself with \the [src].")
		user.make_invisible(INVISIBLESPRAY, invisible_time, FALSE, 1)
	else if (ismob(M))
		to_chat(user, "You spray [M] with \the [src].")
		M.make_invisible(INVISIBLESPRAY, invisible_time, FALSE, 1)
	var/obj/O = target
	if(isobj(O))
		if(locate(O) in get_contents_in_object(user))
			O.make_invisible(INVISIBLESPRAY, invisible_time, 1)
		else
			O.make_invisible(INVISIBLESPRAY, invisible_time, 1)
		to_chat(user, "You spray \the [O] with \the [src].")

	playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
	sprays_left--
	if(istype(target, /obj/machinery/power/supermatter))
		return 0
	if(istype(target, /obj/machinery/singularity))
		animate(target, color = grayscale, time = 6 SECONDS)
		return 0
	return 1

/obj/item/weapon/invisible_spray/permanent
	desc = "A can of... invisibility?"
	permanent = 1

/obj/item/weapon/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items.dmi'
	icon_state = "razor"
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_IRON = 340)

/obj/item/weapon/razor/proc/shave(mob/living/carbon/human/H, location = "mouth")
	if(location == "mouth")
		H.my_appearance.f_style = "Shaved"
	else
		H.my_appearance.h_style = "Skinhead"

	H.update_hair()
	playsound(loc, 'sound/items/Welder2.ogg', 20, 1)


/obj/item/weapon/razor/attack(mob/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/location = user.zone_sel.selecting
		if(location == "mouth")
			if(H.check_body_part_coverage(MOUTH))
				to_chat(user,"<span class='warning'>The mask is in the way!</span>")
				return
			if(H.my_appearance.f_style == "Shaved")
				to_chat(user,"<span class='warning'>Already clean-shaven!</span>")
				return

			if(H == user) //shaving yourself
				user.visible_message("[user] starts to shave their facial hair with [src].", \
									 "<span class='notice'>You take a moment to shave your facial hair with [src]...</span>")
				if(do_after(user, H, 5))
					user.visible_message("[user] shaves \his facial hair clean with [src].", \
										 "<span class='notice'>You finish shaving with [src]. Fast and clean!</span>")
					shave(H, location)
			else
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s facial hair with [src].</span>", \
									 "<span class='notice'>You start shaving [H]'s facial hair...</span>")
				if(do_after(user, H, 50))
					user.visible_message("<span class='warning'>[user] shaves off [H]'s facial hair with [src].</span>", \
										 "<span class='notice'>You shave [H]'s facial hair clean off.</span>")
					shave(H, location)

		else if(location == LIMB_HEAD)
			if(H.check_body_part_coverage(HEAD))
				to_chat(user,"<span class='warning'>The headgear is in the way!</span>")
				return
			if(H.species.anatomy_flags & NO_BALD)
				to_chat(user,"<span class='warning'>[H] does not have hair to shave!</span>")
				return
			if(H.my_appearance.h_style == "Bald" || H.my_appearance.h_style == "Skinhead")
				to_chat(user,"<span class='warning'>There is not enough hair left to shave!</span>")
				return

			if(H == user) //shaving yourself
				user.visible_message("[user] starts to shave their head with [src].", \
									 "<span class='notice'>You start to shave your head with [src]...</span>")
				if(do_after(user, H, 5))
					user.visible_message("[user] shaves \his head with [src].", \
										 "<span class='notice'>You finish shaving with [src].</span>")
					shave(H, location)
			else
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s head with [src]!</span>", \
									 "<span class='notice'>You start shaving [H]'s head...</span>")
				if(do_after(user, H, 50))
					user.visible_message("<span class='warning'>[user] shaves [H]'s head bald with [src]!</span>", \
										 "<span class='notice'>You shave [H]'s head bald.</span>")
					shave(H, location)
		else
			..()
	else
		..()

/obj/item/weapon/pocket_mirror //shamelessly copypasted from [mirror.dm]
	name = "pocket mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all? Touching the mirror will bring out Nanotrasen's state of the art hair modification system."
	icon = 'icons/obj/barber.dmi'
	icon_state = "pocket_mirror"
	flags = FPRINT
	w_class = W_CLASS_TINY

	var/shattered = 0

/obj/item/weapon/pocket_mirror/attack_self(mob/user)
	if(shattered)
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if (isvampire(H))
			var/datum/role/vampire/V = H.mind.GetRole(VAMPIRE)
			if (!(locate(/datum/power/vampire/mature) in V.current_powers))
				to_chat(H, "<span class='notice'>You don't see anything.</span>")
				return
		if(user.hallucinating())
			switch(rand(1,100))
				if(1 to 20)
					to_chat(H, "<span class='sinister'>You look like [pick("a monster","a goliath","a catbeast","a ghost","a chicken","the mailman","a demon")]! Your heart skips a beat.</span>")
					H.Knockdown(4)
					H.Stun(4)
					return
				if(21 to 40)
					to_chat(H, "<span class='sinister'>There's [pick("somebody","a monster","a little girl","a zombie","a ghost","a catbeast","a demon")] standing behind you!</span>")
					H.audible_scream()
					H.dir = turn(H.dir, 180)
					return
				if(41 to 50)
					to_chat(H, "<span class='notice'>You don't see anything.</span>")
					return
				else
					//do nothing
		handle_hair(H)

/obj/item/weapon/pocket_mirror/proc/handle_hair(mob/user, var/mob/living/carbon/human/H = null)
	if(!H && ishuman(user))
		H = user
	if(!H)
		return
	if(arcanetampered)
		to_chat(user, "<span class='sinister'>You feel different.</span>")
		H.Humanize(pick("Unathi","Tajaran","Insectoid","Grey",/*and worst of all*/"Vox"))
		var/list/species_facial_hair = valid_sprite_accessories(facial_hair_styles_list, H.gender, H.species.name)
		if(species_facial_hair.len)
			H.my_appearance.f_style = pick(species_facial_hair)
			H.update_hair()
		var/list/species_hair = valid_sprite_accessories(hair_styles_list, null, H.species.name)
		if(species_hair.len)
			H.my_appearance.h_style = pick(species_hair)
			H.update_hair()
		return
	var/list/species_hair = valid_sprite_accessories(hair_styles_list, null, (H.species.name || null))
	//gender intentionally left null so speshul snowflakes can cross-hairdress
	if(species_hair.len)
		var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in species_hair
		if(!Adjacent(user) || user.incapacitated())
			return
		if(new_style)
			H.my_appearance.h_style = new_style
			H.update_hair()

/obj/item/weapon/pocket_mirror/proc/shatter(mob/shatterer)
	if (shattered)
		return
	shattered = 1
	icon_state = "pocket_mirror_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"

	//Curse the shatterer with bad luck
	var/datum/blesscurse/brokenmirror/mirrorcurse = new /datum/blesscurse/brokenmirror
	shatterer.add_blesscurse(mirrorcurse)

/obj/item/weapon/pocket_mirror/kick_act(mob/living/carbon/human/H)
	shatter(H)
	..()

/obj/item/weapon/pocket_mirror/throw_impact(atom/hit_atom, var/speed, mob/user)
	if(..() || !isturf(hit_atom))
		return
	if (prob(25))
		shatter(user)

/obj/item/weapon/pocket_mirror/comb
	name = "hair comb"
	desc = "Despite the name honey is not included nor recommended for use with this."
	icon_state = "comb"

/obj/item/weapon/pocket_mirror/comb/shatter(mob/shatterer)
	return

/obj/item/weapon/pocket_mirror/comb/attack(mob/M, mob/user)
	if(M == user)
		handle_hair(user)
	else
		..()

/obj/item/weapon/pocket_mirror/scissors
	name = "barber scissors"
	desc = "Scissors designed for cutting and styling hair."
	icon_state = "barber_scissors"
	sharpness = 1
	sharpness_flags = SHARP_TIP | SHARP_BLADE

/obj/item/weapon/pocket_mirror/scissors/shatter(mob/shatterer)
	return

/obj/item/weapon/pocket_mirror/scissors/attack(atom/target, mob/user)
	if(ishuman(target) && target != user)
		user.visible_message("<span class='danger'>[user] begins changing [target]'s style!</span>")	//Chitin, slime, etc. Can't use the word "hair"
		if(do_after(user, target, 3 SECONDS))
			handle_hair(user, target)
	else
		..()


/obj/item/weapon/pocket_mirror/arcane
	name = "strange pocket mirror"
	desc = "is that your reflection? or someone elses."
	arcanetampered = 1


/obj/item/weapon/nanitecontacts
	name = "nanite contacts"
	desc = "Deploys nanobots to your eyes to change their color."
	icon = 'icons/obj/items.dmi'
	icon_state = "nanite_contact"
	flags = FPRINT
	w_class = W_CLASS_TINY
	var/color_r = 255
	var/color_g = 255
	var/color_b = 255

/obj/item/weapon/nanitecontacts/New()
	..()
	color_r = rand(0,255)
	color_g = rand(0,255)
	color_b = rand(0,255)
	update_icon()

/obj/item/weapon/nanitecontacts/update_icon()
	overlays.len = 0
	var/image/I = image(icon = 'icons/obj/items.dmi', icon_state = "contacts_overlay")
	I.color = rgb(color_r, color_g, color_b)
	overlays += I

/obj/item/weapon/nanitecontacts/attack_self(mob/user)
	var/new_color = input(user, "Choose the contact's color:", "Color Select", rgb(color_r, color_g, color_b)) as color|null
	if(new_color)
		color_r = hex2num(copytext(new_color, 2, 4))
		color_g = hex2num(copytext(new_color, 4, 6))
		color_b = hex2num(copytext(new_color, 6, 8))
	update_icon()

/obj/item/weapon/nanitecontacts/attack(mob/M, mob/user)
	if(!istype(M))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/area = user.zone_sel.selecting
		if(area == "eyes")
			var/obj/item/clothing/cover = H.get_body_part_coverage(EYES)
			if(cover)
				to_chat(user, "<span class='notice'>You can't color [H == user ? "your" : "\the [H]'s"] eyes through that [cover.name]!</span>")
				return
		if(H == user)
			user.visible_message("<span class='notice'>[user] colors their eyes with \the [src].</span>", \
								 "<span class='notice'>You color your eyes with \the [src].</span>")
			color_eyes(H)
		else
			user.visible_message("<span class='warning'>[user] begins to color \the [H]'s eyes with \the [src].</span>", \
								 "<span class='notice'>You begin to color \the [H]'s eyes with \the [src].</span>")
			if(do_after(user,H, 20))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] colors [H]'s eyes with \the [src].</span>", \
									 "<span class='notice'>You color [H]'s eyes with \the [src].</span>")
				color_eyes(H)
	else
		to_chat(user, "<span class='notice'>\The [M]'s eyes don't fit in the contacts!</span>")

/obj/item/weapon/nanitecontacts/proc/color_eyes(mob/living/carbon/human/H)
	if(!H)
		return
	else
		H.my_appearance.r_eyes = color_r
		H.my_appearance.g_eyes = color_g
		H.my_appearance.b_eyes = color_b
	H.update_body()
