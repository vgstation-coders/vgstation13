/obj/item/weapon/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = W_CLASS_SMALL
	pressure_resistance = 2

	autoignition_temperature = 522 // Kelvin
	fire_fuel = 1
	var/crayon = null

/obj/item/weapon/folder/New()
	..()
	update_icon()

/obj/item/weapon/folder/black
	crayon = "black"

/obj/item/weapon/folder/blue
	crayon = "blue"

/obj/item/weapon/folder/red
	crayon = "red"

/obj/item/weapon/folder/white
	crayon = "mime"

/obj/item/weapon/folder/yellow
	crayon = "yellow"

/obj/item/weapon/folder/purple
	crayon = "purple"

/obj/item/weapon/folder/orange
	crayon = "orange"

/obj/item/weapon/folder/green
	crayon = "green"

/obj/item/weapon/folder/rainbow
	crayon = "rainbow"

/obj/item/weapon/folder/update_icon()
	overlays.len = 0
	if(contents.len)
		overlays += image(icon = icon, icon_state = "folder_paper")

	switch(crayon)
		if(null)
			icon_state = "folder"
		if("black")
			icon_state = "folder_black"
		if("blue")
			icon_state = "folder_blue"
		if("red")
			icon_state = "folder_red"
		if("mime")
			icon_state = "folder_white"
		if("yellow")
			icon_state = "folder_yellow"
		if("purple")
			icon_state = "folder_purple"
		if("orange")
			icon_state = "folder_orange"
		if("green")
			icon_state = "folder_green"
		if("rainbow")
			icon_state = "folder_honk"
	return

/obj/item/weapon/folder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/photo))
		if(user.drop_item(W, src))
			to_chat(user, "<span class='notice'>You put the [W] into \the [src].</span>")
			update_icon()
	else if(istype(W, /obj/item/weapon/pen))
		set_tiny_label(user, " - '", "'")
	else if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		crayon = C.colourName
		update_icon()
	else if (istype(W, /obj/item/weapon/soap))
		crayon = null
		update_icon()
	return

/obj/item/weapon/folder/attack_self(mob/user as mob)
	var/dat = "<title>[name]</title>"

	for(var/obj/item/weapon/paper/P in src)
		dat += "<A href='?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR>"
	for(var/obj/item/weapon/photo/Ph in src)
		dat += "<A href='?src=\ref[src];remove=\ref[Ph]'>Remove</A> - <A href='?src=\ref[src];look=\ref[Ph]'>[Ph.name]</A><BR>"
	user << browse(dat, "window=folder")
	onclose(user, "folder")
	add_fingerprint(usr)
	return

/obj/item/weapon/folder/Topic(href, href_list)
	..()
	if((usr.stat || usr.restrained()))
		return

	if(usr.contents.Find(src))

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(!(istype(P, /obj/item/weapon/paper)) && !(istype(P, /obj/item/weapon/photo)))
				var/message = "<span class='warning'>[usr]([usr.key]) has tried to remove something other than a paper/photo from a folder.<span>"
				message_admins(message)
				message += "[P]"
				log_game(message)
				admin_log.Add(message)
				return
			if(!(P in src.contents))
				var/message = "<span class='warning'>[usr]([usr.key]) has tried to remove a paper/photo from a folder that didn't contain it.<span>"
				message_admins(message)
				message += "[P]"
				log_game(message)
				admin_log.Add(message)
				return
			if(P)
				P.forceMove(usr.loc)
				usr.put_in_hands(P)

		if(href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"])
			if(P)
				P.show_text(usr)
		if(href_list["look"])
			var/obj/item/weapon/photo/P = locate(href_list["look"])
			if(P)
				P.show(usr)

		//Update everything
		attack_self(usr)
		update_icon()
	return
