/obj/machinery/chem_master/snackbar_machine
	name = "\improper SnackBar Machine"
	desc = "An explosion of flavour in every bite"
	condi = 1
	icon_state = "snackbar"
	chem_board = /obj/item/weapon/circuitboard/snackbar_machine
	windowtype = "snackbar_machine"

	var/max_snack_size = 10

/obj/machinery/chem_master/snackbar_machine/Topic(href, href_list)

	if(href_list["close"])
		usr << browse(null, "window=snackbar_machine")
		usr.unset_machine()
		return 1

	if(href_list["createpill"] || href_list["createpill_multiple"] || href_list["ejectp"] || href_list["change_pill"])
		return

	if(..())
		return 1

	usr.set_machine(src)

	if(href_list["createsnack"])
		var/obj/item/weapon/reagent_containers/food/snacks/snackbar/SB = new/obj/item/weapon/reagent_containers/food/snacks/snackbar(src.loc)
		buffer.trans_to(SB, 10)
		src.updateUsrDialog()
		return 1

	return

/obj/machinery/chem_master/snackbar_machine/attack_hand(mob/user as mob)

	if(..())
		return 1

	user.set_machine(src)

	var/dat = list()
	// Beaker
	if(beaker)
		var/datum/reagents/R = beaker.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker.</A><BR>"

		if(R.total_volume)
			// Beaker buttons
			dat += {"
				<table>
					<td class="column1">
						Add to Snack Buffer: <A href='?src=\ref[src];beaker_addall=1;amount=[R.total_volume]'>All</A>
					</td>
				</table>
			"}

			// Beaker reagents
			dat += "<table>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += "<tr>"
				dat += {"
					<td class="column1">
						[G.name] , [round(G.volume, 0.01)] Units - <A href='?src=\ref[src];analyze=\ref[G]'>(?)</A>
					</td>
					<td class="column2">
						<A href='?src=\ref[src];beaker_add=[G.id];amount=1'>1u</A>
						<A href='?src=\ref[src];beaker_add=[G.id];amount=5'>5u</A>
						<A href='?src=\ref[src];beaker_add=[G.id];amount=10'>10u</A>
						<A href='?src=\ref[src];beaker_addcustom=[G.id]'>Custom</A>
						<A href='?src=\ref[src];beaker_add=[G.id];amount=[G.volume]'>All</A>
					</td>
				"}
				dat += "</tr>"
			dat += "</table>"
		else
			dat += "Beaker is empty."
	else
		dat += "No beaker inserted."

	// Buffer - Like normal chem masters, except retains without a beaker.
	// Makes pills. Can flush or move to internal storage
	dat += "<HR>"
	dat += "<b>&ltInternal Snack Buffer&gt</b> <BR>"

	dat += "Mode: <A href='?src=\ref[src];togglebuffer=1'>[buffer_mode]</A> <BR>"

	if(buffer.total_volume)
		dat += "<table>"
		for(var/datum/reagent/G in buffer.reagent_list)
			dat += "<tr>"
			dat += {"
					<td class="column1">
						[G.name] , [round(G.volume, 0.01)] Units - <A href='?src=\ref[src];analyze=\ref[G]'>(?)</A>
					</td>
					<td class="column2">
						<A href='?src=\ref[src];buffer_add=[G.id];amount=1'>1u</A>
						<A href='?src=\ref[src];buffer_add=[G.id];amount=5'>5u</A>
						<A href='?src=\ref[src];buffer_add=[G.id];amount=10'>10u</A>
						<A href='?src=\ref[src];buffer_addcustom=[G.id]'>Custom</A>
						<A href='?src=\ref[src];buffer_add=[G.id];amount=[G.volume]'>All</A>
					</td>
					"}
			dat += "</tr>"
		dat += "</table>"
	else
		dat += "No snacks in buffer."

	// Snack creation
	dat += "<BR>"
	dat += "<A href='?src=\ref[src];createsnack=1'>Create delicious snack (10 units max)</A><BR>"

	// Make the window
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "[windowtype]", "[name]", 475, 500, src)
	popup.add_stylesheet("chemmaster", 'html/browser/chem_master.css')
	popup.set_content(dat)
	popup.open()
	onclose(user, "[windowtype]")
	return
