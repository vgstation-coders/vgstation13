/obj/item/clothing
	name = "clothing"
	resistance_flags = FLAMMABLE
	max_integrity = 200
	integrity_failure = 80
	var/damaged_clothes = 0 //similar to machine's BROKEN stat and structure's broken var
	var/flash_protect = 0		//What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/tint = 0				//Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = 0					//but separated to allow items to protect but not impair vision, like space helmets
	var/visor_flags = 0			//flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = 0		//same as visor_flags, but for flags_inv
	var/visor_flags_cover = 0	//same as above, but for flags_cover
//what to toggle when toggled with weldingvisortoggle()
	var/visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_VISIONFLAGS | VISOR_DARKNESSVIEW | VISOR_INVISVIEW
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/alt_desc = null
	var/toggle_message = null
	var/alt_toggle_message = null
	var/active_sound = null
	var/toggle_cooldown = null
	var/cooldown = 0
	var/obj/item/device/flashlight/F = null
	var/can_flashlight = 0
	var/scan_reagents = 0 //Can the wearer see reagents while it's equipped?

	//Var modification - PLEASE be careful with this I know who you are and where you live
	var/list/user_vars_to_edit = list() //VARNAME = VARVALUE eg: "name" = "butts"
	var/list/user_vars_remembered = list() //Auto built by the above + dropped() + equipped()

	var/obj/item/storage/internal/pocket/pockets = null

	//These allow head/mask items to dynamically alter the user's hair
	// and facial hair, checking hair_extensions.dmi and facialhair_extensions.dmi
	// for a state matching hair_state+dynamic_hair_suffix
	// THESE OVERRIDE THE HIDEHAIR FLAGS
	var/dynamic_hair_suffix = ""//head > mask for head hair
	var/dynamic_fhair_suffix = ""//mask > head for facial hair

/obj/item/clothing/New()
	..()
	if(ispath(pockets))
		pockets = new pockets(src)

/obj/item/clothing/MouseDrop(atom/over_object)
	var/mob/M = usr

	if(pockets && over_object == M)
		return pockets.MouseDrop(over_object)

	if(ismecha(M.loc)) // stops inventory actions in a mech
		return

	if(!M.incapacitated() && loc == M && istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
			add_fingerprint(usr)

/obj/item/clothing/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	if(pockets)
		pockets.close_all()
	return ..()

/obj/item/clothing/attack_hand(mob/user)
	if(pockets && pockets.priority && ismob(loc))
		//If we already have the pockets open, close them.
		if (user.s_active == pockets)
			pockets.close(user)
		//Close whatever the user has open and show them the pockets.
		else
			if (user.s_active)
				user.s_active.close(user)
			pockets.orient2hud(user)
			pockets.show_to(user)
	else
		return ..()

/obj/item/clothing/attackby(obj/item/W, mob/user, params)
	if(damaged_clothes && istype(W, /obj/item/stack/sheet/cloth))
		var/obj/item/stack/sheet/cloth/C = W
		C.use(1)
		update_clothes_damaged_state(FALSE)
		obj_integrity = max_integrity
		to_chat(user, "<span class='notice'>You fix the damage on [src] with [C].</span>")
		return 1
	if(pockets)
		var/i = pockets.attackby(W, user, params)
		if(i)
			return i
	return ..()

/obj/item/clothing/AltClick(mob/user)
	if(istype(user) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)) && pockets && pockets.quickdraw && pockets.contents.len)
		var/obj/item/I = pockets.contents[1]
		if(!I)
			return
		pockets.remove_from_storage(I, get_turf(src))

		if(!user.put_in_hands(I))
			to_chat(user, "<span class='notice'>You fumble for [I] and it falls on the floor.</span>")
			return 1
		user.visible_message("<span class='warning'>[user] draws [I] from [src]!</span>", "<span class='notice'>You draw [I] from [src].</span>")
		return 1
	else
		return ..()


/obj/item/clothing/Destroy()
	if(pockets)
		qdel(pockets)
		pockets = null
	user_vars_remembered = null //Oh god somebody put REFERENCES in here? not to worry, we'll clean it up
	return ..()


/obj/item/clothing/dropped(mob/user)
	..()
	if(!istype(user))
		return
	if(user_vars_remembered && user_vars_remembered.len)
		for(var/variable in user_vars_remembered)
			if(variable in user.vars)
				if(user.vars[variable] == user_vars_to_edit[variable]) //Is it still what we set it to? (if not we best not change it)
					user.vars[variable] = user_vars_remembered[variable]
		user_vars_remembered = list()


/obj/item/clothing/equipped(mob/user, slot)
	..()

	if(slot_flags & slotdefine2slotbit(slot)) //Was equipped to a valid slot for this item?
		for(var/variable in user_vars_to_edit)
			if(variable in user.vars)
				user_vars_remembered[variable] = user.vars[variable]
				user.vars[variable] = user_vars_to_edit[variable]


/obj/item/clothing/examine(mob/user)
	..()
	if(damaged_clothes)
		to_chat(user,  "<span class='warning'>It looks damaged!</span>")
	if(pockets)
		var/list/how_cool_are_your_threads = list("<span class='notice'>")
		if(pockets.priority)
			how_cool_are_your_threads += "[src]'s storage opens when clicked.\n"
		else
			how_cool_are_your_threads += "[src]'s storage opens when dragged to yourself.\n"
		how_cool_are_your_threads += "[src] can store [pockets.storage_slots] item\s.\n"
		how_cool_are_your_threads += "[src] can store items that are [weightclass2text(pockets.max_w_class)] or smaller.\n"
		if(pockets.quickdraw)
			how_cool_are_your_threads += "You can quickly remove an item from [src] using Alt-Click.\n"
		if(pockets.silent)
			how_cool_are_your_threads += "Adding or removing items from [src] makes no noise.\n"
		how_cool_are_your_threads += "</span>"
		to_chat(user, how_cool_are_your_threads.Join())

/obj/item/clothing/obj_break(damage_flag)
	if(!damaged_clothes)
		update_clothes_damaged_state(TRUE)
	if(ismob(loc)) //It's not important enough to warrant a message if nobody's wearing it
		var/mob/M = loc
		M.visible_message("<span class='warning'>[M]'s [name] starts to fall apart!", "<span class='warning'>Your [name] starts to fall apart!</span>")

/obj/item/clothing/proc/update_clothes_damaged_state(damaging = TRUE)
	var/index = "[REF(initial(icon))]-[initial(icon_state)]"
	var/static/list/damaged_clothes_icons = list()
	if(damaging)
		damaged_clothes = 1
		var/icon/damaged_clothes_icon = damaged_clothes_icons[index]
		if(!damaged_clothes_icon)
			damaged_clothes_icon = icon(initial(icon), initial(icon_state), , 1)	//we only want to apply damaged effect to the initial icon_state for each object
			damaged_clothes_icon.Blend("#fff", ICON_ADD) 	//fills the icon_state with white (except where it's transparent)
			damaged_clothes_icon.Blend(icon('icons/effects/item_damage.dmi', "itemdamaged"), ICON_MULTIPLY) //adds damage effect and the remaining white areas become transparant
			damaged_clothes_icon = fcopy_rsc(damaged_clothes_icon)
			damaged_clothes_icons[index] = damaged_clothes_icon
		add_overlay(damaged_clothes_icon, 1)
	else
		damaged_clothes = 0
		cut_overlay(damaged_clothes_icons[index], TRUE)


/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/

/proc/generate_female_clothing(index,t_color,icon,type)
	var/icon/female_clothing_icon	= icon("icon"=icon, "icon_state"=t_color)
	var/icon/female_s				= icon("icon"='icons/mob/uniform.dmi', "icon_state"="[(type == FEMALE_UNIFORM_FULL) ? "female_full" : "female_top"]")
	female_clothing_icon.Blend(female_s, ICON_MULTIPLY)
	female_clothing_icon 			= fcopy_rsc(female_clothing_icon)
	GLOB.female_clothing_icons[index] = female_clothing_icon

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	if(src.has_sensor == LOCKED_SENSORS)
		to_chat(usr, "The controls are locked.")
		return 0
	if(src.has_sensor == BROKEN_SENSORS)
		to_chat(usr, "The sensors have shorted out!")
		return 0
	if(src.has_sensor <= NO_SENSORS)
		to_chat(usr, "This suit does not have any sensors.")
		return 0

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(usr, src) > 1)
		to_chat(usr, "<span class='warning'>You have moved too far away!</span>")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == usr)
		switch(sensor_mode)
			if(0)
				to_chat(usr, "<span class='notice'>You disable your suit's remote sensing equipment.</span>")
			if(1)
				to_chat(usr, "<span class='notice'>Your suit will now only report whether you are alive or dead.</span>")
			if(2)
				to_chat(usr, "<span class='notice'>Your suit will now only report your exact vital lifesigns.</span>")
			if(3)
				to_chat(usr, "<span class='notice'>Your suit will now report your exact vital lifesigns as well as your coordinate position.</span>")

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.w_uniform == src)
			H.update_suit_sensors()

	..()

/obj/item/clothing/under/AltClick(mob/user)
	if(..())
		return 1

	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	else
		if(attached_accessory)
			remove_accessory(user)
		else
			rolldown()

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr
	rolldown()

/obj/item/clothing/under/proc/rolldown()
	if(!can_use(usr))
		return
	if(!can_adjust)
		to_chat(usr, "<span class='warning'>You cannot wear this suit any differently!</span>")
		return
	if(toggle_jumpsuit_adjust())
		to_chat(usr, "<span class='notice'>You adjust the suit to wear it more casually.</span>")
	else
		to_chat(usr, "<span class='notice'>You adjust the suit back to normal.</span>")
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_inv_w_uniform()
		H.update_body()

/obj/item/clothing/under/proc/toggle_jumpsuit_adjust()
	if(adjusted == DIGITIGRADE_STYLE)
		return
	adjusted = !adjusted
	if(adjusted)
		if(fitted != FEMALE_UNIFORM_TOP)
			fitted = NO_FEMALE_UNIFORM
		if(!alt_covers_chest) // for the special snowflake suits that expose the chest when adjusted
			body_parts_covered &= ~CHEST
	else
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST
	return adjusted

/obj/item/clothing/proc/weldingvisortoggle(mob/user) //proc to toggle welding visors on helmets, masks, goggles, etc.
	if(!can_use(user))
		return FALSE

	visor_toggling()

	to_chat(user, "<span class='notice'>You adjust \the [src] [up ? "up" : "down"].</span>")

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	return TRUE

/obj/item/clothing/proc/visor_toggling() //handles all the actual toggling of flags
	up = !up
	flags_1 ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= initial(flags_cover)
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)


/obj/item/clothing/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return 1
	return 0


/obj/item/clothing/obj_destruction(damage_flag)
	if(damage_flag == "bomb" || damage_flag == "melee")
		var/turf/T = get_turf(src)
		spawn(1) //so the shred survives potential turf change from the explosion.
			var/obj/effect/decal/cleanable/shreds/Shreds = new(T)
			Shreds.desc = "The sad remains of what used to be [name]."
		deconstruct(FALSE)
	else
		..()