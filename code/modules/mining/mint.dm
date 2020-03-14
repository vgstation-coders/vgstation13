/**********************Mint**************************/

/obj/machinery/mineral/mint
	name = "coin press"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "coinpress0"
	density = 1
	anchored = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	var/atom/movable/mover //see ore processing_unit, it's for input/output
	starting_materials = list() //makes the new empty datum
	var/coins_per_sheet = 5 //Related to part quality
	var/newCoins = 0   //how many coins the machine made last run
	var/processing = 0
	var/chosen = null //which material will be used to make coins
	var/coinsToProduce = 10
	var/in_dir = WEST // Sheets go in
	var/out_dir = EAST //Coins come out.

/obj/machinery/mineral/mint/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/coin_press,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser
	)
	RefreshParts()

/obj/machinery/mineral/mint/process()
	if(stat & (NOPOWER|BROKEN)) //It still moves sheets when unbolted otherwise.
		return 0
	var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	if(!in_T.Cross(mover, in_T) || !in_T.Enter(mover) || !out_T.Cross(mover, out_T) || !out_T.Enter(mover))
		return

	for(var/atom/movable/A in in_T)
		if(A.anchored)
			continue

		if(!istype(A, /obj/item/stack/sheet))//Sheets only
			A.forceMove(out_T)
			continue

		var/obj/item/stack/sheet/O = A

		for(var/sheet_id in materials.storage)
			var/datum/material/mat = materials.getMaterial(sheet_id)
			if (mat.cointype && istype(O,mat.sheettype))
				materials.addAmount(sheet_id, O.amount)
				src.updateUsrDialog()
				qdel(O)
				break

/obj/machinery/mineral/mint/RefreshParts()
	var/i = 0
	for(var/obj/item/weapon/stock_parts/manipulator/A in component_parts)
		i += A.rating
	coins_per_sheet = initial(coins_per_sheet) * (i / 2) //Better coin ratio, it's something.

/obj/machinery/mineral/mint/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (NOPOWER | BROKEN))
		if(user.machine == src)
			user.unset_machine(src)
		return
	user.set_machine(src)
	var/dat = list()
	dat += "<table><tr><td colspan='3'; align='center'><b>Sheets</b></td></tr><tr>"
	var/nloaded=0
	for(var/ore_id in materials.storage)
		var/datum/material/ore_info = materials.getMaterial(ore_id)
		if(materials.storage[ore_id] && ore_info.cointype)
			if (chosen == null)
				chosen = ore_id //Auto select the first sheet
			dat += "<td align='right'>"
			if (chosen == ore_id)
				dat += "[ore_info.processed_name]</td>"
			else
				dat += "<a href='?src=\ref[src];choose=[ore_id]'>[ore_info.processed_name]</a></td>"
			dat += "<td>[materials.storage[ore_id]]</td>"
			dat += "<td><a href='?src=\ref[src];eject=[ore_id]'>Eject</a></td></tr>"
			nloaded++
		else
			if(chosen == ore_id)
				chosen = null
	if(nloaded)
		dat += "</table>"
	else
		dat+="<tr><td colspan='3'><em>No Sheets Loaded</em></td></tr></table>"
	dat += "<p>The press will produce <b>[coinsToProduce]</b> coins at a rate of <b>[coins_per_sheet]</b> coins per sheet.</p>"
	dat += "<p>\["
	dat += "<a href='?src=\ref[src];chooseAmt=-10'>-10</a>"
	dat += "<a href='?src=\ref[src];chooseAmt=-5'>-5</a>"
			//"<a href='?src=\ref[src];chooseAmt=-1'>-1</a>"
			//"<a href='?src=\ref[src];chooseAmt=1'>+1</a>"
	dat += "<a href='?src=\ref[src];chooseAmt=5'>+5</a>"
	dat += "<a href='?src=\ref[src];chooseAmt=10'>+10</a>"

	dat += {"\]</p>
		<p>In total, <font color='green'><b>[newCoins]</b></font> coins have been minted.</p>
		<p><b><A href="?src=\ref[src];makeCoins=[1]">Make Coins</A></b></p>"}
	dat += "<table><tr><td align='right'><b>Input:</b></td><td><a href='?src=\ref[src];changedir=1'>[capitalize(dir2text(in_dir))]</a></td></tr><tr><td><b>Output:</b></td><td><a href='?src=\ref[src];changedir=2'>[capitalize(dir2text(out_dir))]</a></td></tr></table>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "mint", "Coin Press", 420, 410, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/mint/proc/Change_Dir(var/dir)
	var/changingdir = dir //See ore processing_unit for original comments
	changingdir = Clamp(changingdir, 1, 2)

	var/newdir = input("Select the new direction", name, "North") as null|anything in list("North", "South", "East", "West")
	if(!newdir)
		return 1
	newdir = text2dir(newdir)

	var/list/dirlist = list(in_dir, out_dir)
	var/olddir = dirlist[changingdir]
	dirlist[changingdir] = -1

	var/conflictingdir = dirlist.Find(newdir)
	if(conflictingdir)
		dirlist[conflictingdir] = olddir

	dirlist[changingdir] = newdir

	in_dir = dirlist[1]
	out_dir = dirlist[2]
	return 1

/obj/machinery/mineral/mint/proc/DropSheet(var/matID)
	var/datum/material/M = materials.getMaterial(matID)
	var/obj/item/stack/sheet/sh = new M.sheettype(src.loc)
	if(sh)
		var/available_num_sheets = materials.storage[matID]
		if(available_num_sheets>0)
			//available_num_sheets % sh.max_amount
			sh.amount = available_num_sheets
			materials.removeAmount(matID, sh.amount)
		else
			qdel(sh)
	return 1

/obj/machinery/mineral/mint/Topic(href, href_list)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	var/turf/out_T = get_step(src, out_dir)

	if(href_list["close"])
		usr.unset_machine(src)
		return 1

	if(processing==1)
		to_chat(usr, "<span class='notice'>The machine is processing.</span>")
		return

	if(href_list["eject"])
		var/datum/material/ma = materials.getMaterial(href_list["eject"])
		var/obj/item/stack/sheet/sh = new ma.sheettype(out_T)
		sh.amount = materials.getAmount(href_list["eject"])
		materials.removeAmount(href_list["eject"], sh.amount)
		if (chosen == href_list["eject"])
			chosen = null

	if("changedir" in href_list)
		//Change_Dir()
		var/changingdir = text2num(href_list["changedir"]) //See ore processing_unit for original comments
		changingdir = Clamp(changingdir, 1, 2)

		var/newdir = input("Select the new direction", name, "North") as null|anything in list("North", "South", "East", "West")
		if(!newdir)
			return 1
		newdir = text2dir(newdir)

		var/list/dirlist = list(in_dir, out_dir)
		var/olddir = dirlist[changingdir]
		dirlist[changingdir] = -1

		var/conflictingdir = dirlist.Find(newdir)
		if(conflictingdir)
			dirlist[conflictingdir] = olddir

		dirlist[changingdir] = newdir

		in_dir = dirlist[1]
		out_dir = dirlist[2]

	if(href_list["choose"])
		chosen = href_list["choose"]

	if(href_list["chooseAmt"])
		coinsToProduce = Clamp(coinsToProduce + text2num(href_list["chooseAmt"]), 0, 1000)

	if(href_list["makeCoins"])
		if(chosen == null)
			return
		var/temp_coins = coinsToProduce
		if (src.out_dir)
			processing = 1
			icon_state = "coinpress1"
			var/datum/material/po=materials.getMaterial(chosen)
			if(!po)
				chosen=null
				processing=0
				return
			while(materials.storage[chosen] > 0 && coinsToProduce > 0)
				var/obj/item/weapon/storage/bag/money/tempbag = locate(/obj/item/weapon/storage/bag/money,out_T)
				materials.removeAmount(chosen, 1) //We'll get that money up front don't you worry.
				for(var/i=0,i<coins_per_sheet,i++)
					var/obj/item/weapon/coin/co = new po.cointype(out_T)
					if(tempbag)
						if(tempbag.can_be_inserted(co, 1))
							tempbag.handle_item_insertion(co, 1)
					coinsToProduce--
					newCoins++
					src.updateUsrDialog()
					sleep(2)
				sleep(2)
			icon_state = "coinpress0"
			processing = 0
			coinsToProduce = temp_coins
	src.updateUsrDialog()
	return

/obj/machinery/mineral/mint/Destroy()
	qdel(mover)
	mover = null
	..()

/obj/machinery/mineral/mint/crowbarDestroy(mob/user)
	if(..() == 1)
		if(materials)
			for(var/matID in materials.storage)
				DropSheet(matID)
		return 1
	return -1