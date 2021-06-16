
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "Ore Box"
	desc = "A heavy box used for storing ore."
	density = 1
	starting_materials = list()
	var/list/stored_ores = list()

/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	// this makes it possible for supply cyborgs to interact with the box
	if (istype(W, /obj/item/device/mining_scanner))
		attack_hand(user)
		return
	if (istype(W, /obj/item/stack/ore))
		var/obj/item/stack/ore/O = W
		if(try_add_ore(O))
			user.u_equip(W,0)
			qdel(W)

	if (istype(W, /obj/item/weapon/storage))
		var/turf/T=get_turf(src)
		var/obj/item/weapon/storage/S = W
		S.hide_from(usr)
		for(var/obj/item/stack/ore/O in S.contents)
			if(try_add_ore(O))
				S.remove_from_storage(O,T) //This will remove the item.
				qdel(O)
		to_chat(user, "<span class='notice'>You empty \the [W] into the box.</span>")
	return

/obj/structure/ore_box/attack_hand(mob/user as mob)
	var/dat = "<b>The contents of the ore box reveal...</b><ul>"
	for(var/ore_id in stored_ores)
		var/amount = stored_ores[ore_id]
		var/obj/item/stack/ore/cast_type = ore_id
		if(amount > 0)
			dat += "<li><b>[initial(cast_type.name)]:</b> [amount]</li>"

	dat += "</ul><A href='?src=\ref[src];removeall=1'>Empty box</A>"
	user << browse("[dat]", "window=orebox")
	return

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	var/mob/user = usr
	if (!Adjacent(user) || user.incapacitated())
		usr << browse(null, "window=orebox")
		return
	user.set_machine(src)
	add_fingerprint(user)
	if(href_list["removeall"])
		dump_everything()
		to_chat(user, "<span class='notice'>You empty the box.</span>")
	updateUsrDialog()
	return

/obj/structure/ore_box/proc/dump_everything()
	for(var/ore_id in stored_ores)
		var/amount = stored_ores[ore_id]
		if(amount > 0)
			drop_stack(ore_id, get_turf(src), amount)

	stored_ores.Cut()

/obj/structure/ore_box/ex_act(severity)
	switch(severity)
		if(1.0)
			dump_everything()
			qdel(src)
		if(2.0)
			if (prob(50))
				dump_everything()
				qdel(src)

/obj/structure/ore_box/proc/try_add_ore(var/obj/item/stack/ore/O)
	if (!O.can_orebox)
		return FALSE

	stored_ores[O.type] += O.amount
	return TRUE
