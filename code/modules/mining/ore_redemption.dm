/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/mineral/ore_redemption
	name = "ore redemption machine"
	desc = "A machine that accepts ore and gives credits, putting the materials into longterm storage."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = 1
	anchored = 1.0
	req_one_access = list(
		access_mining_station,
		access_chemistry,
		access_bar,
		access_science,
		access_ce,
		access_virology
	)
	starting_materials = list() //Makes the new datum
	allowed_types = list(/obj/item/stack/ore)
	pass_flags_self = PASSGLASS
	var/stack_amt = 50 //Amount to stack before releasing
	var/obj/item/weapon/card/id/inserted_id
	var/credits = 0

/obj/machinery/mineral/ore_redemption/attackby(var/obj/item/weapon/W, var/mob/user)
	if(istype(W,/obj/item/weapon/card/id))
		// N3X - Fixes people's IDs getting eaten when a new card is inserted
		if(istype(inserted_id))
			to_chat(user, "<span class='warning'>There already is an ID in \the [src].</span>")
			return
		var/obj/item/weapon/card/id/I = usr.get_active_hand()
		if(istype(I))
			if(usr.drop_item(I, src))
				inserted_id = I

/obj/machinery/mineral/ore_redemption/process()
	var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	if(!in_T.Enter(mover, mover.loc, TRUE) || !out_T.Enter(mover, mover.loc, TRUE))
		return

	for(var/atom/movable/A in in_T)
		if(A.anchored)
			continue

		if(!is_type_in_list(A, allowed_types))
			var/obj/structure/ore_box/B = locate() in in_T
			if(B)
				for(var/O in B.stored_ores)
					var/amount = B.stored_ores[O]
					SmeltOreType(O, amount)
					score.oremined += amount
		else
			for(var/i = 0; i < 10; i++)
				var/obj/item/stack/ore/O = locate() in in_T
				if(istype(O,/obj/item/stack/ore/slag))
					continue //Skip slag for now.
				if(O)
					SmeltMineral(O)
					score.oremined += O.amount
				else
					break

/obj/machinery/mineral/ore_redemption/proc/SmeltMineral(var/obj/item/stack/ore/O)
	if(O.materials)
		credits += O.materials.getValue()
		materials.addFrom(O.materials, TRUE)
		qdel(O)

/obj/machinery/mineral/ore_redemption/proc/SmeltOreType(var/type, var/amount)
	var/obj/item/stack/ore/O = new type
	O.max_amount = INFINITY
	O.set_amount(amount)
	SmeltMineral(O)

/obj/machinery/mineral/ore_redemption/attack_hand(user as mob)
	if(..())
		return
	interact(user)

/obj/machinery/mineral/ore_redemption/interact(mob/user)
	var/dat

	dat += text("<b>Ore Redemption Machine</b><br><br>")
	dat += text("This machine only accepts ore. Gibtonite and Slag are not accepted.<br><br>")
	dat += text("Current unclaimed credits: $[num2septext(credits)]<br>")

	if(istype(inserted_id))
		dat += "You have [inserted_id.GetBalance(format=1)] credits in your bank account. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>"
		dat += "<A href='?src=\ref[src];choice=claim'>Claim points.</A><br>"
	else
		dat += text("No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>")

	for(var/O in materials.storage)
		if(materials.storage[O] > 0)
			var/datum/material/mat = materials.getMaterial(O)
			dat += text("[capitalize(mat.processed_name)]: [materials.storage[O]/mat.cc_per_sheet] <A href='?src=\ref[src];release=[mat.id]'>Release</A><br>")

	dat += text("<br>This unit can hold stacks of [stack_amt] sheets of each mineral type.<br><br>")

	dat += text("<HR><b>Mineral Value List:</b><BR>[get_ore_values()]")

	user << browse("[dat]", "window=console_stacking_machine")
	user.set_machine(src)
	onclose(user, "console_stacking_machine")
	return

/obj/machinery/mineral/ore_redemption/proc/get_ore_values()
	var/dat = "<table border='0' width='300'>"
	for(var/mat_id in materials.storage)
		var/datum/material/mat = materials.getMaterial(mat_id)
		dat += "<tr><td>[capitalize(mat.processed_name)]</td><td>[mat.value]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/mineral/ore_redemption/Topic(href, href_list)
	if(..())
		return
	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.forceMove(loc)
				inserted_id = null
			if(href_list["choice"] == "claim")
				var/datum/money_account/acct = get_card_account(inserted_id)
				if(acct && acct.charge(-credits,null,"Claimed mining credits.",dest_name = "Ore Redemption"))
					credits = 0
					to_chat(usr, "<span class='notice'>Credits transferred.</span>")
				else
					to_chat(usr, "<span class='warning'>Failed to claim credits.</span>")
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				if(usr.drop_item(I, src))
					inserted_id = I
			else
				to_chat(usr, "<span class='warning'>No valid ID.</span>")
				return 1
	else if(href_list["release"] && istype(inserted_id))
		if(check_access(inserted_id))
			var/release=href_list["release"]
			var/datum/material/mat = materials.getMaterial(release)
			if(!mat)
				to_chat(usr, "<span class='warning'>Unable to find material [release]!</span>")
				return 1
			var/desired = input("How much?","How much [mat.processed_name] to eject?", materials.storage[release]/mat.cc_per_sheet) as num
			if(desired==0)
				return 1
			var/turf/out_T = get_step(src, out_dir)
			var/obj/item/stack/sheet/out = new mat.sheettype(out_T.loc)
			out.redeemed = 1 //Central command will not pay for this mineral stack.
			out.set_amount(clamp(round(desired), 0, min(materials.storage[release]/mat.cc_per_sheet, out.max_amount)))
			materials.removeAmount(release, out.amount * mat.cc_per_sheet)
	updateUsrDialog()
	return

/obj/machinery/mineral/ore_redemption/ex_act()
	return //So some chucklefuck doesn't ruin miners reward with an explosion

/obj/machinery/mineral/ore_redemption/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group)
		return 0
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return !opacity
	return !density
