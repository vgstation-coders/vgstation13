//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/item/weapon/circuitboard/airlock
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = W_CLASS_SMALL //It should be tiny! -Agouri
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON

	req_access = list(access_engine_equip)

	var/list/conf_access = null
	var/one_access = 0 //if set to 1, door would receive req_one_access instead of req_access
	var/last_configurator = null
	var/locked = 1
	var/installed = 0

	// Allow dicking with it while it's on the floor.
/obj/item/weapon/circuitboard/airlock/attack_robot(mob/user as mob)
	if(isMoMMI(user))
		return ..()
	attack_self(user)
	return 1

/obj/item/weapon/circuitboard/airlock/attackby(obj/item/W as obj, mob/user as mob)
	if(issolder(W))
		var/obj/item/weapon/solder/S = W
		if(icon_state == "door_electronics_smoked")
			if(!S.remove_fuel(4,user))
				return
			S.playtoolsound(loc, 100)
			if(do_after(user, src,40))
				S.playtoolsound(loc, 100)
				icon_state = "door_electronics"
				to_chat(user, "<span class='notice'>You repair the blown fuses on the circuitboard.</span>")

/obj/item/weapon/circuitboard/airlock/attack_self(mob/user as mob)
	if (!ishigherbeing(user) && !isrobot(user))
		return ..()

	// Can't manipulate it when broken (e.g. emagged)
	if (icon_state == "door_electronics_smoked")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			return

	interact(user)

/obj/item/weapon/circuitboard/airlock/interact(mob/user as mob)
	var/t1 = text("<B>Access control</B><br>\n")

	if (last_configurator)
		t1 += "Operator: [last_configurator]<br>"

	if (locked)
		if(isrobot(user))
			t1 += "<a href='?src=\ref[src];login=1'>Log In</a><hr>"
		else
			t1 += "<a href='?src=\ref[src];login=1'>Set access</a><hr>"
	else
		t1 += "<a href='?src=\ref[src];logout=1'>Finish</a><hr>"

		t1 += "Access requirement is set to "
		t1 += one_access ? "<a style='color: green' href='?src=\ref[src];one_access=1'>ONE</a><hr>" : "<a style='color: red' href='?src=\ref[src];one_access=1'>ALL</a><hr>"

		t1 += conf_access == null ? "<font color=red>All</font><br>" : "<a href='?src=\ref[src];access=all'>All</a><br>"

		t1 += "<br>"

		var/list/accesses = get_all_accesses()
		for (var/acc in accesses)
			var/aname = get_access_desc(acc)

			if (!conf_access || !conf_access.len || !(acc in conf_access))
				t1 += "<a href='?src=\ref[src];access=[acc]'>[aname]</a><br>"
			else if(one_access)
				t1 += "<a style='color: green' href='?src=\ref[src];access=[acc]'>[aname]</a><br>"
			else
				t1 += "<a style='color: red' href='?src=\ref[src];access=[acc]'>[aname]</a><br>"

	t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

	user << browse(t1, "window=airlock_electronics")
	onclose(user, "airlock")

/obj/item/weapon/circuitboard/airlock/Topic(href, href_list)
	if(..())
		return 1 //Its not as though this does ANYTHING
	if(!Adjacent(usr) || usr.incapacitated() || (!ishigherbeing(usr) && !isrobot(usr)) || icon_state == "door_electronics_smoked" || installed)
		return
	if(href_list["close"])
		usr << browse(null, "window=airlock")
		return

	if(href_list["login"])
		if(ishuman(usr))
			var/obj/item/weapon/card/id/I = usr.get_id_card()
			if(istype(I) && src.check_access(I))
				src.locked = 0
				src.last_configurator = I.registered_name
		if(isrobot(usr))
			src.locked = 0
			src.last_configurator = usr.name

	if(locked)
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return

	if(href_list["logout"])
		locked = 1

	if(href_list["one_access"])
		one_access = !one_access

	if(href_list["access"])
		toggle_access(href_list["access"])

	interact(usr)

/obj/item/weapon/circuitboard/airlock/proc/toggle_access(var/acc)
	if (acc == "all")
		conf_access = null
	else
		var/req = text2num(acc)

		if (conf_access == null)
			conf_access = list()

		if (!(req in conf_access))
			conf_access += req
		else
			conf_access -= req
			if (!conf_access.len)
				conf_access = null
