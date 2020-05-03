//Regular rig suits
/obj/item/clothing/head/helmet/space/rig
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight)
	light_power = 1.7
	var/brightness_on = 4 //Luminosity when on. If modified, do NOT run update_brightness() directly
	var/color_on = null //Color when on.
	var/on = 0 //Remember to run update_brightness() when modified, otherwise disasters happen
	var/no_light = 0 //Disables the helmet light when set to 1. Make sure to run check_light() if this is updated
	_color = "engineering" //Determines used sprites: rig[on]-[_color]. Use update_icon() directly to update the sprite. NEEDS TO BE SET CORRECTLY FOR HELMETS
	actions_types = list(/datum/action/item_action/toggle_rig_light)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	pressure_resistance = 200 * ONE_ATMOSPHERE
	eyeprot = 3
	species_fit = list(GREY_SHAPED, TAJARAN_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	var/obj/item/clothing/suit/space/rig/rig

/obj/item/clothing/head/helmet/space/rig/New()
	check_light() //Needed to properly handle helmets with no lights
	..()
	//Useful for helmets with special starting conditions (namely, starts lit)
	update_brightness()

/obj/item/clothing/head/helmet/space/rig/Destroy()
	rig = null
	..()

/obj/item/clothing/head/helmet/space/rig/examine(mob/user)
	..()
	if(!no_light) //There is a light attached or integrated
		to_chat(user, "The helmet is mounted with an Internal Lighting System, it is [on ? "":"un"]lit.")

//We check no_light and update everything accordingly
//Used to clear up the action button and shut down the light if broken
//Minimizes snowflake coding and allows dynamically disabling the helmet's light if needed
/obj/item/clothing/head/helmet/space/rig/proc/check_light()
	if(no_light) //There's no light on the helmet
		if(on) //The helmet light is currently on
			on = 0 //Force it off
			update_brightness() //Update as neccesary
		actions_types.Remove(/datum/action/item_action/toggle_rig_light)//Disable the action button (which is only used to toggle the light, in theory)
	else //We have a light
		actions_types |= /datum/action/item_action/toggle_rig_light //Make sure we restore the action button

/obj/item/clothing/head/helmet/space/rig/process()
	if(on && rig)
		if(!rig.cell.use(1) || rig.loc != loc)
			toggle_light()

/obj/item/clothing/head/helmet/space/rig/proc/toggle_light(var/mob/user)
	if(no_light)
		return
	if(rig)
		on = !on
		if(!rig.cell || rig.cell.charge < 1)
			on = FALSE
		update_brightness()
		if(user)
			user.update_inv_head()

/obj/item/clothing/head/helmet/space/rig/proc/update_brightness()
	if(on)
		processing_objects.Add(src)
		set_light(brightness_on,null,color_on)
	else
		processing_objects.Remove(src)
		set_light(0)
	update_icon()

/obj/item/clothing/head/helmet/space/rig/update_icon()
	icon_state = "rig[on]-[_color]" //No need for complicated if trees


/obj/item/clothing/head/helmet/space/rig/unequipped(mob/living/carbon/human/user, var/from_slot = null)
	..()
	if(from_slot == slot_head && istype(user))
		if(rig && rig.is_worn_by(user))
			rig.deactivate_suit(user)
			if(on)
				toggle_light(user)
			rig = null

/obj/item/clothing/suit/space/rig
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = HARDSUIT_SLOWDOWN_LOW
	species_fit = list(GREY_SHAPED, TAJARAN_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/device/rcd, /obj/item/weapon/wrench/socket)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	pressure_resistance = 200 * ONE_ATMOSPHERE
	var/obj/item/clothing/head/helmet/space/rig/H = null
	var/head_type = /obj/item/clothing/head/helmet/space/rig
	var/obj/item/weapon/cell/cell = null
	var/cell_type = /obj/item/weapon/cell/high //The cell_type we're actually using
	var/list/modules = list()
	actions_types = list(/datum/action/item_action/toggle_rig_helmet)

/obj/item/clothing/suit/space/rig/New()
	..()
	cell = new cell_type
	H = new head_type

/obj/item/clothing/suit/space/rig/Destroy()
	qdel(cell)
	cell = null
	if(H && (H.loc == src || !H.loc))
		qdel(H)
	H = null
	for(var/obj/M in modules)
		qdel(M)
	modules.Cut()
	..()

/obj/item/clothing/suit/space/rig/examine(mob/user)
	..()
	for(var/obj/item/rig_module/M in modules)
		M.examine_addition(user)

/obj/item/clothing/suit/space/rig/unequipped(mob/living/carbon/human/user, var/from_slot = null)
	..()
	if(from_slot == slot_wear_suit && istype(user))
		deactivate_suit(user)

/obj/item/clothing/suit/space/rig/proc/toggle_helmet(mob/living/carbon/human/user)
	if(!user.is_wearing_item(src, slot_wear_suit))
		return
	if(H)
		if(!user.head)
			to_chat(user, "<span class = 'notice'>\The [H] extends from \the [src].</span>")
			user.equip_to_slot(H, slot_head)
			H.rig = src
			H = null
			initialize_suit(user)
	else
		if(user.head && istype(user.head, head_type))
			var/obj/I = user.head
			to_chat(user, "<span class = 'notice'>\The [I] retracts into \the [src].</span>")
			user.u_equip(I,0)
			I.forceMove(src)
			H = I
			deactivate_suit(user)


/obj/item/clothing/suit/space/rig/proc/initialize_suit(mob/user)
	for(var/obj/item/rig_module/R in modules)
		R.activate(user,src)

/obj/item/clothing/suit/space/rig/proc/deactivate_suit(mob/user)
	for(var/obj/item/rig_module/R in modules)
		R.deactivate(user,src)

/obj/item/clothing/suit/space/rig/attackby(obj/W, mob/user)
	if(!H && istype(W, head_type) && user.drop_item(W, src, force_drop = 1))
		to_chat(user, "<span class = 'notice'>You attach \the [W] to \the [src].</span>")
		H = W
		return
	..()


//Chief Engineer's rig
/obj/item/clothing/head/helmet/space/rig/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "rig0-white"
	item_state = "ce_helm"
	_color = "white"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	clothing_flags = PLASMAGUARD

/obj/item/clothing/suit/space/rig/elite
	icon_state = "rig-white"
	name = "advanced hardsuit"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	clothing_flags = PLASMAGUARD
	cell_type = /obj/item/weapon/cell/super
	head_type = /obj/item/clothing/head/helmet/space/rig/elite

//Mining rig
/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "rig0-mining"
	item_state = "rig0-mining"
	_color = "mining"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	pressure_resistance = 40 * ONE_ATMOSPHERE
	clothing_flags = GOLIATHREINFORCE

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	item_state = "rig-mining"
	species_fit = list(INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	pressure_resistance = 40 * ONE_ATMOSPHERE
	clothing_flags = GOLIATHREINFORCE
	head_type = /obj/item/clothing/head/helmet/space/rig/mining

//Syndicate rig
/obj/item/clothing/head/helmet/space/rig/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced helmet designed for work in special operations. A tag on it says \"Property of Gorlex Marauders\"."
	icon_state = "rig0-syndi"
	item_state = "syndie_helm"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, SKRELL_SHAPED, UNATHI_SHAPED, TAJARAN_SHAPED, INSECT_SHAPED)
	_color = "syndi"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 60)
	actions_types = list(/datum/action/item_action/toggle_helmet_camera) //This helmet does not have a light, but we'll do as if
	siemens_coefficient = 0.6
	var/obj/machinery/camera/camera
	pressure_resistance = 40 * ONE_ATMOSPHERE

	species_restricted = null

/obj/item/clothing/head/helmet/space/rig/syndi/attack_self(mob/user)
	if(camera)
		..(user)
	else
		camera = new /obj/machinery/camera(src)
		camera.network = list(CAMERANET_NUKE)
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		to_chat(user, "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>")

/obj/item/clothing/head/helmet/space/rig/syndi/examine(mob/user)
	..()
	if(get_dist(user,src) <= 1)
		to_chat(user, "<span class='info'>This helmet has a built-in camera. It's [camera ? "" : "in"]active.</span>")

/obj/item/clothing/suit/space/rig/syndi
	icon_state = "rig-syndi"
	name = "blood-red hardsuit"
	desc = "An advanced suit that protects against injuries during special operations. A tag on it says \"Property of Gorlex Marauders\"."
	item_state = "syndie_hardsuit"
	species_fit = list(VOX_SHAPED, SKRELL_SHAPED, UNATHI_SHAPED, TAJARAN_SHAPED, INSECT_SHAPED)
	w_class = W_CLASS_MEDIUM
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs)
	siemens_coefficient = 0.6
	pressure_resistance = 40 * ONE_ATMOSPHERE

	species_restricted = null
	head_type = /obj/item/clothing/head/helmet/space/rig/syndi

/obj/item/clothing/head/helmet/space/rig/syndi/commander
	name = "large blood-red hardsuit helmet"
	desc = "An advanced helmet designed for work in special operations. Slightly bulkier than usual. A tag on it says \"Property of Gorlex Marauders\"."
	armor = list(melee = 65, bullet = 55, laser = 35, energy = 20, bomb = 40, bio = 100, rad = 60)
	icon_state = "rig0-syndi-commander"
	item_state = "syndie_helm_commander"
	_color = "syndi-commander"
	species_fit = list()

/obj/item/clothing/suit/space/rig/syndi/commander
	name = "large blood-red hardsuit"
	desc = "An advanced suit that protects against injuries during special operations. Slightly bulkier than usual. A tag on it says \"Property of Gorlex Marauders\"."
	icon_state = "rig-syndi-commander"
	armor = list(melee = 65, bullet = 55, laser = 35, energy = 20, bomb = 40, bio = 100, rad = 60)
	head_type = /obj/item/clothing/head/helmet/space/rig/syndi/commander
	species_fit = list()

//Elite Strike Team rig
/obj/item/clothing/head/helmet/space/rig/syndicate_elite
	name = "syndicate elite hardsuit helmet"
	desc = "The result of reverse-engineered deathsquad technology combined with nuclear operative hardsuit."
	icon_state = "rig0-syndicate_elite"
	item_state = "syndicate-helm-black"
	_color = "syndicate_elite"
	armor = list(melee = 65, bullet = 55, laser = 35,energy = 20, bomb = 40, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4
	clothing_flags = PLASMAGUARD

	species_restricted = null

/obj/item/clothing/suit/space/rig/syndicate_elite
	icon_state = "rig-syndicate_elite"
	name = "syndicate elite hardsuit"
	desc = "The result of reverse-engineered deathsquad technology combined with nuclear operative hardsuit."
	item_state = "syndicate-black"
	w_class = W_CLASS_MEDIUM
	armor = list(melee = 70, bullet = 60, laser = 40, energy = 25, bomb = 50, bio = 100, rad = 60)
	allowed = list(/obj/item/weapon/gun/osipr, /obj/item/device/flashlight, /obj/item/weapon/tank, /obj/item/weapon/gun, /obj/item/ammo_storage, /obj/item/ammo_casing, /obj/item/weapon/melee/baton, /obj/item/weapon/melee/energy/sword, /obj/item/weapon/handcuffs)
	siemens_coefficient = 0.5
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	clothing_flags = PLASMAGUARD

	species_restricted = null
	head_type = /obj/item/clothing/head/helmet/space/rig/syndicate_elite


//Wizard Rig
/obj/item/clothing/head/helmet/space/rig/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state = "wiz_helm"
	_color = "wiz"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7

	wizard_garb = 1

	species_restricted = null

/obj/item/clothing/head/helmet/space/rig/wizard/acidable()
	return 0

/obj/item/clothing/suit/space/rig/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	w_class = W_CLASS_MEDIUM
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7

	wizard_garb = 1

	species_restricted = null
	head_type = /obj/item/clothing/head/helmet/space/rig/wizard
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/teleportation_scroll,/obj/item/weapon/gun/energy/staff)

/obj/item/clothing/suit/space/rig/wizard/acidable()
	return 0

/obj/item/clothing/head/helmet/space/rig/wizard/lich_king
	name = "helm of domination"
	desc = "Worn by a lich with too much summoning time on their hands."
	icon_state = "rig0-domination"
	item_state = "lich_helm"
	_color = "domination"
	species_restricted = list(UNDEAD_SHAPED)

/obj/item/clothing/suit/space/rig/wizard/lich_king
	name = "plate of the damned"
	desc = "Previous incarnations were rumoured to make the user invulnerable. This itteration is famous for having its own in-built cloak."
	icon_state = "lichking_armour"
	item_state = "lichking_armour"
	species_restricted = list(UNDEAD_SHAPED)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|HANDS

//Medical Rig
/obj/item/clothing/head/helmet/space/rig/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has minor radiation shielding."
	icon_state = "rig0-medical"
	item_state = "medical_helm"
	_color = "medical"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/suit/space/rig/medical
	icon_state = "rig-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has minor radiation shielding."
	item_state = "medical_hardsuit"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical, /obj/item/roller)
	pressure_resistance = 40 * ONE_ATMOSPHERE
	head_type = /obj/item/clothing/head/helmet/space/rig/medical


	//Security
/obj/item/clothing/head/helmet/space/rig/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous low pressure environment. Has an additional layer of armor."
	icon_state = "rig0-sec"
	item_state = "sec_helm"
	_color = "sec"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	siemens_coefficient = 0.7
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/suit/space/rig/security
	icon_state = "rig-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/device/flashlight,
		/obj/item/weapon/tank,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/ammo_storage,
		/obj/item/ammo_casing,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/bikehorn/baton,
		/obj/item/weapon/blunderbuss,
		/obj/item/weapon/legcuffs/bolas,
	)
	siemens_coefficient = 0.7
	pressure_resistance = 40 * ONE_ATMOSPHERE
	head_type = /obj/item/clothing/head/helmet/space/rig/security

/obj/item/clothing/suit/space/rig/security/fat
	name = "expanded security hardsuit"
	desc = "An armored suit that has been expanded to accomodate a donut gut."
	clothing_flags = ONESIZEFITSALL

/obj/item/clothing/suit/space/rig/security/fat/step_action()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/H = loc
	if(!(M_FAT in H.mutations))
		if(!heat_conductivity) //Not fat and not yet broken
			sterility = 50
			heat_conductivity = 0.5
			to_chat(H,"<span class='danger'>\The [src] is too loose and can't form a perfect seal around your gaunt body!</span>")
	else
		if(heat_conductivity) //Fat, but not yet restored
			sterility = 100
			heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY //0
			to_chat(H,"<span class='good'>\The [src] forms a robust seal around your girth!</span>")

	// stormtroopers

/obj/item/clothing/head/helmet/space/rig/security/stormtrooper
	icon_state = "rig0-storm"
	_color = "storm"
	name = "stormtrooper helmet"
	desc = "Even with the finest vision enhancement tech, you still can't hit shit."
	no_light = 1

/obj/item/clothing/suit/space/rig/security/stormtrooper
	icon_state = "rig-storm"
	name = "stormtrooper hardsuit"
	desc = "Now even more vulnerable to teddy bears!"
	head_type = /obj/item/clothing/head/helmet/space/rig/security/stormtrooper

//Atmospherics Rig (BS12)
/obj/item/clothing/head/helmet/space/rig/atmos
	desc = "A special helmet designed for work in hazardous low pressure environments. Has reduced radiation shielding to allow for greater mobility."
	name = "atmospherics hardsuit helmet"
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	_color = "atmos"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	clothing_flags = PLASMAGUARD
	armor = list(melee = 40, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/rig/atmos
	desc = "A special suit that protects against hazardous low pressure environments. Has reduced radiation shielding to allow for greater mobility."
	icon_state = "rig-atmos"
	name = "atmos hardsuit"
	item_state = "atmos_hardsuit"
	species_restricted = list("exclude",VOX_SHAPED)
	clothing_flags = PLASMAGUARD
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	armor = list(melee = 40, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	head_type = /obj/item/clothing/head/helmet/space/rig/atmos

//Firefighting/Atmos RIG (old /vg/)
/obj/item/clothing/head/helmet/space/rig/atmos/gold
	desc = "A special helmet designed for work in hazardous low pressure environments and extreme temperatures. In other words, perfect for atmos."
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE*2
	name = "atmos hardsuit helmet"
	icon_state = "rig0-atmos_gold"
	item_state = "atmos_gold_helm"
	_color = "atmos_gold"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	no_light = 1

/obj/item/clothing/suit/space/rig/atmos/gold
	desc = "A special suit that protects against hazardous low pressure environments and extreme temperatures. In other words, perfect for atmos."
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE*4
	gas_transfer_coefficient = 0.80
	permeability_coefficient = 0.25
	icon_state = "rig-atmos_gold"
	name = "atmos hardsuit"
	item_state = "atmos_gold_hardsuit"
	slowdown = HARDSUIT_SLOWDOWN_HIGH
	species_fit = list(GREY_SHAPED,INSECT_SHAPED)
	armor = list(melee = 30, bullet = 5, laser = 40,energy = 5, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/backpack/satchel_norm,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/device/rcd, /obj/item/weapon/extinguisher, /obj/item/weapon/extinguisher/foam, /obj/item/weapon/storage/toolbox, /obj/item/weapon/wrench/socket)
	head_type = /obj/item/clothing/head/helmet/space/rig/atmos/gold

//ADMINBUS RIGS. SOVIET + NAZI
/obj/item/clothing/head/helmet/space/rig/nazi
	name = "nazi hardhelmet"
	desc = "This is the face of das vaterland's top elite. Gas or energy are your only escapes."
	item_state = "rig0-nazi"
	icon_state = "rig0-nazi"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)//GAS THE VOX
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	_color = "nazi"
	pressure_resistance = 40 * ONE_ATMOSPHERE
	color_on = "#FF2222"

/obj/item/clothing/suit/space/rig/nazi
	name = "nazi hardsuit"
	desc = "The attire of a true krieger. All shall fall, and only das vaterland will remain."
	item_state = "rig-nazi"
	icon_state = "rig-nazi"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)//GAS THE VOX
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/)
	pressure_resistance = 40 * ONE_ATMOSPHERE
	head_type = /obj/item/clothing/head/helmet/space/rig/nazi

/obj/item/clothing/head/helmet/space/rig/soviet
	name = "soviet hardhelmet"
	desc = "Crafted with the pride of the proletariat. The vengeful gaze of the visor roots out all fascists and capitalists."
	item_state = "rig0-soviet"
	icon_state = "rig0-soviet"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)//HET
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	_color = "soviet"
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/suit/space/rig/soviet
	name = "soviet hardsuit"
	desc = "Crafted with the pride of the proletariat. The last thing the enemy sees is the bottom of this armor's boot."
	item_state = "rig-soviet"
	icon_state = "rig-soviet"
	slowdown = 1
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)//HET
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/)
	pressure_resistance = 40 * ONE_ATMOSPHERE
	head_type = /obj/item/clothing/head/helmet/space/rig/soviet

//Death squad rig
/obj/item/clothing/head/helmet/space/rig/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "rig0-deathsquad"
	item_state = "rig0-deathsquad"
	armor = list(melee = 65, bullet = 55, laser = 35,energy = 20, bomb = 40, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	_color = "deathsquad"
	clothing_flags = PLASMAGUARD

/obj/item/clothing/suit/space/rig/deathsquad
	name = "deathsquad suit"
	desc = "A heavily armored suit that protects against a lot of things. Used in special operations."
	icon_state = "rig-deathsquad"
	item_state = "rig-deathsquad"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/pinpointer,/obj/item/weapon/shield/energy,/obj/item/weapon/c4,/obj/item/weapon/disk/nuclear)
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.5
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	clothing_flags = PLASMAGUARD
	head_type = /obj/item/clothing/head/helmet/space/rig/deathsquad


//Knight armour rigs
/obj/item/clothing/head/helmet/space/rig/knight
	name = "Space-Knight helm"
	desc = "A well polished helmet belonging to a Space-Knight. Favored by space-jousters for its ability to stay on tight after being launched from a mass driver."
	icon_state = "rig0-knight"
	item_state = "rig0-knight"
	armor = list(melee = 60, bullet = 40, laser = 40,energy = 30, bomb = 50, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	_color = "knight"
	clothing_flags = PLASMAGUARD|GOLIATHREINFORCE


/obj/item/clothing/suit/space/rig/knight
	name = "Space-Knight armour"
	desc = "A well polished set of armour belonging to a Space-Knight. Maidens Rescued in Space: 100, Maidens who have slept with me in Space: 0."
	icon_state = "rig-knight"
	item_state = "rig-knight"
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/melee/baton,/obj/item/weapon/tank,/obj/item/weapon/shield/energy,/obj/item/weapon/claymore)
	armor = list(melee = 60, bullet = 40, laser = 40,energy = 30, bomb = 50, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.5
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	clothing_flags = PLASMAGUARD|GOLIATHREINFORCE
	head_type = /obj/item/clothing/head/helmet/space/rig/knight

/obj/item/clothing/head/helmet/space/rig/knight/black
	name = "Black Knight's helm"
	desc = "An ominous black helmet with a gold trim. The small viewports create an intimidating look, while also making it nearly impossible to see anything."
	icon_state = "rig0-blackknight"
	item_state = "rig0-blackknight"
	armor = list(melee = 70, bullet = 65, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)
	_color="blackknight"
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/suit/space/rig/knight/black
	name = "Black Knight's armour"
	desc = "An ominous black suit of armour with a gold trim. Surprisingly good at preventing accidental loss of limbs."
	icon_state = "rig-blackknight"
	item_state = "rig-blackknight"
	armor = list(melee = 70, bullet = 65, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)
	species_fit = list(GREY_SHAPED)
	head_type = /obj/item/clothing/head/helmet/space/rig/knight/black

/obj/item/clothing/head/helmet/space/rig/knight/solaire
	name = "Solar helm"
	desc = "A simple helmet. 'Made in Astora' is inscribed on the back."
	icon_state = "rig0-solaire"
	item_state = "rig0-solaire"
	armor = list(melee = 60, bullet = 65, laser = 90,energy = 30, bomb = 60, bio = 100, rad = 100)
	_color="solaire"

/obj/item/clothing/suit/space/rig/knight/solaire
	name = "Solar armour"
	desc = "A solar powered hardsuit with a fancy insignia on the chest. Perfect for stargazers and adventurers alike."
	icon_state = "rig-solaire"
	item_state = "rig-solaire"
	armor = list(melee = 60, bullet = 65, laser = 90,energy = 30, bomb = 60, bio = 100, rad = 100)
	head_type = /obj/item/clothing/head/helmet/space/rig/knight/solaire


/obj/item/clothing/suit/space/rig/t51b
	name = "T-51b Power Armor"
	desc = "Relic of a bygone era, the T-51b is powered by a TX-28 MicroFusion Pack, which holds enough fuel to power its internal hydraulics for a century!"
	icon_state = "rig-t51b"
	item_state = "rig-t51b"
	armor = list(melee = 35, bullet = 35, laser = 40, energy = 40, bomb = 80, bio = 100, rad = 100)
	head_type = /obj/item/clothing/head/helmet/space/rig/t51b

/obj/item/clothing/head/helmet/space/rig/t51b
	name = "T-51b Power Armor Helmet"
	desc = "Relic of a bygone era, the T-51b is powered by a TX-28 MicroFusion Pack, which holds enough fuel to power its internal hydraulics for a century!"
	icon_state = "rig0-t51b"
	item_state = "rig0-t51b"
	armor = list(melee = 35, bullet = 35, laser = 40, energy = 40, bomb = 80, bio = 100, rad = 100)
	_color="t51b"

//Ghetto space suit
/obj/item/clothing/head/helmet/space/ghetto
	name = "jury-rigged space-proof fire helmet"
	desc = "A firefighter helmet and gas mask combined and jury-rigged into being 'space-proof' somehow."
	icon_state = "ghettorig"
	item_state = "ghettorig"
	_color = "ghetto"
	pressure_resistance = 4 * ONE_ATMOSPHERE
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 10, bomb = 20, bio = 10, rad = 20)
	body_parts_covered = FULL_HEAD|BEARD
	heat_conductivity = 0
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	eyeprot = 0
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/space/ghettorig
	name = "jury-rigged space-proof firesuit"
	icon_state = "ghettorig"
	item_state = "ghettorig"
	desc = "A firesuit jury-rigged into being 'space-proof' somehow."
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/extinguisher)
	pressure_resistance = 4 * ONE_ATMOSPHERE
	slowdown = 5 //just wear a firesuit instead if you want to go fast
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = 0 //thanks, blanket
	gas_transfer_coefficient = 0.60
	permeability_coefficient = 0.30
	species_fit = list(INSECT_SHAPED)

//RoR survivor Rig
/obj/item/clothing/suit/space/rig/ror
	name = "survivor's hardsuit"
	desc = "...and so he left the asteroid, with everything but his humanity."
	icon_state = "rorsuit"
	item_state = "rorsuit"
	armor = list(melee = 40, bullet = 0, laser = 0,energy = 0, bomb = 65, bio = 100, rad = 50)
	clothing_flags = GOLIATHREINFORCE
	head_type = /obj/item/clothing/head/helmet/space/rig/ror

/obj/item/clothing/head/helmet/space/rig/ror
	name = "survivor's hardsuit helmet"
	desc = "...and so he left the asteroid, with everything but his humanity."
	icon_state = "rorhelm"
	item_state = "rorhelm"
	armor = list(melee = 40, bullet = 0, laser = 0,energy = 0, bomb = 65, bio = 100, rad = 50)
	clothing_flags = GOLIATHREINFORCE

/obj/item/clothing/head/helmet/space/rig/ror/update_icon()
	return

//[Xeno]Archaeologist Rig
/obj/item/clothing/suit/space/rig/arch
	name = "archaeology hardsuit"
	desc = "A hardsuit designed for archaeology expeditions. It's yellow and orange materials provide high visibility and resistance to exotic particles."
	icon_state = "rig-arch"
	item_state = "arch_hardsuit"
	armor = list(melee = 40, bullet = 0, laser = 0,energy = 0, bomb = 65, bio = 100, rad = 50)
	head_type = /obj/item/clothing/head/helmet/space/rig/arch
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/helmet/space/rig/arch
	name = "archaeology hardsuit helmet"
	desc = "A hardsuit helmet designed for archaeology expeditions. It's orange materials provide high visibility and resistance to exotic particles."
	icon_state = "rig0-arch"
	item_state = "arch_helm"
	_color = "arch"
	armor = list(melee = 40, bullet = 0, laser = 0,energy = 0, bomb = 65, bio = 100, rad = 50)
	color_on = "#81F9C6" //Aquamarine. A combination of the colors from the lamp and rail light.
	species_fit = list(INSECT_SHAPED)