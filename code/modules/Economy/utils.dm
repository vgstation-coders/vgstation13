////////////////////////
// Ease-of-use
//
// Economy system is such a mess of spaghetti.  This should help.
////////////////////////

var/global/no_pin_for_debit = TRUE
// If you want to engage the fun, go for TRUE.
// Otherwise everyone has to use a PIN to swipe debits like normal.

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

/datum/money_account/proc/charge(var/transaction_amount,var/datum/money_account/dest,var/transaction_purpose, var/terminal_name="", var/terminal_id=0, var/dest_name = "UNKNOWN", var/authorized_name = "")
	if(transaction_amount <= money || account_number == dest.account_number)
		//transfer the money
		money -= transaction_amount
		if(dest)
			dest.money += transaction_amount

		//create entries in the two account transaction logs
		transaction_purpose = copytext(sanitize(transaction_purpose),1,MAX_MESSAGE_LEN)
		var/datum/transaction/T
		if(dest)
			T = new()
			T.target_name = owner_name + ( authorized_name ? " charged as [authorized_name]" : "")
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
		T.target_name = ((!dest) ? dest_name : dest.owner_name) + ( authorized_name ? " as [authorized_name]" : "")
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
		to_chat(usr, "<span class='warning'>Not enough funds in account.</span>")
		return 0

// Charging cards is an absolute mess so let's make it consistent.

/*
	For checking if the mob can gain access to an account.
	obj/proc/charge_flow_verify_security(
		obj/machinery/account_database/linked_db = Account database for account lookup, however it isn't required if you've already gathered the account already.
		obj/item/weapon/card/card 				 = Card for presence checking and account fetching if missing account.
		mob/user								 = Who to prompt for information and send informational messages.
		datum/money_account/account				 = The account to check security for. It can be null if a card is present.
	)
	Possible returns:
	CARD_CAPTURE_SUCCESS
	CARD_CAPTURE_FAILURE_GENERAL
	CARD_CAPTURE_ACCOUNT_DISABLED
	CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO
	CARD_CAPTURE_FAILURE_SECURITY_LEVEL
	CARD_CAPTURE_FAILURE_USER_CANCELED
*/

/obj/proc/charge_flow_verify_security(var/obj/machinery/account_database/linked_db, var/obj/item/weapon/card/card, var/mob/user, var/datum/money_account/account, var/debit_requires_pin)
	if(!account)
		if(linked_db)
			if(!linked_db.activated || linked_db.stat & (BROKEN|NOPOWER))
				to_chat(user, "[bicon(src)] <span class='warning'>No connection to account database.</span>")
				return CARD_CAPTURE_FAILURE_NO_CONNECTION
			account = linked_db.get_account(card.associated_account_number)
			if(!account)
				to_chat(user, "[bicon(src)] <span class='warning'>Bad account/pin combination or ID is not registered with Nanotrasen accounts database.</span>")
				return CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO
		else
			to_chat(user, "[bicon(src)] <span class='warning'>Internal Error.</span>")
			return CARD_CAPTURE_FAILURE_GENERAL
	if(card)
		to_chat(user, "[bicon(src)] <span class='notice'>Using \the [bicon(card)] [card] to authenticate transaction...</span>")
	if(card && card.associated_account_number != account.account_number)
		// Using card, but account number doesn't match what's on the card.
		to_chat(user, "[bicon(src)] <span class='warning'>The account information on \the [bicon(card)] does not match the requested account.</span>")
		return CARD_CAPTURE_FAILURE_SECURITY_LEVEL
	if(account.disabled)
		to_chat(user, "[bicon(src)] <span class='warning'>Account disabled.</span>")
		return CARD_CAPTURE_ACCOUNT_DISABLED
	switch(account.security_level)
		if (0, 1)
			return CARD_CAPTURE_SUCCESS
		if(2) // Only checking it at max level, this is too annoying otherwise...
			var/user_loc = user.loc
			if(account.security_level >= 2 && !card)
				// Security level is 2 and the card is not present, fail.
				to_chat(user, "[bicon(src)] <span class='warning'>Card Not Present transactions are not allowed for this account.</span>")
				return CARD_CAPTURE_FAILURE_SECURITY_LEVEL
			if(no_pin_for_debit && !debit_requires_pin && account.security_level < 2 && istype(card, /obj/item/weapon/card/debit))
				// Oh boy. The fun is engaged and everyone can swipe a debit without it's PIN.
				// May your select deity help you if you lost your debit and have a security level of 0,
				// letting free the flow of your funds to anyone who made a debit card with your account on it.
				return CARD_CAPTURE_SUCCESS

			var/account_pin = input(user, "Enter account pin", "Card Transaction") as null|num
			// Get the account pin.
			if(user_loc != user.loc)
				to_chat(user, "[bicon(src)] <span class='warning'>You have to keep still to enter information.</span>")
				return CARD_CAPTURE_FAILURE_USER_CANCELED
			if(account_pin == null)
				// If the user canceled, fail.
				visible_message("<span class='info'>[user] firmly presses 'CANCEL' on \the [src]'s PIN pad.</span>")
				return CARD_CAPTURE_FAILURE_USER_CANCELED
			visible_message("<span class='info'>[user] enters some digits into \the [src]'s PIN pad.</span>")
			if(account_pin != account.remote_access_pin)
				// If the pin does not match the account pin, fail.
				to_chat(user, "[bicon(src)] <span class='warning'>Bad account/pin combination.</span>")
				return CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO
			return CARD_CAPTURE_SUCCESS
		else
			return CARD_CAPTURE_FAILURE_SECURITY_LEVEL

/*
	Do-it-all proc to standardize card swipe processing.
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
	Possible returns:
		CARD_CAPTURE_SUCCESS
		CARD_CAPTURE_FAILURE_GENERAL
		CARD_CAPTURE_FAILURE_NOT_ENOUGH_FUNDS
		CARD_CAPTURE_ACCOUNT_DISABLED
		CARD_CAPTURE_ACCOUNT_DISABLED_MERCHANT
		CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO
		CARD_CAPTURE_FAILURE_SECURITY_LEVEL
		CARD_CAPTURE_FAILURE_USER_CANCELED
		CARD_CAPTURE_FAILURE_NO_DESTINATION
		CARD_CAPTURE_FAILURE_NO_CONNECTION
*/

#define PRIMARY_NO_FUNDS (transaction_amount_primary > primary_money_account.money)
#define SECONDARY_NO_FUNDS (transaction_amount_secondary && transaction_amount_secondary > secondary_money_account.money)
#define PRIMARY_SAME_AS_DEST (primary_money_account.account_number == dest.account_number)
#define SECONDARY_SAME_AS_DEST (transaction_amount_secondary && secondary_money_account.account_number == dest.account_number)
// Defines to prevent spaghetti code and improve readability.

/obj/proc/charge_flow(var/obj/machinery/account_database/linked_db, var/obj/item/weapon/card/card, var/mob/user, var/transaction_amount, var/datum/money_account/dest, var/transaction_purpose, var/terminal_name="", var/terminal_id=0, var/dest_name = "UNKNOWN")
	var/datum/money_account/primary_money_account
	// Primary payment.
	var/datum/money_account/secondary_money_account
	// Secondary payment, always a virtual card.
	var/transaction_amount_primary = transaction_amount
	// The amount to charge on our primary payment.
	var/transaction_amount_secondary = 0
	// The amount to charge on our secondary payment.
	var/user_loc = user.loc
	// To keep track of the user just so we can can cancel if they move.
	var/authorized = ""
	// For debit cards.
	if(!linked_db || !linked_db.activated || linked_db.stat & (BROKEN|NOPOWER))
		// The account database has to avaiable, active, and not broken.
		to_chat(user, "[bicon(src)] <span class='warning'>No connection to account database.</span>")
		return CARD_CAPTURE_FAILURE_NO_CONNECTION

	if(!dest)
		// We have to have a destination to charge to.
		to_chat(user, "[bicon(src)] <span class='warning'>No destination account.</span>")
		return CARD_CAPTURE_FAILURE_NO_DESTINATION

	if(dest.disabled)
		to_chat(user, "[bicon(src)] <span class='warning'>Destination account disabled.</span>")
		return CARD_CAPTURE_ACCOUNT_DISABLED_MERCHANT

	if(istype(card, /obj/item/weapon/card))
		// The card is present, so we can fetch the account information ourselves.
		visible_message("<span class='info'>[user] swipes a card through [src].</span>")
		if(istype(card, /obj/item/weapon/card/id))
			// Expect more cards with virtual accounts.
			var/obj/item/weapon/card/id/card_id = card
			primary_money_account = card_id.virtual_wallet
			if(!primary_money_account)
				// A lot of machines keep doing this so for the sake of conformity we'll do it here too.
				// Supposed to make sure the id always comes with a virtual wallet if it hasn't been made yet.
				card_id.update_virtual_wallet()
				primary_money_account = card_id.virtual_wallet

		if(primary_money_account && primary_money_account.virtual)
			// The card contains a virtual wallet, so lets use it.
			// We'll charge the virtual wallet first.
			if(primary_money_account.money < transaction_amount)
				// Not enough funds in the virtual wallet so we'll need the bank account.
				if(primary_money_account.money > 0 && alert(user, "Apply remaining balance of $[num2septext(primary_money_account.money)] from \the [card] virtual wallet?", "Card Transaction", "Yes", "No") == "Yes")
					// But lets check if there's an amount on the virtual card and ask if the user would like to apply that balance.
					if(user_loc != user.loc)
						to_chat(user, "[bicon(src)] <span class='warning'>You have to keep still to enter information.</span>")
						return CARD_CAPTURE_FAILURE_USER_CANCELED
					secondary_money_account = primary_money_account
					// Set our secondary payment to be the virtual wallet.
					transaction_amount_secondary = secondary_money_account.money
					// Apply the full balance of the virtual wallet.
					transaction_amount_primary -= transaction_amount_secondary
					// Adjust the primary.
					to_chat(user, "[bicon(src)] <span class='notice'>Using remaining virtual wallet on \the [bicon(card)] [card] with a balance of $[num2septext(transaction_amount_secondary)]</span>")

				primary_money_account = null
				// We need another source.

		if(!primary_money_account)
			// There wasn't enough funds in the virtual wallet, so lets get the bank account.
			primary_money_account = linked_db.get_account(card.associated_account_number)
			// Using the associated account number, get the account.
			if(!primary_money_account)
				// Couldn't find a matching account so fail.
				to_chat(user, "[bicon(src)] <span class='warning'>Bad account/pin combination.</span>")
				return CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO
	else
		// The card was not found, so prompt the user for account information.
		var/account_number = input(user, "Enter account number", "Card Transaction") as null|num
		// Get the account number from the user.
		if(user_loc != user.loc)
			to_chat(user, "[bicon(src)] <span class='warning'>You have to keep still to enter information.</span>")
			return CARD_CAPTURE_FAILURE_USER_CANCELED

		if(account_number == null)
			// If the user canceled, fail.
			visible_message("<span class='info'>[user] firmly presses 'CANCEL' on \the [src]'s PIN pad.</span>")
			return CARD_CAPTURE_FAILURE_USER_CANCELED

		visible_message("<span class='info'>[user] enters some digits into \the [src]'s PIN pad.</span>")
		primary_money_account = linked_db.get_account(account_number)
		if(!primary_money_account)
			// Couldn't find a matching account so fail.
			to_chat(user, "[bicon(src)] <span class='warning'>Bad account/pin combination.</span>")
			return CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO

	if(primary_money_account.virtual)
		// If our primary is a virtual wallet we don't have to do any security checks.
		to_chat(user, "[bicon(src)] <span class='notice'>Using virtual wallet on \the [bicon(card)] [card] to charge $[num2septext(transaction_amount_primary)]</span>")
	else
		// Otherwise we'll need to fulfill the security checks.
		if(card)
			// If the card was used, don't show the account number.
			to_chat(user, "[bicon(src)] <span class='notice'>Using account associated with \the [bicon(card)] [card] to charge $[num2septext(transaction_amount_primary)]...</span>")
		else
			// Otherwise show.
			to_chat(user, "[bicon(src)] <span class='notice'>Using account [primary_money_account.account_number] to charge $[num2septext(transaction_amount_primary)]...</span>")

		var/security_check = charge_flow_verify_security(null, card, user, primary_money_account)
		if(security_check != CARD_CAPTURE_SUCCESS)
			return security_check

	if(!secondary_money_account && PRIMARY_NO_FUNDS && !PRIMARY_SAME_AS_DEST)
		//If we aren't using a secondary account, make sure we've got enough money in the primary (assuming it's not our destination)
		to_chat(user, "[bicon(src)] <span class='warning'>Not enough funds to process transaction.</span>")
		return CARD_CAPTURE_FAILURE_NOT_ENOUGH_FUNDS
	if(secondary_money_account && SECONDARY_NO_FUNDS && !SECONDARY_SAME_AS_DEST)
		//Secondary only exists if partially paying with both. If that's the case, make sure they can cover the remaining balance there.
		to_chat(user, "[bicon(src)] <span class='warning'>Not enough funds to process transaction.</span>")
		return CARD_CAPTURE_FAILURE_NOT_ENOUGH_FUNDS

	if(card && istype(card, /obj/item/weapon/card/debit))
		// Using debit, find the authorized name.
		var/obj/item/weapon/card/debit/debit_card = card
		authorized = debit_card.authorized_name

	if(transaction_amount_secondary)
		// If we have a vaild secondary amount, charge the secondary payment method.
		secondary_money_account.charge(transaction_amount_secondary, dest, transaction_purpose, terminal_name, terminal_id, dest_name, authorized)

	primary_money_account.charge(transaction_amount_primary, dest, transaction_purpose, terminal_name, terminal_id, dest_name, authorized)
	// Finally charge the primary
	var/account_type = primary_money_account.virtual ? "virtual wallet" : "bank account"
	to_chat(user, "[bicon(src)] <span class='notice'>Remaining balance on [account_type], $[num2septext(primary_money_account.money)].</span>")
	// Present the remaining balance to the user.
	return CARD_CAPTURE_SUCCESS

#undef PRIMARY_NO_FUNDS
#undef SECONDARY_NO_FUNDS
#undef PRIMARY_SAME_AS_DEST
#undef SECONDARY_SAME_AS_DEST