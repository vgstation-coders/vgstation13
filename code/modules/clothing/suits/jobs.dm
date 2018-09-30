/*
 * Job related
 */

//Paramedic
/obj/item/clothing/suit/storage/paramedic
	name = "paramedic vest"
	desc = "A hazard vest used in the recovery of bodies."
	icon_state = "paramedic-vest"
	item_state = "paramedic-vest"
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/device/radio,/obj/item/device/gps, /obj/item/roller)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 10)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

//Botonist
/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	item_state = "apron"
	blood_overlay_type = "armor"
	body_parts_covered = FULL_TORSO
	allowed = list (/obj/item/weapon/reagent_containers/spray/plantbgone,/obj/item/device/analyzer/plant_analyzer,/obj/item/seeds,/obj/item/weapon/reagent_containers/glass/fertilizer,/obj/item/weapon/wirecutters/clippers,/obj/item/weapon/minihoe)
	species_fit = list(VOX_SHAPED)

//Captain
/obj/item/clothing/suit/captunic
	name = "captain's parade tunic"
	desc = "Worn by a Captain to show their class."
	icon_state = "captunic"
	item_state = "bio_suit"
	body_parts_covered = FULL_TORSO|LEGS|FEET|ARMS
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/storage/capjacket
	name = "captain's uniform jacket"
	desc = "A less formal jacket for everyday captain use."
	icon_state = "capjacket"
	item_state = "bio_suit"
	body_parts_covered = FULL_TORSO|ARMS
	species_fit = list(VOX_SHAPED)
	max_combined_w_class = 6
	storage_slots = 3

//Chaplain
/obj/item/clothing/suit/chaplain_hoodie
	name = "chaplain hoodie"
	desc = "This suit says to you 'hush'!"
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	species_fit = list(VOX_SHAPED)
	body_parts_covered = FULL_TORSO|LEGS|ARMS|IGNORE_INV


//Chaplain
/obj/item/clothing/suit/nun
	name = "nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	item_state = "nun"
	body_parts_covered = FULL_TORSO|LEGS|FEET|ARMS
	species_fit = list(VOX_SHAPED)

//Chef
/obj/item/clothing/suit/chef
	name = "Chef's apron"
	desc = "An apron used by a high class chef."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = FULL_TORSO|ARMS
	allowed = list (/obj/item/weapon/kitchen/utensil/knife/large,/obj/item/weapon/kitchen/utensil/knife/large/butch)
	species_fit = list(VOX_SHAPED)

//Chef
/obj/item/clothing/suit/chef/classic
	name = "A classic chef's apron."
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	item_state = "apronchef"
	blood_overlay_type = "armor"
	body_parts_covered = FULL_TORSO
	species_fit = list(VOX_SHAPED)

//Detective
/obj/item/clothing/suit/storage/det_suit
	name = "coat"
	desc = "An 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)
	clothing_flags = ONESIZEFITSALL
	armor = list(melee = 50, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/storage/det_suit/noir
	desc = "Ah, your trusty coat. There's a few tears here and there, giving it a more timely look. Or at least, that's what you told yourself when you found out gettin' it repaired would set you back 200 credits."
	icon_state = "noir_detective"
	item_state = "noir_detective"

//Forensics
/obj/item/clothing/suit/storage/forensics
	name = "jacket"
	desc = "A forensics technician jacket."
	item_state = "det_suit"
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)
	armor = list(melee = 10, bullet = 10, laser = 15, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/forensics/red
	name = "red jacket"
	desc = "A red forensics technician jacket."
	icon_state = "forensics_red"

/obj/item/clothing/suit/storage/forensics/blue
	name = "blue jacket"
	desc = "A blue forensics technician jacket."
	icon_state = "forensics_blue"

//Engineering
/obj/item/clothing/suit/storage/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	item_state = "hazard"
	blood_overlay_type = "armor"
	allowed = list (
		/obj/item/device/analyzer,
		/obj/item/device/flashlight,
		/obj/item/device/multitool,
		/obj/item/device/radio,
		/obj/item/device/t_scanner,
		/obj/item/weapon/crowbar,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/weldingtool,
		/obj/item/weapon/wirecutters,
		/obj/item/weapon/wrench,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/weapon/tank/emergency_nitrogen,
		/obj/item/device/device_analyser,
		/obj/item/device/rcd)
	species_fit = list(VOX_SHAPED)

//Lawyer
/obj/item/clothing/suit/storage/lawyer/bluejacket
	name = "Blue Suit Jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_blue_open"
	item_state = "suitjacket_blue_open"
	blood_overlay_type = "coat"

/obj/item/clothing/suit/storage/lawyer/purpjacket
	name = "Purple Suit Jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_purp"
	item_state = "suitjacket_purp"
	blood_overlay_type = "coat"

//Bridge Officer
/obj/item/clothing/suit/storage/lawyer/bridgeofficer
	name = "bridge officer dress jacket"
	desc = "A classy dress jacket, for special occasions."
	icon_state = "bridgeofficer_jacket"
	item_state = "bridgeofficer_jacket"
	blood_overlay_type = "coat"

//Internal Affairs
/obj/item/clothing/suit/storage/internalaffairs
	name = "Internal Affairs Jacket"
	desc = "A smooth black jacket."
	icon_state = "ia_jacket_open"
	item_state = "ia_jacket"
	blood_overlay_type = "coat"

	verb/toggle()
		set name = "Toggle Coat Buttons"
		set category = "Object"
		set src in usr

		if(usr.incapacitated())
			return 0

		switch(icon_state)
			if("ia_jacket_open")
				src.icon_state = "ia_jacket"
				to_chat(usr, "You button up the jacket.")
			if("ia_jacket")
				src.icon_state = "ia_jacket_open"
				to_chat(usr, "You unbutton the jacket.")
			else
				to_chat(usr, "You attempt to button-up the velcro on your [src], before promptly realising how retarded you are.")
				return
		usr.update_inv_wear_suit()	//so our overlays update

//Medical
/obj/item/clothing/suit/storage/fr_jacket
	name = "first responder jacket"
	desc = "A high-visibility jacket worn by medical first responders."
	icon_state = "fr_jacket_open"
	item_state = "fr_jacket"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/stack/medical, /obj/item/weapon/reagent_containers/dropper, /obj/item/weapon/reagent_containers/hypospray, /obj/item/weapon/reagent_containers/syringe, \
	/obj/item/device/healthanalyzer, /obj/item/device/flashlight, /obj/item/device/radio, /obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen, /obj/item/roller)

	verb/toggle()
		set name = "Toggle Jacket Buttons"
		set category = "Object"
		set src in usr

		if(usr.incapacitated())
			return 0

		switch(icon_state)
			if("fr_jacket_open")
				src.icon_state = "fr_jacket"
				to_chat(usr, "You button up the jacket.")
			if("fr_jacket")
				src.icon_state = "fr_jacket_open"
				to_chat(usr, "You unbutton the jacket.")
		usr.update_inv_wear_suit()	//so our overlays update

//Mime
/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	blood_overlay_type = "armor"
	body_parts_covered = 0

//Head of Personnell
/obj/item/clothing/suit/storage/Hop_Coat
	name = "Head of Personnel's dress jacket"
	desc = "A slightly armoured greatcoat. It looks like it's mostly ceremonial."
	icon_state = "HoP_Coat"
	item_state = "HoP_Coat"
	blood_overlay_type = "coat"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)
	armor = list(melee = 50, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)

//Syndicate exec
/obj/item/clothing/suit/storage/syndicateexec
	name = "syndicate executive jacket"
	desc = "A flash black jacket, it seems oddly heavy."
	icon_state = "ia_jacket_open"
	item_state = "ia_jacket"
	blood_overlay_type = "coat"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)
	armor = list(melee = 50, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/syndicateexec/verb/toggle()
	set name = "Toggle Coat Buttons"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return 0

	switch(icon_state)
		if("ia_jacket_open")
			src.icon_state = "ia_jacket"
			to_chat(usr, "You button up the jacket.")
		if("ia_jacket")
			src.icon_state = "ia_jacket_open"
			to_chat(usr, "You unbutton the jacket.")
		else
			to_chat(usr, "You attempt to button-up the velcro on your [src], before promptly realising how retarded you are.")
			return
		usr.update_inv_wear_suit()	//so our overlays update
