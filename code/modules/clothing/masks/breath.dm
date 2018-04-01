/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "m_mask"
	body_parts_covered = 0
	flags_1 = MASKINTERNALS_1
	visor_flags = MASKINTERNALS_1
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.1
	permeability_coefficient = 0.5
	actions_types = list(/datum/action/item_action/adjust)
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	resistance_flags = NONE

obj/item/clothing/mask/breath/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is wrapping \the [src]'s tube around their neck! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

/obj/item/clothing/mask/breath/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/breath/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	else
		adjustmask(user)

/obj/item/clothing/mask/breath/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click [src] to adjust it.</span>")

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "m_mask"
	permeability_coefficient = 0.01
	equip_delay_other = 10
