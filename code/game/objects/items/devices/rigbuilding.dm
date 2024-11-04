/obj/item/device/rigframe
	name = "Hardsuit frame"
	desc = "An incomplete hardsuit frame, lacking all sealing and armor plating. Its unfinished state makes it impossible to actually wear. The wiring on this frame has not yet been installed."
	icon_state = "rigframe_0"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/spacesuits.dmi', "right_hand" = 'icons/mob/in-hand/right/spacesuits.dmi')
	w_class = W_CLASS_LARGE
	var/buildstate = RIG_EMPTY
	var/obj/item/weapon/cell/cell = null
	var/obj/item/clothing/suit/space/rig/result = null //changes based on which kit you use

/obj/item/device/rigframe/update_icon()
	switch(buildstate)
		if(RIG_EMPTY)
			icon_state = "rigframe_0"
			desc = "An incomplete hardsuit frame, lacking all sealing and armor plating. Its unfinished state makes it impossible to actually wear. The wiring on this frame has not yet been installed."
		if(RIG_WIRED)
			icon_state = "rigframe_1"
			desc = "An incomplete hardsuit frame, lacking all sealing and armor plating. Its unfinished state makes it impossible to actually wear. The wiring is installed, but not secure."
		if(RIG_WIRED_SECURE)
			icon_state = "rigframe_2"
			desc = "An incomplete hardsuit frame, lacking all sealing and armor plating. Its unfinished state makes it impossible to actually wear. Though the wiring is secure, it lacks a power source."
		if(RIG_CELL)
			icon_state = "rigframe_2"
			desc = "An incomplete hardsuit frame, lacking all sealing and armor plating. Its unfinished state makes it impossible to actually wear. This frame is ready to receive its plating."
		if(RIG_PLATE)
			icon_state = "rigframe_3"
			desc = "A nearly-complete hardsuit frame. The plates are installed, but not yet fastened. You couldn't wear it without it falling apart around you."
		else
			icon_state = "rigframe_0" // shouldn't happen

/obj/item/device/rigframe/Destroy()
	QDEL_NULL(cell)
	..()

/obj/item/device/rigframe/attackby(obj/item/weapon/W, mob/user)
	if(src.loc == user)
		to_chat(user, "You need to place \the [src] on the ground before modifying it.")
		return

	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(buildstate != RIG_EMPTY)
			to_chat(user, "It's already wired!")
			return
		else if(C.use(5))
			to_chat(user, "You install the wires in \the [src].")
			playsound(user, 'sound/items/zip.ogg', 50, 1)
			buildstate = RIG_WIRED
			update_icon()
			return
		else
			to_chat(user, "You don't have enough cable to wire \the [src].")
			return

	else if(W.is_wirecutter(user))
		if(buildstate == RIG_WIRED)
			to_chat(user, "You secure the wiring in \the [src].")
			W.playtoolsound(src, 50)
			buildstate = RIG_WIRED_SECURE
			update_icon()
		else if (buildstate >= RIG_WIRED_SECURE)
			to_chat(user, "The wiring is already secure!")
			return
		else
			to_chat(user, "There are no wires to secure.")

	else if(istype(W, /obj/item/weapon/cell))
		var/obj/item/weapon/cell/P = W
		if(buildstate == RIG_WIRED_SECURE)
			if(!user.drop_item(W))
				to_chat(user, "You can't drop \the [P]!")
				return
			P.forceMove(src)
			cell = P
			to_chat(user, "You insert \the [P] into \the [src].")
			playsound(user, 'sound/items/Deconstruct.ogg', 50, 1)
			buildstate = RIG_CELL
			update_icon()
		else if(buildstate >= RIG_CELL)
			to_chat(user, "There's already a cell installed!")
			return
		else
			to_chat(user, "You have to secure the wires first.")
			return

	else if(istype(W, /obj/item/device/rigparts))
		var/obj/item/device/rigparts/R = W
		if(buildstate == RIG_CELL)
			result = R.result
			to_chat(user, "You install \the [R] onto \the [src].")
			playsound(user, 'sound/items/Deconstruct.ogg', 50, 1)
			buildstate = RIG_PLATE
			update_icon()
			qdel(R)
		else if(buildstate == RIG_PLATE)
			to_chat(user, "There's already plating on \the [src].")
			return
		else
			to_chat(user, "You can't install \the [R] yet.")
			return

	else if(W.is_screwdriver(user))
		if(buildstate == RIG_PLATE)
			to_chat(user, "You secure the plating on \the [src].")
			W.playtoolsound(src, 50)
			result = new result(get_turf(src.loc))
			QDEL_NULL(result.cell)
			cell.forceMove(result)
			result.cell = cell
			cell = null

			qdel(src)

		else
			to_chat(user, "Nothing on \the [src] needs securing right now.")
			return
	else
		return

// RIG Parts Kits
/obj/item/device/rigparts
	name = "Hardsuit parts kit"
	desc = "A set of plates, seals, and servos, ready for installation into a hardsuit frame."
	icon_state = "modkit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	var/result = /obj/item/clothing/suit/space/rig

/obj/item/device/rigparts/engineering
	name = "Engineering hardsuit parts kit"
	result = /obj/item/clothing/suit/space/rig/engineer

/obj/item/device/rigparts/atmos
	name = "Atmospherics hardsuit parts kit"
	result = /obj/item/clothing/suit/space/rig/atmos

/obj/item/device/rigparts/mining
	name = "Mining hardsuit parts kit"
	result = /obj/item/clothing/suit/space/rig/mining

/obj/item/device/rigparts/medical
	name = "Medical hardsuit parts kit"
	result = /obj/item/clothing/suit/space/rig/medical

/obj/item/device/rigparts/security
	name = "Security hardsuit parts kit"
	result = /obj/item/clothing/suit/space/rig/security

/obj/item/device/rigparts/arch
	name = "Archaeology hardsuit parts kit"
	result = /obj/item/clothing/suit/space/rig/arch

// Ayy RIG Parts Kits

/obj/item/device/rigparts/ayy_worker
	name = "Laborer rig parts kit"
	icon_state = "ayymodkit_worker_1"
	result = /obj/item/clothing/suit/space/rig/grey/worker

/obj/item/device/rigparts/ayy_worker/dissolvable()
	return WATER

/obj/item/device/rigparts/ayy_researcher
	name = "Researcher rig parts kit"
	icon_state = "ayymodkit_researcher_1"
	result = /obj/item/clothing/suit/space/rig/grey/researcher

/obj/item/device/rigparts/ayy_researcher/dissolvable()
	return WATER

/obj/item/device/rigparts/ayy_soldier
	name = "Soldier rig parts kit"
	icon_state = "ayymodkit_soldier_1"
	result = /obj/item/clothing/suit/space/rig/grey/soldier

/obj/item/device/rigparts/ayy_soldier/dissolvable()
	return WATER
