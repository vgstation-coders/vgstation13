/obj/item/weapon/cartridge/head
	name = "\improper Easy-Record DELUXE"
	icon_state = "cart-h"
	starting_apps = list(/datum/pda_app/cart/status_display)

/datum/pda_app/cart/status_display
	name = "Set Status Display"
	desc = "Change the message displayed on status displays throughout the station."
	icon = "pda_status"
	var/message1
	var/message2

/datum/pda_app/cart/status_display/get_dat(var/mob/user)
	return {"<h4><span class='pda_icon pda_status'></span> Station Status Display Interlink</h4>
		\[ <A HREF='?src=\ref[src];Status=blank'>Clear</A> \]<BR>
		\[ <A HREF='?src=\ref[src];Status=shuttle'>Shuttle ETA</A> \]<BR>
		\[ <A HREF='?src=\ref[src];Status=message'>Message</A> \]
		<ul><li> Line 1: <A HREF='?src=\ref[src];Status=setmsg1'>[ message1 ? message1 : "(none)"]</A>
		<li> Line 2: <A HREF='?src=\ref[src];Status=setmsg2'>[ message2 ? message2 : "(none)"]</A></ul><br>
		\[ Alert: <A HREF='?src=\ref[src];Status=alert;alert=default'>None</A> |
		<A HREF='?src=\ref[src];Status=alert;alert=redalert'>Red Alert</A> |
		<A HREF='?src=\ref[src];Status=alert;alert=lockdown'>Lockdown</A> |
		<A HREF='?src=\ref[src];Status=alert;alert=biohazard'>Biohazard</A> \]<BR>"}

/datum/pda_app/cart/status_display/Topic(href, href_list)
	if(..())
		return
	switch(href_list["Status"])
		if("message")
			post_status("message", message1, message2)
		if("alert")
			post_status("alert", href_list["alert"])
		if("setmsg1")
			message1 = reject_bad_text(trim(copytext(sanitize(input("Line 1", "Enter Message Text", message1) as text|null), 1, 40)), 40)
			pda_device.updateSelfDialog()
		if("setmsg2")
			message2 = reject_bad_text(trim(copytext(sanitize(input("Line 2", "Enter Message Text", message2) as text|null), 1, 40)), 40)
			pda_device.updateSelfDialog()
		else
			post_status(href_list["Status"])
	refresh_pda()

/datum/pda_app/cart/status_display/proc/post_status(var/command, var/data1, var/data2)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = new /datum/signal
	status_signal.source = pda_device
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			if(pda_device)
				var/mob/user = pda_device.fingerprintslast
				if(istype(pda_device.loc,/mob/living))
					name = pda_device.loc
				log_admin("STATUS: [user] set status screen with [pda_device]. Message: [data1] [data2]")
				message_admins("STATUS: [user] set status screen with [pda_device]. Message: [data1] [data2]")

		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(pda_device, status_signal)

/obj/item/weapon/cartridge/hop
    name = "\improper HumanResources9001"
    icon_state = "cart-h"
    starting_apps = list(
        /datum/pda_app/cart/status_display,
        /datum/pda_app/cart/custodial_locator,
        /datum/pda_app/cart/supply_records,
        /datum/pda_app/cart/mulebot,
    )
    fax_pings = TRUE
    radio_type = /obj/item/radio/integrated/signal/bot/mule

/obj/item/weapon/cartridge/hop/dx
    name = "\improper HumanResources9001 DX"
    starting_apps = list(
        /datum/pda_app/cart/status_display,
        /datum/pda_app/cart/custodial_locator,
        /datum/pda_app/cart/supply_records,
        /datum/pda_app/cart/mulebot,
        /datum/pda_app/cart/access_change,
    )

/obj/item/weapon/cartridge/hop/dx/antag
    starting_apps = list(
        /datum/pda_app/cart/status_display,
        /datum/pda_app/cart/custodial_locator,
        /datum/pda_app/cart/supply_records,
        /datum/pda_app/cart/mulebot,
        /datum/pda_app/cart/access_change/antag,
    )

/datum/pda_app/cart/access_change
    name = "Remote Access Change"
    desc = "Remotely changes the access of an ID in a selected PDA"
    category = "Utilities"
	icon = "pda_money"
	var/hacked = FALSE
	var/obj/item/device/pda/selected_pda = null

/datum/pda_app/cart/access_change/antag
	hacked = TRUE

/datum/pda_app/cart/access_change/get_dat(var/mob/user)
	var/dat = "{
		<h4><span class='pda_icon pda_money'></span> Remote access change</h4>
		Target identity: <a href='?src=\ref[src];select_pda=1'>[selected_pda ? selected_pda.name : "Select a PDA"]</a><br>
		}"
	if(!hacked)
		dat += "Authorized identity: [pda_device.id ? pda_device.id.name : "None"]<br>"
	if(selected_pda)
		dat += "{
			Registered name: <a href='?src=\ref[src];edit_name'>[selected_pda.id.registered_name]</a><br>
			Registered account: <a href='?src=\ref[src];edit_account'>[selected_pda.id.associated_account_number]</a><br>
			}"
		for(var/i = 1; i <= 7; i++)
			dat += "<div style='float: left'><b>[get_region_accesses_name(i)]</b><br>"
			for(var/access in get_region_accesses(i))
				var/aname = get_access_desc(access)
				dat += "<a href='?src=\ref[src];access=[access]'>[aname]</a><br>"
			dat += "<br></div>"
	return dat

/datum/pda_app/cart/access_change/Topic(href, href_list)
	if(..())
		return
	var/mob/living/U = usr
	if(!istype(U))
		return
	if(href_list["select_pda"])
		var/list/pda_with_id = list()
		for(var/obj/item/device/pda/pda_id in sortNames(get_viewable_pdas()))
			if(pda_id.id)
				pda_with_id += pda_id
		if(!pda_with_id.len)
			return
		selected_pda = input(U, "Select a PDA to modify the ID of", "PDA Selection") as null|anything in pda_with_id
	if(selected_pda && selected_pda.id)
		var/obj/item/weapon/card/id/selected_id = selected_pda.id
		if(href_list["edit_name"])
			selected_id.registered_name = input(U, "Enter a new name", "ID rename", selected_id.registered_name) as text
		if(href_list["edit_account"])
			var/account_num = input(U, "Enter a new account number", "Account number change", selected_id.associated_account_number) as num
			var/datum/money_account/MA = get_money_account(account_num)
			if(!MA)
				to_chat(usr, "<span class='warning'>That account number was invalid.</span>")
				refresh_pda()
				return
			if(MA.hidden)
				to_chat(usr, "<span class='warning'>That account number is reserved.</span>")
				refresh_pda()
				return
			selected_id.associated_account_number = account_num
		if(href_list["access"])
			return
	refresh_pda()

/obj/item/weapon/cartridge/hos
	name = "\improper R.O.B.U.S.T. DELUXE"
	icon_state = "cart-hos"
	starting_apps = list(
        /datum/pda_app/cart/status_display,
		/datum/pda_app/cart/security_records,
		/datum/pda_app/cart/scanner/hailer,
		/datum/pda_app/cart/secbot,
    )
	radio_type = /obj/item/radio/integrated/signal/bot/beepsky

/obj/item/weapon/cartridge/ce
	name = "\improper Power-On DELUXE"
	icon_state = "cart-ce"
	starting_apps = list(
        /datum/pda_app/cart/status_display,
        /datum/pda_app/cart/power_monitor,
        /datum/pda_app/cart/alert_monitor,
        /datum/pda_app/cart/floorbot,
        /datum/pda_app/cart/scanner/engineer,
        /datum/pda_app/cart/scanner/atmos,
        /datum/pda_app/cart/scanner/mechanic,
    )
	radio_type = /obj/item/radio/integrated/signal/bot/floorbot

/obj/item/weapon/cartridge/cmo
	name = "\improper Med-U DELUXE"
	icon_state = "cart-cmo"
	starting_apps = list(
        /datum/pda_app/cart/status_display,
        /datum/pda_app/cart/medical_records,
        /datum/pda_app/cart/scanner/medical,
        /datum/pda_app/cart/medbot,
        /datum/pda_app/cart/scanner/reagent
    )
	radio_type = /obj/item/radio/integrated/signal/bot/medbot

/obj/item/weapon/cartridge/rd
	name = "\improper Signal Ace DELUXE"
	icon_state = "cart-rd"
	starting_apps = list(
        /datum/pda_app/cart/status_display,
        /datum/pda_app/cart/signaler,
        /datum/pda_app/cart/scanner/robotics,
        /datum/pda_app/cart/scanner/atmos,
    )
	radio_type = /obj/item/radio/integrated/signal

/obj/item/weapon/cartridge/captain
	name = "\improper Value-PAK Cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	starting_apps = list(
        /datum/pda_app/cart/status_display,
        /datum/pda_app/cart/power_monitor,
        /datum/pda_app/cart/alert_monitor,
        /datum/pda_app/cart/scanner/mechanic,
        /datum/pda_app/cart/medical_records,
        /datum/pda_app/cart/scanner/medical,
		/datum/pda_app/cart/security_records,
		/datum/pda_app/cart/scanner/hailer,
        /datum/pda_app/cart/supply_records,
        /datum/pda_app/cart/custodial_locator,
        /datum/pda_app/cart/scanner/reagent,
        /datum/pda_app/cart/scanner/engineer,
        /datum/pda_app/cart/scanner/atmos,
        /datum/pda_app/cart/scanner/robotics,
    )
	fax_pings = TRUE