////////////////////////
// Ease-of-use
//
// Economy system is such a mess of spaghetti.  This should help.
////////////////////////

/proc/get_money_account(var/account_number, var/from_z=-1)
	for(var/obj/machinery/account_database/DB in account_DBs)
		if(from_z > -1 && DB.z != from_z)
			continue
		if((DB.stat & NOPOWER) || !DB.activated )
			continue
		var/datum/money_account/acct = DB.get_account(account_number)
		if(!acct)
			continue
		return acct

// Added this proc for admin tools. Not even sure we need the above proc as it is
/proc/get_money_account_global(account_number)
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == account_number)
			return D


/obj/proc/get_card_account(var/obj/item/weapon/card/I, var/mob/user=null, var/terminal_name="", var/transaction_purpose="", var/require_pin=0)
	if(terminal_name=="")
		terminal_name=src.name
	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		var/attempt_pin=0
		var/datum/money_account/D = get_money_account(C.associated_account_number)
		if(require_pin && user)
			attempt_pin = input(user,"Enter pin code", "Transaction") as num
			if(D.remote_access_pin != attempt_pin)
				return null
		if(D)
			return D

/mob/proc/get_worn_id_account(var/require_pin=0, var/mob/user=null)
	if(ishuman(src))
		var/obj/item/weapon/card/id/I = get_id_card()
		var/attempt_pin=0
		if(!istype(I))
			return null
		var/datum/money_account/D = get_money_account(I.associated_account_number)
		if(require_pin && user)
			attempt_pin = input(user,"Enter pin code", "Transaction") as num
			if(D.remote_access_pin != attempt_pin)
				return null
		return D
	else if(issilicon(src) || isAdminGhost(src))
		return station_account

/datum/money_account/proc/fmtBalance()
	return "$[num2septext(money)]"

/datum/money_account/proc/charge(var/transaction_amount,var/datum/money_account/dest,var/transaction_purpose, var/terminal_name="", var/terminal_id=0, var/dest_name = "UNKNOWN")
	if(transaction_amount <= money)
		//transfer the money
		money -= transaction_amount
		if(dest)
			dest.money += transaction_amount

		//create entries in the two account transaction logs
		var/datum/transaction/T
		if(dest)
			T = new()
			T.target_name = owner_name
			if(terminal_name!="")
				T.target_name += " (via [terminal_name])"
			T.purpose = transaction_purpose
			T.amount = "[transaction_amount]"
			T.source_terminal = terminal_name
			T.date = current_date_string
			T.time = worldtime2text()
			dest.transaction_log.Add(T)
		//
		T = new()
		T.target_name = (!dest) ? dest_name : dest.owner_name
		if(terminal_name!="")
			T.target_name += " (via [terminal_name])"
		T.purpose = transaction_purpose
		if(transaction_amount < 0)
			T.amount = "[-1*transaction_amount]"
		else
			T.amount = "-[transaction_amount]"
		T.source_terminal = terminal_name
		T.date = current_date_string
		T.time = worldtime2text()
		transaction_log.Add(T)
		return 1
	else
		to_chat(usr, "[bicon(src)] <span class='warning'>Not enough funds in account.</span>")
		return 0

// Charging cards is an absolute mess so let's make it consistent.
/*
	obj/proc/charge_flow(
		obj/machinery/account_database/linked_db	= The account database we will use to look up accounts.
		obj/item/weapon/card/card					= The card we will attempt to charge, but it is optional if the terminal will allow manual entry
		mob/user									= The user who we will prompt for pins, account information, and such.
		transaction_amount							= The amount we will charge
		datum/money_account/dest					= The destination of the funds
		transaction_purpose							= The purpose of the transaction
		terminal_name								= The name of the terminal
		terminal_id									= The terminal ID
		dest_name									= The name of the destination (Overrides the name from the destination account)
	)
*/

/obj/proc/charge_flow(var/obj/machinery/account_database/linked_db, var/obj/item/weapon/card/card, var/mob/user, var/transaction_amount, var/datum/money_account/dest, var/transaction_purpose, var/terminal_name="", var/terminal_id=0, var/dest_name = "UNKNOWN")
	var/datum/money_account/source_money_account
	var/datum/money_account/secondary_money_account
	var/card_present = 0
	var/transaction_amount_primary = transaction_amount
	var/transaction_amount_secondary = 0
	var/user_loc = user.loc
	if(!linked_db || !linked_db.activated || linked_db.stat & (BROKEN|NOPOWER))
		to_chat(user, "[bicon(src)] <span class='warning'>No connection to account database.</span>")
		return CARD_CAPTURE_FAILURE_NO_CONNECTION
	if(!dest)
		to_chat(user, "[bicon(src)] <span class='warning'>No destination account.</span>")
		return CARD_CAPTURE_FAILURE_NO_DESTINATION
	if(istype(card, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/card_id = card
		visible_message("<span class='info'>[user] swipes a card through [src].</span>")
		card_present = 1
		source_money_account = card_id.virtual_wallet
		if(!source_money_account)
			// A lot of machines keep doing this so for the sake of conformity we'll do it here too.
			// Supposed to make sure the id always comes with a virtual wallet if it hasn't been made yet.
			card_id.update_virtual_wallet()
			source_money_account = card_id.virtual_wallet
		
		if(source_money_account.money < transaction_amount)
			if(source_money_account.money > 0 && alert(user, "Apply remaining balance of $[num2septext(source_money_account.money)] from your virtual wallet?", "Card Transaction", "Yes", "No") == "Yes")
				// We'll use the wallet to help pay for the rest.
				secondary_money_account = source_money_account
				transaction_amount_secondary = source_money_account.money
				transaction_amount_primary -= transaction_amount_secondary
				to_chat(user, "[bicon(src)] <span class='notice'>Using remaining virtual wallet balance of $[num2septext(transaction_amount_secondary)]</span>")
			// Not enough funds in the virtual wallet so let's get the one from the card.
			source_money_account = linked_db.get_account(card_id.associated_account_number)
			if(!source_money_account)
				to_chat(user, "[bicon(src)] <span class='warning'>Bad account/pin combination.</span>")
				return CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO
	else 
		// Okay, we don't have a card, so let's prompt the user for the account information.
		var/account_number = input(user, "Enter account number", "Card Transaction") as null|num
		if(user_loc != user.loc)
			to_chat(user, "[bicon(src)] <span class='warning'>You have to keep still to enter information.</span>")
			return CARD_CAPTURE_FAILURE_USER_CANCELED
		if(!account_number)
			visible_message("<span class='info'>[user] firmly presses 'CANCEL' on [src]'s PIN pad.</span>")
			return CARD_CAPTURE_FAILURE_USER_CANCELED
		visible_message("<span class='info'>[user] enters some digits into [src]'s PIN pad.</span>")
		source_money_account = linked_db.get_account(account_number)
		if(!source_money_account)
			to_chat(user, "[bicon(src)] <span class='warning'>Bad account/pin combination.</span>")
			return CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO
	if(source_money_account.virtual){
		to_chat(user, "[bicon(src)] <span class='notice'>Using virtual wallet to charge $[num2septext(transaction_amount_primary)]</span>")
	} else {
		if(card_present)
			to_chat(user, "[bicon(src)] <span class='notice'>Using account associated with card to charge $[num2septext(transaction_amount_primary)]...</span>")
		else
			to_chat(user, "[bicon(src)] <span class='notice'>Using account [source_money_account.account_number] to charge $[num2septext(transaction_amount_primary)]...</span>")
		switch(source_money_account.security_level)
			if(0)
				// Easy. We already have everything we need to authorize or more.
			if(1)
				var/account_pin = input(user, "Enter account pin", "Card Transaction") as null|num
				if(user_loc != user.loc)
					to_chat(user, "[bicon(src)] <span class='warning'>You have to keep still to enter information.</span>")
					return CARD_CAPTURE_FAILURE_USER_CANCELED
				if(!account_pin)
					visible_message("<span class='info'>[user] firmly presses 'CANCEL' on [src]'s PIN pad.</span>")
					return CARD_CAPTURE_FAILURE_USER_CANCELED
				visible_message("<span class='info'>[user] enters some digits into [src]'s PIN pad.</span>")
				if(account_pin != source_money_account.remote_access_pin)
					to_chat(user, "[bicon(src)] <span class='warning'>Bad account/pin combination.</span>")
					return CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO
			if(2)
				if(card_present) // Card has to be present else the transaction fails.
					var/account_pin = input(user, "Enter account pin", "Card Transaction") as null|num
					if(user_loc != user.loc)
						to_chat(user, "[bicon(src)] <span class='warning'>You have to keep still to enter information.</span>")
						return CARD_CAPTURE_FAILURE_USER_CANCELED
					if(!account_pin)
						visible_message("<span class='info'>[user] firmly presses 'CANCEL' on [src]'s PIN pad.</span>")
						return CARD_CAPTURE_FAILURE_USER_CANCELED
					visible_message("<span class='info'>[user] enters some digits into [src]'s PIN pad.</span>")
					if(account_pin != source_money_account.remote_access_pin)
						to_chat(user, "[bicon(src)] <span class='warning'>Bad account/pin combination.</span>")
						return CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO
				else 
					to_chat(user, "[bicon(src)] <span class='warning'>Card Not Present transactions are not allowed for this account.</span>")
					return CARD_CAPTURE_FAILURE_SECURITY_LEVEL
			else
				return CARD_CAPTURE_FAILURE_SECURITY_LEVEL
	}
	if(transaction_amount_primary > source_money_account.money || (transaction_amount_secondary && transaction_amount_secondary > secondary_money_account.money) ) // Another check to be safe.
		to_chat(user, "[bicon(src)] <span class='warning'>Not enough funds to process transaction.</span>")
		return CARD_CAPTURE_FAILURE_NOT_ENOUGH_FUNDS
	
	if(transaction_amount_secondary)
		secondary_money_account.charge(transaction_amount_secondary, dest, transaction_purpose, terminal_name, terminal_id, dest_name)

	source_money_account.charge(transaction_amount_primary, dest, transaction_purpose, terminal_name, terminal_id, dest_name)
	var/account_type = source_money_account.virtual ? "virtual wallet" : "bank account"
	to_chat(user, "[bicon(src)] <span class='notice'>Remaining balance on [account_type], $[num2septext(source_money_account.money)].</span>")
	return CARD_CAPTURE_SUCCESS
