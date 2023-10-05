var/global/wages_enabled = 0
var/global/roundstart_enable_wages = 0

var/global/requested_payroll_amount = 0
var/payroll_modifier = 1
var/adjusted_wage_gain = 0

/proc/wageSetup()
	if(roundstart_enable_wages)
		wages_enabled = 1
		stationAllowance()
	WageLoop()

/*

Things that increase wages:

* shipping plasma to centcom increases all wages.
* reducing the salary of one account will increase the other accounts'


Things that decrease wages:

* creating a new station account with some starting funds, and a salary, will decease
* increasing the salary of one account will decrease the other accounts'


All wages are increased by 10% by default thanks to the overhead Nanotrasen gives for every job.
If all wages are increased further, for example by shipping plasma, the wage increase announcement will be used.
If all wages are decreased bellow 100%, for example due to the AI spending all the station funds on monkey cube crates, the wage reduction announcement will be used

*/

/datum/command_alert/wages
	name = "wage payout"
	alert_title = "Quarter-Hourly Salary"
	message = "Payroll has been processed. All eligible accounts have received their paycheck as a direct deposit."
	noalert = 1
	small = 1

/datum/command_alert/wage/announce()
	message = "Payroll has been processed. All eligible accounts have received their paycheck as a direct deposit."
	..()

/datum/command_alert/wage_increase
	name = "wage raise"
	alert_title = "Quarter-Hourly Salary"
	message = "Payroll has been processed. Thanks to the high productivity of the station staff, all wages have been increased by ERROR."
	noalert = 1
	small = 1

/datum/command_alert/wage_increase/announce()
	message = "Payroll has been processed. Thanks to the high productivity of the station staff, all wages have been increased by [round(100*payroll_modifier - 100)]%."
	..()

/datum/command_alert/wage_reduction
	name = "wage reduction"
	alert_title = "Quarter-Hourly Salary"
	message = "Payroll has been processed. Financial mismanagement has resulted in all wages being reduced by ERROR."
	noalert = 1
	small = 1

/datum/command_alert/wage_reduction/announce()
	message = "Payroll has been processed. Financial mismanagement has resulted in all wages being reduced by [round(100*payroll_modifier - 100)]%."
	..()

/proc/stationAllowance()//grants the station the allowance it'll need to pay the next salary
	if(!station_account)
		message_admins("Station allowance skipped, no station account found.")
		return

	for(var/obj/machinery/computer/accounting/A in machines)
		A.new_cycle()
	station_account.money += station_allowance + WageBonuses() + station_funding + station_bonus
	station_bonus = 0

	new /datum/transaction(station_account,"Nanotrasen station allowance","[station_allowance]","Nanotrasen Payroll Server",send2PDAs=FALSE)


/proc/wagePayout()
	if(!station_account)
		message_admins("Wage payout skipped, no station account found.")
		return
	//adding extra allowance due to latejoiners
	if (latejoiner_allowance > 0)
		station_allowance += latejoiner_allowance
		station_account.money += latejoiner_allowance

		new /datum/transaction(station_account,"Nanotrasen new employee allowance","[latejoiner_allowance]","Nanotrasen Payroll Server",send2PDAs=FALSE)
		latejoiner_allowance = 0

	//checking for wage raises/decreases and emptying station account
	requested_payroll_amount = 0
	for(var/datum/money_account/Acc in all_station_accounts)
		if(Acc.wage_gain)
			requested_payroll_amount += Acc.wage_gain
	if(requested_payroll_amount>0)
		payroll_modifier = station_account.money / requested_payroll_amount
	else
		payroll_modifier = 1
	message_admins("Wages: Payroll Modifier is [round(100*payroll_modifier - 100)]%.")

	new /datum/transaction(station_account,"Employee and Department salaries","-[station_account.money]","Account Database",send2PDAs=FALSE)

	station_account.money = 0

	//actually paying the departments and employees
	for(var/datum/money_account/Acc in all_money_accounts)
		if(locate(Acc) in all_station_accounts)
			if(Acc.wage_gain)
				adjusted_wage_gain = round((Acc.wage_gain)*payroll_modifier)
				var/left_from_virtual_wallet = adjusted_wage_gain
				var/decimal_wage_ratio = 0
				var/list/obj/item/device/pda/matching_PDAs = list()
				for(var/obj/item/device/pda/PDA in PDAs)
					// Only works and does this if ID is in PDA
					if(PDA?.id?.virtual_wallet)
						var/datum/pda_app/balance_check/app = locate(/datum/pda_app/balance_check) in PDA.applications
						if(app && app.linked_db && Acc == app.linked_db.attempt_account_access(PDA.id.associated_account_number, 0, 2, 0))
							matching_PDAs.Add(PDA)
				if(matching_PDAs.len)
					decimal_wage_ratio = Acc.virtual_wallet_wage_ratio/100
				for(var/obj/item/device/pda/PDA in matching_PDAs)
					left_from_virtual_wallet -= round(adjusted_wage_gain*(decimal_wage_ratio/matching_PDAs.len))
					PDA.id.virtual_wallet.money += round(adjusted_wage_gain*(decimal_wage_ratio/matching_PDAs.len))
					if(round(adjusted_wage_gain*(decimal_wage_ratio/matching_PDAs.len)) > 0)
						new /datum/transaction(PDA.id.virtual_wallet,"Nanotrasen employee payroll","[round(adjusted_wage_gain*(decimal_wage_ratio/matching_PDAs.len))]",station_account.owner_name)
				Acc.money += left_from_virtual_wallet

				if(left_from_virtual_wallet > 0)
					new /datum/transaction(Acc,"Nanotrasen employee payroll","[left_from_virtual_wallet]",station_account.owner_name)

		else 	//non-station accounts get their money from magic, not that these accounts have any wages anyway
			Acc.money += Acc.wage_gain
			if(Acc.wage_gain > 0)
				new /datum/transaction(Acc,"mysterious transaction","[Acc.wage_gain]","unknown")

	//telling the crew
	if(payroll_modifier > 1.1)//taking the overhead into account
		command_alert(/datum/command_alert/wage_increase)
	else if(payroll_modifier < 1)
		command_alert(/datum/command_alert/wage_reduction)
	else
		command_alert(/datum/command_alert/wages)

	//refuelling the station account for the next salary
	stationAllowance()

/proc/WageBonuses()		//Add any conditions that increase wages here
	var/bonus = 0

	//1000 bonus per prisoner
	for(var/mob/living/carbon/human/H in current_prisoners)
		if(H.z == map.zMainStation && !isspace(get_area(H)) && !H.isDead())
			bonus += 1000

	return bonus

/proc/WageLoop()
	set waitfor = 0
	usr = null
	while(1) //looping
		sleep(15 MINUTES)
		if(wages_enabled)
			wagePayout()
