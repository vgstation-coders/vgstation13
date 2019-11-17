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
	species_fit = list(GREY_SHAPED, TAJARAN_SHAPED)
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
	else
		to_chat(user, "<span class = 'warning'>\The [src] has no linked suit!</span>")

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
			rig.deactivate_suit(user, unequipall = FALSE) //Do not unequip everything if they're just removing their helmet.
			if(on)
				toggle_light(user)
			rig = null

/obj/item/clothing/head/helmet/space/rig/equipped(mob/living/carbon/human/user, var/slot)
	..()
	if(user.is_wearing_item(/obj/item/clothing/suit/space/rig, slot_wear_suit))
		var/obj/item/clothing/suit/space/rig/RS = user.wear_suit
		if(RS.head_type && istype(src, RS.head_type)) //It's my suit! It was made for me!
			rig = user.wear_suit

/obj/item/clothing/suit/space/rig
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = HARDSUIT_SLOWDOWN_LOW
	species_fit = list(GREY_SHAPED, TAJARAN_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/device/rcd, /obj/item/weapon/wrench/socket)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	pressure_resistance = 200 * ONE_ATMOSPHERE
	var/activated = FALSE
	var/list/modules = list()
	actions_types = list(/datum/action/item_action/toggle_rig_suit, /datum/action/item_action/open_rig_ui)

	var/obj/item/clothing/head/helmet/space/rig/H = null
	var/obj/item/clothing/gloves/G = null
	var/obj/item/clothing/shoes/magboots/MB = null
	var/obj/item/weapon/tank/T = null
	var/obj/item/weapon/cell/cell = null

	var/head_type = /obj/item/clothing/head/helmet/space/rig
	var/boots_type =  null
	var/gloves_type = null
	var/tank_type = null
	var/cell_type = /obj/item/weapon/cell/high //The cell_type we're actually using

/obj/item/clothing/suit/space/rig/New()
	..()
	if(cell_type)
		cell = new cell_type(src)
	if(head_type)
		H = new head_type(src)
		H.rig = src
	if(gloves_type)
		G = new gloves_type(src)
	if(boots_type)
		MB = new boots_type(src)
	if(tank_type)
		T = new tank_type(src)

/obj/item/clothing/suit/space/rig/Destroy()
	if(processing_objects.Find(src))
		processing_objects.Remove(src)
	for(var/obj/item/I in list(H,G,T,MB))
		if(I && (I.loc == src || !I.loc))
			qdel(I)
	H = null
	G = null
	T = null
	MB = null
	for(var/obj/M in modules)
		qdel(M)
	modules.Cut()
	if(cell)
		qdel(cell)
	cell = null
	..()

/obj/item/clothing/suit/space/rig/examine(mob/user)
	..()
	for(var/obj/item/rig_module/M in modules)
		M.examine_addition(user)

/obj/item/clothing/suit/space/rig/get_cell()
	return cell

/obj/item/clothing/suit/space/rig/unequipped(mob/living/carbon/human/user, var/from_slot = null)
	..()
	if(from_slot == slot_wear_suit && istype(user))
		deactivate_suit(user)

/obj/item/clothing/suit/space/rig/process()
	if(gcDestroyed)
		return
	if(!activated)
		processing_objects.Remove(src)
		return
	if(!ishuman(loc))
		activated = FALSE
		return
	var/mob/living/carbon/human/wearer = loc
	if(!wearer.is_wearing_item(src, slot_wear_suit))
		return
	if(wearer.timestopped)
		return
	for(var/obj/item/rig_module/R in modules)
		if(R.activated && R.active_power_usage)
			if(!cell.use(R.active_power_usage))
				R.say_to_wearer("Not enough power available in [src]!")
				R.deactivate(R.wearer,src)	
				continue
			R.do_process()

/obj/item/clothing/suit/space/rig/proc/toggle_suit(mob/living/carbon/human/user)
	if(!user.is_wearing_item(src, slot_wear_suit))
		return
	!activated ? initialize_suit(user) : deactivate_suit(user)

/obj/item/clothing/suit/space/rig/proc/initialize_suit(mob/living/carbon/human/user, var/equipall = TRUE)
	if(equipall)
		for(var/obj/item/rig_module/priority_module in modules)
			if(priority_module.requires_component)
				priority_module.activate(user,src)
		if(T)
			if(user.s_store)
				user.remove_from_mob(user.s_store)
			to_chat(user, "<span class = 'notice'>\The [T] extends from \the [src].</span>")
			user.equip_to_slot(T, slot_s_store)
			T = null
		if(H)
			if(user.head)
				user.remove_from_mob(user.head)
			to_chat(user, "<span class = 'notice'>\The [H] extends from \the [src].</span>")
			user.equip_to_slot(H, slot_head)
			if(!user.internal)
				user.toggle_internals(user)
			H = null
		if(G)
			if(user.gloves)
				user.remove_from_mob(user.gloves)
			to_chat(user, "<span class = 'notice'>\The [G] extends from \the [src].</span>")
			user.equip_to_slot(G, slot_gloves)
			G = null
		if(MB)
			if(user.shoes)
				user.remove_from_mob(user.shoes)
			to_chat(user, "<span class = 'notice'>\The [MB] extends from \the [src].</span>")
			user.equip_to_slot(MB, slot_shoes)
			MB = null
	for(var/obj/item/rig_module/module in modules)
		if(!module.activated) //Skip what is already activated.
			module.activate(user,src)
	activated = TRUE
	processing_objects.Add(src)

/obj/item/clothing/suit/space/rig/proc/deactivate_suit(mob/living/carbon/human/user, var/unequipall = TRUE)
	if(unequipall)
		if(head_type && user.head)
			if(!H)
				if(istype(user.head, head_type))
					var/obj/item/clothing/UH = user.head
					to_chat(user, "<span class = 'notice'>\The [UH] retracts into \the [src].</span>")
					user.u_equip(UH,0)
					UH.forceMove(src)
					H = UH
				else
					to_chat(user, "<span class = 'warning'>\The [user.head] isn't compatible with \the [src].</span>")
		if(gloves_type && user.gloves)
			if(!G)
				if(istype(user.gloves, gloves_type))
					var/obj/item/clothing/UG = user.gloves
					to_chat(user, "<span class = 'notice'>\The [UG] retracts into \the [src].</span>")
					user.u_equip(UG,0)
					UG.forceMove(src)
					G = UG
				else
					to_chat(user, "<span class = 'warning'>\The [user.gloves] isn't compatible with \the [src].</span>")
		if(tank_type && user.s_store)
			if(!T)
				if(istype(user.s_store, tank_type))
					var/obj/item/weapon/tank/UT = user.s_store
					to_chat(user, "<span class = 'notice'>\The [UT] retracts into \the [src].</span>")
					user.u_equip(UT,0)
					UT.forceMove(src)
					T = UT
				else
					to_chat(user, "<span class = 'warning'>\The [user.s_store] isn't compatible with \the [src].</span>")
		if(boots_type && user.shoes)
			if(!MB)
				if(istype(user.shoes, boots_type))
					var/obj/item/clothing/UMB = user.shoes
					to_chat(user, "<span class = 'notice'>\The [UMB] retracts into \the [src].</span>")
					user.u_equip(UMB,0)
					UMB.forceMove(src)
					MB = UMB
				else
					to_chat(user, "<span class = 'warning'>\The [user.shoes] isn't compatible with \the [src].</span>")
	for(var/obj/item/rig_module/R in modules)
		R.deactivate(user,src)
	activated = FALSE
	if(processing_objects.Find(src))
		processing_objects.Remove(src)

/obj/item/clothing/suit/space/rig/attackby(obj/W, mob/user)
	if(head_type && !H && istype(W, head_type) && user.drop_item(W, src, force_drop = TRUE))
		to_chat(user, "<span class = 'notice'>You attach \the [W] to \the [src].</span>")
		H = W
		H.rig = src
		return
	if(gloves_type && !G && istype(W, gloves_type) && user.drop_item(W, src, force_drop = TRUE))
		to_chat(user, "<span class = 'notice'>You attach \the [W] to \the [src].</span>")
		G = W
		return
	if(tank_type && !T && istype(W, tank_type) && user.drop_item(W, src, force_drop = TRUE))
		to_chat(user, "<span class = 'notice'>You attach \the [W] to \the [src].</span>")
		T = W
		return
	if(boots_type && !MB && istype(W, boots_type) && user.drop_item(W, src, force_drop = TRUE))
		to_chat(user, "<span class = 'notice'>You attach \the [W] to \the [src].</span>")
		MB = W
		return
	..()
