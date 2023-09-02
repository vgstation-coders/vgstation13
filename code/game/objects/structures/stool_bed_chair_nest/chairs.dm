//standardized colors for couches/comfy chairs
#define CHAIR_BEIGE "#cac3ad"
#define CHAIR_LIME "#aecf79"
#define CHAIR_BROWN "#ae774c"
#define CHAIR_TEAL "#63e4e4"
#define CHAIR_BLACK "#81807c"
#define CHAIR_RED "#e75555"

/obj/structure/bed/chair
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair"
	sheet_amt = 1
	var/image/buckle_overlay = null // image for overlays when a mob is buckled to the chair
	var/image/secondary_buckle_overlay = null // for those really complicated chairs
	var/can_rotate = TRUE
	var/ghost_can_rotate = TRUE
	mob_lock_type = /datum/locking_category/buckle/chair

/obj/structure/bed/chair/New()
	..()
	if(ticker)
		initialize()

/obj/structure/bed/chair/initialize()
	..()
	handle_layer()

/obj/structure/bed/chair/lock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/chair/unlock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/chair/update_icon()
	..()
	if(is_locking(mob_lock_type))
		if (buckle_overlay)
			overlays += buckle_overlay
		if (secondary_buckle_overlay)
			overlays += secondary_buckle_overlay
	else
		overlays -= buckle_overlay
		overlays -= secondary_buckle_overlay

	handle_layer() 				         // part of layer fix

/obj/structure/bed/chair/attackby(var/obj/item/weapon/W, var/mob/user)
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(user.drop_item(W))
			var/obj/structure/bed/chair/e_chair/E = new /obj/structure/bed/chair/e_chair(src.loc)
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			E.dir = dir
			E.part = SK
			SK.forceMove(E)
			SK.master = E
			qdel(src)
			return

	if(W.is_wrench(user))
		if (locked_atoms && locked_atoms.len)
			for (var/mob/living/L in locked_atoms)
				visible_message("<span class='warning'>\The [L] slips from the chair!</span>'")
				L.unlock_from(src)
				L.Stun(2)
		W.playtoolsound(src, 50)
		drop_stack(sheet_type, loc, sheet_amt, user)
		qdel(src)
		return

	if(istype(W, /obj/item/stack/sheet/plasteel))
		if(type in subtypesof(/obj/structure/bed/chair))//only default chairs can be upgraded into seats
			to_chat(user, "<span class='warning'>You Can only upgrade basic chairs.</span>")
			return
		else if (locked_atoms && locked_atoms.len > 0)
			to_chat(user, "<span class='warning'>You cannot upgrade a chair with someone buckled on it.</span>")
			return
		var/obj/item/stack/ST = W
		if (ST.amount < 5)
			to_chat(user, "<span class='warning'>You need 5 plasteel sheets to improve this chair.</span>")
			return

		var/list/ok_types = list(
			"neutral" = /obj/structure/bed/chair/shuttle,
			"red" = /obj/structure/bed/chair/shuttle/red,
			"blue" = /obj/structure/bed/chair/shuttle/blue,
			"yellow" = /obj/structure/bed/chair/shuttle/yellow,
			"white" = /obj/structure/bed/chair/shuttle/white,
			"custom" = /obj/structure/bed/chair/shuttle/white/custom,
			)

		var/seat_color = null
		var/seat_type = input(user,"What colour for the seat's cushions?","Upgrading chair to seat") as null|anything in ok_types


		if (!seat_type)
			return

		if (seat_type == "custom")
			seat_color = input(user, "Please select cushion color.", "Seat color") as color

		var/new_type = ok_types[seat_type]

		user.visible_message("<span class='notice'>\The [user] starts upgrading \the [src] using some plasteel.</span>", \
		"<span class='notice'>You begin upgrading \the [src].</span>")
		if(do_after(user, src, 50))
			if (ST.use(5))
				if (locked_atoms && locked_atoms.len > 0)
					to_chat(user, "<span class='warning'>You cannot upgrade a chair with someone buckled on it.</span>")
					return
				var/obj/structure/bed/chair/shuttle/S = new new_type(loc,seat_color)
				S.dir = dir
				playsound(S, 'sound/items/Deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>\The [user] upgrades \the [src] into \a [S].</span>", \
				"<span class='notice'>You finishing upgrading \the [src] into \a [S].</span>")
				qdel(src)
				return
			else
				to_chat(user, "<span class='warning'>You need 5 plasteel sheets to improve this chair.</span>")
				return
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

/obj/structure/bed/chair/proc/spin(mob/user)
	if(!can_rotate || !user || !isturf(user.loc))
		return

	if(isobserver(user))
		if(!ghost_can_rotate)
			return
		var/mob/dead/observer/ghost = user
		if(ghost.lastchairspin <= world.time - 5) //do not spam this
			investigation_log(I_GHOST, "|| was rotated by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
		ghost.lastchairspin = world.time

	change_dir(turn(dir, 90))

/obj/structure/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	spin(usr)

/obj/structure/bed/chair/relayface(var/mob/living/user, direction) //ALSO for vehicles!
	if(!can_rotate || user.incapacitated())
		return
	change_dir(direction)
	return 1

/obj/structure/bed/chair/AltClick(mob/user as mob)
	buckle_chair(user,user, 0) // Require to stand on the chair in order to do that

/obj/structure/bed/chair/MouseDropTo(mob/M as mob, mob/user as mob)
	buckle_chair(M,user)

/obj/structure/bed/chair/proc/buckle_chair(mob/M as mob, mob/user as mob, var/override_buckle_range = null)
	if(!istype(M))
		return

	var/effective_buckle_range = (isnull(override_buckle_range) ? buckle_range : override_buckle_range)

	var/mob/living/carbon/human/target = null
	if(ishuman(M))
		target = M

	if(user!=M && (!user.Adjacent(M) || !user.Adjacent(src)))
		return

	if(get_dist(src,user) > effective_buckle_range)
		return

	if(target && target.op_stage.butt == 4 && Adjacent(target) && user.Adjacent(src) && !user.incapacitated()) //Butt surgery is at stage 4
		if(!M.knockdown)	//Spam prevention
			M.visible_message(\
				"<span class='notice'>[M.name] has no butt, and slides right out of [src]!</span>",\
				"Having no butt, you slide right out of the [src]",\
				"You hear metal clanking.")

			M.Knockdown(5)
			M.Stun(5)
		else
			to_chat(user, "You can't buckle [M.name] to [src], They just fell out!")

	else
		buckle_mob(M, user)
	if(material_type)
		material_type.on_use(src,M,user)


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

/obj/structure/bed/chair/wood/pew
	name = "pew"
	desc = "Uncomfortable."
	sheet_amt = 2
	anchored = 1
	can_rotate = FALSE

/obj/structure/bed/chair/wood/pew/left
	icon_state = "bench_left"

/obj/structure/bed/chair/wood/pew/right/
	icon_state = "bench_right"

/obj/structure/bed/chair/wood/pew/mid/ // mid refers to a straight couch part
	icon_state = "bench_mid"

/obj/structure/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/wood/wings/cultify()
	return

/obj/structure/bed/chair/wood/throne
	icon = 'icons/obj/stationobjs_64x64.dmi'
	icon_state = "throne"
	name = "throne"
	desc = "A throne fitting for a royal behind."
	sheet_amt = 40
	anchored = 1
	pixel_x = -1*WORLD_ICON_SIZE/2
	pixel_y = -1*WORLD_ICON_SIZE/2

/obj/structure/bed/chair/wood/throne/cultify()
	icon_state = "skullthrone"
	name = "skull throne"
	desc = pick("Put Khorny pun here.","Well, now what?","Now all that is required is a goblet made from your 'other' enemies' skulls.")

/obj/structure/bed/chair/wood/throne/New()
	..()
	buckle_overlay = image("icons/obj/stools-chairs-beds.dmi", "[icon_state]_arm", CHAIR_ARMREST_LAYER)
	buckle_overlay.plane = relative_plane(ABOVE_HUMAN_PLANE)

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
	icon_state = "comfychair"
	var/image/legs
	color = null
	sheet_amt = 1

/obj/structure/bed/chair/comfy/New()
	..()
	buckle_overlay = image("icons/obj/objects.dmi", "[icon_state]_armrest", CHAIR_ARMREST_LAYER)
	buckle_overlay.plane = relative_plane(ABOVE_HUMAN_PLANE)
	legs = image("icons/obj/objects.dmi", "[icon_state]_legs", CHAIR_LEG_LAYER)
	legs.plane = FLOAT_PLANE
	legs.appearance_flags = RESET_COLOR
	overlays += legs
	..()
	overlays += buckle_overlay

/obj/structure/bed/chair/comfy/turn/handle_layer()
	layer = OBJ_LAYER
	plane = OBJ_PLANE

/obj/structure/bed/chair/comfy/attackby(var/obj/item/W, var/mob/user)
	if (W.is_wrench(user))
		for (var/atom/movable/AM in src)
			AM.forceMove(loc)

		return ..()

	if (W.w_class <= W_CLASS_SMALL)
		if (contents.len)
			to_chat(user, "There is already an item between \the [src]'s cushions.")
			return

		if (user.drop_item(W, src))
			to_chat(user, "You hide \the [W] between \the [src]'s cushions.")
			if(arcanetampered)
				var/area/thearea
				var/area/prospective = pick(areas)
				while(!thearea)
					if(prospective.type != /area)
						var/turf/T = pick(get_area_turfs(prospective.type))
						if(T.z == user.z)
							thearea = prospective
							break
					prospective = pick(areas)
				var/list/L = list()
				for(var/turf/T in get_area_turfs(thearea.type))
					if(!T.density)
						var/clear = 1
						for(var/obj/O in T)
							if(O.density)
								clear = 0
								break
						if(clear)
							L+=T
				if(!L.len)
					return

				var/list/backup_L = L
				var/attempt = null
				var/success = 0
				while(L.len)
					attempt = pick(L)
					success = W.Move(attempt)
					if(!success)
						L.Remove(attempt)
					else
						break
				if(!success)
					W.forceMove(pick(backup_L))

		return TRUE

	return ..()

/obj/structure/bed/chair/comfy/attack_hand(var/mob/user, params, proximity)
	if(is_locking(mob_lock_type))
		return ..()
	if(proximity)
		for (var/obj/item/I in src)
			user.put_in_hands(I)
			to_chat(user, "You pull out \the [I] between \the [src]'s cushions.")

/obj/structure/bed/chair/comfy/brown
	color = CHAIR_BROWN

/obj/structure/bed/chair/comfy/beige
	color = CHAIR_BEIGE

/obj/structure/bed/chair/comfy/teal
	color = CHAIR_TEAL

/obj/structure/bed/chair/comfy/black
	color = CHAIR_BLACK

/obj/structure/bed/chair/comfy/lime
	color = CHAIR_LIME

/obj/structure/bed/chair/comfy/red
	color = CHAIR_RED

//Office chairs
/obj/structure/bed/chair/office
	icon_state = "officechair_white"
	sheet_amt = 1

	anchored = 0

/obj/structure/bed/chair/office/New()
	..()
	buckle_overlay = image("icons/obj/objects.dmi", "[icon_state]-overlay", CHAIR_ARMREST_LAYER)
	buckle_overlay.plane = relative_plane(ABOVE_HUMAN_PLANE)

/obj/structure/bed/chair/office/handle_layer() // Fixes layer problem when and office chair is buckled and facing north
	if(dir == NORTH && !is_locking(mob_lock_type))
		layer = CHAIR_ARMREST_LAYER
		plane = ABOVE_HUMAN_PLANE
	else
		layer = OBJ_LAYER
		plane = OBJ_PLANE

/obj/structure/bed/chair/office/relaymove(var/mob/living/user, direction)
	if(user.incapacitated() || !user.has_limbs)
		return 0
	//If we're in space or our area has no gravity...
	var/turf/T = get_turf(loc)
	if(!T)
		return 0
	if(!T.has_gravity())
		// Block relaymove() if needed.
		if(!Process_Spacemove(0))
			return 0
	if(last_airflow + 5 SECONDS > world.time) //ugly hack: can't scoot during ZAS
		return 0

	if(istype(T, /turf/simulated))
		var/turf/simulated/TS = T
		var/obj/effect/overlay/puddle/P = TS.is_wet()
		if(P && P.wet == TURF_WET_LUBE)
			user.unlock_from(src)
			T.Entered(user) //bye bye
			return 0

	//forwards, scoot slow
	if(direction == dir)
		var/scootdelay = user.movement_delay()*6
		set_glide_size(DELAY2GLIDESIZE(scootdelay))
		step(src, direction)
		user.delayNextMove(scootdelay)
	//backwards, scoot fast
	else if(direction == turn(dir, 180))
		var/scootdelay = user.movement_delay()*3
		set_glide_size(DELAY2GLIDESIZE(scootdelay))
		step(src, direction)
		change_dir(turn(direction, 180)) //face away from where we're going
		user.delayNextMove(scootdelay)
	//sideways, swivel to face
	else
		change_dir(direction)
		user.delayNextMove(1)

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
	can_rotate = TRUE
	color = null

// layer stuff
/obj/structure/bed/chair/comfy/couch/New()
	legs = image("icons/obj/objects.dmi", "[icon_state]_legs", CHAIR_LEG_LAYER)		// since i dont want the legs colored they are a separate overlay
	legs.plane = FLOAT_PLANE														//
	legs.appearance_flags = RESET_COLOR												//
	overlays += legs
	secondary_buckle_overlay = image("icons/obj/objects.dmi", "[icon_state]_armrest_legs", CHAIR_ARMREST_LAYER)		// since i dont want the legs colored they are a separate overlay
	secondary_buckle_overlay.plane = relative_plane(ABOVE_HUMAN_PLANE)												//
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
	color = CHAIR_BEIGE
/obj/structure/bed/chair/comfy/couch/right/beige
	color = CHAIR_BEIGE
/obj/structure/bed/chair/comfy/couch/mid/beige
	color = CHAIR_BEIGE
/obj/structure/bed/chair/comfy/couch/turn/inward/beige
	color = CHAIR_BEIGE
/obj/structure/bed/chair/comfy/couch/turn/outward/beige
	color = CHAIR_BEIGE

// #bab866 lime
/obj/structure/bed/chair/comfy/couch/left/lime
	color = CHAIR_LIME
/obj/structure/bed/chair/comfy/couch/right/lime
	color = CHAIR_LIME
/obj/structure/bed/chair/comfy/couch/mid/lime
	color = CHAIR_LIME
/obj/structure/bed/chair/comfy/couch/turn/inward/lime
	color = CHAIR_LIME
/obj/structure/bed/chair/comfy/couch/turn/outward/lime
	color = CHAIR_LIME

// #ae774c brown
/obj/structure/bed/chair/comfy/couch/left/brown
	color = CHAIR_BROWN
/obj/structure/bed/chair/comfy/couch/right/brown
	color = CHAIR_BROWN
/obj/structure/bed/chair/comfy/couch/mid/brown
	color = CHAIR_BROWN
/obj/structure/bed/chair/comfy/couch/turn/inward/brown
	color = CHAIR_BROWN
/obj/structure/bed/chair/comfy/couch/turn/outward/brown
	color = CHAIR_BROWN

// #66baba teal
/obj/structure/bed/chair/comfy/couch/left/teal
	color = CHAIR_TEAL
/obj/structure/bed/chair/comfy/couch/right/teal
	color = CHAIR_TEAL
/obj/structure/bed/chair/comfy/couch/mid/teal
	color = CHAIR_TEAL
/obj/structure/bed/chair/comfy/couch/turn/inward/teal
	color = CHAIR_TEAL
/obj/structure/bed/chair/comfy/couch/turn/outward/teal
	color = CHAIR_TEAL

// #81807c black
/obj/structure/bed/chair/comfy/couch/left/black
	color = CHAIR_BLACK
/obj/structure/bed/chair/comfy/couch/right/black
	color = CHAIR_BLACK
/obj/structure/bed/chair/comfy/couch/mid/black
	color = CHAIR_BLACK
/obj/structure/bed/chair/comfy/couch/turn/inward/black
	color = CHAIR_BLACK
/obj/structure/bed/chair/comfy/couch/turn/outward/black
	color = CHAIR_BLACK

// #c94c4c red
/obj/structure/bed/chair/comfy/couch/left/red
	color = CHAIR_RED
/obj/structure/bed/chair/comfy/couch/right/red
	color = CHAIR_RED
/obj/structure/bed/chair/comfy/couch/mid/red
	color = CHAIR_RED
/obj/structure/bed/chair/comfy/couch/turn/inward/red
	color = CHAIR_RED
/obj/structure/bed/chair/comfy/couch/turn/outward/red
	color = CHAIR_RED

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
		QDEL_NULL(folded)
	..()

/obj/item/folding_chair
	name = "folding chair"
	desc = "A collapsed folding chair that can be carried around."
	icon = 'icons/obj/stools-chairs-beds.dmi'
	icon_state = "folded_chair"
	force = 13
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
		QDEL_NULL(unfolded)
	..()

/obj/item/folding_chair/attack(mob/living/M, mob/living/user, def_zone, originator)
	if(user.is_wearing_item(/obj/item/weapon/storage/belt/champion))
		force *= 2 //Shitcode! There's no proc where the amount of force can be modified at least temporarily.
		..()
		force /= 2
		return
	..()

/obj/item/folding_chair/on_attack(atom/attacked, mob/user)
	hitsound = "trayhit"
	..()

/obj/item/folding_chair/attack_self(mob/user)
	unfolded.forceMove(user.loc)
	unfolded.add_fingerprint(user)
	unfolded.dir = user.dir
	user.drop_item(src, force_drop = 1)
	forceMove(unfolded)

/obj/structure/bed/chair/folding/MouseDropFrom(over_object, src_location, over_location)
	..()
	if(over_object == usr && Adjacent(usr))
		if(!ishigherbeing(usr) || usr.incapacitated() || usr.lying)
			return

		if(is_locking(mob_lock_type))
			return 0

		visible_message("[usr] folds up \the [src].")

		folded.forceMove(get_turf(src))
		forceMove(folded)

//Shuttle seats
/obj/structure/bed/chair/shuttle
	name = "seat"
	desc = "A reinforced chair that's firmly secured to the ground."
	icon_state = "shuttleseat_neutral"
	anchored = 1
	can_rotate = TRUE
	ghost_can_rotate = TRUE

/obj/structure/bed/chair/shuttle/attackby(var/obj/item/W, var/mob/user)
	var/mob/M = locate() in loc//so attacking people isn't made harder by the seats' bulkiness
	if (M && M != user)
		return M.attackby(W,user)
	if(istype(W, /obj/item/assembly/shock_kit))
		to_chat(user,"<span class='warning'>\The [W] cannot be rigged onto \the [src].</span>")
		return
	if(W.is_wrench(user))
		to_chat(user,"<span class='warning'>You cannot find any bolts to unwrench on \the [src].</span>")
		return
	if (iswelder(W))
		if (locked_atoms && locked_atoms.len > 0)
			to_chat(user,"<span class='warning'>You cannot downgrade a seat with someone buckled on it.</span>")
			return
		var/obj/item/tool/weldingtool/WT = W
		to_chat(user, "You start welding the plasteel off \the [src]")
		if (WT.do_weld(user, src, 50, 3))
			if(gcDestroyed)
				return
			if (locked_atoms && locked_atoms.len > 0)
				to_chat(user,"<span class='warning'>You cannot downgrade a seat with someone buckled on it.</span>")
				return
			var/obj/structure/bed/chair/C = new (loc)
			C.dir = dir
			drop_stack(/obj/item/stack/sheet/plasteel, loc, 5, user)
			user.visible_message(\
				"<span class='warning'>\The [src] has been welded apart, leaving \a [C] behind.</span>",\
				"You finish removing the seat components from the chair frame.",\
				"<span class='warning'>You hear welding.</span>")
			qdel(src)
		return
	..()

/obj/structure/bed/chair/shuttle/New()
	..()
	buckle_overlay = image("icons/obj/stools-chairs-beds.dmi", "[icon_state]_buckle", CHAIR_ARMREST_LAYER)
	buckle_overlay.plane = relative_plane(ABOVE_HUMAN_PLANE)

/obj/structure/bed/chair/shuttle/red
	icon_state = "shuttleseat_red"

/obj/structure/bed/chair/shuttle/blue
	icon_state = "shuttleseat_blue"

/obj/structure/bed/chair/shuttle/yellow
	icon_state = "shuttleseat_yellow"

/obj/structure/bed/chair/shuttle/white
	icon_state = "shuttleseat_white"

/obj/structure/bed/chair/shuttle/white/custom

/obj/structure/bed/chair/shuttle/white/custom/New(var/turf/loc, var/seat_color = null)
	..()
	if (seat_color)
		var/image/I1 = image("icons/obj/stools-chairs-beds.dmi", "shuttleseat_color", layer)
		I1.plane = FLOAT_PLANE
		I1.color = seat_color
		overlays += I1

		var/image/I2 = image("icons/obj/stools-chairs-beds.dmi", "shuttleseat_color_buckle", CHAIR_ARMREST_LAYER)
		I2.color = seat_color
		secondary_buckle_overlay = I2
		secondary_buckle_overlay.plane = relative_plane(ABOVE_HUMAN_PLANE)

/obj/structure/bed/chair/shuttle/gamer
	desc = "Ain't got nothing to compensate."
	icon_state = "shuttleseat_GAMER"
	can_rotate = TRUE
	ghost_can_rotate = TRUE

/obj/structure/bed/chair/shuttle/gamer/spin(var/mob/M)
	change_dir(turn(dir, 90))

//Plastic chairs
/obj/structure/bed/chair/plastic
	sheet_type = /obj/item/stack/sheet/mineral/plastic
	sheet_amt = 3
	anchored = 0

/obj/structure/bed/chair/plastic/plastic_chair
	icon_state = "plastic_chair"
	name = "plastic chair"
	desc = "All ready for the barbecue."

/obj/structure/bed/chair/plastic/plastic_chair/New()
	..()
	buckle_overlay = image("icons/obj/stools-chairs-beds.dmi", "[icon_state]_armrest", CHAIR_ARMREST_LAYER)
	buckle_overlay.plane = relative_plane(ABOVE_HUMAN_PLANE)
