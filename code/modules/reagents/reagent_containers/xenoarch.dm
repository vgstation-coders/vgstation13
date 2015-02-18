/obj/item/weapon/reagent_containers/glass/solution_tray
	name = "solution tray"
	desc = "A small, open-topped glass container for delicate research samples. It sports a re-useable strip for labelling with a pen."
	icon = 'icons/obj/device.dmi'
	icon_state = "solution_tray"
	m_amt = 0
	g_amt = 50
	w_type = RECYK_GLASS
	w_class = 1.0
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 2)
	volume = 2
	flags = FPRINT | OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/solution_tray/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/weapon/pen))
		var/new_label = input("What should the new label be?","Label solution tray")
		if(new_label)
			name = "solution tray ([new_label])"
			user << "\blue You write on the label of the solution tray."
	else
		..(W, user)

/obj/item/weapon/storage/box/solution_trays
	name = "solution tray box"
	icon_state = "solution_trays"

/obj/item/weapon/storage/box/solution_trays/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
	new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
	new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
	new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
	new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
	new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
	new /obj/item/weapon/reagent_containers/glass/solution_tray( src )

/obj/item/weapon/reagent_containers/glass/beaker/tungsten
	name = "beaker 'tungsten'"

/obj/item/weapon/reagent_containers/glass/beaker/tungsten/New()
	..()
	reagents.add_reagent("tungsten",50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/oxygen
	name = "beaker 'oxygen'"

/obj/item/weapon/reagent_containers/glass/beaker/oxygen/New()
	..()
	reagents.add_reagent("oxygen",50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/sodium
	name = "beaker 'sodium'"

/obj/item/weapon/reagent_containers/glass/beaker/sodium/New()
	..()
	reagents.add_reagent("sodium",50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/lithium
	name = "beaker 'lithium'"

/obj/item/weapon/reagent_containers/glass/beaker/lithium/New()
	..()
	reagents.add_reagent("lithium",50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/water
	name = "beaker 'water'"

/obj/item/weapon/reagent_containers/glass/beaker/water/New()
	..()
	reagents.add_reagent("water",50)
	update_icon()

	..()
	reagents.add_reagent("water",50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/water
	name = "beaker 'water'"

/obj/item/weapon/reagent_containers/glass/beaker/water/New()
	..()
	reagents.add_reagent("water",50)
	update_icon()

	..()
	reagents.add_reagent("water",50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/fuel
	name = "beaker 'fuel'"

/obj/item/weapon/reagent_containers/glass/beaker/fuel/New()
	..()
	reagents.add_reagent("fuel",50)
	update_icon()

