/datum/event/money_lotto
	endWhen = 2
	announceWhen = 1
	var/list/winning_numbers = list()

/datum/event/money_lotto/can_start()
	return (lotto_papers.len > 0) * (min(20,lotto_papers.len) * 4)

/datum/event/money_lotto/setup()
	if(LOTTO_BALLCOUNT < LOTTO_SAMPLE)
		CRASH("Always make the sample picked lower than the ballcount!")
	var/list/luck_skewed_papers = list()
	for(var/obj/item/weapon/paper/lotto_numbers/LN in lotto_papers)
		var/client/foundclient = directory[ckey(LN.fingerprintslast)]
		var/mob/foundmob = foundclient.mob
		luck_skewed_papers[LN] = foundmob.luck()
	var/obj/item/weapon/paper/lotto_numbers/picked_ticket = pickweight(luck_skewed_papers)
	var/client/foundclient = directory[ckey(picked_ticket.fingerprintslast)]
	var/mob/foundmob = foundclient.mob
	if(foundmob.lucky_prob(1/1000000, luckfactor = 1/12000, maxskew = 49.9)) //TODO: get combination calculation and put it in the first arg
		winning_numbers = picked_ticket.winning_numbers.Copy()
	else
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
