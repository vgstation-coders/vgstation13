# define ASSEMBLED 0
# define WIRED 1
# define BOARDSECURED 2
# define BOARDINSERTED 3
# define FRAMED 4
var/const/max_assembly_amount = 300

/obj/machinery/rust_fuel_compressor
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "fuel_compressor0"
	name = "Fuel Compressor"
	var/list/new_assembly_quantities = list("Deuterium" = 150,"Tritium" = 150,"Uridium-3" = 0,"Rodinium-6" = 0,"Stravium-7" = 0, "Pergium" = 0, "Dilithium" = 0, "Trilithium" = 0, )
	var/compressed_matter = 0
	anchored = 1
	layer = 2.9

	var/has_electronics = FRAMED // uses a switch statement rather than some bitflip stuff


//frame assembly

/obj/item/mounted/frame/rust_fuel_compressor
	name = "Fuel Compressor frame"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "fuel_compressor0"
	w_class = 4
	mount_reqs = list("simfloor", "nospace")
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/mounted/frame/rust_fuel_compressor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/plasteel( get_turf(src.loc), 12 )
		del(src)
		return
	..()

/obj/item/mounted/frame/rust_fuel_compressor/do_build(turf/on_wall, mob/user)
	new /obj/machinery/rust_fuel_compressor(get_turf(user), get_dir(user, on_wall), 1)
	qdel(src)

//construction steps
/obj/machinery/rust_fuel_compressor/New(turf/loc, var/ndir, var/building=0)
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir
	else
		has_electronics = 4
		icon_state = "fuel_compressor1"

	//20% easier to read than apc code
	pixel_x = (dir & 3)? 0 : (dir == 4 ? 24 : -24)
	pixel_y = (dir & 3)? (dir ==1 ? 24 : -24) : 0

/obj/machinery/rust_fuel_compressor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/rust_fuel_compressor/attack_hand(mob/user)
	add_fingerprint(user)
	/*if(stat & (BROKEN|NOPOWER))
		return*/
	if (!has_electronics)
		interact(user)

/obj/machinery/rust_fuel_compressor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	switch(has_electronics)// beginning the construction/deconstruction stuff
		if(ASSEMBLED)
			if (istype(W, /obj/item/weapon/screwdriver))//open the panel
				if (compressed_matter > 0)// if there's carts inside
					to_chat(user, "You cannot open the panel while there is compressed matter inside! It's blocking the way.")// stupid but it gets the point across
					return// can't start deconning yet
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
				src.has_electronics = WIRED
				update_icon()
				user.visible_message("<span class='warning'>[user] unsecures \the [src]'s external cover.</span>", \
				"<span class='notice'>You unsecure \the [src]'s external cover.</span>")
				return
			else if (istype(W, /obj/item/weapon/rcd_ammo))
				compressed_matter += 10
				qdel(W)//THIS WAS A DEL() BEFORE. SHAME. SHAAAAAAAAME
				interact(user)//this actually worked
				return
		if(WIRED)
			if (istype(W, /obj/item/weapon/wirecutters))//cut the wires
				playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)
				src.has_electronics = BOARDSECURED
				update_icon()
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
				A.amount = 5
				user.visible_message("<span class='warning'>[user] cuts cables from \the [src]'s internal wiring.</span>", \
				"<span class='notice'>You cut cables from \the [src]'s internal wiring.</span>")
				return
			else if(istype(W, /obj/item/weapon/screwdriver))//close the panel
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
				src.has_electronics = ASSEMBLED
				icon_state = "fuel_compressor1"
				update_icon()
				user.visible_message("<span class='warning'>[user] secures \the [src]'s external cover.</span>", \
				"<span class='notice'>You secure \the [src]'s external cover.</span>")
				return
		if(BOARDSECURED)
			if (istype(W, /obj/item/weapon/screwdriver))//unsecure the board
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
				src.has_electronics = BOARDINSERTED
				update_icon()
				user.visible_message("<span class='warning'>[user] unsecures \the [src]'s circuit board.</span>", \
				"<span class='notice'>You unsecure \the [src]'s circuit board.</span>")
				return
			else if(istype(W, /obj/item/stack/cable_coil))//add the wires
				var/obj/item/stack/cable_coil/C = W
				if(C.amount >= 5)
					playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)
					src.has_electronics = WIRED
					C.amount -= 5
					update_icon()
					user.visible_message("<span class='warning'>[user] adds wires to \the [src]'s internal circuitry.</span>", \
					"<span class='notice'>You add wires to \the [src]'s internal circuitry.</span>")
				else
					to_chat(user, "<span class='warning'>You need more wires to do this!</span>")
				return
		if(BOARDINSERTED)
			if (istype(W, /obj/item/weapon/crowbar))//remove the board
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
				src.has_electronics = FRAMED
				update_icon()
				new /obj/item/weapon/module/rust_fuel_compressor( src.loc )
				user.visible_message("<span class='warning'>[user] removes \the [src]'s circuit board.</span>", \
				"<span class='notice'>You remove \the [src]'s circuit board.</span>")
				return
			else if(istype(W, /obj/item/weapon/screwdriver))//secure the board
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
				src.has_electronics = BOARDSECURED
				update_icon()
				user.visible_message("<span class='warning'>[user] secures \the [src]'s circuit board.</span>", \
				"<span class='notice'>You secure \the [src]'s circuit board.</span>")
				return
		if(FRAMED)
			if (istype(W, /obj/item/weapon/weldingtool))//remove the assembly
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
					src.has_electronics = FRAMED
					update_icon()
					new /obj/item/mounted/frame/rust_fuel_compressor( src.loc )
					user.visible_message("<span class='warning'>[user] removes \the assembly from the wall.</span>", \
					"<span class='notice'>You remove \the assembly from the wall.</span>")
					qdel(src)
					return
			else if(istype(W, /obj/item/weapon/module/rust_fuel_compressor))//add the board
				playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)
				src.has_electronics = BOARDINSERTED
				update_icon()
				user.visible_message("<span class='warning'>[user] adds \the [src]'s circuit board.</span>", \
				"<span class='notice'>You add \the [src]'s circuit board.</span>")
				qdel(W)
				return
	..()

/obj/machinery/rust_fuel_compressor/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=fuelcomp")
			return


	var/t = {"<B>Reactor Fuel Rod Compressor / Assembler</B><BR>
<A href='?src=\ref[src];close=1'>Close</A><BR>"}
	t += {"Compressed matter in storage: [compressed_matter] <A href='?src=\ref[src];eject_matter=1'>\[Eject all\]</a> <A href='?src=\ref[src];purge_matter=1'>\[Purge matter\]</a><br>
		<A href='?src=\ref[src];activate=1'><b>Activate Fuel Synthesis</b></A><BR> (fuel assemblies require no more than [max_assembly_amount] rods).<br>
		<hr>
		- New fuel assembly constituents:- <br>"}
	for(var/reagent in new_assembly_quantities)
		t += "	[reagent] rods: [new_assembly_quantities[reagent]] \[<A href='?src=\ref[src];change_reagent=[reagent]'>Modify</A>\]<br>"

	t += {"<hr>
		<A href='?src=\ref[src];close=1'>Close</A><BR>"}
	user << browse(t, "window=fuelcomp;size=500x300")
	user.set_machine(src)

	//var/locked
	//var/coverlocked

/obj/machinery/rust_fuel_compressor/Topic(href, href_list)
	if(..()) return 1
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
			to_chat(usr, "<span class='notice'>\icon[src] [src] ejects some compressed matter units.</span>")
		else
			to_chat(usr, "<span class='warning'>\icon[src] there are no more compressed matter units in [src].</span>")

	if ( href_list["purge_matter"] )
		switch(alert("Do you want to purge the compressed matter in storage?","Please Confirm","Yes","No"))
			if("Yes")
				compressed_matter = 0
			if("No")
				return

	if( href_list["activate"] )
//		to_chat(world, "<span class='notice'>New fuel rod assembly</span>")
		var/obj/item/weapon/fuel_assembly/F = new(src)
		var/fail = 0
		var/old_matter = compressed_matter
		var/req_matter = 0
		for(var/reagent in new_assembly_quantities)
			req_matter += new_assembly_quantities[reagent]
//			to_chat(world, "[reagent] matter: [req_matter]/[compressed_matter]")
			if((req_matter / 30) <= compressed_matter)//this is terrible
				F.rod_quantities[reagent] = new_assembly_quantities[reagent]
				if(compressed_matter < 1)
					compressed_matter = 0
			else
/*
				to_chat(world, "bad reagent: [reagent], [req_matter > compressed_matter ? "req_matter > compressed_matter"\)
				 : (req_matter < compressed_matter ? "req_matter < compressed_matter" : "req_matter == compressed_matter")]"
*/
				fail = 1
				break
//			to_chat(world, "<span class='notice'>[reagent]: new_assembly_quantities[reagent]<br></span>")
		if(fail)
			qdel(F)//slay the del()
			compressed_matter = old_matter
			to_chat(usr, "<span class='warning'>\icon[src] [src] flashes red: \'Out of matter.\'</span>")
		else
			req_matter = req_matter / 30
			compressed_matter -= req_matter
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
# undef ASSEMBLED
# undef WIRED
# undef BOARDSECURED
# undef BOARDINSERTED
# undef FRAMED