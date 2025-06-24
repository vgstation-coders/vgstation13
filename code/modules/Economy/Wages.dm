// Wage system configuration
var/global/wages_enabled = 0
var/global/roundstart_enable_wages = 0
var/global/requested_payroll_amount = 0
var/payroll_modifier = 1
var/adjusted_wage_gain = 0

#define WAGE_INTERVAL (15 MINUTES)
#define PRISONER_BONUS 1000

/proc/wageSetup()
	if(roundstart_enable_wages)
		wages_enabled = 1
		stationAllowance()
	WageLoop()

// Command alerts
/datum/command_alert/wages
	name = "wage payout"
	alert_title = "Quarter-Hourly Salary"
	message = "Payroll has been processed. All eligible accounts have received their paycheck as a direct deposit."
	noalert = 1
	small = 1

/datum/command_alert/wage_increase
	name = "wage raise"
	alert_title = "Quarter-Hourly Salary"
	noalert = 1
	small = 1

/datum/command_alert/wage_increase/announce()
	var/increase_percent = round((payroll_modifier - 1) * 100)
	message = "Payroll has been processed. Thanks to the high productivity of the station staff, all wages have been increased by [increase_percent]%."
	..()

/datum/command_alert/wage_reduction
	name = "wage reduction"
	alert_title = "Quarter-Hourly Salary"
	noalert = 1
	small = 1

/datum/command_alert/wage_reduction/announce()
	var/reduction_percent = round((1 - payroll_modifier) * 100)
	message = "Payroll has been processed. Financial mismanagement has resulted in all wages being reduced by [reduction_percent]%."
	..()

/proc/stationAllowance()
	if(!station_account)
		message_admins("Station allowance skipped, no station account found.")
		return

	for(var/obj/machinery/computer/accounting/A in machines)
		A.new_cycle()
		
	var/total_allowance = station_allowance + WageBonuses() + station_funding + station_bonus
	station_account.money += total_allowance
	station_bonus = 0

	new /datum/transaction(station_account, "Nanotrasen station allowance", "[total_allowance]", "Nanotrasen Payroll Server", send2PDAs=FALSE)

/proc/wagePayout()
	if(!station_account)
		message_admins("Wage payout skipped, no station account found.")
		return

	// Handle latejoiner allowance
	if(latejoiner_allowance > 0)
		station_allowance += latejoiner_allowance
		station_account.money += latejoiner_allowance
		new /datum/transaction(station_account, "Nanotrasen new employee allowance", "[latejoiner_allowance]", "Nanotrasen Payroll Server", send2PDAs=FALSE)
		latejoiner_allowance = 0

	// Calculate payroll modifier
	requested_payroll_amount = 0
	for(var/datum/money_account/Acc in all_station_accounts)
		if(Acc.wage_gain)
			requested_payroll_amount += Acc.wage_gain

	if(requested_payroll_amount > 0)
		payroll_modifier = station_account.money / requested_payroll_amount
	else
		payroll_modifier = 1

	message_admins("Wages: Payroll Modifier is [round((payroll_modifier - 1) * 100)]%.")

	// Deduct from station account
	var/actual_payout = min(station_account.money, requested_payroll_amount * payroll_modifier)
	new /datum/transaction(station_account, "Employee and Department salaries", "-[actual_payout]", "Account Database", send2PDAs=FALSE)
	station_account.money = max(0, station_account.money - actual_payout)

	// Pay accounts
	for(var/datum/money_account/Acc in all_money_accounts)
		if(Acc == station_account || !Acc.wage_gain)
			continue

		if(locate(Acc) in all_station_accounts)
			payStationAccount(Acc)
		else
			// Non-station accounts
			Acc.money += Acc.wage_gain
			if(Acc.wage_gain > 0)
				new /datum/transaction(Acc, "mysterious transaction", "[Acc.wage_gain]", "unknown")

	// Send notifications
	if(payroll_modifier > 1.1)
		command_alert(/datum/command_alert/wage_increase)
	else if(payroll_modifier < 1)
		command_alert(/datum/command_alert/wage_reduction)
	else
		command_alert(/datum/command_alert/wages)

	stationAllowance()

/proc/payStationAccount(datum/money_account/Acc)
	adjusted_wage_gain = round(Acc.wage_gain * payroll_modifier)
	var/left_from_virtual_wallet = adjusted_wage_gain
	
	var/list/matching_PDAs = getMatchingPDAs(Acc)
	
	if(matching_PDAs.len)
		var/decimal_wage_ratio = Acc.virtual_wallet_wage_ratio / 100
		var/amount_per_pda = round(adjusted_wage_gain * decimal_wage_ratio / matching_PDAs.len)
		
		for(var/obj/item/device/pda/PDA in matching_PDAs)
			if(amount_per_pda > 0)
				left_from_virtual_wallet -= amount_per_pda
				PDA.id.virtual_wallet.money += amount_per_pda
				new /datum/transaction(PDA.id.virtual_wallet, "Nanotrasen employee payroll", "[amount_per_pda]", station_account.owner_name)

	// Pay remainder to bank account
	if(left_from_virtual_wallet > 0)
		Acc.money += left_from_virtual_wallet
		new /datum/transaction(Acc, "Nanotrasen employee payroll", "[left_from_virtual_wallet]", station_account.owner_name)

/proc/getMatchingPDAs(datum/money_account/Acc)
	var/list/matching_PDAs = list()
	
	for(var/obj/item/device/pda/PDA in PDAs)
		if(!PDA?.id?.virtual_wallet)
			continue
			
		var/datum/pda_app/balance_check/app = locate(/datum/pda_app/balance_check) in PDA.applications
		if(app && app.linked_db && Acc == app.linked_db.attempt_account_access(PDA.id.associated_account_number, 0, 2, 0))
			matching_PDAs.Add(PDA)
	
	return matching_PDAs

/proc/WageBonuses()
	var/bonus = 0
	
	for(var/mob/living/carbon/human/H in current_prisoners)
		if(H.z == map.zMainStation && !isspace(get_area(H)) && !H.isDead())
			bonus += PRISONER_BONUS
	
	return bonus

/proc/WageLoop()
	set waitfor = 0
	usr = null
	while(1)
		sleep(WAGE_INTERVAL)
		if(wages_enabled)
			wagePayout()

#undef WAGE_INTERVAL
#undef PRISONER_BONUS