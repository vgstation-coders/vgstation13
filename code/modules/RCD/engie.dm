/obj/item/device/rcd/matter/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock,
	/datum/rcd_schematic/con_window,
	)


/obj/item/device/rcd/matter/engineering/New()
	. = ..()
	rcd_list += src

/obj/item/device/rcd/matter/engineering/Destroy()
	. = ..()
	rcd_list -= src

/obj/item/device/rcd/matter/engineering/afterattack(var/atom/A, var/mob/user)
	if(malf_rcd_disable)
		return

	return ..()

/obj/item/device/rcd/matter/engineering/suicide_act(var/mob/user)
	visible_message("<span class='danger'>[user] is using the deconstruct function on \the [src] on \himself! It looks like \he's trying to commit suicide!</span>")
	user.death(1)
	return SUICIDE_ACT_CUSTOM

/obj/item/device/rcd/matter/engineering/pre_loaded/New() //Comes with max energy
	..()
	matter = max_matter

/obj/item/device/rcd/borg/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock/borg,
	/datum/rcd_schematic/con_window/borg,
	)

/obj/item/device/rcd/matter/engineering/pre_loaded/admin
	name = "experimental Rapid-Construction-Device (RCD)"
	max_matter = INFINITY

/obj/item/device/rcd/matter/engineering/pre_loaded/admin/afterattack(var/atom/A, var/mob/user)
	if(!user.check_rights(R_ADMIN))
		visible_message("\The [src] disappears into nothing.")
		qdel(src)
		return
	return ..()

/obj/item/device/rcd/matter/engineering/pre_loaded/admin/delay(var/mob/user, var/atom/target, var/amount)
	return TRUE
