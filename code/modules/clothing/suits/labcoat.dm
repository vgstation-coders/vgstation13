/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	var/base_icon_state = "labcoat"
	var/open=1
	//icon_state = "labcoat_open"
	item_state = "labcoat"
	blood_overlay_type = "coat"
	allowed = list(/obj/item/roller, /obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/antibody_scanner,/obj/item/device/flashlight/pen,/obj/item/weapon/minihoe,/obj/item/weapon/switchtool)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	sterility = 40

/obj/item/clothing/suit/storage/labcoat/update_icon()
	if(open)
		icon_state="[base_icon_state]_open"
	else
		icon_state="[base_icon_state]"

/obj/item/clothing/suit/storage/labcoat/verb/toggle()
	set name = "Toggle Labcoat Buttons"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return 0

	if(open)
		to_chat(usr, "You button up the labcoat.")
		src.body_parts_covered |= IGNORE_INV
		sterility = initial(sterility)+30
	else
		to_chat(usr, "You unbutton the labcoat.")
		src.body_parts_covered ^= IGNORE_INV
		sterility = initial(sterility)
	open=!open
	update_icon()
	usr.update_inv_wear_suit()	//so our overlays update

/obj/item/clothing/suit/storage/labcoat/New()
	. = ..()
	update_icon()

/obj/item/clothing/suit/storage/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	base_icon_state = "labcoat_cmo"
	item_state = "labcoat_cmo"
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/antibody_scanner,/obj/item/device/flashlight/pen,/obj/item/weapon/minihoe,/obj/item/weapon/switchtool,/obj/item/roller)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 70, rad = 0)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	sterility = 50

/obj/item/clothing/suit/storage/labcoat/mad
	name = "The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	base_icon_state = "labgreen"
	item_state = "labgreen"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/storage/labcoat/genetics
	name = "geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	base_icon_state = "labcoat_gen"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/suit/storage/labcoat/chemist
	name = "chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	base_icon_state = "labcoat_chem"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/suit/storage/labcoat/virologist
	name = "virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	base_icon_state = "labcoat_vir"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 0)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	sterility = 50

/obj/item/clothing/suit/storage/labcoat/science
	name = "scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	base_icon_state = "labcoat_tox"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/suit/storage/labcoat/oncologist
	name = "oncologist labcoat"
	desc = "A suit that protects against minor radiation exposure. Offers slightly more protection against radiation than the standard model. Has a black stripe on the shoulder."
	base_icon_state = "labcoat_onc"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 60)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/suit/storage/labcoat/rd
	name = "research director's labcoat"
	desc = "It smells like weird science."
	base_icon_state = "labcoat_rd"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 20, bio = 50, rad = 50)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	sterility = 50
