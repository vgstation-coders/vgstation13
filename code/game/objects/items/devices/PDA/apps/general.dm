/datum/pda_app/alarm
	name = "Alarm"
	desc = "Set a time for a personal alarm to trigger."
	price = 0
	menu = FALSE // It's listed elsewhere by the clock
	icon = "pda_clock"
	var/target = 0
	var/status = 1			//	0=off 1=on
	var/lasttimer = 0

/datum/pda_app/alarm/get_dat(var/mob/user)
	return {"
		<h4>Alarm Application</h4>
		The alarm is currently <a href='byond://?src=\ref[src];toggleAlarm=1'>[status ? "ON" : "OFF"]</a><br>
		Current Time:[worldtime2text()]<BR>
		Alarm Time: [target ? "[worldtime2text(target)]" : "Unset"] <a href='byond://?src=\ref[src];setAlarm=1'>SET</a><BR>
		"}

/datum/pda_app/alarm/Topic(href, href_list)
	if(..())
		return
	if(href_list["toggleAlarm"])
		status = !status
	if(href_list["setAlarm"])
		var/nutime = round(input("How long before the alarm triggers, in seconds?", "Alarm", 1) as num)
		if(set_alarm(nutime))
			to_chat(usr, "[bicon(pda_device)]<span class='info'>The PDA confirms your [nutime] second timer.</span>")
	if(href_list["restartAlarm"])
		if(restart_alarm())
			to_chat(usr, "[bicon(pda_device)]<span class='info'>The PDA confirms your [lasttimer] second timer.</span>")
			no_refresh = TRUE
	refresh_pda()

/datum/pda_app/alarm/proc/set_alarm(var/await)
	if(await<=0)
		return FALSE
	target = world.time + (await SECONDS)
	lasttimer = await
	spawn((await SECONDS) + 1 SECONDS)
		alarm()
	return TRUE

/datum/pda_app/alarm/proc/alarm()
	if(!status || world.time < target)
		return //End the loop if it was disabled or if the target isn't here yet. e.g.: target changed
	playsound(pda_device, 'sound/machines/chime.ogg', 40, FALSE, -2)
	var/mob/living/L = get_holder_of_type(pda_device,/mob/living)
	if(L)
		to_chat(usr, "[bicon(pda_device)]<span class='info'>Timer for [lasttimer] seconds has finished. <a href='byond://?src=\ref[src];restartAlarm=1'>(Restart?)</a></span>")

/datum/pda_app/alarm/proc/restart_alarm()
	if(!status || world.time < target || lasttimer <= 0)
		return //End the loop if it was disabled or already active
	return set_alarm(lasttimer)

/datum/pda_app/notekeeper
	name = "Notekeeper"
	desc = "For when your mind isn't focused enough to keep them."
	price = 0
	icon = "pda_notes"
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""

/datum/pda_app/notekeeper/get_dat(var/mob/user)
	return "<h4><span class='pda_icon pda_notes'></span> Notekeeper V2.1</h4> <a href='byond://?src=\ref[src];Edit=1'>Edit</a><br>[note]"

/datum/pda_app/notekeeper/Topic(href, href_list)
	if(..())
		return
	var/mob/living/U = usr
	if (href_list["Edit"])
		var/n = input(U, "Please enter message", name, notehtml) as message
		if (in_range(pda_device, U) && pda_device.loc == U)
			n = copytext(adminscrub(n), 1, MAX_MESSAGE_LEN)
			if (pda_device.current_app == src)
				note = replacetext(n, "\n", "<BR>")
				notehtml = n

				var/log = replacetext(n, "\n", "(new line)")//no intentionally spamming admins with 100 lines, nice try
				log_say("[pda_device] notes - [U] changed the text to: [log]")
				for(var/mob/dead/observer/M in player_list)
					if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTPDA))
						M.show_message("<span class='game say'>[pda_device] notes - <span class = 'name'>[U]</span> changed the text to:</span> [log]")
		else
			U << browse(null, "window=pda")
			return
	refresh_pda()

/datum/pda_app/events
	name = "Current Events"
	desc = "It's happening."
	price = 0
	icon = "pda_clock"
	var/list/currentevents = list()
	var/onthisday = null

/datum/pda_app/events/onInstall()
	..()
	var/list/picknews = file2list("config/news/news.txt")
	for(var/i in 1 to 3)
		currentevents += list(pick_n_take(picknews))
	onthisday = pick(file2list("config/news/history.txt"))

/datum/pda_app/events/get_dat(var/mob/user)
    return {"<h4><span class='pda_icon pda_clock'></span> Current Events</h4>
        Station Time: <b>[worldtime2text()]</b>.<br>
        Empire Date: <b>[pda_device.MM]/[pda_device.DD]/[game_year]</b>.<br><br>
        <b>Current Events,</b><br>
        <li>[currentevents[1]]</li<br>
        <li>[currentevents[2]]</li><br>
        <li>[currentevents[3]]</li><br><br>
        <b>On this day,</b><br>
        <li>[onthisday]</li><br><br>
        <b>Did you know...</b><br>
        <li>[pick(file2list("config/news/facts.txt"))]</li><br>"}

/datum/pda_app/manifest
	name = "View Crew Manifest"
	desc = "Find out which captain you should call a comdom."
	price = 0
	icon = "pda_notes"

/datum/pda_app/manifest/get_dat(var/mob/user)
    var/dat = {"<h4><span class='pda_icon pda_notes'></span> Crew Manifest</h4>
        Entries cannot be modified from this terminal.<br><br>"}
    if(data_core)
        dat += data_core.get_manifest(1) // make it monochrome
    dat += "<br>"
    return dat

/datum/pda_app/balance_check
	name = "Virtual Wallet and Balance Check"
	desc = "Connects to the Account Database to check the balance history the inserted ID card."
	price = 0
	icon = "pda_money"
	var/obj/machinery/account_database/linked_db

/datum/pda_app/balance_check/onInstall()
	..()
	reconnect_database()

/datum/pda_app/balance_check/get_dat(var/mob/user)
	var/dat = {"<h4><span class='pda_icon [icon]'></span> Virtual Wallet and Balance Check Application</h4>"}
	if(!pda_device.id)
		dat += {"<i>Insert an ID card in the PDA to use this application.</i>"}
	else
		var/MM = pda_device.MM
		var/DD = pda_device.DD
		if(!pda_device.id.virtual_wallet)
			pda_device.id.update_virtual_wallet()
		dat += {"<hr>
			<h5>Virtual Wallet</h5>
			Owner: <b>[pda_device.id.virtual_wallet.owner_name]</b><br>
			Balance: <b>[pda_device.id.virtual_wallet.money]</b>$  <u><a href='byond://?src=\ref[src];printCurrency=1'><span class='pda_icon [icon]'></span>Print Currency</a></u>
			<h6>Transaction History</h6>
			On [MM]/[DD]/[game_year]:
			<ul>
			"}
		var/list/v_log = list()
		for(var/e in pda_device.id.virtual_wallet.transaction_log)
			v_log += e
		for(var/datum/transaction/T in reverseRange(v_log))
			dat += {"<li>\[[T.time]\] [T.amount]$, [T.purpose] at [T.source_terminal]</li>"}
		dat += {"</ul><hr>"}
		if(!(linked_db))
			reconnect_database()
		if(linked_db)
			if(linked_db.activated)
				var/datum/money_account/D = linked_db.attempt_account_access(pda_device.id.associated_account_number, 0, 2, 0)
				if(D)
					dat += {"
						<h5>Bank Account</h5>
						Owner: <b>[D.owner_name]</b><br>
						Balance: <b>[D.money]</b>$
						<h6>Transaction History</h6>
						On [MM]/[DD]/[game_year]:
						<ul>
						"}
					var/list/t_log = list()
					for(var/e in D.transaction_log)
						t_log += e
					for(var/datum/transaction/T in reverseRange(t_log))
						if(T.purpose == "Account creation")//always the last element of the reverse transaction_log
							dat += {"</ul>
								On [(DD == 1) ? "[((MM-2)%12)+1]" : "[MM]"]/[((DD-2)%30)+1]/[(DD == MM == 1) ? "[game_year - 1]" : "[game_year]"]:
								<ul>
								<li>\[[T.time]\] [T.amount]$, [T.purpose] at [T.source_terminal]</li>
								</ul>"}
						else
							dat += {"<li>\[[T.time]\] [T.amount]$, [T.purpose] at [T.source_terminal]</li>"}
					if(!D.transaction_log.len)
						dat += {"</ul>"}
				else
					dat += {"
						<h5>Bank Account</h5>
						<i>Unable to access bank account. Either its security settings don't allow remote checking or the account is nonexistent.</i>
						"}
			else
				dat += {"
					<h5>Bank Account</h5>
					<i>Unfortunately your station's Accounts Database doesn't allow remote access. Negociate with your HoP or Captain to solve this issue.</i>
					"}
		else
			dat += {"
				<h5>Bank Account</h5>
				<i>Unable to connect to accounts database. The database is either nonexistent, inoperative, or too far away.</i>
				"}
	return dat

/datum/pda_app/balance_check/Topic(href, href_list)
	if(..())
		return
	if(href_list["printCurrency"])
		var/mob/user = usr
		var/amount = round(input("How much money do you wish to print?", "Currency Printer", 0) as num)
		if(!amount || (amount < 0) || (pda_device.id.virtual_wallet.money <= 0))
			to_chat(user, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Invalid value.'</span>")
			return
		if(amount > pda_device.id.virtual_wallet.money)
			amount = pda_device.id.virtual_wallet.money
		if(amount > 10000) // prevent crashes
			to_chat(user, "[bicon(pda_device)]<span class='notice'>The PDA's screen flashes, 'Maximum single withdrawl limit reached, defaulting to 10,000.'</span>")
			amount = 10000

		if(withdraw_arbitrary_sum(user,amount))
			pda_device.id.virtual_wallet.money -= amount
			if(prob(50))
				playsound(pda_device, 'sound/items/polaroid1.ogg', 50, 1)
			else
				playsound(pda_device, 'sound/items/polaroid2.ogg', 50, 1)

			new /datum/transaction(pda_device.id.virtual_wallet, "Currency printed", "-[amount]", pda_device.name, user.name)
	refresh_pda()

/datum/pda_app/balance_check/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if((pda_device.loc && (DB.z == pda_device.loc.z)) || (DB.z == map.zMainStation))
			if((DB.stat == 0) && DB.activated )//If the database if damaged or not powered, people won't be able to use the app anymore.
				linked_db = DB
				break

//Convert money from the virtual wallet into physical bills
/datum/pda_app/balance_check/proc/withdraw_arbitrary_sum(var/mob/user,var/arbitrary_sum)
	if(!linked_db)
		reconnect_database() //Make one attempt to reconnect
	if(!linked_db || !linked_db.activated || linked_db.stat & (BROKEN|NOPOWER))
		to_chat(user, "[bicon(pda_device)] <span class='warning'>No connection to account database.</span>")
		return 0
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_id,/obj/item/weapon/storage/wallet))
			dispense_cash(arbitrary_sum,H.wear_id)
			to_chat(usr, "[bicon(pda_device)]<span class='notice'>Funds were transferred into your physical wallet!</span>")
			return 1
	var/list/L = dispense_cash(arbitrary_sum,get_turf(src))
	for(var/obj/I in L)
		user.put_in_hands(I)
	return 1

/datum/pda_app/balance_check/Destroy()
	linked_db = null
	..()

/datum/pda_app/atmos_scan
	name = "Atmospheric Scan"
	desc = "Provides a readout of atmospheric data around the user."
	category = "Utilities"
	price = 0
	icon = "pda_atmos"

/datum/pda_app/atmos_scan/get_dat(var/mob/user)
	var/dat = "<h4><span class='pda_icon pda_atmos'></span> Atmospheric Readings</h4>"

	if (isnull(user.loc))
		dat += "Unable to obtain a reading.<br>"
	else
		var/datum/gas_mixture/environment = user.loc.return_air()

		if(!environment)
			dat += "No gasses detected.<br>"

		else
			var/pressure = environment.return_pressure()
			var/total_moles = environment.total_moles()

			dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

			if (total_moles)
				var/o2_level = environment[GAS_OXYGEN]/total_moles
				var/n2_level = environment[GAS_NITROGEN]/total_moles
				var/co2_level = environment[GAS_CARBON]/total_moles
				var/plasma_level = environment[GAS_PLASMA]/total_moles
				var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

				dat += {"Nitrogen: [round(n2_level*100)]%<br>
					Oxygen: [round(o2_level*100)]%<br>
					Carbon Dioxide: [round(co2_level*100)]%<br>
					Plasma: [round(plasma_level*100)]%<br>"}
				if(unknown_level > 0.01)
					dat += "OTHER: [round(unknown_level)]%<br>"
			dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"
	return dat

/datum/pda_app/light
	name = "Flashlight"
	desc = "Turns on the PDA flashlight."
	category = "Utilities"
	price = 0
	has_screen = FALSE
	icon = "pda_flashlight"
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 2 //Luminosity for the flashlight function

/datum/pda_app/light/onInstall()
	..()
	name = "[fon ? "Disable" : "Enable"] Flashlight"
	f_lum = pda_device && (locate(/datum/pda_app/light_upgrade) in pda_device.applications) ? 3 : 2

/datum/pda_app/light/onUninstall()
	fon = 0
	if(pda_device)
		pda_device.set_light(0)
	..()

/datum/pda_app/light/on_select(var/mob/user)
	if(pda_device)
		if(fon)
			fon = 0
			pda_device.set_light(0)
		else
			fon = 1
			pda_device.set_light(f_lum)
	name = "[fon ? "Disable" : "Enable"] Flashlight"
