/obj/structure/bed/chair
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair"
	sheet_amt = 1
	var/image/buckle_overlay = null // image for overlays when a mob is buckled to the chair
	var/image/secondary_buckle_overlay = null // for those really complicated chairs
	var/noghostspin = 0 //Set it to 1 if ghosts should NEVER be able to spin this

	lock_type = /datum/locking_category/buckle/chair

/obj/structure/bed/chair/New()
	..()
	if(ticker)
		initialize()

/obj/structure/bed/chair/initialize()
	..()
	handle_layer()

/obj/structure/bed/chair/can_spook()
	. = ..()
	if(.)
		return !noghostspin

/obj/structure/bed/chair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(user.drop_item(W))
			var/obj/structure/bed/chair/e_chair/E = new /obj/structure/bed/chair/e_chair(src.loc)
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			E.dir = dir
			E.part = SK
			SK.forceMove(E)
			SK.master = E
			qdel(src)
			return

	if(iswrench(W))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		getFromPool(sheet_type, get_turf(src), sheet_amt)
		qdel(src)
		return

	. = ..()

/obj/structure/bed/chair/update_dir()
	..()

	handle_layer()

/obj/structure/bed/chair/proc/handle_layer()
	if(dir == NORTH)
		plane = ABOVE_HUMAN_PLANE
	else
		plane = OBJ_PLANE

/obj/structure/bed/chair/proc/spin()
	change_dir(turn(dir, 90))

/obj/structure/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return

	if(!config.ghost_interaction || !can_spook())
		if(usr.isUnconscious() || usr.restrained())
			return

	if(isobserver(usr))
		var/mob/dead/observer/ghost = usr
		if(ghost.lastchairspin <= world.time - 5) //do not spam this
			investigation_log(I_GHOST, "|| was rotated by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
		ghost.lastchairspin = world.time

	spin()

/obj/structure/bed/chair/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!istype(M))
		return
	var/mob/living/carbon/human/target = null
	if(ishuman(M))
		target = M
	if((target) && (target.op_stage.butt == 4)) //Butt surgery is at stage 4
		if(!M.knockdown)	//Spam prevention
			if(M == usr)
				M.visible_message(\
					"<span class='notice'>[M.name] has no butt, and slides right out of [src]!</span>",\
					"Having no butt, you slide right out of the [src]",\
					"You hear metal clanking.")

			else
				M.visible_message(\
					"<span class='notice'>[M.name] has no butt, and slides right out of [src]!</span>",\
					"Having no butt, you slide right out of the [src]",\
					"You hear metal clanking.")

			M.Knockdown(5)
		else
			to_chat(user, "You can't buckle [M.name] to [src], They just fell out!")

	else
		buckle_mob(M, user)

// Chair types
/obj/structure/bed/chair/wood
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 1
	// TODO:  Special ash subtype that looks like charred chair legs

	sheet_type = /obj/item/stack/sheet/wood
	sheet_amt = 1

/obj/structure/bed/chair/wood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/wood/wings/cultify()
	return

/obj/structure/bed/chair/holowood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/holowood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/holowood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

//Comfy chairs

/obj/structure/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair_black"


	sheet_amt = 1


/obj/structure/bed/chair/comfy/New()
	..()
	buckle_overlay = image("icons/obj/objects.dmi", "[icon_state]_armrest", CHAIR_ARMREST_LAYER)
	buckle_overlay.plane = ABOVE_HUMAN_PLANE

/obj/structure/bed/chair/comfy/lock_atom(var/atom/movable/AM)
	..()
	update_icon()

/obj/structure/bed/chair/comfy/unlock_atom(var/atom/movable/AM)
	..()
	update_icon()

/obj/structure/bed/chair/comfy/update_icon()
	..()
	if(is_locking(lock_type))
		overlays += buckle_overlay
		if(secondary_buckle_overlay)
			overlays += secondary_buckle_overlay
	else
		overlays -= buckle_overlay
		if(secondary_buckle_overlay)
			overlays -= secondary_buckle_overlay

/obj/structure/bed/chair/comfy/attackby(var/obj/item/W, var/mob/user)
	if (iswrench(W))
		for (var/atom/movable/AM in src)
			AM.forceMove(loc)

		return ..()

	if (W.w_class <= W_CLASS_SMALL)
		if (contents.len)
			to_chat(user, "There is already an item between \the [src]'s cushions.")
			return

		if (user.drop_item(W, src))
			to_chat(user, "You hide \the [W] between \the [src]'s cushions.")

		return TRUE

	return ..()

/obj/structure/bed/chair/comfy/attack_hand(var/mob/user)
	if(is_locking(lock_type))
		return ..()

	for (var/obj/item/I in src)
		user.put_in_hands(I)
		to_chat(user, "You pull out \the [I] between \the [src]'s cushions.")

/obj/structure/bed/chair/comfy/brown
	icon_state = "comfychair_brown"

/obj/structure/bed/chair/comfy/beige
	icon_state = "comfychair_beige"

/obj/structure/bed/chair/comfy/teal
	icon_state = "comfychair_teal"

/obj/structure/bed/chair/comfy/black
	icon_state = "comfychair_black"

/obj/structure/bed/chair/comfy/lime
	icon_state = "comfychair_lime"

//Office chairs

/obj/structure/bed/chair/office
	icon_state = "officechair_white"
	sheet_amt = 1

	anchored = 0

/obj/structure/bed/chair/office/New()
	..()
	buckle_overlay = image("icons/obj/objects.dmi", "[icon_state]-overlay", CHAIR_ARMREST_LAYER)
	buckle_overlay.plane = ABOVE_HUMAN_PLANE

/obj/structure/bed/chair/office/lock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/chair/office/unlock_atom(var/atom/movable/AM)
	..()
	update_icon()

/obj/structure/bed/chair/office/update_icon()
	..()
	if(is_locking(lock_type))
		overlays += buckle_overlay
	else
		overlays -= buckle_overlay

	handle_layer() 				         // part of layer fix


/obj/structure/bed/chair/office/handle_layer() // Fixes layer problem when and office chair is buckled and facing north
	if(dir == NORTH && !is_locking(lock_type))
		layer = CHAIR_ARMREST_LAYER
		plane = ABOVE_HUMAN_PLANE
	else
		layer = OBJ_LAYER
		plane = OBJ_PLANE



/obj/structure/bed/chair/office/light
	icon_state = "officechair_white"

/obj/structure/bed/chair/office/dark
	icon_state = "officechair_dark"



// Subtype only for seperation purposes.
/datum/locking_category/buckle/chair


// Couches, offshoot of /comfy/ so that the armrest code can be used easily

/obj/structure/bed/chair/comfy/couch
	name = "couch"
	desc = "Looks really comfy."
	sheet_amt = 2
	anchored = 1
	noghostspin = 1
	var/image/legs
	color = null

// layer stuff

/obj/structure/bed/chair/comfy/couch/New()

	legs = image("icons/obj/objects.dmi", "[icon_state]_legs", CHAIR_LEG_LAYER)		// since i dont want the legs colored they are a separate overlay
	legs.plane = OBJ_PLANE															//
	legs.appearance_flags = RESET_COLOR												//
	overlays += legs
	secondary_buckle_overlay = image("icons/obj/objects.dmi", "[icon_state]_armrest_legs", CHAIR_ARMREST_LAYER)		// since i dont want the legs colored they are a separate overlay
	secondary_buckle_overlay.plane = ABOVE_HUMAN_PLANE																//
	secondary_buckle_overlay.appearance_flags = RESET_COLOR
	..()
	overlays += buckle_overlay
	handle_layer()


/obj/structure/bed/chair/comfy/couch/turn/handle_layer() // makes sure mobs arent buried under certain chair sprites
	layer = OBJ_LAYER
	plane = OBJ_PLANE









// Grey base couch


/obj/structure/bed/chair/comfy/couch/left
	icon_state = "couch_left"

/obj/structure/bed/chair/comfy/couch/right/
	icon_state = "couch_right"

/obj/structure/bed/chair/comfy/couch/mid/ // mid refers to a straight couch part
	icon_state = "couch_mid"

/obj/structure/bed/chair/comfy/couch/turn/inward// and turn is a corner couch part
	icon_state = "couch_turn_in"

/obj/structure/bed/chair/comfy/couch/turn/outward/
	icon_state = "couch_turn_out"


// #cbcab9 beige

/obj/structure/bed/chair/comfy/couch/left/beige
	color = "#cbcab9"
/obj/structure/bed/chair/comfy/couch/right/beige
	color = "#cbcab9"
/obj/structure/bed/chair/comfy/couch/mid/beige
	color = "#cbcab9"
/obj/structure/bed/chair/comfy/couch/turn/inward/beige
	color = "#cbcab9"
/obj/structure/bed/chair/comfy/couch/turn/outward/beige
	color = "#cbcab9"

// #bab866 lime
/obj/structure/bed/chair/comfy/couch/left/lime
	color = "#bab866"
/obj/structure/bed/chair/comfy/couch/right/lime
	color = "#bab866"
/obj/structure/bed/chair/comfy/couch/mid/lime
	color = "#bab866"
/obj/structure/bed/chair/comfy/couch/turn/inward/lime
	color = "#bab866"
/obj/structure/bed/chair/comfy/couch/turn/outward/lime


// #ae774c brown

/obj/structure/bed/chair/comfy/couch/left/brown
	color = "#ae774c"
/obj/structure/bed/chair/comfy/couch/right/brown
	color = "#ae774c"
/obj/structure/bed/chair/comfy/couch/mid/brown
	color = "#ae774c"
/obj/structure/bed/chair/comfy/couch/turn/inward/brown
	color = "#ae774c"
/obj/structure/bed/chair/comfy/couch/turn/outward/brown
	color = "#ae774c"

// #66baba teal

/obj/structure/bed/chair/comfy/couch/left/teal
	color = "#66baba"
/obj/structure/bed/chair/comfy/couch/right/teal
	color = "#66baba"
/obj/structure/bed/chair/comfy/couch/mid/teal
	color = "#66baba"
/obj/structure/bed/chair/comfy/couch/turn/inward/teal
	color = "#66baba"
/obj/structure/bed/chair/comfy/couch/turn/outward/teal
	color = "#66baba"

// #81807c black

/obj/structure/bed/chair/comfy/couch/left/black
	color = "#81807c"
/obj/structure/bed/chair/comfy/couch/right/black
	color = "#81807c"
/obj/structure/bed/chair/comfy/couch/mid/black
	color = "#81807c"
/obj/structure/bed/chair/comfy/couch/turn/inward/black
	color = "#81807c"
/obj/structure/bed/chair/comfy/couch/turn/outward/black
	color = "#81807c"


// #c94c4c red

/obj/structure/bed/chair/comfy/couch/left/red
	color = "#c94c4c"
/obj/structure/bed/chair/comfy/couch/right/red
	color = "#c94c4c"
/obj/structure/bed/chair/comfy/couch/mid/red
	color = "#c94c4c"
/obj/structure/bed/chair/comfy/couch/turn/inward/red
	color = "#c94c4c"
/obj/structure/bed/chair/comfy/couch/turn/outward/red
	color = "#c94c4c"

//Folding chair

/obj/structure/bed/chair/folding
	name = "folding chair"
	icon_state = "folding_chair"
	anchored = 0
	var/obj/item/folding_chair/folded

/obj/structure/bed/chair/folding/New(turf/T, var/chair)
	..(T)
	if(!folded)
		if(chair)
			folded = chair
		else
			folded = new(src, src)

/obj/structure/bed/chair/folding/Destroy()
	if(folded)
		folded.unfolded = null
		qdel(folded)
		folded = null
	..()

/obj/item/folding_chair
	name = "folding chair"
	desc = "A collapsed folding chair that can be carried around."
	icon = 'icons/obj/stools-chairs-beds.dmi'
	icon_state = "folded_chair"
	w_class = W_CLASS_LARGE
	var/obj/structure/bed/chair/folding/unfolded

/obj/item/folding_chair/New(turf/T, var/chair)
	..(T)
	if(!unfolded)
		if(chair)
			unfolded = chair
		else
			unfolded = new(src, src)

/obj/item/folding_chair/Destroy()
	if(unfolded)
		unfolded.folded = null
		qdel(unfolded)
		unfolded = null
	..()

/obj/item/folding_chair/attack_self(mob/user)
	unfolded.forceMove(user.loc)
	unfolded.add_fingerprint(user)
	unfolded.dir = user.dir
	user.drop_item(src, force_drop = 1)
	forceMove(unfolded)

/obj/structure/bed/chair/folding/MouseDrop(over_object, src_location, over_location)
	..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr) || usr.incapacitated() || usr.lying)
			return

		if(is_locking(lock_type))
			return 0

		visible_message("[usr] folds up \the [src].")

		folded.forceMove(get_turf(src))
		forceMove(folded)
