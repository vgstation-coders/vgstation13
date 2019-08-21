/obj/item/weapon/implantcase
	name = "glass case"
	desc = "A hardened case containing an implant."
	icon_state = "implantcase-blue"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/obj/item/weapon/implant/held_implant = null
	var/implant_path = null
	
/obj/item/weapon/implantcase/New()
	..()
	held_implant = new implant_path(src)
	
/obj/item/weapon/implantcase/update_icon()
	if(held_implant)
		icon_state = text("implantcase-[held_implant.case_color]")
	else
		icon_state = "implantcase-empty"

/obj/item/weapon/implantcase/attackby(obj/item/item, mob/user)
	..()
	if(istype(item, /obj/item/weapon/pen))
		set_tiny_label(user, " - '", "'")
	else if(istype(item, /obj/item/weapon/implanter))
		var/obj/item/weapon/implanter/implanter = item
		if(implanter.held_implant)
			if(held_implant || implanter.held_implant.implant_status)
				return

			implanter.held_implant.forceMove(src) //If the implanter is full and the case is empty, put the implant back in the case.
			held_implant = implanter.held_implant
			implanter.held_implant = null

			update_icon()
			implanter.update_icon()
		else if(held_implant)
			held_implant.forceMove(implanter) //If the implanter is empty and the case is full, put the implant into the implanter.
			implanter.held_implant = held_implant
			held_implant = null

			update_icon()
			implanter.update_icon()

/obj/item/weapon/implantcase/on_syringe_injection(var/mob/user, var/obj/item/weapon/reagent_containers/syringe/tool)
	if(!held_implant || !held_implant.allow_reagents)
		return INJECTION_RESULT_FAIL
	if(held_implant.reagents.total_volume >= held_implant.reagents.maximum_volume)
		to_chat(user, "<span class='warning'>[src] is full.</span>")
		return INJECTION_RESULT_FAIL
	var/tx_amount = min(tool.amount_per_transfer_from_this, tool.reagents.total_volume)
	tx_amount = tool.reagents.trans_to(held_implant, tx_amount, log_transfer = TRUE, whodunnit = user)
	to_chat(user, "<span class='notice'>You inject [tx_amount] units of the solution. \The [tool] now contains [tool.reagents.total_volume] units.</span>")
	return INJECTION_RESULT_SUCCESS_BUT_SKIP_REAGENT_TRANSFER

/obj/item/weapon/implantcase/tracking
	name = "Glass Case- 'Tracking'"
	desc = "A case containing a tracking implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-blue"
	implant_path = /obj/item/weapon/implant/tracking

/obj/item/weapon/implantcase/explosive
	name = "Glass Case- 'Explosive'"
	desc = "A case containing an explosive implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-red"
	implant_path = /obj/item/weapon/implant/explosive

/obj/item/weapon/implantcase/chem
	name = "Glass Case- 'Chem'"
	desc = "A case containing a chemical implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-blue"
	implant_path = /obj/item/weapon/implant/chem

/obj/item/weapon/implantcase/loyalty
	name = "Glass Case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-blue"
	implant_path = /obj/item/weapon/implant/loyalty

/obj/item/weapon/implantcase/death_alarm
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	icon = 'icons/obj/items.dmi'
	implant_path = /obj/item/weapon/implant/death_alarm

/obj/item/weapon/implantcase/peace
	name = "glass case- 'Pax'"
	desc = "A case containing a Pax implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-blue"
	implant_path = /obj/item/weapon/implant/peace
	
/obj/item/weapon/implantcase/adrenalin
	name = "glass case- 'Adrenalin'"
	desc = "A case containing an Adrenalin implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-blue"
	implant_path = /obj/item/weapon/implant/adrenalin