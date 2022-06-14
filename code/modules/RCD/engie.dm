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

/obj/item/device/rcd/matter/engineering/suicide_act(var/mob/living/user)
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

/obj/item/device/rcd/matter/engineering/pre_loaded/adv
	name = "advanced Rapid-Construction-Device (RCD)"
	icon_state = "arcd"
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_rfloors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_rwalls,
	/datum/rcd_schematic/con_airlock,
	/datum/rcd_schematic/con_window,
	)
	matter = 60
	max_matter = 60
	var/plasma_matter = 30
	var/max_plasma_matter = 30
	origin_tech = Tc_ENGINEERING + "=5;" + Tc_MATERIALS + "=4;" + Tc_PLASMATECH + "=4"
	mech_flags = MECH_SCAN_FAIL

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/attackby(var/obj/item/stack/S, var/mob/user)
	..()
	if(istype(S,/obj/item/stack/rcd_ammo_plasma))
		if((plasma_matter + 10) > max_plasma_matter)
			to_chat(user, "<span class='notice'>\the [src] can't hold any more plasma matter-units.</span>")
			return 1
		plasma_matter += 10
		S.use(1)
		playsound(src, 'sound/machines/click.ogg', 20, 1)
		to_chat(user, "<span class='notice'>\the [src] now holds [plasma_matter]/[max_plasma_matter] plasma matter-units.</span>")
		return 1

	if(S.is_screwdriver(user))
		while(plasma_matter >= 10)
			new /obj/item/stack/rcd_ammo_plasma(user.loc, 1)
			plasma_matter -= 10

		return 1

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/examine(var/mob/user)
	..()
	to_chat(user, "It currently holds [plasma_matter]/[max_plasma_matter] plasma matter-units.")

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/afterattack(var/atom/A, var/mob/user)
	// Handle energy amounts, but only if not SELF_SANE.
	if(selected && ~selected.flags & RCD_SELF_SANE && get_energy(user,selected.plasma_energy_cost > 0) < selected.plasma_energy_cost)
		return 1

	return ..()

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/delay(var/mob/user, var/atom/target, var/amount)
	return do_after(user, target, amount/2)

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/use_energy(var/amount, var/mob/user, var/plasma_amount)
	..()
	plasma_matter -= plasma_amount
	to_chat(user, "<span class='notice'>\the [src] currently holds [plasma_matter]/[max_plasma_matter] plasma matter-units.")

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/get_energy(var/mob/user, var/plasma = FALSE)
	return plasma ? plasma_matter : matter

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/admin
	name = "experimental Rapid-Construction-Device (RCD)"
	max_matter = INFINITY
	max_plasma_matter = INFINITY

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/admin/afterattack(var/atom/A, var/mob/user)
	if(!user.check_rights(R_ADMIN))
		visible_message("\The [src] disappears into nothing.")
		qdel(src)
		return
	return ..()

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/admin/delay(var/mob/user, var/atom/target, var/amount)
	return TRUE
