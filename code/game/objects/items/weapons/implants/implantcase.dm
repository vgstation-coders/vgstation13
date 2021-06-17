/obj/item/weapon/implantcase
	name = "Glass Case"
	desc = "A case containing an implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/obj/item/weapon/implant/imp = null

/obj/item/weapon/implantcase/proc/update()
	desc = initial(desc)
	if (imp)
		icon_state = text("implantcase-[]", imp._color)
		desc += "<br>It is loaded with a [imp.name]."
	else
		icon_state = "implantcase-0"

/obj/item/weapon/implantcase/attackby(obj/item/I as obj, mob/user as mob)
	..()
	if (istype(I, /obj/item/weapon/pen))
		set_tiny_label(user, " - '", "'")
	else if (istype(I, /obj/item/weapon/implant) && !imp)
		var/obj/item/weapon/implant/timp = I
		if(timp.malfunction == IMPLANT_MALFUNCTION_PERMANENT)
			user.show_message("<span class='warning'>You can't load a broken implant back into a case.</span>")
			return 0
		user.drop_item(timp, force_drop = 1)
		if(timp.implanted) 
			timp.implanted = null
		if(timp.implanted) 
			timp.imp_in = null
		timp.forceMove(src)
		user.show_message("<span class='warning'>You load \the [timp] into \the [src].</span>")
		imp = timp
		update()
	else if (istype(I, /obj/item/weapon/implanter))
		var/obj/item/weapon/implanter/the_implanter = I
		if (the_implanter.imp)
			if (imp || the_implanter.imp.implanted)
				return
			the_implanter.imp.forceMove(src)
			imp = the_implanter.imp
			the_implanter.imp = null

			update()
			the_implanter.update()
		else if (imp)
			imp.forceMove(I)
			the_implanter.imp = imp
			imp = null

			update()
			the_implanter.update()

/obj/item/weapon/implantcase/on_syringe_injection(var/mob/user, var/obj/item/weapon/reagent_containers/syringe/tool)
	if(!imp || !imp.allow_reagents)
		return INJECTION_RESULT_FAIL
	if(imp.reagents.total_volume >= imp.reagents.maximum_volume)
		to_chat(user, "<span class='warning'>[src] is full.</span>")
		return INJECTION_RESULT_FAIL
	var/tx_amount = min(tool.amount_per_transfer_from_this, tool.reagents.total_volume)
	tx_amount = tool.reagents.trans_to(imp, tx_amount, log_transfer = TRUE, whodunnit = user)
	to_chat(user, "<span class='notice'>You inject [tx_amount] units of the solution. \The [tool] now contains [tool.reagents.total_volume] units.</span>")
	return INJECTION_RESULT_SUCCESS_BUT_SKIP_REAGENT_TRANSFER

/obj/item/weapon/implantcase/tracking
	name = "Glass Case- 'Tracking'"
	desc = "A case containing a tracking implant."
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/tracking/New()
	imp = new /obj/item/weapon/implant/tracking(src)
	..()

/obj/item/weapon/implantcase/explosive
	name = "Glass Case- 'Explosive'"
	desc = "A case containing an explosive implant."
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/explosive/New()
	imp = new /obj/item/weapon/implant/explosive(src)
	..()


/obj/item/weapon/implantcase/chem
	name = "Glass Case- 'Chem'"
	desc = "A case containing a chemical implant."
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/chem/New()
	imp = new /obj/item/weapon/implant/chem(src)
	..()

/obj/item/weapon/implantcase/remote
	name = "Glass Case- 'Chem'"
	desc = "A case containing a \"chemical\" implant."
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/remote/New()
	imp = new /obj/item/weapon/implant/explosive/remote(src)
	..()


/obj/item/weapon/implantcase/loyalty
	name = "Glass Case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	icon_state = "implantcase-r"


/obj/item/weapon/implantcase/loyalty/New()
	imp = new /obj/item/weapon/implant/loyalty(src)
	..()


/obj/item/weapon/implantcase/death_alarm
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/death_alarm/New()
	imp = new /obj/item/weapon/implant/death_alarm(src)
	..()

/obj/item/weapon/implantcase/peace
	name = "glass case- 'Pax'"
	desc = "A case containing a peace-inducing implant."
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/peace/New()
	imp = new /obj/item/weapon/implant/peace(src)
	..()


/obj/item/weapon/implantcase/holy
	name = "Glass Case- 'Holy'"
	desc = "A case containing a holy implant."
	icon_state = "implantcase-o"


/obj/item/weapon/implantcase/holy/New()
	imp = new /obj/item/weapon/implant/holy(src)
	..()
