var/list/blueprint_racks = list()

/obj/structure/blueprintrack
	name = "blueprint rack"
	icon = 'icons/obj/library.dmi'
	icon_state = "blueprintrack0"
	anchored = TRUE
	density = TRUE
	opacity = FALSE
	req_access = list(access_library, access_mechanic)
	var/locked = TRUE
	var/emagged = FALSE

/obj/structure/blueprintrack/New()
	..()
	update_icon()
	blueprint_racks += src

/obj/structure/blueprintrack/Destroy()
	blueprint_racks -= src
	..()

/obj/structure/blueprintrack/update_icon()
	icon_state = "blueprintrack[contents.len]"
	if(locked)
		var/image/seal = image(icon, src, "rack_seal", ABOVE_OBJ_LAYER)
		seal.plane = relative_plane(OBJ_PLANE)
		overlays += seal

/obj/structure/blueprintrack/attackby(obj/item/W, mob/user)
	if(emagged && issolder(W))
		var/obj/item/tool/solder/S = W
		if(!S.remove_fuel(4,user))
			return
		S.playtoolsound(loc, 100)
		if(do_after(user, src,4 SECONDS * S.work_speed))
			S.playtoolsound(loc, 100)
			emagged = FALSE
			to_chat(user, "<span class='notice'>You repair the electronics inside the locking mechanism!</span>")
		return

	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "<span class='notice'>The lock seems broken.</span>")
		else
			if(src.allowed(user))
				locked = !locked
				to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] \the [src].</span>")
				update_icon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	if(isEmag(W) && !emagged)
		emagged = TRUE
		locked = FALSE
		visible_message("<span class='danger'>The rack seal clunks loudly as it drops freely.</span>")
		return

	if(istype(W,/obj/item/research_blueprint))
		if(contents.len >= 16)
			to_chat(user, "<span class='warning'>\The [src] is full.</span>")
			return
		else
			user.drop_item(W, src)
			update_icon()

	..()

/obj/structure/blueprintrack/attack_hand(var/mob/user as mob)
	if(!contents.len)
		return
	var/obj/item/choice = input("Retrieve which blueprint?") as null|obj in contents
	if(choice)
		if(user.incapacitated() || user.lying || !Adjacent(user))
			return
		user.put_in_hands(choice)
		update_icon()