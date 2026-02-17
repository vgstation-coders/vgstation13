/obj
	var/obj/item/device/money_scraper/money_scraper = null


/obj/machinery/attackby()

/obj/item/device/money_scraper
	name = "account scraper"
	desc = "The bane of space-gas station owners everywhere. When inserted into a machine, it drains the funds from any swiped card into its connected account."
	icon = 'icons/obj/shoal.dmi'
	icon_state = "money_scraper"
	flags = FPRINT
	item_state = "electronic"
	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_SYNDICATE + "=1;" + Tc_MAGNETS + "=1"

	var/datum/money_account/linked_account //where we get our money from/put it to


/obj/item/device/money_scraper/proc/Scrape()


/obj/item/device/money_scraper/proc/AskForAccountAuth(mob/user, obj/card, money)
	var/yes = yes()
	var/no = no()
	var/charge_prompt = chargeprompt(card, money)
	return alert(user, charge_prompt, yes, no) == yes


/obj/item/device/money_scraper/examine(mob/user)
	..()
	if(!linked_account)
		to_chat(user, "<span class='notice'>A red light on the side indicates that it has no account linked. Swipe a card to link your account.</span>")

/obj/item/device/money_scraper/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/weapon/card))
		if(linked_account)
			to_chat(user, "<span class='warning'>[src] already has an account linked.</span>")
			return
		var/obj/item/weapon/card/C = W
		if(!C.associated_account_number)
			to_chat(user, "<span class='warning'>[C] doesn't have an associated account number.</span>")
			return
		for(var/datum/money_account/D in all_money_accounts)
			if(D.account_number == C.associated_account_number)
				linked_account = D
		to_chat(user, "<span class='warning'>The account listed on [C] doesn't exist.</span>")

/obj/item/device/money_scraper/vox/New()
	..()
	if(raider_account)
		linked_account = raider_account


/obj/item/device/money_scraper/proc/yes()
	return pickweight(list(
		"Yes"		= 5,
		"Yes?"		= 1,
		"Sure"		= 1,
		"What?"		= 1,
		"OK"		= 1,
		"Wait..." 	= 1,
		"Y#S"		= 1,
		"#@^"		= 1,
	))

/obj/item/device/money_scraper/proc/no()
	return pickweight(list(
		"No"		= 5,
		"No?"		= 1,
		"Nope"		= 1,
		"Dammit."	= 1,
		"NO!"		= 1,
		"Hell No" 	= 1,
		"N#"		= 1,
	))

/obj/item/device/money_scraper/proc/chargeprompt(obj/card, var/bal)
	return pickweight(list(
		"Not enough cash to do that transaction. Wanna access the bank account?" = 1,
		"Nope, not enough money in virtual wallet. You could use your bank account for it instead." = 1,
		"ERROR: NOT ENOUGH MONEY IN VIRTUAL WALLET. ACCESS BANK ACCOUNT?" = 1,
		"Insufficient funds for transaction. Pull all available money from bank account?" = 1,
		"ERROR: Insufficient funds. Authorize bank account to cover remaining costs?" = 1,
		"Use bank account to pay?" = 1,
		"NANOTRASEN ALERT: You have insufficient funds for this transaction. To avoid traumatic legal fees, cover the remaining cost using your bank account?" = 1,
		"Out of money in virtual wallet. Pay using checking account?" = 1,
		"Transaction could only be partially completed. Use $1 from bank account to finish transaction?" = 1,
		"SPECIAL OFFER: You are this machine's 1001st customer! Accept free bonus?" = 1,
		"Oops! Out of money in virtual wallet. Cover remaining cost using bank funds?" = 1,
		"ERROR: Virtual wallet data could not be accessed (bluespace?) Buy for free?" = 1,

	))


/obj/item/device/money_scraper/proc/drained_wallet(obj/card, var/bal)
	return pickweight(list(
		"Please authorize this transaction to continue." = 1,
		"Utilizing total virtual wallet on \the [bicon(card)] [card] with a remainder balance of $[bal]" = 1,
		"Seizing available wallet funds on \the [bicon(card)] [card] with a balance of $[bal]" = 1,
		"Now using all virtual wallet money on \the [bicon(card)] [card] with remaining amount of $[bal]" = 1,
		"Paying your way with virtual wallet on \the [bicon(card)] [card] with remaining funds of $[bal]" = 1,
		"Using virtual currency on \the [bicon(card)] [card] with the balance of $[bal]" = 1,
		"Spending remainder virtual wallet of \the [bicon(card)] [card] with only balance of $[bal]" = 1,
		"Purchasing using the leftover wallet of \the [bicon(card)] [card] with a balance of $[bal]" = 1,
		"Using whatever is left in virtual wallet of \the [bicon(card)] [card] with a grand total of $[bal]" = 1,
	))


/obj/item/device/money_scraper/proc/drained_bank(var/num, var/bal)
	return pickweight(list(
		"Draining account [num] to the order of $[bal]..." = 1,
		"Utilizing account [num] to pay exactly $$[bal]." = 1,
		"Access granted, [num] is using $[bal] to cover your costs." = 1,
		"ERROR: SUCCESS! [num] SPENT $[bal] SUCCESSFULLY!" = 1,
		"ERROR: CONGRATULATIONS! [num] does NOT have to spend $[bal] this time!" = 1,
		"Using your bank account ([num]) for normal purposes..." = 1,
		"Loan request to NANOTRASON CENTRAL BANK successfully sent from your account, [num]!" = 1,
		"WARNING: GOOD NEWS! [num] covered the $[bal] cost of your transaction." = 1,
		"Using account [num] to spend $[bal] on some stuff..." = 1,
	))

/obj/item/device/money_scraper/proc/no_money()
	return pickweight(list(
		"<span class='warning'>No more funds in your bank account.</span>" = 1,
		"<span class='warning'>Can't buy that.</span>" = 1,
		"<span class='warning'>ERROR: CARD FROZEN DUE TO REPEATED USE. TRY AGAIN LATER.</span>" = 1,
		"<span class='warning'>OUT OF STOCK.</span>" = 1,
		"<span class='warning'>Not enough funds in any of your accounts to pay for that.</span>" = 1,
		"<span class='warning'>ERROR: CONGRATULATIONS!</span>" = 1,
		"<span class='warning'>You have been pwned.</span>" = 1,
		"<span class='warning'>WARNING: Not enough funds.</span>" = 1,
		"<span class='warning'>ERROR: Not enough funds to process that transaction.</span>" = 1,
		"<span class='warning'>KHAT: CHEE SHKATTARA.</span>" = 1,
		"<span class='warning'>WARNING: Try inviting your friends to this machine for a Nanotrasen Glowing Voucher!</span>" = 1,
	))

/obj/item/device/money_scraper/proc/purpose()
	return pickweight(list(
		"CAW!" = 1,
		"Trust Fund Payment" = 1,
		"Nanotrasen Direct Unsubsidized Loan" = 1,
		"owed money to the wrong people" = 1,
		"ERR" = 1,
		"Employee Discount" = 1,
	))
