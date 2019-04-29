/obj/structure/curtain
	name = "curtain"
	icon = 'icons/obj/curtain.dmi'
	icon_state = "closed"
	opacity = 1
	density = 0
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	var/ctype = 1
	var/holo = FALSE

/obj/structure/curtain/closed/left
	ctype = 2

/obj/structure/curtain/closed/right
	ctype = 3

/obj/structure/curtain/open
	icon_state = "open_1"
	opacity = 0
	ctype = 1

/obj/structure/curtain/open/left
	icon_state = "open_2"
	ctype = 2

/obj/structure/curtain/open/right
	icon_state = "open_3"
	ctype = 3

/obj/structure/curtain/bullet_act(obj/item/projectile/P, def_zone)
	if(!P.nodamage)
		visible_message("<span class='warning'>[P] tears \the [src] down!</span>")
		qdel(src)
	else
		..()

/obj/structure/curtain/attack_hand(mob/user)
	playsound(loc, "rustle", 15, 1, -5)
	toggle()
	..()

/obj/structure/curtain/proc/toggle()
	opacity = !opacity
	if(opacity)
		icon_state = "closed"
		layer = CLOSED_CURTAIN_LAYER
	else
		icon_state = "open_[ctype]"
		layer = OPEN_CURTAIN_LAYER

/obj/structure/curtain/attackby(obj/item/W, mob/user)
	if(iswirecutter(W))
		playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
		if(do_after(user, src, 10))
			to_chat(user, "<span class='notice'>You cut \the [src] down.</span>")
			if(!holo)
				getFromPool(/obj/item/stack/sheet/mineral/plastic, get_turf(src), 4)
			qdel(src)
		return 1
	if(W.is_screwdriver(user))
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		user.visible_message("[user] [anchored? "unsecures" : "secures"] \the [src].", "You [anchored? "unsecure" : "secure"] \the [src].")
		anchored = !anchored
		return 1
	src.attack_hand(user)

/obj/structure/curtain/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/black/holo
	holo = TRUE

/obj/structure/curtain/medical
	name = "plastic curtain"
	color = "#B8F5E3"
	alpha = 200

/obj/structure/curtain/open/bed
	name = "bed curtain"
	color = "#854636"

/obj/structure/curtain/open/privacy
	name = "privacy curtain"
	color = "#B8F5E3"

/obj/structure/curtain/open/shower
	name = "shower curtain"
	color = "#ACD1E9"
	alpha = 200

/obj/structure/curtain/open/shower/left
	icon_state = "open_2"
	ctype = 2

/obj/structure/curtain/open/shower/right
	icon_state = "open_3"
	ctype = 3

/obj/structure/curtain/open/shower/engineering
	color = "#FFA500"

/obj/structure/curtain/open/shower/medical
	color = "#B8F5E3"

/obj/structure/curtain/open/shower/security
	color = "#AA0000"
