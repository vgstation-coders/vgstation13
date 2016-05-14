var/global/enable_wages = 0

/proc/wageSetup()
	WageLoop()

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
	captain_announce("Payroll has been processed. All accounts eligible have have recieved their paycheck as a direct deposit, including department accounts.")

/proc/WageLoop()
	set waitfor = 0
	usr = null
	src = null
	while(1)
		sleep(15 MINUTES)
		if(enable_wages)
			wagePayout()
