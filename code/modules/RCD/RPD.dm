/obj/item/device/rcd/rpd
	name       = "\improper Rapid-Piping-Device (RPD)"
	desc       = "A device used to rapidly pipe things."
	icon_state = "rpd"

	starting_materials = list(MAT_IRON = 75000, MAT_GLASS = 37500)

	var/hook_key

	schematics = list(
		/* Utilities */
		/datum/rcd_schematic/decon_pipes,
		/datum/rcd_schematic/paint_pipes,

		/* Regular pipes */
		/datum/rcd_schematic/pipe,
		/datum/rcd_schematic/pipe/bent,
		/datum/rcd_schematic/pipe/manifold,
		/datum/rcd_schematic/pipe/valve,
		/datum/rcd_schematic/pipe/dvalve,
		/datum/rcd_schematic/pipe/cap,
		/datum/rcd_schematic/pipe/manifold_4w,
		/datum/rcd_schematic/pipe/mtvalve,
		/datum/rcd_schematic/pipe/dtvalve,
		/datum/rcd_schematic/pipe/layer_manifold,
		/datum/rcd_schematic/pipe/layer_adapter,

		/* Devices */
		/datum/rcd_schematic/pipe/connector,
		/datum/rcd_schematic/pipe/unary_vent,
		/datum/rcd_schematic/pipe/passive_vent,
		/datum/rcd_schematic/pipe/pump,
		/datum/rcd_schematic/pipe/passive_gate,
		/datum/rcd_schematic/pipe/volume_pump,
		/datum/rcd_schematic/pipe/scrubber,
		/datum/rcd_schematic/pmeter,
		/datum/rcd_schematic/gsensor,
		/datum/rcd_schematic/pipe/filter,
		/datum/rcd_schematic/pipe/mixer,
		/datum/rcd_schematic/pipe/thermal_plate,
		/datum/rcd_schematic/pipe/injector,
		/datum/rcd_schematic/pipe/dp_vent,

		/* H/E Pipes */
		/datum/rcd_schematic/pipe/he,
		/datum/rcd_schematic/pipe/he_bent,
		/datum/rcd_schematic/pipe/juntion,
		/datum/rcd_schematic/pipe/heat_exchanger,
		/datum/rcd_schematic/pipe/he_manifold,
		/datum/rcd_schematic/pipe/he_manifold4w,

		/* Disposal Pipes */
		/datum/rcd_schematic/pipe/disposal,
		/datum/rcd_schematic/pipe/disposal/bent,
		/datum/rcd_schematic/pipe/disposal/junction,
		/datum/rcd_schematic/pipe/disposal/y_junction,
		/datum/rcd_schematic/pipe/disposal/trunk,
		/datum/rcd_schematic/pipe/disposal/bin,
		/datum/rcd_schematic/pipe/disposal/outlet,
		/datum/rcd_schematic/pipe/disposal/chute,
		/datum/rcd_schematic/pipe/disposal/sort,
		/datum/rcd_schematic/pipe/disposal/sort_wrap
	)

/obj/item/device/rcd/rpd/examine(var/mob/user)
	..()
	to_chat(user, "<span class='notice'>To quickly scroll between directions of the selected schematic, use alt+mousewheel.")
	to_chat(user, "<span class='notice'>To quickly scroll between layers, use shift+mousewheel.</span>")
	to_chat(user, "<span class='notice'>Note that hotkeys like ctrl click do not work while the RPD is held in your active hand!</span>")

/obj/item/device/rcd/rpd/pickup(var/mob/living/L)
	..()

	hook_key = L.on_clickon.Add(src, "mob_onclickon")

/obj/item/device/rcd/rpd/dropped(var/mob/living/L)
	..()

	L.on_clickon.Remove(hook_key)
	hook_key = null

// If the RPD is held, some modifiers are removed.
// This is to prevent the mouse wheel bindings (which require alt and such)
// From being a pain to use, because alt click intercepts regular clicks.
/obj/item/device/rcd/rpd/proc/mob_onclickon(var/list/event_args, var/mob/living/L)
	if (L.get_active_hand() != src)
		return
	if(istype(event_args["target"], /mob/living/carbon))
		return //If we're alt clicking a carbon, let's assume we want to interact with them.

	var/list/modifiers = event_args["modifiers"]
	modifiers -= list("alt", "shift", "ctrl")

/obj/item/device/rcd/rpd/mech/Topic(var/href, var/list/href_list)
	..()
	if(href_list["close"])
		return
	if(usr.incapacitated() || usr.isStunned() || usr.loc != src.loc.loc)
		return TRUE

	if (href_list["schematic"])
		var/datum/rcd_schematic/C = find_schematic(href_list["schematic"])

		if (!istype(C))
			return 1

		switch (href_list["act"])
			if ("select")
				try_switch(usr, C)

			if ("fav")
				favorites |= C
				rebuild_ui()

			if ("defav")
				favorites -= C
				rebuild_ui()

			if ("favorder")
				var/index = favorites.Find(C)
				if (href_list["order"] == "up")
					if (index == favorites.len)
						return 1

					favorites.Swap(index, index + 1)

				else
					if (index == 1)
						return 1

					favorites.Swap(index, index - 1)

				rebuild_favs()

		return 1

	// The href didn't get handled by us so we pass it down to the selected schematic.
	if (selected)
		return selected.Topic(href, href_list)

/obj/item/device/rcd/rpd/admin
	name = "experimental Rapid-Piping-Device (RPD)"

/obj/item/device/rcd/rpd/admin/afterattack(var/atom/A, var/mob/user)
	if(!user.check_rights(R_ADMIN))
		visible_message("\The [src] disappears into nothing.")
		qdel(src)
		return
	return ..()

/obj/item/device/rcd/rpd/admin/delay(var/mob/user, var/atom/target, var/amount)
	return TRUE