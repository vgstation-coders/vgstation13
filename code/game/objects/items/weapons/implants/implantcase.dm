/obj/item/weapon/implantcase
	name = "Glass Case"
	desc = "A case containing an implant."
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/obj/item/weapon/implant/imp = null

/obj/item/weapon/implantcase/proc/update()
	if (src.imp)
		src.icon_state = text("implantcase-[]", src.imp._color)
	else
		src.icon_state = "implantcase-0"
	return

/obj/item/weapon/implantcase/attackby(obj/item/I as obj, mob/user as mob)
	..()
	if (istype(I, /obj/item/weapon/pen))
		set_tiny_label(user, " - '", "'")
	else if (istype(I, /obj/item/weapon/implanter))
		var/obj/item/weapon/implanter/the_implanter = I
		if (the_implanter.imp)
			if (src.imp || the_implanter.imp.implanted)
				return
			the_implanter.imp.forceMove(src)
			src.imp = the_implanter.imp
			the_implanter.imp = null

			src.update()
			the_implanter.update()
		else if (src.imp)
			src.imp.forceMove(I)
			the_implanter.imp = src.imp
			src.imp = null

			src.update()
			the_implanter.update()

/obj/item/weapon/implantcase/on_syringe_injection(var/mob/user, var/obj/item/weapon/reagent_containers/syringe/tool)
	if(!src.imp || !src.imp.allow_reagents)
		return INJECTION_RESULT_FAIL
	if(src.imp.reagents.total_volume >= src.imp.reagents.maximum_volume)
		to_chat(user, "<span class='warning'>[src] is full.</span>")
		return INJECTION_RESULT_FAIL
	var/tx_amount = min(tool.amount_per_transfer_from_this, tool.reagents.total_volume)
	tx_amount = tool.reagents.trans_to(src.imp, tx_amount, log_transfer = TRUE, whodunnit = user)
	to_chat(user, "<span class='notice'>You inject [tx_amount] units of the solution. \The [tool] now contains [tool.reagents.total_volume] units.</span>")
	return INJECTION_RESULT_SUCCESS_BUT_SKIP_REAGENT_TRANSFER

/obj/item/weapon/implantcase/tracking
	name = "Glass Case- 'Tracking'"
	desc = "A case containing a tracking implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/tracking/New()
		src.imp = new /obj/item/weapon/implant/tracking( src )
		..()
		return

/obj/item/weapon/implantcase/explosive
	name = "Glass Case- 'Explosive'"
	desc = "A case containing an explosive implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/explosive/New()
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


/obj/item/weapon/implantcase/loyalty/New()
	src.imp = new /obj/item/weapon/implant/loyalty( src )
	..()
	return


/obj/item/weapon/implantcase/death_alarm
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/death_alarm/New()
	src.imp = new /obj/item/weapon/implant/death_alarm( src )
	..()
	return

/obj/item/weapon/implantcase/peace
	name = "glass case- 'Pax'"
	desc = "A case containing a peace-inducing implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/peace/New()
	src.imp = new /obj/item/weapon/implant/peace(src)
	..()
