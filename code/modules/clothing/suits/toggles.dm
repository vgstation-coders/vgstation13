/obj/item/clothing/suit/wintercoat
    name = "winter coat"
    desc = "A warm, fluffy and incredibly comfortable jacket made from animal furs."
    icon_state = "coatwinter"
    var item_state_slots = list(slot_r_hand_str = "coatwinter", slot_l_hand_str = "coatwinter")
    body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
    heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
    armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
//    action_button_name = "Toggle Hood"
    allowed = list (
    /obj/item/weapon/pen,
    /obj/item/weapon/paper,
    /obj/item/device/flashlight,
    /obj/item/weapon/tank/emergency_oxygen,
    /obj/item/weapon/storage/fancy/cigarettes,
//    /obj/item/weapon/storage/box/matches,
    /obj/item/weapon/reagent_containers/food/drinks/flask
    )


/obj/item/clothing/suit/wintercoat/cargo
    name = "cargo winter coat"
    icon_state = "coatcargo"


/obj/item/clothing/suit/wintercoat/science
    name = "science winter coat"
    icon_state = "coatscience"


/obj/item/clothing/suit/wintercoat/medical
    name = "medical winter coat"
    icon_state = "coatmedical"


/obj/item/clothing/suit/wintercoat/captain
    name = "captain winter coat"
    icon_state = "coatcaptain"


/obj/item/clothing/suit/wintercoat/engineering
    name = "engineering winter coat"
    icon_state = "coatengineering"


/obj/item/clothing/suit/wintercoat/hydro
    name = "hydroponics winter coat"
    icon_state = "coathydro"


/obj/item/clothing/suit/wintercoat/atmos
    name = "atmospherics winter coat"
    icon_state = "coatatmos"



/obj/item/clothing/suit/wintercoat/security
    name = "security winter coat"
    icon_state = "coatsecurity"


/obj/item/clothing/suit/wintercoat/mining
    name = "mining winter coat"
    icon_state = "coatmining"
