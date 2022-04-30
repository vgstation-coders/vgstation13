/obj/structure/closet/secure_closet/guncabinet
	name = "gun cabinet"
	req_access = list(access_armory)
	icon = 'icons/obj/guncabinet.dmi'
	icon_state = "base"
	icon_off = "base"
	icon_broken ="base"
	icon_locked ="base"
	icon_closed ="base"
	icon_opened = "base"

	var/icon/cabinet_door

/obj/structure/closet/secure_closet/guncabinet/New()
	..()
	cabinet_door = icon(icon, "door_locked_[icon_state]")
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/toggle()
	var/old_open = opened
	. = ..()
	update_icon(old_open != opened)

/obj/structure/closet/secure_closet/guncabinet/togglelock()
	. = ..()
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/update_icon(contents_change = 0)
	overlays -= cabinet_door
	overlays.Remove("welded")
	if(opened)
		cabinet_door = icon(icon, "door_open_[icon_state]")
	else
		if(broken)
			cabinet_door = icon(icon, "door_broken_[icon_state]")
		else if (locked)
			cabinet_door = icon(icon, "door_locked_[icon_state]")
		else
			cabinet_door = icon(icon, "door_[icon_state]")

	if(contents_change)
		overlays.len = 0
		var/lazors = 0
		var/shottas = 0
		for (var/obj/item/weapon/gun/G in contents)
			if (istype(G, /obj/item/weapon/gun/energy))
				lazors++
			if (istype(G, /obj/item/weapon/gun/projectile/))
				shottas++
		if (lazors || shottas)
			var/overlay_num = min(lazors + shottas, 7)
			for (var/i = 1 to overlay_num)
				var/gun_state = ""
				if (lazors > 0 && (shottas <= 0 || prob(50)))
					lazors--
					gun_state = "laser"
				else if (shottas > 0)
					shottas--
					gun_state = "projectile"

				var/image/gun = image(icon(src.icon, gun_state))

				gun.pixel_x = ((i-2)*2) * PIXEL_MULTIPLIER
				overlays += gun


	overlays += cabinet_door
	if(welded)
		overlays += image(icon = icon, icon_state = "welded")

/obj/structure/closet/secure_closet/guncabinet/medical
	name = "medical gun cabinet"
	req_access = list(access_medical)
	icon_state = "med"
	icon_off = "med"
	icon_broken ="med"
	icon_locked ="med"
	icon_closed ="med"
	icon_opened = "med"

/obj/structure/closet/secure_closet/guncabinet/engineering
	name = "engineering gun cabinet"
	req_access = list(access_engine_major)
	icon_state = "eng"
	icon_off = "eng"
	icon_broken ="eng"
	icon_locked ="eng"
	icon_closed ="eng"
	icon_opened = "eng"

/obj/structure/closet/secure_closet/guncabinet/science
	name = "science gun cabinet"
	req_access = list(access_science)
	icon_state = "sci"
	icon_off = "sci"
	icon_broken ="sci"
	icon_locked ="sci"
	icon_closed ="sci"
	icon_opened = "sci"

/obj/structure/closet/secure_closet/guncabinet/cargo
	name = "cargo gun cabinet"
	req_access = list(access_cargo)
	icon_state = "cargo"
	icon_off = "cargo"
	icon_broken ="cargo"
	icon_locked ="cargo"
	icon_closed ="cargo"
	icon_opened = "cargo"
