

/obj/item/clothing/under/color
	name = "jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	_color = "white"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	color = COLOR_LINEN
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	dyeable_parts = list("top","top-sleeves-whole","top-sleeves-tip","top-shoulders","top-trim","pants","pants-tip","belt")
	dye_base_iconstate_override = "white"//so we can dye the other jumpsuits without having to add additional icon states
	dye_base_itemstate_override = "w_suit"

/obj/item/clothing/under/color/linen
	//sub-type to track manually crafted jumpsuits for centcomm orders

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	_color = "white"
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	_color = "black"
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/color/blackf
	name = "feminine black jumpsuit"
	desc = "It's very smart and in a ladies-size!"
	icon_state = "black"
	item_state = "bl_suit"
	_color = "blackf"
	color = null
	flags = FPRINT
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	clothing_flags = 0
	dyeable_parts = list()

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"
	_color = "blue"
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "g_suit"
	_color = "green"
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	icon = 'icons/obj/clothing/assistant.dmi'
	icon_state = "grey"
	item_state = "gy_suit"
	_color = "grey"
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	icon_state = "orange"
	item_state = "o_suit"
	_color = "orange"
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/color/prisoner
	name = "prison jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner"
	item_state = "o_suit"
	_color = "prisoner"
	has_sensor = 2
	sensor_mode = 3
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	icon_state = "pink"
	item_state = "p_suit"
	_color = "pink"
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "r_suit"
	_color = "red"
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"
	_color = "yellow"
	color = null
	clothing_flags = ONESIZEFITSALL | COLORS_OVERLAY
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	_color = "psyche"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/lightblue
	name = "lightblue jumpsuit"
	icon_state = "lightblue"
	_color = "lightblue"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/aqua
	name = "aqua jumpsuit"
	icon_state = "aqua"
	_color = "aqua"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/purple
	name = "purple jumpsuit"
	icon_state = "purple"
	item_state = "p_suit"
	_color = "purple"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/lightpurple
	name = "lightpurple jumpsuit"
	icon_state = "lightpurple"
	_color = "lightpurple"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/lightgreen
	name = "lightgreen jumpsuit"
	icon_state = "lightgreen"
	_color = "lightgreen"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/lightbrown
	name = "lightbrown jumpsuit"
	icon_state = "lightbrown"
	_color = "lightbrown"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/brown
	name = "brown jumpsuit"
	icon_state = "brown"
	_color = "brown"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/yellowgreen
	name = "yellowgreen jumpsuit"
	icon_state = "yellowgreen"
	_color = "yellowgreen"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/darkblue
	name = "darkblue jumpsuit"
	icon_state = "darkblue"
	_color = "darkblue"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/lightred
	name = "lightred jumpsuit"
	icon_state = "lightred"
	_color = "lightred"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/darkred
	name = "darkred jumpsuit"
	icon_state = "darkred"
	_color = "darkred"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/blackpants
	name = "black pants"
	icon_state = "blpants"
	_color = "blpants"
	clothing_flags = ONESIZEFITSALL
	gender = PLURAL
	body_parts_covered = LOWER_TORSO|LEGS
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/redpants
	name = "red pants"
	icon_state = "rpants"
	_color = "rpants"
	clothing_flags = ONESIZEFITSALL
	gender = PLURAL
	body_parts_covered = LOWER_TORSO|LEGS
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/bluepants
	name = "blue pants"
	icon_state = "bpants"
	_color = "bpants"
	clothing_flags = ONESIZEFITSALL
	gender = PLURAL
	body_parts_covered = LOWER_TORSO|LEGS
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/greypants
	name = "grey pants"
	icon_state = "gpants"
	_color = "gpants"
	clothing_flags = ONESIZEFITSALL
	gender = PLURAL
	body_parts_covered = LOWER_TORSO|LEGS
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

