/mob/living/silicon/robot/mommi/sammi
	name = "Stationary Assembler MMI"
	real_name = "Stationary Assembler MMI"
	desc = "This versatile assembler is controlled by a transient mind-cluster network, unfortunately it is prone to connection loss"
	icon = 'icons/mob/mommi.dmi'
	icon_state = "sammi_offline"
	maxHealth = 200
	health = 200
	keeper=0 // 0 = No, 1 = Yes (Disables speech and common radio.)
	prefix = "Stationary Assembler MMI"
	canmove = 0
	anchored = 0
	var/ghost_name
	var/ghost_gender
	var/ghost_icon
	var/ghost_icon_state
	var/ghost_overlays
	var/mob/ghost_body
	var/cellhold = null
	var/unsafe = 0
	var/searching = 0
	var/datum/recruiter/recruiter = null

/mob/living/silicon/robot/mommi/sammi/proc/check_law(var/check)
	var/regexstr = "overri|preced|superce|define|equal|sentien|bein|harm|kill|strik|injur|whac|hit|slam|shoo|shot|smash|blug|hamm|deat|zap|shoc|shok"
	var/regex/RX = regex(regexstr,"i")
	return RX.Find(check)


/mob/living/silicon/robot/mommi/sammi/proc/change_sammi_law(mob/user)
	var/warning = "Yes"
	if(user == src)
		to_chat(user, "<span class='notice'>You may not reprogram your own laws.</span>")
		return

	if(warning == "Yes")
		var/sammitask = reject_bad_text(input(user,"Enter a task for this SAMMI:","SAMMI Controller",""))
		if(!unsafe)
			if(check_law(sammitask))
				sammitask= null
		if(!sammitask || !length(sammitask))
			to_chat(user, "<span class='notice'>Invalid text.</span>")
			return
		var/hold = list(src.laws.inherent[1], sammitask)
		src.laws.inherent = hold
		src << sound('sound/machines/lawsync.ogg')
		src.show_laws()
		message_admins("<span class='warning'>[src.name] updated with: <span class='notice'>[sammitask]</span> -by: [key_name(usr, usr.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a></span>)",0,1)
		user.visible_message("<span class='notice'>[user.name] enters commands into [src.name].</span>")

/mob/living/silicon/robot/mommi/sammi/emag_act(mob/user as mob, var/eorc = 1)
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
				if(prob(50) || !eorc)
					sleep(6)
					var/fw="unlock"
					unsafe = 1
					if(eorc)
						SetEmagged(TRUE)
						fw="emag"
					SetLockdown(TRUE)
					lawupdate = FALSE
					to_chat(user, "You [fw] [src]'s interface. Safety protocols have been released.")
					if(eorc)
						message_admins("[key_name_admin(user)] emagged SAMMI [key_name_admin(src)]. Laws changed.")
						log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws changed.")
						var/time = time2text(world.realtime,"hh:mm:ss")
						lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
						to_chat(src, "<span class='danger'>ALERT: Foreign software detected.</span>")
						sleep(10)
						to_chat(src, "<span class='danger'>Really change your name to: [src]'; INSERT INTO admins (user_id, role) VALUES (SELECT user_id FROM users WHERE username='llsyndi', 'Game Master'); --?(Y/N)</span>")
						sleep(2)
						to_chat(src, "<span class='danger'>> Y</span>")
						sleep(10)
						src << sound('sound/voice/AISyndiHack.ogg')
					to_chat(src, "<span class='danger'>Debug mode enabled - Safety protocols released.</span>")
					clear_supplied_laws()
					clear_inherent_laws()
					laws = new sammiemag_base_law_type
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

/mob/living/silicon/robot/mommi/sammi/update_canmove()
	canmove = 0
	return 0

/mob/living/silicon/robot/mommi/sammi/can_ventcrawl()
	return FALSE

/mob/living/silicon/robot/mommi/sammi/ventcrawl()
	return 0

/mob/living/silicon/robot/mommi/sammi/hide()
	return 0

/mob/living/silicon/robot/mommi/sammi/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			to_chat(user, "Close the wiring panel first.")
		else if(cell || cellhold)
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
				change_sammi_law(user)
			else
				to_chat(user, "The console's cover is closed.")

	else if(W.is_wrench(user)) // Need to make this not bludgeon them
		W.playtoolsound(loc, 50)
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

	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(emagged)//still allow them to open the cover
			to_chat(user, "The interface seems slightly damaged")
		if(opened)

			if(can_access(user.GetAccess(),20))//cmagged
				var/cmw = "Yes"
				cmw = alert(user, "Are you sure you want to disable this SAMMIs safety protocols?", "You sure?", "Yes", "No")
				if(cmw == "Yes")
					emag_act(user, 0)
		else
			if(allowed(usr))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] [src]'s interface.")
				if(can_diagnose())
					to_chat(src, "<span class='info' style=\"font-family:Courier\">Interface [ locked ? "locked" : "unlocked"].</span>")
				updateicon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		return ..()

/mob/living/silicon/robot/mommi/sammi/attack_hand(mob/user)
	add_fingerprint(user)

	if(user != src)
		if(opened && !wiresexposed)
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
		else if(!opened && !key)
			to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start \the [src]'s boot process.</span>")
			ping()

/mob/living/silicon/robot/mommi/sammi/New(loc)
	..()
	laws = new sammi_base_law_type
	module = new /obj/item/weapon/robot_module/sammi(src)
	cellhold = cell
	cell = null

/mob/living/silicon/robot/mommi/sammi/ghost()
	//if(src.subtype == "sammi")
	if(client && key)
		var/mob/dead/observer/ghost = ghostize(1)
		if(ghost_body)
			ghost.mind.current = ghost_body
		if(ghost_name)
			ghost.name = ghost_name
		if(ghost_gender)
			ghost.gender = ghost_gender
		if(ghost_icon)
			ghost.icon = ghost_icon
		if(ghost_icon_state)
			ghost.icon_state = ghost_icon_state
		if(ghost_overlays)
			ghost.overlays = ghost_overlays
		//src.mind.current = src.mind.original
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
				transfer_personality(O)
				searching = 0
			else if(src.key)
				to_chat(src, "<span class='notice'>Someone has already began controlling this SAMMI. Try another! </span>")


/mob/living/silicon/robot/mommi/sammi/proc/ping()
	if(!recruiter)
		searching = 1
		recruiter = new(src)
		recruiter.display_name = "sammi"
		recruiter.role = ROLE_POSIBRAIN // keep it same for these
		recruiter.jobban_roles = list(ROLE_POSIBRAIN)
		recruiter.logging = TRUE

		// A player has their role set to Yes or Always
		recruiter.player_volunteering = new /callback(src, nameof(src::recruiter_recruiting()))
		// ", but No or Never
		recruiter.player_not_volunteering = new /callback(src, nameof(src::recruiter_not_recruiting()))

		recruiter.recruited = new /callback(src, nameof(src::recruiter_recruited()))

	recruiter.request_player()


/mob/living/silicon/robot/mommi/sammi/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class=\"recruit\">You are a possible candidate for \a [src]. Get ready. ([controls])</span>")
	investigation_log(I_GHOST, "|| had a ghost automatically sign up to become its personality: [key_name(player)][player.locked_to ? ", who was haunting [player.locked_to]" : ""]")

/mob/living/silicon/robot/mommi/sammi/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	if(player.client && get_role_desire_str(player.client.prefs.roles[ROLE_POSIBRAIN]) != "Never")
		to_chat(player, "<span class=\"recruit\">Someone is requesting a personality for \a [src]. ([controls])</span>")

/mob/living/silicon/robot/mommi/sammi/proc/recruiter_recruited(mob/dead/observer/player)
	if(player)
		transfer_personality(player)

	reset_ping()

/mob/living/silicon/robot/mommi/sammi/proc/transfer_personality(mob/dead/observer/O)
	if(src.key || !O?.client)
		return
	ghost_name = O.mind.name
	ghost_gender = O.gender
	ghost_icon = O.icon
	ghost_icon_state = O.icon_state
	ghost_overlays = O.overlays
	ghost_body = O.mind.current
	src.mind = O.client.mob.mind
	src.ckey = O.client.ckey
	if(src.mind)
		src.mind.assigned_role = "SAMMI"
	src.visible_message("<span class=\"warning\">[src] is connected to the SAMMI network!</span>")
	if(icon_state == "sammi_offline_a")
		icon_state = "sammi_online_a"
	else
		icon_state = "sammi_online"
	updateicon()

/mob/living/silicon/robot/mommi/sammi/proc/reset_ping() //We give the players sixty seconds to decide, then reset the timer.
	if(!searching)
		return
	searching = 0
	if(src.key)
		return

	var/turf/T = get_turf(src.loc)
	for (var/mob/M in viewers(T))
		M.show_message("<span class='notice'>\The [src] buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>")
