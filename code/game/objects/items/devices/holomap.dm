// The station holomap, use it and you get a map of how the pipes should be.

/obj/item/device/holomap
	name = "holomap"
	desc = "Displays the layout of the station's pipe and cable networks."

	icon = 'icons/obj/device.dmi'
	icon_state = "holomap"

	var/list/image/showing = list()
	var/client/viewing // Client that is using the device right now, also determines whether it's on or off.
	//var/datum/delay_controller/delayer
	var/hacked = FALSE
	var/panel  = FALSE

/obj/item/device/holomap/New()
	..()
	//delayer = new(0, ARBITRARILY_LARGE_NUMBER)

/obj/item/device/holomap/Destroy()
	//QDEL_NULL(delayer)

	if (viewing)
		viewing.mob.unregister_event(/event/logout, src, nameof(src::mob_logout()))

	..()

/obj/item/device/holomap/examine(var/mob/M)
	..()
	if (panel)
		to_chat(M, "The panel is open.")

/obj/item/device/holomap/attack_self(var/mob/user)
	if (viewing)
		viewing.images -= showing
		showing.Cut()
		to_chat(user, "You turn off \the [src].")
		viewing.mob.unregister_event(/event/logout, src, nameof(src::mob_logout()))
		viewing = null
		return

	if (!user.client) // delayer.blocked()
		return

	viewing = user.client
	showing = get_images(get_turf(user), viewing.view)
	viewing.images |= showing
	//delayer.addDelay(2 SECONDS) // Should be enough to prevent lag due to spam.
	user.register_event(/event/logout, src, nameof(src::mob_logout()))

/obj/item/device/holomap/proc/mob_logout(mob/user)
	if (viewing)
		viewing.images -= showing
		viewing = null

	user.unregister_event(/event/logout, src, nameof(src::mob_logout()))

	visible_message("\The [src] turns off.")
	showing.Cut()

/obj/item/device/holomap/proc/get_images(var/turf/T, var/view)
	. = list()
	for (var/turf/TT in trange(view, T))
		if (TT.holomap_data)
			. += TT.holomap_data

/obj/item/device/holomap/afterattack(var/turf/target, var/mob/user, var/proximity_flag, var/click_parameters)
	if (!hacked)
		return

	if (!isturf(target))
		target = get_turf(target)

	if (target.holomap_data)
		target.holomap_data.Cut()

	for (var/obj/O in target)
		if (O.supports_holomap())
			target.add_holomap(O)

	to_chat(user, "You reset the holomap data.")

/obj/item/device/holomap/attackby(obj/item/W, mob/user)
	if (W.is_screwdriver(user))
		panel = !panel
		to_chat(user, "<span class='notify'>You [panel ? "open" : "close"] the panel on \the [src].</span>")
		W.playtoolsound(src, 50)
		return 1

	if (W.is_multitool(user) && panel)
		hacked = !hacked
		to_chat(user, "<span class='notify'>You [hacked ? "disable" : "enable"] the lock on \the [src].</span>")
		return 1

	. = ..()
