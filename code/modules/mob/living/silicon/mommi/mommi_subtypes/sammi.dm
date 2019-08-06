/mob/living/silicon/robot/mommi/sammi
	name = "Stationary Assembler MMI"
	real_name = "Stationary Assembler MMI"
	desc = "This versatile assembler is controlled by a transient mind-cluster network, unfortunately it is prone to connection loss"
	icon = 'icons/mob/mommi.dmi'
	icon_state = "sammi_offline"
	maxHealth = 200
	health = 200
	keeper=1 // 0 = No, 1 = Yes (Disables speech and common radio.)
	prefix = "Stationary Assembler MMI"
	canmove = 0
	//..()


/mob/living/silicon/robot/mommi/sammi/emag_act(mob/user)
	if(user == src && !emagged)//Dont shitpost inside the game, thats just going too far
		if(module)
			var/obj/item/weapon/robot_module/mommi/mymodule = module
			to_chat(user, "<span class='warning'>[mymodule.ae_type] safety override initiated.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return TRUE
	if(..())
		return TRUE
	var/hold = new sammiemag_base_law_type
	src.laws = hold
	src.show_laws()

mob/living/silicon/robot/mommi/sammi/update_canmove()
	return 0

mob/living/silicon/robot/mommi/sammi/ventcrawl()
	return 0

mob/living/silicon/robot/mommi/sammi/hide()
	return 0

/mob/living/silicon/robot/mommi/sammi/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		var/obj/item/stack/cable_coil/coil = W
		adjustFireLoss(-30)
		updatehealth()
		coil.use(1)
		src.visible_message("<span class='warning'>[user] has fixed some of the burnt wires on [src]!</span>")
		//for(var/mob/O in viewers(user, null))
		//	O.show_message(text("<span class='warning'>[user] has fixed some of the burnt wires on [src]!</span>"), 1)

	else if (iscrowbar(W))	// crowbar means open or close the cover
		if(opened)
			if(mmi && wiresexposed && wires.IsAllCut())
				//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
				to_chat(user, "You jam the crowbar into \the [src] and begin levering [mmi].")
				if (do_after(user, src,3))
					to_chat(user, "You damage some parts of the casing, but eventually manage to rip out [mmi]!")
					var/limbs = list(/obj/item/robot_parts/l_arm, /obj/item/robot_parts/r_arm)
					for(var/newlimb = 1 to rand(1, 2))
						var/limb_to_spawn = pick(limbs)
						limbs -= limb_to_spawn

						new limb_to_spawn(src.loc)
					// This doesn't work.  Don't use it.
					//src.Destroy()
					// del() because it's infrequent and mobs act weird in qdel.
					qdel(src)
					return
			else
				to_chat(user, "You close the cover.")
				opened = FALSE
				updateicon()
		else
			if(locked)
				to_chat(user, "The cover is locked and cannot be opened.")
			else
				to_chat(user, "You open the cover.")
				opened = TRUE
				updateicon()

	else if (istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			to_chat(user, "Close the wiring panel first.")
		else if(cell)
			to_chat(user, "There is a power cell already installed.")
		else
			user.drop_item(W, src)
			cell = W
			to_chat(user, "You insert the power cell.")
//			chargecount = 0
		updateicon()

	else if (iswirecutter(W) || istype(W, /obj/item/device/multitool))
		if (wiresexposed)
			wires.Interact(user)
		else
			//to_chat(user, "You can't reach the wiring.")
			if(opened){
				var/warning = "Yes"
				if(user == src){
					warning = alert(user, "This action is not allowed under normal circumstance, are you sure you want to continue reprogramming yourself?", "You sure?", "Yes", "No")
				}
				if(warning == "Yes"){
					var/sammitask = reject_bad_text(input(user,"Enter a task for this SAMMI:","SAMMI Controller",""))
					if(!sammitask || !length(sammitask))
						to_chat(user, "<span class='notice'>Invalid text.</span>")
						return
					var/hold = list(src.laws.inherent[1], sammitask)
					src.laws.inherent = hold
					src.show_laws()
					message_admins("<span class='warning'>[src.name] updated with: <span class='notice'>[sammitask]</span> -by: [key_name(usr, usr.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a></span>)",0,1)
					user.visible_message("<span class='notice'>[user.name] enters commands into [src.name].</span>")
				}
			} else {
				to_chat(user, "The console's cover is closed.")
			}

	else if(W.is_screwdriver(user) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
		updateicon()

	else if(W.is_screwdriver(user) && opened && cell)	// radio
		if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			to_chat(user, "Unable to locate a radio.")
		updateicon()

	else if(istype(W, /obj/item/device/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "Unable to locate a radio.")


	else if(istype(W, /obj/item/weapon/wrench)) // Need to make this not bludgeon them
		if(anchored)
			to_chat(user, "<span class='notice'>You unbolt the SAMMI from the floor.</span>")
			anchored = 0
			updateicon()

		else
			to_chat(user, "<span class='notice'>You anchor the SAMMI to the floor.</span>")
			anchored = 1
			updateicon()

		return 0


	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		U.attempt_action(src,user)

	else if(istype(W, /obj/item/device/camera_bug))
		help_shake_act(user)
		return 0

	else
		spark(src, 5, FALSE)
		return ..()

/mob/living/silicon/robot/mommi/sammi/New(loc)
	..()
	laws = new sammi_base_law_type
	module = new /obj/item/weapon/robot_module/mommi/sammi(src)

/mob/living/silicon/robot/mommi/sammi/proc/transfer_personality(var/client/candidate)

	if(!candidate)
		return

	src.mind = candidate.mob.mind
	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.assigned_role = "SAMMI"

/mob/living/silicon/robot/mommi/sammi/ghost()
	//if(src.subtype == "sammi")
	if(client && key)
		ghostize(1)
		src.mind.current = src.mind.original
		src.visible_message("<span class=\"warning\">[src] disconnects from the network...attempting to reconnect!</span>")
		icon_state = "sammi_offline"
		updateicon()

/mob/living/silicon/robot/mommi/sammi/attack_ghost(var/mob/dead/observer/O)
	if(!(src.key))
		var/response = alert(O,"Do you want to take it over?","This SAMMI is mindless","Yes","No")
		if(response == "Yes")
			if(!(src.key))
				src.transfer_personality(O.client)
				src.visible_message("<span class=\"warning\">[src] is connected to the SAMMI network!</span>")
				icon_state = "sammi_online"
				updateicon()
			else if(src.key)
				to_chat(src, "<span class='notice'>Someone has already began controlling this SAMMI. Try another! </span>")

