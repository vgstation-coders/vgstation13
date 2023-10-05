/obj/item/device/rcd/rpd
	name       = "\improper Rapid-Piping-Device (RPD)"
	desc       = "A device used to rapidly pipe things."
	icon_state = "rpd"
	var/has_metal_slime = 0
	var/has_yellow_slime = 0
	starting_materials = list(MAT_IRON = 75000, MAT_GLASS = 37500)
	var/build_all = 0
	var/autowrench = 0
	var/obj/item/tool/wrench/internal_wrench = new()
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
		/datum/rcd_schematic/pipe/mpvalve,
		/datum/rcd_schematic/pipe/dpvalve,
		/datum/rcd_schematic/pipe/cap,
		/datum/rcd_schematic/pipe/manifold_4w,
		/datum/rcd_schematic/pipe/mtvalve,
		/datum/rcd_schematic/pipe/dtvalve,
		/datum/rcd_schematic/pipe/layer_manifold,
		/datum/rcd_schematic/pipe/layer_adapter,
		/datum/rcd_schematic/pipe/z_up,
		/datum/rcd_schematic/pipe/z_down,

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
		/datum/rcd_schematic/pipe/heat_pump,
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
		/datum/rcd_schematic/pipe/disposal/sort_wrap,
		/datum/rcd_schematic/pipe/disposal/up,
		/datum/rcd_schematic/pipe/disposal/down,
	)

/obj/item/device/rcd/rpd/examine(var/mob/user)
	..()
	to_chat(user, "<span class='notice'>To quickly scroll between directions of the selected schematic, use alt+mousewheel.")
	to_chat(user, "<span class='notice'>To quickly scroll between layers, use shift+mousewheel.</span>")
	to_chat(user, "<span class='notice'>Note that hotkeys like ctrl click do not work while the RPD is held in your active hand!</span>")
	if(has_metal_slime)
		to_chat(user, "<span class='notice'>The multilayering mode is currently [build_all ? "enabled" : "disabled"].</span>")
	if(has_yellow_slime)
		to_chat(user, "<span class='notice'>The automatic wrenching mode is currently [autowrench ? "enabled" : "disabled"].</span>")

/obj/item/device/rcd/rpd/pickup(var/mob/living/L)
	..()
	L.register_event(/event/clickon, src, nameof(src::mob_onclickon()))

/obj/item/device/rcd/rpd/dropped(var/mob/living/L)
	..()
	L.unregister_event(/event/clickon, src, nameof(src::mob_onclickon()))
	hook_key = null

// If the RPD is held, some modifiers are removed.
// This is to prevent the mouse wheel bindings (which require alt and such)
// from being a pain to use, because alt click intercepts regular clicks.
/obj/item/device/rcd/rpd/proc/mob_onclickon(mob/user, list/modifiers, atom/target)
	if (user.get_active_hand() != src)
		return
	if(istype(target, /mob/living/carbon))
		return //If we're alt clicking a carbon, let's assume we want to interact with them.

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

/obj/item/device/rcd/rpd/slime_act(primarytype, mob/user)
	if(primarytype == /mob/living/carbon/slime/metal)
		if(has_metal_slime)
			to_chat(user, "It already has a slime extract attached.")
			return FALSE
		else
			has_metal_slime=1
			verbs += /obj/item/device/rcd/rpd/proc/multilayer
			to_chat(user, "You jam the slime extract into the RPD's fabricator.")
			return TRUE

	if(primarytype == /mob/living/carbon/slime/yellow)
		if(has_yellow_slime)
			to_chat(user, "It already has a slime extract attached.")
			return FALSE
		else
			has_yellow_slime=1
			verbs += /obj/item/device/rcd/rpd/proc/autowrench
			to_chat(user, "You jam the slime extract into the RPD's output nozzle.")
			return TRUE

/obj/item/device/rcd/rpd/afterattack(var/atom/A, var/mob/user)
	if(!selected)
		return 1

	if(~selected.flags & (RCD_SELF_SANE | RCD_RANGE) && !(user.Adjacent(A) && A.Adjacent(user))) // If RCD_SELF_SANE and RCD_RANGE are disabled we use adjacency.
		return 1

	if(selected.flags & RCD_RANGE && ~selected.flags & RCD_SELF_SANE && get_dist(A, user) > 1) // RCD_RANGE is used AND we're NOT SELF_SANE, use range(1)
		return 1

	if(selected.flags & RCD_GET_TURF) // Get the turf because RCD_GET_TURF is on.
		A = get_turf(A)
		if (!A)
			return // Thing clicked was in nullspace, so we won't pass a null turf.

	if(~selected.flags & RCD_SELF_SANE && get_energy(user) < selected.energy_cost) // Handle energy amounts, but only if not SELF_SANE.
		return 1
	if(build_all && istype(selected, /datum/rcd_schematic/pipe))
		var/datum/rcd_schematic/pipe/our_schematic = selected //typecast
		if(our_schematic.layer) // this is needed because disposal pipe schematic datums are retarded
			for(var/layer in 1 to 5)
				busy  = TRUE // Busy to prevent switching schematic while it's in use.
				our_schematic.set_layer(layer)
				if(layer != 5 )
					spawn(-1)
						our_schematic.attack(A, user)
				else
					var/t = our_schematic.attack(A, user)
					if(!t) // No errors
						if(~our_schematic.flags & RCD_SELF_COST) // Handle energy costs unless the schematic does it itself.
							use_energy(our_schematic.energy_cost, user)
					else
						if(istext(t))
							to_chat(user, "<span class='warning'>\the [src]'s error light flickers: [t]</span>")
						else
							to_chat(user, "<span class='warning'>\the [src]'s error light flickers.</span>")

				busy = FALSE
			return 1

	busy  = TRUE // Busy to prevent switching schematic while it's in use.
	var/t = selected.attack(A, user)
	if(!t) // No errors
		if(~selected.flags & RCD_SELF_COST) // Handle energy costs unless the schematic does it itself.
			use_energy(selected.energy_cost, user)
	else
		if(istext(t))
			to_chat(user, "<span class='warning'>\the [src]'s error light flickers: [t]</span>")
		else
			to_chat(user, "<span class='warning'>\the [src]'s error light flickers.</span>")

	busy = FALSE
	return 1


/obj/item/device/rcd/rpd/proc/multilayer()
	set category = "Object"
	set name = "Multilayer Mode"

	if(usr.incapacitated())
		return

	src.build_all = !src.build_all
	to_chat(usr, "You [build_all ? "enable" : "disable"] the multilayer mode.")

/obj/item/device/rcd/rpd/proc/autowrench()
	set category = "Object"
	set name = "Autowrench Mode"

	if(usr.incapacitated())
		return

	src.autowrench = !src.autowrench
	to_chat(usr, "You [autowrench ? "enable" : "disable"] the automatic wrenching mode.")

/obj/item/device/rcd/rpd/admin
	name = "experimental Rapid-Piping-Device (RPD)"

/obj/item/device/rcd/rpd/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is building pipes inside \himself! It looks like \he's trying to commit suicide!</span>")
	playsound(src, 'sound/items/Deconstruct.ogg', 75, 1)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
		if(head_organ)
			head_organ.explode()
		else
			user.gib()
	else
		user.gib()
	new /obj/item/pipe(get_turf(src))
	return (SUICIDE_ACT_BRUTELOSS)

/obj/item/device/rcd/rpd/admin/afterattack(var/atom/A, var/mob/user)
	if(!user.check_rights(R_ADMIN))
		visible_message("\The [src] disappears into nothing.")
		qdel(src)
		return
	return ..()

/obj/item/device/rcd/rpd/admin/delay(var/mob/user, var/atom/target, var/amount)
	return TRUE
