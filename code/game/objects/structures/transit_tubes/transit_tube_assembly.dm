/obj/structure/transit_tube_frame
    name = "transit tube frame"
    icon = 'icons/obj/pipes/transit_tube_frames.dmi'
    icon_state = "straight"
    density = 0
    anchored = 0
    pixel_x = -8
    pixel_y = -8
    layer = ABOVE_OBJ_LAYER
    var/list/dir_icon_states = list("N-S","N-S",null,"E-W",null,null,null,"E-W") // Occupies 1, 2, 4 and 8 for dir as an array pointer

/obj/structure/transit_tube_frame/New(var/loc, var/dir_override = null)
    ..()

    if(dir_override)
        dir = dir_override

/obj/structure/transit_tube_frame/attackby(obj/item/W as obj, mob/user as mob)
    if(istype(W,/obj/item/stack/sheet/glass/rglass) && anchored)
        var/obj/item/stack/sheet/glass/rglass/G = W
        playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
        to_chat(user, "<span class='notice'>You begin to add reinforced glass to \the [src]...</span>")
        if(G.amount < 2)
            to_chat(user, "<span class='warning'>You need 2 sheets of glass to do this.</span>")
            return 1
        if(do_after(user, src, 4 SECONDS))
            if(G.amount < 2) //User being tricky
                return 1
            G.use(2)
            to_chat(user, "<span class='notice'>You add the reinforced glass to the [src].</span>")
            new /obj/structure/transit_tube(loc, dir_icon_states[dir])
            qdel(src)
        return 1
    if(W.is_wrench(user))
        to_chat(user, "<span class='notice'>You [anchored ? "unanchor" : "anchor"] \the [src].</span>")
        W.playtoolsound(src, 50)
        anchored = !anchored
    if(iswelder(W))
        var/obj/item/tool/weldingtool/WT = W
        to_chat(user, "<span class='notice'>You begin to dismantle \the [src]...</span>")
        if(WT.do_weld(user, src, 4 SECONDS))
            to_chat(user, "<span class='notice'>You dismantle \the [src].</span>")
            new /obj/item/stack/sheet/metal(get_turf(src), 5)
            qdel(src)
        return 1

/obj/structure/transit_tube_frame/diag
    icon_state = "diag"
    dir_icon_states = list("NE-SW","NE-SW",null,"NW-SE",null,null,null,"NW-SE")

/obj/structure/transit_tube_frame/bent
    icon_state = "bent"
    dir_icon_states = list("N-SW","S-NE",null,"E-NW",null,null,null,"W-SE")

/obj/structure/transit_tube_frame/bent_invert
    icon_state = "bent-invert"
    dir_icon_states = list("N-SE","S-NW",null,"E-SW",null,null,null,"W-NE")

/obj/structure/transit_tube_frame/fork
    icon_state = "fork"
    dir_icon_states = list("N-SW-SE","S-NE-NW",null,"E-NW-SW",null,null,null,"W-SE-NE")

/obj/structure/transit_tube_frame/fork_invert
    icon_state = "fork-invert"
    dir_icon_states = list("N-SE-SW","S-NW-NE",null,"E-SW-NW",null,null,null,"W-NE-SE")

/obj/structure/transit_tube_frame/pass
    icon_state = "pass"
    dir_icon_states = list("N-S-pass","N-S-pass",null,"E-W-pass",null,null,null,"E-W-pass")

/obj/structure/transit_tube_frame/station
    name = "transit tube station frame"
    icon_state = "station"
    var/obj/item/weapon/circuitboard/airlock/electronics = null

/obj/structure/transit_tube_frame/station/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/sheet/glass/rglass) && anchored && electronics)
		var/obj/item/stack/sheet/glass/rglass/G = W
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You begin to add reinforced glass to \the [src]...</span>")
		if(G.amount < 2)
			to_chat(user, "<span class='warning'>You need 2 sheets of glass to do this.</span>")
			return 1
		if(do_after(user, src, 4 SECONDS))
			if(G.amount < 2) //User being tricky
				return 1
			G.use(2)
			to_chat(user, "<span class='notice'>You add the reinforced glass to the [src].</span>")
			var/obj/structure/transit_tube/station/TTS = new /obj/structure/transit_tube/station(loc, null, dir)

			if(src.electronics.one_access)
				TTS.req_access = null
				TTS.req_one_access = src.electronics.conf_access
			else
				TTS.req_access = src.electronics.conf_access
			TTS.req_access_dir = src.electronics.dir_access
			TTS.access_not_dir = src.electronics.access_nodir

			qdel(src)
		return 1
	if(istype(W,/obj/item/weapon/circuitboard/airlock))
		if(electronics)
			to_chat(user, "<span class='warning'>There is already a [electronics] in this!</span>")
		var/obj/item/weapon/circuitboard/airlock/C = W
		if(user.drop_item(C,src))
			to_chat(user, "You add the [C] to the [src].")
			electronics = C
	if(iscrowbar(W) && electronics)
		to_chat(user, "<span class='notice'>You pry the [electronics] out.</span>")
		W.playtoolsound(src, 50)
		electronics.forceMove(get_turf(src))
		user.put_in_hands(electronics)
		electronics = null
	if(W.is_wrench(user))
		to_chat(user, "<span class='notice'>You [anchored ? "unanchor" : "anchor"] \the [src].</span>")
		W.playtoolsound(src, 50)
		anchored = !anchored
	if(iswelder(W))
		if(electronics)
			to_chat(user, "<span class='warning'>Remove the [electronics] first!</span>")
			return 1
		var/obj/item/tool/weldingtool/WT = W
		to_chat(user, "<span class='notice'>You begin to dismantle \the [src]...</span>")
		if(WT.do_weld(user, src, 4 SECONDS))
			to_chat(user, "<span class='notice'>You dismantle \the [src].</span>")
			new /obj/item/stack/sheet/metal(get_turf(src), 5)
			qdel(src)
		return 1

/obj/structure/transit_tube_frame/pod
    name = "transit pod frame"
    icon_state = "pod"
    var/obj/item/weapon/circuitboard/mecha/transitpod/circuitry = null

/obj/structure/transit_tube_frame/pod/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/sheet/glass/rglass) && circuitry)
		var/obj/item/stack/sheet/glass/rglass/G = W
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You begin to add reinforced glass to \the [src]...</span>")
		if(G.amount < 2)
			to_chat(user, "<span class='warning'>You need 2 sheets of glass to do this.</span>")
			return 1
		if(do_after(user, src, 4 SECONDS))
			if(G.amount < 2) //User being tricky
				return 1
			G.use(2)
			to_chat(user, "<span class='notice'>You add the reinforced glass to the [src].</span>")
			var/obj/structure/transit_tube_pod/TTP = new /obj/structure/transit_tube_pod(loc)
			TTP.dir = src.dir
			qdel(src)
		return 1
	if(istype(W,/obj/item/weapon/circuitboard/mecha/transitpod))
		if(circuitry)
			to_chat(user, "<span class='warning'>There is already a [circuitry] in this!</span>")
		var/obj/item/weapon/circuitboard/mecha/transitpod/C = W
		if(user.drop_item(C,src))
			to_chat(user, "You add the [C] to the [src].")
			circuitry = C
	if(iscrowbar(W) && circuitry)
		to_chat(user, "<span class='notice'>You pry the [circuitry] out.</span>")
		W.playtoolsound(src, 50)
		circuitry.forceMove(get_turf(src))
		user.put_in_hands(circuitry)
		circuitry = null
	if(iswelder(W))
		if(circuitry)
			to_chat(user, "<span class='warning'>Remove the [circuitry] first!</span>")
			return 1
		var/obj/item/tool/weldingtool/WT = W
		to_chat(user, "<span class='notice'>You begin to dismantle \the [src]...</span>")
		if(WT.do_weld(user, src, 4 SECONDS))
			to_chat(user, "<span class='notice'>You dismantle \the [src].</span>")
			new /obj/item/stack/sheet/metal(get_turf(src), 5)
			qdel(src)
		return 1

/obj/item/weapon/circuitboard/mecha/transitpod
	name = "Circuit board (Transit tube pod)"
	icon_state = "mainboard"
