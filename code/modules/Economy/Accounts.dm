var/current_date_string
var/num_financial_terminals = 1
var/num_financial_database = 1
var/num_vending_machines = 1
var/num_pda_terminals = 1
var/num_merch_computers = 1
var/datum/money_account/station_account
var/list/datum/money_account/department_accounts = list()
var/next_account_number = 0
var/obj/machinery/account_database/centcomm_account_db
var/datum/money_account/vendor_account
var/list/all_money_accounts = list()
var/list/all_station_accounts = list()
var/datum/money_account/trader_account

var/station_allowance = 0//This is what Nanotrasen will send to the Station Account after every salary, as provision for the next salary.
var/latejoiner_allowance = 0//Added to station_allowance and reset before every wage payout.
var/station_funding = 0 //A bonus to the station allowance that persists between cycles. Admins can set this on the database.
var/station_bonus = 0 //A bonus to station allowance that gets reset after wage payout. Admins can boost this too.

/proc/create_station_account()
	if(!station_account)
		next_account_number = rand(11111, 99999)
		station_account = new()
		station_account.owner_name = "[station_name()] Station Account"
		station_account.account_number = rand(11111, 99999)
		station_account.remote_access_pin = rand(1111, 9999)
		station_account.money = 0//The money is distributed by Nanotrasen in prevision for the next salary.
		station_account.wage_gain = 0//Salary money is taken from this account, so no more getting money out of nowhere.

		//create an entry in the account transaction log for when it was created
		new /datum/transaction(station_account,"Account creation",0,"Biesel GalaxyNet Terminal #277",date = "2nd April, [game_year]",time = "11:24")

		//add the account
		all_money_accounts.Add(station_account)

/proc/create_department_account(department, var/receives_wage = 0)
	next_account_number = rand(111111, 999999)

	var/datum/money_account/department_account = new()
	department_account.owner_name = "[department] Account"
	department_account.account_number = rand(11111, 99999)
	department_account.remote_access_pin = rand(1111, 9999)
	department_account.money = DEPARTMENT_START_FUNDS
	if(receives_wage == 1)
		department_account.wage_gain = DEPARTMENT_START_WAGE
		station_allowance += DEPARTMENT_START_WAGE + round(DEPARTMENT_START_WAGE/10)//overhead of 10%

	//create an entry in the account transaction log for when it was created
	new /datum/transaction(department_account, "Account creation", department_account.money, "Biesel GalaxyNet Terminal #277",\
							date = "2nd April, [game_year]", time = "11:24", send2PDAs = FALSE)

	//add the account
	all_money_accounts.Add(department_account)

	all_station_accounts.Add(department_account)

	department_accounts[department] = department_account

//the current ingame time (hh:mm) can be obtained by calling:
//worldtime2text()

/proc/create_account(var/new_owner_name = "Default user", var/starting_funds = 0, var/obj/machinery/account_database/source_db, var/wage_payout = 0, var/security_pref = 1, var/ratio_pref = 0.5, var/makehidden = FALSE, var/isStationAccount = TRUE)

	//create a new account
	var/datum/money_account/M = new()
	M.owner_name = new_owner_name
	M.remote_access_pin = rand(1111, 9999)
	M.money = starting_funds
	M.wage_gain = wage_payout
	M.security_level = security_pref
	M.hidden = makehidden
	M.virtual_wallet_wage_ratio = ratio_pref

	var/ourdate = ""
	var/ourtime = ""
	var/ourterminal = ""
	//create an entry in the account transaction log for when it was created
	if(!source_db)
		//set a random date, time and location some time over the past few decades
		var/DD = text2num(time2text(world.timeofday, "DD"))	//For muh lore we'll pretend that Nanotrasen changed its account policy
		ourdate = "[(DD == 1) ? "31" : "[DD-1]"] [time2text(world.timeofday, "Month")], [game_year]"	//shortly before the events of the round,
		ourtime = "[rand(0,24)]:[rand(11,59)]"	//prompting everyone to get a new account one day prior.
		ourterminal = "NTGalaxyNet Terminal #[multinum_display(rand(111,1111),4)]"	//The point being to partly to justify the transaction history being empty at the beginning of the round.

		M.account_number = rand(11111, 99999)
	else
		ourdate = current_date_string
		ourtime = worldtime2text()
		ourterminal = source_db.machine_id

		M.account_number = next_account_number
		next_account_number += rand(1,25)

		//create a sealed package containing the account details
		var/obj/item/delivery/P = new /obj/item/delivery(source_db.loc)

		var/obj/item/weapon/paper/R = new /obj/item/weapon/paper(P)
		R.name = "Account information: [M.owner_name]"

		R.info = {"<b>Account details (confidential)</b><br><hr><br>
			<i>Account holder:</i> [M.owner_name]<br>
			<i>Account number:</i> [M.account_number]<br>
			<i>Account pin:</i> [M.remote_access_pin]<br>
			<i>Starting balance:</i> $[M.money]<br>
			<i>Date and time:</i> [worldtime2text()], [current_date_string]<br><br>
			<i>Creation terminal ID:</i> [source_db.machine_id]<br>
			<i>Authorised NT officer overseeing creation:</i> [source_db.held_card.registered_name]<br>"}
		//stamp the paper
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-cent"
		if(!R.stamped)
			R.stamped = new
		R.stamped += /obj/item/weapon/stamp
		R.overlays += stampoverlay
		R.stamps += "<HR><i>This paper has been stamped by the Accounts Database.</i>"

	//add the account
	new /datum/transaction(M,"Account creation",starting_funds,ourterminal,new_owner_name,ourdate,ourtime)
	all_money_accounts.Add(M)
	if (isStationAccount)
		all_station_accounts.Add(M)

	return M

/datum/money_account
	var/owner_name = ""
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/list/transaction_log = list()
	var/security_level = 1	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login
	var/virtual = 0
	var/virtual_wallet_wage_ratio = 50
	var/wage_gain = 0 // How much an account gains per 'wage' tick.
	var/disabled = 0
	var/hidden = FALSE
	// 0 Unlocked
	// 1 User locked
	// 2 Admin locked

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""
	var/source_name = ""

/datum/transaction/New(var/datum/money_account/account=null, var/purpose="", var/amount = 0, var/source_terminal="", var/target_name="", var/date="", var/time = "", var/send2PDAs = TRUE, var/source_name="")
	// Default to account name if not specified
	src.target_name = target_name == "" && account ? account.owner_name : target_name
	// Default to source terminal if not specified
	src.source_name = source_name == "" ? source_terminal : source_name
	src.purpose = purpose
	src.amount = amount
	// Get current date and time if not specified
	src.date = date != "" ? date : current_date_string
	src.time = time != "" ? time : worldtime2text()
	src.source_terminal = source_terminal
	if(account)
		account.transaction_log.Add(src)
		// Automatically ignore sending any zero sum transactions, plus variable to skip the search.
		if(account.account_number && send2PDAs && amount)
			for(var/obj/item/device/pda/PDA in PDAs)
				// Only works and does this if ID is in PDA
				if(PDA.id)
					var/datum/pda_app/balance_check/app = locate(/datum/pda_app/balance_check) in PDA.applications
					if(app && app.linked_db && account == app.linked_db.attempt_account_access(PDA.id.associated_account_number, 0, 2, 0))
						var/turf/U = get_turf(PDA)
						var/datum/pda_app/messenger/app2 = locate(/datum/pda_app/messenger) in PDA.applications
						if(app2 && !app2.silent)
							playsound(U, 'sound/machines/twobeep.ogg', 50, 1)
						for (var/mob/O in hearers(3, U))
							if(app2 && !app2.silent)
								O.show_message(text("[bicon(PDA)] *[app2.ttone]*"))
						var/mob/living/L = null
						if(PDA.loc && isliving(PDA.loc))
							L = PDA.loc
						else
							L = get_holder_of_type(PDA, /mob/living/silicon)
						if(L)
							to_chat(L,"[bicon(PDA)] <b>Money transfer from [source_terminal] ([amount]$).</b>")

/obj/machinery/account_database
	name = "accounts database"
	desc = "Holds transaction logs, account data and all kinds of other financial records."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "account_db"
	density = TRUE
	anchored = TRUE
	req_one_access = list(access_hop, access_captain)
	var/receipt_num
	var/machine_id = ""
	var/obj/item/weapon/card/id/held_card
	var/access_level = 0
	var/datum/money_account/detailed_account_view
	var/creating_new_account = 0
	var/activated = 1

	machine_flags = EMAGGABLE | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL

/obj/machinery/account_database/New(loc)
	..(loc)

	update_moody_light('icons/lighting/moody_lights.dmi', "overlay_account")

	if(!station_account)
		create_station_account()

	if(department_accounts.len == 0)
		for(var/department in station_departments)
			create_department_account(department, receives_wage = 1)
	if(!vendor_account)
		vendor_account = create_account("Vendor", 0, null, 0, 1, 0, TRUE, FALSE)

	if(!current_date_string)
		current_date_string = "[time2text(world.timeofday, "DD")] [time2text(world.timeofday, "Month")], [game_year]"

	machine_id = "[station_name()] Account Database #[multinum_display(num_financial_database,4)]"
	num_financial_database++

	account_DBs += src

	if(ticker)
		initialize()

/obj/machinery/account_database/initialize()
	..()

	if(z == map.zCentcomm && isnull(centcomm_account_db))
		centcomm_account_db = src

/obj/machinery/account_database/Destroy()
	if(centcomm_account_db == src)
		centcomm_account_db = null

	..()

/obj/machinery/account_database/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(isAdminGhost(user) || is_malf_owner(user) || (ishuman(user) && !user.stat && get_dist(src,user) <= 1))
		var/dat = "<b>Accounts Database</b><br>"

		dat += {"<i>[machine_id]</i><br>
			Confirm identity: <a href='?src=\ref[src];choice=insert_card'>[held_card ? held_card : "-----"]</a><br>"}
		if(access_level > 0 || isAdminGhost(user) || is_malf_owner(user))

			dat += {"<a href='?src=\ref[src];toggle_activated=1'>[activated ? "Disable" : "Enable"] remote access</a><br>
				Combined department and personnel budget is currently [station_allowance+station_bonus+station_funding] credits. A total of [global.requested_payroll_amount] credits were requested during the last payroll cycle.<br>"}
			if(station_bonus || isAdminGhost(user))
				dat += "The budget was increased by a bonus of [station_bonus] this cycle. [isAdminGhost(user) ? "<a href='?src=\ref[src];choice=addbonus;'>Adjust</a>" : ""]<br>"
			if(station_funding || isAdminGhost(user))
				dat += "Central Command has earmarked an additional [station_funding] for the budget. [isAdminGhost(user) ? "<a href='?src=\ref[src];choice=addfunding;'>Adjust</a>" : ""]<br>"
			if(creating_new_account)

				dat += {"<br>
					<a href='?src=\ref[src];choice=view_accounts_list;'>Return to accounts list</a>
					<form name='create_account' action='?src=\ref[src]' method='get'>
					<input type='hidden' name='src' value='\ref[src]'>
					<input type='hidden' name='choice' value='finalise_create_account'>
					<b>Holder name:</b> <input type='text' id='holder_name' name='holder_name' style='width:250px; background-color:white;'><br>
					<b>Initial funds:</b> <input type='text' id='starting_funds' name='starting_funds' style='width:250px; background-color:white;'> (subtracted from station account.)<br>
					<i>New accounts are automatically assigned a secret number and pin, which are printed separately in a sealed package.</i><br>
					<b>Ensure that the station account has enough money to create the account, or it will not be created</b>
					<input type='submit' value='Create'><br>
					</form>"}
			else
				if(detailed_account_view)

					dat += {"<br>
						<a href='?src=\ref[src];choice=view_accounts_list;'>Return to accounts list</a><hr>
						<b>Account number:</b> #[detailed_account_view.account_number]<br>
						<b>Account holder:</b> [detailed_account_view.owner_name]<br>
						<b>Account balance:</b> $[detailed_account_view.money]<br>
						<b>Assigned wage payout:</b> $[detailed_account_view.wage_gain] <a href='?src=\ref[src];choice=edit_wage_payout;account_num=[detailed_account_view.account_number]'>Edit</a><br>
						<b>Account status:</b> "}
					switch(detailed_account_view.disabled)
						if(0)
							dat += "Enabled"
						if(1)
							dat += "User Disabled"
						if(2)
							dat += "Administratively Disabled"
						else
							dat += "???ERROR???"
					dat += {"<br>
						<a href='?src=\ref[src];choice=toggle_account;'>Administratively [detailed_account_view.disabled ? "enable" : "disable"] account</a><br>
						<table border=1 style='width:100%'>
						<tr>
						<td><b>Date</b></td>
						<td><b>Time</b></td>
						<td><b>Target</b></td>
						<td><b>Purpose</b></td>
						<td><b>Value</b></td>
						<td><b>Source terminal ID</b></td>
						</tr>"}
					for(var/datum/transaction/T in detailed_account_view.transaction_log)

						dat += {"<tr>
							<td>[T.date]</td>
							<td>[T.time]</td>
							<td>[T.target_name]</td>
							<td>[T.purpose]</td>
							<td>$[T.amount]</td>
							<td>[T.source_terminal]</td>
							</tr>"}
					dat += "</table>"
				else

					dat += {"<a href='?src=\ref[src];choice=create_account;'>Create new account</a><br><br>
						<table border=1 style='width:100%'>"}
					for(var/i=1, i<=all_money_accounts.len, i++)
						var/datum/money_account/D = all_money_accounts[i]
						if(D.hidden)
							continue

						dat += {"<tr>
							<td>#[D.account_number]</td>
							<td>[D.owner_name]</td>
							<td><a href='?src=\ref[src];choice=view_account_detail;account_index=[i]'>View in detail</a></td>
							</tr>"}
					dat += "</table>"
		user << browse(dat,"window=account_db;size=700x650")
	else
		user << browse(null,"window=account_db")

/obj/machinery/account_database/attackby(var/obj/O, var/mob/user)
	. = ..()
	if(.)
		return
	if(isID(O))
		var/obj/item/weapon/card/id/idcard = O
		if(access_level == 3)
			return attack_hand(user)
		if(!held_card)
			if(usr.drop_item(O, src))
				held_card = idcard

				if(access_cent_captain in idcard.access)
					access_level = 2
				else if((access_hop in idcard.access) || (access_captain in idcard.access))
					access_level = 1
	if(issolder(O) && emagged)
		var/obj/item/tool/solder/S = O
		if(!S.remove_fuel(4,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		if(do_after(user, src,4 SECONDS * S.work_speed))
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
			emagged = FALSE
			access_level = 0
			to_chat(user, "<span class='notice'>You repair the security checks on \the [src].</span>")

/obj/machinery/account_database/emag_act(mob/user)
	if(emagged)
		emagged = 0
		access_level = 0
		if(held_card)
			var/obj/item/weapon/card/id/C = held_card
			if(access_cent_captain in C.access)
				access_level = 2
			else if((access_hop in C.access) || (access_captain in C.access))
				access_level = 1
		attack_hand(user)
		to_chat(user, "<span class='notice'>You re-enable the security checks of [src].</span>")
	else
		emagged = 1
		access_level = 3
		to_chat(user, "<span class='warning'>You disable the security checks of [src].</span>")
	return

/obj/machinery/account_database/Topic(var/href, var/href_list)
	if(..())
		return 1
	if(href_list["toggle_activated"])
		activated = !activated

	if(href_list["choice"])
		switch(href_list["choice"])
			if("create_account")
				creating_new_account = 1
			if("finalise_create_account")
				var/account_name = href_list["holder_name"]
				var/starting_funds = max(text2num(href_list["starting_funds"]), 0)
				if ((station_account.money - starting_funds) > 0)
					station_account.money -= starting_funds
					if(starting_funds >0)
						//Create a transaction log entry if you need to
						new /datum/transaction(station_account, "New account funds initialisation", "([starting_funds])",\
												machine_id, account_name, send2PDAs = FALSE)
					create_account(account_name, starting_funds, src)
					creating_new_account = 0
			if("insert_card")
				if(held_card)
					held_card.forceMove(src.loc)
					if(ishuman(usr) && !usr.get_active_hand())
						usr.put_in_hands(held_card)
					held_card = null
					if(access_level < 3)
						access_level = 0
				else
					var/obj/item/I = usr.get_active_hand()
					if(emag_check(I,usr))
						return
					if (istype(I, /obj/item/weapon/card/id))
						var/obj/item/weapon/card/id/C = I
						if(usr.drop_item(C, src))
							held_card = C
							if(access_level < 3)
								if(access_cent_captain in C.access)
									access_level = 2
								else if((access_hop in C.access) || (access_captain in C.access))
									access_level = 1
			if("view_account_detail")
				var/index = text2num(href_list["account_index"])
				if(index && index <= all_money_accounts.len)
					detailed_account_view = all_money_accounts[index]
			if("view_accounts_list")
				detailed_account_view = null
				creating_new_account = 0
			if("addfunding")
				if(!isAdminGhost(usr))
					return
				var/new_funding = input(usr, "Adjust the budget for ALL cycles", "Adjust by", station_funding) as null|num
				station_funding = new_funding
			if("addbonus")
				if(!isAdminGhost(usr))
					return
				var/new_bonus = input(usr, "Adjust the budget for THIS cycles", "Adjust by", station_bonus) as null|num
				station_bonus = new_bonus
			if("toggle_account")
				if(detailed_account_view)
					detailed_account_view.disabled = detailed_account_view.disabled ? 0 : 2
			if("edit_wage_payout")
				var/acc_num = text2num(href_list["account_num"])
				var/datum/money_account/acc = get_money_account_global(acc_num)
				if(acc)
					var/new_payout = input(usr, "Select a new payout for this account", "New payout", acc.wage_gain) as null|num
					if(new_payout >= 0 && new_payout != null)
						if(new_payout > ARBITRARILY_LARGE_NUMBER)
							//10x what the entire station should be earning
							spark(loc, 3, FALSE)
							visible_message("<span class='warning'>\The [src] shoots out sparks!</span>")
							return
						if(!isAdminGhost(usr))
							//Admin ghosts never trigger audit
							var/suspicious_user = held_card ? held_card.registered_name : "ERR;\\ invalid objectName 'ZZTPW00"
							if(requested_payroll_amount && new_payout > requested_payroll_amount)
								//Requesting more than the entire station earned last cycle
								//Doesn't play if this is the first cycle
								var/datum/command_alert/suspicious_wages/SW = new()
								SW.announce(suspicious_user,acc.owner_name)
								qdel(SW)
							if(acc.wage_gain && new_payout > acc.wage_gain*2)
								//Send an audit request to IAA if more than double old age
								//Doesn't send if account had no wage before
								var/obj/item/weapon/paper/audit/P
								for(var/obj/machinery/faxmachine/F in allfaxes)
									if(F.department == "Internal Affairs" && !F.stat)
										flick("faxreceive", F)
										playsound(F.loc, "sound/effects/fax.ogg", 50, 1)
										P = new (F,suspicious_user,acc.owner_name,acc.wage_gain,new_payout)
										spawn(2 SECONDS)
											P.forceMove(F.loc)

						acc.wage_gain = round(new_payout)
					detailed_account_view = acc

	attack_hand(usr)

/obj/machinery/account_database/proc/charge_to_account(var/attempt_account_number, var/source_name, var/purpose, var/terminal_id, var/amount, var/target_name)
	if(!activated || !attempt_account_number)
		return 0
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == attempt_account_number)
			D.money += amount

			//create a transaction log entry
			new /datum/transaction(D, purpose, "[abs(amount)]", terminal_id, source_name, source_name = target_name)

			return 1

	return 0

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/obj/machinery/account_database/proc/attempt_account_access(var/attempt_account_number, var/attempt_pin_number, var/security_level_passed = 0,var/pin_needed=1)
	if(!activated || !attempt_account_number)
		return 0
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == attempt_account_number)
			if( D.security_level <= security_level_passed && (!D.security_level || D.remote_access_pin == attempt_pin_number || !pin_needed) )
				return D

/obj/machinery/account_database/proc/get_account(var/account_number)
	if(!account_number)
		// Don't bother searching if there's no account number.
		return null
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == account_number)
			return D
