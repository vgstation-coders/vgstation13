/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a high-security card-locked storage unit."
	icon = 'icons/obj/closet.dmi'
	moody_light_icon = 'icons/obj/closet.dmi'
	moody_light_state = "light"
	icon_state = "secure"
	density = 1
	opened = 0
	large = 1
	locked = 1
	has_electronics = 1
	var/overlay_x = 0
	var/overlay_y = 0
	wall_mounted = 0 //never solid (You can always pass over it)
	health = 200
	var/id_tag = null

/obj/structure/closet/secure_closet/cabinet
	icon_state = "cabinetsecure"
	has_lockless_type = /obj/structure/closet/cabinet/basic
	is_wooden = TRUE
	starting_materials = list(MAT_WOOD = 2*CC_PER_SHEET_WOOD)
	w_type = RECYK_WOOD
	overlay_x = -1

/obj/structure/closet/secure_closet/basic
	has_lockless_type = /obj/structure/closet/basic

/obj/structure/closet/secure_closet/New()
	. = ..()
	update_icon()

/obj/structure/closet/secure_closet/can_open()
	if(!..())
		return 0
	if(src.locked)
		return 0
	return 1

/obj/structure/closet/secure_closet/close()
	..()
	update_icon()
	return 1

/obj/structure/closet/secure_closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken)
		if(prob(50/severity))
			src.locked = !src.locked
			src.update_icon()
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				src.req_access = list()
				src.req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/secure_closet/proc/togglelock(mob/user)
	if(allowed(user))
		locked = !locked
		visible_message("<span class='notice'>The locker has been [locked ? null : "un"]locked by [user].</span>")
	else
		to_chat(user, "<span class='notice'>Access Denied.</span>")
	update_icon()

/obj/structure/closet/secure_closet/attackby(obj/item/weapon/W, mob/user)
	if(opened)
		return ..()
	else if(broken)
		if(issolder(W))
			var/obj/item/tool/solder/S = W
			if(!S.remove_fuel(4,user))
				return
			S.playtoolsound(loc, 100)
			if(do_after(user, src,4 SECONDS * S.work_speed))
				S.playtoolsound(loc, 100)
				broken = 0
				to_chat(user, "<span class='notice'>You repair the electronics inside the locking mechanism!</span>")
				update_icon()
		else
			to_chat(user, "<span class='notice'>The locker appears to be broken.</span>")
			return
	else if(!broken && emag_check(W,user))
		return
	else if(iswelder(W) && canweld())
		var/obj/item/tool/weldingtool/WT = W
		if(!WT.remove_fuel(1,user))
			return
		welded =! welded
		update_icon()
		visible_message("<span class='warning'>[src] has been [welded?"welded shut":"unwelded"] by [user.name].</span>", 1, "You hear welding.", 2)
	else if(W.is_screwdriver(user) && !locked && has_lockless_type)
		remove_lock(user)
		return
	else
		togglelock(user)

/obj/structure/closet/secure_closet/emag_act(mob/user)
	if(!broken)
		broken = TRUE
		locked = FALSE
		desc = "It appears to be broken."
		for(var/mob/O in viewers(user, 3))
			O.show_message("<span class='warning'>The locker has been broken by [user] with an electromagnetic card!</span>", 1, "You hear a faint electrical spark.", 2)
		overlays.len = 0
		overlays += "emag"
		spawn(5)
			overlays.len = 0
			update_icon()

/obj/structure/closet/secure_closet/relaymove(mob/user)
	if(user.stat || !isturf(src.loc))
		return

	if(!(src.locked) && !(src.welded))
		open(user)
	else
		if(!can_open())
			to_chat(user, "<span class='notice'>It won't budge!</span>")
		else
			to_chat(user, "<span class='notice'>The locker is locked!</span>")
		if(world.time > lastbang+5)
			lastbang = world.time
			for(var/mob/M in hearers(src, null))
				to_chat(M, "<FONT size=[max(0, 5 - get_dist(src, M))]>BANG, bang!</FONT>")
	return

/obj/structure/closet/secure_closet/attack_hand(mob/user)
	if(!Adjacent(user))
		return
	add_fingerprint(user)

	if(!toggle() && locked)
		return togglelock(user)

/obj/structure/closet/secure_closet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/closet/secure_closet/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(!Adjacent(usr) || usr.loc == src)
		return

	if(src.broken)
		return

	if (ishuman(usr))
		if (!opened)
			togglelock(usr)
			return 1
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/secure_closet/AltClick()
	if(verb_togglelock())
		return
	return ..()

/obj/structure/closet/secure_closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.len = 0
	kill_moody_light()
	if(!opened)
		if(!broken)
			var/image/I = image(icon = icon, icon_state = moody_light_state)
			I.color = locked ? "#f00" : "#0f0"
			I.pixel_x = overlay_x
			I.pixel_y = overlay_y
			overlays += I
			update_moody_light(offX = overlay_x, offY = overlay_y)
		if(welded)
			overlays += image(icon = icon, icon_state = "welded")
	icon_state = opened && icon_open_override ? icon_open_override : "[initial(icon_state)][opened ? "open" : ""]"