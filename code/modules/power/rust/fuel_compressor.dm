var/const/max_assembly_amount = 300
var/const/max_fuel_amount = 24

/obj/machinery/rust_fuel_compressor
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "fuel_compressor1"
	name = "Fuel Compressor"
	desc = "A machine that uses compressed matter units to form fuel assemblies for the R-UST fuel injector."
	var/list/new_assembly_quantities = list("Deuterium" = 150,"Tritium" = 150,"Rodinium-6" = 0,"Stravium-7" = 0, "Pergium" = 0, "Dilithium" = 0)
	var/compressed_matter = 0
	anchored = 1
	machine_flags = EMAGGABLE
	var/locked = 0
	var/construct_progress = 0 // 3 is fully built

/obj/machinery/rust_fuel_compressor/examine(mob/user)
	..()
	if(stat & BROKEN)
		to_chat(user, "Looks broken.")
		return
	switch(construct_progress)
		if (3)
			to_chat(user, "The cover is closed.")
		if (2)
			to_chat(user, "The cover is open and the wiring is exposed.")
		if (1)
			to_chat(user, "The cover is open and you can see unwired electronics inside.")
		else
			to_chat(user, "The cover is open and shows an empty slot for a circuit board.")


/obj/machinery/rust_fuel_compressor/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER) || construct_progress < 3)
		return
	interact(user)

/obj/machinery/rust_fuel_compressor/attackby(obj/item/stack/S as obj, mob/user as mob)
	if (istype(S, /obj/item/stack/rcd_ammo))
		if(max_fuel_amount == compressed_matter)
			to_chat(usr, "<span class='warning'>[bicon(src)] [src] flashes red: \'Compressed matter storage is at maximum capacity.\'</span>")
			return
		var/to_add = min(max_fuel_amount - compressed_matter, S.amount)
		compressed_matter += to_add
		S.use(to_add)
		to_chat(user, "You add [to_add == 1 ? "a cartridge" : "some cartridges"] of compressed matter to the compressor.")
		return
	..()

/obj/machinery/rust_fuel_compressor/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (FORCEDISABLE|BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=fuelcomp")
			return


	var/t = {"<B>Reactor Fuel Rod Compressor / Assembler</B><BR>
<A href='?src=\ref[src];close=1'>Close</A><BR>"}
	if(locked)
		t += "Swipe your ID to unlock this console."
	else

		t += {"Compressed matter cartridges in storage: [compressed_matter] <A href='?src=\ref[src];eject_matter=1'>\[Eject all\]</a><br>
			<A href='?src=\ref[src];activate=1'><b>Activate Fuel Synthesis</b></A><BR> (fuel assemblies require exactly [max_assembly_amount] rods in total).<br>
			<hr>
			- New fuel assembly constituents:- <br>"}
		for(var/reagent in new_assembly_quantities)
			t += "	[reagent] rods: [new_assembly_quantities[reagent]] \[<A href='?src=\ref[src];change_reagent=[reagent]'>Modify</A>\]<br>"

	t += {"<hr>
		<A href='?src=\ref[src];close=1'>Close</A><BR>"}
	user << browse(HTML_SKELETON(t), "window=fuelcomp;size=500x300")
	user.set_machine(src)

	//var/locked
	//var/coverlocked

/obj/machinery/rust_fuel_compressor/Topic(href, href_list)
	if(..())
		return 1
	if( href_list["close"] )
		usr << browse(null, "window=fuelcomp")
		usr.machine = null

	if( href_list["eject_matter"] )
		var/ejected = 0
		while(compressed_matter > 0)
			var/obj/item/stack/rcd_ammo/ejectedmatter = new /obj/item/stack/rcd_ammo(get_step(get_turf(src), src.dir))
			if(compressed_matter >= ejectedmatter.max_amount)
				ejectedmatter.amount = ejectedmatter.max_amount
				compressed_matter -= ejectedmatter.max_amount
				ejected = 1
			else
				ejectedmatter.amount = compressed_matter
				compressed_matter = 0
				ejected = 1
		if(ejected)
			to_chat(usr, "<span class='notice'>[bicon(src)] [src] ejects some compressed matter units.</span>")
		else
			to_chat(usr, "<span class='warning'>[bicon(src)] there are no more compressed matter units in [src].</span>")
	if( href_list["activate"] )
		if(compressed_matter < 1)
			to_chat(usr, "<span class='warning'>[bicon(src)] [src] flashes red: \'Insufficient matter. Add more matter and try again.\'</span>")
		else
			var/obj/item/weapon/fuel_assembly/F = new(src)
			var/rodcount = 0
			for(var/reagent in new_assembly_quantities)
				if(new_assembly_quantities[reagent] == 0) continue
				rodcount += new_assembly_quantities[reagent]
				F.rod_current_quantities[reagent] = new_assembly_quantities[reagent]
				F.rod_starting_quantities[reagent] = new_assembly_quantities[reagent]
			if(rodcount != 300)
				qdel(F)
				to_chat(usr, "<span class='warning'>[bicon(src)] [src] flashes red: \'Incomplete assembly. Ensure there are 300 rods total in the assembly.\'</span>")
			else
				F.forceMove(src.loc)
				F.percent_depleted = 0
				compressed_matter--
				visible_message("<span class='notice'>[bicon(src)] [src] compresses a fuel rod assembly and ejects it to the floor.</span>")

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
