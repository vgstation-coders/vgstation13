var/const/max_assembly_amount = 300

/obj/machinery/rust_fuel_compressor
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "fuel_compressor1"
	name = "Fuel Compressor"
	var/list/new_assembly_quantities = list("Deuterium" = 150,"Tritium" = 150,"Rodinium-6" = 0,"Stravium-7" = 0, "Pergium" = 0, "Dilithium" = 0)
	var/compressed_matter = 0
	anchored = 1
	layer = 2.9

	var/opened = 1 //0=closed, 1=opened
	var/locked = 0
	var/has_electronics = 0 // 0 - none, bit 1 - circuitboard, bit 2 - wires

/obj/machinery/rust_fuel_compressor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/rust_fuel_compressor/attack_hand(mob/user)
	add_fingerprint(user)
	/*if(stat & (BROKEN|NOPOWER))
		return*/
	interact(user)

/obj/machinery/rust_fuel_compressor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/rcd_ammo))
		compressed_matter += 10
		del(W)
		return
	..()

/obj/machinery/rust_fuel_compressor/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=fuelcomp")
			return


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\fuel_compressor.dm:39: var/t = "<B>Reactor Fuel Rod Compressor / Assembler</B><BR>"
	var/t = {"<B>Reactor Fuel Rod Compressor / Assembler</B><BR>
<A href='?src=\ref[src];close=1'>Close</A><BR>"}
	// END AUTOFIX
	if(locked)
		t += "Swipe your ID to unlock this console."
	else

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\fuel_compressor.dm:44: t += "Compressed matter in storage: [compressed_matter] <A href='?src=\ref[src];eject_matter=1'>\[Eject all\]</a><br>"
		t += {"Compressed matter in storage: [compressed_matter] <A href='?src=\ref[src];eject_matter=1'>\[Eject all\]</a><br>
			<A href='?src=\ref[src];activate=1'><b>Activate Fuel Synthesis</b></A><BR> (fuel assemblies require no more than [max_assembly_amount] rods).<br>
			<hr>
			- New fuel assembly constituents:- <br>"}
		// END AUTOFIX
		for(var/reagent in new_assembly_quantities)
			t += "	[reagent] rods: [new_assembly_quantities[reagent]] \[<A href='?src=\ref[src];change_reagent=[reagent]'>Modify</A>\]<br>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\fuel_compressor.dm:50: t += "<hr>"
	t += {"<hr>
		<A href='?src=\ref[src];close=1'>Close</A><BR>"}
	// END AUTOFIX
	user << browse(t, "window=fuelcomp;size=500x300")
	user.set_machine(src)

	//var/locked
	//var/coverlocked

/obj/machinery/rust_fuel_compressor/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=fuelcomp")
		usr.machine = null

	if( href_list["eject_matter"] )
		var/ejected = 0
		while(compressed_matter > 10)
			new /obj/item/weapon/rcd_ammo(get_step(get_turf(src), src.dir))
			compressed_matter -= 10
			ejected = 1
		if(ejected)
			usr << "<span class=\"notice\">\icon[src] [src] ejects some compressed matter units.</span>"
		else
			usr << "<span class=\"rose\">\icon[src] there are no more compressed matter units in [src].</span>"

	if( href_list["activate"] )
		//world << "<span class=\"notice\">New fuel rod assembly</span>"
		var/obj/item/weapon/fuel_assembly/F = new(src)
		var/fail = 0
		var/old_matter = compressed_matter
		for(var/reagent in new_assembly_quantities)
			var/req_matter = round(new_assembly_quantities[reagent] / 30)
			//world << "[reagent] matter: [req_matter]/[compressed_matter]"
			if(req_matter <= compressed_matter)
				F.rod_quantities[reagent] = new_assembly_quantities[reagent]
				compressed_matter -= req_matter
				if(compressed_matter < 1)
					compressed_matter = 0
			else
				/*world << "bad reagent: [reagent], [req_matter > compressed_matter ? "req_matter > compressed_matter"\
				 : (req_matter < compressed_matter ? "req_matter < compressed_matter" : "req_matter == compressed_matter")]"*/
				fail = 1
				break
			//world << "<span class=\"notice\">[reagent]: new_assembly_quantities[reagent]</span><br>"
		if(fail)
			del(F)
			compressed_matter = old_matter
			usr << "<span class=\"rose\">\icon[src] [src] flashes red: \'Out of matter.\'</span>"
		else
			F.loc = src.loc//get_step(get_turf(src), src.dir)
			F.percent_depleted = 0
			if(compressed_matter < 0.034)
				compressed_matter = 0

	if( href_list["change_reagent"] )
		var/cur_reagent = href_list["change_reagent"]
		var/avail_rods = 300
		for(var/rod in new_assembly_quantities)
			avail_rods -= new_assembly_quantities[rod]
		avail_rods += new_assembly_quantities[cur_reagent]
		avail_rods = max(avail_rods, 0)

		var/new_amount = min(input("Enter new [cur_reagent] rod amount (max [avail_rods])", "Fuel Assembly Rod Composition ([cur_reagent])") as num, avail_rods)
		new_assembly_quantities[cur_reagent] = new_amount

	updateDialog()
