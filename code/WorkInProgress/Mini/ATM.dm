/*

TODO:
give money an actual use (QM stuff, vending machines)
send money to people (might be worth attaching money to custom database thing for this, instead of being in the ID)
log transactions

*/

#define NO_SCREEN 0
#define CHANGE_SECURITY_LEVEL 1
#define TRANSFER_FUNDS 2
#define VIEW_TRANSACTION_LOGS 3
#define PRINT_DELAY 100
#define DEBIT_CARD_COST 5
#define CAN_INTERACT_WITH_ACCOUNT authenticated_account && linked_db && !authenticated_account.disabled

/obj/machinery/atm
	name = "Nanotrasen Automatic Teller Machine"
	desc = "For all your monetary needs!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "atm"
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	var/datum/money_account/authenticated_account
	var/number_incorrect_tries = 0
	var/previous_account_number = 0
	var/max_pin_attempts = 3
	var/ticks_left_locked_down = 0
	var/ticks_left_timeout = 0
	var/machine_id = ""
	var/view_screen = NO_SCREEN
	var/lastprint = 0 // Printer needs time to cooldown
	var/obj/item/weapon/card/atm_card = null // Since there's debit cards now, scan doesn't work for us.

	machine_flags = PURCHASER //not strictly true, but it connects it to the account

/obj/machinery/atm/New()
	..()
	machine_id = "[station_name()] ATM #[multinum_display(num_financial_terminals,4)]"
	num_financial_terminals++
	if(ticker)
		initialize()

/obj/machinery/atm/Destroy()
	if(atm_card)
		qdel(atm_card)
		atm_card = null
	..()

/obj/machinery/atm/process()
	if(stat & NOPOWER)
		return

	if(linked_db && ( (linked_db.stat & NOPOWER) || !linked_db.activated ) )
		linked_db = null
		authenticated_account = null
		src.visible_message("<span class='warning'>[bicon(src)] [src] buzzes rudely, \"Connection to remote database lost.\"</span>")
		updateDialog()

	if(ticks_left_timeout > 0)
		ticks_left_timeout--
		if(ticks_left_timeout <= 0)
			authenticated_account = null
	if(ticks_left_locked_down > 0)
		ticks_left_locked_down--
		if(ticks_left_locked_down <= 0)
			number_incorrect_tries = 0

/obj/machinery/atm/attackby(obj/item/I as obj, mob/user as mob)
	if(iswrench(I))
		user.visible_message("<span class='notice'>[user] begins to take apart the [src]!</span>", "<span class='notice'>You start to take apart the [src]</span>")
		if(do_after(user, src, 40))
			user.visible_message("<span class='notice'>[user] disassembles the [src]!</span>", "<span class='notice'>You disassemble the [src]</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
			new /obj/item/stack/sheet/metal (src.loc,2)
			if(atm_card)
				atm_card.forceMove(get_turf(src))
				atm_card = null
			qdel(src)
			return
	if(istype(I, /obj/item/weapon/card))
		if(!atm_card && is_valid_atm_card(I))
			if(usr.drop_item(I, src))
				atm_card = I
				if(authenticated_account && atm_card.associated_account_number != authenticated_account.account_number)
					authenticated_account = null
				src.attack_hand(user)
	else if(CAN_INTERACT_WITH_ACCOUNT)
		if(istype(I,/obj/item/weapon/spacecash))
			var/obj/item/weapon/spacecash/dosh = I
			//consume the money
			authenticated_account.money += dosh.worth * dosh.amount
			if(prob(50))
				playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
			else
				playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)

			//create a transaction log entry
			var/datum/transaction/T = new()
			T.target_name = authenticated_account.owner_name
			T.purpose = "Credit deposit"
			T.amount = dosh.worth * dosh.amount
			T.source_terminal = machine_id
			T.date = current_date_string
			T.time = worldtime2text()
			authenticated_account.transaction_log.Add(T)

			to_chat(user, "<span class='info'>You insert [T.amount] credit\s into \the [src].</span>")
			src.attack_hand(user)
			qdel(I)
	else
		..()

/obj/machinery/atm/proc/is_valid_atm_card(obj/item/I)
	// Since we can now have IDs and debit cards that can be used
	if(istype(I, /obj/item/weapon/card/debit) || istype(I, /obj/item/weapon/card/id))
		return TRUE
	else
		return FALSE
/obj/machinery/atm/proc/get_card_name_or_account()
	if(!atm_card)
		return "------"
	if(istype(atm_card, /obj/item/weapon/card/debit))
		return "DEBIT [atm_card.associated_account_number]"
	if(istype(atm_card, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/card_id = atm_card
		return card_id.name

/obj/machinery/atm/attack_hand(mob/user as mob,var/fail_safe=0)
	if(isobserver(user) && !isAdminGhost(user))
		to_chat(user, "<span class='warning'>Your ghostly limb passes right through \the [src].</span>")
		return
	if(istype(user, /mob/living/silicon))
		to_chat(user, "<span class='warning'>Artificial unit recognized. Artificial units do not currently receive monetary compensation, as per Nanotrasen regulation #1005.</span>")
		return
	if(get_dist(src,user) <= 1 || isAdminGhost(user))
		//check to see if the user has low security enabled
		if(!fail_safe)
			scan_user(user)

		//js replicated from obj/machinery/computer/card
		var/dat = {"<h1>Nanotrasen Automatic Teller Machine</h1>
			For all your monetary needs!<br>
			<i>This terminal is</i> [machine_id]. <i>Report this code when contacting Nanotrasen IT Support</i><br/>
			Card: <a href='?src=\ref[src];choice=insert_card'>[get_card_name_or_account()]</a><br><br><hr>"}
		if(ticks_left_locked_down > 0)
			dat += "<span class='alert'>Maximum number of pin attempts exceeded! Access to this ATM has been temporarily disabled.</span>"
		else if(authenticated_account)
			if(authenticated_account.disabled && view_screen != CHANGE_SECURITY_LEVEL)
				dat += "<b>ACCOUNT DISABLED</b><br><hr>"
				if(authenticated_account.disabled < 2)
					dat += "<A href='?src=\ref[src];choice=toggle_account'>Toggle account status</a><br>"
					dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=1'>Change account security level</a><br>"
					dat += "<A href='?src=\ref[src];choice=logout'>Logout</a><br>"
				else
					dat += "Contact your Head of Personnel for more information.<br>"
			else
				switch(view_screen)
					if(CHANGE_SECURITY_LEVEL)
						dat += "Select a new security level for this account:<br><hr>"
						var/text = "Zero - Either the account number or card is required to access this account. Vendor transactions will pay from your bank account if your virtual wallet has insufficient funds."
						if(authenticated_account.security_level != 0)
							if(authenticated_account.disabled)
								text = "<b>ACCOUNT DISABLED CAN NOT USE</b><br><s>[text]</s>"
							else
								text = "<A href='?src=\ref[src];choice=change_security_level;new_security_level=0'>[text]</a>"
						dat += "[text]<hr>"
						text = "One - An account number and pin must be manually entered to access this account and process transactions."
						if(authenticated_account.security_level != 1)
							text = "<A href='?src=\ref[src];choice=change_security_level;new_security_level=1'>[text]</a>"
						dat += "[text]<hr>"
						text = "Two - In addition to account number and pin, a card is required to access this account and process transactions."
						if(authenticated_account.security_level != 2)
							text = "<A href='?src=\ref[src];choice=change_security_level;new_security_level=2'>[text]</a>"
						dat += {"[text]<hr><br>
							<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a>"}
					if(VIEW_TRANSACTION_LOGS)
						dat += {"<b>Transaction logs</b><br>
							<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a>
							<table border=1 style='width:100%'>
							<tr>
							<td><b>Date</b></td>
							<td><b>Time</b></td>
							<td><b>Target</b></td>
							<td><b>Purpose</b></td>
							<td><b>Value</b></td>
							<td><b>Source terminal ID</b></td>
							</tr>"}
						for(var/datum/transaction/T in authenticated_account.transaction_log)
							dat += {"<tr>
								<td>[T.date]</td>
								<td>[T.time]</td>
								<td>[T.target_name]</td>
								<td>[T.purpose]</td>
								<td>$[T.amount]</td>
								<td>[T.source_terminal]</td>
								</tr>"}
						dat += "</table>"
					if(TRANSFER_FUNDS)
						dat += {"<b>Bank Account balance:</b> $[authenticated_account.money]<br>
							<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a><br><br>
							<form name='transfer' action='?src=\ref[src]' method='get'>
							<input type='hidden' name='src' value='\ref[src]'>
							<input type='hidden' name='choice' value='transfer'>
							Target account number: <input type='text' name='target_acc_number' value='' style='width:200px; background-color:white;'><br>
							Funds to transfer: <input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><br>
							Transaction purpose: <input type='text' name='purpose' value='Funds transfer' style='width:200px; background-color:white;'><br>
							<input type='submit' value='Transfer funds'><br>
							</form>"}
					else
						dat += {"Welcome, <b>[authenticated_account.owner_name].</b><br/>
							<b>Account balance:</b> $[authenticated_account.money]
							<form name='withdrawal' action='?src=\ref[src]' method='get'>
							<input type='hidden' name='src' value='\ref[src]'>
							<input type='hidden' name='choice' value='withdrawal'>
							<input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><input type='submit' value='Withdraw funds'><br>
							</form><hr>
							"}
						if(atm_card)
							if(istype(atm_card, /obj/item/weapon/card/id))
								var/obj/item/weapon/card/id/card_id = atm_card
								dat += {"
									<b>Virtual Wallet balance:</b> $[card_id.virtual_wallet.money]<br>
									<form name='withdraw_to_wallet' action='?src=\ref[src]' method='get'>
									<input type='hidden' name='src' value='\ref[src]'>
									<input type='hidden' name='choice' value='withdraw_to_wallet'>
									<input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><input type='submit' value='Withdraw to virtual wallet'><br>
									</form>
									<form name='deposit_from_wallet' action='?src=\ref[src]' method='get'>
									<input type='hidden' name='src' value='\ref[src]'>
									<input type='hidden' name='choice' value='deposit_from_wallet'>
									<input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><input type='submit' value='Deposit from virtual wallet'><br>
									</form><hr>
									"}
							else if(istype(atm_card, /obj/item/weapon/card/debit))
								var/obj/item/weapon/card/debit/card_debit = atm_card
								dat += {"
									<b>Debit Card Authorized User:</b> [card_debit.authorized_name]<br>
									<form name='change_debit_authorized_name' action='?src=\ref[src]' method='get'>
									<input type='hidden' name='src' value='\ref[src]'>
									<input type='hidden' name='choice' value='change_debit_authorized_name'>
									<input type='text' name='new_debit_name' value='[card_debit.authorized_name]' style='width:200px; background-color:white;'><input type='submit' value='Change'><br>
									</form><hr>
									"}
						else
							dat += {"
								<i>Insert an ID card to perform fund transfers to/from it.</i><br>
								"}
						dat += {"
							<A href='?src=\ref[src];choice=view_screen;view_screen=1'>Change account security level</a><br>
							<A href='?src=\ref[src];choice=view_screen;view_screen=2'>Make transfer to another bank account</a><br>
							<A href='?src=\ref[src];choice=view_screen;view_screen=3'>View transaction log</a><br>
							<A href='?src=\ref[src];choice=balance_statement'>Print balance statement</a><br>
							<A href='?src=\ref[src];choice=create_debit_card'>Print new debit card ($5)</a><br>
							<A href='?src=\ref[src];choice=toggle_account'>Toggle account status</a><br>
							<A href='?src=\ref[src];choice=logout'>Logout</a><br>
							"}
		else if(linked_db)
			dat += {"<form name='atm_auth' action='?src=\ref[src]' method='get'>
				<input type='hidden' name='src' value='\ref[src]'>
				<input type='hidden' name='choice' value='attempt_auth'>
				<b>Account:</b> <input type='text' id='account_num' name='account_num' style='width:250px; background-color:white;'><br>
				<b>PIN:</b> <input type='text' id='account_pin' name='account_pin' style='width:250px; background-color:white;'><br>
				<input type='submit' value='Submit'><br>
				</form>"}
		else
			dat += "<span class='warning'>Unable to connect to accounts database, please retry and if the issue persists contact Nanotrasen IT support.</span>"
			reconnect_database()

		user << browse(dat,"window=atm;size=550x650")
	else
		user << browse(null,"window=atm")

/obj/machinery/atm/Topic(var/href, var/href_list)
	if(..())
		return 1
	var/failsafe = 0
	if(href_list["choice"])
		switch(href_list["choice"])
			if("toggle_account")
				if(authenticated_account && linked_db && authenticated_account.disabled < 2)
					authenticated_account.disabled = !authenticated_account.disabled
					to_chat(usr, "[bicon(src)]<span class='info'>Account [authenticated_account.disabled ? "disabled" : "enabled"].</span>")
			if("transfer")
				if(CAN_INTERACT_WITH_ACCOUNT)
					var/transfer_amount = text2num(href_list["funds_amount"])
					if(transfer_amount <= 0)
						alert("That is not a valid amount.")
					else if(transfer_amount <= authenticated_account.money)
						var/target_account_number = text2num(href_list["target_acc_number"])
						var/transfer_purpose = copytext(sanitize(href_list["purpose"]),1,MAX_MESSAGE_LEN)
						if(linked_db.charge_to_account(target_account_number, authenticated_account.owner_name, transfer_purpose, machine_id, transfer_amount))
							to_chat(usr, "[bicon(src)]<span class='info'>Funds transfer successful.</span>")
							authenticated_account.money -= transfer_amount

							//create an entry in the account transaction log
							var/datum/transaction/T = new()
							T.target_name = "Account #[target_account_number]"
							T.purpose = transfer_purpose
							T.source_terminal = machine_id
							T.date = current_date_string
							T.time = worldtime2text()
							T.amount = "-[transfer_amount]"
							authenticated_account.transaction_log.Add(T)
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>Funds transfer failed.</span>")

					else
						to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")
			if("view_screen")
				view_screen = text2num(href_list["view_screen"])
			if("change_security_level")
				if(authenticated_account && linked_db && authenticated_account.disabled < 2)
					var/new_sec_level = max( min(text2num(href_list["new_security_level"]), 2), authenticated_account.disabled ? 1 : 0)
					// If the account is disabled, prevent downgrading to level 0
					authenticated_account.security_level = new_sec_level
			if("attempt_auth")
				if(linked_db && !ticks_left_locked_down)
					var/tried_account_num = text2num(href_list["account_num"])
					if(!tried_account_num && atm_card)
						tried_account_num = atm_card.associated_account_number
					var/tried_pin = text2num(href_list["account_pin"])

					authenticated_account = linked_db.attempt_account_access(tried_account_num, tried_pin, atm_card && atm_card.associated_account_number == tried_account_num ? 2 : 1)
					if(!authenticated_account)
						number_incorrect_tries++
						if(previous_account_number == tried_account_num)
							if(number_incorrect_tries > max_pin_attempts)
								//lock down the atm
								ticks_left_locked_down = 30
								playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)

								//create an entry in the account transaction log
								var/datum/money_account/failed_account = linked_db.get_account(tried_account_num)
								if(failed_account)
									var/datum/transaction/T = new()
									T.target_name = failed_account.owner_name
									T.purpose = "Unauthorised login attempt"
									T.source_terminal = machine_id
									T.date = current_date_string
									T.time = worldtime2text()
									failed_account.transaction_log.Add(T)
							else
								to_chat(usr, "<span class='warning'>[bicon(src)] Incorrect pin/account combination entered, [max_pin_attempts - number_incorrect_tries] attempts remaining.</span>")
								previous_account_number = tried_account_num
								playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
						else
							to_chat(usr, "<span class='warning'>[bicon(src)] incorrect pin/account combination entered.</span>")
							number_incorrect_tries = 0
					else
						playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
						ticks_left_timeout = 120
						view_screen = NO_SCREEN

						//create a transaction log entry
						var/datum/transaction/T = new()
						T.target_name = authenticated_account.owner_name
						T.purpose = "Remote terminal access"
						T.source_terminal = machine_id
						T.date = current_date_string
						T.time = worldtime2text()
						authenticated_account.transaction_log.Add(T)

						to_chat(usr, "<span class='notice'>[bicon(src)] Access granted. Welcome user '[authenticated_account.owner_name].'</span>")

					previous_account_number = tried_account_num
			if("withdrawal")
				if(CAN_INTERACT_WITH_ACCOUNT)
					var/amount = max(text2num(href_list["funds_amount"]),0)
					if(amount <= 0)
						alert("That is not a valid amount.")
					else if(authenticated_account && amount > 0)
						if(amount <= authenticated_account.money)
							playsound(src, 'sound/machines/chime.ogg', 50, 1)

							//remove the money
							if(amount > 10000) // prevent crashes
								to_chat(usr, "<span class='notice'>The ATM's screen flashes, 'Maximum single withdrawl limit reached, defaulting to 10,000.'</span>")
								amount = 10000
							authenticated_account.money -= amount
							withdraw_arbitrary_sum(usr,amount)

							//create an entry in the account transaction log
							var/datum/transaction/T = new()
							T.target_name = authenticated_account.owner_name
							T.purpose = "Credit withdrawal"
							T.amount = "-[amount]"
							T.source_terminal = machine_id
							T.date = current_date_string
							T.time = worldtime2text()
							authenticated_account.transaction_log.Add(T)
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")
			if("withdraw_to_wallet")
				if(CAN_INTERACT_WITH_ACCOUNT)
					var/amount = max(text2num(href_list["funds_amount"]),0)
					if(!istype(atm_card, /obj/item/weapon/card/id))
						to_chat(usr, "<span class='notice'>You must insert your ID card before you can transfer funds to it.</span>")
						return

					var/obj/item/weapon/card/id/card_id = atm_card
					if(amount <= 0)
						alert("That is not a valid amount.")
					else if(authenticated_account && amount > 0)
						if(amount <= authenticated_account.money)
							authenticated_account.money -= amount
							card_id.virtual_wallet.money += amount

							//create an entry in the account transaction log
							var/datum/transaction/T = new()
							T.target_name = card_id.virtual_wallet.owner_name
							T.purpose = "Credit transfer to wallet"
							T.amount = "-[amount]"
							T.source_terminal = machine_id
							T.date = current_date_string
							T.time = worldtime2text()
							authenticated_account.transaction_log.Add(T)

							T = new()
							T.target_name = authenticated_account.owner_name
							T.purpose = "Credit transfer to wallet"
							T.amount = "[amount]"
							T.source_terminal = machine_id
							T.date = current_date_string
							T.time = worldtime2text()
							card_id.virtual_wallet.transaction_log.Add(T)
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")
			if("deposit_from_wallet")
				if(CAN_INTERACT_WITH_ACCOUNT)
					var/amount = max(text2num(href_list["funds_amount"]),0)
					if(!istype(atm_card, /obj/item/weapon/card/id))
						to_chat(usr, "<span class='notice'>You must insert your ID card before you can transfer funds from its virtual wallet.</span>")
						return

					var/obj/item/weapon/card/id/card_id = atm_card
					if(amount <= 0)
						alert("That is not a valid amount.")
					else if(authenticated_account && amount > 0)
						if(amount <= card_id.virtual_wallet.money)
							authenticated_account.money += amount
							card_id.virtual_wallet.money -= amount

							//create an entry in the account transaction log
							var/datum/transaction/T = new()
							T.target_name = card_id.virtual_wallet.owner_name
							T.purpose = "Credit transfer from wallet"
							T.amount = "[amount]"
							T.source_terminal = machine_id
							T.date = current_date_string
							T.time = worldtime2text()
							authenticated_account.transaction_log.Add(T)

							T = new()
							T.target_name = authenticated_account.owner_name
							T.purpose = "Credit transfer from wallet"
							T.amount = "-[amount]"
							T.source_terminal = machine_id
							T.date = current_date_string
							T.time = worldtime2text()
							card_id.virtual_wallet.transaction_log.Add(T)
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")
			if("balance_statement")
				if(CAN_INTERACT_WITH_ACCOUNT)
					if(world.timeofday < lastprint + PRINT_DELAY)
						to_chat(usr, "<span class='notice'>The [src.name] flashes an error on its display.</span>")
						return
					lastprint = world.timeofday
					var/obj/item/weapon/paper/R = new(src.loc)
					R.name = "Account balance: [authenticated_account.owner_name]"
					R.info = {"<b>NT Automated Teller Account Statement</b><br><br>
						<i>Account holder:</i> [authenticated_account.owner_name]<br>
						<i>Account number:</i> [authenticated_account.account_number]<br>
						<i>Balance:</i> $[authenticated_account.money]<br>
						<i>Date and time:</i> [worldtime2text()], [current_date_string]<br><br>
						<i>Service terminal ID:</i> [machine_id]<br>"}

					//stamp the paper
					var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
					stampoverlay.icon_state = "paper_stamp-cent"
					if(!R.stamped)
						R.stamped = new
					R.stamped += /obj/item/weapon/stamp
					R.overlays += stampoverlay
					R.stamps += "<HR><i>This paper has been stamped by the Automatic Teller Machine.</i>"
					playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, 1)
			if("create_debit_card")
				if(CAN_INTERACT_WITH_ACCOUNT)
					if(world.timeofday < lastprint + PRINT_DELAY)
						to_chat(usr, "<span class='notice'>The [src.name] flashes an error on its display.</span>")
						return
					var/desired_authorized_name = input(usr, "Enter authorized name", "Set Authorized Name", authenticated_account.owner_name) as text
					if(authenticated_account.charge(DEBIT_CARD_COST, null, "New debit card", machine_id, null, "Terminal"))
						lastprint = world.timeofday
						var/obj/item/weapon/card/debit/debit_card = new(src.loc, authenticated_account.account_number, desired_authorized_name)
						debit_card.name = authenticated_account.owner_name + "'s " + debit_card.name
						playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, 1)
					else
						playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
			if("change_debit_authorized_name")
				if(atm_card && istype(atm_card, /obj/item/weapon/card/debit/))
					var/obj/item/weapon/card/debit/debit_card = atm_card
					debit_card.change_authorized_name(href_list["new_debit_name"])
			if("insert_card")
				if(atm_card)
					atm_card.forceMove(src.loc)
					authenticated_account = null

					if(ishuman(usr) && !usr.get_active_hand())
						usr.put_in_hands(atm_card)
					atm_card = null

				else
					var/obj/item/I = usr.get_active_hand()
					if (is_valid_atm_card(I))
						if(usr.drop_item(I, src))
							atm_card = I
			if("logout")
				authenticated_account = null
				failsafe = 1

	src.attack_hand(usr,failsafe)

//create the most effective combination of notes to make up the requested amount
/obj/machinery/atm/proc/withdraw_arbitrary_sum(var/mob/user,var/arbitrary_sum)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_id,/obj/item/weapon/storage/wallet))
			dispense_cash(arbitrary_sum,H.wear_id)
			to_chat(usr, "[bicon(src)]<span class='notice'>Funds were transferred into your physical wallet!</span>")
			return
		if(istype(H.wear_id, /obj/item/device/pda))
			var/obj/item/device/pda/P = H.wear_id
			if(P.add_to_virtual_wallet(arbitrary_sum, user, src))
				to_chat(usr, "[bicon(src)]<span class='notice'>Funds were transferred into your virtual wallet!</span>")
				return
		if(istype(H.wear_id, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/ID = H.wear_id
			if(ID.add_to_virtual_wallet(arbitrary_sum, user, src))
				to_chat(usr, "[bicon(src)]<span class='notice'>Funds were transferred into your virtual wallet!</span>")
				return
	var/turf/our_turf = get_turf(src)
	var/turf/destination_turf = get_step(our_turf, turn(dir, 180))
	var/just_throw_it = FALSE
	if(!destination_turf.Adjacent(src)) //Can we get to this turf being where the ATM is facing?
		destination_turf = our_turf //We'll handle it another way
		just_throw_it = TRUE
	var/list/cash = dispense_cash(arbitrary_sum,destination_turf)
	if(just_throw_it) //Just throw it at them
		for(var/obj/I in cash)
			I.throw_at(pick(trange(3, src)), rand(2,5), rand(1,4))

//stolen wholesale and then edited a bit from newscasters, which are awesome and by Agouri
/obj/machinery/atm/proc/scan_user(mob/living/carbon/human/human_user as mob)
	if(!authenticated_account && linked_db)
		if(human_user.wear_id)
			var/obj/item/weapon/card/id/I
			if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
				I = human_user.wear_id
			else if(istype(human_user.wear_id, /obj/item/device/pda) )
				var/obj/item/device/pda/P = human_user.wear_id
				I = P.id
			if(I)
				authenticated_account = linked_db.attempt_account_access(I.associated_account_number)
				if(authenticated_account)
					to_chat(human_user, "<span class='notice'>[bicon(src)] Access granted. Welcome user '[authenticated_account.owner_name].'</span>")

					//create a transaction log entry
					var/datum/transaction/T = new()
					T.target_name = authenticated_account.owner_name
					T.purpose = "Remote terminal access"
					T.source_terminal = machine_id
					T.date = current_date_string
					T.time = worldtime2text()
					authenticated_account.transaction_log.Add(T)

#undef NO_SCREEN
#undef CHANGE_SECURITY_LEVEL
#undef TRANSFER_FUNDS
#undef VIEW_TRANSACTION_LOGS
#undef PRINT_DELAY
#undef DEBIT_CARD_COST
#undef CAN_INTERACT_WITH_ACCOUNT