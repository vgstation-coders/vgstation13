/obj/item/weapon/camera_assembly
	name = "\improper camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	w_class = 2
	anchored = 0

	m_amt = 700
	g_amt = 300
	w_type = RECYK_ELECTRONIC

	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/device/assembly/prox_sensor, /obj/item/stack/sheet/mineral/plasma, /obj/item/weapon/reagent_containers/food/snacks/grown/carrot)
	var/list/upgrades = list()
	var/state = 0
	var/busy = 0
	/*
				0 = Nothing done to it
				1 = Wrenched in place
				2 = Welded in place
				3 = Wires attached to it (you can now attach/dettach upgrades)
				4 = Screwdriver panel closed and is fully built (you cannot attach upgrades)
	*/

/obj/item/weapon/camera_assembly/attackby(obj/item/W as obj, mob/living/user as mob)

	switch(state)

		if(0)
			// State 0
			if(iswrench(W) && isturf(src.loc))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] starts wrenching [src] into place!</span>", "<span class='notice'>You start wrenching [src] into place.</span>", "<span class='notice'>You hear a ratchet.</span>")
				if(do_after(user,50))
					user.visible_message("<span class='warning'>[user] wrenchs [src] into place!</span>", "<span class='notice'>You wrench [src] into place.</span>")
					anchored = 1
					state = 1
					update_icon()
					auto_turn()
		if(1)
			// State 1
			if(iswelder(W))
				user.visible_message("<span class='warning'>[user] starts welding [src] into place!</span>", "<span class='notice'>You start welding [src] into place.</span>", "<span class='notice'>You hear welding.</span>")
				if(weld(W, user))
					anchored = 1
					state = 2
					user.visible_message("<span class='warning'>[user] welds [src] into place!</span>", "<span class='notice'>You weld [src] into place.</span>")

			else if(iswrench(W))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] starts unanchoring [src]!</span>", "<span class='notice'>You start unanchoring [src].</span>", "<span class='notice'>You hear a ratchet.</span>")
				if(do_after(user,50))
					user.visible_message("<span class='warning'>[user] unanchors [src]!</span>", "<span class='notice'>You unanchor [src].</span>")
					user << "You unattach the assembly from it's place."
					anchored = 0
					update_icon()
					state = 0

		if(2)
			// State 2
			if(iscoil(W))
				var/obj/item/weapon/cable_coil/C = W
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] starts wiring [src]!</span>", "<span class='notice'>You start wiring [src].</span>")
				if(do_after(user,50))
					if(C.use(2))
						user.visible_message("<span class='warning'>[user] wires up [src]!</span>", "<span class='notice'>You wire up [src].</span>")
						state = 3

			else if(iswelder(W))

				user.visible_message("<span class='warning'>[user] starts unwelding [src] from the wall!</span>", "<span class='notice'>You start unwelding [src] from the wall.</span>", "<span class='notice'>You hear welding.</span>")
				if(weld(W, user))
					user.visible_message("<span class='warning'>[user] unwelds [src] from the wall!</span>", "<span class='notice'>You unweld [src] from the wall.</span>")
					state = 1
					anchored = 1
				return


		if(3)
			// State 3
			if(isscrewdriver(W))
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] puts [src] together!</span>", "<span class='notice'>You put [src] together.</span>")

				var/input = strip_html(input(usr, "Which networks would you like to connect this camera to? Seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13"))
				if(!input)
					usr << "No input found please hang up and try your call again."
					return

				var/list/tempnetwork = text2list(input, ",")
				if(tempnetwork.len < 1)
					usr << "No network found please hang up and try your call again."
					return

				state = 4
				var/obj/machinery/camera/C = new(src.loc)
				src.loc = C
				C.assembly = src

				C.auto_turn()

				C.network = tempnetwork

				C.c_tag = "[get_area_name(src)] ([rand(1, 999)]"

				for(var/i = 5; i >= 0; i -= 1)
					var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
					if(direct != "LEAVE IT")
						C.dir = text2dir(direct)
					if(i != 0)
						var/confirm = alert(user, "Is this what you want? Chances Remaining: [i]", "Confirmation", "Yes", "No")
						if(confirm == "Yes")
							break
				return

			else if(iswirecutter(W))

				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] starts cutting out [src]'s wiring!</span>", "<span class='notice'>You start cutting out [src]'s wiring.</span>")
				if(do_after(user,50))
					new/obj/item/weapon/cable_coil(get_turf(src), 2)
					user.visible_message("<span class='warning'>[user] cuts out [src]'s wiring!</span>", "<span class='notice'>You cut out [src]'s wiring.</span>")
					state = 2

	// Upgrades!
	if(is_type_in_list(W, possible_upgrades) && !is_type_in_list(W, upgrades)) // Is a possible upgrade and isn't in the camera already.
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] attaches [W] to [src]'s inner circuits!</span>", "<span class='notice'>You attach [W] to [src]'s inner circuits.</span>")
		upgrades += W
		user.drop_item(W)
		W.loc = src

	// Taking out upgrades
	else if(iscrowbar(W) && upgrades.len)
		var/obj/U = locate(/obj) in upgrades
		if(U)
			user.visible_message("<span class='warning'>[user] unattaches an upgrade from [src]!</span>", "<span class='notice'>You unattach an upgrade from [src].</span>")
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			U.loc = get_turf(src)
			upgrades -= U

	..()

/obj/item/weapon/camera_assembly/update_icon()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/weapon/camera_assembly/attack_hand(mob/user as mob)
	if(!anchored)
		..()

/obj/item/weapon/camera_assembly/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)

	if(busy)
		return 0
	if(!WT.isOn())
		return 0
	playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, 50))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0