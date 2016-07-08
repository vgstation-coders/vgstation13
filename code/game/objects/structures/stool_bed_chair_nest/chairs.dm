/obj/structure/bed/chair
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair"
	sheet_amt = 1
	var/image/buckle_overlay = null // image for overlays when a mob is buckled to the chair
	var/overrideghostspin = 0 //Set it to 1 if ghosts should NEVER be able to spin this

	lock_type = /datum/locking_category/chair

/obj/structure/bed/chair/New()
	..()
	spawn(3)
		handle_layer()

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
		layer = FLY_LAYER
		plane = PLANE_EFFECTS
	else
		layer = OBJ_LAYER
		plane = PLANE_OBJ

/obj/structure/bed/chair/proc/spin()
	change_dir(turn(dir, 90))

/obj/structure/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return

	if((!config.ghost_interaction && !blessed) || overrideghostspin)
		if(usr.isUnconscious() || usr.restrained())
			return

	spin()

/obj/structure/bed/chair/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!istype(M)) return
	var/mob/living/carbon/human/target = null
	if(ishuman(M))
		target = M
	if((target) && (target.op_stage.butt == 4)) //Butt surgery is at stage 4
		if(!M.weakened)	//Spam prevention
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

			M.Weaken(5)
		else
			to_chat(user, "You can't buckle [M.name] to [src], They just fell out!")

	else
		buckle_mob(M, user)

// Chair types
/obj/structure/bed/chair/wood
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3
	// TODO:  Special ash subtype that looks like charred chair legs

	sheet_type = /obj/item/stack/sheet/wood
	sheet_amt = 3

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


	sheet_amt = 2


/obj/structure/bed/chair/comfy/New()
	..()
	buckle_overlay = image("icons/obj/objects.dmi", "[icon_state]_armrest", MOB_LAYER + 0.1)
	buckle_overlay.plane = PLANE_MOB

/obj/structure/bed/chair/comfy/lock_atom(var/atom/movable/AM)
	..()
	update_icon()

/obj/structure/bed/chair/comfy/unlock_atom(var/atom/movable/AM)
	..()
	update_icon()

/obj/structure/bed/chair/comfy/update_icon()
	..()
	if(locked_atoms.len)
		overlays += buckle_overlay
	else
		overlays -= buckle_overlay

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
	sheet_amt = 5

	anchored = 0

/obj/structure/bed/chair/office/New()
	..()
	buckle_overlay = image("icons/obj/objects.dmi", "[icon_state]-overlay", MOB_LAYER + 0.1)
	buckle_overlay.plane = PLANE_MOB

/obj/structure/bed/chair/office/lock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/chair/office/unlock_atom(var/atom/movable/AM)
	..()
	update_icon()

/obj/structure/bed/chair/office/update_icon()
	..()
	if(locked_atoms.len)
		overlays += buckle_overlay
	else
		overlays -= buckle_overlay

	handle_layer() 				         // part of layer fix


/obj/structure/bed/chair/office/handle_layer() // Fixes layer problem when and office chair is buckled and facing north
	if(dir == NORTH && !locked_atoms.len)
		layer = FLY_LAYER
		plane = PLANE_EFFECTS
	else
		layer = OBJ_LAYER
		plane = PLANE_OBJ



/obj/structure/bed/chair/office/light
	icon_state = "officechair_white"

/obj/structure/bed/chair/office/dark
	icon_state = "officechair_dark"



// Subtype only for seperation purposes.
/datum/locking_category/chair


// Couches, offshoot of /comfy/ so that the armrest code can be used easily

/obj/structure/bed/chair/comfy/couch
	name = "couch"
	desc = "Looks really comfy."
	sheet_amt = 3
	anchored = 1
	overrideghostspin = 1

// layer stuff

/obj/structure/bed/chair/comfy/couch/turn/handle_layer() // makes sure mobs arent buried under certain chair sprites
	layer = OBJ_LAYER
	plane = PLANE_OBJ

/obj/structure/bed/chair/comfy/couch/turn/New()			 // adds in the overlay at all times so that it looks like mobs are in the couch rather than infront of or buried under it
	..()
	overlays += buckle_overlay							 // since the corners are "3 dimensional" the sprites were a bit tricky.


// Beige couch

/obj/structure/bed/chair/comfy/couch/left/beige // might be better to do ..../biege/(direction) so that one can add different flavour text for different colors more easily
	icon_state = "couch_left_beige"				// but since i need to fix the sprites for the .../turn/... parts this is the way it is

/obj/structure/bed/chair/comfy/couch/right/beige
	icon_state = "couch_right_beige"

/obj/structure/bed/chair/comfy/couch/mid/beige // mid refers to a straight couch part
	icon_state = "couch_mid_beige"

/obj/structure/bed/chair/comfy/couch/turn/inward/beige // and turn is a corner couch part
	icon_state = "couch_turn_in_beige"

/obj/structure/bed/chair/comfy/couch/turn/outward/beige
	icon_state = "couch_turn_out_beige"

// Red couch

/obj/structure/bed/chair/comfy/couch/left/red
	icon_state = "couch_left_red"

/obj/structure/bed/chair/comfy/couch/right/red
	icon_state = "couch_right_red"

/obj/structure/bed/chair/comfy/couch/mid/red
	icon_state = "couch_mid_red"

/obj/structure/bed/chair/comfy/couch/turn/inward/red
	icon_state = "couch_turn_in_red"

/obj/structure/bed/chair/comfy/couch/turn/outward/red
	icon_state = "couch_turn_out_red"

// Black couch

/obj/structure/bed/chair/comfy/couch/left/black
	icon_state = "couch_left_black"

/obj/structure/bed/chair/comfy/couch/right/black
	icon_state = "couch_right_black"

/obj/structure/bed/chair/comfy/couch/mid/black
	icon_state = "couch_mid_black"

/obj/structure/bed/chair/comfy/couch/turn/inward/black
	icon_state = "couch_turn_in_black"

/obj/structure/bed/chair/comfy/couch/turn/outward/black
	icon_state = "couch_turn_out_black"

//Teal couch

/obj/structure/bed/chair/comfy/couch/left/teal
	icon_state = "couch_left_teal"

/obj/structure/bed/chair/comfy/couch/right/teal
	icon_state = "couch_right_teal"

/obj/structure/bed/chair/comfy/couch/mid/teal
	icon_state = "couch_mid_teal"

/obj/structure/bed/chair/comfy/couch/turn/inward/teal
	icon_state = "couch_turn_in_teal"

/obj/structure/bed/chair/comfy/couch/turn/outward/teal
	icon_state = "couch_turn_out_teal"

