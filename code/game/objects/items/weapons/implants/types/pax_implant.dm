/obj/item/weapon/implant/peace
	name = "pax implant"
	desc = "A bean-shaped implant with a single embossed word - PAX - on it."
	var/imp_alive = 0
	var/imp_msg_debounce = 0

/obj/item/weapon/implant/peace/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Pax Implant<BR>
<b>Manufacturer:</b> Ouroboros Medical<BR>
<b>Effect:</b> Makes the host incapable of committing violent acts.
<b>Important Notes:</b> Effect accomplished by paralyzing parts of the brain. This effect is neutralized by 15u or greater of Methylin.<BR>
<b>Life:</b> Sustained as long as it remains within a host. Survives on the host's nutrition. Dies upon removal.<BR>
"}

/obj/item/weapon/implant/peace/meltdown()
	visible_message("<span class='warning'>\The [src] releases a dying hiss as it denatures!</span>")
	name = "denatured implant"
	desc = "A dead, hollow implant. Wonder what it used to be..."
	icon_state = "implant_melted"
	malfunction = IMPLANT_MALFUNCTION_PERMANENT

/obj/item/weapon/implant/peace/process()
	var/mob/living/carbon/host = imp_in

	if (isnull(host) && imp_alive)
		malfunction = IMPLANT_MALFUNCTION_PERMANENT

	if (malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		meltdown()
		processing_objects.Remove(src)
		return

	if (!isnull(host) && !imp_alive)
		imp_alive = 1

	if (host.nutrition <= 0 || host.reagents.has_reagent(METHYLIN, 15))
		malfunction = IMPLANT_MALFUNCTION_TEMPORARY
	else
		malfunction = 0

	if (!imp_msg_debounce && malfunction == IMPLANT_MALFUNCTION_TEMPORARY)
		imp_msg_debounce = 1
		to_chat(host, "<span class='warning'>Your rage bubbles, \the [src] inside you is being suppressed!</span>")

	if (imp_msg_debounce && !malfunction)
		imp_msg_debounce = 0
		to_chat(host, "<span class='warning'>Your rage cools, \the [src] inside you is active!</span>")

	if (!malfunction)
		host.nutrition = max(host.nutrition - 0.15,0)


/obj/item/weapon/implant/peace/insert(mob/living/target, target_limb, mob/implanter)
	if(imp_alive) // ?
		return FALSE
	return ..()

/obj/item/weapon/implant/peace/implanted(mob/implanter)
	processing_objects += src
	to_chat(imp_in, "<span class='warning'>You feel your desire to harm anyone slowly drift away...</span>")

/obj/item/weapon/implant/peace/handle_removal(mob/remover)
	meltdown()
