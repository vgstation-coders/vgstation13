/obj/structure/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	flags = FPRINT
	density = 0
	anchored = 1
	var/notices = 0

/obj/structure/noticeboard/initialize()
	for(var/obj/item/I in loc)
		if(notices > 4)
			break
		if(istype(I, /obj/item/weapon/paper))
			I.forceMove(src)
			notices++
	icon_state = "nboard0[notices]"

//attaching papers!!
/obj/structure/noticeboard/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(O.is_wrench(user))
		to_chat(user, "<span class='notice'>You disassemble \the [src].</span>")
		O.playtoolsound(src, 100)
		new /obj/item/stack/sheet/wood (src.loc,2)
		qdel(src)
	if(istype(O, /obj/item/weapon/paper))
		if(notices < 5)
			O.add_fingerprint(user)
			add_fingerprint(user)
			user.drop_item(O,src, force_drop = 1)
			notices++
			icon_state = "nboard0[notices]"	//update sprite
			to_chat(user, "<span class='notice'>You pin the paper to the noticeboard.</span>")
		else
			to_chat(user, "<span class='notice'>You reach to pin your paper to the board but hesitate. You are certain your paper will not be seen among the many others already attached.</span>")

/obj/structure/noticeboard/attack_hand(user as mob)
	var/dat = "<B>Noticeboard</B><BR>"
	for(var/obj/item/weapon/paper/P in src)
		dat += "<A href='?src=\ref[src];read=\ref[P]'>[P.name]</A> <A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A><BR>"
	user << browse("<HEAD><TITLE>Notices</TITLE></HEAD>[dat]","window=noticeboard")
	onclose(user, "noticeboard")


/obj/structure/noticeboard/Topic(href, href_list)
	..()
	usr.set_machine(src)
	if(href_list["remove"])
		if((usr.stat || usr.restrained()))	//For when a player is handcuffed while they have the notice window open
			return
		var/obj/item/P = locate(href_list["remove"])
		if((P && P.loc == src))
			P.forceMove(get_turf(src))	//dump paper on the floor because you're a clumsy fuck
			P.add_fingerprint(usr)
			add_fingerprint(usr)
			notices--
			icon_state = "nboard0[notices]"

	if(href_list["write"])
		if((usr.stat || usr.restrained())) //For when a player is handcuffed while they have the notice window open
			return
		var/obj/item/P = locate(href_list["write"])

		if((P && P.loc == src)) //ifthe paper's on the board
			var/pen_index = usr.find_held_item_by_type(/obj/item/weapon/pen)
			if(pen_index)
				var/obj/item/weapon/pen/pen = usr.held_items[pen_index]
				add_fingerprint(usr)
				P.attackby(pen, usr)
			else
				to_chat(usr, "<span class='notice'>You'll need something to write with!</span>")

	if(href_list["read"])
		var/obj/item/weapon/paper/P = locate(href_list["read"])
		if((P && P.loc == src))
			P.show_text(usr)
	return
