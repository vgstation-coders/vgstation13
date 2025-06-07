/datum/pda_app/messenger
    name = "Messenger"
    desc = "Allows the PDA to send messages, images and funds to other PDAs, if possible."
    price = 0
    icon = "pda_mail"
    var/silent = 0 //To beep or not to beep, that is the question
    var/toff = 0 //If 1, messenger disabled
    var/list/tnote = list() //Current Texts
    var/last_text //No text spamming
    var/ttone = "beep" //The ringtone!
    var/list/icon/imglist = list() // Viewable message photos
    var/list/incoming_transactions = list()

/datum/pda_app/messenger/get_dat(var/mob/user)
	var/dat = ""
	switch(mode)
		if (0)
			dat += {"<h4><span class='pda_icon pda_mail'></span> SpaceMessenger V3.9.4</h4>
				<a href='byond://?src=\ref[src];choice=Toggle Ringer'><span class='pda_icon pda_bell'></span> Ringer: [silent == 1 ? "Off" : "On"]</a> |
				<a href='byond://?src=\ref[src];choice=Toggle Messenger'><span class='pda_icon pda_mail'></span> Send / Receive: [toff == 1 ? "Off" : "On"]</a> |
				<a href='byond://?src=\ref[src];choice=Ringtone'><span class='pda_icon pda_bell'></span> Set Ringtone</a> |
				<a href='byond://?src=\ref[src];choice=1'><span class='pda_icon pda_mail'></span> Messages</a>"}
			dat += "<br>"
			for(var/datum/pda_app/cart/virus/V in pda_device.applications)
				dat += "<b>[V.charges] [V.virus_type] left.</b><HR>"

			dat += {"<h4><span class='pda_icon pda_menu'></span> Detected PDAs</h4>
				<ul>"}
			var/count = 0

			if (!toff)
				for (var/obj/item/device/pda/P in sortNames(get_viewable_pdas()))
					if (P == src)
						continue
					if(P.hidden)
						continue
					dat += "<li><a href='byond://?src=\ref[src];choice=Message;target=\ref[P]'>[P]</a>"
					if (pda_device.id && !istype(P,/obj/item/device/pda/ai))
						dat += " (<a href='byond://?src=\ref[src];choice=transferFunds;target=\ref[P]'><span class='pda_icon pda_money'></span>*Send Money*</a>)"

					for(var/datum/pda_app/cart/virus/V in pda_device.applications)
						if (P.accepted_viruses && P.accepted_viruses.len && (V.type in P.accepted_viruses))
							dat += " (<a href='byond://?src=\ref[V];target=\ref[P]'>[V.icon ? "<span class='pda_icon [V.icon]'></span>" : ""]*[V.name]*</a>)"
					dat += "</li>"
					count++
			dat += "</ul>"
			if (count == 0)
				dat += "None detected.<br>"
		if(1)
			dat += {"<h4><span class='pda_icon pda_mail'></span> SpaceMessenger V3.9.4</h4>
				<a href='byond://?src=\ref[src];choice=Clear'><span class='pda_icon pda_blank'></span> Clear Messages</a>
				<h4><span class='pda_icon pda_mail'></span> Messages</h4>"}
			for(var/note in tnote)
				dat += tnote[note]
				var/icon/img = imglist[note]
				if(img)
					user << browse_rsc(ImagePDA(img), "tmp_photo_[note].png")
					dat += "<img src='tmp_photo_[note].png' width = '192' style='-ms-interpolation-mode:nearest-neighbor'><BR>"
			dat += "<br>"
	return dat

/datum/pda_app/messenger/Topic(href, href_list)
    if(..())
        return
    var/mob/living/U = usr
    switch(href_list["choice"])
        if("1")
            mode = 1
        if("Toggle Messenger")
            toff = !toff
        if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
            silent = !silent
        if("Clear")//Clears messages
            imglist.Cut()
            tnote.Cut()
        if("Ringtone")
            var/t = input(U, "Please enter new ringtone", name, ttone) as text
            if (pda_device.loc == U)
                if (t)
                    if(INVOKE_EVENT(pda_device, /event/pda_change_ringtone, "user" = U, "new_ringtone" = t))
                        to_chat(U, "The PDA softly beeps.")
                        U << browse(null, "window=pda")
                        src.mode = 0
                    else
                        t = copytext(sanitize(t), 1, 20)
                        ttone = t
                    return
            else
                U << browse(null, "window=pda")
                return
        if("Message")
            var/obj/item/device/pda/P = locate(href_list["target"])
            P.overlays.len = 0  // replying to a message from chat clears alert
            P.update_icon()
            src.create_message(U, P)
        if("viewPhoto")
            var/obj/item/weapon/photo/PH = locate(href_list["image"])
            PH.show(U)

        if("transferFunds")
            if(!pda_device.id)
                return
            var/obj/machinery/message_server/useMS = null
            if(message_servers)
                for (var/obj/machinery/message_server/MS in message_servers)
                    if(MS.is_functioning())
                        useMS = MS
                        break
            if(!useMS)
                to_chat(usr, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Error, Messaging server is not responding.'</span>")
                return
            var/obj/item/device/pda/P = locate(href_list["target"])
            var/datum/signal/signal = pda_device.telecomms_process()

            var/useTC = 0
            if(signal)
                if(signal.data["done"])
                    useTC = 1
                    var/turf/pos = get_turf(P)
                    if(pos.z in signal.data["level"])
                        useTC = 2

            if(!useTC) // only send the message if it's stable
                to_chat(usr, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Error, Unable to receive signal from local subspace comms. PDA outside of comms range.'</span>")
                return
            if(useTC != 2) // Does our recepient have a broadcaster on their level?
                to_chat(usr, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Error, Unable to receive handshake signal from recipient PDA. Recipient PDA outside of comms range.'</span>")
                return

            var/amount = round(input("How much money do you wish to transfer to [P.owner]?", "Money Transfer", 0) as num)
            if(!amount || (amount < 0) || (pda_device.id.virtual_wallet.money <= 0))
                to_chat(usr, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Invalid value.'</span>")
                return
            if(amount > pda_device.id.virtual_wallet.money)
                amount = pda_device.id.virtual_wallet.money

            var/datum/pda_app/messenger/P_app = locate(/datum/pda_app/messenger) in P.applications
            if(P_app)
                switch(P_app.receive_funds(pda_device.owner,amount,name))
                    if(1)
                        to_chat(usr, "[bicon(pda_device)]<span class='notice'>The PDA's screen flashes, 'Transaction complete!'</span>")
                    if(2)
                        to_chat(usr, "[bicon(pda_device)]<span class='notice'>The PDA's screen flashes, 'Transaction complete! The recipient will earn the funds once he enters his ID in his PDA.'</span>")
                    else
                        to_chat(usr, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Error, transaction canceled'</span>")
                        return
            else
                to_chat(usr, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Error, transaction canceled'</span>")
                return

            pda_device.id.virtual_wallet.money -= amount
            new /datum/transaction(pda_device.id.virtual_wallet, "Money transfer", "-[amount]", pda_device.name, P.owner)
    refresh_pda()

//Receive money transferred from another PDA
/datum/pda_app/messenger/proc/receive_funds(var/creditor_name,var/arbitrary_sum,var/other_pda)
	var/datum/pda_app/balance_check/app = locate(/datum/pda_app/balance_check) in pda_device.applications
	if(!app.linked_db)
		app.reconnect_database()
	if(!app.linked_db || !app.linked_db.activated || app.linked_db.stat & (BROKEN|NOPOWER))
		return 0 //This sends its own error message
	var/turf/U = get_turf(pda_device)
	if(!silent)
		playsound(U, 'sound/machines/twobeep.ogg', 50, 1)

	for (var/mob/O in hearers(3, U))
		if(!silent)
			O.show_message(text("[bicon(pda_device)] *[ttone]*"))

	var/mob/living/L = null
	if(pda_device.loc && isliving(pda_device.loc))
		L = pda_device.loc
	else
		L = get_holder_of_type(pda_device, /mob/living/silicon)

	if(L)
		to_chat(L, "[bicon(pda_device)] <b>Money transfer from [creditor_name] ([arbitrary_sum]$) </b>[pda_device.id ? "" : "Insert your ID in the PDA to receive the funds."]")

	tnote["msg_id"] = "<i><b>&larr; Money transfer from [creditor_name] ([arbitrary_sum]$)<br>"
	msg_id++

	if(pda_device.id)
		if(!pda_device.id.virtual_wallet)
			pda_device.id.update_virtual_wallet()
		pda_device.id.virtual_wallet.money += arbitrary_sum
		new /datum/transaction(pda_device.id.virtual_wallet, "Money transfer", arbitrary_sum, other_pda, creditor_name, send2PDAs = FALSE)
		return 1
	else
		incoming_transactions |= list(list(creditor_name,arbitrary_sum,other_pda))
		return 2

//Receive money transferred from another PDA
/datum/pda_app/messenger/proc/receive_incoming_transactions(var/obj/item/weapon/card/id/ID_card)
	var/mob/living/L = null
	if(pda_device.loc && isliving(pda_device.loc))
		L = pda_device.loc
	to_chat(L, "[bicon(pda_device)]<span class='notice'> <b>Transactions successfully received! </b></span>")

	for(var/transac in incoming_transactions)
		if(!pda_device.id.virtual_wallet)
			pda_device.id.update_virtual_wallet()
		pda_device.id.virtual_wallet.money += transac[2]
		new /datum/transaction(pda_device.id.virtual_wallet, "Money transfer", transac[2], transac[3], transac[1])

	incoming_transactions = list()

/datum/pda_app/messenger/proc/create_message(var/mob/living/U = usr, var/obj/item/device/pda/P, var/multicast_message = null, obj/item/device/pda/reply_to, var/overridemessage)
    if(!reply_to)
        reply_to = pda_device
    if (!istype(P))
        return
    var/datum/pda_app/messenger/P_app = locate(/datum/pda_app/messenger) in P.applications
    if(!P_app || P_app.toff)
        return
    var/t = null
    if(overridemessage)
        t = overridemessage
    if(multicast_message)
        t = multicast_message
    if(!t)
        t = input(U, "Please enter message", "Message to [P]", null) as text|null
        t = copytext(parse_emoji(sanitize(t)), 1, MAX_MESSAGE_LEN)
        if (!t || P_app.toff || (!in_range(pda_device, U) && pda_device.loc != U)) //If no message, messaging is off, and we're either out of range or not in usr
            return

        if (last_text && world.time < last_text + 5)
            return
        last_text = world.time
    // check if telecomms I/O route 1459 is stable
    //var/telecomms_intact = telecomms_process(P.owner, owner, t)
    var/obj/machinery/message_server/useMS = null
    if(message_servers)
        for (var/obj/machinery/message_server/MS in message_servers)
        //PDAs are now dependant on the Message Server.
            if(MS.is_functioning())
                useMS = MS
                break

    var/datum/signal/signal = pda_device.telecomms_process()

    var/useTC = FALSE
    if(signal)
        if(signal.data["done"])
            var/turf/pos = get_turf(P)
            if(pos.z in signal.data["level"])
                useTC = TRUE
                //Let's make this barely readable
                if(signal.data["compression"] > 0)
                    t = Gibberish(t, signal.data["compression"] + 50)

    if(useMS && useTC) // only send the message if it's stable
        if(!useTC) // Does our recepient have a broadcaster on their level?
            to_chat(U, "ERROR: Cannot reach recepient.")
            return

        var/obj/item/weapon/photo/current_photo = null

        if(pda_device.photo)
            current_photo = pda_device.photo

        if(pda_device.cartridge && istype(pda_device.cartridge, /obj/item/weapon/cartridge/camera))
            var/obj/item/weapon/cartridge/camera/CM = pda_device.cartridge
            if(CM.stored_photos.len)
                current_photo = input(U, "Photos found in [CM]. Please select one", "Cartridge Photo Selection") as null|anything in CM.stored_photos

        if(current_photo)
            imglist["[msg_id]"] = current_photo.img
            P_app.imglist["[msg_id]"] = current_photo.img

        useMS.send_pda_message("[P.owner]","[pda_device.owner]","[t]",imglist["[msg_id]"])

        tnote["[msg_id]"] = "<i><b>&rarr; To [P.owner]:</b></i><br>[t]<br>"
        P_app.tnote["[msg_id]"] = "<i><b>&larr; From <a href='byond://?src=\ref[P_app];choice=Message;target=\ref[reply_to]'>[pda_device.owner]</a> ([pda_device.ownjob]):</b></i><br>[t]<br>"
        msg_id++
        for(var/mob/dead/observer/M in player_list)
            if(!multicast_message && M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTPDA)) // src.client is so that ghosts don't have to listen to mice
                M.show_message("<a href='?src=\ref[M];follow=\ref[U]'>(Follow)</a> <span class='game say'>PDA Message - <span class='name'>\
                    [U.real_name][U.real_name == pda_device.owner ? "" : " (as [pda_device.owner])"]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span>\
                    [pda_device.photo ? " (<a href='byond://?src=\ref[P_app];choice=viewPhoto;image=\ref[pda_device.photo];skiprefresh=1;target=\ref[reply_to]'>View Photo</a>)</span>" : ""]")


        if (prob(15)&&!multicast_message) //Give the AI a chance of intercepting the message
            var/who = pda_device.owner
            if(prob(50))
                who = P:owner
            for(var/mob/living/silicon/ai/ai in mob_list)
                // Allows other AIs to intercept the message but the AI won't intercept their own message.
                if(ai.aiPDA != P && ai.aiPDA != src)
                    ai.show_message("<i>Intercepted message from <b>[who]</b>: [t]</i>")

        if (!P_app.silent)
            playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
        for (var/mob/O in hearers(3, P.loc))
            if(!P_app.silent)
                O.show_message(text("[bicon(P)] *[P_app.ttone]*"))
        //Search for holder of the PDA.
        var/mob/living/L = null
        if(P.loc && isliving(P.loc))
            L = P.loc
        //Maybe they are a pAI!
        else
            L = get_holder_of_type(P, /mob/living/silicon)

        if(L)
            L.show_message("[bicon(P)] <b>Message from [pda_device.owner] ([pda_device.ownjob]), </b>\"[t]\" [pda_device.photo ? "(<a href='byond://?src=\ref[P_app];choice=viewPhoto;image=\ref[pda_device.photo];skiprefresh=1;target=\ref[reply_to]'>View Photo</a>)" : ""] (<a href='byond://?src=\ref[P_app];choice=Message;skiprefresh=1;target=\ref[reply_to]'>Reply</a>)", 2)
        U.show_message("[bicon(pda_device)] <span class='notice'>Message for <a href='byond://?src=\ref[src];choice=Message;skiprefresh=1;target=\ref[P]'>[P]</a> has been sent.</span>")
        log_pda("[key_name(usr)] (PDA: [pda_device.name]) sent \"[t]\" to [P.name]")
        P.overlays.len = 0
        if(P.show_overlays)
            P.overlays += image('icons/obj/pda.dmi', "pda-r")
    else
        to_chat(U, "[bicon(pda_device)] <span class='notice'>ERROR: Messaging server is not responding.</span>")

/datum/pda_app/multimessage
    name = "Department Messenger"
    desc = "Messages an entire department at once."
    price = 0
    has_screen = FALSE
    icon = "pda_mail"

/datum/pda_app/multimessage/on_select(var/mob/user)
    var/list/department_list = list("security","engineering","medical","research","cargo","service")
    var/target = input("Select a department", "CAMO Service") as null|anything in department_list
    if(!target)
        return
    var/t = input(user, "Please enter message", "Message to [target]", null) as text|null
    t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)

    var/datum/pda_app/messenger/message_app = locate(/datum/pda_app/messenger) in pda_device.applications
    //If no message or messenger, messaging is off, and we're either out of range or not in usr
    if (!message_app ||!t || message_app.toff || (!in_range(pda_device, user) && pda_device.loc != user))
        return
    if (message_app.last_text && world.time < message_app.last_text + 5)
        return
    message_app.last_text = world.time
    for(var/obj/machinery/pda_multicaster/multicaster in pda_multicasters)
        if(multicaster.check_status())
            var/datum/signal/signal = pda_device.telecomms_process()
            if(signal)
                if(signal.data["done"])
                    var/turf/pos = get_turf(multicaster)
                    if(pos.z in signal.data["level"])
                        //Let's make this barely readable
                        if(signal.data["compression"] > 0)
                            t = Gibberish(t, signal.data["compression"] + 50)
                        multicaster.multicast(target,pda_device,user,t)
                        message_app.tnote["msg_id"] = "<i><b>&rarr; To [target]:</b></i><br>[t]<br>"
                        msg_id++
                        return
    to_chat(user, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Error, CAMO server is not responding.'</span>")
