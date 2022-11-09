/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	clothing_flags = MASKINTERNALS
	w_class = W_CLASS_SMALL
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	autoignition_temperature = AUTOIGNITION_PROTECTIVE
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	can_flip = 1



/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01
	species_fit = list(VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/mask/breath/vox
	desc = "A weirdly-shaped breath mask."
	name = "vox breath mask"
	icon_state = "voxmask"
	item_state = "voxmask"
	permeability_coefficient = 0.01
	species_restricted = list(VOX_SHAPED)
