/datum/event/money_lotto
	endWhen = 2
	announceWhen = 1
	var/list/winning_numbers = list()

/datum/event/money_lotto/can_start()
	return (lotto_papers.len > 0) * (min(20,lotto_papers.len) * 4)

/datum/event/money_lotto/setup()
	for(var/i in 1 to LOTTO_SAMPLE)
		var/newnumber = 0
		do
			newnumber = rand(1,LOTTO_BALLCOUNT)
		while(newnumber in winning_numbers)
		winning_numbers.Add(newnumber)
	for(var/obj/machinery/vending/lotto/L in machines)
		L.winning_numbers = winning_numbers.Copy()

/datum/event/money_lotto/announce()
	var/datum/command_alert/lotto_results/LR = new
	LR.message = "A lotto number draw has been announced with the winning numbers [english_list(winning_numbers)]. Please return all lucky winning tickets to lotto vendors to redeem cash prizes"
	command_alert(LR)
