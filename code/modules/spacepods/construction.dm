/obj/structure/spacepod_frame
	name = "spacepod frame"
	density = 1
	opacity = 0

	anchored = 1
	layer = ABOVE_DOOR_LAYER

	icon = 'icons/48x48/pod_construction.dmi'
	icon_state = "pod_1"

	var/datum/construction/construct

/obj/structure/spacepod_frame/New()
	..()
	bound_width = 64
	bound_height = 64

	construct = new /datum/construction/reversible/pod/chassis(src)

	dir = EAST

/obj/structure/spacepod_frame/Destroy()
	QDEL_NULL(construct)
	..()

/obj/structure/spacepod_frame/attack_hand()
	return

/obj/structure/spacepod_frame/attackby(obj/item/W, mob/user)
	if(!construct?.action(W, user))
		..()

/obj/structure/spacepod_frame/unarmored
	name = "unarmored spacepod"
	desc = "A space pod with unwelded bulkhead panelling exposed."
	icon_state = "pod_9"

/obj/structure/spacepod_frame/unarmored/New()
	..()
	QDEL_NULL(construct)

/obj/structure/spacepod_frame/unarmored/attackby(obj/item/W, mob/user)
	if(!construct)
		if(istype(W,/obj/item/pod_parts/armor/civ))
			construct = new /datum/construction/reversible/pod/unarmored/civ(src)
		else if(istype(W, /obj/item/pod_parts/armor/taxi))
			construct = new /datum/construction/reversible/pod/unarmored/taxi(src)
	..()

/////////////////////////////////
// CONSTRUCTION STEPS
/////////////////////////////////
/datum/construction/reversible/pod/chassis
	result = /obj/structure/spacepod_frame/unarmored
	//taskpath = /datum/job_objective/make_pod
	steps = list(
				// 9. Bulkhead secured with bolts
				list(
					Co_DESC = "A space pod with unwelded bulkhead panelling exposed.",
					Co_BACKSTEP = list(
						Co_KEY      = "is_wrench",
						Co_VIS_MSG  = "{USER} unbolt{s} {HOLDER}'s bulkhead panelling.",
					),
					Co_NEXTSTEP = list(
						Co_KEY      = /obj/item/tool/weldingtool,
						Co_VIS_MSG  = "{USER} seal{s} {HOLDER}'s bulkhead panelling with a weld.",
						Co_AMOUNT   = 3
					)
				),
				// 8. Bulkhead added
				list(
					Co_DESC = "A space pod with loose bulkhead panelling exposed.",
					Co_BACKSTEP = list(
						Co_KEY      = /obj/item/tool/crowbar,
						Co_VIS_MSG  = "{USER} pop{s} {HOLDER}'s bulkhead panelling loose.",
					),
					Co_NEXTSTEP = list(
						Co_KEY      = "is_wrench",
						Co_VIS_MSG  = "{USER} secure{s} {HOLDER}'s bulkhead panelling."
					)
				),
				// 7. Core secured
				list(
					Co_DESC = "A naked space pod with an exposed core. How lewd.",
					Co_BACKSTEP = list(
						Co_KEY      = "is_wrench",
						Co_VIS_MSG  = "{USER} unsecure{s} {HOLDER}'s core."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = /obj/item/stack/sheet/metal,
						Co_AMOUNT   = 5,
						Co_VIS_MSG  = "{USER} fabricate{s} a pressure bulkhead for {HOLDER}.",
					)
				),
				// 6. Core inserted
				list(
					Co_DESC = "A naked space pod with a loose core.",
					Co_BACKSTEP = list(
						Co_KEY      = /obj/item/tool/crowbar,
						Co_VIS_MSG  = "{USER} delicately remove{s} the core from {HOLDER} with a crowbar."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = "is_wrench",
						Co_VIS_MSG  = "{USER} secure{s} the core's bolts."
					)
				),
				// 5. Circuit secured
				list(
					Co_DESC = "A wired pod frame with a secured mainboard.",
					Co_BACKSTEP = list(
						Co_KEY      = "is_screwdriver",
						Co_VIS_MSG  = "{USER} unsecure{s} the mainboard."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = /obj/item/pod_parts/core,
						Co_VIS_MSG  = "{USER} insert{s} the core into {HOLDER}.",
						Co_AMOUNT   = 1,
						Co_KEEP
					)
				),
				// 4. Circuit added
				list(
					Co_DESC = "A wired pod frame with a loose mainboard.",
					Co_BACKSTEP = list(
						Co_KEY      = /obj/item/tool/crowbar,
						Co_VIS_MSG  = "{USER} prie{s} out the mainboard."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = "is_screwdriver",
						Co_VIS_MSG  = "{USER} secure{s} the mainboard."
					)
				),
				// 3. Cleanly wired
				list(
					Co_DESC = "A wired pod frame.",
					Co_BACKSTEP = list(
						Co_KEY      = "is_screwdriver",
						Co_VIS_MSG  = "{USER} unclip{s} {HOLDER}'s wiring harnesses."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = /obj/item/weapon/circuitboard/mecha/pod,
						Co_VIS_MSG  = "{USER} insert{s} the mainboard into {HOLDER}.",
						Co_AMOUNT   = 1,
						Co_KEEP
					)
				),
				// 2. Crudely Wired
				list(
					Co_DESC = "A crudely-wired pod frame.",
					Co_BACKSTEP = list(
						Co_KEY      = "is_wirecutter",
						Co_VIS_MSG  = "{USER} cut{s} out {HOLDER}'s wiring."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = "is_screwdriver",
						Co_VIS_MSG  = "{USER} adjust{s} the wiring."
					)
				),
				// 1. Initial state
				list(
					Co_DESC = "An empty pod frame.",
					Co_NEXTSTEP = list(
						Co_KEY      = /obj/item/stack/cable_coil,
						Co_VIS_MSG  = "{USER} wire{s} {HOLDER}.",
						Co_AMOUNT   = 10
					)
				)
			)

/datum/construction/reversible/pod/spawn_result(mob/user as mob)
	..()
	feedback_inc("spacepod_created",1)
	return

/datum/construction/reversible/pod/chassis/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	holder.icon_state = "pod_[steps.len - index + 1 - diff]"
	return 1


/datum/construction/reversible/pod/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/////////////////////////////////
// PODS
/////////////////////////////////
/datum/construction/reversible/pod/unarmored/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	holder.icon_state = "pod_[9 + (steps.len - index + 1 - diff)]"
	return 1


/datum/construction/reversible/pod/unarmored/civ
	result = /obj/spacepod/civilian
	//taskpath = /datum/job_objective/make_pod
	steps = list(
				// 3. Bolted-down armor
				list(
					Co_DESC = "A space pod with unsecured armor.",
					Co_BACKSTEP = list(
						Co_KEY      = "is_wrench",
						Co_VIS_MSG  = "{USER} unsecure{s} {HOLDER}'s armor."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = /obj/item/tool/weldingtool,
						Co_VIS_MSG  = "{USER} weld{s} {HOLDER}'s armor.",
						Co_AMOUNT = 3
					)
				),
				// 2. Loose armor
				list(
					Co_DESC = "A space pod with unsecured armor.",
					Co_BACKSTEP = list(
						Co_KEY      = /obj/item/tool/crowbar,
						Co_VIS_MSG  = "{USER} remove{s} {HOLDER}'s armor."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = "is_wrench",
						Co_VIS_MSG  = "{USER} bolt{s} down {HOLDER}'s armor."
					)
				),
				// 1. Welded bulkhead
				list(
					Co_DESC = "A space pod with sealed bulkhead panelling exposed.",
					Co_BACKSTEP = list(
						Co_KEY      = /obj/item/tool/weldingtool,
						Co_VIS_MSG  = "{USER} cut{s} {HOLDER}'s bulkhead panelling loose.",
						Co_AMOUNT   = 3
					),
					Co_NEXTSTEP = list(
						Co_KEY      = /obj/item/pod_parts/armor/civ,
						Co_VIS_MSG  = "{USER} install{s} {HOLDER}'s armor plating.",
						Co_AMOUNT   = 1,
						Co_KEEP
					)
			)
		)

/datum/construction/reversible/pod/unarmored/taxi
	result = /obj/spacepod/taxi
	//taskpath = /datum/job_objective/make_pod
	steps = list(
				// 3. Bolted-down armor
				list(
					Co_DESC = "A space pod with unsecured armor.",
					Co_BACKSTEP = list(
						Co_KEY      = "is_wrench",
						Co_VIS_MSG  = "{USER} unsecure{s} {HOLDER}'s armor."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = /obj/item/tool/weldingtool,
						Co_VIS_MSG  = "{USER} weld{s} {HOLDER}'s armor.",
						Co_AMOUNT = 3
					)
				),
				// 2. Loose armor
				list(
					Co_DESC = "A space pod with unsecured armor.",
					Co_BACKSTEP = list(
						Co_KEY      = /obj/item/tool/crowbar,
						Co_VIS_MSG  = "{USER} remove{s} {HOLDER}'s armor."
					),
					Co_NEXTSTEP = list(
						Co_KEY      = "is_wrench",
						Co_VIS_MSG  = "{USER} bolt{s} down {HOLDER}'s armor."
					)
				),
				// 1. Welded bulkhead
				list(
					Co_DESC = "A space pod with sealed bulkhead panelling exposed.",
					Co_BACKSTEP = list(
						Co_KEY      = /obj/item/tool/weldingtool,
						Co_VIS_MSG  = "{USER} cut{s} {HOLDER}'s bulkhead panelling loose.",
						Co_AMOUNT   = 3
					),
					Co_NEXTSTEP = list(
						Co_KEY      = /obj/item/pod_parts/armor/taxi,
						Co_VIS_MSG  = "{USER} install{s} {HOLDER}'s armor plating.",
						Co_AMOUNT   = 1,
						Co_KEEP
					)
			)
		)
