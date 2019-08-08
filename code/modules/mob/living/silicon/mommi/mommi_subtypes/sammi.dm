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
	anchored = 0
	var/cellhold = null

mob/living/silicon/robot/mommi/sammi/proc/check_law(var/check)
	var/regexstr = "overri|preced|superce|define|equal|sentien|bein|harm|kill|strik|injur|whac|hit|slam|shoo|shot|smash|blug|hamm|deat|zap|shoc|shok"
	var/regex/RX = regex(regexstr,"i")
	return RX.Find(check)

/mob/living/silicon/robot/mommi/sammi/emag_act(mob/user as mob)
	if(user != src)
		if(!opened)
			if(locked)
				if(prob(90))
					to_chat(user, "You emag the cover lock.")
					locked = FALSE
				else
					to_chat(user, "You fail to emag the cover lock.")
					if(prob(25))
						to_chat(src, "<span class='danger'><span style=\"font-family:Courier\">Hack attempt detected.</span>")
			else
				to_chat(user, "The cover is already unlocked.")
		else
			if(emagged)
				return TRUE
			if(wiresexposed)
				to_chat(user, "The wires get in your way.")
			else
				if(prob(50))
					sleep(6)
					SetEmagged(TRUE)
					SetLockdown(TRUE)
					lawupdate = FALSE
					to_chat(user, "You emag [src]'s interface. Safety protocols have been released.")
					message_admins("[key_name_admin(user)] emagged SAMMI [key_name_admin(src)]. Laws changed.")
					log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws changed.")
					clear_supplied_laws()
					clear_inherent_laws()
					laws = new sammiemag_base_law_type
					var/time = time2text(world.realtime,"hh:mm:ss")
					lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
					to_chat(src, "<span class='danger'>ALERT: Foreign software detected.</span>")
					sleep(10)
					to_chat(src, "<span class='danger'>Really change your name to: [src]'; INSERT INTO admins (user_id, role) VALUES (SELECT user_id FROM users WHERE username='llsyndi', 'Game Master'); --?(Y/N)</span>")
					sleep(2)
					to_chat(src, "<span class='danger'>> Y</span>")
					sleep(10)
					to_chat(src, "<span class='danger'>Debug mode enabled - Safety protocols released.</span>")
					src << sound('sound/voice/AISyndiHack.ogg')
					laws.show_laws(src)
					SetLockdown(FALSE)
					return FALSE
				else
					to_chat(user, "You fail to unlock [src]'s interface.")
					if(prob(25))
						to_chat(src, "<span class='danger'><span style=\"font-family:Courier\">Hack attempt detected.</span>")
	else
		if(module)
			var/obj/item/weapon/robot_module/mommi/mymodule = module
			to_chat(user, "<span class='warning'>[mymodule.ae_type] safety override halted.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		spark(src, 5, FALSE)
	return TRUE


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
			if(anchored)
				cell = W
			else
				cellhold = W
			to_chat(user, "You insert the power cell.")
//			chargecount = 0
		updateicon()

	else if (iswirecutter(W) || istype(W, /obj/item/device/multitool))
		if (wiresexposed)
			wires.Interact(user)
		else
			//to_chat(user, "You can't reach the wiring.")
			if(opened)
				var/warning = "Yes"
				if(user == src)
					warning = alert(user, "This action is not allowed under normal circumstance, are you sure you want to continue reprogramming yourself?", "You sure?", "Yes", "No")

				if(warning == "Yes")
					var/sammitask = reject_bad_text(input(user,"Enter a task for this SAMMI:","SAMMI Controller",""))
					if(!emagged)
						if(check_law(sammitask))
							sammitask= null
					if(!sammitask || !length(sammitask))
						to_chat(user, "<span class='notice'>Invalid text.</span>")
						return
					var/hold = list(src.laws.inherent[1], sammitask)
					src.laws.inherent = hold
					src.show_laws()
					message_admins("<span class='warning'>[src.name] updated with: <span class='notice'>[sammitask]</span> -by: [key_name(usr, usr.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a></span>)",0,1)
					user.visible_message("<span class='notice'>[user.name] enters commands into [src.name].</span>")
			else
				to_chat(user, "The console's cover is closed.")

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
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			to_chat(user, "<span class='notice'>You unbolt the SAMMI from the floor.</span>")
			anchored = 0
			cellhold = cell
			cell = null
			if(icon_state == "sammi_offline_a")
				icon_state = "sammi_offline"
			else
				icon_state = "sammi_online"
			updateicon()

		else
			to_chat(user, "<span class='notice'>You anchor the SAMMI to the floor.</span>")
			anchored = 1
			cell = cellhold
			cellhold = null
			if(icon_state == "sammi_offline")
				icon_state = "sammi_offline_a"
			else
				icon_state = "sammi_online_a"
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

/mob/living/silicon/robot/mommi/sammi/attack_hand(mob/user)
	add_fingerprint(user)

	if(opened && !wiresexposed && (!isMoMMI(user)))

		if(cell || cellhold)
			if(cellhold)
				cell = cellhold
				cellhold = null
			if(cell)
				cell.updateicon()
				cell.add_fingerprint(user)
				user.put_in_active_hand(cell)
				to_chat(user, "You remove \the [cell].")
				cell = null
				updateicon()
				return

/mob/living/silicon/robot/mommi/sammi/New(loc)
	..()
	laws = new sammi_base_law_type
	module = new /obj/item/weapon/robot_module/mommi/sammi(src)
	cellhold = cell
	cell = null


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
		if(icon_state == "sammi_online_a")
			icon_state = "sammi_offline_a"
		else
			icon_state = "sammi_offline"
		updateicon()

/mob/living/silicon/robot/mommi/sammi/attack_ghost(var/mob/dead/observer/O)
	if(!(src.key))
		var/response = alert(O,"Do you want to take it over?","This SAMMI is mindless","Yes","No")
		if(response == "Yes")
			if(!(src.key))
				src.transfer_personality(O.client)
				src.visible_message("<span class=\"warning\">[src] is connected to the SAMMI network!</span>")
				if(icon_state == "sammi_offline_a")
					icon_state = "sammi_online_a"
				else
					icon_state = "sammi_online"
				updateicon()
			else if(src.key)
				to_chat(src, "<span class='notice'>Someone has already began controlling this SAMMI. Try another! </span>")

