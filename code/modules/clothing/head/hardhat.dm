/obj/item/clothing/head/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	flags = FPRINT
	item_state = "hardhat0_yellow"
	light_power = 2
	light_range = 4
	lighting_flags = MOVABLE_LIGHT
	var/on = 0
	_color = "yellow" //Determines used sprites: hardhat[on]_[_color] and hardhat[on]_[_color]2 (lying down sprite)
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 10, bomb = 20, bio = 10, rad = 20)
	actions_types = list(/datum/action/item_action/toggle_light)
	siemens_coefficient = 0.9
	species_fit = list (VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/hardhat/attack_self(mob/user)
	on = !on
	icon_state = "hardhat[on]_[_color]"
	item_state = "hardhat[on]_[_color]"

	if(on)
		set_light()
	else
		kill_light()

	user.update_inv_head()

/obj/item/clothing/head/hardhat/orange
	icon_state = "hardhat0_orange"
	item_state = "hardhat0_orange"
	_color = "orange"
	name = "orange hard hat"
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/hardhat/red
	icon_state = "hardhat0_red"
	item_state = "hardhat0_red"
	_color = "red"
	name = "firefighter helmet"
	flags = FPRINT
	heat_conductivity = INS_HELMET_HEAT_CONDUCTIVITY
	pressure_resistance = 3 * ONE_ATMOSPHERE
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/hardhat/white
	icon_state = "hardhat0_white"
	item_state = "hardhat0_white"
	_color = "white"
	name = "white hard hat"
	flags = FPRINT
	pressure_resistance = 3 * ONE_ATMOSPHERE
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/hardhat/dblue
	icon_state = "hardhat0_dblue"
	item_state = "hardhat0_dblue"
	_color = "dblue"
	name = "blue hard hat"
	species_fit = list(GREY_SHAPED,VOX_SHAPED, INSECT_SHAPED)

