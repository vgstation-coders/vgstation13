/obj/item/device/mmi/posibrain/strangeball
	name = "strange ball"
	desc = "A complex metallic ball with \"TG17355\" carved on its surface."
	var/ball = "omoikaneball"
	var/burger = "omoikane"
	icon_state = "omoikaneball"
	mech_flags = MECH_SCAN_ILLEGAL

/obj/item/device/mmi/posibrain/strangeball/search_for_candidates()
	..()
	icon_state = "[ball]-searching"

/obj/item/device/mmi/posibrain/strangeball/transfer_personality(var/mob/candidate)
	src.searching = 0
	var/turf/T = get_turf(src)
	var/mob/living/silicon/robot/M = new /mob/living/silicon/robot(T)
	M.UnlinkSelf() //No Lawsync, No robotics console, No camera, final destination.
	M.laws = new /datum/ai_laws/asimov() // WOOP WOOP HUMAN HARM
	M.cell.maxcharge = 15000
	M.cell.charge = 15000
	M.pick_module(forced_module="TG17355")
	M.icon_state = burger
	M.updateicon()
	M.ckey = candidate.ckey
	M.Namepick()
	M.updatename()
	src.investigation_log(I_ARTIFACT, "|| [key_name(M)] spawned as TG17355 Cyborg.")
	qdel(src)

/obj/item/device/mmi/posibrain/strangeball/reset_search()
	..()
	icon_state = ball

/obj/item/device/mmi/posibrain/strangeball/strangeegg
	name = "strange egg"
	desc = "A complex egg-like machine with \"TG17355\" carved on its surface."
	ball = "peaceegg"
	burger = "peaceborg"
	icon_state = "peaceegg"
	w_class = W_CLASS_GIANT
	density = 1

/obj/item/device/mmi/posibrain/strangeball/strangeegg/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.incapacitated() || U.lying || searching)
			return
		if(U.gloves)
			to_chat(U, "<b>You touch \the [src]</b> with your gloved hands, [pick("but nothing of note happens","but nothing happens","but nothing interesting happens","but you notice nothing different","but nothing seems to have happened")].")
			return
		to_chat(U, "<span class='notice'>You touch \the [src].</span>")
		return search_for_candidates()

/obj/item/device/mmi/posibrain/strangeball/strangeegg/attack_paw(mob/user)
	return
