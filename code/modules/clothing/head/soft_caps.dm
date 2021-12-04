/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "cargosoft"
	flags = FPRINT
	item_state = "helmet"
	_color = "cargo"
	var/flipped = 0
	siemens_coefficient = 0.9
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/proc/flip(var/mob/user as mob)
	if(!user.incapacitated())
		src.flipped = !src.flipped
		if(src.flipped)
			icon_state = "[_color]soft_flipped"
			to_chat(user, "You flip the hat backwards.")
		else
			icon_state = "[_color]soft"
			to_chat(user, "You flip the hat back in normal position.")
		user.update_inv_head()	//so our mob-overlays update

/obj/item/clothing/head/soft/attack_self(var/mob/user as mob)
	flip(user)

/obj/item/clothing/head/soft/verb/flip_cap()
	set category = "Object"
	set name = "Flip cap"
	set src in usr
	flip(usr)

/obj/item/clothing/head/soft/dropped()
	src.icon_state = "[_color]soft" //because of this line and 15 and 18, the icon_state will end up blank if you were to try allowing heads to dye caps with their stamps
	src.flipped=0
	..()

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red color."
	icon_state = "redsoft"
	_color = "red"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue color."
	icon_state = "bluesoft"
	_color = "blue"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green color."
	icon_state = "greensoft"
	_color = "green"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "yellowsoft"
	_color = "yellow"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey color."
	icon_state = "greysoft"
	_color = "grey"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange color."
	icon_state = "orangesoft"
	_color = "orange"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white color."
	icon_state = "mimesoft"
	_color = "mime"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple color."
	icon_state = "purplesoft"
	_color = "purple"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	_color = "rainbow"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's a baseball hat in a tasteful red color."
	icon_state = "secsoft"
	_color = "sec"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/paramedic
	name = "paramedic cap"
	desc = "It's a baseball hat in a tasteful blue color."
	icon_state = "paramedicsoft"
	_color = "paramedic"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/bridgeofficer
	name = "bridge officer cap"
	desc = "It's a baseball hat in a tasteful blue color."
	icon_state = "bridgeofficersoft"
	_color = "bridgeofficer"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/soft/black
	name = "black cap"
	desc = "It's a baseball hat in a tasteful black color."
	icon_state = "blacksoft"
	_color = "black"
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)