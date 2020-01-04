
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "Ore Box"
	desc = "A heavy box used for storing ore."
	density = 1
	var/list/ores_by_name = list()

/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	// this makes it possible for supply cyborgs to interact with the box
	if (istype(W, /obj/item/device/mining_scanner))
		attack_hand(user)
		return
	if (istype(W, /obj/item/stack/ore))
		var/obj/item/stack/ore/O = W
		if(O.materials)
			user.u_equip(W,FALSE) //remove from slot but do not treat as dropped
			ores_by_name[O.name] += 1
			O.forceMove(src)
	if (istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		S.hide_from(usr)
		for(var/obj/item/stack/ore/O in S.contents)
			if(O.materials)
				ores_by_name[O.name] += 1
				S.remove_from_storage(O,src)
		to_chat(user, "<span class='notice'>You empty \the [W] into the box.</span>")
	return

/obj/structure/ore_box/attack_hand(mob/user as mob)
	var/dat = "<b>The contents of the ore box reveal...</b><ul>"

	for(var/element in ores_by_name)
		dat += "<li><b>[element]:</b> [ores_by_name[element]]</li>"

	dat += "</ul><A href='?src=\ref[src];removeall=1'>Empty box</A>"
	user << browse("[dat]", "window=orebox")
	return

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["removeall"])
		dump_everything()
		to_chat(usr, "<span class='notice'>You empty the box.</span>")
	src.updateUsrDialog()
	return

/obj/structure/ore_box/proc/dump_everything()
	for(var/obj/item/stack/ore/O in contents)
		O.forceMove(get_turf(src))
	ores_by_name.Cut()

/obj/structure/ore_box/ex_act(severity)
	switch(severity)
		if(1.0)
			dump_everything()
			qdel(src)
		if(2.0)
			if (prob(50))
				dump_everything()
				qdel(src)
