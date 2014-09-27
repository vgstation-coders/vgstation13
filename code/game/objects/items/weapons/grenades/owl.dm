/obj/item/weapon/grenade/chem_grenade/owl
	name = "Owl Smokebomb"
	desc = "HOOT HOOT!"
	icon_state = "owl"
	item_state = "owl"
	stage = 2
	path = 1

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("sugar", 20)
		B2.reagents.add_reagent("phosphorus", 20)
		B2.reagents.add_reagent("potassium", 20)

		detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

		beakers += B1
		beakers += B2
		icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/grenade/flashbang/owl
	name = "Owl Flashbang"
	desc = "HOOT HOOT!"
	icon_state = "owl"
	item_state = "owl"
