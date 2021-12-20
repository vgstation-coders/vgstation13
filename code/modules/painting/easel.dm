/obj/structure/easel
	name = "easel"
	desc = ""
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "easel"
	density = 1
	var/obj/item/mounted/frame/painting/painting = null


/obj/structure/easel/Destroy()
	//remove/destroy painting
	..()

/obj/structure/easel/attackby(obj/item/I, mob/user)

	// Deconstruct
	if (I.is_wrench(user))

		return

	// Place painting
	if (istype(I, /obj/item/mounted/frame/painting/))
		return

	..()