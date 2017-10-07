/obj/item/device/rcd/matter/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock
	)

	var/disabled		= 0

/obj/item/device/rcd/matter/engineering/afterattack(var/atom/A, var/mob/user)
	if(disabled)
		return

	return ..()

/obj/item/device/rcd/matter/engineering/suicide_act(var/mob/user)
	visible_message("<span class='danger'>[user] is using the deconstruct function on \the [src] on \himself! It looks like \he's  trying to commit suicide!</span>")
	return (user.death(1))

/obj/item/device/rcd/matter/engineering/pre_loaded/New() //Comes with max energy
	..()
	matter = max_matter

/obj/item/device/rcd/borg/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock
	)

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter in a cartridge form, used in various fabricators."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = Tc_MATERIALS + "=2"
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 20000, MAT_GLASS = 10000)
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/rcd_ammo/attackby(var/obj/O, mob/user)
	if(is_type_in_list(O, list(/obj/item/device/rcd/matter/engineering,  /obj/item/device/rcd/matter/rsf)) || (istype(O, /obj/item/device/material_synth) && !istype(O, /obj/item/device/material_synth/robot)))
		return O.attackby(src, user)

/obj/item/device/rcd/matter/engineering/mech
	matter = 30

/obj/item/device/rcd/matter/engineering/mech/use_energy(var/amount, var/mob/user)
	return	//handled in mech code

/obj/item/device/rcd/matter/engineering/mech/use_energy(var/amount, var/mob/user)
	return	//handled in mech code
/*
/obj/item/device/rcd/matter/engineering/mech/Topic(var/href, var/list/href_list)
	..()
	if (usr.incapacitated() || usr.isStunned() || usr.loc != src.loc.loc)
		return 1

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
*/