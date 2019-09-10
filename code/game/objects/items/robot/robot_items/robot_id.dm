/obj/item/weapon/card/robot //This is not a child of id cards, as to avoid dumb typechecks on computers. Ported from bay's research cyborg.
	name = "access code transmission device"
	icon_state = "id-robot"
	desc = "A circuit grafted onto the bottom of an ID card."

//Warden upgrade's peacekeeper barrier ID
/obj/item/weapon/card/robot/peacekeeper
	name = "security code transmission device"

/obj/item/weapon/card/robot/peacekeeper/New()
	..()
	desc += " This one is used to transmit security codes into deployable barriers, allowing the user to lock and unlock them."