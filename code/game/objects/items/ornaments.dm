/obj/item/ornament
	name = "ornament"
	desc = "A glass ornament. What some would call plain, others call elegant."
	icon = 'icons/obj/ball_ornaments.dmi'
	icon_state = "white_ball_ornament"
	w_class = 2

/obj/item/ornament/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(src, /obj/item/ornament/teardrop))
		return
	if(istype(W, /obj/item/toy/crayon) || istype(W, /obj/item/weapon/pen))
		var/obj/item/ornament/O
		var/color_string = null
		if(istype(W, /obj/item/toy/crayon))
			var/obj/item/toy/crayon/C = W
			switch(C.colourName)
				if("red")
					O = new /obj/item/ornament/red(get_turf(src))
				if("blue")
					O = new /obj/item/ornament/blue(get_turf(src))
				if("green")
					O = new /obj/item/ornament/green(get_turf(src))
				if("purple")
					O = new /obj/item/ornament/purple(get_turf(src))
				if("orange")
					O = new /obj/item/ornament/orange(get_turf(src))
				if("yellow")
					O = new /obj/item/ornament/gold(get_turf(src))
					color_string = "gold"
				if("rainbow")
					O = new /obj/item/ornament/magenta(get_turf(src))
					color_string = "a deep pink"
				else
					return
			if(!color_string)
				color_string = C.colourName
		else
			O = new /obj/item/ornament/silver(get_turf(src))
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

/obj/item/ornament/teardrop/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/toy/crayon) || istype(W, /obj/item/weapon/pen))
		var/obj/item/ornament/teardrop/O
		var/color_string = null
		if(istype(W, /obj/item/toy/crayon))
			var/obj/item/toy/crayon/C = W
			switch(C.colourName)
				if("red")
					O = new /obj/item/ornament/teardrop/red(get_turf(src))
				if("blue")
					O = new /obj/item/ornament/teardrop/blue(get_turf(src))
				if("green")
					O = new /obj/item/ornament/teardrop/green(get_turf(src))
				if("purple")
					O = new /obj/item/ornament/teardrop/purple(get_turf(src))
				if("orange")
					O = new /obj/item/ornament/teardrop/orange(get_turf(src))
				if("yellow")
					O = new /obj/item/ornament/teardrop/gold(get_turf(src))
					color_string = "gold"
				if("rainbow")
					O = new /obj/item/ornament/teardrop/magenta(get_turf(src))
					color_string = "a deep pink"
				else
					return
			if(!color_string)
				color_string = C.colourName
		else
			O = new /obj/item/ornament/teardrop/silver(get_turf(src))
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