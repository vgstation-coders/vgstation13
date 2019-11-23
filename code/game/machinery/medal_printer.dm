/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/medal_printer
	name = "medal printer"
	desc = "Prints a variety of medal accessories."
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "medalprinter"
	icon_state_open = "medalprinter_t"
	nano_file = "medalprinter.tmpl"
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EMAGGABLE
	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS | HASMAT_OVER
	var/locked = 1

	allowed_materials = list(
						MAT_IRON,
						MAT_GOLD,
						MAT_SILVER,
						MAT_PLASMA
	)

	part_sets = list(
		"Standard_Medals"=list(
		new /obj/item/clothing/accessory/medal/participation(), \
		new /obj/item/clothing/accessory/medal/silver(), \
		new /obj/item/clothing/accessory/medal/gold(), \
		),
		"Unique_Medals"=list(
		new /obj/item/clothing/accessory/medal/conduct(), \
		new /obj/item/clothing/accessory/medal/bronze_heart(), \
		new /obj/item/clothing/accessory/medal/silver/valor(), \
		new /obj/item/clothing/accessory/medal/silver/security(), \
		new /obj/item/clothing/accessory/medal/gold/captain(), \
		new /obj/item/clothing/accessory/medal/gold/heroism(), \
		new /obj/item/clothing/accessory/medal/nobel_science(), \
		))

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/medal_printer/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/medal_printer,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)
	RefreshParts()

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/medal_printer/attack_hand(mob/user as mob)
	if((locked == 1) && (emagged == 0))
		to_chat(usr, "[src] is locked.")
		return
	..()

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/medal_printer/attackby(var/obj/item/O, var/mob/user)
	. = ..()

	if(issilicon(user))
		return

	if(istype(O, /obj/item/weapon/card/emag))
		machine_flags &= ~EMAGGABLE
		emagged = 1
		new/obj/effect/effect/sparks(get_turf(src))
		playsound(loc,"sparks",50,1)

	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = O
		if(emagged == 1)
			to_chat(usr, "[src] does not respond to the ID.")
			return
		if((access_captain in I.access) || (access_hop in I.access))
			locked = !locked
			if(locked == 1)
				to_chat(usr, "You lock \the [src].")
			else
				to_chat(usr, "You unlock \the [src].")

	if((locked == 1) && (emagged == 0))
		return

	if(istype(O, /obj/item/clothing/accessory/medal))
		O.name = sanitize((input(user, "What would you like to label \the [O]?", "Medal Labelling", null)  as text), 1, MAX_NAME_LEN)
		if((loc == usr && usr.isUnconscious()))
			O.name = "medal"
		add_fingerprint(usr)