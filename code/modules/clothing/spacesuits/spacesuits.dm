//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	flags = FPRINT  | STOPSPRESSUREDMG
	item_state = "space"
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|AIRTIGHT
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	species_restricted = list("exclude","Diona","Muton")

	cold_breath_protection = 230
	var/obj/machinery/camera/camera
	var/list/camera_networks
	brightness_on = 4
	on = 0

/obj/item/clothing/head/helmet/space/attack_self(mob/user)

	if(!camera && camera_networks)
		if(!action_button_name)
			action_button_name = "[icon_state]"

		camera = new /obj/machinery/camera(src)
		camera.network = camera_networks
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		user << "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>"
		return 1
	..()

/obj/item/clothing/head/helmet/space/examine()
	..()
	if(camera_networks && get_dist(usr, src) <= 1)
		usr << "This helmet has a built-in camera. It's [camera ? "" : "in"]active."


/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = FPRINT  | STOPSPRESSUREDMG
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = 3
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	species_restricted = list("exclude","Diona","Muton")