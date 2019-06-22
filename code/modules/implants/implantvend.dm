/obj/machinery/vending/implant
	name = "\improper ImplantVend"
	desc = "A vending machine filled with a wide variety of implants."
	req_access = list(access_security)
	product_ads = list(
		"Motivate! Motivate! Motivate!",
		"The good stuff is in the back.",
		"Ahem. Fuck revolutionaries, and fuck the occult!",
		"Loyalty implants will pay themselves off in increased productivity!",
		"I'm sure you've got lots of spare cash! Put it in!",
		"There doesn't need to be subversive elements for you to implant!",
		"Become a beast today! Fill your body with perfectly legal amounts of adrenalin!"
	)
	icon_state = "implant"
	icon_vend = "implant-vend"
	vend_delay = 13 //32 is total time, 13 is time for animation to open the drawer thingy
	products = list(
		/obj/item/weapon/implanter = 3,
		/obj/item/weapon/implantcase/loyalty = 5,
		/obj/item/weapon/implantcase/tracking = 4,
		/obj/item/weapon/implantcase/exile = 2
		)
	contraband = list(
		/obj/item/weapon/implantcase/peace = 2,
		)
	premium = list(
		/obj/item/weapon/implantcase/adrenalin = 1
		)
		
	pack = /obj/structure/vendomatpack/implant
	
/obj/structure/vendomatpack/implant
	name = "ImplantVend recharge pack"
	targetvendomat = /obj/machinery/vending/implant
	icon_state = "sec"