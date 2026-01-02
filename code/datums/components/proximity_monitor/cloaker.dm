/obj/effect/cloakfield
	name = "cloaking field"
	icon = 'icons/effects/fields.dmi'
	var/image/fieldimage
	plane = ABOVE_TURF_PLANE


/obj/effect/cloakfield/New(loc)
	..()
	fieldimage = image('icons/effects/fields.dmi', src , "center")
	var/matrix/IM = matrix()
	IM.Scale(3,3)
	fieldimage.alpha = 185
	fieldimage.appearance_flags = PIXEL_SCALE
	fieldimage.transform = IM
	fieldimage.override = TRUE


/datum/component/proximity_monitor/advanced/cloaker
	var/list/image/field_images = list()

	var/obj/effect/cloakfield/fieldeffect

//	trigger_once = TRUE
	edge_is_a_field = TRUE

	// This is the image attached to the carrier (topmost holder of the parent) as an overlay.
	// This image is passed onto /obj/effect/cloaked/proc/set_image(), which is what living mobs will see when they get close.
	var/image/cloakimage

	var/list/seeing_clients = list()
	var/client/current_client
	var/atom/movable/carrier

/datum/component/proximity_monitor/advanced/cloaker/initialize(...)
	..()
	fieldeffect = new(parent)
	assign_carrier(get_holder_at_turf_level(parent))
	on_moved()
	return TRUE

/datum/component/proximity_monitor/advanced/cloaker/Destroy()
	var/client/C = get_client()
	if(C)
		remove_all_images_from_client(C)

	assign_carrier(null)

	for(var/image/I in field_images)
		field_images -= I
		QDEL_NULL(I)
	qdel(fieldeffect)

	for(var/client/seeing in seeing_clients)
		seeing.images -= cloakimage

	..()

/datum/component/proximity_monitor/advanced/cloaker/proc/get_client()
	var/mob/living/holder = get_holder_of_type(parent, /mob/living)
	if(ismob(holder))
		return holder.client

/datum/component/proximity_monitor/advanced/cloaker/on_moved(atom/movable/mover)
	..()

	// First we get the highest-level holder of the cloaking device.
	var/atom/movable/AM = get_holder_at_turf_level(parent)

	// The holder of this component (aka, the cloaking device itself) is never cloaked.
	//  We can skip these if nothing is carrying the device, or if the carrier hasn't changed.
	if(carrier != AM && AM != parent)
		assign_carrier(AM)

	if(carrier)
		cloakimage.dir = carrier.dir
		fieldeffect.set_glide_size(carrier.glide_size)
	fieldeffect.forceMove(get_turf(parent))

	var/client/C = get_client()
	if(C && C != current_client)
		if(current_client)
			remove_all_images_from_client(current_client)
		send_all_images(C)
	current_client = C

/datum/component/proximity_monitor/advanced/cloaker/on_entered(atom/movable/mover, turf/location, atom/oldloc)
	. = ..()
	if(!ismob(mover) || !cloakimage)
		return
	var/mob/M = mover
	if(!M.client)
		return
	M.client.images += cloakimage
	seeing_clients += M.client

/datum/component/proximity_monitor/advanced/cloaker/on_uncrossed(atom/movable/mover, turf/location, atom/newloc)
	. = ..()
	if(!ismob(mover) || !cloakimage)
		return
	var/mob/M = mover
	if(!M.client)
		return
	M.client.images -= cloakimage
	seeing_clients -= M.client

/datum/component/proximity_monitor/advanced/cloaker/proc/assign_carrier(var/atom/movable/AM)
	if(carrier == AM)
		return 				// Nothing to change.

	if(carrier)
		make_visible(carrier)				// Make the old carrier visible
		carrier.unregister_event(/event/face, src, nameof(src::on_moved()))

	carrier = AM

	if(carrier)																// AM can be null if we're getting qdel'd, for instance.													// Tell the cloak effect to relay clicks to the new carrier.
		create_cloak_image(carrier)											// Create the camo overlays.
		make_invisible(carrier)												// Make the new carrier invisible.
		carrier.register_event(/event/face, src, nameof(src::on_moved()))


/datum/component/proximity_monitor/advanced/cloaker/proc/create_cloak_image(var/atom/movable/AM)
	if(!AM)		// Fuck.
		return
	QDEL_NULL(cloakimage)				// Clear the old image.

	// A serious limitation of this is that their appearance will not update.
	// A new image will need to be created every time their appearance changes.
	// But there's no way to know exactly when an appearance will change, because icon_state and overlays are just edited arbitrarily...
//	var/image/I = image(AM.appearance, AM)
//	cloakimage = image('icons/effects/effects.dmi', AM, "cloaked_base")
/*
	cloakimage = image(AM.appearance, AM)
	cloakimage.override = TRUE
	cloakimage.plane = relative_plane_to_plane(AM.plane, AM.plane)				// Set the plane.
	cloakimage.color = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0.5,0.8,0.9,0.15)		// Make it a solid color
*/
	//I.color = list(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0) 						// Turn it into an alpha mask.

	// This is so, so stupid.
	var/icon/flat_icon = icon(AM.icon, AM.icon_state)
	for(var/I in AM.overlays)
		flat_icon.Blend(icon(I:icon, I:icon_state), ICON_OVERLAY)
	flat_icon.Blend(rgb(255, 255, 255))
	flat_icon.BecomeAlphaMask()
	var/icon/cloak_icon = new/icon('icons/effects/effects.dmi', "cloaked_base")
	cloak_icon.AddAlphaMask(flat_icon)

	cloakimage = image(cloak_icon, AM)

	cloakimage.color = "#a7daddff"
	cloakimage.override = TRUE
	cloakimage.plane = relative_plane_to_plane(AM.plane, AM.plane)


//	cloakimage.filters += filter(type="layer", icon=icon('icons/effects/effects.dmi',"cloaked_base"), blend_mode=BLEND_INSET_OVERLAY)
	cloakimage.filters += filter(type="outline", name="cloakoutline", size=1, color="#36dee798")

	// Taken straight from the byond ref :)
	// TODO something better
	var/start = cloakimage.filters.len
	var/X
	var/Y
	var/rsq
	var/i
	var/waves
	for(i=1, i<=7, ++i)
		// choose a wave with a random direction and a period between 10 and 30 pixels
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<500 || rsq>700)   // keep trying if we don't like the numbers
		// keep distortion (size) small, from 0.5 to 3 pixels
		// choose a random phase (offset)
		cloakimage.filters += filter(type="wave", name="example_wave" , x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	for(i=1, i<=7, ++i)
		// animate phase of each wave from its original phase to phase-1 and then reset;
		// this moves the wave forward in the X,Y direction
		if(start+i<=cloakimage.filters.len)
			waves = cloakimage.filters[start+i]
			animate(waves, offset=waves:offset, time=0, loop=-1, flags=ANIMATION_PARALLEL)
			animate(offset=waves:offset-1, time=rand()*20+10)


/datum/component/proximity_monitor/advanced/cloaker/proc/make_invisible(var/atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		M.make_invisible(CLOAKDEVICE, 0, TRUE, 100, INVISIBILITY_LEVEL_TWO)		// Why is this not an atom/movable level proc!
	else if(isobj(AM))
		var/obj/O = AM
		O.make_invisible(CLOAKDEVICE, 0, 100, INVISIBILITY_LEVEL_TWO)			// Why is this not an atom/movable level proc!

/datum/component/proximity_monitor/advanced/cloaker/proc/make_visible(var/atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		M.make_visible(CLOAKDEVICE)
	else if(isobj(AM))
		var/obj/O = carrier
		O.make_visible(CLOAKDEVICE)


/datum/component/proximity_monitor/advanced/cloaker/proc/place_field_image(turf/target, var/image_state)
	var/image/I = image('icons/effects/fields.dmi', target, image_state)
	I.plane = ABOVE_TURF_PLANE
	field_images[target] = I
	var/client/C = get_client()
	if(C)
		send_image_to_client(C, I)

/datum/component/proximity_monitor/advanced/cloaker/proc/remove_field_image(turf/target)
	var/client/C = get_client()
	var/image/I = field_images[target]
	if(C && I)
		remove_image_from_client(C, I)
	QDEL_NULL(field_images[target])
	field_images[target] = null


/datum/component/proximity_monitor/advanced/cloaker/proc/send_image_to_client(var/client/C, var/image/I)
	if(I)
		C.images += I

/datum/component/proximity_monitor/advanced/cloaker/proc/remove_image_from_client(var/client/C, var/image/I)
	if(I)
		C.images -= I

// Sends all field_images to the passed client.
/datum/component/proximity_monitor/advanced/cloaker/proc/send_all_images(var/client/C)
	send_image_to_client(C, fieldeffect.fieldimage)
	for(var/image/I in field_images)
		send_image_to_client(C, I)

// Removes all field_images from the passed client.
/datum/component/proximity_monitor/advanced/cloaker/proc/remove_all_images_from_client(var/client/C)
	remove_image_from_client(C, fieldeffect.fieldimage)
	for(var/image/I in field_images)
		remove_image_from_client(C, I)


/datum/component/proximity_monitor/advanced/cloaker/setup_edge_turf(turf/target)
	. = ..()
//	place_field_image(target, "red")

/datum/component/proximity_monitor/advanced/cloaker/cleanup_edge_turf(turf/target)
	. = ..()
//	remove_field_image(target)

/datum/component/proximity_monitor/advanced/cloaker/setup_field_turf(turf/target)
	. = ..()
//	place_field_image(target, "blue")

/datum/component/proximity_monitor/advanced/cloaker/cleanup_field_turf(turf/target)
	. = ..()
//	remove_field_image(target)
