/obj/item/implantcase
	name = "Glass Case"
	desc = "A case containing an implant."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/obj/item/implant/imp = null

/obj/item/implantcase/proc/update()
	if (src.imp)
		src.icon_state = text("implantcase-[]", src.imp._color)
	else
		src.icon_state = "implantcase-0"
	return

/obj/item/implantcase/attackby(obj/item/I as obj, mob/user as mob)
	..()
	if (istype(I, /obj/item/pen))
		set_tiny_label(user, " - '", "'")
	else if (istype(I, /obj/item/implanter))
		var/obj/item/implanter/the_implanter = I
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

/obj/item/implantcase/on_syringe_injection(var/mob/user, var/obj/item/reagent_containers/syringe/tool)
	if(!src.imp || !src.imp.allow_reagents)
		return INJECTION_RESULT_FAIL
	if(src.imp.reagents.total_volume >= src.imp.reagents.maximum_volume)
		to_chat(user, "<span class='warning'>[src] is full.</span>")
		return INJECTION_RESULT_FAIL
	var/tx_amount = min(tool.amount_per_transfer_from_this, tool.reagents.total_volume)
	tx_amount = tool.reagents.trans_to(src.imp, tx_amount, log_transfer = TRUE, whodunnit = user)
	to_chat(user, "<span class='notice'>You inject [tx_amount] units of the solution. \The [tool] now contains [tool.reagents.total_volume] units.</span>")
	return INJECTION_RESULT_SUCCESS_BUT_SKIP_REAGENT_TRANSFER

/obj/item/implantcase/tracking
	name = "Glass Case- 'Tracking'"
	desc = "A case containing a tracking implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/implantcase/tracking/New()
		src.imp = new /obj/item/implant/tracking( src )
		..()
		return

/obj/item/implantcase/explosive
	name = "Glass Case- 'Explosive'"
	desc = "A case containing an explosive implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/implantcase/explosive/New()
		src.imp = new /obj/item/implant/explosive( src )
		..()
		return


/obj/item/implantcase/chem
	name = "Glass Case- 'Chem'"
	desc = "A case containing a chemical implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/implantcase/chem/New()
	src.imp = new /obj/item/implant/chem( src )
	..()
	return


/obj/item/implantcase/loyalty
	name = "Glass Case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"


/obj/item/implantcase/loyalty/New()
	src.imp = new /obj/item/implant/loyalty( src )
	..()
	return


/obj/item/implantcase/death_alarm
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/implantcase/death_alarm/New()
	src.imp = new /obj/item/implant/death_alarm( src )
	..()
	return

/obj/item/implantcase/peace
	name = "glass case- 'Pax'"
	desc = "A case containing a peace-inducing implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/implantcase/peace/New()
	src.imp = new /obj/item/implant/peace(src)
	..()
