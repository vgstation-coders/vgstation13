/obj/item/mounted/frame/apc_frame
	name = "\improper APC frame"
	desc = "Used for repairing or building APCs."
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	flags = FPRINT
	w_type=RECYK_METAL
	mount_reqs = list("simfloor", "nospace")
	sheets_refunded = 0 // we handle this in the datum below
	resulttype = /obj/machinery/power/apc
	var/datum/construction/construct

/obj/item/mounted/frame/apc_frame/New()
	..()
	construct = new /datum/construction/reversible/crank_charger(src)

/obj/item/mounted/frame/apc_frame/attackby(var/obj/item/W, var/mob/user)
	if(!construct || !construct.action(W, user))
		..()

/obj/item/mounted/frame/apc_frame/try_build(turf/on_wall, mob/user)
	if(..())
		var/turf/turf_loc = get_turf(user)
		var/area/area_loc = turf_loc.loc

		if (area_loc.areaapc)
			to_chat(user, "<span class='rose'>This area already has an APC.</span>")
			return //only one APC per area
		if(area_loc.forbid_apc)
			to_chat(user, "<span class='rose'>You cannot build an APC in this area.</span>")
			return
		for(var/obj/machinery/power/terminal/T in turf_loc)
			if (T.master)
				to_chat(user, "<span class='rose'>There is another network terminal here.</span>")
				return
			else
				var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(turf_loc)
				C.amount = 10
				to_chat(user, "You cut the cables and disassemble the unused power terminal.")
				qdel(T)
		return 1
	return
