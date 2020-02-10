var/global/wages_enabled = 0
var/global/roundstart_enable_wages = 0

var/global/requested_payroll_amount = 0
var/payroll_reduction_modifier = 1
var/adjusted_wage_gain = 0

/proc/wageSetup()
	if(roundstart_enable_wages)
		wages_enabled = 1
	WageLoop()

/datum/command_alert/wages
	name = "wage payout"
	message = "Payroll has been processed. All eligible accounts have received their paycheck as a direct deposit."
	noalert = 1

/datum/command_alert/wage_reduction
	name = "wage reduction"
	message = "Payroll has been processed. Financial mismanagement has resulted in a average wage reduction. All eligible accounts have received the remainder of their paycheck as a direct deposit."
	noalert = 1

/proc/wagePayout()
	requested_payroll_amount = 0
	for(var/datum/money_account/Acc in all_money_accounts)
		if(Acc.wage_gain)
			requested_payroll_amount += Acc.wage_gain
	
	if(requested_payroll_amount > global.allowable_payroll_amount)
		payroll_reduction_modifier = global.allowable_payroll_amount / requested_payroll_amount 
	else
		payroll_reduction_modifier = 1

	for(var/datum/money_account/Acc in all_money_accounts)
		if(Acc.wage_gain)
			adjusted_wage_gain = round((Acc.wage_gain)*payroll_reduction_modifier)
			Acc.money += adjusted_wage_gain

			if(adjusted_wage_gain > 0)
				var/datum/transaction/T = new()
				T.purpose = "Nanotrasen employee payroll"
				T.target_name = Acc.owner_name
				T.amount = "[adjusted_wage_gain]"
				T.date = current_date_string
				T.time = worldtime2text()
				T.source_terminal = "Nanotrasen Payroll Server"
				Acc.transaction_log.Add(T)

	if(payroll_reduction_modifier == 1)
		command_alert(/datum/command_alert/wages)
	else
		command_alert(/datum/command_alert/wage_reduction)

/proc/WageLoop()
	set waitfor = 0
	usr = null
	src = null
	while(1) //looping
		sleep(15 MINUTES)
		if(wages_enabled)
			wagePayout()
