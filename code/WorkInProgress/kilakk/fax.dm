//Updated by Cutelildick

var/list/obj/machinery/faxmachine/allfaxes = list()
var/list/alldepartments = list("Central Command")

/obj/machinery/faxmachine
	name = "fax machine"
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	req_one_access = list(access_lawyer, access_heads)
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	pass_flags = PASSTABLE
	var/authenticated = 0

	var/obj/item/weapon/paper/tofax = null // what we're sending
	var/faxtime = 0 //so people can know when we can fax again!
	var/cooldown_time = 900

	var/department = "Unknown" // our department

	var/dpt = "Central Command" // the department we're sending to

/obj/machinery/faxmachine/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/fax,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()
	allfaxes += src

	if(department == "Unknown")
		department = "Fax #[allfaxes.len]"

	if( !("[department]" in alldepartments) )
		alldepartments += department

/obj/machinery/faxmachine/RefreshParts()
	var/scancount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module))
			scancount += SP.rating-1
	cooldown_time = initial(cooldown_time) - 300*scancount

/obj/machinery/faxmachine/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/faxmachine/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/faxmachine/verb/remove_id()
	set name = "Remove ID from the fax machine"
	set src in view(1)
	if(scan && ishuman(usr))
		usr.put_in_hands(scan)
		scan = null

/obj/machinery/faxmachine/verb/remove_paper()
	set name = "Remove fax material from the fax machine"
	set src in view(1)
	if(tofax && ishuman(usr))
		usr.put_in_hands(tofax)
		tofax = null

/obj/machinery/faxmachine/attack_hand(mob/user as mob)
	user.set_machine(src)

	var/dat = "Fax Machine<BR>"

	var/scan_name
	if(scan)
		scan_name = scan.name
	else
		scan_name = "--------"

	dat += "Confirm Identity: <a href='byond://?src=\ref[src];scan=1'>[scan_name]</a><br>"

	if(authenticated)
		dat += "<a href='byond://?src=\ref[src];logout=1'>{Log Out}</a>"
	else
		dat += "<a href='byond://?src=\ref[src];auth=1'>{Log In}</a>"

	dat += "<hr>"

	if(authenticated || isAdminGhost(user))
		dat += "<b>Logged in to:</b> Central Command Quantum Entanglement Network<br><br>"

		if(tofax)
			dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><br><br>"

			if(faxtime>world.time)
				dat += "<b>Transmitter arrays realigning. Please stand by for [(faxtime - world.time) / 10] second\s.</b><br>"

			else
				dat += "<a href='byond://?src=\ref[src];send=1'>Send</a><br>"
				dat += "<b>Currently sending:</b> [tofax.name]<br>"
				if(dpt == null)
					//Old bug fix. Not selecting a dpt and/or my new lawyer access feature broke the dpt select.
					dpt = "Central Command"
				dat += "<b>Sending to:</b> <a href='byond://?src=\ref[src];dept=1'>[dpt]</a><br>"

		else
			if(faxtime>world.time)
				dat += "Please insert paper to send via secure connection.<br><br>"
				dat += "<b>Transmitter arrays realigning. Please stand by for [(faxtime - world.time) / 10] second\s.</b><br>"
			else
				dat += "Please insert paper to send via secure connection.<br><br>"

	else
		dat += "\proper authentication is required to use this device.<br><br>"

		if(tofax)
			dat += "<a href ='byond://?src=\ref[src];remove=1'>Remove Paper</a><br>"

	user << browse(dat, "window=copier")
	onclose(user, "copier")
	return

/obj/machinery/faxmachine/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["send"])
		if(tofax)
			if((dpt == "Central Command") | (dpt == "Nanotrasen HR"))
				if(!map.linked_to_centcomm)
					to_chat(usr, "<span class='danger'>\The [src] displays a 404 error: Central Command not found</span>")
					return
				if(dpt == "Central Command")
					Centcomm_fax(tofax, tofax.name, usr)
				if(dpt == "Nanotrasen HR")
					if(findtext(tofax.stamps, "magnetic"))
						if(findtext(tofax.name,"Demotion"))
							new /obj/item/demote_chip(src.loc)
						if(findtext(tofax.name,"Commendation"))
							new /obj/item/mounted/poster(src.loc,-1)

			else
				SendFax(tofax.info, tofax.name, usr, dpt, 0, tofax.display_x, tofax.display_y)
			log_game("([usr]/([usr.ckey]) sent a fax titled [tofax] to [dpt] - contents: [tofax.info]")
			to_chat(usr, "Message transmitted successfully.")
			faxtime = world.time + cooldown_time

	if(href_list["remove"])
		if(tofax)
			tofax.forceMove(loc)
			if(Adjacent(usr))
				usr.put_in_hands(tofax)
			to_chat(usr, "<span class='notice'>You take the paper out of \the [src].</span>")
			tofax = null

	if(href_list["scan"])
		if (scan)
			if(ishuman(usr))
				scan.forceMove(usr.loc)
				if(!usr.get_active_hand())
					usr.put_in_hands(scan)
				scan = null
			else
				scan.forceMove(src.loc)
				scan = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				if(usr.drop_item(I, src))
					scan = I
		authenticated = 0

	if(href_list["dept"])
		dpt = input(usr, "Which department?", "Choose a department", "") as null|anything in alldepartments

	if(href_list["auth"])
		if ( (!( authenticated ) && (scan)) )
			if (check_access(scan))
				authenticated = 1
				if(access_lawyer in scan.access)
					alldepartments += "Nanotrasen HR"

	if(href_list["logout"])
		authenticated = 0
		if(access_lawyer in scan.access)
			alldepartments -= "Nanotrasen HR"

	updateUsrDialog()

/obj/machinery/faxmachine/attackby(obj/item/O as obj, mob/user as mob)
	if(stat & NOPOWER)
		to_chat(user, "<span class = 'warning'>\The [src] has no power.</span>")
		return
	if(stat & BROKEN)
		to_chat(user, "<span class = 'warning'>\The [src] is broken!</span>")
		return
	if(istype(O, /obj/item/weapon/paper))
		if(!tofax)
			if(user.drop_item(O, src))
				tofax = O
				to_chat(user, "<span class='notice'>You insert the paper into \the [src].</span>")
				flick("faxsend", src)
				updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")

	else if(istype(O, /obj/item/weapon/card/id))

		var/obj/item/weapon/card/id/idcard = O
		if(!scan)
			if(usr.drop_item(idcard, src))
				scan = idcard

	else if(O.is_wrench(user))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	return

/obj/machinery/faxmachine/kick_act()
	..()
	if(tofax)
		tofax.forceMove(loc)
		tofax = null
		return
	if(scan)
		scan.forceMove(loc)
		scan = null
		return

/proc/Centcomm_fax(var/obj/item/weapon/paper/sent, var/sentname, var/mob/Sender)

//why the fuck doesnt the thing show as orange
	var/msg = "<span class='notice'><b>  CENTCOMM FAX: [key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<a href='?_src_=holder;role_panel=\ref[Sender]'>RP</a>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;check_antagonist=1'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<a href='?_src_=holder;CentcommFaxReply=\ref[Sender]'>RPLY</a>)</b>: Receiving '[sentname]' via secure connection ... <a href='?_src_=holder;CentcommFaxView=\ref[sent]'>view message</a></span>"
	for (var/client/C in admins)
		C.output_to_special_tab(msg)
		C << 'sound/effects/fax.ogg'

proc/SendFax(var/sent, var/sentname, var/mob/Sender, var/dpt, var/centcomm, var/xdim, var/ydim)

	var/faxed = null
	for(var/obj/machinery/faxmachine/F in allfaxes)

		if(centcomm || F.department == dpt )
			if(! (F.stat & (BROKEN|NOPOWER) ) )

				flick("faxreceive", F)

				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(F)

				if (centcomm)
					P.name = "[command_name()] - [sentname]"
				else//probably a
					P.name = "[sentname]"
				P.info = "[sent]"
				if(xdim)
					P.display_x = xdim
				if(ydim)
					P.display_y = ydim
				P.update_icon()

				playsound(F.loc, "sound/effects/fax.ogg", 50, 1)

				if(centcomm)
					CentcommStamp(P)


				// give the sprite some time to flick
				spawn(20)
					P.forceMove(F.loc)

				faxed = P //doesn't return here in case there's multiple faxes in the department
	if(centcomm)
		for(var/obj/item/device/pda/pingme in PDAs)
			if(pingme.cartridge && pingme.cartridge.fax_pings)
				playsound(pingme, "sound/effects/kirakrik.ogg", 50, 1)
				pingme.visible_message("[bicon(pingme)] *Fax Received*")
	return faxed

/proc/CentcommStamp(var/obj/item/weapon/paper/P)
	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.icon_state = "paper_stamp-cent"
	if(!P.stamped)
		P.stamped = new
	P.stamped += /obj/item/weapon/stamp
	P.overlays += stampoverlay
	P.stamps += "<HR><i>This paper has been stamped by the Central Command Quantum Relay.</i>"

/proc/SendMerchantFax(mob/living/carbon/human/merchant)
	var/obj/item/weapon/paper/merchantreport/P
	for(var/obj/machinery/faxmachine/F in allfaxes)
		if(F.department == "Internal Affairs" && !F.stat)
			flick("faxreceive", F)
			playsound(F.loc, "sound/effects/fax.ogg", 50, 1)
			P = new /obj/item/weapon/paper/merchantreport(F,merchant)
			spawn(2 SECONDS)
				P.forceMove(F.loc)
	return P
