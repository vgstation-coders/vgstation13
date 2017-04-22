/obj/item/ornament
	name = "ornament"
	desc = "A glass ornament. What some would call plain, others call elegant."
	icon = 'icons/obj/ball_ornaments.dmi'
	icon_state = "white_ball_ornament"
	w_class = 2
	var/list/ornaments_list = list("red" = /obj/item/ornament/red,
								"blue" = /obj/item/ornament/blue,
								"green" = /obj/item/ornament/green,
								"purple" = /obj/item/ornament/purple,
								"orange" = /obj/item/ornament/orange,
								"yellow" = /obj/item/ornament/gold,
								"rainbow" = /obj/item/ornament/magenta,
								"gray" = /obj/item/ornament/silver)

/obj/item/ornament/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/toy/crayon) || istype(W, /obj/item/weapon/pen))
		var/obj/item/ornament/O
		var/type_to_spawn
		var/color_string = null
		if(istype(W, /obj/item/toy/crayon))
			var/obj/item/toy/crayon/C = W
			switch(C.colourName)
				if("yellow")
					color_string = "gold"
				if("rainbow")
					color_string = "a deep pink"
				if("mime")
					return
			type_to_spawn = ornaments_list[C.colourName]
			O = new type_to_spawn(get_turf(src))
			if(!color_string)
				color_string = C.colourName
		else
			type_to_spawn = ornaments_list["gray"]
			O = new type_to_spawn(get_turf(src))
		if(O)
			O.canremove = canremove
			O.cant_drop = cant_drop
			if(loc == user)
				user.drop_item(src, force_drop = 1)
				user.put_in_hands(O)
			qdel(src)
			if(color_string)
				to_chat(user, "You color \the [src] [color_string].")
			else
				to_chat(user, "You lightly shade \the [src] with \the [W] until it appears silver.")

/obj/item/ornament/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return 0
	if(istype(target, /obj/structure/flora))
		var/obj/structure/flora/F = target
		F.hang_ornament(src, user, click_parameters)
		return 1
	return ..()

/obj/item/ornament/throw_impact(atom/hit_atom)
	..()
	src.visible_message("<span class='warning'>\The [src] shatters!</span>","<span  class='warning'>You hear a shatter!</span>")
	if(get_turf(src))
		playsound(get_turf(src), 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	if(prob(33))
		getFromPool(/obj/item/weapon/shard, get_turf(src)) // Create a glass shard at the hit location!
	qdel(src)

/obj/item/ornament/red
	name = "red ornament"
	desc = "A glass ornament with a deep red color. It's just not Christmas without some of these."
	icon_state = "red_ball_ornament"

/obj/item/ornament/blue
	name = "blue ornament"
	desc = "A glass ornament with a deep blue color."
	icon_state = "blue_ball_ornament"

/obj/item/ornament/green
	name = "green ornament"
	desc = "A glass ornament with a vibrant green color. It's just not Christmas without some of these."
	icon_state = "green_ball_ornament"

/obj/item/ornament/purple
	name = "purple ornament"
	desc = "A glass ornament with a deep purple color."
	icon_state = "purple_ball_ornament"

/obj/item/ornament/magenta
	name = "magenta ornament"
	desc = "A glass ornament with a soft magenta color."
	icon_state = "magenta_ball_ornament"

/obj/item/ornament/orange
	name = "orange ornament"
	desc = "A glass ornament with a deep orange color."
	icon_state = "orange_ball_ornament"

/obj/item/ornament/silver
	name = "silver ornament"
	desc = "A glass ornament with a brilliant silver color. Best paired with gold ornaments."
	icon_state = "silver_ball_ornament"

/obj/item/ornament/gold
	name = "gold ornament"
	desc = "A glass ornament with a brilliant gold color. Best paired with silver ornaments."
	icon_state = "gold_ball_ornament"

/obj/item/ornament/teardrop
	name = "teardrop ornament"
	desc = "A teardrop-shaped glass ornament. The long point on the end is reminiscent of an icicle."
	icon = 'icons/obj/teardrop_ornaments.dmi'
	icon_state = "white_teardrop_ornament"
	ornaments_list = list("red" = /obj/item/ornament/teardrop/red,
						"blue" = /obj/item/ornament/teardrop/blue,
						"green" = /obj/item/ornament/teardrop/green,
						"purple" = /obj/item/ornament/teardrop/purple,
						"orange" = /obj/item/ornament/teardrop/orange,
						"yellow" = /obj/item/ornament/teardrop/gold,
						"rainbow" = /obj/item/ornament/teardrop/magenta,
						"gray" = /obj/item/ornament/teardrop/silver)

/obj/item/ornament/teardrop/red
	name = "red teardrop ornament"
	desc = "A teardrop-shaped glass ornament with a deep red color. It's just not Christmas without some of these."
	icon_state = "red_teardrop_ornament"

/obj/item/ornament/teardrop/blue
	name = "blue teardrop ornament"
	desc = "A teardrop-shaped glass ornament with a deep blue color. It evokes the image of dripping water."
	icon_state = "blue_teardrop_ornament"

/obj/item/ornament/teardrop/green
	name = "green teardrop ornament"
	desc = "A teardrop-shaped glass ornament with a vibrant green color. It's just not Christmas without some of these."
	icon_state = "green_teardrop_ornament"

/obj/item/ornament/teardrop/purple
	name = "purple teardrop ornament"
	desc = "A teardrop-shaped glass ornament with a deep purple color."
	icon_state = "purple_teardrop_ornament"

/obj/item/ornament/teardrop/magenta
	name = "magenta teardrop ornament"
	desc = "A teardrop-shaped glass ornament with a soft magenta color."
	icon_state = "magenta_teardrop_ornament"

/obj/item/ornament/teardrop/orange
	name = "orange teardrop ornament"
	desc = "A teardrop-shaped glass ornament with a deep orange color."
	icon_state = "orange_teardrop_ornament"

/obj/item/ornament/teardrop/silver
	name = "silver teardrop ornament"
	desc = "A teardrop-shaped glass ornament with a brilliant silver color. Best paired with gold teardrop ornaments."
	icon_state = "silver_teardrop_ornament"

/obj/item/ornament/teardrop/gold
	name = "gold teardrop ornament"
	desc = "A teardrop-shaped glass ornament with a brilliant gold color. Best paired with silver teardrop ornaments."
	icon_state = "gold_teardrop_ornament"

/obj/item/ornament/topper
	name = "star topper"
	desc = "A star-shaped tree topper. Appropriate for a Christmas in space."
	icon_state = "star_topper"