/obj/item/device/pipe_painter
	name = "pipe painter"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler1"
	item_state = "flight"
	flags_1 = NOBLUDGEON_1
	var/paint_color = "grey"

	materials = list(MAT_METAL=5000, MAT_GLASS=2000)

/obj/item/device/pipe_painter/afterattack(atom/A, mob/user, proximity_flag)
	//Make sure we only paint adjacent items
	if(!proximity_flag)
		return

	if(!istype(A, /obj/machinery/atmospherics/pipe))
		return

	var/obj/machinery/atmospherics/pipe/P = A
	if(P.paint(GLOB.pipe_paint_colors[paint_color]))
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] paints \the [P] [paint_color].</span>","<span class='notice'>You paint \the [P] [paint_color].</span>")

/obj/item/device/pipe_painter/attack_self(mob/user)
	paint_color = input("Which colour do you want to use?","Pipe painter") in GLOB.pipe_paint_colors

/obj/item/device/pipe_painter/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It is set to [paint_color].</span>")
