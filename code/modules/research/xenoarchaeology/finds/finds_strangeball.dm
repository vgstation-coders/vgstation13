/obj/item/device/mmi/posibrain/strangeball
	name = "strange ball"
	desc = "A complex metal ball with \"TG17355\" carved on its surface."
	icon_state = "omoikaneball"

/obj/item/device/mmi/posibrain/search_for_candidates()
	..()
	icon_state = "omoikaneball-searching"

/obj/item/device/mmi/posibrain/strangeball/transfer_personality(var/mob/candidate)
	src.searching = 0
	var/turf/T = get_turf(src)
	var/mob/living/silicon/robot/M = new /mob/living/silicon/robot(T)
	M.cell.maxcharge = 15000
	M.cell.charge = 15000
	M.pick_module(forced_module="TG17355")
	M.icon_state = "omoikane"
	M.updateicon()
	M.ckey = candidate.ckey
	M.Namepick()
	M.updatename()
	qdel(src)

/obj/item/device/mmi/posibrain/strangeball/reset_search()
	..()
	icon_state = "omoikaneball"
