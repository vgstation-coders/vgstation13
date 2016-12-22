

/obj/item/weapon/implantcase
	name = "Glass Case"
	desc = "A case containing an implant."
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/obj/item/weapon/implant/imp = null
	proc
		update()


	update()
		if (src.imp)
			src.icon_state = text("implantcase-[]", src.imp._color)
		else
			src.icon_state = "implantcase-0"
		return


	attackby(obj/item/weapon/I as obj, mob/user as mob)
		..()
		if (istype(I, /obj/item/weapon/pen))
			set_tiny_label(user, " - '", "'")
		else if(istype(I, /obj/item/weapon/reagent_containers/syringe))
			if(!src.imp)
				return
			if(!src.imp.allow_reagents)
				return
			if(src.imp.reagents.total_volume >= src.imp.reagents.maximum_volume)
				to_chat(user, "<span class='warning'>[src] is full.</span>")
			else
				spawn(5)
					I.reagents.trans_to(src.imp, 5)
					to_chat(user, "<span class='notice'>You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units.</span>")
		else if (istype(I, /obj/item/weapon/implanter))
			if (I:imp)
				if ((src.imp || I:imp.implanted))
					return
				I:imp.forceMove(src)
				src.imp = I:imp
				I:imp = null
				src.update()
				I:update()
			else
				if (src.imp)
					if (I:imp)
						return
					src.imp.forceMove(I)
					I:imp = src.imp
					src.imp = null
					update()
				I:update()
		return



/obj/item/weapon/implantcase/tracking
	name = "Glass Case- 'Tracking'"
	desc = "A case containing a tracking implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"


	New()
		src.imp = new /obj/item/weapon/implant/tracking( src )
		..()
		return



/obj/item/weapon/implantcase/explosive
	name = "Glass Case- 'Explosive'"
	desc = "A case containing an explosive implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"


	New()
		src.imp = new /obj/item/weapon/implant/explosive( src )
		..()
		return



/obj/item/weapon/implantcase/chem
	name = "Glass Case- 'Chem'"
	desc = "A case containing a chemical implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"
/obj/item/weapon/implantcase/chem/New()

	src.imp = new /obj/item/weapon/implant/chem( src )
	..()
	return


/obj/item/weapon/implantcase/loyalty
	name = "Glass Case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"


	New()
		src.imp = new /obj/item/weapon/implant/loyalty( src )
		..()
		return


/obj/item/weapon/implantcase/death_alarm
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

	New()
		src.imp = new /obj/item/weapon/implant/death_alarm( src )
		..()
		return
