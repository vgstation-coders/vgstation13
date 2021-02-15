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
	station_account.money += station_allowance + WageBonuses()

	var/datum/transaction/T = new()
	T.purpose = "Nanotrasen station allowance"
	T.target_name = station_account.owner_name
	T.amount = "[station_allowance]"
	T.date = current_date_string
	T.time = worldtime2text()
	T.source_terminal = "Nanotrasen Payroll Server"
	station_account.transaction_log.Add(T)


/proc/wagePayout()
	//adding extra allowance due to latejoiners
	if (latejoiner_allowance > 0)
		station_allowance += latejoiner_allowance
		station_account.money += latejoiner_allowance

		var/datum/transaction/allowance = new()
		allowance.purpose = "Nanotrasen new employee allowance"
		allowance.target_name = station_account.owner_name
		allowance.amount = "[latejoiner_allowance]"
		allowance.date = current_date_string
		allowance.time = worldtime2text()
		allowance.source_terminal = "Nanotrasen Payroll Server"
		station_account.transaction_log.Add(allowance)

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

	var/datum/transaction/salaries = new()
	salaries.purpose = "Employee and Department salaries"
	salaries.target_name = station_account.owner_name
	salaries.amount = "-[station_account.money]"
	salaries.date = current_date_string
	salaries.time = worldtime2text()
	salaries.source_terminal = "Account Database"//todo: destroying the account database fucks up salaries? Sounds a bit easy to abuse, at least until the database gets moved to somwhere safe.
	station_account.transaction_log.Add(salaries)

	station_account.money = 0

	//actually paying the departments and employees
	for(var/datum/money_account/Acc in all_money_accounts)
		if(locate(Acc) in all_station_accounts)
			if(Acc.wage_gain)
				adjusted_wage_gain = round((Acc.wage_gain)*payroll_modifier)
				Acc.money += adjusted_wage_gain

				if(adjusted_wage_gain > 0)
					var/datum/transaction/T = new()
					T.purpose = "Nanotrasen employee payroll"
					T.target_name = Acc.owner_name
					T.amount = "[adjusted_wage_gain]"
					T.date = current_date_string
					T.time = worldtime2text()
					T.source_terminal = station_account.owner_name
					Acc.transaction_log.Add(T)

		else 	//non-station accounts get their money from magic, not that these accounts have any wages anyway
			Acc.money += Acc.wage_gain
			if(Acc.wage_gain > 0)
				var/datum/transaction/T = new()
				T.purpose = "mysterious transaction"
				T.target_name = Acc.owner_name
				T.amount = "[Acc.wage_gain]"
				T.date = current_date_string
				T.time = worldtime2text()
				T.source_terminal = "unknown"
				Acc.transaction_log.Add(T)

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
		if(H.z == STATION_Z && !isspace(get_area(H)) && !H.isDead())
			bonus += 1000

	return bonus

/proc/WageLoop()
	set waitfor = 0
	usr = null
	while(1) //looping
		sleep(15 MINUTES)
		if(wages_enabled)
			wagePayout()
