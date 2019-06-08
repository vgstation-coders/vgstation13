
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "Ore Box"
	desc = "A heavy box used for storing ore."
	density = 1
	starting_materials = list()

/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	// this makes it possible for supply cyborgs to interact with the box
	if (istype(W, /obj/item/device/mining_scanner))
		attack_hand(user)
		return
	if (istype(W, /obj/item/stack/ore))
		var/obj/item/stack/ore/O = W
		if(O.material)
			materials.addAmount(O.material, O.amount)
			user.u_equip(W,0)
			returnToPool(W)
	if (istype(W, /obj/item/weapon/storage))
		var/turf/T=get_turf(src)
		var/obj/item/weapon/storage/S = W
		S.hide_from(usr)
		for(var/obj/item/stack/ore/O in S.contents)
			if(O.material)
				S.remove_from_storage(O,T) //This will remove the item.
				materials.addAmount(O.material, O.amount)
				returnToPool(O)
		to_chat(user, "<span class='notice'>You empty \the [W] into the box.</span>")
	return

/obj/structure/ore_box/attack_hand(mob/user as mob)
	var/dat = "<b>The contents of the ore box reveal...</b><ul>"
	for(var/ore_id in materials.storage)
		var/datum/material/mat = materials.getMaterial(ore_id)
		if(materials.storage[ore_id] > 0)
			dat += "<li><b>[mat.name]:</b> [materials.storage[ore_id]]</li>"

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
	for(var/ore_id in materials.storage)
		var/datum/material/mat = materials.getMaterial(ore_id)
		if(mat.oretype && materials.storage[ore_id])
			drop_stack(mat.oretype, get_turf(src), materials.storage[ore_id])
			materials.removeAmount(ore_id, materials.storage[ore_id])

/obj/structure/ore_box/ex_act(severity)
	switch(severity)
		if(1.0)
			dump_everything()
			qdel(src)
		if(2.0)
			if (prob(50))
				dump_everything()
				qdel(src)
