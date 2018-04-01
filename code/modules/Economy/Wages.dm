var/global/wages_enabled = 0
var/global/roundstart_enable_wages = 0

/proc/wageSetup()
	if(roundstart_enable_wages)
		wages_enabled = 1
	WageLoop()

/datum/command_alert/wages
	name = "wage payout"
	message = "Payroll has been processed. All accounts eligible have have received their paycheck as a direct deposit, including department accounts."
	noalert = 1

/proc/wagePayout()
	for(var/datum/money_account/Acc in all_money_accounts)
		if(Acc.wage_gain)
			Acc.money += Acc.wage_gain

			var/datum/transaction/T = new()
			T.purpose = "Nanotrasen employee payroll"
			T.amount = "[Acc.wage_gain]"
			T.date = current_date_string
			T.time = worldtime2text()
			T.source_terminal = "Nanotrasen Payroll Server"
			Acc.transaction_log.Add(T)
	command_alert(/datum/command_alert/wages)

/proc/WageLoop()
	set waitfor = 0
	usr = null
	src = null
	while(1) //looping
		sleep(15 MINUTES)
		if(wages_enabled)
			wagePayout()
