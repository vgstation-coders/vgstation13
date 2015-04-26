/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"
	species_fit = list("Vox")

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	item_state = "boxinggreen"
	species_fit = list("Vox")

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	item_state = "boxingblue"
	species_fit = list("Vox")

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	item_state = "boxingyellow"
	species_fit = list("Vox")

/obj/item/clothing/gloves/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	item_state = "whitegloves"
	_color="mime"
	species_fit = list("Vox")

/obj/item/clothing/gloves/white/stunglove // For Clown Planet's mimes. - N3X
	New()
		..()
		cell = new /obj/item/weapon/cell/crap/empty(src)
