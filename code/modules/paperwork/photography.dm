/*	Photography!
 *	Contains:
 *		Camera
 *		Silicon Camera
 *		Camera Film
 *		Photos
 * 		ID Photos
 *		Photo Albums
 *		Photo Booth
 */

/*
 * Film
 */
/obj/item/device/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1;" + Tc_PROGRAMMING + "=1"


/*
 * Photo
 */
/obj/item/weapon/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = W_CLASS_TINY
	w_type = RECYK_PLASTIC
	flammable = TRUE
	var/icon/img		//Big photo image
	var/scribble		//Scribble on the back.
	var/blueprints = FALSE	//Does it include the blueprints?
	var/info 			//Info on the camera about mobs or some shit
	var/photo_size = 3 //Used to scale up bigger images, 3 is default

	var/list/double_agent_completion_ids = list()


/obj/item/weapon/photo/attack_self(mob/user)
	show(user)


/obj/item/weapon/photo/proc/photocreate(var/inicon, var/inimg, var/ininfo, var/inblueprints)
	icon = inicon
	img = inimg
	info = ininfo
	blueprints = inblueprints

/obj/item/weapon/photo/attackby(obj/item/weapon/P, mob/user)
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null)  as text)
		txt = copytext(txt, 1, 128)
		if(Adjacent(user) && !user.stat)
			scribble = txt
	..()


/obj/item/weapon/photo/examine(mob/user)
	if(Adjacent(user))
		show(user)
	else
		..()
		to_chat(user, "<span class='notice'>You can't make out the picture from here.</span>")


/obj/item/weapon/photo/proc/show(mob/user)
	user << browse_rsc(img, "tmp_photo.png")
	var/displaylength = 192
	switch(photo_size)
		if(5)
			displaylength = 320
		if(7)
			displaylength = 448

	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='[displaylength]' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=book;size=[displaylength]x[scribble ? displaylength+108 : displaylength]")
	if(info) //Would rather not display a blank line of text
		to_chat(user, info)
	onclose(user, "[name]")


/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text), 1, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if(!usr.isUnconscious() && Adjacent(usr))
		name = "photo[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)

/*
 * ID Photo
 */
/obj/item/weapon/photo/id
	name = "ID photo"
	desc = "An ID photo. It can be used to update the records database."
	icon_state = "photo_id"
	var/icon/four_sides	// a 4-direction icon of the mob
	var/background = "white"

/obj/item/weapon/photo/id/attackby(var/obj/item/weapon/W, var/mob/user)
	if(iswirecutter(W))
		var/turf/T = get_turf(src)
		for (var/direction in cardinal)
			var/obj/item/weapon/photo/P = new/obj/item/weapon/photo(T)
			var/icon/side = icon('icons/effects/32x32.dmi', background)
			if (four_sides)
				var/icon/side_mob = icon(four_sides, dir = direction)
				side.Blend(side_mob, ICON_OVERLAY)
			var/icon/small_img = icon(side)
			var/icon/ic = icon('icons/obj/items.dmi',"photo")
			small_img.Scale(8, 8)
			ic.Blend(small_img,ICON_OVERLAY, 13, 13)
			P.icon = ic
			P.img = side
			P.info = info
			P.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
			P.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER
			P.photo_size = 1
		playsound(T, 'sound/items/poster_ripped.ogg', 30, 1)
		qdel(src)
		return
	..()


/*
 * Photo album
 */
/obj/item/weapon/storage/photo_album
	name = "photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_only_hold = list("/obj/item/weapon/photo",)
	storage_slots = 50
	max_combined_w_class = 200


/*
 * Camera
 */
/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. This model uses space technology to expand polaroids to an appropriate size."
	icon_state = "polaroid"
	item_state = "polaroid"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=1;" + Tc_PROGRAMMING + "=1"
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_ELECTRONIC
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>", "<span class='warning'>A label covers the lens!</span>")
	slimeadd_message = "You add the slime extract to the camera lens"
	slimes_accepted = SLIME_SEPIA
	slimeadd_success_message = "It now has a sepia tinge"
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = TRUE
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/blueprints = FALSE	//are blueprints visible in the current photo being created?

	var/list/double_agent_completion_ids = list()

	var/list/aipictures = list() //Allows for storage of pictures taken by AI, in a similar manner the datacore stores info

	var/photo_size = 3 //Default is 3x3. 1x1, 5x5, 7x7 are also options

	var/panelopen = FALSE
	var/obj/item/weapon/light/bulb/flashbulb = null
	var/start_with_bulb = TRUE

	var/see_ghosts = FALSE

/obj/item/device/camera/New(var/empty = FALSE)
	..()
	if(empty == TRUE)
		start_with_bulb = FALSE
		pictures_left = 0
	if(start_with_bulb)
		flashbulb = new(src)

/obj/item/device/camera/Destroy()
	QDEL_NULL(flashbulb)
	..()

/obj/item/device/camera/slime_act(primarytype, mob/user)
	if(primarytype == SLIME_SEPIA && ..())
		var/obj/item/device/camera/sepia/S = new(user.loc)
		if(src in user.held_items)
			user.put_in_hands(S)
		qdel(src)

/obj/item/device/camera/sepia
	name = "camera"
	desc = "This polaroid camera takes pictures in sepia. It's for the aesthetic."
	icon_state = "sepia-polaroid"
	item_state = "sepia-polaroid"
	icon_on = "sepia-camera"
	icon_off = "sepia-camera_off"
	mech_flags = MECH_SCAN_FAIL
	see_ghosts = TRUE


/obj/item/device/camera/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [pictures_left] photos left.</span>")
	if(panelopen)
		to_chat(user, "<span class='notice'>There is an open panel on the side.</span>")

/obj/item/device/camera/proc/get_base_photo_icon(new_icon_state = "")
	var/icon/res
	switch(photo_size)
		if(1)
			res = icon('icons/effects/32x32.dmi', new_icon_state)
		if(3)
			res = icon('icons/effects/96x96.dmi', new_icon_state)
		if(5)
			res = icon('icons/effects/160x160.dmi', new_icon_state)
		if(7)
			res = icon('icons/effects/224x224.dmi', new_icon_state)
		else
			res = icon('icons/effects/32x32.dmi', new_icon_state)

	return res


/obj/item/device/camera/verb/set_zoom()
	set name = "Switch camera zoom"
	set category = "Object"

	if(usr.incapacitated())
		return

	switch(photo_size)
		if(1)
			photo_size = 3
		if(3)
			photo_size = 5
		if(5)
			photo_size = 7
		if(7)
			photo_size = 1

	usr.simple_message("<span class='info'>You switch the camera zoom to [photo_size]x[photo_size].</span>", "<span class='danger'>You press the... you wonder if you can photograph those rainbow guys dancing in the background.</span>")

	/*if(photo_size == 3)
		photo_size = 1
		usr.simple_message("<span class='info'>You zoom the camera in.</span>", "<span class='danger'>You drink from the mysterious bottle labeled \"DRINK ME\". Everything feels huge!</span>") //Second message is shown when hallucinating
	else
		photo_size = 3
		usr.simple_message("<span class='info'>You zoom the camera out.</span>", "<span class='danger'>You take a bite of the mysterious mushroom. Everything feels so tiny!</span>") //Second message is shown when hallucinating
	*/

/obj/item/device/camera/AltClick()
	if(is_holder_of(usr, src))
		set_zoom()
	else
		return ..()

/obj/item/device/camera/cartridge
	name = "PDA camera"
	desc = "You should not be seeing this outside of a cartridge"
	start_with_bulb = FALSE
	var/obj/item/weapon/cartridge/camera/host_cart = null

/obj/item/device/camera/cartridge/New()
	if(!loc || !istype(loc,/obj/item/weapon/cartridge/camera))
		qdel(src) // Do not exist outside of cartridges
	else
		host_cart = loc

/obj/item/device/camera/silicon
	name = "silicon photo camera"
	start_with_bulb = FALSE
	var/in_camera_mode = FALSE

/obj/item/device/camera/silicon/ai_camera //camera AI can take pictures with
	name = "\improper AI photo camera"

/obj/item/device/camera/silicon/robot_camera
	name = "cyborg photo camera"

/obj/item/device/camera/silicon/robot_camera/verb/borgprinting()
	set category ="Robot Commands"
	set name = "Print Image"
	set src in usr

	if(!isrobot(usr))
		return

	var/mob/living/silicon/robot/R = usr

	if(R.incapacitated())
		return

	borgprint()

/obj/item/device/camera/attackby(obj/item/I, mob/user)
	if(I.is_screwdriver(user))
		to_chat(user, "You [panelopen ? "close" : "open"] the panel on the side of \the [src].")
		panelopen = !panelopen
		I.playtoolsound(src, 50)

	if(istype(I, /obj/item/stack/cable_coil))
		if(!panelopen)
			return
		var/obj/item/device/blinder/Q = new(loc, empty = TRUE)
		handle_blinder(Q)
		var/obj/item/stack/cable_coil/C = I
		user.create_in_hands(src, Q, C, 5, "You attach [C.amount > 5 ? "some" : "the"] wires to \the [src]'s flash circuit.")

	if(istype(I, /obj/item/device/camera_film))
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return

		if(user.drop_item(I))
			to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")

			qdel(I)
			pictures_left = pictures_max
			icon_state = icon_on
			on = 1
			return
	..()

/obj/item/device/camera/proc/handle_blinder(obj/item/device/blinder/blinder)
	if(flashbulb)
		blinder.flashbulb = flashbulb
		flashbulb.forceMove(blinder)
		flashbulb = null

	blinder.name = name
	blinder.icon = icon
	blinder.base_desc = desc
	blinder.update_desc()
	blinder.icon_state = icon_state
	blinder.item_state = item_state
	blinder.mech_flags = mech_flags
	blinder.decon_path = type

/obj/item/device/camera/proc/camera_get_icon_deluxe(list/turfs, turf/center)
	var/list/datas = list()
	for(var/turf/T in turfs)
		datas += get_turf_image_datas(T,src)

	var/sorted_data = sort_image_datas(datas)

	var/icon/res = get_base_photo_icon()

	var/icon/img = getFlatIconDeluxe(sorted_data, center, (photo_size-1)/2, large_canvas = TRUE)
	res.Blend(img,ICON_OVERLAY)

	return res

/obj/item/device/camera/proc/camera_get_assassination_results(turf/the_turf)
	if (assassination_objectives.len > 0)
		for(var/mob/living/A in the_turf)
			if (A.mind && A.health < 0)//well they might be in crit but that's good enough I guess
				for(var/datum/objective/target/assassinate/ass in assassination_objectives)
					if (ass.target == A.mind)
						double_agent_completion_ids += makeweakref(ass)
		for(var/obj/item/organ/external/head/H in the_turf)
			var/mob/living/carbon/brain/brainmob = H.brainmob
			if (brainmob && brainmob.mind)
				for(var/datum/objective/target/assassinate/ass in assassination_objectives)
					if (ass.target == brainmob.mind)
						double_agent_completion_ids += makeweakref(ass)
		for(var/obj/item/organ/internal/brain/B in the_turf)
			var/mob/living/carbon/brain/brainmob = B.brainmob
			if (brainmob && brainmob.mind)
				for(var/datum/objective/target/assassinate/ass in assassination_objectives)
					if (ass.target == brainmob.mind)
						double_agent_completion_ids += makeweakref(ass)



/obj/item/device/camera/proc/camera_get_mobs(turf/the_turf)
	var/mob_detail
	for(var/mob/living/A in the_turf)
		if(A.invisibility)
			continue
		var/holding = null
		for(var/obj/item/I in A.held_items)
			var/item_count = 0

			switch(item_count)
				if(0)
					holding = "They are holding \a [I]"
				else
					holding += " and \a [I]"

			item_count++

		if(!mob_detail)
			mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."

	for(var/mob/living/simple_animal/S in the_turf)
		if(S.invisibility != 0)
			continue
		if(!mob_detail)
			mob_detail = "You can see [S] on the photo[S.health < (S.maxHealth/2) ? " - [S] looks hurt":""]."
		else
			mob_detail += "You can also see [S] on the photo[S.health < (S.maxHealth/2) ? " - [S] looks hurt":""]."
	for(var/mob/dead/observer/O in the_turf)//in case ghosts have been made visible
		if(O.invisibility != 0)
			continue
		if(!mob_detail)
			mob_detail = "Wait...is that [O] on the photo? "
		else
			mob_detail += "...wait a minute...isn't that [O] on the photo?"
	return mob_detail


/obj/item/device/camera/sepia/camera_get_mobs(turf/the_turf)
	var/mob_detail
	for(var/mob/living/carbon/A in the_turf)
		var/holding = null
		for(var/obj/item/I in A.held_items)
			var/item_count = 0

			switch(item_count)
				if(0)
					holding = "They are holding \a [I]"
				else
					holding += " and \a [I]"

			item_count++

		if(!mob_detail)
			mob_detail = "You can see [A] on the photo[A.health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] on the photo[A.health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	for(var/mob/living/simple_animal/S in the_turf)
		if(!mob_detail)
			mob_detail = "You can see [S] on the photo[S.health < (S.maxHealth/2) ? " - [S] looks hurt":""]."
		else
			mob_detail += "You can also see [S] on the photo[S.health < (S.maxHealth/2) ? " - [S] looks hurt":""]."
	for(var/mob/dead/observer/O in the_turf)
		if(!mob_detail)
			mob_detail = "Wait...is that [O] on the photo? "
		else
			mob_detail += "...wait a minute...isn't that [O] on the photo?"

	return mob_detail


/obj/item/device/camera/proc/captureimage(atom/target, mob/user, flag)  //Proc for both regular and AI-based camera to take the image
	if(min_harm_label && harm_labeled >= min_harm_label)
		var/icon/I = get_base_photo_icon("blocked")

		printpicture(user, I, "You can't see a thing.", flag)
		return
	var/mobs = ""
	var/list/seen
	if(!isAI(user) && !istype(user.client.eye, /obj/item/device/camera_bug)) //crappy check, but without it AI photos would be subject to line of sight from the AI Eye object. Made the best of it by moving the sec camera check inside
		if(user.client)		//To make shooting through security cameras possible
			seen = get_hear(world.view, user.client.eye) //To make shooting through security cameras possible
			// To make shooting through the tgui cameras possible
			for(var/datum/tgui/ui in user.tgui_open_uis)
				var/obj/machinery/computer/security/tv = ui.src_object.ui_host()
				if(istype(tv, /obj/machinery/computer/security))
					if(tv.active_camera)
						seen |= get_hear(world.view, tv.active_camera)
		else
			seen = get_hear(world.view, user)
	else
		if(istype(user.client.eye, /obj/item/device/camera_bug))
			seen = get_hear(world.view, get_turf(user.client.eye))
		else
			seen = get_hear(world.view, target)

	var/list/turfs = list()
	for(var/turf/T in range(round(photo_size * 0.5), target))
		if(T in seen)
			if(isAI(user) && !cameranet.checkTurfVis(T))
				continue
			else
				turfs += T
				mobs += camera_get_mobs(T)
				camera_get_assassination_results(T)

	var/icon/temp = get_base_photo_icon()

	temp.Blend("#000", ICON_OVERLAY)
	temp.Blend(camera_get_icon_deluxe(turfs, target), ICON_OVERLAY)

	if(!issilicon(user))
		printpicture(user, temp, mobs, flag)
	else
		aipicture(user, temp, mobs, user, blueprints)

/obj/item/device/camera/proc/printpicture(mob/user, icon/temp, mobs, flag) //Normal camera proc for creating photos
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo(loc)
	user.put_in_hands(P)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
	P.icon = ic
	P.img = temp
	P.info = mobs
	P.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	P.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER
	P.photo_size = photo_size

	if(blueprints)
		P.blueprints = TRUE
		blueprints = FALSE

	if (double_agent_completion_ids.len > 0)
		P.double_agent_completion_ids = double_agent_completion_ids.Copy()
		double_agent_completion_ids = list()

/obj/item/device/camera/cartridge/printpicture(mob/user, icon/temp, mobs, flag) //Add photos to cart
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
	host_cart.stored_photos += P
	host_cart.photo_number++
	temp = ImagePDA(temp)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
	P.name = "photo [host_cart.photo_number]"
	P.icon = ic
	P.img = temp
	P.info = mobs
	P.photo_size = photo_size

	if(blueprints)
		P.blueprints = TRUE
		blueprints = FALSE

	if (double_agent_completion_ids.len > 0)
		P.double_agent_completion_ids = double_agent_completion_ids.Copy()
		double_agent_completion_ids = list()

/obj/item/device/camera/sepia/printpicture(mob/user, icon/temp, mobs, flag) //Creates photos in sepia
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo(loc)
	user.put_in_hands(P)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
	P.icon = ic
	P.img = temp
	P.info = mobs
	P.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	P.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER
	P.photo_size = photo_size

	if(blueprints)
		P.blueprints = TRUE
		blueprints = FALSE

	var/icon/I1 = icon(P.icon, P.icon_state)
	var/icon/I2 = icon(P.img)

	I1.MapColors(rgb(100,89,69), rgb(196,175,136), rgb(48,43,33))//sepia magic formula
	I2.MapColors(rgb(100,89,69), rgb(196,175,136), rgb(48,43,33))

	P.icon = I1
	P.img = I2

/obj/item/device/camera/proc/aipicture(mob/user, icon/temp, mobs, isAI) //instead of printing a picture like a regular camera would, we do this instead for the AI
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
	var/icon = ic
	var/img = temp
	var/info = mobs
	var/pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	var/pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER

	var/injectblueprints = TRUE
	if(blueprints)
		injectblueprints = TRUE
		blueprints = FALSE

	if(isAI(user))
		injectaialbum(icon, img, info, pixel_x, pixel_y, injectblueprints)
	else
		injectmasteralbum(icon, img, info, pixel_x, pixel_y, injectblueprints)


/datum/picture
	var/name = "image"
	var/list/fields = list()


/obj/item/device/camera/proc/injectaialbum(var/icon, var/img, var/info, var/pixel_x, var/pixel_y, var/blueprintsinject) //stores image information to a list similar to that of the datacore
	var/numberer = 1
	for(var/datum/picture in aipictures)
		numberer++

	var/datum/picture/P = new()

	P.fields["name"] = "Image [numberer] (taken by [loc.name])"
	P.fields["icon"] = icon
	P.fields["img"] = img
	P.fields["info"] = info
	P.fields["pixel_x"] = pixel_x
	P.fields["pixel_y"] = pixel_y
	P.fields["blueprints"] = blueprintsinject

	aipictures += P
	to_chat(loc, "<span class='info'>Image recorded and saved to local database.</span>")//feedback to the AI player that the picture was taken

/obj/item/device/camera/proc/injectmasteralbum(var/icon, var/img, var/info, var/pixel_x, var/pixel_y, var/blueprintsinject)
	var/numberer = 1
	var/mob/living/silicon/robot/C = loc //Hackyman

	if(C.connected_ai)
		for(var/datum/picture in C.connected_ai.aicamera.aipictures)
			numberer++
		var/datum/picture/P = new()
		P.fields["name"] = "Image [numberer] (taken by [C.name])"
		P.fields["icon"] = icon
		P.fields["img"] = img
		P.fields["info"] = info
		P.fields["pixel_x"] = pixel_x
		P.fields["pixel_y"] = pixel_y
		P.fields["blueprints"] = blueprintsinject

		C.connected_ai.aicamera.aipictures += P
		to_chat(C.connected_ai, "<span class='info'>New image uploaded by [C.name].</span>")
		to_chat(C, "<span class='info'>Image recorded and uploaded to [C.connected_ai.name]'s database.</span>")	//feedback to the Cyborg player that the picture was taken
	else
		injectaialbum(icon, img, info, pixel_x, pixel_y, blueprintsinject)

/obj/item/device/camera/silicon/proc/viewpichelper(var/obj/item/device/camera/silicon/targetloc)
	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	if(!targetloc.aipictures.len)
		to_chat(usr, "<span class='danger'>No images saved</span>")
		return
	for(var/datum/picture/i in targetloc.aipictures)
		nametemp += i.fields["name"]
	find = input("Select image (numbered in order taken)") in nametemp
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()

	for(var/datum/picture/q in targetloc.aipictures)
		if(q.fields["name"] == find)
			selection = q
			break  	// just in case some AI decides to take 10 thousand pictures in a round

	P.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["info"])
	P.pixel_x = selection.fields["pixel_x"]
	P.pixel_y = selection.fields["pixel_y"]

	P.show(usr)
	qdel(P)    //so 10 thousdand pictures items are not left in memory should an AI take them and then view them all.

/obj/item/device/camera/silicon/proc/viewpictures(var/mob/user)
	if(isrobot(user)) // Cyborg/MoMMI
		var/mob/living/silicon/robot/C = user
		if(C.connected_ai)
			viewpichelper(C.connected_ai.aicamera)
		else
			viewpichelper(src)
	else // AI
		viewpichelper(src)

/obj/item/device/camera/afterattack(atom/target, mob/user, flag)
	if(!on || pictures_left<=0 || (!isturf(target) && !isturf(target.loc)))
		return
	pictures_left--
	captureimage(target, user, flag)

	playsound(loc, "polaroid", 75, 1, -3)

	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
	icon_state = icon_off
	on = FALSE
	if(pictures_left > 0)
		spawn(64)
			icon_state = icon_on
			on = TRUE

/obj/item/device/camera/remote_attack(atom/target, mob/user, atom/movable/eye)
	if(istype(eye, /obj/machinery/camera) || istype(user.client.eye, /obj/item/device/camera_bug))
		return afterattack(target, user) //Allow taking photos when looking through cameras

/obj/item/device/camera/silicon/proc/toggle_camera_mode(var/mob/living/silicon/S = null)
	if(!S)
		return
	in_camera_mode = !in_camera_mode
	to_chat(S, "<B>Camera Mode [in_camera_mode ? "activated":"deactivated"]</B>")
	if(S.camera_icon)
		S.camera_icon.icon_state = "camera[in_camera_mode ? "1":""]"

/obj/item/device/camera/silicon/robot_camera/proc/borgprint()
	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	var/mob/living/silicon/robot/C = loc
	var/obj/item/device/camera/silicon/targetcam = null

	if(C.stat)
		return
	if(C.toner < CYBORG_PHOTO_COST)
		to_chat(C, "Insufficent toner to print image.")
		return
	if(C.connected_ai)
		targetcam = C.connected_ai.aicamera
	else
		targetcam = C.aicamera
	if(!targetcam.aipictures.len)
		to_chat(C, "<span class='danger'>No images saved</span>")
		return
	for(var/datum/picture/t in targetcam.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image (numbered in order taken)") in nametemp
	for(var/datum/picture/q in targetcam.aipictures)
		if(q.fields["name"] == find)
			selection = q
			break
	var/obj/item/weapon/photo/p = new /obj/item/weapon/photo(C.loc)
	p.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["info"], selection.fields["blueprints"])
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	C.toner -= CYBORG_PHOTO_COST
	visible_message("[C.name] spits out a photograph from a narrow slot on it's chassis.")
	playsound(loc, "polaroid", 75, 1, -3)
	to_chat(C, "You print a photograph.")

/obj/item/device/camera/silicon/proc/sync(var/mob/living/silicon/robot/R)
	if(R.connected_ai && R.connected_ai.aicamera && R.aicamera) // Send images the Cyborg has taken to the AI's album upon sync.
		R.connected_ai.aicamera.aipictures |= R.aicamera.aipictures
		R.aicamera.aipictures = R.connected_ai.aicamera.aipictures
		to_chat(R, "<span class='notice'>Photo database synced with [R.connected_ai.name].</span>")


/*
 * Photo Booth
 */
/obj/machinery/photobooth
	name = "photo booth"
	desc = "Come get your picture!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "photobooth"
	density = TRUE
	anchored = TRUE
	ghost_read=0
	ghost_write=0
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 10
	active_power_usage = 10
	var/background = "white"
	var/photo_power_usage = 1000
	var/icon/photo
	var/mob/living/current_mob
	component_parts = newlist(
		/obj/item/weapon/circuitboard/photobooth,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor
	) // capacitors for the flash, scanning_modules for the processing of the image, matter bin for the ink

/obj/machinery/photobooth/security
	background = "mugshot"
	icon_state = "secbooth"

/obj/machinery/photobooth/New()
	..()
	var/image/I = image(icon, src, "[icon_state]_overlay")
	I.plane = relative_plane(ABOVE_HUMAN_PLANE)
	I.layer = 0
	overlays += I

/obj/machinery/photobooth/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>You can perform an Alt-Click to change the background on the ID photos.</span>")

/obj/machinery/photobooth/Uncross(var/atom/movable/mover, var/turf/target)
	if(target) //Are we doing a manual check to see
		if(get_dir(loc, target) == SOUTH)
			return 1
	else if(mover.dir == SOUTH) //Or are we using move code
		return 1
	return 0

/obj/machinery/photobooth/Cross(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(air_group)
		return 0
	if(get_dir(loc, target) == SOUTH || get_dir(loc, mover) == SOUTH)
		return 1
	return 0

/obj/machinery/photobooth/AltClick()
	if (!isliving(usr) || !Adjacent(usr))
		return
	var/mob/living/user = usr
	var/new_background = input(user, "Choose a photo background", "Photo Booth") as null|anything in list(
		"white",
		"black",
		"flowers",
		"fire",
		"space",
		"balloons",
		"nanotrasen_dark",
		"nanotrasen_light",
		"mugshot",
		)
	if (new_background)
		background = new_background
		to_chat(user, "<span class='notice'>You set the photo background to \"[background]\"</span>")

/obj/machinery/photobooth/attack_hand(var/mob/living/user)
	if (!isliving(user))
		return
	if (current_mob)
		if (current_mob != user)
			to_chat(user, "<span class='warning'>\The [current_mob] is already using the booth currently.</span>")
		return
	var/turf/T = get_turf(src)
	current_mob = locate() in T
	if (!current_mob)
		to_chat(user, "<span class='notice'>You must enter the booth from the front before you can take a picture of yourself.</span>")
		return
	lock_atom(current_mob, /datum/locking_category/photobooth)
	anim(target = src, a_icon = icon, flick_anim = "photobooth-flash", sleeptime = 40, plane = ABOVE_HUMAN_PLANE, lay = OPEN_CURTAIN_LAYER)
	playsound(T, "rustle", 50, 1, -2)
	spawn(17)
		playsound(T, "polaroid", 75, 1, -3)
		photo = capture_mob(current_mob)
		sleep(16)
		if (!current_mob.gcDestroyed)
			unlock_atom(current_mob)
		sleep(16)
		anim(target = src, a_icon = icon, flick_anim = "photobooth-print", sleeptime = 30, plane = ABOVE_HUMAN_PLANE, lay = WINDOOR_LAYER)
		playsound(T, "sound/effects/fax.ogg", 50, 1)
		sleep(10)
		if (!current_mob.gcDestroyed)
			print_photo(current_mob)
		current_mob = null

/obj/machinery/photobooth/proc/capture_mob(var/mob/living/L)
	if (!L || L.gcDestroyed)
		return
	var/icon/I = icon('icons/effects/32x32.dmi', "blank")
	var/icon/result = icon(I, "")
	result.Insert(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(L)), override_dir = SOUTH),  "", dir = SOUTH)
	result.Insert(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(L)), override_dir = NORTH),  "", dir = NORTH)
	result.Insert(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(L)), override_dir = EAST),  "", dir = EAST)
	result.Insert(getFlatIconDeluxe(sort_image_datas(get_content_image_datas(L)), override_dir = WEST),  "", dir = WEST)
	return result

/obj/machinery/photobooth/proc/print_photo(var/mob/living/L)
	var/turf/T = get_turf(src)
	var/obj/item/weapon/photo/id/P = new/obj/item/weapon/photo/id(T)
	P.pixel_x = 8 * PIXEL_MULTIPLIER
	P.pixel_y = 0
	P.background = background
	P.plane = ABOVE_HUMAN_PLANE
	P.layer = CLOSED_CURTAIN_LAYER
	var/icon/result =  icon('icons/effects/70x70.dmi', "photo_id")
	var/icon/bground = icon('icons/effects/32x32.dmi', background)
	result.Blend(bground,ICON_OVERLAY,3,37)
	result.Blend(bground,ICON_OVERLAY,37,37)
	result.Blend(bground,ICON_OVERLAY,37,3)
	result.Blend(bground,ICON_OVERLAY,3,3)
	if (photo)
		var/icon/side_south = icon(photo, dir = SOUTH)
		result.Blend(side_south,ICON_OVERLAY,3,37)
		var/icon/side_north = icon(photo, dir = NORTH)
		result.Blend(side_north,ICON_OVERLAY,37,37)
		var/icon/side_east = icon(photo, dir = EAST)
		result.Blend(side_east,ICON_OVERLAY,3,3)
		var/icon/side_west = icon(photo, dir = WEST)
		result.Blend(side_west,ICON_OVERLAY,37,3)

		bground.Blend(photo, ICON_OVERLAY)
		P.four_sides = bground

	var/icon/small_img = icon(result)
	var/icon/ic = icon('icons/obj/items.dmi',"photo_id")
	small_img.Scale(15, 15)
	ic.Blend(small_img,ICON_OVERLAY, 10, 10)
	P.icon = ic
	P.img = result
	if (photo && L)
		var/mob_detail = "You can see \a [L] on the photo.[(3*L.health) < (L.maxHealth/4) ? " They look hurt.":""]"
		for(var/obj/item/I in L.held_items)
			var/item_count = 0

			switch(item_count)
				if(0)
					mob_detail += " They are holding \a [I]"
				else
					mob_detail += " and \a [I]."

			item_count++
		P.info = mob_detail

/datum/locking_category/photobooth
