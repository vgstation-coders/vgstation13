/obj/item/key/tractor
	name = "tractor key"
	desc = "Shiny keys."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/tractor
	name = "tractor"
	icon = 'goon/icons/vehicles.dmi'
	icon_state = "tractor"
	keytype = /obj/item/key/tractor
	headlights = TRUE
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/tractor
	var/image/steering_overlay

/obj/structure/bed/chair/vehicle/tractor/New()
	..()
	steering_overlay = image('goon/icons/vehicles.dmi',src,"north_steering")
	overlays += steering_overlay

/obj/structure/bed/chair/vehicle/tractor/update_icon()
	for(var/datum/action/vehicle/toggle_headlights/TH in vehicle_actions)
		if(TH.on)
			icon_state = "[initial(icon_state)]-on"
			return
	icon_state = "[initial(icon_state)]"

/obj/structure/bed/chair/vehicle/tractor/buckle_mob(mob/M, mob/user)
	..()
	overlays -= steering_overlay

/obj/structure/bed/chair/vehicle/tractor/manual_unbuckle(mob/user, var/resisting = FALSE)
	..()
	overlays += steering_overlay

/obj/structure/bed/chair/vehicle/tractor/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 7 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 5 * PIXEL_MULTIPLIER, "y" = 4 * PIXEL_MULTIPLIER),
		"[NORTH]" = list("x" = 0, "y" = 4 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = -5 * PIXEL_MULTIPLIER, "y" = 4 * PIXEL_MULTIPLIER)
		)

/obj/structure/bed/chair/vehicle/tractor/handle_layer()
		plane = ABOVE_HUMAN_PLANE
		layer = VEHICLE_LAYER

/obj/effect/decal/mecha_wreckage/vehicle/tractor
	// TODO: SPRITE PLS
	//icon = 'goon/icons/vehicles.dmi'
	//icon_state="tractor_destroyed"
	name = "tractor wreckage"
	desc = "The quartermaster sobs quietly on a pile of guns."

//and they say that a hero can save us
//Fire Tractors

/obj/item/key/tractor/fire
	name = "fire tractor key"
	desc = "Blazing keys."
	icon_state = "fire_keys"

/obj/structure/bed/chair/vehicle/tractor/fire
	name = "fire tractor"
	icon_state = "firetractor"
	desc = "The chariot of true heroes. Features a water synthesizer that can connect with any OSHA-compliant fire extinguisher."
	keytype = /obj/item/key/tractor/fire
	headlights = FALSE //Has the siren headlights instead, over in New()

	var/obj/item/weapon/extinguisher/attached_extinguisher
	//can the extinguisher be easily removed and does it have effectively infinite ammo
	var/extinguisher_linked = FALSE
	//locking variable for tampering with the fire extinguisher hoses
	var/hose_tweaking = FALSE

/obj/structure/bed/chair/vehicle/tractor/fire/New()
	..()
	new /datum/action/vehicle/toggle_headlights/siren(src) //Sierns are special headlights
	new /datum/action/vehicle/spray_extinguisher(src)

	//Comes with a free extinguisher, pre-attached!
	attached_extinguisher = new(src)
	attached_extinguisher.safety = FALSE
	extinguisher_linked = TRUE
	var/image/sprayer_image = image('goon/icons/vehicles.dmi',src,"extinguisher")
	sprayer_image.color = COLOR_RED
	overlays += sprayer_image

/obj/structure/bed/chair/vehicle/tractor/fire/examine(mob/user)
	..()
	var/obj/item/weapon/extinguisher/sprayer = locate(/obj/item/weapon/extinguisher) in src
	if(sprayer)
		to_chat(user, "<span class='info'>It has \a [sprayer] attached. The supply hoses are [extinguisher_linked ? "connected" : "not connected"].</span>")
	else
		to_chat(user, "<span class='info'>The fire extinguisher attachment slot is empty.</span>")

/obj/structure/bed/chair/vehicle/tractor/fire/attackby(obj/item/W, mob/living/user)
	//Extinguisher attaching
	if(istype(W,/obj/item/weapon/extinguisher))
		if(attached_extinguisher)
			to_chat(user,"<span class='notice'>There's already an attached extinguisher!</span>")
			return
		var/obj/item/weapon/extinguisher/sprayer = W
		if(!user.drop_item(sprayer, src))
			//Couldn't drop it for some reason, such as superglue
			return
		user.visible_message("[user] attaches \the [sprayer] to \the [src].","<span class='notice'>You attach \the [sprayer] to \the [src].</span>")
		attached_extinguisher = sprayer
		//Draw the tiny extinguisher overlay and color it
		var/image/sprayer_image = image('goon/icons/vehicles.dmi',src,"extinguisher")
		var/newcolor = COLOR_RED
		if(istype(sprayer,/obj/item/weapon/extinguisher/mini))
			newcolor = COLOR_WHITE
		else if(istype(sprayer,/obj/item/weapon/extinguisher/foam))
			newcolor = LIGHT_COLOR_ORANGE
		sprayer_image.color = newcolor
		overlays += sprayer_image
		//Update the ACTION BUTTON with the correct type of extinguisher
		var/datum/action/vehicle/spray_extinguisher/spray_action = locate(/datum/action/vehicle/spray_extinguisher) in vehicle_actions
		if(!spray_action)
			return
		spray_action.icon_icon = sprayer.icon
		spray_action.button_icon_state = sprayer.icon_state
		spray_action.UpdateButtonIcon()
		return
	//Connecting to the internal water synth
	if(iswrench(W) && attached_extinguisher)
		if(hose_tweaking)
			to_chat(user,"<span class='notice'>The extinguisher hoses are already being tampered with!</span>")
			return
		user.visible_message("[user] begins to [extinguisher_linked ? "detatch" : "attach"] the internal hoses [extinguisher_linked ? "from" : "to"] \the [attached_extinguisher].", \
			"<span class='notice'>You begin to [extinguisher_linked ? "detatch" : "attach"] the internal hoses [extinguisher_linked ? "from" : "to"] \the [attached_extinguisher].</span>")
		hose_tweaking = TRUE
		W.playtoolsound(src, 100)
		if(!do_after(user, src, 40))
			hose_tweaking = FALSE
			return
		if(!attached_extinguisher)
			//Somehow, someone has taken your extinguisher! Either way, ain't there no more so ain't linked no more.
			extinguisher_linked = FALSE
			hose_tweaking = FALSE
			return
		user.visible_message("[user] [extinguisher_linked ? "detatches" : "attaches"] the internal hoses [extinguisher_linked ? "from" : "to"] \the [attached_extinguisher].", \
			"<span class='notice'>You [extinguisher_linked ? "detatch" : "attach"] the internal hoses [extinguisher_linked ? "from" : "to"] \the [attached_extinguisher].</span>")
		extinguisher_linked = !extinguisher_linked
		if(extinguisher_linked)
			//Special things happen when you freshly connect an extinguisher
			if(attached_extinguisher.safety)
				to_chat(user,"<span class='notice'>The safety on \the [attached_extinguisher] automatically clicks off.</span>")
				attached_extinguisher.safety = FALSE
			//Refills the extinguisher immediately
			var/avail_vol = attached_extinguisher.reagents.maximum_volume - attached_extinguisher.reagents.total_volume
			attached_extinguisher.reagents.add_reagent(WATER, avail_vol)
			playsound(src, 'sound/effects/refill.ogg', 50, 1)
		hose_tweaking = FALSE
		return
	..()

//For the macro lovers
/obj/structure/bed/chair/vehicle/tractor/fire/verb/verb_spray_extinguisher()
	set name = "Spray Extinguisher"
	set category = "Object"
	set src in oview(0)

	var/datum/action/vehicle/spray_extinguisher/spray_action = locate(/datum/action/vehicle/spray_extinguisher) in vehicle_actions
	if(!spray_action)
		return
	spray_action.Trigger()

//Janicart has this so we'll have it here as well
/obj/structure/bed/chair/vehicle/tractor/fire/verb/verb_remove_extinguisher()
	set name = "Remove Extinguisher"
	set category = "Object"
	set src in oview(1)

	if(attached_extinguisher && !usr.incapacitated() && Adjacent(usr) && usr.dexterity_check())
		remove_extinguisher(usr)

//Removes an attached extinguisher from a fire tractor.
/obj/structure/bed/chair/vehicle/tractor/fire/proc/remove_extinguisher(var/mob/user)
	if(extinguisher_linked)
		to_chat(user,"<span class='notice'>\The [attached_extinguisher] is securely fastened to \the [src]!</span>")
		return
	user.visible_message("[user] removes \the [attached_extinguisher] from \the [src].","<span class='notice'>You remove \the [attached_extinguisher] from \the [src].</span>")
	user.put_in_hands(attached_extinguisher)
	attached_extinguisher = null
	overlays = null
	//Special handling for the steering wheel that can be seen through people!
	if(!occupant)
		overlays += steering_overlay
	//Disable the action button so it's clear there's no extinguisher!
	var/datum/action/vehicle/spray_extinguisher/spray_action = locate(/datum/action/vehicle/spray_extinguisher) in vehicle_actions
	if(!spray_action)
		return
	spray_action.UpdateButtonIcon()

/obj/structure/bed/chair/vehicle/tractor/fire/setup_wreckage(var/obj/effect/decal/mecha_wreckage/wreck)
	if(attached_extinguisher)
		wreck.add_salvagable(attached_extinguisher, 75)
		attached_extinguisher = null

/obj/structure/bed/chair/vehicle/tractor/fire/attack_hand(mob/user)
	if(occupant && occupant == user)
		return ..()
	if(attached_extinguisher && !extinguisher_linked)
		remove_extinguisher(user)
	else
		..()

/obj/structure/bed/chair/vehicle/tractor/fire/AltClick(mob/user)
	if(attached_extinguisher)
		remove_extinguisher(user)
		return
	..()
