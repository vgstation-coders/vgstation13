///PDA apps by Deity Link///

//Menu values
var/global/list/pda_app_menus = list(
	PDA_APP_ALARM,
	PDA_APP_RINGER,
	PDA_APP_SPAMFILTER,
	PDA_APP_BALANCECHECK,
	PDA_APP_STATIONMAP,
	PDA_APP_NEWSREADER,
	PDA_APP_SNAKEII,
	PDA_APP_MINESWEEPER,
	PDA_APP_SPESSPETS,
	)

/datum/pda_app
	var/name = "Template Application"
	var/desc = "Template Description"
	var/price = 10
	var/menu = 0	//keep it at 0 if your app doesn't need its own menu on the PDA
	var/obj/item/device/pda/pda_device = null
	var/icon = null	//name of the icon that appears in front of the app name on the PDA, example: "pda_game.png"
	var/no_refresh = 0

/datum/pda_app/proc/onInstall(var/obj/item/device/pda/device)
	if(istype(device))
		pda_device = device
		pda_device.applications += src

/datum/pda_app/proc/get_dat()
	return ""

/datum/pda_app/Topic(href, href_list)
	if(..())
		return TRUE

	var/mob/living/U = usr

	if (!pda_device.can_use(U)) //From PDA, double check here
		U.unset_machine()
		U << browse(null, "window=pda")
		return TRUE

	pda_device.add_fingerprint(U)
	U.set_machine(pda_device)

/datum/pda_app/proc/refresh_pda()
	if(!no_refresh)
		if(usr.machine == pda_device)
			pda_device.attack_self(usr)
		else
			usr.unset_machine()
			usr << browse(null, "window=pda")
	else
		no_refresh = 0

/datum/pda_app/Destroy()
	if(pda_device.applications)
		pda_device.applications -= src
	pda_device = null
	..()

/////////////////////////////////////////////////

/datum/pda_app/ringer
	name = "Ringer"
	desc = "Set the frequency to that of a desk bell to be notified anytime someone presses it."
	price = 10
	menu = PDA_APP_RINGER
	icon = "pda_bell"
	var/frequency = 1457	//	1200 < frequency < 1600 , always end with an odd number.
	var/status = 1			//	0=off 1=on

/datum/pda_app/ringer/get_dat()
	return {"
	<h4>Ringer Application</h4>
	Status: <a href='byond://?src=\ref[src];toggleDeskRinger=1'>[status ? "On" : "Off"]</a><br>
	Frequency:
		<a href='byond://?src=\ref[src];ringerFrequency=-10'>-</a>
		<a href='byond://?src=\ref[src];ringerFrequency=-2'>-</a>
		[format_frequency(frequency)]
		<a href='byond://?src=\ref[src];ringerFrequency=2'>+</a>
		<a href='byond://?src=\ref[src];ringerFrequency=10'>+</a><br>
		<br>
	"}

/datum/pda_app/ringer/Topic(href, href_list)
	if(..())
		return
	if(href_list["toggleDeskRinger"])
		status = !status
	if(href_list["ringerFrequency"])
		var/i = frequency + text2num(href_list["ringerFrequency"])
		if(i < MINIMUM_FREQUENCY)
			i = 1201
		if(i > MAXIMUM_FREQUENCY)
			i = 1599
		frequency = i
	refresh_pda()

/datum/pda_app/alarm
	name = "Alarm"
	desc = "Set a time for a personal alarm to trigger."
	price = 0
	//menu = PDA_APP_ALARM Don't uncomment, it's listed elsewhere by the clock
	icon = "pda_clock"
	var/target = 0
	var/status = 1			//	0=off 1=on
	var/lasttimer = 0

/datum/pda_app/alarm/get_dat()
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
			no_refresh = 1
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

/datum/pda_app/light_upgrade
	name = "PDA Flashlight Enhancer"
	desc = "Slightly increases the luminosity of your PDA's flashlight."
	price = 60
	icon = "pda_flashlight"

/datum/pda_app/light_upgrade/onInstall()
	..()
	pda_device.f_lum = 3
	if(pda_device.fon)
		pda_device.set_light(pda_device.f_lum)

/datum/pda_app/spam_filter
	name = "Spam Filter"
	desc = "Spam messages won't ring your PDA anymore. Enjoy the quiet."
	price = 30
	menu = PDA_APP_SPAMFILTER
	icon = "pda_mail"
	var/function = 1	//0=do nothing 1=conceal the spam 2=block the spam

/datum/pda_app/spam_filter/get_dat()
	return {"
		<h4>Spam Filtering Application</h4>
		<ul>
		<li>[(function == 2) ? "<b>Block the spam.</b>" : "<a href='byond://?src=\ref[src];setFilter=1;filter=2'>Block the spam.</a>"]</li>
		<li>[(function == 1) ? "<b>Conceal the spam.</b>" : "<a href='byond://?src=\ref[src];setFilter=1;filter=1'>Conceal the spam.</a>"]</li>
		<li>[(function == 0) ? "<b>Do nothing.</b>" : "<a href='byond://?src=\ref[src];setFilter=1;filter=0'>Do nothing.</a>"]</li>
		</ul>
		"}

/datum/pda_app/spam_filter/Topic(href, href_list)
	if(..())
		return
	if(href_list["setFilter"])
		function = text2num(href_list["filter"])
	refresh_pda()

/datum/pda_app/balance_check
	name = "Virtual Wallet and Balance Check"
	desc = "Connects to the Account Database to check the balance history the inserted ID card."
	price = 0
	icon = "pda_money"
	menu = PDA_APP_BALANCECHECK
	var/obj/machinery/account_database/linked_db

/datum/pda_app/balance_check/onInstall()
	..()
	reconnect_database()

/datum/pda_app/balance_check/get_dat()
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

/datum/pda_app/station_map
	name = "Station Holo-Map ver. 2.0"
	desc = "Displays a holo-map of the station. Useful for finding your way."
	price = 50
	menu = PDA_APP_STATIONMAP
	icon = "pda_map"
	var/obj/item/device/station_map/holomap = null

/datum/pda_app/station_map/onInstall(var/obj/item/device/pda/device)
	..()
	if (istype(device))
		holomap = new(device)

/datum/pda_app/station_map/Destroy()
	if (holomap)
		qdel(holomap)
		holomap = null
	..()

/datum/pda_app/newsreader
	name = "Newsreader"
	desc = "Access to the latest news from the comfort of your pocket."
	price = 40
	menu = PDA_APP_NEWSREADER
	icon = "pda_news"
	var/datum/feed_channel/viewing_channel
	var/screen = NEWSREADER_CHANNEL_LIST

/datum/pda_app/newsreader/proc/newsAlert(var/channel_name)
	if(pda_device.silent)
		return
	var/turf/T = get_turf(pda_device)
	playsound(T, 'sound/machines/twobeep.ogg', 50, 1)
	for (var/mob/O in hearers(3, T))
		O.show_message(text("[bicon(pda_device)] [channel_name ? "Breaking news from [channel_name]" : "Attention! Wanted issue distributed!"]!"))